---@class WQAchievements
local WQA = WQAchievements

local L = WQA.L
local LibQTip = LibStub("LibQTip-1.0")

function WQA:CreateQTip()
    if not LibQTip:IsAcquired("WQAchievements") and not self.tooltip then
        local tooltip = LibQTip:Acquire("WQAchievements", 2, "LEFT", "LEFT")
        self.tooltip = tooltip

        tooltip:SetScript(
            "OnHide",
            function()
                if WQA.PopUp then
                    WQA.PopUp:Hide()
                end
            end
        )

        if self.db.profile.options.popupShowExpansion or self.db.profile.options.popupShowZone then
            tooltip:AddColumn()
        end
        if self.db.profile.options.popupShowTime then
            tooltip:AddColumn()
        end

        tooltip:AddHeader(_G.WORLD_QUEST_BANNER)
        tooltip:SetCell(1, tooltip:GetColumnCount(), _G.REWARDS)
        tooltip:SetFrameStrata("MEDIUM")
        tooltip:SetFrameLevel(100)
        tooltip:AddSeparator()
    end
end

---@param questID number
local function GetIconTexture(questID)
    local texture = select(2, GetQuestLogRewardInfo(1, questID))
    if texture then
        return texture
    end

    local currencyInfo = C_QuestLog.GetQuestRewardCurrencyInfo(questID, 1, false)
    if currencyInfo then
        return currencyInfo.texture
    end

    return [[Interface\GossipFrame\auctioneerGossipIcon]]
end

