WQAchievements = LibStub("AceAddon-3.0"):NewAddon("WQAchievements", "AceConsole-3.0", "AceTimer-3.0")
local WQA = WQAchievements
WQA.data = {}
WQA.watched = {}
WQA.questList = {}
WQA.links = {}

-- Blizzard
local IsActive = C_TaskQuest.IsActive

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
if locale == "deDE" then
	L["WQChat"] = "Interessante Weltquests verfügbar:"
	L["WQforAch"] = "%s für %s"
	L["WQforAchTime"] = "%s (%s) für %s"
end

local function GetQuestZoneID(questID)
	if WQA.questList[questID].isEmissary then return "Emissary" end
	if not WQA.questList[questID].info then	WQA.questList[questID].info = {} end
	if WQA.questList[questID].info.zoneID then
		return WQA.questList[questID].info.zoneID
	else
		WQA.questList[questID].info.zoneID = C_TaskQuest.GetQuestZoneID(questID)
		return WQA.questList[questID].info.zoneID
	end
end

local function GetQuestZoneName(questID)
	if WQA.questList[questID].isEmissary then return "Emissary" end
	if not WQA.questList[questID].info then	WQA.questList[questID].info = {} end
	WQA.questList[questID].info.zoneName = WQA.questList[questID].info.zoneName or C_Map.GetMapInfo(GetQuestZoneID(questID)).name
	return WQA.questList[questID].info.zoneName
end

local function GetExpansion(questID)
	if not WQA.questList[questID].info then	WQA.questList[questID].info = {} end
	if WQA.questList[questID].info.expansion then
		return WQA.questList[questID].info.expansion
	else
		local zoneID = GetQuestZoneID(questID)
		for expansion,zones in ipairs(WQA.ZoneIDList) do
			for _, v in pairs(zones) do
				if zoneID == v then
					WQA.questList[questID].info.expansion = expansion
					return expansion
				end
			end
		end

		for expansion,v in ipairs(WQA.EmissaryQuestIDList) do
			for _,id in pairs(v) do
				if id == questID then
					WQA.questList[questID].info.expansion = expansion
					return expansion
				end
			end
		end
	end
	return -1
end

local function GetExpansionName(id)
	return WQA.ExpansionList[id] or "Unknown" end
	

local newOrder
do
	local current = 0
	function newOrder()
		current = current + 1
		return current
	end
end

WQA.data.custom = {wqID = "", rewardID = "", rewardType = "none"}
--WQA.data.customReward = 0

function WQA:OnInitialize()
	-- Defaults
	local defaults = {
		profile = {
			options = {
				['*'] = true,
				chat = true,
				PopUp = false,
				zone = { ['*'] = true},
				reward = {
					gear = {
						AzeriteArmorCache = true,
						itemLevelUpgrade = true,
						itemLevelUpgradeMin = 1,
						PawnUpgrade = true,
						StatWeightScore = true,
						PercentUpgradeMin = 1,
						unknownAppearance = true,
						unknownSource = false,
					},
					reputation = {['*'] = false},
					currency = {},
					craftingreagent = {['*'] = false},
					['*'] = { ['*'] = true},		
				},
				emissary = {['*'] = false},
				delay = 5,
			},
			['*'] = {['*'] = true}
		},
		global = {
			['*'] = {['*'] = false}
		}
	}
	self.db = LibStub("AceDB-3.0"):New("WQADB", defaults, true)	
end

function WQA:OnEnable()
	------------------
	-- 	Options
	------------------
	LibStub("AceConfig-3.0"):RegisterOptionsTable("WQAchievements", function() return self:GetOptions() end)
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("WQAchievements", "WQAchievements")
	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("WQAProfiles", profiles)
	self.optionsFrame.Profiles = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("WQAProfiles", "Profiles", "WQAchievements")

	self.event = CreateFrame("Frame")
	self.event:RegisterEvent("PLAYER_ENTERING_WORLD")
	self.event:SetScript("OnEvent", function (...)
		local _, name, id = ...
		if name == "PLAYER_ENTERING_WORLD" then
			self.event:UnregisterEvent("PLAYER_ENTERING_WORLD")
			self:ScheduleTimer("Show", self.db.profile.options.delay, nil, true)
			self:ScheduleTimer(function ()
				self:Show("new", true)
				self:ScheduleRepeatingTimer("Show", 30*60, "new", true)
			end, (32-(date("%M") % 30))*60)
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
		end
	end)
end

WQA:RegisterChatCommand("wqa", "slash")

function WQA:slash(input)
	local arg1 = string.lower(input)

	if arg1 == "" then
		self:Show()
		--self:CheckWQ()
	elseif arg1 == "new" then
		self:Show("new")
	elseif arg1 == "popup" then
		self:Show("popup")
	end
end

