local WQA = WQAchievements

-- Blizzard
local IsActive = C_TaskQuest.IsActive
local GetQuestTagInfo = C_QuestLog.GetQuestTagInfo
local GetBountiesForMapID = C_QuestLog.GetBountiesForMapID
local GetTitleForQuestID = C_QuestLog.GetTitleForQuestID
local GetCurrencyLink = C_CurrencyInfo.GetCurrencyLink
local IsQuestFlaggedCompleted = C_QuestLog.IsQuestFlaggedCompleted

-- Locales
local locale = GetLocale()
WQA.L = {}
local L = WQA.L
L["NO_QUESTS"] = "No interesting World Quests active!"
L["WQChat"] = "Interesting World Quests are active:"
L["WQforAch"] = "%s for %s"
L["WQforAchTime"] = "%s (%s) for %s"
L["achievements"] = "Achievements"
L["mounts"] = "Mounts"
L["pets"] = "Pets"
L["toys"] = "Toys"
L["completed"] = "Completed"
L["notCompleted"] = "Not completed"
L["tracking_disabled"] = "Don't track"
L["tracking_default"] = "Default"
L["tracking_always"] = "Always track"
L["tracking_wasEarnedByMe"] = "Track if not earned by active character"
L["tracking_exclusive"] = "Only track with this character"
L["tracking_other"] = "Only tracked by %s"
L["LE_QUEST_TAG_TYPE_PVP"] = "PVP"
L["LE_QUEST_TAG_TYPE_PET_BATTLE"] = "Pet Battle"
L["LE_QUEST_TAG_TYPE_PROFESSION"] = "Profession"
L["LE_QUEST_TAG_TYPE_DUNGEON"] = "Dungeon"
if locale == "deDE" then
	L["WQChat"] = "Interessante Weltquests verfügbar:"
	L["WQforAch"] = "%s für %s"
	L["WQforAchTime"] = "%s (%s) für %s"
	L["NO_QUESTS"] = "Keine interessanten Weltquests verfügbar!"
	L["achievements"] = "Erfolge"
	L["mounts"] = "Reittiere"
	L["pets"] = "Haustiere"
	L["toys"] = "Spielzeuge"
	L["completed"] = "Abgeschlossen"
	L["notCompleted"] = "Nicht abgeschlossen"
	L["tracking_disabled"] = "Nicht verfolgen"
	L["tracking_default"] = "Standard"
	L["tracking_always"] = "Immer verfolgen"
	L["tracking_wasEarnedByMe"] = "Verfolgen, wenn nicht mit aktiven Charakter errungen"
	L["tracking_exclusive"] = "Nur mit diesem Charakter verfolgen"
	L["tracking_other"] = "Nur mit %s verfolgen"
end

local function GetExpansionByMissionID(missionID)
	return WQA.missionList[missionID].expansion
end

local questZoneIDList = {
	-- Outside Influences
	[55463] = 1462,
	[55658] = 1462,
	[55688] = 1462,
	[55718] = 1462,
	[55765] = 1462,
	[55885] = 1462,
	[56053] = 1462,
	[55813] = 1462,
	[56301] = 1462,
	[56142] = 1462,
	[55528] = 1462,
	[56365] = 1462,
	[56572] = 1462,
	[56501] = 1462,
	[56493] = 1462,
	[56552] = 1462,
	[56558] = 1462,
	[55575] = 1462,
	[55672] = 1462,
	[55717] = 1462,
	[56049] = 1462,
	[56469] = 1462,
	[55816] = 1462,
	[55905] = 1462,
	[56184] = 1462,
	[56306] = 1462,
	[54090] = 1462,
	[56355] = 1462,
	[56523] = 1462,
	[56410] = 1462,
	[56508] = 1462,
	[56471] = 1462,
	[56405] = 1462,
	-- Periodic Destruction
	[55121] = 1355
}

local function GetQuestZoneID(questID)
	if WQA.questList[questID] and WQA.questList[questID].isEmissary then
		return "Emissary"
	end
	--if not WQA.questList[questID].info then	WQA.questList[questID].info = {} end
	--if WQA.questList[questID].info.zoneID then
	--	return WQA.questList[questID].info.zoneID
	--else
	--	WQA.questList[questID].info.zoneID = questZoneIDList[questID] or C_TaskQuest.GetQuestZoneID(questID)
	--	return WQA.questList[questID].info.zoneID
	--end
	return questZoneIDList[questID] or C_TaskQuest.GetQuestZoneID(questID)
