include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

DEFINE_BASECLASS( "base_structure" )

-- local references to commonly used functions and libraries
local v = FindMetaTable("Vector")
local Length = v.Length
local LengthSqr = v.LengthSqr
local Distance = v.Distance
local GetNormal = v.GetNormal


-- Table used for "static" functions
Base_Unit = {}

-- When searching for stuff extending base_unit, this table might be faster (has to be tested).
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


-----------------------------------------------------------------------------------------


function ENT:Initialize()
	
	BaseClass.Initialize( self )
	
	self.IsUnit = true
	self.IsAi = false
	self.IsMobile = false
	self.IsShooter = false
	
	self.LocalShootPos = self:OBBCenter()
	
	Base_Unit.Add(self)
	self:GetTeam():AddUnit(self) -- Unit count and such
	
end


-- code for mobile units
function ENT:PhysicsUpdate( phys )
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


-- code for ai-units
function ENT:Think ()
	
	if GetGameIsPaused() == 0 then
		
		if not self.Building and self.IsAlive and self.IsAi then
			
			self:GetTarget()
			target = self.TargetEntity
			
			if self.IsShooter and target then
				self:Shoot(target)
			end
			
		end
		
	end
	
	Structure.ENT.Think( self )
	
end



------------------------------------------
-------- Might get overriden ----------
------------------------------------------

function ENT:GetTarget()
	local pos = self:GetPos()
	if self.ForceTarget and Structure.IsValid(self.ForceTarget) then
		local tarPos = self.ForceTarget:GetPos()
		local direction = tarPos - pos
		
		if LengthSqr(direction) <= self.RangeSqr then
			local filter = player.GetAll()
			table.insert(filter, self)
			local tracedata = {}
				tracedata.start = self:GetShootPos( direction )
				tracedata.endpos = tarPos
				tracedata.filter = filter
			local trace = util.TraceLine(tracedata)
			
			if trace.Entity == self.ForceTarget then
				self.TargetEntity = self.ForceTarget
				return self.TargetEntity
			end
		end
	end
	
	if self.TargetEntity and Structure.IsValid(self.TargetEntity) then
		local tarPos = self.TargetEntity:GetPos()
		local direction = tarPos - pos
		
		if LengthSqr(direction) <= self.RangeSqr then
			local filter = player.GetAll()
			table.insert(filter, self)
			local tracedata = {}
				tracedata.start = self:GetShootPos( direction )
				tracedata.endpos = tarPos
				tracedata.filter = filter
			local trace = util.TraceLine(tracedata)
			
			if trace.Entity == self.TargetEntity then
				return self.TargetEntity
			end
		end
	end
	
	
	local target = nil
	local closestRange = nil
	local teem = self:GetTeam()
	for _,v in pairs(Structure.GetTableReference()) do
		if Structure.IsValid(v) and v ~= self then
			if v:GetTeam() ~= teem and self:GetTargetPriority(v) > 0
					and self:GetTargetPriority(v) > self:GetTargetPriority(target) then
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
							target = v
						end
						
					end
				end
			end
		end
	end
	
	self.TargetEntity = target
	return target
	
end

function ENT:GetShootPos( direction )
	local corner = (self:OBBMaxs() - self:OBBCenter())
	local radius = (corner.x < corner.y and corner.x < corner.z and corner.x) or (corner.y < corner.x and corner.y < corner.z and corner.y) or (corner.z < corner.x and corner.z < corner.y and corner.z)
	return self:LocalToWorld( self.LocalShootPos ) + GetNormal(direction) * radius
end

-- Can be overwritten for classes with target priorities impossible to set using Priority table.
-- Higher number = higher priority; 0 means not a target.
function ENT:GetTargetPriority( target )
	if not target then return 0 end
	
	 -- Stuff not in priority list, but extending structure or unit, is still a target
	 -- Example of usage: Some sort of flak unit is likely to prioritize hoverballs and such.
	return self.Balance.Priority[target:GetClass()]
		or target.IsUnit and 20
		or target.IsStructure and 10
		or 0
end


-----------------------------------
--------- OVERRIDE THESE ----------
-----------------------------------

function ENT:Shoot( targetEntity )
	-- Do shooting stuff
end