local WQA = WQAchievements
local L = WQA.L

local GetTitleForQuestID = C_QuestLog.GetTitleForQuestID
local GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo
local GetItemInfo = C_Item.GetItemInfo

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
            2590, -- Council of Dornogal
            2688, -- Flame's Radiance
            2658, -- The K'aresh Trust
            2653, -- The Cartels of Undermine
            2673, -- Bilgewater Cartel
            2675, -- Blackwater Cartel
            2669, -- Darkfuse Solutions
            2677, -- Steamwheedle Cartel
            2671 -- Venture Company
        }
    },
    [12] = {
        Neutral = {
            -- Some of these may not be tied to WQ Reputations
            2696, -- Amani Tribe
            2712, -- Blood Knights
            2713, -- Farstriders
            2704, -- Hara'ti
            2711, -- Magisters
            2764, -- Preyseeker's Journey
            2714, -- Shades of the Row
            2710, -- Silvermoon Court
            2770, -- Slayer's Duellum
            2699 -- The Singularity
        }
    }
}

WQA.CurrencyIDList = {
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
        1553, -- Azerite
        1560, -- War Ressource
        {id = 1716, faction = "Horde"}, -- Honorbound Service Medal
        {id = 1717, faction = "Alliance"}, -- 7th Legion Service Medal
        1721, -- Prismatic Manapearl
        1166 -- Timewarped Badge
    },
    [9] = {
        1819, -- Medallion of Service (Kyrian covenant)
        1889 -- Adventure Campaign Progress
    },
    [10] = {
        2003, -- Dragon Isles Supplies
        2657, -- Mysterious Fragment
        2245 -- Flightstones
    },
    [11] = {
        3008, -- Valorstones
        3056, -- Kej
        2815, -- Resonance Crystals
        -- (PvP Currency may not be tracking currently)
        2123, -- Bloody Tokens
        1792, -- Honor
        1602 -- Conquest
    },
    [12] = {}
}

WQA.CraftingReagentIDList = {
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
        -- 2391, -- Rustbolt Resistance
        {id = 56119, faction = "Alliance"}, -- Waveblade Ankoan
        {id = 56120, faction = "Horde"} -- The Unshackled
    }
}

WQA.RacingPursesByExp = {
    [10] = {204359, 205226, 210549}, -- Dragonflight
    [11] = {227450, 199192} -- The War Within
}

WQA.RacingPursesList = {
    [227450] = "Sky Racer's Purse",
    [199192] = "Dragon Racer's Purse",
    [204359] = "Reach Racer's Purse",
    [205226] = "Cavern Racer's Purse",
    [210549] = "Dream Racer's Purse"
}

-- Shared order counter
local order = 0
local function newOrder(inc)
    if inc then
        order = order + inc
    end
    order = order + 1
    return order
end

-- Tracking modes (same values you already use in the DB)
local trackingModes = {
    disabled = L["tracking_disabled"],
    default = L["tracking_default"],
    always = L["tracking_always"],
    wasEarnedByMe = L["tracking_wasEarnedByMe"],
    exclusive = L["tracking_exclusive"]
}

local worldQuestType = {
    ["LE_QUEST_TAG_TYPE_PVP"] = Enum.QuestTagType.PvP,
    ["LE_QUEST_TAG_TYPE_PET_BATTLE"] = Enum.QuestTagType.PetBattle,
    ["LE_QUEST_TAG_TYPE_PROFESSION"] = Enum.QuestTagType.Profession,
    ["LE_QUEST_TAG_TYPE_DUNGEON"] = Enum.QuestTagType.Dungeon
}

local function AddCategoryMasterToggle(args, category, expansionKey)
    local dbPath = ("rewardCurrency"):find(category) and "reward" or category -- adjust if needed
    if expansionKey then
        dbPath = category
    end

    args["master_" .. category .. (expansionKey or "")] = {
        type = "select",
        name = L["Master Tracking"] or "Master Tracking",
        desc = L["master_tracking_desc"] or "Quickly set tracking for everything in this category",
        order = newOrder(-50), -- puts it at the very top
        width = 2.5,
        values = {
            [""] = L["Use Individual Settings"] or "Use Individual Settings",
            always = L["tracking_always"],
            disabled = L["tracking_disabled"],
            wasEarnedByMe = L["Only if not obtained"]
        },
        get = function()
            return WQA.db.profile.master[category .. (expansionKey or "")]
        end,
        set = function(_, value)
            if value == "" then
                value = nil
            end
            WQA.db.profile.master[category .. (expansionKey or "")] = value
            WQA:RefreshTracking()
        end
    }

    -- Nice header + spacing
    args["master_header_" .. category] = {
        type = "header",
        name = "",
        order = newOrder(-49)
    }
end

