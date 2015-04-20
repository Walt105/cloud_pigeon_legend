

if CAI == nil then
	CAI = class({})
end

--有有一些modifier不作为
CAI.NotWorkModifiers = {
	"modifier_boss_millenary_treant_a5",
}

function CAI:NotWork( unit )
	for k,v in pairs(CAI.NotWorkModifiers) do
		if IsValidAndAlive(unit) == true then
			if unit:HasModifier(v) then
				return true
			end
		end
	end
	return false
end

function CAI:NotWorkChanneling( unit )
	if IsValidAndAlive(unit) ~= true then return false end
	for i=0,unit:GetAbilityCount()-1 do
		local ability = unit:GetAbilityByIndex(i)
		if ability then
			if ability:IsChanneling() then
				return true
			end
		end
	end
	return false
end

--匹配boss技能
function CAI:FindBossAbility( unit,name )
	--GameRules.BossAbility在Abilities/common.lua中的净化进行了记录
	for k,v in pairs(GameRules.BossAbility) do
		if name == k then
			return v
		end
	end
	return false
end

--施法
function CAI:CastAbility( unit,ability,at )
	
	if ability:IsUnitTarget() then
		print(unit:GetUnitName().." Cast "..ability:GetAbilityName())
		local teams = ability:GetAbilityTargetTeam()
	    local types = ability:GetAbilityTargetType()
	    local flags = ability:GetAbilityTargetFlags()
	    local target = CAI:FindRadiusOneUnit( unit,ability:GetCastRange(),teams,types,flags,at )
		if target then
			unit:CastAbilityOnTarget(target,ability,target:GetPlayerOwnerID())
			print("target:",target:GetUnitName())
		end
	elseif ability:IsPoint() then
		print(unit:GetUnitName().." Cast "..ability:GetAbilityName())
		local teams = ability:GetAbilityTargetTeam()
	    local types = ability:GetAbilityTargetType()
	    local flags = ability:GetAbilityTargetFlags()
	    local target = CAI:FindRadiusOneUnit( unit,ability:GetCastRange(),teams,types,flags,at )
	    if target then
			unit:CastAbilityOnPosition(target:GetOrigin(),ability,target:GetPlayerOwnerID())
		end
	elseif ability:IsNoTarget() then
		print(unit:GetUnitName().." Cast "..ability:GetAbilityName())
		ability:CastAbility()
	end
end

--获取生命值最大的单位
function FindUnitMaxHeal( group )
	local max = nil
	local min = nil
	if group then
		max = group[1]
		min = group[1]
		for k,v in pairs(group) do
			if v ~= max then
				if IsValidAndAlive(v) == true then
					if v:GetHealth() > max:GetHealth() then
						max = v
					elseif v:GetHealth() < min:GetHealth() then
						min = v
					end
				end
			end
		end
	end

	return max,min
end

--计算是近战还是远程
function CAI:FindSelectMeleeAndRange( i,const )
	if (i-BOSSCASTABILITYSELECT_EXTRA_MELEE) == const then
		return "Melee"
	elseif (i-BOSSCASTABILITYSELECT_EXTRA_RANGE) == const then
		return "Range"
	elseif (i-BOSSCASTABILITYSELECT_EXTRA_MELEE-BOSSCASTABILITYSELECT_EXTRA_RANGE) == const then
		return "MeleeAndRange"
	end
end

--重新筛选单位组
function CAI:AgainSelectGroup( i,const,group )
	if i == const or CAI:FindSelectMeleeAndRange( i,const ) == "MeleeAndRange" then
		return group

	elseif CAI:FindSelectMeleeAndRange( i,const ) == "Melee" then
		local num = #group
		for i=1,num do
			for k,v in pairs(group) do
				if IsValidAndAlive(v) == true then
					if v:IsRangedAttacker() then
						table.remove(group,k)
						break
					end
				else
					table.remove(group,k)
					break
				end
			end
		end
		return group

	elseif CAI:FindSelectMeleeAndRange( i,const ) == "Range" then
		local num = #group
		for i=1,num do
			for k,v in pairs(group) do
				if IsValidAndAlive(v) == true then
					if v:IsRangedAttacker() then else
						table.remove(group,k)
						break
					end
				else
					table.remove(group,k)
					break
				end
			end
		end
		return group

	end
end

--根据仇恨选择
function CAI:AgainSelectGroupHate( i,const,boss )
	if i == const or CAI:FindSelectMeleeAndRange( i,const ) == "MeleeAndRange" then
		return boss:GetHateSystemMaxHero()

	elseif CAI:FindSelectMeleeAndRange( i,const ) == "Melee" then
		if GetBossCastAbilitySelect(i) == BOSSCASTABILITYSELECT_HATESYSTEM_MAX then
			return boss:GetHateSystemMaxMeleeHero()
		else
			return boss:GetHateSystemMinMeleeHero()
		end

	elseif CAI:FindSelectMeleeAndRange( i,const ) == "Range" then
		if GetBossCastAbilitySelect(i) == BOSSCASTABILITYSELECT_HATESYSTEM_MAX then

			return boss:GetHateSystemMaxRangedHero()
		else
			return boss:GetHateSystemMinRangedHero()
		end

	end
end

