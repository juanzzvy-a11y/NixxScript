-- BLADE SPIN MODULE: USER INFO / SESSION INFO
return function(ctx)
    local player = ctx.LocalPlayer
    local Window = ctx.Window
    local WindUI = ctx.WindUI
    local Players = ctx.Players
    local Stats = ctx.Services.Stats
    local MarketplaceService = ctx.Services.MarketplaceService

    local tab = Window:Tab({Title="User Info", Icon="user-round"})
    local function ageText(days)
        local years = math.floor(days/365)
        local months = math.floor((days%365)/30)
        local remain = days%30
        if years > 0 then return string.format("%d years, %d months", years, months) end
        if months > 0 then return string.format("%d months, %d days", months, remain) end
        return tostring(remain) .. " days"
    end

    local gameName = "Unknown Game"
    pcall(function() gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name end)

    tab:Paragraph({
        Title="BASIC INFORMATION",
        Desc=string.format("Display Name: %s\nUsername: @%s\nUser ID: %d", player.DisplayName, player.Name, player.UserId),
    })
    tab:Divider()
    tab:Paragraph({
        Title="ACCOUNT DETAILS",
        Desc=string.format("Account Age: %s\nLocale: %s", ageText(player.AccountAge), player.LocaleId or "Unknown"),
    })
    tab:Divider()
    tab:Paragraph({
        Title="SESSION INFORMATION",
        Desc=string.format("Game: %s\nJoin Time: %s\nPlace ID: %d\nJob ID: %s", gameName, os.date("%H:%M:%S"), game.PlaceId, game.JobId:sub(1,20) .. "..."),
    })
    local characterParagraph = tab:Paragraph({Title="CHARACTER STATS", Desc="Loading..."})

    local function copyText(value, label)
        local copied = false
        pcall(function()
            if setclipboard then setclipboard(tostring(value)); copied=true
            elseif toclipboard then toclipboard(tostring(value)); copied=true end
        end)
        WindUI:Notify({
            Title=copied and "Copied" or "Clipboard unavailable",
            Content=copied and (label .. " copied.") or "Executor tidak menyediakan clipboard.",
            Duration=3,
        })
    end

    tab:Button({Title="Copy Username", Icon="copy", Callback=function() copyText(player.Name, "Username") end})
    tab:Button({Title="Copy User ID", Icon="copy", Callback=function() copyText(player.UserId, "User ID") end})
    tab:Button({Title="Copy Profile Link", Icon="link", Callback=function()
        copyText("https://www.roblox.com/users/" .. player.UserId .. "/profile", "Profile link")
    end})
    tab:Button({Title="Copy Place ID", Icon="copy", Callback=function() copyText(game.PlaceId, "Place ID") end})

    local lastUpdate = 0
    ctx:Track(ctx.Services.RunService.Heartbeat:Connect(function(dt)
        lastUpdate += dt
        if lastUpdate < 1 then return end
        lastUpdate = 0
        local character = player.Character
        local hum = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if hum and root then
            local p = root.Position
            pcall(function()
                characterParagraph:SetDesc(string.format(
                    "Health: %d/%d\nWalkSpeed: %d\nJumpPower: %d\nPosition: X:%d Y:%d Z:%d",
                    math.floor(hum.Health), math.floor(hum.MaxHealth), math.floor(hum.WalkSpeed),
                    math.floor(hum.JumpPower), math.floor(p.X), math.floor(p.Y), math.floor(p.Z)
                ))
            end)
        else
            pcall(function() characterParagraph:SetDesc("Character not spawned") end)
        end
    end))
end
