---@class WQAchievements : AceAddon
---@field tooltip LibQTip.Tooltip
WQAchievements = LibStub("AceAddon-3.0"):NewAddon("WQAchievements", "AceConsole-3.0", "AceTimer-3.0")

---@class WQAchievements
local WQA = WQAchievements

WQA.data = {}
WQA.watched = {}
WQA.watchedMissions = {}
WQA.questList = {}
WQA.missionList = {}
WQA.itemList = {}
WQA.links = {}
WQA.Criterias = {}
WQA.Rewards = {}
