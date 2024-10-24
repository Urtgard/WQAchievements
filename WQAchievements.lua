---@class WQAchievements
local WQA = WQAchievements

local LibQTip = LibStub("LibQTip-1.0")

-- Blizzard
local IsActive = C_TaskQuest.IsActive
local GetQuestTagInfo = C_QuestLog.GetQuestTagInfo
local GetBountiesForMapID = C_QuestLog.GetBountiesForMapID
local GetTitleForQuestID = C_QuestLog.GetTitleForQuestID
local GetCurrencyLink = C_CurrencyInfo.GetCurrencyLink
local IsQuestFlaggedCompleted = C_QuestLog.IsQuestFlaggedCompleted
local L = WQA.L

local newOrder
do
	local current = 0
	function newOrder()
		current = current + 1
		return current
	end
end

WQA.data.custom = { wqID = "", rewardID = "", rewardType = "none", questType = "WORLD_QUEST" }
WQA.data.custom.mission = { missionID = "", rewardID = "", rewardType = "none" }
--WQA.data.customReward = 0

local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local dataobj =
	ldb:NewDataObject(
		"WQAchievements",
		{
			type = "data source",
			text = "WQA",
			icon = "Interface\\Icons\\INV_Misc_Map06"
		}
	)

local icon = LibStub("LibDBIcon-1.0")

function WQA:OnInitialize()
	-- Remove data for the other faction
	local faction = UnitFactionGroup("player")
	for k, v in pairs(self.data) do
		for kk, vv in pairs(v) do
			if type(vv) == "table" then
				for kkk, vvv in pairs(vv) do
					if vvv.faction and not (vvv.faction == faction) then
						self.data[k][kk][kkk] = nil
					end
				end
			end
		end
	end
	self.faction = faction

	-- Defaults
	local defaults = {
		char = {
			["*"] = {
				["profession"] = {
					["*"] = {
						isMaxLevel = true
					}
				}
			}
		},
		profile = {
			options = {
				["*"] = true,
				chat = true,
				PopUp = false,
				popupRememberPosition = false,
				popupX = 600,
				popupY = 800,
				zone = { ["*"] = true },
				reward = {
					gear = {
						["*"] = true,
						itemLevelUpgradeMin = 1,
						PercentUpgradeMin = 1,
						unknownSource = false,
						azeriteTraits = "",
						conduit = false
					},
					general = {
						gold = false,
						goldMin = 0,
						worldQuestType = {
							["*"] = true
						}
					},
					reputation = { ["*"] = false },
					currency = {},
					craftingreagent = { ["*"] = false },
					["*"] = {
						["*"] = true,
						profession = {
							["*"] = {
								skillup = true
							}
						}
					}
				},
				emissary = { ["*"] = false },
				missionTable = {
					reward = {
						gold = false,
						goldMin = 0,
						["*"] = {
							["*"] = false
						}
					}
				},
				delay = 5,
				LibDBIcon = { hide = false }
			},
			["achievements"] = { exclusive = {}, ["*"] = "default" },
			["mounts"] = { exclusive = {}, ["*"] = "default" },
			["pets"] = { exclusive = {}, ["*"] = "default" },
			["toys"] = { exclusive = {}, ["*"] = "default" },
			custom = {
				["*"] = { ["*"] = true }
			},
			["*"] = { ["*"] = true }
		},
		global = {
			completed = { ["*"] = false },
			custom = {
				["*"] = { ["*"] = false }
			}
		}
	}
	self.db = LibStub("AceDB-3.0"):New("WQADB", defaults, true)

	-- copy old data
	if type(self.db.global.custom) == "table" then
		for k, v in pairs(self.db.global.custom) do
			if type(k) == "number" then
				self.db.global.custom.worldQuest[k] = v
				self.db.global.custom[k] = nil
			end
		end
	end
	if type(self.db.global.customReward) == "table" then
		for k, v in pairs(self.db.global.customReward) do
			self.db.global.custom.worldQuestReward[k] = true
		end
		self.db.global.customReward = nil
	end

	-- Minimap Icon
	icon:Register("WQAchievements", dataobj, self.db.profile.options.LibDBIcon)
end

function WQA:OnEnable()
	local name, server = UnitFullName("player")
	self.playerName = name .. "-" .. server
	------------------
	-- 	Options
	------------------
	LibStub("AceConfig-3.0"):RegisterOptionsTable(
		"WQAchievements",
		function()
			return self:GetOptions()
		end
	)
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("WQAchievements", "WQAchievements")
	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("WQAProfiles", profiles)
	self.optionsFrame.Profiles =
		LibStub("AceConfigDialog-3.0"):AddToBlizOptions("WQAProfiles", "Profiles", "WQAchievements")

	self.event = CreateFrame("Frame")
	self.event:RegisterEvent("PLAYER_ENTERING_WORLD")
	self.event:RegisterEvent("GARRISON_MISSION_LIST_UPDATE")
	self.event:SetScript(
		"OnEvent",
		function(...)
			local _, name, id = ...
			if name == "PLAYER_ENTERING_WORLD" then
				self:ScheduleTimer(
					function()
						for i = 1, #self.ZoneIDList do
							for _, mapID in pairs(self.ZoneIDList[i]) do
								if self.db.profile.options.zone[mapID] == true then
									local quests = C_TaskQuest.GetQuestsOnMap(mapID)
									if quests then
										for j = 1, #quests do
											local questID = quests[j].questID
											local numQuestRewards = GetNumQuestLogRewards(questID)
											if numQuestRewards > 0 then
												GetQuestLogRewardInfo(1, questID)
											end
										end
									end
								end
							end
						end
					end,
					self.db.profile.options.delay
				)

				self.event:UnregisterEvent("PLAYER_ENTERING_WORLD")
				self:ScheduleTimer("Show", self.db.profile.options.delay + 1, nil, true)
				self:ScheduleTimer(
					function()
						self:Show("new", true)
						self:ScheduleRepeatingTimer("Show", 30 * 60, "new", true)
					end,
					(32 - (date("%M") % 30)) * 60
				)
			elseif name == "QUEST_LOG_UPDATE" or name == "GET_ITEM_INFO_RECEIVED" then
				self.event:UnregisterEvent("QUEST_LOG_UPDATE")
				self.event:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
				self:CancelTimer(self.timer)
				if GetTime() - self.start > 1 then
					self:Reward()
				else
					self:ScheduleTimer("Reward", 1)
				end
			elseif name == "PLAYER_REGEN_ENABLED" then
				self.event:UnregisterEvent("PLAYER_REGEN_ENABLED")
				self:Show("new", true)
			elseif name == "QUEST_TURNED_IN" then
				self.db.global.completed[id] = true
			elseif name == "GARRISON_MISSION_LIST_UPDATE" then
				self:CheckMissions()
			end
		end
	)

	C_AddOns.LoadAddOn("Blizzard_GarrisonUI")
end

WQA:RegisterChatCommand("wqa", "slash")

function WQA:slash(input)
	local arg1 = string.lower(input)

	if arg1 == "" then
		--self:CheckWQ()
		self:Show()
	elseif arg1 == "new" then
		self:Show("new")
	elseif arg1 == "popup" then
		self:Show("popup")
	end
end

function WQA:CreateQuestList()
	self:Debug("CreateQuestList")
	self.questList = {}
	self.questPinList = {}
	self.questPinMapList = {}
	self.missionList = {}
	self.questFlagList = {}
	self.Criterias.AreaPoi.list = {}

	for expansionID = 7, 11 do
		local data = self.data[expansionID]

		if (data.achievements) then
			for _, v in pairs(data.achievements) do
				self.Achievements:Register(v)
			end
		end

		if (data.mounts) then
			self:AddMounts(data.mounts)
		end

		if (data.pets) then
			self:AddPets(data.pets)
		end

		if (data.toys) then
			self:AddToys(data.toys)
		end

		if (data.miscellaneous) then
			self:AddMiscellaneous(data.miscellaneous)
		end
	end


	self:AddCustom()
	self:Special()
	self:Reward()
	self:EmissaryReward()
