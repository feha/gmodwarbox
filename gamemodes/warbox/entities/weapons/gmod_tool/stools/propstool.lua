TOOL.Category		= "(Warbox)"
TOOL.Name			= "#propstool"
TOOL.Command		= nil
TOOL.ConfigName		= ""
cleanup.Register("Warbox")

TOOL.ClientConVar[ "teamnumber" ] = "1"
TOOL.ClientConVar[ "model" ] = "models/props_c17/concrete_barrier001a.mdl"
TOOL.ClientConVar[ "health" ] = "100"
TOOL.ClientConVar[ "angleyaw" ] = "0"
TOOL.ClientConVar[ "anglepitch" ] = "0"
TOOL.ClientConVar[ "angleroll" ] = "0"
TOOL.ClientConVar[ "offset" ] = "0"
TOOL.ClientConVar[ "global" ] = "0"
TOOL.ClientConVar[ "center" ] = "0"
TOOL.ClientConVar[ "gravity" ] = "0"
TOOL.ClientConVar[ "weld" ] = "0"

if (CLIENT) then
	language.Add( "Tool.propstool.name", "propstool" )
	language.Add( "Tool.propstool.desc", "propstool for testing" )
	language.Add( "Tool.propstool.0", "Left-click to spawn prop. Right-click copies angle of entity or surface to the stool." )
	language.Add( "Undone_propstool", "Undone propstool stuff" )
	language.Add( "SBoxLimit_Warbox_Unit", "Personal Limit Reached" )
end


-- Helper functions ------------------------------
local v = FindMetaTable("Vector")
local LengthSqr = v.LengthSqr
local Dot = v.Dot

-- Why do I even have to use this for placing a prop to a surface when so many other tools use a simpler approach?
-- Sometimes perfectionism makes your solutions silly, although better.
local function RayPlaneIntersection( Start, Dir, Pos, Normal )
	
	local A = Dot(Normal, Dir)
	
	//Check if the ray is aiming towards the plane (fail if it origin behind the plane, but that is checked later)
	if (A < 0) then
		
		local B = Dot(Normal, Pos-Start)
		
		//Check if the ray origin in front of plane
		if (B < 0) then
			return (Start + Dir * (B/A))
		end
		
	//Check if the ray is parallel to the plane
	elseif (A == 0) then
		
		//Check if the ray origin inside the plane
		if (Dot(Normal, Pos-Start) == 0) then
			return Start
		end
		
	end
	
	return false
	
end
--------------------------------------


function TOOL:LeftClick( trace )
	if ( SERVER ) then
		if ( not self:GetSWEP():CheckLimit( "propstool" ) ) then return false end
		
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
			unit = ents.Create("wb_structure_prop")
				unit:SetPos( self.GhostEntity:GetPos() )
				unit:SetAngles( self.GhostEntity:GetAngles() )
				unit:SetTeam( teem )
				unit.Model = self:GetClientInfo("model")
				unit:SetModel( unit.Model )
			unit:Spawn()
			unit:Activate()
			
			local upright = nil
			if self:GetClientNumber("weld") == 1 then
				upright = constraint.Weld( unit, trace.Entity, 0, trace.PhysicsBone, 0, true )
				trace.Entity:DeleteOnRemove( unit )
			end
			
			undo.Create( "propstool" )
				undo.AddEntity( unit )
				if upright then undo.AddEntity( upright ) end
				undo.SetPlayer( self:GetOwner() )
			undo.Finish()
			cleanup.Add( ply, "Warbox", unit )
			
			return true
		end
	end
end


function TOOL:RightClick( trace )

	if (trace.Hit and not trace.HitNoDraw) then
		print(self:GetClientNumber("anglepitch"))
		
		local Ang
		if trace.Entity and trace.Entity:IsValid() then
			Ang = trace.Entity:GetAngles()
		else
			Ang = trace.HitNormal:Angle()
		end
		
		RunConsoleCommand(self.Mode.."_angleyaw", tostring(Ang.y))
		RunConsoleCommand(self.Mode.."_anglepitch", tostring(Ang.p))
		RunConsoleCommand(self.Mode.."_angleroll", tostring(Ang.r))
		
		print(self:GetClientNumber("anglepitch"))
		
	end
	
end

