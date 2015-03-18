
--颜色渲染添加
function AntimageOneAbilityColor( keys )
	local caster = keys.caster
	local ability = keys.ability

	if ability:IsHidden() == false then
		local modifierName = string.format("modifier_%s_color",ability:GetAbilityName())
		ability:ApplyDataDrivenModifier(caster,caster,modifierName,nil)
	end
end

--透明
function AntimageOneAbility3( keys )
	local caster = keys.caster

	if caster:HasModifier("modifier_antimage_one_ability3") then
		caster:AddNewModifier(caster,keys.ability,"modifier_invisible",nil)

		local ability = caster:FindAbilityByName("antimage_one_ability4")
		if ability then
			ability:ApplyDataDrivenModifier(caster,caster,"modifier_antimage_one_ability4_damage",nil)
			ability:ApplyDataDrivenModifier(caster,caster,"modifier_antimage_one_ability4_3",nil)
		end
	end
end

--突变
function AntimageOneAbility4Cast( keys )
	keys.caster.AntimageOneAbility4Cast = keys.ability:GetAbilityName()
end

function AntimageOneAbility4( keys )
	local caster = keys.caster

	local abilityName = caster.AntimageOneAbility4Cast or nil

	if abilityName then
		local name = {
			"antimage_one_ability1",
			"antimage_one_ability2",
			"antimage_one_ability3",
		}

		--通过CD和技能名来判断当前使用哪个技能，并添加相应的modifier
		for i,v in pairs(name) do
			local ability = caster:FindAbilityByName(v)

			if ability then
				local cd = ability:GetCooldown(ability:GetLevel() - 1) - 0.3
				local re = ability:GetCooldownTimeRemaining()
				if ability:IsCooldownReady() == false and  re>=cd then
					if abilityName == ability:GetAbilityName() then
						keys.ability:ApplyDataDrivenModifier(caster,caster,"modifier_antimage_one_ability4_damage",nil)

						local modifierName = string.format("modifier_antimage_one_ability4_%d",i)
						keys.ability:ApplyDataDrivenModifier(caster,caster,modifierName,nil)

						break
					end
				end
			end
		end
	end
end


--幻象
function AntimageOneAbility5( keys )
	local caster = keys.caster
	local caster_abs = caster:GetAbsOrigin()

	if caster.AntimageOneAbility5 ~= "illusion" then
		local unit = CreateUnitByName(caster:GetUnitName(),caster_abs,false,nil,nil,caster:GetTeamNumber())
		unit.AntimageOneAbility5 = "illusion"
		unit.vOwner = caster:GetOwner()
		unit:SetPlayerID(caster:GetPlayerOwnerID())
		unit:SetControllableByPlayer(caster:GetPlayerOwnerID(),true)
		unit:AddNewModifier(unit,keys.ability,"modifier_illusion",{duration=keys.duration})
		unit:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})
		unit:SetModelScale(0.5)

		keys.ability:ApplyDataDrivenModifier(caster,unit,"modifier_antimage_one_ability5_remove",nil)

		local num = unit:GetAbilityCount()
		for i=0,num-1 do
			local ability = unit:GetAbilityByIndex(i)
			if ability then
				unit:RemoveAbility(ability:GetAbilityName())
			end
		end
	end

end
--删除幻象
function AntimageOneAbility5Remove( keys )
	local target = keys.target

	CustomTimer("AntimageOneAbility5Remove",function( )
		target:RemoveSelf()
		return nil
	end,0.1)
end


--统一
function AntimageOneAbility6( keys )
	local caster = keys.caster

	local name_1 = {
		"antimage_one_ability1",
		"antimage_one_ability2",
		"antimage_one_ability3",
	}

	local name_2 = {
		"antimage_one_ability1_fake",
		"antimage_one_ability2_fake",
		"antimage_one_ability3_fake",
	}

	--实现调换技能，并且添加相应的modifier
	for k,v in pairs(name_1) do
		local ability_1 = caster:FindAbilityByName(v)
		local ability_2 = caster:FindAbilityByName(name_2[k])
		if ability_1 ~= nil and ability_2 ~= nil then
			caster:SwapAbilities(v,name_2[k],false,true)

			local modifierName = string.format("modifier_antimage_one_ability%d",k)
			ability_1:ApplyDataDrivenModifier(caster,caster,modifierName,nil)
		end
	end
end

function AntimageOneAbility6Destroy( keys )
	local caster = keys.caster

	local name_1 = {
		"antimage_one_ability1",
		"antimage_one_ability2",
		"antimage_one_ability3",
	}

	local name_2 = {
		"antimage_one_ability1_fake",
		"antimage_one_ability2_fake",
		"antimage_one_ability3_fake",
	}

	--实现调换技能
	for k,v in pairs(name_1) do
		local ability_1 = caster:FindAbilityByName(v)
		local ability_2 = caster:FindAbilityByName(name_2[k])
		if ability_1 ~= nil and ability_2 ~= nil then
			caster:SwapAbilities(v,name_2[k],true,false)
		end
	end
end