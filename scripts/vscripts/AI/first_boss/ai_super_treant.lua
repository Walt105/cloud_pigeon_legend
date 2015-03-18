

function Spawn( val )

	local IsFirstSpawn = true
	local start = false
	GameRules:GetGameModeEntity():SetContextThink("ai_super_treant",function( )

		if IsValidAndAlive(thisEntity) == "Not Valid" then
			GameRules._IsRespawn = true
			CustomRespawnHero()

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
			return nil
		end

		--是否第一次创建
		if IsFirstSpawn then
			IsFirstSpawn = false
			thisEntity:AddHateSystem()
		end

		if thisEntity.BossFindUnitNum then
			local ent_1 = Entities:FindByName(nil,"touch_1")
			local ent_2 = Entities:FindByName(nil,"touch_2")
			if thisEntity.BossFindUnitNum > 0 then
				if start == false then start = true end

				ent_2:Enable()
				GameRules._IsRespawn =false
				
				local target = thisEntity:GetHateSystemMaxHero()
				if target ~= nil then
					local newOrder = {
				        UnitIndex = thisEntity:entindex(), 
				        TargetIndex = target:entindex(),
				        OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
				        Queue = 0
				    }
				    ExecuteOrderFromTable(newOrder)
				end
			else
				ent_1:Enable()
				ent_1:Trigger()
				GameRules._IsRespawn = true
				CustomRespawnHero()

				if IsValidAndAlive(thisEntity) and start then
					start = false
					local ent_unit = Entities:FindByName(nil,"first_boss_super_treant")
					thisEntity:SetAbsOrigin(ent_unit:GetAbsOrigin())
				end
			end
		end

		return 1
	end,10)
end