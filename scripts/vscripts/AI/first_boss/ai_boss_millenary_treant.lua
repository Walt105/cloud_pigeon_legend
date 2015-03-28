
function Spawn( val )
	print(thisEntity)
	SetAbilitiesLevelToOne(thisEntity)
	
	CAI:AutoCastAbility( thisEntity )
	thisEntity:AddHateSystem()
end