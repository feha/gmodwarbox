ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Author = "Feha"

include("mixins/BalanceMixin.lua")
include("mixins/QueryableTagMixin.lua")
include("mixins/TeamMixin.lua")
include("mixins/BuildingMixin.lua")
Mixins.RegisterMixin(ENT, BalanceMixin)
Mixins.RegisterMixin(ENT, QueryableTagMixin)
Mixins.RegisterMixin(ENT, TeamMixin)
Mixins.RegisterMixin(ENT, BuildingMixin)


function ENT:SetupDataTables()
    self.InitializeMixins( self )
    
    --code
    
    self.PostSetupDataTablesMixins( self )
end
