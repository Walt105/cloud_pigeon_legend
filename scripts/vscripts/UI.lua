
if CUI == nil then
	CUI = class({})
end

function CUI:Init( )
	--在控制台里注册命令
	Convars:RegisterCommand( "SyncGold", function(name)
	    --锁定发送命令的玩家
	    local cmdPlayer = Convars:GetCommandClient()
	    if cmdPlayer then
	        --如果玩家有效
	        print("player "..tostring(cmdPlayer:GetPlayerID()),"Call SyncGold")
	        return self:SyncGold( cmdPlayer )
	    end
	end, "SyncGold", FCVAR_CHEAT )
end

function CUI:SyncGold( cmdPlayer )
	print("CUI:SyncGold")
end