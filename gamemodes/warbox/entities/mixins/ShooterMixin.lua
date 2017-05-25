
assert(Mixins)

ShooterMixin = Mixins.CreateMixin( ShooterMixin, "Shooter" )

ShooterMixin.expectedMixins =
{
    Targeting = "GetTarget needed to find targets to shoot."
}

ShooterMixin.expectedCallbacks =
{
}

ShooterMixin.optionalCallbacks =
{
    Shoot = "Called when shooting. Takes a target-entity as argument.",
    OnShooterHasTarget = "Called during Shooter's `Think()` whenever Shooter has a target",
    OnShooterThink = "Called during Shooter's `Think()`, after `GetTarget()` of Shooter",
}


--[[ TODO figure out if, and how, I want to make variables that should exist, exists.
ShooterMixin.shooterNextShot = nil,
--]]


if SERVER then

    function ShooterMixin:Think()

        local curtime = CurTime()
        
        if GetGameIsPaused() == 0 then
            
            if not self.Building and self.IsAlive and self.IsAi then
                
                self:GetTarget()
                
                if self.IsShooter then
                    if self.OnShooterThink then
                        self:OnShooterThink()
                    end
                end
                
                if self.IsShooter and self.TargetEntity then
                    if self.OnShooterHasTarget then
                        self:OnShooterHasTarget(self.TargetEntity)
                    end
                    if self:GetCanShoot(curtime) then
                        self.shooterNextShot = curtime + self.shooterCooldown
                        if self.Shoot then
                            self:Shoot(self.TargetEntity)
                        end
                    end
                end
                
            end
            
        end
        
        self:NextThink(curtime + self.Delay)
        return true
        
    end


    function ShooterMixin:GetCanShoot(curtime)
        
        return self.shooterCanShoot and not self:IsOnCooldown(curtime)
        
    end


    function ShooterMixin:IsOnCooldown(curtime)
        
        return (self.shooterNextShot or 0) > (curtime or CurTime())
        
    end
end