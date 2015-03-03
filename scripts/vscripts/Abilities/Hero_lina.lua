

--弹跳火球
function LinaOneAbility1( keys )
	local caster = keys.caster
 	local target = keys.target
 	local ability = keys.ability
 	local effectName = keys.EffectName
 	local move_speed = tonumber(keys.move_speed)
 	local radius = keys.radius
 	local count = keys.count
 	local teams = ability:GetAbilityTargetTeam()
    local types = ability:GetAbilityTargetType()
    local flags = ability:GetAbilityTargetFlags()
    local find_tpye = FIND_CLOSEST

 	Catapult( caster,target,ability,effectName,move_speed,radius,count,teams,types,flags,find_tpye )
end

--火气冲天
function LinaOneAbility2( keys )
	local caster = keys.caster
	local point = keys.target_points[1]
	local face = caster:GetForwardVector()
	local ability = keys.ability

	local unit = {}
	local num = 6
	for i=1,num do
		local vec = point + face * 200
		local rota = RotatePosition(point,QAngle(0,(360/num)*i,0),vec)
		unit[i] = CreateUnitByName("npc_majia",rota,false,nil,nil,caster:GetTeamNumber())
		ability:ApplyDataDrivenModifier(caster,unit[i],"modifier_lina_one_ability2",nil)
	end
end