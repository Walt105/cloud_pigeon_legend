

function OnStartTouch( trigger )
	local unit = trigger.activator

	if unit:GetUnitName() == "npc_first_boss_super_treant" then
		if IsValidAndAlive(unit) then
			local ent = Entities:FindByName(nil,"first_boss_super_treant")
			unit:SetAbsOrigin(ent:GetAbsOrigin())
			unit:Stop()
		end
	end
end