

--自然之力
function WindrunnerOneAbility1( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if ability:GetAutoCastState() then
	else
		ability:ToggleAutoCast()

		CustomTimer("WindrunnerOneAbility1",function( )
			ability:ToggleAutoCast()
			return nil
		end,0.1)
	end

	--命令施法者攻击目标
	caster:SetAttacking(target)
	local newOrder = {
        UnitIndex = caster:entindex(), 
        TargetIndex = target:entindex(),
        OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
        Queue = 0
    }
    ExecuteOrderFromTable(newOrder)

end

function WindrunnerOneAbility1Unit( keys )
	local caster = keys.caster
	local target = keys.target

	--用于存储unit
	if caster.WindrunnerOneAbility1Unit == nil then
		caster.WindrunnerOneAbility1Unit = {}
	end

	--筛选目标
	local teams = DOTA_UNIT_TARGET_TEAM_FRIENDLY
    local types = DOTA_UNIT_TARGET_HERO
    local flags = DOTA_UNIT_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS
    local group = FindUnitsInRadius(caster:GetTeamNumber(),caster:GetOrigin(),nil,2000,teams,types,flags,FIND_CLOSEST,true)
    local hero  = group[RandomInt(1,#group)]
	local unit = {}
	table.insert( caster.WindrunnerOneAbility1Unit, unit )

	--记录
	unit.WindrunnerOneAbility1Damage = keys.DamageTaken
	unit.WindrunnerOneAbility1Target = hero

	--发射
	if IsValidEntity(hero) then
		if hero:IsAlive() then
			local info = 
		    {
		        Target = hero,
		        Source = target,
		        Ability = keys.ability,  
		        EffectName = "particles/units/heroes/hero_skywrath_mage/skywrath_mage_arcane_bolt.vpcf",
		        bDodgeable = false,
		        iMoveSpeed = 900,
		        bProvidesVision = true,
		        iVisionRadius = 300,
		        iVisionTeamNumber = caster:GetTeamNumber(),
		        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
		    }
		    projectile = ProjectileManager:CreateTrackingProjectile(info)
		end
	end
end

function WindrunnerOneAbility1Heal( keys )
	local caster = keys.caster
	local target = keys.target

	for i,v in ipairs(caster.WindrunnerOneAbility1Unit) do
		if v.WindrunnerOneAbility1Damage ~= nil and v.WindrunnerOneAbility1Target ~= nil then
			if v.WindrunnerOneAbility1Target == target then
				if IsValidEntity(target) then
					if target:IsAlive() then
						target:CustomHeal(v.WindrunnerOneAbility1Damage)
					end
				end
			end
		end
	end
	
end

--旋风
function WindrunnerOneAbility2( keys )
	local caster = keys.caster
	local duration = keys.duration
	local caster_abs = caster:GetOrigin()
	local face = caster:GetForwardVector()
	local angle_speed = keys.angle_speed
	local radius = keys.radius

	local num = keys.number
	local unit = {}
	for i=1,num do
		local vec = caster_abs + face*25
		local rota = RotatePosition(caster_abs,QAngle(0,(360/num)*i,0),vec) 
		unit[i] = CustomCreateUnit("npc_majia",rota,270,caster:GetTeamNumber())
		unit[i].WindrunnerOneAbility2=tostring(unit[i])
		unit[i]:SetOwner(caster)
		keys.ability:ApplyDataDrivenModifier(unit[i],unit[i],"modifier_windrunner_one_ability2",nil)

		local name = "particles/custom/heros/windrunner/windrunner_guardian.vpcf"
		local p = CustomCreateParticle(name,PATTACH_ABSORIGIN,unit[i],10,false,nil)

		--从25到radius
		RotateMotion( unit[i],caster,duration,25,radius,angle_speed,function( )
			local vec = unit[i]:GetAbsOrigin()+unit[i]:GetUpVector()*100
			ParticleManager:SetParticleControl(p,0,vec)
			ParticleManager:SetParticleControl(p,1,vec)
		end,function( )

			--返回来
			RotateMotion( unit[i],caster,duration,25,0,angle_speed,function( )
				local vec = unit[i]:GetAbsOrigin()+unit[i]:GetUpVector()*100
				ParticleManager:SetParticleControl(p,0,vec)
				ParticleManager:SetParticleControl(p,1,vec)
			end,function( )
				ParticleManager:DestroyParticle(p,false)
				unit[i]:Kill(nil,nil)
			end )
		end )
	end
end

function WindrunnerOneAbility2Effect( keys )
	local caster = keys.caster
	local group = keys.target_entities

	local s = ""
	local str = caster.WindrunnerOneAbility2 or ""

	for k,v in pairs(group) do
		if IsValidAndAlive(v) == true then
			repeat
			if v:IsAncient() then break end
			if v:GetUnitName()=="npc_majia" then break end
			s = tostring(v)
			if string.find(str,s) == nil then
				caster.WindrunnerOneAbility2 = caster.WindrunnerOneAbility2..s
				if v:IsOpposingTeam(caster:GetTeamNumber()) then
					keys.ability:ApplyDataDrivenModifier(caster:GetOwner(),v,"modifier_windrunner_one_ability2_damage",nil)
				else
					keys.ability:ApplyDataDrivenModifier(caster:GetOwner(),v,"modifier_windrunner_one_ability2_heal",nil)
				end
			end
			until true
		end
	end
	
end


--轻盈
function WindrunnerOneAbility4( keys )
	local caster = keys.caster
	local ability = keys.ability
	local num = caster:GetModifierStackCount("modifier_windrunner_one_ability4",ability)

	if num<keys.move_speed_max then
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_windrunner_one_ability4_effect",nil)
	end
end


--疾影
function WindrunnerOneAbility5Created( keys )
	local caster = keys.caster
	local ability = keys.ability

	if ability:IsCooldownReady() == false then
		caster:RemoveModifierByName("modifier_windrunner_one_ability5")
	end
end

function WindrunnerOneAbility5Remove( keys )
	local caster = keys.caster
	local ability = keys.ability
	local time = ability:GetCooldown(ability:GetLevel() - 1)

	ability:StartCooldown(time)
	caster:RemoveModifierByName("modifier_windrunner_one_ability5")

	CustomTimer("WindrunnerOneAbility5Remove",function( )
		
		if IsValidEntity(caster) then
			if caster:IsAlive() then
				ability:ApplyDataDrivenModifier(caster,caster,"modifier_windrunner_one_ability5",nil)
			end
		end

		return nil
	end,time + 0.1)
end


--神箭
function WindrunnerOneAbility6( keys )
	local caster = keys.caster
	local target = keys.target
	local count = keys.count
	local ability = keys.ability

	if caster.WindrunnerOneAbility6Unit == nil then
		caster.WindrunnerOneAbility6Unit = {}
	end

	local old_target = caster

	--生成独立的字符串
	local str = DoUniqueString(ability:GetAbilityName())

	--假设一个马甲
	local unit = {}

	--绑定信息
	--是否发射下一个投射物
	unit.WindrunnerOneAbility6Next = false

	--本次弹射标识的字符串
	unit.WindrunnerOneAbility6Projectile = str

	--本次弹射的目标
	unit.WindrunnerOneAbility6Target = target

	--把unit插入CatapultUnit
	table.insert(caster.WindrunnerOneAbility6Unit,unit)

	--用于决定是否发射投射物
    local fire = true

    --弹射最大次数
    local count_num = 0
    
	CustomTimer(str,
		function( )

			--满足达到最大弹射次数删除计时器
			if count_num>=count then
				TableRemoveTable(caster.WindrunnerOneAbility6Unit,unit)
				return nil
			end

			if unit.WindrunnerOneAbility6Next then
				unit.WindrunnerOneAbility6Next = false

				local teams = DOTA_UNIT_TARGET_TEAM_BOTH
			    local types = DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO
			    local flags = DOTA_UNIT_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES

			    if IsValidAndAlive(target)=="Not Valid" then return nil end
			    local group = FindUnitsInRadius(caster:GetTeamNumber(),target:GetOrigin(),nil,1000,teams,types,flags,FIND_UNITS_EVERYWHERE,true)

			    TableRemoveTable(group,target)

			    local num = #group
			    if num <= 0 then
			    	TableRemoveTable(caster.WindrunnerOneAbility6Unit,unit)
			    	return nil
			    end

			    old_target = target

			    while true do
			    	target = group[RandomInt(1,num)]
			    	if IsValidEntity(target) then
			    		if target:IsAlive() then
			    			unit.WindrunnerOneAbility6Target = target
			    			break
			    		end
			    	end
			    	TableRemoveTable(group,target)
			    	num = #group
			    	if num <= 0 then TableRemoveTable(caster.WindrunnerOneAbility6Unit,unit) return nil end
			    end

			    fire = true
			end

			--发射投射物
			if fire then
				fire = false
				count_num = count_num + 1
				local info = 
			    {
			        Target = target,
			        Source = old_target,
			        Ability = ability,  
			        EffectName = "particles/units/heroes/hero_enchantress/enchantress_impetus.vpcf",
			        bDodgeable = false,
			        iMoveSpeed = 1100,
			        bProvidesVision = true,
			        iVisionRadius = 300,
			        iVisionTeamNumber = caster:GetTeamNumber(),
			        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
			    }
			    projectile = ProjectileManager:CreateTrackingProjectile(info)	
			    EmitSoundOn("Ability.Powershot.Alt",old_target)		    
			end

		    return 0.05
		end,0)
end

function WindrunnerOneAbility6Impact( keys )
	local caster = keys.caster
	local target = keys.target

	--防止意外
	if caster.WindrunnerOneAbility6Unit == nil then
		caster.WindrunnerOneAbility6Unit = {}
	end
	if target.WindrunnerOneAbility6Impact == nil then
		target.WindrunnerOneAbility6Impact = {}
	end

	--挨个检测是否是弹射的目标
	for i,v in pairs(caster.WindrunnerOneAbility6Unit) do
		
		if v.WindrunnerOneAbility6Projectile ~= nil and v.WindrunnerOneAbility6Target ~= nil then

			if v.WindrunnerOneAbility6Target == target then

				--标记target被CatapultThisProjectile命中
				table.insert(target.WindrunnerOneAbility6Impact,v.WindrunnerOneAbility6Projectile)

				--允许发射下一次投射物
				v.WindrunnerOneAbility6Next = true

				if target:IsOpposingTeam(caster:GetTeamNumber()) then
					--造成伤害
					local t = {	target = target,
								caster = caster,
								damage = keys.damage,
								damage_type = keys.damage_type}
					local damage = DamageTarget(t)
				else
					target:CustomHeal(keys.damage)
				end
				return
			end

		end
	end
end