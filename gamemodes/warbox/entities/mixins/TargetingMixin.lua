
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

--[[ TODO figure out if, and how, I want to make variables that should exist, exists.
TargetingMixin.TargetEntity = nil,
TargetingMixin.canHitFilter = nil,
--]]


if SERVER then
    -- local references to commonly used functions and libraries
    local v = FindMetaTable("Vector")
    local LengthSqr = v.LengthSqr -- Sqr is better performance and comparisons still work just as well.
    local GetNormal = v.GetNormal


    function TargetingMixin:Initialize()
        self.rangeSqr = math.pow(self.Range, 2)
        self.canHitFilter = self.canHitFilter or {}
        self.canHitFilter[self]=self
    end


    --- A function to check if a target is valid or not.
    -- A valid target is valid irregardless of teams or even if `source == target`
    -- If target.IsValidTarget exists, it's used instead.
    -- @param source The TargetingMixin entity
    -- @param target The entity to check
    -- @param pos Optional position-vector, overrides `pos = source:GetPos()` if set.
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
            -- Or should I use GetShootPos?
            local tarPos = target.GetTargetingPosition and target:GetTargetingPosition()
                    or target:GetPos()
            local direction = tarPos - pos
            local rangeSqr = LengthSqr(direction)
            source.TargetEntityDir = direction
            if source:GetCanHit(target, tarPos, direction, rangeSqr) then
                return true, tarPos, direction, rangeSqr
            end
        end
    end


    --- A function used to find a new target.
    -- The target returned is verified to be valid by `IsValidTarget`.
    -- @param self The TargetingMixin entity
    -- @param pos Optional position-vector, overrides `pos = source:GetPos()` if set.
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
                            tarPos = tarpos or v.GetTargetingPosition and v:GetTargetingPosition()
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


    function TargetingMixin:GetTarget()
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
        if self.OnNewTarget and target and self.TargetEntity ~= target then
            self:OnNewTarget(target, tarPos, direction, rangeSqr)
        end
        
        self.TargetEntity = target
        self.TargetEntityDir = direction
        return self.TargetEntity, tarPos, self.TargetEntityDir, rangeSqr
    end


    -- TODO Move to ShooterMixin
    function TargetingMixin:GetShootPos( direction )
        if direction then
            local corner = (self:OBBMaxs() - self:OBBCenter())
            local radius = (corner.x < corner.y and corner.x < corner.z and corner.x) or (corner.y < corner.x and corner.y < corner.z and corner.y) or (corner.z < corner.x and corner.z < corner.y and corner.z)
            return self:LocalToWorld( self.localShootPos ) + GetNormal(direction) * radius
        else
            return self:LocalToWorld( self.localShootPos )
        end
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


    function TargetingMixin:GetCanHit( target, tarpos, direction, rangeSqr )
        if rangeSqr <= self.rangeSqr then
            local filter = player.GetAll()
            for k,v in pairs(self.canHitFilter) do
                table.insert(filter, k)
            end
            local tracedata = {}
                tracedata.start = self:GetShootPos( direction )
                tracedata.endpos = tarpos-- + direction
                tracedata.filter = filter
            local trace = util.TraceLine(tracedata)
            
            return trace.Entity == target
        end
        
        return false
    end
end