function TOOL:UpdateGhost( ent, ply )

	if not ent then return end
	if not ent:IsValid() then return end
	
	local tr 		= util.GetPlayerTrace( ply )
	local trace 	= util.TraceLine( tr )
	
	if not trace.Hit then return end
	
	if trace.Entity:IsPlayer() then
	
		ent:SetNoDraw( true )
		return
		
	end
	
	local Pos, Ang
	
	local Normal = trace.HitNormal
	if self:GetClientNumber("global") == 1 then
		Ang = Angle(self:GetClientNumber("anglepitch"), self:GetClientNumber("angleyaw"), self:GetClientNumber("angleroll"))
	else
		Ang = Normal:Angle()
		Ang:RotateAroundAxis( Normal, self:GetClientNumber("angleyaw") )
		Ang:RotateAroundAxis( Ang:Right(), self:GetClientNumber("anglepitch") )
		Ang:RotateAroundAxis( Ang:Up(), self:GetClientNumber("angleroll") )
	end
	ent:SetAngles( Ang )
	
	if self:GetClientNumber("center") == 1 then
		Pos = trace.HitPos + ent:GetPos() - ent:LocalToWorld(ent:OBBCenter())
	else
		local CurPos = ent:LocalToWorld(ent:OBBCenter())
		local diameter = LengthSqr( ent:OBBMaxs() - ent:OBBMins() )
		local Nearest = ent:NearestPoint( CurPos - (Normal * diameter) )
		-- Simply using nearest will make the prop offset, so the hitnormal dir != as origin-hitpos dir
		local NearestCentered = RayPlaneIntersection( CurPos, -Normal, Nearest, Normal )
		local Offset = CurPos - NearestCentered + (Normal * self:GetClientNumber("offset"))
		Pos = trace.HitPos + ent:GetPos() - ent:LocalToWorld(ent:OBBCenter()) + Offset
	end
	ent:SetPos( Pos )
	
	ent:SetNoDraw( false )
	
end


function TOOL:Think()

	if not self.GhostEntity || not self.GhostEntity:IsValid() || self.GhostEntity:GetModel() != self:GetClientInfo( "model" ) then
		self:MakeGhostEntity( self:GetClientInfo( "model" ), Vector(0,0,0), Angle(0,0,0) )
	end
	
	self:UpdateGhost( self.GhostEntity, self:GetOwner() )
	
end

function TOOL.BuildCPanel( CPanel )

	-- HEADER
	CPanel:AddControl( "Header", { Text = "#tool.propstool.name", Description	= "#tool.propstool.desc" }  )
	
	
	if LocalPlayer():IsAdmin() then
		CPanel:AddControl ("Slider", {
			Label = "Team Number (Only applies on Admin team)",
			Command = "teststool_teamnumber",
			Type = "Integer",
			Min = "1",
			Max = "8"
		} )
	end
	
	
	CPanel:AddControl( "PropSelect", { Label = "#tool.propstool.model",
									 ConVar = "propstool_model",
									 Category = "BaseProps",
									 Height = 4,
									 Models = list.Get( "BasePropModels" ) } )
	
	
	CPanel:AddControl( "Slider", { Label = "#tool.propstool.health",
									 Type = "Float",
									 Min = 0,
									 Max = 100,
									 Command = "propstool_health" } )
	
	
	CPanel:AddControl( "Slider", { Label = "#tool.propstool.offset",
									 Type = "Float",
									 Min = 0,
									 Max = 5000,
									 Command = "propstool_offset" } )
	
	CPanel:AddControl( "Slider", { Label = "#tool.propstool.angleyaw",
									 Type = "Float",
									 Min = -180,
									 Max = 180,
									 Command = "propstool_angleyaw" } )
	
	CPanel:AddControl( "Slider", { Label = "#tool.propstool.anglepitch",
									 Type = "Float",
									 Min = -180,
									 Max = 180,
									 Command = "propstool_anglepitch" } )
	
	CPanel:AddControl( "Slider", { Label = "#tool.propstool.angleroll",
									 Type = "Float",
									 Min = -180,
									 Max = 180,
									 Command = "propstool_angleroll" } )
	
	CPanel:AddControl( "CheckBox", { Label = "#tool.propstool.global",
									 Command = "propstool_global" } )
	
	CPanel:AddControl( "CheckBox", { Label = "#tool.propstool.center",
									 Command = "propstool_center" } )
	
	CPanel:AddControl( "CheckBox", { Label = "#tool.propstool.gravity",
									 Command = "propstool_gravity" } )
	
	CPanel:AddControl( "CheckBox", { Label = "#tool.propstool.weld",
									 Description = "placeholder text",
									 Command = "propstool_weld" } )
	
