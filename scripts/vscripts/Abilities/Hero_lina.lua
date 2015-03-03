

--弹跳火球
function LinaOneAbility1( keys )
	local caster = keys.caster
	local target = keys.target
	local old_target = caster

	local str = DoUniqueString("LinaOneAbility1")
	print(str)

	local unit = CreateUnitByName("npc_majia",caster:GetOrigin(),false,nil,nil,caster:GetTeamNumber())
	unit.LinaOneAbility1Next = false
	unit.LinaOneAbility1ThisProjectile 	= str
	unit.LinaOneAbility1ThisTarget		= target

	if caster.LinaOneAbility1MaJia == nil then
		caster.LinaOneAbility1MaJia = {}
	end

	table.insert(caster.LinaOneAbility1MaJia,unit)

	local teams = DOTA_UNIT_TARGET_TEAM_ENEMY
    local types = DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO
    local flags = DOTA_UNIT_TARGET_FLAG_NONE

    local fire = true
    local num = 0
	GameRules:GetGameModeEntity():SetContextThink(str,
		function( )

			if unit.LinaOneAbility1Next then
				local group = FindUnitsInRadius(caster:GetTeamNumber(),target:GetOrigin(),nil,600,teams,types,flags,FIND_CLOSEST,true)

				for i=1,#group do
					if group[i].LinaOneAbility1Impact == nil then
						group[i].LinaOneAbility1Impact = {}
					end
					if LinaOneAbility1FindImpact(group[i],str) == false then
						old_target = target
						target = group[i]
						fire = true
						unit.LinaOneAbility1Next =false
						unit.LinaOneAbility1ThisTarget = target
						break
					end
				end

				if unit.LinaOneAbility1ThisTarget == target then
					PrintMsg(num)
					PrintMsg("over")
					TableRemoveTable(caster.LinaOneAbility1MaJia,unit)
					unit:RemoveSelf()
					return nil
				end
			end

			if fire then
				fire = false
				local info = 
			    {
			        Target = target,
			        Source = old_target,
			        Ability = keys.ability,  
			        EffectName = "particles/units/heroes/hero_jakiro/jakiro_base_attack_fire.vpcf",
			        bDodgeable = false,
			        iMoveSpeed = 1100,
			        bProvidesVision = true,
			        iVisionRadius = 300,
			        iVisionTeamNumber = caster:GetTeamNumber(),
			        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
			    }
			    projectile = ProjectileManager:CreateTrackingProjectile(info)
			    num = num + 1
			end

		    return 0.05
		end,0)
end

function LinaOneAbility1FindImpact( unit,str )
	
	for i,v in pairs(unit.LinaOneAbility1Impact) do
		if v == str then
			return true
		end
	end
	return false
end

function LinaOneAbility1Impact( keys )
	local caster = keys.caster
	local target = keys.target

	if target.LinaOneAbility1Impact == nil then
		target.LinaOneAbility1Impact = {}
	end

	print("LinaOneAbility1Impact")
	for i,v in pairs(caster.LinaOneAbility1MaJia) do
		
		if v.LinaOneAbility1ThisProjectile ~= nil and v.LinaOneAbility1ThisTarget ~= nil then

			if v.LinaOneAbility1ThisTarget == target then
				table.insert(target.LinaOneAbility1Impact,v.LinaOneAbility1ThisProjectile)
				print("target.."..v.LinaOneAbility1ThisProjectile)
				v.LinaOneAbility1Next = true
				return
			end

		end
	end
end