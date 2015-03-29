
function Spawn( val )
	print(thisEntity)
	SetAbilitiesLevelToOne(thisEntity)
	thisEntity:AddHateSystem()
	CAI:AutoCastAbility( thisEntity )
	CAI:AutoAttack( thisEntity )
end