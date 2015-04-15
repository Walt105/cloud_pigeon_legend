

--A1
function BossStoneA1( keys )
	local caster = keys.caster
	local point = keys.target_points[1]
	local radius = keys.radius
	local distance = keys.distance
	local duration = keys.duration
	local caster_abs = caster:GetAbsOrigin()
	local face = (point - caster_abs):Normalized()

	local unit = CustomCreateUnit( "npc_majia",caster_abs,0,caster:GetTeamNumber() )
	keys.ability:ApplyDataDrivenModifier(caster,unit,"modifier_boss_stone_a1",nil)

	local name = "particles/custom/heros/boss_stone/boss_stone_avalanche.vpcf"
	local p = CustomCreateParticle(name,PATTACH_WORLDORIGIN,caster,duration,false,nil)

	local _dis = 0
	local _time = 0.02
	local _dis_speed = distance/(duration/_time)
	
	CustomTimer("BossStoneA1",function( )
		if _dis >= distance then
			unit:RemoveSelf()
			return nil
		end
		_dis = _dis + _dis_speed

		local vec = caster_abs + face * _dis
		if IsValidAndAlive(unit)==true then
			unit:SetAbsOrigin(vec)
		end
		ParticleManager:SetParticleControl(p,0,vec)
		ParticleManager:SetParticleControl(p,1,Vector(radius,radius,radius))

		return _time
	end,0)
end


--A2
function BossStoneA2( keys )
	local caster = keys.caster
	local ability = keys.ability
	Knockback( caster,caster,0.5,0,800,true,function( )
		caster:RemoveModifierByName("modifier_boss_stone_a2_do")
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_boss_stone_a2",nil)
	end)
end


--A5
function BossStoneA5( keys )
	local caster = keys.caster
	local attacker = keys.attacker
	local take_damamge = keys.take_damamge

	if IsValidAndAlive(attacker)==true then
		--造成伤害
		local t = {	target = attacker,
					caster = caster,
					damage = take_damamge*(keys.percent/100),
					damage_type = keys.damage_type}
		local damage = DamageTarget(t)
	end
end


--A6
function BossStoneA6( keys )
	local caster = keys.caster

	if IsValidAndAlive(caster)~=true then return end

	local ability = keys.ability
	local low = keys.low_heal
	local heal_percent = caster:GetHealthPercent()

	if ability.BossStoneA6==nil then
		ability.BossStoneA6 = {}
		ability.BossStoneA6Low = low
		for i=low,100-low,low do
			ability.BossStoneA6[i]=true
		end
	elseif ability.BossStoneA6Low ~= low then
		ability.BossStoneA6 = {}
		ability.BossStoneA6Low = low
		for i=low,100-low,low do
			ability.BossStoneA6[i]=true
		end
	end
	local modifierName = "modifier_boss_stone_a6_effect"

	for i=low,100-low,low do
		if heal_percent<=i then
			if ability.BossStoneA6[i] then
				ability.BossStoneA6[i] = false
				keys.ability:ApplyDataDrivenModifier(caster,caster,modifierName,nil)
			end
		else
			if ability.BossStoneA6[i] == false then
				ability.BossStoneA6[i] = true
				caster:RemoveModifierByName(modifierName)
			end
		end
	end
end


--Stone Big A1
function BossStoneSmallA1( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	local face = (caster:GetAbsOrigin() - point):Normalized()
	local vec = caster:GetAbsOrigin() + face*100
	Knockback( caster,vec,0.5,(point-caster:GetAbsOrigin()):Length(),500,true,function( )
		caster:RemoveModifierByName("modifier_boss_stone_small_a1_do")
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_boss_stone_small_a1",nil)
	end)
end

function BossStoneSmallA1Cast( keys )
	local caster = keys.caster
	local group = keys.target_entities
	local target = group[RandomInt(1,#group)]

	if IsValidAndAlive(target)~=true then return end

	caster:CastAbilityOnPosition(target:GetAbsOrigin(),keys.ability,target:GetPlayerOwnerID())
end