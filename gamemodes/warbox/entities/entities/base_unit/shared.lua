ENT.Type = "anim"
ENT.Base = "base_structure"
ENT.Author = "Feha"

include("mixins/QueryableTagMixin.lua")
include("mixins/TargetingMixin.lua")
include("mixins/TargetMixin.lua")
include("mixins/ShooterMixin.lua")
include("mixins/MobileMixin.lua")
Mixins.RegisterMixin(ENT, QueryableTagMixin)
Mixins.RegisterMixin(ENT, TargetingMixin)
Mixins.RegisterMixin(ENT, TargetMixin)
Mixins.RegisterMixin(ENT, ShooterMixin)
Mixins.RegisterMixin(ENT, MobileMixin)

function ENT:SetupDataTables()
    self.InitializeMixins( self )
    
    --code
    
    self.PostSetupDataTablesMixins( self )
end
