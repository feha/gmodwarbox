
-- This file will have values like health of units and such, all in this location.
-- This will make it easyer to balance things, although adding/removing things
-- also means this file has to be changed.

Balance = {}

-- if stuff gets sorted, MAKE SURE that you replace every usage of it to the correct one
local notsorted = {
	WorldTipDisplayRange = 250, -- Range used to limit how far a unit displays its WorldTip
	WorldTipDisplayRangeSqr = math.pow(250, 2),
	WorlTipUpdateRate = 0.100 -- seconds
}
Balance.notsorted = notsorted


local player = {
	StartRes = 500, -- Default player start resources
	MaxRes = 200000
}
Balance.player = player


-- Base-classes
local base_structure = {
	IsStructure = true,
	Model = "models/props_junk/watermelon01.mdl",
	MaxHealth = 500, -- Default structure health
	Delay = 1, -- seconds
	BuildTime = 10, -- seconds
	DeathDamage = 50,
	DeathRadius = 100
}
Balance.base_structure = base_structure


local base_unit = {
	IsUnit = true,
--	IsAi = false,
--	IsMobile = false,
--	IsShooter = false,
	MaxHealth = 100 -- Default unit health
}
base_unit = table.Merge( table.Copy(base_structure), base_unit ) -- merge with baseclass
Balance.base_unit = base_unit


local base_mobile = {
	IsMobile = true,
	MaxHealth = 50, -- Default mobile unit health
	Speed = 100,
	MoveRange = 42
}
base_mobile = table.Merge( table.Copy(base_unit), base_mobile )
Balance.base_mobile = base_mobile


local base_ai = {
	IsAi = true,
	MaxHealth = 100, -- Default ai unit health
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
	MaxHealth = 50, -- Default ai unit health
	Delay = 0.500, -- seconds
	Range = 250,
	Speed = 50,
	MoveRange = 50
}
base_mobile_ai = table.Merge( table.Copy(base_mobile), base_mobile_ai )
base_mobile_ai = table.Merge( table.Copy(base_ai), base_mobile_ai )
Balance.base_mobile_ai = base_mobile_ai


local testshooter = {
	IsShooter = true,
	MaxHealth = 50, -- Default ai unit health
	Delay = 1.200, -- seconds
	Range = 250,
	Speed = 50,
	MoveRange = 50,
	Damage = 10
}
testshooter = table.Merge( table.Copy(base_mobile_ai), testshooter )
Balance.testshooter = testshooter