local WQA = WQAchievements

WQA.Achievements = {}

function WQA.Achievements:Register(achievement, forced, forcedByMe)
    if achievement.criteriaType == "SPECIAL" then
        return
    end

    local id = achievement.id
    forced = forced or false
    forcedByMe = false

    if WQA.db.profile.achievements[id] == "disabled" then
        return
    end
    if WQA.db.profile.achievements[id] == "exclusive" and WQA.db.profile.achievements.exclusive[id] ~= WQA.playerName then
        return
    end
    if WQA.db.profile.achievements[id] == "always" then
        forced = true
    end
    if WQA.db.profile.achievements[id] == "wasEarnedByMe" then
        forcedByMe = true
    end

    local _, _, _, completed, _, _, _, _, _, _, _, _, wasEarnedByMe = GetAchievementInfo(id)
    if (achievement.notAccountwide and not wasEarnedByMe) or not completed or forced or forcedByMe then
        if achievement.criteriaType == "ACHIEVEMENT" then
            self:Register_ACHIEVEMENT(achievement, forced, forcedByMe)
        elseif achievement.criteriaType == "QUEST_SINGLE" then
            self:Register_QUEST_SINGLE(achievement)
        elseif achievement.criteriaType == "QUEST_PIN" then
            self:Register_QUEST_PIN(achievement, forced)
        elseif achievement.criteriaType == "QUEST_FLAG" then
            self:Register_QUEST_FLAG(achievement)
        else
            local achievementNumCriteria = GetAchievementNumCriteria(id)

            if achievementNumCriteria > 0 then
                for i = 1, achievementNumCriteria do
                    local _, _, criteriaCompleted, _, _, _, _, questID = GetAchievementCriteriaInfo(id, i)

                    if not criteriaCompleted or forced then
                        if achievement.criteriaType == "QUESTS" then
                            self:Register_QUESTS(achievement, i)
                        elseif achievement.criteriaType == "MISSION_TABLE" then
                            self:Register_MISSION_TABLE(achievement, i, questID)
                        elseif achievement.criteriaType == "AREA_POI" then
                            self:Register_AREA_POI(achievement, i)
                        else
                            WQA:AddRewardToQuest(questID, "ACHIEVEMENT", id)
                        end
                    end
                end
            else
                if achievement.criteriaType == "QUESTS" then
                    self:Register_QUESTS(achievement, 1)
                end
            end
        end
    end
end

function WQA.Achievements:Register_ACHIEVEMENT(achievement, forced, forcedByMe)
    for _, criteriaAchievement in pairs(achievement.criteria) do
        self:Register(criteriaAchievement, forced, forcedByMe)
    end
end

function WQA.Achievements:Register_QUEST_SINGLE(achievement)
    local id = achievement.id

    if type(achievement.criteria) == "table" then
        for _, questID in pairs(achievement.criteria) do
            WQA:AddRewardToQuest(questID, "ACHIEVEMENT", id)
        end
    else
        WQA:AddRewardToQuest(achievement.criteria, "ACHIEVEMENT", id)
    end
end

function WQA.Achievements:Register_QUEST_PIN(achievement, forced)
    local id = achievement.id

    C_QuestLine.RequestQuestLinesForMap(achievement.mapID)
    for i = 1, GetAchievementNumCriteria(id) do
        local _, _, completed, _, _, _, _, questID = GetAchievementCriteriaInfo(id, i)

        if not questID then
            return
        end

        if not completed or forced then
            if achievement.criteriaInfo[i] then
                for _, questID in pairs(achievement.criteriaInfo[i]) do
                    WQA:AddRewardToQuest(questID, "ACHIEVEMENT", id)
                    WQA.questPinMapList[achievement.mapID] = true
                    WQA.questPinList[questID] = true
                end
            else
                WQA:AddRewardToQuest(questID, "ACHIEVEMENT", id)
                WQA.questPinMapList[achievement.mapID] = true
                WQA.questPinList[questID] = true
            end
        end
    end
end

function WQA.Achievements:Register_QUEST_FLAG(achievement)
    WQA:AddRewardToQuest(achievement.criteria, "ACHIEVEMENT", achievement.id)
    WQA.questFlagList[achievement.criteria] = true
end

function WQA.Achievements:Register_QUESTS(achievement, index)
    local id = achievement.id

    if type(achievement.criteria[index]) == "table" then
        for _, questID in pairs(achievement.criteria[index]) do
            WQA:AddRewardToQuest(questID, "ACHIEVEMENT", id)
        end
    else
        local questID = achievement.criteria[index]
        if questID then
            WQA:AddRewardToQuest(questID, "ACHIEVEMENT", id)
        end
    end
end

function WQA.Achievements:Register_MISSION_TABLE(achievement, index, criteriaQuestId)
    local id = achievement.id

    if achievement.criteria and achievement.criteria[index] then
        if type(achievement.criteria[index]) == "table" then
            for _, questID in pairs(achievement.criteria[index]) do
                WQA:AddRewardToMission(questID, "ACHIEVEMENT", id)
            end
        else
            local questID = achievement.criteria[index]
            if questID then
                WQA:AddRewardToMission(questID, "ACHIEVEMENT", id)
            end
        end
    else
        WQA:AddRewardToMission(criteriaQuestId, "ACHIEVEMENT", id)
    end
end

function WQA.Achievements:Register_AREA_POI(achievement, index)
    local id = achievement.id

    if not achievement.criteria[index].AreaPoiId then
        for _, areaPoi in pairs(achievement.criteria[index]) do
            WQA.Criterias.AreaPoi:AddReward(areaPoi, "ACHIEVEMENT", id)
        end
    else
        local areaPoi = achievement.criteria[index]
        if areaPoi then
            WQA.Criterias.AreaPoi:AddReward(areaPoi, "ACHIEVEMENT", id)
        end
    end
end
