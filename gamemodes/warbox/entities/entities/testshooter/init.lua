include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

DEFINE_BASECLASS( "base_mobile_ai" )


function ENT:Initialize()
	
	BaseClass.Initialize( self )
	
end

-----------------------------------
--------- OVERRIDE THESE ----------
-----------------------------------

-- Do shooting stuff
function ENT:Shoot( targetEntity )
	local pos = self:GetPos()
	local tarpos = targetEntity:GetPos()
	local direction = tarpos - pos
	local color = self:GetTeam():GetColor()
	
	local fx_laser = EffectData()
		fx_laser:SetAngles( Angle(color.r, color.g, color.b) )
		fx_laser:SetOrigin( pos )
		fx_laser:SetStart(  tarpos )
		fx_laser:SetScale(  2 )
	util.Effect("coloredlaser", fx_laser)
	
	local fx_muzzle = EffectData()
		fx_muzzle:SetOrigin(pos )
		fx_muzzle:SetAngles( direction:Angle() )
		fx_muzzle:SetScale( 1.2 )
	util.Effect("MuzzleEffect", fx_muzzle)
	
	self:EmitSound("Weapon_Mortar.Single", 100, 100)
	
	targetEntity:TakeDamage(self.Damage, self)
end