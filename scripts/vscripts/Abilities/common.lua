
--target绕着caster旋转
--len:int,是距离
--angle:int,是旋转角度
--interval:float,是旋转间隔
--dura:float,是持续时间
--f:bool,表示顺时针还是逆时针,true为顺时针
function RotateTargetToCaster( caster,targets,len,angle,interval,dura,f )

	if f then
		angle = -angle
	end

	local target_num = #targets
	local time = 0
	local angle_add = angle
	angle = 0
	local caster_face = caster:GetForwardVector()
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("TargetRotateCaster"),
		function( )
			time = time + interval
			if time>dura then
				return nil
			end

			local caster_abs = caster:GetAbsOrigin()
			local face = caster_abs + caster_face * 400
			for i=1,target_num do
				local vec = RotatePosition(caster_abs,QAngle(0,(360/target_num)*i+angle,0),face)

				if IsValidEntity(targets[i]) then
					targets[i]:SetAbsOrigin(vec)
				end
			end

			angle = angle + angle_add

			return interval
		end,0)
end


--同步技能等级
function SyncAbilityLevel( keys )
	local caster = keys.caster

	--获取要同步的技能的名称
	local abilityName = keys.abilityName or false

	if abilityName then
		if type(abilityName) == "string" then

			--获取要同步的技能
			local ability1 = keys.ability
			local ability2 = caster:FindAbilityByName(abilityName)

			--获取技能等级
			local lvl_1 = ability1:GetLevel()
			local lvl_2 = ability2:GetLevel()

			if lvl_1 ~= lvl_2 then

				--同步等级大的技能
				local lvl = 0
				if lvl_1 > lvl_2 then
					lvl = lvl_1
				else
					lvl = lvl_2
				end

				--设置技能等级
				ability2:SetLevel(lvl)
			end

		end
	end
end

--弹射函数
--用于检测是否被此次弹射命中过
function CatapultFindImpact( unit,str )
	for i,v in pairs(unit.CatapultImpact) do
		if v == str then
			return true
		end
	end
	return false
end

--caster是施法者或者主要来源
--target是第一个目标
--ability是技能来源
--effectName是弹射的投射物
--move_speed是投射物的速率
--doge是表示能否被躲掉
--radius是每次弹射的范围
--count是弹射次数
--teams,types,flags获取单位的三剑客
--find_tpye是单位组按远近或者随机排列
--		FIND_CLOSEST
--      FIND_FARTHEST
--      FIND_UNITS_EVERYWHERE
function Catapult( caster,target,ability,effectName,move_speed,radius,count,teams,types,flags,find_tpye )
	print("Run Catapult")

	local old_target = caster

	--生成独立的字符串
	local str = DoUniqueString(ability:GetAbilityName())
	print("Catapult:"..str)

	--假设一个马甲
	local unit = {}

	--绑定信息
	--是否发射下一个投射物
	unit.CatapultNext = false

	--本次弹射标识的字符串
	unit.CatapultThisProjectile = str

	--本次弹射的目标
	unit.CatapultThisTarget		= target

	--CatapultUnit用来存储unit
	if caster.CatapultUnit == nil then
		caster.CatapultUnit = {}
	end

	--把unit插入CatapultUnit
	table.insert(caster.CatapultUnit,unit)

	--用于决定是否发射投射物
    local fire = true

    --弹射最大次数
    local count_num = 0
    
	GameRules:GetGameModeEntity():SetContextThink(str,
		function( )

			--满足达到最大弹射次数删除计时器
			if count_num>=count then
				print("Catapult impact :"..count_num)
				print("Catapult:"..str.." is over")
				return nil
			end


			if unit.CatapultNext then

				--获取单位组
				local group = FindUnitsInRadius(caster:GetTeamNumber(),target:GetOrigin(),nil,radius,teams,types,flags,FIND_CLOSEST,true)
				
				--用于计算循环次数
				local num = 0
				for i=1,#group do
					if group[i].CatapultImpact == nil then
						group[i].CatapultImpact = {}
					end

					--判断是否命中
					local impact = CatapultFindImpact(group[i],str)

					if  impact == false then

						--替换old_target
						old_target = target

						--新target
						target = group[i]

						--可以发射新投射物
						fire = true

						--等待下一个目标
						unit.CatapultNext =false

						--锁定当前目标
						unit.CatapultThisTarget = target
						break
					end
					num = num + 1
				end

				--如果大于等于单位组的数量那么就删除计时器
				if num >= #group then
					--从CatapultUnit中删除unit
					TableRemoveTable(caster.CatapultUnit,unit)

					print("Catapult impact :"..count_num)
					print("Catapult:"..str.." is over")
					return nil
				end
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
			        EffectName = effectName,
			        bDodgeable = false,
			        iMoveSpeed = move_speed,
			        bProvidesVision = true,
			        iVisionRadius = 300,
			        iVisionTeamNumber = caster:GetTeamNumber(),
			        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
			    }
			    projectile = ProjectileManager:CreateTrackingProjectile(info)			    
			end

		    return 0.05
		end,0)
end

--此函数在KV里面用OnProjectileHitUnit调用
function CatapultImpact( keys )
	local caster = keys.caster
	local target = keys.target

	--防止意外
	if caster.CatapultUnit == nil then
		caster.CatapultUnit = {}
	end
	if target.CatapultImpact == nil then
		target.CatapultImpact = {}
	end

	--挨个检测是否是弹射的目标
	for i,v in pairs(caster.CatapultUnit) do
		
		if v.CatapultThisProjectile ~= nil and v.CatapultThisTarget ~= nil then

			if v.CatapultThisTarget == target then

				--标记target被CatapultThisProjectile命中
				table.insert(target.CatapultImpact,v.CatapultThisProjectile)

				--允许发射下一次投射物
				v.CatapultNext = true
				return
			end

		end
	end
end
