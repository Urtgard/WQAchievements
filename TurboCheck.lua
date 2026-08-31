---@class WQAchievements
local WQA = WQAchievements

--[[
WQA Turbo progressive CheckWQ
==============================

Upstream CheckWQ has an all-or-nothing retry rule:

  if ANY active quest/reward link is unavailable:
      schedule CheckWQ again
      return without publishing ANY active quests

That defeats Turbo's non-blocking reward scanner. Two completely ready quests
can be held back for many seconds by one unrelated quest whose item/quest link
has not entered Blizzard's local cache yet.

Turbo changes readiness from GLOBAL to PER-TASK:

  ready WQ  -> publish now
  ready WQ  -> publish now
  pending WQ -> omit only this WQ and retry it later

A retry uses mode="new", so quests that become ready later are announced once
instead of re-printing all already-known quests.

The same principle is applied to missions/POIs: unavailable auxiliary data may
schedule a later retry but does not block ready world quests.
]]

local IsActive = C_TaskQuest.IsActive

local CHECK_RETRY_DELAY_SECONDS = 0.50

local function cancelCheckRetry(self)
	local timer = self._wqaTurboCheckRetryTimer

	if timer and timer.Cancel then
		timer:Cancel()
	end

	self._wqaTurboCheckRetryTimer = nil
end

local function scheduleCheckRetry(self)
	-- Coalesce all unresolved task/link retries into one timer.
	if self._wqaTurboCheckRetryTimer then
		return
	end

	self._wqaTurboCheckRetryTimer = C_Timer.NewTimer(
		CHECK_RETRY_DELAY_SECONDS,
		function()
			self._wqaTurboCheckRetryTimer = nil

			-- "new" means already-published tasks are not announced again.
			self:CheckWQ("new", true)
		end
	)
end

local function isQuestActive(self, questID)
	return
		IsActive(questID)
		or self:EmissaryIsActive(questID)
		or self:isQuestPinActive(questID)
		or self:IsQuestFlaggedCompleted(questID)
end

---Resolve/cache all currently required links for one active world quest.
---@return boolean ready
function WQA:TurboPrepareWorldQuest(questID)
	local quest = self.questList[questID]

	if not quest or not quest.reward then
		return false
	end

	local questLink = self:GetTaskLink({
		id = questID,
		type = "WORLD_QUEST"
	})

	if not questLink then
		return false
	end

	local sawReward = false

	for rewardType, rewardData in pairs(quest.reward) do
		sawReward = true

		if
			rewardType ~= "custom"
			and rewardType ~= "professionSkillup"
			and rewardType ~= "gold"
		then
			local link =
				self:GetRewardLinkByID(
					questID,
					rewardType,
					rewardData,
					1
				)

			if not link then
				return false
			end

			self:SetRewardLinkByID(
				questID,
				rewardType,
				rewardData,
				1,
				link
			)

			if
				rewardType == "achievement"
				or rewardType == "chance"
				or rewardType == "azeriteTraits"
			then
				for i = 2, #rewardData do
					link =
						self:GetRewardLinkByID(
							questID,
							rewardType,
							rewardData,
							i
						)

					if not link then
						return false
					end

					self:SetRewardLinkByID(
						questID,
						rewardType,
						rewardData,
						i,
						link
					)
				end
			end
		end
	end

	-- A questList entry is expected to contain at least one reward. Preserve
	-- the upstream conservative behaviour for malformed/half-built entries:
	-- wait for the next pass rather than exposing a row the rendering code
	-- cannot describe.
	return sawReward
end

---Resolve/cache links for one mission.
---@return boolean ready
function WQA:TurboPrepareMission(missionID)
	local mission = self.missionList[missionID]

	if not mission or not mission.reward then
		return false
	end

	local sawReward = false

	for rewardType, rewardData in pairs(mission.reward) do
		sawReward = true

		if
			rewardType ~= "custom"
			and rewardType ~= "professionSkillup"
			and rewardType ~= "gold"
		then
			local link =
				self:GetRewardLinkByMissionID(
					missionID,
					rewardType,
					rewardData,
					1
				)

			if not link then
				return false
			end

			self:SetRewardLinkByMissionID(
				missionID,
				rewardType,
				rewardData,
				1,
				link
			)
		end
	end

	return sawReward
end

