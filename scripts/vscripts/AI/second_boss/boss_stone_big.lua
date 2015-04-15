

function Spawn( val )
	CAI:AutoAttack( thisEntity )

	CustomTimer(thisEntity:GetUnitName(),function( )
		local models = thisEntity:GetWearables()

		for k,v in pairs(models) do
			if v:GetModelName() == "models/heroes/tiny_01/tiny_01_right_arm.vmdl" then
				v:SetModel("models/items/tiny/scarletquarry_offhand_t2/scarletquarry_offhand_t2.vmdl")

			elseif v:GetModelName() == "models/heroes/tiny_01/tiny_01_left_arm.vmdl" then
				v:SetModel("models/items/tiny/scarletquarry_arms_t2/scarletquarry_arms_t2.vmdl")

			elseif v:GetModelName() == "models/heroes/tiny_01/tiny_01_body.vmdl" then
				v:SetModel("models/items/tiny/scarletquarry_armor_t2/scarletquarry_armor_t2.vmdl")

			elseif v:GetModelName() == "models/heroes/tiny_01/tiny_01_head.vmdl" then
				v:SetModel("models/items/tiny/scarletquarry_head_t2/scarletquarry_head_t2.vmdl")

			end
		end

		local newOrder = {
	        UnitIndex = thisEntity:entindex(), 
	        OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
	        Position = thisEntity:GetOrigin(), 
	        Queue = 0
	    }
	    ExecuteOrderFromTable(newOrder)

		return nil
	end,0.01)
end