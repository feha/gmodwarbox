
assert(Mixins)

TargetingMixin = Mixins.CreateMixin( TargetingMixin, "Targeting" )

TargetingMixin.expectedMixins =
{
    Balance = "Loads values such as range.",
    Team = "Teams are taken into account when targeting",
}

TargetingMixin.expectedCallbacks =
{
}

TargetingMixin.optionalCallbacks =
{
    GetTarget = "Called when *** looks for a target.",
    GetTargetPriority = "Called when targetting to prioritize targets.",
    GetCanHit = "Called to verify that target is possible to hit.",
    OnNewTarget = "Called when target changes (including to nil).",
}


TargetingMixin.documentation =
{
    TargetEntity = "The target set by `self:GetTarget()`",
    TargetEntityDir = "Don't expect this to be a recent and updated value "
            .. "without insight in how this mixin and ones using it are implemented. "
            .. "The reason it exist is because of performance optimization, "
            .. "as dir found during targeting can be reused instead of recalculating it.",
    canHitFilter = "Table of entities (besides players) to filter out from GetCanHit()'s traces.",
}


-- local references to commonly used functions and libraries
local v = FindMetaTable("Vector")
local LengthSqr = v.LengthSqr -- Sqr is better performance and comparisons still work just as well.
local GetNormal = v.GetNormal


function TargetingMixin:Initialize()
    self.rangeSqr = math.pow(self.Range, 2)
    self.canHitFilter = self.canHitFilter or {}
    self.canHitFilter[self] = self
    self.localShootPos = self.localShootPos or self:OBBCenter()
end


function TargetingMixin:GetShootPos( direction )
    if direction then
        local corner = (self:OBBMaxs() - self:OBBCenter())
        local radius = (corner.x < corner.y and corner.x < corner.z and corner.x) or (corner.y < corner.x and corner.y < corner.z and corner.y) or (corner.z < corner.x and corner.z < corner.y and corner.z)
        return self:LocalToWorld( self.localShootPos ) + GetNormal(direction) * radius
    else
        return self:LocalToWorld( self.localShootPos )
    end
end


