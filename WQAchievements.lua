---@class WQAchievements
local WQA = WQAchievements

local LibQTip = LibStub("LibQTip-1.0")

-- Blizzard
local IsActive = C_TaskQuest.IsActive
local GetQuestTagInfo = C_QuestLog.GetQuestTagInfo
local GetBountiesForMapID = C_QuestLog.GetBountiesForMapID
local GetTitleForQuestID = C_QuestLog.GetTitleForQuestID
local GetCurrencyLink = C_CurrencyInfo.GetCurrencyLink
local IsQuestFlaggedCompleted = C_QuestLog.IsQuestFlaggedCompleted
local GetItemInfo = C_Item.GetItemInfo
local L = WQA.L

local newOrder
do
    local current = 0
    function newOrder()
        current = current + 1
        return current
    end
end

function WQA:RefreshTracking()
    -- Cancel any pending refresh
    if self.refreshTimer then
        self:CancelTimer(self.refreshTimer)
        self.refreshTimer = nil
    end

    -- 2 minute rescan — only one scan no matter how many boxes you click
    self.refreshTimer =
        self:ScheduleTimer(
        function()
            self.refreshTimer = nil
            self:CreateQuestList()
            self:Show()
        end,
        120
    )
    if WQA.PopUp and WQA.PopUp:IsShown() then
        WQA:AnnouncePopUp(WQA.activeTasks or {}, false)
    -- UpdateHScroll will be called inside AnnouncePopUp
    end
end

WQA.data.custom = {wqID = "", rewardID = "", rewardType = "none", questType = "WORLD_QUEST"}
WQA.data.custom.mission = {missionID = "", rewardID = "", rewardType = "none"}
--WQA.data.customReward = 0

local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local dataobj =
    ldb:NewDataObject(
    "WQAchievements",
    {
        type = "data source",
        text = "WQA",
        icon = "Interface\\Icons\\INV_Misc_Map06"
    }
)

local icon = LibStub("LibDBIcon-1.0")

function WQA:GetOptions()
    return self.options
end

function WQA:GetEffectiveTracking(category, id, expansionKey)
    -- Safety first – if something ridiculous is passed as expansionKey (like a function from pairs()), force it to nil
    if type(expansionKey) ~= "string" and type(expansionKey) ~= "number" then
        expansionKey = nil
    end

    local masterKey

    -- REWARDS TAB: we expect expansionKey to be a NUMBER (6-11)
    if category == "rewardCurrency" or category == "rewardItem" or category == "rewardEmissary" then
        local expNum = tonumber(expansionKey) or 7 -- default to Legion if unknown
        masterKey = category .. expNum
    else
        -- GENERAL TAB: expansionKey is a string like "Dragonflight" or the expansion number
        local key = expansionKey
        if type(key) == "number" then
            key = tostring(key)
        end
        masterKey = category .. (key or "")
    end

    local master = self.db.profile.master[masterKey]

    -- Master override
    if master and master ~= "" then
        if master == "wasEarnedByMe" then
            local hasIt = false
            if category == "achievements" then
                local _, _, _, completed = GetAchievementInfo(id)
                hasIt = completed or false
            elseif category == "mounts" then
                hasIt = C_MountJournal.GetMountInfoByID(id) ~= nil
            elseif category == "pets" then
                hasIt = C_PetJournal.GetPetInfoBySpeciesID(id) ~= nil
            elseif category == "toys" then
                hasIt = PlayerHasToy(id)
            end
            return hasIt and "disabled" or "always"
        end
        return master -- "always" or "disabled"
    end

    -- Individual override
    local individual = self.db.profile[category][id]
    if individual and individual ~= "default" then
        return individual
    end

    -- Global default
    return self.db.profile.general.defaultTracking or "default"
end

function WQA:OnInitialize()
    -- Remove data for the other faction
    local faction = UnitFactionGroup("player")
    for k, v in pairs(self.data) do
        for kk, vv in pairs(v) do
            if type(vv) == "table" then
                for kkk, vvv in pairs(vv) do
                    if vvv.faction and not (vvv.faction == faction) then
                        self.data[k][kk][kkk] = nil
                    end
                end
            end
        end
    end
    self.faction = faction
    -- Assign global static list from QuestData.lua to local addon
    self.AllWorldQuestIDs = _G["WQA"] and _G["WQA"].AllWorldQuestIDs or {}
    _G["WQA"] = nil -- Cleanup global to avoid conflicts

    -- Defaults
    local defaults = {
        char = {
            ["*"] = {
                ["profession"] = {
                    ["*"] = {
                        isMaxLevel = true
                    }
                }
            }
        },
        profile = {
            options = {
                ["*"] = true,
                chat = true,
                PopUp = false,
                popupRememberPosition = false,
                popupX = 600,
                popupY = 800,
                zone = {["*"] = true},
                reward = {
                    gear = {
                        ["*"] = true,
                        itemLevelUpgradeMin = 1,
                        PercentUpgradeMin = 1,
                        unknownSource = false,
                        azeriteTraits = "",
                        conduit = false
                    },
                    general = {
                        gold = false,
                        goldMin = 0,
                        worldQuestType = {
                            ["*"] = true
                        }
                    },
                    reputation = {["*"] = false},
                    currency = {},
                    craftingreagent = {["*"] = false},
                    ["*"] = {
                        ["*"] = true,
                        profession = {
                            ["*"] = {
                                skillup = true
                            }
                        }
                    }
                },
                emissary = {["*"] = false},
                master = {},
                missionTable = {
                    reward = {
                        gold = false,
                        goldMin = 0,
                        ["*"] = {
                            ["*"] = false
                        }
                    }
                },
                delay = 5,
                LibDBIcon = {hide = false}
            },
            ["achievements"] = {exclusive = {}, ["*"] = "default"},
            ["mounts"] = {exclusive = {}, ["*"] = "default"},
            ["pets"] = {exclusive = {}, ["*"] = "default"},
            ["toys"] = {exclusive = {}, ["*"] = "default"},
            custom = {
                ["*"] = {["*"] = true}
            },
            ["*"] = {["*"] = true}
        },
        global = {
            completed = {["*"] = false},
            custom = {
                ["*"] = {["*"] = false}
            }
        }
    }
    self.db = LibStub("AceDB-3.0"):New("WQADB", defaults, true)

    -- copy old data
    if type(self.db.global.custom) == "table" then
        for k, v in pairs(self.db.global.custom) do
            if type(k) == "number" then
                self.db.global.custom.worldQuest[k] = v
                self.db.global.custom[k] = nil
            end
        end
    end
    if type(self.db.global.customReward) == "table" then
        for k, v in pairs(self.db.global.customReward) do
            self.db.global.custom.worldQuestReward[k] = true
        end
        self.db.global.customReward = nil
    end

    self:UpdateOptions()
    -- Minimap Icon
    icon:Register("WQAchievements", dataobj, self.db.profile.options.LibDBIcon)
end

local function ShouldScan()
    if UnitAffectingCombat("player") then
        return false
    end

    local inInstance, instanceType = IsInInstance()
    if
        inInstance and
            (instanceType == "party" or instanceType == "raid" or instanceType == "scenario" or instanceType == "pvp" or
                instanceType == "arena")
     then
        return false
    end
    return true
end

local function AnythingTracked()
    -- Emissary
    if WQA.db.profile.options.emissary then
        for _, v in pairs(WQA.db.profile.options.emissary) do
            if v == true then
                return true
            end
        end
    end

    -- Mission table
    if WQA.db.profile.options.missionTable and WQA.db.profile.options.missionTable.reward then
        local r = WQA.db.profile.options.missionTable.reward
        if r.gold or (r.currency and next(r.currency)) or (r.item and next(r.item)) then
            return true
        end
    end

    -- General rewards
    if WQA.db.profile.options.reward then
        local r = WQA.db.profile.options.reward
        -- Gear
        if r.gear and next(r.gear) then
            return true
        end
        -- General (gold, worldQuestType)
        if r.general and (r.general.gold or (r.general.worldQuestType and next(r.general.worldQuestType))) then
            return true
        end
        -- Reputation
        if r.reputation and next(r.reputation) then
            return true
        end
        -- Currency
        if r.currency and next(r.currency) then
            return true
        end
        -- Crafting reagents
        if r.craftingreagent and next(r.craftingreagent) then
            return true
        end
        -- Recipe
        if r.recipe and next(r.recipe) then
            return true
        end
        -- Profession skillup
        if r.profession then
            for _, prof in pairs(r.profession) do
                if prof.skillup then
                    return true
                end
            end
        end
    end

    return false
end

-- function WQA:OnEnable()
-- local name, server = UnitFullName("player")
-- self.playerName = name .. "-" .. server

-- local addon = self -- Key fix: Capture addon object for closures

-- ------------------
-- -- Options
-- ------------------
-- LibStub("AceConfig-3.0"):RegisterOptionsTable(
-- "WQAchievements",
-- function()
-- return self:GetOptions()
-- end
-- )
-- self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("WQAchievements", "WQAchievements")
-- local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
-- LibStub("AceConfig-3.0"):RegisterOptionsTable("WQAProfiles", profiles)
-- self.optionsFrame.Profiles =
-- LibStub("AceConfigDialog-3.0"):AddToBlizOptions("WQAProfiles", "Profiles", "WQAchievements")

-- -- Event frame + throttling setup
-- self.event = CreateFrame("Frame")
-- self.event:RegisterEvent("ZONE_CHANGED_NEW_AREA")
-- self.event:RegisterEvent("PLAYER_ENTERING_WORLD")
-- self.event:RegisterEvent("GARRISON_MISSION_LIST_UPDATE")
-- self.event:RegisterEvent("QUEST_TURNED_IN")
-- self.event:RegisterEvent("PLAYER_REGEN_ENABLED") -- Keep for OOC reloads

-- -- Throttling locals (closures capture them + addon)
-- local scanFrame = CreateFrame("Frame")
-- local batchSize = 10 -- Tune: 5-20 based on FPS testing
-- local mapIDsToScan = {}
-- local currentIndex = 1

-- local function StartScan()
-- if not AnythingTracked() then
-- print("|cffff0000[WQA] Nothing tracked - scan skipped|r")
-- return
-- end
-- -- Check every time — fresh data
-- if UnitAffectingCombat("player") then
-- print("|cffff0000[WQA] Scan skipped - in combat|r")
-- return
-- end
-- local inInstance, instanceType = IsInInstance()
-- if
-- inInstance and
-- (instanceType == "party" or instanceType == "raid" or instanceType == "scenario" or
-- instanceType == "pvp" or
-- instanceType == "arena")
-- then
-- print("|cffff0000[WQA] Scan skipped - in instance (" .. (instanceType or "unknown") .. ")|r")
-- return
-- end

