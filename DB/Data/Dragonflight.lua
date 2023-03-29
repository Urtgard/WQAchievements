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
        name = "A Legendary Album",
        id = 16570,
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
    },
    -- Grand Hunt
    {
        name = "Hunt Master",
        id = 16540,
        criteriaType = "AREA_POI",
        criteria = {
            {AreaPoiId = 7342, MapId = 1978},
            {AreaPoiId = 7342, MapId = 1978},
            {AreaPoiId = 7342, MapId = 1978},
            {AreaPoiId = 7343, MapId = 1978},
            {AreaPoiId = 7343, MapId = 1978},
            {AreaPoiId = 7343, MapId = 1978},
            {AreaPoiId = 7345, MapId = 1978},
            {AreaPoiId = 7345, MapId = 1978},
            {AreaPoiId = 7345, MapId = 1978},
            {AreaPoiId = 7344, MapId = 1978},
            {AreaPoiId = 7344, MapId = 1978}
        }
    },
    {
        name = "The Disgruntled Hunter",
        id = 16542,
        criteriaType = "AREA_POI",
        criteria = {
            {AreaPoiId = 7342, MapId = 1978},
            {AreaPoiId = 7342, MapId = 1978},
            {AreaPoiId = 7342, MapId = 1978},
            {AreaPoiId = 7343, MapId = 1978},
            {AreaPoiId = 7343, MapId = 1978},
            {AreaPoiId = 7343, MapId = 1978},
            {AreaPoiId = 7345, MapId = 1978},
            {AreaPoiId = 7345, MapId = 1978},
            {AreaPoiId = 7345, MapId = 1978},
            {AreaPoiId = 7344, MapId = 1978},
            {AreaPoiId = 7344, MapId = 1978}
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
                        {AreaPoiId = 7249, MapId = 2022},
                        {AreaPoiId = 7253, MapId = 2022},
                        {AreaPoiId = 7257, MapId = 2022}
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
                        {AreaPoiId = 7250, MapId = 2022},
                        {AreaPoiId = 7254, MapId = 2022},
                        {AreaPoiId = 7258, MapId = 2022}
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
                        {AreaPoiId = 7251, MapId = 2022},
                        {AreaPoiId = 7255, MapId = 2022},
                        {AreaPoiId = 7259, MapId = 2022}
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
                        {AreaPoiId = 7252, MapId = 2022},
                        {AreaPoiId = 7256, MapId = 2022},
                        {AreaPoiId = 7260, MapId = 2022}
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
                        {AreaPoiId = 7221, MapId = 2023},
                        {AreaPoiId = 7225, MapId = 2023}
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
                        {AreaPoiId = 7222, MapId = 2023},
                        {AreaPoiId = 7226, MapId = 2023}
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
                        {AreaPoiId = 7223, MapId = 2023},
                        {AreaPoiId = 7227, MapId = 2023}
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
                        {AreaPoiId = 7224, MapId = 2023},
                        {AreaPoiId = 7228, MapId = 2023}
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
                        {AreaPoiId = 7237, MapId = 2024},
                        {AreaPoiId = 7233, MapId = 2024},
                        {AreaPoiId = 7229, MapId = 2024}
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
                        {AreaPoiId = 7238, MapId = 2024},
                        {AreaPoiId = 7234, MapId = 2024},
                        {AreaPoiId = 7230, MapId = 2024}
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
                        {AreaPoiId = 7239, MapId = 2024},
                        {AreaPoiId = 7235, MapId = 2024},
                        {AreaPoiId = 7231, MapId = 2024}
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
                        {AreaPoiId = 7240, MapId = 2024},
                        {AreaPoiId = 7236, MapId = 2024},
                        {AreaPoiId = 7232, MapId = 2024}
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
                        {AreaPoiId = 7298, MapId = 2025},
                        {AreaPoiId = 7245, MapId = 2025}
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
                        {AreaPoiId = 7299, MapId = 2025},
                        {AreaPoiId = 7246, MapId = 2025}
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
                        {AreaPoiId = 7300, MapId = 2025},
                        {AreaPoiId = 7247, MapId = 2025}
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
                        {AreaPoiId = 7301, MapId = 2025},
                        {AreaPoiId = 7248, MapId = 2025}
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
            202458
        }
    }
}
