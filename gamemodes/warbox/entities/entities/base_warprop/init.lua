include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

local BaseClass = baseclass.Get("base_anim")
--ENT.BaseClass = baseclass.Get("base_anim")

include("mixins/BalanceMixin.lua")
include("mixins/QueryableTagMixin.lua")
include("mixins/TeamMixin.lua")
include("mixins/BuildingMixin.lua")
Mixins.RegisterMixin(ENT, BalanceMixin)
Mixins.RegisterMixin(ENT, QueryableTagMixin)
Mixins.RegisterMixin(ENT, TeamMixin)
Mixins.RegisterMixin(ENT, BuildingMixin)

-- local references to commonly used functions
local v = FindMetaTable("Vector")
local LengthSqr = v.LengthSqr


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
----[[
function WarProp.UpdateNetworkedVariables( )
	for k, ply in pairs(player.GetAll()) do
		local entity = ply:GetEyeTrace().Entity
		if WarProp.IsValid( entity ) and LengthSqr(ply:GetPos() - entity:GetPos()) < Balance.notsorted.WorldTipDisplayRangeSqr then
			-- Might change from networked vars to something like net-lib
			entity:SetNetworkedInt("WB_BuildProgress", math.floor( entity.BuildProgress * 100 ) )
		end
	end
end
timer.Create( "WarProp.UpdateNetworkedVariables", Balance.notsorted.WorlTipUpdateRate, 0, WarProp.UpdateNetworkedVariables )
--]]

-----------------------------------------------------------------------------------------


function ENT:Initialize()
	
	BaseClass.Initialize( self )
    
    self.InitializeMixins( self )
	
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
	
    self.PostInitializeMixins( self )
    
end
