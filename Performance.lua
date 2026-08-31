---@class WQAchievements
local WQA = WQAchievements

local unpackResults = table.unpack or unpack

local function packResults(...)
	return {
		n = select("#", ...),
		...
	}
end

WQA.perf = WQA.perf or {
	stats = {}
}

WQA.perf.stats = WQA.perf.stats or {}

---Record one measured execution.
---@param label string
---@param elapsed number milliseconds
function WQA:PerfRecord(label, elapsed)
	local stat = self.perf.stats[label]

	if not stat then
		stat = {
			calls = 0,
			total = 0,
			max = 0
		}
		self.perf.stats[label] = stat
	end

	stat.calls = stat.calls + 1
	stat.total = stat.total + elapsed

	if elapsed > stat.max then
		stat.max = elapsed
	end
end

---Start a performance measurement.
---@return number startTime
function WQA:PerfStart()
	return debugprofilestop()
end

---Finish a performance measurement.
---@param label string
---@param startTime number
---@return number elapsed
function WQA:PerfStop(label, startTime)
	local elapsed = debugprofilestop() - startTime
	self:PerfRecord(label, elapsed)
	return elapsed
end

---Clear collected function timings and scanner summary data.
function WQA:ResetPerf()
	wipe(self.perf.stats)
	self.rewardScannerLastStats = nil

	print("|cff00ccffWQA TURBO PERF|r measurements reset")
end

local function printRewardScannerSummary(self)
	local state = self._wqaRewardScan
	local stats = state and state.stats or self.rewardScannerLastStats

	if not stats then
		return
	end

	local phase = state and state.phase or "finished"
	local pending = state and #state.pending or (stats.pendingRemaining or 0)

	print("|cff00ccffWQA TURBO PERF|r incremental Reward scanner")
	print(string.format(
		"phase=%s maps=%d quests=%d pending=%d rewardPending=%d itemPending=%d",
		phase,
		stats.mapsScanned or 0,
		stats.questVisits or 0,
		pending,
		stats.rewardPending or 0,
		stats.itemPending or 0
	))
	print(string.format(
		"retryChecks=%d reissues=%d timedOut=%d slices=%d cpu=%.3fms maxSlice=%.3fms wall=%.0fms",
		stats.retryChecks or 0,
		stats.preloadReissues or 0,
		stats.timedOut or 0,
		stats.slices or 0,
		stats.cpuMs or 0,
		stats.maxSliceMs or 0,
		stats.wallMs or 0
	))
end

---Print collected measurements ordered by worst single execution.
function WQA:PrintPerfSummary()
	local rows = {}

	for label, stat in pairs(self.perf.stats) do
		rows[#rows + 1] = {
			label = label,
			calls = stat.calls,
			total = stat.total,
			average = stat.total / stat.calls,
			max = stat.max
		}
	end

	table.sort(rows, function(a, b)
		return a.max > b.max
	end)

	print("|cff00ccffWQA TURBO PERF|r summary")

	if #rows == 0 then
		print("No function measurements recorded.")
	else
		for _, row in ipairs(rows) do
			print(string.format(
				"%-28s calls=%3d total=%8.3fms avg=%7.3fms max=%8.3fms",
				row.label,
				row.calls,
				row.total,
				row.average,
				row.max
			))
		end
	end

	printRewardScannerSummary(self)
end

---Slash command:
---  /wqaperf
---  /wqaperf reset
function WQA:PerfSlash(input)
	input = string.lower(strtrim(input or ""))

	if input == "reset" then
		self:ResetPerf()
	else
		self:PrintPerfSummary()
	end
end

WQA:RegisterChatCommand("wqaperf", "PerfSlash")

---Wrap an existing method with low-overhead timing instrumentation.
---Return values are preserved, including nil values.
---@param object table
---@param methodName string
---@param label string?
local function WrapMethod(object, methodName, label)
	local original = object[methodName]

	if type(original) ~= "function" then
		return
	end

	label = label or methodName

	object[methodName] = function(self, ...)
		local started = debugprofilestop()
		local results = packResults(original(self, ...))
		local elapsed = debugprofilestop() - started

		WQA:PerfRecord(label, elapsed)

		return unpackResults(results, 1, results.n)
	end
end

-- Addon lifecycle
WrapMethod(WQA, "OnInitialize")
WrapMethod(WQA, "OnEnable")

-- Main refresh pipeline
WrapMethod(WQA, "Show")
WrapMethod(WQA, "ShowCached")
WrapMethod(WQA, "Refresh")
WrapMethod(WQA, "TurboPublishEnrichment")
WrapMethod(WQA, "TurboRefreshOpenPopup")
WrapMethod(WQA, "CreateQuestList")
WrapMethod(WQA, "Reward")
WrapMethod(WQA, "EmissaryReward")
WrapMethod(WQA, "CheckWQ")
WrapMethod(WQA, "TurboPrepareWorldQuest")
WrapMethod(WQA, "TurboPrepareMission")

-- Incremental scanner: this measures one complete per-frame worker slice.
WrapMethod(WQA, "RewardScannerRunSlice")

-- Collection/database construction
WrapMethod(WQA, "BuildMountCollectionCache")
WrapMethod(WQA, "BuildPetCollectionCache")
WrapMethod(WQA, "AddMounts")
WrapMethod(WQA, "AddPets")
WrapMethod(WQA, "AddToys")
WrapMethod(WQA, "AddCustom")
WrapMethod(WQA, "Special")

-- Secondary processing
-- Deliberately do not wrap CheckItems/CheckReward/CheckCurrencies here:
-- they are hot per-quest functions, and allocating profiler return tables for
-- every call would distort the very frame-budget test we are trying to run.
WrapMethod(WQA, "CheckMissions")
WrapMethod(WQA, "SortQuestList")

-- Output/UI
WrapMethod(WQA, "AnnounceChat")
WrapMethod(WQA, "AnnouncePopUp")
WrapMethod(WQA, "AnnounceLDB")
WrapMethod(WQA, "UpdateQTip")

-- Area POI processing lives on its own object.
if WQA.Criterias and WQA.Criterias.AreaPoi then
	WrapMethod(WQA.Criterias.AreaPoi, "Check", "AreaPoi.Check")
end
