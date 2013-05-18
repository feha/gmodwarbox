TOOL.Category		= "(Warbox)"
TOOL.Name			= "#infantry"
TOOL.Command		= nil
TOOL.ConfigName		= ""
cleanup.Register("Warbox")
TOOL.ClientConVar[ "teamnumber" ] = "1"

if (CLIENT) then
	language.Add( "Tool_teststool_name", "infantry" )
	language.Add( "Tool_teststool_desc", "Tool to spawn infantry" )
	language.Add( "Tool_teststool_0", "Left-click to spawn unit. Right-click to spawn unit welded?" )
	language.Add( "Undone_teststool", "Undone infantry" )
	language.Add( "SBoxLimit_Warbox_Unit", "Personal Limit Reached" )
end

function TOOL:LeftClick( trace )
	if ( SERVER ) then
	
		if ( not self:GetSWEP():CheckLimit( "infantry" ) ) then return false end
		
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
			unit = ents.Create("wb_shooter_infantry")
				unit:SetPos( trace.HitPos + trace.HitNormal )
				unit:SetAngles(Normal:Angle())
				unit:SetTeam( teem )
			unit:Spawn()
			unit:Activate()
			
			undo.Create( "infantry" )
				undo.AddEntity( unit )
				undo.SetPlayer( self:GetOwner() )
			undo.Finish()
			cleanup.Add( ply, "Warbox", unit )
			
			return true
		end
		
	end
end


function TOOL:RightClick(trace)
	if ( not self:GetSWEP():CheckLimit( "infantry" ) ) then return false end
		
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
			unit = ents.Create("wb_shooter_infantry")
				unit:SetPos( trace.HitPos + trace.HitNormal )
				unit:SetAngles(Normal:Angle())
				unit:SetTeam( teem )
			unit:Spawn()
			unit:Activate()
			
			constraint = constraint.Weld( unit, trace.Entity, 0, trace.PhysicsBone, 0, true )
			trace.Entity:DeleteOnRemove( unit )
			
			undo.Create( "infantry" )
				undo.AddEntity( unit )
				undo.AddEntity( constraint )
				undo.SetPlayer( self:GetOwner() )
			undo.Finish()
			cleanup.Add( ply, "Warbox", unit )
			
			return true
		end
		
	end
end



function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl ("Header", { Text="#Tool_teststool_name", Description="#Tool_teststool_desc" })
	
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
