include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

local BaseClass = baseclass.Get("base_structure")


-- local references to commonly used functions
local v = FindMetaTable("Vector")
local LengthSqr = v.LengthSqr


-- Static helper functions
ConstructionYard = {}
function ConstructionYard.GetTableReference()
	return QueryableTagMixin.GetTableReference("ConstructionYard")
end
function ConstructionYard.GetTable()
	return QueryableTagMixin.GetTable("ConstructionYard")
end
function ConstructionYard.IsValid( constructionyard )
	return constructionyard and IsValid(constructionyard) and constructionyard.IsConstructionYard and constructionyard.IsAlive
end
function ConstructionYard.PointIsWithinInfluence( point, teem )
	assert(type(res) == "vector", "point of type " .. type(index) .. "  has to be a vector.")
	
	if teem then
		for k,v in pairs(constructionyards) do
			if (ConstructionYard.IsValid(v) and v:GetTeam() == teem) then
				local pos = v:GetPos()
				local direction = pos - point
				local rangeSqr = LengthSqr(direction)
				if (rangeSqr <= v.RangeSqr) then
					return true
				end
			end
		end
	else
		for k,v in pairs(constructionyards) do
			local pos = v:GetPos()
			local direction = pos - point
			local rangeSqr = LengthSqr(direction)
			if (rangeSqr <= v.RangeSqr) then
				return true
			end
		end
	end
	
	return false
end


-----------------------------------------------------------------------------------------


function ENT:Initialize()
	
	BaseClass.Initialize( self )
	
    -- TODO possible to check win condition in this callback
    self:AddTag( "ConstructionYard", function() self:RemoveCallOnRemove("RemoveConstructionYard") end )
	self:CallOnRemove( "RemoveConstructionYard", function() self:RemoveTag("ConstructionYard")  end )
	
	self.RangeSqr = math.pow(self.Range, 2)
	
	self:GetTeam():AddConstructionYard(self)
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	
end
