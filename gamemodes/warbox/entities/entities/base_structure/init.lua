include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

DEFINE_BASECLASS( "base_anim" )

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
	assert(structure.CallOnRemove, "structure.CallOnRemove is nil. If you call Base_Unit.Remove(structure) manually, just create an empty function.")
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



function ENT:Initialize()
	
	BaseClass.Initialize( self )
	
	-- Fields defualt values
	self.Balance = Balance[self:GetUnitType()]
	self.Model			=	self.Balance.Model
	self.CurHealth		=	self.Balance.MaxHealth
	self.MaxHealth		=	self.Balance.MaxHealth
	self.DeathDamage	=	self.Balance.DeathDamage
	self.DeathRadius	=	self.Balance.DeathRadius
	self.Delay			=	self.Balance.Delay
	self.BuildTime		=	self.Balance.BuildTime -- milliseconds

	self.BuildProgress	=	0
	self.Building		=	true
	self.IsDead			=	false -- True when dead => IsStructure check not needed since (not false) == (not nil)
	
	
	-- make it static?
	self:SetModel( self.Model )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetRenderMode( RENDERMODE_TRANSALPHA )
	
	local physics = self:GetPhysicsObject()
	if (physics:IsValid()) then
		physics:Wake()
		physics:SetBuoyancyRatio(self.Bouyancy or 0)
		physics:EnableGravity(self.HasGravity)
	end
	
	if not self.StdMat then
		self:SetMaterial("models/debug/debugwhite")
	else
		self:SetMaterial(self.StdMat)
	end
	self:SetColor( self:GetTeam().Color )
	local color = self:GetColor()
	color.r = 255*self.BuildProgress
	self:SetColor(color)
	
	self.IsStructure = true
	Structure.Add(self)
	
end


-- Used for stuff like building. will have to be split in different ways.
-- Structures and units both need to be built (further baseclass?),
-- but units will have target aquiring as well.
function ENT:Think ()
	if GetGameIsPaused() == 0 then
	
		if self.Building and self.IsDead then
			self.BuildProgress = self.BuildProgress + self.Delay/self.BuildTime
			self.Building = (self.BuildProgress < 1)
			
			local color = self:GetColor()
			color.r = math.min(255*self.BuildProgress,255)
			self:SetColor(color)
		end
		
	end
	
	
    self:NextThink(CurTime() + self.Delay)
	return true
end


-- all things will have health and die when shoot too much.
function ENT:OnTakeDamage (dmginfo)
	self:TakePhysicsDamage(dmginfo)
	
	if not self.IsDead then
		self.CurHealth = self.CurHealth - dmginfo:GetDamage()
		if self.CurHealth <= 0 then
			self:OnDeath()
		end
	end
end


function ENT:OnDeath()
	print("death")
	self.IsDead = true
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
	self:Remove() -- add a timer for removing stuff, so it sticks around a little while
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
