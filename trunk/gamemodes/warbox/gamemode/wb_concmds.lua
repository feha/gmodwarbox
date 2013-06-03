
-- Team comamnds
local function joinTeam(ply, cmd, args)
	print(cmd)
	local teamIndex = tonumber(args[1])
	print(teamIndex)
	if teamIndex and (WarboxTEAM.GetTeam(teamIndex) and WarboxTEAM.GetTeam(teamIndex):IsAdmin() or ply:IsAdminOrSuper()) then
		ply:SetTeam(teamIndex)
	end
end
concommand.Add("join", joinTeam)

-- Unit selecting
local function select(ply, cmd, args)
	print(cmd)
	if cmd:sub(1,1) == '+' then -- cmd is "+wb_order"
		ply:SelectStart()
	else -- cmd is "-wb_order"
		ply:SelectEnd(args[1] == "true", args[2] == "true", args[3] == "true", args[4] == "true")
	end
end
concommand.Add("+wb_select", select)
concommand.Add("-wb_select", select)

-- Unit ordering
local function order(ply, cmd, args)
	print(cmd)
	ply:OrderSelection(args[1] == "true", args[2] == "true", args[3] == "true", args[4] == "true")
end
concommand.Add("wb_order", order)
