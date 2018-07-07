WQAchievements = LibStub("AceAddon-3.0"):NewAddon("WQAchievements", "AceConsole-3.0", "AceTimer-3.0")
WQA = WQAchievements
WQA.cache = {}
WQA.data = {}
WQA.watched = {}
WQA.questList = {}


function WQA:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("WQADB", defaults)
end

-- Blizzard
local IsActive = C_TaskQuest.IsActive

-- Defaults
local defaults = {
	char = {
		achievements = {
			pvp = {id = 11474, status = true},
			ff = {id = 9696, status = true},
			botbi = {id = 10876, status = true},
			fishing = {id = 10598, status = true}
		},
			argus = true
	}
}

-- Locales
local locale = GetLocale()
WQA.L = {}
local L = WQA.L
L["WQChat"] = "Interesting World Quests are active:"
L["WQforAch"] = "%s for %s"
if locale == "deDE" then
	L["WQChat"] = "Interessante Weltquests sind verfügbar:"
	L["WQforAch"] = "%s für %s"
end

WQA:RegisterChatCommand("wqa", "slash")

function WQA:slash(input)
	local arg1 = string.lower(input)

	if arg1 == "" then
		self:checkWQ()
	elseif arg1 == "details" then
		self:checkWQ("details")
	elseif self.db.char.achievements[arg1] then
		print("Tracking of "..GetAchievementLink(self.db.char.achievements[arg1].id).." is now "..tostring(not self.db.char.achievements[arg1].status))
		self.db.char.achievements[arg1].status = not self.db.char.achievements[arg1].status
		self.qList = {}
		self:buildQList()
		self:BuildArgus()
	elseif arg1 == "argus" then
		
		self.db.char.argus = not self.db.char.argus
		self.qList = {}
		self:buildQList()
		self:BuildArgus()	
	elseif arg1 == "chat" then
		self.db.char.chat = not self.db.char.chat
	elseif arg1 == "?" then
		for k,v in pairs(self.db.char.achievements) do
			print("Tracking of "..GetAchievementLink(v.id).." is "..tostring(v.status))
			print("Toggle tracking with /wqa "..k)
		end
		print("Tracking of Argus is "..tostring(self.db.char.argus))
		print("Toggle tracking with /wqa argus")
		--print("Toggle chat output with /wqa chat")
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
				{id = 9686, criteriaType = QUESTS, criteria = trainer},
				{id = 9687, criteriaType = QUESTS, criteria = trainer},
				{id = 9688, criteriaType = QUESTS, criteria = trainer},
				{id = 9689, criteriaType = QUESTS, criteria = trainer},
				{id = 9690, criteriaType = QUESTS, criteria = trainer},
				{id = 9691, criteriaType = QUESTS, criteria = trainer},
				{id = 9692, criteriaType = QUESTS, criteria = trainer},
				{id = 9693, criteriaType = QUESTS, criteria = trainer},
				{id = 9694, criteriaType = QUESTS, criteria = trainer},
				{id = 9695, criteriaType = QUESTS, criteria = trainer}}
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
			}
		},
		mounts = {
			{itemID = 152814, spellID = 253058, quest = {{trackingID = 48695, wqID = 48696}}},
			{itemID = 152905, spellID = 253661, quest = {{trackingID = 49183, wqID = 47561}}},
			{itemID = 152904, spellID = 253662, quest = {{trackingID = 48721, wqID = 48740}}},
			{itemID = 152790, spellID = 243652, quest = {{trackingID = 48821, wqID = 48835}}},
			{itemID = 152844, spellID = 253107, quest = {{trackingID = 48705, wqID = 48725}}},
			{itemID = 152903, spellID = 253660, quest = {{trackingID = 48810, wqID = 48465}, {trackingID = 48809, wqID = 48467}}},
			--Egg
			{itemID = 152842, spellID = 253106, quest = {{trackingID = 48667, wqID = 48502}, {trackingID = 48712, wqID = 48732}, {trackingID = 48812, wqID = 48827}}},
			{itemID = 152841, spellID = 253108, quest = {{trackingID = 48667, wqID = 48502}, {trackingID = 48712, wqID = 48732}, {trackingID = 48812, wqID = 48827}}},
			{itemID = 152840, spellID = 253109, quest = {{trackingID = 48667, wqID = 48502}, {trackingID = 48712, wqID = 48732}, {trackingID = 48812, wqID = 48827}}},
			{itemID = 152843, spellID = 235764, quest = {{trackingID = 48667, wqID = 48502}, {trackingID = 48712, wqID = 48732}, {trackingID = 48812, wqID = 48827}}},
		},
		pets = {
			{itemID = 153056, creatureID = 128159, quest = {{trackingID = 0, wqID = 48729}}},
			--Egg
			{itemID = 153055, creatureID = 128158, quest = {{trackingID = 48667, wqID = 48502}, {trackingID = 48712, wqID = 48732}, {trackingID = 48812, wqID = 48827}}},
			{itemID = 153054, creatureID = 128157, quest = {{trackingID = 48667, wqID = 48502}, {trackingID = 48712, wqID = 48732}, {trackingID = 48812, wqID = 48827}}}
		},
		toys = {
			{itemID = 153183, quest = {{trackingID = 0, wqID = 48724}, {trackingID = 0, wqID = 48723}}},
			{itemID = 153126, quest = {{trackingID = 0, wqID = 48829}}},
			{itemID = 153124, quest = {{trackingID = 0, wqID = 48512}}},
			{itemID = 153180, quest = {{trackingID = 48718, wqID = 48737}}},
			{itemID = 153181, quest = {{trackingID = 48718, wqID = 48737}}},
			{itemID = 153179, quest = {{trackingID = 48718, wqID = 48737}}},
			{itemID = 153193, quest = {{trackingID = 0, wqID = 48701}}},
		}
	}
	WQA.data.legion = legion
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
			{name =  "A Most Efficient Apocalypse", id = 13021, criteriaType = "QUEST_SINGLE", criteria = 50665}
		},
		mounts = {
		},
		pets = {
		},
		toys = {
		}
	}
	WQA.data.bfa = bfa
