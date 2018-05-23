WQAchievements = LibStub("AceAddon-3.0"):NewAddon("WQAchievements", "AceConsole-3.0", "AceTimer-3.0")
WQA = WQAchievements

-- Blizzard
local IsActive = C_TaskQuest.IsActive
local GetQuestInfoByQuestID = C_TaskQuest.GetQuestInfoByQuestID

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

WQA.aL = {}
WQA.aL.pvp = {11475, 11476, 11477, 11478}
WQA.aL.ff = {9686, 9687, 9688, 9689, 9690, 9691, 9692, 9693, 9694, 9695}
WQA.aL.botbi = {10876}
WQA.aL.fishing = {10598}
WQA.trainerList = {42159, 40299, 40277, 42442, 40298, 40280, 40282, 41687, 40278, 41944, 41895, 40337, 41990, 40279, 41860}
WQA.fishQList = {}
WQA.fishQList[1] = {41612, 41613, 41270}
WQA.fishQList[3] = {41604, 41605, 41279}
WQA.fishQList[4] = {41598, 41599, 41264}
WQA.fishQList[7] = {41611, 41265, 41610}
WQA.fishQList[8] = {41617, 41280, 41616}
WQA.fishQList[9] = {41597, 41244, 41596}
WQA.fishQList[10] = {41602, 41274, 41603}
WQA.fishQList[11] = {41609, 41243}
WQA.fishQList[14] = {41615, 41275, 41614}
WQA.fishQList[19] = {41269, 41600, 41601}
WQA.watched = {}

-- Terrors of the Shore
-- Commander of Argus

WQA.Argus = {}
WQA.Argus.Mounts = {
	{itemID = 152814, spellID = 253058, questID = 48695, wqID = 48696},
	{itemID = 152905, spellID = 253661, questID = 49183, wqID = 47561},
	{itemID = 152904, spellID = 253662, questID = 48721, wqID = 48740},
	{itemID = 152903, spellID = 253660, {{questID = 48810, wqID = 48465}, {questID = 48809, wqID = 48467}}},
	{itemID = 152790, spellID = 243652, questID = 48821, wqID = 48835},
	{itemID = 152844, spellID = 253107, questID = 48705, wqID = 48725},
	--Egg
	{itemID = 152842, spellID = 253106, {{questID = 48667, wqID = 48502}, {questID = 48712, wqID = 48732}, {questID = 48812, wqID = 48827}}},
	{itemID = 152841, spellID = 253108, {{questID = 48667, wqID = 48502}, {questID = 48712, wqID = 48732}, {questID = 48812, wqID = 48827}}},
	{itemID = 152840, spellID = 253109, {{questID = 48667, wqID = 48502}, {questID = 48712, wqID = 48732}, {questID = 48812, wqID = 48827}}},
	{itemID = 152843, spellID = 235764, {{questID = 48667, wqID = 48502}, {questID = 48712, wqID = 48732}, {questID = 48812, wqID = 48827}}},
}

WQA.Argus.Pets = {
	{itemID = 153056, creatureID = 128159, questID = 0, wqID = 48729},
	--Egg
	{itemID = 153055, creatureID = 128158, {{questID = 48667, wqID = 48502}, {questID = 48712, wqID = 48732}, {questID = 48812, wqID = 48827}}},
	{itemID = 153054, creatureID = 128157, {{questID = 48667, wqID = 48502}, {questID = 48712, wqID = 48732}, {questID = 48812, wqID = 48827}}}
}

WQA.Argus.Toys = {
	{itemID = 153183, {{questID = 0, wqID = 48724}, {questID = 0, wqID = 48723}}},
	{itemID = 153126, questID = 0, wqID = 48829},
	{itemID = 153124, questID = 0, wqID = 48512},
	{itemID = 153180, questID = 48718, wqID = 48737},
	{itemID = 153181, questID = 48718, wqID = 48737},
	{itemID = 153179, questID = 48718, wqID = 48737},
	{itemID = 153193, questID = 0, wqID = 48701},
}


