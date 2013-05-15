
local PLAYER = FindMetaTable("Player")


-- local function Loadout( ply )

	-- ply:RemoveAllAmmo()
	
	-- ply:Give( "gmod_tool" )
	-- ply:Give( "gmod_camera" )
	-- ply:Give( "weapon_physgun" )
	
	-- self.Player:SwitchToDefaultWeapon()

-- end
-- hook.Add( "PlayerLoadout", "warbox_loadout", Loadout)


local oldSetTeam = PLAYER.SetTeam
function PLAYER:SetTeam( teamIndex )
	
	-- The old SetTeam is serverside only
	if SERVER then
		oldSetTeam( self, teamIndex )
	end
	
	if self.warboxTeam then
		self.warboxTeam:RemovePlayer(self) -- Remove player from old team
	end
	
	-- Ensure new team exists, and if not, create it
	self.warboxTeam = WarboxTEAM.GetTeam(teamIndex)
	if not self.warboxTeam then
		self.warboxTeam = WarboxTEAM(teamIndex, "", Color(111, 111, 111, 255))
	end
	
	self.warboxTeam:AddPlayer(self) -- Add player to new team
	
	self:SetColor(self:GetTeam():GetColor()) -- Change to team-color
	
end

function PLAYER:GetTeam( )
	if CLIENT then self:SetTeam(self:Team()) end -- Need to make it synced in a better way I think.
	
	if not self.warboxTeam then
		self:SetTeam( self:Team() )
	end
	
	return self.warboxTeam
end


function PLAYER:IsAdminTeam()
	return self:GetTeam():IsAdmin()
end

function PLAYER:IsAdminOrSuper()
	return self:IsAdmin() or self:IsSuperAdmin() or self == LocalPlayer()
end


-- Resources ----------------
PLAYER.Res = 0
PLAYER.MaxRes = Balance.player.MaxRes

function PLAYER:GetRes( )
	return math.floor( self.Res )
end

-- These three should become shared using net-lib or networked variables (or deaths/frags) to share data
function PLAYER:SetRes( res )
	self.Res = math.min( res, self.MaxRes )
end

function PLAYER:AddRes( res )
	self:SetRes( self.Res + res )
end

function PLAYER:ConsumeRes( cost )
	if self.Res < cost then return false end
	
	self:SetRes( self.Res - cost )
	return true
end


