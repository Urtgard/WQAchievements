---@class WQAchievements
local WQA = WQAchievements
local RewardType = WQA.Rewards.RewardType

---@param rewardType RewardType
function WQA:AddReward(list, rewardType, reward, emissary)
    local l = list
    if emissary == true then
        l.isEmissary = true
    end
    if not l.reward then
        l.reward = {}
    end

    ---@type table <RewardType, any>
    l = l.reward
    if rewardType == RewardType.Achievement then
        if not l.achievement then
            l.achievement = {}
        end

        for _, achievement in ipairs(l.achievement) do
            if achievement.id == reward then
                return
            end
        end

        l.achievement[#l.achievement + 1] = {id = reward}
    elseif rewardType == RewardType.Chance then
        if not l.chance then
            l.chance = {}
        end

        for _, v in pairs(l.chance) do
            if v.id == reward then
                return
            end
        end

        l.chance[#l.chance + 1] = {id = reward}
    elseif rewardType == RewardType.Custom then
        if not l.custom then
            l.custom = true
        end
    elseif rewardType == RewardType.Item then
        if not l.item then
            l.item = {}
        end
        for k, v in pairs(reward) do
            l.item[k] = v
        end
    elseif rewardType == RewardType.Reputation then
        if not l.reputation then
            l.reputation = {}
        end
        for k, v in pairs(reward) do
            l.reputation[k] = v
        end
    elseif rewardType == RewardType.Recipe then
        l.recipe = reward
    elseif rewardType == RewardType.CustomItem then
        l.customItem = reward
    elseif rewardType == RewardType.Currency then
        if not l.currency then
            l.currency = {}
        end
        for k, v in pairs(reward) do
            l.currency[k] = v
        end
    elseif rewardType == RewardType.ProfessionSkillup then
        l.professionSkillup = reward
    elseif rewardType == RewardType.Gold then
        l.gold = reward
    elseif rewardType == RewardType.AzeriteTrait then
        if not l.azeriteTraits then
            l.azeriteTraits = {}
        end
        for k, v in pairs(l.azeriteTraits) do
            if v.spellID == reward then
                return
            end
        end
        l.azeriteTraits[#l.azeriteTraits + 1] = {spellID = reward}
    elseif rewardType == RewardType.Miscellaneous then
        if not l[RewardType.Miscellaneous] then
            ---@type { [string]: boolean }
            l[RewardType.Miscellaneous] = {}
        end

        table.insert(l[RewardType.Miscellaneous], reward)
    end
end
