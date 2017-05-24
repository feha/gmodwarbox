ENT.Type = "anim"
ENT.Base = "base_warprop"
ENT.Author = "Feha"

-- Likely to move mixin includes to mixin.lua or similar
include("mixins/HealthMixin.lua")
include("mixins/QueryableTagMixin.lua")
Mixins.RegisterMixin(ENT, HealthMixin)
Mixins.RegisterMixin(ENT, QueryableTagMixin)

function ENT:SetupDataTables()
    self.InitializeMixins( self )
    
    --code
    
    self.PostSetupDataTablesMixins( self )
end
