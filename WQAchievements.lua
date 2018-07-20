WQAchievements = LibStub("AceAddon-3.0"):NewAddon("WQAchievements", "AceConsole-3.0", "AceTimer-3.0")
local WQA = WQAchievements
WQA.cache = {}
WQA.data = {}
WQA.watched = {}
WQA.questList = {}


-- Blizzard
local IsActive = C_TaskQuest.IsActive

-- Locales
local locale = GetLocale()
WQA.L = {}
local L = WQA.L
L["WQChat"] = "Interesting World Quests are active:"
L["WQforAch"] = "%s for %s"
L["achievements"] = "Achievements"
L["mounts"] = "Mounts"
L["pets"] = "Pets"
L["toys"] = "Toys"
if locale == "deDE" then
	L["WQChat"] = "Interessante Weltquests sind verfügbar:"
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
	self.db = LibStub("AceDB-3.0"):New("WQADB", defaults)

	------------------
	-- 	Options Table
	------------------
	WQA.options = {
		type = "group",
		childGroups = "tab",
		args = {
			general = {
				order = 1,
				type = "group",
				childGroups = "tree",
				name = "General",
				args = {}
			},
			custom = {
				order = 2,
				type = "group",
				childGroups = "tree",
				name = "Custom",
				args = {
					--Add WQ
					header1 = { type = "header", name = "Add a World Quest", order = newOrder(), },
					addWQ = {
						name = "WorldQuestID",
						--desc = "To add a worldquest, enter a unique name for the worldquest, and click Okay",
						type = "input",
						order = newOrder(),
						width = .6,
						set = function(info,val)
				   			WQA.data.custom.wqID = val
				   		end,
				    	get = function() return tostring(WQA.data.custom.wqID )  end
					},
					rewardID = {
						name = "Reward (optional)",
						desc = "Enter an achievementID or itemID",
						type = "input",
						width = .6,
						order = newOrder(),
						set = function(info,val)
				   			WQA.data.custom.rewardID = val
				   		end,
				    	get = function() return tostring(WQA.data.custom.rewardID )  end
					},
					rewardType = {
						name = "Reward type",
						order = newOrder(),
						type = "select",
						values = {item = "Item", achievement = "Achievement", none = "none"},
						width = .6,
						set = function(info,val)
				   			WQA.data.custom.rewardType = val
				   		end,
				    	get = function() return WQA.data.custom.rewardType end
					},
					button = {
						order = newOrder(),
						type = "execute",
						name = "Add",
						width = .3,
						func = function() WQA:CreateCustomQuest() end
					},
					--Configure
					header2 = { type = "header", name = "Configure custom World Quests", order = newOrder(), },
				}
			}
		},
	}

	for i = 1, 2 do
		local v = self.data[i]
		self.options.args.general.args[v.name] = {
			order = i,
			name = v.name,
			type = "group",
			inline = true,
			args = {
			}
		}
		self:CreateGroup(self.options.args.general.args[v.name].args, v, "achievements")
		self:CreateGroup(self.options.args.general.args[v.name].args, v, "mounts")
		self:CreateGroup(self.options.args.general.args[v.name].args, v, "pets")
		self:CreateGroup(self.options.args.general.args[v.name].args, v, "toys")
	end

	self:UpdateCustomQuests()
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
			self:ScheduleTimer("CreateQuestList", 5)
			self:ScheduleTimer(function ()
				self:checkWQ("new")
				self:ScheduleRepeatingTimer("checkWQ",30*60,"new")
			end, (32-(date("%M") % 30))*60)
		end
	end)
end




