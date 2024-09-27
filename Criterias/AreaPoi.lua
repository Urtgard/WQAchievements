---@class WQAchievements
local WQA = WQAchievements

---@alias AreaPoiCriteria
---| { AreaPoiId: integer, MapId: integer}

local criteria = {}
criteria.list = {}
criteria.watched = {}

---@param poi AreaPoiCriteria
---@param rewardType RewardType
---@param emissary boolean?
function criteria:AddReward(poi, rewardType, reward, emissary)
    local poiId = poi.AreaPoiId
    local mapId = poi.MapId

    if not self.list[poiId] then
        self.list[poiId] = {}
    end
    if not self.list[poiId][mapId] then
        self.list[poiId][mapId] = {}
    end

    local l = self.list[poiId][mapId]

    WQA:AddReward(l, rewardType, reward, emissary)
end

function criteria:Check()
    local active = {}
    local new = {}
    local retry = false

    for poiId, mapIds in pairs(self.list) do
        for mapId in pairs(mapIds) do
            local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(mapId, poiId)

            if poiInfo then
                local link
                for k, v in pairs(self.list[poiId][mapId].reward) do
                    if k == "custom" or k == "professionSkillup" or k == "gold" then
                        link = true
                    else
                        link = WQA:GetRewardLinkByID(poiId, k, v, 1)
                    end

                    if not link then
                        WQA:Debug(poiId, k, v, 1)
                        retry = true
                    else
                        WQA:SetRewardLinkByID(poiId, k, v, 1, link)
                    end

                    if k == "achievement" or k == "chance" or k == "azeriteTraits" then
                        for i = 2, #v do
                            link = WQA:GetRewardLinkByID(poiId, k, v, i)
                            if not link then
                                WQA:Debug(poiId, k, v, i)
                                retry = true
                            else
                                WQA:SetRewardLinkByID(poiId, k, v, i, link)
                            end
                        end
                    end
                end
                if (not link) then
                    WQA:Debug(poiId, poiInfo.name, link)
                    retry = true
                else
                    if not active[poiId] then
                        active[poiId] = {}
                    end
                    active[poiId][mapId] = true

                    if not self.watched[poiId] or not self.watched[poiId][mapId] then
                        if not new[poiId] then
                            new[poiId] = {}
                        end
                        new[poiId][mapId] = true
                    end
                end
            end
        end
    end

    return {
        active = active,
        new = new,
        retry = retry
    }
end

WQA.Criterias.AreaPoi = criteria
