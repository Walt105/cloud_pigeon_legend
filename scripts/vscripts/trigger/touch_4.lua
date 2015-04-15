
function OnStartTouch( trigger )
	local unit = trigger.activator

	if unit:GetUnitName() == "boss_stone" then
		if IsValidAndAlive(unit) then
			local ent = Entities:FindByName(nil,"second_boss")
			unit:SetAbsOrigin(ent:GetAbsOrigin())
			unit:Stop()
		end
	end
end