
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


--尾随
function JuggOneAbility2OnCreate( keys )
	local caster = keys.caster
	local target = keys.target

	if caster == target then
		caster:SetMana(caster:GetMana() + keys.ability:GetManaCost(keys.ability:GetLevel() - 1))
		keys.ability:EndCooldown()
		return
	else
		keys.ability:ApplyDataDrivenModifier(caster,caster,"modifier_juggernaut_one_ability2",nil)
	end

	--OneAbility2Dura 用于判断是否在持续时间内
	caster.OneAbility2Dura = true
	caster:AddNewModifier(nil,nil,"modifier_phased",{duration = keys.duration})

	--获取技能并设置显隐
	local ability1 = keys.ability
	local ability2 = caster:FindAbilityByName("juggernaut_one_ability2_over")
	ability1:SetHidden(true)
	ability2:SetHidden(false)

	local interval = 0.02
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("OneAbility2OnCreate"),
		function( )
			if IsValidEntity(target)==false or caster.OneAbility2Dura == false then

				caster:RemoveModifierByName("modifier_phased")
				caster:RemoveModifierByName("modifier_juggernaut_one_ability2")
				FindClearSpaceForUnit(caster,caster:GetOrigin(),true)

				return nil
			end

			--在双方存活的情况下，caster尾随在target后面
			if target:IsAlive() and caster:IsAlive() then

				local target_abs = target:GetAbsOrigin()
				local face = target:GetForwardVector()	* -1
				local vec = target_abs + 150 * face

				caster:SetAbsOrigin(vec)

			else

				caster:RemoveModifierByName("modifier_juggernaut_one_ability2")

				return nil
			end

			return interval
		end,0)
end

function JuggOneAbility2Over( keys )
	local caster = keys.caster
	caster.OneAbility2Dura = false

	--获取技能并设置显隐
	local ability1 = caster:FindAbilityByName("juggernaut_one_ability2")
	local ability2 = caster:FindAbilityByName("juggernaut_one_ability2_over")
	ability1:SetHidden(false)
	ability2:SetHidden(true)
end


--三把刀
--狂暴 1
--剧毒 2
--吸血 3
function JuggOneAbility3( keys )
	local caster = keys.caster

	local ability = {}
	ability[1] = caster:FindAbilityByName("juggernaut_one_ability3_kuangbao")
	ability[2] = caster:FindAbilityByName("juggernaut_one_ability3_judu")
	ability[3] = caster:FindAbilityByName("juggernaut_one_ability3_xixue")

	for i=1,#ability do
		if ability[i] == nil then
			return
		end
	end
	
	if caster.JuggOneAbility3_next_weapon == 1 then
		caster.JuggOneAbility3_next_weapon = 2

		--设置技能可见性
		ability[1]:SetHidden(false)
		ability[2]:SetHidden(true)
		ability[3]:SetHidden(true)

		--添加和删除modifier
		caster:RemoveModifierByName("modifier_juggernaut_one_ability3_judu")
		caster:RemoveModifierByName("modifier_juggernaut_one_ability3_xixue")
		ability[1]:ApplyDataDrivenModifier(caster,caster,"modifier_juggernaut_one_ability3_kuangbao",nil)
		
	elseif caster.JuggOneAbility3_next_weapon == 2 then
		caster.JuggOneAbility3_next_weapon = 3

		--设置技能可见性
		ability[1]:SetHidden(true)
		ability[2]:SetHidden(false)
		ability[3]:SetHidden(true)

		--添加和删除modifier
		caster:RemoveModifierByName("modifier_juggernaut_one_ability3_kuangbao")
		caster:RemoveModifierByName("modifier_juggernaut_one_ability3_xixue")
		ability[2]:ApplyDataDrivenModifier(caster,caster,"modifier_juggernaut_one_ability3_judu",nil)
		
	elseif caster.JuggOneAbility3_next_weapon == 3 then
		caster.JuggOneAbility3_next_weapon = 1

		--设置技能可见性
		ability[1]:SetHidden(true)
		ability[2]:SetHidden(true)
		ability[3]:SetHidden(false)

		--添加和删除modifier
		caster:RemoveModifierByName("modifier_juggernaut_one_ability3_kuangbao")
		caster:RemoveModifierByName("modifier_juggernaut_one_ability3_judu")
		ability[3]:ApplyDataDrivenModifier(caster,caster,"modifier_juggernaut_one_ability3_xixue",nil)
		
	end
end

--初始化
function JuggOneAbility3Init( keys )
	local caster = keys.caster

	if caster.one_ability3_init == nil then
		caster.one_ability3_init = true

		--下一把武器
		if caster.JuggOneAbility3_next_weapon == nil then
			caster.JuggOneAbility3_next_weapon = 2
		end

		--获取技能
		local ability = {}
		ability[1] = caster:FindAbilityByName("juggernaut_one_ability3_kuangbao")
		ability[2] = caster:FindAbilityByName("juggernaut_one_ability3_judu")
		ability[3] = caster:FindAbilityByName("juggernaut_one_ability3_xixue")

		--其中一个技能为nil就退出函数
		for i=1,#ability do
			if ability[i] == nil then
				return
			end
		end

		--设置技能可见性
		ability[1]:SetHidden(false)
		ability[2]:SetHidden(true)
		ability[3]:SetHidden(true)

		--添加和删除modifier
		ability[1]:ApplyDataDrivenModifier(caster,caster,"modifier_juggernaut_one_ability3_kuangbao",nil)
		caster:RemoveModifierByName("modifier_juggernaut_one_ability3_judu")
		caster:RemoveModifierByName("modifier_juggernaut_one_ability3_xixue")
	end
end

--用于英雄死亡后modifier消失的修复
function JuggOneAbility3OnCreated( keys )
	local caster = keys.caster

	--获取技能
	local ability = {}
	ability[1] = caster:FindAbilityByName("juggernaut_one_ability3_kuangbao")
	ability[2] = caster:FindAbilityByName("juggernaut_one_ability3_judu")
	ability[3] = caster:FindAbilityByName("juggernaut_one_ability3_xixue")

	--其中一个技能为nil就退出函数
	for i=1,#ability do
		if ability[i] == nil then
			return
		end
	end

	if caster.JuggOneAbility3_next_weapon == 1 then
		ability[3]:ApplyDataDrivenModifier(caster,caster,"modifier_juggernaut_one_ability3_xixue",nil)

	elseif caster.JuggOneAbility3_next_weapon == 2 then
		ability[1]:ApplyDataDrivenModifier(caster,caster,"modifier_juggernaut_one_ability3_kuangbao",nil)

	elseif caster.JuggOneAbility3_next_weapon == 3 then
		ability[2]:ApplyDataDrivenModifier(caster,caster,"modifier_juggernaut_one_ability3_judu",nil)

	end
end

--显示狂暴的modifier数量
function JuggOneAbility3KBModifierCount( keys )
	local caster = keys.caster

	local modifierName = "modifier_juggernaut_one_ability3_kuangbao"
	local i = caster:GetModifierStackCount(modifierName,keys.ability)

	if keys.AddOrLow == "Add" then
		caster:SetModifierStackCount(modifierName,keys.ability,i+1)
	end

	if keys.AddOrLow == "Low" then
		caster:SetModifierStackCount(modifierName,keys.ability,i-1)
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