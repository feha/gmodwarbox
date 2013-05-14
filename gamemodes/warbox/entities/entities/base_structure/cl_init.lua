include("shared.lua")

DEFINE_BASECLASS( "base_anim" )

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Draw()
	
	BaseClass.Draw( self )
	
	-- Add stuff like build and health overlay
	
end