-- print("|cff00ff00[WQA] Starting scan...|r")
-- addon.start = GetTime()
-- currentIndex = 1
-- if addon.AllWorldQuestIDs then -- Static ID scan
-- local questIDsToScan = {}
-- for exp, ids in pairs(addon.AllWorldQuestIDs) do
-- for _, questID in ipairs(ids) do
-- table.insert(questIDsToScan, questID)
-- end
-- end
-- if #questIDsToScan > 0 then
-- scanFrame:SetScript("OnUpdate", ScanUpdate)
-- else
-- -- No IDs: Trigger post-logic
-- local now = GetTime()
-- addon:CancelTimer(addon.timer)
-- if now - addon.start > 1 then
-- addon:Reward()
-- else
-- addon:ScheduleTimer("Reward", 1)
-- end
-- end
-- else -- Fallback to old map scan
-- mapIDsToScan = {}
-- for i = 1, #addon.ZoneIDList do
-- for _, mapID in pairs(addon.ZoneIDList[i]) do
-- if addon.db.profile.options.zone[mapID] == true then
-- table.insert(mapIDsToScan, mapID)
-- end
-- end
-- end
-- if #mapIDsToScan > 0 then
-- scanFrame:SetScript(
-- "OnUpdate",
-- function(self, elapsed)
-- local processed = 0
-- while processed < batchSize and currentIndex <= #mapIDsToScan do
-- local mapID = mapIDsToScan[currentIndex]
-- local quests = C_TaskQuest.GetQuestsOnMap(mapID)
-- if quests then
-- for j = 1, #quests do
-- local questID = quests[j].questID
-- local numQuestRewards = GetNumQuestLogRewards(questID)
-- if numQuestRewards > 0 then
-- GetQuestLogRewardInfo(1, questID)
-- end
-- end
-- end
-- currentIndex = currentIndex + 1
-- processed = processed + 1
-- end
-- if currentIndex > #mapIDsToScan then
-- self:SetScript("OnUpdate", nil)
-- local now = GetTime()
-- addon:CancelTimer(addon.timer)
-- if now - addon.start > 1 then
-- addon:Reward()
-- else
-- addon:ScheduleTimer("Reward", 1)
-- end
-- end
-- end
-- )
-- else
-- -- No maps: Trigger Reward
-- local now = GetTime()
-- addon:CancelTimer(addon.timer)
-- if now - addon.start > 1 then
-- addon:Reward()
-- else
-- addon:ScheduleTimer("Reward", 1)
-- end
-- end
-- end
-- end

-- local function ScanUpdate(self, elapsed)
-- local processed = 0
-- while processed < batchSize and currentIndex <= #questIDsToScan do
-- local questID = questIDsToScan[currentIndex]
-- if C_TaskQuest.IsActive(questID) then -- Only process active
-- local numQuestRewards = GetNumQuestLogRewards(questID)
-- if numQuestRewards > 0 then
-- GetQuestLogRewardInfo(1, questID)
-- end
-- end
-- currentIndex = currentIndex + 1
-- processed = processed + 1
-- end
-- if currentIndex > #questIDsToScan then
-- self:SetScript("OnUpdate", nil)
-- -- Complete: Trigger Reward()
-- local now = GetTime()
-- addon:CancelTimer(addon.timer)
-- if now - addon.start > 1 then
-- addon:Reward()
-- else
-- addon:ScheduleTimer("Reward", 1)
-- end
-- end
-- end

-- -- Fixed OnEvent: Proper sig, addon refs, adapted original handlers (dropped log/info to avoid early triggers)
-- local function OnEvent(frame, event, questID)
-- if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
-- -- Cancel any old timer
-- if addon.timer then
-- addon:CancelTimer(addon.timer)
-- end

-- local function ShouldScan()
-- if UnitAffectingCombat("player") then
-- return false
-- end
-- local inInstance, instanceType = IsInInstance()
-- if
-- inInstance and
-- (instanceType == "party" or instanceType == "raid" or instanceType == "scenario" or
-- instanceType == "pvp" or
-- instanceType == "arena")
-- then
-- return false
-- end
-- return true
-- end

-- local doScan = AnythingTracked() and ShouldScan()

-- if doScan then
-- addon.timer = addon:ScheduleTimer(StartScan, addon.db.profile.options.delay or 5)
-- print("|cff00ff00[WQA] Fresh scan scheduled|r")
-- else
-- if not AnythingTracked() then
-- print("|cffff0000[WQA] Nothing tracked - scan skipped|r")
-- else
-- print("|cffff0000[WQA] In instance/combat - scan skipped|r")
-- end
-- end

-- -- ONLY show popup if we actually scanned
-- if doScan then
-- addon:ScheduleTimer("Show", (addon.db.profile.options.delay or 5) + 1, nil, true)
-- end

-- if event == "PLAYER_ENTERING_WORLD" then
-- addon.event:UnregisterEvent("PLAYER_ENTERING_WORLD")
-- end

-- -- 30-minute reminder (always runs — harmless if nothing new)
-- addon:ScheduleTimer(
-- function()
-- addon:Show("new", true)
-- addon:ScheduleRepeatingTimer("Show", 30 * 60, "new", true)
-- end,
-- (32 - (date("%M") % 30)) * 60
-- )
-- elseif event == "GARRISON_MISSION_LIST_UPDATE" then
-- addon:CheckMissions()
-- elseif event == "QUEST_TURNED_IN" then
-- addon.db.global.completed[questID] = true
-- elseif event == "PLAYER_REGEN_ENABLED" then
-- addon.event:UnregisterEvent("PLAYER_REGEN_ENABLED")
-- addon:Show("new", true)
-- end
-- end

-- self.event:SetScript("OnEvent", OnEvent)
-- C_AddOns.LoadAddOn("Blizzard_GarrisonUI")
-- end

function WQA:OnEnable()
    local name, server = UnitFullName("player")
    self.playerName = name .. "-" .. server

    ------------------
    -- Options
    ------------------
    LibStub("AceConfig-3.0"):RegisterOptionsTable(
        "WQAchievements",
        function()
            return self:GetOptions()
        end
    )
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("WQAchievements", "WQAchievements")
    local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
    LibStub("AceConfig-3.0"):RegisterOptionsTable("WQAProfiles", profiles)
    self.optionsFrame.Profiles =
        LibStub("AceConfigDialog-3.0"):AddToBlizOptions("WQAProfiles", "Profiles", "WQAchievements")

    -- Event frame
    self.event = CreateFrame("Frame")
    self.event:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    self.event:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.event:RegisterEvent("GARRISON_MISSION_LIST_UPDATE")
    self.event:RegisterEvent("QUEST_TURNED_IN")
    self.event:RegisterEvent("PLAYER_REGEN_ENABLED")

    -- Throttling
    local scanFrame = CreateFrame("Frame")
    local batchSize = 10
    local currentIndex = 1
    local questIDsToScan = {}

    local function StartScan()
        if not AnythingTracked() then
            print("|cffff0000[WQA] Nothing tracked - scan skipped|r")
            return
        end
        if UnitAffectingCombat("player") then
            print("|cffff0000[WQA] Scan skipped - in combat|r")
            return
        end
        local inInstance, instanceType = IsInInstance()
        if
            inInstance and
                (instanceType == "party" or instanceType == "raid" or instanceType == "scenario" or
                    instanceType == "pvp" or
                    instanceType == "arena")
         then
            print("|cffff0000[WQA] Scan skipped - in instance (" .. (instanceType or "unknown") .. ")|r")
            return
        end

        print("|cff00ff00[WQA] Starting scan...|r")
        self.start = GetTime()
        currentIndex = 1
        questIDsToScan = {}

        if self.AllWorldQuestIDs then
            for _, ids in pairs(self.AllWorldQuestIDs) do
                for _, questID in ipairs(ids) do
                    table.insert(questIDsToScan, questID)
                end
            end
        end

        if #questIDsToScan > 0 then
            scanFrame:SetScript(
                "OnUpdate",
                function(self, elapsed)
                    local processed = 0
                    while processed < batchSize and currentIndex <= #questIDsToScan do
                        local questID = questIDsToScan[currentIndex]
                        if C_TaskQuest.IsActive(questID) then
                            local numQuestRewards = GetNumQuestLogRewards(questID)
                            if numQuestRewards > 0 then
                                GetQuestLogRewardInfo(1, questID)
                            end
                        end
                        currentIndex = currentIndex + 1
                        processed = processed + 1
                    end
                    if currentIndex > #questIDsToScan then
                        self:SetScript("OnUpdate", nil)
                        local now = GetTime()
                        WQA:CancelTimer(WQA.timer) -- ← FIXED: WQA:CancelTimer
                        if now - WQA.start > 1 then
                            WQA:Reward()
                        else
                            WQA:ScheduleTimer("Reward", 1)
                        end
                    end
                end
            )
        else
            local now = GetTime()
            WQA:CancelTimer(WQA.timer) -- ← FIXED: WQA:CancelTimer
            if now - WQA.start > 1 then
                WQA:Reward()
            else
                WQA:ScheduleTimer("Reward", 1)
            end
        end
    end

    local function OnEvent(frame, event, questID)
        if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
            if WQA.timer then
                WQA:CancelTimer(WQA.timer) -- ← FIXED: WQA:CancelTimer
            end
            local doScan = AnythingTracked() and not UnitAffectingCombat("player")
            local inInstance, instanceType = IsInInstance()
            if
                inInstance and
                    (instanceType == "party" or instanceType == "raid" or instanceType == "scenario" or
                        instanceType == "pvp" or
                        instanceType == "arena")
             then
                doScan = false
            end

            if doScan then
                WQA.timer = WQA:ScheduleTimer(StartScan, WQA.db.profile.options.delay or 5)
                print("|cff00ff00[WQA] Fresh scan scheduled|r")
            else
                if not AnythingTracked() then
                    print("|cffff0000[WQA] Nothing tracked - scan skipped|r")
                else
                    print("|cffff0000[WQA] In instance/combat - scan skipped|r")
                end
            end

            if doScan then
                WQA:ScheduleTimer("Show", (WQA.db.profile.options.delay or 5) + 1, nil, true)
            end

            if event == "PLAYER_ENTERING_WORLD" then
                WQA.event:UnregisterEvent("PLAYER_ENTERING_WORLD")
            end

            WQA:ScheduleTimer(
                function()
                    WQA:Show("new", true)
                    WQA:ScheduleRepeatingTimer("Show", 30 * 60, "new", true)
                end,
                (32 - (date("%M") % 30)) * 60
            )
        elseif event == "GARRISON_MISSION_LIST_UPDATE" then
            WQA:CheckMissions()
        elseif event == "QUEST_TURNED_IN" then
            WQA.db.global.completed[questID] = true
        elseif event == "PLAYER_REGEN_ENABLED" then
            WQA.event:UnregisterEvent("PLAYER_REGEN_ENABLED")
            WQA:Show("new", true)
        end
    end

    self.event:SetScript("OnEvent", OnEvent)
    C_AddOns.LoadAddOn("Blizzard_GarrisonUI")
end

WQA:RegisterChatCommand("wqa", "slash")
function WQA:slash(input)
    local arg1 = string.lower(input or "")
    if not ShouldScan() then
        print("|cffff0000[WQA] Scan skipped - in instance or combat|r")
        return
    end

    if not AnythingTracked() then
        print("|cffff0000[WQA] Nothing tracked - no scan|r")
        return
    end

    if arg1 == "" then
        self:Show()
    elseif arg1 == "new" then
        self:Show("new")
    elseif arg1 == "popup" then
        self:Show("popup")
    end
end

