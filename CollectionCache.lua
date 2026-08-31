---@class WQATurbo
local WQA = WQATurbo

local IsQuestFlaggedCompleted = C_QuestLog.IsQuestFlaggedCompleted

--[[
Collection cache
================

The original WQATurbo AddMounts/AddPets implementation scans the entire
Mount Journal / Pet Journal once for every expansion that contains collectible
data.

For example, CreateQuestList() currently calls AddMounts three times and
AddPets four times. That means the same account-wide journals are traversed
seven times during one refresh.

This module preserves the original behaviour but changes the access pattern:

  1. Snapshot the journal once per CreateQuestList() refresh.
  2. Index ownership by the IDs WQA already uses:
       mount spellID
       pet companion/creatureID
  3. AddMounts/AddPets iterate only WQA's small static data tables and perform
     O(1) ownership lookups.

The snapshot is deliberately rebuilt once per refresh rather than cached
forever. This keeps behaviour aligned with upstream if the player's collection
or Pet Journal filters change, while still removing the repeated scans.
]]

WQA.collectionCache = WQA.collectionCache or {
	mountKnown = {},
	mountCollected = {},
	petKnown = {},
	petOwned = {},
	mountValid = false,
	petValid = false,
	mountJournalEntries = 0,
	petJournalEntries = 0,
	mountBuilds = 0,
	petBuilds = 0
}

---Invalidate both journal snapshots.
---Called once at the beginning of each CreateQuestList() rebuild.
function WQA:InvalidateCollectionCache()
	local cache = self.collectionCache
	cache.mountValid = false
	cache.petValid = false
end

---Build a spellID -> collection-state index for the Mount Journal.
function WQA:BuildMountCollectionCache()
	local cache = self.collectionCache

	wipe(cache.mountKnown)
	wipe(cache.mountCollected)

	local mountIDs = C_MountJournal.GetMountIDs() or {}
	cache.mountJournalEntries = #mountIDs
	cache.mountBuilds = cache.mountBuilds + 1

	for i = 1, #mountIDs do
		local mountID = mountIDs[i]
		local _, spellID, _, _, _, _, _, _, _, _, isCollected =
			C_MountJournal.GetMountInfoByID(mountID)

		if spellID then
			cache.mountKnown[spellID] = true
			cache.mountCollected[spellID] = isCollected == true
		end
	end

	cache.mountValid = true
end

---Build a companionID -> ownership index for the Pet Journal.
---
---GetPetInfoByIndex() may expose the same companion more than once, so an
---owned result always wins over an unowned result.
function WQA:BuildPetCollectionCache()
	local cache = self.collectionCache

	wipe(cache.petKnown)
	wipe(cache.petOwned)

	local total = C_PetJournal.GetNumPets() or 0
	cache.petJournalEntries = total
	cache.petBuilds = cache.petBuilds + 1

	for i = 1, total do
		local _, _, owned, _, _, _, _, _, _, _, companionID =
			C_PetJournal.GetPetInfoByIndex(i)

		if companionID then
			cache.petKnown[companionID] = true

			if owned then
				cache.petOwned[companionID] = true
			elseif cache.petOwned[companionID] == nil then
				cache.petOwned[companionID] = false
			end
		end
	end

	cache.petValid = true
end

---Optimized replacement for upstream AddMounts().
---@param mounts table
function WQA:AddMounts(mounts)
	local cache = self.collectionCache

	if not cache.mountValid then
		self:BuildMountCollectionCache()
	end

	-- Iterate only the addon data for this expansion instead of traversing the
	-- entire Mount Journal again.
	for _, mount in pairs(mounts) do
		local spellID = mount.spellID

		-- Upstream only sees mounts that exist in GetMountIDs(), so preserve
		-- that behaviour instead of treating an unknown spellID as uncollected.
		if spellID and cache.mountKnown[spellID] then
			local setting = self.db.profile.mounts[spellID]

			local enabled =
				not (
					setting == "disabled"
					or (
						setting == "exclusive"
						and self.db.profile.mounts.exclusive[spellID] ~= self.playerName
					)
				)

			if enabled then
				local forced = setting == "always"

				if not cache.mountCollected[spellID] or forced then
					for _, quest in pairs(mount.quest) do
						if not IsQuestFlaggedCompleted(quest.trackingID or 0) then
							self:AddRewardToQuest(quest.wqID, "CHANCE", mount.itemID)
						end
					end
				end
			end
		end
	end
end

---Optimized replacement for upstream AddPets().
---@param pets table
function WQA:AddPets(pets)
	local cache = self.collectionCache

	if not cache.petValid then
		self:BuildPetCollectionCache()
	end

	-- Upstream searches the static pet table for each journal entry. Reverse
	-- that lookup: visit each WQA pet once and check ownership in O(1).
	--
	-- The upstream loop breaks after the first match for a companionID, so
	-- preserve that property if a data table ever contains duplicates.
	local processed = {}

	for _, pet in pairs(pets) do
		local companionID = pet.creatureID

		if
			companionID
			and not processed[companionID]
			and cache.petKnown[companionID]
		then
			processed[companionID] = true

			local setting = self.db.profile.pets[companionID]

			local enabled =
				not (
					setting == "disabled"
					or (
						setting == "exclusive"
						and self.db.profile.pets.exclusive[companionID] ~= self.playerName
					)
				)

			if enabled then
				local forced = setting == "always"

				if not cache.petOwned[companionID] or forced then
					if pet.emissary == true then
						self:AddEmissaryReward(pet.questID, "CHANCE", pet.itemID)
					end

					if pet.source and pet.source.type == "ITEM" then
						self.itemList[pet.source.itemID] = true
					end

					if pet.questID then
						self:AddRewardToQuest(pet.questID, "CHANCE", pet.itemID)
					end

					if pet.quest then
						for _, quest in pairs(pet.quest) do
							if not IsQuestFlaggedCompleted(quest.trackingID) then
								self:AddRewardToQuest(quest.wqID, "CHANCE", pet.itemID)
							end
						end
					end
				end
			end
		end
	end
end

-- Preserve upstream semantics by rebuilding the account-wide ownership
-- snapshots once for each CreateQuestList() refresh. AddMounts/AddPets can then
-- be called repeatedly by the expansion loop without rescanning the journals.
local OriginalCreateQuestList = WQA.CreateQuestList

function WQA:CreateQuestList(...)
	self:InvalidateCollectionCache()
	return OriginalCreateQuestList(self, ...)
end

---Small diagnostic command:
---  /wqacache
function WQA:CollectionCacheSlash()
	local cache = self.collectionCache

	print("|cff00ccffWQA CACHE|r collection snapshots")
	print(string.format(
		"mounts: journal=%d builds=%d valid=%s",
		cache.mountJournalEntries or 0,
		cache.mountBuilds or 0,
		tostring(cache.mountValid)
	))
	print(string.format(
		"pets:   journal=%d builds=%d valid=%s",
		cache.petJournalEntries or 0,
		cache.petBuilds or 0,
		tostring(cache.petValid)
	))
end

WQA:RegisterChatCommand("wqacache", "CollectionCacheSlash")
