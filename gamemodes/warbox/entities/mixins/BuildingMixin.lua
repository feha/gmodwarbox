
assert(Mixins)

BuildingMixin = Mixins.CreateMixin( BuildingMixin, "Building" )

BuildingMixin.expectedMixins =
{
}

BuildingMixin.expectedCallbacks =
{
}

BuildingMixin.optionalCallbacks =
{
}


function BuildingMixin:Initialize()
    
	self.Building		= self.BuildTime > 0 and true
	self.BuildProgress	= self.BuildTime > 0 and 0 or 1
	self.InitTime		= CurTime()
	self.LastBuild		= self.InitTime
    
	-- Networked variables
    --self:SetNetworkedInt("WB_BuildProgress", math.floor( self.BuildProgress * 100 ) )
    
    
	self:SetColor( self:GetTeam().Color )
	local color = self:GetColor()
	color.a = 100 + 155 * self.BuildProgress -- move base alpha to Balance.lua?
	self:SetColor(color)
	
	if self.Building then
		self:SheduleBuilding()
	end
    
end

function BuildingMixin:SheduleBuilding() -- looks cooler than copypasting this timer when I want to start building
	-- move delay to Balance-lua?
	timer.Simple( 1, function() if self.Build then self:Build() end end )
end

function BuildingMixin:Build()
	if GetGameIsPaused() == 0 then
		
		if WarProp.IsValid( self ) and self.Building then
			local timeDiff = CurTime() - self.InitTime
			local deltatime = CurTime() - self.LastBuild
			self.BuildProgress = math.min(timeDiff/self.BuildTime, 1)
			self.Building = self.BuildProgress < 1
			
			local color = self:GetColor()
            local base_alpha = 100 -- move base alpha to Balance.lua?
			color.a = base_alpha + (255-base_alpha) * self.BuildProgress
			self:SetColor(color)
			
			if self.OnBuild then
				self:OnBuild(deltatime)
			end
			
			self.LastBuild = CurTime()
            
			if self.Building then
				self:SheduleBuilding()
			end
		end
		
	end
end
