DeriveGamemode("sandbox")

GM.Name 		= "Warbox"
GM.Author 		= "Feha"
GM.Email 		= "felix@hallqvist.se"
GM.Website 		= "needs a forum"

--DeriveGamemode("sandbox")
GM.IsSandboxDerived = true

-- Add all clientside and shared files here
if SERVER then
	-- .txt files
	AddCSLuaFile( "../data/gamestrings/english.txt" )
	
	-- .lua files
	AddCSLuaFile( "utility.lua" )
	AddCSLuaFile( "balance.lua" )
	AddCSLuaFile( "gamestrings.lua" )
	AddCSLuaFile( "team_extension.lua" )
	AddCSLuaFile( "player_extension.lua" )
	AddCSLuaFile( "cl_scoreboard.lua" )
	AddCSLuaFile( "scoreboard/scoreboard.lua" )
	AddCSLuaFile( "scoreboard/team_frame.lua" )
	AddCSLuaFile( "scoreboard/player_line.lua" )
end

-- Include shared files
include( 'utility.lua' )
include( 'balance.lua' )
include( 'gamestrings.lua' )
include( 'team_extension.lua' )
include( 'player_extension.lua' )


-- Create the initial teams
-- inside or outside init?
--			ID	Name								Color(	Red		Green	Blue	Alpha)	public
WarboxTEAM( -2,	GameStrings.GetString("neutral"),	Color(	255,	255,	255,	255 ) )
WarboxTEAM( -1,	GameStrings.GetString("admin"),		Color(	0,		0,		0,		255 ) )
WarboxTEAM( 0,	GameStrings.GetString("spectator"),	Color(	255,	255,	255,	255 ),	true )
WarboxTEAM( 1,	GameStrings.GetString("red"),		Color(	255,	0,		0,		255 ),	true )
WarboxTEAM( 2,	GameStrings.GetString("green"),		Color(	0,		255,	0,		255 ),	true )
WarboxTEAM( 3,	GameStrings.GetString("blue"),		Color(	0,		0,		255,	255 ),	true )
WarboxTEAM( 4,	GameStrings.GetString("cyan"),		Color(	0,		200,	200,	255 ),	true )
WarboxTEAM( 5,	GameStrings.GetString("magenta"),	Color(	200,	0,		200,	255 ),	true )
WarboxTEAM( 6,	GameStrings.GetString("yellow"),	Color(	200,	200,	0,		255 ),	true )
WarboxTEAM( 7,	GameStrings.GetString("???"),		Color(	100,	255,	255,	255 ),	true )
WarboxTEAM( 8,	GameStrings.GetString("pink"),		Color(	255,	100,	255,	255 ),	true )
WarboxTEAM( 9,	GameStrings.GetString("orange???"),	Color(	255,	255,	100,	255 ),	true )

function GM:Initialize()
	self.BaseClass.Initialize( self )
end
