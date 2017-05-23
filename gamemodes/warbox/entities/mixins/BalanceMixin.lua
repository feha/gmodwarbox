
assert(Mixins)

BalanceMixin = Mixins.CreateMixin( BalanceMixin, "Balance" )

BalanceMixin.expectedMixins =
{
}

BalanceMixin.expectedCallbacks =
{
}

BalanceMixin.optionalCallbacks =
{
}


function BalanceMixin:MixinPreInitialize()
    
	self.Balance = Balance[self:GetWBType()]
	for	k, v in pairs(self.Balance) do
		self[k] = v
	end
    
end

