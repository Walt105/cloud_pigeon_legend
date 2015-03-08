
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
			return
		end
	end
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
