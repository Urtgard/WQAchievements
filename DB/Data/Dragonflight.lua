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
            { 67005 },
            { 70209 },
            { 70439 },
            { 69949 }
        }
    },
    {
        name = "A Champion's Tour: Dragon Isles",
        id = 16590,
        criteriaType = "QUESTS",
        criteria = {
            { 67005 },
            { 70209 },
            { 70439 },
            { 69949 }
        }
    },
    {
        name = "A Champion's Pursuit",
        id = 16599,
        criteriaType = "QUESTS",
        criteria = {
            { 72008 },
            { 72058 },
            { 72019 },
            { 71225 }
        }
    },
    {
        name = "Wildlife Photographer",
        id = 16560,
        criteriaType = "QUESTS",
        criteria = {
            { 70075, 70632 },
            { 70079, 70659 },
            { 70100 },
            { 70110, 70699 }
        }
    },
    {
        name = "A Legendary Album",
        id = 16570,
        criteriaType = "QUESTS",
        criteria = {
            { 70075 },
            { 70632 },
            { 70100 },
            { 70659 },
            { 70110 },
            { 70079 },
            { 70699 }
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
    },
    -- Grand Hunt
    {
        name = "Hunt Master",
        id = 16540,
        criteriaType = "AREA_POI",
        criteria = {
            { AreaPoiId = 7342, MapId = 1978 },
            { AreaPoiId = 7342, MapId = 1978 },
            { AreaPoiId = 7342, MapId = 1978 },
            { AreaPoiId = 7343, MapId = 1978 },
            { AreaPoiId = 7343, MapId = 1978 },
            { AreaPoiId = 7343, MapId = 1978 },
            { AreaPoiId = 7345, MapId = 1978 },
            { AreaPoiId = 7345, MapId = 1978 },
            { AreaPoiId = 7345, MapId = 1978 },
            { AreaPoiId = 7344, MapId = 1978 },
            { AreaPoiId = 7344, MapId = 1978 }
        }
    },
    {
        name = "The Disgruntled Hunter",
        id = 16542,
        criteriaType = "AREA_POI",
        criteria = {
            { AreaPoiId = 7342, MapId = 1978 },
            { AreaPoiId = 7342, MapId = 1978 },
            { AreaPoiId = 7342, MapId = 1978 },
            { AreaPoiId = 7343, MapId = 1978 },
            { AreaPoiId = 7343, MapId = 1978 },
            { AreaPoiId = 7343, MapId = 1978 },
            { AreaPoiId = 7345, MapId = 1978 },
            { AreaPoiId = 7345, MapId = 1978 },
            { AreaPoiId = 7345, MapId = 1978 },
            { AreaPoiId = 7344, MapId = 1978 },
            { AreaPoiId = 7344, MapId = 1978 }
        }
    },
    --
    -- Primal Storms
    {
        name = "Chasing Storms in The Waking Shores",
        id = 16468,
        criteriaType = "ACHIEVEMENT",
        criteria = {
            {
                name = "Thunderstorms in The Waking Shores",
                id = 16463,
                criteriaType = "AREA_POI",
                criteria = {
                    {
                        { AreaPoiId = 7249, MapId = 2022 },
                        { AreaPoiId = 7253, MapId = 2022 },
                        { AreaPoiId = 7257, MapId = 2022 }
                    }
                },
                notAccountwide = true
            },
            {
                name = "Sandstorms in The Waking Shores",
                id = 16465,
                criteriaType = "AREA_POI",
                criteria = {
                    {
                        { AreaPoiId = 7250, MapId = 2022 },
                        { AreaPoiId = 7254, MapId = 2022 },
                        { AreaPoiId = 7258, MapId = 2022 }
                    }
                },
                notAccountwide = true
            },
            {
                name = "Firestorms in The Waking Shores",
                id = 16466,
                criteriaType = "AREA_POI",
                criteria = {
                    {
                        { AreaPoiId = 7251, MapId = 2022 },
                        { AreaPoiId = 7255, MapId = 2022 },
                        { AreaPoiId = 7259, MapId = 2022 }
                    }
                },
                notAccountwide = true
            },
            {
                name = "Snowstorms in The Waking Shores",
                id = 16467,
                criteriaType = "AREA_POI",
                criteria = {
                    {
                        { AreaPoiId = 7252, MapId = 2022 },
                        { AreaPoiId = 7256, MapId = 2022 },
                        { AreaPoiId = 7260, MapId = 2022 }
                    }
                },
                notAccountwide = true
            }
        }
    },
    {
        name = "Chasing Storms in the Ohn'ahran Plains",
        id = 16476,
        criteriaType = "ACHIEVEMENT",
        criteria = {
            {
                name = "Thunderstorms in the Ohn'ahran Plains",
                id = 16475,
                criteriaType = "AREA_POI",
                criteria = {
                    {
                        { AreaPoiId = 7221, MapId = 2023 },
                        { AreaPoiId = 7225, MapId = 2023 }
                    }
                },
                notAccountwide = true
            },
            {
                name = "Sandstorms in the Ohn'ahran Plains",
                id = 16477,
                criteriaType = "AREA_POI",
                criteria = {
                    {
                        { AreaPoiId = 7222, MapId = 2023 },
                        { AreaPoiId = 7226, MapId = 2023 }
                    }
                },
                notAccountwide = true
            },
            {
                name = "Firestorms in the Ohn'ahran Plains",
                id = 16478,
                criteriaType = "AREA_POI",
                criteria = {
                    {
                        { AreaPoiId = 7223, MapId = 2023 },
                        { AreaPoiId = 7227, MapId = 2023 }
                    }
                },
                notAccountwide = true
            },
            {
                name = "Snowstorms in the Ohn'ahran Plains",
                id = 16479,
                criteriaType = "AREA_POI",
                criteria = {
                    {
                        { AreaPoiId = 7224, MapId = 2023 },
                        { AreaPoiId = 7228, MapId = 2023 }
                    }
                },
                notAccountwide = true
            }
        }
    },
    {
        name = "Chasing Storms in The Azure Span",
        id = 16484,
        criteriaType = "ACHIEVEMENT",
        criteria = {
            {
                name = "Thunderstorms in The Azure Span",
                id = 16480,
                criteriaType = "AREA_POI",
                criteria = {
                    {
                        { AreaPoiId = 7237, MapId = 2024 },
                        { AreaPoiId = 7233, MapId = 2024 },
                        { AreaPoiId = 7229, MapId = 2024 }
                    }
                },
                notAccountwide = true
            },
            {
                name = "Sandstorms in The Azure Span",
                id = 16481,
                criteriaType = "AREA_POI",
                criteria = {
                    {
                        { AreaPoiId = 7238, MapId = 2024 },
                        { AreaPoiId = 7234, MapId = 2024 },
                        { AreaPoiId = 7230, MapId = 2024 }
                    }
                },
                notAccountwide = true
            },
            {
                name = "Firestorms in The Azure Span",
                id = 16482,
                criteriaType = "AREA_POI",
                criteria = {
                    {
                        { AreaPoiId = 7239, MapId = 2024 },
                        { AreaPoiId = 7235, MapId = 2024 },
                        { AreaPoiId = 7231, MapId = 2024 }
                    }
                },
                notAccountwide = true
            },
            {
                name = "Snowstorms in The Azure Span",
                id = 16483,
                criteriaType = "AREA_POI",
                criteria = {
                    {
                        { AreaPoiId = 7240, MapId = 2024 },
                        { AreaPoiId = 7236, MapId = 2024 },
                        { AreaPoiId = 7232, MapId = 2024 }
                    }
                },
                notAccountwide = true
            }
        }
    },
    {
        name = "Chasing Storms in Thaldraszus",
        id = 16489,
        criteriaType = "ACHIEVEMENT",
        criteria = {
            {
                name = "Thunderstorms in Thaldraszus",
                id = 16485,
                criteriaType = "AREA_POI",
                criteria = {
                    {
                        { AreaPoiId = 7298, MapId = 2025 },
                        { AreaPoiId = 7245, MapId = 2025 }
                    }
                },
                notAccountwide = true
            },
            {
                name = "Sandstorms in Thaldraszus",
                id = 16486,
                criteriaType = "AREA_POI",
                criteria = {
                    {
                        { AreaPoiId = 7299, MapId = 2025 },
                        { AreaPoiId = 7246, MapId = 2025 }
                    }
                },
                notAccountwide = true
            },
            {
                name = "Firestorms in Thaldraszus",
                id = 16487,
                criteriaType = "AREA_POI",
                criteria = {
                    {
                        { AreaPoiId = 7300, MapId = 2025 },
                        { AreaPoiId = 7247, MapId = 2025 }
                    }
                },
                notAccountwide = true
            },
            {
                name = "Snowstorms in Thaldraszus",
                id = 16488,
                criteriaType = "AREA_POI",
                criteria = {
                    {
                        { AreaPoiId = 7301, MapId = 2025 },
                        { AreaPoiId = 7248, MapId = 2025 }
                    }
                },
                notAccountwide = true
            }
        }
    },
    --
    {
        name = "Battle on the Dragon Isles",
        id = 16464,
        criteriaType = "QUESTS",
        criteria = {
            71206,
            71202,
            66588,
            71145,
            71166,
            66551,
            71140,
            71180
        }
    },
    {
        name = "Battle on the Dragon Isles II",
        id = 17406,
        criteriaType = "QUESTS",
        criteria = {
            74841,
            74838,
            74835,
            74794,
            74840,
            74837,
            74836,
            74792
        }
    },
    {
        name = "Global Swarming",
        id = 17541,
        criteriaType = "QUESTS",
        criteria = {
            73146,
            73147,
            73148,
            73149
        }
    },
    {
        name = "Battle in Zaralek Cavern",
        id = 17880,
        criteriaType = "QUESTS",
        criteria = {
            75680,
            75750,
            75834,
            75835
        }
    },
    {
        name = "Friends In Feather",
        id = 19293,
        criteriaType = "QUEST_SINGLE",
        criteria = 78370
    },
    {
        name = "Goggle Wobble",
        id = 19791,
        criteriaType = "QUESTS",
        criteria = {
            78820,
            78931,
            78616
        }
    },
    {
        name = "When a Rock is Just a Rock",
        id = 19786,
        criteriaType = "QUESTS",
        criteria = {
            { 78645, 78661, 78663 }
        }
    },
    {
        name = "Clued In",
        id = 19787,
        criteriaType = "QUESTS",
        criteria = {
            { 77424, 76587, 76734, 76739, 77362 }
        }
    },
    {
        name = "Just One More Thing",
        id = 19792,
        criteriaType = "QUESTS",
        criteria = {

            77424, -- Lost Atheneum
            76587, -- The Riverbed
            76734, -- Igira's Watch
            76739, -- Gaze of Neltharion
            76911, -- Concord Observatory
            77362  -- Winglord's Perch
        }
    },
    {
        name = "Taking From Nature",
        id = 16553,
        criteriaType = "AREA_POI",
        criteria = {
            { AreaPoiId = 7086, MapId = 2022 },
            { AreaPoiId = 7266, MapId = 2024 },
            { AreaPoiId = 7270, MapId = 2023 },
            { AreaPoiId = 7271, MapId = 2025 },
            { AreaPoiId = 7272, MapId = 2024 }
        }
    },
}

