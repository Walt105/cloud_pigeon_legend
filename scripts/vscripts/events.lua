
--[[
这里主要编写事件
]]

if CEvents == nil then
	CEvents = class({})
end

function CEvents:Init( )
	--监听游戏进度
	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(CEvents,"OnGameRulesStateChange"), self)

	--监听单位被击杀的事件,用于刷怪
	ListenToGameEvent("entity_killed", Dynamic_Wrap(CEvents, "OnEntityKilled"), self)

	--监听单位重生或者出生
	ListenToGameEvent("npc_spawned", Dynamic_Wrap(CEvents, "OnNPCSpawned"), self)
end

----------------------------------------------------------------------------------------------------------
function CEvents:OnGameRulesStateChange( keys )
	
end
----------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------
function CEvents:OnEntityKilled( keys )
	
end
----------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------
function CEvents:OnNPCSpawned( keys )
	local unit = EntIndexToHScript(keys.entindex)


	--判断玩家英雄是否是第一次创建，如果是则设置全部技能等级为1
	if unit.OnFirstSpawned == nil and unit:IsHero() and unit:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
		unit.OnFirstSpawned = true
		unit:SetAbilityPoints(0)

		local num = unit:GetAbilityCount() - 1
		for i=0,num do
			local ability = unit:GetAbilityByIndex(i)
			if ability then
				ability:SetLevel(1)
			end
		end
	end
end
----------------------------------------------------------------------------------------------------------