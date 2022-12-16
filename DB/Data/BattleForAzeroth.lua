local WQA = WQAchievements

-- Battle for Azeroth
local data = {
    name = "Battle for Azeroth"
}
WQA.data[8] = data

-- Achievements
local trainer = {
    52009,
    52165,
    52218,
    52278,
    52297,
    52316,
    52325,
    52430,
    52471,
    52751,
    52754,
    52799,
    52803,
    52850,
    52856,
    52878,
    52892,
    52923,
    52938
}

data.achievements = {
    {name = "Adept Sandfisher", id = 13009, criteriaType = "QUEST_SINGLE", criteria = 51173, faction = "Horde"},
    {name = "Scourge of Zem'lan", id = 13011, criteriaType = "QUESTS", criteria = {{51763, 51783}}},
    {name = "Vorrik's Champion", id = 13014, criteriaType = "QUESTS", criteria = {51957, 51983}, faction = "Horde"},
    {
        name = "Revenge is Best Served Speedily",
        id = 13022,
        criteriaType = "QUEST_SINGLE",
        criteria = 50786,
        faction = "Horde"
    },
    {name = "It's Really Getting Out of Hand", id = 13023, criteriaType = "QUESTS", criteria = {{50559, 51127}}},
    {name = "Zandalari Spycatcher", id = 13025, criteriaType = "QUEST_SINGLE", criteria = 50717, faction = "Horde"},
    {
        name = "7th Legion Spycatcher",
        id = 13026,
        criteriaType = "QUEST_SINGLE",
        criteria = 50899,
        faction = "Alliance"
    },
    {name = "By de Power of de Loa!", id = 13035, criteriaType = "QUESTS", criteria = {{51178, 51232}}},
    {name = "Bless the Rains Down in Freehold", id = 13050, criteriaType = "QUESTS", criteria = {{53196, 52159}}},
    {
        name = "Kul Runnings",
        id = 13060,
        criteriaType = "QUESTS",
        criteria = {49994, 53188, 53189},
        faction = "Alliance"
    },
    {
        name = "Battle on Zandalar and Kul Tiras",
        id = 12936,
        criteriaType = "QUESTS",
        criteria = {
            52009,
            52126,
            52165,
            52218,
            52278,
            52297,
            52316,
            52325,
            52430,
            52455,
            52471,
            52751,
            52754,
            52779,
            52799,
            52803,
            52850,
            52856,
            52864,
            52878,
            52892,
            52923,
            52937,
            52938
        }
    },
    {
        name = "A Most Efficient Apocalypse",
        id = 13021,
        criteriaType = "QUEST_SINGLE",
        criteria = 50665,
        faction = "Horde"
    },
    -- Thanks NatalieWright
    {
        name = "Adventurer of Zuldazar",
        id = 12944,
        criteriaType = "QUESTS",
        criteria = {
            50864,
            50877,
            {51085, 51087},
            51081,
            {50287, 51374, 50866},
            50885,
            50863,
            50862,
            50861,
            50859,
            50845,
            50857,
            nil,
            50875,
            50874,
            nil,
            50872,
            50876,
            50871,
            50870,
            50869,
            50868,
            50867
        }
    },
    {
        name = "Adventurer of Vol'dun",
        id = 12943,
        criteriaType = "QUESTS",
        criteria = {
            51105,
            51095,
            51096,
            51117,
            nil,
            51118,
            51120,
            51098,
            51121,
            51099,
            51108,
            51100,
            51125,
            51102,
            51429,
            51103,
            51124,
            51107,
            51122,
            51123,
            51104,
            51116,
            51106,
            51119,
            51112,
            51113,
            51114,
            51115
        }
    },
    {
        name = "Adventurer of Nazmir",
        id = 12942,
        criteriaType = "QUESTS",
        criteria = {
            50488,
            50570,
            50564,
            nil,
            50490,
            50506,
            50568,
            50491,
            50492,
            50499,
            50496,
            50498,
            50501,
            nil,
            50502,
            50503,
            50505,
            50507,
            50566,
            50511,
            50512,
            nil,
            50513,
            50514,
            nil,
            50515,
            50516,
            50489,
            50519,
            50518,
            50509,
            50517
        }
    },
    {
        name = "Adventurer of Drustvar",
        id = 12941,
        criteriaType = "QUESTS",
        criteria = {
            51469,
            51505,
            51506,
            51508,
            51468,
            51972,
            nil,
            nil,
            nil,
            51897,
            51457,
            nil,
            51909,
            51507,
            51917,
            nil,
            51919,
            51908,
            51491,
            51512,
            51527,
            51461,
            51467,
            51528,
            51466,
            51541,
            51542,
            51884,
            51874,
            51906,
            51887,
            51989,
            51988
        }
    },
    {
        name = "Adventurer of Tiragarde Sound",
        id = 12939,
        criteriaType = "QUESTS",
        criteria = {
            51653,
            51652,
            51666,
            51669,
            51841,
            51665,
            51848,
            51842,
            51654,
            51662,
            51844,
            51664,
            51670,
            51895,
            nil,
            51659,
            51843,
            51660,
            51661,
            51890,
            51656,
            51893,
            51892,
            51651,
            51839,
            51891,
            51849,
            51894,
            51655,
            51847,
            nil,
            51657
        }
    },
    {
        name = "Adventurer of Stormsong Valley",
        id = 12940,
        criteriaType = "QUESTS",
        criteria = {
            52452,
            52315,
            51759,
            {51976, 51977, 51978},
            52476,
            51774,
            51921,
            nil,
            51776,
            52459,
            52321,
            51781,
            nil,
            51886,
            51779,
            51778,
            52306,
            52310,
            51901,
            51777,
            52301,
            nil,
            52463,
            nil,
            52328,
            51782, -- Captain Razorspine
            52299, -- Whiplash
            nil,
            52300,
            nil,
            52464,
            52309,
            52322,
            nil
        }
    },
    {name = "Sabertron Assemble", id = 13054, criteriaType = "QUESTS", criteria = {nil, 51977, 51978, 51976, 51974}},
    {name = "Drag Race", id = 13059, criteriaType = "QUEST_SINGLE", criteria = 53346, faction = "Alliance"},
    {
        name = "Unbound Monstrosities",
        id = 12587,
        criteriaType = "QUESTS",
        criteria = {52166, 52157, 52181, 52169, 52196, 136385}
    },
    {name = "Wide World of Quests", id = 13144, criteriaType = "SPECIAL"},
    {
        name = "Family Battler",
        id = 13279,
        criteriaType = "ACHIEVEMENT",
        criteria = {
            {id = 13280, criteriaType = "QUESTS", criteria = trainer},
            {id = 13270, criteriaType = "QUESTS", criteria = trainer},
            {id = 13271, criteriaType = "QUESTS", criteria = trainer},
            {id = 13272, criteriaType = "QUESTS", criteria = trainer},
            {id = 13273, criteriaType = "QUESTS", criteria = trainer},
            {id = 13274, criteriaType = "QUESTS", criteria = trainer},
            {id = 13281, criteriaType = "QUESTS", criteria = trainer},
            {id = 13275, criteriaType = "QUESTS", criteria = trainer},
            {id = 13277, criteriaType = "QUESTS", criteria = trainer},
            {id = 13278, criteriaType = "QUESTS", criteria = trainer}
        }
    },
    -- 8.1
    {name = "Upright Citizens", id = 13285, criteriaType = "QUEST_SINGLE", criteria = 53704, faction = "Alliance"},
    {
        name = "Scavenge like a Vulpera",
        id = 13437,
        criteriaType = "QUEST_SINGLE",
        criteria = 54415,
        faction = "Horde"
    },
    {name = "Pushing the Payload", id = 13441, criteriaType = "QUEST_SINGLE", criteria = 54505, faction = "Horde"},
    {
        name = "Pushing the Payload",
        id = 13440,
        criteriaType = "QUEST_SINGLE",
        criteria = 54498,
        faction = "Alliance"
    },
    {name = "Doomsoul Surprise", id = 13435, criteriaType = "QUEST_SINGLE", criteria = 54689, faction = "Horde"},
    {name = "Come On and Slam", id = 13426, criteriaType = "QUEST_SINGLE", criteria = 54512, faction = "Alliance"},
    {name = "Boxing Match", id = 13439, criteriaType = "QUESTS", criteria = {{54524, 54516}}, faction = "Alliance"},
    {name = "Boxing Match", id = 13438, criteriaType = "QUESTS", criteria = {{54524, 54516}}, faction = "Horde"},
    -- 8.1.5
    -- Circle, Square, Triangle
    {
        name = "Master Calligrapher",
        id = 13512,
        criteriaType = "QUESTS",
        criteria = {{55340, 55342}, {55264, 55343}, {55341, 55344}}
    },
    -- Mission Table
    -- Alliance
    {name = "Azeroth at War: The Barrens", id = 12896, criteriaType = "MISSION_TABLE", faction = "Alliance"},
    {name = "Azeroth at War: Kalimdor on Fire", id = 12899, criteriaType = "MISSION_TABLE", faction = "Alliance"},
    {name = "Azeroth at War: After Lordaeron", id = 12898, criteriaType = "MISSION_TABLE", faction = "Alliance"},
    -- Horde
    {name = "Azeroth at War: The Barrens", id = 12867, criteriaType = "MISSION_TABLE", faction = "Horde"},
    {name = "Azeroth at War: Kalimdor on Fire", id = 12870, criteriaType = "MISSION_TABLE", faction = "Horde"},
    {name = "Azeroth at War: After Lordaeron", id = 12869, criteriaType = "MISSION_TABLE", faction = "Horde"},
    -- 8.2
    {
        name = "Outside Influences",
        id = 13556,
        criteriaType = "QUEST_PIN",
        mapID = "1462",
        criteriaInfo = {
            [4] = {55658, 55672},
            [5] = {55658, 55688},
            [6] = {55658, 55717},
            [7] = {55658, 55718},
            [8] = {55658, 56049},
            [10] = {55658, 55469},
            [25] = {56552, 56558}
        }
    },
    {name = "Nazjatarget Eliminated", id = 13690},
    {name = "Puzzle Performer", id = 13764},
    -- criteriaType = "QUESTS", criteria= {56025, 56024, 56023, 56022, 56021, 56020, 56019, 56018, nil, 56008, 56007, 56009, 56006, 56003, 56010, 56011, 56014, 56016, 56015, 56013,  56012}},
    {name = "Periodic Destruction", id = 13699, criteriaType = "QUEST_FLAG", criteria = 55121}
}

-- Pets
data.pets = {
    {name = "Vengeful Chicken", itemID = 160940, creatureID = 139372, quest = {{trackingID = 0, wqID = 51212}}},
    {
        name = "Rebuilt Gorilla Bot",
        itemID = 166715,
        creatureID = 149348,
        quest = {{trackingID = 0, wqID = 54272}},
        faction = "Alliance"
    },
    {
        name = "Rebuilt Mechanical Spider",
        itemID = 166723,
        creatureID = 149361,
        quest = {{trackingID = 0, wqID = 54273}},
        faction = "Horde"
    }
}

-- Toys
data.toys = {
    {
        name = "Echoes of Rezan",
        itemID = 160509,
        quest = {{trackingID = 0, wqID = 50855}, {trackingID = 0, wqID = 50957}}
    },
    {name = "Toy Siege Tower", itemID = 163828, quest = {{trackingID = 0, wqID = 52847}}, faction = "Alliance"},
    {name = "Toy War Machine", itemID = 163829, quest = {{trackingID = 0, wqID = 52848}}, faction = "Horde"}
}

-- Mounts
data.mounts = {
    {name = "Mollie", itemID = 174842, spellID = 298367, quest = {{wqID = 52196}}}
}
