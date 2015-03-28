
if CHateSystem == nil then
	CHateSystem = class({})
end

--返回当前存活着的仇恨值最大的一个近战单位
function CDOTA_BaseNPC:GetHateSystemMaxMeleeHero( )
	if self.HateSystemUnit ~= nil and self.HateSystemHateNum ~= nil then
		
		for k,v in pairs(self._HateSystemMeleeHero) do
			if IsValidAndAlive(v) == true then
				return v
			end
		end

	end
	return nil
end

--返回当前存活着的仇恨值最大的一个远程单位
function CDOTA_BaseNPC:GetHateSystemMaxRangedHero( )
	if self.HateSystemUnit ~= nil and self.HateSystemHateNum ~= nil then
		
		for k,v in pairs(self._HateSystemRangedHero) do
			if IsValidAndAlive(v) == true then
				return v
			end
		end
		
	end
	return nil
end

--返回当前存活着的仇恨值最小的一个近战单位
function CDOTA_BaseNPC:GetHateSystemMinMeleeHero( )
	if self.HateSystemUnit ~= nil and self.HateSystemHateNum ~= nil then
		
		local num = #self._HateSystemMeleeHero
		for i=num,1,-1 do
			if IsValidAndAlive(self._HateSystemMeleeHero[i]) == true then
				return self._HateSystemMeleeHero[i]
			end
		end

	end
	return nil
end

--返回当前存活着的仇恨值最小的一个远程单位
function CDOTA_BaseNPC:GetHateSystemMinRangedHero( )
	if self.HateSystemUnit ~= nil and self.HateSystemHateNum ~= nil then
		
		local num = #self._HateSystemRangedHero
		for i=num,1,-1 do
			if IsValidAndAlive(self._HateSystemRangedHero[i]) == true then
				return self._HateSystemRangedHero[i]
			end
		end

	end
	return nil
end

