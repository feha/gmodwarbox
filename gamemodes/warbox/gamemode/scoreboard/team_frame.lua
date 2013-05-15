
--
-- This defines a new panel type for the team frames. The team frames is given a team
-- and then from that point on it pretty much looks after itself. It updates team info
-- in the think function, and removes itself when the team is empty.
--
local TEAM_FRAME =
{
    Init = function( self )
		
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
		
        self:Dock( TOP )
        self:DockPadding( 4, 4, 4, 4 )
        self:DockMargin( 4, 4, 4, 0 ) -- Why doesnt margin down work? well the rest fixes padding problem
		
        self.Players = self:Add( "Panel" )
        self.Players:Dock( FILL )

    end,

    Setup = function( self, teem )
		
        self.Team = teem
		
        self.Name:SetText( teem:GetName() )

        self:Think( self )

    end,
	
    Think = function( self )
		
		--
        -- Loop through each player in team, and if one doesn't have a score entry - create it.
        --
        for id, ply in pairs( self.Team:GetPlayersReference() ) do
            if IsValid( ply.ScoreEntry ) then continue end

            ply.ScoreEntry = vgui.CreateFromTable( ScoreBoardAssets.PLAYER_LINE, ply.ScoreEntry )
            ply.ScoreEntry:Setup( ply )

            self.Players:Add( ply.ScoreEntry )

        end
		
        if self.Team:IsEmpty() then
            self:Remove()
            return
        end
		
		self.Players:SizeToChildren( false, true ) 
		self:SizeToChildren( false, true ) 
		
        if self.NumScore == nil or self.NumScore != self.Team:GetScore() then
            self.NumScore    =    self.Team:GetScore()
            self.Score:SetText( self.Team:GetScore() )
        end
		
        --
        -- This is what sorts the list. The panels are docked in the z order,
        -- so if we set the z order according to kills they'll be ordered that way!
        -- Careful though, it's a signed short internally, so needs to range between -32,768k and +32,767
        --
        self:SetZPos( -self.Team:GetIndex() )

    end,

    Paint = function( self, w, h )

        --if self.Team:IsEmpty() then
        --    return
        --end

        --
        -- We draw our background a different colour based on the status of the player
        --
		
        draw.RoundedBox( 4, 0, 0, w, h, self.Team:GetColor() )

    end,
}

--
-- Convert it from a normal table into a Panel Table based on DPanel
--
TEAM_FRAME = vgui.RegisterTable( TEAM_FRAME, "DPanel" );
ScoreBoardAssets.TEAM_FRAME = TEAM_FRAME