function WQA:CreateQuestList()
    self:Debug("CreateQuestList")
    self.questList = {}
    self.questPinList = {}
    self.questPinMapList = {}
    self.missionList = {}
    self.questFlagList = {}
    self.Criterias.AreaPoi.list = {}

    for expansionID = 7, 11 do
        local data = self.data[expansionID]

        if (data.achievements) then
            for _, v in pairs(data.achievements) do
                self.Achievements:Register(v)
            end
        end

        if (data.mounts) then
            self:AddMounts(data.mounts)
        end

        if (data.pets) then
            self:AddPets(data.pets)
        end

        if (data.toys) then
            self:AddToys(data.toys)
        end

        if (data.miscellaneous) then
        --  self:AddMiscellaneous(data.miscellaneous)
        end
    end

    self:AddCustom()
    self:Special()
    self:Reward()
    self:EmissaryReward()
end

function WQA:AddMounts(mounts)
    for i, id in pairs(C_MountJournal.GetMountIDs()) do
        local n, spellID, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(id)

        local track = self:GetEffectiveTracking("mounts", spellID, "Dragonflight") -- Change "Dragonflight" to match your master key if different

        -- Skip if disabled or exclusive belongs to another character I/O
        if track == "disabled" then
            -- do nothing
        elseif track == "exclusive" and self.db.profile.mounts.exclusive[spellID] ~= self.playerName then
            -- do nothing — someone else has exclusive lock
        else
            local forced = (track == "always" or track == "exclusive")
            if not isCollected or forced then
                for _, mount in pairs(mounts) do
                    if spellID == mount.spellID then
                        for _, v in pairs(mount.quest) do
                            if not IsQuestFlaggedCompleted(v.trackingID or 0) then
                                self:AddRewardToQuest(v.wqID, "CHANCE", mount.itemID)
                            end
                        end
                    end
                end
            end
        end
    end
end

function WQA:AddPets(pets)
    local total = C_PetJournal.GetNumPets()
    for i = 1, total do
        local petID, _, owned, _, _, _, _, _, _, _, companionID = C_PetJournal.GetPetInfoByIndex(i)
        local track = self:GetEffectiveTracking("pets", companionID, "Dragonflight")

        if track ~= "disabled" then
            local forced = (track == "always" or track == "exclusive")
            if not owned or forced then
                for _, pet in pairs(pets) do
                    if companionID == pet.creatureID then
                        if pet.emissary == true then
                            self:AddEmissaryReward(pet.questID, "CHANCE", pet.itemID)
                        end
                        if pet.source and pet.source.type == "ITEM" then
                            self.itemList[pet.source.itemID] = true
                        end
                        if pet.questID then
                            self:AddRewardToQuest(pet.questID, "CHANCE", pet.itemID)
                        end
                        if pet.quest then
                            for _, v in pairs(pet.quest) do
                                if not IsQuestFlaggedCompleted(v.trackingID) then
                                    self:AddRewardToQuest(v.wqID, "CHANCE", pet.itemID)
                                end
                            end
                        end
                        break
                    end
                end
            end
        end
    end
end

function WQA:AddToys(toys)
    for _, toy in pairs(toys) do
        local itemID = toy.itemID
        local track = self:GetEffectiveTracking("toys", itemID, "Dragonflight")

        if track ~= "disabled" then
            local forced = (track == "always" or track == "exclusive")
            if not PlayerHasToy(toy.itemID) or forced then
                if toy.source and toy.source.type == "ITEM" then
                    self.itemList[toy.source.itemID] = true
                else
                    if toy.questID then
                        self:AddRewardToQuest(toy.questID, "CHANCE", toy.itemID)
                    else
                        for _, v in pairs(toy.quest) do
                            if not IsQuestFlaggedCompleted(v.trackingID) then
                                self:AddRewardToQuest(v.wqID, "CHANCE", toy.itemID)
                            end
                        end
                    end
                end
            end
        end
    end
end

function WQA:AddCustom()
    -- Custom World Quests
    if type(self.db.global.custom.worldQuest) == "table" then
        for questID, v in pairs(self.db.global.custom.worldQuest) do
            if self.db.profile.custom.worldQuest[questID] == true then
                self:AddRewardToQuest(questID, "CUSTOM")
                if v.questType == "QUEST_FLAG" then
                    self.questFlagList[questID] = true
                elseif v.questType == "QUEST_PIN" and v.mapID then
                    C_QuestLine.RequestQuestLinesForMap(v.mapID)
                    self.questPinMapList[v.mapID] = true
                    self.questPinList[questID] = true
                end
            end
        end
    end

    -- Custom Missions
    if type(self.db.global.custom.mission) == "table" then
        for k, v in pairs(self.db.global.custom.mission) do
            if self.db.profile.custom.mission[k] == true then
                self:AddRewardToMission(k, "CUSTOM")
            end
        end
    end
end

function WQA:AddRewardToMission(missionID, rewardType, reward)
    if not self.missionList[missionID] then
        self.missionList[missionID] = {}
    end
    local l = self.missionList[missionID]

    self:AddReward(l, rewardType, reward)
end

function WQA:AddRewardToQuest(questID, rewardType, reward, emissary)
    if not self.questList[questID] then
        self.questList[questID] = {}
    end
    local l = self.questList[questID]

    self:AddReward(l, rewardType, reward, emissary)
end

function WQA:AddEmissaryReward(questID, rewardType, reward)
    self:AddRewardToQuest(questID, rewardType, reward, true)
end

WQA.first = false
function WQA:Show(mode, auto)
    if auto and self.db.profile.options.delayCombat == true and UnitAffectingCombat("player") then
        self.event:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end
    self:Debug("Show", mode)
    self:CreateQuestList()
    self:CheckWQ(mode)
    self.first = true
end

function WQA:CheckWQ(mode)
    local addon = self
    addon:Debug("CheckWQ")
    if addon.rewards ~= true or addon.emissaryRewards ~= true then
        addon:Debug("NoRewards")
        addon:ScheduleTimer("CheckWQ", 0.4, mode)
        return
    end
    -- Throttling setup for questList loop
    local checkFrame = CreateFrame("Frame")
    local batchSize = 5 -- Low for smooth FPS; tune 3-10 based on typical #questList
    local questIDsToProcess = {}
    local currentIndex = 1
    local activeQuests = {}
    local newQuests = {}
    local overallRetry = false
    -- Flatten questList keys (fast, since questList is likely <100)
    for questID in pairs(addon.questList) do
        table.insert(questIDsToProcess, questID)
    end
    local function CheckUpdate(frame, elapsed)
        local processed = 0
        local batchRetry = false
        while processed < batchSize and currentIndex <= #questIDsToProcess do
            local questID = questIDsToProcess[currentIndex]
            if
                IsActive(questID) or addon:EmissaryIsActive(questID) or addon:isQuestPinActive(questID) or
                    addon:IsQuestFlaggedCompleted(questID)
             then
                local questLink = addon:GetTaskLink({id = questID, type = "WORLD_QUEST"})
                local linkMissing = false -- Track per quest
                for k, v in pairs(addon.questList[questID].reward) do
                    local link
                    if k == "custom" or k == "professionSkillup" or k == "gold" then
                        link = true
                    else
                        link = addon:GetRewardLinkByID(questID, k, v, 1)
                    end
                    if not link then
                        addon:Debug(questID, k, v, 1)
                        batchRetry = true
                    else
                        addon:SetRewardLinkByID(questID, k, v, 1, link)
                    end
                    if k == "achievement" or k == "chance" or k == "azeriteTraits" then
                        for i = 2, #v do
                            link = addon:GetRewardLinkByID(questID, k, v, i)
                            if not link then
                                addon:Debug(questID, k, v, i)
                                batchRetry = true
                            else
                                addon:SetRewardLinkByID(questID, k, v, i, link)
                            end
                        end
                    end
                    if not link then
                        linkMissing = true
                    end
                end
                if not questLink or linkMissing then
                    addon:Debug(questID, questLink, "link missing")
                    batchRetry = true
                else
                    activeQuests[questID] = true
                    if not addon.watched[questID] then
                        newQuests[questID] = true
                    end
                end
            end
            currentIndex = currentIndex + 1
            processed = processed + 1
        end
        overallRetry = overallRetry or batchRetry
        if currentIndex > #questIDsToProcess then
            frame:SetScript("OnUpdate", nil)
            -- Quests done: Now handle missions (chunk if many; assume <50 for now)
            local activeMissions = addon:CheckMissions()
            local newMissions = {}
            local missionsRetry = false
            if type(activeMissions) == "table" then
                for missionID in pairs(activeMissions) do
                    local linkMissing = false
                    for k, v in pairs(addon.missionList[missionID].reward) do
                        local link
                        if k == "custom" or k == "professionSkillup" or k == "gold" then
                            link = true
                        else
                            link = addon:GetRewardLinkByMissionID(missionID, k, v, 1)
                        end
                        if not link then
                            missionsRetry = true
                        else
                            addon:SetRewardLinkByMissionID(missionID, k, v, 1, link)
                        end
                    end
                    if linkMissing then
                        missionsRetry = true
                    else
                        if not addon.watchedMissions[missionID] then
                            newMissions[missionID] = true
                        end
                    end
                end
            else
                missionsRetry = true
            end
            overallRetry = overallRetry or missionsRetry
            -- POIs (single call, no chunk)
            local pois = addon.Criterias.AreaPoi:Check()
            if pois.retry then
                overallRetry = true
            end
            if overallRetry then
                addon:Debug("NoLink")
                addon:ScheduleTimer("CheckWQ", 1, mode)
                return
            end
            -- Build tables
            addon.activeTasks = {}
            for id in pairs(activeQuests) do
                table.insert(addon.activeTasks, {id = id, type = "WORLD_QUEST"})
            end
            for id in pairs(activeMissions) do
                table.insert(addon.activeTasks, {id = id, type = "MISSION"})
            end
            for poiId, mapIds in pairs(pois.active) do
                for mapId in pairs(mapIds) do
                    table.insert(addon.activeTasks, {id = poiId, mapId = mapId, type = "AREA_POI"})
                end
            end
            addon.activeTasks = addon:SortQuestList(addon.activeTasks)
            addon.newTasks = {}
            for id in pairs(newQuests) do
                addon.watched[id] = true
                table.insert(addon.newTasks, {id = id, type = "WORLD_QUEST"})
            end
            for id in pairs(newMissions) do
                addon.watchedMissions[id] = true
                table.insert(addon.newTasks, {id = id, type = "MISSION"})
            end
            for poiId, mapIds in pairs(pois.new) do
                for mapId in pairs(mapIds) do
                    if not addon.Criterias.AreaPoi.watched[poiId] then
                        addon.Criterias.AreaPoi.watched[poiId] = {}
                    end
                    addon.Criterias.AreaPoi.watched[poiId][mapId] = true
                    table.insert(addon.newTasks, {id = poiId, mapId = mapId, type = "AREA_POI"})
                end
            end
            -- Announce based on mode
            if mode == "new" then
                addon:AnnounceChat(addon.newTasks, addon.first)
                if addon.db.profile.options.PopUp == true then
                    addon:AnnouncePopUp(addon.newTasks, addon.first)
                end
            elseif mode == "popup" then
                addon:AnnouncePopUp(addon.activeTasks)
            elseif mode == "LDB" then
                addon:AnnounceLDB(addon.activeTasks)
            else
                addon:AnnounceChat(addon.activeTasks)
                if addon.db.profile.options.PopUp == true then
                    addon:AnnouncePopUp(addon.activeTasks)
                end
            end
            addon:UpdateLDBText(next(addon.activeTasks), next(addon.newTasks))
        end
    end
    -- Start chunking if quests exist
    if #questIDsToProcess > 0 then
        checkFrame:SetScript("OnUpdate", CheckUpdate)
    else
        -- No quests: Handle missions/pois immediately (rare)
        local activeMissions = addon:CheckMissions()
        local newMissions = {}
        local missionsRetry = false
        if type(activeMissions) == "table" then
            for missionID in pairs(activeMissions) do
                local linkMissing = false
                for k, v in pairs(addon.missionList[missionID].reward) do
                    local link
                    if k == "custom" or k == "professionSkillup" or k == "gold" then
                        link = true
                    else
                        link = addon:GetRewardLinkByMissionID(missionID, k, v, 1)
                    end
                    if not link then
                        missionsRetry = true
                    else
                        addon:SetRewardLinkByMissionID(missionID, k, v, 1, link)
                    end
                end
                if linkMissing then
                    missionsRetry = true
                else
                    if not addon.watchedMissions[missionID] then
                        newMissions[missionID] = true
                    end
                end
            end
        else
            missionsRetry = true
        end
        overallRetry = overallRetry or missionsRetry
        -- POIs (single call, no chunk)
        local pois = addon.Criterias.AreaPoi:Check()
        if pois.retry then
            overallRetry = true
        end
        if overallRetry then
            addon:Debug("NoLink")
            addon:ScheduleTimer("CheckWQ", 1, mode)
            return
        end
        -- Build tables
        addon.activeTasks = {}
        for id in pairs(activeQuests) do
            table.insert(addon.activeTasks, {id = id, type = "WORLD_QUEST"})
        end
        for id in pairs(activeMissions) do
            table.insert(addon.activeTasks, {id = id, type = "MISSION"})
        end
        for poiId, mapIds in pairs(pois.active) do
            for mapId in pairs(mapIds) do
                table.insert(addon.activeTasks, {id = poiId, mapId = mapId, type = "AREA_POI"})
            end
        end
        addon.activeTasks = addon:SortQuestList(addon.activeTasks)
        addon.newTasks = {}
        for id in pairs(newQuests) do
            addon.watched[id] = true
            table.insert(addon.newTasks, {id = id, type = "WORLD_QUEST"})
        end
        for id in pairs(newMissions) do
            addon.watchedMissions[id] = true
            table.insert(addon.newTasks, {id = id, type = "MISSION"})
        end
        for poiId, mapIds in pairs(pois.new) do
            for mapId in pairs(mapIds) do
                if not addon.Criterias.AreaPoi.watched[poiId] then
                    addon.Criterias.AreaPoi.watched[poiId] = {}
                end
                addon.Criterias.AreaPoi.watched[poiId][mapId] = true
                table.insert(addon.newTasks, {id = poiId, mapId = mapId, type = "AREA_POI"})
            end
        end
        -- Announce based on mode
        if mode == "new" then
            addon:AnnounceChat(addon.newTasks, addon.first)
            if addon.db.profile.options.PopUp == true then
                addon:AnnouncePopUp(addon.newTasks, addon.first)
            end
        elseif mode == "popup" then
            addon:AnnouncePopUp(addon.activeTasks)
        elseif mode == "LDB" then
            addon:AnnounceLDB(addon.activeTasks)
        else
            addon:AnnounceChat(addon.activeTasks)
            if addon.db.profile.options.PopUp == true then
                addon:AnnouncePopUp(addon.activeTasks)
            end
        end
        addon:UpdateLDBText(next(addon.activeTasks), next(addon.newTasks))
    end
