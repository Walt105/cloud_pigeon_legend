

function Spawn( val )

	--设置技能等级为1
	local num = thisEntity:GetAbilityCount() - 1
	for i=0,num do
		local ability = thisEntity:GetAbilityByIndex(i)
		if ability then
			ability:SetLevel(1)
		end
	end

	GameRules.MajiaCommonAbility:ApplyDataDrivenModifier(thisEntity,thisEntity,"modifier_first_boss_ai",{})
	thisEntity:SetCustomHealthLabel("BOSS",255,0,0)
	thisEntity:AddHateSystem()

	local start = false
	CustomTimer("ai_boss_millenary_treant",function( )

		if IsValidAndAlive(thisEntity) == true then
			if thisEntity:HasModifier("modifier_boss_millenary_treant_a5") then
				return 1
			end
		end

		if thisEntity.BossFindUnitNum then
			local ent_1 = Entities:FindByName(nil,"touch_1")
			local ent_2 = Entities:FindByName(nil,"touch_3")
			if thisEntity.BossFindUnitNum > 0 then
				if start == false then start = true end

				ent_2:Enable()
				GameRules._IsRespawn =false
				
				local target = thisEntity:GetHateSystemMaxHero()
				if target ~= nil then
					if IsValidAndAlive(target) == true then
						local newOrder = {
					        UnitIndex = thisEntity:entindex(), 
					        TargetIndex = target:entindex(),
					        OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
					        Queue = 0
					    }
					    ExecuteOrderFromTable(newOrder)
					end
				end
			else
				ent_1:Enable()
				ent_1:Trigger()
				GameRules._IsRespawn = true
				CustomRespawnHero()

				if IsValidAndAlive(thisEntity) == true and start then
					start = false
					local ent_unit = Entities:FindByName(nil,"first_boss_point")
					thisEntity:SetAbsOrigin(ent_unit:GetAbsOrigin())
					thisEntity:SetHealth(thisEntity:GetMaxHealth())
					thisEntity:GetHateSystemClear()
					thisEntity:Stop()

					local teams = DOTA_UNIT_TARGET_TEAM_FRIENDLY
				    local types = DOTA_UNIT_TARGET_BASIC
				    local flags = DOTA_UNIT_TARGET_FLAG_NONE
				    local group = FindUnitsInRadius(thisEntity:GetTeamNumber(),ent_unit:GetOrigin(),nil,4000,teams,types,flags,FIND_CLOSEST,true)
				    for k,v in pairs(group) do
				    	if IsValidEntity(v) then
				    		v:RemoveSelf()
				    	end
				    end
				end
			end
		end

		return 1
	end,0)

end

function ModifierFirstBossAi( keys )
	local caster = keys.caster

	if caster._FirstBossHealA6 == nil then
		caster._FirstBossHealA1={}
		caster._FirstBossHealA4={}
		caster._FirstBossHealA6={}

		for i=5,100,5 do
			caster._FirstBossHealA1[i] = true
		end
		for i=4,100,4 do
			caster._FirstBossHealA4[i] = true
		end
		for i=20,80,20 do
			caster._FirstBossHealA6[i] = true
		end
		caster.spell = 0

	end

	if IsValidAndAlive(caster) == true then
		if caster:HasModifier("modifier_boss_millenary_treant_a5") then
			return
		end
	end

	local heal_percent = caster:GetHealthPercent()

	if heal_percent ~= 100 then
		local spell = false
		
		--施放A1
		for i=5,100,5 do
			if heal_percent <= i then
				if caster._FirstBossHealA1[i] then
					caster._FirstBossHealA1[i] = false
					spell = true
					break
				end
			end
		end
		if spell then
			local ability = caster:FindAbilityByName("boss_millenary_treant_a1")
			local target = caster:GetHateSystemMeleeHero( 0 )
			if IsValidAndAlive(target) == true then
				caster:CastAbilityOnTarget(target,ability,target:GetPlayerID())
			    print("fire boss_millenary_treant_a1")

			    local ranged = caster:GetHateSystemRangedHero( 0 )
			    if IsValidAndAlive(ranged) == true then
			    	local ability2 = caster:FindAbilityByName("boss_millenary_treant_a2")
			    	caster:CastAbilityOnTarget(ranged,ability2,ranged:GetPlayerID())
			    	print("fire boss_millenary_treant_a2")
			    end
			end
		end

		--施放A3
		spell = false
		for i=4,100,4 do
			if heal_percent <= i then
				if caster._FirstBossHealA4[i] then
					caster._FirstBossHealA4[i] = false
					spell = true
					break
				end
			end
		end
		if spell then
			local ability = caster:FindAbilityByName("boss_millenary_treant_a3")
			ability:CastAbility()
		end
			
		--施放A4
		if RollPercentage(2) then
			local ability = caster:FindAbilityByName("boss_millenary_treant_a4")
			ability:CastAbility()
		end

		--施放A5
		spell = false
		for i=20,80,20 do
			if heal_percent <= i then
				if caster._FirstBossHealA6[i] then
					caster._FirstBossHealA6[i] = false
					spell = true
					break
				end
			end
		end
		if spell then
			local ability = caster:FindAbilityByName("boss_millenary_treant_a5")
			ability:CastAbility()
			print("fire boss_millenary_treant_a5")
		end
	end

end