end

function WQA:AddMounts(mounts)
	for i, id in pairs(C_MountJournal.GetMountIDs()) do
		local n, spellID, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(id)
		local forced = false

		if
			not (self.db.profile.mounts[spellID] == "disabled" or
				(self.db.profile.mounts[spellID] == "exclusive" and self.db.profile.mounts.exclusive[spellID] ~= self.playerName))
		then
			if self.db.profile.mounts[spellID] == "always" then
				forced = true
			end

			if not isCollected or forced then
				for _, mount in pairs(mounts) do
					if spellID == mount.spellID then
						for _, v in pairs(mount.quest) do
							if not IsQuestFlaggedCompleted(v.trackingID or 0) then
								self:AddRewardToQuest(v.wqID, "CHANCE", mount.itemID)
							end
						end
					end
				end
			end
		end
	end
end

function WQA:AddPets(pets)
	local total = C_PetJournal.GetNumPets()
	for i = 1, total do
		local petID, _, owned, _, _, _, _, _, _, _, companionID = C_PetJournal.GetPetInfoByIndex(i)
		local forced = false

		if
			not (self.db.profile.pets[companionID] == "disabled" or
				(self.db.profile.pets[companionID] == "exclusive" and self.db.profile.pets.exclusive[companionID] ~= self.playerName))
		then
			if self.db.profile.pets[companionID] == "always" then
				forced = true
			end

			if not owned or forced then
				for _, pet in pairs(pets) do
					if companionID == pet.creatureID then
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
							for _, v in pairs(pet.quest) do
								if not IsQuestFlaggedCompleted(v.trackingID) then
									self:AddRewardToQuest(v.wqID, "CHANCE", pet.itemID)
								end
							end
						end

						break
					end
				end
			end
		end
	end
end

function WQA:AddToys(toys)
	for _, toy in pairs(toys) do
		local itemID = toy.itemID
		local forced = false

		if
			not (self.db.profile.toys[itemID] == "disabled" or
				(self.db.profile.toys[itemID] == "exclusive" and self.db.profile.toys.exclusive[itemID] ~= self.playerName))
		then
			if self.db.profile.toys[itemID] == "always" then
				forced = true
			end

			if not PlayerHasToy(toy.itemID) or forced then
				if toy.source and toy.source.type == "ITEM" then
					self.itemList[toy.source.itemID] = true
				else
					if toy.questID then
						self:AddRewardToQuest(toy.questID, "CHANCE", toy.itemID)
					else
						for _, v in pairs(toy.quest) do
							if not IsQuestFlaggedCompleted(v.trackingID) then
								self:AddRewardToQuest(v.wqID, "CHANCE", toy.itemID)
							end
						end
					end
				end
			end
		end
	end
end

function WQA:AddCustom()
	-- Custom World Quests
	if type(self.db.global.custom.worldQuest) == "table" then
		for questID, v in pairs(self.db.global.custom.worldQuest) do
			if self.db.profile.custom.worldQuest[questID] == true then
				self:AddRewardToQuest(questID, "CUSTOM")
				if v.questType == "QUEST_FLAG" then
					self.questFlagList[questID] = true
				elseif v.questType == "QUEST_PIN" and v.mapID then
					C_QuestLine.RequestQuestLinesForMap(v.mapID)
					self.questPinMapList[v.mapID] = true
					self.questPinList[questID] = true
				end
			end
		end
	end

	-- Custom Missions
	if type(self.db.global.custom.mission) == "table" then
		for k, v in pairs(self.db.global.custom.mission) do
			if self.db.profile.custom.mission[k] == true then
				self:AddRewardToMission(k, "CUSTOM")
			end
		end
	end
end

function WQA:AddRewardToMission(missionID, rewardType, reward)
	if not self.missionList[missionID] then
		self.missionList[missionID] = {}
	end
	local l = self.missionList[missionID]

	self:AddReward(l, rewardType, reward)
end

function WQA:AddRewardToQuest(questID, rewardType, reward, emissary)
	if not self.questList[questID] then
		self.questList[questID] = {}
	end
	local l = self.questList[questID]

	self:AddReward(l, rewardType, reward, emissary)
end

function WQA:AddEmissaryReward(questID, rewardType, reward)
	self:AddRewardToQuest(questID, rewardType, reward, true)
end

WQA.first = false
function WQA:Show(mode, auto)
	if auto and self.db.profile.options.delayCombat == true and UnitAffectingCombat("player") then
		self.event:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end
	self:Debug("Show", mode)
	self:CreateQuestList()
	self:CheckWQ(mode)
	self.first = true
end

function WQA:CheckWQ(mode)
	self:Debug("CheckWQ")
	if self.rewards ~= true or self.emissaryRewards ~= true then
		self:Debug("NoRewards")
		self:ScheduleTimer("CheckWQ", .4, mode)
		return
	end

	local activeQuests = {}
	local newQuests = {}
	local retry = false
	for questID, _ in pairs(self.questList) do
		if
			IsActive(questID) or self:EmissaryIsActive(questID) or self:isQuestPinActive(questID) or
			self:IsQuestFlaggedCompleted(questID)
		then
			local questLink = self:GetTaskLink({ id = questID, type = "WORLD_QUEST" })
			local link
			for k, v in pairs(self.questList[questID].reward) do
				if k == "custom" or k == "professionSkillup" or k == "gold" then
					link = true
				else
					link = self:GetRewardLinkByID(questID, k, v, 1)
				end
				if not link then
					self:Debug(questID, k, v, 1)
					retry = true
				else
					self:SetRewardLinkByID(questID, k, v, 1, link)
				end

				if k == "achievement" or k == "chance" or k == "azeriteTraits" then
					for i = 2, #v do
						link = self:GetRewardLinkByID(questID, k, v, i)
						if not link then
							self:Debug(questID, k, v, i)
							retry = true
						else
							self:SetRewardLinkByID(questID, k, v, i, link)
						end
					end
				end
			end
			if (not questLink or not link) then
				self:Debug(questID, questLink, link)
				retry = true
			else
				activeQuests[questID] = true
				if not self.watched[questID] then
					newQuests[questID] = true
				end
			end
		end
	end

	local activeMissions = self:CheckMissions()
	local newMissions = {}
	if type(activeMissions) == "table" then
		for missionID, _ in pairs(activeMissions) do
			local link = false
			for k, v in pairs(self.missionList[missionID].reward) do
				if k == "custom" or k == "professionSkillup" or k == "gold" then
					link = true
				else
					link = self:GetRewardLinkByMissionID(missionID, k, v, 1)
				end
				if not link then
					retry = true
				else
					self:SetRewardLinkByMissionID(missionID, k, v, 1, link)
				end
			end
			if not link then
				retry = true
			else
				if not self.watchedMissions[missionID] then
					newMissions[missionID] = true
				end
			end
		end
	else
		retry = true
	end

	local pois = self.Criterias.AreaPoi:Check()

	if pois.retry then
		retry = true
	end

	if retry == true then
		self:Debug("NoLink")
		self:ScheduleTimer("CheckWQ", 1, mode)
		return
	end

	self.activeTasks = {}
	for id in pairs(activeQuests) do
		table.insert(self.activeTasks, { id = id, type = "WORLD_QUEST" })
	end
	for id in pairs(activeMissions) do
		table.insert(self.activeTasks, { id = id, type = "MISSION" })
	end
	for poiId, mapIds in pairs(pois.active) do
		for mapId in pairs(mapIds) do
			table.insert(self.activeTasks, { id = poiId, mapId = mapId, type = "AREA_POI" })
		end
	end

	self.activeTasks = self:SortQuestList(self.activeTasks)

	self.newTasks = {}
	for id in pairs(newQuests) do
		self.watched[id] = true
		table.insert(self.newTasks, { id = id, type = "WORLD_QUEST" })
	end
	for id in pairs(newMissions) do
		self.watchedMissions[id] = true
		table.insert(self.newTasks, { id = id, type = "MISSION" })
	end
	for poiId, mapIds in pairs(pois.new) do
		for mapId in pairs(mapIds) do
			if not self.Criterias.AreaPoi.watched[poiId] then
				self.Criterias.AreaPoi.watched[poiId] = {}
			end
			self.Criterias.AreaPoi.watched[poiId][mapId] = true

			table.insert(self.newTasks, { id = poiId, mapId = mapId, type = "AREA_POI" })
		end
	end

	if mode == "new" then
		self:AnnounceChat(self.newTasks, self.first)
		if self.db.profile.options.PopUp == true then
			self:AnnouncePopUp(self.newTasks, self.first)
		end
	elseif mode == "popup" then
		self:AnnouncePopUp(self.activeTasks)
	elseif mode == "LDB" then
		self:AnnounceLDB(self.activeTasks)
	else
		self:AnnounceChat(self.activeTasks)
		if self.db.profile.options.PopUp == true then
			self:AnnouncePopUp(self.activeTasks)
		end
	end

	self:UpdateLDBText(next(self.activeTasks), next(self.newTasks))
