include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

local BaseClass = baseclass.Get("base_structure")
--ENT.BaseClass = baseclass.Get("base_structure")

-- Static helper functions
Base_Unit = {}
function Base_Unit.GetTableReference()
	return QueryableTagMixin.GetTableReference("Base_Unit") -- Copying steals performance, this function is better used when it wont be modified.
end
function Base_Unit.GetTable()
	return QueryableTagMixin.GetTable("Base_Unit")
end
function Base_Unit.IsValid( unit )
	return Structure.IsValid(unit) and unit.IsUnit
end


-----------------------------------------------------------------------------------------


function ENT:Initialize()
	
	BaseClass.Initialize( self )
	
    self:AddTag( "Base_Unit", function() self:RemoveCallOnRemove("RemoveBase_Unit") end )
	self:CallOnRemove( "RemoveBase_Unit", function() self:RemoveTag("Base_Unit")  end )
    
	self:GetTeam():AddUnit(self) -- Unit count and such
	
end


-----------------------------------
--------- OVERRIDE THESE ----------
-----------------------------------

function ENT:Shoot( targetEntity )
	-- Do shooting stuff
end