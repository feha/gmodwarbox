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
	self.contestingTeam = nil
	self.contestProgress = 0
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	
	-- Networked variables
    self:SetNetworkedInt("WB_ContestProgress", math.floor( self.contestProgress * 100 ) )
    self:SetNetworkedInt("WB_ContesterID", -2) -- Should not matter while contestProgress = 0
	
end


function ENT:Think()
	local deltatime = CurTime() - (self.LastThink or CurTime())
	
	if GetGameIsPaused() == 0 then
		
		local contestants, numcontestants = self:GetContestants()
		
		self:CheckContest( contestants, numcontestants, deltatime )
		
	end
	
	self.LastThink = CurTime()
	
	self:NextThink(self.LastThink + self.Delay)
	return true
	
end

-- Have a team contest for the point
-- Currently I am thinking that it will work like this:
-- Contest progress is inspired by bf2, probably with first having to de-capture the point,
-- before it can start being captured again.


function ENT:SetContestingTeam( teem )
	
	self.contestingTeam = teem
	self:SetNetworkedInt("WB_ContesterID", self.contestingTeam:GetIndex() )
	
end

function ENT:AddContestProgress( progress )
	
	self.contestProgress = math.max( math.min( self.contestProgress + progress, 1 ), 0)
	self:SetNetworkedInt("WB_ContestProgress", math.floor( self.contestProgress * 100 ) )
	
end


-- Get contestants for the point
function ENT:GetContestants()
	
	local contestants = {}
	local numcontestants = 0
	
	local teem
	local pos = self:GetPos()
	for _,contestant in pairs(Base_Unit.GetTableReference()) do
		if Base_Unit.IsValid(contestant) and contestant.IsAlive and not contestant.Building then
			local unitpos = contestant:GetPos()
			local direction = unitpos - pos
			local rangeSqr = LengthSqr(direction)
			if rangeSqr > self.Range then
				numcontestants = teem == contestant:GetTeam() and numcontestants or numcontestants + 1
				teem = contestant:GetTeam()
				local multiplier = contestant.CaptureMultiplier or 1
				contestants[teem] = contestants[teem] or 0
				contestants[teem] = contestants[teem] + 1 * multiplier or 1 * multiplier
			end
		end
	end
	
	return contestants, numcontestants
	
end

function ENT:CheckContest( contestants, numcontestants, deltatime )
	
	if numcontestants > 1 then
		
		-- If there is more than one team trying to contest a point, it is shown as "contested" and nothing happens.
		-- Any contest progress is paused. Will each team share one progress and fight for it, or have one each?
		-- If the latter, maybe have the progress paused only for the teams that are currently contesting.
		-- The others slowly decrease.
		
	elseif numcontestants == 1 then
		
		-- If there is only one team contesting the point, it is shown as "contested" (different from with multiple?),
		-- and the 'contest-progress' slowly raises until it is captured by that team. 
		for teem,number in pairs(contestants) do
			self:Contest( teem, number, deltatime )
		end
		
	else
		
		-- If there is no team trying to contest a point, it belongs to whatever team last captured it,
		-- with any contest-progress slowly resetting.
		if self.contestProgress > 0 then
			self:AddContestProgress( -0.1 * deltatime )
		end
		
	end
	
end


function ENT:Contest( teem, number, deltatime )
	
	if not self.captured or self.captured ~= teem then
		
		if self.contestProgress == 0 then
			
			self:SetContestingTeam( teem )
			
		end
		
		local progress = (number / self.TimeToCapture) * deltatime
		
		-- Add progress if its your progress, subtract otherwise
		self:AddContestProgress( self.contestingTeam == teem and progress or (progress * -1) )
		
		if self.contestProgress >= 1 then
			self:Capture(teem)
		elseif self.contestProgress == 0 and self.captured then
			self:Liberate() -- Liberate/De-capture the point if a team held it prior to this
		end
	end
	
end


-- Used when the point is captured
function ENT:Capture(teem)
	
	if not WarboxTEAM.IsTeam(teem) then return end
	
	-- A timer is used to give each team their income. The amount is the sum of this table.
	teem.capturepoints = teem.capturepoints or {}
	teem.capturepoints[self] = self.Income
	teem:AddIncome(self.Income) -- Or should income be in teems be default?
	-- lets think about this
	
	-- Visual stuff is often nice
	self:SetColor( teem:GetColor() )
	
	-- Keep check on which team holds this point
	self.captured = teem
	
end

-- Used when a captured point is liberated
function ENT:Liberate()
	
	-- did it belong to any team previously?
	if self.captured then
		if not WarboxTEAM.IsTeam(self.captured) then return end
		
		self.captured.capturepoints = self.captured.capturepoints or {}
		if self.captured.capturepoints[self] then
			self.captured.capturepoints[self] = nil
			self.captured:AddIncome(-self.Income)
		end
		
		self.captured = nil
	end
	
	-- Visual stuff is often nice
	self:SetColor( self:GetTeam():GetColor() )
	
end
