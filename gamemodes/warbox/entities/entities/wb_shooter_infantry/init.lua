include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

DEFINE_BASECLASS( "base_mobile_ai" )

-- local references to commonly used functions and libraries
local v = FindMetaTable("Vector")
local GetNormal = v.GetNormal


function ENT:Initialize()
	
	BaseClass.Initialize( self )
	
end

-- Do shooting stuff
function ENT:Shoot( targetEntity )
	local direction = self.TargetEntityDir
	local pos = self:GetShootPos( direction )
	local tarpos = targetEntity:GetPos()
	
	local bullet = {}
		bullet.Num = self.NumberOfBullets
		bullet.Src = pos
		bullet.Dir = GetNormal(direction)
		bullet.Spread = self.Spread
		bullet.Tracer = 1
		bullet.Force = self.BulletForce
		bullet.Damage = self.Damage
		bullet.TracerName = "AR2Tracer"
	self:FireBullets(bullet)
	
	local fx = EffectData()
		fx:SetOrigin( pos )
		fx:SetAngles( direction:Angle() )
		fx:SetScale(  1.5 )
	util.Effect("MuzzleEffect", fx)
	
	self.Entity:EmitSound("Weapon_P90.Single", 100, 100)
end