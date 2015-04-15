

function Spawn( val )

	thisEntity:AddHateSystem()
	CAI:AutoCastAbility( thisEntity )
	CAI:AutoAttack( thisEntity )

	CustomTimer(thisEntity:GetUnitName(),function( )
		local models = thisEntity:GetWearables()

		for k,v in pairs(models) do
			if v:GetModelName() == "models/heroes/tiny_01/tiny_01_right_arm.vmdl" then
				v:SetModel("models/items/tiny/scarletquarry_offhand_t4/scarletquarry_offhand_t4.vmdl")

			elseif v:GetModelName() == "models/heroes/tiny_01/tiny_01_left_arm.vmdl" then
				v:SetModel("models/items/tiny/scarletquarry_arms_t4/scarletquarry_arms_t4.vmdl")

			elseif v:GetModelName() == "models/heroes/tiny_01/tiny_01_body.vmdl" then
				v:SetModel("models/items/tiny/scarletquarry_armor_t4/scarletquarry_armor_t4.vmdl")

			elseif v:GetModelName() == "models/heroes/tiny_01/tiny_01_head.vmdl" then
				v:SetModel("models/items/tiny/scarletquarry_head_t4/scarletquarry_head_t4.vmdl")

			end
		end

		return nil
	end,0.01)

	local war = false
	CustomTimer(thisEntity:GetUnitName(),function( )
		
		if IsValidAndAlive(thisEntity) == true then
			if thisEntity._BossIsWar then
				war = true
			else
				if war then
					war = false
					-- local group = FindUnitsInRadius(thisEntity:GetTeamNumber(),thisEntity:GetOrigin(),nil,3000,DOTA_UNIT_TARGET_TEAM_FRIENDLY,DOTA_UNIT_TARGET_BASIC,DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS,FIND_CLOSEST,true)
					-- for k,v in pairs(group) do
					-- 	if IsValidAndAlive(v) then
					-- 		v:Kill(nil,nil)
					-- 	end
					-- end

					-- local ent = Entities:FindByName(nil,"first_boss_point")
					-- thisEntity:SetAbsOrigin(ent:GetAbsOrigin())
					thisEntity:SetHealth(thisEntity:GetMaxHealth())
					thisEntity:Stop()
				end
			end
		else
			GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
			return nil
		end

		return 1
	end,1)
end