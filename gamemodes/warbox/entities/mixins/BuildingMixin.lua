
assert(Mixins)

BuildingMixin = Mixins.CreateMixin( BuildingMixin, "Building" )

BuildingMixin.expectedMixins =
{
}

BuildingMixin.expectedCallbacks =
{
}

BuildingMixin.optionalCallbacks =
{
}


if SERVER then
    -- local references to commonly used functions
    local v = FindMetaTable("Vector")
    local LengthSqr = v.LengthSqr
    
    function UpdateNetworkedVariables()
        for k, ply in pairs(player.GetAll()) do
            local entity = ply:GetEyeTrace().Entity
            if WarProp.IsValid( entity ) and LengthSqr(ply:GetPos() - entity:GetPos()) < Balance.notsorted.WorldTipDisplayRangeSqr then
                -- Might change from networked vars to something like net-lib
                entity:SetNetworkedInt("WB_BuildProgress", math.floor( entity.BuildProgress * 100 ) )
            end
        end
    end
    if not timer.Exists( "UpdateNetworkedVariables") then
        timer.Create( "UpdateNetworkedVariables", Balance.notsorted.WorlTipUpdateRate, 0, UpdateNetworkedVariables )
    end
    
    
    function BuildingMixin:Initialize()
        
        self.Building		= self.BuildTime > 0 and true
        self.BuildProgress	= self.BuildTime > 0 and 0 or 1
        self.InitTime		= CurTime()
        self.LastBuild		= self.InitTime
        
        -- Networked variables
        --self:SetNetworkedInt("WB_BuildProgress", math.floor( self.BuildProgress * 100 ) ) -- use networkvars
        
        
        self:SetColor( self:GetTeam().Color )
        local color = self:GetColor()
        color.a = 100 + 155 * self.BuildProgress -- move base alpha to Balance.lua?
        self:SetColor(color)
        
        if self.Building then
            self:SheduleBuilding()
        end
        
    end

    function BuildingMixin:SheduleBuilding() -- looks cooler than copypasting this timer when I want to start building
        -- move delay to Balance-lua?
        timer.Simple( 1, function() if self.Build then self:Build() end end )
    end

    function BuildingMixin:Build()
        if GetGameIsPaused() == 0 then
            
            if WarProp.IsValid( self ) and self.Building then
                local timeDiff = CurTime() - self.InitTime
                local deltatime = CurTime() - self.LastBuild
                self.BuildProgress = math.min(timeDiff/self.BuildTime, 1)
                self.Building = self.BuildProgress < 1
                
                local color = self:GetColor()
                local base_alpha = 100 -- move base alpha to Balance.lua?
                color.a = base_alpha + (255-base_alpha) * self.BuildProgress
                self:SetColor(color)
                
                if self.OnBuild then
                    self:OnBuild(deltatime)
                end
                
                self.LastBuild = CurTime()
                
                if self.Building then
                    self:SheduleBuilding()
                end
            end
            
        end
    end
end



if CLIENT then
    -- local references to commonly used functions and libraries
    local v = FindMetaTable("Vector")
    local LengthSqr = v.LengthSqr
    
    function BuildingMixin:Draw()
        
        -- To get transparancy you need to both set rendermode and rendergroup
        self:SetRenderMode(RENDERMODE_TRANSALPHA )
        self.RenderGroup = RENDERGROUP_BOTH
        
        -- health and building worldtip
        local ply = LocalPlayer()
        if ply:GetEyeTrace().Entity == self and LengthSqr(ply:GetPos() - self:GetPos()) < Balance.notsorted.WorldTipDisplayRangeSqr then
            
            local str = GameStrings.GetString(self:GetClass()) .. "\n"
                        .. string.format( GameStrings.GetString("owner"), self:GetTeam():GetName() ) .. "\n"
            
            local buildprogress = self:GetNetworkedInt("WB_BuildProgress")
            if buildprogress < 100  then
                str =	str .. string.format( GameStrings.GetString("building"), buildprogress )
            end
            
            AddWorldTip( nil, str, nil, self:GetPos(), self )
            
        end
        
    end
end