if SERVER then
    

    --- A function to check if a target is valid or not.
    -- A valid target is valid irregardless of teams or even if `source == target`
    -- If target.IsValidTarget exists, it's used instead.
    -- @param source The TargetingMixin entity
    -- @param target The entity to check
    -- @param pos Optional position-vector, overrides `pos = source:GetTargetingPos()` if set.
    -- @return Boolean - True if target is valid.
    -- @return Vector - Position of target.
    -- @return Vector - Direction to target from source.
    -- @return Float - Range (squared) to target from source.
    local function IsValidTarget(source, target, pos)
        assert(source and Mixins.HasMixin(source, "Targeting")
                , tostring(source) .. ": Expects a non-nil TargetingMixin-entity" )
        
        -- Target must exist
        if not target then return end
        
        local pos = pos or (source.GetShootPos and source:GetShootPos()) or source:GetPos()
        assert(type(pos) == "Vector"
                , "Expected a pos of type vector, received " .. type(pos) .. ".")
        
        -- Overriden
        if target.IsValidTarget then
            return target:IsValidTarget(source, target, pos)
        end
        
        -- Default behaviour
        if Structure.IsValid(target) then
            local tarPos = target.GetTargetPosition and target:GetTargetPosition()
                    or target:GetPos()
            local direction = tarPos - pos
            local rangeSqr = LengthSqr(direction)
            print(target, tarPos, direction, rangeSqr, source.rangeSqr)
            if source:GetCanHit(target, tarPos, direction, rangeSqr, pos) then
                return true, tarPos, direction, rangeSqr
            end
            return nil, tarPos, direction, rangeSqr
        end
    end


    --- A function used to find a new target.
    -- The target returned is verified to be valid by `IsValidTarget`.
    -- @param self The TargetingMixin entity
    -- @param pos Optional position-vector, overrides `pos = source:GetTargetingPos()` if set.
    -- @return Boolean - True if target is valid.
    -- @return Vector - Position of target.
    -- @return Vector - Direction to target from source.
    -- @return Float - Range (squared) to target from source.
    function TargetingMixin:FindNewTarget(pos)
        local target = nil
        local targetPos = nil
        local targetDir = nil
        local targetRangeSqr = nil
        local teem = self:GetTeam()
        local pos = pos or (self.GetShootPos and self:GetShootPos()) or self:GetPos()
        -- Make the target-table retrieving more customizeable
        for _,v in pairs(Structure.GetTableReference()) do
            if Structure.IsValid(v) then
                if v ~= self and v:GetTeam() ~= teem and self:GetTargetPriority(v) > 0
                        and self:GetTargetPriority(v) >= self:GetTargetPriority(target) then
                    -- It's possible the last three are nil if target.IsValidTarget exists.
                    local valid, tarPos, direction, rangeSqr = IsValidTarget(self, v, pos)
                    if valid then
                        if not targetRangeSqr or (rangeSqr or 0) < targetRangeSqr then
                            tarPos = tarpos or v.GetTargetPosition and v:GetTargetPosition()
                                    or v:GetPos()
                            target = v
                            targetPos = tarPos
                            targetDir = direction or (tarPos - pos)
                            targetRangeSqr = rangeSqr or 0
                        end
                    end
                end
            end
        end
        
        return target, targetPos, targetDir, targetRangeSqr
    end


    --- A function used to get a new target.
    -- The target returned is verified to be valid by `IsValidTarget`.
    -- Priorities are `self.ForceTarget`, followed by current and then finding a new one.
    -- It sets `self.TargetEntity` and `self.TargetEntityDir` as an alternative to return values.
    -- @param self The TargetingMixin entity
    -- @param pos Optional position-vector, overrides `pos = source:GetTargetingPos()` if set.
    -- @return Boolean - True if target is valid.
    -- @return Vector - Position of target.
    -- @return Vector - Direction to target from source.
    -- @return Float - Range (squared) to target from source.
    function TargetingMixin:GetTarget(pos)
        local target = nil
        local pos = pos or (self.GetShootPos and self:GetShootPos()) or self:GetPos()
        
        -- Target ForceTarget over current target if availible
        local valid, tarPos, direction, rangeSqr = IsValidTarget(self, self.ForceTarget, pos)
        if valid then
            target = valid and self.ForceTarget
        end
        
        -- When possible, persist current target over aquiring new one with better priority/range
        if not target and self.TargetEntity then
            valid, tarPos, direction, rangeSqr = IsValidTarget(self, self.TargetEntity, pos)
            if valid then
                target = self.TargetEntity
            end
        end
        
        -- Aquire a new target.
        if not target then
            target, tarPos, direction, rangeSqr = self:FindNewTarget(pos)
        end
        
        -- Call `OnNewTarget` when target changes.
        if self.OnNewTarget and self.TargetEntity ~= target then
            self:OnNewTarget(target, tarPos, direction, rangeSqr)
        end
        
        self.TargetEntity = target
        self.TargetEntityDir = direction
        return target, tarPos, direction, rangeSqr
    end


    --- A function used to get the priority of a target.
    -- Can be overwritten for classes with priorities impossible to set using Priority table.
    -- Higher number = higher priority; 0 and less  = not a target.
    function TargetingMixin:GetTargetPriority( target )
        if not target then return 0 end
        
         -- Stuff in priority list sets priority, but this can be modified for dynamic purposes if needed
         -- Since list only takes classnames, we also check if its a unit or structure
         -- Example of usage: Some sort of flak unit is likely to prioritize hoverballs and such.
        return self.Priority[target:GetClass()]
                or target.IsUnit and 20
                or target.IsStructure and 10
                or 0
    end


    function TargetingMixin:GetCanHit( target, tarPos, direction, rangeSqr, pos )
        if rangeSqr <= self.rangeSqr then
            local filter = player.GetAll()
            for k,v in pairs(self.canHitFilter) do
                table.insert(filter, k)
            end
            local pos = pos or (self.GetShootPos and self:GetShootPos( direction )) or self:GetPos()
            local tarPos = tarPos or (target.GetTargetPosition and target:GetTargetPosition())
                    or target:GetPos()
            local tracedata = {}
                tracedata.start = pos
                tracedata.endpos = tarPos
                tracedata.filter = filter
            local trace = util.TraceLine(tracedata)
            
            assert(not self.canHitFilter[trace.Entity], "trace hit entity in its filter.")
            return trace.Entity == target
        end
        
        return false
    end
end