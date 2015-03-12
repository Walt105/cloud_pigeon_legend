
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

	--如果是英雄添加通用技能
	if unit:IsHero() then
		unit:AddAbility("common_ability")
	end

	--判断玩家英雄是否是第一次创建，如果是则设置全部技能等级为1
	if unit.OnFirstSpawned == nil and unit:IsHero() and unit:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
		unit.OnFirstSpawned = true
		unit:SetAbilityPoints(0)

		--针对主宰的技能进行从新排列
		if unit:GetUnitName() == "npc_dota_hero_juggernaut" then
			local abilityName = {
				"juggernaut_one_ability1",
				"juggernaut_one_ability2",
				"juggernaut_one_ability2_over",
				"juggernaut_one_ability3",
				"juggernaut_one_ability3_kuangbao",
				"juggernaut_one_ability3_judu",
				"juggernaut_one_ability3_xixue",
				"juggernaut_one_ability4",
				"juggernaut_one_ability5",
			}

			for i,v in ipairs(abilityName) do
				unit:RemoveAbility(v)
			end

			for i,v in ipairs(abilityName) do
				unit:AddAbility(v)
			end

			for i,v in ipairs(abilityName) do
				local ability = unit:FindAbilityByName(v)
				ability:SetLevel(1)
			end

			return
		end

		--设置技能等级为1
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