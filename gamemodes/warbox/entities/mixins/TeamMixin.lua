
assert(Mixins)

TeamMixin = Mixins.CreateMixin( TeamMixin, "Team" )

TeamMixin.expectedMixins =
{
}

TeamMixin.expectedCallbacks =
{
}

TeamMixin.optionalCallbacks =
{
}


function TeamMixin:Initialize()
    
	self:SetColor( self:GetTeam().Color )
    
end