---Turbo replacement for upstream CheckWQ().
---
---The optional second argument is internal and only indicates that this call
---came from Turbo's coalesced retry timer.
function WQA:CheckWQ(mode, fromRetry)
	self:Debug("CheckWQ (WQA Turbo progressive)", mode)

	-- Dynamic Reward() is background-only in Turbo. EmissaryReward() is still
	-- upstream code, so allow it to finish without blocking ordinary WQs.
	if self.emissaryRewards ~= true then
		scheduleCheckRetry(self)
	end

	local activeQuests = {}
	local newQuests = {}
	local needsRetry = false

	for questID in pairs(self.questList or {}) do
		if isQuestActive(self, questID) then
			if self:TurboPrepareWorldQuest(questID) then
				activeQuests[questID] = true

				if not self.watched[questID] then
					newQuests[questID] = true
				end
			else
				-- Only this quest waits. Ready quests continue to publication.
				needsRetry = true
			end
		end
	end

	local activeMissions = self:CheckMissions()
	local readyMissions = {}
	local newMissions = {}

	if type(activeMissions) == "table" then
		for missionID in pairs(activeMissions) do
			if self:TurboPrepareMission(missionID) then
				readyMissions[missionID] = true

				if not self.watchedMissions[missionID] then
					newMissions[missionID] = true
				end
			else
				needsRetry = true
			end
		end
	else
		activeMissions = {}
		needsRetry = true
	end

	local pois = self.Criterias.AreaPoi:Check()

	if not pois then
		pois = {
			active = {},
			new = {},
			retry = true
		}
	end

	if pois.retry then
		needsRetry = true
	end

	-- Publish all READY tasks now. This is the crucial difference from
	-- upstream, which returned before reaching this block if anything needed
	-- a retry.
	self.activeTasks = {}

	for id in pairs(activeQuests) do
		table.insert(
			self.activeTasks,
			{
				id = id,
				type = "WORLD_QUEST"
			}
		)
	end

	for id in pairs(readyMissions) do
		table.insert(
			self.activeTasks,
			{
				id = id,
				type = "MISSION"
			}
		)
	end

	for poiId, mapIds in pairs(pois.active or {}) do
		for mapId in pairs(mapIds) do
			table.insert(
				self.activeTasks,
				{
					id = poiId,
					mapId = mapId,
					type = "AREA_POI"
				}
			)
		end
	end

	self.activeTasks = self:SortQuestList(self.activeTasks)

	self.newTasks = {}

	for id in pairs(newQuests) do
		self.watched[id] = true

		table.insert(
			self.newTasks,
			{
				id = id,
				type = "WORLD_QUEST"
			}
		)
	end

	for id in pairs(newMissions) do
		self.watchedMissions[id] = true

		table.insert(
			self.newTasks,
			{
				id = id,
				type = "MISSION"
			}
		)
	end

	for poiId, mapIds in pairs(pois.new or {}) do
		for mapId in pairs(mapIds) do
			if not self.Criterias.AreaPoi.watched[poiId] then
				self.Criterias.AreaPoi.watched[poiId] = {}
			end

			self.Criterias.AreaPoi.watched[poiId][mapId] = true

			table.insert(
				self.newTasks,
				{
					id = poiId,
					mapId = mapId,
					type = "AREA_POI"
				}
			)
		end
	end

	if mode == "new" then
		self:AnnounceChat(self.newTasks, self.first)

		if self.db.profile.options.PopUp == true then
			self:AnnouncePopUp(self.newTasks, self.first)
		end
	elseif mode == "popup" then
		self:AnnouncePopUp(self.activeTasks)
	elseif mode == "LDB" then
		self:AnnounceLDB(self.activeTasks)
	else
		self:AnnounceChat(self.activeTasks)

		if self.db.profile.options.PopUp == true then
			self:AnnouncePopUp(self.activeTasks)
		end
	end

	self:UpdateLDBText(next(self.activeTasks), next(self.newTasks))

	if needsRetry then
		scheduleCheckRetry(self)
	else
		cancelCheckRetry(self)
	end

	-- A retry or background enrichment may have changed activeTasks while the
	-- user has the minimap popup open. Rebuild that popup from the current
	-- ready-task set without starting another data scan.
	if mode ~= "popup" and self.TurboRefreshOpenPopup then
		self:TurboRefreshOpenPopup()
	end
end
