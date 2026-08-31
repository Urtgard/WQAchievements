---@class WQATurbo
local WQA = WQATurbo

--[[
WQA Turbo non-blocking reward enrichment
=========================================

The important architectural rule in this version is:

    Blizzard reward-data readiness must never block WQA's usable results.

CreateQuestList() already constructs the static achievement, mount, pet, toy and
custom mappings. Reward() now starts dynamic reward discovery in the
background and immediately marks the reward phase as usable, allowing CheckWQ()
to display those static results without waiting for HaveQuestRewardData().

Dynamic item/currency/profession rewards are enriched later. When the
background pass finishes, CheckWQ("new") runs once so a quest that became
interesting only because of a dynamic reward can be surfaced.

This also replaces the aggressive event-driven 0.1s polling prototype. That
prototype demonstrated that polling harder cannot make Blizzard populate
reward data faster: on one test it performed 14,205 checks and 2,966 preload
reissues while the server/client cache still took ~15 seconds.

This implementation therefore:
  * requests each missing reward payload once during discovery;
  * polls unresolved IDs at a modest 0.5s cadence;
  * reissues a preload request only after 5 seconds, at most twice per quest;
  * keeps all polling frame-budgeted;
  * times out a permanently broken payload after 30 seconds;
  * never blocks normal WQA output while enrichment is pending.
]]

local GetQuestTagInfo = C_QuestLog.GetQuestTagInfo
local GetQuestZoneID = C_TaskQuest.GetQuestZoneID
local GetQuestsOnMap = C_TaskQuest.GetQuestsOnMap
local RequestPreloadRewardData = C_TaskQuest.RequestPreloadRewardData

local FRAME_BUDGET_MS = 2.0
local RETRY_INTERVAL_SECONDS = 0.50
local REISSUE_PRELOAD_AFTER_SECONDS = 5.0
local MAX_PRELOAD_REISSUES = 2
local MAX_PENDING_AGE_SECONDS = 30.0

local SkipRewardDataPreloadQuests = {
	[83366] = true, -- upstream issue #184

	-- Neighborhood weekly quests
	[95413] = true,
	[95416] = true,
	[95440] = true,
	[95438] = true
}

local workerFrame = CreateFrame("Frame")
workerFrame:Hide()

local function cancelTimer(timer)
	if timer and timer.Cancel then
		timer:Cancel()
	end
end

local function cancelStateTimer(state)
	if not state then
		return
	end

	cancelTimer(state.retryTimer)
	state.retryTimer = nil
end

local function buildZoneToExpansion(zoneIDList)
	local result = {}

	for expansion, zones in pairs(zoneIDList) do
		for _, zoneID in pairs(zones) do
			result[zoneID] = expansion
		end
	end

	return result
end