end

local function GetMissionZoneID(missionID)
	if WQA.missionList[missionID].shipyard == true then
		return -GetExpansionByMissionID(missionID) - .5
	else
		return -GetExpansionByMissionID(missionID)
	end
end

local function GetTaskZoneID(task)
	if task.type == "MISSION" then
		return GetMissionZoneID(task.id)
	else
		return GetQuestZoneID(task.id)
	end
end

local function GetMapInfo(mapID)
	if mapID then
		return C_Map.GetMapInfo(mapID)
	else
		return {name = "Unknown"}
	end
end

local function GetQuestZoneName(questID)
	if WQA.questList[questID].isEmissary then
		return "Emissary"
	end
	if not WQA.questList[questID].info then
		WQA.questList[questID].info = {}
	end
	WQA.questList[questID].info.zoneName = WQA.questList[questID].info.zoneName or GetMapInfo(GetQuestZoneID(questID)).name
	return WQA.questList[questID].info.zoneName
end

local function GetMissionZoneName(missionID)
	if WQA.missionList[missionID].shipyard == true then
		return "Shipyard"
	else
		return "Mission Table"
	end
end

local function GetTaskZoneName(task)
	if task.type == "MISSION" then
		return GetMissionZoneName(task.id)
	else
		return GetQuestZoneName(task.id)
	end
end

ExpansionByZoneID = {
	-- BfA
	[1169] = 8 -- Tol Dagor
}

local function GetExpansionByQuestID(questID)
	--if not WQA.questList[questID].info then	WQA.questList[questID].info = {} end
	--if WQA.questList[questID].info.expansion then
	--	return WQA.questList[questID].info.expansion
	--else
	local zoneID = GetQuestZoneID(questID)

	if ExpansionByZoneID[zoneID] then
		--	WQA.questList[questID].info.expansion = ExpansionByZoneID[zoneID]
		return ExpansionByZoneID[zoneID]
	end

	for expansion, zones in pairs(WQA.ZoneIDList) do
		for _, v in pairs(zones) do
			if zoneID == v then
				--			WQA.questList[questID].info.expansion = expansion
				return expansion
			end
		end
	end

	for expansion, v in pairs(WQA.EmissaryQuestIDList) do
		for _, id in pairs(v) do
			if type(id) == "table" then
				id = id.id
			end
			if id == questID then
				--					WQA.questList[questID].info.expansion = expansion
				return expansion
			end
		end
	end
	--end
	return -1
end

local function GetExpansion(task)
	if task.type == "MISSION" then
		return GetExpansionByMissionID(task.id)
	else
		return GetExpansionByQuestID(task.id)
	end
end

local function GetExpansionName(id)
	return WQA.ExpansionList[id] or "Unknown"
end

local function GetMissionTimeLeftMinutes(id)
	if not WQA.missionList[id].offerEndTime then
		return 0
	else
		return (WQA.missionList[id].offerEndTime - GetTime()) / 60
	end
end

local function GetTaskTime(task)
	if task.type == "WORLD_QUEST" then
		return C_TaskQuest.GetQuestTimeLeftMinutes(task.id)
	else
		return GetMissionTimeLeftMinutes(task.id)
	end
end

local function GetTaskLink(task)
	if task.type == "WORLD_QUEST" then
		--	else
		--		return GetQuestLink(task.id)
		--	end
		--	if WQA.questPinList[task.id] or WQA.questFlagList[task.id] then
		return GetQuestLink(task.id) or GetTitleForQuestID(task.id)
	else
		return C_Garrison.GetMissionLink(task.id)
	end
end

local newOrder
do
	local current = 0
	function newOrder()
		current = current + 1
		return current
	end
end