-- Helper to get current tracking value (including exclusive "other player" display)
local function GetTracking(info)
    local db = WQA.db.profile[info[#info - 2]][tonumber(info[#info - 1])]
    if db == "exclusive" then
        local name, realm = UnitFullName("player")
        local fullName = name and (name .. "-" .. realm) or "???"
        local exclusiveName = WQA.db.profile[info[#info - 2]].exclusive[tonumber(info[#info - 1])]
        if exclusiveName and exclusiveName ~= fullName then
            return "other"
        end
    end
    return db or "default"
end

-- Helper to set tracking value
local function SetTracking(info, value)
    local category = info[#info - 2]
    local id = tonumber(info[#info - 1])
    if value == "other" then
        value = "exclusive"
    end -- "other" is just display
    WQA.db.profile[category][id] = value
    if value == "exclusive" then
        local name, realm = UnitFullName("player")
        WQA.db.profile[category].exclusive[id] = name .. "-" .. realm
    end
end

-- Create the per-reward line (name + dropdown)
local function AddRewardLine(args, id, name, category, expansionKey)
    local safeName = name or "Unknown"

    if category == "rewardEmissary" then
        safeName = C_QuestLog.GetTitleForQuestID(id) or ("Emissary " .. id)
    elseif category == "rewardCurrency" then
        local info = C_CurrencyInfo.GetCurrencyInfo(id)
        safeName = info and info.name or ("Currency " .. id)
    elseif category == "rewardItem" then
        safeName = C_Item.GetItemNameByID(id) or ("Item " .. id)
    end

    args[tostring(id)] = {
        type = "toggle",
        name = safeName,
        --width = "full",
        order = newOrder(),
        get = function()
            if category == "rewardCurrency" then
                return WQA.db.profile.options.reward.currency[id] or false
            elseif category == "rewardEmissary" then
                return WQA.db.profile.options.emissary[id] or false
            elseif category == "rewardItem" then
                return WQA.db.profile.options.reward.craftingreagent[id] or false
            else
                return false
            end
        end,
        set = function(_, val)
            if category == "rewardCurrency" then
                WQA.db.profile.options.reward.currency[id] = val
            elseif category == "rewardEmissary" then
                WQA.db.profile.options.emissary[id] = val
            elseif category == "rewardItem" then
                WQA.db.profile.options.reward.craftingreagent[id] = val
            end
            WQA:RefreshTracking()
        end
    }
end

-- Generic group creator for mounts/pets/toys/achievements
function WQA:CreateCategoryGroup(parentArgs, expansionData, category)
    if not expansionData[category] or not next(expansionData[category]) then
        return
    end

    local groupKey = category
    parentArgs[groupKey] = {
        type = "group",
        name = L[category] or category,
        order = newOrder(10),
        args = {}
    }

    local args = parentArgs[groupKey].args

    -- Headers
    args["notCompleted"] = {
        type = "header",
        name = "|cffffea00" .. (L["notCompleted"] or "Not completed") .. "|r",
        order = 1,
        hidden = true
    }
    args["completed"] = {
        type = "header",
        name = "|cffffea00" .. (L["completed"] or "Completed") .. "|r",
        order = 1000,
        hidden = true
    }

    for _, object in pairs(expansionData[category]) do
        local id = object.id or object.spellID or object.creatureID or object.itemID
        local idString = tostring(id)

        -- Name entry
        args[idString .. "Name"] = {
            type = "description",
            name = idString, -- temporary
            fontSize = "medium",
            order = newOrder()
            --width = 1.8
        }

        -- Tracking dropdown
        args[idString] = {
            type = "select",
            name = "",
            values = {
                disabled = L["tracking_disabled"],
                default = L["tracking_default"],
                always = L["tracking_always"],
                wasEarnedByMe = L["tracking_wasEarnedByMe"],
                exclusive = L["tracking_exclusive"]
            },
            width = 1.3,
            order = newOrder(),
            get = function()
                local value = WQA.db.profile[category][id]
                if value == "exclusive" then
                    local name, realm = UnitFullName("player")
                    local fullName = name .. "-" .. realm
                    local exclusiveName = WQA.db.profile[category].exclusive[id]
                    if exclusiveName and exclusiveName ~= fullName then
                        return "other"
                    end
                end
                return value or "default"
            end,
            set = function(_, value)
                if value == "other" then
                    value = "exclusive"
                end
                WQA.db.profile[category][id] = value
                if value == "exclusive" then
                    local name, realm = UnitFullName("player")
                    WQA.db.profile[category].exclusive[id] = name .. "-" .. realm
                end
                WQA:RefreshTracking()
            end
        }

        -- Resolve real name + rarity color + NotifyChange
        local displayName = idString
        local color = "|cffffffff"

        if object.itemID then
            local _, link = GetItemInfo(object.itemID)
            if link then
                displayName = link
            else
                -- ORIGINAL FIX — force refresh when item loads
                if not select(2, GetItemInfo(object.itemID)) then
                    if not WQA.optionsTimer then
                        WQA.optionsTimer =
                            WQA:ScheduleTimer(
                            function()
                                LibStub("AceConfigRegistry-3.0"):NotifyChange("WQAchievements")
                                WQA.optionsTimer = nil
                            end,
                            2
                        )
                    end
                end
            end
        elseif object.id then
            local link = GetAchievementLink(object.id)
            displayName = link and link:match("|h%[(.-)%]|h") or object.name or idString
            color = "|cffffd700" -- yellow
        elseif object.spellID then
            local mountID = C_MountJournal.GetMountFromSpell(object.spellID)
            if mountID then
                local name = C_MountJournal.GetMountInfoByID(mountID)
                displayName = name or object.name or idString
                color = "|cffa335ee" -- epic purple
            end
        elseif object.creatureID then
            local _, _, _, _, rarity = C_PetJournal.GetPetInfoBySpeciesID(object.creatureID)
            local petName = C_PetJournal.GetPetInfoBySpeciesID(object.creatureID)
            displayName = petName or object.name or idString
            if rarity == 4 then
                color = "|cffa335ee"
            elseif rarity == 3 then
                color = "|cff0070dd"
            elseif rarity == 2 then
                color = "|cff1eff00"
            else
                color = "|cffffffff"
            end
        end

        args[idString .. "Name"].name = color .. displayName .. "|r"
    end
end

-- Rewards tab (currencies, crafting reagents, emissary, etc.)
function WQA:CreateRewardOptions()
    local args = self.options.args.reward.args

    args.general = {
        type = "group",
        name = L["General"],
        order = newOrder(10),
        args = {
            -- GOLD
            gold = {
                type = "toggle",
                name = L["Gold"],
                order = newOrder(),
                set = function(_, val)
                    WQA.db.profile.options.reward.general.gold = val
                end,
                get = function()
                    return WQA.db.profile.options.reward.general.gold
                end
            },
            goldMin = {
                name = L["minimum Gold"],
                type = "input",
                order = newOrder(),
                set = function(_, val)
                    WQA.db.profile.options.reward.general.goldMin = tonumber(val) or 0
                end,
                get = function()
                    return tostring(WQA.db.profile.options.reward.general.goldMin or 0)
                end
            },
            header1 = {type = "header", name = "Item Level Upgrade", order = newOrder()},
            -- GEAR

            itemLevelUpgrade = {
                type = "toggle",
                name = L["ItemLevel Upgrade"],
                order = newOrder(),
                set = function(_, val)
                    WQA.db.profile.options.reward.general.itemLevelUpgrade = val
                end,
                get = function()
                    return WQA.db.profile.options.reward.general.itemLevelUpgrade
                end
            },
            itemLevelUpgradeMin = {
                name = L["minimum ItemLevel Upgrade"],
                type = "input",
                order = newOrder(),
                set = function(_, val)
                    WQA.db.profile.options.reward.general.itemLevelUpgradeMin = tonumber(val) or 1
                end,
                get = function()
                    return tostring(WQA.db.profile.options.reward.general.itemLevelUpgradeMin or 1)
                end
            },
            PawnUpgrade = {
                type = "toggle",
                name = L["% Upgrade (Pawn)"],
                order = newOrder(),
                set = function(_, val)
                    WQA.db.profile.options.reward.general.PawnUpgrade = val
                end,
                get = function()
                    return WQA.db.profile.options.reward.general.PawnUpgrade
                end
            },
            StatWeightScore = {
                type = "toggle",
                name = L["% Upgrade (Stat Weight Score)"],
                order = newOrder(),
                set = function(_, val)
                    WQA.db.profile.options.reward.general.StatWeightScore = val
                end,
                get = function()
                    return WQA.db.profile.options.reward.general.StatWeightScore
                end
            },
            PercentUpgradeMin = {
                name = L["minimum % Upgrade"],
                type = "input",
                order = newOrder(),
                set = function(_, val)
                    WQA.db.profile.options.reward.general.PercentUpgradeMin = tonumber(val) or 1
                end,
                get = function()
                    return tostring(WQA.db.profile.options.reward.general.PercentUpgradeMin or 1)
                end
            },
            header2 = {type = "header", name = "Transmog", order = newOrder()},
            unknownAppearance = {
                type = "toggle",
                name = L["Unknown appearance"],
                order = newOrder(),
                set = function(_, val)
                    WQA.db.profile.options.reward.general.unknownAppearance = val
                end,
                get = function()
                    return WQA.db.profile.options.reward.general.unknownAppearance
                end
            },
            unknownSource = {
                type = "toggle",
                name = L["Unknown source"],
                order = newOrder(),
                set = function(_, val)
                    WQA.db.profile.options.reward.general.unknownSource = val
                end,
                get = function()
                    return WQA.db.profile.options.reward.general.unknownSource
                end
            },
            header3 = {type = "header", name = "BFA/SL General", order = newOrder()},
            AzeriteArmorCache = {
                type = "toggle",
                name = L["Azerite Armor Cache"],
                order = newOrder(),
                set = function(_, val)
                    WQA.db.profile.options.reward.general.AzeriteArmorCache = val
                end,
                get = function()
                    return WQA.db.profile.options.reward.general.AzeriteArmorCache
                end
            },
            armorCache = {
                type = "toggle",
                name = L["Armor Cache"],
                order = newOrder(),
                set = function(_, val)
                    WQA.db.profile.options.reward.general.armorCache = val
                end,
                get = function()
                    return WQA.db.profile.options.reward.general.armorCache
                end
            },
            weaponCache = {
                type = "toggle",
                name = L["Weapon Cache"],
                order = newOrder(),
                set = function(_, val)
                    WQA.db.profile.options.reward.general.weaponCache = val
                end,
                get = function()
                    return WQA.db.profile.options.reward.general.weaponCache
                end
            },
            jewelryCache = {
                type = "toggle",
                name = L["Jewelry Cache"],
                order = newOrder(),
                set = function(_, val)
                    WQA.db.profile.options.reward.general.jewelryCache = val
                end,
                get = function()
                    return WQA.db.profile.options.reward.general.jewelryCache
                end
            },
            azeriteTraits = {
                name = L["Azerite Traits"],
                desc = L["Comma separated spellIDs"],
                type = "input",
                order = newOrder(),
                set = function(_, val)
                    WQA.db.profile.options.reward.general.azeriteTraits = val
                end,
                get = function()
                    return WQA.db.profile.options.reward.general.azeriteTraits
                end
            },
            conduit = {
                name = L["Conduit"],
                desc = L["Track conduit"],
                type = "toggle",
                order = newOrder(),
                set = function(_, val)
                    WQA.db.profile.options.reward.general.conduit = val
                end,
                get = function()
                    return WQA.db.profile.options.reward.general.conduit
                end
            }
        }
    }

    local worldQuestTypeGroup = {
        order = newOrder(),
        name = L["World Quest Type"],
        type = "group",
        args = {
            header = {
                type = "header",
                name = L["World Quest Type"],
                order = newOrder()
            }
        }
    }

    do
        local args = worldQuestTypeGroup.args
        local ordered = {}

        -- gather keys
        for k in pairs(worldQuestType) do
            table.insert(ordered, k)
        end

        table.sort(ordered)

        for _, k in ipairs(ordered) do
            local v = worldQuestType[k]

            args[k] = {
                type = "toggle",
                name = L[k],
                order = newOrder(),
                set = function(_, val)
                    WQA.db.profile.options.reward.worldQuestType[v] = val
                end,
                get = function()
                    return WQA.db.profile.options.reward.worldQuestType[v] or false
                end
            }
        end
    end

    self.options.args.reward.args.worldQuestType = worldQuestTypeGroup
    --[[ --Skyriding Raceing Purses
    WQA.db.profile.options.reward = WQA.db.profile.options.reward or {}
    WQA.db.profile.options.reward.racingPurses = WQA.db.profile.options.reward.racingPurses or {}
    local RPDB = WQA.db.profile.options.reward.racingPurses

    -- Racing Purses top-level group (like Reputation)
    args.racingPurses = {
        type = "group",
        name = "|cffffd700Racing Purses|r",
        order = -10, -- top of options
        childGroups = "tree",
        args = {}
    }

    for exp, purses in pairs(WQA.RacingPursesByExp) do
        local expName = WQA.ExpansionList[exp] or ("Expansion " .. exp)

        -- Create expansion group
        args.racingPurses.args["exp" .. exp] = {
            type = "group",
            name = expName,
            order = exp,
            args = {}
        }
        local groupArgs = args.racingPurses.args["exp" .. exp].args

        -- Master toggle for all purses
        groupArgs["master_racing_purses_" .. exp] = {
            type = "toggle",
            name = "|cffffd700Always Track ALL Racing Purses from " .. expName .. "|r",
            width = "full",
            order = 0,
            get = function()
                for itemID in pairs(purses) do
                    if not RPDB[itemID] then
                        return false
                    end
                end
                return true
            end,
            set = function(_, val)
                for itemID in pairs(purses) do
                    RPDB[itemID] = val
                end
                WQA:RefreshTracking()
            end
        }

        groupArgs["header_" .. exp] = {type = "header", name = "", order = -1}

        -- Individual toggles
        for _, itemID in ipairs(purses) do
            local purseName = WQA.RacingPursesList[itemID] or ("Purse " .. itemID)

            groupArgs["purse_" .. itemID] = {
                type = "toggle",
                name = purseName, -- string ✅
                width = "full",
                order = order,
                get = function()
                    return RPDB[itemID]
                end,
                set = function(_, val)
                    RPDB[itemID] = val
                    WQA:RefreshTracking()
                end
            }
            order = order + 1
        end
    end
--]]
    -- Reputation
    args.reputation = {
        type = "group",
        name = L["Reputation"] or "Reputation",
        order = newOrder(10),
        childGroups = "tree",
        args = {}
    }
    for exp = 7, 11 do
        if FactionIDList[exp] then
            local expName = WQA.ExpansionList[exp] or ("Expansion " .. exp)
            args.reputation.args["exp" .. exp] = {
                type = "group",
                name = expName,
                order = exp,
                args = {}
            }
            local groupArgs = args.reputation.args["exp" .. exp].args

            -- MASTER TOGGLE FOR REPUTATION
            groupArgs["master_rep_" .. exp] = {
                type = "toggle",
                name = "|cffffd700Always Track ALL Reputation from " .. expName .. "|r",
                width = "full",
                order = 0,
                get = function()
                    for _, factionID in pairs(FactionIDList[exp].Neutral or {}) do
                        if not WQA.db.profile.options.reward.reputation[factionID] then
                            return false
                        end
                    end
                    local playerFaction = UnitFactionGroup("player")
                    for _, factionID in pairs(FactionIDList[exp][playerFaction] or {}) do
                        if not WQA.db.profile.options.reward.reputation[factionID] then
                            return false
                        end
                    end
                    return true
                end,
                set = function(_, val)
                    local factions = {}
                    for _, t in pairs({"Neutral", UnitFactionGroup("player")}) do
                        for _, id in pairs(FactionIDList[exp][t] or {}) do
                            factions[id] = true
                        end
                    end
                    for id in pairs(factions) do
                        WQA.db.profile.options.reward.reputation[id] = val
                    end
                    WQA:RefreshTracking()
                end
            }

            local function addFaction(id)
                local factionInfo = C_Reputation.GetFactionDataByID(id)
                local factionName = factionInfo and factionInfo.name or ("Faction " .. id)
                groupArgs["faction_" .. id] = {
                    type = "toggle",
                    name = factionName,
                    order = newOrder(),
                    get = function()
                        return WQA.db.profile.options.reward.reputation[id]
                    end,
                    set = function(_, val)
                        WQA.db.profile.options.reward.reputation[id] = val
                        WQA:RefreshTracking()
                    end
                }
            end

            for _, id in pairs(FactionIDList[exp].Neutral or {}) do
                addFaction(id)
            end
            local playerFaction = UnitFactionGroup("player")
            for _, id in pairs(FactionIDList[exp][playerFaction] or {}) do
                addFaction(id)
            end
        end
    end

    -- Currencies
    args.currencies = {
        type = "group",
        name = L["Currencies"] or "Currencies",
        order = newOrder(10),
        childGroups = "tree",
        args = {}
    }

    -- Ensure the currency DB table exists
    WQA.db.profile.options.reward.currency = WQA.db.profile.options.reward.currency or {}

    for exp = 6, 11 do
        local currencyList = WQA.CurrencyIDList[exp]
        if currencyList then
            local expName = WQA.ExpansionList[exp] or ("Expansion " .. exp)

            -- Expansion group
            args.currencies.args["exp" .. exp] = {
                type = "group",
                name = expName,
                order = exp,
                args = {}
            }
            local groupArgs = args.currencies.args["exp" .. exp].args

            -- Master toggle for all currencies in this expansion
            groupArgs["master_currency_" .. exp] = {
                type = "toggle",
                name = "|cffffd700Always Track ALL Currencies from " .. expName .. "|r",
                width = "full",
                order = 0,
                get = function()
                    for _, entry in ipairs(currencyList) do
                        local id = type(entry) == "table" and entry.id or entry
                        if not WQA.db.profile.options.reward.currency[id] then
                            return false
                        end
                    end
                    return true
                end,
                set = function(_, val)
                    for _, entry in ipairs(currencyList) do
                        local id = type(entry) == "table" and entry.id or entry
                        WQA.db.profile.options.reward.currency[id] = val
                    end
                    WQA:RefreshTracking()
                end
            }

            -- Add per-currency toggles
            for _, entry in ipairs(currencyList) do
                local id = type(entry) == "table" and entry.id or entry
                local faction = type(entry) == "table" and entry.faction or nil

                -- Only show faction-appropriate currencies
                if not faction or faction == UnitFactionGroup("player") then
                    -- Set default if nil
                    if WQA.db.profile.options.reward.currency[id] == nil then
                        WQA.db.profile.options.reward.currency[id] = true
                    end

                    -- Add the toggle
                    local info = C_CurrencyInfo.GetCurrencyInfo(id)
                    local name = info and info.name or ("Currency " .. id)
                    groupArgs[tostring(id)] = {
                        type = "toggle",
                        name = name,
                        order = newOrder(),
                        get = function()
                            return WQA.db.profile.options.reward.currency[id]
                        end,
                        set = function(_, val)
                            WQA.db.profile.options.reward.currency[id] = val
                            WQA:RefreshTracking()
                        end
                    }
                end
            end
        end
    end

    -- Crafting Reagents
    --[[  if next(WQA.CraftingReagentIDList) then
        args.reagents = {
            type = "group",
            name = L["Crafting Reagents"] or "Crafting Reagents",
            order = newOrder(10),
            childGroups = "tree",
            args = {}
        }
        for exp, list in pairs(WQA.CraftingReagentIDList) do
            local expName = WQA.ExpansionList[exp] or ("Expansion " .. exp)
            args.reagents.args["exp" .. exp] = {
                type = "group",
                name = expName,
                order = exp,
                args = {}
            }
            local groupArgs = args.reagents.args["exp" .. exp].args

            -- MASTER TOGGLE FOR REAGENTS
            groupArgs["master_reagent_" .. exp] = {
                type = "toggle",
                name = "|cffffd700Always Track ALL Crafting Reagents from " .. expName .. "|r",
                width = "full",
                order = 0,
                get = function()
                    for _, itemID in ipairs(list) do
                        if not WQA.db.profile.options.reward.craftingreagent[itemID] then
                            return false
                        end
                    end
                    return true
                end,
                set = function(_, val)
                    for _, itemID in ipairs(list) do
                        WQA.db.profile.options.reward.craftingreagent[itemID] = val
                    end
                    WQA:RefreshTracking()
                end
            }

            groupArgs["master_header_reagent" .. exp] = {type = "header", name = "", order = -199}

            for _, itemID in ipairs(list) do
                local name = GetItemInfo(itemID) or ("Item " .. itemID)
                AddRewardLine(groupArgs, itemID, name, "rewardItem", exp)
            end
        end
    end
--]]
    -- Emissary Quests
    if next(WQA.EmissaryQuestIDList) then
        args.emissary = {
            type = "group",
            name = L["Emissary Quests"] or "Emissary Quests",
            order = newOrder(10),
            childGroups = "tree",
            args = {}
        }
        for exp, list in pairs(WQA.EmissaryQuestIDList) do
            local expName = WQA.ExpansionList[exp] or ("Expansion " .. exp)
            args.emissary.args["exp" .. exp] = {
                type = "group",
                name = expName,
                order = exp,
                args = {}
            }
            local groupArgs = args.emissary.args["exp" .. exp].args

            -- MASTER TOGGLE FOR EMISSARIES
            groupArgs["master_emissary_" .. exp] = {
                type = "toggle",
                name = "|cffffd700Always Track ALL Emissaries from " .. expName .. "|r",
                width = "full",
                order = 0,
                get = function()
                    for _, entry in ipairs(list) do
                        local id = type(entry) == "table" and entry.id or entry
                        if not WQA.db.profile.options.emissary[id] then
                            return false
                        end
                    end
                    return true
                end,
                set = function(_, val)
                    for _, entry in ipairs(list) do
                        local id = type(entry) == "table" and entry.id or entry
                        WQA.db.profile.options.emissary[id] = val
                    end
                    WQA:RefreshTracking()
                end
            }

            for _, entry in ipairs(list) do
                local id = type(entry) == "table" and entry.id or entry
                local faction = type(entry) == "table" and entry.faction or nil
                if not faction or faction == UnitFactionGroup("player") then
                    -- Force DB entry to exist
                    WQA.db.profile.options.emissary[id] = WQA.db.profile.options.emissary[id] or false

                    local title = C_QuestLog.GetTitleForQuestID(id) or ("Emissary " .. id)
                    AddRewardLine(groupArgs, id, title, "rewardEmissary", exp)
                end
            end
        end
    end

    -- Mission Table
    args.missionTable = {
        type = "group",
        name = L["Mission Table"] or "Mission Table",
        order = newOrder(15),
        childGroups = "tree",
        args = {}
    }

    for expIndex = 6, 9 do
        local exp = expIndex -- ensures `exp` is a number
        local expName = WQA.ExpansionList[exp] or ("Expansion " .. exp)
        args.missionTable.args["exp" .. exp] = {
            type = "group",
            name = expName,
            order = exp,
            args = {}
        }

        local groupArgs = args.missionTable.args["exp" .. exp].args

        -- Initialize reward tables if missing
        local expTable = WQA.db.profile.options.missionTable.reward["exp" .. exp]
        if not expTable then
            expTable = {gold = false, currency = {}, reputation = {}, items = false}
            WQA.db.profile.options.missionTable.reward["exp" .. exp] = expTable
        else
            expTable.currency = expTable.currency or {}
            expTable.reputation = expTable.reputation or {}
            expTable.items = expTable.items or false
        end

        -------------------------------
        -- MASTER TOGGLE FOR ENTIRE EXP
        -------------------------------
        groupArgs["master_all_" .. exp] = {
            type = "toggle",
            name = "|cffffd700Always Track ALL Mission Table Rewards for " .. expName .. "|r",
            width = "full",
            order = 0,
            get = function()
                if not expTable.gold or not expTable.items then
                    return false
                end
                for _, v in pairs(WQA.CurrencyIDList[exp] or {}) do
                    local id = type(v) == "table" and v.id or v
                    if not expTable.currency[id] then
                        return false
                    end
                end
                for id, tracked in pairs(expTable.reputation) do
                    if not tracked then
                        return false
                    end
                end
                return true
            end,
            set = function(_, val)
                expTable.gold = val
                expTable.items = val
                for _, v in pairs(WQA.CurrencyIDList[exp] or {}) do
                    local id = type(v) == "table" and v.id or v
                    expTable.currency[id] = val
                end
                for id, _ in pairs(expTable.reputation) do
                    expTable.reputation[id] = val
                end
                WQA:RefreshTracking()
            end
        }

        -----------------------------------
        -- INDIVIDUAL CURRENCY TOGGLES
        -----------------------------------
        for _, v in pairs(WQA.CurrencyIDList[exp] or {}) do
            local id = type(v) == "table" and v.id or v
            local faction = type(v) == "table" and v.faction or nil
            if not faction or faction == UnitFactionGroup("player") then
                if expTable.currency[id] == nil then
                    expTable.currency[id] = true
                end

                groupArgs["currency_" .. id] = {
                    type = "toggle",
                    name = C_CurrencyInfo.GetCurrencyLink(id) or ("Currency " .. id),
                    order = id,
                    get = function()
                        return expTable.currency[id]
                    end,
                    set = function(_, val)
                        expTable.currency[id] = val
                        WQA:RefreshTracking()
                    end
                }
            end
        end
    end
end

-- Main options builder
function WQA:UpdateOptions()
    order = 0

    self.options = {
        type = "group",
        childGroups = "tab",
        name = "WQAchievements",
        args = {
            -- 1. General (Mounts / Pets / Toys / Achievements per expansion)

            general = {
                type = "group",
                name = L["General"],
                order = newOrder(),
                childGroups = "tree",
                args = {}
            },
            -- 2. Rewards (Currencies, Reagents, Emissaries, Reputation, Gold, World Quest Type)

            reward = {
                type = "group",
                name = L["Rewards"],
                order = newOrder(),
                childGroups = "tree",
                args = {}
            },
            -- 3. Custom World Quests / Missions

            custom = {
                type = "group",
                name = L["Custom"],
                order = newOrder(),
                childGroups = "tree",
                args = {
                    desc = {
                        type = "description",
                        name = L["Add your own world quests or missions that are not automatically detected."] or
                            "Add your own world quests or missions that are not automatically detected.",
                        fontSize = "medium",
                        order = 1
                    },
                    quest = {
                        order = newOrder(),
                        name = L["World Quest"],
                        type = "group",
                        inline = true,
                        args = {
                            header1 = {type = "header", name = L["Add a Quest you want to track"], order = newOrder()},
                            addWQ = {
                                name = L["QuestID"],
                                type = "input",
                                order = newOrder(),
                                width = 0.6,
                                set = function(_, val)
                                    WQA.data.custom.wqID = val
                                end,
                                get = function()
                                    return tostring(WQA.data.custom.wqID or "")
                                end
                            },
                            questType = {
                                name = L["Quest type"],
                                type = "select",
                                order = newOrder(),
                                values = {
                                    WORLD_QUEST = L["World Quest"],
                                    QUEST_PIN = L["Quest Pin"],
                                    QUEST_FLAG = L["IsQuestFlaggedCompleted"],
                                    IsActive = L["IsActive"]
                                },
                                set = function(_, val)
                                    WQA.data.custom.questType = val
                                end,
                                get = function()
                                    return WQA.data.custom.questType or "WORLD_QUEST"
                                end
                            },
                            mapID = {
                                name = L["mapID"],
                                desc = L["Quest pin tracking needs a mapID.\nSee https://wago.tools/db2/UiMap for help."],
                                type = "input",
                                width = 0.5,
                                order = newOrder(),
                                set = function(_, val)
                                    WQA.data.custom.mapID = val
                                end,
                                get = function()
                                    return tostring(WQA.data.custom.mapID or "")
                                end
                            },
                            button = {
                                type = "execute",
                                name = L["Add"],
                                width = .35,
                                order = newOrder(),
                                func = function()
                                    WQA:CreateCustomQuest()
                                end
                            },
                            header2 = {type = "header", name = L["Configure custom World Quests"], order = newOrder()}
                        }
                    },
                    reward = {
                        order = newOrder(),
                        name = L["Reward"],
                        type = "group",
                        inline = true,
                        args = {
                            header1 = {
                                type = "header",
                                name = L["Add a World Quest Reward you want to track"],
                                order = newOrder()
                            },
                            itemID = {
                                name = L["itemID"],
                                type = "input",
                                order = newOrder(),
                                width = 0.6,
                                set = function(_, val)
                                    WQA.data.custom.worldQuestReward = val
                                end,
                                get = function()
                                    return tostring(WQA.data.custom.worldQuestReward or 0)
                                end
                            },
                            button = {
                                type = "execute",
                                name = L["Add"],
                                width = .35,
                                order = newOrder(),
                                func = function()
                                    WQA:CreateCustomReward()
                                end
                            },
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
                            header1 = {type = "header", name = L["Add a Mission you want to track"], order = newOrder()},
                            missionID = {
                                name = L["MissionID"],
                                type = "input",
                                order = newOrder(),
                                width = 0.6,
                                set = function(_, val)
                                    WQA.data.custom.mission.missionID = val
                                end,
                                get = function()
                                    return tostring(WQA.data.custom.mission.missionID or "")
                                end
                            },
                            rewardID = {
                                name = L["Reward (optional)"],
                                desc = L["Enter an achievementID or itemID"],
                                type = "input",
                                width = 0.6,
                                order = newOrder(),
                                set = function(_, val)
                                    WQA.data.custom.mission.rewardID = val
                                end,
                                get = function()
                                    return tostring(WQA.data.custom.mission.rewardID or "")
                                end
                            },
                            rewardType = {
                                name = L["Reward type"],
                                type = "select",
                                order = newOrder(),
                                values = {item = L["Item"], achievement = L["Achievement"], none = L["none"]},
                                width = 0.6,
                                set = function(_, val)
                                    WQA.data.custom.mission.rewardType = val
                                end,
                                get = function()
                                    return WQA.data.custom.mission.rewardType or "none"
                                end
                            },
                            button = {
                                type = "execute",
                                name = L["Add"],
                                width = .35,
                                order = newOrder(),
                                func = function()
                                    WQA:CreateCustomMission()
                                end
                            },
                            header2 = {type = "header", name = L["Configure custom Missions"], order = newOrder()}
                        }
                    },
                    missionReward = {
                        order = newOrder(),
                        name = L["Reward"],
                        type = "group",
                        inline = true,
                        args = {
                            header1 = {
                                type = "header",
                                name = L["Add a Mission Reward you want to track"],
                                order = newOrder()
                            },
                            itemID = {
                                name = L["itemID"],
                                type = "input",
                                order = newOrder(),
                                width = 0.6,
                                set = function(_, val)
                                    WQA.data.custom.missionReward = val
                                end,
                                get = function()
                                    return tostring(WQA.data.custom.missionReward or 0)
                                end
                            },
                            button = {
                                type = "execute",
                                name = L["Add"],
                                width = .35,
                                order = newOrder(),
                                func = function()
                                    WQA:CreateCustomMissionReward()
                                end
                            },
                            header2 = {
                                type = "header",
                                name = L["Configure custom Mission Rewards"],
                                order = newOrder()
                            }
                        }
                    }
                }
            },
            -- 4. Options (delay, chat, popup, minimap, etc.)

            options = {
                type = "group",
                name = L["Options"],
                order = newOrder(),
                args = {
                    desc1 = {
                        type = "description",
                        fontSize = "medium",
                        name = L["Select where WQA is allowed to post"] or "Select where WQA is allowed to post",
                        order = newOrder()
                    },
                    chat = {
                        type = "toggle",
                        name = L["Chat"],
                        width = "double",
                        set = function(_, val)
                            WQA.db.profile.options.chat = val
                        end,
                        get = function()
                            return WQA.db.profile.options.chat
                        end,
                        order = newOrder()
                    },
                    PopUp = {
                        type = "toggle",
                        name = L["PopUp"],
                        width = "double",
                        set = function(_, val)
                            WQA.db.profile.options.PopUp = val
                        end,
                        get = function()
                            return WQA.db.profile.options.PopUp
                        end,
                        order = newOrder()
                    },
                    popupRememberPosition = {
                        type = "toggle",
                        name = L["Remember PopUp position"],
                        width = "double",
                        set = function(_, val)
                            WQA.db.profile.options.popupRememberPosition = val
                        end,
                        get = function()
                            return WQA.db.profile.options.popupRememberPosition
                        end,
                        order = newOrder()
                    },
                    popupResetPosition = {
                        type = "execute",
                        name = L["Reset Popup Position"] or "Reset Popup Position",
                        desc = L["Moves the popup window back to the center of the screen"] or
                            "Moves the popup window back to the center of the screen",
                        order = newOrder(),
                        width = "full",
                        func = function()
                            WQA.db.profile.options.popupX = nil
                            WQA.db.profile.options.popupY = nil
                            if WQA.PopUp and WQA.PopUp:IsShown() then
                                WQA.PopUp:ClearAllPoints()
                                WQA.PopUp:SetPoint("CENTER")
                            end
                            print("|cFF00FF00[WQA]|r Popup position reset to center.")
                        end
                    },
                    sortByName = {
                        type = "toggle",
                        name = L["Sort quests by name"],
                        width = "double",
                        set = function(_, val)
                            WQA.db.profile.options.sortByName = val
                        end,
                        get = function()
                            return WQA.db.profile.options.sortByName
                        end,
                        order = newOrder()
                    },
                    sortByZoneName = {
                        type = "toggle",
                        name = L["Sort quests by zone name"],
                        width = "double",
                        set = function(_, val)
                            WQA.db.profile.options.sortByZoneName = val
                        end,
                        get = function()
                            return WQA.db.profile.options.sortByZoneName
                        end,
                        order = newOrder()
                    },
                    chatShowExpansion = {
                        type = "toggle",
                        name = L["Show expansion in chat"],
                        width = "double",
                        set = function(_, val)
                            WQA.db.profile.options.chatShowExpansion = val
                        end,
                        get = function()
                            return WQA.db.profile.options.chatShowExpansion
                        end,
                        order = newOrder()
                    },
                    chatShowZone = {
                        type = "toggle",
                        name = L["Show zone in chat"],
                        width = "double",
                        set = function(_, val)
                            WQA.db.profile.options.chatShowZone = val
                        end,
                        get = function()
                            return WQA.db.profile.options.chatShowZone
                        end,
                        order = newOrder()
                    },
                    chatShowTime = {
                        type = "toggle",
                        name = L["Show time left in chat"],
                        width = "double",
                        set = function(_, val)
                            WQA.db.profile.options.chatShowTime = val
                        end,
                        get = function()
                            return WQA.db.profile.options.chatShowTime
                        end,
                        order = newOrder()
                    },
                    popupShowExpansion = {
                        type = "toggle",
                        name = L["Show expansion in popup"],
                        width = "double",
                        set = function(_, val)
                            WQA.db.profile.options.popupShowExpansion = val
                        end,
                        get = function()
                            return WQA.db.profile.options.popupShowExpansion
                        end,
                        order = newOrder()
                    },
                    popupShowZone = {
                        type = "toggle",
                        name = L["Show zone in popup"],
                        width = "double",
                        set = function(_, val)
                            WQA.db.profile.options.popupShowZone = val
                        end,
                        get = function()
                            return WQA.db.profile.options.popupShowZone
                        end,
                        order = newOrder()
                    },
                    popupShowTime = {
                        type = "toggle",
                        name = L["Show time left in popup"],
                        width = "double",
                        set = function(_, val)
                            WQA.db.profile.options.popupShowTime = val
                        end,
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
                        set = function(_, val)
                            WQA.db.profile.options.delay = tonumber(val) or 5
                        end,
                        get = function()
                            return tostring(WQA.db.profile.options.delay or 5)
                        end
                    },
                    delayCombat = {
                        name = L["Delay output while in combat"],
                        type = "toggle",
                        order = newOrder(),
                        width = "double",
                        set = function(_, val)
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
                        set = function(_, val)
                            WQA.db.profile.options.WorldQuestTracker = val
                        end,
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
                        set = function(_, val)
                            WQA.db.profile.options.esc = val
                        end,
                        get = function()
                            return WQA.db.profile.options.esc
                        end,
                        order = newOrder()
                    },
                    LibDBIcon = {
                        type = "toggle",
                        name = L["Show Minimap Icon"],
                        width = "double",
                        set = function(_, val)
                            WQA.db.profile.options.LibDBIcon.hide = not val
                            WQA:UpdateMinimapIcon()
                        end,
                        get = function()
                            return not WQA.db.profile.options.LibDBIcon.hide
                        end,
                        order = newOrder()
                    },
                    popupWidth = {
                        type = "range",
                        name = L["Popup Width"] or "Popup Width",
                        min = 300,
                        max = 1400,
                        step = 10,
                        width = "full",
                        get = function()
                            return WQA.db.profile.options.popupWidth or 600
                        end,
                        set = function(_, val)
                            WQA.db.profile.options.popupWidth = val
                            if WQA.PopUp and WQA.PopUp:IsShown() then
                                WQA:AnnouncePopUp(WQA.activeTasks or {}, false)
                            end
                        end
                    },
                    popupMaxHeight = {
                        type = "range",
                        name = L["Popup Maximum Height"] or "Popup Maximum Height",
                        min = 300,
                        max = 1000,
                        step = 10,
                        width = "full",
                        get = function()
                            return WQA.db.profile.options.popupMaxHeight or 700
                        end,
                        set = function(_, val)
                            WQA.db.profile.options.popupMaxHeight = val
                            if WQA.PopUp and WQA.PopUp:IsShown() then
                                WQA:AnnouncePopUp(WQA.activeTasks or {}, false)
                            end
                        end
                    },
                    popupScale = {
                        type = "range",
                        name = L["Popup Scale"] or "Popup Scale",
                        min = 0.5,
                        max = 2.0,
                        step = 0.05,
                        isPercent = true,
                        width = "full",
                        get = function()
                            return WQA.db.profile.options.popupScale or 1.0
                        end,
                        set = function(_, val)
                            WQA.db.profile.options.popupScale = val
                            if WQA.PopUp and WQA.PopUp:IsShown() then
                                WQA:AnnouncePopUp(WQA.activeTasks or {}, false)
                            end
                        end
                    }
                }
            }
        }
    }

    -- Fill General tab (expansions with mounts/pets/toys/achievements)

    for i = 6, 11 do -- Warlords to The War Within
        local data = self.data[i]
        if data then
            local expGroup = {
                type = "group",
                name = self.ExpansionList[i] or ("Expansion " .. i),
                order = newOrder(),
                childGroups = "tree",
                args = {}
            }
            self.options.args.general.args["exp" .. i] = expGroup

            -- Add achievements, mounts, pets, toys
            self:CreateCategoryGroup(expGroup.args, data, "achievements")
            self:CreateCategoryGroup(expGroup.args, data, "mounts")
            self:CreateCategoryGroup(expGroup.args, data, "pets")
            self:CreateCategoryGroup(expGroup.args, data, "toys")
        end
    end

    -- Fill Rewards tab

    self:CreateRewardOptions()
    self:UpdateCustom()
end

function WQA:GetOptions()
    self:UpdateOptions()
    self:SortOptions()
    return self.options
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
            width = 1.7
        }

        args[id .. "questType"] = {
            name = L["Quest type"],
            order = newOrder(),
            desc = L[
                "IsActive:\nUse this as a last resort. Works for some daily quests.\n\nIsQuestFlaggedCompleted:\nUse this for quests, that are always active.\n\nQuest Pin:\nUse this, if the daily is marked with a quest pin on the world map.\n\nWorld Quest:\nUse this, if you want to track a world quest."
            ],
            type = "select",
            values = {
                WORLD_QUEST = L["World Quest"],
                QUEST_PIN = L["Quest Pin"],
                QUEST_FLAG = L["IsQuestFlaggedCompleted"],
                IsActive = L["IsActive"]
            },
            width = .62,
            set = function(info, val)
                self.db.global.custom.worldQuest[id].questType = val
            end,
            get = function()
                return tostring(self.db.global.custom.worldQuest[id].questType or "")
            end
        }
        args[id .. "mapID"] = {
            name = L["mapID"],
            desc = L["Quest pin tracking needs a mapID.\nSee https://wago.tools/db2/UiMap for help."],
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
            width = .45,
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
            width = 1.7
        }
        args[id .. "Delete"] = {
            order = newOrder(),
            type = "execute",
            name = L["Delete"],
            width = .45,
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
            width = 1.7
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
            values = {item = "Item", achievement = "Achievement", none = "none"},
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
            width = .45,
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
            width = .45,
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
    for _, expansionGroup in pairs(self.options.args.general.args) do
        for category, catGroup in pairs(expansionGroup.args) do
            if catGroup.args["notCompleted"] then
                local t = {}
                for key, option in pairs(catGroup.args) do
                    if key:find("Name$") then
                        local idStr = key:match("^(%d+)Name$")
                        if idStr then
                            local id = tonumber(idStr)
                            local completed = false

                            if category == "achievements" then
                                _, _, _, completed = GetAchievementInfo(id)
                            elseif category == "mounts" then
                                for _, mountID in pairs(C_MountJournal.GetMountIDs()) do
                                    local _, spellID, _, _, _, _, _, _, _, _, isCollected =
                                        C_MountJournal.GetMountInfoByID(mountID)
                                    if spellID == id then
                                        completed = isCollected
                                        break
                                    end
                                end
                            elseif category == "pets" then
                                local total = C_PetJournal.GetNumPets()
                                for i = 1, total do
                                    local _, _, owned, _, _, _, _, _, _, _, companionID =
                                        C_PetJournal.GetPetInfoByIndex(i)
                                    if companionID == id then
                                        completed = owned
                                        break
                                    end
                                end
                            elseif category == "toys" then
                                completed = PlayerHasToy(id)
                            end

                            table.insert(
                                t,
                                {
                                    nameKey = key,
                                    dropdownKey = idStr,
                                    name = option.name,
                                    completed = completed
                                }
                            )
                        end
                    end
                end

                -- Sort alphabetically
                table.sort(
                    t,
                    function(a, b)
                        return a.name < b.name
                    end
                )

                local order = 1
                local notCompletedShown = false
                local completedShown = false

                for _, entry in ipairs(t) do
                    if not entry.completed then
                        if not notCompletedShown then
                            catGroup.args["notCompleted"].hidden = false
                            catGroup.args["notCompleted"].order = order
                            notCompletedShown = true
                            order = order + 1
                        end
                        catGroup.args[entry.nameKey].order = order
                        catGroup.args[entry.dropdownKey].order = order + 0.1
                        order = order + 1
                    end
                end

                -- Completed after not completed
                for _, entry in ipairs(t) do
                    if entry.completed then
                        if not completedShown then
                            catGroup.args["completed"].hidden = false
                            catGroup.args["completed"].order = order
                            completedShown = true
                            order = order + 1
                        end
                        catGroup.args[entry.nameKey].order = order
                        catGroup.args[entry.dropdownKey].order = order + 0.1
                        order = order + 1
                    end
                end
            end
        end
    end
end