end

function WQA:link(x)
    if not x then
        return ""
    end
    local t = string.upper(x.type)
    if t == "ACHIEVEMENT" then
        return GetAchievementLink(x.id)
    elseif t == "ITEM" then
        return select(2, GetItemInfo(x.id))
    else
        return ""
    end
end

function WQA:GetRewardForID(questID, key, type)
    local l
    if type == "MISSION" then
        l = self.missionList[questID].reward
    else
        l = self.questList[questID].reward
    end

    local r = ""
    if l then
        if l.item then
            if l.item then
                if l.item.transmog then
                    r = r .. l.item.transmog
                end
                if l.item.itemLevelUpgrade then
                    if r ~= "" then
                        r = r .. " "
                    end
                    r = r .. "|cFF00FF00+" .. l.item.itemLevelUpgrade .. " iLvl|r"
                end
                if l.item.itemPercentUpgrade then
                    if r ~= "" then
                        r = r .. ", "
                    end
                    r = r .. "|cFF00FF00+" .. l.item.itemPercentUpgrade .. "%|r"
                end
                if l.item.AzeriteArmorCache then
                    for i = 1, 5, 2 do
                        local upgrade = l.item.AzeriteArmorCache[i]
                        if upgrade > 0 then
                            r = r .. "|cFF00FF00+" .. upgrade .. " iLvl|r"
                        elseif upgrade < 0 then
                            r = r .. "|cFFFF0000" .. upgrade .. " iLvl|r"
                        else
                            r = r .. "±" .. upgrade
                        end
                        if i ~= 5 then
                            r = r .. " / "
                        end
                    end
                end
                if l.item.cache then
                    local cache = l.item.cache
                    local upgradeChance = cache.upgradeNum / cache.n
                    upgradeChance = 1 / 2 * upgradeChance + .5
                    upgradeChance = string.format("%X", (1 - upgradeChance) * 255)
                    if string.len(upgradeChance) == 1 then
                        upgradeChance = "0" .. upgradeChance
                    end
                    r =
                        r ..
                        "|cFF" ..
                            upgradeChance ..
                                "FF" ..
                                    upgradeChance ..
                                        cache.upgradeNum .. "/" .. cache.n .. " max +" .. cache.upgradeMax .. "|r"
                    local item = {
                        itemLink = itemLink,
                        cache = {upgradeNum = upgradeNum, n = n, upgradeMax = upgradeMax}
                    }
                end
            end
            r = l.item.itemLink .. " " .. r
        end
        if l.currency and key ~= "item" then
            r = r .. l.currency.amount .. " " .. l.currency.name
        end
    end
    return r
end

function WQA:AnnounceChat(tasks, silent)
    if self.db.profile.options.chat == false then
        return
    end
    if next(tasks) == nil then
        if silent ~= true then
            print(L["NO_QUESTS"])
        end
        return
    end

    local output = L["WQChat"]
    print(output)
    local expansion, zoneID
    for _, task in ipairs(tasks) do
        local text, i = "", 0

        if self.db.profile.options.chatShowExpansion == true then
            if self:GetExpansion(task) ~= expansion then
                expansion = self:GetExpansion(task)
                print(self:GetExpansionName(expansion))
            end
        end

        if self.db.profile.options.chatShowZone == true then
            if self:GetTaskZoneID(task) ~= zoneID then
                zoneID = self:GetTaskZoneID(task)
                print(self:GetTaskZoneName(task))
            end
        end

        local l
        if task.type == "WORLD_QUEST" then
            l = self.questList[task.id]
        elseif task.type == "MISSION" then
            l = self.missionList[task.id]
        elseif task.type == "AREA_POI" then
            l = self.Criterias.AreaPoi.list[task.id][task.mapId]
        end

        local rewards = l.reward

        local more
        for k, v in pairs(rewards) do
            local rewardText = self:GetRewardTextByID(task.id, k, v, 1, task.type)
            if k == "achievement" or k == "chance" or k == "azeriteTraits" then
                for j = 2, 3 do
                    local t = self:GetRewardTextByID(task.id, k, v, j, task.type)
                    if t then
                        rewardText = rewardText .. " & " .. t
                    end
                end
                if self:GetRewardTextByID(task.id, k, v, 4, task.type) then
                    more = true
                end
            end

            i = i + 1
            if i > 1 then
                text = text .. " & " .. rewardText
            else
                text = rewardText
            end
        end
        if more == true then
            text = text .. " & ..."
        end

        if self.db.profile.options.chatShowTime then
            output =
                "   " ..
                string.format(L["WQforAchTime"], self:GetTaskLink(task), self:formatTime(self:GetTaskTime(task)), text)
        else
            output = "   " .. string.format(L["WQforAch"], self:GetTaskLink(task), text)
        end

        print(output)
    end
end

local inspectScantip = CreateFrame("GameTooltip", "WorldQuestListInspectScanningTooltip", nil, "GameTooltipTemplate")
inspectScantip:SetOwner(UIParent, "ANCHOR_NONE")

local EquipLocToSlot1 = {
    INVTYPE_HEAD = 1,
    INVTYPE_NECK = 2,
    INVTYPE_SHOULDER = 3,
    INVTYPE_BODY = 4,
    INVTYPE_CHEST = 5,
    INVTYPE_ROBE = 5,
    INVTYPE_WAIST = 6,
    INVTYPE_LEGS = 7,
    INVTYPE_FEET = 8,
    INVTYPE_WRIST = 9,
    INVTYPE_HAND = 10,
    INVTYPE_FINGER = 11,
    INVTYPE_TRINKET = 13,
    INVTYPE_CLOAK = 15,
    INVTYPE_WEAPON = 16,
    INVTYPE_SHIELD = 17,
    INVTYPE_2HWEAPON = 16,
    INVTYPE_WEAPONMAINHAND = 16,
    INVTYPE_RANGED = 16,
    INVTYPE_RANGEDRIGHT = 16,
    INVTYPE_WEAPONOFFHAND = 17,
    INVTYPE_HOLDABLE = 17,
    INVTYPE_TABARD = 19
}
local EquipLocToSlot2 = {
    INVTYPE_FINGER = 12,
    INVTYPE_TRINKET = 14,
    INVTYPE_WEAPON = 17
}

local ReputationItemList = {
    -- Army of the Light Insignia
    [152957] = 2165,
    [152955] = 2165,
    [152956] = 2165,
    [152958] = 2165,
    [152960] = 2170,
    -- Argussian Reach Insignia
    [152954] = 2170,
    [152959] = 2170,
    [152961] = 2170,
    [141342] = 1894,
    -- The Wardens
    [139025] = 1894,
    [141991] = 1894,
    [147415] = 1894,
    [150929] = 1894,
    [146945] = 1894,
    [146939] = 1894,
    [141340] = 1900,
    -- Court of Farondis
    [139023] = 1900,
    [147410] = 1900,
    [141989] = 1900,
    [150927] = 1900,
    [146937] = 1900,
    [146943] = 1900,
    [139021] = 1883,
    -- Dreamweavers
    [141988] = 1883,
    [147411] = 1883,
    [141339] = 1883,
    [150926] = 1883,
    [146942] = 1883,
    [146936] = 1883,
    -- Highmountain Tribe
    [141341] = 1828,
    [139024] = 1828,
    [141990] = 1828,
    [147412] = 1828,
    [150928] = 1828,
    [146944] = 1828,
    [146938] = 1828,
    -- Valarjar
    [139020] = 1948,
    [141338] = 1948,
    [141987] = 1948,
    [147414] = 1948,
    [146935] = 1948,
    [146941] = 1948,
    [150925] = 1948,
    -- The Nightfallen
    [141343] = 1859,
    [141992] = 1859,
    [139026] = 1859,
    [147413] = 1859,
    [150930] = 1859,
    [146940] = 1859,
    [146946] = 1859
}

