include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

local BaseClass = baseclass.Get("base_anim")

function ENT:Initialize()
    
    self:AddTag( "Projectile", function() self:RemoveCallOnRemove("RemoveProjectile") end )
	self:CallOnRemove( "RemoveProjectile", function() self:RemoveTag("Projectile")  end )
    
    self:SetModel(self.model)
    self:SetMaterial(self.material)
    
    self.propsize = self:OBBMaxs() - self:OBBMins()
    local r = self.minRadius
    self.radius = r
    self:PhysicsInitSphere(r)
    self:SetCollisionBounds(Vector(-r,-r,-r),Vector(r,r,r))
    self:SetModelScale(r / self.propsize.x, 0)
    
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
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
	timer.Simple(self.timeToLive, function() if self.OnExpiration then self:OnExpiration() end end)
end

function ENT:Think()
    
end

function ENT:SetRadius(r)
    self.radius = r
    self:PhysicsInitSphere(r)
    self:SetCollisionBounds(Vector(-r,-r,-r), Vector(r,r,r))
	local scale = r / self.propsize.x
	--local vec = r / self.propsize
    --local mat = Matrix()
    --mat:Scale(vec)
    --self:EnableMatrix("RenderMultiply", mat) -- nil method?
    self:SetModelScale(scale,0)
    
	local physics = self:GetPhysicsObject();
	if (physics:IsValid()) then
		physics:Wake()
		physics:EnableGravity(false)
	end
end

function ENT:Break()
    if IsValid(self:GetOwner()) then
        self:GetOwner().projectile = nil
    end
    
    local pos = self:GetPos()
    
    -- Deals less damage if exploding during windup.
    local progress = (self.radius - self.minRadius) / (self.maxRadius - self.minRadius)
    progress = progress == 0 and 0.1 or progress
    local expl=ents.Create("point_hurt")
        expl.Team= self.Team
        expl:SetPos(pos)
        expl:SetOwner(self)
        expl:SetKeyValue("Damage", self.damage * progress)
        expl:SetKeyValue("DamageRadius", self.explosionRadius * progress)
        expl:SetKeyValue("DamageType", "0")
    expl:Spawn()
    expl:Activate()
    expl:Fire("Hurt", "", 0)
    expl:Fire("kill", "", 0)
    
    local fx = EffectData()
    fx:SetOrigin(pos)
    fx:SetStart(pos)
    fx:SetScale(progress)
    util.Effect("cball_explode", fx)
    self:Fire ("kill", "", 0)
end

function ENT:OnExpiration()
    self:Break()
end


function ENT:PhysicsCollide( data )
    assert(not data.HitEntity:IsPlayer()
            , "Projectiles should be unable to hit players.")
    assert(self:GetOwner() ~= data.HitEntity
            , "Battlemage projectiles should be unable to hit their battlemage.")
    
    -- Break on any impact
    self:Break()
end
