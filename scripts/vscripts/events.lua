
--[[
这里主要编写事件
]]

if CEvents == nil then
	CEvents = class({})
end

function CEvents:Init( )
	--监听游戏进度
	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(CEvents,"OnGameRulesStateChange"), self)

	--监听单位被击杀的事件
	ListenToGameEvent("entity_killed", Dynamic_Wrap(CEvents, "OnEntityKilled"), self)

	--监听单位重生或者出生
	ListenToGameEvent("npc_spawned", Dynamic_Wrap(CEvents, "OnNPCSpawned"), self)

end

----------------------------------------------------------------------------------------------------------
function CEvents:OnGameRulesStateChange( keys )

	local new = GameRules:State_Get()

	if new == DOTA_GAMERULES_STATE_HERO_SELECTION then
		--设置玩家
		for i=0,DOTA_MAX_PLAYER_TEAMS - 1 do
			local player = PlayerResource:GetPlayer(i)
			if player then
				table.insert( GameRules._Players,player )
				PlayerResource:SetGold(player:GetPlayerID(),300,true)
				PlayerResource:SetGold(player:GetPlayerID(),0,false)

				GameRules.PlayerNum = GameRules.PlayerNum + 1
				if PlayerResource:GetTeam(i) ~= DOTA_TEAM_GOODGUYS then
					player:SetTeam(DOTA_TEAM_GOODGUYS)
				end
			end
		end

		if GameRules.PlayerNum == 0 then
			GameRules.PlayerNum = 1
		end

		--设置玩家系数
		GameRules.PlayerPercent = GameRules.PlayerNum / GameRules.PlayerMaxNum
	end

	if new == DOTA_GAMERULES_STATE_PRE_GAME then

		--创建马甲，此马甲用于存放技能
		local ent = Entities:FindByName(nil,"hidden_point")
		if ent then
			GameRules.Majia = CustomCreateUnit("npc_majia",ent:GetOrigin(),270,DOTA_TEAM_GOODGUYS)
			if GameRules.Majia then
				GameRules.Majia:AddAbility("common_ability")
				GameRules.MajiaCommonAbility = GameRules.Majia:FindAbilityByName("common_ability")
			end
		end

		--设置英雄重生地点
		GameRules._HeroRespawn = Entities:FindByName(nil,"hero_respawn")

		if GetMapName() == "template_map" then

			CTemplateMap:CreateUnit()

		elseif GetMapName() == "cloud_pigeon_legend" then

			CCloudPigeonLegend:Start( )

		end
	end
	
end
----------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------
function CEvents:OnEntityKilled( keys )
	local unit = EntIndexToHScript(keys.entindex_killed)

	if unit:IsHero() and unit:GetTeamNumber() == DOTA_TEAM_GOODGUYS and GameRules._IsRespawn then
		CustomTimer("OnEntityKilled",function( )
			if IsValidAndAlive(unit) == false then
				unit:RespawnHero(true,true,true)
				unit:SetAbsOrigin(GameRules._HeroRespawn:GetOrigin())
				FindClearSpaceForUnit(unit,unit:GetOrigin(),true)
			end
			return nil
		end,3)
	end
end
----------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------
function HeroAbilityRearrange( unitName )
	--需要重新排列的英雄
	local heroName = {
		"npc_dota_hero_juggernaut",
	}
	for k,v in pairs(heroName) do
		if v == unitName then
			return true
		end
	end

	return false
end

function CEvents:OnNPCSpawned( keys )
	local unit = EntIndexToHScript(keys.entindex)

	--如果是英雄添加通用技能
	if unit:IsHero() then
		unit:AddAbility("common_ability")
		unit:SetTimeUntilRespawn(99999)
	end

	--判断玩家英雄是否是第一次创建，如果是则设置全部技能等级为1
	if unit.OnFirstSpawned == nil and unit:IsHero() and unit:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
		unit.OnFirstSpawned = true
		unit:SetAbilityPoints(0)

		--记录玩家的英雄
		table.insert( GameRules._PlayerHeroes,unit )

		--针对某些英雄的技能进行重新排列
		if HeroAbilityRearrange(unit:GetUnitName()) then
			local abilityName = {}

			if unit:GetUnitName() == "npc_dota_hero_juggernaut" then
				abilityName = {
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
			end

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