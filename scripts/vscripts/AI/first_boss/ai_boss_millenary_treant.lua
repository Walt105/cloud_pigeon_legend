

function Spawn( val )

	--设置技能等级为1
	local num = thisEntity:GetAbilityCount() - 1
	for i=0,num do
		local ability = thisEntity:GetAbilityByIndex(i)
		if ability then
			ability:SetLevel(1)
		end
	end

	thisEntity:SetCustomHealthLabel("BOSS",255,0,0)
	thisEntity:AddHateSystem()

	local start = false
	CustomTimer("ai_boss_millenary_treant",function( )
		if thisEntity.BossFindUnitNum then
			local ent_1 = Entities:FindByName(nil,"touch_1")
			local ent_2 = Entities:FindByName(nil,"touch_3")
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
					local ent_unit = Entities:FindByName(nil,"first_boss_point")
					thisEntity:SetAbsOrigin(ent_unit:GetAbsOrigin())
					thisEntity:SetHealth(thisEntity:GetMaxHealth())
					thisEntity:Stop()
				end
			end
		end

		return 1
	end,0)

end