------------------
-- 	Data
------------------
--	Legion
do
	local legion = {}
	local trainer = {42159, 40299, 40277, 42442, 40298, 40280, 40282, 41687, 40278, 41944, 41895, 40337, 41990, 40279, 41860}
	legion = {
		name = "Legion",
		achievements = {
			{name = "Free For All, More For Me", id = 11474, criteriaType = "ACHIEVEMENT", criteria = {
				{id = 11475, notAccountwide = true},
				{id = 11476, notAccountwide = true},
				{id = 11477, notAccountwide = true},
				{id = 11478, notAccountwide = true}}
			},
			{name = "Family Familiar", id = 9696, criteriaType = "ACHIEVEMENT", criteria = {
				{id = 9686, criteriaType = "QUESTS", criteria = trainer},
				{id = 9687, criteriaType = "QUESTS", criteria = trainer},
				{id = 9688, criteriaType = "QUESTS", criteria = trainer},
				{id = 9689, criteriaType = "QUESTS", criteria = trainer},
				{id = 9690, criteriaType = "QUESTS", criteria = trainer},
				{id = 9691, criteriaType = "QUESTS", criteria = trainer},
				{id = 9692, criteriaType = "QUESTS", criteria = trainer},
				{id = 9693, criteriaType = "QUESTS", criteria = trainer},
				{id = 9694, criteriaType = "QUESTS", criteria = trainer},
				{id = 9695, criteriaType = "QUESTS", criteria = trainer}}
			},
			{name = "Battle on the Broken Isles", id = 10876},
			{name = "Fishing \'Round the Isles", id = 10598, criteriaType = "QUESTS", criteria = {
				{41612, 41613, 41270},
				nil,
				{41604, 41605, 41279},
				{41598, 41599, 41264},
				nil,
				nil,
				{41611, 41265, 41610},
				{41617, 41280, 41616},
				{41597, 41244, 41596},
				{41602, 41274, 41603},
				{41609, 41243},
				nil,
				nil,
				{41615, 41275, 41614},
				nil,
				nil,
				nil,
				nil,
				{41269, 41600, 41601}},
			},
			{name = "Crate Expectations", id = 11681, criteriaType = "QUEST_SINGLE", criteria = 45542},
			{name = "They See Me Rolling", id = 11607, criteriaType = "QUEST_SINGLE", criteria = 46175},
			{name = "Variety is the Spice of Life", id = 11189, criteriaType = "SPECIAL"},
		},
		mounts = {
			{name = "Maddened Chaosrunner", itemID = 152814, spellID = 253058, quest = {{trackingID = 48695, wqID = 48696}}},
			{name = "Crimson Slavermaw", itemID = 152905, spellID = 253661, quest = {{trackingID = 49183, wqID = 47561}}},
			{name = "Acid Belcher", itemID = 152904, spellID = 253662, quest = {{trackingID = 48721, wqID = 48740}}},
			{name = "Vile Fiend", itemID = 152790, spellID = 243652, quest = {{trackingID = 48821, wqID = 48835}}},
			{name = "Lambent Mana Ray", itemID = 152844, spellID = 253107, quest = {{trackingID = 48705, wqID = 48725}}},
			{name = "Biletooth Gnasher", itemID = 152903, spellID = 253660, quest = {{trackingID = 48810, wqID = 48465}, {trackingID = 48809, wqID = 48467}}},
			-- Egg
			{name = "Vibrant Mana Ray", itemID = 152842, spellID = 253106, quest = {{trackingID = 48667, wqID = 48502}, {trackingID = 48712, wqID = 48732}, {trackingID = 48812, wqID = 48827}}},
			{name = "Felglow Mana Ray", itemID = 152841, spellID = 253108, quest = {{trackingID = 48667, wqID = 48502}, {trackingID = 48712, wqID = 48732}, {trackingID = 48812, wqID = 48827}}},
			{name = "Scintillating Mana Ray", itemID = 152840, spellID = 253109, quest = {{trackingID = 48667, wqID = 48502}, {trackingID = 48712, wqID = 48732}, {trackingID = 48812, wqID = 48827}}},
			{name = "Darkspore Mana Ray", itemID = 152843, spellID = 235764, quest = {{trackingID = 48667, wqID = 48502}, {trackingID = 48712, wqID = 48732}, {trackingID = 48812, wqID = 48827}}},
		},
		pets = {
			{name = "Grasping Manifestation", itemID = 153056, creatureID = 128159, quest = {{trackingID = 0, wqID = 48729}}},
			-- Egg
			{name = "Fel-Afflicted Skyfin", itemID = 153055, creatureID = 128158, quest = {{trackingID = 48667, wqID = 48502}, {trackingID = 48712, wqID = 48732}, {trackingID = 48812, wqID = 48827}}},
			{name = "Docile Skyfin", itemID = 153054, creatureID = 128157, quest = {{trackingID = 48667, wqID = 48502}, {trackingID = 48712, wqID = 48732}, {trackingID = 48812, wqID = 48827}}},
			-- Emissary
			{name = "Thistleleaf Adventurer", itemID = 130167, creatureID = 99389, questID = 42170, emissary = true},
			{name = "Wondrous Wisdomball", itemID = 141348, creatureID = 113827, questID = 43179, emissary = true},
		},
		toys = {
			{name = "Barrier Generator", itemID = 153183, quest = {{trackingID = 48704, wqID = 48724}, {trackingID = 48703, wqID = 48723}}},
			{name = "Micro-Artillery Controller", itemID = 153126, quest = {{trackingID = 0, wqID = 48829}}},
			{name = "Spire of Spite", itemID = 153124, quest = {{trackingID = 0, wqID = 48512}}},
			{name = "Yellow Conservatory Scroll", itemID = 153180, quest = {{trackingID = 48718, wqID = 48737}}},
			{name = "Red Conservatory Scroll", itemID = 153181, quest = {{trackingID = 48718, wqID = 48737}}},
			{name = "Blue Conservatory Scroll", itemID = 153179, quest = {{trackingID = 48718, wqID = 48737}}},
			{name = "Baarut the Brisk", itemID = 153193, quest = {{trackingID = 0, wqID = 48701}}},
		}
	}
	WQA.data[1] = legion
