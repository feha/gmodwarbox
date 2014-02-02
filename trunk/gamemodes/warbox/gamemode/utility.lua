

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
