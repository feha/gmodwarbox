
-- Table used for 'static' functions
GameStrings = {}
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
	return strings[GameStrings.current][str]
end
GameStrings.GetString = GetString


-- Decode a gamestring file into a table of gamestrings
local function Decode( source_string, target_table, filename )
	
	if source_string ~= "" then
		local rows = string.Explode( "\n", source_string, true )
		
		for k,row in pairs(rows) do
			if row ~= "" and string.find(row, "^[^--]") then
				local keyvalue = string.Explode( "=", row, true )
				assert(#keyvalue == 2, "Decode - Invalid format of row: [" .. tostring(k) .. ", \"".. row .."\"] in file: " .. filename)
				target_table[keyvalue[1]] = keyvalue[2]
			end
		end
		
		return target_table
	end
	
end

local function DecodeFile( filename, target_table )
	
	if not file.Exists( "gamestrings/" .. filename .. ".txt" , "DATA" ) then
		error( "DecodeFile - Tried to load non-existent gamestrings from file: " .. filename )
	end
	
	local str = file.Read( "gamestrings/" .. filename .. ".txt" , "DATA" )
	
	target_table[filename] = {}
	Decode(str, target_table[filename], filename)
	
end


-- Recursivelly finds all files in a directory and adds them to target table.
local function FindListOfGameStrings( directory, target_table )
	
	if not file.IsDir( directory , "DATA" ) then
		error( "FindListOfGameStrings - Input is not a Directory: " .. directory )
	end
	
	local files, directories = file.Find( directory, "DATA" )
	
	for _,filename in pairs(files) do
		if filename ~= "" then
			table.insert( target_table, directory .. "/" .. string.GetFileFromFilename(filename) )
		end
	end
	
	for _,dir in pairs(directories) do
		FindListOfGameStrings( directory .. "/" .. dir )
	end
	
end
FindListOfGameStrings( "gamestrings", GameStrings.files )
DecodeFile( GameStrings.default, strings )