end
-- Battle for Azeroth
do
	local bfa = {}
	local trainer = {52009, 52218, 52278, 52297, 52316, 52325, 52430, 52471, 52751, 52754, 52799, 52803, 52850, 52856, 52878, 52892, 52923, 52938}
	bfa = {
		name = "Battle for Azeroth",
		achievements = {
			{name = "Adept Sandfisher", id = 13009, criteriaType = "QUEST_SINGLE", criteria = 51173},
			{name = "Scourge of Zem'lan", id = 13011, criteriaType = "QUESTS", criteria = {{51763, 51783}}},
			{name = "Vorrik's Champion", id = 13014, criteriaType = "QUESTS", criteria = {51957, 51983}},
			{name = "Revenge is Best Served Speedily", id = 13022, criteriaType = "QUEST_SINGLE", criteria = 50786},
			{name = "It's Really Getting Out of Hand", id = 13023, criteriaType = "QUEST_SINGLE", criteria = 50559},
			{name = "Zandalari Spycatcher", id = 13025, criteriaType = "QUEST_SINGLE", criteria = 50717},
			{name = "7th Legion Spycatcher", id = 13026, criteriaType = "QUEST_SINGLE", criteria = 50899},
			{name = "By de Power of de Loa!", id = 13035, criteriaType = "QUEST_SINGLE", criteria = 51178},
			{name = "Bless the Rains Down in Freehold", id = 13050, criteriaType = "QUESTS", criteria = {{53196, 52159}}},
			{name = "Kul Runnings", id = 13060, criteriaType = "QUESTS", criteria = {49994, 53188, 53189}},	-- Frozen Freestyle
			{name = "Battle on Zandalar and Kul Tiras", id = 12936},
			{name = "A Most Efficient Apocalypse", id = 13021, criteriaType = "QUEST_SINGLE", criteria = 50665},
			-- Thanks NatalieWright
			{name = "Adventurer of Zuldazar", id = 12944, criteriaType = "QUESTS", criteria = {50864, 50877, {51085, 51087}, 51081, {50287, 51374, 50866}, 50885, 50863, 50862, 50861, 50859, 50845, 50857, nil, 50875, 50874, nil, 50872, 50876, 50871, 50870, 50869, 50868, 50867}},
			{name = "Adventurer of Vol'dun", id = 12943, criteriaType = "QUESTS", criteria = {51105, 51095, 51096, 51117, nil, 51118, 51120, 51098, 51121, 51099, 51108, 51100, 51125, 51102, 51429, 51103, 51124, 51107, 51122, 51123, 51104, 51116, 51106, 51119, 51112, 51113, 51114, 51115}},
			{name = "Adventurer of Nazmir", id = 12942, criteriaType = "QUESTS", criteria = {50488, 50570, 50564, nil, 50490, 50506, 50568, 50491, 50492, 50499, 50496, 50498, 50501, nil, 50502, 50503, 50505, 50507, 50566, 50511, 50512, nil, 50513, 50514, nil, 50515, 50516, 50489, 50519, 50518, 50509, 50517}},
			{name = "Adventurer of Drustvar", id = 12941, criteriaType = "QUESTS", criteria = {51469, 51505, 51506, 51508, 51468, 51972, nil, nil, nil, 51897, 51457, nil, 51909, 51507, 51917, nil, 51919, 51908, 51491, 51512, 51527, 51461, 51467, 51528, 51466, 51541, 51542, 51884, 51874, 51906, 51887, 51989, 51988}},
			{name = "Adventurer of Tiragarde Sound", id = 12939, criteriaType = "QUESTS", criteria = {51653, 51652, 51666, 51669, 51841, 51665, 51848, 51842, 51654, 51662, 51844, 51664, 51670, 51895, nil, 51659, 51843, 51660, 51661, 51890, 51656, 51893, 51892, 51651, 51839, 51891, 51849, 51894, 51655, 51847, nil, 51657}},
			{name = "Adventurer of Stormsong Valley", id = 12940, criteriaType = "QUESTS", criteria = {52452, 52315, 51759, {51976, 51977, 51978}, 52476, 51774, 51921, nil, 51776, 52459, 52321, 51781, nil, 51886, 51779, 51778, 52306, 52310, 51901, 51777, 52301, nil, 52463, nil, 52328, 51782, 52299, nil, 52300, nil, 52464, 52309, 52322, nil}},
			{name = "Sabertron Assemble", id = 13054, criteriaType = "QUESTS", criteria = {nil, 51977, 51978, 51976, 51978}},
			-- Sabertron Assemble
			-- green 51976
			{name = "Drag Race", id = 13059, criteriaType = "QUEST_SINGLE", criteria = 53346},
			{name = "Unbound Monstrosities", id = 12587, criteriaType = "QUESTS", criteria = {52166, 52157, 52181, 52169, 52196, 136385}},
			{name = "Wide World of Quests", id = 13144, criteriaType = "SPECIAL"},
			{name = "Family Battler", id = 13279, criteriaType = "ACHIEVEMENT", criteria = {
				{id = 13280, criteriaType = "QUESTS", criteria = trainer},
				{id = 13270, criteriaType = "QUESTS", criteria = trainer},
				{id = 13271, criteriaType = "QUESTS", criteria = trainer},
				{id = 13272, criteriaType = "QUESTS", criteria = trainer},
				{id = 13273, criteriaType = "QUESTS", criteria = trainer},
				{id = 13274, criteriaType = "QUESTS", criteria = trainer},
				{id = 13281, criteriaType = "QUESTS", criteria = trainer},
				{id = 13275, criteriaType = "QUESTS", criteria = trainer},
				{id = 13277, criteriaType = "QUESTS", criteria = trainer},
				{id = 13278, criteriaType = "QUESTS", criteria = trainer}}
			},
		},
		toys = {
			{name = "Echoes of Rezan", itemID = 160509, quest = {{trackingID = 0, wqID = 50855}}},
			{name = "Toy Siege Tower", itemID = 163828, quest = {{trackingID = 0, wqID = 52847}}},
			{name = "Toy War Machine", itemID = 163829, quest = {{trackingID = 0, wqID = 52848}}},
		}
	}
	WQA.data[2] = bfa
end

-- Terrors of the Shore
-- Commander of Argus

function WQA:CreateQuestList()
	self:Debug("CreateQuestList")
	self.questList = {}

	for _,v in pairs(self.data[1].achievements) do
		self:AddAchievements(v)
	end
	self:AddMounts(self.data[1].mounts)
	self:AddPets(self.data[1].pets)
	self:AddToys(self.data[1].toys)

	for _,v in pairs(self.data[2].achievements) do
		self:AddAchievements(v)
	end
	self:AddToys(self.data[2].toys)
	
	self:AddCustom()
	self:Special()
	self:Reward()
	self:EmissaryReward()
end

