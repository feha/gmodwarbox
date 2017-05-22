include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

DEFINE_BASECLASS( "base_warprop" )

-- Likely to move mixin includes to mixin.lua or similar
include("../mixins/HealthMixin.lua")
Mixins.RegisterMixin(ENT, Mixins.HealthMixin)


-- local references to commonly used functions
local v = FindMetaTable("Vector")
local LengthSqr = v.LengthSqr


-- Table used for "static" functions
Structure = {}

-- When searching for stuff extending base_structure, this table should be faster.
local structures = {}
function Structure.GetTableReference()
	return structures -- Copying steals performance, this function is better used when it wont be modified.
end
function Structure.GetTable()
	return table.Copy(structures)
end
function Structure.Add(structure)
	assert(structure.CallOnRemove, "structure.CallOnRemove is nil. If you call Structure.Remove(structure) manually, just create an empty function.")
	assert(type(structure.CallOnRemove) == "function", "structure.CallOnRemove is not a function. If you call Structure.Remove(structure) manually, just create an empty function.")
	
	table.insert( structures, structure )
	structure:CallOnRemove( "RemoveStructure", Structure.Remove )
end
function Structure.Remove(structure)
	for k,v in pairs(structures) do
		if (structure == v) then
			table.remove(structures, k)
			v:RemoveCallOnRemove( "RemoveStructureFromSelection" )
			break
		end
	end
end


-- Static helper functions
function Structure.IsValid( structure )
	return structure and IsValid(structure) and structure.IsStructure and structure.IsAlive
end


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

-----------------------------------------------------------------------------------------


function ENT:Initialize()
	
	BaseClass.Initialize( self )
    
    self.InitializeMixins( self ) -- Want this to run after all functions has been created.
	
	Structure.Add( self )
	
end