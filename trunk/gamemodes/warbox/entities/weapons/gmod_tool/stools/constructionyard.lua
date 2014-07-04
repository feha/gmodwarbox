TOOL.Category		= "(Warbox)"
TOOL.Name			= "#constructionyard"
TOOL.Command		= nil
TOOL.ConfigName		= ""
cleanup.Register("Warbox")
TOOL.ClientConVar[ "teamnumber" ] = "1"

if (CLIENT) then
	language.Add( "Tool.constructionyard.name", "constructionyard" )
	language.Add( "Tool.constructionyard.desc", "Tool to spawn constructionyard" )
	language.Add( "Tool.constructionyard.0", "Left-click to spawn unit. Right-click to spawn unit welded?" )
	language.Add( "Undone.teststool", "Undone constructionyard" )
	language.Add( "SBoxLimit.Warbox.Unit", "Personal Limit Reached" )
end

function TOOL:LeftClick( trace )
	if ( SERVER ) then
	
		--if ( not self:GetSWEP():CheckLimit( "constructionyard" ) ) then return false end
		
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
			local entityclass = "wb_structure_constructionyard"
			local built = teem:GetNumberOfConstructionYardsBuilt()
			local cost
			if (built+1 < #(Balance[entityclass].CostTable)) then
				cost = Balance[entityclass].CostTable[built+1]
			else
				local num = built+1 - #Balance[entityclass].CostTable
				cost = Balance[entityclass].CostTable[built+1] * 2^(num+1)
			end
			if ply:ConsumeRes(cost) then
				ent = ents.Create(entityclass)
					ent:SetPos( trace.HitPos + trace.HitNormal )
					ent:SetAngles(Angle(0,0,0))
					ent:SetTeam( teem )
				ent:Spawn()
				ent:Activate()
				
				if built == 0 then
					ent.BuildTime = 1 -- First construction yard should finish instantly
				end
				
				undo.Create( "constructionyard" )
					undo.AddEntity( ent )
					undo.SetPlayer( self:GetOwner() )
				undo.Finish()
				cleanup.Add( ply, "Warbox", ent )
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
		
		--if ( not self:GetSWEP():CheckLimit( "constructionyard" ) ) then return false end
		
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
			unit = ents.Create("wb_structure_constructionyard")
				unit:SetPos( trace.HitPos + trace.HitNormal )
				unit:SetAngles(Angle(0,0,0))
				unit:SetTeam( teem )
			unit:Spawn()
			unit:Activate()
			
			constraint = constraint.Weld( unit, trace.Entity, 0, trace.PhysicsBone, 0, true )
			trace.Entity:DeleteOnRemove( unit )
			
			undo.Create( "constructionyard" )
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
	CPanel:AddControl ("Header", { Text="#Tool.constructionyard.name", Description="#Tool.constructionyard.desc" })
	
	--local VGUI = vgui.Create("HelpButton",CPanel)
	--	VGUI:SetTopic("teststool")
	--CPanel:AddPanel(VGUI)
	
	if LocalPlayer():IsAdmin() then
		CPanel:AddControl ("Slider", {
			Label = "Team Number (Only applies on Admin team)",
			Command = "constructionyard_teamnumber",
			Type = "Integer",
			Min = "1",
			Max = "8"
		} )
	end
end
