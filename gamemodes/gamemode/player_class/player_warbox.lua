DEFINE_BASECLASS( "player_sandbox" )

local PLAYER = {} 

--
-- See gamemodes/base/player_class/player_default.lua for all overridable variables
--
PLAYER.WalkSpeed 			= 200
PLAYER.RunSpeed				= 400



function PLAYER:Loadout()

	self.Player:RemoveAllAmmo()
	
	self.Player:Give( "gmod_tool" )
	self.Player:Give( "gmod_camera" )
	self.Player:Give( "weapon_physgun" )
	
	self.Player:SwitchToDefaultWeapon()

end


function PLAYER:SetTeam( teamIndex )

	self.BaseClass.SetTeam( self, teamIndex )
	
	self.Player.warboxTeam = WarboxTEAM.teams[teamIndex]
	self.Player.warboxTeam:AddPlayer(self.Player)
	
end

function PLAYER:GetTeam( )
	return self.Player.warboxTeam
end


-- Resources ----------------
PLAYER.Res = 0
PLAYER.MaxRes = Balance.player.MaxRes

function PLAYER:GetRes( )
	return math.floor( self.Res )
end

function PLAYER:SetRes( res )
	self.Res = math.min( res, self.MaxRes )
end

function PLAYER:AddRes( res )
	self:SetRes( self.Res + res )
end

function PLAYER:ConsumeRes( cost )
	if self.Res < cost then return false end
	
	self:SetRes( self.Res - cost )
	return true
end


-- UnitSelection ----------------
function PLAYER:GetUnitSelectionCount()
	return #self.Player.unitSelection or 0
end

-- unitSelection is a table where the units are the KEYS, as it makes it easyer to treat as a Set.
function PLAYER:GetUnitSelectionArray()
	
	local tbl = {}
	for k,_ in pairs(self.Player.unitSelection or {}) do
		table.insert(tbl,k)
	end
	return tbl
	
end

function PLAYER:GetUnitSelection()
	
	return table.Copy(self.Player.unitSelection) or {}
	
end

function PLAYER:SetUnitSelection( unitSelection )
	
	self.Player.unitSelection = {}
	for _,v in pairs(unitSelection) do
		assert(v.IsUnit == true, "Selection needs to be a table of Units.")
		self.Player.unitSelection[v] = v
	end
	
end

function PLAYER:AddUnitSelection( unitSelection )
	
	for _,v in pairs(unitSelection) do
		assert(v.IsUnit == true, "Selection needs to be a table of Units.")
		self.Player.unitSelection[v] = v
	end
	
end

function PLAYER:RemoveUnitSelection( unitSelection )
	
	for _,v in pairs(unitSelection) do
		assert(v.IsUnit == true, "Selection needs to be a table of Units.")
		self.Player.unitSelection[v] = nil
	end
	
end



player_manager.RegisterClass( "player_warbox", PLAYER, "player_sandbox" )