end

function WQA:link(x)
	if not x then
		return ""
	end
	local t = string.upper(x.type)
	if t == "ACHIEVEMENT" then
		return GetAchievementLink(x.id)
	elseif t == "ITEM" then
		return select(2, GetItemInfo(x.id))
	else
		return ""
	end
end

function WQA:GetRewardForID(questID, key, type)
	local l
	if type == "MISSION" then
		l = self.missionList[questID].reward
	else
		l = self.questList[questID].reward
	end

	local r = ""
	if l then
		if l.item then
			if l.item then
				if l.item.transmog then
					r = r .. l.item.transmog
				end
				if l.item.itemLevelUpgrade then
					if r ~= "" then
						r = r .. " "
					end
					r = r .. "|cFF00FF00+" .. l.item.itemLevelUpgrade .. " iLvl|r"
				end
				if l.item.itemPercentUpgrade then
					if r ~= "" then
						r = r .. ", "
					end
					r = r .. "|cFF00FF00+" .. l.item.itemPercentUpgrade .. "%|r"
				end
				if l.item.AzeriteArmorCache then
					for i = 1, 5, 2 do
						local upgrade = l.item.AzeriteArmorCache[i]
						if upgrade > 0 then
							r = r .. "|cFF00FF00+" .. upgrade .. " iLvl|r"
						elseif upgrade < 0 then
							r = r .. "|cFFFF0000" .. upgrade .. " iLvl|r"
						else
							r = r .. "±" .. upgrade
						end
						if i ~= 5 then
							r = r .. " / "
						end
					end
				end
				if l.item.cache then
					local cache = l.item.cache
					local upgradeChance = cache.upgradeNum / cache.n
					upgradeChance = 1 / 2 * upgradeChance + .5
					upgradeChance = string.format("%X", (1 - upgradeChance) * 255)
					if string.len(upgradeChance) == 1 then
						upgradeChance = "0" .. upgradeChance
					end
					r =
						r ..
						"|cFF" ..
						upgradeChance ..
						"FF" ..
						upgradeChance .. cache.upgradeNum .. "/" .. cache.n .. " max +" .. cache.upgradeMax .. "|r"
					local item = {
						itemLink = itemLink,
						cache = { upgradeNum = upgradeNum, n = n, upgradeMax = upgradeMax }
					}
				end
			end
			r = l.item.itemLink .. " " .. r
		end
		if l.currency and key ~= "item" then
			r = r .. l.currency.amount .. " " .. l.currency.name
		end
	end
	return r
end

function WQA:AnnounceChat(tasks, silent)
	if self.db.profile.options.chat == false then
		return
	end
	if next(tasks) == nil then
		if silent ~= true then
			print(L["NO_QUESTS"])
		end
		return
	end

	local output = L["WQChat"]
	print(output)
	local expansion, zoneID
	for _, task in ipairs(tasks) do
		local text, i = "", 0

		if self.db.profile.options.chatShowExpansion == true then
			if self:GetExpansion(task) ~= expansion then
				expansion = self:GetExpansion(task)
				print(self:GetExpansionName(expansion))
			end
		end

		if self.db.profile.options.chatShowZone == true then
			if self:GetTaskZoneID(task) ~= zoneID then
				zoneID = self:GetTaskZoneID(task)
				print(self:GetTaskZoneName(task))
			end
		end

		local l
		if task.type == "WORLD_QUEST" then
			l = self.questList[task.id]
		elseif task.type == "MISSION" then
			l = self.missionList[task.id]
		elseif task.type == "AREA_POI" then
			l = self.Criterias.AreaPoi.list[task.id][task.mapId]
		end

		local rewards = l.reward

		local more
		for k, v in pairs(rewards) do
			local rewardText = self:GetRewardTextByID(task.id, k, v, 1, task.type)
			if k == "achievement" or k == "chance" or k == "azeriteTraits" then
				for j = 2, 3 do
					local t = self:GetRewardTextByID(task.id, k, v, j, task.type)
					if t then
						rewardText = rewardText .. " & " .. t
					end
				end
				if self:GetRewardTextByID(task.id, k, v, 4, task.type) then
					more = true
				end
			end

			i = i + 1
			if i > 1 then
				text = text .. " & " .. rewardText
			else
				text = rewardText
			end
		end
		if more == true then
			text = text .. " & ..."
		end

		if self.db.profile.options.chatShowTime then
			output = "   " ..
				string.format(L["WQforAchTime"], self:GetTaskLink(task), self:formatTime(self:GetTaskTime(task)), text)
		else
			output = "   " .. string.format(L["WQforAch"], self:GetTaskLink(task), text)
		end

		print(output)
	end
end

local inspectScantip = CreateFrame("GameTooltip", "WorldQuestListInspectScanningTooltip", nil, "GameTooltipTemplate")
inspectScantip:SetOwner(UIParent, "ANCHOR_NONE")

local EquipLocToSlot1 = {
	INVTYPE_HEAD = 1,
	INVTYPE_NECK = 2,
	INVTYPE_SHOULDER = 3,
	INVTYPE_BODY = 4,
	INVTYPE_CHEST = 5,
	INVTYPE_ROBE = 5,
	INVTYPE_WAIST = 6,
	INVTYPE_LEGS = 7,
	INVTYPE_FEET = 8,
	INVTYPE_WRIST = 9,
	INVTYPE_HAND = 10,
	INVTYPE_FINGER = 11,
	INVTYPE_TRINKET = 13,
	INVTYPE_CLOAK = 15,
	INVTYPE_WEAPON = 16,
	INVTYPE_SHIELD = 17,
	INVTYPE_2HWEAPON = 16,
	INVTYPE_WEAPONMAINHAND = 16,
	INVTYPE_RANGED = 16,
	INVTYPE_RANGEDRIGHT = 16,
	INVTYPE_WEAPONOFFHAND = 17,
	INVTYPE_HOLDABLE = 17,
	INVTYPE_TABARD = 19
}
local EquipLocToSlot2 = {
	INVTYPE_FINGER = 12,
	INVTYPE_TRINKET = 14,
	INVTYPE_WEAPON = 17
}

ItemTooltipScan = CreateFrame("GameTooltip", "WQTItemTooltipScan", UIParent, "InternalEmbeddedItemTooltipTemplate")
ItemTooltipScan.texts = {
	_G["WQTItemTooltipScanTooltipTextLeft1"],
	_G["WQTItemTooltipScanTooltipTextLeft2"],
	_G["WQTItemTooltipScanTooltipTextLeft3"],
	_G["WQTItemTooltipScanTooltipTextLeft4"]
}
ItemTooltipScan.patern = ITEM_LEVEL:gsub("%%d", "(%%d+)") --from LibItemUpgradeInfo-1.0

