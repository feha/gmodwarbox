WarboxTEAM = {}

local teams = {}

function WarboxTEAM.GetTeam( index )
	return teams[index]
end


local meta = {}
meta.__index = meta


-- Index ----------------
function meta:GetIndex()
	return self.Index
end

function meta:IsAdmin( )
	return not self.Public
end

-- Name ----------------
function meta:GetName()
	return self.Name
end

function meta:SetName( name )
	assert(type(name) == "string", "name has to be a string.")
	self.Name = name
end

-- Color ----------------
function meta:GetColor()
	return Color( self.Color.r, self.Color.g, self.Color.b, self.Color.a )
end

function meta:SetColor( color )
	--assert(type(color) == "Color", "color has to be a color.")
	self.Color = Color( color.r, color.g, color.b, color.a )
end

-- Score ----------------
function meta:GetScore()
	return team.GetScore(self:GetIndex())
end

function meta:SetScore( score )
	assert(type(score) == "number", "score has to be a number.")
	team.SetScore(self:GetIndex(), score)
end

function meta:AddScore( score )
	assert(type(score) == "number", "score has to be a number.")
	team.AddScore(self:GetIndex(), score)
end


-- Players ----------------
function meta:GetPlayerCount()
	local sum = 0
	for k,p in pairs(self.players) do
		sum = sum + 1
	end
	return sum
end

function meta:IsEmpty()
	return self.players == nil or self.players == {} or self:GetPlayerCount() == 0
end

function meta:GetPlayersArray()
	local tbl = {}
	for k,_ in pairs(self.players) do
		table.insert(tbl,k)
	end
	return tbl
end

function meta:GetPlayers()
	return table.Copy(self.players)
end

function meta:GetPlayersReference()
	return self.players
end

function meta:AddPlayer(ply)
	self.players[ply] = ply
end

function meta:RemovePlayer(ply)
	self.players[ply] = nil
end


-- Units ----------------
-- TODO: make shared with client
function meta:GetUnitCount()
	return #self.units or 0
end


function meta:GetUnitsArray()
	
	local tbl = {}
	for k,_ in pairs(self.units) do
		table.insert(tbl,k)
	end
	return tbl
	
end

function meta:GetUnits()
	return table.Copy(self.units)
end


function meta:SetUnits( units )
	
	self.units = {}
	for k,v in pairs(units or {}) do
		assert(v.IsUnit == true, "Table should be a table of Units.")
		self.units[v] = v
	end
	
end


function meta:AddUnits( units )
	
	for _,v in pairs(units) do
		self:AddUnit(v)
	end
	
end

function meta:AddUnit( unit )
	
	assert(unit.IsUnit == true, "Table should be a table of Units.")
	self.units[unit] = unit
	
end


function meta:RemoveUnits( units )
	
	for _,v in pairs(units) do
		self:RemoveUnit(v)
	end
	
end

function meta:RemoveUnit( unit )
	
	assert(unit.IsUnit == true, "Table should be a table of Units.")
	self.units[unit] = nil
	
end



setmetatable(WarboxTEAM, {
	__call = function( self, index, name, color, public )
		assert(type(index) == "number", "index of type " .. type(index) .. " has to be a number.")
		assert(type(name) == "string", "name of type " .. type(index) .. " has to be a string.")
		--assert(type(color) == "Color", "color of type " .. type(index) .. " has to be a color.") -- color == number?
		
		team.SetUp( index, name, Color( color.r, color.g, color.b, color.a ) )
		
		local Team = setmetatable({}, meta)
		teams[index] = Team
		Team.Index = index
		Team.Name = name
		Team.Color = Color( color.r, color.g, color.b, color.a )
		Team.Public = public -- nil/false if only admins may join
		
		
		Team.Open = true -- false When a player locks his team
		Team.Score = 0
		Team.Research = {}
		Team.players = {}
		Team.units = {}
		
		return Team
	end
})
