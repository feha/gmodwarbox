include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

local BaseClass = baseclass.Get("base_unit")

-- local references to commonly used functions and libraries
local v = FindMetaTable("Vector")
local GetNormal = v.GetNormal


function ENT:Initialize()
	
	BaseClass.Initialize( self )
    
    self.localShootPos = Vector(0,0,30)
    self.shooterCanShoot = false
    self.windupSound = CreateSound(self, "vehicles/airboat/fan_blade_idle_loop1.wav")
    self:EmitSound("NPC_Hunter.FlechetteShoot.wav", 100, 100)
    self:CallOnRemove( "RemoveWindup"
            , function()
                if IsValid(sound) then
                    sound:Stop()
                end
            end, self.windupSound)
	
end

-- TODO make the effect strings loaded balance.lua tables
-- Wind up effect / Charge the magics
function ENT:OnNewTarget( target, tarPos, direction, rangeSqr )
    if target and self.projectile then
        local unwound = CurTime() - self.shooterWindupEnd
        local wound = self.shooterWindupEnd - self.shooterWindupStart - unwound
        self.shooterWindupStart = CurTime() - wound
    elseif not target then
        self.shooterWindupEnd = CurTime()
    end
end


-- Wind up effect / Charge the magics
function ENT:OnShooterThink()
    local minRadius, maxRadius = self.projectileMinRadius, self.projectileMaxRadius
    if self.TargetEntity then
        if self.projectile then
            local windup = math.min((CurTime() - self.shooterWindupStart) / self.shooterWindup, 1)
            local r = minRadius + (maxRadius - minRadius) * windup
            self.projectile:SetRadius(r)
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
                self.projectile:SetOwner(self)
                self.projectile:SetTeam(self:GetTeam())
                self.projectile.minRadius = minRadius
                self.projectile.maxRadius = maxRadius
                self.projectile.damage = self.damage
                self.projectile.force = self.projectileForce
                self.projectile.explosionRadius = self.projectileExplosionRadius
            self.projectile:Activate()
            self.projectile:Spawn()
            self.canHitFilter[self.projectile] = self.projectile
            self.projectile:CallOnRemove( "RemoveProjectile"
                    , function(projectile)
                        if IsValid(self) then
                            self.canHitFilter[projectile] = nil
                            self.windupSound:Stop()
                        end
                    end, self.projectile )
            
            -- emit some cool, loopable, sound
            self.windupSound:PlayEx(1, 200)
        end
    elseif self.projectile then
        local wound = self.shooterWindupEnd - self.shooterWindupStart
        local unwound = CurTime() - self.shooterWindupEnd
        local windup = math.max((wound - unwound) / self.shooterWindup, 0)
        
        self.projectile:SetRadius(minRadius + (maxRadius - minRadius) * windup)
        
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
    local spread = Angle(math.Rand(-self.spread.x, self.spread.x)
            , math.Rand(-self.spread.y, self.spread.y)
            , math.Rand(-self.spread.z, self.spread.z))
    direction:Rotate(spread)
    direction:Normalize()
    
	self.projectile:SetParent(nil)
    self.projectile:GetPhysicsObject():SetVelocity(direction * self.projectileSpeed)
    self.projectile:ScheduleExpiration()
    self.projectile = nil
    self.windupSound:Stop()
    
    --self:EmitSound("npc/strider/strider_minigun.wav", 100, 100)
    self:EmitSound("npc/strider/fire.wav", 55, 200)
end


ENT.OverrideMixins={}
ENT.OverrideMixins["GetShootPos"] = {}
function ENT:GetShootPos()
    return self:LocalToWorld( self:OBBCenter() + self.localShootPos )
end