
function Spawn( val )
	print(thisEntity)
	SetAbilitiesLevelToOne(thisEntity)
	thisEntity:AddHateSystem()
	CAI:AutoCastAbility( thisEntity )
	CAI:AutoAttack( thisEntity )

	local war = false
	CustomTimer("ai_boss_millenary_treant",function( )
		
		if IsValidAndAlive(thisEntity) == true then
			if thisEntity._BossIsWar then
				war = true
			else
				if war then
					war = false
					local group = FindUnitsInRadius(thisEntity:GetTeamNumber(),thisEntity:GetOrigin(),nil,3000,DOTA_UNIT_TARGET_TEAM_FRIENDLY,DOTA_UNIT_TARGET_BASIC,DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS,FIND_CLOSEST,true)
					for k,v in pairs(group) do
						if IsValidAndAlive(v) then
							v:Kill(nil,nil)
						end
					end

					local ent = Entities:FindByName(nil,"first_boss_point")
					thisEntity:SetAbsOrigin(ent:GetAbsOrigin())
					thisEntity:SetHealth(thisEntity:GetMaxHealth())
					thisEntity:Stop()
				end
			end
		end

		return 1
	end,1)
end