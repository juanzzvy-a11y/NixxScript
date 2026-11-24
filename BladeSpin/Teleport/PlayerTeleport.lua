-- BLADE SPIN MODULE: PLAYER TELEPORT
return function(ctx)
    local Players = ctx.Players
    local player = ctx.LocalPlayer
    local tab = ctx.Window:Tab({Title="Teleport", Icon="map-pin"})
    local selectedName
    local dropdown

    local function getNames()
        local names = {}
        for _, target in ipairs(Players:GetPlayers()) do
            if target ~= player then table.insert(names, target.Name) end
        end
        table.sort(names)
        return names
    end

    tab:Paragraph({Title="PLAYERS ONLINE", Desc="Pilih pemain di server saat ini."})
    dropdown = tab:Dropdown({
        Title="Select Player",
        Desc="Select player to teleport to",
        Values=getNames(),
        Multi=false,
        Callback=function(value) selectedName=value end,
    })

    local function refresh()
        local names = getNames()
        if dropdown and dropdown.Refresh then pcall(function() dropdown:Refresh(names) end) end
        if selectedName and not table.find(names, selectedName) then
            selectedName=nil
            if dropdown and dropdown.Clear then pcall(function() dropdown:Clear() end) end
        end
    end

    tab:Button({Title="Refresh Player List", Icon="refresh-cw", Callback=function()
        refresh()
        ctx.WindUI:Notify({Title="Players", Content="List diperbarui: " .. #getNames() .. " pemain.", Duration=3})
    end})

    tab:Button({Title="Teleport to Player", Icon="map-pin", Callback=function()
        if not selectedName then
            ctx.WindUI:Notify({Title="Error", Content="Pilih pemain terlebih dahulu.", Duration=3})
            return
        end
        local target = Players:FindFirstChild(selectedName)
        local myCharacter = player.Character
        local targetRoot = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        local myRoot = myCharacter and myCharacter:FindFirstChild("HumanoidRootPart")
        if not targetRoot or not myRoot then
            ctx.WindUI:Notify({Title="Error", Content="Karakter pemain belum tersedia.", Duration=3})
            return
        end
        myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
        ctx.WindUI:Notify({Title="Teleport", Content="Berpindah ke " .. selectedName, Duration=3})
    end})

    ctx:Track(Players.PlayerAdded:Connect(function() task.defer(refresh) end))
    ctx:Track(Players.PlayerRemoving:Connect(function() task.defer(refresh) end))
end
