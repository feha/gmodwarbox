
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


-- Networked stuff
function TeamMixin:SetupDataTables() -- TODO Setup runs before init...
    
	self:NetworkVar( "Int", 0, "TeamID" )

end


    
if SERVER then
    function TeamMixin:Initialize()
        self:SetColor( self:GetTeam().Color )
    end
end


function TeamMixin:GetTeam()
	return WarboxTEAM.GetTeam(self:GetTeamID())
end

function TeamMixin:SetTeam( warboxTeam )
	self:SetTeamID( warboxTeam:GetIndex() )
end