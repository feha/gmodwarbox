include('shared.lua')
include('wb_concmds.lua')

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )


function GM:PlayerConnect( name, ip )
	print("PlayerConnect")
end

function GM:PlayerDisconnect( name, ip )
	print("PlayerDisconnect")
end

function GM:PlayerInitialSpawn( ply )
	print("PlayerInitialSpawn")
	ply:SetTeam( 0 )
	
end

function GM:PlayerAuthed( ply, steamID, uniqueID )
	print("PlayerAuthed")
end

function GM:PlayerSpawn(ply)
	print("PlayerSpawn")
	ply:RemoveAllAmmo()
	
	ply:Give( "weapon_physgun" )
	ply:Give( "gmod_tool" )
	ply:Give( "gmod_camera" )
	
	ply:Give("wb_swep_order")
	ply:SelectWeapon("wb_swep_order")
end

-- function GM:PlayerLoadout(ply)
	-- print("PlayerLoadout")
	-- ply:RemoveAllAmmo()
	
	-- ply:Give( "gmod_tool" )
	-- ply:Give( "gmod_camera" )
	-- ply:Give( "weapon_physgun" )
	
	-- ply:SwitchToDefaultWeapon()
-- end


-- Will be used for pausing and such
-- 0 = running
-- 1 = paused
-- 2 = more paused...
local pause = 0
function GetGameIsPaused()
	return pause
end

function SetGameIsPaused( paused )
	if pause == 2 and paused < 2 then
		for _,v in pairs(Structure.GetTableReference()) do
			local phys = v:GetPhysicsObject()
			if phys:IsValid() then
				phys:Wake()
			end
		end
	elseif paused == 2 then
		for _,v in pairs(Structure.GetTableReference()) do
			local phys = v:GetPhysicsObject()
			if phys:IsValid() then
				phys:Sleep()
			end
		end
	end
	
	pause = paused
end

concommand.Add( "wb_pause", function(ply, cmd, args)
	if ply:IsAdmin() then
		if args[1] then
			SetGameIsPaused( args[1] )
		else
			ply:PrintMessage( HUD_PRINTCONSOLE, "pause = " .. tostring(GetGameIsPaused()) )
		end
	end
end , nil, "Used to pause the game; 0 = unpaused" )
