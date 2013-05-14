include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

DEFINE_BASECLASS( "base_mobile" )

function ENT:Initialize()
	
	BaseClass.Initialize( self )
	
	-- Fields defualt values
	self.RangeSqr		=	math.pow(self.Range, 2)

	self.IsAi = true
	
end