local function buildEnabledMaps(self)
	local result = {}

	for _, zones in pairs(self.ZoneIDList) do
		for _, mapID in pairs(zones) do
			if self.db.profile.options.zone[mapID] == true then
				result[#result + 1] = mapID
			end
		end
	end

	return result
end

local function addPending(
	state,
	kind,
	work,
	firstSeen,
	attempts,
	lastRequestedAt,
	reissues
)
	state.pending[#state.pending + 1] = {
		kind = kind,
		work = work,
		firstSeen = firstSeen or GetTime(),
		attempts = attempts or 1,
		lastRequestedAt = lastRequestedAt,
		reissues = reissues or 0
	}

	if #state.pending > state.stats.pendingPeak then
		state.stats.pendingPeak = #state.pending
	end
end

local function timedOut(entry)
	return GetTime() - entry.firstSeen >= MAX_PENDING_AGE_SECONDS
end

function WQA:RewardScannerProcessProfession(state, work, questTagInfo, zoneID)
	local tradeskillLineID = questTagInfo and questTagInfo.tradeskillLineID
	if not tradeskillLineID then
		return
	end

	local expansion = state.zoneToExpansion[zoneID] or 0
	local professionName = C_TradeSkillUI.GetTradeSkillDisplayName(tradeskillLineID)

	if
		not self.db.char[expansion].profession[tradeskillLineID].isMaxLevel
		and self.db.profile.options.reward[expansion].profession[tradeskillLineID].skillup
	then
		self:AddRewardToQuest(work.questID, "PROFESSION_SKILLUP", professionName)
	end
end

function WQA:RewardScannerProcessRewardDetails(state, work, questTagInfo, zoneID)
	local questID = work.questID

	local itemRetry = self:CheckItems(questID)

	self:CheckCurrencies(questID)
	self:RewardScannerProcessProfession(state, work, questTagInfo, zoneID)

	state.stats.enrichedQuests = state.stats.enrichedQuests + 1

	-- Initial-pass enrichment is already present before the first normal
	-- output. Retry-pass enrichment arrived later and should be published to
	-- the UI as soon as this retry batch finishes.
	if state.phase == "background-retry" then
		state.enrichmentDirty = true
	end

	if itemRetry then
		addPending(state, "item", work)
		state.stats.itemPending = state.stats.itemPending + 1
	end
end

function WQA:RewardScannerProcessInitialQuest(state, work)
	local questID = work.questID
	local mapID = work.mapID
	local questTagInfo = GetQuestTagInfo(questID)
	local worldQuestType = questTagInfo and questTagInfo.worldQuestType or 0
	local worldQuestTypeOptions = self.db.profile.options.reward.general.worldQuestType

	if self.questList[questID] and not worldQuestTypeOptions[worldQuestType] then
		self.questList[questID] = nil
	end

	local zoneID = GetQuestZoneID(questID)

	if
		self.db.profile.options.zone[zoneID] ~= true
		or not worldQuestTypeOptions[worldQuestType]
	then
		return
	end

	-- Preserve the original dynamically generated "100 different WQs"
	-- achievement tracking.
	if QuestUtils_IsQuestWorldQuest(questID) and not self.db.global.completed[questID] then
		local expansion = state.zoneToExpansion[zoneID] or 0

		if
			self.db.profile.achievements[11189] ~= "disabled"
			and not select(4, GetAchievementInfo(11189))
			and expansion == 7
			and mapID ~= 830
			and mapID ~= 885
			and mapID ~= 882
		then
			self:AddRewardToQuest(questID, "ACHIEVEMENT", 11189)
		elseif
			self.db.profile.achievements[13144] ~= "disabled"
			and not select(4, GetAchievementInfo(13144))
			and expansion == 8
		then
			self:AddRewardToQuest(questID, "ACHIEVEMENT", 13144)
		elseif
			self.db.profile.achievements[14758] ~= "disabled"
			and not select(4, GetAchievementInfo(14758))
			and expansion == 9
		then
			self:AddRewardToQuest(questID, "ACHIEVEMENT", 14758)
		end
	end

	if
		not SkipRewardDataPreloadQuests[questID]
		and HaveQuestData(questID)
		and not HaveQuestRewardData(questID)
	then
		local now = GetTime()
		RequestPreloadRewardData(questID)

		addPending(state, "reward", work, now, 1, now, 0)
		state.stats.rewardPending = state.stats.rewardPending + 1
		return
	end

	self:RewardScannerProcessRewardDetails(state, work, questTagInfo, zoneID)
end

function WQA:RewardScannerRetryEntry(state, entry)
	local work = entry.work
	local questID = work.questID

	state.stats.retryChecks = state.stats.retryChecks + 1

	if timedOut(entry) then
		state.stats.timedOut = state.stats.timedOut + 1
		return
	end

	if entry.kind == "reward" then
		if HaveQuestData(questID) and not HaveQuestRewardData(questID) then
			local now = GetTime()
			local lastRequestedAt = entry.lastRequestedAt or entry.firstSeen
			local reissues = entry.reissues or 0

			if
				reissues < MAX_PRELOAD_REISSUES
				and now - lastRequestedAt >= REISSUE_PRELOAD_AFTER_SECONDS
			then
				RequestPreloadRewardData(questID)
				lastRequestedAt = now
				reissues = reissues + 1
				state.stats.preloadReissues = state.stats.preloadReissues + 1
			end

			addPending(
				state,
				"reward",
				work,
				entry.firstSeen,
				entry.attempts + 1,
				lastRequestedAt,
				reissues
			)
			return
		end

		local questTagInfo = GetQuestTagInfo(questID)
		local zoneID = GetQuestZoneID(questID)
		self:RewardScannerProcessRewardDetails(state, work, questTagInfo, zoneID)
		return
	end

	if entry.kind == "item" then
		if self:CheckItems(questID) then
			addPending(
				state,
				"item",
				work,
				entry.firstSeen,
				entry.attempts + 1,
				entry.lastRequestedAt,
				entry.reissues
			)
		end
	end
end

function WQA:RewardScannerPublishPendingChanges(state)
	if not state.enrichmentDirty then
		return
	end

	state.enrichmentDirty = false
	state.stats.publishCount = state.stats.publishCount + 1

	-- Publish current results now. Do not wait for every unrelated pending
	-- quest in the world to resolve.
	self:TurboPublishEnrichment()
end

function WQA:RewardScannerScheduleRetry(state)
	if self._wqaRewardScan ~= state then
		return
	end

	state.phase = "background-wait"
	workerFrame:Hide()
	cancelStateTimer(state)

	state.retryTimer = C_Timer.NewTimer(RETRY_INTERVAL_SECONDS, function()
		if WQA._wqaRewardScan ~= state then
			return
		end

		state.retryQueue = state.pending
		state.pending = {}
		state.retryIndex = 1
		state.phase = "background-retry"
		workerFrame:Show()
	end)
end

function WQA:RewardScannerInitialPassFinished(state)
	if self._wqaRewardScan ~= state then
		return
	end

	state.stats.initialPassWallMs = (GetTime() - state.startedAt) * 1000
	state.stats.initialPassFinished = true

	-- IMPORTANT: WQA is already usable. self.rewards was deliberately set to
	-- true as soon as the background scan was scheduled, so CheckWQ did not
	-- wait for this point.
	if #state.pending > 0 then
		self:RewardScannerScheduleRetry(state)
	else
		self:RewardScannerFinish(state)
	end
end

function WQA:RewardScannerFinish(state)
	if self._wqaRewardScan ~= state then
		return
	end

	workerFrame:Hide()
	cancelStateTimer(state)

	state.stats.wallMs = (GetTime() - state.startedAt) * 1000
	state.stats.finished = true
	state.stats.pendingRemaining = #state.pending

	self.rewardScannerLastStats = state.stats
	self._wqaRewardScan = nil

	-- Any retry-batch discoveries were already published progressively.
	-- If enrichmentDirty somehow remains set (for example because completion
	-- happened through a future code path), flush it once here.
	self:RewardScannerPublishPendingChanges(state)
end

function WQA:RewardScannerStepInitial(state)
	if state.currentQuests then
		if state.currentQuestIndex <= #state.currentQuests then
			local quest = state.currentQuests[state.currentQuestIndex]
			state.currentQuestIndex = state.currentQuestIndex + 1

			if quest and quest.questID then
				state.stats.questVisits = state.stats.questVisits + 1
				self:RewardScannerProcessInitialQuest(
					state,
					{
						questID = quest.questID,
						mapID = state.currentMapID
					}
				)
			end

			return true
		end

		state.currentQuests = nil
		state.currentQuestIndex = 1
		state.currentMapID = nil
	end

	if state.mapIndex <= #state.maps then
		local mapID = state.maps[state.mapIndex]
		state.mapIndex = state.mapIndex + 1
		state.currentMapID = mapID
		state.currentQuests = GetQuestsOnMap(mapID) or {}
		state.currentQuestIndex = 1
		state.stats.mapsScanned = state.stats.mapsScanned + 1
		return true
	end

	self:RewardScannerInitialPassFinished(state)
	return false
end

function WQA:RewardScannerStepRetry(state)
	if state.retryIndex <= #state.retryQueue then
		local entry = state.retryQueue[state.retryIndex]
		state.retryIndex = state.retryIndex + 1

		if entry then
			self:RewardScannerRetryEntry(state, entry)
		end

		return true
	end

	state.retryQueue = nil

	-- Some quests may have become useful during this retry batch. Surface
	-- them now, even if hundreds of unrelated reward payloads remain pending.
	self:RewardScannerPublishPendingChanges(state)

	if #state.pending > 0 then
		self:RewardScannerScheduleRetry(state)
	else
		self:RewardScannerFinish(state)
	end

	return false
end

function WQA:RewardScannerStep(state)
	if state.phase == "initial" then
		return self:RewardScannerStepInitial(state)
	elseif state.phase == "background-retry" then
		return self:RewardScannerStepRetry(state)
	end

	return false
end

function WQA:RewardScannerRunSlice(state)
	if self._wqaRewardScan ~= state then
		workerFrame:Hide()
		return
	end

	local sliceStart = debugprofilestop()

	repeat
		local continueNow = self:RewardScannerStep(state)

		if not continueNow then
			break
		end
	until debugprofilestop() - sliceStart >= FRAME_BUDGET_MS

	local elapsed = debugprofilestop() - sliceStart
	state.stats.slices = state.stats.slices + 1
	state.stats.cpuMs = state.stats.cpuMs + elapsed

	if elapsed > state.stats.maxSliceMs then
		state.stats.maxSliceMs = elapsed
	end
end

workerFrame:SetScript("OnUpdate", function()
	local state = WQA._wqaRewardScan

	if not state then
		workerFrame:Hide()
		return
	end

	WQA:RewardScannerRunSlice(state)
end)

function WQA:Reward()
	self:Debug("Reward (WQA Turbo background enrichment)")

	local oldState = self._wqaRewardScan
	if oldState then
		cancelStateTimer(oldState)
	end

	self._wqaRewardScanGeneration = (self._wqaRewardScanGeneration or 0) + 1

	if self.db.profile.options.reward.gear.azeriteTraits ~= "" then
		self.azeriteTraitsList = {}

		for spellID in string.gmatch(
			self.db.profile.options.reward.gear.azeriteTraits,
			"(%d+)"
		) do
			self.azeriteTraitsList[tonumber(spellID)] = true
		end
	end

	local state = {
		generation = self._wqaRewardScanGeneration,
		startedAt = GetTime(),
		phase = "initial",

		maps = buildEnabledMaps(self),
		mapIndex = 1,
		currentMapID = nil,
		currentQuests = nil,
		currentQuestIndex = 1,

		zoneToExpansion = buildZoneToExpansion(self.ZoneIDList),

		pending = {},
		retryQueue = nil,
		retryIndex = 1,
		retryTimer = nil,
		enrichmentDirty = false,

		stats = {
			finished = false,
			initialPassFinished = false,
			initialPassWallMs = 0,
			mapsScanned = 0,
			questVisits = 0,
			rewardPending = 0,
			itemPending = 0,
			pendingPeak = 0,
			retryChecks = 0,
			preloadReissues = 0,
			enrichedQuests = 0,
			publishCount = 0,
			timedOut = 0,
			slices = 0,
			cpuMs = 0,
			maxSliceMs = 0,
			wallMs = 0
		}
	}

	self._wqaRewardScan = state
	self.rewardScannerCurrentStats = state.stats

	-- Critical non-blocking change:
	--
	-- Static achievement / mount / pet / toy / custom data was already added
	-- to questList by CreateQuestList(). Dynamic reward enrichment is optional
	-- background work and must not hold CheckWQ behind its old .4s retry loop.
	self.rewards = true

	workerFrame:Show()
end

function WQA:PrintRewardScannerStatus()
	local state = self._wqaRewardScan
	local stats = state and state.stats or self.rewardScannerLastStats

	if not stats then
		print("|cff00ccffWQA TURBO SCAN|r no scan data yet")
		return
	end

	local phase = state and state.phase or "finished"
	local pending = state and #state.pending or (stats.pendingRemaining or 0)

	print(string.format(
		"|cff00ccffWQA TURBO SCAN|r phase=%s usable=yes maps=%d quests=%d pending=%d rewardPending=%d itemPending=%d retries=%d reissues=%d enriched=%d publishes=%d timedOut=%d slices=%d cpu=%.3fms maxSlice=%.3fms initial=%.0fms enrichment=%.0fms",
		phase,
		stats.mapsScanned or 0,
		stats.questVisits or 0,
		pending,
		stats.rewardPending or 0,
		stats.itemPending or 0,
		stats.retryChecks or 0,
		stats.preloadReissues or 0,
		stats.enrichedQuests or 0,
		stats.publishCount or 0,
		stats.timedOut or 0,
		stats.slices or 0,
		stats.cpuMs or 0,
		stats.maxSliceMs or 0,
		stats.initialPassWallMs or 0,
		stats.wallMs or 0
	))
end

WQA:RegisterChatCommand("wqascan", "PrintRewardScannerStatus")
