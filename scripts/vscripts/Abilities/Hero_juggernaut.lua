
--三个风暴
function JuggOneAbility1OnCreate( keys )
	local caster = keys.caster
	local ability = keys.ability
	local caster_abs = caster:GetAbsOrigin()
	local caster_face = caster:GetForwardVector()

	local unit = {}	--储存创建的单位

	local num = keys.storm_num	--创建的单位数量
	for i=1,num do
		local vec = caster_abs + caster_face * keys.radius_two
		unit[i] = CreateUnitByName("npc_majia",vec,false,nil,nil,caster:GetTeamNumber())
		unit[i].JuggOneAbility1Summoner = caster

		local vec2 = RotatePosition(caster_abs,QAngle(0,(360/num)*i,0),vec)
		unit[i]:SetAbsOrigin(vec2)

		ability:ApplyDataDrivenModifier(caster,unit[i],"modifier_juggernaut_one_ability1_majia",nil)
	end

	--调用旋转函数
	RotateTargetToCaster(caster,unit,keys.radius_two,5,0.01,ability:GetDuration(),false)

end

function JuggOneAbility1UnitDamage( keys )
	local caster = keys.target
	local targets = keys.target_entities

	--获取召唤者
	local hero = caster.JuggOneAbility1Summoner or false

	if hero then

		--判断召唤者是否存活
		if hero:IsAlive() then

			local table = {	caster = hero,
							target_entities = targets,
							damage = keys.damage,
							damage_type = keys.damage_type}
			DamageAOE(table)	--启动伤害系统

		else

			caster:RemoveModifierByName("modifier_juggernaut_one_ability1_majia")	--如果召唤者死亡删除马甲

		end
	end
end


--回旋剑刃
function JuggOneAbility2( keys )
	local caster = keys.caster
	local point = keys.target_points[1]
	local caster_abs = caster:GetAbsOrigin()
	local face = (point - caster_abs):Normalized()
	local len = (point - caster_abs):Length()

	local num = 2
	local c = true

	for i=1,num do
		local unit = CustomCreateUnit("npc_majia",caster_abs,270,caster:GetTeamNumber())
		keys.ability:ApplyDataDrivenModifier(caster,unit,"modifier_juggernaut_one_ability1_majia",nil)

		if i%2==0 then c = false else c = true end

		EllipseMotion( unit,caster,caster_abs+face*len,face,caster:GetRightVector(),1,300,c,nil,function( )
			unit:RemoveSelf()
		end )
	end
end


--神秘
function JuggOneAbility3CreateModifier( keys )
	local caster = keys.caster
	local ability = keys.ability

	local i = caster:GetModifierStackCount("modifier_juggernaut_one_ability4_effect",ability)

	if caster:HasModifier("modifier_juggernaut_one_ability4_effect") then
		caster:SetModifierStackCount("modifier_juggernaut_one_ability4_effect",ability,i+1)
	else
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_juggernaut_one_ability4_effect",nil)
	end
end

function JuggOneAbility3DestroyModifier( keys )
	local caster = keys.caster
	local ability = keys.ability

	local i = caster:GetModifierStackCount("modifier_juggernaut_one_ability4_effect",ability)

	if i > 0 then
		caster:SetModifierStackCount("modifier_juggernaut_one_ability4_effect",ability,i-1)
	else
		caster:RemoveModifierByName("modifier_juggernaut_one_ability4_effect")
	end
end