include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

local BaseClass = baseclass.Get("base_warprop")
--ENT.BaseClass = baseclass.Get("base_warprop")

-- Likely to move mixin includes to mixin.lua or similar
include("mixins/HealthMixin.lua")
include("mixins/QueryableTagMixin.lua")
Mixins.RegisterMixin(ENT, HealthMixin)
Mixins.RegisterMixin(ENT, QueryableTagMixin)


-- local references to commonly used functions
local v = FindMetaTable("Vector")
local LengthSqr = v.LengthSqr


-- Static helper functions
Structure = {}
function Structure.GetTableReference()
	return QueryableTagMixin.GetTableReference("Structure") -- Copying steals performance, this function is better used when it wont be modified.
end
function Structure.GetTable()
	return QueryableTagMixin.GetTable("Structure")
end
function Structure.IsValid( structure )
	return structure and IsValid(structure) and structure.IsStructure and structure.IsAlive
end
----[[
function Structure.UpdateNetworkedVariables( )
	for k, ply in pairs(player.GetAll()) do
		local entity = ply:GetEyeTrace().Entity
		if Structure.IsValid( entity ) and LengthSqr(ply:GetPos() - entity:GetPos()) < Balance.notsorted.WorldTipDisplayRangeSqr then
			-- Might change from networked vars to something like net-lib
			entity:SetNetworkedInt("WB_MaxHealth", math.floor(entity.MaxHealth))
			entity:SetNetworkedInt("WB_CurHealth", math.floor(entity.CurHealth))
			entity:SetNetworkedFloat("WB_BuildProgress", entity.BuildProgress)
		end
	end
end
timer.Create( "Structure.UpdateNetworkedVariables", Balance.notsorted.WorlTipUpdateRate, 0, Structure.UpdateNetworkedVariables )
--]]

-----------------------------------------------------------------------------------------


function ENT:Initialize()
	
	BaseClass.Initialize( self )
    
    self.InitializeMixins( self ) -- Want this to run after all functions has been created.
	
    self:AddTag( "Structure", function() self:RemoveCallOnRemove("RemoveStructure") end )
	self:CallOnRemove( "RemoveStructure", function() self:RemoveTag("Structure")  end )
	
    self.PostInitializeMixins( self )
    
end