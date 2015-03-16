
--[[
这里主地图的内容
]]

if CCloudPigeonLegend == nil then
	CCloudPigeonLegend = class({})
end

function CCloudPigeonLegend:Start( )
	local TeamNumver = DOTA_TEAM_BADGUYS

	--创建超级树精
	local ent = Entities:FindByName(nil,"first_boss_super_treant")
	local super_treant = CustomCreateUnit("npc_first_boss_super_treant",ent:GetOrigin(),270,TeamNumver)

	--创建小树精
	local num = math.floor(15 * GameRules.PlayerPercent)
	local count = 0
	local ent_1 = Entities:FindByName(nil,"first_boss_small_treant_1_1")
	local ent_2 = Entities:FindByName(nil,"first_boss_small_treant_2_1")
	local unitName = "npc_first_boss_small_treant"

	CustomTimer("CCloudPigeonLegend",function( )

		if count > num then
			return nil
		end

		local unit_1 = CustomCreateUnit(unitName,ent_1:GetOrigin(),270,TeamNumver)
		local unit_2 = CustomCreateUnit(unitName,ent_2:GetOrigin(),270,TeamNumver)

		--禁止单位寻找最短路径
		unit_1:SetMustReachEachGoalEntity(true)
		unit_2:SetMustReachEachGoalEntity(true)

		--让单位沿着设置好的路线开始行动
		unit_1:SetInitialGoalEntity(ent_1)
		unit_2:SetInitialGoalEntity(ent_2)

		count = count + 1
		return 1
	end,5)

	--创建大树精
	local num_3 = math.floor(40 * GameRules.PlayerPercent)
	local count_3 = 0
	local ent_3 = Entities:FindByName(nil,"first_boss_big_treant_1_1")
	local ent_3_vec = ent_3:GetOrigin()
	CustomTimer("CCloudPigeonLegend",function( )

		if count_3 > num_3 then
			return nil
		end

		local unit = CustomCreateUnit("npc_first_boss_big_treant",ent_3_vec,270,TeamNumver)

		--禁止单位寻找最短路径
		unit:SetMustReachEachGoalEntity(true)

		--让单位沿着设置好的路线开始行动
		unit:SetInitialGoalEntity(ent_3)

		count_3 = count_3 + 1
		return 1
	end,1)
end

