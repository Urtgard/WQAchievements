local WQA = WQAchievements

-- Shadowlands
local data = {
    name = _G.EXPANSION_NAME8
}
WQA.data[9] = data

-- Achievements
local trainer = {
    61883,
    61885,
    61886,
    61867,
    61868,
    61866,
    61787,
    61791,
    61784,
    61946,
    61948
}

data.achievements = {
    {name = "Tea Tales", id = 14233, criteriaType = "QUESTS", criteria = {59848, 59850, 59852, 59853}},
    {name = "Something's Not Quite Right....", id = 14671, criteriaType = "QUEST_SINGLE", criteria = 60739},
    {name = "A Bit of This, A Bit of That", id = 14672, criteriaType = "QUEST_SINGLE", criteria = 60475},
    {name = "Flight School Graduate", id = 14735, criteriaType = "QUESTS", criteria = {60844, 60858, 60911}},
    {
        name = "What Bastion Remembered",
        id = 14737,
        criteriaType = "QUEST_SINGLE",
        criteria = {
            59717,
            59705
        }
    },
    {name = "Aerial Ace", id = 14741, criteriaType = "QUEST_SINGLE", criteria = 60911},
    {name = "Breaking the Stratus Fear", id = 14762, criteriaType = "QUEST_SINGLE", criteria = 60858},
    {name = "Ramparts Racer", id = 14765, criteriaType = "QUEST_SINGLE", criteria = 59643},
    {name = "Parasoling", id = 14766, criteriaType = "QUEST_SINGLE", criteria = 59718},
    {name = "Caught in a Bat Romance", id = 14772, criteriaType = "QUEST_SINGLE", criteria = 60602},
    {name = "Friend of Ooz", id = 15055, criteriaType = "QUEST_SINGLE", criteria = 64016},
    {name = "Friend of Bloop", id = 15056, criteriaType = "QUEST_SINGLE", criteria = 64017},
    {name = "Friend of Plaguey", id = 15057, criteriaType = "QUEST_SINGLE", criteria = 63989},
    {
        name = "Battle in the Shadowlands",
        id = 14625,
        criteriaType = "QUESTS",
        criteria = {
            61949,
            61948,
            61947,
            61946,
            61886,
            61885,
            61883, -- Sylla
            61879,
            61870,
            61868,
            61867, -- Rotgut
            61866,
            61791,
            61787, -- Zolla
            61784,
            61783
        }
    },
    {
        name = "Adventures: Into the Breach",
        id = 14844,
        criteriaType = "MISSION_TABLE",
        criteria = {{2296, 2250}, {2251, 2297}, {2252, 2298}, {2299, 2253}, 2254, 2255, 2256, 2258, 2259, 2260}
    },
    {
        name = "Impressing Zo'Sorg",
        id = 14516,
        criteriaType = "QUESTS",
        criteria = {
            {59658},
            {59803},
            {59825},
            {60231}
        }
    },
    {
        name = "The World Beyond",
        id = 14758,
        criteriaType = "SPECIAL"
    },
    {
        name = "Family Exorcist",
        id = 14879,
        criteriaType = "ACHIEVEMENT",
        criteria = {
            {id = 14868, criteriaType = "QUESTS", criteria = trainer},
            {id = 14869, criteriaType = "QUESTS", criteria = trainer},
            {id = 14870, criteriaType = "QUESTS", criteria = trainer},
            {id = 14871, criteriaType = "QUESTS", criteria = trainer},
            {id = 14872, criteriaType = "QUESTS", criteria = trainer},
            {id = 14873, criteriaType = "QUESTS", criteria = trainer},
            {id = 14874, criteriaType = "QUESTS", criteria = trainer},
            {id = 14875, criteriaType = "QUESTS", criteria = trainer},
            {id = 14876, criteriaType = "QUESTS", criteria = trainer},
            {id = 14877, criteriaType = "QUESTS", criteria = trainer}
        }
    }
}

-- Pets
data.pets = {
    {name = "Dal", itemID = 183859, creatureID = 171136, quest = {{trackingID = 0, wqID = 60655}}},
    {name = "Carpal", itemID = 183114, creatureID = 173847, source = {type = "ITEM", itemID = 183111}},
    {name = "Primordial Bogling", itemID = 180588, creatureID = 171121, quest = {{trackingID = 0, wqID = 59808}}}
}

-- Toys
data.toys = {
    {name = "Tithe Collector's Vessel", itemID = 180947, source = {type = "ITEM", itemID = 180947}},
    {name = "Gormling in a Bag", itemID = 184487, source = {type = "ITEM", itemID = 184487}}
}
