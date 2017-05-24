include("shared.lua")

local BaseClass = baseclass.Get("base_warprop")

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
		
		if self:GetNetworkedInt("WB_BuildProgress") < 100  then
			local buildprogress = math.floor(self:GetNetworkedInt("WB_BuildProgress"))
			str =	str .. string.format( GameStrings.GetString("building"), buildprogress )
		else
			local health = self:GetNetworkedInt("WB_CurHealth")
			local maxhealth = self:GetNetworkedInt("WB_MaxHealth")
			
			str =	str .. string.format( GameStrings.GetString("health"), health, maxhealth )
		end
		
		AddWorldTip( nil, str, nil, self:GetPos(), self )
		
	end
	
end