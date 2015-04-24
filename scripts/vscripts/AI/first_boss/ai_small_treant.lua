

function Spawn( val )
	local ent = Entities:FindByName(nil,"first_boss_treant_over")
	local ent_abs = ent:GetAbsOrigin()
	thisEntity._turn = false
	local turn = false
	CustomTimer("ai_small_treant",function( )
		
		if IsValidAndAlive(thisEntity)~=true then
			return nil
		end

		if (ent_abs - thisEntity:GetAbsOrigin()):Length()>100 and thisEntity._turn == false then
			local newOrder = {
		        UnitIndex = thisEntity:entindex(), 
		        OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
		        Position = ent_abs, 
		        Queue = 0
		    }
		    ExecuteOrderFromTable(newOrder)
		end

		if thisEntity._turn then
			if not turn and IsValidAndAlive(GameRules._npc_cloudforged)==true then
				turn = not turn

				local name = nil
				if RollPercentage(70) then
					name = "cloudforged"
				else
					name = "cloudforgedwing"
				end
				ent = Entities:FindByName(nil,name)
				ent_abs = ent:GetAbsOrigin()

			elseif IsValidAndAlive(GameRules._npc_cloudforged)~=true and not turn then
				turn = not turn
				ent = Entities:FindByName(nil,"cloudforgedwing")
				ent_abs = ent:GetAbsOrigin()
			elseif IsValidAndAlive(GameRules._npc_cloudforged)~=true and turn then
				turn = not turn
				ent = Entities:FindByName(nil,"cloudforgedwing")
				ent_abs = ent:GetAbsOrigin()
			end

			local newOrder = {
		        UnitIndex = thisEntity:entindex(), 
		        OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
		        Position = ent_abs, 
		        Queue = 0
		    }
		    ExecuteOrderFromTable(newOrder)
		end

		return 3
	end,1)
end