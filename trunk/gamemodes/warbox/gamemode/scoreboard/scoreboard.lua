
--
-- Here we define a new panel table for the scoreboard. It basically consists
-- of a header and a scrollpanel - into which the player lines are placed.
--
local SCORE_BOARD =
{
    Init = function( self )
		print("init board")
        self.Header = self:Add( "Panel" )
        self.Header:Dock( TOP )
        self.Header:SetHeight( 100 )

        self.Name = self.Header:Add( "DLabel" )
        self.Name:SetFont( "ScoreboardDefaultTitle" )
        self.Name:SetTextColor( Color( 255, 255, 255, 255 ) )
        self.Name:Dock( TOP )
        self.Name:SetHeight( 40 )
        self.Name:SetContentAlignment( 5 )
        self.Name:SetExpensiveShadow( 2, Color( 0, 0, 0, 200 ) )
		
        self.Teams = self:Add( "DScrollPanel" )
        self.Teams:Dock( FILL )
		self.Teams.Think = function( self )
			self:SizeToChildren( false, true )
			self:DockPadding( 0, 0, 0, 8 ) -- Why does only padding down work? well at least it fixes margin problem
		end
		self.Teams.Paint = function( self, w, h )
			draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 0, 200 ) )
		end

    end,

    PerformLayout = function( self )

        self:SetSize( 700, ScrH() - 200 )
        self:SetPos( ScrW() / 2 - 350, 100 )

    end,

    Paint = function( self, w, h )

        --draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 0, 200 ) )

    end,

    Think = function( self, w, h )

        self.Name:SetText( GetHostName() )

        --
        -- Loop through each player, check if its team has a score entry - create it otherwise.
        --
        for id, ply in pairs( player.GetAll() ) do
			
            if ( IsValid( ply:GetTeam().ScoreEntry ) ) then continue end

            ply:GetTeam().ScoreEntry = vgui.CreateFromTable( ScoreBoardAssets.TEAM_FRAME, ply:GetTeam().ScoreEntry )
            ply:GetTeam().ScoreEntry:Setup( ply:GetTeam() )

            self.Teams:AddItem( ply:GetTeam().ScoreEntry )

        end        

    end,
}

--vgui.Register( "ScoreBoard", PANEL, "Panel" ) -- might change to this
SCORE_BOARD = vgui.RegisterTable( SCORE_BOARD, "EditablePanel" );
ScoreBoardAssets.SCORE_BOARD = SCORE_BOARD