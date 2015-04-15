
function OnStartTouch( trigger )
	local unit = trigger.activator

	local ent = Entities:FindByName(nil,"second_06")
	local ent2 = Entities:FindByName(nil,"second_02")
	for i=1,10 do
		local unit = CustomCreateUnit("boss_stone_big",ent:GetOrigin(),180,DOTA_TEAM_BADGUYS)
		
		CustomTimer("boss_stone_big",function( )
			local newOrder = {
		        UnitIndex = unit:entindex(), 
		        OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
		        Position = ent2:GetOrigin(), 
		        Queue = 0
		    }
		    ExecuteOrderFromTable(newOrder)
		    return nil
		end,1)
		
	end

	local majia = CustomCreateUnit("npc_majia",ent:GetOrigin(),270,DOTA_TEAM_GOODGUYS)
	majia:SetDayTimeVisionRange(1800)
	majia:SetNightTimeVisionRange(1800)
	table.insert( GameRules._RemoveMajia,majia )
end