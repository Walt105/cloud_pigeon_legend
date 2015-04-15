
--蓝色精灵效果
function WispBlue1( keys )
	local caster = keys.caster
	local target = keys.target

	if target:IsHero() == false then return end

	target:Kill(nil,caster)
end

--精灵球弹跳
function NpcWispAbility1( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	local face = (caster:GetAbsOrigin() - point):Normalized()
	local vec = caster:GetAbsOrigin() + face*100
	Knockback( caster,vec,0.5,(point-caster:GetAbsOrigin()):Length(),500,true,function( )
		local modifierName = string.format("modifier_npc_wisp_ability1_%s",caster:GetUnitName())
		ability:ApplyDataDrivenModifier(caster,caster,modifierName,nil)
	end)
end

--绿色精灵效果
function WispAbility1Green( keys )
	local caster = keys.caster
	local target = keys.target

	if target:IsHero()==false then return end

	local modifierName = string.format("modifier_npc_wisp_ability1_%s_effect",caster:GetUnitName())

	caster:Kill(nil,caster)
	target:RemoveModifierByName(modifierName)
	local caster_abs = target:GetAbsOrigin()

	--获取玩家英雄
	local unit = {}
	for i=0,DOTA_MAX_PLAYER_TEAMS-1 do
		local player = PlayerResource:GetPlayer(i)
		if player then
			local hero = player:GetAssignedHero()
			if hero:IsOpposingTeam(caster:GetTeamNumber())==false then
				table.insert(unit,hero)
			end
		end
	end

	--获取死亡的英雄
	local unit_death = {}
	for i,v in ipairs(unit) do
		if v:IsAlive() then
		else
			table.insert(unit_death,v)
		end
	end
	TableRemoveTable(unit_death,caster)
	TableRemoveTable(unit,caster)

	if #unit_death ~= 0 then

		--有英雄死亡时
		local hero = unit_death[RandomInt(1,#unit_death)]
		hero:RespawnUnit()
		hero:SetAbsOrigin(caster_abs)
		hero:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})

	else

		--没有英雄死亡
		target:CustomHeal(RandomInt(200,1000))

	end
	
end

--红色精灵效果
function WispAbility1Red( keys )
	local caster = keys.caster
	local target = keys.target

	if target:IsHero()==false then return end

	if RollPercentage(15) then
		target:Kill(nil,caster)
	else
		local ability = caster:FindAbilityByName("npc_wisp_red_effect")
		if ability then
			local modifier = string.format("modifier_npc_wisp_red_effect_buff_%d",RandomInt(1,8))
			ability:ApplyDataDrivenModifier(target,target,modifier,nil)
		end
	end
	caster:Kill(nil,caster)

	if IsValidAndAlive(target)~=true then return end
	local modifierName = string.format("modifier_npc_wisp_ability1_%s_effect",caster:GetUnitName())
	target:RemoveModifierByName(modifierName)
end