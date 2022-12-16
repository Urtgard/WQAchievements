local WQA = WQAchievements

--	Legion
local data = {
    name = "Legion"
}
WQA.data[7] = data

-- Achievements
local trainer = {
    42159,
    40299,
    40277,
    42442,
    40298,
    40280,
    40282,
    41687,
    40278,
    41944,
    41895,
    40337,
    41990,
    40279,
    41860
}
local argusTrainer = {
    49041,
    49042,
    49043,
    49044,
    49045,
    49046,
    49047,
    49048,
    49049,
    49050,
    49051,
    49052,
    49053,
    49054,
    49055,
    49056,
    49057,
    49058
}

data.achievements = {
    {
        name = "Free For All, More For Me",
        id = 11474,
        criteriaType = "ACHIEVEMENT",
        criteria = {
            {id = 11475, notAccountwide = true},
            {id = 11476, notAccountwide = true},
            {id = 11477, notAccountwide = true},
            {id = 11478, notAccountwide = true}
        }
    },
    {
        name = "Family Familiar",
        id = 9696,
        criteriaType = "ACHIEVEMENT",
        criteria = {
            {id = 9686, criteriaType = "QUESTS", criteria = trainer},
            {id = 9687, criteriaType = "QUESTS", criteria = trainer},
            {id = 9688, criteriaType = "QUESTS", criteria = trainer},
            {id = 9689, criteriaType = "QUESTS", criteria = trainer},
            {id = 9690, criteriaType = "QUESTS", criteria = trainer},
            {id = 9691, criteriaType = "QUESTS", criteria = trainer},
            {id = 9692, criteriaType = "QUESTS", criteria = trainer},
            {id = 9693, criteriaType = "QUESTS", criteria = trainer},
            {id = 9694, criteriaType = "QUESTS", criteria = trainer},
            {id = 9695, criteriaType = "QUESTS", criteria = trainer}
        }
    },
    {
        name = "Family Fighter",
        id = 12100,
        criteriaType = "ACHIEVEMENT",
        criteria = {
            {id = 12089, criteriaType = "QUESTS", criteria = argusTrainer},
            {id = 12091, criteriaType = "QUESTS", criteria = argusTrainer},
            {id = 12092, criteriaType = "QUESTS", criteria = argusTrainer},
            {id = 12093, criteriaType = "QUESTS", criteria = argusTrainer},
            {id = 12094, criteriaType = "QUESTS", criteria = argusTrainer},
            {id = 12095, criteriaType = "QUESTS", criteria = argusTrainer},
            {id = 12096, criteriaType = "QUESTS", criteria = argusTrainer},
            {id = 12097, criteriaType = "QUESTS", criteria = argusTrainer},
            {id = 12098, criteriaType = "QUESTS", criteria = argusTrainer},
            {id = 12099, criteriaType = "QUESTS", criteria = argusTrainer}
        }
    },
    {name = "Battle on the Broken Isles", id = 10876},
    {
        name = "Fishing 'Round the Isles",
        id = 10598,
        criteriaType = "QUESTS",
        criteria = {
            {41612, 41613, 41270},
            41267,
            {41604, 41605, 41279},
            {41598, 41599, 41264},
            41268,
            41252,
            {41611, 41265, 41610},
            {41617, 41280, 41616},
            {41597, 41244, 41596},
            {41602, 41274, 41603},
            {41609, 41243},
            41273,
            41266,
            {41615, 41275, 41614},
            41278,
            41271,
            41277,
            41240,
            {41269, 41600, 41601},
            41253,
            41276,
            41272,
            41282,
            41283
        }
    },
    {name = "Crate Expectations", id = 11681, criteriaType = "QUEST_SINGLE", criteria = 45542},
    {name = "They See Me Rolling", id = 11607, criteriaType = "QUEST_SINGLE", criteria = 46175},
    {name = "Variety is the Spice of Life", id = 11189, criteriaType = "SPECIAL"}
}

