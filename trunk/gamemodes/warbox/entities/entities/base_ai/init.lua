include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

DEFINE_BASECLASS( "base_unit" )

-- local references to commonly used functions
local v = FindMetaTable("Vector")
local LengthSqr = v.LengthSqr
local Normalized = v.Normalized


function ENT:Initialize()
	
	BaseClass.Initialize( self )
	
	-- Fields defualt values
	self.Range			=	self.Balance.Range

	self.RangeSqr		=	math.pow(self.Range, 2)

	
	self.IsAi = true
	self.LocalShootPos = self:OBBCenter()
	
end


function ENT:Think ()
	
	if GetGameIsPaused() == 0 then
	
		if not self.Building and not self.IsDead and self.IsShooter then
			
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

-- Can be overwritten for classes with target priorities impossible to set using Priority table.
-- Higher number = higher priority; 0 means not a target.
function ENT:GetTargetPriority( entity )
	if not entity return 0 end
	 -- Stuff not in priority list, but extending structure or unit, is still a target
	return self.Balance.Priority[entity:GetClass()]
		or entity.IsUnit and 20
		or entity.isStructure and 10
		or 0
end


function ENT:Shoot( )
	-- Do shooting stuff
end
