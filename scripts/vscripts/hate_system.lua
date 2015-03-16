
if CHateSystem == nil then
	CHateSystem = class({})
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
				else
					TableRemoveTable(boss.HateSystemUnit,unit)
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
		ability:ApplyDataDrivenModifier(self,self,"modifier_boss_find_unit",nil)
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