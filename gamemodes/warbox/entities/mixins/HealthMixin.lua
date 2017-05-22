
assert(Mixins)

Mixins.HealthMixin = Mixins.CreateMixin( Mixins.HealthMixin, "Health" )
local HealthMixin = Mixins.HealthMixin

HealthMixin.expectedMixins =
{
}

HealthMixin.expectedCallbacks =
{
}

HealthMixin.optionalCallbacks =
{
    --OnTakeDamage = "Called when an entity takes damage.",
    OnDeath = "Called when an entity dies (CurHealth <= 0 after taking damage)",
}

--[[
-- Might remove this information, not needed for the engine.
-- Though might also appropriate it to handle settign the networked variables more "properly".
HealthMixin.networkVars =
{
    WB_MaxHealth = "Int",
    WB_CurHealth = "Int",
}
--]]

function HealthMixin:Initialize()

    self.IsAlive		= true
    self.MaxHealth = self.OriginalMaxHealth
    self.CurHealth = self.MaxHealth
    
	-- Networked variables
	self:SetNetworkedInt("WB_MaxHealth", math.floor(self.MaxHealth))
	self:SetNetworkedInt("WB_CurHealth", math.floor(self.CurHealth))
    
end


--- 
-- Regenerate some health if damaged while being built
-- @param deltatime
function HealthMixin:OnBuild(deltatime)
	if self.CurHealth < self.MaxHealth then
		math.min( self.CurHealth + self.BuildRegen*deltatime, self.MaxHealth )
	end
end


--- Callback used when dealt damage by damage-dealers
-- Things with health should lose some when dealt damage.
-- @param dmginfo 
function HealthMixin:OnTakeDamage(dmginfo)
	self:TakePhysicsDamage(dmginfo)
	
	if self.IsAlive then
		self.CurHealth = self.CurHealth - dmginfo:GetDamage()
		if self.CurHealth <= 0 then
			self:OnDeath()
		end
	end
end


--- All things with health die when damaged too much.
-- Standard behaviour for dying is to explode and disappear.
function HealthMixin:OnDeath()
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
    -- TODO
	-- Add a timer for removing stuff, so it sticks around a little while
	-- Also make it unconstrain/parent so it flies off stuff if attached
end

