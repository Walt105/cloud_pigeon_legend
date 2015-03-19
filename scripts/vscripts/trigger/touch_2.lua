
function Touch2OnStartTouch(trigger)
	local activator = trigger.activator
	table.insert( GameRules._touch2TriggerUnit,activator )
	GameRules._touch2TriggerNum = GameRules._touch2TriggerNum + 1
end
 
function Touch2OnEndTouch(trigger)
	local activator = trigger.activator

	if activator._Touch2OnEndTouch then
		activator._Touch2OnEndTouch = false
		return
	end

	if IsValidAndAlive(activator) == true or activator:IsNull() or activator:IsAlive() == false then
		GameRules._touch2TriggerNum = GameRules._touch2TriggerNum - 1
	end
end

function Touch2OnTrigger(  )
	--PrintMsg("TriggerNum"..GameRules._touch2TriggerNum)

	for k,v in pairs(GameRules._touch2TriggerUnit) do
		repeat
		if v:IsNull() then TableRemoveTable(GameRules._touch2TriggerUnit,v) break end
		if IsValidEntity(v) then
			if v._Touch2OnEndTouch == nil then v._Touch2OnEndTouch = false end
			if v:IsHero() then
				if not v:IsAlive() and not v._Touch2OnEndTouch then
					v._Touch2OnEndTouch = true
					GameRules._touch2TriggerNum = GameRules._touch2TriggerNum - 1
				end
			end
		end
		until true
	end
end