--获取周围的一个单位
function CAI:FindRadiusOneUnit( boss,radius,teams,types,flags,at )
	local group = FindUnitsInRadius(boss:GetTeamNumber(),boss:GetOrigin(),nil,radius,teams,types,flags,FIND_ANY_ORDER,true)
	local unit = group[RandomInt(1,#group)]

	if at then
		if at.BossCastAbilitySelect then
			local str = BossCastStringSplit(at.BossCastAbilitySelect)
			local i = FindBossCastAbilityUnit(str)

			if GetBossCastAbilitySelect(i) == BOSSCASTABILITYSELECT_Random then
				--随机选取
				group = CAI:AgainSelectGroup( i,BOSSCASTABILITYSELECT_Random,group )
				unit = group[RandomInt(1,#group)]

			elseif GetBossCastAbilitySelect(i) == BOSSCASTABILITYSELECT_MAX_HEAL then
				--选取生命值最大的
				group = CAI:AgainSelectGroup( i,BOSSCASTABILITYSELECT_MAX_HEAL,group )
				unit = FindUnitMaxHeal(group)

			elseif GetBossCastAbilitySelect(i) == BOSSCASTABILITYSELECT_MIN_HEAL then
				--选取生命值最小的
				group = CAI:AgainSelectGroup( i,BOSSCASTABILITYSELECT_MIN_HEAL,group )
				_,unit = FindUnitMaxHeal(group)

			elseif GetBossCastAbilitySelect(i) == BOSSCASTABILITYSELECT_HATESYSTEM_MAX then
				--选取仇恨值最大的
				unit = CAI:AgainSelectGroupHate( i,BOSSCASTABILITYSELECT_HATESYSTEM_MAX,boss )

			elseif GetBossCastAbilitySelect(i) == BOSSCASTABILITYSELECT_HATESYSTEM_MIN then
				--选取仇恨值最小的
				unit = CAI:AgainSelectGroupHate( i,BOSSCASTABILITYSELECT_HATESYSTEM_MIN,boss )

			end
		end
	end

	return unit
end

--AI-自动施放技能入口
function CAI:AutoCastAbility( unit )

	local ability = {}
	local ability_not = {}
	for i=0,unit:GetAbilityCount()-1 do
		local a = unit:GetAbilityByIndex(i)
		if a then
			local aName = a:GetAbilityName()
			local b = CAI:FindBossAbility(unit,aName)
			if b then
				if b.Boss == 1 and b.BossAutoCast == 1 then
					ability[aName] = b
				elseif b.Boss == 1 and b.BossAutoCast == 0 then
					ability_not[aName] = b
				end
			end
		end
	end
	
	CustomTimer("CAI_AutoCastAbility",function( )
		
		if IsValidAndAlive(unit) ~= true then
			return nil
		end

		if unit._BossIsWar == true then else
			return RandomFloat(1,10)
		end

		if CAI:NotWork(unit) or CAI:NotWorkChanneling( unit ) then
			return RandomFloat(1,5)
		end

		local group = FindUnitsInRadius(unit:GetTeamNumber(),unit:GetOrigin(),nil,1000,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS,FIND_UNITS_EVERYWHERE,true)
		if #group > 0 then else
			return RandomFloat(1,10)
		end

		local heal_percent = unit:GetHealthPercent()
		local time = 0.25 + (heal_percent/10)

		local random = RandomFloat(15,100)

		if RollPercentage(random) then
			for k,v in pairs(ability) do
				local hp = v.BossHealPercent
				if hp then
					if heal_percent <= hp then
						local min = v.BossCastPercentMin
						local max = v.BossCastPercentMax
						if min ~= nil and max ~= nil then
							if RollPercentage(RandomFloat(min,max)) then
								local a = unit:FindAbilityByName(k)
								if a then
									if a:IsCooldownReady() then
										CAI:CastAbility( unit,a,v )

										if v.BossNextAbility ~= nil and v.BossNextAbilityDelay ~= nil then
											CustomTimer("CAINEXT",function( )
												local b = unit:FindAbilityByName(v.BossNextAbility)
												if b then
													if b:IsCooldownReady() then
														CAI:CastAbility( unit,b,ability_not[v.BossNextAbility] )
													end
												end
											end,tonumber(v.BossNextAbilityDelay))
										end
									end
								end
							end
						end
					end
				end
			end
		end

		return RandomFloat(0.25,time)
	end,0)

end


--AI-自动攻击入口
function CAI:AutoAttack( unit )
	CustomTimer("CAI_AutoAttack",function( )
		
		if IsValidAndAlive(unit) ~= true then
			return nil
		end

		if unit._BossIsWar == true then else
			return RandomFloat(1,10)
		end

		if CAI:NotWork(unit) or CAI:NotWorkChanneling( unit ) then
			return RandomFloat(1,5)
		end

		local group = FindUnitsInRadius(unit:GetTeamNumber(),unit:GetOrigin(),nil,600,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS,FIND_CLOSEST,true)
		if #group > 0 then 
			local a = nil
			_,a = FindUnitMaxHeal( group )
			local newOrder = {
		        UnitIndex       = unit:entindex(), 
		        TargetIndex     = a:entindex(),
		        OrderType       = DOTA_UNIT_ORDER_ATTACK_TARGET,
		        Queue           = 0
		    }
		    ExecuteOrderFromTable(newOrder)
		    return RandomFloat(1,3)
		else
			return RandomFloat(1,10)
		end

		return RandomFloat(1,3)
	end,0)
end