---@class WQAchievements
local WQA = WQAchievements

--[[
WQA Turbo runtime cleanup
=========================

This replaces the upstream OnEnable() startup path.

Removed:
  * the synchronous "preload every enabled map" login scan;
  * the old QUEST_LOG_UPDATE / GET_ITEM_INFO_RECEIVED branch that restarted
    the entire Reward() function;
  * the extra +1 second startup delay that existed to accommodate that preload.

Preserved:
  * login scan / automatic output;
  * combat deferral;
  * quest completion tracking;
  * garrison mission updates;
  * the 30-minute automatic refresh schedule;
  * existing /wqa compatibility.
]]

local STARTUP_DELAY_CAP_SECONDS = 1.0

function WQA:OnEnable()
	local name, server = UnitFullName("player")
	self.playerName = name .. "-" .. server

	-- Keep the original option-table identifiers for now so existing option
	-- code and Settings.OpenToCategory("WQAchievements") continue to work.
	LibStub("AceConfig-3.0"):RegisterOptionsTable(
		"WQAchievements",
		function()
			return self:GetOptions()
		end
	)

	self.optionsFrame =
		LibStub("AceConfigDialog-3.0"):AddToBlizOptions(
			"WQAchievements",
			"WQA Turbo"
		)

	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("WQAProfiles", profiles)

	self.optionsFrame.Profiles =
		LibStub("AceConfigDialog-3.0"):AddToBlizOptions(
			"WQAProfiles",
			"Profiles",
			"WQA Turbo"
		)

	self.event = CreateFrame("Frame")
	self.event:RegisterEvent("PLAYER_ENTERING_WORLD")
	self.event:RegisterEvent("GARRISON_MISSION_LIST_UPDATE")

	self.event:SetScript("OnEvent", function(_, eventName, id)
		if eventName == "PLAYER_ENTERING_WORLD" then
			self.event:UnregisterEvent("PLAYER_ENTERING_WORLD")

			-- Turbo no longer needs a long login delay to let a synchronous
			-- reward preload run first. Respect smaller user values, but cap
			-- legacy/default values at one second.
			local configuredDelay =
				tonumber(self.db.profile.options.delay) or STARTUP_DELAY_CAP_SECONDS

			local startupDelay = math.max(
				0,
				math.min(configuredDelay, STARTUP_DELAY_CAP_SECONDS)
			)

			self:ScheduleTimer("Show", startupDelay, nil, true)

			-- Preserve upstream refresh alignment and recurring refresh.
			self:ScheduleTimer(
				function()
					self:Show("new", true)
					self:ScheduleRepeatingTimer("Show", 30 * 60, "new", true)
				end,
				(32 - (date("%M") % 30)) * 60
			)

		elseif eventName == "PLAYER_REGEN_ENABLED" then
			self.event:UnregisterEvent("PLAYER_REGEN_ENABLED")
			self:Show("new", true)

		elseif eventName == "QUEST_TURNED_IN" then
			self.db.global.completed[id] = true

		elseif eventName == "GARRISON_MISSION_LIST_UPDATE" then
			self:CheckMissions()
		end
	end)

	C_AddOns.LoadAddOn("Blizzard_GarrisonUI")
end

-- Keep the original /wqa command for users migrating from WQAchievements.
-- Add one compact Turbo command for development and later release use.
function WQA:TurboSlash(input)
	local command = string.match(input or "", "^(%S*)")
	command = string.lower(command or "")

	if command == "" then
		-- Display the current cache immediately. Do not restart the scanner.
		self:ShowCached()
	elseif command == "refresh" then
		-- Explicit full refresh.
		self:Refresh()
	elseif command == "new" then
		self:Refresh("new")
	elseif command == "popup" then
		self:ShowCached("popup")
	elseif command == "perf" then
		self:PrintPerfSummary()
	elseif command == "reset" then
		self:ResetPerf()
	elseif command == "scan" then
		self:PrintRewardScannerStatus()
	elseif command == "cache" then
		self:CollectionCacheSlash()
	else
		print("|cff00ccffWQA Turbo|r commands:")
		print("/wqat - show current results instantly")
		print("/wqat refresh - rebuild and rescan")
		print("/wqat new - refresh and announce newly found tasks")
		print("/wqat popup - open cached popup")
		print("/wqat perf - performance summary")
		print("/wqat scan - scanner status")
		print("/wqat cache - collection-cache status")
		print("/wqat reset - reset profiler counters")
	end
end

WQA:RegisterChatCommand("wqat", "TurboSlash")