local ReputationItemList = {
	-- Army of the Light Insignia
	[152957] = 2165,
	[152955] = 2165,
	[152956] = 2165,
	[152958] = 2165,
	[152960] = 2170,
	-- Argussian Reach Insignia
	[152954] = 2170,
	[152959] = 2170,
	[152961] = 2170,
	[141342] = 1894,
	-- The Wardens
	[139025] = 1894,
	[141991] = 1894,
	[147415] = 1894,
	[150929] = 1894,
	[146945] = 1894,
	[146939] = 1894,
	[141340] = 1900,
	-- Court of Farondis
	[139023] = 1900,
	[147410] = 1900,
	[141989] = 1900,
	[150927] = 1900,
	[146937] = 1900,
	[146943] = 1900,
	[139021] = 1883,
	-- Dreamweavers
	[141988] = 1883,
	[147411] = 1883,
	[141339] = 1883,
	[150926] = 1883,
	[146942] = 1883,
	[146936] = 1883,
	-- Highmountain Tribe
	[141341] = 1828,
	[139024] = 1828,
	[141990] = 1828,
	[147412] = 1828,
	[150928] = 1828,
	[146944] = 1828,
	[146938] = 1828,
	-- Valarjar
	[139020] = 1948,
	[141338] = 1948,
	[141987] = 1948,
	[147414] = 1948,
	[146935] = 1948,
	[146941] = 1948,
	[150925] = 1948,
	-- The Nightfallen
	[141343] = 1859,
	[141992] = 1859,
	[139026] = 1859,
	[147413] = 1859,
	[150930] = 1859,
	[146940] = 1859,
	[146946] = 1859
}

local ReputationCurrencyList = {
	[1579] = 2164, -- Champions of Azeroth
	[1598] = 2163, -- Tortollan Seekers
	[1593] = 2160, -- Proudmoore Admiralty
	[1592] = 2161, -- Order of Embers
	[1594] = 2162, -- Storm's Wake
	[1599] = 2159, -- 7th Legion
	[1597] = 2103, -- Zandalari Empire
	[1595] = 2156, -- Talanji's Expedition
	[1596] = 2158, -- Voldunai
	[1600] = 2157, -- The Honorbound
	[1742] = 2391, -- Rustbolt Resistance
	[1739] = 2400, -- Waveblade Ankoan
	[1757] = 2417, -- Uldum Accord
	[1758] = 2415, -- Rajani
	[1738] = 2373, -- The Unshackled
	[1807] = 2413, -- Court of Harvesters
	[1907] = 2470, -- Death's Advance
	[1804] = 2407, -- The Ascended
	[1982] = 2478, -- The Enlightened
	[1805] = 2410, -- The Undying Army
	[1806] = 2465, -- The Wild Hunt
	[1880] = 2432, -- Ve'nari
	[2819] = 2615, -- Azerothian Archives
	[2031] = 2507, -- Dragonscale Expedition
	[2652] = 2574, -- Dream Wardens
	[2109] = 2511, -- Iskaara Tuskarr
	[2420] = 2564, -- Loamm Niffen
	[2108] = 2503, -- Maruuk Centaur
	[2106] = 2510, -- Valdrakken Accord
	[2902] = 2594, -- The Assembly of the Deeps
	[2899] = 2570, -- Hallowfall Arathi
	[2903] = 2600, -- The Severed Threads
	[2897] = 2590 -- Council of Dornogal
}

function WQA:Reward()
	self:Debug("Reward")

	self.event:UnregisterEvent("QUEST_LOG_UPDATE")
	self.event:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
	self.rewards = false
	local retry = false

	-- Azerite Traits
	if self.db.profile.options.reward.gear.azeriteTraits ~= "" then
		self.azeriteTraitsList = {}
		for spellID in string.gmatch(self.db.profile.options.reward.gear.azeriteTraits, "(%d+)") do
			self.azeriteTraitsList[tonumber(spellID)] = true
		end
	end

	for i in pairs(self.ZoneIDList) do
		for _, mapID in pairs(self.ZoneIDList[i]) do
			if self.db.profile.options.zone[mapID] == true then
				local quests = C_TaskQuest.GetQuestsOnMap(mapID)
				if quests then
					for i = 1, #quests do
						local questID = quests[i].questID
						local questTagInfo = GetQuestTagInfo(questID)
						local worldQuestType = 0
						if questTagInfo then
							worldQuestType = questTagInfo.worldQuestType
						end

						if self.questList[questID] and not self.db.profile.options.reward.general.worldQuestType[worldQuestType] then
							self.questList[questID] = nil
						end

						if
							self.db.profile.options.zone[C_TaskQuest.GetQuestZoneID(questID)] == true and
							self.db.profile.options.reward.general.worldQuestType[worldQuestType]
						then
							-- 100 different World Quests achievements
							if QuestUtils_IsQuestWorldQuest(questID) and not self.db.global.completed[questID] then
								local zoneID = C_TaskQuest.GetQuestZoneID(questID)
								local exp = 0
								for expansion, zones in pairs(WQA.ZoneIDList) do
									for _, v in pairs(zones) do
										if zoneID == v then
											exp = expansion
										end
									end
								end

								if
									self.db.profile.achievements[11189] ~= "disabled" and not select(4, GetAchievementInfo(11189)) and exp == 7 and
									mapID ~= 830 and
									mapID ~= 885 and
									mapID ~= 882
								then
									self:AddRewardToQuest(questID, "ACHIEVEMENT", 11189)
								elseif
									self.db.profile.achievements[13144] ~= "disabled" and not select(4, GetAchievementInfo(13144)) and exp == 8
								then
									self:AddRewardToQuest(questID, "ACHIEVEMENT", 13144)
								elseif
									self.db.profile.achievements[14758] ~= "disabled" and not select(4, GetAchievementInfo(14758)) and exp == 9
								then
									self:AddRewardToQuest(questID, "ACHIEVEMENT", 14758)
								end
							end

							if HaveQuestData(questID) and not HaveQuestRewardData(questID) then
								C_TaskQuest.RequestPreloadRewardData(questID)
								retry = true
							end
							retry = self:CheckItems(questID) or retry
							self:CheckCurrencies(questID)

							-- Profession
							local tradeskillLineID
							if questTagInfo then
								tradeskillLineID = GetQuestTagInfo(questID).tradeskillLineID
							end

							if tradeskillLineID then
								local professionName = C_TradeSkillUI.GetTradeSkillDisplayName(tradeskillLineID)
								local zoneID = C_TaskQuest.GetQuestZoneID(questID)
								local exp = 0
								for expansion, zones in pairs(WQA.ZoneIDList) do
									for _, v in pairs(zones) do
										if zoneID == v then
											exp = expansion
										end
									end
								end

								if
									not self.db.char[exp].profession[tradeskillLineID].isMaxLevel and
									self.db.profile.options.reward[exp].profession[tradeskillLineID].skillup
								then
									self:AddRewardToQuest(questID, "PROFESSION_SKILLUP", professionName)
								end
							end
						end
					end
				end
			end
		end
	end

	if retry == true then
		self.Debug("|cFFFF0000<<<RETRY>>>|r")
		self.start = GetTime()
		self.timer =
			self:ScheduleTimer(
				function()
					self:Reward()
				end,
				2
			)
		self.event:RegisterEvent("QUEST_LOG_UPDATE")
		self.event:RegisterEvent("GET_ITEM_INFO_RECEIVED")
	else
		self.rewards = true
	end
end

local weaponCache = {
	[165872] = true, -- 7th Legion Equipment Cache
	[165867] = true, -- Kul Tiran Weapons Cache
	[165871] = true, -- Honorbound Equipment Cache
	[165863] = true -- Zandalari Weapons Cache
}
local armorCache = {
	[165872] = true, -- 7th Legion Equipment Cache
	[165870] = true, -- Order of Embers Equipment Cache
	[165868] = true, -- Storm's Wake Equipment Cache
	[165869] = true, -- Proudmoore Admiralty Equipment Cache
	[165871] = true, -- Honorbound Equipment Cache
	[165865] = true, -- Nazmir Expeditionary Equipment Cache
	[165864] = true, -- Voldunai Equipment Cache
	[165866] = true -- Zandalari Empire Equipment Cache
}
local jewelryCache = {
	[165785] = true -- Tortollan Trader's Stock
}