function WQA:AddAchievements(achievement)
	if self.db.profile.achievements[achievement.name] == false then return end
	local id = achievement.id
	local _,_,_,completed,_,_,_,_,_,_,_,_,wasEarnedByMe = GetAchievementInfo(id)
	if (achievement.notAccountwide and not wasEarnedByMe) or not completed then
		if achievement.criteriaType == "ACHIEVEMENT" then
			for _,v in pairs(achievement.criteria) do
				self:AddAchievements(v)
			end
		elseif achievement.criteriaType == "QUEST_SINGLE" then
			self:AddReward(achievement.criteria, "ACHIEVEMENT", id)
		elseif achievement.criteriaType ~= "SPECIAL" then
			for i=1, GetAchievementNumCriteria(id) do
				local _,t,completed,_,_,_,_,questID = GetAchievementCriteriaInfo(id,i)
				if not completed then
					if achievement.criteriaType == "QUESTS" then
						if type(achievement.criteria[i]) == "table" then
							for _,questID in pairs(achievement.criteria[i]) do
								self:AddReward(questID, "ACHIEVEMENT", id)
							end
						else
							questID = achievement.criteria[i] or 0
							self:AddReward(questID, "ACHIEVEMENT", id)
						end
					elseif achievement.criteriaType == 1 and t == 0 then
						for _,questID in pairs(achievement.criteria[i]) do
							self:AddReward(questID, "ACHIEVEMENT", id)
						end
					else
						self:AddReward(questID, "ACHIEVEMENT", id)
					end
				end
			end	
		end
	end
end

function WQA:AddMounts(mounts)
	for i,id in pairs(C_MountJournal.GetMountIDs()) do
		local n, spellID, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(id)
		if not isCollected then
			for _,mount in pairs(mounts) do
				if self.db.profile.mounts[mount.name] == true then
					if spellID == mount.spellID then
						for _,v  in pairs(mount.quest) do
							if not IsQuestFlaggedCompleted(v.trackingID) then
								self:AddReward(v.wqID, "CHANCE", mount.itemID)
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
  		if not owned then
  			for _,pet in pairs(pets) do
  				if self.db.profile.pets[pet.name] == true then
					  if companionID == pet.creatureID then
						if pet.emissary == true then
							self:AddEmissaryReward(pet.questID, "CHANCE", pet.itemID)
						else
							for _,v in pairs(pet.quest) do
								if not IsQuestFlaggedCompleted(v.trackingID) then
									self:AddReward(v.wqID, "CHANCE", pet.itemID)
								end
							end
		  				end
		  			end
		  		end
  			end
  		end
  	end
end

function WQA:AddToys(toys)
	for _,toy in pairs(toys) do
		if self.db.profile.toys[toy.name] == true then
			if not PlayerHasToy(toy.itemID) then
				for _,v in pairs(toy.quest) do
					if not IsQuestFlaggedCompleted(v.trackingID) then
						self:AddReward(v.wqID, "CHANCE", toy.itemID)
					end
				end
			end
		end
	end
end

function WQA:AddCustom()
	if type(self.db.global.custom) == "table" then
		for k,v in pairs(self.db.global.custom) do
			if self.db.profile.custom[k] == true then
				self:AddReward(k, "CUSTOM")
			end
		end
	end
end

