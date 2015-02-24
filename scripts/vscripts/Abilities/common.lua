
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
