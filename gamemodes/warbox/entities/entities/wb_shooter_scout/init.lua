include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

local BaseClass = baseclass.Get("base_unit")

function ENT:Initialize()
	
	BaseClass.Initialize( self )
	
end

-- Do shooting stuff
function ENT:Shoot( targetEntity )
	local direction = self.TargetEntityDir
	local pos = self:GetShootPos( direction )
	local tarpos = targetEntity:NearestPoint(pos)--targetEntity:GetPos()
	local color = self:GetTeam():GetColor()
	
	local fx_laser = EffectData()
		fx_laser:SetAngles( Angle(color.r, color.g, color.b) )
		fx_laser:SetOrigin( pos )
		fx_laser:SetStart(  tarpos )
		fx_laser:SetScale(  2 )
	util.Effect("coloredlaser", fx_laser)
	
	local fx_muzzle = EffectData()
		fx_muzzle:SetOrigin( pos )
		fx_muzzle:SetAngles( direction:Angle() )
		fx_muzzle:SetScale(  1.2 )
	util.Effect("MuzzleEffect", fx_muzzle)
	
	self:EmitSound("Weapon_Mortar.Single", 100, 100)
	
	targetEntity:TakeDamage(self.Damage, self)
end