-- CanIMogIt
function WQA:IsTransmogable(itemLink)
	-- Returns whether the item is transmoggable or not.

	-- White items are not transmoggable.
	local quality = select(3, GetItemInfo(itemLink))
	if quality == nil then
		return
	end
	if quality <= 1 then
		return false
	end

	local itemID, _, _, slotName = GetItemInfoInstant(itemLink)

	-- See if the game considers it transmoggable
	local transmoggable = select(3, C_Transmog.CanTransmogItem(itemID))
	if transmoggable == false then
		return false
	end

	-- See if the item is in a valid transmoggable slot
	local slot = EquipLocToSlot1[slotName]
	if slot == nil or slot == 11 or slot == 13 or slot == 2 then
		return false
	end
	return true
end

function WQA:CheckItems(questID, isEmissary)
	local numQuestRewards = GetNumQuestLogRewards(questID)

	if numQuestRewards == 0 then
		return false
	end

	local retryArray = {}

	for rewardIndex = 1, numQuestRewards do
		retryArray[rewardIndex] = self:CheckReward(questID, isEmissary, rewardIndex)
	end

	for _, retry in pairs(retryArray) do
		if retry then return true end
	end

	return false
end

function WQA:CheckReward(questID, isEmissary, rewardIndex)
	local retry = false

	local itemName, itemTexture, quantity, quality, isUsable, itemID = GetQuestLogRewardInfo(rewardIndex,
		questID)
	if itemID then
		inspectScantip:SetQuestLogItem("reward", rewardIndex, questID)
		local itemLink = select(2, inspectScantip:GetItem())
		if not itemLink then
			return true
		elseif string.find(itemLink, "%[]") then
			return true
		end

		local itemName,
		_,
		itemRarity,
		itemLevel,
		itemMinLevel,
		itemType,
		itemSubType,
		itemStackCount,
		itemEquipLoc,
		itemTexture,
		itemSellPrice,
		itemClassID,
		itemSubClassID = GetItemInfo(itemLink)
		local expacID = self:GetExpansionByQuestID(questID)

		-- Ask Pawn if this is an Upgrade
		if PawnIsItemAnUpgrade and self.db.profile.options.reward.gear.PawnUpgrade then
			local Item = PawnGetItemData(itemLink)
			if Item then
				local UpgradeInfo, BestItemFor, SecondBestItemFor, NeedsEnhancements = PawnIsItemAnUpgrade(Item)
				if
					UpgradeInfo and UpgradeInfo[1].PercentUpgrade * 100 >= self.db.profile.options.reward.gear.PercentUpgradeMin and
					UpgradeInfo[1].PercentUpgrade < 10
				then
					local item = {
						itemLink = itemLink,
						itemPercentUpgrade = math.floor(UpgradeInfo[1].PercentUpgrade * 100 + .5)
					}
					self:AddRewardToQuest(questID, "ITEM", item, isEmissary)
				end
			end
		end

		-- StatWeightScore
		local StatWeightScore = LibStub("AceAddon-3.0"):GetAddon("StatWeightScore", true)
		if StatWeightScore and self.db.profile.options.reward.gear.StatWeightScore then
			local slotID = EquipLocToSlot1[itemEquipLoc]
			if slotID then
				local itemPercentUpgrade = 0
				local ScoreModule = StatWeightScore:GetModule("StatWeightScoreScore")
				local SpecModule = StatWeightScore:GetModule("StatWeightScoreSpec")
				local ScanningTooltipModule = StatWeightScore:GetModule("StatWeightScoreScanningTooltip")
				local specs = SpecModule:GetSpecs()
				for _, spec in pairs(specs) do
					if spec.Enabled then
						local score =
							ScoreModule:CalculateItemScore(
								itemLink,
								slotID,
								ScanningTooltipModule:ScanTooltip(itemLink),
								spec,
								equippedItemHasUniqueGem
							).Score
						local equippedScore
						local equippedLink = GetInventoryItemLink("player", slotID)
						if equippedLink then
							equippedScore =
								ScoreModule:CalculateItemScore(
									equippedLink,
									slotID,
									ScanningTooltipModule:ScanTooltip(equippedLink),
									spec,
									equippedItemHasUniqueGem
								).Score
						else
							retry = true
						end

						local slotID2 = EquipLocToSlot2[itemEquipLoc]
						if slotID2 then
							equippedLink = GetInventoryItemLink("player", slotID2)
							if equippedLink then
								local equippedScore2 =
									ScoreModule:CalculateItemScore(
										equippedLink,
										slotID2,
										ScanningTooltipModule:ScanTooltip(equippedLink),
										spec,
										equippedItemHasUniqueGem
									).Score
								if equippedScore or 0 > equippedScore2 then
									equippedScore = equippedScore2
								end
							else
								retry = true
							end
						end

						if equippedScore then
							if (score - equippedScore) / equippedScore * 100 > itemPercentUpgrade then
								itemPercentUpgrade = (score - equippedScore) / equippedScore * 100
							end
						end
					end
				end
				if itemPercentUpgrade >= self.db.profile.options.reward.gear.PercentUpgradeMin then
					local item = { itemLink = itemLink, itemPercentUpgrade = math.floor(itemPercentUpgrade + .5) }
					self:AddRewardToQuest(questID, "ITEM", item, isEmissary)
				end
			end
		end

		-- Upgrade by itemLevel
		if self.db.profile.options.reward.gear.itemLevelUpgrade then
			local itemLevel1, itemLevel2
			local slotID = EquipLocToSlot1[itemEquipLoc]
			if slotID then
				if GetInventoryItemID("player", slotID) then
					local itemLink1 = GetInventoryItemLink("player", slotID)
					if itemLink1 then
						itemLevel1 = GetDetailedItemLevelInfo(itemLink1)
						if not itemLevel1 then
							retry = true
						end
					else
						retry = true
					end
				end
			end
			if EquipLocToSlot2[itemEquipLoc] then
				slotID = EquipLocToSlot2[itemEquipLoc]
				if GetInventoryItemID("player", slotID) then
					local itemLink2 = GetInventoryItemLink("player", slotID)
					if itemLink2 then
						itemLevel2 = GetDetailedItemLevelInfo(itemLink2)
						if not itemLevel2 then
							retry = true
						end
					else
						retry = true
					end
				end
			end

			itemLevel = GetDetailedItemLevelInfo(itemLink)
			if not itemLevel then
				retry = true
			else
				local itemLevelEquipped = math.min(itemLevel1 or 1000, itemLevel2 or 1000)
				if itemLevel - itemLevelEquipped >= self.db.profile.options.reward.gear.itemLevelUpgradeMin then
					local item = { itemLink = itemLink, itemLevelUpgrade = itemLevel - itemLevelEquipped }
					self:AddRewardToQuest(questID, "ITEM", item, isEmissary)
				end
			end
		end

		-- Azerite Armor Cache
		if itemID == 163857 and self.db.profile.options.reward.gear.AzeriteArmorCache then
			itemLevel = GetDetailedItemLevelInfo(itemLink)
			local AzeriteArmorCacheIsUpgrade = false
			local AzeriteArmorCache = {}
			for i = 1, 5, 2 do
				if GetInventoryItemID("player", i) then
					local itemLink1 = GetInventoryItemLink("player", i)
					if itemLink1 then
						local itemLevel1 = GetDetailedItemLevelInfo(itemLink1)
						if itemLevel1 then
							AzeriteArmorCache[i] = itemLevel - itemLevel1
							if itemLevel > itemLevel1 and itemLevel - itemLevel1 >= self.db.profile.options.reward.gear.itemLevelUpgradeMin then
								AzeriteArmorCacheIsUpgrade = true
							end
						else
							retry = true
						end
					else
						retry = true
					end
				else
					AzeriteArmorCache[i] = itemLevel
					if itemLevel and itemLevel >= self.db.profile.options.reward.gear.itemLevelUpgradeMin then
						AzeriteArmorCacheIsUpgrade = true
					end
				end
			end
			if AzeriteArmorCacheIsUpgrade == true then
				local item = { itemLink = itemLink, AzeriteArmorCache = AzeriteArmorCache }
				self:AddRewardToQuest(questID, "ITEM", item, isEmissary)
			end
		end

		-- Equipment Cache
		if
			(weaponCache[itemID] and self.db.profile.options.reward.gear.weaponCache) or
			(armorCache[itemID] and self.db.profile.options.reward.gear.armorCache) or
			(jewelryCache[itemID] and self.db.profile.options.reward.gear.jewelryCache)
		then
			itemLevel = GetDetailedItemLevelInfo(itemLink)
			local n = 0
			local upgrade
			local upgradeMax = 0
			local upgradeSum = 0
			local upgradeNum = 0

			if weaponCache[itemID] then
				for i = 16, 17 do
					if GetInventoryItemID("player", i) then
						local itemLink1 = GetInventoryItemLink("player", i)
						if itemLink1 then
							local itemLevel1 = GetDetailedItemLevelInfo(itemLink1)
							if itemLevel1 then
								n = n + 1
								upgrade = itemLevel - itemLevel1
								if upgrade >= self.db.profile.options.reward.gear.itemLevelUpgradeMin then
									upgradeNum = upgradeNum + 1
									if upgrade > upgradeMax then
										upgradeMax = upgrade
									end
								end
								upgradeSum = upgradeSum + upgrade
							else
								retry = true
							end
						else
							retry = true
						end
					end
				end
			end

			if armorCache[itemID] then
				for i = 1, 10 do
					if i == 4 then
						i = 15
					end
					if i ~= 2 then
						if GetInventoryItemID("player", i) then
							local itemLink1 = GetInventoryItemLink("player", i)
							if itemLink1 then
								local itemLevel1 = GetDetailedItemLevelInfo(itemLink1)
								if itemLevel1 then
									n = n + 1
									upgrade = itemLevel - itemLevel1
									if upgrade >= self.db.profile.options.reward.gear.itemLevelUpgradeMin then
										upgradeNum = upgradeNum + 1
										if upgrade > upgradeMax then
											upgradeMax = upgrade
										end
									end
									upgradeSum = upgradeSum + upgrade
								else
									retry = true
								end
							else
								retry = true
							end
						end
					end
				end
			end

			if jewelryCache[itemID] then
				for i = 11, 14 do
					if GetInventoryItemID("player", i) then
						local itemLink1 = GetInventoryItemLink("player", i)
						if itemLink1 then
							local itemLevel1 = GetDetailedItemLevelInfo(itemLink1)
							if itemLevel1 then
								n = n + 1
								upgrade = itemLevel - itemLevel1
								if upgrade >= self.db.profile.options.reward.gear.itemLevelUpgradeMin then
									upgradeNum = upgradeNum + 1
									if upgrade > upgradeMax then
										upgradeMax = upgrade
									end
								end
								upgradeSum = upgradeSum + upgrade
							else
								retry = true
							end
						else
							retry = true
						end
					end
				end
			end

			if upgradeNum > 0 then
				local item = {
					itemLink = itemLink,
					cache = { upgradeNum = upgradeNum, n = n, upgradeMax = upgradeMax }
				}
				self:AddRewardToQuest(questID, "ITEM", item, isEmissary)
			end
		end

		-- Transmog
		if self.db.profile.options.reward.gear.unknownAppearance and self:IsTransmogable(itemLink) then
			if itemClassID == 2 or itemClassID == 4 then
				local transmog
				if AllTheThings then
					local searchForLinkResult = AllTheThings.SearchForLink(itemLink)
					if (searchForLinkResult and searchForLinkResult[1]) then
						local state = searchForLinkResult[1].collected
						if not state then
							transmog = "|TInterface\\Addons\\AllTheThings\\assets\\unknown:0|t"
						elseif state == 2 and self.db.profile.options.reward.gear.unknownSource then
							transmog = "|TInterface\\Addons\\AllTheThings\\assets\\known_circle:0|t"
						end
					end
				end

				if CanIMogIt and not transmog then
					if CanIMogIt:IsEquippable(itemLink) and CanIMogIt:CharacterCanLearnTransmog(itemLink) then
						if not CanIMogIt:PlayerKnowsTransmog(itemLink) then
							transmog = "|TInterface\\AddOns\\CanIMogIt\\Icons\\UNKNOWN:0|t"
						elseif not CanIMogIt:PlayerKnowsTransmogFromItem(itemLink) and self.db.profile.options.reward.gear.unknownSource then
							transmog = "|TInterface\\AddOns\\CanIMogIt\\Icons\\KNOWN_circle:0|t"
						end
					end
				end
				if transmog then
					local item = { itemLink = itemLink, transmog = transmog }
					self:AddRewardToQuest(questID, "ITEM", item, isEmissary)
				end
			end
		end

		-- Reputation Token
		local factionID = ReputationItemList[itemID] or nil
		if factionID then
			if self.db.profile.options.reward.reputation[factionID] == true then
				local reputation = { itemLink = itemLink, factionID = factionID }
				self:AddRewardToQuest(questID, "REPUTATION", reputation, isEmissary)
			end
		end

		-- print(expacID,self:GetExpansionByQuestID(questID), itemLink, questID)
		-- Recipe
		if itemClassID == 9 then
			if self.db.profile.options.reward.recipe[expacID] == true then
				self:AddRewardToQuest(questID, "RECIPE", itemLink, isEmissary)
			end
		end

		-- Crafting Reagent
		--[[
			if self.db.profile.options.reward.craftingreagent[itemID] == true then
				if not self.questList[questID] then self.questList[questID] = {} end
				local l = self.questList[questID]
				if not l.reward then l.reward = {} end
				if not l.reward.item then l.reward.item = {} end
				l.reward.item.itemLink = itemLink
			end--]]
		-- Custom itemID
		if self.db.global.custom.worldQuestReward[itemID] == true then
			if self.db.profile.custom.worldQuestReward[itemID] == true then
				self:AddRewardToQuest(questID, "CUSTOM_ITEM", itemLink, isEmissary)
			end
		end

		-- Items
		if self.itemList[itemID] == true then
			local item = { itemLink = itemLink }
			self:AddRewardToQuest(questID, "ITEM", item, isEmissary)
		end

		-- Azerite Traits
		if
			self.db.profile.options.reward.gear.azeriteTraits ~= "" and
			C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(itemLink)
		then
			for _, ring in pairs(C_AzeriteEmpoweredItem.GetAllTierInfoByItemID(itemLink)) do
				for _, azeritePowerID in pairs(ring.azeritePowerIDs) do
					local spellID = C_AzeriteEmpoweredItem.GetPowerInfo(azeritePowerID).spellID
					if self.azeriteTraitsList[spellID] then
						self:AddRewardToQuest(questID, "AZERITE_TRAIT", spellID, isEmissary)
						self:AddRewardToQuest(questID, "ITEM", { itemLink = itemLink }, isEmissary)
					end
				end
			end
		end

		-- Conduit
		if self.db.profile.options.reward.gear.conduit and C_Soulbinds.IsItemConduitByItemInfo(itemLink) then
			self:AddRewardToQuest(questID, "ITEM", { itemLink = itemLink }, isEmissary)
		end
	else
		retry = true
	end

	return retry