--根据队列返回一个近战英雄，为0则为随机
function CDOTA_BaseNPC:GetHateSystemMeleeHero( queue )
	if self.HateSystemUnit ~= nil and self.HateSystemHateNum ~= nil then
		if queue == 0 then
			return self._HateSystemMeleeHero[RandomInt(1,#self._HateSystemMeleeHero)]
		end
		return self._HateSystemMeleeHero[queue]
	end
end

--根据队列返回一个远程英雄，为0则为随机
function CDOTA_BaseNPC:GetHateSystemRangedHero( queue )
	if self.HateSystemUnit ~= nil and self.HateSystemHateNum ~= nil then
		if queue == 0 then
			return self._HateSystemRangedHero[RandomInt(1,#self._HateSystemRangedHero)]
		end
		return self._HateSystemRangedHero[queue]
	end
end

--打印
function CHateSystem:HateSystemMeleeAndRangedShow( boss )
	local melee_num = #boss._HateSystemMeleeHero
	local range_num = #boss._HateSystemRangedHero

	print("-------------HateSystemMelee-------------")
	for i=1,melee_num do
		local unit = boss._HateSystemMeleeHero[i]
		if IsValidAndAlive(unit) == true then
			print(unit:GetUnitName(),"hate is",boss.HateSystemHateNum[i])
		end
	end
	print("-----------------------------------------")

	print("-------------HateSystemRanged-------------")
	for i=1,range_num do
		local unit = boss._HateSystemRangedHero[i]
		if IsValidAndAlive(unit) == true then
			print(unit:GetUnitName(),"hate is",boss.HateSystemHateNum[i])
		end
	end
	print("-----------------------------------------")

end

--排列
function CHateSystem:HateSystemMeleeAndRangedQueue( boss )
	local melee_num = #boss._HateSystemMeleeHero
	local range_num = #boss._HateSystemRangedHero

	for i=1,melee_num do
		local temp = nil
		local unit = boss._HateSystemMeleeHero[i]
		for j=i,melee_num do
			local new = boss._HateSystemMeleeHero[j]
			if boss:GetHateSystemHeroNum( unit ) < boss:GetHateSystemHeroNum( new ) then
				temp = boss._HateSystemMeleeHero[i]
				boss._HateSystemMeleeHero[i] = boss._HateSystemMeleeHero[j]
				boss._HateSystemMeleeHero[j] = temp
			end
		end
	end

	for i=1,range_num do
		local temp = nil
		local unit = boss._HateSystemRangedHero[i]
		for j=i,range_num do
			local new = boss._HateSystemRangedHero[j]
			if boss:GetHateSystemHeroNum( unit ) < boss:GetHateSystemHeroNum( new ) then
				temp = boss._HateSystemRangedHero[i]
				boss._HateSystemRangedHero[i] = boss._HateSystemRangedHero[j]
				boss._HateSystemRangedHero[j] = temp
			end
		end
	end	

	--CHateSystem:HateSystemMeleeAndRangedShow( boss )
end

--对远程英雄和近战英雄进行分类
function CHateSystem:HateSystemMeleeAndRangedCreated( boss )

	if boss._HateSystemMeleeHero == nil then
		boss._HateSystemMeleeHero  = {}
		boss._HateSystemRangedHero = {}
	end

	for k,v in pairs(boss.HateSystemUnit) do
		repeat
			if FindTableToTable( boss._HateSystemRangedHero,v ) then break end
			if FindTableToTable( boss._HateSystemMeleeHero ,v ) then break end
			if IsValidAndAlive(v) == true then
				if v:IsHero() then
					if v:IsRangedAttacker() then
						table.insert( boss._HateSystemRangedHero,v )
					else
						table.insert( boss._HateSystemMeleeHero ,v )
					end
				end
			end
		until true
	end
	CHateSystem:HateSystemMeleeAndRangedQueue( boss )
end

--打印仇恨系统消息
function CHateSystem:HateSystemShow( boss )
	if boss.HateSystemUnit ~= nil and boss.HateSystemHateNum ~= nil then
		
		local unit_num = #boss.HateSystemUnit
		local hate_num = #boss.HateSystemHateNum
		if unit_num == hate_num then
			print("-------------HateSystem-------------")
			for i=1,unit_num do
				local unit = boss.HateSystemUnit[i]
				if IsValidEntity(unit) then
					if unit:IsAlive() then
						print(unit:GetUnitName(),"hate is",boss.HateSystemHateNum[i])
					end
				end
			end
			print("------------------------------------")
		end
	end
end

--对仇恨系统进行排列
function CHateSystem:HateSystemQueue( boss )
	if boss.HateSystemUnit ~= nil and boss.HateSystemHateNum ~= nil then

		local unit_num = #boss.HateSystemUnit
		local hate_num = #boss.HateSystemHateNum
		if unit_num == hate_num then
			for i=1,unit_num do
				for j=i+1,unit_num do
					if boss.HateSystemHateNum[i] < boss.HateSystemHateNum[j] then
						local temp = boss.HateSystemHateNum[i]
						local unit = boss.HateSystemUnit[i]
						boss.HateSystemUnit[i] 		= boss.HateSystemUnit[j]
						boss.HateSystemUnit[j] 		= unit
						boss.HateSystemHateNum[i] 	= boss.HateSystemHateNum[j]
						boss.HateSystemHateNum[j] 	= temp
					end
				end
			end
			CHateSystem:HateSystemShow(boss)
			CHateSystem:HateSystemMeleeAndRangedCreated( boss )
		end
	end
end

--查找单位在仇恨系统的所在位置
function CHateSystem:HateSystemFindPosition( t1,t2 )
	for k,v in pairs(t1) do
		if v == t2 then
			return k
		end
	end
	return 0
end

--仇恨系统入口
function HateSystemOnTaken( keys )
	local target = keys.caster
	local attacker = keys.attacker

	if target.HateSystemUnit == nil then
		target.HateSystemUnit = {}
		target.HateSystemHateNum = {}
	end

	local i = CHateSystem:HateSystemFindPosition(target.HateSystemUnit,attacker)
	if FindTableToTable(target.HateSystemUnit,attacker) == false then
		i = #target.HateSystemUnit + 1
		target.HateSystemUnit[i] = attacker
		target.HateSystemHateNum[i] = 0
	end

	target.HateSystemHateNum[i] = target.HateSystemHateNum[i] + math.floor(keys.take_damage)
	CHateSystem:HateSystemQueue(target)
end

--添加仇恨系统
function CDOTA_BaseNPC:AddHateSystem( )
	local ability = GameRules.Majia:FindAbilityByName("common_ability")
	if ability then
		ability:ApplyDataDrivenModifier(self,self,"modifier_hate_system",nil)
		ability:ApplyDataDrivenModifier(self,self,"modifier_boss_is_war",nil)
	end
end

--获取某位置上的单位
function CDOTA_BaseNPC:GetHateSystemHero( queue )
	if self.HateSystemUnit ~= nil and self.HateSystemHateNum ~= nil then
		
		local unit_num = #self.HateSystemUnit
		local hate_num = #self.HateSystemHateNum
		if unit_num == hate_num then
			return self.HateSystemUnit[queue]
		end
	end
end

--获取某单位的仇恨值
function CDOTA_BaseNPC:GetHateSystemHeroNum( unit )
	if self.HateSystemUnit ~= nil and self.HateSystemHateNum ~= nil then
		
		local unit_num = #self.HateSystemUnit
		local hate_num = #self.HateSystemHateNum
		if unit_num == hate_num then
			for k,v in pairs(self.HateSystemUnit) do
				if v == unit then
					return self.HateSystemHateNum[k]
				end
			end
		end
	end
	return 0
end

--返回当前存活着的仇恨值最大的一个单位
function CDOTA_BaseNPC:GetHateSystemMaxHero( )
	if self.HateSystemUnit ~= nil and self.HateSystemHateNum ~= nil then
		
		local unit_num = #self.HateSystemUnit
		local hate_num = #self.HateSystemHateNum
		if unit_num == hate_num then
			local unit = nil
			for i=1,unit_num do
				unit = self:GetHateSystemHero(i)
				if IsValidEntity(unit) then
					if unit:IsAlive() then
						break
					end
				end
			end
			return unit
		end
	end
end

--返回当前存活着的仇恨值最小的一个单位
function CDOTA_BaseNPC:GetHateSystemMinHero( )
	if self.HateSystemUnit ~= nil and self.HateSystemHateNum ~= nil then
		
		local unit_num = #self.HateSystemUnit
		local hate_num = #self.HateSystemHateNum
		if unit_num == hate_num then
			local num = unit_num
			local unit = nil
			for i=1,unit_num do
				unit = self:GetHateSystemHero(num)
				if IsValidEntity(unit) then
					if unit:IsAlive() then
						break
					end
				end
				num = num - 1
			end
			return unit
		end
	end
end

--清空仇恨系统
function CDOTA_BaseNPC:GetHateSystemClear( )
	self.HateSystemUnit = nil
	self.HateSystemHateNum = nil
end

--仇恨置零
function CDOTA_BaseNPC:GetHateSystemZero( unit )
	if self.HateSystemUnit ~= nil and self.HateSystemHateNum ~= nil then
		
		local unit_num = #self.HateSystemUnit
		local hate_num = #self.HateSystemHateNum
		if unit_num == hate_num then
			local unit = nil
			for k,v in pairs(self.HateSystemUnit) do
				if v == unit then
					self.HateSystemHateNum[k] = 0
				end
			end
		end
	end
end
