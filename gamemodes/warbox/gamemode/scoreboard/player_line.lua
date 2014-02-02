
--
-- This defines a new panel type for the player row. The player row is given a player
-- and then from that point on it pretty much looks after itself. It updates player info
-- in the think function, and removes itself when the player leaves the server.
--
local PLAYER_LINE = {}

function PLAYER_LINE:Init(  )
	
	self.AvatarButton = self:Add( "DButton" )
	self.AvatarButton:Dock( LEFT )
	self.AvatarButton:SetSize( 32, 32 )
	self.AvatarButton.DoClick = function() self.Player:ShowProfile() end

	self.Avatar = vgui.Create( "AvatarImage", self.AvatarButton )
	self.Avatar:SetSize( 32, 32 )
	self.Avatar:SetMouseInputEnabled( false )        

	self.Name = self:Add( "DLabel" )
	self.Name:Dock( FILL )
	self.Name:SetFont( "ScoreboardDefault" )
	self.Name:DockMargin( 8, 0, 0, 0 )

	self.Mute = self:Add( "DImageButton" )
	self.Mute:SetSize( 32, 32 )
	self.Mute:Dock( RIGHT )

	self.Ping = self:Add( "DLabel" )
	self.Ping:Dock( RIGHT )
	self.Ping:SetWidth( 50 )
	self.Ping:SetFont( "ScoreboardDefault" )
	self.Ping:SetContentAlignment( 5 )
	
	self.Resources = self:Add( "DLabel" )
	self.Resources:Dock( RIGHT )
	self.Resources:SetWidth( 50 )
	self.Resources:SetFont( "ScoreboardDefault" )
	self.Resources:SetContentAlignment( 5 )

	self:Dock( TOP )
	self:DockPadding( 3, 3, 3, 3 )
	self:SetHeight( 32 + 3*2 )
	self:DockMargin( 4, 4, 4, 4 )
	
end

function PLAYER_LINE:Setup( ply )

	self.Player = ply
	self.Team = ply:GetTeam()

	self.Avatar:SetPlayer( ply )
	self.Name:SetText( ply:Nick() )

	self:Think( self )

end

function PLAYER_LINE:Think( )

	if ( not IsValid( self.Player ) or self.Player:GetTeam() ~= self.Team ) then
		self:Remove()
		return
	end

	if self.NumResources == nil or self.NumResources != self.Player:GetRes() then
		self.NumResources = self.Player:GetRes()
		print(self.Player)
		print(self.Player:GetRes())
		self.Resources:SetText( self.NumResources )
	end
	
	if ( self.NumPing == nil || self.NumPing != self.Player:Ping() ) then
		self.NumPing = self.Player:Ping()
		self.Ping:SetText( self.NumPing )
	end

	--
	-- Change the icon of the mute button based on state
	--
	if ( self.Muted == nil || self.Muted != self.Player:IsMuted() ) then

		self.Muted = self.Player:IsMuted()
		if ( self.Muted ) then
			self.Mute:SetImage( "icon32/muted.png" )
		else
			self.Mute:SetImage( "icon32/unmuted.png" )
		end

		self.Mute.DoClick = function() self.Player:SetMuted( !self.Muted ) end

	end

	--
	-- This is what sorts the list. The panels are docked in the z order,
	-- so if we set the z order according to kills they'll be ordered that way!
	-- Careful though, it's a signed short internally, so needs to range between -32,768k and +32,767
	--
	self:SetZPos( self.Player:UserID() )

end

function PLAYER_LINE:Paint( w, h )

	if not IsValid( self.Player ) then
		return
	end
	
	draw.RoundedBox( 4, 0, 0, w, h, Color( 123, 123, 123, 123 ) )

end

--
-- Convert it from a normal table into a Panel Table based on DPanel
--
PLAYER_LINE = vgui.RegisterTable( PLAYER_LINE, "DPanel" );
ScoreBoardAssets.PLAYER_LINE = PLAYER_LINE