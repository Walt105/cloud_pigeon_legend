
function OnStartTouch( trigger )
	local unit = trigger.activator

	if unit:GetUnitName() == "boss_millenary_treant" then
		if IsValidAndAlive(unit) then
			local ent = Entities:FindByName(nil,"first_boss_point")
			unit:SetAbsOrigin(ent:GetAbsOrigin())
			unit:SetHealth(unit:GetMaxHealth())
			unit:Stop()
		end
	end
end