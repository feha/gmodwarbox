DeriveGamemode("sandbox")

GM.Name 		= "Warbox"
GM.Author 		= "Feha"
GM.Email 		= "felix@hallqvist.se"
GM.Website 		= "needs a forum"

--DeriveGamemode("sandbox")
GM.IsSandboxDerived = true

-- Add all clientside and shared files here
if SERVER then
	AddCSLuaFile( "balance.lua" )
	AddCSLuaFile('team_extension.lua')
	AddCSLuaFile('player_extension.lua')
	AddCSLuaFile( "cl_worldtips.lua" )
	AddCSLuaFile( "cl_scoreboard.lua" )
	AddCSLuaFile( "scoreboard/scoreboard.lua" )
	AddCSLuaFile( "scoreboard/team_frame.lua" )
	AddCSLuaFile( "scoreboard/player_line.lua" )
end

-- Include shared files
include('balance.lua')
include('team_extension.lua')
include('player_extension.lua')

-- Create the initial teams
-- inside or outside init?
--		ID		Name			Color(	Red		Green	Blue	Alpha)		public
WarboxTEAM( -1,		"Admin",		Color(	0,		0,		0,		255 ) )
WarboxTEAM( 0,		"Spectator",	Color(	255,	255,	255,	255 ),	true )
WarboxTEAM( 1,		"Red",			Color(	255,	0,		0,		255 ),	true )
WarboxTEAM( 2,		"Green",		Color(	0,		255,	0,		255 ),	true )
WarboxTEAM( 3,		"Blue",			Color(	0,		0,		255,	255 ),	true )
WarboxTEAM( 4,		"Cyan",			Color(	0,		200,	200,	255 ),	true )
WarboxTEAM( 5,		"Magenta",		Color(	200,	0,		200,	255 ),	true )
WarboxTEAM( 6,		"Yellow",		Color(	200,	200,	0,		255 ),	true )
WarboxTEAM( 7,		"???",			Color(	100,	255,	255,	255 ),	true )
WarboxTEAM( 8,		"Pink",			Color(	255,	100,	255,	255 ),	true )
WarboxTEAM( 9,		"Orange???",	Color(	255,	255,	100,	255 ),	true )

function GM:Initialize()
	self.BaseClass.Initialize( self )
end
