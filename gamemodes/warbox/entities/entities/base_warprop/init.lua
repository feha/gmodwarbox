include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

local BaseClass = baseclass.Get("base_anim")
--ENT.BaseClass = baseclass.Get("base_anim")

-- Static helper functions
WarProp = {}
function WarProp.GetTableReference()
	return QueryableTagMixin.GetTableReference("WarProp")
end
function WarProp.GetTable()
	return QueryableTagMixin.GetTable("WarProp")
end
function WarProp.IsValid( warprop )
	return warprop and IsValid(warprop) and warprop.IsWarProp
end

-----------------------------------------------------------------------------------

function ENT:Initialize()
	
	BaseClass.Initialize( self )
	
    self:AddTag( "WarProp", function() self:RemoveCallOnRemove("RemoveWarProp") end )
	self:CallOnRemove( "RemoveWarProp", function() self:RemoveTag("WarProp")  end )
	
	-- make it static and change to physics in subclasses when needed?
	self:SetModel( self.Model )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
	local physics = self:GetPhysicsObject()
	if (physics:IsValid()) then
		physics:Wake()
		physics:SetBuoyancyRatio(self.Bouyancy or 0)
		physics:SetMaterial("metal")
		physics:EnableGravity(self.HasGravity)
	end
	
	if not self.StdMat then
		self:SetMaterial("models/debug/debugwhite")
	else
		self:SetMaterial(self.StdMat)
	end
    
end
