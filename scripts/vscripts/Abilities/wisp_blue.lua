
function WispBlue1( keys )
	local caster = keys.caster
	local target = keys.target

	if target:IsHero() == false then return end

	target:Kill(nil,caster)
end