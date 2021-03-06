TOOL.Category		= "(Warbox)"
TOOL.Name			= "#teststool"
TOOL.Command		= nil
TOOL.ConfigName		= ""
cleanup.Register("Warbox")
TOOL.ClientConVar[ "teamnumber" ] = "1"

if (CLIENT) then
	language.Add( "Tool.teststool.name", "teststool" )
	language.Add( "Tool.teststool.desc", "teststool for testing" )
	language.Add( "Tool.teststool.0", "Left-click to teststool stuff. Right-click to teststool stuff differently?" )
	language.Add( "Undone.teststool", "Undone teststool stuff" )
	language.Add( "SBoxLimit.Warbox.Unit", "Personal Limit Reached" )
end

function TOOL:LeftClick(trace)
	if ( SERVER ) then
		--if ( not self:GetSWEP():CheckLimit( "teststool" ) ) then return false end
		
		local ply = self:GetOwner()
		local Pos = trace.HitPos
		local Normal = trace.HitNormal
		
		local teem = nil
		if ply:IsAdminTeam() then
			teem = WarboxTEAM.GetTeam( self:GetClientNumber("teamnumber") )
		else
			teem = ply:GetTeam()
		end
		
		if (trace.Hit and not trace.HitNoDraw) then
			unit = ents.Create("wb_warprop_capturepoint")
				unit:SetPos( trace.HitPos + trace.HitNormal )
				unit:SetAngles(Normal:Angle())
			unit:Spawn()
			unit:Activate()
			
			--upright = constraint.Weld( unit, trace.Entity, 0, trace.PhysicsBone, 0, true )
			--trace.Entity:DeleteOnRemove( unit )
			
			undo.Create( "teststool" )
				undo.AddEntity( unit )
				--undo.AddEntity( upright )
				undo.SetPlayer( self:GetOwner() )
			undo.Finish()
			cleanup.Add( ply, "Warbox", unit )
			
			return true
		end
	end
end


function TOOL:RightClick(trace)
	
end

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl ("Header", { Text="#Tool.teststool.name", Description="#Tool.teststool.desc" })
	
	--local VGUI = vgui.Create("HelpButton",CPanel)
	--	VGUI:SetTopic("teststool")
	--CPanel:AddPanel(VGUI)
	
	if LocalPlayer():IsAdmin() then
		CPanel:AddControl ("Slider", {
			Label = "Team Number (Only applies on Admin team)",
			Command = "teststool_teamnumber",
			Type = "Integer",
			Min = "1",
			Max = "8"
		} )
	end
end
