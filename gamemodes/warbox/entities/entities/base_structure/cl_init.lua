include("shared.lua")

DEFINE_BASECLASS( "base_anim" )

-- local references to commonly used functions and libraries
local v = FindMetaTable("Vector")
local LengthSqr = v.LengthSqr


ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Draw()
	
	-- afaik the baseclass only does self:DrawModel(), but I use baseclass anyway
	BaseClass.Draw( self )
	
	-- Add stuff like build and health overlay
	local ply = LocalPlayer()
	if ply:GetEyeTrace().Entity == self and LengthSqr(ply:GetPos() - self:GetPos()) < Balance.notsorted.WorldTipDisplayRangeSqr then
		if self:GetNetworkedInt("WB_BuildProgress") < 1  then
			AddWorldTip( nil, self:GetClass() .. "\nBuilding: " .. math.floor(self:GetNetworkedInt("WB_BuildProgress") * 100) .. "%", nil, self:GetPos(), self  )
		else
			AddWorldTip( nil, self:GetClass() .. "\nHealth: " .. self:GetNetworkedInt("WB_CurHealth") .. "/" .. self:GetNetworkedInt("WB_MaxHealth"), nil, self:GetPos(), self  )
		end
	end
	
end