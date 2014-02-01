include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

DEFINE_BASECLASS( "base_anim" )

-- local references to commonly used functions
local v = FindMetaTable("Vector")
local LengthSqr = v.LengthSqr


-- Table used for "static" functions
WarProp = {}

-- When searching for stuff extending base_structure, this table should be faster.
local warprops = {}
function WarProp.GetTableReference()
	return warprops -- Copying steals performance, this function is better used when it wont be modified.
end
function WarProp.GetTable()
	return table.Copy(warprops)
end
function WarProp.Add(warprop)
	assert(warprop, "warprop is nil, its bad idea to add it to he WarProp table.")
	assert(warprop.CallOnRemove, "warprop.CallOnRemove is nil. If you call WarProp.Remove(warprop) manually, just create an empty function.")
	assert(type(warprop.CallOnRemove) == "function", "warprop.CallOnRemove is not a function. If you call WarProp.Remove(warprop) manually, just create an empty function.")
	
	table.insert( warprops, warprop )
	warprop:CallOnRemove( "RemoveWarProp", WarProp.Remove )
end
function WarProp.Remove(warprop)
	for k,v in pairs(warprops) do
		if (warprop == v) then
			table.remove(warprops, k)
			v:RemoveCallOnRemove( "RemoveWarPropFromSelection" )
			break
		end
	end
end


-- Static helper functions
function WarProp.IsValid( warprop )
	return warprop and IsValid(warprop) and warprop.IsWarProp
end


function WarProp.UpdateNetworkedVariables( )
	for k, ply in pairs(player.GetAll()) do
		local entity = ply:GetEyeTrace().Entity
		if WarProp.IsValid( entity ) and LengthSqr(ply:GetPos() - entity:GetPos()) < Balance.notsorted.WorldTipDisplayRangeSqr then
			-- Might change from networked vars to something like net-lib
			entity:SetNetworkedFloat("WB_BuildProgress", entity.BuildProgress)
		end
	end
end
timer.Create( "WarProp.UpdateNetworkedVariables", Balance.notsorted.WorlTipUpdateRate, 0, WarProp.UpdateNetworkedVariables )

-----------------------------------------------------------------------------------------


function ENT:Initialize()
	
	BaseClass.Initialize( self )
	
	-- Fields defualt values
	self.Balance = Balance[self:GetWBType()]
	for	k, v in pairs(self.Balance) do
		self[k] = v
	end
	
	WarProp.Add(self)
	
	self.Building		= self.BuildTime > 0 and true
	self.BuildProgress	= self.BuildTime > 0 and 0 or 1
	self.InitTime		= CurTime()
	self.LastBuild		= self.InitTime
	
	-- Networked variables
    self:SetNetworkedFloat("WB_BuildProgress", self.BuildProgress)
	
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
	self:SetColor( self:GetTeam().Color )
	local color = self:GetColor()
	color.a = 100 + 155 * self.BuildProgress -- move base alpha to Balance.lua?
	self:SetColor(color)
	
	if self.Building then
		self:SheduleBuilding()
	end
	
end


function ENT:SheduleBuilding() -- looks cooler than copypasting this timer when I want to start building
	-- move delay to Balance-lua?
	timer.Simple( 0.1, function() if self.Build then self:Build() end end )
end

function ENT:Build()
	if GetGameIsPaused() == 0 then
		
		if WarProp.IsValid( self ) and self.Building then
			local timeDiff = CurTime() - self.InitTime
			local deltatime = CurTime() - self.LastBuild
			self.BuildProgress = math.min(timeDiff/self.BuildTime, 1)
			self.Building = self.BuildProgress < 1
			
			local color = self:GetColor()
			-- move base alpha to Balance.lua?
			color.a = 100 + 155 * self.BuildProgress
			self:SetColor(color)
			
			if self.OnBuild then
				self:OnBuild(deltatime)
			end
			
			self.LastBuild = CurTime()
			
			if self.Building then
				self:SheduleBuilding()
			end
		end
		
	end
end