end

function WQA:CheckCurrencies(questID, isEmissary)
	local questRewardCurrencies = C_QuestLog.GetQuestRewardCurrencies(questID)

	for _, currencyInfo in ipairs(questRewardCurrencies) do
		local currencyID = currencyInfo.currencyID
		local amount = currencyInfo.totalRewardAmount

		if self.db.profile.options.reward.currency[currencyID] then
			local currency = { currencyID = currencyID, amount = amount }
			self:AddRewardToQuest(questID, "CURRENCY", currency, isEmissary)
		end

		-- Reputation Currency
		local factionID = ReputationCurrencyList[currencyID] or nil
		if factionID then
			if self.db.profile.options.reward.reputation[factionID] == true then
				local reputation = {
					name = currencyInfo.name,
					currencyID = currencyID,
					amount = amount,
					factionID = factionID
				}
				self:AddRewardToQuest(questID, "REPUTATION", reputation, isEmissary)
			end
		end
	end

	local gold = math.floor(GetQuestLogRewardMoney(questID) / 10000) or 0
	if gold > 0 then
		if self.db.profile.options.reward.general.gold and gold >= self.db.profile.options.reward.general.goldMin then
			self:AddRewardToQuest(questID, "GOLD", gold, isEmissary)
		end
	end
end

