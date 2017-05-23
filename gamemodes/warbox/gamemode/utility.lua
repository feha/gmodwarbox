

-- Gives net lib a 'smart' Send/Broadcast function
net.End = function( ply )
	if SERVER then
		if ply then
			return net.Send( ply )
		else
			return net.Broadcast()
		end
	else
		return net.SendToServer()
	end
end


-- GMod's BaseClass'ing system loves going through all tables accessible from an Entity's table
-- and add a BaseClass-table indexed at ["BaseClass"].
-- This can cause infinitely recursive loops within the very same system it seems...
function NewBaseClassSafeTable(t)
    assert(t == nil or type(t) == "table",
            "Expected nil or table for optional variable 't', received " .. type(t) .. ".")
            
    mt = {
        __newindex = function(self, k, v)
            if k == "BaseClass" and self == v then
                --print("Stop trying to make my tables recursive Garry!"
                --        .. " Particularly if you intend to recursively traverse them afterwards...")
            else
                rawset(self, k, v)
            end
        end,
        isBaseClassSafe = true
    }
    mt.__index = mt
    return setmetatable(t or {}, mt)
end


/*--------------------------------------------------------------------------------------------------
chat.AddText([ Player ply,] Colour colour, string text, Colour colour, string text, ... )
--------------------------------------------------------------------------------------------------*/
if SERVER then
	util.AddNetworkString( "AddText" )
	chat = { }
	local function AddText( ... )
		
		local ply
		if ( type( select(1, ...) ) == "Player" ) then
			ply = select(1, ...)
		end
		
		net.Start( "AddText" )
			
			net.WriteTable( {select(2, ...)} )
		
		net.End( ply )
		
	end
	chat.AddText = AddText
	
else -- CLIENT
	net.Receive( "AddText", function( )
			arg = net.ReadTable()
			
			chat.AddText( unpack( arg ) )
	end )
end