WQA.data.custom = {wqID = "", rewardID = "", rewardType = "none", questType = "WORLD_QUEST"}
WQA.data.custom.mission = {missionID = "", rewardID = "", rewardType = "none"}
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
				zone = {["*"] = true},
				reward = {
					gear = {
						["*"] = true,
						itemLevelUpgradeMin = 1,
						PercentUpgradeMin = 1,
						unknownSource = false,
						azeriteTraits = ""
					},
					general = {
						gold = false,
						goldMin = 0,
						worldQuestType = {
							["*"] = true
						}
					},
					reputation = {["*"] = false},
					currency = {},
					craftingreagent = {["*"] = false},
					["*"] = {
						["*"] = true,
						profession = {
							["*"] = {
								skillup = true
							}
						}
					}
				},
				emissary = {["*"] = false},
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
				LibDBIcon = {hide = false}
			},
			["achievements"] = {exclusive = {}, ["*"] = "default"},
			["mounts"] = {exclusive = {}, ["*"] = "default"},
			["pets"] = {exclusive = {}, ["*"] = "default"},
			["toys"] = {exclusive = {}, ["*"] = "default"},
			custom = {
				["*"] = {["*"] = true}
			},
			["*"] = {["*"] = true}
		},
		global = {
			completed = {["*"] = false},
			custom = {
				["*"] = {["*"] = false}
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
				for i = 1, #self.ZoneIDList do
					for _, mapID in pairs(self.ZoneIDList[i]) do
						if self.db.profile.options.zone[mapID] == true then
							local quests = C_TaskQuest.GetQuestsForPlayerByMapID(mapID)
							if quests then
								for i = 1, #quests do
									local questID = quests[i].questId
									local numQuestRewards = GetNumQuestLogRewards(questID)
									if numQuestRewards > 0 then
										local itemName, itemTexture, quantity, quality, isUsable, itemID = GetQuestLogRewardInfo(1, questID)
									end
								end
							end
						end
					end
				end

				self.event:UnregisterEvent("PLAYER_ENTERING_WORLD")
				self:ScheduleTimer("Show", self.db.profile.options.delay, nil, true)
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

	LoadAddOn("Blizzard_GarrisonUI")
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

	-- Legion
	for _, v in pairs(self.data[7].achievements) do
		self.Achievements:Register(v)
	end
	self:AddMounts(self.data[7].mounts)
	self:AddPets(self.data[7].pets)
	self:AddToys(self.data[7].toys)

	-- Battle for Azeroth
	for _, v in pairs(self.data[8].achievements) do
		self.Achievements:Register(v)
	end
	self:AddMounts(self.data[8].mounts)
	self:AddPets(self.data[8].pets)
	self:AddToys(self.data[8].toys)

	-- Shadowlands
	for _, v in pairs(self.data[9].achievements) do
		self.Achievements:Register(v)
	end
	self:AddPets(self.data[9].pets)
	self:AddToys(self.data[9].toys)

	-- Dragonflight
	for _, v in pairs(self.data[10].achievements) do
		self.Achievements:Register(v)
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

function WQA:AddReward(list, rewardType, reward, emissary)
	local l = list
	if emissary == true then
		l.isEmissary = true
	end
	if not l.reward then
		l.reward = {}
	end
	l = l.reward
	if rewardType == "ACHIEVEMENT" then
		if not l.achievement then
			l.achievement = {}
		end

		for _, achievement in ipairs(l.achievement) do
			if achievement.id == reward then
				return
			end
		end

		l.achievement[#l.achievement + 1] = {id = reward}
	elseif rewardType == "CHANCE" then
		if not l.chance then
			l.chance = {}
		end
		l.chance[#l.chance + 1] = {id = reward}
	elseif rewardType == "CUSTOM" then
		if not l.custom then
			l.custom = true
		end
	elseif rewardType == "ITEM" then
		if not l.item then
			l.item = {}
		end
		for k, v in pairs(reward) do
			l.item[k] = v
		end
	elseif rewardType == "REPUTATION" then
		if not l.reputation then
			l.reputation = {}
		end
		for k, v in pairs(reward) do
			l.reputation[k] = v
		end
	elseif rewardType == "RECIPE" then
		l.recipe = reward
	elseif rewardType == "CUSTOM_ITEM" then
		l.customItem = reward
	elseif rewardType == "CURRENCY" then
		if not l.currency then
			l.currency = {}
		end
		for k, v in pairs(reward) do
			l.currency[k] = v
		end
	elseif rewardType == "PROFESSION_SKILLUP" then
		l.professionSkillup = reward
	elseif rewardType == "GOLD" then
		l.gold = reward
	elseif rewardType == "AZERITE_TRAIT" then
		if not l.azeriteTraits then
			l.azeriteTraits = {}
		end
		for k, v in pairs(l.azeriteTraits) do
			if v.spellID == reward then
				return
			end
		end
		l.azeriteTraits[#l.azeriteTraits + 1] = {spellID = reward}
	end
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
			local questLink = GetTaskLink({id = questID, type = "WORLD_QUEST"})
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

	if retry == true then
		self:Debug("NoLink")
		self:ScheduleTimer("CheckWQ", 1, mode)
		return
	end

	self.activeTasks = {}
	for id in pairs(activeQuests) do
		table.insert(self.activeTasks, {id = id, type = "WORLD_QUEST"})
	end
	for id in pairs(activeMissions) do
		table.insert(self.activeTasks, {id = id, type = "MISSION"})
	end

	self.activeTasks = self:SortQuestList(self.activeTasks)

	self.newTasks = {}
	for id in pairs(newQuests) do
		self.watched[id] = true
		table.insert(self.newTasks, {id = id, type = "WORLD_QUEST"})
	end
	for id in pairs(newMissions) do
		self.watchedMissions[id] = true
		table.insert(self.newTasks, {id = id, type = "MISSION"})
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
								"FF" .. upgradeChance .. cache.upgradeNum .. "/" .. cache.n .. " max +" .. cache.upgradeMax .. "|r"
					local item = {itemLink = itemLink, cache = {upgradeNum = upgradeNum, n = n, upgradeMax = upgradeMax}}
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
			if GetExpansion(task) ~= expansion then
				expansion = GetExpansion(task)
				print(GetExpansionName(expansion))
			end
		end

		if self.db.profile.options.chatShowZone == true then
			if GetTaskZoneID(task) ~= zoneID then
				zoneID = GetTaskZoneID(task)
				print(GetTaskZoneName(task))
			end
		end

		local l
		if task.type == "WORLD_QUEST" then
			l = self.questList
		else
			l = self.missionList
		end

		local more
		for k, v in pairs(l[task.id].reward) do
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
			output = "   " .. string.format(L["WQforAchTime"], GetTaskLink(task), self:formatTime(GetTaskTime(task)), text)
		else
			output = "   " .. string.format(L["WQforAch"], GetTaskLink(task), text)
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
	[1738] = 2373 -- The Unshackled
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
				local quests = C_TaskQuest.GetQuestsForPlayerByMapID(mapID)
				if quests then
					for i = 1, #quests do
						local questID = quests[i].questId
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
	local retry = false
	local numQuestRewards = GetNumQuestLogRewards(questID)
	if numQuestRewards > 0 then
		local itemName, itemTexture, quantity, quality, isUsable, itemID = GetQuestLogRewardInfo(1, questID)
		if itemID then
			inspectScantip:SetQuestLogItem("reward", 1, questID)
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
			local expacID = GetExpansionByQuestID(questID)

			-- Ask Pawn if this is an Upgrade
			if PawnIsItemAnUpgrade and self.db.profile.options.reward.gear.PawnUpgrade then
				local Item = PawnGetItemData(itemLink)
				if Item then
					local UpgradeInfo, BestItemFor, SecondBestItemFor, NeedsEnhancements = PawnIsItemAnUpgrade(Item)
					if
						UpgradeInfo and UpgradeInfo[1].PercentUpgrade * 100 >= self.db.profile.options.reward.gear.PercentUpgradeMin and
							UpgradeInfo[1].PercentUpgrade < 10
					 then
						local item = {itemLink = itemLink, itemPercentUpgrade = math.floor(UpgradeInfo[1].PercentUpgrade * 100 + .5)}
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
						local item = {itemLink = itemLink, itemPercentUpgrade = math.floor(itemPercentUpgrade + .5)}
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
				local itemLevelEquipped = math.min(itemLevel1 or 1000, itemLevel2 or 1000)
				if itemLevel - itemLevelEquipped >= self.db.profile.options.reward.gear.itemLevelUpgradeMin then
					local item = {itemLink = itemLink, itemLevelUpgrade = itemLevel - itemLevelEquipped}
					self:AddRewardToQuest(questID, "ITEM", item, isEmissary)
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
					local item = {itemLink = itemLink, AzeriteArmorCache = AzeriteArmorCache}
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
					local item = {itemLink = itemLink, cache = {upgradeNum = upgradeNum, n = n, upgradeMax = upgradeMax}}
					self:AddRewardToQuest(questID, "ITEM", item, isEmissary)
				end
			end

			-- Transmog
			if self.db.profile.options.reward.gear.unknownAppearance and self:IsTransmogable(itemLink) then
				if itemClassID == 2 or itemClassID == 4 then
					local transmog
					if AllTheThings then
						local state = AllTheThings.SearchForLink(itemLink)[1].collected
						if not state then
							transmog = "|TInterface\\Addons\\AllTheThings\\assets\\unknown:0|t"
						elseif state == 2 and self.db.profile.options.reward.gear.unknownSource then
							transmog = "|TInterface\\Addons\\AllTheThings\\assets\\known_circle:0|t"
						end
					elseif CanIMogIt then
						if CanIMogIt:IsEquippable(itemLink) and CanIMogIt:CharacterCanLearnTransmog(itemLink) then
							if not CanIMogIt:PlayerKnowsTransmog(itemLink) then
								transmog = "|TInterface\\AddOns\\CanIMogIt\\Icons\\UNKNOWN:0|t"
							elseif not CanIMogIt:PlayerKnowsTransmogFromItem(itemLink) and self.db.profile.options.reward.gear.unknownSource then
								transmog = "|TInterface\\AddOns\\CanIMogIt\\Icons\\KNOWN_circle:0|t"
							end
						end
					end
					if transmog then
						local item = {itemLink = itemLink, transmog = transmog}
						self:AddRewardToQuest(questID, "ITEM", item, isEmissary)
					end
				end
			end

			-- Reputation Token
			local factionID = ReputationItemList[itemID] or nil
			if factionID then
				if self.db.profile.options.reward.reputation[factionID] == true then
					local reputation = {itemLink = itemLink, factionID = factionID}
					self:AddRewardToQuest(questID, "REPUTATION", reputation, isEmissary)
				end
			end

			-- print(expacID, GetExpansionByQuestID(questID), itemLink, questID)
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
				local item = {itemLink = itemLink}
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
							self:AddRewardToQuest(questID, "ITEM", {itemLink = itemLink}, isEmissary)
						end
					end
				end
			end

			-- Conduit
			if self.db.profile.options.reward.gear.conduit and C_Soulbinds.IsItemConduitByItemInfo(itemLink) then
				self:AddRewardToQuest(questID, "ITEM", {itemLink = itemLink}, isEmissary)
			end
		else
			retry = true
		end
	end

	return retry
end

function WQA:CheckCurrencies(questID, isEmissary)
	local numQuestCurrencies = GetNumQuestLogRewardCurrencies(questID)
	for i = 1, numQuestCurrencies do
		local name, texture, numItems, currencyID = GetQuestLogRewardCurrencyInfo(i, questID)
		if self.db.profile.options.reward.currency[currencyID] then
			local currency = {currencyID = currencyID, amount = numItems}
			self:AddRewardToQuest(questID, "CURRENCY", currency, isEmissary)
		end

		-- Reputation Currency
		local factionID = ReputationCurrencyList[currencyID] or nil
		if factionID then
			if self.db.profile.options.reward.reputation[factionID] == true then
				local reputation = {name = name, currencyID = currencyID, amount = numItems, factionID = factionID}
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

local LibQTip = LibStub("LibQTip-1.0")

function WQA:CreateQTip()
	if not LibQTip:IsAcquired("WQAchievements") and not self.tooltip then
		local tooltip = LibQTip:Acquire("WQAchievements", 2, "LEFT", "LEFT")
		self.tooltip = tooltip

		if self.db.profile.options.popupShowExpansion or self.db.profile.options.popupShowZone then
			tooltip:AddColumn()
		end
		if self.db.profile.options.popupShowTime then
			tooltip:AddColumn()
		end

		tooltip:AddHeader("World Quest")
		tooltip:SetCell(1, tooltip:GetColumnCount(), "Reward")
		tooltip:SetFrameStrata("MEDIUM")
		tooltip:SetFrameLevel(100)
		tooltip:AddSeparator()
	end
end

function WQA:UpdateQTip(tasks)
	local tooltip = self.tooltip
	if next(tasks) == nil then
		tooltip:AddLine(L["NO_QUESTS"])
	else
		tooltip.quests = tooltip.quests or {}
		tooltip.missions = tooltip.missions or {}
		local i = tooltip:GetLineCount()
		local expansion, zoneID
		for _, task in ipairs(tasks) do
			local id = task.id
			if (task.type == "WORLD_QUEST" and not tooltip.quests[id]) or (task.type == "MISSION" and not tooltip.missions[id]) then
				local j = 1

				if self.db.profile.options.popupShowExpansion then
					j = 2
					if GetExpansion(task) ~= expansion then
						expansion = GetExpansion(task)
						tooltip:AddLine(string.format("|cff33ff33%s|r", GetExpansionName(expansion)))
						i = i + 1
						zoneID = nil
					end
				end

				tooltip:AddLine()
				i = i + 1

				if self.db.profile.options.popupShowZone then
					j = 2
					if GetTaskZoneID(task) ~= zoneID then
						zoneID = GetTaskZoneID(task)
						tooltip:SetCell(i, 1, "     " .. GetTaskZoneName(task))
					end
				end

				if self.db.profile.options.popupShowTime then
					tooltip:SetCell(i, j, self:formatTime(GetTaskTime(task)))
					j = j + 1
				end

				if task.type == "WORLD_QUEST" then
					tooltip.quests[id] = true
				elseif task.type == "MISSION" then
					tooltip.missions[id] = true
				end

				local link = GetTaskLink(task)
				tooltip:SetCell(i, j, link)

				tooltip:SetCellScript(
					i,
					j,
					"OnEnter",
					function(self)
						GameTooltip_SetDefaultAnchor(GameTooltip, self)
						GameTooltip:ClearLines()
						GameTooltip:ClearAllPoints()
						GameTooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 0)
						if task.type == "WORLD_QUEST" then
							if string.find(link, "|Hquest:") then
								GameTooltip:SetHyperlink(link)
							end
						else
							GameTooltip:SetText(C_Garrison.GetMissionName(id))
							GameTooltip:AddLine(
								string.format(GARRISON_MISSION_TOOLTIP_NUM_REQUIRED_FOLLOWERS, C_Garrison.GetMissionMaxFollowers(id)),
								1,
								1,
								1
							)
							GarrisonMissionButton_AddThreatsToTooltip(
								id,
								WQA.missionList[task.id].followerType,
								false,
								C_Garrison.GetFollowerAbilityCountersForMechanicTypes(WQA.missionList[task.id].followerType)
							)
							GameTooltip:AddLine(GARRISON_MISSION_AVAILABILITY)
							GameTooltip:AddLine(WQA.missionList[task.id].offerTimeRemaining, 1, 1, 1)
							if not C_Garrison.IsPlayerInGarrison(WQA.missionList[task.id].followerType) then
								GameTooltip:AddLine(" ")
								GameTooltip:AddLine(
									GarrisonFollowerOptions[WQA.missionList[task.id].followerType].strings.RETURN_TO_START,
									nil,
									nil,
									nil,
									1
								)
							end
						end
						GameTooltip:Show()
					end
				)
				tooltip:SetCellScript(
					i,
					j,
					"OnLeave",
					function()
						GameTooltip:Hide()
					end
				)
				tooltip:SetCellScript(
					i,
					j,
					"OnMouseDown",
					function()
						if ChatEdit_TryInsertChatLink(link) ~= true then
							if
								task.type == "WORLD_QUEST" and not WQA.questList[id].isEmissary and
									not (self.questPinList[id] or self.questFlagList[id])
							 then
								if WorldQuestTrackerAddon and self.db.profile.options.WorldQuestTracker then
									if WorldQuestTrackerAddon.IsQuestBeingTracked(id) then
										WorldQuestTrackerAddon.RemoveQuestFromTracker(id)
										WQA:ScheduleTimer(
											function()
												WorldQuestTrackerAddon:FullTrackerUpdate()
											end,
											.5
										)
									else
										local _, _, numObjectives = GetTaskInfo(id)
										local widget = {questID = id, mapID = GetQuestZoneID(id), numObjectives = numObjectives}
										zoneID = GetQuestZoneID(id)
										local x, y = C_TaskQuest.GetQuestLocation(id, zoneID)
										widget.questX, widget.questY = x or 0, y or 0
										widget.IconTexture =
											select(2, GetQuestLogRewardInfo(1, id)) or select(2, GetQuestLogRewardCurrencyInfo(1, id)) or
											[[Interface\GossipFrame\auctioneerGossipIcon]]
										local function f(widget)
											if not widget.IconTexture then
												WQA:ScheduleTimer(
													function()
														widget.IconTexture =
															select(2, GetQuestLogRewardInfo(1, id)) or select(2, GetQuestLogRewardCurrencyInfo(1, id))
														f(widget)
													end,
													1.5
												)
											else
												WorldQuestTrackerAddon.AddQuestToTracker(widget)
												WQA:ScheduleTimer(
													function()
														WorldQuestTrackerAddon:FullTrackerUpdate()
													end,
													.5
												)
											end
										end
										f(widget)
									end
								else
									if not C_QuestLog.AddWorldQuestWatch(id, 1) then
										C_QuestLog.RemoveWorldQuestWatch(id)
									end
								end
							end
						end
					end
				)

				local list
				if task.type == "WORLD_QUEST" then
					list = WQA.questList[id].reward
				elseif task.type == "MISSION" then
					list = WQA.missionList[id].reward
				end

				local more = false
				for k, v in pairs(list) do
					for n = 1, 3 do
						if n == 1 or (n > 1 and (k == "achievement" or k == "chance" or k == "azeriteTraits")) then
							local text = self:GetRewardTextByID(id, k, v, n, task.type)
							if text then
								j = j + 1

								if j > tooltip:GetColumnCount() then
									tooltip:AddColumn()
								end
								tooltip:SetCell(i, j, text)

								tooltip:SetCellScript(
									i,
									j,
									"OnEnter",
									function(self)
										GameTooltip:SetOwner(self, "ANCHOR_NONE")
										GameTooltip:ClearLines()
										ContainerFrameItemButton_CalculateItemTooltipAnchors(self, GameTooltip)

										if WQA:GetRewardLinkByID(id, k, v, n) then
											GameTooltip:SetHyperlink(WQA:GetRewardLinkByID(id, k, v, n))
										else
											GameTooltip:SetText(WQA:GetRewardTextByID(id, k, v, n, task.type))
										end
										GameTooltip:Show()
										if (IsModifiedClick("COMPAREITEMS") or GetCVarBool("alwaysCompareItems")) and k == "item" then
											GameTooltip_ShowCompareItem()
										else
											GameTooltip_HideShoppingTooltips(GameTooltip)
										end
									end
								)
								tooltip:SetCellScript(
									i,
									j,
									"OnLeave",
									function()
										GameTooltip_HideResetCursor()
									end
								)
								tooltip:SetCellScript(
									i,
									j,
									"OnMouseDown",
									function()
										HandleModifiedItemClick(WQA:GetRewardLinkByID(id, k, v, n))
									end
								)
								if n == 3 then
									local m = 4
									if self:GetRewardTextByID(id, k, v, m, task.type) then
										j = j + 1
										if j > tooltip:GetColumnCount() then
											tooltip:AddColumn()
										end
										tooltip:SetCell(i, j, "...")
										local moreTooltipText = ""
										while self:GetRewardTextByID(id, k, v, m, task.type) do
											if m == 4 then
												moreTooltipText = moreTooltipText .. self:GetRewardTextByID(id, k, v, m, task.type)
											else
												moreTooltipText = moreTooltipText .. "\n" .. self:GetRewardTextByID(id, k, v, m, task.type)
											end
											m = m + 1
										end

										tooltip:SetCellScript(
											i,
											j,
											"OnEnter",
											function(self)
												GameTooltip_SetDefaultAnchor(GameTooltip, self)
												GameTooltip:ClearLines()
												GameTooltip:ClearAllPoints()
												GameTooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 0)
												GameTooltip:SetText(moreTooltipText)
												GameTooltip:Show()
											end
										)
										tooltip:SetCellScript(
											i,
											j,
											"OnLeave",
											function()
												GameTooltip:Hide()
											end
										)
									end
								end
							end
						end
					end
				end
			end
		end
	end
	tooltip:Show()
end

function WQA:AnnouncePopUp(quests, silent)
	if not self.PopUp then
		local PopUp = CreateFrame("Frame", "WQAchievementsPopUp", UIParent, "UIPanelDialogTemplate")
		if self.db.profile.options.esc then
			tinsert(UISpecialFrames, "WQAchievementsPopUp")
		end
		self.PopUp = PopUp
		PopUp:SetMovable(true)
		PopUp:EnableMouse(true)
		PopUp:RegisterForDrag("LeftButton")
		PopUp:SetScript(
			"OnDragStart",
			function(self)
				self.moving = true
				self:StartMoving()
			end
		)
		PopUp:SetScript(
			"OnDragStop",
			function(self)
				self.moving = nil
				self:StopMovingOrSizing()
				if WQA.db.profile.options.popupRememberPosition then
					WQA.db.profile.options.popupX = self:GetLeft()
					WQA.db.profile.options.popupY = self:GetTop()
				end
			end
		)
		PopUp:SetWidth(300)
		PopUp:SetHeight(100)
		PopUp:SetPoint("CENTER") --, self.db.profile.options.popupX, self.db.profile.options.popupY)
		--PopUp:SetPoint("TOPLEFT", self.db.profile.options.popupX, self.db.profile.options.popupY)
		PopUp:Hide()

		PopUp:SetScript(
			"OnHide",
			function()
				LibQTip:Release(WQA.tooltip)
				WQA.tooltip.quests = nil
				WQA.tooltip.missions = nil
				WQA.tooltip = nil
				PopUp.shown = false
			end
		)
	end
	if next(quests) == nil and silent == true then
		return
	end
	local PopUp = self.PopUp
	PopUp:Show()
	PopUp.shown = true
	self:CreateQTip()
	self.tooltip:SetAutoHideDelay()
	self.tooltip:ClearAllPoints()
	self.tooltip:SetPoint("TOP", PopUp, "TOP", 2, -27)
	self:UpdateQTip(quests)
	PopUp:SetWidth(self.tooltip:GetWidth() + 8.5)
	PopUp:SetHeight(self.tooltip:GetHeight() + 32)
	PopUp:SetScale(self.tooltip:GetScale())
	PopUp:SetFrameLevel(self.tooltip:GetFrameLevel())

	if self.db.profile.options.popupRememberPosition then
		PopUp:ClearAllPoints()
		PopUp:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", self.db.profile.options.popupX, self.db.profile.options.popupY)
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

function WQA:GetRewardLinkByID(questId, key, value, i)
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

local function SortByZoneName(a, b)
	if a.type == "MISSION" and b.type ~= "MISSION" then
		return false
	elseif b.type == "MISSION" and a.type ~= "MISSION" then
		return true
	elseif a.type == "MISSION" and b.type == "MISSION" then
		return GetTaskZoneName(a) < GetTaskZoneName(b)
	else
		a = a.id
		b = b.id
	end
	if WQA.questList[a].isEmissary then
		if WQA.questList[b].isEmissary then
			return false
		else
			return true
		end
	elseif WQA.questList[b].isEmissary then
		return false
	end
	return GetQuestZoneName(a) < GetQuestZoneName(b)
end

local function SortByExpansion(a, b)
	a = GetExpansion(a)

	b = GetExpansion(b)
	--return GetExpansion(a) > GetExpansion(b)
	return a > b
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
		list = WQA:InsertionSort(list, SortByName)
	end

	if self.db.profile.options.sortByZoneName == true then
		list = WQA:InsertionSort(list, SortByZoneName)
	end

	list = WQA:InsertionSort(list, SortByExpansion)
	return list
end

local GetBountiesForMapIDRequested = false
function WQA:EmissaryReward()
	self.emissaryRewards = false
	local retry = false

	for _, mapID in pairs({627, 875}) do
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
	[6] = Enum.GarrisonType.Type_6_0,
	[7] = Enum.GarrisonType.Type_7_0,
	[8] = Enum.GarrisonType.Type_8_0,
	[9] = Enum.GarrisonType.Type_9_0
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
				for missionID, mission in ipairs(C_Garrison.GetAvailableMissions(Enum.GarrisonFollowerType.FollowerType_6_2)) do
					mission.followerType = Enum.GarrisonFollowerType.FollowerType_6_2
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
									local currency = {currencyID = currencyID, amount = amount}
									self:AddRewardToMission(missionID, "CURRENCY", currency)
									addMission = true
								else
									local factionID = ReputationCurrencyList[currencyID] or nil
									if factionID then
										if self.db.profile.options.missionTable.reward.reputation[factionID] == true then
											local reputation = {currencyID = currencyID, amount = amount, factionID = factionID}
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
									local item = {itemLink = itemLink}
									self:AddRewardToMission(missionID, "ITEM", item)
									addMission = true
								end

								-- Reputation Token
								local factionID = ReputationItemList[itemID] or nil
								if factionID then
									if self.db.profile.options.missionTable.reward.reputation[factionID] == true then
										local reputation = {itemLink = itemLink, factionID = factionID}
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
											if not searchForLinkResult then
												retry = true
											else
												local state = searchForLinkResult[1].collected
												if not state then
													transmog = "|TInterface\\Addons\\AllTheThings\\assets\\unknown:0|t"
												elseif state == 2 and self.db.profile.options.reward.gear.unknownSource then
													transmog = "|TInterface\\Addons\\AllTheThings\\assets\\known_circle:0|t"
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
											local item = {itemLink = itemLink, transmog = transmog}
											self:AddRewardToMission(missionID, "ITEM", item)
											addMission = true
										end
									end
								end

								-- Conduit
								if self.db.profile.options.reward.gear.conduit and C_Soulbinds.IsItemConduitByItemInfo(itemLink) then
									self:AddRewardToMission(missionID, "ITEM", {itemLink = itemLink})
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