WQA.debug = false
function WQA:Debug(...)
	if self.debug == true then
		print(GetTime(), GetFramerate(), ...)
	end
end

function WQA:GetRewardTextByID(questID, key, value, i, type)
	local k, v = key, value
	local text
	if k == "custom" then
		text = "Custom"
	elseif k == "item" then
		text = self:GetRewardForID(questID, k, type)
	elseif k == "reputation" then
		if v.itemLink then
			text = self:GetRewardLinkByID(questID, k, v, i)
		else
			text = v.amount .. " " .. self:GetRewardLinkByID(questID, k, v, i)
		end
	elseif k == "currency" then
		text = v.amount .. " " .. GetCurrencyLink(v.currencyID, v.amount)
	elseif k == "professionSkillup" then
		text = v
	elseif k == "gold" then
		text = GOLD_AMOUNT_TEXTURE_STRING:format(v, 0, 0)
	else
		text = self:GetRewardLinkByID(questID, k, v, i)
	end
	return text
end

function WQA:GetRewardLinkByMissionID(missionID, key, value, i)
	return self:GetRewardLinkByID(missionID, key, value, i)
end

function WQA:GetRewardLinkByID(questID, key, value, i)
	local k, v = key, value
	local link = nil
	if k == "achievement" then
		if not v[i] then
			return nil
		end
		link = v[i].achievementLink or GetAchievementLink(v[i].id)
	elseif k == "chance" then
		if not v[i] then
			return nil
		end
		link = v[i].itemLink or select(2, GetItemInfo(v[i].id))
	elseif k == "custom" then
		return nil
	elseif k == "item" then
		link = v.itemLink
	elseif k == "reputation" then
		if v.itemLink then
			link = v.itemLink
		else
			link = v.currencyLink or GetCurrencyLink(v.currencyID, v.amount)
		end
	elseif k == "recipe" then
		link = v
	elseif k == "customItem" then
		link = v
	elseif k == "currency" then
		link = v.currencyLink or GetCurrencyLink(v.currencyID, v.amount)
	elseif k == "professionSkillup" then
		return nil
	elseif k == "gold" then
		return nil
	elseif k == "azeriteTraits" then
		if not v[i] then
			return nil
		end
		link = GetSpellLink(v[i].spellID)
	elseif k == WQA.Rewards.RewardType.Miscellaneous then
		link = table.concat(v, ", ")
	end
	return link
end

function WQA:SetRewardLinkByMissionID(missionID, key, value, i, link)
	self:SetRewardLinkByID(missionID, key, value, i, link)
end

function WQA:SetRewardLinkByID(questID, key, value, i, link)
	local k, v = key, value
	if k == "achievement" then
		v[i].achievementLink = link
	elseif k == "chance" then
		v[i].itemLink = link
	elseif k == "reputation" then
		if not v.itemLink then
			v.currencyLink = link
		end
	elseif k == "currency" then
		v.currencyLink = link
	end
end

local function GetQuestName(questID)
	return C_TaskQuest.GetQuestInfoByQuestID(questID) or GetTitleForQuestID(questID) or
		select(3, string.find(GetQuestLink(questID) or "[unknown]", "%[(.+)%]"))
end

local function GetMissionName(missionID)
	return C_Garrison.GetMissionName(missionID)
end

local function SortByName(a, b)
	if a.type == "WORLD_QUEST" then
		a = GetQuestName(a.id)
	else
		a = GetMissionName(a.id)
	end

	if b.type == "WORLD_QUEST" then
		b = GetQuestName(b.id)
	else
		b = GetMissionName(b.id)
	end

	--return GetQuestName(a) < GetQuestName(b)
	return a < b
end

function WQA:InsertionSort(A, compareFunction)
	for i, v in ipairs(A) do
		local j = i
		while j > 1 and compareFunction(A[j], A[j - 1]) do
			local temp = A[j]
			A[j] = A[j - 1]
			A[j - 1] = temp
			j = j - 1
		end
	end
	return A
end

function WQA:SortQuestList(list)
	if self.db.profile.options.sortByName == true then
		list = self:InsertionSort(list, SortByName)
	end

	if self.db.profile.options.sortByZoneName == true then
		list = self:InsertionSort(list, function(a, b) return self:SortByZoneName(a, b) end)
	end

	list = self:InsertionSort(list, function(a, b) return self:SortByExpansion(a, b) end)
	return list
end

local GetBountiesForMapIDRequested = false
function WQA:EmissaryReward()
	self.emissaryRewards = false
	local retry = false

	for _, mapID in pairs({ 627, 875 }) do
		local bounties = GetBountiesForMapID(mapID)
		if bounties then
			for _, emissary in ipairs(GetBountiesForMapID(mapID)) do
				local questID = emissary.questID
				if self.db.profile.options.emissary[questID] == true then
					self:AddEmissaryReward(questID, "CUSTOM", nil, true)
				end
				if HaveQuestData(questID) and HaveQuestRewardData(questID) then
					retry = (self:CheckItems(questID, true) or retry)
					self:CheckCurrencies(questID, true)
				else
					retry = true
				end
			end
		end
	end

	if retry == true or GetBountiesForMapIDRequested == false then
		GetBountiesForMapIDRequested = true
		self:ScheduleTimer(
			function()
				self:EmissaryReward()
			end,
			1.5
		)
	else
		GetBountiesForMapIDRequested = false
		self.emissaryRewards = true
	end
end

function WQA:EmissaryIsActive(questID)
	local emissary = {}
	for _, v in pairs(self.EmissaryQuestIDList) do
		for _, id in pairs(v) do
			if type(id) == "table" then
				id = id.id
			end
			if id == questID then
				emissary[id] = true
			end
		end
	end

	if emissary[questID] ~= true then
		return false
	end

	local i = 1
	while C_QuestLog.GetInfo(i) do
		local questLogQuestID = C_QuestLog.GetInfo(i).questID
		if questLogQuestID == questID then
			return true
		end
		i = i + 1
	end
	return false
end

function WQA:Special()
	if
		(self.db.profile.achievements[11189] ~= "disabled" and not select(4, GetAchievementInfo(11189)) == true) or
		(self.db.profile.achievements[13144] ~= "disabled" and not select(4, GetAchievementInfo(13144)) == true) or
		(self.db.profile.achievements[14758] ~= "disabled" and not select(4, GetAchievementInfo(14758)))
	then
		self.event:RegisterEvent("QUEST_TURNED_IN")
	end
end

local function PopUpIsShown()
	if WQA.PopUp then
		return WQA.PopUp.shown
	else
		return false
	end
end

local anchor
function dataobj:OnEnter()
	anchor = self
	if not PopUpIsShown() then
		WQA:Show("LDB")
	end
end

function dataobj:OnClick(button)
	if button == "LeftButton" then
		WQA:Show("popup")
	elseif button == "RightButton" then
		Settings.OpenToCategory("WQAchievements")
	end
