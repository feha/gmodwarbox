
assert(Mixins)

TargetingMixin = Mixins.CreateMixin( TargetingMixin, "Targeting" )

TargetingMixin.expectedMixins =
{
    Balance = "Loads values such as range."
}

TargetingMixin.expectedCallbacks =
{
}

TargetingMixin.optionalCallbacks =
{
    GetTarget = "Called when *** looks for a target.",
    GetTargetPriority = "Called when targetting to prioritize targets.",
    GetCanHit = "Called to verify that target is possible to hit."
}


-- local references to commonly used functions and libraries
local v = FindMetaTable("Vector")
local Length = v.Length
local LengthSqr = v.LengthSqr
local Distance = v.Distance
local GetNormal = v.GetNormal


function TargetingMixin:Initialize()
	self.RangeSqr = math.pow(self.Range, 2)
end


function TargetingMixin:GetTarget()
    
	local pos = self:GetPos()
	if self.ForceTarget and Structure.IsValid(self.ForceTarget) then
		local tarPos = self.ForceTarget:GetPos() --self.ForceTarget:NearestPoint(pos)
		local direction = tarPos - pos
		local rangeSqr = LengthSqr(direction)
		self.TargetEntityDir = direction
		if self:GetCanHit(self.ForceTarget, tarPos, direction, rangeSqr) then
			self.TargetEntity = self.ForceTarget
			return self.TargetEntity
		end
	end
	
	if self.TargetEntity and Structure.IsValid(self.TargetEntity) then
		local tarPos = self.TargetEntity:GetPos() --self.TargetEntity:NearestPoint(pos)
		local direction = tarPos - pos
		local rangeSqr = LengthSqr(direction)
		self.TargetEntityDir = direction
		
		if self:GetCanHit(self.TargetEntity, tarPos, direction, rangeSqr) then
			return self.TargetEntity
		end
	end
	
	
	local target = nil
	local closestRangeSqr = nil
	local teem = self:GetTeam()
	for _,v in pairs(Structure.GetTableReference()) do
		if Structure.IsValid(v) and v ~= self then
			if v:GetTeam() ~= teem and self:GetTargetPriority(v) > 0
					and self:GetTargetPriority(v) >= self:GetTargetPriority(target) then
				local tarPos = v:GetPos() --v:NearestPoint(pos)
				local direction = tarPos - pos
				local rangeSqr = LengthSqr(direction)
				if self:GetCanHit(v, tarPos, direction, rangeSqr) then
					
					-- Will there be other stuff than range priorities?
					if not closestRangeSqr or rangeSqr < closestRangeSqr then
						closestRangeSqr = rangeSqr
						target = v
						self.TargetEntityDir = direction
					end
					
				end
			end
		end
	end
	
	self.TargetEntity = target
	return target
	
end

function TargetingMixin:GetShootPos( direction )
	local corner = (self:OBBMaxs() - self:OBBCenter())
	local radius = (corner.x < corner.y and corner.x < corner.z and corner.x) or (corner.y < corner.x and corner.y < corner.z and corner.y) or (corner.z < corner.x and corner.z < corner.y and corner.z)
	return self:LocalToWorld( self.LocalShootPos ) + GetNormal(direction) * radius
end


--- Can be overwritten for classes with target priorities impossible to set using Priority table.
-- Higher number = higher priority; 0 means not a target.
function TargetingMixin:GetTargetPriority( target )
	if not target then return 0 end
	
	 -- Stuff in priority list sets priority, but this can be modified for dynamic purposes if needed
	 -- Since list only takes classnames, we also check if its a unit or structure
	 -- Example of usage: Some sort of flak unit is likely to prioritize hoverballs and such.
	return self.Priority[target:GetClass()]
            or target.IsUnit and 20
            or target.IsStructure and 10
            or 0
end


function TargetingMixin:GetCanHit( target, tarpos, direction, rangeSqr )
	if rangeSqr <= self.RangeSqr then
		local filter = player.GetAll()
		table.insert(filter, self)
		local tracedata = {}
			tracedata.start = self:GetShootPos( direction )
			tracedata.endpos = tarpos-- + direction
			tracedata.filter = filter
		local trace = util.TraceLine(tracedata)
		
		return trace.Entity == target
	end
	
	return false
end