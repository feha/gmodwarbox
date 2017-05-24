include("shared.lua")

local BaseClass = baseclass.Get("base_warprop")

-- local references to commonly used functions and libraries
local v = FindMetaTable("Vector")
local LengthSqr = v.LengthSqr

function ENT:Draw()
	
	-- To get transparancy you need to both set rendermode and rendergroup
	self:SetRenderMode(RENDERMODE_NORMAL  )
	self.RenderGroup = RENDERGROUP_OPAQUE
	
	---- afaik the baseclass only does self:DrawModel(), but I use baseclass anyway
	--BaseClass.Draw( self )
	self:DrawModel()
	
	-- health and building worldtip
	local ply = LocalPlayer()
	if ply:GetEyeTrace().Entity == self and LengthSqr(ply:GetPos() - self:GetPos()) < Balance.notsorted.WorldTipDisplayRangeSqr then
		
		local progress = self:GetNetworkedInt("WB_ContestProgress")
		local contestername = WarboxTEAM.GetTeam(self:GetNetworkedInt("WB_ContesterID")):GetName()
		local str = GameStrings.GetString(self:GetClass()) .. "\n"
		
		if progress == 0 then
			str = str .. GameStrings.GetString("wb_warprop_capturepoint_uncontested")
		elseif progress == 100  then
			str = 	str .. GameStrings.GetString("wb_warprop_capturepoint_captured") .. "\n"
						.. string.format( GameStrings.GetString("owner"), contestername )
		else
			local contester = string.format(
												GameStrings.GetString("wb_warprop_capturepoint_contester"),
												contestername
											)
			str = 	str .. string.format(GameStrings.GetString("progress"), progress ) .. "\n"
						.. contester
		end
		
		AddWorldTip( nil, str, nil, self:GetPos(), self )
		
	end
	
end