local timer


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
			}
		}
	}
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
			},
			options = {
				order = 3,
				type = "group",
				name = "Options",
				args = {
					desc1 = { type = "description", fontSize = "medium", name = "Select where WQA is allowed to post", order = newOrder(), },
					chat = {
						type = "toggle",
						name = "Chat",
						width = "double",
						set = function(info, val)
							WQA.db.char.options.chat = val
						end,
						descStyle = "inline",
					    get = function()
					    	return WQA.db.char.options.chat
				    	end,
					    order = newOrder()
					},
					PopUp = {
						type = "toggle",
						name = "PopUp",
						width = "double",
						handler = WQA,
						set = function(info, val)
							WQA.db.char.options.PopUp = val
						end,
						descStyle = "inline",
					    get = function()
					    	return WQA.db.char.options.PopUp
				    	end,
					    order = newOrder()
					}
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
			self:ScheduleTimer("Show", 5)
			self:ScheduleTimer(function ()
				self:Show("new")
				self:ScheduleRepeatingTimer("Show",30*60,"new")
			end, (32-(date("%M") % 30))*60)
		end
		if name == "QUEST_LOG_UPDATE" then
			self.event:UnregisterEvent("QUEST_LOG_UPDATE")
			self.waitforevent = false
			self:CancelTimer(timer)
			self:Reward()
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
			width = .4,
			order = newOrder(),
			type = "description"
		}
	end
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
			{name = "Crate Expectations", id = 11681, criteriaType = "QUEST_SINGLE", criteria = 45542}
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
	self:Reward()
end

function WQA:AddAchievement(achievement)
	if self.db.char.achievements and (self.db.char.achievements[achievement.name] == true) then return end
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
					end
				end
			end
		end
	end
end

function WQA:AddCustom()
	if type(self.db.global.custom) == "table" then
		for k,v in pairs(self.db.global.custom) do
			if not (self.db.char.custom and self.db.char.custom[tostring(k)] == true) then
				if not self.questList[k] then self.questList[k] = {} end
	 			local l = self.questList[k]
				l[#l + 1] = { id = v.rewardID, type = v.rewardType}
			end
		end
	end
end

WQA.first = false
function WQA:Show(mode)
	self:CreateQuestList()
	self:CheckWQ(mode)
	self.first = true
end


function WQA:CheckWQ(mode)
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
	local l = self.questList[questID].rewards
	local r = ""
	if l and l.item then
		if l.item.bonus.itemLevelUpgrade then
			r = r.."|cFF00FF00+"..l.item.bonus.itemLevelUpgrade.." iLvl|r"
		end
		if l.item.bonus.itemPercentUpgrade then
			if r ~= "" then r = r.."," end
			r = r.."|cFF00FF00+".. l.item.bonus.itemPercentUpgrade.."%|r"
		end
		if l.item.bonus.transmog then
			if r ~= "" then r = r.." " end
			r = r..icons[l.item.bonus.transmog]
		end
		r = l.item.itemLink.." "..r
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
		if not self.questList[questID].rewards then
			output = "   "..string.format(L["WQforAch"],GetQuestLink(questID),self:link(self.questList[questID][1]))
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
			if not self.questList[questID].rewards then
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

WQA.waitforevent = false
function WQA:Reward()
	self.rewards = false
	if self.waitforevent == true then
		self.rewards = true
		self.waitforevent = false
		return
	end
	
	for k,mapID in pairs({
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

		
	}) do 
		local quests = C_TaskQuest.GetQuestsForPlayerByMapID(mapID)
		if quests then
		for i=1,#quests do
			local questID = quests[i].questId
			local numQuestRewards = GetNumQuestLogRewards (questID)
			--	print( GetNumQuestLogRewards (questID))
				if (numQuestRewards > 0) then
				local itemName, itemTexture, quantity, quality, isUsable, itemID = GetQuestLogRewardInfo(1, questID)
			--	if not itemName then print(itemID) end
			--	print(GetQuestLogRewardInfo(1, questID))
				if itemID then
					inspectScantip:SetQuestLogItem("reward", 1, questID)
					itemLink = select(2,inspectScantip:GetItem())
					local itemName, _, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice, itemClassID, itemSubClassID = GetItemInfo (itemLink)

					-- Ask Pawn if this is an Upgrade
					if PawnIsItemAnUpgrade then
						local Item = PawnGetItemData(itemLink)
						if Item then
							local UpgradeInfo, BestItemFor, SecondBestItemFor, NeedsEnhancements = PawnIsItemAnUpgrade(Item)
							if UpgradeInfo then
								if not self.questList[questID] then self.questList[questID] = {} end
						 		local l = self.questList[questID]
						 		if not l.rewards then l.rewards = {item = {itemLink = itemLink, bonus = {}}} end
								l.rewards.item.bonus.itemPercentUpgrade = math.floor(UpgradeInfo[1].PercentUpgrade*100+.5)
							end
						end
					end

					-- Upgrade by itemLevel
					--if not PawnIsItemAnUpgrade or itemEquipLoc == INVTYPE_TRINKET then

						local itemLevel1, itemLevel2
						if EquipLocToSlot1[itemEquipLoc] then
							local itemLink1 = GetInventoryItemLink("player", EquipLocToSlot1[itemEquipLoc])
							--print(itemLink1)
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
						--print(itemEquipLoc, EquipLocToSlot1[itemEquipLoc], itemLink1, itemLink2)
						itemLevel = GetDetailedItemLevelInfo(itemLink)
						local itemLevelEquipped = math.min(itemLevel1 or 1000, itemLevel2 or 1000)
						if itemLevel > itemLevelEquipped then
							if not self.questList[questID] then self.questList[questID] = {} end
					 		local l = self.questList[questID]
					 		if not l.rewards then l.rewards = {item = {itemLink = itemLink, bonus = {}}} end
							l.rewards.item.bonus.itemLevelUpgrade = itemLevel - itemLevelEquipped
						end
					--end

					-- Transmog
					if CanIMogIt then
						if CanIMogIt:IsEquippable(itemLink) and CanIMogIt:CharacterCanLearnTransmog(itemLink) then
							if not CanIMogIt:PlayerKnowsTransmog(itemLink) then
								if not self.questList[questID] then self.questList[questID] = {} end
								local l = self.questList[questID]
								if not l.rewards then l.rewards = {item = {itemLink = itemLink, bonus = {}}} end
								l.rewards.item.bonus.transmog = "unknown"
							elseif not CanIMogIt:PlayerKnowsTransmogFromItem(itemLink)  then
								if not self.questList[questID] then self.questList[questID] = {} end
								local l = self.questList[questID]
								if not l.rewards then l.rewards = {item = {itemLink = itemLink, bonus = {}}} end
								l.rewards.item.bonus.transmog = "known"
							end
						end
					end
				end
			end
		end
	end
	 end
	timer = self:ScheduleTimer(function() self:Reward() end, .5)
	self.event:RegisterEvent("QUEST_LOG_UPDATE")
	self.waitforevent = true
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