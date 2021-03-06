
--A1
function BossMillenaryTreantA1( keys )
	local caster = keys.caster
	local target = keys.target
	local group = keys.target_entities

	for k,v in pairs(group) do
		if IsValidAndAlive(v)==true then
			local info = 
		    {
		        Target = v,
		        Source = target,
		        Ability = keys.ability,  
		        EffectName = "particles/units/heroes/hero_treant/treant_leech_seed_projectile.vpcf",
		        bDodgeable = false,
		        iMoveSpeed = 800,
		        bProvidesVision = true,
		        iVisionRadius = 300,
		        iVisionTeamNumber = caster:GetTeamNumber(),
		        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
		    }
		    projectile = ProjectileManager:CreateTrackingProjectile(info)	
		end
	end
end

--记录命中的单位
function BossMillenaryTreantA1OnCreated( keys )
	keys.caster.BossMillenaryTreantA1Target = keys.target
end

--消除记录的单位
function BossMillenaryTreantA1OnDestroy( keys )
	keys.caster.BossMillenaryTreantA1Target = nil
end


--A2
function BossMillenaryTreantA2( keys )
	local caster = keys.caster
	local ability = keys.ability
	local radius = keys.radius
	local damage = keys.damage
	local damage_type = keys.damage_type
	local teams = ability:GetAbilityTargetTeam()
	local types = ability:GetAbilityTargetType()
	local flags = ability:GetAbilityTargetFlags()
	local point = keys.target_points[1]

	local p = CustomCreateParticle("particles/custom/heros/boss_millenary_treant/boss_millenary_treant_tree.vpcf",PATTACH_WORLDORIGIN,caster,15,false,function( )
	    local group = FindUnitsInRadius(caster:GetTeamNumber(),point,nil,radius,teams,types,flags,FIND_UNITS_EVERYWHERE,true)
	    caster:DamageAOEFun( group,damage,damage_type )
	end)
	ParticleManager:SetParticleControl(p,0,point)
	ParticleManager:SetParticleControl(p,1,point)
	ParticleManager:SetParticleControl(p,2,point)
end

--A4
function BossMillenaryTreantA4( keys )
	local caster = keys.caster
	local target = keys.target

	if caster.BossMillenaryTreantA4Num == nil then
		caster.BossMillenaryTreantA4Num = 0
	end

	caster.BossMillenaryTreantA4Num = caster.BossMillenaryTreantA4Num % 2

	--调整召唤物的位置
	local ent = nil
	if caster.BossMillenaryTreantA4Num == 0 then
		ent = Entities:FindByName(nil,"first_boss_spawn_5")
	else
		ent = Entities:FindByName(nil,"first_boss_spawn_6")
	end
	if ent then
		target:SetAbsOrigin(ent:GetAbsOrigin())
		CustomTimer("BossMillenaryTreantA4",function( )
			if IsValidAndAlive(target) == nil then return nil end

			local newOrder = {
		        UnitIndex = target:entindex(), 
		        OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
		        Position = caster:GetOrigin(), 
		        Queue = 0
			}
		    ExecuteOrderFromTable(newOrder)
		    return nil
		end,1.5)
	end

	caster.BossMillenaryTreantA4Num = caster.BossMillenaryTreantA4Num + 1
	target:AddNewModifier(nil,nil,"modifier_phased",{duration = 0.1})
end

--A5
function BossMillenaryTreantA5( keys )
	local caster = keys.caster
	local target = keys.target

	if caster.BossMillenaryTreantA5Num == nil then
		caster.BossMillenaryTreantA5Num = 0
	end

	caster.BossMillenaryTreantA5Num = caster.BossMillenaryTreantA5Num % 4

	--调整召唤物的位置
	local ent = nil
	if caster.BossMillenaryTreantA5Num == 0 then
		ent = Entities:FindByName(nil,"first_boss_spawn_1")

		local ent_boss = Entities:FindByName(nil,"first_boss_point")
		if ent_boss then caster:SetAbsOrigin(ent_boss:GetAbsOrigin()) end
		caster.BossMillenaryTreantA5UunitNum = 4

	elseif caster.BossMillenaryTreantA5Num == 1 then
		ent = Entities:FindByName(nil,"first_boss_spawn_2")

	elseif caster.BossMillenaryTreantA5Num == 2 then
		ent = Entities:FindByName(nil,"first_boss_spawn_3")

	elseif caster.BossMillenaryTreantA5Num == 3 then
		ent = Entities:FindByName(nil,"first_boss_spawn_4")
	end
	if ent then
		target:SetAbsOrigin(ent:GetAbsOrigin())
		CustomTimer("BossMillenaryTreantA5",function( )
			if IsValidAndAlive(target) == nil then return nil end
			
			local newOrder = {
		        UnitIndex = target:entindex(), 
		        OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
		        Position = caster:GetOrigin(), 
		        Queue = 0
			}
		    ExecuteOrderFromTable(newOrder)
		    return nil
		end,1.5)
	end

	caster.BossMillenaryTreantA5Num = caster.BossMillenaryTreantA5Num + 1
	target:AddNewModifier(nil,nil,"modifier_phased",{duration = 0.1})
end

function BossMillenaryTreantA5Kill( keys )
	if keys.target:GetUnitName() == "boss_millenary_treant_A5_unit" then
		keys.target:Kill(keys.ability,keys.caster)
		keys.caster:CustomHeal(keys.heal)
	end
end

--在不同的生命值阶段播放不同的音效
function BossMillenaryTreantA6Heal( keys )
	local caster = keys.caster

	if caster.A6HealSound == nil then
		caster.A6HealSound = {}
		caster.A6HealSound[10] = true
		caster.A6HealSound[30] = true
		caster.A6HealSound[50] = true
		caster.A6HealSound[70] = true
		caster.A6HealSound[90] = true
	end

	local heal_percent = caster:GetHealthPercent()
	local soundName = "BossMillenaryTreant.Heal"

	if heal_percent<=10 and caster.A6HealSound[10] then
		caster.A6HealSound[10] = false
		soundName = soundName..tostring(10)

	elseif heal_percent<=30 and caster.A6HealSound[30] then
		caster.A6HealSound[30] = false
		soundName = soundName..tostring(30)

	elseif heal_percent<=50 and caster.A6HealSound[50] then
		caster.A6HealSound[50] = false
		soundName = soundName..tostring(50)

	elseif heal_percent<=70 and caster.A6HealSound[70] then
		caster.A6HealSound[70] = false
		soundName = soundName..tostring(70)

	elseif heal_percent<=90 and caster.A6HealSound[90] then
		caster.A6HealSound[90] = false
		soundName = soundName..tostring(90)

	end

	if soundName ~= "BossMillenaryTreant.Heal" then
		if IsValidAndAlive(caster) then
			caster:EmitSound(soundName)
		end
	end
end

function BossMillenaryTreantA6HealDestroy( keys )
	EmitGlobalSound("BossMillenaryTreant.Heal00")
end

--A6
function BossMillenaryTreantA6( keys )
	local caster = keys.caster

	if caster:GetHealth() < 200 then
		caster:SetHealth(caster:GetMaxHealth() * (keys.heal_percent / 100))
		caster:RemoveModifierByName("modifier_boss_millenary_treant_a6")
	end
end