

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

-- function LinaOneAbility1( keys )
-- 	local caster = keys.caster
-- 	local target = keys.target
-- 	local old_target = caster

-- 	local str = DoUniqueString("LinaOneAbility1")

-- 	local unit = {}
-- 	unit.LinaOneAbility1Next = false
-- 	unit.LinaOneAbility1ThisProjectile 	= str
-- 	unit.LinaOneAbility1ThisTarget		= target

-- 	if caster.LinaOneAbility1MaJia == nil then
-- 		caster.LinaOneAbility1MaJia = {}
-- 	end

-- 	table.insert(caster.LinaOneAbility1MaJia,unit)

-- 	local teams = DOTA_UNIT_TARGET_TEAM_ENEMY
--     local types = DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO
--     local flags = DOTA_UNIT_TARGET_FLAG_NONE

--     local fire = true
--     local count = 0
    
-- 	GameRules:GetGameModeEntity():SetContextThink(str,
-- 		function( )
-- 			if count>=keys.count then
-- 				return nil
-- 			end


-- 			if unit.LinaOneAbility1Next then
-- 				local group = FindUnitsInRadius(caster:GetTeamNumber(),target:GetOrigin(),nil,keys.radius,teams,types,flags,FIND_CLOSEST,true)
				
-- 				local num = 0
-- 				for i=1,#group do
-- 					if group[i].LinaOneAbility1Impact == nil then
-- 						group[i].LinaOneAbility1Impact = {}
-- 					end

-- 					local impact = LinaOneAbility1FindImpact(group[i],str)

-- 					if  impact == false then
-- 						old_target = target
-- 						target = group[i]
-- 						fire = true
-- 						unit.LinaOneAbility1Next =false
-- 						unit.LinaOneAbility1ThisTarget = target
-- 						break
-- 					end
-- 					num = num + 1
-- 				end

-- 				if num >= #group then
-- 					TableRemoveTable(caster.LinaOneAbility1MaJia,unit)
-- 					return nil
-- 				end
-- 			end

-- 			if fire then
-- 				fire = false
-- 				count = count + 1
-- 				local info = 
-- 			    {
-- 			        Target = target,
-- 			        Source = old_target,
-- 			        Ability = keys.ability,  
-- 			        EffectName = "particles/units/heroes/hero_jakiro/jakiro_base_attack_fire.vpcf",
-- 			        bDodgeable = false,
-- 			        iMoveSpeed = 1100,
-- 			        bProvidesVision = true,
-- 			        iVisionRadius = 300,
-- 			        iVisionTeamNumber = caster:GetTeamNumber(),
-- 			        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
-- 			    }
-- 			    projectile = ProjectileManager:CreateTrackingProjectile(info)			    
-- 			end

-- 		    return 0.05
-- 		end,0)
-- end

-- function LinaOneAbility1FindImpact( unit,str )
	
-- 	for i,v in pairs(unit.LinaOneAbility1Impact) do
-- 		if v == str then
-- 			return true
-- 		end
-- 	end
-- 	return false
-- end

-- function LinaOneAbility1Impact( keys )
-- 	local caster = keys.caster
-- 	local target = keys.target

-- 	if target.LinaOneAbility1Impact == nil then
-- 		target.LinaOneAbility1Impact = {}
-- 	end

-- 	for i,v in pairs(caster.LinaOneAbility1MaJia) do
		
-- 		if v.LinaOneAbility1ThisProjectile ~= nil and v.LinaOneAbility1ThisTarget ~= nil then

-- 			if v.LinaOneAbility1ThisTarget == target then
-- 				table.insert(target.LinaOneAbility1Impact,v.LinaOneAbility1ThisProjectile)
-- 				v.LinaOneAbility1Next = true
-- 				return
-- 			end

-- 		end
-- 	end
-- end