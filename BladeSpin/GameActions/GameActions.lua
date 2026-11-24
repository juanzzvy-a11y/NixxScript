-- BLADE SPIN MODULE: GAME ACTIONS STATUS
-- Source BLADE SCRIPT.lua exposes Unlock All Swords and Auto Farm Coins & XP
-- by firing game-specific server remotes (AddToInventory/AddCoins/AddXP).
-- These remote-spam actions are not ported into this modular build.
return function(ctx)
    local tab=ctx.Window:Tab({Title="Game Actions", Icon="gamepad-2"})
    local player=ctx.LocalPlayer
    tab:Paragraph({
        Title="SWORD BATTLES",
        Desc="Fitur sumber: Unlock All Swords. Implementasi aslinya memanggil ReplicatedStorageHolders.Events.AddToInventory:FireServer untuk setiap item. Modul ini tidak mengirim remote unlock dari client.",
    })
    tab:Paragraph({
        Title="AUTO FARM COINS & XP",
        Desc="Fitur sumber: Auto Farm Coins & XP. Implementasi aslinya mengirim AddCoins:FireServer(1000000) dan AddXP:FireServer(100000) berulang saat InRound. Modul ini tidak memalsukan reward atau spam remote server.",
    })
    tab:Paragraph({
        Title="CURRENT ROUND STATUS",
        Desc="In Round: " .. tostring(player:GetAttribute("InRound")==true),
    })
    local status=tab:Paragraph({Title="LIVE STATUS", Desc="Menunggu..."})
    local elapsed=0
    ctx:Track(ctx.Services.RunService.Heartbeat:Connect(function(dt)
        elapsed+=dt
        if elapsed>=1 then
            elapsed=0
            pcall(function()
                status:SetDesc("In Round: " .. tostring(player:GetAttribute("InRound")==true))
            end)
        end
    end))
end