end

function WQA:AnnounceLDB(quests)
	-- Hide PopUp
	if PopUpIsShown() then
		return
	end

	self:CreateQTip()
	self.tooltip:SetAutoHideDelay(
		.25,
		anchor,
		function()
			if not PopUpIsShown() then
				LibQTip:Release(WQA.tooltip)
				WQA.tooltip.quests = nil
				WQA.tooltip.missions = nil
				WQA.tooltip = nil
			end
		end
	)
	self.tooltip:SmartAnchorTo(anchor)
	self:UpdateQTip(quests)
end

function WQA:UpdateLDBText(activeTasks, newTasks)
	if newTasks ~= nil then
		dataobj.text = "New World Quests active"
	elseif activeTasks ~= nil then
		dataobj.text = "World Quests active"
	else
		dataobj.text = "No World Quests active"
	end
end

function WQA:formatTime(t)
	local t = math.floor(t or 0)
	local d, h, m, timeString
	d = math.floor(t / 60 / 24)
	h = math.floor(t / 60 % 24)
	m = t % 60
	if d > 0 then
		if h > 0 then
			timeString = string.format("%dd %dh", d, h)
		else
			timeString = string.format("%dd", d)
		end
	elseif h > 0 then
		if m > 0 then
			timeString = string.format("%dh %dm", h, m)
		else
			timeString = string.format("%dh", h)
		end
	else
		timeString = string.format("%dm", m)
	end

	if t > 0 then
		if t <= 180 then
			if t <= 30 then
				timeString = string.format("|cffff3333%s|r", timeString)
			else
				timeString = string.format("|cffffff00%s|r", timeString)
			end
		end
	end

	return timeString
end

local LE_GARRISON_TYPE = {
	[6] = Enum.GarrisonType.Type_6_0_Garrison,
	[7] = Enum.GarrisonType.Type_7_0_Garrison,
	[8] = Enum.GarrisonType.Type_8_0_Garrison,
	[9] = Enum.GarrisonType.Type_9_0_Garrison
}

function WQA:CheckMissions()
	local activeMissions = {}
	local retry
	for i in pairs(WQA.ExpansionList) do
		local type = LE_GARRISON_TYPE[i]
		local followerType = GetPrimaryGarrisonFollowerType(type)
		if type and C_Garrison.HasGarrison(type) then
			local missions = C_Garrison.GetAvailableMissions(followerType)
			-- Add Shipyard Missions
			if i == 6 and C_Garrison.HasShipyard() then
				for missionID, mission in ipairs(C_Garrison.GetAvailableMissions(Enum.GarrisonFollowerType.FollowerType_6_0_Boat)) do
					mission.followerType = Enum.GarrisonFollowerType.FollowerType_6_0_Boat
					missions[#missions + 1] = mission
				end
			end

			if missions then
				for _, mission in ipairs(missions) do
					local missionID = mission.missionID
					local addMission = false
					if self.missionList[missionID] then
						addMission = true
					end
					for _, reward in ipairs(mission.rewards) do
						if reward.currencyID then
							if reward.currencyID ~= 0 then
								local currencyID = reward.currencyID
								local amount = reward.quantity
								if self.db.profile.options.missionTable.reward.currency[currencyID] then
									local currency = { currencyID = currencyID, amount = amount }
									self:AddRewardToMission(missionID, "CURRENCY", currency)
									addMission = true
								else
									local factionID = ReputationCurrencyList[currencyID] or nil
									if factionID then
										if self.db.profile.options.missionTable.reward.reputation[factionID] == true then
											local reputation = {
												currencyID = currencyID,
												amount = amount,
												factionID = factionID
											}
											self:AddRewardToMission(missionID, "REPUTATION", reputation)
										end
									end
								end
							else
								local gold = math.floor(reward.quantity / 10000)
								if
									self.db.profile.options.missionTable.reward.gold and
									gold >= self.db.profile.options.missionTable.reward.goldMin
								then
									self:AddRewardToMission(missionID, "GOLD", gold)
									addMission = true
								end
							end
						end

						if reward.itemID then
							local itemID = reward.itemID
							local itemName,
							itemLink,
							itemRarity,
							itemLevel,
							itemMinLevel,
							itemType,
							itemSubType,
							itemStackCount,
							itemEquipLoc,
							itemTexture,
							itemSellPrice,
							itemClassID,
							itemSubClassID = GetItemInfo(itemID)

							if not itemLink then
								retry = true
							else
								-- Custom Mission Reward
								if self.db.global.custom.missionReward[itemID] and self.db.profile.custom.missionReward[itemID] then
									local item = { itemLink = itemLink }
									self:AddRewardToMission(missionID, "ITEM", item)
									addMission = true
								end

								-- Reputation Token
								local factionID = ReputationItemList[itemID] or nil
								if factionID then
									if self.db.profile.options.missionTable.reward.reputation[factionID] == true then
										local reputation = { itemLink = itemLink, factionID = factionID }
										self:AddRewardToMission(missionID, "REPUTATION", reputation)
										addMission = true
									end
								end

								-- Transmog
								if self.db.profile.options.reward.gear.unknownAppearance and self:IsTransmogable(itemLink) then
									if itemClassID == 2 or itemClassID == 4 then
										local transmog
										if AllTheThings then
											local searchForLinkResult = AllTheThings.SearchForLink(itemLink)
											if not searchForLinkResult or not searchForLinkResult[1] then
												retry = true
											else
												local state = searchForLinkResult[1].collected
												if not state then
													transmog = "|TInterface\\Addons\\AllTheThings\\assets\\unknown:0|t"
												elseif state == 2 and self.db.profile.options.reward.gear.unknownSource then
													transmog =
													"|TInterface\\Addons\\AllTheThings\\assets\\known_circle:0|t"
												end
											end
										elseif CanIMogIt then
											if CanIMogIt:IsEquippable(itemLink) and CanIMogIt:CharacterCanLearnTransmog(itemLink) then
												if not CanIMogIt:PlayerKnowsTransmog(itemLink) then
													transmog = "|TInterface\\AddOns\\CanIMogIt\\Icons\\UNKNOWN:0|t"
												elseif
													not CanIMogIt:PlayerKnowsTransmogFromItem(itemLink) and self.db.profile.options.reward.gear.unknownSource
												then
													transmog = "|TInterface\\AddOns\\CanIMogIt\\Icons\\KNOWN_circle:0|t"
												end
											end
										end
										if transmog then
											local item = { itemLink = itemLink, transmog = transmog }
											self:AddRewardToMission(missionID, "ITEM", item)
											addMission = true
										end
									end
								end

								-- Conduit
								if self.db.profile.options.reward.gear.conduit and C_Soulbinds.IsItemConduitByItemInfo(itemLink) then
									self:AddRewardToMission(missionID, "ITEM", { itemLink = itemLink })
									addMission = true
								end
							end
						end
						if addMission == true then
							self.missionList[missionID].offerEndTime = mission.offerEndTime or nil
							self.missionList[missionID].offerTimeRemaining = mission.offerTimeRemaining or nil
							self.missionList[missionID].expansion = i
							self.missionList[missionID].followerType = mission.followerType or followerType
							activeMissions[missionID] = true
						end
					end
				end
			end
		end
	end

	if retry then
		return nil
	else
		return activeMissions
	end
end

function WQA:isQuestPinActive(questID)
	for mapID in pairs(self.questPinMapList) do
		for _, questPin in pairs(C_QuestLine.GetAvailableQuestLines(mapID)) do
			if questPin.questID == questID then
				return true
			end
		end
	end
	return false
end

function WQA:IsQuestFlaggedCompleted(questID)
	if self.questFlagList[questID] then
		return not IsQuestFlaggedCompleted(questID)
	else
		return false
	end
end

function WQA:UpdateMinimapIcon()
	if self.db.profile.options.LibDBIcon.hide then
		icon:Hide("WQAchievements")
	else
		icon:Show("WQAchievements")
	end
end
