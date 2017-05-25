
assert(Mixins)

TargetMixin = Mixins.CreateMixin( TargetMixin, "Target" )

TargetMixin.expectedMixins =
{
}

TargetMixin.expectedCallbacks =
{
}

TargetMixin.optionalCallbacks =
{
    IsValidTarget = "Called to verify if a target is valid. Default-behavior is overridden if this exists.",
    GetTargetPosition = "Called when something tries to target this TargetMixin-entity.",
}


function TargetMixin:Initialize()
	self.localTargetPos = self:OBBCenter()
end


--[[
--- A function to check if a target is valid or not.
-- Overrides the default-behaviour when TargetingMixin checks for validity.
-- @param source The TargetMixin entity
-- @param target The entity to check
-- @param pos Optional position-vector, overrides `pos = source:GetPos()` if set.
-- @return Boolean - True if target is valid.
function TargetMixin:IsValidTarget(source, target, pos)
end
--]]


--- Function used to get the position used for targetting this entity.
-- Default-behaviour is to return the world position of its `OBBCenter()`.
function TargetMixin:GetTargetPosition()
    print("targetpos")
	return self:LocalToWorld( self.localTargetPos )
end