-- Mounts
data.mounts = {
    {
        name = "Maddened Chaosrunner",
        itemID = 152814,
        spellID = 253058,
        quest = {{trackingID = 48695, wqID = 48696}}
    },
    {
        name = "Crimson Slavermaw",
        itemID = 152905,
        spellID = 253661,
        quest = {{trackingID = 49183, wqID = 47561}}
    },
    {name = "Acid Belcher", itemID = 152904, spellID = 253662, quest = {{trackingID = 48721, wqID = 48740}}},
    {name = "Vile Fiend", itemID = 152790, spellID = 243652, quest = {{trackingID = 48821, wqID = 48835}}},
    {name = "Lambent Mana Ray", itemID = 152844, spellID = 253107, quest = {{trackingID = 48705, wqID = 48725}}},
    {
        name = "Biletooth Gnasher",
        itemID = 152903,
        spellID = 253660,
        quest = {{trackingID = 48810, wqID = 48465}, {trackingID = 48809, wqID = 48467}}
    },
    -- Egg
    {
        name = "Vibrant Mana Ray",
        itemID = 152842,
        spellID = 253106,
        quest = {
            {trackingID = 48667, wqID = 48502},
            {trackingID = 48712, wqID = 48732},
            {trackingID = 48812, wqID = 48827}
        }
    },
    {
        name = "Felglow Mana Ray",
        itemID = 152841,
        spellID = 253108,
        quest = {
            {trackingID = 48667, wqID = 48502},
            {trackingID = 48712, wqID = 48732},
            {trackingID = 48812, wqID = 48827}
        }
    },
    {
        name = "Scintillating Mana Ray",
        itemID = 152840,
        spellID = 253109,
        quest = {
            {trackingID = 48667, wqID = 48502},
            {trackingID = 48712, wqID = 48732},
            {trackingID = 48812, wqID = 48827}
        }
    },
    {
        name = "Darkspore Mana Ray",
        itemID = 152843,
        spellID = 235764,
        quest = {
            {trackingID = 48667, wqID = 48502},
            {trackingID = 48712, wqID = 48732},
            {trackingID = 48812, wqID = 48827}
        }
    }
}

-- Pets
data.pets = {
    {
        name = "Grasping Manifestation",
        itemID = 153056,
        creatureID = 128159,
        quest = {{trackingID = 0, wqID = 48729}}
    },
    -- Egg
    {
        name = "Fel-Afflicted Skyfin",
        itemID = 153055,
        creatureID = 128158,
        quest = {
            {trackingID = 48667, wqID = 48502},
            {trackingID = 48712, wqID = 48732},
            {trackingID = 48812, wqID = 48827}
        }
    },
    {
        name = "Docile Skyfin",
        itemID = 153054,
        creatureID = 128157,
        quest = {
            {trackingID = 48667, wqID = 48502},
            {trackingID = 48712, wqID = 48732},
            {trackingID = 48812, wqID = 48827}
        }
    },
    -- Emissary
    {name = "Thistleleaf Adventurer", itemID = 130167, creatureID = 99389, questID = 42170, emissary = true},
    {name = "Wondrous Wisdomball", itemID = 141348, creatureID = 113827, questID = 43179, emissary = true},
    -- Treasure Master Iks'reeged
    {name = "Scraps", itemID = 146953, creatureID = 120397, questID = 45379}
}

-- Toys
data.toys = {
    {
        name = "Barrier Generator",
        itemID = 153183,
        quest = {{trackingID = 48704, wqID = 48724}, {trackingID = 48703, wqID = 48723}}
    },
    {name = "Micro-Artillery Controller", itemID = 153126, quest = {{trackingID = 0, wqID = 48829}}},
    {name = "Spire of Spite", itemID = 153124, quest = {{trackingID = 0, wqID = 48512}}},
    {name = "Yellow Conservatory Scroll", itemID = 153180, quest = {{trackingID = 48718, wqID = 48737}}},
    {name = "Red Conservatory Scroll", itemID = 153181, quest = {{trackingID = 48718, wqID = 48737}}},
    {name = "Blue Conservatory Scroll", itemID = 153179, quest = {{trackingID = 48718, wqID = 48737}}},
    {name = "Baarut the Brisk", itemID = 153193, quest = {{trackingID = 0, wqID = 48701}}},
    -- Treasure Master Iks'reeged
    {name = "Pilfered Sweeper", itemID = 147867, questID = 45379}
}

-- Terrors of the Shore
-- Commander of Argus
