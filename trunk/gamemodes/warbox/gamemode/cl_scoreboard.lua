
ScoreBoardAssets = {}

include( "scoreboard/scoreboard.lua" )
include( "scoreboard/team_frame.lua" )
include( "scoreboard/player_line.lua" )

surface.CreateFont( "ScoreboardDefault",
{
    font        = "Helvetica",
    size        = 22,
    weight        = 800
})

surface.CreateFont( "ScoreboardDefaultTitle",
{
    font        = "Helvetica",
    size        = 32,
    weight        = 800
})

--[[---------------------------------------------------------
   Name: gamemode:ScoreboardShow( )
   Desc: Sets the scoreboard to visible
-----------------------------------------------------------]]
function GM:ScoreboardShow()
	
    if ( !IsValid( g_Scoreboard ) ) then
		print(ScoreBoardAssets.SCORE_BOARD)
        g_Scoreboard = vgui.CreateFromTable( ScoreBoardAssets.SCORE_BOARD )
    end
	
    if ( IsValid( g_Scoreboard ) ) then
        g_Scoreboard:Show()
        g_Scoreboard:MakePopup()
        g_Scoreboard:SetKeyboardInputEnabled( false )
    end

end

--[[---------------------------------------------------------
   Name: gamemode:ScoreboardHide( )
   Desc: Hides the scoreboard
-----------------------------------------------------------]]
function GM:ScoreboardHide()

    if ( IsValid( g_Scoreboard ) ) then
        g_Scoreboard:Hide()
    end

end


--[[---------------------------------------------------------
   Name: gamemode:HUDDrawScoreBoard( )
   Desc: If you prefer to draw your scoreboard the stupid way (without vgui)
-----------------------------------------------------------]]
function GM:HUDDrawScoreBoard()

end