local ReputationCurrencyList = {
    [1579] = 2164, -- Champions of Azeroth
    [1598] = 2163, -- Tortollan Seekers
    [1593] = 2160, -- Proudmoore Admiralty
    [1592] = 2161, -- Order of Embers
    [1594] = 2162, -- Storm's Wake
    [1599] = 2159, -- 7th Legion
    [1597] = 2103, -- Zandalari Empire
    [1595] = 2156, -- Talanji's Expedition
    [1596] = 2158, -- Voldunai
    [1600] = 2157, -- The Honorbound
    [1742] = 2391, -- Rustbolt Resistance
    [1739] = 2400, -- Waveblade Ankoan
    [1757] = 2417, -- Uldum Accord
    [1758] = 2415, -- Rajani
    [1738] = 2373, -- The Unshackled
    [1807] = 2413, -- Court of Harvesters
    [1907] = 2470, -- Death's Advance
    [1804] = 2407, -- The Ascended
    [1982] = 2478, -- The Enlightened
    [1805] = 2410, -- The Undying Army
    [1806] = 2465, -- The Wild Hunt
    [1880] = 2432, -- Ve'nari
    [2819] = 2615, -- Azerothian Archives
    [2031] = 2507, -- Dragonscale Expedition
    [2652] = 2574, -- Dream Wardens
    [2109] = 2511, -- Iskaara Tuskarr
    [2420] = 2564, -- Loamm Niffen
    [2108] = 2503, -- Maruuk Centaur
    [2106] = 2510, -- Valdrakken Accord
    [2902] = 2594, -- The Assembly of the Deeps
    [2899] = 2570, -- Hallowfall Arathi
    [2903] = 2600, -- The Severed Threads
    [2897] = 2590 -- Council of Dornogal
}

