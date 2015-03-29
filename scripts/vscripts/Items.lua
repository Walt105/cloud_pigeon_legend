
function PayAbilityPoint( keys )
	local caster = keys.caster
	local point = keys.point or 1

	caster:SetAbilityPoints(caster:GetAbilityPoints() + point)
end