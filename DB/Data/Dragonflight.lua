local WQA = WQAchievements

-- Dragonflight
local data = {
    name = "Dragonflight"
}
WQA.data[10] = data

-- Achievements
data.achievements = {
    {
        name = "Malicia's Challenge",
        id = 16589,
        criteriaType = "QUESTS",
        criteria = {
            {67005},
            {70209},
            {70439},
            {69949}
        }
    },
    {
        name = "A Champion's Tour: Dragon Isles",
        id = 16590,
        criteriaType = "QUESTS",
        criteria = {
            {67005},
            {70209},
            {70439},
            {69949}
        }
    },
    {
        name = "A Champion's Pursuit",
        id = 16599,
        criteriaType = "QUESTS",
        criteria = {
            {72008},
            {72058},
            {72019},
            {71225}
        }
    },
    {
        name = "Wildlife Photographer",
        id = 16560,
        criteriaType = "QUESTS",
        criteria = {
            {70075, 70632},
            {70079, 70659},
            {70100},
            {70110, 70699}
        }
    },
    {
        name = "Legendary Photographs",
        id = 16573,
        criteriaType = "QUESTS",
        criteria = {
            {70075},
            {70632},
            {70100},
            {70659},
            {70110},
            {70079},
            {70699}
        }
    },
    {
        name = "Great Shots Galore!",
        id = 16568,
        criteriaType = "QUESTS",
        criteria = {
            {
                70075,
                70632,
                70079,
                70659,
                70100,
                70110,
                70699
            }
        }
    }
}
