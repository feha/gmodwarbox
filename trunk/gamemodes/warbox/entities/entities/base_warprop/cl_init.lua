include("shared.lua")

DEFINE_BASECLASS( "base_anim" )

-- local references to commonly used functions and libraries
local v = FindMetaTable("Vector")
local LengthSqr = v.LengthSqr


--ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Draw()
	
	-- To get transparancy you need to both set rendermode and rendergroup
	self:SetRenderMode(RENDERMODE_TRANSALPHA )
	self.RenderGroup = RENDERGROUP_BOTH
	
	-- afaik the baseclass only does self:DrawModel(), but I use baseclass anyway
	BaseClass.Draw( self )
	
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