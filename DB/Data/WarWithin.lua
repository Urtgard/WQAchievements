local WQA = WQAchievements

-- War Within
local data = {
    name = _G.EXPANSION_NAME10
}
WQA.data[11] = data

-- Achievements
local trainer = {
    82293,
    82292,
    82294,
    82295

}

data.achievements = {
    {
        name = "Worm Theory",
        id = 40869,
        criteriaType = "QUESTS",
        criteria = {
            { 82324 },
            { 79959 },
            { 79958 }
        }
    },
    {
        name = "I Only Need One Trip",
        id = 40623,
        criteriaType = "QUESTS",
        criteria = {
            { 82580 }
        }
    },
    {
        name = "For the Collective",
        id = 40630,
        criteriaType = "QUESTS",
        criteria = {
            { 82580 }
        }
    },
    {
        name = "Hanging Tight",
        id = 40507,
        criteriaType = "QUESTS",
        criteria = {
            { 83101 }
        }
    },
    {
        name = "Children's Entertainer",
        id = 40150,
        criteriaType = "QUESTS",
        criteria = {
            { 82288 },
            { 82288 },
            { 82288 },
            { 82288 },
            { 82288 },
            { 82288 },
            { 82288 },
            { 82288 }
        }
    },
    {
        name = "Mine Poppin'",
        id = 40843,
        criteriaType = "QUESTS",
        criteria = {
            { 82468 }
        }
    },
    {
        name = "Never Enough",
        id = 40082,
        criteriaType = "QUESTS",
        criteria = {
            { 82120 }
        }
    },
    {
        name = "A Champion's Tour: The War Within",
        id = 40088,
        criteriaType = "QUESTS",
        criteria = {
            { 80395 },
            { 80394 },
            { 80208 },
            { 80323 },
            { 80412 },
            { 81622 },
            { 80409 },
            { 80457 }
        }
    },
    {
        name = "Unbound Battle",
        id = 40087,
        criteriaType = "QUESTS",
        criteria = {
            { 80395 },
            { 80394 },
            { 80208 },
            { 80323 },
            { 80412 },
            { 81622 },
            { 80409 },
            { 80457 }
        }
    },
    {
        name = "Battle on Khaz Algar",
        id = 40153,
        criteriaType = "QUESTS",
        criteria = {
            { 82291 }, -- Awakened Custodian
            { 82300 }, -- Haywire Servobot
            { 82298 }, -- Guttergunk
            { 82292 }, -- Collector Dyna
            { 82297 }, -- Zadeu
            { 82293 }, -- Friendhaver Grem
            { 82294 }, -- Kyrie
            { 82295 }  -- Ziriak
        }
    }
}

-- Miscellaneous
data.miscellaneous = {
    {
        name = "Special Assignment",
        criteriaType = "AREA_POI",
        criteria = {
            { AreaPoiID = 7823, MapId = 2248 }, -- Special Assignment: Cinderbee Surge
            { AreaPoiID = 7824, MapId = 2248 }, -- Special Assignment: Titanic Resurgence
            { AreaPoiID = 7825, MapId = 2214 }, -- Special Assignment: Shadows Below
            { AreaPoiID = 7826, MapId = 2214 }, -- Special Assignment: When the Deeps Stir
            { AreaPoiID = 7827, MapId = 2215 }, -- Special Assignment: Lynx Rescue
            { AreaPoiID = 7828, MapId = 2215 }, -- Special Assignment: Rise of the Colossals
            { AreaPoiID = 7829, MapId = 2255 }, -- Special Assignment: Bombs from Behind
            { AreaPoiID = 7830, MapId = 2255 }, -- Special Assignment: A Pound of Cure
            { AreaPoiID = 7886, MapId = 2248 }, -- Special Assignment: Titanic Resurgence
            { AreaPoiID = 7887, MapId = 2248 }  -- Special Assignment: Titanic Resurgence
        }
    },
}
