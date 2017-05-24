TOOL.Category		= "(Warbox)"
TOOL.Name			= "#battlemage"
TOOL.Command		= nil
TOOL.ConfigName		= ""
cleanup.Register("Warbox")
TOOL.ClientConVar[ "teamnumber" ] = "1"

if (CLIENT) then
	language.Add( "Tool.battlemage.name", "battlemage" )
	language.Add( "Tool.battlemage.desc", "Tool to spawn battlemages" )
	language.Add( "Tool.battlemage.0", "Left-click to spawn unit. Right-click to spawn unit welded?" )
	language.Add( "Undone.teststool", "Undone battlemage" )
	language.Add( "SBoxLimit.Warbox.Unit", "Personal Limit Reached" )
end

function TOOL:LeftClick( trace )
	if ( SERVER ) then
	
		--if ( not self:GetSWEP():CheckLimit( "battlemage" ) ) then return false end
		
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
			local entityclass = "wb_battlemage"
			if ply:ConsumeRes(Balance[entityclass].Cost) then
				unit = ents.Create(entityclass)
					unit:SetPos( trace.HitPos + trace.HitNormal )
					unit:SetAngles(Normal:Angle() + Angle(90,0,0))
                    unit:SetTeam( teem )
				unit:Spawn()
				unit:Activate()
                local corner = (unit:OBBMaxs() - unit:OBBCenter())
                local radius = (corner.x > corner.y and corner.x > corner.z and corner.x) or (corner.y > corner.x and corner.y > corner.z and corner.y) or (corner.z > corner.x and corner.z > corner.y and corner.z)
                unit:SetPos( trace.HitPos + trace.HitNormal * radius )
				
				undo.Create( "battlemage" )
					undo.AddEntity( unit )
					undo.SetPlayer( self:GetOwner() )
				undo.Finish()
				cleanup.Add( ply, "Warbox", unit )
			else
				-- Really should add a message system
				print("cant afford")
				return
			end
		end
		
	end
end


function TOOL:RightClick(trace)
	if ( SERVER ) then
		
		--if ( not self:GetSWEP():CheckLimit( "battlemage" ) ) then return false end
		
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
			unit = ents.Create("wb_battlemage")
				unit:SetPos( trace.HitPos + trace.HitNormal )
				unit:SetAngles(Normal:Angle() + Angle(90,0,0))
				unit:SetTeam( teem )
			unit:Spawn()
			unit:Activate()
			
			constraint = constraint.Weld( unit, trace.Entity, 0, trace.PhysicsBone, 0, true )
			trace.Entity:DeleteOnRemove( unit )
			
			undo.Create( "battlemage" )
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
	CPanel:AddControl ("Header", { Text="#Tool.battlemage.name", Description="#Tool.battlemage.desc" })
	
	--local VGUI = vgui.Create("HelpButton",CPanel)
	--	VGUI:SetTopic("teststool")
	--CPanel:AddPanel(VGUI)
	
	if LocalPlayer():IsAdmin() then
		CPanel:AddControl ("Slider", {
			Label = "Team Number (Only applies on Admin team)",
			Command = "battlemage_teamnumber",
			Type = "Integer",
			Min = "1",
			Max = "8"
		} )
	end
end
