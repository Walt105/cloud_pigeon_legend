
--[[
这里主要编写通用的函数
]]


--发送消息
function PrintMsg( str )
	GameRules:SendCustomMessage(tostring(str),2,0)
end

--判断游戏是否暂停
function GamePaused()
	old = GameRules:GetGameTime()
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("GamePaused"),function( )
		local new = GameRules:GetGameTime()

		if new == old then
			GameRules._IsGamePaused = true
		else
			GameRules._IsGamePaused = false
		end
		old = new

		return 0.1
	end,0)
end

--删除table中的table
function TableRemoveTable( table_1 , table_2 )
	for i,v in pairs(table_1) do
		if v == table_2 then
			table.remove(table_1,i)
			return i
		end
	end
	return false
end

--寻找table
function FindTableToTable( table_1 , table_2 )
	for k,v in pairs(table_1) do
		if v == table_2 then
			return true
		end
	end
	return false
end

--停止播放音效
function StopSound( keys )
	StopSoundEvent(keys.EffectName,keys.caster)
end

--显示暴击数字
function CriticalStrikeMsg( npc, num, color )

	local colorNum = #color
	if colorNum ~= 3 then
		color = {255,255,255}
	end

	local particleName = "particles/msg_fx/msg_crit.vpcf"
	local p = ParticleManager:CreateParticle(particleName,PATTACH_CUSTOMORIGIN_FOLLOW,npc)
	ParticleManager:SetParticleControl(p,0,npc:GetOrigin())
	ParticleManager:SetParticleControl(p,1,Vector(10,num,4))
	ParticleManager:SetParticleControl(p,2,Vector(1,(#tostring(num))+1,0))
	ParticleManager:SetParticleControl(p,3,Vector(color[1],color[2],color[3]))
end


--创建单位
function CustomCreateUnit( unitName,vec,angle,teamNumer )
	local unit = CreateUnitByName(tostring(unitName),vec,false,nil,nil,teamNumer)
	unit:SetAngles(0,angle,0)
	unit:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})

	--如果是DOTA_TEAM_BADGUYS单位根据玩家人数设置基础难度
	if teamNumer == DOTA_TEAM_BADGUYS and unitName ~= "npc_majia" then

		local ability_player_difficulty = GameRules.Majia:FindAbilityByName("common_ability")
		if ability_player_difficulty then
			local modifierName = "modifier_player_difficulty"
			ability_player_difficulty:ApplyDataDrivenModifier(unit,unit,modifierName,nil)
			unit:SetModifierStackCount(modifierName,ability_player_difficulty,GameRules.PlayerNum)
		end
	end

	return unit
end

--判断实体有效
function IsValidAndAlive( unit )
	if IsValidEntity(unit) then
		if unit:IsAlive() then
			return true
		else
			return false
		end
	else
		return "Not Valid"
	end
	
end

--复活英雄
function CustomRespawnHero( )
	if GameRules._IsRespawn then
		CustomTimer("CustomRespawnHero",function( )
			for k,v in pairs(GameRules._PlayerHeroes) do
				if IsValidAndAlive(v) == false then
					v:RespawnHero(true,true,true)
					v:SetAbsOrigin(GameRules._HeroRespawn:GetOrigin())
					FindClearSpaceForUnit(v,v:GetOrigin(),true)
				end
			end
			return nil
		end,3)
	end
end


-------------------------------------------------------
--对施法选择器进行分割
BOSSCASTABILITYSELECT_MAX_HEAL = 1 						--选取生命值最大的
BOSSCASTABILITYSELECT_MIN_HEAL = 2 						--选取生命值最小的
BOSSCASTABILITYSELECT_HATESYSTEM_MAX = 3				--选取仇恨最高的
BOSSCASTABILITYSELECT_HATESYSTEM_MIN = 4				--选取仇恨最低的
BOSSCASTABILITYSELECT_Random   = 5						--随机选取

BOSSCASTABILITYSELECT_EXTRA_MELEE = 100					--选取近战
BOSSCASTABILITYSELECT_EXTRA_RANGE = 200					--选取远程

--储存常量
GameRules.BossCastAbilitySelect = {
	BOSSCASTABILITYSELECT_EXTRA_MELEE,
	BOSSCASTABILITYSELECT_EXTRA_RANGE,
}

--匹配常量
function FindBossCastAbilitySelect( str )
	if str == "BOSSCASTABILITYSELECT_MAX_HEAL" then
		return BOSSCASTABILITYSELECT_MAX_HEAL

	elseif str == "BOSSCASTABILITYSELECT_MIN_HEAL" then
		return BOSSCASTABILITYSELECT_MIN_HEAL

	elseif str == "BOSSCASTABILITYSELECT_HATESYSTEM_MAX" then
		return BOSSCASTABILITYSELECT_HATESYSTEM_MAX

	elseif str == "BOSSCASTABILITYSELECT_HATESYSTEM_MIN" then
		return BOSSCASTABILITYSELECT_HATESYSTEM_MIN
		
	elseif str == "BOSSCASTABILITYSELECT_Random" then
		return BOSSCASTABILITYSELECT_Random

	elseif str == "BOSSCASTABILITYSELECT_EXTRA_MELEE" then
		return BOSSCASTABILITYSELECT_EXTRA_MELEE

	elseif str == "BOSSCASTABILITYSELECT_EXTRA_RANGE" then
		return BOSSCASTABILITYSELECT_EXTRA_RANGE

	end

	return 0
end

--合计常量值
function FindBossCastAbilityUnit( str_t )
	if str_t then
		local sl = 0
		for k,v in pairs(str_t) do
			sl = sl + FindBossCastAbilitySelect(v)
		end
		return sl
	end
	return false
end

--取得常量
function GetBossCastAbilitySelect( i )
	for k,v in pairs(GameRules.BossCastAbilitySelect) do
		repeat
			if v == 0 then break end
			i = i % v
		until true
	end
	return i
end

--分割字符串
function BossCastStringSplit(str)
	local _s1 = {}
	local _s2 = {}
	local len = string.len(str)

	for i=1,len do
		local c = string.sub(str,i,i)
		table.insert( _s1,c )
	end

	local i = 0
	local s = ""
	local a = string.byte("a")
	local A = string.byte("A")
	local z = string.byte("z")
	local Z = string.byte("Z")

	for k,v in pairs(_s1) do
		local j = string.byte(v)

		if (j >= a and j <= z) or ( j >= A and j <= Z ) or j == string.byte("_") then
			s = s..v
		else
			if s ~= "" then table.insert( _s2,s ); s = "" end
		end
	end
	table.insert( _s2,s )

	return _s2;
end


-------------------------------------------------------
--设所有技能等级为1
function SetAbilitiesLevelToOne( unit )
	local num = unit:GetAbilityCount() - 1
	for i=0,num do
		local ability = unit:GetAbilityByIndex(i)
		if ability then
			ability:SetLevel(1)
		end
	end
end



