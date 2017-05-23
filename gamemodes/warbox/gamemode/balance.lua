
-- This file will have values like health of units and such, all in this location.
-- This will make it easyer to balance things, although adding/removing things
-- also means this file has to be changed.

Balance = {}

-- if stuff gets sorted, MAKE SURE that you replace every usage of it to the correct one
local notsorted = {
	WorldTipDisplayRange = 250, -- Range used to limit how far a unit displays its WorldTip
	WorldTipDisplayRangeSqr = math.pow(250, 2),
	WorlTipUpdateRate = 0.100, -- seconds
	PaydayDelay = 60,
}
Balance.notsorted = notsorted

local rainbow = {
	default		= Color(234,	234,	234,	255 ),
	white		= Color(255,	255,	255,	255 ),
	red			= Color(255,	0,		0,		255 ),
	green		= Color(0,		255,	0,		255 ),
	blue		= Color(50,		222,	255,	255 ),
	darkred		= Color(150,	0,		0,		255 ),
	darkgreen	= Color(0,		150,	0,		255 ),
	darkblue	= Color(0,		0,		150,	255 ),
	nicered		= Color(211,	0,		0,		255 ),
	nicegreen	= Color(0,		200,	0,		255 ),
	niceblue	= Color(0,		75,		200,	255 ),
}
Balance.colors = rainbow


local player = {
	StartRes = 1000, -- Default player start resources
	MaxRes = 200000
}
Balance.player = player


-- Base-classes
local base_warprop = {
	IsWarProp = true,
	HasGravity = true,
	Model = "models/props_junk/watermelon01.mdl",
	BuildTime = 10, -- seconds
}
Balance.base_warprop = base_warprop


local base_structure = {
	IsStructure = true,
	OriginalMaxHealth = 500, -- Default structure health (original = if max-health changes this does not)
	BuildRegen = 100, -- Health regenerated per second if damaged while being built
	DeathDamage = 20,
	DeathRadius = 100
}
base_structure = table.Merge( table.Copy(base_warprop), base_structure ) -- merge with baseclass
Balance.base_structure = base_structure


local base_unit = {
	IsUnit = true,
	IsMobile = false,
	IsAi = false,
    IsShooter = false,
	Delay = 1, -- seconds
	OriginalMaxHealth = 25, -- Default unit health
	Speed = 100,
	MoveRange = 42,
	Delay = 0.250, -- seconds
	Range = 500,
	Priority = {
		base_structure	=	10,
		base_unit		=	20
	}
}
base_unit = table.Merge( table.Copy(base_structure), base_unit )
Balance.base_unit = base_unit

--[[
local base_mobile = {
	IsMobile = true,
	OriginalMaxHealth = 10, -- Default mobile unit health
	Speed = 100,
	MoveRange = 42
}
base_mobile = table.Merge( table.Copy(base_unit), base_mobile )
Balance.base_mobile = base_mobile


local base_ai = {
	IsAi = true,
	OriginalMaxHealth = 10, -- Default ai unit health
	Delay = 0.250, -- seconds
	Range = 500,
	Priority = {
		base_structure	=	10,
		base_unit		=	20
	}
}
base_ai = table.Merge( table.Copy(base_unit), base_ai )
Balance.base_ai = base_ai


local base_mobile_ai = {
	OriginalMaxHealth = 5, -- Default ai unit health
	Delay = 0.500, -- seconds
	Range = 250,
	Speed = 50,
	MoveRange = 50
}
base_mobile_ai = table.Merge( table.Copy(base_mobile), base_mobile_ai )
base_mobile_ai = table.Merge( table.Copy(base_ai), base_mobile_ai )
Balance.base_mobile_ai = base_mobile_ai
--]]

-- warprops
local wb_warprop_capturepoint = {
	Model = "models/props_trainstation/tracksign01.mdl",
	BuildTime = 0,
	Range = 250,
	Delay = 0.5,
	TimeToCapture = 20, -- A single regular unit (no multiplier) takes 20 seconds to capture a point
	Income = 1000
}
wb_warprop_capturepoint = table.Merge( table.Copy(base_structure), wb_warprop_capturepoint)
Balance.wb_warprop_capturepoint = wb_warprop_capturepoint


-- structures
local wb_structure_prop = {
	Model = "",
	MassRatio = 2.5,
	AreaRatio = 1.685,
	SizeRatio = 0.796,
	OriginalMaxHealth = 2000, -- Default structure health
	BuildTime = 1, -- seconds
	DeathDamage = 10,
	DeathRadius = 100
}
wb_structure_prop = table.Merge( table.Copy(base_structure), wb_structure_prop )
Balance.wb_structure_prop = wb_structure_prop

local wb_structure_constructionyard = {
	IsConstructionYard = true,
	Model = "models/props_buildings/watertower_001c.mdl",
	OriginalMaxHealth	= 10000, -- Default structure health
	BuildTime = 120, -- seconds
	CostTable = {0, 50000, 100000, 250000, 350000, 500000, 700000, 1000000}, -- After the last cost, it is multiplies by 2 for each new
	Range = 3000, -- Range of influence
	DeathDamage = 5000,
	DeathRadius = 1000
}
wb_structure_constructionyard = table.Merge( table.Copy(base_structure), wb_structure_constructionyard )
Balance.wb_structure_constructionyard = wb_structure_constructionyard


-- shooters
local wb_shooter_scout = {
	IsMobile = true,
	IsAi = true,
    IsShooter = true,
	OriginalMaxHealth = 16,
	BuildRegen = 100,
	Cost = 50,
	Delay = 1.200,
	Range = 250,
	Speed = 75,
	MoveRange = 50,
	Damage = 3,
	CaptureMultiplier = 2
}
wb_shooter_scout = table.Merge( table.Copy(base_unit), wb_shooter_scout )
Balance.wb_shooter_scout = wb_shooter_scout


local wb_shooter_infantry = {
	IsMobile = true,
	IsAi = true,
    IsShooter = true,
	OriginalMaxHealth = 25,
	BuildRegen = 100,
	Cost = 100,
	Delay = 0.500,
	Speed = 50,
	MoveRange = 50,
	Range = 500,
	NumberOfBullets = 1,
	Spread = Vector(0.05, 0.05, 0.05),
	Damage = 5,
	BulletForce = 1,
}
wb_shooter_infantry = table.Merge( table.Copy(base_unit), wb_shooter_infantry )
Balance.wb_shooter_infantry = wb_shooter_infantry
