
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
	assert(type(score) == "number", "score of type " .. type(index) .. " has to be a number.")
	team.SetScore(self:GetIndex(), score)
end

function meta:AddScore( score )
	assert(type(score) == "number", "score of type " .. type(index) .. "  has to be a number.")
	team.AddScore(self:GetIndex(), score)
end

-- Income & Resources ----------------
-- resource income over time. split and given to each player in the team
-- Not sure if I want this to exist here, although it does matter a lot, so still possible.
function meta:GetIncome()
	return self.Income
end

function meta:SetIncome( income )
	assert(type(income) == "number", "income of type " .. type(index) .. "  has to be a number.")
	self.Income = income
end

function meta:AddIncome( income )
	assert(type(income) == "number", "income of type " .. type(index) .. "  has to be a number.")
	self.Income = self.Income + income
end

-- Possibly make teams actually have a variable with res, and make sure its updated when players res is?
-- Would need to somehow make sure it links to everything relevant and isnt hell to edit anything
-- Like player join/leave team, player res change, other?
-- Also possible to make a shared pool of res, doubt it will be the only one, but something that could
-- somehow affect teamplay in an interesting way that simply donating back and forth cant?
-- Scoreboard kinda spam this afaik?
function meta:GetRes()
	
	local sum = 0
	for _, ply in pairs( self:GetPlayersReference() ) do
		
		sum = sum + ply:GetRes()

	end
	
	return sum
	
end

function meta:AddRes( res )
	
	assert(type(res) == "number", "res of type " .. type(index) .. "  has to be a number.")
	if self:GetConstructionYardCount() > 0 then
		local numplayers = self:GetPlayerCount()
		local playerincome = res / numplayers
		for ply,_ in pairs(self:GetPlayersReference()) do
			ply:Message( string.format(GameStrings.GetString("payday_received"), playerincome ), "nicered" )
			ply:AddRes(playerincome)
		end
	else
		for ply,_ in pairs(self:GetPlayersReference()) do
			ply:Message( string.format(GameStrings.GetString("payday_no_constructionyard") ), "nicered" )
		end
	end
	
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


-- Construction Yards ----------------
function meta:PointIsInTerritory( point )
	return ConstructionYard.PointIsWithinInfluence( point, self )
end

function meta:GetConstructionYardCount()
	local sum = 0
	for _,_ in pairs(self.constructionyards) do
		sum = sum + 1
	end
	return sum
end

function meta:GetNumberOfConstructionYardsBuilt()
	return self.NumberOfConstructionYardsBuilt
end


function meta:GetConstructionYardsArray()
	
	local tbl = {}
	for k,_ in pairs(self.constructionyards) do
		table.insert(tbl,k)
	end
	return tbl
	
end

function meta:GetConstructionYards()
	return table.Copy(self.constructionyards)
end


function meta:SetConstructionYards( constructionyards )
	
	constructionyards = constructionyards or {}
	self.constructionyards = {}
	for _,_ in pairs(constructionyards) do
		assert(v.IsConstructionYard == true, "Table should be a table of ConstructionYards.")
		self.constructionyards[v] = v
	end
	
	-- TODO: How should this handle self.NumberOfConstructionYardsBuilt?
	-- self.NumberOfConstructionYardsBuilt = #constructionyards
	
end


function meta:AddConstructionYards( constructionyards )
	
	constructionyards = constructionyards or {}
	for _,v in pairs(constructionyards) do
		assert(v.IsConstructionYard == true, "Table should be a table of ConstructionYards.")
		self:AddConstructionYard(v)
	end
	
	self.NumberOfConstructionYardsBuilt = self.NumberOfConstructionYardsBuilt + #constructionyards
	
end

function meta:AddConstructionYard( entity )
	
	assert(entity.IsConstructionYard == true, "entity should be a ConstructionYard.")
	self.constructionyards[entity] = entity
	
	self.NumberOfConstructionYardsBuilt = self.NumberOfConstructionYardsBuilt + 1
	
end


function meta:RemoveConstructionYards( constructionyards )
	
	for _,v in pairs(constructionyards or {}) do
		self:RemoveConstructionYard(v)
	end
	
end

function meta:RemoveConstructionYard( entity )
	
	assert(entity.IsConstructionYard == true, "entity should be a ConstructionYard.")
	assert(entity:GetTeam() == self, "entity should belong to the team it is being removed from.")
	self.constructionyards[entity] = nil
	
end


-- Units ----------------
-- TODO: make shared with client
function meta:GetUnitCount()
	local sum = 0
	for _,_ in pairs(self.units) do
		sum = sum + 1
	end
	return sum
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
	
	for _,v in pairs(units or {}) do
		self:AddUnit(v)
	end
	
end

function meta:AddUnit( entity )
	
	assert(entity.IsUnit == true, "entity should be a Unit.")
	self.units[entity] = entity
	
end


function meta:RemoveUnits( units )
	
	for _,v in pairs(units or {}) do
		self:RemoveUnit(v)
	end
	
end

function meta:RemoveUnit( entity )
	
	assert(entity.IsUnit == true, "entity should be a Unit.")
	assert(entity:GetTeam() == self, "entity should belong to the team it is being removed from.")
	self.units[entity] = nil
	
end


-- The static 'class' WarboxTEAM used to create teams, and with some static utility functions
WarboxTEAM = {}

local teams = {}

function WarboxTEAM.GetTeamsReference( )
	return teams
end

function WarboxTEAM.GetTeamsCopy( )
	return table.Copy(teams)
end

function WarboxTEAM.GetTeam( index )
	return teams[index]
end

function WarboxTEAM.IsTeam( teem )
	if teem == nil then return false end
	return getmetatable(teem) == meta
end

function WarboxTEAM.Payday( )
	print("PAYDAY")
	for k,teem in pairs(teams) do
		teem:AddRes(teem:GetIncome())
	end
end
timer.Create( "WarBox.team_extension.Payday", Balance.notsorted.PaydayDelay, 0, WarboxTEAM.Payday )


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
		Team.Income = 0
		Team.NumberOfConstructionYardsBuilt = 0
		Team.Research = {}
		Team.players = {}
		Team.constructionyards = {}
		Team.units = {}
		
		return Team
	end
})
