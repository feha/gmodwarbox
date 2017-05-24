ENT.Type = "anim"
ENT.Base = "base_structure"
ENT.Author = "Feha"

include("mixins/QueryableTagMixin.lua")
Mixins.RegisterMixin(ENT, QueryableTagMixin)

function ENT:SetupDataTables()
    self.InitializeMixins( self )
    
    --code
    
    self.PostSetupDataTablesMixins( self )
end
