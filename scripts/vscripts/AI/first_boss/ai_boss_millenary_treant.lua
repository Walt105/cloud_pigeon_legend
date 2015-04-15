
function Spawn( val )
	print(thisEntity)
	SetAbilitiesLevelToOne(thisEntity)
	thisEntity:AddHateSystem()
	CAI:AutoCastAbility( thisEntity )
	CAI:AutoAttack( thisEntity )

	local war = false
	CustomTimer("ai_boss_millenary_treant",function( )
		
		if IsValidAndAlive(thisEntity) == true then
			if thisEntity._BossIsWar then
				war = true
			else
				if war then
					war = false
					local group = FindUnitsInRadius(thisEntity:GetTeamNumber(),thisEntity:GetOrigin(),nil,3000,DOTA_UNIT_TARGET_TEAM_FRIENDLY,DOTA_UNIT_TARGET_BASIC,DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS,FIND_CLOSEST,true)
					for k,v in pairs(group) do
						if IsValidAndAlive(v) then
							v:Kill(nil,nil)
						end
					end

					local ent = Entities:FindByName(nil,"first_boss_point")
					thisEntity:SetAbsOrigin(ent:GetAbsOrigin())
					thisEntity:SetHealth(thisEntity:GetMaxHealth())
					thisEntity:Stop()
				end
			end
		else
			local group = FindUnitsInRadius(thisEntity:GetTeamNumber(),thisEntity:GetOrigin(),nil,3000,DOTA_UNIT_TARGET_TEAM_FRIENDLY,DOTA_UNIT_TARGET_BASIC,DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS,FIND_CLOSEST,true)
			for k,v in pairs(group) do
				if IsValidAndAlive(v) then
					v:Kill(nil,nil)
				end
			end

			for k,v in pairs(GameRules._RemoveMajia) do
				if IsValidAndAlive(v) == true then
					v:RemoveSelf()
				end
			end

			--创建一个马甲毁坏树木
			local ent_unit = Entities:FindByName(nil,"second_01")
			local ent_tree = Entities:FindByName(nil,"second_02")
			local unit = CustomCreateUnit("npc_majia",ent_unit:GetOrigin(),270,DOTA_TEAM_BADGUYS)
			GameRules.MajiaCommonAbility:ApplyDataDrivenModifier(unit,unit,"modifier_first_boss_tree",{duration = 8})
			TargetMoveToCaster( ent_tree,unit,10 )

			--创建跳跃的石头
			local stone_ent = {"second_01","second_03","second_04","second_05","first_boss_spawn_2"}
			local stone_spawn_ent = Entities:FindByName(nil,"second_02")
			for k,v in pairs(stone_ent) do
				local unit = CustomCreateUnit("boss_stone_big",stone_spawn_ent:GetOrigin(),270,DOTA_TEAM_BADGUYS)
				local ent = Entities:FindByName(nil,v)
				CustomTimer("boss_stone_big",function( )
					local ability = unit:FindAbilityByName("boss_stone_small_a1")
					if ability then
						unit:CastAbilityOnPosition(ent:GetOrigin(),ability,0)
					end
					return nil
				end,2)
			end

			--创建boss
			local ent_boss = Entities:FindByName(nil,"second_boss")
			GameRules.ThisBoss = CustomCreateUnit("boss_stone",ent_boss:GetOrigin(),270,DOTA_TEAM_BADGUYS)

			--马甲
			local majia = CustomCreateUnit("npc_majia",ent_boss:GetOrigin(),270,DOTA_TEAM_GOODGUYS)
			majia:SetDayTimeVisionRange(1800)
			majia:SetNightTimeVisionRange(1800)
			table.insert( GameRules._RemoveMajia,majia )
			return nil
		end

		return 1
	end,1)
end