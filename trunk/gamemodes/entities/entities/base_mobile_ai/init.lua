include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

DEFINE_BASECLASS( "base_ai" )

-- local references to commonly used functions
local v = FindMetaTable("Vector")
local LengthSqr = v.LengthSqr


function ENT:Initialize()
	
	BaseClass.Initialize( self )
	
	-- Fields defualt values
	self.Speed			=	self.Balance.Speed
	self.MoveRange		=	self.Balance.MoveRange

	self.SpeedSqr		=	math.pow(self.Speed, 2)
	self.MoveRangeSqr	=	math.pow(self.MoveRange, 2)
	
	
	self.IsMobile = true
	
end


-- TODO???
-- Maybe, rather than 1 class for movement and one for ai and one for both.
-- How about making a bool for mobile units and keep the movement code in the ai class?
-- If I really want classes like this, these classes could just be setting those bools.
-- Damn I wish I had mixins :P
function ENT:PhysicsUpdate( phys )
	
	if GetGameIsPaused() == 0 then
		
		if not self.IsDead and self.IsMobile then
			
			local movePos, moveDirection, moveLengthSqr = nil
			
			local MoveVec = self.MoveVec -- localized reference, Be aware of using '=' operator
			local FollowEnt = self.FollowEnt -- localized reference, Be aware of using '=' operator
			if FollowEnt ~= nil and FollowEnt[1] ~= nil then
				local ent = FollowEnt[1]
				
				if not ent:IsValid() or ent.IsDead then
					table.remove( FollowEnt, 1 )
				else
					movePos = ent.GetPos()
				end
			elseif MoveVec ~= nil and MoveVec[1] ~= nil then
				local vec = MoveVec[1]
				
				local moveDirection = vec - self:GetPos()
				local lengthSqr = LenthSqr(direction)
				if len > self.MoveRangeSqr then
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
				moveLengthSqr = moveLengthSqr or LenthSqr(moveDirection)
				--phys:SetDamping(2, 0)
				if moveLengthSqr > self.MoveRangeSqr then
					if LengthSqr(self:GetVelocity()) < self.SpeedSqr or self.HasGravity == false then
						phys:ApplyForceCenter(moveDirection:Normalize() * self.MovingForce)
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
