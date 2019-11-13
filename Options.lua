local WQA = WQAchievements
local L = WQA.L

local optionsTimer
local start

WQA.ExpansionList = {
	[6] = "Warlords of Draenor",
	[7] = "Legion",
	[8] = "Battle for Azeroth",
}

local IDToExpansionID = {
	[1] = 6,
	[2] = 7,
	[3] = 8
}

local CurrencyIDList = {
	[7] = {
		1220, -- Order Resources
		1226, -- Nethershard
		1342, -- Legionfall War Supplies
		1533, -- Wakening Essence
	},
	[8] = {
		1553, -- Azerite
		1560, -- War Ressource
		{id = 1716, faction = "Horde"}, -- Honorbound Service Medal
		{id = 1717, faction = "Alliance"}, -- 7th Legion Service Medal
		1721, -- Prismatic Manapearl
		1602, -- Conquest
	}
}

local CraftingReagentIDList = {
	[7] = {
		124124, -- Blood of Sargeras
		133680, -- Slice of Bacon

		124444, -- Infernal Brimstone
		151564, -- Empyrium
		123919, -- Felslate
		123918, -- Leystone Ore

		124116, -- Felhide
		136533, -- Dreadhide Leather
		151566, -- Fiendish Leather
		124113, -- Stonehide Leather
		124115, -- Stormscale

		124106, -- Felwort
		124101, -- Aethril
		124102, -- Dreamleaf
		124103, -- Foxflower
		124104, -- Fjarnskaggl
		124105, -- Starlight Rose
		151565, -- Astral Glory
	},
	[8] = {
		152513, -- Platinum Ore
		152512, -- Monelite Ore
		152579, -- Storm Silver Ore

		152542, -- Hardened Tempest Hide
		153051, -- Mistscale
		154165, -- Calcified Bone
		154722, -- Tempest Hide
		152541, -- Coarse Leather
		153050, -- Shimmerscale
		154164, -- Blood-Stained Bone

		152510, -- Anchor Weed
		152505, -- Riverbud
		152506, -- Star Moss
		152507, -- Akunda's Bite
		152508, -- Winter's Kiss
		152509, -- Siren's Pollen
		152511, -- Sea Stalk
	}
}

local worldQuestType = {
	["LE_QUEST_TAG_TYPE_PVP"] = LE_QUEST_TAG_TYPE_PVP,
	["LE_QUEST_TAG_TYPE_PET_BATTLE"] = LE_QUEST_TAG_TYPE_PET_BATTLE,
	["LE_QUEST_TAG_TYPE_PROFESSION"] = LE_QUEST_TAG_TYPE_PROFESSION,
	["LE_QUEST_TAG_TYPE_DUNGEON"] = LE_QUEST_TAG_TYPE_DUNGEON,
}

WQA.ZoneIDList = {
	[7] = {
		619, -- Broken Isles
		627, -- Dalaran
		630, -- Azsuna
		641, -- Val'sharah
		650, -- Highmountain
		--625, -- Dalaran
		680, -- Suramar
		634, -- Stormheim
		646, -- Broken Shore
		790, -- Eye of Azshara
		885,
		830,
		882,	
	},
	[8] = {
		14, -- Arathi Highlands
		62, -- Darkshore
		875,
		876,
		862,
		863,
		864,
		895, -- Tiragarde Sound
		942,
		896, -- Drustvar
		1161, -- Boralus
		1165, -- Dazar'alor
		1355, -- Nazjatar
		1462, -- Mechagon
	}
}

WQA.EmissaryQuestIDList = {
	[7] = {
		42233, -- Highmountain Tribes
		42420, -- Court of Farondis
		42170, -- The Dreamweavers
		42422, -- The Wardens
		42421, -- The Nightfallen
		42234, -- Valarjar
		48639, -- Army of the Light
		48642, -- Argussian Reach
		48641, -- Armies of Legionfall
		43179, -- Kirin Tor
	},
	[8] = {
		50604, -- Tortollan Seekers
		50562, -- Champions of Azeroth
		{id = 50599, faction = "Alliance"}, -- Proudmoore Admiralty
		{id = 50600, faction = "Alliance"}, -- Order of Embers
		{id = 50601, faction = "Alliance"}, -- Storm's Wake
		{id = 50605, faction = "Alliance"}, -- 7th Legion
		{id = 50598, faction = "Horde"}, -- Zandalari Empire
		{id = 50603, faction = "Horde"}, -- Voldunai
		{id = 50602, faction = "Horde"}, -- Talanji's Expedition
		{id = 50606, faction = "Horde"}, -- The Honorbound
		-- 8.2
		--2391, -- Rustbolt Resistance
		{id = 56119, faction = "Alliance"}, -- Waveblade Ankoan
		{id = 56120, faction = "Horde"}, -- The Unshackled

	},
}

local FactionIDList = {
	[7] = {
		Neutral = {
			2165,
			2170,
			1894, -- The Wardens
			1900, -- Court of Farondis
			1883, -- Dreamweavers
			1828, -- Highmountain Tribe
			1948, -- Valarjar
			1859, -- The Nightfallen
		}
	},
	[8] = {
		Neutral = {
			2164, -- Champions of Azeroth
			2163, -- Tortollan Seekers
			2391, -- Rustbolt Resistance
		},
		Alliance = {
			2160, -- Proudmoore Admiralty
			2161, -- Order of Embers
			2162, -- Storm's Wake
			2159, -- 7th Legion
			2400, -- Waveblade Ankoan
		},
		Horde = {
			2103, -- Zandalari Empire
			2156, -- Talanji's Expedition
			2158, -- Voldunai
			2157, -- The Honorbound
			2373, -- The Unshackled
		},
	},
}

