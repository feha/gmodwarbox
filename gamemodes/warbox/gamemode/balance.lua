
-- This file will have values like health of units and such, all in this location.
-- This will make it easyer to balance things, although adding/removing things
-- also means this file has to be changed.

Balance = {}


local player = {
	StartRes = 500, -- Default player start resources
	MaxRes = 200000
}
Balance.player = player


-- Base-classes
local base_structure = {
	Model = "models/props_junk/watermelon01.mdl",
	MaxHealth = 500, -- Default structure health
	Delay = 1, -- seconds
	BuildTime = 1, -- seconds
	DeathDamage = 50,
	DeathRadius = 100
}
Balance.base_structure = base_structure


local base_unit = {
	MaxHealth = 100 -- Default unit health
}
base_unit = table.Merge( table.Copy(base_structure), base_unit ) -- merge with baseclass
Balance.base_unit = base_unit


local base_mobile = {
	MaxHealth = 50, -- Default mobile unit health
	Speed = 100,
	MoveRange = 42
}
base_mobile = table.Merge( table.Copy(base_unit), base_mobile )
Balance.base_mobile = base_mobile


local base_ai = {
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
base_mobile_ai = table.Merge( table.Copy(base_ai), base_mobile_ai )
Balance.base_mobile_ai = base_mobile_ai
