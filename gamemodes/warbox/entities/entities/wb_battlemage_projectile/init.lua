include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

local BaseClass = baseclass.Get("base_anim")

function ENT:Initialize()
    
    self:AddTag( "Projectile", function() self:RemoveCallOnRemove("RemoveProjectile") end )
	self:CallOnRemove( "RemoveProjectile", function() self:RemoveTag("Projectile")  end )
    
    self:SetModel(self.model)
    self:SetMaterial(self.material)
    
    self.radius = self.minRadius
    local r = self.radius
    self:PhysicsInitSphere(r)
    self:SetCollisionBounds(Vector(-r,-r,-r),Vector(r,r,r))
    
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetSkin(1)
    
	local physics = self:GetPhysicsObject();
	if (physics:IsValid()) then
		physics:Wake()
		physics:EnableGravity(false)
	end
    
end

function ENT:ScheduleExpiration()
	timer.Simple(self.timeToLive, function() self:OnExpiration() end)
end

function ENT:Think()
    
end

function ENT:SetRadius(r)
    self.radius = r
    self:PhysicsInitSphere(r)
    self:SetCollisionBounds(Vector(-r,-r,-r),Vector(r,r,r))
    
	local physics = self:GetPhysicsObject();
	if (physics:IsValid()) then
		physics:Wake()
		physics:EnableGravity(false)
	end
end

function ENT:Break()
    local pos = self:GetPos()
    
    local expl=ents.Create("point_hurt")
        expl.Team= self.Team
        expl:SetPos(pos)
        expl:SetOwner(self)
        expl:SetKeyValue("Damage",self.damage)
        expl:SetKeyValue("DamageRadius", self.explosionRadius)
        expl:SetKeyValue("DamageType", "0")
    expl:Spawn()
    expl:Activate()
    expl:Fire("Hurt", "", 0)
    expl:Fire("kill","",0)
    
    local fx = EffectData()
    fx:SetOrigin(pos)
    fx:SetStart(pos)
    fx:SetScale(1)
    util.Effect("cball_explode", fx)
    self:Fire ("kill", "", 0)
end

function ENT:OnExpiration()
    self:Break()
end

function ENT:PhysicsCollide( data )
    print("PhysicsCollide", data)
    if self.shooter ~= data.Entity then
        self:Break()
    end
end