function WQA:AddReward(questID, rewardType, reward, emissary)
	if not self.questList[questID] then self.questList[questID] = {} end
	local l = self.questList[questID]
	if emissary == true then
		l.isEmissary = true
	end
	if not l.reward then l.reward = {} end
	l = l.reward
	if rewardType == "ACHIEVEMENT" then
		if not l.achievement then l.achievement = {} end
		l.achievement[#l.achievement + 1] = {id = reward}
	elseif rewardType == "CHANCE" then
		if not l.chance then l.chance = {} end
		l.chance[#l.chance + 1] = {id = reward}
	elseif rewardType == "CUSTOM" then
		if not l.custom then l.custom = true end
	elseif rewardType == "ITEM" then
 		if not l.item then l.item = {} end
 		for k,v in pairs(reward) do
 			l.item[k] = v
 		end
	elseif rewardType == "REPUTATION" then
		if not l.reputation then l.reputation = {} end
 		for k,v in pairs(reward) do
 			l.reputation[k] = v
 		end
	elseif rewardType == "RECIPE" then
		l.recipe = reward
	elseif rewardType == "CUSTOM_ITEM" then
		l.customItem = reward
	elseif rewardType == "CURRENCY" then
		if not l.currency then l.currency = {} end
 		for k,v in pairs(reward) do
 			l.currency[k] = v
 		end	
	end
end

function WQA:AddEmissaryReward(questID, rewardType, reward)
	self:AddReward(questID, rewardType, reward, true)
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
	for questID,qList in pairs(self.questList) do
		if IsActive(questID) or self:EmissaryIsActive(questID) then
			local questLink = GetQuestLink(questID)
			local link
			for k,v in pairs(self.questList[questID].reward) do
				if k == "custom" then
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
			end
			if not questLink or not link then
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

	if retry == true then
		self:Debug("NoLink")
		self:ScheduleTimer("CheckWQ", 1, mode)
		return
	end

	self.activeQuests = {}
	for id in pairs(activeQuests) do table.insert(self.activeQuests, id) end

	self.activeQuests = self:SortQuestList(self.activeQuests)

	self.newQuests = {}
	for id in pairs(newQuests) do
		self.watched[id] = true
		table.insert(self.newQuests, id)
	end

	if mode == "new" then
		self:AnnounceChat(self.newQuests, self.first)
		if self.db.profile.options.PopUp == true then
			self:AnnouncePopUp(self.newQuests, self.first)
		end
	elseif mode == "popup" then
		self:AnnouncePopUp(self.activeQuests)
	elseif mode == "LDB" then
		self:AnnounceLDB(self.activeQuests)
	else
		self:AnnounceChat(self.activeQuests)
		if self.db.profile.options.PopUp == true then
			self:AnnouncePopUp(self.activeQuests)
		end
	end

	self:UpdateLDBText(next(activeQuests), next(newQuests))
end

function WQA:link(x)
	if not x then return "" end
	local t = string.upper(x.type)
	if t == "ACHIEVEMENT" then
		return GetAchievementLink(x.id)
	elseif t == "ITEM" then
		return select(2,GetItemInfo(x.id))
	else
		return ""
	end
end

local icons = {
	unknown = "|TInterface\\AddOns\\CanIMogIt\\Icons\\UNKNOWN:0|t",
	known = "|TInterface\\AddOns\\CanIMogIt\\Icons\\KNOWN_circle:0|t",
}

function WQA:GetRewardForID(questID, key)
	local l = self.questList[questID].reward
	local r = ""
	if l then
		if l.item then
			if l.item then
				if l.item.transmog then
					r = r..icons[l.item.transmog]
				end
				if l.item.itemLevelUpgrade then
					if r ~= "" then r = r.." " end
					r = r.."|cFF00FF00+"..l.item.itemLevelUpgrade.." iLvl|r"
				end
				if l.item.itemPercentUpgrade then
					if r ~= "" then r = r..", " end
					r = r.."|cFF00FF00+"..l.item.itemPercentUpgrade.."%|r"
				end
				if l.item.AzeriteArmorCache then
					for i=1,5,2 do
						local upgrade = l.item.AzeriteArmorCache[i]
						if upgrade > 0 then
							r = r.."|cFF00FF00+"..upgrade.." iLvl|r"
						elseif upgrade < 0 then
							r = r.."|cFFFF0000"..upgrade.." iLvl|r"
						else
							r = r.."±"..upgrade
						end
						if i ~= 5 then
							r = r.." / "
						end
					end
				end
			end
			r = l.item.itemLink.." "..r
		end
		if l.currency and key ~= "item" then
			r = r..l.currency.amount.." "..l.currency.name
		end
	end
	return r
end

function WQA:AnnounceChat(activeQuests, silent)
	if self.db.profile.options.chat == false then return end
	if next(activeQuests) == nil then
		if silent ~= true then
			print(L["NO_QUESTS"])
		end
		return
	end

	local output = L["WQChat"]
	print(output)
	local expansion, zoneID
	for _, questID in ipairs(activeQuests) do
		local text, i = "", 0

		if self.db.profile.options.chatShowExpansion == true then
			if GetExpansion(questID) ~= expansion then
				expansion = GetExpansion(questID)
				print(GetExpansionName(expansion))
			end
		end

		if self.db.profile.options.chatShowZone == true then
			if GetQuestZoneID(questID) ~= zoneID then
				zoneID = GetQuestZoneID(questID)
				print(GetQuestZoneName(questID))
			end
		end

		for k,v in pairs(self.questList[questID].reward) do
			i = i + 1
			if i > 1 then
				text = text.." & "..self:GetRewardTextByID(questID, k, v, 1)
			else
				text =self:GetRewardTextByID(questID, k, v, 1)
			end
		end

		if self.db.profile.options.chatShowTime then
			output = "   "..string.format(L["WQforAchTime"], GetQuestLink(questID), self:formatTime(C_TaskQuest.GetQuestTimeLeftMinutes(questID)), text)
		else
			output = "   "..string.format(L["WQforAch"], GetQuestLink(questID), text)
		end
		print(output)
	end
end

local inspectScantip = CreateFrame("GameTooltip", "WorldQuestListInspectScanningTooltip", nil, "GameTooltipTemplate")
inspectScantip:SetOwner(UIParent, "ANCHOR_NONE")

local EquipLocToSlot1 = 
{
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
	INVTYPE_TABARD = 19,
}
local EquipLocToSlot2 = 
{
	INVTYPE_FINGER = 12,
	INVTYPE_TRINKET = 14,
	INVTYPE_WEAPON = 17,
}

ItemTooltipScan = CreateFrame ("GameTooltip", "WQTItemTooltipScan", UIParent, "InternalEmbeddedItemTooltipTemplate")
   	ItemTooltipScan.texts = {
   		_G ["WQTItemTooltipScanTooltipTextLeft1"],
   		_G ["WQTItemTooltipScanTooltipTextLeft2"],
   		_G ["WQTItemTooltipScanTooltipTextLeft3"],
   		_G ["WQTItemTooltipScanTooltipTextLeft4"],
  }
	ItemTooltipScan.patern = ITEM_LEVEL:gsub ("%%d", "(%%d+)") --from LibItemUpgradeInfo-1.0

local ReputationItemList = {
	[152957] = 2165, -- Army of the Light Insignia
	[152960] = 2170, -- Argussian Reach Insignia
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
}

function WQA:Reward()
	self:Debug("Reward")

	self.event:UnregisterEvent("QUEST_LOG_UPDATE")
	self.event:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
	self.rewards = false
	local retry = false

	for i=1,#self.ZoneIDList do
		for _,mapID in pairs(self.ZoneIDList[i]) do
			if self.db.profile.options.zone[mapID] == true then
				local quests = C_TaskQuest.GetQuestsForPlayerByMapID(mapID)
				if quests then
					for i=1,#quests do
						local questID = quests[i].questId
						if self.db.profile.options.zone[C_TaskQuest.GetQuestZoneID(questID)] == true then
							-- 100 different World Quests achievements
							if QuestUtils_IsQuestWorldQuest(questID) and not self.db.global.completed[questID] then
								local zoneID = C_TaskQuest.GetQuestZoneID(questID)
								local exp = 0
								for expansion,zones in ipairs(WQA.ZoneIDList) do
									for _, v in pairs(zones) do
										if zoneID == v then
											exp = expansion
										end
									end
								end

								if self.db.profile.achievements["Variety is the Spice of Life"] == true and not select(4,GetAchievementInfo(11189)) == true  and exp == 1 and not mapID == 885 and not mapID == 830 and not mapID == 882 then
									self:AddReward(questID, "ACHIEVEMENT", 11189)
								elseif self.db.profile.achievements["Wide World of Quests"] == true and not select(4,GetAchievementInfo(13144)) == true and exp == 2 then
									self:AddReward(questID, "ACHIEVEMENT", 13144)
								end
							end

							if HaveQuestData(questID) and not HaveQuestRewardData(questID) then
								C_TaskQuest.RequestPreloadRewardData(questID)
								retry = true
							end
							retry = (self:CheckItems(questID) or retry)
							self:CheckCurrencies(questID)
						end
					end
				end
			end
		end
	end

	if retry == true then
		self.Debug("|cFFFF0000<<<RETRY>>>|r")
		self.start = GetTime()
		self.timer = self:ScheduleTimer(function() self:Reward() end, 2)
		self.event:RegisterEvent("QUEST_LOG_UPDATE")
		self.event:RegisterEvent("GET_ITEM_INFO_RECEIVED")
	else
		self.rewards = true
	end
end

function WQA:CheckItems(questID, isEmissary)
	local retry = false
	local numQuestRewards = GetNumQuestLogRewards(questID)
	if numQuestRewards > 0 then
		local itemName, itemTexture, quantity, quality, isUsable, itemID = GetQuestLogRewardInfo(1, questID)
		if itemID then
			inspectScantip:SetQuestLogItem("reward", 1, questID)
			itemLink = select(2,inspectScantip:GetItem())
			--print(":",itemLink)
			local itemName, _, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice, itemClassID, itemSubClassID, _, expacID = GetItemInfo(itemLink)

			-- Ask Pawn if this is an Upgrade
			if PawnIsItemAnUpgrade and self.db.profile.options.reward.gear.PawnUpgrade then
				local Item = PawnGetItemData(itemLink)
				if Item then
					local UpgradeInfo, BestItemFor, SecondBestItemFor, NeedsEnhancements = PawnIsItemAnUpgrade(Item)
					if UpgradeInfo and UpgradeInfo[1].PercentUpgrade*100 >= self.db.profile.options.reward.gear.PercentUpgradeMin then
						local item = {itemLink = itemLink, itemPercentUpgrade = math.floor(UpgradeInfo[1].PercentUpgrade*100+.5)}
						self:AddReward(questID, "ITEM", item, isEmissary)
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
					for _,spec in pairs(specs) do
						if spec.Enabled then
							local score = ScoreModule:CalculateItemScore(itemLink, slotID, ScanningTooltipModule:ScanTooltip(itemLink), spec, equippedItemHasUniqueGem).Score
							local equippedScore
							local equippedLink = GetInventoryItemLink("player", slotID)
							if equippedLink then
								equippedScore = ScoreModule:CalculateItemScore(equippedLink, slotID, ScanningTooltipModule:ScanTooltip(equippedLink), spec, equippedItemHasUniqueGem).Score
							else
								retry = true
							end
							
							slotID2 =  EquipLocToSlot2[itemEquipLoc]
							if slotID2 then
								equippedLink = GetInventoryItemLink("player", slotID2)
								if equippedLink then
									local equippedScore2 = ScoreModule:CalculateItemScore(equippedLink, slotID2, ScanningTooltipModule:ScanTooltip(equippedLink), spec, equippedItemHasUniqueGem).Score
									if equippedScore or 0 > equippedScore2 then
										equippedScore = equippedScore2
									end
								else
									retry = true
								end
							end

							if equippedScore then
								if (score-equippedScore)/equippedScore*100 > itemPercentUpgrade then
									itemPercentUpgrade = (score-equippedScore)/equippedScore*100
								end
							end
						end
					end
					if itemPercentUpgrade >= self.db.profile.options.reward.gear.PercentUpgradeMin then
						local item = {itemLink = itemLink, itemPercentUpgrade = math.floor(itemPercentUpgrade + .5)}
						self:AddReward(questID, "ITEM", item, isEmissary)
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
					self:AddReward(questID, "ITEM", item, isEmissary)
				end
			end

			-- Azerite Armor Cache
			if itemID == 163857 and self.db.profile.options.reward.gear.AzeriteArmorCache then
				itemLevel = GetDetailedItemLevelInfo(itemLink)
				local AzeriteArmorCacheIsUpgrade = false
				local AzeriteArmorCache = {}
				for i=1,5,2 do
					if GetInventoryItemID("player", i) then
						local itemLink1 = GetInventoryItemLink("player", i)
						if itemLink1 then
							itemLevel1 = GetDetailedItemLevelInfo(itemLink1)
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
						if itemLevel > itemLevel1 and itemLevel >= self.db.profile.options.reward.gear.itemLevelUpgradeMin then
							AzeriteArmorCacheIsUpgrade = true
						end
					end
				end
				if AzeriteArmorCacheIsUpgrade == true then
					local item = {itemLink = itemLink, AzeriteArmorCache = AzeriteArmorCache}
					self:AddReward(questID, "ITEM", item, isEmissary)
				end
			end

			-- Transmog
			if CanIMogIt and self.db.profile.options.reward.gear.unknownAppearance then
				if CanIMogIt:IsEquippable(itemLink) and CanIMogIt:CharacterCanLearnTransmog(itemLink) then
					local transmog
					if not CanIMogIt:PlayerKnowsTransmog(itemLink) then
						transmog = "unknown"
					elseif not CanIMogIt:PlayerKnowsTransmogFromItem(itemLink) and self.db.profile.options.reward.gear.unknownSource then
						transmog = "known"
					end
					if transmog then
						local item = {itemLink = itemLink, transmog = transmog}
						self:AddReward(questID, "ITEM", item, isEmissary)
					end
				end
			end

			-- Reputation Token
			local factionID = ReputationItemList[itemID] or nil
			if factionID then
				if self.db.profile.options.reward.reputation[factionID] == true then
					local reputation = {itemLink = itemLink, factionID = factionID}
					self:AddReward(questID, "REPUTATION", reputation, isEmissary)
				end
			end

			-- Recipe
			if itemClassID == 9 then
				if self.db.profile.options.reward.recipe[expacID] == true then
					self:AddReward(questID, "RECIPE", itemLink, isEmissary)
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
			if self.db.global.customReward[itemID] == true then
				if self.db.profile.customReward[itemID] == true then
					self:AddReward(questID, "CUSTOM_ITEM", itemLink, isEmissary)
				end
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
			 self:AddReward(questID, "CURRENCY", currency, isEmissary)
		 end

		 -- Reputation Currency
		 local factionID = ReputationCurrencyList[currencyID] or nil
		 if factionID then
			 if self.db.profile.options.reward.reputation[factionID] == true then
				 local reputation = {name = name, currencyID = currencyID, amount = numItems, factionID = factionID}
				 self:AddReward(questID, "REPUTATION", reputation, isEmissary)
			 end
		 end
	end
end

WQA.debug = false
function WQA:Debug(...)
	if self.debug == true
		then print(GetTime(),GetFramerate(),...)
	end
end

local LibQTip = LibStub("LibQTip-1.0")

function WQA:CreateQTip()
	if not LibQTip:IsAcquired("WQAchievements") and not self.tooltip then
		local tooltip = LibQTip:Acquire("WQAchievements", 2, "LEFT", "LEFT")
		self.tooltip = tooltip
		
		if self.db.profile.options.popupShowExpansion or self.db.profile.options.popupShowZone  then
			tooltip:AddColumn()
		end
		if self.db.profile.options.popupShowTime then
			tooltip:AddColumn()
		end

		tooltip:AddHeader("World Quest")
		tooltip:SetCell(1, tooltip:GetColumnCount(), "Reward")
		tooltip:SetFrameStrata("HIGH")
		tooltip:AddSeparator()
	end
end

function WQA:UpdateQTip(quests)
	local tooltip = self.tooltip
	if next(quests) == nil then
		tooltip:AddLine(L["NO_QUESTS"])
	else
		tooltip.quests = tooltip.quests or {}
		local i = tooltip:GetLineCount()
		local expansion, zoneID
		for _, questID in ipairs(quests) do
			if not tooltip.quests[questID] then
				local j = 1

				if self.db.profile.options.popupShowExpansion then
					j = 2
					if GetExpansion(questID) ~= expansion then
						expansion = GetExpansion(questID)
						tooltip:AddLine(GetExpansionName(expansion))
						i = i + 1
						zoneID = nil
					end
				end

				tooltip:AddLine()
				i = i + 1
				
				if self.db.profile.options.popupShowZone then
					j = 2
					if GetQuestZoneID(questID) ~= zoneID then
						zoneID = GetQuestZoneID(questID)
						tooltip:SetCell(i,1,GetQuestZoneName(questID))
					end
				end

				if self.db.profile.options.popupShowTime then
					tooltip:SetCell(i, j, self:formatTime(C_TaskQuest.GetQuestTimeLeftMinutes(questID)))
					j = j + 1
				end

				tooltip.quests[questID] = true			
				local questLink = GetQuestLink(questID)
				tooltip:SetCell(i,j,questLink)

				tooltip:SetCellScript(i, j, "OnEnter", function(self) 
					GameTooltip_SetDefaultAnchor(GameTooltip, self)
					GameTooltip:ClearLines()
					GameTooltip:ClearAllPoints()
					GameTooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 0)
					GameTooltip:SetHyperlink(questLink)
					GameTooltip:Show()
				end)
				tooltip:SetCellScript(i, j, "OnLeave", function() GameTooltip:Hide() end)
				tooltip:SetCellScript(i, j, "OnMouseDown", function()
					if ChatEdit_TryInsertChatLink(questLink) ~= true then
						if WorldQuestTrackerAddon and self.db.profile.options.WorldQuestTracker then
							if WorldQuestTrackerAddon.IsQuestBeingTracked(questID) then
								WorldQuestTrackerAddon.RemoveQuestFromTracker(questID)
								WQA:ScheduleTimer(function () WorldQuestTrackerAddon:FullTrackerUpdate() end, .5)
							else
								local _, _, numObjectives = GetTaskInfo(questID)
								local widget = {questID = questID, mapID = GetQuestZoneID(questID), numObjectives = numObjectives}
								local x, y = C_TaskQuest.GetQuestLocation (questID, zoneID)
								widget.questX, widget.questY = x or 0, y or 0
								widget.IconTexture = select(2,GetQuestLogRewardInfo(1, questID)) or select(2, GetQuestLogRewardCurrencyInfo(1, questID))
								local function f(widget)
									if not widget.IconTexture then
										WQA:ScheduleTimer(function()
											widget.IconTexture = select(2,GetQuestLogRewardInfo(1, questID)) or select(2, GetQuestLogRewardCurrencyInfo(1, questID))
											f(widget) end, 1.5)
									else
										WorldQuestTrackerAddon.AddQuestToTracker(widget)
										WQA:ScheduleTimer(function () WorldQuestTrackerAddon:FullTrackerUpdate() end, .5)
									end
								end
								f(widget)
							end
						else
							if IsWorldQuestHardWatched(questID) or (IsWorldQuestWatched(questID) and GetSuperTrackedQuestID() == questID) then
								BonusObjectiveTracker_UntrackWorldQuest(questID)
							else
								BonusObjectiveTracker_TrackWorldQuest(questID, true)
							end
						end				
					end					
				end)
				
				for k,v in pairs(WQA.questList[questID].reward) do
					j = j + 1
					local text = self:GetRewardTextByID(questID, k, v, 1)
					if j > tooltip:GetColumnCount() then tooltip:AddColumn() end
					tooltip:SetCell(i, j, text)
				
					tooltip:SetCellScript(i, j, "OnEnter", function(self) 
						GameTooltip_SetDefaultAnchor(GameTooltip, self)
						GameTooltip:ClearLines()
						GameTooltip:ClearAllPoints()
						GameTooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 0)
						
						if WQA:GetRewardLinkByID(questID, k, v, 1) then
							GameTooltip:SetHyperlink(WQA:GetRewardLinkByID(questID, k, v, 1))
						else
							GameTooltip:SetText(WQA:GetRewardTextByID(questID, k, v, 1))
						end
						GameTooltip:Show()
						if IsModifiedClick("COMPAREITEMS") or GetCVarBool("alwaysCompareItems") then
							GameTooltip_ShowCompareItem()
						end
					end)
					tooltip:SetCellScript(i, j, "OnLeave", function() GameTooltip:Hide() end)
					tooltip:SetCellScript(i, j, "OnMouseDown", function()
						HandleModifiedItemClick(WQA:GetRewardLinkByID(questID, k, v, 1))
					end)
				end
			end
		end
	end
	tooltip:Show()
