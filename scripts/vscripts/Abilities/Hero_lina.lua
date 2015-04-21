

--凤凰飞舞
function LinaOneAbility1( keys )
	local caster = keys.caster
	local caster_abs = caster:GetAbsOrigin()
	local face = caster:GetForwardVector()
	local num = keys.number
	local radius = keys.radius
	local angle_speed = keys.angle_speed
	local len = keys.length

 	for i=1,num do
 		local vec = caster_abs + face*radius
		local rota = RotatePosition(caster_abs,QAngle(0,(360/num)*i,0),vec) 
 		local unit = CustomCreateUnit("npc_lina_phoenix",rota,270,caster:GetTeamNumber())
 		keys.ability:ApplyDataDrivenModifier(caster,unit,"modifier_lina_one_ability1",nil)

 		RotateMotion( unit,caster,2.5,radius,radius,angle_speed,function( a )
 			local c_abs = caster:GetAbsOrigin()
 			local u_abs = unit:GetAbsOrigin()
 			local f = (u_abs - c_abs):Normalized()
 			unit:SetForwardVector(f)
 			unit:SetForwardVector(-unit:GetRightVector())
 			a.AngleSpeed = a.AngleSpeed + 0.02
 			angle_speed = a.AngleSpeed

 		end,function( )

 			if IsValidAndAlive(caster)==true then
	 			RotateMotion( unit,caster,4,len,0,angle_speed,function( a )
		 			local c_abs = caster:GetAbsOrigin()
		 			local u_abs = unit:GetAbsOrigin()
		 			local f = (u_abs - c_abs):Normalized()
		 			unit:SetForwardVector(f)
		 			unit:SetForwardVector(-unit:GetRightVector())
		 			a.AngleSpeed = a.AngleSpeed + 0.02

		 		end,function( )
		 			unit:RemoveSelf()
		 		end)
		 	else
		 		unit:RemoveSelf()
	 		end
 		end)
 	end
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

	CustomTimer("LinaOneAbility2",function( )
		EmitSoundOn("Ability.LightStrikeArray",unit[1])

		return keys.interval
	end,keys.interval)
end


--汲取热量
function LinaOneAbility3( keys )
	local caster = keys.caster
	local target = keys.target
	local s = 850

	local name = "particles/custom/heros/lina/lina_ability1.vpcf"
	local p = CustomCreateParticle(name,PATTACH_CUSTOMORIGIN_FOLLOW,caster,1.6,false,function( )
		keys.ability:ApplyDataDrivenModifier(caster,target,"modifier_lina_one_ability3",nil)
	end)
	ParticleManager:SetParticleControlEnt(p,1,caster,5,"attach_hitloc",caster:GetOrigin(),true)
	ParticleManager:SetParticleControlEnt(p,0,target,5,"attach_hitloc",target:GetOrigin(),true)
	ParticleManager:SetParticleControl(p,2,Vector(s,s,s))
	ParticleManager:SetParticleControl(p,3,Vector(s,s,s))
end


--轰轰烈烈
function LinaOneAbility6( keys )
	local caster = keys.caster
	local group = keys.target_entities
	local group_num = #group
	local radius = keys.radius

	local target = group[RandomInt(1,group_num)]

	local unit = nil
	local unit_abs = caster:GetOrigin()
	for i=1,group_num do
		if IsValidEntity(target) then
			if target:IsAlive() then
				unit = CreateUnitByName("npc_majia",target:GetOrigin(),false,nil,nil,caster:GetTeamNumber())
				unit_abs = unit:GetAbsOrigin()
				break
			end
		end
		target = group[RandomInt(1,group_num)]
	end

	if unit == nil then return end

	local dura = 1.5
	local particleName_1 = "particles/units/heroes/hero_invoker/invoker_chaos_meteor_fly.vpcf"
	local p_1 = ParticleManager:CreateParticle(particleName_1,PATTACH_WORLDORIGIN,unit)
	ParticleManager:SetParticleControl(p_1,0,Vector(unit_abs.x,unit_abs.y,1000))
	ParticleManager:SetParticleControl(p_1,1,unit_abs)
	ParticleManager:SetParticleControl(p_1,2,Vector(dura,dura,dura))
	ParticleManager:SetParticleControl(p_1,3,unit_abs)

	EmitSoundOn("Hero_Invoker.ChaosMeteor.Loop",unit)

	CustomTimer("LinaOneAbility6",
		function( )
			StopSoundEvent("Hero_Invoker.ChaosMeteor.Loop",unit)

			local particleName_2 = "particles/custom/heros/lina/lina_ability6_over.vpcf"
			local p_2 = ParticleManager:CreateParticle(particleName_2,PATTACH_WORLDORIGIN,unit)
			ParticleManager:SetParticleControl(p_2,0,unit_abs)
			ParticleManager:SetParticleControl(p_2,1,Vector(radius,radius,radius))
			ParticleManager:SetParticleControl(p_2,3,unit_abs)

			keys.ability:ApplyDataDrivenModifier(caster,unit,"modifier_lina_one_ability6_damage",nil)

			return nil
		end,dura)
end