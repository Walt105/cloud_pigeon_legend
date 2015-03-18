
--[[
这里主要编写通用的函数
]]


--发送消息
function PrintMsg( str )
	GameRules:SendCustomMessage(tostring(str),2,0)
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