end

function WQA:AnnouncePopUp(quests, silent)
	if not self.PopUp then
		local PopUp = CreateFrame("Frame", "WQAchievementsPopUp", UIParent, "UIPanelDialogTemplate")
		self.PopUp = PopUp
		PopUp:SetMovable(true)
		PopUp:EnableMouse(true)
		PopUp:RegisterForDrag("LeftButton")
		PopUp:SetScript("OnDragStart", function(self)
			self.moving = true
		    self:StartMoving()
		end)
		PopUp:SetScript("OnDragStop", function(self)
			self.moving = nil
		    self:StopMovingOrSizing()
		end)
		PopUp:SetWidth(300)
		PopUp:SetHeight(100)
		PopUp:SetPoint("CENTER")
		PopUp:Hide()

		PopUp:SetScript("OnHide", function()
			LibQTip:Release(WQA.tooltip)
			WQA.tooltip.quests = nil
			WQA.tooltip = nil
			PopUp.shown = false
		end)
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
	PopUp:SetWidth(self.tooltip:GetWidth()+8.5)
	PopUp:SetHeight(self.tooltip:GetHeight()+32)
end

function WQA:GetRewardTextByID(questID, key, value, i)
	local k, v = key, value
	local text
	if k == "custom" then
		text = "Custom"
	elseif k == "item" then
		text = self:GetRewardForID(questID, k)	
	elseif k == "reputation" then
		if v.itemLink then
			text = self:GetRewardLinkByID(questID, k, v, i)
		else
			text = v.amount.." "..self:GetRewardLinkByID(questID, k, v, i)
		end
	elseif k == "currency" then
		text = v.amount.." "..GetCurrencyLink(v.currencyID, v.amount)
	else
		text = self:GetRewardLinkByID(questID, k, v, i)
	end
	return text
