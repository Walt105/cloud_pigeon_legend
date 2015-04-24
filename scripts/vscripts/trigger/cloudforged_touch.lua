

function OnStartTouch( trigger )
	local unit = trigger.activator

	CustomTimer(unit:GetUnitName(),function( )
		if unit._CloudIsWar == false then
			local newOrder = {
		        UnitIndex       = unit:entindex(),
		        OrderType       = DOTA_UNIT_ORDER_ATTACK_MOVE,
		        Position        = unit.spawnPoint + unit.spawnAngle*5, 
		        Queue           = 0
		    }
		    ExecuteOrderFromTable(newOrder)
		end
		return nil
	end,2)
end