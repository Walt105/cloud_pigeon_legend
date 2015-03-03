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

	--载入音效
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_troll_warlord.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_jakiro.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_razor.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_zuus.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_stormspirit.vsndevts", context )

	--载入特效
	PrecacheResource( "particle", "particles/units/heroes/hero_viper/viper_poison_debuff.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_sven/sven_loadout.vpcf", context )
	PrecacheResource( "particle", "particles/status_fx/status_effect_gods_strength.vpcf", context )
	PrecacheResource( "particle", "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze.vpcf", context )
	PrecacheResource( "particle_folder", "particles/custom", context )
	PrecacheResource( "particle_folder", "particles/units/heroes/hero_razor", context )
	PrecacheResource( "particle_folder", "particles/units/heroes/hero_zuus", context )
	PrecacheResource( "particle_folder", "particles/units/heroes/hero_jakiro", context )
	PrecacheResource( "particle_folder", "particles/units/heroes/hero_stormspirit", context )

end

-- Create the game mode when we activate
function Activate()
	GameRules.CloudPigeonLegend = CCloudPigeonLegendGameMode()
	GameRules.CloudPigeonLegend:InitGameMode()
end

function CCloudPigeonLegendGameMode:InitGameMode()
	print( "CloudPigeonLegend addon is loaded." )
	require("require_everything")

	--隐藏dota2的一些UI
	HideGameHud()
	
	
end

function HideGameHud( )
	local mode = GameRules:GetGameModeEntity()
	mode:SetHUDVisible(DOTA_HUD_VISIBILITY_TOP_HEROES, false)
	mode:SetHUDVisible(DOTA_HUD_VISIBILITY_INVENTORY_SHOP, false)

	Convars:SetInt("dota_render_crop_height", 0)
	Convars:SetInt("dota_render_y_inset", 0)
end
