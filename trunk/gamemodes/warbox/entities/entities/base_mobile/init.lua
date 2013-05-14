include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

DEFINE_BASECLASS( "base_unit" )

function ENT:Initialize()
	
	BaseClass.Initialize( self )
	
	-- Fields defualt values
	self.Speed			=	self.Balance.Speed
	self.MoveRange		=	self.Balance.MoveRange

	self.SpeedSqr		=	math.pow(self.Speed, 2)
	self.MoveRangeSqr	=	math.pow(self.MoveRange, 2)
	
	self.IsMobile = true
	
end
