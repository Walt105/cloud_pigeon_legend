

function Spawn( val )

	CustomTimer(thisEntity:GetUnitName(),function( )
		local models = thisEntity:GetWearables()

		for k,v in pairs(models) do
			if v:GetModelName() == "models/heroes/tiny_01/tiny_01_right_arm.vmdl" then
				v:SetModel("models/items/tiny/scarletquarry_offhand/scarletquarry_offhand.vmdl")

			elseif v:GetModelName() == "models/heroes/tiny_01/tiny_01_left_arm.vmdl" then
				v:SetModel("models/items/tiny/scarletquarry_arms/scarletquarry_arms.vmdl")

			elseif v:GetModelName() == "models/heroes/tiny_01/tiny_01_body.vmdl" then
				v:SetModel("models/items/tiny/scarletquarry_armor/scarletquarry_armor.vmdl")

			elseif v:GetModelName() == "models/heroes/tiny_01/tiny_01_head.vmdl" then
				v:SetModel("models/items/tiny/scarletquarry_head/scarletquarry_head.vmdl")

			end
		end

		return nil
	end,0.01)

	CustomTimer(thisEntity:GetUnitName(),function( )
		
		if IsValidEntity(thisEntity) then
			if thisEntity:IsAlive() then

				local new = thisEntity:GetOrigin()
				if new == old then
					local range = 200
					local vec = new + Vector(RandomFloat(-range,range),RandomFloat(-range,range),RandomFloat(-range,range))
					local newOrder = {
				        UnitIndex = thisEntity:entindex(), 
				        OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
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