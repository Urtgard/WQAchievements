local WQA = WQAchievements
local L = WQA.L

-- Blizzard
local GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo
local GetTitleForQuestID = C_QuestLog.GetTitleForQuestID

local optionsTimer

local CurrencyIDList = {
	[6] = {
		823, -- Apexis Crystal
		824 -- Garrison Resources
	},
	[7] = {
		1220, -- Order Resources
		1226, -- Nethershard
		1342, -- Legionfall War Supplies
		1508, -- Veiled Argunite
		1533 -- Wakening Essence
	},
	[8] = {
		1553,                          -- Azerite
		1560,                          -- War Ressource
		{ id = 1716, faction = "Horde" }, -- Honorbound Service Medal
		{ id = 1717, faction = "Alliance" }, -- 7th Legion Service Medal
		1721,                          -- Prismatic Manapearl
		1602,                          -- Conquest
		1166                           -- Timewarped Badge
	},
	[9] = {
		1819, -- Medallion of Service (Kyrian covenant)
		1889 -- Adventure Campaign Progress
	},
	[10] = {
		2003, -- Dragon Isles Supplies
		2123, -- Bloody Tokens
		2657, -- Mysterious Fragment
		2245, -- Flightstones
	},
	[11] = {
		3008, -- Valorstones
		3056, -- Kej
		2815, -- Resonance Crystals
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
		151565 -- Astral Glory
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
		152511 -- Sea Stalk
	}
}