local newOrder
do
	local current = 0
	function newOrder()
		current = current + 1
		return current
	end
end

function WQA:UpdateOptions()
	------------------
	-- 	Options Table
	------------------
	self.options = {
		type = "group",
		childGroups = "tab",
		args = {
			general = {
				order = newOrder(),
				type = "group",
				childGroups = "tree",
				name = "General",
				args = {}
			},
			reward = {
				order = newOrder(),
				type = "group",
				name = "Rewards",
				args = {
					general = {
						order = newOrder(),
						name = "General",
						type = "group",
						--inline = true,
						args = {
							gold = {
								type = "toggle",
								name = "Gold",
								set = function(info, val)
									WQA.db.profile.options.reward.general.gold = val
								end,
								descStyle = "inline",
							 get = function()
							 	return WQA.db.profile.options.reward.general.gold
						 	end,
							 order = newOrder()
							},
							goldMin = {
								name = "minimum Gold",
								type = "input",
								order = newOrder(),
								--width = .6,
								set = function(info,val)
									WQA.db.profile.options.reward.general.goldMin = tonumber(val)
								end,
						 	get = function() return tostring(WQA.db.profile.options.reward.general.goldMin)  end
							},
						},
					},
					gear = {
						order = newOrder(),
						name = "Gear",
						type = "group",
						--inline = true,
						args = {
							itemLevelUpgrade = {
								type = "toggle",
								name = "ItemLevel Upgrade",
								--width = "double",
								set = function(info, val)
									WQA.db.profile.options.reward.gear.itemLevelUpgrade = val
								end,
								descStyle = "inline",
							 get = function()
							 	return WQA.db.profile.options.reward.gear.itemLevelUpgrade
						 	end,
							 order = newOrder()
							},
							AzeriteArmorCache = {
								type = "toggle",
								name = "Azerite Armor Cache",
								--width = "double",
								set = function(info, val)
									WQA.db.profile.options.reward.gear.AzeriteArmorCache = val
								end,
								descStyle = "inline",
							 get = function()
							 	return WQA.db.profile.options.reward.gear.AzeriteArmorCache
						 	end,
							 order = newOrder()
							},
							itemLevelUpgradeMin = {
								name = "minimum ItemLevel Upgrade",
								type = "input",
								order = newOrder(),
								--width = .6,
								set = function(info,val)
									WQA.db.profile.options.reward.gear.itemLevelUpgradeMin = tonumber(val)
								end,
						 	get = function() return tostring(WQA.db.profile.options.reward.gear.itemLevelUpgradeMin)  end
							},
							armorCache = {
								type = "toggle",
								name = "Armor Cache",
								--width = "double",
								set = function(info, val)
									WQA.db.profile.options.reward.gear.armorCache = val
								end,
								descStyle = "inline",
							 get = function()
							 	return WQA.db.profile.options.reward.gear.armorCache
						 	end,
							 order = newOrder()
							},
							weaponCache = {
								type = "toggle",
								name = "Weapon Cache",
								--width = "double",
								set = function(info, val)
									WQA.db.profile.options.reward.gear.weaponCache = val
								end,
								descStyle = "inline",
							 get = function()
							 	return WQA.db.profile.options.reward.gear.weaponCache
						 	end,
							 order = newOrder()
							},
							jewelryCache = {
								type = "toggle",
								name = "Jewelry Cache",
								--width = "double",
								set = function(info, val)
									WQA.db.profile.options.reward.gear.jewelryCache = val
								end,
								descStyle = "inline",
							 get = function()
							 	return WQA.db.profile.options.reward.gear.jewelryCache
						 	end,
							 order = newOrder()
							},
							desc1 = { type = "description", fontSize = "small", name = " ", order = newOrder(), },
							PawnUpgrade = {
								type = "toggle",
								name = "% Upgrade (Pawn)",
								--width = "double",
								set = function(info, val)
									WQA.db.profile.options.reward.gear.PawnUpgrade = val
								end,
								descStyle = "inline",
							 get = function()
							 	return WQA.db.profile.options.reward.gear.PawnUpgrade
						 	end,
							 order = newOrder()
							},
							StatWeightScore = {
								type = "toggle",
								name = "% Upgrade (Stat Weight Score)",
								--width = "double",
								set = function(info, val)
									WQA.db.profile.options.reward.gear.StatWeightScore = val
								end,
								descStyle = "inline",
							 get = function()
							 	return WQA.db.profile.options.reward.gear.StatWeightScore
						 	end,
							 order = newOrder()
							},
							PercentUpgradeMin = {
								name = "minimum % Upgrade",
								type = "input",
								order = newOrder(),
								--width = .6,
								set = function(info,val)
									WQA.db.profile.options.reward.gear.PercentUpgradeMin = tonumber(val)
								end,
						 	get = function() return tostring(WQA.db.profile.options.reward.gear.PercentUpgradeMin)  end
							},
							desc2 = { type = "description", fontSize = "small", name = " ", order = newOrder(), },
							unknownAppearance = {
								type = "toggle",
								name = "Unknown appearance",
								--width = "double",
								set = function(info, val)
									WQA.db.profile.options.reward.gear.unknownAppearance = val
								end,
								descStyle = "inline",
							 get = function()
							 	return WQA.db.profile.options.reward.gear.unknownAppearance
						 	end,
							 order = newOrder()
							},
							unknownSource = {
								type = "toggle",
								name = "Unknown source",
								--width = "double",
								set = function(info, val)
									WQA.db.profile.options.reward.gear.unknownSource = val
								end,
								descStyle = "inline",
							 get = function()
							 	return WQA.db.profile.options.reward.gear.unknownSource
						 	end,
							 order = newOrder()
							},
						},
					},
				}
			},
			custom = {
				order = newOrder(),
				type = "group",
				childGroups = "tree",
				name = "Custom",
				args = {
					quest = {
						order = newOrder(),
						name = "World Quest",
						type = "group",
						inline = true,
						args = {
							--Add WQ
							header1 = { type = "header", name = "Add a Quest you want to track", order = newOrder(), },
							addWQ = {
								name = "QuestID",
								--desc = "To add a worldquest, enter a unique name for the worldquest, and click Okay",
								type = "input",
								order = newOrder(),
								width = .6,
								set = function(info,val)
									WQA.data.custom.wqID = val
								end,
						 	get = function() return tostring(WQA.data.custom.wqID)  end
							},
							questType = {
								name = "Quest type",
								order = newOrder(),
								desc = "IsActive:\nUse this as a last resort. Works for some daily quests.\n\nIsQuestFlaggedCompleted:\nUse this for quests, that are always active.\n\nQuest Pin:\nUse this, if the daily is marked with a quest pin on the world map.\n\nWorld Quest:\nUse this, if you want to track a world quest.",
								type = "select",
								values = {WORLD_QUEST = "World Quest", QUEST_PIN = "Quest Pin", QUEST_FLAG = "IsQuestFlaggedCompleted", IsActive = "IsActive"},
								--width = .6,
								set = function(info,val)
									WQA.data.custom.questType = val
								end,
						 		get = function() return WQA.data.custom.questType end
							},
							mapID = {
								name = "mapID",
								desc = "Quest pin tracking needs a mapID.\nSee https://wow.gamepedia.com/UiMapID for help.",
								type = "input",
								width = .5,
								order = newOrder(),
								set = function(info,val)
									WQA.data.custom.mapID = val
								end,
						 	get = function() return tostring(WQA.data.custom.mapID or "")  end
							},
							--[[
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
							},--]]
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
					reward = {
						order = newOrder(),
						name = "Reward",
						type = "group",
						inline = true,
						args = {
							--Add item
							header1 = { type = "header", name = "Add a World Quest Reward you want to track", order = newOrder(), },
							itemID = {
								name = "itemID",
								--desc = "To add a worldquest, enter a unique name for the worldquest, and click Okay",
								type = "input",
								order = newOrder(),
								width = .6,
								set = function(info,val)
									WQA.data.custom.worldQuestReward = val
								end,
						 	get = function() return tostring(WQA.data.custom.worldQuestReward or 0)  end
							},
							button = {
								order = newOrder(),
								type = "execute",
								name = "Add",
								width = .3,
								func = function() WQA:CreateCustomReward() end
							},
							--Configure
							header2 = { type = "header", name = "Configure custom World Quest Rewards", order = newOrder(), },
						}
					},
					mission = {
						order = newOrder(),
						name = "Mission",
						type = "group",
						inline = true,
						args = {
							--Add WQ
							header1 = { type = "header", name = "Add a Mission you want to track", order = newOrder(), },
							missionID = {
								name = "MissionID",
								type = "input",
								order = newOrder(),
								width = .6,
								set = function(info,val)
									WQA.data.custom.mission.missionID = val
								end,
						 	get = function() return tostring(WQA.data.custom.mission.missionID)  end
							},
							rewardID = {
								name = "Reward (optional)",
								desc = "Enter an achievementID or itemID",
								type = "input",
								width = .6,
								order = newOrder(),
								set = function(info,val)
									WQA.data.custom.mission.rewardID = val
								end,
						 	get = function() return tostring(WQA.data.custom.mission.rewardID )  end
							},
							rewardType = {
								name = "Reward type",
								order = newOrder(),
								type = "select",
								values = {item = "Item", achievement = "Achievement", none = "none"},
								width = .6,
								set = function(info,val)
									WQA.data.custom.mission.rewardType = val
								end,
						 	get = function() return WQA.data.custom.mission.rewardType end
							},
							button = {
								order = newOrder(),
								type = "execute",
								name = "Add",
								width = .3,
								func = function() WQA:CreateCustomMission() end
							},
							--Configure
							header2 = { type = "header", name = "Configure custom Missions", order = newOrder(), },
						}
					},
					missionReward = {
						order = newOrder(),
						name = "Reward",
						type = "group",
						inline = true,
						args = {
							--Add item
							header1 = { type = "header", name = "Add a Mission Reward you want to track", order = newOrder(), },
							itemID = {
								name = "itemID",
								type = "input",
								order = newOrder(),
								width = .6,
								set = function(info,val)
									WQA.data.custom.missionReward = val
								end,
						 	get = function() return tostring(WQA.data.custom.missionReward or 0)  end
							},
							button = {
								order = newOrder(),
								type = "execute",
								name = "Add",
								width = .3,
								func = function() WQA:CreateCustomMissionReward() end
							},
							--Configure
							header2 = { type = "header", name = "Configure custom Mission Rewards", order = newOrder(), },
						}
					},
				}
			},
			options = {
				order = newOrder(),
				type = "group",
				name = "Options",
				args = {
					desc1 = { type = "description", fontSize = "medium", name = "Select where WQA is allowed to post", order = newOrder(), },
					chat = {
						type = "toggle",
						name = "Chat",
						width = "double",
						set = function(info, val)
							WQA.db.profile.options.chat = val
						end,
						descStyle = "inline",
					 get = function()
					 	return WQA.db.profile.options.chat
				 	end,
					 order = newOrder()
					},
					PopUp = {
						type = "toggle",
						name = "PopUp",
						width = "double",
						set = function(info, val)
							WQA.db.profile.options.PopUp = val
						end,
						descStyle = "inline",
					 get = function()
					 	return WQA.db.profile.options.PopUp
				 	end,
					 order = newOrder()
					},
					sortByName = {
						type = "toggle",
						name = "Sort quests by name",
						width = "double",
						set = function(info, val)
							WQA.db.profile.options.sortByName = val
						end,
						descStyle = "inline",
					 get = function()
					 	return WQA.db.profile.options.sortByName
				 	end,
					 order = newOrder()
					},
					sortByZoneName = {
						type = "toggle",
						name = "Sort quests by zone name",
						width = "double",
						set = function(info, val)
							WQA.db.profile.options.sortByZoneName = val
						end,
						descStyle = "inline",
					 get = function()
					 	return WQA.db.profile.options.sortByZoneName
				 	end,
					 order = newOrder()
					},
					chatShowExpansion = {
						type = "toggle",
						name = "Show expansion in chat",
						width = "double",
						set = function(info, val)
							WQA.db.profile.options.chatShowExpansion = val
						end,
						descStyle = "inline",
					 get = function()
					 	return WQA.db.profile.options.chatShowExpansion
				 	end,
					 order = newOrder()
					},
					chatShowZone = {
						type = "toggle",
						name = "Show zone in chat",
						width = "double",
						set = function(info, val)
							WQA.db.profile.options.chatShowZone = val
						end,
						descStyle = "inline",
					 get = function()
					 	return WQA.db.profile.options.chatShowZone
				 	end,
					 order = newOrder()
					},
					chatShowTime = {
						type = "toggle",
						name = "Show time left in chat",
						width = "double",
						set = function(info, val)
							WQA.db.profile.options.chatShowTime = val
						end,
						descStyle = "inline",
					 get = function()
					 	return WQA.db.profile.options.chatShowTime
				 	end,
					 order = newOrder()
					},
					popupShowExpansion = {
						type = "toggle",
						name = "Show expansion in popup",
						width = "double",
						set = function(info, val)
							WQA.db.profile.options.popupShowExpansion = val
						end,
						descStyle = "inline",
					 get = function()
					 	return WQA.db.profile.options.popupShowExpansion
				 	end,
					 order = newOrder()
					},
					popupShowZone = {
						type = "toggle",
						name = "Show zone in popup",
						width = "double",
						set = function(info, val)
							WQA.db.profile.options.popupShowZone = val
						end,
						descStyle = "inline",
					 get = function()
					 	return WQA.db.profile.options.popupShowZone
				 	end,
					 order = newOrder()
					},
					popupShowTime = {
						type = "toggle",
						name = "Show time left in popup",
						width = "double",
						set = function(info, val)
							WQA.db.profile.options.popupShowTime = val
						end,
						descStyle = "inline",
					 get = function()
					 	return WQA.db.profile.options.popupShowTime
				 	end,
					 order = newOrder()
					},
					delay = {
						name = "Delay on login in s",
						type = "input",
						order = newOrder(),
						width = "double",
						set = function(info,val)
							WQA.db.profile.options.delay = tonumber(val)
						end,
						get = function() return tostring(WQA.db.profile.options.delay)  end
					},
					delayCombat = {
						name = "Delay output while in combat",
						type = "toggle",
						order = newOrder(),
						width = "double",
						set = function(info,val)
							WQA.db.profile.options.delayCombat = val
						end,
						get = function() return WQA.db.profile.options.delayCombat end
					},
					WorldQuestTracker = {
						type = "toggle",
						name = "Use World Quest Tracker",
						width = "double",
						set = function(info, val)
							WQA.db.profile.options.WorldQuestTracker = val
						end,
						descStyle = "inline",
					 get = function()
					 	return WQA.db.profile.options.WorldQuestTracker
				 	end,
					 order = newOrder()
					},
				}
			}
		},
	}

	-- General
	-- worldQuestType
	local args = self.options.args.reward.args.general.args
	args.header1 = { type = "header", name = "World Quest Type", order = newOrder(), }
	for k,v in pairs(worldQuestType) do
		args[k] = {
			type = "toggle",
			name = L[k],
			set = function(info, val)
				WQA.db.profile.options.reward.general.worldQuestType[v] = val
			end,
			descStyle = "inline",
			get = function()
				return WQA.db.profile.options.reward.general.worldQuestType[v] or false
			end,
			order = newOrder()
		}
	end

	for i in pairs(self.ExpansionList) do
		local v = self.data[i] or nil
		if v ~= nil then
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
	end
	
	for _,i in ipairs(IDToExpansionID) do
		self.options.args.reward.args[self.ExpansionList[i]] = {
			order = newOrder(),
			name = self.ExpansionList[i],
			type = "group",
			args = {}
		}
		
		-- World Quests
		if i > 6 then
			self.options.args.reward.args[self.ExpansionList[i]].args[self.ExpansionList[i].."WorldQuests"] = {
				order = newOrder(),
				name = "World Quests",
				type = "group",
				args = {}
			}
			local args = self.options.args.reward.args[self.ExpansionList[i]].args[self.ExpansionList[i].."WorldQuests"].args

			-- Zones
			if WQA.ZoneIDList[i] then
				args.zone = {
					order = newOrder(),
					name = "Zones",
					type = "group",
					args = {},
					inline = false,
				}
				for k,v in pairs(WQA.ZoneIDList[i]) do
					local name = C_Map.GetMapInfo(v).name
					args.zone.args[name] = {
						type = "toggle",
						name = name,
						set = function(info, val)
							WQA.db.profile.options.zone[v] = val
						end,
						descStyle = "inline",
						get = function()
							return WQA.db.profile.options.zone[v] or false
						end,
						order = newOrder()
					}
				end
			end

			-- Currencies
			if CurrencyIDList[i] then
				args.currency = {
					order = newOrder(),
					name = "Currencies",
					type = "group",
					args = {}
				}
				for k,v in pairs(CurrencyIDList[i]) do
					if not (type(v) == "table" and v.faction ~= self.faction) then
						if type(v) == "table" then v = v.id end
						args.currency.args[GetCurrencyInfo(v)] = {
							type = "toggle",
							name = GetCurrencyInfo(v),
							set = function(info, val)
								WQA.db.profile.options.reward.currency[v] = val
							end,
							descStyle = "inline",
							get = function()
								return WQA.db.profile.options.reward.currency[v]
							end,
							order = newOrder()
						}
					end
				end
			end

			-- Reputation
			if FactionIDList[i] then
				args.reputation = {
					order = newOrder(),
					name = "Reputation",
					type = "group",
					args = {}
				}
				for _, factionGroup in pairs {"Neutral", UnitFactionGroup("player")} do
					if FactionIDList[i][factionGroup] then
						for k,v in pairs(FactionIDList[i][factionGroup]) do
							args.reputation.args[GetFactionInfoByID(v)] = {
								type = "toggle",
								name = GetFactionInfoByID(v),
								set = function(info, val)
									WQA.db.profile.options.reward.reputation[v] = val
								end,
								descStyle = "inline",
								get = function()
									return WQA.db.profile.options.reward.reputation[v]
								end,
								order = newOrder()
							}
						end
					end
				end
			end

			-- Emissary
			if self.EmissaryQuestIDList[i] then
				args.emissary = {
					order = newOrder(),
					name = "Emissary Quests",
					type = "group",
					args = {}
				}
				for k,v in pairs(self.EmissaryQuestIDList[i]) do
					if not (type(v) == "table" and v.faction ~= self.faction) then
						if type(v) == "table" then v = v.id end
						args.emissary.args[C_QuestLog.GetQuestInfo(v) or tostring(v)] = {
							type = "toggle",
							name = C_QuestLog.GetQuestInfo(v) or tostring(v),
							set = function(info, val)
								WQA.db.profile.options.emissary[v] = val
							end,
							descStyle = "inline",
							get = function()
								return WQA.db.profile.options.emissary[v]
							end,
							order = newOrder()
						}
					end
				end
			end

			-- Professions
			if i > 6 then
				args.profession = {
					order = newOrder(),
					name = "Professions",
					type = "group",
					args = {}
				}

				-- Recipes
				args.profession.args["Recipes"] = {
					type = "toggle",
					name = "Recipes",
					set = function(info, val)
						WQA.db.profile.options.reward.recipe[i] = val
					end,
					descStyle = "inline",
					get = function()
						return WQA.db.profile.options.reward.recipe[i]
					end,
					order = newOrder()
				}

				-- Skillup
				-- if not self.db.char[exp+5].profession[tradeskillLineID].isMaxLevel and self.db.profile.options.reward[exp+5].profession[tradeskillLineID].skillup thenthen
				for _, tradeskillLineIndex in pairs({GetProfessions()}) do
					local professionName,_,_,_,_,_, tradeskillLineID = GetProfessionInfo(tradeskillLineIndex)
					args.profession.args[tradeskillLineID.."Header"] = { type = "header", name = professionName, order = newOrder(), }
					args.profession.args[tradeskillLineID.."Skillup"] = {
						type = "toggle",
						name = "Skillup",
						desc = "Track every World Quest until skill level is maxed out",
						set = function(info, val)
							WQA.db.profile.options.reward[i].profession[tradeskillLineID].skillup = val
						end,
						get = function()
							return WQA.db.profile.options.reward[i].profession[tradeskillLineID].skillup
						end,
						order = newOrder()
					}
					args.profession.args[tradeskillLineID.."MaxLevel"] = {
						type = "toggle",
						name = "Skill level is maxed out*",
						desc = "Setting is per character",
						set = function(info, val)
							WQA.db.char[i].profession[tradeskillLineID].isMaxLevel = val
						end,
						get = function()
							return WQA.db.char[i].profession[tradeskillLineID].isMaxLevel
						end,
						order = newOrder()
					}
				end
					-- Crafting Reagents
					--
					--for k,v in pairs(CraftingReagentIDList[i] or {}) do
					--	local name = GetItemInfo(v)
					--	if name then
					--		self.options.args.reward.args[ExpansionList[i]].args.profession.args[GetItemInfo(v)] = {
					--			type = "toggle",
					--			name = GetItemInfo(v),
					--			set = function(info, val)
					--				WQA.db.profile.options.reward.craftingreagent[v] = val
					--			end,
					--			descStyle = "inline",
					--		 get = function()
					--		 	return WQA.db.profile.options.reward.craftingreagent[v]
					--	 	end,
					--		 order = newOrder()
					--		}
					--	else
					--		--LibStub("AceConfigRegistry-3.0"):NotifyChange("WQAchievements")
					--	end
					--end
			end
		end

		-- Mission Table
		self.options.args.reward.args[self.ExpansionList[i]].args[self.ExpansionList[i].."MissionTable"] = {
			order = newOrder(),
			name = (i ~= 6 and "Mission Table" or "Mission Table & Shipyard"),
			type = "group",
			args = {}
		}
		local args = self.options.args.reward.args[self.ExpansionList[i]].args[self.ExpansionList[i].."MissionTable"].args

		-- Currencies
		if CurrencyIDList[i] then
			args.currency = {
				order = newOrder(),
				name = "Currencies",
				type = "group",
				args = {}
			}
			if i == 8 then
				args.currency.args = {
					gold = {
						type = "toggle",
						name = "Gold",
						set = function(info, val)
							WQA.db.profile.options.missionTable.reward.gold = val
						end,
						descStyle = "inline",
						get = function()
							return WQA.db.profile.options.missionTable.reward.gold
						end,
						order = newOrder()
					},
					goldMin = {
						name = "minimum Gold",
						type = "input",
						order = newOrder(),
						--width = .6,
						set = function(info,val)
							WQA.db.profile.options.missionTable.reward.goldMin = tonumber(val)
						end,
						get = function() return tostring(WQA.db.profile.options.missionTable.reward.goldMin)  end
					},
				}
			end

			for k,v in pairs(CurrencyIDList[i]) do
				if not (type(v) == "table" and v.faction ~= self.faction) then
					if type(v) == "table" then v = v.id end
					args.currency.args[GetCurrencyInfo(v)] = {
						type = "toggle",
						name = GetCurrencyInfo(v),
						set = function(info, val)
							WQA.db.profile.options.missionTable.reward.currency[v] = val
						end,
						descStyle = "inline",
						get = function()
							return WQA.db.profile.options.missionTable.reward.currency[v]
						end,
						order = newOrder()
					}
				end
			end
		end

		-- Reputation
		if FactionIDList[i] then
			args.reputation = {
				order = newOrder(),
				name = "Reputation",
				type = "group",
				args = {}
			}
			for _, factionGroup in pairs {"Neutral", UnitFactionGroup("player")} do
				if FactionIDList[i][factionGroup] then
					for k,v in pairs(FactionIDList[i][factionGroup]) do
						args.reputation.args[GetFactionInfoByID(v)] = {
							type = "toggle",
							name = GetFactionInfoByID(v),
							set = function(info, val)
								WQA.db.profile.options.missionTable.reward.reputation[v] = val
							end,
							descStyle = "inline",
							get = function()
								return WQA.db.profile.options.missionTable.reward.reputation[v]
							end,
							order = newOrder()
						}
					end
				end
			end
		end
	end

	self:UpdateCustom()
end

function WQA:GetOptions()
	self:UpdateOptions()
	self:SortOptions()
	return self.options
end

function WQA:ToggleSet(info, val,...)
	--print(info[#info-2],info[#info-1],info[#info])
	local expansion = info[#info-2]
	local category = info[#info-1]
	local option = info[#info]
	WQA.db.profile[category][tonumber(option)] = val
	if val == "exclusive" then
		local name, server = UnitFullName("player")
		WQA.db.profile[category].exclusive[tonumber(option)] = name.."-"..server
	elseif WQA.db.profile[category].exclusive[tonumber(option)] then
		WQA.db.profile[category].exclusive[tonumber(option)] = nil
	end
	--if not WQA.db.profile[expansion] then WQA.db.profile[expansion] = {} end
	--[[if not WQA.db.profile[category] then WQA.db.profile[category] = {} end
	if not val == true then
		WQA.db.profile[category][option] = true
	else
		WQA.db.profile[category][option] = nil
	end-- ]]
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

		args["completed"] = { type = "header", name = L["completed"], order = newOrder(), hidden = true, }
		args["notCompleted"] = { type = "header", name = L["notCompleted"], order = newOrder(), hidden = true, }

		local expansion = data.name
		local data = data[groupName]
		for _,object in pairs(data) do
			local id = object.id or object.spellID or object.creatureID or object.itemID
			local idString = tostring(id)
			args[idString.."Name"] = {
				type = "description",
				name = idString,
				fontSize = "medium",
				order = newOrder(),
				width = 1.5,
			}
			args[idString] = {
				type = "select",
				values = {disabled = L["tracking_disabled"], default = L["tracking_default"], always = L["tracking_always"], wasEarnedByMe = L["tracking_wasEarnedByMe"], exclusive = L["tracking_exclusive"]},
				width = 1.4,
				--type = "toggle",
				name = "",--idString,
				handler = WQA,
				set = "ToggleSet",
				--descStyle = "inline",
			 get = function(info)
			 	local value = WQA.db.profile[groupName][id]
			 	if value == "exclusive" then
			 		local name, server = UnitFullName("player")
			 		name = name.."-"..server
			 		if WQA.db.profile[info[#info-1]].exclusive[id] ~= name then
			 			info.option.values.other = string.format(L["tracking_other"], WQA.db.profile[info[#info-1]].exclusive[id])
			 			return "other"
			 		end
			 	end
					return value
		 	end,
				order = newOrder(),
			}
			if object.itemID then
				if not select(2,GetItemInfo(object.itemID)) then
					self:CancelTimer(optionsTimer)
					start = GetTime()
					optionsTimer = self:ScheduleTimer(function() LibStub("AceConfigRegistry-3.0"):NotifyChange("WQAchievements") end, 2)
				end
				args[idString.."Name"].name = select(2,GetItemInfo(object.itemID)) or object.name
			else
				args[idString.."Name"].name = GetAchievementLink(object.id) or object.name
			end
		end
	end
end

function WQA:CreateCustomQuest()
	 if not self.db.global.custom then self.db.global.custom = {} end
	 if not self.db.global.custom.worldQuest then self.db.global.custom.worldQuest = {} end
 	self.db.global.custom.worldQuest[tonumber(self.data.custom.wqID)] = {questType = self.data.custom.questType, mapID = self.data.custom.mapID}--{rewardID = tonumber(self.data.custom.rewardID), rewardType = self.data.custom.rewardType}
 	self:UpdateCustomQuests()
 end

function WQA:UpdateCustomQuests()
 	local data = self.db.global.custom.worldQuest
 	if type(data) ~= "table" then return false end
 	local args = self.options.args.custom.args.quest.args
 	for id,object in pairs(data) do
		args[tostring(id)] = {
			type = "toggle",
			name = GetQuestLink(id) or C_QuestLog.GetQuestInfo(id) or tostring(id),
			width = "double",
			set = function(info, val)
				WQA.db.profile.custom.worldQuest[id] = val
			end,
			descStyle = "inline",
		 get = function()
		 	return WQA.db.profile.custom.worldQuest[id]
	 	end,
		 order = newOrder(),
		 width = 1.2
		}

		args[id.."questType"] = {
			name = "Quest type",
			order = newOrder(),
			desc = "IsActive:\nUse this as a last resort. Works for some daily quests.\n\nIsQuestFlaggedCompleted:\nUse this for quests, that are always active.\n\nQuest Pin:\nUse this, if the daily is marked with a quest pin on the world map.\n\nWorld Quest:\nUse this, if you want to track a world quest.",
			type = "select",
			values = {WORLD_QUEST = "World Quest", QUEST_PIN = "Quest Pin", QUEST_FLAG = "IsQuestFlaggedCompleted", IsActive = "IsActive"},
			width = .8,
			set = function(info,val)
				self.db.global.custom.worldQuest[id].questType = val
			end,
			get = function() return tostring(self.db.global.custom.worldQuest[id].questType or "") end
		}
		args[id.."mapID"] = {
			name = "mapID",
			desc = "Quest pin tracking needs a mapID.\nSee https://wow.gamepedia.com/UiMapID for help.",
			type = "input",
			width = .4,
			order = newOrder(),
			set = function(info,val)
				self.db.global.custom.worldQuest[id].mapID = val
			end,
		 get = function() return tostring(self.db.global.custom.worldQuest[id].mapID or "")  end
		}

		--[[
		args[id.."Reward"] = {
			name = "Reward (optional)",
			desc = "Enter an achievementID or itemID",
			type = "input",
			width = .6,
			order = newOrder(),
			set = function(info,val)
				self.db.global.custom.worldQuest[id].rewardID = tonumber(val)
			end,
			get = function() return
				tostring(self.db.global.custom.worldQuest[id].rewardID or "")
			end
		}
		args[id.."RewardType"] = {
			name = "Reward type",
			order = newOrder(),
			type = "select",
			values = {item = "Item", achievement = "Achievement", none = "none"},
			width = .6,
			set = function(info,val)
				self.db.global.custom.worldQuest[id].rewardType = val
			end,
			get = function() return self.db.global.custom.worldQuest[id].rewardType or nil end
		}--]]
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
				self.db.global.custom.worldQuest[id] = nil
				self:UpdateCustomQuests()
				GameTooltip:Hide()
			end
		}
		args[id.."space"] = {
			name =" ",
			width = .25,
			order = newOrder(),
			type = "description"
		}
	end
end

function WQA:CreateCustomReward()
	 if not self.db.global.custom then self.db.global.custom = {} end
	 if not self.db.global.custom.worldQuestReward then self.db.global.custom.worldQuestReward = {} end
 	self.db.global.custom.worldQuestReward[tonumber(self.data.custom.worldQuestReward)] = true
 	self:UpdateCustomRewards()
end

function WQA:UpdateCustomRewards()
 	local data = self.db.global.custom.worldQuestReward
 	if type(data) ~= "table" then return false end
 	local args = self.options.args.custom.args.reward.args
 	for id,_ in pairs(data) do
 		local _, itemLink = GetItemInfo(id)
		args[tostring(id)] = {
			type = "toggle",
			name = itemLink or tostring(id),
			width = "double",
			set = function(info, val)
				WQA.db.profile.custom.worldQuestReward[id] = val
			end,
			descStyle = "inline",
		 get = function()
		 	return WQA.db.profile.custom.worldQuestReward[id]
	 	end,
		 order = newOrder(),
		 width = 1.2
		}
		args[id.."Delete"] = {
			order = newOrder(),
			type = "execute",
			name = "Delete",
			width = .5,
			func = function()
				args[tostring(id)] = nil
				args[id.."Delete"] = nil
				args[id.."space"] = nil
				self.db.global.custom.worldQuestReward[id] = nil
				self:UpdateCustomRewards()
				GameTooltip:Hide()
			end
		}
		args[id.."space"] = {
			name =" ",
			width = 1,
			order = newOrder(),
			type = "description"
		}
	end
end

function WQA:CreateCustomMission()
	if not self.db.global.custom then self.db.global.custom = {} end
	if not self.db.global.custom.mission then self.db.global.custom.mission = {} end
	self.db.global.custom.mission[tonumber(self.data.custom.mission.missionID)] = {rewardID = tonumber(self.data.custom.mission.rewardID), rewardType = self.data.custom.mission.rewardType}
 	self:UpdateCustomMissions()
end

function WQA:UpdateCustomMissions()
	local data = self.db.global.custom.mission
	if type(data) ~= "table" then return false end
	local args = self.options.args.custom.args.mission.args
	for id,object in pairs(data) do
	args[tostring(id)] = {
		type = "toggle",
		name = C_Garrison.GetMissionLink(id) or tostring(id),
		width = "double",
		set = function(info, val)
			WQA.db.profile.custom.mission[id] = val
		end,
		descStyle = "inline",
		get = function()
			return WQA.db.profile.custom.mission[id]
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
			self.db.global.custom.mission[id].rewardID = tonumber(val)
		end,
		get = function() return
			tostring(self.db.global.custom.mission[id].rewardID or "")
		end
	}
	args[id.."RewardType"] = {
		name = "Reward type",
		order = newOrder(),
		type = "select",
		values = {item = "Item", achievement = "Achievement", none = "none"},
		width = .6,
		set = function(info,val)
			self.db.global.custom.mission[id].rewardType = val
		end,
		get = function() return self.db.global.custom.mission[id].rewardType or nil end
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
			self.db.global.custom.mission[id] = nil
			self:UpdateCustomMissions()
			GameTooltip:Hide()
		end
	}
	args[id.."space"] = {
		name =" ",
		width = .25,
		order = newOrder(),
		type = "description"
	}
end
end

function WQA:CreateCustomMissionReward()
	if not self.db.global.custom then self.db.global.custom = {} end
	if not self.db.global.custom.missionReward then self.db.global.custom.missionReward = {} end
	self.db.global.custom.missionReward[tonumber(self.data.custom.missionReward)] = true
	self:UpdateCustomMissionRewards()
end

function WQA:UpdateCustomMissionRewards()
	local data = self.db.global.custom.missionReward
	if type(data) ~= "table" then return false end
	local args = self.options.args.custom.args.missionReward.args
	for id,_ in pairs(data) do
		local _, itemLink = GetItemInfo(id)
		args[tostring(id)] = {
			type = "toggle",
			name = itemLink or tostring(id),
			width = "double",
			set = function(info, val)
				WQA.db.profile.custom.missionReward[id] = val
			end,
			descStyle = "inline",
			get = function()
				return WQA.db.profile.custom.missionReward[id]
			end,
			order = newOrder(),
			width = 1.2
		}
		args[id.."Delete"] = {
			order = newOrder(),
			type = "execute",
			name = "Delete",
			width = .5,
			func = function()
				args[tostring(id)] = nil
				args[id.."Delete"] = nil
				args[id.."space"] = nil
				self.db.global.custom.missionReward[id] = nil
				self:UpdateCustomMissionRewards()
				GameTooltip:Hide()
			end
		}
		args[id.."space"] = {
			name =" ",
			width = 1,
			order = newOrder(),
			type = "description"
		}
	end
end

function WQA:UpdateCustom()
	self:UpdateCustomQuests()
	self:UpdateCustomRewards()
	self:UpdateCustomMissions()
	self:UpdateCustomMissionRewards()
end

function WQA:SortOptions()
	for k,v in pairs(WQA.options.args.general.args) do
		for kk,vv in pairs(v.args) do
			t = {}
			for kkk,vvv in pairs(vv.args) do
				local completed = false
				local id = select(3,string.find(kkk, "(%d*)Name"))
				if id then
					id = tonumber(id)
					if kk == "achievements" then
						completed = select(4,GetAchievementInfo(id))
					elseif kk == "mounts" then
						for _, mountID in pairs(C_MountJournal.GetMountIDs()) do
							local _, spellID, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)
							if spellID == id then
								completed = isCollected
								break
							end
						end
					elseif kk == "pets" then
						local total = C_PetJournal.GetNumPets()
						for i = 1, total do
							local petID, _, owned, _, _, _, _, _, _, _, companionID = C_PetJournal.GetPetInfoByIndex(i)
							if companionID == id then
								completed = owned
								break
							end
						end
					elseif kk == "toys" then
						completed = PlayerHasToy(id)
					end
					vvv.disabled = completed
					table.insert(t, {key = kkk, name = select(3,string.find(vvv.name, "%[(.+)%]")) or vvv.name, completed = completed, id = tostring(id)})
				end
			end
			table.sort(t, function(a,b) return a.name < b.name end)
			local completedHeader = false
			for order,object in pairs(t) do
				if not object.completed then
					vv.args["notCompleted"].order = 0
					vv.args["notCompleted"].hidden = false
				end
				if object.completed then
					order = order + 100
					if not completedHeader then
						vv.args["completed"].order = order*2 - .5
						vv.args["completed"].hidden = false
						completedHeader = true
					end
				end
				vv.args[object.key].order = order*2
				vv.args[object.id].order = order*2 + 1
			end
		end
	end
end