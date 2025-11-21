---@class WQAchievements
local WQA = WQAchievements

local GetTitleForQuestID = C_QuestLog.GetTitleForQuestID


function WQA:GetExpansionByMissionID(missionID)
    return WQA.missionList[missionID].expansion
end

local questZoneIDList = {
    -- Outside Influences
    [55463] = 1462,
    [55658] = 1462,
    [55688] = 1462,
    [55718] = 1462,
    [55765] = 1462,
    [55885] = 1462,
    [56053] = 1462,
    [55813] = 1462,
    [56301] = 1462,
    [56142] = 1462,
    [55528] = 1462,
    [56365] = 1462,
    [56572] = 1462,
    [56501] = 1462,
    [56493] = 1462,
    [56552] = 1462,
    [56558] = 1462,
    [55575] = 1462,
    [55672] = 1462,
    [55717] = 1462,
    [56049] = 1462,
    [56469] = 1462,
    [55816] = 1462,
    [55905] = 1462,
    [56184] = 1462,
    [56306] = 1462,
    [54090] = 1462,
    [56355] = 1462,
    [56523] = 1462,
    [56410] = 1462,
    [56508] = 1462,
    [56471] = 1462,
    [56405] = 1462,
    -- Periodic Destruction
    [55121] = 1355
}

function WQA:GetQuestZoneID(questID)
    if WQA.questList[questID] and WQA.questList[questID].isEmissary then
        return "Emissary"
    end
    --if not WQA.questList[questID].info then	WQA.questList[questID].info = {} end
    --if WQA.questList[questID].info.zoneID then
    --	return WQA.questList[questID].info.zoneID
    --else
    --	WQA.questList[questID].info.zoneID = questZoneIDList[questID] or C_TaskQuest.GetQuestZoneID(questID)
    --	return WQA.questList[questID].info.zoneID
    --end
    return questZoneIDList[questID] or C_TaskQuest.GetQuestZoneID(questID)
end

function WQA:GetMissionZoneID(missionID)
    if WQA.missionList[missionID].shipyard == true then
        return -self:GetExpansionByMissionID(missionID) - .5
    else
        return -self:GetExpansionByMissionID(missionID)
    end
end

function WQA:GetTaskZoneID(task)
    if task.type == "MISSION" then
        return -self:GetExpansionByMissionID(task.id)
    end

    if task.type == "WORLD_QUEST" then
        local zoneID = C_TaskQuest.GetQuestZoneID(task.id)
        if zoneID then return zoneID end

        -- Fallback for emissary/bounty quests (Legion/BfA)
        if self.EmissaryQuestIDList then
            for exp, list in pairs(self.EmissaryQuestIDList) do
                for _, entry in pairs(list) do
                    local id = type(entry) == "table" and entry.id or entry
                    if id == task.id then
                        -- Use a dummy zoneID based on expansion (just for filtering)
                        return 1000 + exp  -- 1007 = Legion, 1008 = BfA, etc.
                    end
                end
            end
        end

        return 0 -- unknown
    end

    if task.type == "AREA_POI" then
        return task.mapId
    end

    return 0
end

function WQA:GetMapInfo(mapID)
    if mapID then
        return C_Map.GetMapInfo(mapID)
    else
        return { name = "Unknown" }
    end
end

function WQA:GetQuestZoneName(questID)
    if WQA.questList[questID].isEmissary then
        return "Emissary"
    end
    if not WQA.questList[questID].info then
        WQA.questList[questID].info = {}
    end
    WQA.questList[questID].info.zoneName = WQA.questList[questID].info.zoneName or
        self:GetMapInfo(self:GetQuestZoneID(questID)).name
    return WQA.questList[questID].info.zoneName
end

function WQA:GetMissionZoneName(missionID)
    if WQA.missionList[missionID].shipyard == true then
        return "Shipyard"
    else
        return "Mission Table"
    end
end

function WQA:GetTaskZoneName(task)
    if task.type == "MISSION" then
        return self:GetMissionZoneName(task.id)
    end

    if task.type == "AREA_POI" then
        return self:GetMapInfo(task.mapId).name
    end

    return self:GetQuestZoneName(task.id)
end

ExpansionByZoneID = {
    -- BfA
    [1169] = 8 -- Tol Dagor
}

function WQA:GetExpansionByMapId(mapId)
    if ExpansionByZoneID[mapId] then
        return ExpansionByZoneID[mapId]
    end

    for expansion, zones in pairs(WQA.ZoneIDList) do
        for _, v in pairs(zones) do
            if mapId == v then
                return expansion
            end
        end
    end

    return -1
end

function WQA:GetExpansionByQuestID(questID)
    --if not WQA.questList[questID].info then	WQA.questList[questID].info = {} end
    --if WQA.questList[questID].info.expansion then
    --	return WQA.questList[questID].info.expansion
    --else
    local zoneID = self:GetQuestZoneID(questID)

    local expansionId = self:GetExpansionByMapId(zoneID)

    if (expansionId > 0) then
        return expansionId
    end

    for expansion, v in pairs(WQA.EmissaryQuestIDList) do
        for _, id in pairs(v) do
            if type(id) == "table" then
                id = id.id
            end
            if id == questID then
                return expansion
            end
        end
    end
    return -1
end

function WQA:GetExpansion(task)
    if task.type == "MISSION" then
        return self:GetExpansionByMissionID(task.id)
    end

    if task.type == "AREA_POI" then
        return self:GetExpansionByMapId(task.mapId)
    end

    return self:GetExpansionByQuestID(task.id)
end

function WQA:GetExpansionName(id)
    return WQA.ExpansionList[id] or "Unknown"
end

function WQA:GetMissionTimeLeftMinutes(id)
    if not WQA.missionList[id].offerEndTime then
        return 0
    else
        return (WQA.missionList[id].offerEndTime - GetTime()) / 60
    end
end

function WQA:GetTaskTime(task)
    if task.type == "WORLD_QUEST" then
        return C_TaskQuest.GetQuestTimeLeftMinutes(task.id)
    elseif task.type == "MISSION" then
        return self:GetMissionTimeLeftMinutes(task.id)
    elseif task.type == "AREA_POI" then
        local seconds = C_AreaPoiInfo.GetAreaPOISecondsLeft(task.id)
        if seconds then
            return seconds / 60
        end
    end
end

function WQA:GetTaskLink(task)
    if task.type == "WORLD_QUEST" then
        --	else
        --		return GetQuestLink(task.id)
        --	end
        --	if WQA.questPinList[task.id] or WQA.questFlagList[task.id] then
        return GetQuestLink(task.id) or GetTitleForQuestID(task.id)
    elseif task.type == "MISSION" then
        return C_Garrison.GetMissionLink(task.id)
    elseif task.type == "AREA_POI" then
        return C_AreaPoiInfo.GetAreaPOIInfo(task.mapId, task.id).name
    end
end