-- UnitSelectionTable ---------------- (all below this serverside?)
if SERVER then
	function PLAYER:GetUnitSelectionCount()
		return #self.unitSelection or 0
	end

	-- unitSelection is a table where the units are the KEYS, as it makes it easyer to treat as a Set.
	function PLAYER:GetUnitSelectionArray()
		
		local tbl = {}
		for k,_ in pairs(self.unitSelection or {}) do
			table.insert(tbl,k)
		end
		return tbl
		
	end

	function PLAYER:GetUnitSelection()
		
		return table.Copy(self.unitSelection) or {}
		
	end

	function PLAYER:SetUnitSelection( unitSelection )
		
		self.unitSelection = {}
		self:AddUnitSelection( unitSelection )
		
	end

	function PLAYER:AddUnitSelection( unitSelection )
		
		for _,v in pairs(unitSelection) do
			assert(v.IsUnit == true, "Selection needs to be a table of Units.")
			self.AddUnitToSelection(v)
		end
		
	end

	function PLAYER:RemoveUnitSelection( unitSelection )
		
		for _,v in pairs(unitSelection) do
			assert(v.IsUnit == true, "Selection needs to be a table of Units.")
			self.unitSelection[v] = nil
		end
		
	end

	function PLAYER:AddUnitToSelection(unit)
		assert(unit.CallOnRemove, "unit.CallOnRemove is nil. If you call Base_Unit.Remove(unit) manually, just create an empty function.")
		assert(type(unit.CallOnRemove) == "function", "Unit.CallOnRemove is not a function. If you call PLAYER:Remove(unit) manually, just create an empty function.")
		
		self.unitSelection[unit] = unit
		-- Will this be needed? I intend to ensure stuff is alive before ordering anyway...
		unit:CallOnRemove( "RemoveUnitFromSelection", PLAYER.RemoveUnitFromSelection, self )
	end
	function PLAYER:RemoveUnitFromSelection(unit)
		for k,v in pairs(self.unitSelection) do
			if (unit == v) then
				self.unitSelection[v] = nil
				v:RemoveCallOnRemove( "RemoveUnitFromSelection" )
				break
			end
		end
	end


	-- Unit Selection ----------------
	function PLAYER:SelectStart()
		self.SelectionStartPos = self:GetEyeTrace().HitPos
		print(self.SelectionStartPos)
	end

	function PLAYER:SelectThink()
		local tr = self:GetEyeTrace()
		
		local selectionEnd = tr.HitPos
		local direction = (self.SelectionStartPos - selectionEnd)/2
		local center = selectionEnd + direction
		local radius = vector.LengthSqr(direction)
		
		-- Do effect to show current selection target
	end

	local v = FindMetaTable("Vector")
	local LengthSqr = v.LengthSqr
	function PLAYER:SelectEnd(add_to_selection, select_non_mobile, select_of_type, something_more )
		local tr = self:GetEyeTrace()
		
		local selectionEnd = tr.HitPos
		local endEntity = tr.Entity
		local direction = (self.SelectionStartPos - selectionEnd)/2
		local center = selectionEnd + direction
		local radiusSqr = LengthSqr(direction)
		
		print(selectionEnd)
		if not add_to_selection then
			self:SetUnitSelection( {} )
		end
		
		-- TODO
		-- Change to use a list of mobile units, and alternative base_units.
		local source = ( select_non_mobile and Structure.GetTableReference() ) or Base_Unit.GetTableReference()
		
		local type_to_unit = {}
		local types_in_selection = {}
		for k,v in pairs(source) do
			if (Structure.IsValid(v) and (v:GetTeam() == self:GetTeam() or self:IsAdminTeam())) and v.IsAlive then
				if select_of_type then
					if not type_to_unit[v:GetUnitType()] then
						type_to_unit[v:GetUnitType()] = {}
					end
					table.insert( type_to_unit[v:GetUnitType()], v )
				end
				if LengthSqr(v:GetPos() - center) <= radiusSqr then
					self:AddUnitToSelection( v )
					print("selected")
					print(v)
					if select_of_type then
						table.insert( types_in_selection, v:GetUnitType() )
					end
				end
			end
		end
		
		-- If selection is empty and player aimed at a unit, force it to the selection.
		if self:GetUnitSelectionCount() == 0 and endEntity:IsValid()
				and endEntity.IsUnit and endEntity.IsAlive then
			self:AddUnitToSelection( endEntity )
			if select_of_type then
				table.insert( types_in_selection, v:GetUnitType() )
			end
		end
		
		-- TODO
		-- Change Base_Unit list to either have a copy indexed by type, or be indexed by type to begin with
		-- If I argue its harder to create a Set because of numeric indexes, slap me,
		-- since I could just index the table for each type like I do now.
		-- Problem lies in if I want to keep the unit tables at one, and instead need two loops for it,
		-- or if I want to use two tables, and then my loops use the most appropriate one.
		if select_of_type then
			for _,unitType in pairs(types_in_selection) do
				self:AddUnitSelection( type_to_units[unitType] )
			end
		end
		
	end


	-- Unit Ordering ----------------
	function PLAYER:OrderSelection(add, follow, target, patrol)
		local selection = self:GetUnitSelection()
		
		local tr = self:GetEyeTrace()
		local targetVector = tr.HitPos
		local targetEntity = tr.Entity
		for k,v in pairs(selection) do
			if v.IsMobile or (target and v.IsUnit) then
				-- Force fire
				if target then
					v.ForceTarget = targetEntity
				end
				
				-- Move order
				if not add then
					v.MoveVec = {}
					v.FollowEnt = {}
				end
				if follow then
					table.insert(v.FollowEnt, targetEntity)
				else
					table.insert(v.MoveVec, targetVector)
				end
				
				v.Patrolling = patrol
				print("ordered")
			end
		end
	end
end
