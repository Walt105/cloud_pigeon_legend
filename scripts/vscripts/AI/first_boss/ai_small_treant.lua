

function Spawn( val )
	local old = thisEntity:GetOrigin()
	CustomTimer("ai_small_treant",function( )
		
		if IsValidEntity(thisEntity) then
			if thisEntity:IsAlive() then

				local new = thisEntity:GetOrigin()
				if new == old then
					local range = 200
					local vec = new + Vector(RandomFloat(-range,range),RandomFloat(-range,range),RandomFloat(-range,range))
					local newOrder = {
				        UnitIndex = thisEntity:entindex(), 
				        OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
				        Position = vec, 
				        Queue = 0
				    }
				    ExecuteOrderFromTable(newOrder)
				end

				old = new
				return 0.9
			else
				return nil
			end
		else
			return nil
		end
	end,0.9)
end