end

list.Set( "BasePropModels", "models/props_c17/fence03a.mdl", {} )
list.Set( "BasePropModels", "models/props_building_details/storefront_template001a_bars.mdl", {} )
list.Set( "BasePropModels", "models/props_c17/fence01a.mdl", {} )
list.Set( "BasePropModels", "models/props_c17/concrete_barrier001a.mdl", {} )
list.Set( "BasePropModels", "models/props_c17/concrete_barrier001a.mdl", {} )
list.Set( "BasePropModels", "models/props_lab/BlastDoor001c.mdl", {} )
list.Set( "BasePropModels", "models/props_lab/BlastDoor001a.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/metal_plate1.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/metal_plate1x2.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/metal_plate2x4.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/metal_plate2x2.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/metal_plate4x4.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/metal_plate1_tri.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/metal_plate1x2_tri.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/metal_plate2x2_tri.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/metal_plate2x4_tri.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/metal_tube.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/metal_tubex2.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/metal_wire1x1.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/metal_wire1x1x1.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/metal_wire1x1x2.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/metal_wire1x1x2b.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/metal_wire1x2.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/metal_wire1x2b.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/metal_wire1x2x2b.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/metal_wire2x2.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/metal_wire2x2b.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/metal_wire2x2x2b.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/glass/glass_plate1x1.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/glass/glass_plate1x2.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/glass/glass_plate2x2.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/glass/glass_plate2x4.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/glass/glass_plate4x4.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/windows/window1x1.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/windows/window1x2.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/windows/window2x2.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/windows/window2x4.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/windows/window4x4.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/wood/wood_boardx1.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/wood/wood_boardx2.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/wood/wood_boardx4.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/wood/wood_panel1x1.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/wood/wood_panel1x2.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/wood/wood_panel2x2.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/wood/wood_panel2x4.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/wood/wood_panel4x4.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/wood/wood_wire1x1.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/wood/wood_wire1x1x1.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/wood/wood_wire1x1x2.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/wood/wood_wire1x1x2b.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/wood/wood_wire1x2.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/wood/wood_wire1x2b.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/wood/wood_wire1x2x2b.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/wood/wood_wire2x2.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/wood/wood_wire2x2b.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/wood/wood_wire2x2x2b.mdl", {} )
list.Set( "BasePropModels", "models/hunter/plates/plate1x1.mdl", {} )
list.Set( "BasePropModels", "models/hunter/plates/plate1x2.mdl", {} )
list.Set( "BasePropModels", "models/hunter/plates/plate1x3.mdl", {} )
list.Set( "BasePropModels", "models/hunter/plates/plate1x4.mdl", {} )
list.Set( "BasePropModels", "models/hunter/plates/plate1x5.mdl", {} )
list.Set( "BasePropModels", "models/hunter/plates/plate1x6.mdl", {} )
list.Set( "BasePropModels", "models/hunter/plates/plate1x7.mdl", {} )
list.Set( "BasePropModels", "models/hunter/plates/plate1x8.mdl", {} )
list.Set( "BasePropModels", "models/hunter/plates/plate2x2.mdl", {} )
list.Set( "BasePropModels", "models/hunter/plates/plate2x3.mdl", {} )
list.Set( "BasePropModels", "models/hunter/plates/plate2x4.mdl", {} )
list.Set( "BasePropModels", "models/hunter/plates/plate2x5.mdl", {} )
list.Set( "BasePropModels", "models/hunter/plates/plate2x6.mdl", {} )
list.Set( "BasePropModels", "models/hunter/plates/plate2x7.mdl", {} )
list.Set( "BasePropModels", "models/hunter/plates/plate2x8.mdl", {} )
list.Set( "BasePropModels", "models/hunter/plates/plate3x3.mdl", {} )
list.Set( "BasePropModels", "models/hunter/plates/plate3x4.mdl", {} )
list.Set( "BasePropModels", "models/hunter/plates/plate3x5.mdl", {} )
list.Set( "BasePropModels", "models/hunter/plates/plate3x6.mdl", {} )
list.Set( "BasePropModels", "models/hunter/plates/plate3x7.mdl", {} )
list.Set( "BasePropModels", "models/hunter/plates/plate3x8.mdl", {} )
list.Set( "BasePropModels", "models/hunter/plates/plate4x4.mdl", {} )
list.Set( "BasePropModels", "models/hunter/plates/plate4x5.mdl", {} )
list.Set( "BasePropModels", "models/hunter/plates/plate4x6.mdl", {} )
list.Set( "BasePropModels", "models/hunter/plates/plate4x7.mdl", {} )
list.Set( "BasePropModels", "models/hunter/plates/plate4x8.mdl", {} )
list.Set( "BasePropModels", "models/hunter/plates/plate5x5.mdl", {} )
list.Set( "BasePropModels", "models/hunter/plates/plate5x6.mdl", {} )
list.Set( "BasePropModels", "models/hunter/plates/plate5x7.mdl", {} )
list.Set( "BasePropModels", "models/hunter/plates/plate5x8.mdl", {} )
list.Set( "BasePropModels", "models/hunter/plates/plate6x6.mdl", {} )
list.Set( "BasePropModels", "models/hunter/plates/plate6x7.mdl", {} )
list.Set( "BasePropModels", "models/hunter/plates/plate6x8.mdl", {} )
list.Set( "BasePropModels", "models/hunter/plates/plate7x7.mdl", {} )
list.Set( "BasePropModels", "models/hunter/plates/plate7x8.mdl", {} )
list.Set( "BasePropModels", "models/hunter/plates/plate8x8.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube025x025x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube025x05x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube025x075x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube025x1x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube025x125x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube025x150x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube025x2x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube025x3x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube025x4x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube025x5x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube025x6x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube025x7x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube025x8x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube05x05x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube05x075x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube05x1x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube05x2x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube05x3x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube05x4x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube05x5x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube05x6x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube05x7x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube05x8x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube075x075x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube075x1x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube075x2x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube075x3x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube075x4x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube075x6x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube075x8x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube1x1x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube1x2x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube1x3x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube1x4x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube1x5x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube1x6x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube1x7x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube1x8x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube2x2x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube2x4x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube2x6x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube2x8x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube3x3x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube3x4x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube3x6x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube3x8x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube4x4x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube4x6x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube4x8x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube6x6x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube8x8x025.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube05x05x05.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube05x105x05.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube05x1x05.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube05x2x05.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube05x3x05.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube05x4x05.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube05x5x05.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube05x6x05.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube05x7x05.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube05x8x05.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube1x1x05.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube1x2x05.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube1x4x05.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube1x6x05.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube1x8x05.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube2x2x05.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube2x4x05.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube2x6x05.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube2x8x05.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube3x3x05.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube4x4x05.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube4x6x05.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube4x8x05.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube6x6x05.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube6x8x05.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube8x8x05.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube075x075x075.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube075x1x075.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube075x2x075.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube075x3x075.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube075x4x075.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube075x5x075.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube075x6x075.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube075x7x075.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube075x8x075.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube075x1x1.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube075x2x1.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube075x3x1.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube1x1x1.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube1x2x1.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube1x3x1.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube1x4x1.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube1x6x1.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube1x8x1.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube2x1x1.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube2x2x1.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube2x4x1.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube2x6x1.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube2x8x1.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube4x4x1.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube4x6x1.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube4x8x1.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube6x6x1.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube6x8x1.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube8x8x1.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube2x2x2.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube4x4x2.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube4x6x2.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube6x6x2.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube6x8x2.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube8x8x2.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube4x4x4.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube4x6x4.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube8x8x2.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube4x6x6.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube6x6x6.mdl", {} )
list.Set( "BasePropModels", "models/hunter/blocks/cube8x8x8.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/plastic/plastic_angle_90.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/plastic/plastic_angle_180.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/plastic/plastic_angle_360.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/plastic/plastic_panel1x1.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/plastic/plastic_panel1x2.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/plastic/plastic_panel1x3.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/plastic/plastic_panel1x4.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/plastic/plastic_panel1x8.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/plastic/plastic_panel2x2.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/plastic/plastic_panel2x3.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/plastic/plastic_panel2x4.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/plastic/plastic_panel2x8.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/plastic/plastic_panel3x3.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/plastic/plastic_panel4x4.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/plastic/plastic_panel4x8.mdl", {} )
list.Set( "BasePropModels", "models/props_phx/construct/plastic/plastic_panel8x8.mdl", {} )
list.Set( "BasePropModels", "models/props_c17/FurnitureBed001a.mdl", {} )