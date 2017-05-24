ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Author = "Feha"

include("mixins/BalanceMixin.lua")
include("mixins/QueryableTagMixin.lua")
include("mixins/TeamMixin.lua")
Mixins.RegisterMixin(ENT, BalanceMixin)
Mixins.RegisterMixin(ENT, QueryableTagMixin)
Mixins.RegisterMixin(ENT, TeamMixin)


function ENT:SetupDataTables()
    self.InitializeMixins( self )
    
    --code
    
    self.PostSetupDataTablesMixins( self )
end
