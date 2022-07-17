if not string.StartWith(game.GetMap(), "ra_") then return
end

hook.Add("PlayerSpawn", "PlyaerSpawned", function(ply)

if engine.ActiveGamemode() ~= "riot_act" then

RunConsoleCommand( "disconnect" )

print(" Load Riot Act gamemode! ")
print(" Запустите режим Riot Act! ")

end

end)