-- BLADE SPIN MODULE: SERVER TOOLS
return function(ctx)
    local player=ctx.LocalPlayer
    local TeleportService=ctx.Services.TeleportService
    local HttpService=ctx.Services.HttpService
    local tab=ctx.Window:Tab({Title="Server", Icon="server"})

    tab:Button({Title="Hop Empty Server", Icon="refresh-cw", Callback=function()
        local placeId=game.PlaceId
        local endpoint="https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100"
        local ok, response=pcall(function()
            return HttpService:JSONDecode(game:HttpGet(endpoint))
        end)
        if not ok or type(response)~="table" or type(response.data)~="table" then
            ctx.WindUI:Notify({Title="Server Hop", Content="Gagal mengambil daftar server.", Duration=4})
            return
        end
        local candidates={}
        for _, server in ipairs(response.data) do
            if server.id~=game.JobId and server.playing<server.maxPlayers then
                table.insert(candidates,server)
            end
        end
        table.sort(candidates,function(a,b) return a.playing<b.playing end)
        if candidates[1] then
            TeleportService:TeleportToPlaceInstance(placeId,candidates[1].id,player)
        else
            ctx.WindUI:Notify({Title="Server Hop", Content="Tidak ada server yang tersedia pada halaman ini.", Duration=4})
        end
    end})

    tab:Button({Title="Rejoin", Icon="refresh-cw", Callback=function()
        TeleportService:Teleport(game.PlaceId,player)
    end})
end
