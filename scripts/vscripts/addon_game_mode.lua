-- Generated from template

if CCloudPigeonLegendGameMode == nil then
	CCloudPigeonLegendGameMode = class({})
end

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]

	--载入模型
	PrecacheResource( "model", "models/heroes/antimage/antimage_arms.vmdl", context )
	PrecacheResource( "model", "models/heroes/antimage/antimage_belt.vmdl", context )
	PrecacheResource( "model", "models/heroes/antimage/antimage_chest.vmdl", context )
	PrecacheResource( "model", "models/heroes/antimage/antimage_head.vmdl", context )
	PrecacheResource( "model", "models/heroes/antimage/antimage_offhand_weapon.vmdl", context )
	PrecacheResource( "model", "models/heroes/antimage/antimage_weapon.vmdl", context )

	--载入音效
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_troll_warlord.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_jakiro.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_razor.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_zuus.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_invoker.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_stormspirit.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_ogre_magi.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_skywrath_mage.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_treant.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/custom/Boss_millenary_treant/Boss_millenary_treant_A4.vsndevts", context )

	--载入特效
	PrecacheResource( "particle", "particles/units/heroes/hero_viper/viper_poison_debuff.vpcf", context )
	
	PrecacheResource( "particle", "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze.vpcf", context )
	PrecacheResource( "particle_folder", "particles/custom", context )
	PrecacheResource( "particle_folder", "particles/status_fx", context )
	PrecacheResource( "particle_folder", "particles/units/heroes/hero_sven", context )
	PrecacheResource( "particle_folder", "particles/units/heroes/hero_razor", context )
	PrecacheResource( "particle_folder", "particles/units/heroes/hero_zuus", context )
	PrecacheResource( "particle_folder", "particles/units/heroes/hero_jakiro", context )
	PrecacheResource( "particle_folder", "particles/units/heroes/hero_invoker", context )
	PrecacheResource( "particle_folder", "particles/units/heroes/hero_phoenix", context )
	PrecacheResource( "particle_folder", "particles/units/heroes/hero_stormspirit", context )
	PrecacheResource( "particle_folder", "particles/units/heroes/hero_treant", context )

	--载入模型
	local unit_kv = LoadKeyValues("scripts/npc/npc_units_custom.txt")
    if unit_kv then
        for unit_name,keys in pairs(unit_kv) do
            --print("precacheing resource for unit"..unit_name)
            if type(keys) == "table" then
                if keys.Model then
                    --print("precacheing model"..keys.Model)
                    PrecacheModel(keys.Model, context )
                end
            end
        end
    end

end

-- Create the game mode when we activate
function Activate()
	GameRules.CloudPigeonLegend = CCloudPigeonLegendGameMode()
	GameRules.CloudPigeonLegend:InitGameMode()
end

function CCloudPigeonLegendGameMode:InitGameMode()
	print( "CloudPigeonLegend addon is loaded." )
	print( "Load map is "..GetMapName()..".vmap" )

	GameRules.CustomPurgeTable = {}
	GameRules.BossAbility = {}
	require("require_everything")

	--隐藏dota2的一些UI
	HideGameHud()
	
	--设置游戏准备时间
	GameRules:SetPreGameTime( 10.0)

	-- 设定选择英雄时间
	GameRules:SetHeroSelectionTime(15)

	-- 设定是否可以选择相同英雄
	GameRules:SetSameHeroSelectionEnabled( false )

	-- 是否使用自定义的英雄经验
  	GameRules:SetUseCustomHeroXPValues ( true )
  	
  	-- 设定每秒工资数
  	GameRules:SetGoldPerTick(0)
  	GameRules:SetGoldTickTime(3600)

  	-- 隐藏击杀信息
  	GameRules:SetHideKillMessageHeaders(true)

  	-- 允许自定义英雄等级
  	GameRules:GetGameModeEntity():SetUseCustomHeroLevels(true)

  	--设置树木重生时间
  	GameRules:SetTreeRegrowTime( 3600.0 )

  	--不允许买活
  	GameRules:GetGameModeEntity():SetBuybackEnabled(false)

  	--最大等级
  	MaxLevel = 1

  	--升级所需经验
	XpTable = {1}
	GameRules:GetGameModeEntity():SetCustomHeroMaxLevel(MaxLevel)
	GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel(XpTable)
	
	--初始化
	CEvents:Init()
	CustomPurgeInit()
	GameRules.PlayerNum = 0
	GameRules.PlayerMaxNum = 6
	GameRules.PlayerPercent = 0
	GameRules.ThisBoss = nil
	GameRules._HeroRespawn = nil
	GameRules._IsRespawn = true
	GameRules._PlayerHeroes = {}
	GameRules._Players = {}
	GameRules._touch2TriggerNum = 0
	GameRules._touch2TriggerUnit = {}
	GameRules._touch3TriggerNum = 0
	GameRules._touch3TriggerUnit = {}
end

function HideGameHud( )
	local mode = GameRules:GetGameModeEntity()
	mode:SetHUDVisible(DOTA_HUD_VISIBILITY_TOP_HEROES, false)
	--mode:SetHUDVisible(DOTA_HUD_VISIBILITY_INVENTORY_SHOP, false)
	mode:SetHUDVisible(DOTA_HUD_VISIBILITY_TOP_TIMEOFDAY, false)

	Convars:SetInt("dota_render_crop_height", 0)
	Convars:SetInt("dota_render_y_inset", 0)
end
