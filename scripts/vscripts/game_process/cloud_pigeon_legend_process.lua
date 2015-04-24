
--[[
这里主地图的内容
]]

if CCloudPigeonLegend == nil then
	CCloudPigeonLegend = class({})
end

function CCloudPigeonLegend:Start( )
	local TeamNumber = DOTA_TEAM_BADGUYS
		
	--创建超级树精
	local ent = Entities:FindByName(nil,"first_boss_super_treant")
	local super_treant = CustomCreateUnit("npc_first_boss_super_treant",ent:GetOrigin(),270,TeamNumber)

	--创建小树精
	local ent_1 = Entities:FindByName(nil,"first_boss_treant_over")
	local ent_2 = Entities:FindByName(nil,"first_boss_small_treant_1_1")
	local ent_3 = Entities:FindByName(nil,"first_boss_small_treant_2_1")

	local units = {}
	for i=1,6 do
		table.insert( units,"npc_treant_0"..i )
	end
	local sp = {
		ent_2:GetAbsOrigin(),
		ent_3:GetAbsOrigin(),
	}
	CRoundThinker:Init( 10,units,GameRules.PlayerNum+5,0.1,sp,1,TeamNumber,"RoundThinkerTitle","UnitCountTitle" )
	CRoundThinker:Start()

	--创建大树精
	local num_3 = math.floor(40 * GameRules.PlayerPercent)
	local count_3 = 0
	local ent_3 = Entities:FindByName(nil,"first_boss_big_treant_1_1")
	local ent_3_vec = ent_3:GetOrigin()
	CustomTimer("CCloudPigeonLegend",function( )

		if count_3 > num_3 then
			return nil
		end

		local unit = CustomCreateUnit("npc_first_boss_big_treant",ent_3_vec,270,TeamNumber)

		--禁止单位寻找最短路径
		unit:SetMustReachEachGoalEntity(true)

		--让单位沿着设置好的路线开始行动
		unit:SetInitialGoalEntity(ent_3)

		count_3 = count_3 + 1
		return 1
	end,1)
end

