


function Spawn( val )

	local start = false

	thisEntity:AddHateSystem()
	thisEntity._BossIsWar = false
	CAI:AutoAttack( thisEntity )
	GameRules:GetGameModeEntity():SetContextThink("ai_super_treant",function( )
		
		if IsValidAndAlive(thisEntity) == "Not Valid" then
			GameRules._IsRespawn = true
			CustomRespawnHero()
			GiveAbilityPointToAll( 2 )

			--创建boss
			local ent_boss = Entities:FindByName(nil,"first_boss_point")
			GameRules.ThisBoss = CustomCreateUnit("boss_millenary_treant",ent_boss:GetOrigin(),270,DOTA_TEAM_BADGUYS)
			
			--创建一个马甲毁坏树木
			local ent_unit = Entities:FindByName(nil,"first_boss_super_treant")
			local ent_tree = Entities:FindByName(nil,"first_boss_tree")
			local unit = CustomCreateUnit("npc_majia",ent_unit:GetOrigin(),270,DOTA_TEAM_BADGUYS)
			GameRules.MajiaCommonAbility:ApplyDataDrivenModifier(unit,unit,"modifier_first_boss_tree",{duration = 8})
			TargetMoveToCaster( ent_tree,unit,10 )

			--显示箭头
			local text_enable = Entities:FindByName(nil,"Text_2_enable")
			text_enable:Enable()

			--创建马甲
			local majia = CustomCreateUnit("npc_majia",ent_boss:GetOrigin(),270,DOTA_TEAM_GOODGUYS)
			majia:SetDayTimeVisionRange(1800)
			majia:SetNightTimeVisionRange(1800)
			for i=1,4 do
				local ent = Entities:FindByName(nil,"first_boss_spawn_"..tostring(i))
				local majia = CustomCreateUnit("npc_majia",ent:GetOrigin(),270,DOTA_TEAM_GOODGUYS)
				majia:SetDayTimeVisionRange(1800)
				majia:SetNightTimeVisionRange(1800)
			end
			return nil
		end

		return 1
	end,10)
end