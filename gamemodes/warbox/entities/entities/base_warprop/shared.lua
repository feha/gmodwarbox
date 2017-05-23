ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Author = "Feha"

--DEFINE_BASECLASS( "base_anim" )

--ENT.Spawnable = false
--ENT.AdminSpawnable = false


function ENT:GetWBType()
	return self:GetClass()
end


-- Networked stuff
function ENT:SetupDataTables()

	self:NetworkVar( "Int", 0, "TeamID" )

end

function ENT:GetTeam()
	return WarboxTEAM.GetTeam(self:GetTeamID())
end

function ENT:SetTeam( warboxTeam )
	self:SetTeamID( warboxTeam:GetIndex() )
end
