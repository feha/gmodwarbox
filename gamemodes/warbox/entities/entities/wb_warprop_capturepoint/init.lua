include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

DEFINE_BASECLASS( "base_warprop" )

-- local references to commonly used functions
local v = FindMetaTable("Vector")
local LengthSqr = v.LengthSqr


function ENT:Initialize()
	
	BaseClass.Initialize( self )
	
	
	self:SetTeam( WarboxTEAM.GetTeam(-2) )
	
	self.captured = nil
	
end


function ENT:Think ()
	
	if GetGameIsPaused() == 0 then
		
		self:GetContestants()
		
	end
	
	self:NextThink(CurTime() + self.Delay)
	return true
	
end


-- Get contestants for the point
function ENT:GetContestants()
	-- find all base_unit and derivatives in self.radius
end

-- Have a team contest for the point
-- Currently I am thinking that it will work like this:
-- If there is more than one team trying to contest a point, it is shown as "contested" and nothing happens.
-- Any contest progress is paused. Will each team share one progress and fight for it, or have one each?
-- If the latter, maybe have the progress paused only for the teams that are currently contesting.
-- If there is only one team contesting the point, it is shown as "contested" (different from with multiple?),
-- and the 'contest-progress' slowly raises until it is captured by that team. 
-- If there is no team trying to contest a point, it belongs to whatever team last captured it,
-- with any contest-progress slowly resetting.
-- Contest progress is inspired by bf2, with first having to de-capture the point, before it can start being captured again.
function ENT:Contest(teem)
	
end


-- Used when the point is captured
function ENT:Contest(teem)

	if not WarboxTEAM.IsTeam(teem) then return end
	
	-- did it belong to any team previously?
	if self.captured then
		self.captured.capturepoints[self] = nil
	end
	
	-- A timer is used to give each team their income. The amount is the sum of this table.
	teem.capturepoints[self] = self.Income
	
	-- Visual stuff is often nice
	self:SetColor( teem:GetColor() )
	
	-- Keep check on which team holds this point
	self.captured = teem
	
end