function WQA:buildQList()
	self.questList = {}
	for k,v in pairs(self.db.char.achievements) do
		if k == "pvp" then
			local _,_,_,completed = GetAchievementInfo(11474)
			if completed then
				v.status = false
			end
		end
		if v.status == true then
			for _,id in pairs(self.aL[k]) do
				local _,_,_,completed,_,_,_,_,_,_,_,_,wasEarnedByMe = GetAchievementInfo(id)
				if completed == false or (k == "pvp" and not wasEarnedByMe) then
					for i=1, GetAchievementNumCriteria(id) do
						local _,t,completed,_,_,_,_,questID = GetAchievementCriteriaInfo(id,i)
						if completed == false then
							if id == 10598 and t == 0 then
								for _,questID in pairs(self.fishQList[i]) do
							 		if not self.questList[questID] then self.questList[questID] = {} end
							 		local l = self.questList[questID]
									l[#l + 1] = { id = id, type = "ACHIEVEMENT"}
									GetAchievementLink(id)
								end
							else
								if t == 158 then questID = self.trainerList[i] end
								if not self.questList[questID] then self.questList[questID] = {} end
								local l = self.questList[questID]
								l[#l + 1] = { id = id, type = "ACHIEVEMENT"}
								GetAchievementLink(id)
							end
						end
					end
				end
			end
		end
	end
	if not self.db.char.argus then
		self:checkWQ()
		return
	else
		self:BuildArgus()
	end
end

WQA.cache = {}
function WQA:BuildArgus()
	for i,id in pairs(C_MountJournal.GetMountIDs()) do
		local n, spellID, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(id)
		if not isCollected then
			for _, v in pairs(WQA.Argus.Mounts) do
				if spellID == v.spellID then
					if v.questID then
						if not IsQuestFlaggedCompleted(v.questID) then
							if not self.questList[v.wqID] then self.questList[v.wqID] = {} end
					 		local l = self.questList[v.wqID]
							l[#l + 1] = { id = v.itemID, type = "MOUNT"}
							GetItemInfo(v.itemID)
							self.cache[v.itemID] = true
						end
					else
						for _, vv in pairs(v[1]) do
							if not IsQuestFlaggedCompleted(vv.questID) then
								if not self.questList[vv.wqID] then self.questList[vv.wqID] = {} end
						 		local l = self.questList[vv.wqID]
								l[#l + 1] = { id = v.itemID, type = "MOUNT"}
								GetItemInfo(v.itemID)
								self.cache[v.itemID] = true
							end
						end
					end
				end
			end
		end
	end

	local total = C_PetJournal.GetNumPets()
 	for i = 1, total do
  		local petID, _, owned, _, _, _, _, _, _, _, companionID = C_PetJournal.GetPetInfoByIndex(i)
  		if not owned then
  			for _, v in pairs(self.Argus.Pets) do
  				if companionID == v.creatureID then
  					if v.questID then
						if not IsQuestFlaggedCompleted(v.questID) then
							if not self.questList[v.wqID] then self.questList[v.wqID] = {} end
					 		local l = self.questList[v.wqID]
							l[#l + 1] = { id = v.itemID, type = "PET"}
							self.cache[v.itemID] = true
						end
					else
						for _, vv in pairs(v[1]) do
							if not IsQuestFlaggedCompleted(vv.questID) then
								if not self.questList[vv.wqID] then self.questList[vv.wqID] = {} end
						 		local l = self.questList[vv.wqID]
								l[#l + 1] = { id = v.itemID, type = "PET"}
								self.cache[v.itemID] = true
							end
						end
					end
  				end
  			end
  		end
  	end

	for _, v in pairs(self.Argus.Toys) do
		if not PlayerHasToy(v.itemID) then
			if v.questID then
				if not IsQuestFlaggedCompleted(v.questID) then
					if not self.questList[v.wqID] then self.questList[v.wqID] = {} end
			 		local l = self.questList[v.wqID]
					l[#l + 1] = { id = v.itemID, type = "TOY"}
					self.cache[v.itemID] = true
				end
			else
				for _, vv in pairs(v[1]) do
					if not IsQuestFlaggedCompleted(vv.questID) then
						if not self.questList[vv.wqID] then self.questList[vv.wqID] = {} end
				 		local l = self.questList[vv.wqID]
						l[#l + 1] = { id = v.itemID, type = "TOY"}
						self.cache[v.itemID] = true
					end
				end
			end
		end
	end
	self:Cache()
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
		--local _, link = GetItemInfo(x.id)
		return self.links[x.id]
	end
end

function WQA:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("WQADB", defaults)

end

function WQA:OnEnable()
	self.event = CreateFrame("Frame")
	self.event:RegisterEvent("PLAYER_ENTERING_WORLD")
	self.event:SetScript("OnEvent", function (...)
		local _, name, id = ...
		if name == "PLAYER_ENTERING_WORLD" then
			self.event:UnregisterEvent("PLAYER_ENTERING_WORLD")
			self:ScheduleTimer("buildQList", 5)
			--self:ScheduleTimer("BuildArgus", 6)
			--self:ScheduleTimer("checkWQ", 15)
			self:ScheduleTimer(function ()
				self:checkWQ("new")
				self:ScheduleRepeatingTimer("checkWQ",30*60,"new")
			end, (32-(date("%M") % 30))*60)
		end
	end)

	--self:ScheduleRepeatingTimer("checkWQ",300,"new")
end
