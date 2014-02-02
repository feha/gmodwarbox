
-- Table used for 'static' functions
GameStrings = {}
GameStrings.directory = "gamemodes/Warbox/content/data/gamestrings"
GameStrings.default = "english"
GameStrings.current = GameStrings.default

GameStrings.files = {}

local strings = {}
GameStrings.strings = strings


local function SetGameStrings(str)
	GameStrings.current = str
end
GameStrings.SetGameStrings = SetGameStrings

local function GetGameStrings(str)
	return GameStrings.current
end
GameStrings.SetGameStrings = SetGameStrings


local function GetString(str)
	strings[GameStrings.current] = strings[GameStrings.current] or {}
	return strings[GameStrings.current][str] or "MISSING GAMESTRING"
end
GameStrings.GetString = GetString


-- Decode a gamestring file into a table of gamestrings
local function Decode( source_string, target_table, filename )
	if source_string ~= "" then
		local rows = string.Explode( "\n", source_string, true )
		
		for k,row in pairs(rows) do
			local _, _, left, right = string.find( row, "[\t%s]*([^\t%s]+.*[^\t%s]+)[\t%s]*=[^\"]*\"([^\n\r]+)\"[^\"]*" )
			local _, _, left2, right2 = string.find( row, "[\t%s]*([^\t%s]+.*[^\t%s]+)[\t%s]*=[\t%s]*([^\t%s]+.*[^\t%s]+)[\t%s]*" )
			if left and right then
				target_table[left] = right
			elseif left2 and right2 then
				target_table[left2] = right2
			end
		end
		
		return target_table
	end
	
end

local function DecodeFile( filename, target_table )
	
	--if not file.Exists( "WarBox/content/data/gamestrings/" .. filename .. ".txt" , "GAME" ) then
	--	error( "DecodeFile - Tried to load non-existent gamestrings from file: " .. filename )
	--end
	
	local str = file.Read( GameStrings.files[filename], "GAME" )
	
	target_table[filename] = {}
	Decode(str, target_table[filename], filename)
	
end


-- Recursivelly finds all files in a directory and adds them to target table.
local function FindListOfGameStrings( directory, path, target_table )
	
	if not file.IsDir( directory , path ) then
		-- Bugged during map load, for some reason always returns false then, so lets retry until it works
		timer.Simple( 0.1, function() FindListOfGameStrings( directory, path, target_table ) end )
		error( "FindListOfGameStrings - Not a directory! directory: \"" .. directory .. "\" & path: \"" .. path .. "\"" )
	end
	
	local files, directories = file.Find( directory .. "/*.txt", path )
	for _,filename in pairs(files) do
		local name = ({string.find(filename, "([^/]+).txt$")})[3] -- "dirs/name.txt" -> "name"
		if name ~= "" then
			target_table[name] = directory .. "/" .. filename
		end
	end
	
	for _,dir in pairs(directories) do
		FindListOfGameStrings( directory .. "/" .. dir )
	end
	
	-- Load the default
	DecodeFile( GameStrings.default, strings )
	
end
FindListOfGameStrings( GameStrings.directory, "GAME", GameStrings.files )