function WQA:UpdateQTip(tasks)
    local tooltip = self.tooltip
    if next(tasks) == nil then
        tooltip:AddLine(L["NO_QUESTS"])
    else
        tooltip.quests = tooltip.quests or {}
        tooltip.missions = tooltip.missions or {}
        tooltip.pois = tooltip.pois or {}

        local i = tooltip:GetLineCount()
        local expansion, zoneID
        for _, task in ipairs(tasks) do
            local id = task.id
            if
                (task.type == "WORLD_QUEST" and not tooltip.quests[id]) or
                    (task.type == "MISSION" and not tooltip.missions[id]) or
                    (task.type == "AREA_POI" and not tooltip.pois[id])
             then
                local j = 1

                if self.db.profile.options.popupShowExpansion then
                    j = 2
                    if self:GetExpansion(task) ~= expansion then
                        expansion = self:GetExpansion(task)
                        tooltip:AddLine(string.format("|cff33ff33%s|r", self:GetExpansionName(expansion)))
                        i = i + 1
                        zoneID = nil
                    end
                end

                tooltip:AddLine()
                i = i + 1

                if self.db.profile.options.popupShowZone then
                    j = 2
                    if self:GetTaskZoneID(task) ~= zoneID then
                        zoneID = self:GetTaskZoneID(task)
                        tooltip:SetCell(i, 1, "     " .. self:GetTaskZoneName(task))
                    end
                end

                if self.db.profile.options.popupShowTime then
                    tooltip:SetCell(i, j, self:formatTime(self:GetTaskTime(task)))
                    j = j + 1
                end

                if task.type == "WORLD_QUEST" then
                    tooltip.quests[id] = true
                elseif task.type == "MISSION" then
                    tooltip.missions[id] = true
                end

                local link = self:GetTaskLink(task)
                tooltip:SetCell(i, j, link)

                tooltip:SetCellScript(
                    i,
                    j,
                    "OnEnter",
                    function(self)
                        GameTooltip_SetDefaultAnchor(GameTooltip, self)
                        GameTooltip:ClearLines()
                        GameTooltip:ClearAllPoints()
                        GameTooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 0)
                        if task.type == "WORLD_QUEST" then
                            if string.find(link, "|Hquest:") then
                                GameTooltip:SetHyperlink(link)
                            end
                        elseif task.type == "MISSION" then
                            GameTooltip:SetText(C_Garrison.GetMissionName(id))
                            GameTooltip:AddLine(
                                string.format(
                                    GARRISON_MISSION_TOOLTIP_NUM_REQUIRED_FOLLOWERS,
                                    C_Garrison.GetMissionMaxFollowers(id)
                                ),
                                1,
                                1,
                                1
                            )
                            GarrisonMissionButton_AddThreatsToTooltip(
                                id,
                                WQA.missionList[task.id].followerType,
                                false,
                                C_Garrison.GetFollowerAbilityCountersForMechanicTypes(
                                    WQA.missionList[task.id].followerType
                                )
                            )
                            GameTooltip:AddLine(GARRISON_MISSION_AVAILABILITY)
                            GameTooltip:AddLine(WQA.missionList[task.id].offerTimeRemaining, 1, 1, 1)
                            if not C_Garrison.IsPlayerInGarrison(WQA.missionList[task.id].followerType) then
                                GameTooltip:AddLine(" ")
                                GameTooltip:AddLine(
                                    GarrisonFollowerOptions[WQA.missionList[task.id].followerType].strings.RETURN_TO_START,
                                    nil,
                                    nil,
                                    nil,
                                    1
                                )
                            end
                        elseif task.type == "AREA_POI" then
                            local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(task.mapId, task.id)

                            GameTooltip_SetTitle(GameTooltip, poiInfo.name, HIGHLIGHT_FONT_COLOR)

                            if poiInfo.description then
                                GameTooltip_AddNormalLine(GameTooltip, poiInfo.description)
                            end

                            if C_AreaPoiInfo.IsAreaPOITimed(poiInfo.areaPoiID) then
                                local secondsLeft = C_AreaPoiInfo.GetAreaPOISecondsLeft(poiInfo.areaPoiID)
                                if secondsLeft and secondsLeft > 0 then
                                    local timeString = SecondsToTime(secondsLeft)
                                    GameTooltip_AddNormalLine(GameTooltip, BONUS_OBJECTIVE_TIME_LEFT:format(timeString))
                                end
                            end

                            if poiInfo.textureKit == "OribosGreatVault" then
                                GameTooltip_AddBlankLineToTooltip(GameTooltip)
                                GameTooltip_AddInstructionLine(GameTooltip, ORIBOS_GREAT_VAULT_POI_TOOLTIP_INSTRUCTIONS)
                            end

                            if poiInfo.widgetSetID then
                                GameTooltip_AddWidgetSet(GameTooltip, poiInfo.widgetSetID, 10)
                            end

                            if poiInfo.textureKit then
                                local backdropStyle = GAME_TOOLTIP_TEXTUREKIT_BACKDROP_STYLES[poiInfo.textureKit]
                                if (backdropStyle) then
                                    SharedTooltip_SetBackdropStyle(GameTooltip, backdropStyle)
                                end
                            end
                        end
                        GameTooltip:Show()
                    end
                )
                tooltip:SetCellScript(
                    i,
                    j,
                    "OnLeave",
                    function()
                        GameTooltip:Hide()
                    end
                )
                tooltip:SetCellScript(
                    i,
                    j,
                    "OnMouseDown",
                    function()
                        if ChatEdit_TryInsertChatLink(link) ~= true then
                            if task.type == "WORLD_QUEST" and not (self.questPinList[id] or self.questFlagList[id]) then
                                if WorldQuestTrackerAddon and self.db.profile.options.WorldQuestTracker then
                                    if WorldQuestTrackerAddon.IsQuestBeingTracked(id) then
                                        WorldQuestTrackerAddon.RemoveQuestFromTracker(id)
                                        WQA:ScheduleTimer(
                                            function()
                                                WorldQuestTrackerAddon:FullTrackerUpdate()
                                            end,
                                            .5
                                        )
                                    else
                                        local _, _, numObjectives = GetTaskInfo(id)
                                        local widget = {
                                            questID = id,
                                            mapID = self:GetQuestZoneID(id),
                                            numObjectives = numObjectives
                                        }
                                        zoneID = self:GetQuestZoneID(id)
                                        local x, y = C_TaskQuest.GetQuestLocation(id, zoneID)
                                        widget.questX, widget.questY = x or 0, y or 0
                                        widget.IconTexture = GetIconTexture(id)
                                        local function f(widget)
                                            if not widget.IconTexture then
                                                WQA:ScheduleTimer(
                                                    function()
                                                        widget.IconTexture = GetIconTexture(id)
                                                        f(widget)
                                                    end,
                                                    1.5
                                                )
                                            else
                                                WorldQuestTrackerAddon.AddQuestToTracker(widget)
                                                WQA:ScheduleTimer(
                                                    function()
                                                        WorldQuestTrackerAddon:FullTrackerUpdate()
                                                    end,
                                                    .5
                                                )
                                            end
                                        end
                                        f(widget)
                                    end
                                else
                                    if not C_QuestLog.AddWorldQuestWatch(id, 1) then
                                        C_QuestLog.RemoveWorldQuestWatch(id)
                                    end
                                end
                            end
                        end
                    end
                )

                local list
                if task.type == "WORLD_QUEST" then
                    list = WQA.questList[id].reward
                elseif task.type == "MISSION" then
                    list = WQA.missionList[id].reward
                elseif task.type == "AREA_POI" then
                    list = WQA.Criterias.AreaPoi.list[task.id][task.mapId].reward
                end

                local more = false
                for k, v in pairs(list) do
                    for n = 1, 3 do
                        if n == 1 or (n > 1 and (k == "achievement" or k == "chance" or k == "azeriteTraits")) then
                            local text = self:GetRewardTextByID(id, k, v, n, task.type)
                            if text then
                                j = j + 1

                                if j > tooltip:GetColumnCount() then
                                    tooltip:AddColumn()
                                end
                                tooltip:SetCell(i, j, text)

                                tooltip:SetCellScript(
                                    i,
                                    j,
                                    "OnEnter",
                                    function(self)
                                        GameTooltip:SetOwner(self, "ANCHOR_NONE")
                                        GameTooltip:ClearLines()
                                        ContainerFrameItemButton_CalculateItemTooltipAnchors(self, GameTooltip)

                                        local link = WQA:GetRewardLinkByID(id, k, v, n)
                                        if link and link ~= "" then
                                            GameTooltip:SetHyperlink(link)
                                        else
                                            -- Fallback for currency/gold (our custom string) — still show tooltip via text
                                            local text = WQA:GetRewardTextByID(id, k, v, n, task.type)
                                            if text then
                                                -- Extract item/currency ID if possible and try to show proper tooltip
                                                local itemID = text:match("item:(%d+)")
                                                local currencyID = text:match("currency:(%d+)")
                                                if itemID then
                                                    GameTooltip:SetItemByID(tonumber(itemID))
                                                elseif currencyID then
                                                    GameTooltip:SetCurrencyByID(tonumber(currencyID))
                                                else
                                                    GameTooltip:SetText(text, 1, 1, 1, 1, true)
                                                end
                                            end
                                        end

                                        -- Compare items on shift-click (for gear)
                                        if
                                            (IsModifiedClick("COMPAREITEMS") or GetCVarBool("alwaysCompareItems")) and
                                                k == "item"
                                         then
                                            GameTooltip_ShowCompareItem()
                                        else
                                            GameTooltip_HideShoppingTooltips(GameTooltip)
                                        end

                                        GameTooltip:Show()
                                    end
                                )
                                tooltip:SetCellScript(
                                    i,
                                    j,
                                    "OnLeave",
                                    function()
                                        GameTooltip_HideResetCursor()
                                    end
                                )
                                tooltip:SetCellScript(
                                    i,
                                    j,
                                    "OnMouseDown",
                                    function()
                                        HandleModifiedItemClick(WQA:GetRewardLinkByID(id, k, v, n))
                                    end
                                )
                                if n == 3 then
                                    local m = 4
                                    if self:GetRewardTextByID(id, k, v, m, task.type) then
                                        j = j + 1
                                        if j > tooltip:GetColumnCount() then
                                            tooltip:AddColumn()
                                        end
                                        tooltip:SetCell(i, j, "...")
                                        local moreTooltipText = ""
                                        while self:GetRewardTextByID(id, k, v, m, task.type) do
                                            if m == 4 then
                                                moreTooltipText =
                                                    moreTooltipText .. self:GetRewardTextByID(id, k, v, m, task.type)
                                            else
                                                moreTooltipText =
                                                    moreTooltipText ..
                                                    "\n" .. self:GetRewardTextByID(id, k, v, m, task.type)
                                            end
                                            m = m + 1
                                        end

                                        tooltip:SetCellScript(
                                            i,
                                            j,
                                            "OnEnter",
                                            function(self)
                                                GameTooltip_SetDefaultAnchor(GameTooltip, self)
                                                GameTooltip:ClearLines()
                                                GameTooltip:ClearAllPoints()
                                                GameTooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 0)
                                                GameTooltip:SetText(moreTooltipText)
                                                GameTooltip:Show()
                                            end
                                        )
                                        tooltip:SetCellScript(
                                            i,
                                            j,
                                            "OnLeave",
                                            function()
                                                GameTooltip:Hide()
                                            end
                                        )
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    tooltip:Show()
end

