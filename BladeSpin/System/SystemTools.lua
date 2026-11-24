-- BLADE SPIN MODULE: SYSTEM TOOLS
-- Includes the source features Anti AFK, Performance HUD, FPS Boost, Infinite Zoom, Respawn.
-- "Bypass Admin" self-kick behaviour is intentionally not included.
return function(ctx)
    local player = ctx.LocalPlayer
    local RunService = ctx.Services.RunService
    local Lighting = ctx.Services.Lighting
    local VirtualUser = ctx.Services.VirtualUser
    local tab = ctx.Window:Tab({Title="System", Icon="settings-2"})

    local antiAfk = false
    local fpsBoost = false
    local infiniteZoom = false
    local hudEnabled = false
    local originalZoom = {Max=player.CameraMaxZoomDistance, Min=player.CameraMinZoomDistance}
    local savedParts = {}
    local savedEffects = {}
    local hudGui, hudLabel
    local fpsConnection
    local smoothedFPS = 60
    local lastTick = os.clock()

    tab:Toggle({Title="Anti AFK", Value=false, Callback=function(value) antiAfk=value end})
    ctx:Track(player.Idled:Connect(function()
        if antiAfk then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0,0))
            end)
        end
    end))

    local function rememberAndOptimize(object)
        if object:IsA("BasePart") then
            if not savedParts[object] then savedParts[object]={Color=object.Color, Material=object.Material} end
            object.Material=Enum.Material.SmoothPlastic
            object.Color=Color3.fromRGB(220,220,220)
        elseif object:IsA("PointLight") or object:IsA("SpotLight") or object:IsA("SurfaceLight")
            or object:IsA("ParticleEmitter") or object:IsA("Beam") or object:IsA("Trail")
            or object:IsA("Fire") or object:IsA("Smoke") then
            if savedEffects[object]==nil then savedEffects[object]=object.Enabled end
            object.Enabled=false
        end
    end

    local function restoreGraphics()
        for object, values in pairs(savedParts) do
            if object.Parent then
                object.Color=values.Color
                object.Material=values.Material
            end
        end
        for object, enabled in pairs(savedEffects) do
            if object.Parent then object.Enabled=enabled end
        end
        table.clear(savedParts)
        table.clear(savedEffects)
        Lighting.GlobalShadows=true
        Lighting.EnvironmentDiffuseScale=1
        Lighting.EnvironmentSpecularScale=1
        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("BloomEffect") or effect:IsA("SunRaysEffect") or effect:IsA("BlurEffect")
                or effect:IsA("DepthOfFieldEffect") or effect:IsA("ColorCorrectionEffect") then
                effect.Enabled=true
            end
        end
    end

    tab:Toggle({Title="FPS Boost", Value=false, Callback=function(value)
        fpsBoost=value
        if value then
            for _, object in ipairs(workspace:GetDescendants()) do rememberAndOptimize(object) end
            Lighting.GlobalShadows=false
            Lighting.EnvironmentDiffuseScale=0
            Lighting.EnvironmentSpecularScale=0
        else
            restoreGraphics()
        end
    end})
    ctx:Track(workspace.DescendantAdded:Connect(function(object)
        if fpsBoost then task.defer(function() pcall(rememberAndOptimize, object) end) end
    end))

    tab:Toggle({Title="Infinite Zoom", Value=false, Callback=function(value)
        infiniteZoom=value
        if value then
            player.CameraMaxZoomDistance=math.huge
            player.CameraMinZoomDistance=0.5
        else
            player.CameraMaxZoomDistance=originalZoom.Max
            player.CameraMinZoomDistance=originalZoom.Min
        end
    end})

    tab:Toggle({Title="Performance HUD", Value=false, Callback=function(value)
        hudEnabled=value
        if value and not hudGui then
            hudGui=Instance.new("ScreenGui")
            hudGui.Name="NixxPerformanceHUD"
            hudGui.ResetOnSpawn=false
            hudGui.Parent=(gethui and gethui()) or game:GetService("CoreGui")
            local frame=Instance.new("Frame")
            frame.Size=UDim2.fromOffset(360,42)
            frame.Position=UDim2.new(0.5,-180,0,18)
            frame.BackgroundColor3=Color3.fromRGB(0,0,0)
            frame.BackgroundTransparency=0.3
            frame.Parent=hudGui
            Instance.new("UICorner", frame).CornerRadius=UDim.new(0,12)
            hudLabel=Instance.new("TextLabel")
            hudLabel.Size=UDim2.fromScale(1,1)
            hudLabel.BackgroundTransparency=1
            hudLabel.Font=Enum.Font.GothamBold
            hudLabel.TextSize=14
            hudLabel.TextColor3=Color3.new(1,1,1)
            hudLabel.Parent=frame
        elseif hudGui then
            hudGui.Enabled=value
        end
    end})

    ctx:Track(RunService.RenderStepped:Connect(function()
        local now=os.clock()
        local delta=math.max(now-lastTick,0.001)
        lastTick=now
        local fps=math.clamp(1/delta,5,240)
        smoothedFPS += (fps-smoothedFPS)*0.08
        if hudEnabled and hudLabel then
            local ping=0
            pcall(function() ping=ctx.Services.Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
            hudLabel.Text=string.format("PING: %d ms  |  FPS: %d", math.floor(ping), math.floor(smoothedFPS))
        end
    end))

    tab:Button({Title="Respawn Character", Icon="refresh-cw", Callback=function()
        local character=player.Character
        local hum=character and character:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health=0 else player:LoadCharacter() end
    end})

    ctx:Track(player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if infiniteZoom then
            player.CameraMaxZoomDistance=math.huge
            player.CameraMinZoomDistance=0.5
        end
    end))
end
