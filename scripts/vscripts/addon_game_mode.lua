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
