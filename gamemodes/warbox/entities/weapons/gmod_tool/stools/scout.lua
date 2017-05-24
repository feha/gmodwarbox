TOOL.Category		= "(Warbox)"
TOOL.Name			= "#scout"
TOOL.Command		= nil
TOOL.ConfigName		= ""
cleanup.Register("Warbox")
TOOL.ClientConVar[ "teamnumber" ] = "1"

if (CLIENT) then
	language.Add( "Tool.scout.name", "scout" )
	language.Add( "Tool.scout.desc", "Tool to spawn scout" )
	language.Add( "Tool.scout.0", "Left-click to spawn unit. Right-click to spawn unit welded?" )
	language.Add( "Undone.scout", "Undone scout" )
	language.Add( "SBoxLimit.Warbox.Unit", "Personal Limit Reached" )
end

function TOOL:LeftClick( trace )
	if ( SERVER ) then
	
		--if ( not self:GetSWEP():CheckLimit( "scout" ) ) then return false end
		
		local ply = self:GetOwner()
		local Pos = trace.HitPos
		local Normal = trace.HitNormal
		
		local teem = nil
		if ply:IsAdminTeam() then
			teem = WarboxTEAM.GetTeam( self:GetClientNumber("teamnumber") )
            print("admin")
		else
			teem = ply:GetTeam()
            print("not admin")
		end
        print(teem)
		
		if (trace.Hit and not trace.HitNoDraw) then
			local entityclass = "wb_shooter_scout"
			if ply:ConsumeRes(Balance[entityclass].Cost) then
				local unit = ents.Create(entityclass)
					unit:SetPos( trace.HitPos + trace.HitNormal )
					unit:SetAngles(Normal:Angle())
                    unit:SetTeam( teem )
				unit:Spawn()
				unit:Activate()
				
				undo.Create( "scout" )
					undo.AddEntity( unit )
					undo.SetPlayer( self:GetOwner() )
				undo.Finish()
				cleanup.Add( ply, "Warbox", unit )
				
				return true
			else
				-- Really should add a message system
				ply:Message( string.format(GameStrings.GetString("you_need_more_resources"), ply:GetRes() ), "nicered" )
				return
			end
		end
		
	end
end


function TOOL:RightClick(trace)
	if ( SERVER ) then
		
		--if ( not self:GetSWEP():CheckLimit( "scout" ) ) then return false end
		
		local ply = self:GetOwner()
		local Pos = trace.HitPos
		local Normal = trace.HitNormal
		
		local teem = nil
		if ply:IsAdminTeam() then
			teem = WarboxTEAM.GetTeam( self:GetClientNumber("teamnumber") )
            print("admin")
		else
			teem = ply:GetTeam()
            print("not admin")
		end
        print(teem)
		
		if (trace.Hit and not trace.HitNoDraw) then
			local unit = ents.Create("wb_shooter_scout")
				unit:SetPos( trace.HitPos + trace.HitNormal )
				unit:SetAngles(Normal:Angle())
                unit:SetTeam( teem )
			unit:Spawn()
			unit:Activate()
			
			local constraint = constraint.Weld( unit, trace.Entity, 0, trace.PhysicsBone, 0, true )
			trace.Entity:DeleteOnRemove( unit )
			
			undo.Create( "scout" )
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
	CPanel:AddControl ("Header", { Text="#Tool.scout.name", Description="#Tool.scout.desc" })
	
	--local VGUI = vgui.Create("HelpButton",CPanel)
	--	VGUI:SetTopic("teststool")
	--CPanel:AddPanel(VGUI)
	
	if LocalPlayer():IsAdmin() then
		CPanel:AddControl ("Slider", {
			Label = "Team Number (Only applies on Admin team)",
			Command = "scout_teamnumber",
			Type = "Integer",
			Min = "1",
			Max = "8"
		} )
	end
end
