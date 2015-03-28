
--[[
这里主要编写技能相关的函数
]]

-----------------------------------------------------------------------------------------------------------
--旋转单位
-----------------------------------------------------------------------------------------------------------
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
-----------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------
--同步技能等级
-----------------------------------------------------------------------------------------------------------
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
-----------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------
--增加或者减少modifier的数字
-----------------------------------------------------------------------------------------------------------
--Add增加modifier数量
--Low减少modifier数量
--count是数量
--remove的值随便填写个1，不填写就是不删除
function AddOrLowModifierCount( keys )
	local caster = keys.caster
	local ability = keys.ability
	local count = tonumber(keys.count)
	local modifierName = keys.modifierName

	if caster:HasModifier(modifierName) then
		local i = caster:GetModifierStackCount(modifierName,ability)
		if keys.AddOrLow == "Add" then
			caster:SetModifierStackCount(modifierName,keys.ability,i+count)
		end

		if keys.AddOrLow == "Low" then
			if i <= count then
				caster:SetModifierStackCount(modifierName,keys.ability,0)
				if keys.Remove then
					caster:RemoveModifierByName(modifierName)
				end
			else
				caster:SetModifierStackCount(modifierName,keys.ability,i-count)
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------
--弹射函数
-----------------------------------------------------------------------------------------------------------
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
-----------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------
--恢复生命值
-----------------------------------------------------------------------------------------------------------
function CDOTA_BaseNPC:CustomHeal( heal )
	self:SetHealth(self:GetHealth() + heal)
	local heal_num = #tostring(math.floor(heal))
    local particle = ParticleManager:CreateParticle("particles/msg_fx/msg_heal.vpcf",PATTACH_ABSORIGIN_FOLLOW,self)
    ParticleManager:SetParticleControl(particle,0,self:GetOrigin())
    ParticleManager:SetParticleControl(particle,1,Vector(10,heal,0))
    ParticleManager:SetParticleControl(particle,2,Vector(1,heal_num + 1,0))
    ParticleManager:SetParticleControl(particle,3,Vector(0,255,0))
    ParticleManager:ReleaseParticleIndex(particle)
end
-----------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------
--计时器
-----------------------------------------------------------------------------------------------------------
function CustomTimer( timerName,fun,delay )
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString(timerName),fun,delay)
end
-----------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------
--净化
-----------------------------------------------------------------------------------------------------------
GameRules.CustomPurgeTable = {}
GameRules.BossAbility = {}
function CustomPurgeInit( )
	local kv = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
	if kv then
		--此for获取技能
        for name,keys in pairs(kv) do
            if type(keys) == "table" then

            	--记录Boss技能
            	if keys.Boss == 1 then
            		GameRules.BossAbility[name] = keys
            	end
                
                --此for获取Modifiers
                for modifiers,mKeys in pairs(keys) do
                	if modifiers == "Modifiers" then
	                	--此for获取Modifiers里面的modifier
	                	for modifierName,modifierKeys in pairs(mKeys) do
	                		GameRules.CustomPurgeTable[modifierName]=modifierKeys
	                	end
                	end
                end
            end
        end
    end
end

function CDOTA_BaseNPC:CustomPurge( RemoveBuff,RemoveDebuff )
	print("----Run CustomPurge----")
	for i,v in pairs(GameRules.CustomPurgeTable) do
		if self:HasModifier(i) then
			if v.IsDebuff then
				print(v.IsDebuff,v.IsPurgable)
				if v.IsDebuff == 1 and v.IsPurgable == 1 and RemoveDebuff then
					self:RemoveModifierByName(i)
					print("Purge:"..i)
				end
			end
		end
	end
end


-----------------------------------------------------------------------------------------------------------
--增加攻击速度
-----------------------------------------------------------------------------------------------------------
function CDOTA_BaseNPC:AddAttackSpeed( attack_speed,dura )

	local ability = self:FindAbilityByName("common_ability")

	if ability then
		ability:ApplyDataDrivenModifier(self,self,"modifier_add_attack_speed_percent",{duration=tonumber(dura)})
		local speed = (self:GetAttackSpeed()*100 + 13) * attack_speed
		local num = self:GetModifierStackCount("modifier_add_attack_speed_percent",ability)
		self:SetModifierStackCount("modifier_add_attack_speed_percent",ability,num + tonumber(speed))
	end

end


-----------------------------------------------------------------------------------------------------------
--记录BOSS附近的单位
-----------------------------------------------------------------------------------------------------------
function BossIsWarCreated( keys )
	local target = keys.target
	target._BossIsWar = true
	local str = target:GetUnitName()
	PrintMsg("#BossIsWarCreated")
