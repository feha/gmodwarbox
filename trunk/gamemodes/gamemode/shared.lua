DeriveGamemode("sandbox")

GM.Name 		= "Warbox"
GM.Author 		= "Feha"
GM.Email 		= "felix@hallqvist.se"
GM.Website 		= "needs a forum"

--DeriveGamemode("sandbox")
GM.IsSandboxDerived = true

include('balance.lua')
include('team_extension.lua')

-- inside or outside init?
--		ID		Name			Color(	Red		Green	Blue	Alpha)
WarboxTEAM( -1,		"Admin",		Color(	0,		0,		0,		255 ) )
WarboxTEAM( 0,		"Spectator",	Color(	255,	255,	255,	255 ) )
WarboxTEAM( 1,		"Red",			Color(	255,	0,		0,		255 ) )
WarboxTEAM( 2,		"Green",		Color(	0,		255,	0,		255 ) )
WarboxTEAM( 3,		"Blue",			Color(	0,		0,		255,	255 ) )
WarboxTEAM( 4,		"Cyan",			Color(	0,		200,	200,	255 ) )
WarboxTEAM( 5,		"Magenta",		Color(	200,	0,		200,	255 ) )
WarboxTEAM( 6,		"Yellow",		Color(	200,	200,	0,		255 ) )
WarboxTEAM( 7,		"???",			Color(	100,	255,	255,	255 ) )
WarboxTEAM( 8,		"Pink",			Color(	255,	100,	255,	255 ) )
WarboxTEAM( 9,		"Orange???",	Color(	255,	255,	100,	255 ) )

function GM:Initialize()
	self.BaseClass.Initialize( self )
end