end

-- Terrors of the Shore
-- Commander of Argus

function WQA:buildBeta()
	for _,v in pairs(self.data.legion.achievements) do
		self:AddAchievement(v)
	end
	self:AddMounts(self.data.legion.mounts)
	self:AddPets(self.data.legion.pets)
	self:AddToys(self.data.legion.toys)
	for _,v in pairs(self.data.bfa.achievements) do
		self:AddAchievement(v)
	end
	self:Cache()
end

function WQA:AddAchievement(achievement)
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
						questID = achievement.criteria[i] or 0			
						if not self.questList[questID] then self.questList[questID] = {} end
						local l = self.questList[questID]
						l[#l + 1] = { id = id, type = "ACHIEVEMENT"}
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
				if spellID == mount.spellID then
					for _,v  in pairs(mount.quest) do
						if not IsQuestFlaggedCompleted(v.trackingID) then
							if not self.questList[v.wqID] then self.questList[v.wqID] = {} end
					 		local l = self.questList[v.wqID]
							l[#l + 1] = { id = mount.itemID, type = "MOUNT"}
							self.cache[mount.itemID] = true
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
  				if companionID == pet.creatureID then
					for _,v in pairs(pet.quest) do
						if not IsQuestFlaggedCompleted(v.trackingID) then
							if not self.questList[v.wqID] then self.questList[v.wqID] = {} end
							local l = self.questList[v.wqID]
							l[#l + 1] = { id = pet.itemID, type = "PET"}
							self.cache[pet.itemID] = true
						end
	  				end
	  			end
  			end
  		end
  	end
end

function WQA:AddToys(toys)
	for _,toy in pairs(toys) do
		if not PlayerHasToy(toy.itemID) then
			for _,v in pairs(toy.quest) do
				if not IsQuestFlaggedCompleted(v.trackingID) then
					if not self.questList[v.wqID] then self.questList[v.wqID] = {} end
			 		local l = self.questList[v.wqID]
					l[#l + 1] = { id = toy.itemID, type = "TOY"}
					self.cache[toy.itemID] = true
				end
			end
		end
	end
end

WQA.links = {}
function WQA:Cache()
	local n = 0
	for id, _ in pairs(self.cache) do
		n = n + 1;
		local link = select(2,GetItemInfo(id))
		if link then
			self.links[id] = link
			--print(id)
			n = n - 1
			self.cache[id] = nil
		end
	end
	if n > 0 then
		self:ScheduleTimer(function ()
			self:Cache()
		end, 4)
	else
		self:checkWQ("new")
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
	if x.type == "ACHIEVEMENT" then
		return GetAchievementLink(x.id)
	elseif x.type == "PET" or x.type == "MOUNT" or x.type == "TOY" then
		return self.links[x.id]
	end
end



function WQA:OnEnable()
	self.event = CreateFrame("Frame")
	self.event:RegisterEvent("PLAYER_ENTERING_WORLD")
	self.event:SetScript("OnEvent", function (...)
		local _, name, id = ...
		if name == "PLAYER_ENTERING_WORLD" then
			self.event:UnregisterEvent("PLAYER_ENTERING_WORLD")
			self:ScheduleTimer("buildBeta", 5)
			self:ScheduleTimer(function ()
				self:checkWQ("new")
				self:ScheduleRepeatingTimer("checkWQ",30*60,"new")
			end, (32-(date("%M") % 30))*60)
		end
	end)
end
