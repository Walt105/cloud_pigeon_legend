

function Spawn( val )
	local unitName = thisEntity:GetUnitName()

	CustomTimer(unitName,function( )
		
		thisEntity.spawnPoint = thisEntity:GetAbsOrigin()
		thisEntity.spawnAngle = thisEntity:GetForwardVector()
		local old = thisEntity.spawnPoint
		local new = thisEntity.spawnPoint
		local back = true

		CustomTimer(unitName,function( )

			if IsValidAndAlive(thisEntity) ~= true then
				if unitName == "npc_cloudpigeon" then
					GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
				end
				return nil
			end
			
			new = thisEntity:GetAbsOrigin()

			if thisEntity._CloudIsWar == false and back==true and (new - thisEntity.spawnPoint):Length()>100 then 
				local newOrder = {
			        UnitIndex       = thisEntity:entindex(),
			        OrderType       = DOTA_UNIT_ORDER_ATTACK_MOVE,
			        Position        = thisEntity.spawnPoint, 
			        Queue           = 0
			    }
			    ExecuteOrderFromTable(newOrder)
			    back = false

			elseif thisEntity._CloudIsWar == true then
				back = true
			end

			old = new
			return 0.2
		end,0)

		-- CustomTimer(unitName,function( )
		-- 	thisEntity:SetCustomHealthLabel( "#"..unitName, 0, 255, 0 )
		-- 	return nil
		-- end,15)

		return nil
	end,1)

		
end