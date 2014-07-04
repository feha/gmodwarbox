if ( SERVER ) then
   AddCSLuaFile ( "shared.lua" )
end

if ( CLIENT ) then
	SWEP.PrintName          = "Warbox Order Gun"
	SWEP.Author				= "Feha"
	SWEP.Contact			= ""
	SWEP.Purpose			= "Used to order units"
	SWEP.Instructions		= "Primary fire = Select units (HOLD). Secondary Fire = Order units. Reload = currently nil null nada"
	SWEP.Slot               = 2 -- change?
	SWEP.SlotPos            = 1 -- change?
	SWEP.DrawAmmo           = false
	SWEP.DrawCrosshair      = true
end


-- change?
SWEP.ViewModelFOV	        = 60
SWEP.ViewModelFlip	        = false
SWEP.ViewModel		        = "models/weapons/v_357.mdl"
SWEP.WorldModel		        = "models/weapons/w_357.mdl"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"


function SWEP:Deploy ( )
	self.Weapon:SendWeaponAnim ( ACT_VM_DRAW )
	return true
end


--local keyevents2 = false

function SWEP:Initialize()
	--self.reloadtimer = 0
end

function SWEP:Think()
	
	local ply = self:GetOwner()
	
	if CLIENT then
		-- Display area to be selected
		if self.isSelecting then
			local tr = ply:GetEyeTrace()
			local pos = tr.HitPos
			local radius = pos:Distance(self.selectVolume:GetPos()) / 49 -- magic number?
			self.selectVolume:SetModelScale(radius, 0)
			self.selectVolume:SetPos((self.selectVolume.StartPos + pos)/2)
			self.selectVolume:DrawModel()
		end
	end
	
	
	-- If player released primary fire (finished selection)
	if not ply:KeyDown(IN_ATTACK) and self.isSelecting then
		self.isSelecting = nil
		
		if CLIENT then
			if self.selectVolume and IsValid(self.selectVolume) then self.selectVolume:Remove() end
		end
		
		if SERVER then
			local shift	= ply:KeyDown(IN_SPEED)	-- add to selection
			local use	= ply:KeyDown(IN_USE)	-- select non-mobile as well
			local ctrl	= ply:KeyDown(IN_DUCK)	-- select all of type
			--local alt	= ply:KeyDown(IN_WALK)
			--local space	= ply:KeyDown(IN_JUMP)
			
			ply:SelectEnd(shift, use, duck, nil)
		end
	end
	--if not ply:KeyDown(IN_RELOAD) and keyevents2 then
		--ply:ConCommand("-wmstanceradial")
		--keyevents2 = false
	--end
	
	self.Weapon:NextThink(CurTime())-- + 0.05)
	return true
	
end


--[[
function SWEP:Reload()
	if IsFirstTimePredicted() then
		if self.reloadtimer <= CurTime() then
		   self.reloadtimer = (CurTime() + 1)
		else
			return false
		end
	end
	local ply = self:GetOwner()
	if ply:KeyDown(IN_SPEED) || ply:KeyDown(IN_DUCK) || ply:KeyDown(IN_JUMP) || ply:KeyDown(IN_USE) || ply:KeyDown(IN_WALK) then
		ply:ConCommand("wmstanceselect")
	elseif keyevents2 == false then
		keyevents2 = true
		ply:ConCommand("+wmstanceradial")
	end
end
--]]


function SWEP:PrimaryAttack()
	
	self.isSelecting = true
	
	if CLIENT then
		local tr = self:GetOwner():GetEyeTrace()
		if tr.Hit then
			local pos = tr.HitPos
			if self.selectVolume and IsValid(self.selectVolume) then self.selectVolume:Remove() end
			
			self.selectVolume = ClientsideModel("models/hunter/misc/shell2x2.mdl")
				self.selectVolume:SetPos(pos)
				self.selectVolume.StartPos = pos
				self.selectVolume:SetColor(255,255,255, 75)
				self.selectVolume:DrawShadow( false )
				self.selectVolume:SetModelScale(0.01, 0)
			self.selectVolume:Spawn()
			self.selectVolume:Activate()
		end
	end
	
	if SERVER then
		self:GetOwner():SelectStart()
	end
	
end


function SWEP:SecondaryAttack()
	
	if SERVER then
		local ply = self:GetOwner()
		
		local shift	= ply:KeyDown(IN_SPEED)	-- add waypoint
		local use	= ply:KeyDown(IN_USE)	-- follow
		local alt	= ply:KeyDown(IN_WALK)	-- force-fire
		local ctrl	= ply:KeyDown(IN_DUCK)	-- patrol
		--local space	= ply:KeyDown(IN_JUMP)
		
		self:GetOwner():OrderSelection(shift, use, alt, ctrl)
	end
	
end


function SWEP:Holster()

	
	if SERVER then
		if self.isSelecting then
			local ply = self:GetOwner()
			
			local shift	= ply:KeyDown(IN_SPEED)	-- add to selection
			local use	= ply:KeyDown(IN_USE)	-- select non-mobile as well
			local ctrl	= ply:KeyDown(IN_DUCK)	-- select all of type
			--local alt	= ply:KeyDown(IN_WALK)
			--local space	= ply:KeyDown(IN_JUMP)
			
			ply:SelectEnd(shift, use, duck, nil)
		end
	end
	
	self.isSelecting = nil
	
	return true
	
end

