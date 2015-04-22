
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

	--玩家购买物品
	ListenToGameEvent("dota_item_purchased",Dynamic_Wrap(CEvents, "OnItemPurchased"),self)

	--单位捡起物品
	ListenToGameEvent("dota_item_picked_up",Dynamic_Wrap(CEvents, "OnItemPickedUp"),self)

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

				GameRules.PlayerNum = GameRules.PlayerNum + 1
				if PlayerResource:GetTeam(i) ~= DOTA_TEAM_GOODGUYS then
					player:SetTeam(DOTA_TEAM_GOODGUYS)
				end
			end
		end

		for k,player in pairs(GameRules._Players) do
			if player then
				PlayerResource:SetGold(player:GetPlayerID(),300,true)
				PlayerResource:SetGold(player:GetPlayerID(),0,false)
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

			--创建蓝色精灵球
			for i=1,6 do
				local name = string.format("wisp_0%d",i)
				local ent = Entities:FindByName(nil,name)
				if IsValidEntity(ent) then
					CustomCreateUnit("npc_wisp_blue",ent:GetOrigin(),270,DOTA_TEAM_GOODGUYS)
				end
			end

		end
	end
	
end
----------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------
function CEvents:OnEntityKilled( keys )
	local unit = EntIndexToHScript(keys.entindex_killed)
	local unit_abs = unit:GetAbsOrigin()
	local unit_face = unit:GetForwardVector()

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

	if unit:GetTeamNumber() == DOTA_TEAM_BADGUYS and unit:IsAncient()==false then
		if unit.IsWispCreate == false then return end
		if unit:IsBoss() then
			local num = 8
			local u = {}
			local name = nil
			for i=1,num do
				local vec = unit_abs + unit_face*25
				local rota = RotatePosition(unit_abs,QAngle(0,(360/num)*i,0),vec) 

				if (i%2)==0 then name="npc_wisp_red" else name="npc_wisp_green" end

				u[i] = CustomCreateUnit(name,rota,270,DOTA_TEAM_GOODGUYS)

				local time = 0

				--从25到radius
				RotateMotion( u[i],unit_abs,5,25,400,5,function( )
					time = time + 0.02
					if time >= 2 then
						local ability = u[i]:FindAbilityByName("npc_wisp_ability1")
						if ability then
							ability:ApplyDataDrivenModifier(u[i],u[i],"modifier_npc_wisp_ability1_"..u[i]:GetUnitName(),nil)
						end
					end
				end,nil)
			end
		else
			if RollPercentage(RandomFloat(105,50)) then
				local wisp = CustomCreateUnit("npc_wisp_green",unit_abs,270,DOTA_TEAM_GOODGUYS)
				local ability = wisp:FindAbilityByName("npc_wisp_ability1")
				if ability then
					local face = wisp:GetForwardVector()
					local abs = wisp:GetAbsOrigin() + face * RandomInt(50,350)
					local vec = RotatePosition(wisp:GetAbsOrigin(),QAngle(0,RandomFloat(0,360),0),abs)
					wisp:CastAbilityOnPosition(vec,ability,0)
				end
			end
			if RollPercentage(RandomFloat(15,50)) then
				local wisp = CustomCreateUnit("npc_wisp_red",unit_abs,270,DOTA_TEAM_GOODGUYS)
				local ability = wisp:FindAbilityByName("npc_wisp_ability1")
				if ability then
					local face = wisp:GetForwardVector()
					local abs = wisp:GetAbsOrigin() + face * RandomInt(50,350)
					local vec = RotatePosition(wisp:GetAbsOrigin(),QAngle(0,RandomFloat(0,360),0),abs)
					wisp:CastAbilityOnPosition(vec,ability,0)
				end
			end
		end
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
		-- if HeroAbilityRearrange(unit:GetUnitName()) then
		-- 	local abilityName = {}

		-- 	if unit:GetUnitName() == "npc_dota_hero_juggernaut" then
		-- 		abilityName = {
		-- 			"juggernaut_one_ability1",
		-- 			"juggernaut_one_ability2",
		-- 			"juggernaut_one_ability2_over",
		-- 			"juggernaut_one_ability3",
		-- 			"juggernaut_one_ability3_kuangbao",
		-- 			"juggernaut_one_ability3_judu",
		-- 			"juggernaut_one_ability3_xixue",
		-- 			"juggernaut_one_ability4",
		-- 			"juggernaut_one_ability5",
		-- 		}
		-- 	end

		-- 	for i,v in ipairs(abilityName) do
		-- 		unit:RemoveAbility(v)
		-- 	end

		-- 	for i,v in ipairs(abilityName) do
		-- 		unit:AddAbility(v)
		-- 	end

		-- 	for i,v in ipairs(abilityName) do
		-- 		local ability = unit:FindAbilityByName(v)
		-- 		ability:SetLevel(1)
		-- 	end

		-- 	return
		-- end

		--设置技能等级为1
		SetAbilitiesLevelToOne(unit)

	end
end
----------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------
function CDOTA_BaseNPC:FindItem( itemname )
	if IsValidAndAlive(self) then
		for i=0,12 do
			local item = self:GetItemInSlot(i)
			if item then
				if item:GetAbilityName() == itemname then
					return item
				end
			end
		end
	end
	return nil
end

ItemX = nil
function CEvents:OnItemPurchased( keys )
	local player = PlayerResource:GetPlayer(keys.PlayerID)

	if player then
		local hero = player:GetAssignedHero()
		if keys.itemname == "item_pay_ability_point" then
			local item = hero:FindItem(keys.itemname)
			if item then
				hero:RemoveItem(item)
			end
		end
	end
		
end
----------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------
function CEvents:OnItemPickedUp( keys )
	local playerid = keys.PlayerID 
	local itemname = keys.itemname 
	local item = EntIndexToHScript(keys.ItemEntityIndex)
	local hero = EntIndexToHScript(keys.HeroEntityIndex)

	if itemname == "item_pay_ability_point" then
		item:RemoveSelf()
	end
end