---@class WQAchievements
local WQA = WQAchievements

local unpackResults = table.unpack or unpack

local function packResults(...)
	return {
		n = select("#", ...),
		...
	}
end

WQA.perf = {
	stats = {}
}

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

---Clear all collected performance measurements.
function WQA:ResetPerf()
	wipe(self.perf.stats)
	self.perf.rewardDiagnostics = {}
	print("|cff00ccffWQA PERF|r measurements reset")
end

---Print collected measurements ordered by worst single execution.
function WQA:PrintPerfSummary()
	local rows = {}

	for label, stat in pairs(self.perf.stats) do
		table.insert(rows, {
			label = label,
			calls = stat.calls,
			total = stat.total,
			average = stat.total / stat.calls,
			max = stat.max
		})
	end

	table.sort(rows, function(a, b)
		return a.max > b.max
	end)

	print("|cff00ccffWQA PERF|r summary")

	if #rows == 0 then
		print("No measurements recorded.")
		return
	end

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
	if self.perf.rewardDiagnostics then
		print("|cff00ccffWQA PERF|r Reward diagnostics")

		for run, diag in ipairs(self.perf.rewardDiagnostics) do
			local missing = {}
			local itemRetries = {}

			for questID in pairs(diag.missingRewardData) do
				table.insert(missing, questID)
			end

			for questID in pairs(diag.itemRetries) do
				table.insert(itemRetries, questID)
			end

			table.sort(missing)
			table.sort(itemRetries)

			print(string.format(
				"run=%d maps=%d quests=%d missingRewardData=%d itemRetries=%d",
				run,
				diag.maps,
				diag.quests,
				#missing,
				#itemRetries
			))

			if #missing > 0 then
				print("  missing reward data: " .. table.concat(missing, ", "))
			end

			if #itemRetries > 0 then
				print("  item retries: " .. table.concat(itemRetries, ", "))
			end
		end
	end
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
WrapMethod(WQA, "CreateQuestList")
WrapMethod(WQA, "Reward")
WrapMethod(WQA, "EmissaryReward")
WrapMethod(WQA, "CheckWQ")

-- Collection/database construction
WrapMethod(WQA, "AddMounts")
WrapMethod(WQA, "AddPets")
WrapMethod(WQA, "AddToys")
WrapMethod(WQA, "AddCustom")
WrapMethod(WQA, "Special")

-- Secondary processing
WrapMethod(WQA, "CheckMissions")
WrapMethod(WQA, "SortQuestList")
WrapMethod(WQA, "CheckItems")
WrapMethod(WQA, "CheckReward")
WrapMethod(WQA, "CheckCurrencies")
WrapMethod(WQA, "GetExpansionByQuestID")

-- Output/UI
WrapMethod(WQA, "AnnounceChat")
WrapMethod(WQA, "AnnouncePopUp")
WrapMethod(WQA, "AnnounceLDB")
WrapMethod(WQA, "UpdateQTip")

-- Area POI processing lives on its own object.
if WQA.Criterias and WQA.Criterias.AreaPoi then
	WrapMethod(WQA.Criterias.AreaPoi, "Check", "AreaPoi.Check")
end