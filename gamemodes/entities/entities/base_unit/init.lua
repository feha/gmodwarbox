include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

DEFINE_BASECLASS( "base_structure" )

-- Table used for "static" functions
Base_Unit = {}

-- When searching for stuff extending base_unit, this table should be faster.
local units = {}
function Base_Unit.GetTableReference()
	return units -- Copying steals performance, this function is better used when it wont be modified.
end
function Base_Unit.GetTable()
	return table.Copy(units)
end
function Base_Unit.Add(unit)
	assert(unit.CallOnRemove, "unit.CallOnRemove is nil. If you call Base_Unit.Remove(unit) manually, just create an empty function.")
	assert(type(unit.CallOnRemove) == "function", "Unit.CallOnRemove is not a function. If you call Base_Unit.Remove(unit) manually, just create an empty function.")
	
	table.insert( units, unit )
	unit:CallOnRemove( "RemoveUnit", Base_Unit.Remove )
end
function Base_Unit.Remove(unit)
	for k,v in pairs(units) do
		if (unit == v) then
			table.remove(units, k)
			v:RemoveCallOnRemove( "RemoveUnitFromSelection" )
			break
		end
	end
end



function ENT:Initialize()
	
	BaseClass.Initialize( self )
	
	
	self.IsUnit = true
	Base_Unit.Add(self)
	self:GetTeam():AddUnit(self) -- Unit count and such
	
	
	self.IsMobile = false
	self.IsShooter = false
	
end

--[[
function ENT:PhysicsUpdate( phys )
	
	if self.IsMobile and GetGameIsPaused() == 0 and not self.IsDead then
		
		local movePos, moveDirection, moveLengthSqr = nil
		
		local MoveVec = self.MoveVec -- localized reference.
		local FollowEnt = self.FollowEnt -- localized reference.
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
				table.remove( FollowEnt, 1 )
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


function ENT:Think ()
	
	if self.IsShooter an GetGameIsPaused() == 0 then
	
		if not self.Building and not self.IsDead then
			if not self.ForceTarget then
				local closestRange = nil
				self.Target = nil
				local pos = self:GetPos()
				local teem = self.GetTeam()
				for _,v in pairs(Structure.GetTableReference()) do
					if v:GetTeam() ~= teem and self:GetTargetPriority(v) > 0
							and self:GetTargetPriority(v) > self:GetTargetPriority(self.Target) then
						local tarPos = v:GetPos()
						local direction = tarPos - pos
						local range = LengthSqr(direction)
						if range <= self.RangeSqr then
							local filter = player.GetAll()
							table.insert(filter, self)
							local tracedata = {}
							tracedata.start = self:GetShootPos( direction )
							tracedata.endpos = tarPos
							tracedata.filter = filter
							local trace = util.TraceLine(tracedata)
							if trace.Entity == v then
								
								-- Will there be other stuff than range priorities?
								if  not closestRange or range < closestRange then
									closestRange = range
									self.Target = v
								end
								
							end
						end
					end
				end
			end
			
			if self.ForceTarget or self.Target then
				self:Shoot()
			end
			
		end
		
	end
	
	
	self.BaseClass.Think( self )
	
end

function ENT:GetShootPos( direction )
	local corner = (self:OBBMaxs() - self:OBBCenter)
	local radius = (corner.x < corner.y and corner.x < corner.z and corner.x) or (corner.y < corner.x and corner.y < corner.z and corner.y) or (corner.z < corner.x and corner.z < corner.y and corner.z)
	return self:LocalToWorld( self.LocalShootPos ) + Normalized(direction) * radius
end

-- Can be overwritten for classes with priorities impossible to set using Priority table (balance.lua)
-- Higher number = higher priority; 0 means not a target.
function ENT:GetTargetPriority( entity )
	if not entity return 0 end
	 -- Stuff not in priority list, but extending structure or unit, is still a target
	return self.Balance.Priority[entity:GetClass()]
		or entity.IsUnit and 20
		or entity.isStructure and 10
		or 0
end
--]]