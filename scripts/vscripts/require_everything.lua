
--[[
这里主要填写需要在游戏开始载入的lua
]]


--技能
require("Abilities/common")

--通用
require("global")
require("util/damage")
require("events")
require("AI/aifn")
require("UI")

--游戏流程
require("game_process/RoundThinker")
require("game_process/template_map_process")
require("game_process/cloud_pigeon_legend_process")

--仇恨系统
require("hate_system")