end

function WQA:GetRewardLinkByID(questId, key, value, i)
	local k, v = key, value
	local link = nil
	if k == "achievement" then
		link = v[i].achievementLink or GetAchievementLink(v[i].id)
	elseif k == "chance" then
		link = v[i].itemLink or select(2,GetItemInfo(v[i].id))
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
	end
	return link
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

local function SortByZoneName(a,b)
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

local function SortByExpansion(a,b)
	return GetExpansion(a) > GetExpansion(b)
end

local function GetQuestName(questID)
	return C_TaskQuest.GetQuestInfoByQuestID(questID) or C_QuestLog.GetQuestInfo(questID) or select(3,string.find(GetQuestLink(questID), "%[(.+)%]"))
end

local function SortByName(a,b)
	return GetQuestName(a) < GetQuestName(b)
end

local function InsertionSort(A, compareFunction)
	for i,v in ipairs(A) do
		local j = i
		while j > 1 and compareFunction(A[j],A[j-1]) do
			local temp = A[j]
			A[j] = A[j-1]
			A[j-1] = temp
			j = j - 1
		end
	end
	return A
end

function WQA:SortQuestList(list)
	if self.db.profile.options.sortByName == true then
		list = InsertionSort(list, SortByName)
	end

	if self.db.profile.options.sortByZoneName == true then
		list = InsertionSort(list, SortByZoneName)
	end

	list = InsertionSort(list, SortByExpansion)
	return list
