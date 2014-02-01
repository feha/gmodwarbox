include("shared.lua")

DEFINE_BASECLASS( "base_warprop" )

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
		if self:GetNetworkedInt("WB_BuildProgress") < 1  then
			local buildprogress = math.floor(self:GetNetworkedInt("WB_BuildProgress") * 100)
			AddWorldTip( nil,
						GameStrings.GetString(self:GetClass()) .. "\n"
						.. GameStrings.GetString("building") .. ": " .. buildprogress .. "%",
						nil, self:GetPos(), self )
		else
			local health = self:GetNetworkedInt("WB_CurHealth")
			local maxhealth = self:GetNetworkedInt("WB_MaxHealth")
			AddWorldTip( nil,
						GameStrings.GetString(self:GetClass()) .. "\n"
						.. GameStrings.GetString("health") .. ": " .. health .. "/" .. maxhealth,
						nil, self:GetPos(), self  )
		end
	end
	
end