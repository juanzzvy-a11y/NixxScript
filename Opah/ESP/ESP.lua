-- OPAH MODULE: ESP KUNCI / OPAH / PLAYER + DISTANCE
return function(ctx)
    local player=ctx.LocalPlayer
    local Players=ctx.Players
    local Workspace=ctx.Services.Workspace
    local RunService=ctx.Services.RunService
    local tab=ctx.Window:Tab({Title="Opah ESP", Icon="scan-eye"})

    local enabled={Keys=false, Opah=false, Players=false}
    local range=300
    local tags={}
    local scanClock=0
    local function rootOf(character)
        return character and character:FindFirstChild("HumanoidRootPart")
    end
    local function partOf(object)
        if object:IsA("BasePart") then return object end
        if object:IsA("Model") then return object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart",true) end
    end
    local function isKey(object)
        local n=object.Name:lower()
        return (n:find("key",1,true) or n:find("kunci",1,true))
            and not n:find("monkey",1,true) and not n:find("keypad",1,true)
            and not n:find("keyboard",1,true) and not n:find("keyhole",1,true)
    end
    local function isOpah(object)
        local n=object.Name:lower()
        return object:IsA("Model") and n:find("opah",1,true)
            and not n:find("motor",1,true) and not n:find("vehicle",1,true)
    end
    local function remove(object)
        local entry=tags[object]
        if entry then
            if entry.highlight then entry.highlight:Destroy() end
            if entry.billboard then entry.billboard:Destroy() end
            tags[object]=nil
        end
    end
    local function add(object,label,color)
        if tags[object] or not object.Parent then return end
        local part=partOf(object)
        if not part then return end
        local entry={}
        if object:IsA("Model") then
            local h=Instance.new("Highlight")
            h.Name="NixxOpahESP"
            h.Adornee=object
            h.FillColor=color
            h.OutlineColor=color
            h.FillTransparency=0.65
            h.OutlineTransparency=0.05
            h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
            h.Parent=object
            entry.highlight=h
        end
        local gui=Instance.new("BillboardGui")
        gui.Name="NixxOpahESPTag"
        gui.Adornee=part
        gui.Size=UDim2.fromOffset(150,26)
        gui.StudsOffset=Vector3.new(0,2.5,0)
        gui.AlwaysOnTop=true
        gui.Parent=player:WaitForChild("PlayerGui")
        local labelObject=Instance.new("TextLabel")
        labelObject.BackgroundTransparency=1
        labelObject.Size=UDim2.fromScale(1,1)
        labelObject.Font=Enum.Font.GothamBold
        labelObject.TextSize=13
        labelObject.TextStrokeTransparency=0.2
        labelObject.TextColor3=color
        labelObject.Text=label
        labelObject.Parent=gui
        entry.billboard=gui
        tags[object]=entry
    end
    local function refresh()
        local myRoot=rootOf(player.Character)
        if not myRoot then return end
        for object in pairs(tags) do
            if not object.Parent then remove(object) end
        end
        for _,object in ipairs(Workspace:GetDescendants()) do
            if object:IsA("Model") or object:IsA("BasePart") then
                local part=partOf(object)
                if part and (part.Position-myRoot.Position).Magnitude<=range then
                    if enabled.Keys and isKey(object) then
                        add(object,"KUNCI",Color3.fromRGB(255,220,70))
                    elseif enabled.Opah and isOpah(object) then
                        add(object,"OPAH",Color3.fromRGB(255,75,75))
                    end
                end
            end
        end
        if enabled.Players then
            for _,target in ipairs(Players:GetPlayers()) do
                if target~=player and target.Character then
                    local targetRoot=rootOf(target.Character)
                    if targetRoot and (targetRoot.Position-myRoot.Position).Magnitude<=range then
                        add(target.Character,target.DisplayName,Color3.fromRGB(70,190,255))
                    end
                end
            end
        end
    end

    tab:Toggle({Title="ESP Kunci", Value=false, Callback=function(v) enabled.Keys=v end})
    tab:Toggle({Title="ESP Opah", Value=false, Callback=function(v) enabled.Opah=v end})
    tab:Toggle({Title="ESP Player", Value=false, Callback=function(v) enabled.Players=v end})
    tab:Slider({Title="Jarak ESP", Value={Min=50,Max=1000,Default=300}, Step=50, Callback=function(v) range=tonumber(v) or 300 end})

    ctx:Track(RunService.Heartbeat:Connect(function(dt)
        scanClock+=dt
        if scanClock>=1.5 then
            scanClock=0
            if enabled.Keys or enabled.Opah or enabled.Players then
                task.spawn(refresh)
            else
                for object in pairs(tags) do remove(object) end
            end
        end
    end))
    ctx:Track(Players.PlayerRemoving:Connect(function(target)
        if target.Character then remove(target.Character) end
    end))
end