local worldQuestType = {
	["LE_QUEST_TAG_TYPE_PVP"] = Enum.QuestTagType.PvP,
	["LE_QUEST_TAG_TYPE_PET_BATTLE"] = Enum.QuestTagType.PetBattle,
	["LE_QUEST_TAG_TYPE_PROFESSION"] = Enum.QuestTagType.Profession,
	["LE_QUEST_TAG_TYPE_DUNGEON"] = Enum.QuestTagType.Dungeon
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
		43179 -- Kirin Tor
	},
	[8] = {
		50604,                          -- Tortollan Seekers
		50562,                          -- Champions of Azeroth
		{ id = 50599, faction = "Alliance" }, -- Proudmoore Admiralty
		{ id = 50600, faction = "Alliance" }, -- Order of Embers
		{ id = 50601, faction = "Alliance" }, -- Storm's Wake
		{ id = 50605, faction = "Alliance" }, -- 7th Legion
		{ id = 50598, faction = "Horde" }, -- Zandalari Empire
		{ id = 50603, faction = "Horde" }, -- Voldunai
		{ id = 50602, faction = "Horde" }, -- Talanji's Expedition
		{ id = 50606, faction = "Horde" }, -- The Honorbound
		-- 8.2
		-- 2391, -- Rustbolt Resistance
		{ id = 56119, faction = "Alliance" }, -- Waveblade Ankoan
		{ id = 56120, faction = "Horde" } -- The Unshackled
	}
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
			1859 -- The Nightfallen
		}
	},
	[8] = {
		Neutral = {
			2164, -- Champions of Azeroth
			2163, -- Tortollan Seekers
			2391, -- Rustbolt Resistance
			2417, -- Uldum Accord
			2415 -- Rajani
		},
		Alliance = {
			2160, -- Proudmoore Admiralty
			2161, -- Order of Embers
			2162, -- Storm's Wake
			2159, -- 7th Legion
			2400 -- Waveblade Ankoan
		},
		Horde = {
			2103, -- Zandalari Empire
			2156, -- Talanji's Expedition
			2158, -- Voldunai
			2157, -- The Honorbound
			2373 -- The Unshackled
		}
	},
	[9] = {
		Neutral = {
			2413, -- Court of Harvesters
			2470, -- Death's Advance
			2407, -- The Ascended
			2478, -- The Enlightened
			2410, -- The Undying Army
			2465, -- The Wild Hunt
			2432 -- Ve'nari
		}
	},
	[10] = {
		Neutral = {
			2615, -- Azerothian Archives
			2507, -- Dragonscale Expedition
			2574, -- Dream Wardens
			2511, -- Iskaara Tuskarr
			2564, -- Loamm Niffen
			2503, -- Maruuk Centaur
			2510 -- Valdrakken Accord
		}
	},
	[11] = {
		Neutral = {
			2594, -- The Assembly of the Deeps
			2570, -- Hallowfall Arathi
			2600, -- The Severed Threads
			2590 -- Council of Dornogal
		}

	}
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
				name = L["General"],
				args = {}
			},
			reward = {
				order = newOrder(),
				type = "group",
				name = L["Rewards"],
				args = {
					general = {
						order = newOrder(),
						name = L["General"],
						type = "group",
						-- inline = true,
						args = {
							gold = {
								type = "toggle",
								name = L["Gold"],
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
								name = L["minimum Gold"],
								type = "input",
								order = newOrder(),
								set = function(info, val)
									WQA.db.profile.options.reward.general.goldMin = tonumber(val)
								end,
								get = function()
									return tostring(WQA.db.profile.options.reward.general.goldMin)
								end
							}
						}
					},
					gear = {
						order = newOrder(),
						name = L["Gear"],
						type = "group",
						-- inline = true,
						args = {
							itemLevelUpgrade = {
								type = "toggle",
								name = L["ItemLevel Upgrade"],
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
								name = L["Azerite Armor Cache"],
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
								name = L["minimum ItemLevel Upgrade"],
								type = "input",
								order = newOrder(),
								set = function(info, val)
									WQA.db.profile.options.reward.gear.itemLevelUpgradeMin = tonumber(val)
								end,
								get = function()
									return tostring(WQA.db.profile.options.reward.gear.itemLevelUpgradeMin)
								end
							},
							armorCache = {
								type = "toggle",
								name = L["Armor Cache"],
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
								name = L["Weapon Cache"],
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
								name = L["Jewelry Cache"],
								set = function(info, val)
									WQA.db.profile.options.reward.gear.jewelryCache = val
								end,
								descStyle = "inline",
								get = function()
									return WQA.db.profile.options.reward.gear.jewelryCache
								end,
								order = newOrder()
							},
							desc1 = {
								type = "description",
								fontSize = "small",
								name = " ",
								order = newOrder()
							},
							PawnUpgrade = {
								type = "toggle",
								name = L["% Upgrade (Pawn)"],
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
								name = L["% Upgrade (Stat Weight Score)"],
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
								name = L["minimum % Upgrade"],
								type = "input",
								order = newOrder(),
								set = function(info, val)
									WQA.db.profile.options.reward.gear.PercentUpgradeMin = tonumber(val)
								end,
								get = function()
									return tostring(WQA.db.profile.options.reward.gear.PercentUpgradeMin)
								end
							},
							desc2 = {
								type = "description",
								fontSize = "small",
								name = " ",
								order = newOrder()
							},
							unknownAppearance = {
								type = "toggle",
								name = L["Unknown appearance"],
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
								name = L["Unknown source"],
								set = function(info, val)
									WQA.db.profile.options.reward.gear.unknownSource = val
								end,
								descStyle = "inline",
								get = function()
									return WQA.db.profile.options.reward.gear.unknownSource
								end,
								order = newOrder()
							},
							azeriteTraits = {
								name = L["Azerite Traits"],
								desc = L["Comma separated spellIDs"],
								type = "input",
								order = newOrder(),
								set = function(info, val)
									WQA.db.profile.options.reward.gear.azeriteTraits = val
								end,
								get = function()
									return WQA.db.profile.options.reward.gear.azeriteTraits
								end
							},
							conduit = {
								name = L["Conduit"],
								desc = L["Track conduit"],
								type = "toggle",
								order = newOrder(),
								set = function(info, val)
									WQA.db.profile.options.reward.gear.conduit = val
								end,
								get = function()
									return WQA.db.profile.options.reward.gear.conduit
								end
							}
						}
					}
				}
			},
			custom = {
				order = newOrder(),
				type = "group",
				childGroups = "tree",
				name = L["Custom"],
				args = {
					quest = {
						order = newOrder(),
						name = L["World Quest"],
						type = "group",
						inline = true,
						args = {
							-- Add WQ
							header1 = {
								type = "header",
								name = L["Add a Quest you want to track"],
								order = newOrder()
							},
							addWQ = {
								name = L["QuestID"],
								-- desc = "To add a worldquest, enter a unique name for the worldquest, and click Okay",
								type = "input",
								order = newOrder(),
								width = .6,
								set = function(info, val)
									WQA.data.custom.wqID = val
								end,
								get = function()
									return tostring(WQA.data.custom.wqID)
								end
							},
							questType = {
								name = L["Quest type"],
								order = newOrder(),
								desc =
								L["IsActive:\nUse this as a last resort. Works for some daily quests.\n\nIsQuestFlaggedCompleted:\nUse this for quests, that are always active.\n\nQuest Pin:\nUse this, if the daily is marked with a quest pin on the world map.\n\nWorld Quest:\nUse this, if you want to track a world quest."],
								type = "select",
								values = {
									WORLD_QUEST = L["World Quest"],
									QUEST_PIN = L["Quest Pin"],
									QUEST_FLAG = L["IsQuestFlaggedCompleted"],
									IsActive = L["IsActive"]
								},
								set = function(info, val)
									WQA.data.custom.questType = val
								end,
								get = function()
									return WQA.data.custom.questType
								end
							},
							mapID = {
								name = L["mapID"],
								desc =
								L["Quest pin tracking needs a mapID.\nSee https://wow.gamepedia.com/UiMapID for help."],
								type = "input",
								width = .5,
								order = newOrder(),
								set = function(info, val)
									WQA.data.custom.mapID = val
								end,
								get = function()
									return tostring(WQA.data.custom.mapID or "")
								end
							},
							--[[
							rewardID = {
							name = L["Reward (optional)"],
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
							name = L["Reward type"],
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
								name = L["Add"],
								width = .3,
								func = function()
									WQA:CreateCustomQuest()
								end,
								disabled = function()
									local mapId = self.data.custom.mapID
									local questID = self.data.custom.wqID
									return (questID == nil or questID == "") or
										(self.data.custom.questType == "QUEST_PIN" and (mapId == nil or mapId == ""))
								end
							},
							-- Configure
							header2 = {
								type = "header",
								name = L["Configure custom World Quests"],
								order = newOrder()
							}
						}
					},
					reward = {
						order = newOrder(),
						name = L["Reward"],
						type = "group",
						inline = true,
						args = {
							-- Add item
							header1 = {
								type = "header",
								name = L["Add a World Quest Reward you want to track"],
								order = newOrder()
							},
							itemID = {
								name = L["itemID"],
								-- desc = "To add a worldquest, enter a unique name for the worldquest, and click Okay",
								type = "input",
								order = newOrder(),
								width = .6,
								set = function(info, val)
									WQA.data.custom.worldQuestReward = val
								end,
								get = function()
									return tostring(WQA.data.custom.worldQuestReward or 0)
								end
							},
							button = {
								order = newOrder(),
								type = "execute",
								name = L["Add"],
								width = .3,
								func = function()
									WQA:CreateCustomReward()
								end
							},
							-- Configure
							header2 = {
								type = "header",
								name = L["Configure custom World Quest Rewards"],
								order = newOrder()
							}
						}
					},
					mission = {
						order = newOrder(),
						name = L["Mission"],
						type = "group",
						inline = true,
						args = {
							-- Add WQ
							header1 = {
								type = "header",
								name = L["Add a Mission you want to track"],
								order = newOrder()
							},
							missionID = {
								name = L["MissionID"],
								type = "input",
								order = newOrder(),
								width = .6,
								set = function(info, val)
									WQA.data.custom.mission.missionID = val
								end,
								get = function()
									return tostring(WQA.data.custom.mission.missionID)
								end
							},
							rewardID = {
								name = L["Reward (optional)"],
								desc = L["Enter an achievementID or itemID"],
								type = "input",
								width = .6,
								order = newOrder(),
								set = function(info, val)
									WQA.data.custom.mission.rewardID = val
								end,
								get = function()
									return tostring(WQA.data.custom.mission.rewardID)
								end
							},
							rewardType = {
								name = L["Reward type"],
								order = newOrder(),
								type = "select",
								values = {
									item = L["Item"],
									achievement = L["Achievement"],
									none = L["none"]
								},
								width = .6,
								set = function(info, val)
									WQA.data.custom.mission.rewardType = val
								end,
								get = function()
									return WQA.data.custom.mission.rewardType
								end
							},
							button = {
								order = newOrder(),
								type = "execute",
								name = L["Add"],
								width = .3,
								func = function()
									WQA:CreateCustomMission()
								end
							},
							-- Configure
							header2 = {
								type = "header",
								name = L["Configure custom Missions"],
								order = newOrder()
							}
						}
					},
					missionReward = {
						order = newOrder(),
						name = L["Reward"],
						type = "group",
						inline = true,
						args = {
							-- Add item
							header1 = {
								type = "header",
								name = L["Add a Mission Reward you want to track"],
								order = newOrder()
							},
							itemID = {
								name = L["itemID"],
								type = "input",
								order = newOrder(),
								width = .6,
								set = function(info, val)
									WQA.data.custom.missionReward = val
								end,
								get = function()
									return tostring(WQA.data.custom.missionReward or 0)
								end
							},
							button = {
								order = newOrder(),
								type = "execute",
								name = L["Add"],
								width = .3,
								func = function()
									WQA:CreateCustomMissionReward()
								end
							},
							-- Configure
							header2 = {
								type = "header",
								name = L["Configure custom Mission Rewards"],
								order = newOrder()
							}
						}
					}
				}
			},
			options = {
				order = newOrder(),
				type = "group",
				name = L["Options"],
				args = {
					AutoShow = {
						type = "toggle",
						name = L["AutoShow"],
						width = "double",
						set = function(info, val)
							WQA.db.profile.options.AutoShow = val
						end,
						descStyle = "inline",
						get = function()
							return WQA.db.profile.options.AutoShow
						end,
						order = newOrder()
					},
					desc1 = {
						type = "description",
						fontSize = "medium",
						name = L["Select where WQA is allowed to post"],
						order = newOrder()
					},
					chat = {
						type = "toggle",
						name = L["Chat"],
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
						name = L["PopUp"],
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
					popupRememberPosition = {
						type = "toggle",
						name = L["Remember PopUp position"],
						width = "double",
						set = function(info, val)
							WQA.db.profile.options.popupRememberPosition = val
						end,
						descStyle = "inline",
						get = function()
							return WQA.db.profile.options.popupRememberPosition
						end,
						order = newOrder()
					},
					sortByName = {
						type = "toggle",
						name = L["Sort quests by name"],
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
						name = L["Sort quests by zone name"],
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
						name = L["Show expansion in chat"],
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
						name = L["Show zone in chat"],
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
						name = L["Show time left in chat"],
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
						name = L["Show expansion in popup"],
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
						name = L["Show zone in popup"],
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
						name = L["Show time left in popup"],
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
						name = L["Delay on login in s"],
						type = "input",
						order = newOrder(),
						width = "double",
						set = function(info, val)
							WQA.db.profile.options.delay = tonumber(val)
						end,
						get = function()
							return tostring(WQA.db.profile.options.delay)
						end
					},
					delayCombat = {
						name = L["Delay output while in combat"],
						type = "toggle",
						order = newOrder(),
						width = "double",
						set = function(info, val)
							WQA.db.profile.options.delayCombat = val
						end,
						get = function()
							return WQA.db.profile.options.delayCombat
						end
					},
					WorldQuestTracker = {
						type = "toggle",
						name = L["Use World Quest Tracker"],
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
					esc = {
						type = "toggle",
						name = L["Close PopUp with ESC"],
						desc = L["Requires a reload"],
						width = "double",
						set = function(info, val)
							WQA.db.profile.options.esc = val
						end,
						descStyle = "inline",
						get = function()
							return WQA.db.profile.options.esc
						end,
						order = newOrder()
					},
					LibDBIcon = {
						type = "toggle",
						name = L["Show Minimap Icon"],
						width = "double",
						set = function(info, val)
							WQA.db.profile.options.LibDBIcon.hide = not val
							WQA:UpdateMinimapIcon()
						end,
						descStyle = "inline",
						get = function()
							return not WQA.db.profile.options.LibDBIcon.hide
						end,
						order = newOrder()
					}
				}
			}
		}
	}

	-- General
	-- worldQuestType
	local args = self.options.args.reward.args.general.args
	args.header1 = {
		type = "header",
		name = L["World Quest Type"],
		order = newOrder()
	}
	for k, v in pairs(worldQuestType) do
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
				args = {}
			}
			self:CreateGroup(self.options.args.general.args[v.name].args, v, "achievements")
			self:CreateGroup(self.options.args.general.args[v.name].args, v, "mounts")
			self:CreateGroup(self.options.args.general.args[v.name].args, v, "pets")
			self:CreateGroup(self.options.args.general.args[v.name].args, v, "toys")
		end
	end

	for i = 6, 11 do
		self.options.args.reward.args[self.ExpansionList[i]] = {
			order = newOrder(),
			name = self.ExpansionList[i],
			type = "group",
			args = {}
		}

		-- World Quests
		if i > 6 then
			self.options.args.reward.args[self.ExpansionList[i]].args[self.ExpansionList[i] .. "WorldQuests"] = {
				order = newOrder(),
				name = L["World Quests"],
				type = "group",
				args = {}
			}
			local args = self.options.args.reward.args[self.ExpansionList[i]].args
				[self.ExpansionList[i] .. "WorldQuests"].args

			-- Zones
			if WQA.ZoneIDList[i] then
				args.zone = {
					order = newOrder(),
					name = L["Zones"],
					type = "group",
					args = {},
					inline = false
				}
				for k, v in pairs(WQA.ZoneIDList[i]) do
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
					name = L["Currencies"],
					type = "group",
					args = {}
				}
				for k, v in pairs(CurrencyIDList[i]) do
					if not (type(v) == "table" and v.faction ~= self.faction) then
						if type(v) == "table" then
							v = v.id
						end
						args.currency.args[GetCurrencyInfo(v).name] = {
							type = "toggle",
							name = GetCurrencyInfo(v).name,
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
					name = L["Reputation"],
					type = "group",
					args = {}
				}
				for _, factionGroup in pairs {
					"Neutral",
					UnitFactionGroup("player")
				} do
					if FactionIDList[i][factionGroup] then
						for _, factionID in pairs(FactionIDList[i][factionGroup]) do
							local factionName = C_Reputation.GetFactionDataByID(factionID).name

							args.reputation.args[factionName] = {
								type = "toggle",
								name = factionName,
								set = function(info, val)
									WQA.db.profile.options.reward.reputation[factionID] = val
								end,
								descStyle = "inline",
								get = function()
									return WQA.db.profile.options.reward.reputation[factionID]
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
					name = L["Emissary Quests"],
					type = "group",
					args = {}
				}
				for k, v in pairs(self.EmissaryQuestIDList[i]) do
					if not (type(v) == "table" and v.faction ~= self.faction) then
						if type(v) == "table" then
							v = v.id
						end
						args.emissary.args[GetTitleForQuestID(v) or tostring(v)] = {
							type = "toggle",
							name = GetTitleForQuestID(v) or tostring(v),
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
					name = L["Professions"],
					type = "group",
					args = {}
				}

				-- Recipes
				args.profession.args["Recipes"] = {
					type = "toggle",
					name = L["Recipes"],
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
				for _, tradeskillLineIndex in pairs({ GetProfessions() }) do
					local professionName, _, _, _, _, _, tradeskillLineID = GetProfessionInfo(tradeskillLineIndex)
					args.profession.args[tradeskillLineID .. "Header"] = {
						type = "header",
						name = professionName,
						order = newOrder()
					}
					args.profession.args[tradeskillLineID .. "Skillup"] = {
						type = "toggle",
						name = L["Skillup"],
						desc = L["Track every World Quest until skill level is maxed out"],
						set = function(info, val)
							WQA.db.profile.options.reward[i].profession[tradeskillLineID].skillup = val
						end,
						get = function()
							return WQA.db.profile.options.reward[i].profession[tradeskillLineID].skillup
						end,
						order = newOrder()
					}
					args.profession.args[tradeskillLineID .. "MaxLevel"] = {
						type = "toggle",
						name = L["Skill level is maxed out*"],
						desc = L["Setting is per character"],
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
				-- for k,v in pairs(CraftingReagentIDList[i] or {}) do
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
				-- end
			end
		end

		-- Mission Table
		self.options.args.reward.args[self.ExpansionList[i]].args[self.ExpansionList[i] .. "MissionTable"] = {
			order = newOrder(),
			name = (i ~= 6 and L["Mission Table"] or L["Mission Table & Shipyard"]),
			type = "group",
			args = {}
		}
		local args = self.options.args.reward.args[self.ExpansionList[i]].args[self.ExpansionList[i] .. "MissionTable"]
			.args

		-- Currencies
		if CurrencyIDList[i] then
			args.currency = {
				order = newOrder(),
				name = L["Currencies"],
				type = "group",
				args = {}
			}
			if i == 8 then
				args.currency.args = {
					gold = {
						type = "toggle",
						name = L["Gold"],
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
						name = L["minimum Gold"],
						type = "input",
						order = newOrder(),
						set = function(info, val)
							WQA.db.profile.options.missionTable.reward.goldMin = tonumber(val)
						end,
						get = function()
							return tostring(WQA.db.profile.options.missionTable.reward.goldMin)
						end
					}
				}
			end

			for k, v in pairs(CurrencyIDList[i]) do
				if not (type(v) == "table" and v.faction ~= self.faction) then
					if type(v) == "table" then
						v = v.id
					end
					args.currency.args[GetCurrencyInfo(v).name] = {
						type = "toggle",
						name = GetCurrencyInfo(v).name,
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
				name = L["Reputation"],
				type = "group",
				args = {}
			}
			for _, factionGroup in pairs { "Neutral", UnitFactionGroup("player") } do
				if FactionIDList[i][factionGroup] then
					for _, factionID in pairs(FactionIDList[i][factionGroup]) do
						local factionName = C_Reputation.GetFactionDataByID(factionID).name

						args.reputation.args[factionName] = {
							type = "toggle",
							name = factionName,
							set = function(info, val)
								WQA.db.profile.options.missionTable.reward.reputation[factionID] = val
							end,
							descStyle = "inline",
							get = function()
								return WQA.db.profile.options.missionTable.reward.reputation[factionID]
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

function WQA:ToggleSet(info, val, ...)
	-- print(info[#info-2],info[#info-1],info[#info])
	local expansion = info[#info - 2]
	local category = info[#info - 1]
	local option = info[#info]
	WQA.db.profile[category][tonumber(option)] = val
	if val == "exclusive" then
		local name, server = UnitFullName("player")
		WQA.db.profile[category].exclusive[tonumber(option)] = name .. "-" .. server
	elseif WQA.db.profile[category].exclusive[tonumber(option)] then
		WQA.db.profile[category].exclusive[tonumber(option)] = nil
	end
	-- if not WQA.db.profile[expansion] then WQA.db.profile[expansion] = {} end
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
			args = {}
		}
		local args = options[groupName].args

		args["completed"] = {
			type = "header",
			name = L["completed"],
			order = newOrder(),
			hidden = true
		}
		args["notCompleted"] = {
			type = "header",
			name = L["notCompleted"],
			order = newOrder(),
			hidden = true
		}

		local expansion = data.name
		local data = data[groupName]
		for _, object in pairs(data) do
			local id = object.id or object.spellID or object.creatureID or object.itemID
			local idString = tostring(id)
			args[idString .. "Name"] = {
				type = "description",
				name = idString,
				fontSize = "medium",
				order = newOrder(),
				width = 1.5
			}
			args[idString] = {
				type = "select",
				values = {
					disabled = L["tracking_disabled"],
					default = L["tracking_default"],
					always = L["tracking_always"],
					wasEarnedByMe = L["tracking_wasEarnedByMe"],
					exclusive = L["tracking_exclusive"]
				},
				width = 1.4,
				-- type = "toggle",
				name = "", -- idString,
				handler = WQA,
				set = "ToggleSet",
				-- descStyle = "inline",
				get = function(info)
					local value = WQA.db.profile[groupName][id]
					if value == "exclusive" then
						local name, server = UnitFullName("player")
						name = name .. "-" .. server
						if WQA.db.profile[info[#info - 1]].exclusive[id] ~= name then
							info.option.values.other = string.format(L["tracking_other"],
								WQA.db.profile[info[#info - 1]].exclusive[id])
							return "other"
						end
					end
					return value
				end,
				order = newOrder()
			}
			if object.itemID then
				if not select(2, GetItemInfo(object.itemID)) then
					self:CancelTimer(optionsTimer)
					optionsTimer =
						self:ScheduleTimer(
							function()
								LibStub("AceConfigRegistry-3.0"):NotifyChange("WQAchievements")
							end,
							2
						)
				end
				args[idString .. "Name"].name = select(2, GetItemInfo(object.itemID)) or object.name
			else
				args[idString .. "Name"].name = GetAchievementLink(object.id) or object.name
			end
		end
	end
end

function WQA:CreateCustomQuest()
	if not self.db.global.custom then
		self.db.global.custom = {}
	end
	if not self.db.global.custom.worldQuest then
		self.db.global.custom.worldQuest = {}
	end
	self.db.global.custom.worldQuest[tonumber(self.data.custom.wqID)] = {
		questType = self.data.custom.questType,
		mapID = self.data.custom.mapID
	} -- {rewardID = tonumber(self.data.custom.rewardID), rewardType = self.data.custom.rewardType}
	self:UpdateCustomQuests()
end

function WQA:UpdateCustomQuests()
	local data = self.db.global.custom.worldQuest
	if type(data) ~= "table" then
		return false
	end
	local args = self.options.args.custom.args.quest.args
	for id, object in pairs(data) do
		args[tostring(id)] = {
			type = "toggle",
			name = GetQuestLink(id) or GetTitleForQuestID(id) or tostring(id),
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

		args[id .. "questType"] = {
			name = L["Quest type"],
			order = newOrder(),
			desc =
			L["IsActive:\nUse this as a last resort. Works for some daily quests.\n\nIsQuestFlaggedCompleted:\nUse this for quests, that are always active.\n\nQuest Pin:\nUse this, if the daily is marked with a quest pin on the world map.\n\nWorld Quest:\nUse this, if you want to track a world quest."],
			type = "select",
			values = {
				WORLD_QUEST = L["World Quest"],
				QUEST_PIN = L["Quest Pin"],
				QUEST_FLAG = L["IsQuestFlaggedCompleted"],
				IsActive = L["IsActive"]
			},
			width = .8,
			set = function(info, val)
				self.db.global.custom.worldQuest[id].questType = val
			end,
			get = function()
				return tostring(self.db.global.custom.worldQuest[id].questType or "")
			end
		}
		args[id .. "mapID"] = {
			name = L["mapID"],
			desc = L["Quest pin tracking needs a mapID.\nSee https://wow.gamepedia.com/UiMapID for help."],
			type = "input",
			width = .4,
			order = newOrder(),
			set = function(info, val)
				self.db.global.custom.worldQuest[id].mapID = val
			end,
			get = function()
				return tostring(self.db.global.custom.worldQuest[id].mapID or "")
			end
		}

		--[[
		args[id.."Reward"] = {
		name = L["Reward (optional)"],
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
		name = L["Reward type"],
		order = newOrder(),
		type = "select",
		values = {item = "Item", achievement = "Achievement", none = "none"},
		width = .6,
		set = function(info,val)
		self.db.global.custom.worldQuest[id].rewardType = val
		end,
		get = function() return self.db.global.custom.worldQuest[id].rewardType or nil end
		}--]]
		args[id .. "Delete"] = {
			order = newOrder(),
			type = "execute",
			name = L["Delete"],
			width = .5,
			func = function()
				args[tostring(id)] = nil
				args[id .. "Reward"] = nil
				args[id .. "RewardType"] = nil
				args[id .. "Delete"] = nil
				args[id .. "space"] = nil
				self.db.global.custom.worldQuest[id] = nil
				self:UpdateCustomQuests()
				GameTooltip:Hide()
			end
		}
		args[id .. "space"] = {
			name = " ",
			width = .25,
			order = newOrder(),
			type = "description"
		}
	end
end

function WQA:CreateCustomReward()
	if not self.db.global.custom then
		self.db.global.custom = {}
	end
	if not self.db.global.custom.worldQuestReward then
		self.db.global.custom.worldQuestReward = {}
	end
	self.db.global.custom.worldQuestReward[tonumber(self.data.custom.worldQuestReward)] = true
	self:UpdateCustomRewards()
end

function WQA:UpdateCustomRewards()
	local data = self.db.global.custom.worldQuestReward
	if type(data) ~= "table" then
		return false
	end
	local args = self.options.args.custom.args.reward.args
	for id, _ in pairs(data) do
		local _, itemLink = GetItemInfo(id)
		args[tostring(id)] = {
			type = "toggle",
			name = itemLink or tostring(id),
			--width = "double",
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
		args[id .. "Delete"] = {
			order = newOrder(),
			type = "execute",
			name = L["Delete"],
			width = .5,
			func = function()
				args[tostring(id)] = nil
				args[id .. "Delete"] = nil
				args[id .. "space"] = nil
				self.db.global.custom.worldQuestReward[id] = nil
				self:UpdateCustomRewards()
				GameTooltip:Hide()
			end
		}
		args[id .. "space"] = {
			name = " ",
			width = 1,
			order = newOrder(),
			type = "description"
		}
	end
end

function WQA:CreateCustomMission()
	if not self.db.global.custom then
		self.db.global.custom = {}
	end
	if not self.db.global.custom.mission then
		self.db.global.custom.mission = {}
	end
	self.db.global.custom.mission[tonumber(self.data.custom.mission.missionID)] = {
		rewardID = tonumber(self.data.custom.mission.rewardID),
		rewardType = self.data.custom.mission.rewardType
	}
	self:UpdateCustomMissions()
end

function WQA:UpdateCustomMissions()
	local data = self.db.global.custom.mission
	if type(data) ~= "table" then
		return false
	end
	local args = self.options.args.custom.args.mission.args
	for id, object in pairs(data) do
		args[tostring(id)] = {
			type = "toggle",
			name = C_Garrison.GetMissionLink(id) or tostring(id),
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
		args[id .. "Reward"] = {
			name = L["Reward (optional)"],
			desc = L["Enter an achievementID or itemID"],
			type = "input",
			width = .6,
			order = newOrder(),
			set = function(info, val)
				self.db.global.custom.mission[id].rewardID = tonumber(val)
			end,
			get = function()
				return tostring(self.db.global.custom.mission[id].rewardID or "")
			end
		}
		args[id .. "RewardType"] = {
			name = L["Reward type"],
			order = newOrder(),
			type = "select",
			values = { item = "Item", achievement = "Achievement", none = "none" },
			width = .6,
			set = function(info, val)
				self.db.global.custom.mission[id].rewardType = val
			end,
			get = function()
				return self.db.global.custom.mission[id].rewardType or nil
			end
		}
		args[id .. "Delete"] = {
			order = newOrder(),
			type = "execute",
			name = L["Delete"],
			width = .5,
			func = function()
				args[tostring(id)] = nil
				args[id .. "Reward"] = nil
				args[id .. "RewardType"] = nil
				args[id .. "Delete"] = nil
				args[id .. "space"] = nil
				self.db.global.custom.mission[id] = nil
				self:UpdateCustomMissions()
				GameTooltip:Hide()
			end
		}
		args[id .. "space"] = {
			name = " ",
			width = .25,
			order = newOrder(),
			type = "description"
		}
	end
end

function WQA:CreateCustomMissionReward()
	if not self.db.global.custom then
		self.db.global.custom = {}
	end
	if not self.db.global.custom.missionReward then
		self.db.global.custom.missionReward = {}
	end
	self.db.global.custom.missionReward[tonumber(self.data.custom.missionReward)] = true
	self:UpdateCustomMissionRewards()
end

function WQA:UpdateCustomMissionRewards()
	local data = self.db.global.custom.missionReward
	if type(data) ~= "table" then
		return false
	end
	local args = self.options.args.custom.args.missionReward.args
	for id, _ in pairs(data) do
		local _, itemLink = GetItemInfo(id)
		args[tostring(id)] = {
			type = "toggle",
			name = itemLink or tostring(id),
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
		args[id .. "Delete"] = {
			order = newOrder(),
			type = "execute",
			name = L["Delete"],
			width = .5,
			func = function()
				args[tostring(id)] = nil
				args[id .. "Delete"] = nil
				args[id .. "space"] = nil
				self.db.global.custom.missionReward[id] = nil
				self:UpdateCustomMissionRewards()
				GameTooltip:Hide()
			end
		}
		args[id .. "space"] = {
			name = " ",
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
	for k, v in pairs(WQA.options.args.general.args) do
		for kk, vv in pairs(v.args) do
			local t = {}
			for kkk, vvv in pairs(vv.args) do
				local completed = false
				local id = select(3, string.find(kkk, "(%d*)Name"))
				if id then
					id = tonumber(id)
					if kk == "achievements" then
						completed = select(4, GetAchievementInfo(id))
					elseif kk == "mounts" then
						for _, mountID in pairs(C_MountJournal.GetMountIDs()) do
							local _, spellID, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(
								mountID)
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
					table.insert(
						t,
						{
							key = kkk,
							name = select(3, string.find(vvv.name, "%[(.+)%]")) or vvv.name,
							completed = completed,
							id = tostring(id)
						}
					)
				end
			end
			table.sort(
				t,
				function(a, b)
					return a.name < b.name
				end
			)
			local completedHeader = false
			for order, object in pairs(t) do
				if not object.completed then
					vv.args["notCompleted"].order = 0
					vv.args["notCompleted"].hidden = false
				end
				if object.completed then
					order = order + 100
					if not completedHeader then
						vv.args["completed"].order = order * 2 - .5
						vv.args["completed"].hidden = false
						completedHeader = true
					end
				end
				vv.args[object.key].order = order * 2
				vv.args[object.id].order = order * 2 + 1
			end
		end
	end
end
