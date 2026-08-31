---@class WQAchievements
local WQA = WQAchievements
local LibQTip = LibStub("LibQTip-1.0")

--[[
WQA Turbo cached UI
===================

Upstream WQAchievements uses WQA:Show() for two different jobs:

  1. rebuild/refresh the entire data model;
  2. display that model in chat, the minimap popup, or the LDB tooltip.

That means even clicking the minimap icon calls CreateQuestList() again.

Turbo separates those concerns:

  * popup/LDB requests render the current cache immediately;
  * /wqat renders the current cache immediately;
  * /wqat refresh explicitly starts a new data refresh;
  * automatic scheduled Show("new", true) still performs a real refresh.

This also provides progressive background publishing. When dynamic reward
enrichment discovers new information, CheckWQ("new") updates active/new task
state once, and an already-open popup is rebuilt from that fresh state.
]]

local OriginalShow = WQA.Show

local function hasUsableCache(self)
	return type(self.questList) == "table"
		and type(self.activeTasks) == "table"
end

---Render the currently available cache without rebuilding questList.
---@param mode string?
function WQA:ShowCached(mode)
	if not hasUsableCache(self) then
		-- First-ever access before startup initialization completed.
		return OriginalShow(self, mode)
	end

	self:Debug("ShowCached", mode)
	self:CheckWQ(mode)
	self.first = true
end

---Explicitly rebuild the data model and start a fresh background enrichment.
---@param mode string?
---@param auto boolean?
function WQA:Refresh(mode, auto)
	return OriginalShow(self, mode, auto)
end

---Compatibility override used by the original minimap/LDB callbacks.
---
---The original file's data broker object is local, so the cleanest way to
---make minimap interaction instant is to make display-only modes cache-only.
---All other Show() calls preserve upstream refresh semantics.
function WQA:Show(mode, auto)
	if mode == "popup" or mode == "LDB" then
		return self:ShowCached(mode)
	end

	return self:Refresh(mode, auto)
end

---Fully rebuild an already-open popup from current activeTasks.
---
---UpdateQTip() intentionally de-duplicates quest rows and therefore cannot
---update reward columns for an existing row. Releasing/reacquiring the QTip
---gives us a true in-place refresh of the popup's contents.
function WQA:TurboRefreshOpenPopup()
	if not (self.PopUp and self.PopUp.shown) then
		return
	end

	if self.tooltip then
		LibQTip:Release(self.tooltip)
		self.tooltip = nil
	end

	self:AnnouncePopUp(self.activeTasks or {})
end

---Publish newly enriched reward information without starting another scan.
---
---CheckWQ("new") updates activeTasks/newTasks and only announces genuinely
---new tasks because WQA's watched table de-duplicates notifications.
function WQA:TurboPublishEnrichment()
	if not self.questList then
		return
	end

	self:CheckWQ("new")
end
