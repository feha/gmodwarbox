include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

DEFINE_BASECLASS( "base_structure" )


-- local references to commonly used functions
local v = FindMetaTable("Vector")
local LengthSqr = v.LengthSqr


-- Table used for "static" functions
ConstructionYard = {}

-- When searching for stuff extending base_structure, this table should be faster.
local constructionyards = {}
function ConstructionYard.GetTableReference()
	return constructionyards -- Copying steals performance, this function is better used when it wont be modified.
end
function ConstructionYard.GetTable()
	return table.Copy(constructionyards)
end
function ConstructionYard.Add(constructionyard)
	assert(constructionyard.CallOnRemove, "constructionyard.CallOnRemove is nil. If you call ConstructionYard.Remove(constructionyard) manually, just create an empty function.")
	assert(type(constructionyard.CallOnRemove) == "function", "constructionyard.CallOnRemove is not a function. If you call ConstructionYard.Remove(constructionyard) manually, just create an empty function.")
	
	table.insert( constructionyards, constructionyard )
	constructionyard:CallOnRemove( "RemoveStructure", ConstructionYard.Remove )
end
function ConstructionYard.Remove(constructionyard)
	for k,v in pairs(constructionyards) do
		if (constructionyard == v) then
			table.remove(constructionyards, k)
			v:RemoveCallOnRemove( "RemoveStructureFromSelection" )
			break
		end
	end
	
	-- TODO: Check victory-condition (if all constructionyards left belong to same team, they win
end


-- Static helper functions
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
	
	self.RangeSqr = math.pow(self.Range, 2)
	
	ConstructionYard.Add(self)
	self:GetTeam():AddConstructionYard(self)
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	
end
