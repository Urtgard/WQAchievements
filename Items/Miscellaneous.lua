---@class WQAchievements
local WQA = WQAchievements
local CriteriaType = WQA.Criterias.CriteriaType
local RewardType = WQA.Rewards.RewardType

---@param items { name: string, criteriaType: CriteriaType, criteria: AreaPoiCriteria[] }[]
function WQA:AddMiscellaneous(items)
    for _, item in pairs(items) do
        if item.criteriaType == CriteriaType.AreaPoi then
            for _, criteria in pairs(item.criteria) do
                WQA.Criterias.AreaPoi:AddReward(
                    criteria --[[@as AreaPoiCriteria]],
                    RewardType.Miscellaneous,
                    item.name)
            end
        end
    end
end
