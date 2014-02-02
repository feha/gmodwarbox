
--
-- This defines a new panel type for the team frames. The team frames is given a team
-- and then from that point on it pretty much looks after itself. It updates team info
-- in the think function, and removes itself when the team is empty.
--
local TEAM_FRAME = {}

function TEAM_FRAME:Init(  )
	
	self.Header = self:Add( "Panel" )
	self.Header:Dock( TOP )
	self.Header:SetHeight( 32 )
	
	self.Name = self.Header:Add( "DLabel" )
	self.Name:Dock( FILL )
	self.Name:SetFont( "ScoreboardDefault" )
	self.Name:DockMargin( 8, 0, 0, 0 )
	
	self.Score = self.Header:Add( "DLabel" )
	self.Score:Dock( RIGHT )
	self.Score:SetWidth( 50 )
	self.Score:SetFont( "ScoreboardDefault" )
	
	self.Resources = self.Header:Add( "DLabel" )
	self.Resources:Dock( RIGHT )
	self.Resources:SetWidth( 50 )
	self.Resources:SetFont( "ScoreboardDefault" )
	
	self:Dock( TOP )
	self:DockPadding( 4, 4, 4, 4 )
	self:DockMargin( 4, 4, 4, 0 ) -- Why doesnt margin down work? well the rest fixes padding problem
	
	self.Players = self:Add( "Panel" )
	self.Players:Dock( FILL )

end

function TEAM_FRAME:Setup( teem )
	
	self.Team = teem
	
	self.Name:SetText( teem:GetName() )

	self:Think( self )

end

function TEAM_FRAME:Think(  )
	
	--
	-- Loop through each player in team, and if one doesn't have a score entry - create it.
	--
	for _, ply in pairs( self.Team:GetPlayersReference() ) do
		
		if not IsValid( ply.ScoreEntry ) then

			ply.ScoreEntry = vgui.CreateFromTable( ScoreBoardAssets.PLAYER_LINE, self )
			ply.ScoreEntry:Setup( ply )

			self.Players:Add( ply.ScoreEntry )
			
		end

	end
	
	if self.Team:IsEmpty() then
		self:Remove()
		return
	end
	
	self.Players:SizeToChildren( false, true ) 
	self:SizeToChildren( false, true ) 
	
	if self.NumResources == nil or self.NumResources != self.Team:GetRes() then
		self.NumResources = self.Team:GetRes()
		self.Resources:SetText( self.NumResources )
	end
	
	if self.NumScore == nil or self.NumScore != self.Team:GetScore() then
		self.NumScore = self.Team:GetScore()
		self.Score:SetText( self.Team:GetScore() )
	end
	
	--
	-- This is what sorts the list. The panels are docked in the z order,
	-- so if we set the z order according to kills they'll be ordered that way!
	-- Careful though, it's a signed short internally, so needs to range between -32,768k and +32,767
	--
	self:SetZPos( -self.Team:GetIndex() )

end

function TEAM_FRAME:Paint( w, h )

	--if self.Team:IsEmpty() then
	--    return
	--end

	--
	-- We draw our background a different colour based on the status of the player
	--
	
	-- Just tweaking the color a little bit
	local color = self.Team:GetColor()
	color.a = color.a * 0.80
	draw.RoundedBox( 4, 0, 0, w, h, color )

end

--
-- Convert it from a normal table into a Panel Table based on DPanel
--
TEAM_FRAME = vgui.RegisterTable( TEAM_FRAME, "DPanel" );
ScoreBoardAssets.TEAM_FRAME = TEAM_FRAME