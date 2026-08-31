---@class WQATurbo : AceAddon
---@field tooltip LibQTip.Tooltip
WQATurbo = LibStub("AceAddon-3.0"):NewAddon("WQATurbo", "AceConsole-3.0", "AceTimer-3.0")

---@class WQATurbo
local WQA = WQATurbo

WQA.data = {}
WQA.watched = {}
WQA.watchedMissions = {}
WQA.questList = {}
WQA.missionList = {}
WQA.itemList = {}
WQA.links = {}
WQA.Criterias = {}
WQA.Rewards = {}
