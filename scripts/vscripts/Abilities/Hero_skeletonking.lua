
--灵魂之球
function SkeletonkingOneAbility1( keys )
	local caster = keys.caster
	local target = keys.target

	if IsValidEntity(target) then
		if target:IsAlive() then
			local target_abs = target:GetAbsOrigin()

			--造成伤害
			local t = {	target = target,
						caster = caster,
						damage = RandomInt(keys.damage_min,keys.damage_max),
						damage_type = keys.damage_type}
			local damage = DamageTarget(t)

			--创建单位
		    local unit = CreateUnitByName("npc_majia",target_abs,false,nil,nil,caster:GetTeamNumber())
		    unit.SkeletonkingOneAbility1Heal = damage * keys.num

		    --施放技能
		    local abilityName = "skeletonking_one_ability1_majia"
		    unit:AddAbility(abilityName)
		    local ability = unit:FindAbilityByName(abilityName)
		    ability:SetLevel(1)
		    ability:CastAbility()
		end
	end
end

function SkeletonkingOneAbility1Heal( keys )
	local caster = keys.caster
	local target = keys.target

	if caster ~= target then
		local heal = caster.SkeletonkingOneAbility1Heal or 0
		target:CustomHeal(heal)
	end
end


--灵魂净化
function SkeletonkingOneAbility3( keys )
	local target = keys.target
	local ability = keys.ability
	target:CustomPurge(false,true)
	ability:ApplyDataDrivenModifier(target,target,"modifier_skeletonking_one_ability3",nil)
end


--饥渴难耐
function SkeletonkingOneAbility4IsCriticalStrike( keys )
	local caster = keys.caster
	if keys.IsCriticalStrike == "true" then
		caster.SkeletonkingOneAbility4IsCriticalStrike=true
	else
		caster.SkeletonkingOneAbility4IsCriticalStrike=false
	end
end
function SkeletonkingOneAbility4( keys )
	local caster = keys.caster

	if caster.SkeletonkingOneAbility4IsCriticalStrike == true then
		local teams = DOTA_UNIT_TARGET_TEAM_FRIENDLY
    	local types = DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO
    	local flags = DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS
    	local group = FindUnitsInRadius(caster:GetTeamNumber(),caster:GetOrigin(),nil,keys.radius,teams,types,flags,FIND_CLOSEST,true)

    	for i,v in pairs(group) do
    		v:CustomHeal(keys.AttackDamage)
    	end
	end
end


--稳固
function SkeletonkingOneAbility5( keys )
	local caster = keys.caster
	local caster_abs = caster:GetAbsOrigin()

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

	else

		--没有英雄死亡
		local hero = unit[1]
		if hero == nil then return end
		for i=1,#unit do
			if hero:GetHealth() > unit[i]:GetHealth() then
				hero = unit[i]
			end
		end
		hero:SetHealth(hero:GetMaxHealth())

	end
end


--巨石之魂
function SkeletonkingOneAbility6( keys )
	local caster = keys.caster
	local ability = keys.ability
	local group = keys.target_entities

	for k,v in pairs(group) do
		if IsValidAndAlive(v) == true then
			ability:ApplyDataDrivenModifier(v,v,"modifier_skeletonking_one_ability6",nil)
			v.SkeletonkingOneAbility6Hero = caster
		end
	end
end

function SkeletonkingOneAbility6OnCreated( keys )
	local caster = keys.caster
	caster.SkeletonkingOneAbility6=0
end

function SkeletonkingOneAbility6TakeDamage( keys )
	local caster = keys.caster

	if IsValidAndAlive(caster) == true then
		caster:SetHealth(caster:GetHealth() + keys.TakeDamage)
		caster.SkeletonkingOneAbility6 = caster.SkeletonkingOneAbility6 + keys.TakeDamage
	end
end

function SkeletonkingOneAbility6OnDestroy( keys )
	local caster = keys.caster
	local group = keys.target_entities
	local hero = caster.SkeletonkingOneAbility6Hero or caster

	--造成伤害
	local t = {	target_entities = group,
				caster = hero,
				damage = caster.SkeletonkingOneAbility6,
				damage_type = keys.damage_type}
	local damage = DamageAOE(t)
end