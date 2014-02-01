include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

DEFINE_BASECLASS( "base_warprop" )

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
	
	Structure.Add(self)
	
	self.IsAlive		=	true
	self.CurHealth		=	self.MaxHealth
	
	-- Networked variables
	self:SetNetworkedInt("WB_MaxHealth", math.floor(self.MaxHealth))
	self:SetNetworkedInt("WB_CurHealth", math.floor(self.CurHealth))
	
end


function ENT:OnBuild(deltatime)
	if self.CurHealth < self.MaxHealth then
		math.min( self.CurHealth + self.BuildRegen*deltatime, self.MaxHealth )
	end
end


-- All things with health die when damaged too much.
function ENT:OnTakeDamage(dmginfo)
	self:TakePhysicsDamage(dmginfo)
	
	if self.IsAlive then
		self.CurHealth = self.CurHealth - dmginfo:GetDamage()
		if self.CurHealth <= 0 then
			self:OnDeath()
		end
	end
end


function ENT:OnDeath()
	self.IsAlive = false
	--self:BeforeDeathFunc()
	
	local expl = ents.Create("env_explosion")
		expl:SetPos(self:GetPos())
		expl:SetOwner(self)
		expl.Team = self:GetTeam()
		expl:SetKeyValue("iMagnitude", self.DeathDamage)
		expl:SetKeyValue("iRadiusOverride", self.DeathRadius)
	expl:Spawn()
	expl:Activate()
	expl:Fire("explode", 0, 0)
	expl:Remove()
	
	self:SetColor (0, 0, 0, 255)
	self:Remove()
	-- Add a timer for removing stuff, so it sticks around a little while
	-- Also make it unconstrain/parent so it flies off stuff if attached
end
