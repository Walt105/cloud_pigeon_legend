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

	--载入特效
	PrecacheResource( "particle", "particles/units/heroes/hero_viper/viper_poison_debuff.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_sven/sven_loadout.vpcf", context )
	PrecacheResource( "particle", "particles/status_fx/status_effect_gods_strength.vpcf", context )
	
end

-- Create the game mode when we activate
function Activate()
	GameRules.CloudPigeonLegend = CCloudPigeonLegendGameMode()
	GameRules.CloudPigeonLegend:InitGameMode()
end

function CCloudPigeonLegendGameMode:InitGameMode()
	print( "CloudPigeonLegend addon is loaded." )
	require("require_everything")
	
end
