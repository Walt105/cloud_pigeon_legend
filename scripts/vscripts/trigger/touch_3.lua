
function Touch3OnStartTouch(trigger)
	local activator = trigger.activator
	table.insert( GameRules._touch3TriggerUnit,activator )
	GameRules._touch3TriggerNum = GameRules._touch3TriggerNum + 1
end
 
function Touch3OnEndTouch(trigger)
	local activator = trigger.activator

	if activator._Touch3OnEndTouch then
		activator._Touch3OnEndTouch = false
		return
	end

	if IsValidAndAlive(activator) == true or activator:IsNull() or activator:IsAlive() == false then
		GameRules._touch3TriggerNum = GameRules._touch3TriggerNum - 1
	end
end

function Touch3OnTrigger(  )
	PrintMsg("TriggerNum"..GameRules._touch3TriggerNum)

	for k,v in pairs(GameRules._touch3TriggerUnit) do
		repeat
		if v:IsNull() then TableRemoveTable(GameRules._touch3TriggerUnit,v) break end
		if IsValidEntity(v) then
			if v._Touch3OnEndTouch == nil then v._Touch3OnEndTouch = false end
			if v:IsHero() then
				if not v:IsAlive() and not v._Touch3OnEndTouch then
					v._Touch3OnEndTouch = true
					GameRules._touch3TriggerNum = GameRules._touch3TriggerNum - 1
				end
			end
		end
		until true
	end
end