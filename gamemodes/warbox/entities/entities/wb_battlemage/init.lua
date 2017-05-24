include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

local BaseClass = baseclass.Get("base_unit")

-- local references to commonly used functions and libraries
local v = FindMetaTable("Vector")
local GetNormal = v.GetNormal


ENT.OverrideMixins={}
ENT.OverrideMixins["Initialize"] = {Shooter = true}
function ENT:Initialize()
	
	BaseClass.Initialize( self )
    
    self.localShootPos = Vector(0,0,30)
    self.shooterCanShoot = false
    self.windupSound = CreateSound(self, "vehicles/airboat/fan_blade_idle_loop1.wav")
	
end

-- TODO make the effect strings loaded balance.lua tables
-- Wind up effect / Charge the magics
function ENT:OnNewTarget( target, tarPos, direction, rangeSqr )
    if target and self.projectile then
        local unwound = Curtime() - self.shooterWindupEnd
        local wound = self.shooterWindupEnd - self.shooterWindupStart - unwound
        self.shooterWindupStart = CurTime() - wound
    elseif not target then
        self.shooterWindupEnd = CurTime()
    end
end


-- Wind up effect / Charge the magics
function ENT:OnShooterThink()
    local minRadius = self.projectileMinRadius
    if self.TargetEntity then
        if self.projectile then
            local windup = math.min((CurTime() - self.shooterWindupStart) / self.shooterWindup, 1)
            self.projectile:SetRadius(minRadius + (self.projectileMaxRadius - minRadius) * windup)
            if windup == 1 then
                self.shooterCanShoot = true
            end
        elseif not self:IsOnCooldown() then
            self.shooterWindupStart = CurTime()
            
            local pos = self:GetShootPos()
            local direction = self.TargetEntityDir:GetNormalized()
            self.projectile = ents.Create("wb_battlemage_projectile")
                self.projectile:SetPos(pos)
                self.projectile:SetAngles(direction:Angle())
                self.projectile:SetParent(self)
                self.projectile:SetTeam(self:GetTeam())
                self.projectile.minRadius = minRadius
                self.projectile.damage = self.damage
                self.projectile.force = self.projectileForce
                self.projectile.explosionRadius = self.projectileExplosionRadius
            self.projectile:Activate()
            self.projectile:Spawn()
            self.canHitFilter[self.projectile] = self.projectile
            self.projectile:CallOnRemove( "RemoveFromFilter"
                    , function(projectile)
                        if self.canHitFilter then
                            self.canHitFilter[projectile] = nil
                        end
                    end, self.projectile )
            
            -- emit some cool, loopable, sound
            self.windupSound:PlayEx(1, 200)
        end
    elseif self.projectile then
        local wound = self.shooterWindupEnd - self.shooterWindupStart
        local unwound = CurTime() - self.shooterWindupEnd
        local windup = math.max((wound - unwound) / self.shooterWindup, 0)
        
        self:SetRadius(minRadius + (self.projectileMaxRadius - minRadius) * windup)
        
        if wound <= unwound then
            self.projectile:Remove()
            self.projectile = nil
            self.windupSound:Stop()
        end
    end
end


function ENT:Shoot( targetEntity )
    self.shooterCanShoot = false
    
	local direction = self.TargetEntityDir:GetNormalized()
    local spread = self.spread + Angle(math.Rand(-self.spread.x, self.spread.x)
            , math.Rand(-self.spread.y, self.spread.y)
            , math.Rand(-self.spread.z, self.spread.z))
    direction:Rotate(spread) -- TODO fix
    
    direction:Normalize()
    --Vector(direction.x * spread.x, direction.y * spread.y, direction.z * spread.z)
    
	self.projectile:SetParent(nil)
    self.projectile:GetPhysicsObject():SetVelocity(direction*300)
    self.projectile:ScheduleExpiration()
    self.projectile = nil
    
    self.windupSound:Stop()
    self:EmitSound("NPC_Hunter.FlechetteShoot", 100, 100)
end


ENT.OverrideMixins["GetShootPos"] = {}
function ENT:GetShootPos()
    return self:LocalToWorld( self:OBBCenter() + self.localShootPos )
end