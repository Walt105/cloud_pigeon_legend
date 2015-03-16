
--[[
这里主要模版地图的内容
]]

if CTemplateMap == nil then
	CTemplateMap = class({})
end

function CTemplateMap:CreateUnit( )
	CustomTimer("OnGameRulesStateChange",function( )
		local unit = CreateUnitByName("npc_dota_creep_badguys_melee",Vector(0,0,0),false,nil,nil,DOTA_TEAM_BADGUYS)
		unit:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})
		return 4
	end,4)
end