function WQA:AnnouncePopUp(quests, silent)
    if not self.PopUp then
        local PopUp = CreateFrame("Frame", "WQAchievementsPopUp", UIParent, "UIPanelDialogTemplate")
        PopUp:SetMovable(true)
        PopUp:EnableMouse(true)
        PopUp:RegisterForDrag("LeftButton")
        PopUp:SetScript("OnDragStart", PopUp.StartMoving)
        PopUp:SetScript(
            "OnDragStop",
            function(self)
                self:StopMovingOrSizing()
                if WQA.db.profile.options.popupRememberPosition then
                    WQA.db.profile.options.popupX = self:GetLeft()
                    WQA.db.profile.options.popupY = self:GetTop()
                end
            end
        )

        -- ESC closes window
        if WQA.db.profile.options.esc then
            tinsert(UISpecialFrames, PopUp:GetName())
        end

        local scroll = CreateFrame("ScrollFrame", nil, PopUp, "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", 9, -30)
        scroll:SetPoint("BOTTOMRIGHT", -14, 13)
        scroll:SetClipsChildren(true)

        -- Content frame — tooltip is placed inside here
        local content = CreateFrame("Frame", nil, scroll)
        content:SetSize(500, 20)
        scroll:SetScrollChild(content)

        PopUp.close = CreateFrame("Button", nil, PopUp, "UIPanelCloseButton")
        PopUp.close:SetPoint("TOPRIGHT", -4, -4)

        -- Assign
        self.PopUp = PopUp
        self.PopUp.content = content
        self.PopUp.scroll = scroll
    end

    -- no quests and silent → don't show popup
    if not next(quests) and silent then
        return
    end

    local PopUp = self.PopUp
    PopUp:Show()
    PopUp.shown = true

    self:CreateQTip()
    self.tooltip:ClearAllPoints()
    self.tooltip:SetParent(PopUp.content)
    self.tooltip:SetPoint("TOPLEFT")
    self.tooltip:SetPoint("TOPRIGHT")

    -- fill tooltip with quest data
    self:UpdateQTip(quests)

    local tooltipHeight = self.tooltip:GetHeight()
    PopUp.content:SetHeight(tooltipHeight + 20)

    local scrollbar = PopUp.scroll.ScrollBar or PopUp.scroll.scrollBar
    if scrollbar then
        scrollbar:ClearAllPoints()
        scrollbar:SetPoint("TOPLEFT", PopUp.scroll, "TOPRIGHT", -12, -18)
        scrollbar:SetPoint("BOTTOMLEFT", PopUp.scroll, "BOTTOMRIGHT", -12, 18)
    end

    local width = WQA.db.profile.options.popupWidth or 600
    local maxHeight = WQA.db.profile.options.popupMaxHeight or 700
    local scale = WQA.db.profile.options.popupScale or 1.0

    PopUp:SetWidth(width * scale)
    PopUp:SetHeight(math.min(tooltipHeight + 100, maxHeight) * scale)
    PopUp:SetScale(scale)

    -- Apply content width relative to frame width
    PopUp.content:SetWidth(width - 50)

    if WQA.db.profile.options.popupRememberPosition then
        PopUp:ClearAllPoints()
        PopUp:SetPoint(
            "TOPLEFT",
            UIParent,
            "BOTTOMLEFT",
            WQA.db.profile.options.popupX or (UIParent:GetWidth() / 2 - PopUp:GetWidth() / 2),
            WQA.db.profile.options.popupY or (UIParent:GetHeight() / 2 + PopUp:GetHeight() / 2)
        )
    end
end

function WQA:SortByZoneName(a, b)
    if a.type == "MISSION" and b.type ~= "MISSION" then
        return false
    elseif b.type == "MISSION" and a.type ~= "MISSION" then
        return true
    elseif a.type == "MISSION" and b.type == "MISSION" then
        return self:GetTaskZoneName(a) < self:GetTaskZoneName(b)
    end

    if a.type == "WORLD_QUEST" and WQA.questList[a.id].isEmissary ~= nil then
        if b.type == "WORLD_QUEST" and WQA.questList[b.id].isEmissary ~= nil then
            return false
        else
            return true
        end
    elseif b.type == "WORLD_QUEST" and WQA.questList[b.id].isEmissary ~= nil then
        return false
    end

    return self:GetTaskZoneName(a) < self:GetTaskZoneName(b)
end

function WQA:SortByExpansion(a, b)
    a = self:GetExpansion(a)

    b = self:GetExpansion(b)
    --returnself:GetExpansion(a) >self:GetExpansion(b)
    return a > b
end