end

function BossIsWarDestroy( keys )
	local target = keys.target
	target._BossIsWar = false
	PrintMsg("#BossIsWarDestroy")
end

-----------------------------------------------------------------------------------------------------------
--Target不断向Caster靠近
-----------------------------------------------------------------------------------------------------------
function TargetMoveToCaster( Caster,Target,speed )
	print("Run TargetMoveToCaster")
	CustomTimer("TargetMoveToCaster",function( )

				if IsValidAndAlive(Caster) == false and IsValidAndAlive(Target) == false then
					return nil
				end

				--获取位置
				local Target_abs = Target:GetAbsOrigin()
				local Caster_abs = Caster:GetAbsOrigin()

				if (Caster_abs - Target_abs):Length()<=50 then
					print("TargetMoveToCaster over")
					return nil
				end

				--设置位置
				local face = (Caster_abs - Target_abs):Normalized()
				local vec = Target_abs + face * speed

				Target:SetAbsOrigin(vec)

				return 0.02
			end,0.0)
end

-----------------------------------------------------------------------------------------------------------
--判断技能的行为
-----------------------------------------------------------------------------------------------------------
GameRules.AbilityBehavior = {             
    DOTA_ABILITY_BEHAVIOR_ATTACK,            
    DOTA_ABILITY_BEHAVIOR_AURA,     
    DOTA_ABILITY_BEHAVIOR_AUTOCAST,    
    DOTA_ABILITY_BEHAVIOR_CHANNELLED,   
    DOTA_ABILITY_BEHAVIOR_DIRECTIONAL,    
    DOTA_ABILITY_BEHAVIOR_DONT_ALERT_TARGET,    
    DOTA_ABILITY_BEHAVIOR_DONT_CANCEL_MOVEMENT, 
    DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK,   
    DOTA_ABILITY_BEHAVIOR_DONT_RESUME_MOVEMENT,             
    DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING,    
    DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL,      
    DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE,   
    DOTA_ABILITY_BEHAVIOR_IGNORE_TURN ,        
    DOTA_ABILITY_BEHAVIOR_IMMEDIATE,         
    DOTA_ABILITY_BEHAVIOR_ITEM,              
    DOTA_ABILITY_BEHAVIOR_NOASSIST,            
    DOTA_ABILITY_BEHAVIOR_NONE,             
    DOTA_ABILITY_BEHAVIOR_NORMAL_WHEN_STOLEN, 
    DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE,       
    DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES,      
    DOTA_ABILITY_BEHAVIOR_RUNE_TARGET,         
    DOTA_ABILITY_BEHAVIOR_UNRESTRICTED ,  
}

--判断单体技能
function CDOTABaseAbility:IsUnitTarget( )
	local b = self:GetBehavior()

	if self:IsHidden() then b = b - 1 end
	for k,v in pairs(GameRules.AbilityBehavior) do
		repeat
			if v == 0 then break end
			b = b % v
		until true
	end

	if (b - DOTA_ABILITY_BEHAVIOR_AOE) == DOTA_ABILITY_BEHAVIOR_UNIT_TARGET then
		b = b - DOTA_ABILITY_BEHAVIOR_AOE
	end

	if b == DOTA_ABILITY_BEHAVIOR_UNIT_TARGET then
		return true
	end
	return false
end

--判断点目标技能
function CDOTABaseAbility:IsPoint( )
	local b = self:GetBehavior()

	if self:IsHidden() then b = b - 1 end
	for k,v in pairs(GameRules.AbilityBehavior) do
		repeat
			if v == 0 then break end
			b = b % v
		until true
	end

	if (b - DOTA_ABILITY_BEHAVIOR_AOE) == DOTA_ABILITY_BEHAVIOR_POINT then
		b = b - DOTA_ABILITY_BEHAVIOR_AOE
	end

	if b == DOTA_ABILITY_BEHAVIOR_POINT then
		return true
	end
	return false
end

--判断无目标技能
function CDOTABaseAbility:IsNoTarget( )
	local b = self:GetBehavior()

	if self:IsHidden() then b = b - 1 end
	for k,v in pairs(GameRules.AbilityBehavior) do
		repeat
			if v == 0 then break end
			b = b % v
		until true
	end

	if (b - DOTA_ABILITY_BEHAVIOR_AOE) == DOTA_ABILITY_BEHAVIOR_NO_TARGET then
		b = b % DOTA_ABILITY_BEHAVIOR_AOE
	end

	if b == DOTA_ABILITY_BEHAVIOR_NO_TARGET then
		return true
	end
	return false
end

