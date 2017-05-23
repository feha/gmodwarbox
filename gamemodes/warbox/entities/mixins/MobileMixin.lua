
assert(Mixins)

MobileMixin = Mixins.CreateMixin( MobileMixin, "Mobile" )

MobileMixin.expectedMixins =
{
    Balance = "Loads values such as speed."
}

MobileMixin.expectedCallbacks =
{
}

MobileMixin.optionalCallbacks =
{
}


-- local references to commonly used functions and libraries
local v = FindMetaTable("Vector")
local LengthSqr = v.LengthSqr
local GetNormal = v.GetNormal


function MobileMixin:Initialize()
	self.SpeedSqr		=	math.pow(self.Speed, 2)
	self.MoveRangeSqr	=	math.pow(self.MoveRange, 2)
end


function MobileMixin:PhysicsUpdate( phys )
--function ENT:PhysicsSimulate( phys, deltatime ) 
	
	if GetGameIsPaused() == 0 and self.IsMobile then
		
		-- entities fall asleep when they come ot a rest
		-- this should fix that.
		-- For optimization, let it sleep like it wants, and move waking to ordering melons.
		-- like a setorder or whatever
		phys:Wake()
		
		if self.IsAlive and not self.Building then
			
			
			local movePos, moveDirection, moveLengthSqr = nil
			
			local MoveVec = self.MoveVec -- localized reference.
			local FollowEnt = self.FollowEnt -- localized reference.
			if FollowEnt ~= nil and FollowEnt[1] ~= nil then
				local ent = FollowEnt[1]
				
				if not IsValid(ent) or ent.IsAlive == false then
					table.remove( FollowEnt, 1 )
				else
					movePos = ent.GetPos()
				end
			elseif MoveVec ~= nil and MoveVec[1] ~= nil then
				local vec = MoveVec[1]
				
				local moveDirection = vec - self:GetPos()
				local lengthSqr = LengthSqr(moveDirection)
				if lengthSqr < self.MoveRangeSqr then
					table.remove( MoveVec, 1 )
					if self.Patrolling then
						table.insert( MoveVec, vec )
					end
				else
					movePos = vec
				end
				
			end
			
			if movePos then
				moveDirection = moveDirection or movePos - self:GetPos()
				moveLengthSqr = moveLengthSqr or LengthSqr(moveDirection)
				--phys:SetDamping(2, 0)
				if moveLengthSqr > self.MoveRangeSqr then
					if LengthSqr(self:GetVelocity()) < self.SpeedSqr or self.HasGravity == false then
						phys:ApplyForceCenter(GetNormal( moveDirection ) * self.Speed)
					end
				else
					if self.HasGravity == false then
						self:SetVelocity(self:GetVelocity() * 0.1) -- use drag instead?
					end
					
					if #TargetVec > 1 then
						table.insert( TargetVec, table.remove(TargetVec,1) ) -- Move first to last
					else
						self.TargetVec = nil -- Has to use self, since this operation doesnt change the table
					end
				end
			end
		
		end
		
	end
	
end