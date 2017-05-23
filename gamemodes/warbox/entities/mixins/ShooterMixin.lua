
assert(Mixins)

ShooterMixin = Mixins.CreateMixin( ShooterMixin, "Shooter" )

ShooterMixin.expectedMixins =
{
    Targeting = "GetTarget needed to find targets to shoot."
}

ShooterMixin.expectedCallbacks =
{
    Shoot = "Called when shooting. Takes a target-entity as argument."
}

ShooterMixin.optionalCallbacks =
{
}


function ShooterMixin:Initialize()
    
	self.LocalShootPos = self:OBBCenter()
    
end


function ShooterMixin:Think()
    
	if GetGameIsPaused() == 0 then
		
		if not self.Building and self.IsAlive and self.IsAi then
			
			self:GetTarget()
			target = self.TargetEntity
			
			if self.IsShooter and target then
				self:Shoot(target)
			end
			
		end
		
	end
	
	self:NextThink(CurTime() + self.Delay)
	return true
	
end
