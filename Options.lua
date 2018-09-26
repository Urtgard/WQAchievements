local WQA = WQAchievements
local L = WQA.L

WQA.ExpansionList = {
	[1] = "Legion",
	[2] = "Battle for Azeroth",
}

local ExpansionIDList = {
	[1] = 6, -- Legion
	[2] = 7, -- Battle for Azeroth
}

local CurrencyIDList = {
	[1] = {
		1220, -- Order Resources
		1226, -- Nethershard
		1342, -- Legionfall War Supplies
		1533, -- Wakening Essence
	},
	[2] = {
		1553, -- Azerite
		1560, -- War Ressource
	}
}

local CraftingReagentIDList = {
	[1] = {
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
	[2] = {
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

WQA.ZoneIDList = {
	[1] = {
		619,
		630,
		641,
		650,
		625,
		680,
		634,
		646,
		790,
		885,
		830,
		882,
	},
	[2] = {
		875,
		876,
		862,
		863,
		864,
		895,
		942,
		896,
	}
}

local FactionIDList = {
	[1] = {
		Neutral = {
			2165,
			2170,
		}
	},
	[2] = {
		Neutral = {
			2164, -- Champions of Azeroth
			2163, -- Tortollan Seekers
		},
		Alliance = {
			2160, -- Proudmoore Admiralty
			2161, -- Order of Embers
			2162, -- Storm's Wake
			2159, -- 7th Legion
		},
		Horde = {
			2103, -- Zandalari Empire
			2156, -- Talanji's Expedition
			2158, -- Voldunai
			2157, -- The Honorbound
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
	WQA.options = {
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
				childGroups = "tree",
				name = "Rewards",
				args = {
					gear = {
						order = newOrder(),
						name = "Gear",
						type = "group",
						inline = true,
						args = {
							itemLevelUpgrade = {
								type = "toggle",
								name = "ItemLevel Upgrade",
								--width = "double",
								set = function(info, val)
									WQA.db.char.options.reward.gear.itemLevelUpgrade = val
								end,
								descStyle = "inline",
							    get = function()
							    	return WQA.db.char.options.reward.gear.itemLevelUpgrade
						    	end,
							    order = newOrder()
							},
							AzeriteArmorCache = {
								type = "toggle",
								name = "Azerite Armor Cache",
								--width = "double",
								set = function(info, val)
									WQA.db.char.options.reward.gear.AzeriteArmorCache = val
								end,
								descStyle = "inline",
							    get = function()
							    	return WQA.db.char.options.reward.gear.AzeriteArmorCache
						    	end,
							    order = newOrder()
							},
							itemLevelUpgradeMin = {
								name = "minimum ItemLevel Upgrade",
								type = "input",
								order = newOrder(),
								--width = .6,
								set = function(info,val)
						   			WQA.db.char.options.reward.gear.itemLevelUpgradeMin = tonumber(val)
						   		end,
						    	get = function() return tostring(WQA.db.char.options.reward.gear.itemLevelUpgradeMin)  end
							},
							desc1 = { type = "description", fontSize = "small", name = " ", order = newOrder(), },
							PawnUpgrade = {
								type = "toggle",
								name = "% Upgrade (Pawn)",
								--width = "double",
								set = function(info, val)
									WQA.db.char.options.reward.gear.PawnUpgrade = val
								end,
								descStyle = "inline",
							    get = function()
							    	return WQA.db.char.options.reward.gear.PawnUpgrade
						    	end,
							    order = newOrder()
							},
							PawnUpgradeMin = {
								name = "minimum % Upgrade",
								type = "input",
								order = newOrder(),
								--width = .6,
								set = function(info,val)
						   			WQA.db.char.options.reward.gear.PawnUpgradeMin = tonumber(val)
						   		end,
						    	get = function() return tostring(WQA.db.char.options.reward.gear.PawnUpgradeMin)  end
							},
							desc2 = { type = "description", fontSize = "small", name = " ", order = newOrder(), },
							unknownAppearance = {
								type = "toggle",
								name = "Unknown appearance",
								--width = "double",
								set = function(info, val)
									WQA.db.char.options.reward.gear.unknownAppearance = val
								end,
								descStyle = "inline",
							    get = function()
							    	return WQA.db.char.options.reward.gear.unknownAppearance
						    	end,
							    order = newOrder()
							},
							unknownSource = {
								type = "toggle",
								name = "Unknown source",
								--width = "double",
								set = function(info, val)
									WQA.db.char.options.reward.gear.unknownSource = val
								end,
								descStyle = "inline",
							    get = function()
							    	return WQA.db.char.options.reward.gear.unknownSource
						    	end,
							    order = newOrder()
							},
						}
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
							header1 = { type = "header", name = "Add a World Quest you want to track", order = newOrder(), },
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
						   			WQA.data.customReward = val
						   		end,
						    	get = function() return tostring(WQA.data.customReward or 0)  end
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
						set = function(info, val)
							WQA.db.char.options.PopUp = val
						end,
						descStyle = "inline",
					    get = function()
					    	return WQA.db.char.options.PopUp
				    	end,
					    order = newOrder()
					},
					sortByName = {
						type = "toggle",
						name = "Sort quests by name",
						width = "double",
						set = function(info, val)
							WQA.db.char.options.sortByName = val
						end,
						descStyle = "inline",
					    get = function()
					    	return WQA.db.char.options.sortByName
				    	end,
					    order = newOrder()
					},
					sortByZoneName = {
						type = "toggle",
						name = "Sort quests by zone name",
						width = "double",
						set = function(info, val)
							WQA.db.char.options.sortByZoneName = val
						end,
						descStyle = "inline",
					    get = function()
					    	return WQA.db.char.options.sortByZoneName
				    	end,
					    order = newOrder()
					},
					sortByExpansion = {
						type = "toggle",
						name = "Sort quests by expansion",
						width = "double",
						set = function(info, val)
							WQA.db.char.options.sortByExpansion = val
						end,
						descStyle = "inline",
					    get = function()
					    	return WQA.db.char.options.sortByExpansion
				    	end,
					    order = newOrder()
					},
					chatShowExpansion = {
						type = "toggle",
						name = "Show expansion in chat",
						width = "double",
						set = function(info, val)
							WQA.db.char.options.chatShowExpansion = val
						end,
						descStyle = "inline",
					    get = function()
					    	return WQA.db.char.options.chatShowExpansion
				    	end,
					    order = newOrder()
					},
					chatShowZone = {
						type = "toggle",
						name = "Show zone in chat",
						width = "double",
						set = function(info, val)
							WQA.db.char.options.chatShowZone = val
						end,
						descStyle = "inline",
					    get = function()
					    	return WQA.db.char.options.chatShowZone
				    	end,
					    order = newOrder()
					},
					popupShowExpansion = {
						type = "toggle",
						name = "Show expansion in popup",
						width = "double",
						set = function(info, val)
							WQA.db.char.options.popupShowExpansion = val
						end,
						descStyle = "inline",
					    get = function()
					    	return WQA.db.char.options.popupShowExpansion
				    	end,
					    order = newOrder()
					},
					popupShowZone = {
						type = "toggle",
						name = "Show zone in popup",
						width = "double",
						set = function(info, val)
							WQA.db.char.options.popupShowZone = val
						end,
						descStyle = "inline",
					    get = function()
					    	return WQA.db.char.options.popupShowZone
				    	end,
					    order = newOrder()
					},
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

	for i=1,#self.ExpansionList do
		self.options.args.reward.args[self.ExpansionList[i]] = {
			order = newOrder(),
			name = self.ExpansionList[i],
			type = "group",
			inline = true,
			args = {}
		}
		-- Zones
		if WQA.ZoneIDList[i] then
			self.options.args.reward.args[self.ExpansionList[i]].args.zone = {
				order = newOrder(),
				name = "Zones",
				type = "group",
				args = {}
			}
			for k,v in pairs(WQA.ZoneIDList[i]) do
				local name = C_Map.GetMapInfo(v).name
				self.options.args.reward.args[self.ExpansionList[i]].args.zone.args[name] = {
					type = "toggle",
					name = name,
					set = function(info, val)
						WQA.db.char.options.zone[v] = val
					end,
					descStyle = "inline",
				    get = function()
				    	return WQA.db.char.options.zone[v] or false
			    	end,
				    order = newOrder()
				}
			end
		end

		-- Currencies
		if CurrencyIDList[i] then
			self.options.args.reward.args[self.ExpansionList[i]].args.currency = {
				order = newOrder(),
				name = "Currencies",
				type = "group",
				args = {}
			}
			for k,v in pairs(CurrencyIDList[i]) do
				self.options.args.reward.args[self.ExpansionList[i]].args.currency.args[GetCurrencyInfo(v)] = {
					type = "toggle",
					name = GetCurrencyInfo(v),
					set = function(info, val)
						WQA.db.char.options.reward.currency[v] = val
					end,
					descStyle = "inline",
				    get = function()
				    	return WQA.db.char.options.reward.currency[v]
			    	end,
				    order = newOrder()
				}
			end
		end

		-- Reputation
		if FactionIDList[i] then
			self.options.args.reward.args[self.ExpansionList[i]].args.reputation = {
				order = newOrder(),
				name = "Reputation",
				type = "group",
				args = {}
			}
			for _, factionGroup in pairs {"Neutral", UnitFactionGroup("player")} do
				if FactionIDList[i][factionGroup] then
					for k,v in pairs(FactionIDList[i][factionGroup]) do
						self.options.args.reward.args[self.ExpansionList[i]].args.reputation.args[GetFactionInfoByID(v)] = {
							type = "toggle",
							name = GetFactionInfoByID(v),
							set = function(info, val)
								WQA.db.char.options.reward.reputation[v] = val
							end,
							descStyle = "inline",
						    get = function()
						    	return WQA.db.char.options.reward.reputation[v]
					    	end,
						    order = newOrder()
						}
					end
				end
			end
		end

		-- Professions
		self.options.args.reward.args[self.ExpansionList[i]].args.profession = {
			order = newOrder(),
			name = "Professions",
			type = "group",
			args = {}
		}

			-- Recipes
			self.options.args.reward.args[self.ExpansionList[i]].args.profession.args["Recipes"] = {
				type = "toggle",
				name = "Recipes",
				set = function(info, val)
					WQA.db.char.options.reward.recipe[ExpansionIDList[i]] = val
				end,
				descStyle = "inline",
			    get = function()
			    	return WQA.db.char.options.reward.recipe[ExpansionIDList[i]]
		    	end,
			    order = newOrder()
			}

			-- Crafting Reagents
			--
			--for k,v in pairs(CraftingReagentIDList[i] or {}) do
			--	local name = GetItemInfo(v)
			--	if name then
			--		self.options.args.reward.args[ExpansionList[i]].args.profession.args[GetItemInfo(v)] = {
			--			type = "toggle",
			--			name = GetItemInfo(v),
			--			set = function(info, val)
			--				WQA.db.char.options.reward.craftingreagent[v] = val
			--			end,
			--			descStyle = "inline",
			--		    get = function()
			--		    	return WQA.db.char.options.reward.craftingreagent[v]
			--	    	end,
			--		    order = newOrder()
			--		}
			--	else
			--		--LibStub("AceConfigRegistry-3.0"):NotifyChange("WQAchievements")
			--	end
			--end
	end

	self:UpdateCustomQuests()
	self:UpdateCustomRewards()
end

function WQA:ToggleSet(info, val,...)
	--print(info[#info-2],info[#info-1],info[#info])
	local expansion = info[#info-2]
	local category = info[#info-1]
	local option = info[#info]
	WQA.db.char[category][option] = val
	--if not WQA.db.char[expansion] then WQA.db.char[expansion] = {} end
	--[[if not WQA.db.char[category] then WQA.db.char[category] = {} end
	if not val == true then
		WQA.db.char[category][option] = true
	else
		WQA.db.char[category][option] = nil
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
			    	return WQA.db.char[groupName][object.name]
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
 	local args = self.options.args.custom.args.quest.args
 	for id,object in pairs(data) do
		args[tostring(id)] = {
			type = "toggle",
			name = GetQuestLink(id) or tostring(id),
			width = "double",
			set = function(info, val)
				WQA.db.char.custom[id] = val
			end,
			descStyle = "inline",
		    get = function()
		    	return WQA.db.char.custom[id]
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
			width = .25,
			order = newOrder(),
			type = "description"
		}
	end
 end

 function WQA:CreateCustomReward()
 	if not self.db.global.customReward then self.db.global.customReward = {} end
 	self.db.global.customReward[tonumber(self.data.customReward)] = true
 	self:UpdateCustomRewards()
 end

function WQA:UpdateCustomRewards()
 	local data = self.db.global.customReward
 	if type(data) ~= "table" then return false end
 	local args = self.options.args.custom.args.reward.args
 	for id,_ in pairs(data) do
 		local _, itemLink = GetItemInfo(id)
		args[tostring(id)] = {
			type = "toggle",
			name = itemLink or tostring(id),
			width = "double",
			set = function(info, val)
				WQA.db.char.customReward[id] = val
			end,
			descStyle = "inline",
		    get = function()
		    	return WQA.db.char.customReward[id]
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
				self.db.global.customReward[id] = nil
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