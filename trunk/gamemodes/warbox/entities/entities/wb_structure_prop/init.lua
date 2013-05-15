include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

DEFINE_BASECLASS( "base_structure" )

-- local references to commonly used functions
local v = FindMetaTable("Vector")
local LengthSqr = v.LengthSqr


function ENT:Initialize()
	
	BaseClass.Initialize( self )
	
	-- Formulas using surface-area, volume and mass to calculate health of model
	local box = (self.Entity:OBBMaxs() - self.Entity:OBBMins())
	local area = 2 * (box.x * box.y + box.x * box.z + box.y * box.z)
	local size = math.min( box.x * box.y * box.z, 3*math.pow(10,7) ) -- capped near peak for obvious reasons
	
	local masstohealthresult = self:GetPhysicsObject():GetMass() * self.MassRatio
	local areatohealthresult = math.pow(area, 1/2) * self.AreaRatio + 0.00175*area
	local sizetohealthresult = math.pow(size, 1/2) * self.AreaRatio - 0.00007*size -- Lowers the higher end of the graph
	
	local bboxtohealthresult = math.max( areatohealthresult, sizetohealthresult )
	
	self.MaxHealth = math.min( math.min( masstohealthresult, bboxtohealthresult ), self.MaxMaxHealth )
	self.CurHealth = self.MaxHealth
	
	-- Scaled linear from 3 seconds to 2 minutes
	self.BuildTime = 3 + 2 * 60 * self.MaxHealth/self.MaxMaxHealth 
	
	-- Networked variables
	self:SetNetworkedInt("WB_MaxHealth", math.floor(self.MaxHealth))
	self:SetNetworkedInt("WB_CurHealth", math.floor(self.CurHealth))
	
end