end

function WQA:EmissaryReward()
	self.emissaryRewards = false
	local retry = false
	for _, mapID in pairs({619,875}) do
		for _, emissary in ipairs(GetQuestBountyInfoForMapID(mapID)) do
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

	if retry == true then
		self:ScheduleTimer(function() self:EmissaryReward() end, 2)
	else
		self.emissaryRewards = true
	end
end

function WQA:EmissaryIsActive(questID)
	local emissary = {}
	for _,v in ipairs(self.EmissaryQuestIDList) do
		for _,id in pairs(v) do
			if id == questID then
				emissary[id] = true
			end
		end
	end

	if emissary[questID] ~= true then
		return false
	end

	local i = 1
	while GetQuestLogTitle(i) do
		local _,_,_,_,_,_,_, questLogQuestID = GetQuestLogTitle(i)
		if questLogQuestID == questID then
			return true
		end
		i = i + 1
	end
	return false
end

function WQA:Special()
	if (self.db.profile.achievements["Variety is the Spice of Life"] == true and not select(4,GetAchievementInfo(11189)) == true) or (self.db.profile.achievements["Wide World of Quests"] == true and not select(4,GetAchievementInfo(13144)) == true) then 
		self.event:RegisterEvent("QUEST_TURNED_IN")
	end
end

local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local dataobj = ldb:NewDataObject("WQAchievements", {
	type = "data source",
	text = "WQA",
	icon = "Interface\\Icons\\INV_Misc_Map06",
})

local anchor
function dataobj:OnEnter()
	anchor = self
	WQA:Show("LDB")
end

local function PopUpIsShown()
	if WQA.PopUp then
		return WQA.PopUp.shown
	else
		return false
	end
end

function WQA:AnnounceLDB(quests)
	-- Hide PopUp
	if PopUpIsShown() then
		self.PopUp:Hide()
	end

	self:CreateQTip()
	self.tooltip:SetAutoHideDelay(.25, anchor, function()
		if not PopUpIsShown() then
			LibQTip:Release(WQA.tooltip)
			WQA.tooltip.quests = nil
			WQA.tooltip = nil
		end
	end)
	self.tooltip:SmartAnchorTo(anchor)
	self:UpdateQTip(quests)
end

function WQA:UpdateLDBText(activeQuests, newQuests)
	if newQuests ~= nil then
		dataobj.text = "New World Quests active"
	elseif activeQuests ~= nil then
		dataobj.text = "World Quests active"
	else
		dataobj.text = "No World Quests active"
	end
end

function WQA:formatTime(t)
	local d, h, m
	d = math.floor(t/60/24)
	h = math.floor(t/60 % 24)
	m = t % 60
	if d > 0 then
		if h > 0 then
			return d.."d "..h.."h"
		else
			return d.."d"
		end
	elseif h > 0 then
		if m > 0 then
			return h.."h "..m.."m"
		else
			return h.."h"
		end
	else
		return m.."m"
	end
end