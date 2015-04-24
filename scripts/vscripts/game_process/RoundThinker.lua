if CRoundThinker == nil then
	CRoundThinker = class({})
end

--初始化
function CRoundThinker:Init( nextTime,unitsName,count,interval,spawnPoints,testRound,team,thinkTitle,unitTitle )
	self._currentRound = testRound
	self._unitsName = unitsName
	self._maxRound = #unitsName
	self._count = count
	self._spawnPoints = spawnPoints
	self._nextTime = nextTime
	self._interval = interval
	self._teamNumber = team
	self._currentTime = 0
	self._thinkBar = nil
	self._thinkTitle = nil
	self._currentUnitCount = 0
	self._currentUnitTitle = nil
	self._currentUnitBar = nil
	self._thinkTitleName = thinkTitle
	self._unitTitleName = unitTitle
end

--开启新的一波
function CRoundThinker:Start( )
	if self._currentRound >= self._maxRound then
		return
	end

	self._currentTime = self._nextTime
	
	self._thinkTitle  = SpawnEntityFromTableSynchronous( "quest", {
        name = self._unitsName[self._currentRound],
        title =  self._thinkTitleName..self._currentRound
    })
    self._thinkTitle:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_ROUND,self._currentRound)

    self._thinkBar = SpawnEntityFromTableSynchronous( "subquest_base", {
        show_progress_bar = true,
        progress_bar_hue_shift = -119
    } )
    self._thinkTitle:AddSubquest( self._thinkBar )
    self._thinkBar:SetTextReplaceValue( SUBQUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, self._nextTime)
    self._thinkBar:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, self._nextTime)

    CRoundThinker:Run()
end

--等待刷怪
function CRoundThinker:Run( )
	
	CustomTimer("CRoundThinkerRun",function( )
		
		if self._currentTime <= 0 then
			self._thinkTitle:CompleteQuest()
			self._thinkBar:CompleteSubquest()
			CRoundThinker:Create()
			return nil
		end

		self._currentTime = self._currentTime - 1
		self._thinkBar:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, self._currentTime )

		return 1
	end,1)
end

--刷怪
function CRoundThinker:Create( )
	
	local count = 0
	self._currentUnitCount = self._count * #self._spawnPoints
	CustomTimer("CRoundThinkerCreate",function( )
		
		if count >= self._count then
			CRoundThinker:Destroy()
			return nil
		end

		for k,v in pairs(self._spawnPoints) do
			local unit = CustomCreateUnit(self._unitsName[self._currentRound],v,270,self._teamNumber)
			unit:SetContextThink(DoUniqueString("CRoundThinkerCreate"),function( )
				if IsValidAndAlive(unit) ~= true then
					self._currentUnitCount = self._currentUnitCount - 1
					return nil
				end

				return 0.2
			end,1)
		end
		
		count = count + 1
		return self._interval
	end,self._interval)
end

--下一波计算
function CRoundThinker:Destroy( )

	self._currentUnitTitle  = SpawnEntityFromTableSynchronous( "quest", {
        name = self._unitsName[self._currentRound],
        title =  self._unitTitleName
    })
    self._currentUnitTitle:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_ROUND,self._currentRound)

    self._currentUnitBar = SpawnEntityFromTableSynchronous( "subquest_base", {
        show_progress_bar = true,
        progress_bar_hue_shift = -119
    } )
    self._currentUnitTitle:AddSubquest( self._currentUnitBar )
    self._currentUnitBar:SetTextReplaceValue( SUBQUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, self._currentUnitCount)
    self._currentUnitBar:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, self._currentUnitCount)

    local old = self._currentUnitCount
    local new = 0
    CustomTimer("CRoundThinkerDestroy",function( )
    	if self._currentUnitCount <= 0 then
    		self._currentUnitTitle:CompleteQuest()
			self._currentUnitBar:CompleteSubquest()
    		self._currentRound = self._currentRound + 1
    		CRoundThinker:Start()
    		return nil
    	end

    	new = self._currentUnitCount
    	if new ~= old then
    		self._currentUnitBar:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, self._currentUnitCount)
    	end

    	old = new
    	return 0.1
    end,0)
end