include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

DEFINE_BASECLASS( "base_anim" )

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
	assert(type(structure.CallOnRemove) == "function", "structure.CallOnRemove is not a function. If you call Base_Unit.Remove(structure) manually, just create an empty function.")
	
	table.insert( structures, structure )
	structure:CallOnRemove( "RemoveUnit", Structure.Remove )
end
function Structure.Remove(structure)
	for k,v in pairs(structures) do
		if (structure == v) then
			table.remove(structures, k)
			v:RemoveCallOnRemove( "RemoveUnitFromSelection" )
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
	
	-- Fields defualt values
	self.Balance = Balance[self:GetUnitType()]
	for	k, v in pairs(self.Balance) do
		self[k] = v
	end
	
	Structure.Add(self)
	
	self.IsAlive		=	true
	self.CurHealth		=	self.MaxHealth
	self.Building		=	true
	self.BuildProgress	=	0
	self.InitTime = CurTime()
	
	self:SheduleBuilding()
	--self:Build()
	
	-- Networked variables
	self:SetNetworkedInt("WB_MaxHealth", math.floor(self.MaxHealth))
	self:SetNetworkedInt("WB_CurHealth", math.floor(self.CurHealth))
    self:SetNetworkedFloat("WB_BuildProgress", self.BuildProgress)
	
	
	-- make it static and change to physics in base_unit?
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
	self:SetColor( self:GetTeam().Color )
	local color = self:GetColor()
	color.a = 100
	self:SetColor(color)
	
end


function ENT:SheduleBuilding() -- looks cooler than copypasting this timer when I want to start building
	-- move delay to Balance-lua?
	timer.Simple( 0.1, function() if self.Build then self:Build() end end )
end

function ENT:Build()
	if GetGameIsPaused() == 0 then
		
		if Structure.IsValid( self ) and self.Building then
			local timeDiff = CurTime() - self.InitTime
			self.BuildProgress = math.min(--[[self.BuildProgress +--]] timeDiff/self.BuildTime, 1)
			self.Building = self.BuildProgress < 1
			
			local color = self:GetColor()
			-- move base alpha to Balance.lua?
			color.a = 100 + 155 * self.BuildProgress
			self:SetColor(color)
			
			if self.Building then
				self:SheduleBuilding()
			end
		end
		
	end
end

-- Not normally used, but will likely be used by medics or similar. Otherwise: Remove this eventually.
function ENT:ProgressBuild( progress ) -- in seconds
	if self.Building then
		self.InitTime = self.InitTime - progress
		local timeDiff = CurTime() - self.InitTime
		self.BuildProgress = math.min(timeDiff/self.BuildTime, 1)
		self.Building = self.BuildProgress < 1
		
		local color = self:GetColor()
		-- move base alpha to Balance.lua?
		color.a = 100 + 155 * self.BuildProgress
		self:SetColor(color)
	end
end


-- All things will has health and die when damaged too much.
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


-- team stuff
function ENT:GetUnitType()
	return self:GetClass() --"base_structure"
end

function ENT:GetTeam()
	return self.warboxTeam
end

function ENT:SetTeam( warboxTeam )
	self.warboxTeam = warboxTeam
end
