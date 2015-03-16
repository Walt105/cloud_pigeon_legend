

function Spawn( val )
	thisEntity:AddHateSystem()

	CustomTimer("ai_super_treant",function( )

		if IsValidAndAlive(thisEntity) then else
			return nil
		end

		if thisEntity.BossFindUnitNum then
			if thisEntity.BossFindUnitNum > 0 then
				local target = thisEntity:GetHateSystemMaxHero()
				if target ~= nil then
					local newOrder = {
				        UnitIndex = thisEntity:entindex(), 
				        TargetIndex = target:entindex(),
				        OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
				        Queue = 0
				    }
				    ExecuteOrderFromTable(newOrder)
				end
			end
		end

		return 1
	end,1)
end