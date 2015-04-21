
--储备电能
function LunaOneAbility1OnCreate( keys )
	local caster = keys.caster
	local ability = keys.ability

	local m = caster.LunaOneAbility1Modifier or 0

	if caster:HasModifier("modifier_luna_one_ability1_null") then

		if m<keys.max_modifier then
			local i = caster:GetModifierStackCount("modifier_luna_one_ability1_null",ability)
			ability:ApplyDataDrivenModifier(caster,caster,"modifier_luna_one_ability1_effect",nil)
			caster:SetModifierStackCount("modifier_luna_one_ability1_null",ability,i+1)
			caster.LunaOneAbility1Modifier = caster.LunaOneAbility1Modifier + 1
		end

	else

		ability:ApplyDataDrivenModifier(caster,caster,"modifier_luna_one_ability1_null",nil)
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_luna_one_ability1_effect",nil)
		caster:SetModifierStackCount("modifier_luna_one_ability1_null",ability,1)
		caster.LunaOneAbility1Modifier = 1

	end
end

--删除叠加的电能
function LunaOneAbility1RemoveModifier( caster,count )
	
	local ability = caster:FindAbilityByName("luna_one_ability1")
	local num = caster:GetModifierStackCount("modifier_luna_one_ability1_null",ability)

	if count == 0 then	--为0则删除全部

		caster:RemoveModifierByName("modifier_luna_one_ability1_null")

		for i=1,num do
			if caster:HasModifier("modifier_luna_one_ability1_effect") then
				caster:RemoveModifierByName("modifier_luna_one_ability1_effect")

			else
				return
			end
		end

	elseif count > 0 then	--大于0则减去相应数量

		for i=1,count do
			if caster:HasModifier("modifier_luna_one_ability1_effect") then
				caster:RemoveModifierByName("modifier_luna_one_ability1_effect")
				caster:SetModifierStackCount("modifier_luna_one_ability1_null",ability,num-1)

				if caster:GetModifierStackCount("modifier_luna_one_ability1_null",ability) == 0 then
					caster:RemoveModifierByName("modifier_luna_one_ability1_null")
				end

			else
				return
			end
		end

	end
end


--摩擦生电
function LunaOneAbility2( keys )
	local caster = keys.caster
	local point = keys.target_points[1]
	local ability = keys.ability
	local caster_abs = caster:GetAbsOrigin()
	local face = (caster_abs - point):Normalized()
	local vec = caster_abs + face*100

	local unit = CustomCreateUnit("npc_majia",caster_abs,270,caster:GetTeamNumber())
	ability:ApplyDataDrivenModifier(caster,unit,"modifier_luna_one_ability2",nil)

	Knockback( unit,vec,0.5,(point-caster_abs):Length(),500,true,function( )
		local u_abs = unit:GetAbsOrigin()
		local q = ParticleManager:CreateParticle("particles/units/heroes/hero_stormspirit/stormspirit_overload_discharge.vpcf",PATTACH_WORLDORIGIN,unit)
		ParticleManager:SetParticleControl(q,0,u_abs)

		ability:ApplyDataDrivenModifier(caster,unit,"modifier_luna_one_ability2_damage",nil)

		unit:RemoveSelf()
	end)
end


--感应电流
function LunaOneAbility3( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local heal = caster:GetHealthPercent()

	if heal < 50 then

		--恢复血量
		ability:ApplyDataDrivenModifier(caster,target,"modifier_luna_one_ability3_effect_heal",nil)

	else

		--造成伤害
		ability:ApplyDataDrivenModifier(caster,target,"modifier_luna_one_ability3_effect_damage",nil)
		LunaOneAbility1RemoveModifier(caster,1)

	end
end


--避雷针
function LunaOneAbilityLight( caster ) --此为雷劈特效的创建
	
	local vec = caster:GetOrigin()
	local p = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf",PATTACH_WORLDORIGIN,caster)
	ParticleManager:SetParticleControl(p,0,vec)
	ParticleManager:SetParticleControl(p,1,Vector(vec.x,vec.y,1000))
	ParticleManager:SetParticleControl(p,3,vec)
	ParticleManager:ReleaseParticleIndex(p)

	local q = ParticleManager:CreateParticle("particles/units/heroes/hero_stormspirit/stormspirit_overload_discharge.vpcf",PATTACH_WORLDORIGIN,caster)
	ParticleManager:SetParticleControl(q,0,vec)

	EmitSoundOn("Hero_Zuus.LightningBolt",caster)
	
end

function LunaOneAbility4( keys )
	local caster = keys.caster
	local target = keys.target

	if caster.LunaOneAbility4AddChance == nil then
		caster.LunaOneAbility4AddChance = 0
	end

	if RollPercentage(keys.chance + caster.LunaOneAbility4AddChance) then

		LunaOneAbilityLight(target)
		keys.ability:ApplyDataDrivenModifier(caster,target,"modifier_luna_one_ability4_damage",nil)
		LunaOneAbility1RemoveModifier(caster,1)

	end
end


--电磁感应
function LunaOneAbility5( keys )
	local caster = keys.caster
	local ability = keys.ability

	local num = caster:GetModifierStackCount("modifier_luna_one_ability5_effect",ability)

	if num == 0 then

		--初始化
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_luna_one_ability5_effect",nil)
		caster:SetModifierStackCount("modifier_luna_one_ability5_effect",ability,1)

	else

		--增加层数
		caster:SetModifierStackCount("modifier_luna_one_ability5_effect",ability,num + 1)

	end
end


--乌云
function LunaOneAbility6( keys )
	local caster = keys.caster
	local ability = keys.ability

	--创建马甲
	local unit = CreateUnitByName("npc_majia",caster:GetOrigin(),false,nil,nil,caster:GetTeamNumber())

	--设置避雷针触发概率为100
	caster.LunaOneAbility4AddChance = 100

	CustomTimer("LunaOneAbility6",
		function( )
			
			if caster:HasModifier("modifier_luna_one_ability6")==false then
				caster.LunaOneAbility4AddChance = 0 
				unit:RemoveSelf()
				return nil
			end

			--随机取地点
			local caster_abs = caster:GetAbsOrigin()
			local face = caster_abs + caster:GetForwardVector() * RandomInt(0,keys.range)
			local vec = RotatePosition(caster_abs,QAngle(0,RandomInt(0,360),0),face)

			--移动马甲位置并且造成伤害
			unit:SetAbsOrigin(vec)
			LunaOneAbilityLight(unit)
			ability:ApplyDataDrivenModifier(caster,unit,"modifier_luna_one_ability6_damage",nil)

			--消耗一层电能
			LunaOneAbility1RemoveModifier(caster,1)

			return keys.interval
		end,0)
end
