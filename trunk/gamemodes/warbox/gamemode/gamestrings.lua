
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
	return strings[GameStrings.current][str] or "MISSING GAMESTRING"
end
GameStrings.GetString = GetString


-- Decode a gamestring file into a table of gamestrings
local function Decode( source_string, target_table, filename )
	if source_string ~= "" then
		local rows = string.Explode( "\n", source_string, true )
		
		for k,row in pairs(rows) do
			local _, _, left, right = string.find( row, "[^\"]*\"([^\"\n\r]*)\".*=.*\"([^\"\n\r]*)\"[^\"]*" )
			local _, _, left2, right2 = string.find( row, "[\t%s]*([^\t%s]+.*[^\t%s]+)[\t%s]*=[\t%s]*([^\t%s]+.*[^\t%s]+)[\t%s]*" )
			if left and right then
				print(left .. "=" ..right)
				target_table[left] = right
			elseif left2 and right2 then
				print(left2 .. "=" ..right2)
				target_table[left2] = right2
			end
		end
		
		return target_table
	end
	
end

local function DecodeFile( filename, target_table )
	
	--if not file.Exists( "WarBox/content/data/gamestrings/" .. filename .. ".txt" , "lcl" ) then
	--	error( "DecodeFile - Tried to load non-existent gamestrings from file: " .. filename )
	--end
	
	local str = file.Read( "WarBox/content/data/gamestrings/" .. filename .. ".txt" , "lcl" )
	
	target_table[filename] = {}
	Decode(str, target_table[filename], filename)
	
end


-- Recursivelly finds all files in a directory and adds them to target table.
local function FindListOfGameStrings( directory, path, target_table )
	
	if not file.IsDir( directory , path ) then
		error( "FindListOfGameStrings - Not a directory! directory: " .. directory .. " & path: " .. path )
	end
	
	local files, directories = file.Find( directory .. "/*.txt", path )
	
	for _,filename in pairs(files) do
		if filename ~= "" then
			table.insert( target_table, directory .. "/" .. string.GetFileFromFilename(filename) )
		end
	end
	
	for _,dir in pairs(directories) do
		FindListOfGameStrings( directory .. "/" .. dir )
	end
	
end
FindListOfGameStrings( "WarBox/content/data/gamestrings", "lcl", GameStrings.files )
DecodeFile( GameStrings.default, strings )

