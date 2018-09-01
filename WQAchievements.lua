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
L["achievements"] = "Achievements"
L["mounts"] = "Mounts"
L["pets"] = "Pets"
L["toys"] = "Toys"
if locale == "deDE" then
	L["WQChat"] = "Interessante Weltquests verfügbar:"
	L["WQforAch"] = "%s für %s"
end

local newOrder
do
	local current = 0
	function newOrder()
		current = current + 1
		return current
	end
end

WQA.data.custom = {wqID = "", rewardID = "", rewardType = "none"}

function WQA:OnInitialize()
	-- Defaults
	local defaults = {
		char = {
			options = {
				chat = true,
				PopUp = false,
				zone = { ['*'] = true},
				reward = {
					gear = {
						itemLevelUpgrade = true,
						itemLevelUpgradeMin = 1,
						PawnUpgrade = true,
						PawnUpgradeMin = 1,
						unknownAppearance = true,
						unknownSource = false,
					},
					reputation = { ['*'] = false},
					currency = {},
				}
			},
			['*'] = { ['*'] = true}
		}
	}
	self.db = LibStub("AceDB-3.0"):New("WQADB", defaults)
	self:UpdateOptions()
end

function WQA:OnEnable()
	------------------
	-- 	Options
	------------------
	LibStub("AceConfig-3.0"):RegisterOptionsTable("WQAchievements", self.options)
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("WQAchievements", "WQAchievements")

	self.event = CreateFrame("Frame")
	self.event:RegisterEvent("PLAYER_ENTERING_WORLD")
	self.event:SetScript("OnEvent", function (...)
		local _, name, id = ...
		if name == "PLAYER_ENTERING_WORLD" then
			self.event:UnregisterEvent("PLAYER_ENTERING_WORLD")
			self:ScheduleTimer("Show", 5)
			self:ScheduleTimer(function ()
				self:Show("new")
				self:ScheduleRepeatingTimer("Show",30*60,"new")
			end, (32-(date("%M") % 30))*60)
		end
		if name == "QUEST_LOG_UPDATE" or name == "GET_ITEM_INFO_RECEIVED" then
			self.event:UnregisterEvent("QUEST_LOG_UPDATE")
			self.event:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
			self:CancelTimer(self.timer)
			if GetTime() - self.start > 1 then
				self:Reward()
			else
				self:ScheduleTimer("Reward", 1)
			end
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
	elseif arg1 == "details" then
		self:checkWQ("details")
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
			{name = "Fishing \'Round the Isles", id = 10598, criteriaType = 1, criteria = {
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
			{name = "They See Me Rolling", id = 11607, criteriaType = "QUEST_SINGLE", criteria = 46175}
		},
		mounts = {
			{name = "Maddened Chaosrunner", itemID = 152814, spellID = 253058, quest = {{trackingID = 48695, wqID = 48696}}},
			{name = "Crimson Slavermaw", itemID = 152905, spellID = 253661, quest = {{trackingID = 49183, wqID = 47561}}},
			{name = "Acid Belcher", itemID = 152904, spellID = 253662, quest = {{trackingID = 48721, wqID = 48740}}},
			{name = "Vile Fiend", itemID = 152790, spellID = 243652, quest = {{trackingID = 48821, wqID = 48835}}},
			{name = "Lambent Mana Ray", itemID = 152844, spellID = 253107, quest = {{trackingID = 48705, wqID = 48725}}},
			{name = "Biletooth Gnasher", itemID = 152903, spellID = 253660, quest = {{trackingID = 48810, wqID = 48465}, {trackingID = 48809, wqID = 48467}}},
			--Egg
			{name = "Vibrant Mana Ray", itemID = 152842, spellID = 253106, quest = {{trackingID = 48667, wqID = 48502}, {trackingID = 48712, wqID = 48732}, {trackingID = 48812, wqID = 48827}}},
			{name = "Felglow Mana Ray", itemID = 152841, spellID = 253108, quest = {{trackingID = 48667, wqID = 48502}, {trackingID = 48712, wqID = 48732}, {trackingID = 48812, wqID = 48827}}},
			{name = "Scintillating Mana Ray", itemID = 152840, spellID = 253109, quest = {{trackingID = 48667, wqID = 48502}, {trackingID = 48712, wqID = 48732}, {trackingID = 48812, wqID = 48827}}},
			{name = "Darkspore Mana Ray", itemID = 152843, spellID = 235764, quest = {{trackingID = 48667, wqID = 48502}, {trackingID = 48712, wqID = 48732}, {trackingID = 48812, wqID = 48827}}},
		},
		pets = {
			{name = "Grasping Manifestation", itemID = 153056, creatureID = 128159, quest = {{trackingID = 0, wqID = 48729}}},
			--Egg
			{name = "Fel-Afflicted Skyfin", itemID = 153055, creatureID = 128158, quest = {{trackingID = 48667, wqID = 48502}, {trackingID = 48712, wqID = 48732}, {trackingID = 48812, wqID = 48827}}},
			{name = "Docile Skyfin", itemID = 153054, creatureID = 128157, quest = {{trackingID = 48667, wqID = 48502}, {trackingID = 48712, wqID = 48732}, {trackingID = 48812, wqID = 48827}}}
		},
		toys = {
			{name = "Barrier Generator", itemID = 153183, quest = {{trackingID = 0, wqID = 48724}, {trackingID = 0, wqID = 48723}}},
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
	bfa = {
		name = "Battle for Azeroth",
		achievements = {
			{name = "Adept Sandfisher", id = 13009, criteriaType = "QUEST_SINGLE", criteria = 51173},
			{name = "Scourge of Zem'lan", id = 13011, criteriaType = 1, criteria = {{51763, 51783}}},
			{name = "Vorrik's Champion", id = 13014, criteriaType = "QUESTS", criteria = {51957, 51983}},
			{name = "Revenge is Best Served Speedily", id = 13022, criteriaType = "QUEST_SINGLE", criteria = 50786},
			{name = "It's Really Getting Out of Hand", id = 13023, criteriaType = "QUEST_SINGLE", criteria = 50559},
			{name = "Zandalari Spycatcher", id = 13025, criteriaType = "QUEST_SINGLE", criteria = 50717},
			{name = "7th Legion Spycatcher", id = 13026, criteriaType = "QUEST_SINGLE", criteria = 50899},
			{name = "By de Power of de Loa!", id = 13035, criteriaType = "QUEST_SINGLE", criteria = 51178},
			{name = "Bless the Rains Down in Freehold", id = 13050, criteriaType = "QUEST_SINGLE", criteria = 53196},
			{name = "Kul Runnings", id = 13060, criteriaType = "QUESTS", criteria = {49994,0,53189}},	-- Frozen Freestyle
			{name = "Battle on Zandalar and Kul Tiras", id = 12936},
			{name = "A Most Efficient Apocalypse", id = 13021, criteriaType = "QUEST_SINGLE", criteria = 50665},
			-- Thanks NatalieWright
			{name = "Adventurer of Zuldazar", id = 12944, criteriaType = "QUESTS", criteria = {50864, 50877, {51085, 51087}, 51081, {50287, 51374, 50866}, 50885, 50863, 50862, 50861, 50859, 50845, 50857, nil, 50875, 50874, nil, 50872, 50876, 50871, 50870, 50869, 50868, 50867}},
			{name = "Adventurer of Vol'dun", id = 12943, criteriaType = "QUESTS", criteria = {51105, 51095, 51096, 51117, nil, 51118, 51120, 51098, 51121, 51099, 51108, 51100, 51125, 51102, 51429, 51103, 51124, 51107, 51122, 51123, 51104, 51116, 51106, 51119, 51112, 51113, 51114, 51115}},
			{name = "Adventurer of Nazmir", id = 12942, criteriaType = "QUESTS", criteria = {50488, 50570, 50564, nil, 50490, 50506, 50568, 50491, 50492, 50499, 50496, 50498, 50501, nil, 50502, 50503, 50505, 50507, 50566, 50511, 50512, nil, 50513, 50514, nil, 50515, 50516, 50489, 50519, 50518, 50509, 50517}},
			{name = "Adventurer of Drustvar", id = 12941, criteriaType = "QUESTS", criteria = {51469, 51505, 51506, 51508, 51468, 51972, nil, nil, nil, 51897, 51457, nil, 51909, 51507, 51917, nil, 51919, 51908, 51491, 51512, 51527, 51461, 51467, 51528, 51466, 51541, 51542, 51884, 51874, 51906, 51887, 51989, 51988}},
			{name = "Adventurer of Tiragarde Sound", id = 12939, criteriaType = "QUESTS", criteria = {51653, 51652, 51666, 51669, 51841, 51665, 51848, 51842, 51654, 51662, 51844, 51664, 51670, 51895, nil, 51659, 51843, 51660, 51661, 51890, 51656, 51893, 51892, 51651, 51839, 51891, 51849, 51894, 51655, 51847, nil, 51657}},
			{name = "Adventurer of Stormsong Valley", id = 12940, criteriaType = "QUESTS", criteria = {52452, 52315, 51759, {51976, 51977, 51978}, 52476, 51774, 51921, nil, 51776, 52459, 52321, 51781, nil, 51886, 51779, 51778, 52306, 52310, 51901, 51777, 52301, nil, 52463, nil, 52328, 51782, 52299, nil, 52300, nil, 52464, 52309, 52322, nil}},
		},
	}
	WQA.data[2] = bfa
end

-- Terrors of the Shore
-- Commander of Argus

function WQA:CreateQuestList()
	self:Debug("CreateQuestList")
	self.questList = {}
	for _,v in pairs(self.data[1].achievements) do
		self:AddAchievement(v)
	end
	self:AddMounts(self.data[1].mounts)
	self:AddPets(self.data[1].pets)
	self:AddToys(self.data[1].toys)
	for _,v in pairs(self.data[2].achievements) do
		self:AddAchievement(v)
	end
	self:AddCustom()
	self:Reward()
end

function WQA:AddAchievement(achievement)
	if self.db.char.achievements[achievement.name] == false then return end
	local id = achievement.id
	local _,_,_,completed,_,_,_,_,_,_,_,_,wasEarnedByMe = GetAchievementInfo(id)
	if (achievement.notAccountwide and not wasEarnedByMe) or not completed then
		if achievement.criteriaType == "ACHIEVEMENT" then
			for _,v in pairs(achievement.criteria) do
				self:AddAchievement(v)
			end
		elseif achievement.criteriaType == "QUEST_SINGLE" then
			if not self.questList[achievement.criteria] then self.questList[achievement.criteria] = {} end
			local l = self.questList[achievement.criteria]
			l[#l + 1] = { id = id, type = "ACHIEVEMENT"}
		else
			for i=1, GetAchievementNumCriteria(id) do
				local _,t,completed,_,_,_,_,questID = GetAchievementCriteriaInfo(id,i)
				if not completed then
					if achievement.criteriaType == "QUESTS" then
						if type(achievement.criteria[i]) == "table" then
							for _,questID in pairs(achievement.criteria[i]) do
						 		if not self.questList[questID] then self.questList[questID] = {} end
						 		local l = self.questList[questID]
								l[#l + 1] = { id = id, type = "ACHIEVEMENT"}
							end
						else
							questID = achievement.criteria[i] or 0
							if not self.questList[questID] then self.questList[questID] = {} end
							local l = self.questList[questID]
							l[#l + 1] = { id = id, type = "ACHIEVEMENT"}
						end
					elseif achievement.criteriaType == 1 and t == 0 then
						for _,questID in pairs(achievement.criteria[i]) do
					 		if not self.questList[questID] then self.questList[questID] = {} end
					 		local l = self.questList[questID]
							l[#l + 1] = { id = id, type = "ACHIEVEMENT"}
						end
					else
						if not self.questList[questID] then self.questList[questID] = {} end
						local l = self.questList[questID]
						l[#l + 1] = { id = id, type = "ACHIEVEMENT"}
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
				if self.db.char.mounts[mount.name] == true then
					if spellID == mount.spellID then
						for _,v  in pairs(mount.quest) do
							if not IsQuestFlaggedCompleted(v.trackingID) then
								if not self.questList[v.wqID] then self.questList[v.wqID] = {} end
						 		local l = self.questList[v.wqID]
								l[#l + 1] = { id = mount.itemID, type = "ITEM"}
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
  				if self.db.char.pets[pet.name] == true then
	  				if companionID == pet.creatureID then
						for _,v in pairs(pet.quest) do
							if not IsQuestFlaggedCompleted(v.trackingID) then
								if not self.questList[v.wqID] then self.questList[v.wqID] = {} end
								local l = self.questList[v.wqID]
								l[#l + 1] = { id = pet.itemID, type = "ITEM"}
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
		if self.db.char.toys[toy.name] == true then
			if not PlayerHasToy(toy.itemID) then
				for _,v in pairs(toy.quest) do
					if not IsQuestFlaggedCompleted(v.trackingID) then
						if not self.questList[v.wqID] then self.questList[v.wqID] = {} end
				 		local l = self.questList[v.wqID]
						l[#l + 1] = { id = toy.itemID, type = "ITEM"}
					end
				end
			end
		end
	end
end

function WQA:AddCustom()
	if type(self.db.global.custom) == "table" then
		for k,v in pairs(self.db.global.custom) do
			if self.db.char.custom[k] == true then
				if not self.questList[k] then self.questList[k] = {} end
	 			local l = self.questList[k]
				l[#l + 1] = { id = v.rewardID, type = v.rewardType}
			end
		end
	end
end

WQA.first = false
function WQA:Show(mode)
	self:Debug("Show", mode)
	self:CreateQuestList()
	self:CheckWQ(mode)
	self.first = true
end


function WQA:CheckWQ(mode)
	self:Debug("CheckWQ")
	if self.rewards ~= true then
		self:ScheduleTimer("CheckWQ", .4, mode)
		return
	end
	local activeQuests = {}
	local newQuests = {}
	for questID,qList in pairs(self.questList) do
		if IsActive(questID) then
			local questLink = GetQuestLink(questID)
			local link = self:link(self.questList[questID][1])
			if not questLink or not link then
				self:ScheduleTimer("CheckWQ", .5, mode)
				return
			end
			activeQuests[questID] = true
			if not self.watched[questID] then
				newQuests[questID] = true
			end
		end
	end

	for id,_ in pairs(newQuests) do
		self.watched[id] = true
	end

	if mode == "new" then
		self:AnnounceChat(newQuests, self.first)
		self:AnnouncePopUp(newQuests, self.first)
	else
		self:AnnounceChat(activeQuests)
		self:AnnouncePopUp(activeQuests)
	end
end

function WQA:checkWQ(mode)
	local first = false
	local output = L["WQChat"]
	local watchedNew = {}
	for questID,qList in pairs(self.questList) do
		if IsActive(questID) and not ((self.watched[questID] or watchedNew[questID]) and mode == "new") then
			if not (mode == "details") then
				if first == false then
					first = true
				end
				watchedNew[questID] = true
				local questLink = GetQuestLink(questID)
				if not questLink then
					self:ScheduleTimer("checkWQ",.5)
					return
				end
				output = output.."\n"..string.format(L["WQforAch"],GetQuestLink(questID),self:link(qList[1]))
				for k,_ in pairs(watchedNew) do
					self.watched[k] = true
				end
			end
			if mode == "details" then
				if first == false then
					first = true
					print(L["WQChat"])
				end
				print(GetQuestLink(questID))
				for _, v in pairs(qList) do
					print("     "..self:link(v))
				end
			end
		end
	end
	if first and not (mode == "details") then
		print(output)
	end
end

function WQA:link(x)
	if not x then return "" end
	local t = string.upper(x.type)
	if t == "ACHIEVEMENT" then
		return GetAchievementLink(x.id)
	elseif t == "ITEM" then
		return select(2,GetItemInfo(x.id))--self.links[x.id]
	elseif t == "ITEMPERCENTUPGRADE" then
		if x.itemLink then
			return x.itemLink.."|cFF00FF00 +"..x.upgrade.."%"
		else	
			return select(2,GetItemInfo(x.id)).."|cFF00FF00 +"..x.upgrade.."%"
		end
	elseif t == "ITEMLEVELUPGRADE" then
		if x.itemLink then
			return x.itemLink.."|cFF00FF00 +"..x.upgrade.." iLvl"
		else	
			return select(2,GetItemInfo(x.id)).."|cFF00FF00 +"..x.upgrade.." iLvl"
		end
	elseif t == "TRANSMOG" then
		return x.itemLink.."Transmog"
	elseif t == "UNIQUETRANSMOG" then
		return x.itemLink.."unique Transmog"
	else
		return ""
	end
end

local icons = {
	unknown = "|TInterface\\AddOns\\CanIMogIt\\Icons\\UNKNOWN:0|t",
	known = "|TInterface\\AddOns\\CanIMogIt\\Icons\\KNOWN_circle:0|t",
}

function WQA:GetRewardForID(questID)
	local l = self.questList[questID].reward
	local r = ""
	if l then
		if l.item then
			if l.item.bonus then
				if l.item.bonus.itemLevelUpgrade then
					r = r.."|cFF00FF00+"..l.item.bonus.itemLevelUpgrade.." iLvl|r"
				end
				if l.item.bonus.itemPercentUpgrade then
					if r ~= "" then r = r.."," end
					r = r.."|cFF00FF00+"..l.item.bonus.itemPercentUpgrade.."%|r"
				end
				if l.item.bonus.transmog then
					if r ~= "" then r = r.." " end
					r = r..icons[l.item.bonus.transmog]
				end
				if l.item.bonus.AzeriteArmorCache then
					for i=1,5,2 do
						local upgrade = l.item.bonus.AzeriteArmorCache[i]
						if upgrade > 0 then
							r = r.."|cFF00FF00+"..upgrade.." iLvl|r"
						elseif upgrade < 0 then
							r = r.."|cFFFF0000-"..upgrade.." iLvl|r"
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
		if l.currency then
			r = r..l.currency.amount.." "..l.currency.name
		end
	end
	return r
end

function WQA:AnnounceChat(activeQuests, silent)
	if self.db.char.options.chat == false then return end
	if next(activeQuests) == nil then
		if silent ~= true then
			print(L["NO_QUESTS"])
		end
		return
	end

	local output = L["WQChat"]
	print(output)
	for questID,_ in pairs(activeQuests) do
		if self.questList[questID][1] then
			output = "   "..string.format(L["WQforAch"],GetQuestLink(questID),self:link(self.questList[questID][1]))
			if self.questList[questID].reward then
				output = output.." & "..self:GetRewardForID(questID)
			end
		else
			output = "   "..string.format(L["WQforAch"],GetQuestLink(questID),self:GetRewardForID(questID))
		end
		print(output)
	end
end

function WQA:CreatePopUp()
	if self.PopUp then return self.PopUp end
	local f = CreateFrame("Frame", "WQAchievementsPopUp", UIParent, "UIPanelDialogTemplate")
	f:SetFrameStrata("BACKGROUND")
	f:SetWidth(500)
	f:SetPoint("TOP",0,-200)

	-- Move and resize
	f:SetMovable(true)
	f:EnableMouse(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", function(self)
		self.moving = true
        self:StartMoving()
	end)
	f:SetScript("OnDragStop", function(self)
		self.moving = nil
        self:StopMovingOrSizing()
	end)

	f.ResizeButton = CreateFrame("Button", f:GetName().."ResizeButton", f)
	f.ResizeButton:SetWidth(16)
	f.ResizeButton:SetHeight(16)
	f.ResizeButton:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT")
	f.ResizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")

	f.Title:SetText("WQAchievements")
	f.Title:SetFontObject(GameFontNormalLarge)
	
	f.ScrollingMessageFrame = CreateFrame("ScrollingMessageFrame", "PopUpScroll", f)
	f.ScrollingMessageFrame:SetHyperlinksEnabled(true)
	f.ScrollingMessageFrame:SetWidth(470)
	f.ScrollingMessageFrame:SetPoint("TOP",f,"TOP",0,-28)
	f.ScrollingMessageFrame:SetFontObject(GameFontNormalLarge)
	f.ScrollingMessageFrame:SetFading(false)
	f.ScrollingMessageFrame:SetScript("OnHyperlinkEnter", function(_,_,link,line)
		GameTooltip_SetDefaultAnchor(GameTooltip, line)
		GameTooltip:ClearLines()
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint("BOTTOM", line, "TOP", 0, 0)
		GameTooltip:SetHyperlink(link)
		GameTooltip:Show() end)
	f.ScrollingMessageFrame:SetScript("OnHyperlinkLeave", function() GameTooltip:Hide() end)
	f.ScrollingMessageFrame:SetJustifyV("CENTER")

	f.ScrollingMessageFrame:SetInsertMode(1)

	f.ScrollingMessageFrame:SetScript("OnMouseWheel", function(self, delta)
		if ( delta > 0 ) then
			self:ScrollDown()
		else
			self:ScrollUp()
		end
	end)

	--f.CloseButton = CreateFrame("Button", "CloseButton", f, "UIPanelCloseButton")
	--f.CloseButton:SetPoint("TOPRIGHT", f, "TOPRIGHT")

	self.PopUp = f
	return f
end

function WQA:p()
	print("pp")
end

function WQA:AnnouncePopUp(activeQuests, silent)
	if self.db.char.options.PopUp == false then return end
	local f = self:CreatePopUp()
	if f:IsShown() ~= true then
		f.ScrollingMessageFrame:Clear()
	end
	local i = 1
	if next(activeQuests) == nil then
		if silent ~= true then
--			f.ScrollingMessageFrame:SetJustifyH("CENTER")
			f.ScrollingMessageFrame:AddMessage(L["NO_QUESTS"])
			f:Show()
		end
	else
		f.ScrollingMessageFrame:SetJustifyH("LEFT")
		local Message = {}
		for questID,_ in pairs(activeQuests) do
			if not self.questList[questID].reward then
				Message[i] = string.format(L["WQforAch"],GetQuestLink(questID),self:link(self.questList[questID][1]))
			else
				Message[i] = string.format(L["WQforAch"],GetQuestLink(questID),self:GetRewardForID(questID))
			end			
			i = i+1
		end
		for j=#Message,1,-1 do
			f.ScrollingMessageFrame:AddMessage(Message[j])
		end
		f.ScrollingMessageFrame:AddMessage(L["WQChat"])

		f:Show()
	end
	i = math.max(3,i)
	f:SetHeight(38+i*16)
	f.ScrollingMessageFrame:SetHeight(16*i)
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
			if self.db.char.options.zone[mapID] == true then
				local quests = C_TaskQuest.GetQuestsForPlayerByMapID(mapID)
				if quests then
					for i=1,#quests do
						local questID = quests[i].questId
						if self.db.char.options.zone[C_TaskQuest.GetQuestZoneID(questID)] == true then
							if HaveQuestData(questID) and not HaveQuestRewardData(questID) then
								C_TaskQuest.RequestPreloadRewardData(questID)
								retry = true
							end

							local numQuestRewards = GetNumQuestLogRewards(questID)
							if numQuestRewards > 0 then
								local itemName, itemTexture, quantity, quality, isUsable, itemID = GetQuestLogRewardInfo(1, questID)
								if itemID then
									inspectScantip:SetQuestLogItem("reward", 1, questID)
									itemLink = select(2,inspectScantip:GetItem())
									local itemName, _, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice, itemClassID, itemSubClassID = GetItemInfo(itemLink)

									-- Ask Pawn if this is an Upgrade
									if PawnIsItemAnUpgrade and self.db.char.options.reward.gear.PawnUpgrade then
										local Item = PawnGetItemData(itemLink)
										if Item then
											local UpgradeInfo, BestItemFor, SecondBestItemFor, NeedsEnhancements = PawnIsItemAnUpgrade(Item)
											if UpgradeInfo and UpgradeInfo[1].PercentUpgrade*100 >= self.db.char.options.reward.gear.PawnUpgradeMin then
												if not self.questList[questID] then self.questList[questID] = {} end
										 		local l = self.questList[questID]
										 		if not l.reward then l.reward = {} end
												if not l.reward.item then l.reward.item = {} end
												if not l.reward.item.bonus then l.reward.item.bonus = {} end
												l.reward.item.itemLink = itemLink
												l.reward.item.bonus.itemPercentUpgrade = math.floor(UpgradeInfo[1].PercentUpgrade*100+.5)
											end
										end
									end

									--StatWeightScore
									--local StatWeightScore = LibStub("AceAddon-3.0"):GetAddon("StatWeightScore")
									--local ScoreModule = StatWeightScore:GetModule("StatWeightScoreScore")

									-- Upgrade by itemLevel
									if self.db.char.options.reward.gear.itemLevelUpgrade then
										local itemLevel1, itemLevel2 = nil, nil
										if EquipLocToSlot1[itemEquipLoc] then
											local itemLink1 = GetInventoryItemLink("player", EquipLocToSlot1[itemEquipLoc])
											if itemLink1 then
												itemLevel1 = GetDetailedItemLevelInfo(itemLink1)
											end
										end
										if EquipLocToSlot2[itemEquipLoc] then
											local itemLink2 = GetInventoryItemLink("player", EquipLocToSlot2[itemEquipLoc])
											if itemLink2 then
												itemLevel2 = GetDetailedItemLevelInfo(itemLink2)
											end
										end
										itemLevel = GetDetailedItemLevelInfo(itemLink)
										local itemLevelEquipped = math.min(itemLevel1 or 1000, itemLevel2 or 1000)
										if itemLevel - itemLevelEquipped >= self.db.char.options.reward.gear.itemLevelUpgradeMin then
											if not self.questList[questID] then self.questList[questID] = {} end
									 		local l = self.questList[questID]
									 		if not l.reward then l.reward = {} end
											if not l.reward.item then l.reward.item = {} end
											if not l.reward.item.bonus then l.reward.item.bonus = {} end
											l.reward.item.itemLink = itemLink
											l.reward.item.bonus.itemLevelUpgrade = itemLevel - itemLevelEquipped
										end
									end

									-- Azerite Armor Cache
									if itemID == 163857 and self.db.char.options.reward.gear.AzeriteArmorCache then
										itemLevel = GetDetailedItemLevelInfo(itemLink)
										local AzeriteArmorCacheIsUpgrade = false
										local AzeriteArmorCache = {}
										for i=1,5,2 do
											local itemLink1 = GetInventoryItemLink("player", i)
											if itemLink1 then
												local itemLevel1 = GetDetailedItemLevelInfo(itemLink1) or 0
												AzeriteArmorCache[i] = itemLevel - itemLevel1
												if itemLevel > itemLevel1 and itemLevel - itemLevel1 >= self.db.char.options.reward.gear.itemLevelUpgradeMin then
													AzeriteArmorCacheIsUpgrade = true
												end
											end
										end
										if AzeriteArmorCacheIsUpgrade == true then
											if not self.questList[questID] then self.questList[questID] = {} end
											local l = self.questList[questID]
											if not l.reward then l.reward = {} end
											if not l.reward.item then l.reward.item = {} end
											if not l.reward.item.bonus then l.reward.item.bonus = {} end
											l.reward.item.itemLink = itemLink
											l.reward.item.bonus.AzeriteArmorCache = AzeriteArmorCache
										end
									end

									-- Transmog
									if CanIMogIt and self.db.char.options.reward.gear.unknownAppearance then
										if CanIMogIt:IsEquippable(itemLink) and CanIMogIt:CharacterCanLearnTransmog(itemLink) then
											if not CanIMogIt:PlayerKnowsTransmog(itemLink) then
												if not self.questList[questID] then self.questList[questID] = {} end
												local l = self.questList[questID]
												if not l.reward then l.reward = {} end
												if not l.reward.item then l.reward.item = {} end
												if not l.reward.item.bonus then l.reward.item.bonus = {} end
												l.reward.item.itemLink = itemLink
												l.reward.item.bonus.transmog = "unknown"
											elseif not CanIMogIt:PlayerKnowsTransmogFromItem(itemLink) and self.db.char.options.reward.gear.unknownSource then
												if not self.questList[questID] then self.questList[questID] = {} end
												local l = self.questList[questID]
												if not l.reward then l.reward = {} end
												if not l.reward.item then l.reward.item = {} end
												if not l.reward.item.bonus then l.reward.item.bonus = {} end
												l.reward.item.itemLink = itemLink
												l.reward.item.bonus.transmog = "known"
											end
										end
									end

									-- Reputation Token
									local factionID = ReputationItemList[itemID] or nil
									if factionID then
										if self.db.char.options.reward.reputation[factionID] == true then
											if not self.questList[questID] then self.questList[questID] = {} end
											local l = self.questList[questID]
											if not l.reward then l.reward = {} end
											if not l.reward.item then l.reward.item = {} end
											l.reward.item.itemLink = itemLink
										end
									end
								else
									retry = true
								end
							end

							local numQuestCurrencies = GetNumQuestLogRewardCurrencies(questID)
							for i = 1, numQuestCurrencies do
								local name, texture, numItems, currencyID = GetQuestLogRewardCurrencyInfo(i, questID)
								if self.db.char.options.reward.currency[currencyID] then
									if not self.questList[questID] then self.questList[questID] = {} end
						 			local l = self.questList[questID]
						 			if not l.reward then l.reward = {currency = {}} end
						 			l.reward.currency = {name = name, amount = numItems}
						 		end

						 		-- Reputation Currency
						 		local factionID = ReputationCurrencyList[currencyID] or nil
						 		if factionID then
						 			if self.db.char.options.reward.reputation[factionID] == true then
						 				if not self.questList[questID] then self.questList[questID] = {} end
							 			local l = self.questList[questID]
							 			if not l.reward then l.reward = {currency = {}} end
							 			l.reward.currency = {name = name, amount = numItems}
						 			end
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
		self.timer = self:ScheduleTimer(function() self:Reward() end, 2)
		self.event:RegisterEvent("QUEST_LOG_UPDATE")
		self.event:RegisterEvent("GET_ITEM_INFO_RECEIVED")
	else
		self.rewards = true
	end
end


---- by reward
--  GetQuestsForPlayerByMapID
--[[

print( "\124Hmylinktype:myfunc\124h\124T"..(select(3,GetSpellInfo(12345)))..":16\124t\124h" ) 

Now since your defining your own link type, you need to intercept the default chat link handler and replace it with your own. You save the old function in case the link isn't one of yours so it can be handled as normal. 

local OldSetItemRef = SetItemRef 
function SetItemRef(link, text, button, chatFrame) 
local func = strmatch(link, "^mylinktype:(%a+)") 
if func == "myfunc" then 
print(random(1, 10)) 
else 
OldSetItemRef(link, text, button, chatFrame) 
end 
end 

--list of all zone ids
WorldQuestTracker.MapData.ZoneIDs = {
	--Legion
		ARGUS = 		905, --905
		BROKENISLES = 	619, --
		AZSUNA = 		630, --631 632 633
		VALSHARAH = 	641, --642 643 644
		HIGHMONTAIN = 	650, --
		DALARAN = 	625,
		SURAMAR =		680,
		STORMHEIM = 	634,
		BROKENSHORE = 	646,
		EYEAZSHARA = 	790,
		ANTORAN = 	885,
		KROKUUN = 	830,
		MCCAREE = 	882,
		
	--BFA
		DARKSHORE = 	62,
		ARATHI =		14,
		ZANDALAR = 	875,
		KULTIRAS = 	876,
		ZULDAZAAR = 	862,
		NAZMIR = 		863,
		VOLDUN = 		864,
		TIRAGARDE = 	895,
		STORMSONG = 	942,
		DRUSTVAR = 	896,
	
}
--]]
WQA.debug = false
function WQA:Debug(...)
	if self.debug == true
		then print(GetTime(),GetFramerate(),...)
	end
end