function WQA:Reward()
    local addon = self
    addon:Debug("Reward")
    addon.event:UnregisterEvent("QUEST_LOG_UPDATE")
    addon.event:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
    addon.rewards = false
    addon.retryCount = (addon.retryCount or 0) + 1 -- Track retries
    if addon.retryCount > 5 then -- Limit to 5 retries to prevent loop
        addon:Debug("Max retries reached, forcing rewards true")
        addon.rewards = true
        addon.retryCount = 0
        return
    end
    local overallRetry = false

    -- Azerite Traits (unchanged)
    if addon.db.profile.options.reward.gear.azeriteTraits ~= "" then
        addon.azeriteTraitsList = {}
        for spellID in string.gmatch(addon.db.profile.options.reward.gear.azeriteTraits, "(%d+)") do
            addon.azeriteTraitsList[tonumber(spellID)] = true
        end
    end

    -- Throttling setup
    local rewardFrame = CreateFrame("Frame")
    local batchSize = 50 -- Tune: higher for static IDs (faster)
    local timeBudget = 0.01 -- Max ms per frame
    local questIDsToProcess = {}
    local mapIDsToProcess = {}
    local currentIndex = 1
    local usingStatic = addon.AllWorldQuestIDs and next(addon.AllWorldQuestIDs) ~= nil -- Check if populated

    if usingStatic then
        addon:Debug("Using static list: true")
        -- Flatten questIDs
        for exp, ids in pairs(addon.AllWorldQuestIDs) do
            for _, questID in ipairs(ids) do
                local zoneID = C_TaskQuest.GetQuestZoneID(questID)
                if zoneID and addon.db.profile.options.zone[zoneID] == true then
                    table.insert(questIDsToProcess, questID)
                end
            end
        end
    else
        addon:Debug("Using static list: false - falling back to map scan")
        -- Fallback: Flatten mapIDs
        for i in pairs(addon.ZoneIDList) do
            for _, mapID in pairs(addon.ZoneIDList[i]) do
                if addon.db.profile.options.zone[mapID] == true then
                    table.insert(mapIDsToProcess, mapID)
                end
            end
        end
    end

    local function RewardUpdate(frame, elapsed)
        local processed = 0
        local retry = false
        local startTime = GetTime()
        while processed < batchSize and currentIndex <= (usingStatic and #questIDsToProcess or #mapIDsToProcess) and
            (GetTime() - startTime) < timeBudget do
            local questID
            if usingStatic then
                questID = questIDsToProcess[currentIndex]
                if not C_TaskQuest.IsActive(questID) then
                    currentIndex = currentIndex + 1
                    processed = processed + 1
                else
                    -- Per-quest logic
                    local questTagInfo = GetQuestTagInfo(questID)
                    local worldQuestType = 0
                    if questTagInfo then
                        worldQuestType = questTagInfo.worldQuestType
                    end
                    if
                        addon.questList[questID] and
                            not addon.db.profile.options.reward.general.worldQuestType[worldQuestType]
                     then
                        addon.questList[questID] = nil
                    end
                    if
                        addon.db.profile.options.zone[C_TaskQuest.GetQuestZoneID(questID)] == true and
                            addon.db.profile.options.reward.general.worldQuestType[worldQuestType]
                     then
                        -- 100 different World Quests achievements
                        if QuestUtils_IsQuestWorldQuest(questID) and not addon.db.global.completed[questID] then
                            local zoneID = C_TaskQuest.GetQuestZoneID(questID)
                            local exp = 0
                            for expansion, zones in pairs(addon.ZoneIDList) do
                                for _, v in pairs(zones) do
                                    if zoneID == v then
                                        exp = expansion
                                    end
                                end
                            end
                            if
                                addon.db.profile.achievements[11189] ~= "disabled" and
                                    not select(4, GetAchievementInfo(11189)) and
                                    exp == 7 and
                                    zoneID ~= 830 and
                                    zoneID ~= 885 and
                                    zoneID ~= 882
                             then
                                addon:AddRewardToQuest(questID, "ACHIEVEMENT", 11189)
                            elseif
                                addon.db.profile.achievements[13144] ~= "disabled" and
                                    not select(4, GetAchievementInfo(13144)) and
                                    exp == 8
                             then
                                addon:AddRewardToQuest(questID, "ACHIEVEMENT", 13144)
                            elseif
                                addon.db.profile.achievements[14758] ~= "disabled" and
                                    not select(4, GetAchievementInfo(14758)) and
                                    exp == 9
                             then
                                addon:AddRewardToQuest(questID, "ACHIEVEMENT", 14758)
                            end
                        end
                        -- For quest ID 83366...
                        if questID ~= 83366 and HaveQuestData(questID) and not HaveQuestRewardData(questID) then
                            C_TaskQuest.RequestPreloadRewardData(questID)
                            retry = true
                        end
                        retry = addon:CheckItems(questID) or retry
                        addon:CheckCurrencies(questID)
                        -- Profession
                        local tradeskillLineID
                        if questTagInfo then
                            tradeskillLineID = questTagInfo.tradeskillLineID
                        end
                        if tradeskillLineID then
                            local professionName = C_TradeSkillUI.GetTradeSkillDisplayName(tradeskillLineID)
                            local zoneID = C_TaskQuest.GetQuestZoneID(questID)
                            local exp = 0
                            for expansion, zones in pairs(addon.ZoneIDList) do
                                for _, v in pairs(zones) do
                                    if zoneID == v then
                                        exp = expansion
                                    end
                                end
                            end
                            if
                                not addon.db.char[exp].profession[tradeskillLineID].isMaxLevel and
                                    addon.db.profile.options.reward[exp].profession[tradeskillLineID].skillup
                             then
                                addon:AddRewardToQuest(questID, "PROFESSION_SKILLUP", professionName)
                            end
                        end
                    end
                    currentIndex = currentIndex + 1
                    processed = processed + 1
                end
            else
                -- Fallback map logic
                local mapID = mapIDsToProcess[currentIndex]
                local quests = C_TaskQuest.GetQuestsOnMap(mapID)
                if quests then
                    for i = 1, #quests do
                        local questID = quests[i].questID
                        -- (full per-quest logic, same as above)
                        local questTagInfo = GetQuestTagInfo(questID)
                        local worldQuestType = 0
                        if questTagInfo then
                            worldQuestType = questTagInfo.worldQuestType
                        end
                        if
                            addon.questList[questID] and
                                not addon.db.profile.options.reward.general.worldQuestType[worldQuestType]
                         then
                            addon.questList[questID] = nil
                        end
                        if
                            addon.db.profile.options.zone[C_TaskQuest.GetQuestZoneID(questID)] == true and
                                addon.db.profile.options.reward.general.worldQuestType[worldQuestType]
                         then
                            -- 100 different World Quests achievements
                            if QuestUtils_IsQuestWorldQuest(questID) and not addon.db.global.completed[questID] then
                                local zoneID = C_TaskQuest.GetQuestZoneID(questID)
                                local exp = 0
                                for expansion, zones in pairs(addon.ZoneIDList) do
                                    for _, v in pairs(zones) do
                                        if zoneID == v then
                                            exp = expansion
                                        end
                                    end
                                end
                                if
                                    addon.db.profile.achievements[11189] ~= "disabled" and
                                        not select(4, GetAchievementInfo(11189)) and
                                        exp == 7 and
                                        mapID ~= 830 and
                                        mapID ~= 885 and
                                        mapID ~= 882
                                 then
                                    addon:AddRewardToQuest(questID, "ACHIEVEMENT", 11189)
                                elseif
                                    addon.db.profile.achievements[13144] ~= "disabled" and
                                        not select(4, GetAchievementInfo(13144)) and
                                        exp == 8
                                 then
                                    addon:AddRewardToQuest(questID, "ACHIEVEMENT", 13144)
                                elseif
                                    addon.db.profile.achievements[14758] ~= "disabled" and
                                        not select(4, GetAchievementInfo(14758)) and
                                        exp == 9
                                 then
                                    addon:AddRewardToQuest(questID, "ACHIEVEMENT", 14758)
                                end
                            end
                            -- For quest ID 83366...
                            if questID ~= 83366 and HaveQuestData(questID) and not HaveQuestRewardData(questID) then
                                C_TaskQuest.RequestPreloadRewardData(questID)
                                retry = true
                            end
                            retry = addon:CheckItems(questID) or retry
                            addon:CheckCurrencies(questID)
                            -- Profession
                            local tradeskillLineID
                            if questTagInfo then
                                tradeskillLineID = questTagInfo.tradeskillLineID
                            end
                            if tradeskillLineID then
                                local professionName = C_TradeSkillUI.GetTradeSkillDisplayName(tradeskillLineID)
                                local zoneID = C_TaskQuest.GetQuestZoneID(questID)
                                local exp = 0
                                for expansion, zones in pairs(addon.ZoneIDList) do
                                    for _, v in pairs(zones) do
                                        if zoneID == v then
                                            exp = expansion
                                        end
                                    end
                                end
                                if
                                    not addon.db.char[exp].profession[tradeskillLineID].isMaxLevel and
                                        addon.db.profile.options.reward[exp].profession[tradeskillLineID].skillup
                                 then
                                    addon:AddRewardToQuest(questID, "PROFESSION_SKILLUP", professionName)
                                end
                            end
                        end
                    end
                end
                currentIndex = currentIndex + 1
                processed = processed + 1
            end
        end

        overallRetry = overallRetry or retry

        if currentIndex > (usingStatic and #questIDsToProcess or #mapIDsToProcess) then
            frame:SetScript("OnUpdate", nil)
            if overallRetry then
                addon:Debug("|cFFFF0000<<<RETRY>>>|r")
                addon.start = GetTime()
                addon.timer =
                    addon:ScheduleTimer(
                    function()
                        addon:Reward()
                    end,
                    2
                )
                addon.event:RegisterEvent("QUEST_LOG_UPDATE")
                addon.event:RegisterEvent("GET_ITEM_INFO_RECEIVED")
            else
                addon.rewards = true
                addon.retryCount = 0
            end
        end
    end

    -- Start chunking
    if (usingStatic and #questIDsToProcess > 0) or (not usingStatic and #mapIDsToProcess > 0) then
        rewardFrame:SetScript("OnUpdate", RewardUpdate)
    else
        addon.rewards = true
    end
end

local weaponCache = {
    [165872] = true, -- 7th Legion Equipment Cache
    [165867] = true, -- Kul Tiran Weapons Cache
    [165871] = true, -- Honorbound Equipment Cache
    [165863] = true -- Zandalari Weapons Cache
}
local armorCache = {
    [165872] = true, -- 7th Legion Equipment Cache
    [165870] = true, -- Order of Embers Equipment Cache
    [165868] = true, -- Storm's Wake Equipment Cache
    [165869] = true, -- Proudmoore Admiralty Equipment Cache
    [165871] = true, -- Honorbound Equipment Cache
    [165865] = true, -- Nazmir Expeditionary Equipment Cache
    [165864] = true, -- Voldunai Equipment Cache
    [165866] = true -- Zandalari Empire Equipment Cache
}
local jewelryCache = {
    [165785] = true -- Tortollan Trader's Stock
}

-- CanIMogIt
function WQA:IsTransmogable(itemLink)
    -- Returns whether the item is transmoggable or not.

    -- White items are not transmoggable.
    local quality = select(3, GetItemInfo(itemLink))
    if quality == nil then
        return
    end
    if quality <= 1 then
        return false
    end

    local itemID, _, _, slotName = GetItemInfoInstant(itemLink)

    -- See if the game considers it transmoggable
    local transmoggable = select(3, C_Transmog.CanTransmogItem(itemID))
    if transmoggable == false then
        return false
    end

    -- See if the item is in a valid transmoggable slot
    local slot = EquipLocToSlot1[slotName]
    if slot == nil or slot == 11 or slot == 13 or slot == 2 then
        return false
    end
    return true
end

function WQA:CheckItems(questID, isEmissary)
    local numQuestRewards = GetNumQuestLogRewards(questID)

    if numQuestRewards == 0 then
        return false
    end

    local retryArray = {}

    for rewardIndex = 1, numQuestRewards do
        retryArray[rewardIndex] = self:CheckReward(questID, isEmissary, rewardIndex)
    end

    for _, retry in pairs(retryArray) do
        if retry then
            return true
        end
    end

    return false
end

function WQA:CheckReward(questID, isEmissary, rewardIndex)
    local retry = false

    local itemName, itemTexture, quantity, quality, isUsable, itemID = GetQuestLogRewardInfo(rewardIndex, questID)
    if itemID then
        inspectScantip:SetQuestLogItem("reward", rewardIndex, questID)
        local itemLink = select(2, inspectScantip:GetItem())
        if not itemLink then
            return true
        elseif string.find(itemLink, "%[]") then
            return true
        end

        local itemName,
            _,
            itemRarity,
            itemLevel,
            itemMinLevel,
            itemType,
            itemSubType,
            itemStackCount,
            itemEquipLoc,
            itemTexture,
            itemSellPrice,
            itemClassID,
            itemSubClassID = GetItemInfo(itemLink)
        local expacID = self:GetExpansionByQuestID(questID)

        -- Ask Pawn if this is an Upgrade
        if PawnIsItemAnUpgrade and self.db.profile.options.reward.gear.PawnUpgrade then
            local Item = PawnGetItemData(itemLink)
            if Item then
                local UpgradeInfo, BestItemFor, SecondBestItemFor, NeedsEnhancements = PawnIsItemAnUpgrade(Item)
                if
                    UpgradeInfo and
                        UpgradeInfo[1].PercentUpgrade * 100 >= self.db.profile.options.reward.gear.PercentUpgradeMin and
                        UpgradeInfo[1].PercentUpgrade < 10
                 then
                    local item = {
                        itemLink = itemLink,
                        itemPercentUpgrade = math.floor(UpgradeInfo[1].PercentUpgrade * 100 + .5)
                    }
                    self:AddRewardToQuest(questID, "ITEM", item, isEmissary)
                end
            end
        end

        -- StatWeightScore
        local StatWeightScore = LibStub("AceAddon-3.0"):GetAddon("StatWeightScore", true)
        if StatWeightScore and self.db.profile.options.reward.gear.StatWeightScore then
            local slotID = EquipLocToSlot1[itemEquipLoc]
            if slotID then
                local itemPercentUpgrade = 0
                local ScoreModule = StatWeightScore:GetModule("StatWeightScoreScore")
                local SpecModule = StatWeightScore:GetModule("StatWeightScoreSpec")
                local ScanningTooltipModule = StatWeightScore:GetModule("StatWeightScoreScanningTooltip")
                local specs = SpecModule:GetSpecs()
                for _, spec in pairs(specs) do
                    if spec.Enabled then
                        local score =
                            ScoreModule:CalculateItemScore(
                            itemLink,
                            slotID,
                            ScanningTooltipModule:ScanTooltip(itemLink),
                            spec,
                            equippedItemHasUniqueGem
                        ).Score
                        local equippedScore
                        local equippedLink = GetInventoryItemLink("player", slotID)
                        if equippedLink then
                            equippedScore =
                                ScoreModule:CalculateItemScore(
                                equippedLink,
                                slotID,
                                ScanningTooltipModule:ScanTooltip(equippedLink),
                                spec,
                                equippedItemHasUniqueGem
                            ).Score
                        else
                            retry = true
                        end

                        local slotID2 = EquipLocToSlot2[itemEquipLoc]
                        if slotID2 then
                            equippedLink = GetInventoryItemLink("player", slotID2)
                            if equippedLink then
                                local equippedScore2 =
                                    ScoreModule:CalculateItemScore(
                                    equippedLink,
                                    slotID2,
                                    ScanningTooltipModule:ScanTooltip(equippedLink),
                                    spec,
                                    equippedItemHasUniqueGem
                                ).Score
                                if equippedScore or 0 > equippedScore2 then
                                    equippedScore = equippedScore2
                                end
                            else
                                retry = true
                            end
                        end

                        if equippedScore then
                            if (score - equippedScore) / equippedScore * 100 > itemPercentUpgrade then
                                itemPercentUpgrade = (score - equippedScore) / equippedScore * 100
                            end
                        end
                    end
                end
                if itemPercentUpgrade >= self.db.profile.options.reward.gear.PercentUpgradeMin then
                    local item = {itemLink = itemLink, itemPercentUpgrade = math.floor(itemPercentUpgrade + .5)}
                    self:AddRewardToQuest(questID, "ITEM", item, isEmissary)
                end
            end
        end

        -- Upgrade by itemLevel
        if self.db.profile.options.reward.gear.itemLevelUpgrade then
            local itemLevel1, itemLevel2
            local slotID = EquipLocToSlot1[itemEquipLoc]
            if slotID then
                if GetInventoryItemID("player", slotID) then
                    local itemLink1 = GetInventoryItemLink("player", slotID)
                    if itemLink1 then
                        itemLevel1 = GetDetailedItemLevelInfo(itemLink1)
                        if not itemLevel1 then
                            retry = true
                        end
                    else
                        retry = true
                    end
                end
            end
            if EquipLocToSlot2[itemEquipLoc] then
                slotID = EquipLocToSlot2[itemEquipLoc]
                if GetInventoryItemID("player", slotID) then
                    local itemLink2 = GetInventoryItemLink("player", slotID)
                    if itemLink2 then
                        itemLevel2 = GetDetailedItemLevelInfo(itemLink2)
                        if not itemLevel2 then
                            retry = true
                        end
                    else
                        retry = true
                    end
                end
            end

            itemLevel = GetDetailedItemLevelInfo(itemLink)
            if not itemLevel then
                retry = true
            else
                local itemLevelEquipped = math.min(itemLevel1 or 1000, itemLevel2 or 1000)
                if itemLevel - itemLevelEquipped >= self.db.profile.options.reward.gear.itemLevelUpgradeMin then
                    local item = {itemLink = itemLink, itemLevelUpgrade = itemLevel - itemLevelEquipped}
                    self:AddRewardToQuest(questID, "ITEM", item, isEmissary)
                end
            end
        end

        -- Azerite Armor Cache
        if itemID == 163857 and self.db.profile.options.reward.gear.AzeriteArmorCache then
            itemLevel = GetDetailedItemLevelInfo(itemLink)
            local AzeriteArmorCacheIsUpgrade = false
            local AzeriteArmorCache = {}
            for i = 1, 5, 2 do
                if GetInventoryItemID("player", i) then
                    local itemLink1 = GetInventoryItemLink("player", i)
                    if itemLink1 then
                        local itemLevel1 = GetDetailedItemLevelInfo(itemLink1)
                        if itemLevel1 then
                            AzeriteArmorCache[i] = itemLevel - itemLevel1
                            if
                                itemLevel > itemLevel1 and
                                    itemLevel - itemLevel1 >= self.db.profile.options.reward.gear.itemLevelUpgradeMin
                             then
                                AzeriteArmorCacheIsUpgrade = true
                            end
                        else
                            retry = true
                        end
                    else
                        retry = true
                    end
                else
                    AzeriteArmorCache[i] = itemLevel
                    if itemLevel and itemLevel >= self.db.profile.options.reward.gear.itemLevelUpgradeMin then
                        AzeriteArmorCacheIsUpgrade = true
                    end
                end
            end
            if AzeriteArmorCacheIsUpgrade == true then
                local item = {itemLink = itemLink, AzeriteArmorCache = AzeriteArmorCache}
                self:AddRewardToQuest(questID, "ITEM", item, isEmissary)
            end
        end

        -- Equipment Cache
        if
            (weaponCache[itemID] and self.db.profile.options.reward.gear.weaponCache) or
                (armorCache[itemID] and self.db.profile.options.reward.gear.armorCache) or
                (jewelryCache[itemID] and self.db.profile.options.reward.gear.jewelryCache)
         then
            itemLevel = GetDetailedItemLevelInfo(itemLink)
            local n = 0
            local upgrade
            local upgradeMax = 0
            local upgradeSum = 0
            local upgradeNum = 0

            if weaponCache[itemID] then
                for i = 16, 17 do
                    if GetInventoryItemID("player", i) then
                        local itemLink1 = GetInventoryItemLink("player", i)
                        if itemLink1 then
                            local itemLevel1 = GetDetailedItemLevelInfo(itemLink1)
                            if itemLevel1 then
                                n = n + 1
                                upgrade = itemLevel - itemLevel1
                                if upgrade >= self.db.profile.options.reward.gear.itemLevelUpgradeMin then
                                    upgradeNum = upgradeNum + 1
                                    if upgrade > upgradeMax then
                                        upgradeMax = upgrade
                                    end
                                end
                                upgradeSum = upgradeSum + upgrade
                            else
                                retry = true
                            end
                        else
                            retry = true
                        end
                    end
                end
            end

            if armorCache[itemID] then
                for i = 1, 10 do
                    if i == 4 then
                        i = 15
                    end
                    if i ~= 2 then
                        if GetInventoryItemID("player", i) then
                            local itemLink1 = GetInventoryItemLink("player", i)
                            if itemLink1 then
                                local itemLevel1 = GetDetailedItemLevelInfo(itemLink1)
                                if itemLevel1 then
                                    n = n + 1
                                    upgrade = itemLevel - itemLevel1
                                    if upgrade >= self.db.profile.options.reward.gear.itemLevelUpgradeMin then
                                        upgradeNum = upgradeNum + 1
                                        if upgrade > upgradeMax then
                                            upgradeMax = upgrade
                                        end
                                    end
                                    upgradeSum = upgradeSum + upgrade
                                else
                                    retry = true
                                end
                            else
                                retry = true
                            end
                        end
                    end
                end
            end

            if jewelryCache[itemID] then
                for i = 11, 14 do
                    if GetInventoryItemID("player", i) then
                        local itemLink1 = GetInventoryItemLink("player", i)
                        if itemLink1 then
                            local itemLevel1 = GetDetailedItemLevelInfo(itemLink1)
                            if itemLevel1 then
                                n = n + 1
                                upgrade = itemLevel - itemLevel1
                                if upgrade >= self.db.profile.options.reward.gear.itemLevelUpgradeMin then
                                    upgradeNum = upgradeNum + 1
                                    if upgrade > upgradeMax then
                                        upgradeMax = upgrade
                                    end
                                end
                                upgradeSum = upgradeSum + upgrade
                            else
                                retry = true
                            end
                        else
                            retry = true
                        end
                    end
                end
            end

            if upgradeNum > 0 then
                local item = {
                    itemLink = itemLink,
                    cache = {upgradeNum = upgradeNum, n = n, upgradeMax = upgradeMax}
                }
                self:AddRewardToQuest(questID, "ITEM", item, isEmissary)
            end
        end

        -- Transmog
        if self.db.profile.options.reward.gear.unknownAppearance and self:IsTransmogable(itemLink) then
            if itemClassID == 2 or itemClassID == 4 then
                local transmog
                if AllTheThings then
                    local searchForLinkResult = AllTheThings.SearchForLink(itemLink)
                    if (searchForLinkResult and searchForLinkResult[1]) then
                        local state = searchForLinkResult[1].collected
                        if not state then
                            transmog = "|TInterface\\Addons\\AllTheThings\\assets\\unknown:0|t"
                        elseif state == 2 and self.db.profile.options.reward.gear.unknownSource then
                            transmog = "|TInterface\\Addons\\AllTheThings\\assets\\known_circle:0|t"
                        end
                    end
                end

                if CanIMogIt and not transmog then
                    if CanIMogIt:IsEquippable(itemLink) and CanIMogIt:CharacterCanLearnTransmog(itemLink) then
                        if not CanIMogIt:PlayerKnowsTransmog(itemLink) then
                            transmog = "|TInterface\\AddOns\\CanIMogIt\\Icons\\UNKNOWN:0|t"
                        elseif
                            not CanIMogIt:PlayerKnowsTransmogFromItem(itemLink) and
                                self.db.profile.options.reward.gear.unknownSource
                         then
                            transmog = "|TInterface\\AddOns\\CanIMogIt\\Icons\\KNOWN_circle:0|t"
                        end
                    end
                end
                if transmog then
                    local item = {itemLink = itemLink, transmog = transmog}
                    self:AddRewardToQuest(questID, "ITEM", item, isEmissary)
                end
            end
        end

        -- Reputation Token
        local factionID = ReputationItemList[itemID] or nil
        if factionID then
            if self.db.profile.options.reward.reputation[factionID] == true then
                local reputation = {itemLink = itemLink, factionID = factionID}
                self:AddRewardToQuest(questID, "REPUTATION", reputation, isEmissary)
            end
        end

        -- print(expacID,self:GetExpansionByQuestID(questID), itemLink, questID)
        -- Recipe
        if itemClassID == 9 then
            if self.db.profile.options.reward.recipe[expacID] == true then
                self:AddRewardToQuest(questID, "RECIPE", itemLink, isEmissary)
            end
        end

        -- Crafting Reagent
        --[[
		local exp = self:GetExpansionByQuestID(questID) or 7
			if WQA:GetEffectiveTracking("rewardItem", itemID, exp) == "always" then
				if not self.questList[questID] then self.questList[questID] = {} end
				local l = self.questList[questID]
				if not l.reward then l.reward = {} end
				if not l.reward.item then l.reward.item = {} end
				l.reward.item.itemLink = itemLink
			end--]]
        -- Custom itemID
        if self.db.global.custom.worldQuestReward[itemID] == true then
            if self.db.profile.custom.worldQuestReward[itemID] == true then
                self:AddRewardToQuest(questID, "CUSTOM_ITEM", itemLink, isEmissary)
            end
        end

        -- Items
        if self.itemList[itemID] == true then
            local item = {itemLink = itemLink}
            self:AddRewardToQuest(questID, "ITEM", item, isEmissary)
        end

        -- Azerite Traits
        if
            self.db.profile.options.reward.gear.azeriteTraits ~= "" and
                C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(itemLink)
         then
            for _, ring in pairs(C_AzeriteEmpoweredItem.GetAllTierInfoByItemID(itemLink)) do
                for _, azeritePowerID in pairs(ring.azeritePowerIDs) do
                    local spellID = C_AzeriteEmpoweredItem.GetPowerInfo(azeritePowerID).spellID
                    if self.azeriteTraitsList[spellID] then
                        self:AddRewardToQuest(questID, "AZERITE_TRAIT", spellID, isEmissary)
                        self:AddRewardToQuest(questID, "ITEM", {itemLink = itemLink}, isEmissary)
                    end
                end
            end
        end

        -- Conduit
        if self.db.profile.options.reward.gear.conduit and C_Soulbinds.IsItemConduitByItemInfo(itemLink) then
            self:AddRewardToQuest(questID, "ITEM", {itemLink = itemLink}, isEmissary)
        end
    else
        retry = true
    end

    return retry
end

function WQA:CheckCurrencies(questID, isEmissary)
    local questRewardCurrencies = C_QuestLog.GetQuestRewardCurrencies(questID)

    for _, currencyInfo in ipairs(questRewardCurrencies) do
        local currencyID = currencyInfo.currencyID
        local amount = currencyInfo.totalRewardAmount

        if WQA:GetEffectiveTracking("rewardCurrency", currencyID, exp) == "always" then
            local currency = {currencyID = currencyID, amount = amount}
            self:AddRewardToQuest(questID, "CURRENCY", currency, isEmissary)
        end

        -- Reputation Currency
        local factionID = ReputationCurrencyList[currencyID] or nil
        if factionID then
            if self.db.profile.options.reward.reputation[factionID] == true then
                local reputation = {
                    name = currencyInfo.name,
                    currencyID = currencyID,
                    amount = amount,
                    factionID = factionID
                }
                self:AddRewardToQuest(questID, "REPUTATION", reputation, isEmissary)
            end
        end
    end

    local gold = math.floor(GetQuestLogRewardMoney(questID) / 10000) or 0
    if gold > 0 then
        if self.db.profile.options.reward.general.gold and gold >= self.db.profile.options.reward.general.goldMin then
            self:AddRewardToQuest(questID, "GOLD", gold, isEmissary)
        end
    end
end

WQA.debug = false
function WQA:Debug(...)
    if self.debug == true then
        print(GetTime(), GetFramerate(), ...)
    end
end

function WQA:GetRewardTextByID(questID, key, value, i, type)
    local k, v = key, value
    local text

    if k == "custom" then
        if HaveQuestRewardData(questID) then
            -- First: Try item reward (normal cache)
            local itemLink = GetQuestLogItemLink("reward", 1, questID)
            if itemLink and itemLink ~= "" then
                text = itemLink
            else
                -- Second: Try currency reward (Azerite, Gold, etc.)
                local currencyInfo = C_QuestLog.GetQuestRewardCurrencyInfo(questID, 1, false)
                if currencyInfo and currencyInfo.currencyID then
                    local amount = currencyInfo.quantity or currencyInfo.totalRewardAmount or 0
                    if currencyInfo.currencyID == 0 then
                        -- Gold reward
                        text = GOLD_AMOUNT_TEXTURE_STRING:format(amount * 10000, 0, 0)
                    else
                        -- Currency like Azerite
                        text = amount .. " " .. GetCurrencyLink(currencyInfo.currencyID, amount)
                    end
                end
            end
        end

        -- Fallback if data not loaded
        if not text then
            text = "Custom"
        end
    elseif k == "item" then
        text = self:GetRewardForID(questID, k, type)
    elseif k == "reputation" then
        if v.itemLink then
            text = self:GetRewardLinkByID(questID, k, v, i)
        else
            text = v.amount .. " " .. self:GetRewardLinkByID(questID, k, v, i)
        end
    elseif k == "currency" then
        text = v.amount .. " " .. GetCurrencyLink(v.currencyID, v.amount)
    elseif k == "professionSkillup" then
        text = v
    elseif k == "gold" then
        text = GOLD_AMOUNT_TEXTURE_STRING:format(v, 0, 0)
    else
        text = self:GetRewardLinkByID(questID, k, v, i)
    end

    return text
end

function WQA:GetRewardLinkByMissionID(missionID, key, value, i)
    return self:GetRewardLinkByID(missionID, key, value, i)
end

function WQA:GetRewardLinkByID(questID, key, value, i)
    local k, v = key, value
    local link = nil
    if k == "achievement" then
        if not v[i] then
            return nil
        end
        link = v[i].achievementLink or GetAchievementLink(v[i].id)
    elseif k == "chance" then
        if not v[i] then
            return nil
        end
        link = v[i].itemLink or select(2, GetItemInfo(v[i].id))
    elseif k == "custom" then
        return nil
    elseif k == "item" then
        link = v.itemLink
    elseif k == "reputation" then
        if v.itemLink then
            link = v.itemLink
        else
            link = v.currencyLink or GetCurrencyLink(v.currencyID, v.amount)
        end
    elseif k == "recipe" then
        link = v
    elseif k == "customItem" then
        link = v
    elseif k == "currency" then
        link = v.currencyLink or GetCurrencyLink(v.currencyID, v.amount)
    elseif k == "professionSkillup" then
        return nil
    elseif k == "gold" then
        return nil
    elseif k == "azeriteTraits" then
        if not v[i] then
            return nil
        end
        link = GetSpellLink(v[i].spellID)
    elseif k == WQA.Rewards.RewardType.Miscellaneous then
        link = table.concat(v, ", ")
    end
    return link
end

function WQA:SetRewardLinkByMissionID(missionID, key, value, i, link)
    self:SetRewardLinkByID(missionID, key, value, i, link)
end

function WQA:SetRewardLinkByID(questID, key, value, i, link)
    local k, v = key, value
    if k == "achievement" then
        v[i].achievementLink = link
    elseif k == "chance" then
        v[i].itemLink = link
    elseif k == "reputation" then
        if not v.itemLink then
            v.currencyLink = link
        end
    elseif k == "currency" then
        v.currencyLink = link
    end
end

local function GetQuestName(questID)
    return C_TaskQuest.GetQuestInfoByQuestID(questID) or GetTitleForQuestID(questID) or
        select(3, string.find(GetQuestLink(questID) or "[unknown]", "%[(.+)%]"))
end

local function GetMissionName(missionID)
    return C_Garrison.GetMissionName(missionID)
end

local function SortByName(a, b)
    if a.type == "WORLD_QUEST" then
        a = GetQuestName(a.id)
    else
        a = GetMissionName(a.id)
    end

    if b.type == "WORLD_QUEST" then
        b = GetQuestName(b.id)
    else
        b = GetMissionName(b.id)
    end

    --return GetQuestName(a) < GetQuestName(b)
    return a < b
end

function WQA:InsertionSort(A, compareFunction)
    for i, v in ipairs(A) do
        local j = i
        while j > 1 and compareFunction(A[j], A[j - 1]) do
            local temp = A[j]
            A[j] = A[j - 1]
            A[j - 1] = temp
            j = j - 1
        end
    end
    return A
end

function WQA:SortQuestList(list)
    if self.db.profile.options.sortByName == true then
        list = self:InsertionSort(list, SortByName)
    end

    if self.db.profile.options.sortByZoneName == true then
        list =
            self:InsertionSort(
            list,
            function(a, b)
                return self:SortByZoneName(a, b)
            end
        )
    end

    list =
        self:InsertionSort(
        list,
        function(a, b)
            return self:SortByExpansion(a, b)
        end
    )
    return list
end

local GetBountiesForMapIDRequested = false
function WQA:EmissaryReward()
    self.emissaryRewards = false
    local retry = false

    for _, mapID in pairs({627, 875}) do
        local bounties = GetBountiesForMapID(mapID)
        if bounties then
            for _, emissary in ipairs(GetBountiesForMapID(mapID)) do
                local questID = emissary.questID
                local exp = self:GetExpansionByQuestID(questID) or 7
                if WQA:GetEffectiveTracking("rewardEmissary", questID, exp) ~= "disabled" then
                    self:AddEmissaryReward(questID, "CUSTOM", nil, true)
                end
                if HaveQuestData(questID) and HaveQuestRewardData(questID) then
                    retry = (self:CheckItems(questID, true) or retry)
                    self:CheckCurrencies(questID, true)
                else
                    retry = true
                end
            end
        end
    end

    if retry == true or GetBountiesForMapIDRequested == false then
        GetBountiesForMapIDRequested = true
        self:ScheduleTimer(
            function()
                self:EmissaryReward()
            end,
            1.5
        )
    else
        GetBountiesForMapIDRequested = false
        self.emissaryRewards = true
    end
end

function WQA:EmissaryIsActive(questID)
    -- Is this quest an emissary at all?
    local isEmissaryQuest = false

    -- BfA+ (in EmissaryQuestIDList)
    for _, v in pairs(self.EmissaryQuestIDList) do
        for _, entry in pairs(v) do
            local id = type(entry) == "table" and entry.id or entry
            if id == questID then
                isEmissaryQuest = true
                break
            end
        end
        if isEmissaryQuest then
            break
        end
    end

    -- Legion (old bounty system)
    if not isEmissaryQuest then
        for _, mapID in pairs({627, 875}) do
            local bounties = GetBountiesForMapID(mapID)
            if bounties then
                for _, bounty in ipairs(bounties) do
                    if bounty.questID == questID then
                        isEmissaryQuest = true
                        break
                    end
                end
            end
            if isEmissaryQuest then
                break
            end
        end
    end

    if not isEmissaryQuest then
        return false
    end

    -- Is tracking enabled?
    if not WQA.db.profile.options.emissary[questID] then
        return false
    end

    -- Is it actually active?
    local i = 1
    while C_QuestLog.GetInfo(i) do
        local info = C_QuestLog.GetInfo(i)
        if info and info.questID == questID then
            return true
        end
        i = i + 1
    end

    return false
end

function WQA:Special()
    if
        (self.db.profile.achievements[11189] ~= "disabled" and not select(4, GetAchievementInfo(11189)) == true) or
            (self.db.profile.achievements[13144] ~= "disabled" and not select(4, GetAchievementInfo(13144)) == true) or
            (self.db.profile.achievements[14758] ~= "disabled" and not select(4, GetAchievementInfo(14758)))
     then
        self.event:RegisterEvent("QUEST_TURNED_IN")
    end
end

local function PopUpIsShown()
    if WQA.PopUp then
        return WQA.PopUp.shown
    else
        return false
    end
end

local anchor
function dataobj:OnEnter()
    anchor = self
    if not PopUpIsShown() then
        WQA:Show("LDB")
    end
end

function dataobj:OnClick(button)
    if button == "LeftButton" then
        WQA:Show("popup")
    elseif button == "RightButton" then
        Settings.OpenToCategory("WQAchievements")
    end
end

function WQA:AnnounceLDB(quests)
    -- Hide PopUp
    if PopUpIsShown() then
        return
    end

    self:CreateQTip()
    self.tooltip:SetAutoHideDelay(
        .25,
        anchor,
        function()
            if not PopUpIsShown() then
                LibQTip:Release(WQA.tooltip)
                WQA.tooltip.quests = nil
                WQA.tooltip.missions = nil
                WQA.tooltip = nil
            end
        end
    )
    self.tooltip:SmartAnchorTo(anchor)
    self:UpdateQTip(quests)
end

function WQA:UpdateLDBText(activeTasks, newTasks)
    if newTasks ~= nil then
        dataobj.text = "New World Quests active"
    elseif activeTasks ~= nil then
        dataobj.text = "World Quests active"
    else
        dataobj.text = "No World Quests active"
    end
end

function WQA:formatTime(t)
    local t = math.floor(t or 0)
    local d, h, m, timeString
    d = math.floor(t / 60 / 24)
    h = math.floor(t / 60 % 24)
    m = t % 60
    if d > 0 then
        if h > 0 then
            timeString = string.format("%dd %dh", d, h)
        else
            timeString = string.format("%dd", d)
        end
    elseif h > 0 then
        if m > 0 then
            timeString = string.format("%dh %dm", h, m)
        else
            timeString = string.format("%dh", h)
        end
    else
        timeString = string.format("%dm", m)
    end

    if t > 0 then
        if t <= 180 then
            if t <= 30 then
                timeString = string.format("|cffff3333%s|r", timeString)
            else
                timeString = string.format("|cffffff00%s|r", timeString)
            end
        end
    end

    return timeString
end

local LE_GARRISON_TYPE = {
    [6] = Enum.GarrisonType.Type_6_0_Garrison,
    [7] = Enum.GarrisonType.Type_7_0_Garrison,
    [8] = Enum.GarrisonType.Type_8_0_Garrison,
    [9] = Enum.GarrisonType.Type_9_0_Garrison
}

function WQA:CheckMissions()
    local activeMissions = {}
    local retry = false

    for exp, _ in pairs(self.ExpansionList) do
        local type = LE_GARRISON_TYPE[exp]
        local followerType = GetPrimaryGarrisonFollowerType(type)
        if type and C_Garrison.HasGarrison(type) then
            local missions = C_Garrison.GetAvailableMissions(followerType)
            if missions then
                for _, mission in ipairs(missions) do
                    local missionID = mission.missionID
                    local addMission = false

                    -- Gold (per expansion)
                    local expTable = WQA.db.profile.options.missionTable.reward["exp" .. exp] or {}
                    if expTable.gold then
                        for _, reward in ipairs(mission.rewards) do
                            if reward.currencyID == 0 then
                                local gold = math.floor(reward.quantity / 10000)
                                if gold >= (expTable.goldMin or 0) then
                                    self:AddRewardToMission(missionID, "GOLD", gold)
                                    addMission = true
                                end
                            end
                        end
                    end

                    -- Currencies
                    for _, reward in ipairs(mission.rewards) do
                        if reward.currencyID and reward.currencyID > 0 then
                            if WQA.db.profile.options.missionTable.reward.currency[reward.currencyID] then
                                local currency = {currencyID = reward.currencyID, amount = reward.quantity}
                                self:AddRewardToMission(missionID, "CURRENCY", currency)
                                addMission = true
                            end
                        end
                    end

                    -- Items (reputation tokens + custom rewards)
                    for _, reward in ipairs(mission.rewards) do
                        if reward.itemID then
                            local itemID = reward.itemID
                            local _, itemLink = GetItemInfo(itemID)
                            -- Reputation token
                            local factionID = ReputationItemList[itemID]
                            if factionID and WQA.db.profile.options.missionTable.reward.reputation[factionID] then
                                local reputation = {itemLink = itemLink or ("Item " .. itemID), factionID = factionID}
                                self:AddRewardToMission(missionID, "REPUTATION", reputation)
                                addMission = true
                            end

                            -- CUSTOM MISSION REWARD
                            if WQA.db.global.custom.missionReward and WQA.db.profile.custom.missionReward[itemID] then
                                local displayName = itemLink or ("Item " .. itemID)
                                local item = {itemLink = displayName}
                                self:AddRewardToMission(missionID, "ITEM", item)
                                addMission = true
                                retry = true -- force retry if name not cached
                            end

                            if not itemLink then
                                retry = true
                            end
                        end
                    end

                    if addMission then
                        self.missionList[missionID] = self.missionList[missionID] or {}
                        self.missionList[missionID].offerEndTime = mission.offerEndTime
                        self.missionList[missionID].offerTimeRemaining = mission.offerTimeRemaining
                        self.missionList[missionID].expansion = exp
                        self.missionList[missionID].followerType = followerType
                        activeMissions[missionID] = true
                    end
                end
            end
        end
    end

    return activeMissions -- always return the table (even if retry)
end

function WQA:isQuestPinActive(questID)
    for mapID in pairs(self.questPinMapList) do
        for _, questPin in pairs(C_QuestLine.GetAvailableQuestLines(mapID)) do
            if questPin.questID == questID then
                return true
            end
        end
    end
    return false
end

function WQA:IsQuestFlaggedCompleted(questID)
    if self.questFlagList[questID] then
        return not IsQuestFlaggedCompleted(questID)
    else
        return false
    end
end

function WQA:UpdateMinimapIcon()
    if self.db.profile.options.LibDBIcon.hide then
        icon:Hide("WQAchievements")
    else
        icon:Show("WQAchievements")
    end
end