-- Pets
data.pets = {
    {
        name = "Wildfire",
        itemID = 202412,
        creatureID = 200771,
        quest = { { trackingID = 0, wqID = 73148 } }
    },
    {
        name = "Vortex",
        itemID = 202413,
        creatureID = 200769,
        quest = { { trackingID = 0, wqID = 73146 } }
    },
    {
        name = "Tremblor",
        itemID = 202411,
        creatureID = 200770,
        quest = { { trackingID = 0, wqID = 73147 } }
    },
    {
        name = "Flow",
        itemID = 202407,
        creatureID = 200772,
        quest = { { trackingID = 0, wqID = 73149 } }
    },
    {
        name = "Time-Lost Vorquin Foal",
        itemID = 193855,
        creatureID = 191298,
        quest = { { trackingID = 0, wqID = 74378 } }
    }
}

-- Toys
data.toys = {
    {
        name = "Glutinous Glitterscale Glob",
        itemID = 205688,
        quest = { { trackingID = 0, wqID = 75343 } }
    },
    {
        name = "Chasing Storm",
        itemID = 202020,
        quest = { { trackingID = 0, wqID = 74378 } }
    }
}

-- Mounts
data.mounts = {
    {
        name = "Skyskin Hornstrider",
        itemID = 192800,
        spellID = 352926,
        quest = { { trackingID = 0, wqID = 74378 } }
    }
}