function WQA:ToggleSet(info, val)
	--print(info[#info-2],info[#info-1],info[#info])
	local expansion = info[#info-2]
	local category = info[#info-1]
	local option = info[#info]
	--if not WQA.db.char[expansion] then WQA.db.char[expansion] = {} end
	if not WQA.db.char[category] then WQA.db.char[category] = {} end
	if not val == true then
		WQA.db.char[category][option] = true
	else
		WQA.db.char[category][option] = nil
	end
end

function WQA:ToggleGet()
end

function WQA:CreateGroup(options, data, groupName)
	if data[groupName] then
		options[groupName] = {
			order = 1,
			name = L[groupName],
			type = "group",
			args = {
			}
		}
		local args = options[groupName].args
		local expansion = data.name
		local data = data[groupName]
		for _,object in pairs(data) do
			args[object.name] = {
				type = "toggle",
				name = object.name,
				width = "double",
				handler = WQA,
				set = "ToggleSet",
				descStyle = "inline",
			    get = function()
			    	if not WQA.db.char[groupName] then return true end
			    	if not WQA.db.char[groupName][object.name]  then return true end
			    	return false
		    	end,
			    order = newOrder()	
			}
			if object.itemID then
				args[object.name].name = select(2,GetItemInfo(object.itemID)) or object.name
			else
				args[object.name].name = GetAchievementLink(object.id) or object.name
			end
		end
	end
end

function WQA:CreateCustomQuest()
 	if not self.db.global.custom then self.db.global.custom = {} end
 	self.db.global.custom[tonumber(self.data.custom.wqID)] = {rewardID = tonumber(self.data.custom.rewardID), rewardType = self.data.custom.rewardType}
 	self:UpdateCustomQuests()
 end

function WQA:UpdateCustomQuests()
 	local data = self.db.global.custom
 	if type(data) ~= "table" then return false end
 	local args = self.options.args.custom.args
 	for id,object in pairs(data) do
		args[tostring(id)] = {
			type = "toggle",
			name = GetQuestLink(id) or tostring(id),
			width = "double",
			handler = WQA,
			set = "ToggleSet",
			descStyle = "inline",
		    get = function()
		    	if not WQA.db.char.custom then return true end
		    	if not WQA.db.char.custom[tostring(id)]  then return true end
		    	return false
	    	end,
		    order = newOrder(),
		    width = 1.2
		}
		args[id.."Reward"] = {
			name = "Reward (optional)",
			desc = "Enter an achievementID or itemID",
			type = "input",
			width = .6,
			order = newOrder(),
			set = function(info,val)
				self.db.global.custom[id].rewardID = tonumber(val)
			end,
			get = function() return
				tostring(self.db.global.custom[id].rewardID or "")
			end
		}
		args[id.."RewardType"] = {
			name = "Reward type",
			order = newOrder(),
			type = "select",
			values = {item = "Item", achievement = "Achievement", none = "none"},
			width = .6,
			set = function(info,val)
				self.db.global.custom[id].rewardType = val
			end,
			get = function() return self.db.global.custom[id].rewardType or nil end
		}
		args[id.."Delete"] = {
			order = newOrder(),
			type = "execute",
			name = "Delete",
			width = .5,
			func = function()
				args[tostring(id)] = nil
				args[id.."Reward"] = nil
				args[id.."RewardType"] = nil
				args[id.."Delete"] = nil
				args[id.."space"] = nil
				self.db.global.custom[id] = nil
				self:UpdateCustomQuests()
				GameTooltip:Hide()
			end
		}
		args[id.."space"] = {
			name =" ",
			width = .5,
			order = newOrder(),
			type = "description"
		}
	end
 end
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


WQA:RegisterChatCommand("wqa", "slash")

function WQA:slash(input)
	local arg1 = string.lower(input)

	if arg1 == "" then
		self:CreateQuestList()
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
			{name =  "A Most Efficient Apocalypse", id = 13021, criteriaType = "QUEST_SINGLE", criteria = 50665}
		},
	}
	WQA.data[2] = bfa
end

-- Terrors of the Shore
-- Commander of Argus

function WQA:CreateQuestList()
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
	self:Cache()
end

function WQA:AddAchievement(achievement)
	if self.db.char.achievements and self.db.char.achievements[achievement.name] == true then return end
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
				if not (self.db.char.mounts and self.db.char.mounts[mount.name] == true) then
					if spellID == mount.spellID then
						for _,v  in pairs(mount.quest) do
							if not IsQuestFlaggedCompleted(v.trackingID) then
								if not self.questList[v.wqID] then self.questList[v.wqID] = {} end
						 		local l = self.questList[v.wqID]
								l[#l + 1] = { id = mount.itemID, type = "ITEM"}
								self.cache[mount.itemID] = true
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
  				if not (self.db.char.pets and self.db.char.pets[pet.name] == true) then
	  				if companionID == pet.creatureID then
						for _,v in pairs(pet.quest) do
							if not IsQuestFlaggedCompleted(v.trackingID) then
								if not self.questList[v.wqID] then self.questList[v.wqID] = {} end
								local l = self.questList[v.wqID]
								l[#l + 1] = { id = pet.itemID, type = "ITEM"}
								self.cache[pet.itemID] = true
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
		if not (self.db.char.toys and self.db.char.toys[toy.name] == true) then
			if not PlayerHasToy(toy.itemID) then
				for _,v in pairs(toy.quest) do
					if not IsQuestFlaggedCompleted(v.trackingID) then
						if not self.questList[v.wqID] then self.questList[v.wqID] = {} end
				 		local l = self.questList[v.wqID]
						l[#l + 1] = { id = toy.itemID, type = "ITEM"}
						self.cache[toy.itemID] = true
					end
				end
			end
		end
	end
end

function WQA:AddCustom()
	if type(self.db.global.custom) == "table" then
		for k,v in pairs(self.db.global.custom) do
			if not self.questList[k] then self.questList[k] = {} end
	 		local l = self.questList[k]
			l[#l + 1] = { id = v.rewardID, type = v.rewardType}
			if v.rewardType == "item" then self.cache[v.rewardID] = true end
		end
	end
end

WQA.links = {}
WQA.cacheStart = GetTime()
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
	if n > 0 and (GetTime() - self.cacheStart < 20) then
		self:ScheduleTimer(function ()
			self:Cache()
		end, 2)
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
	local t = string.upper(x.type)
	if t == "ACHIEVEMENT" then
		return GetAchievementLink(x.id)
	elseif t == "ITEM" then
		return self.links[x.id]
	else
		return ""
	end
end