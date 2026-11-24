-- OPAH MODULE: SPEED / DOUBLE JUMP / FLOAT BUTTON / NOCLIP / FULLBRIGHT / ANTI-AFK
return function(ctx)
    local player=ctx.LocalPlayer
    local RunService=ctx.Services.RunService
    local UIS=ctx.Services.UserInputService
    local Lighting=ctx.Services.Lighting
    local VirtualUser=ctx.Services.VirtualUser
    local tab=ctx.Window:Tab({Title="Opah Misc", Icon="sliders-horizontal"})

    local speedOn=false
    local speedValue=32
    local originalSpeed=16
    local doubleJumpOn=false
    local floatingButtonOn=false
    local noclipOn=false
    local fullbrightOn=false
    local antiAfkOn=true
    local extraJump=1
    local lastGround=0
    local lastDouble=0
    local savedCollision={}
    local savedLighting
    local floatGui

    local function humanoid()
        local c=player.Character
        return c and c:FindFirstChildOfClass("Humanoid")
    end
    local function root()
        local c=player.Character
        return c and c:FindFirstChild("HumanoidRootPart")
    end
    local function applySpeed()
        local h=humanoid()
        if h and speedOn then h.WalkSpeed=speedValue end
    end
    tab:Slider({Title="Speed Value", Value={Min=16,Max=60,Default=32}, Step=1, Callback=function(v)
        speedValue=tonumber(v) or 32
        applySpeed()
    end})
    tab:Toggle({Title="Speed", Value=false, Callback=function(v)
        local h=humanoid()
        if v and h then originalSpeed=h.WalkSpeed end
        speedOn=v
        if h then h.WalkSpeed=v and speedValue or originalSpeed end
    end})

    local function tryDoubleJump()
        if not doubleJumpOn then return end
        local h=humanoid()
        local r=root()
        if not h or not r then return end
        local state=h:GetState()
        local inAir=h.FloorMaterial==Enum.Material.Air or state==Enum.HumanoidStateType.Freefall or state==Enum.HumanoidStateType.Jumping
        local now=os.clock()
        if not inAir or extraJump<=0 or now-lastGround<0.15 or now-lastDouble<0.25 then return end
        extraJump-=1
        lastDouble=now
        local power=h.UseJumpPower and h.JumpPower or math.sqrt(2*workspace.Gravity*h.JumpHeight)
        if power<40 then power=50 end
        local velocity=r.AssemblyLinearVelocity
        r.AssemblyLinearVelocity=Vector3.new(velocity.X,power,velocity.Z)
        pcall(function() h:ChangeState(Enum.HumanoidStateType.Jumping) end)
    end

    tab:Toggle({Title="Double Jump", Value=false, Callback=function(v) doubleJumpOn=v end})
    tab:Toggle({Title="Tombol 2x Jump", Value=false, Callback=function(v)
        floatingButtonOn=v
        if v and not floatGui then
            floatGui=Instance.new("ScreenGui")
            floatGui.Name="NixxDoubleJumpButton"
            floatGui.ResetOnSpawn=false
            floatGui.Parent=(gethui and gethui()) or game:GetService("CoreGui")
            local button=Instance.new("TextButton")
            button.Size=UDim2.fromOffset(66,66)
            button.Position=UDim2.new(1,-90,1,-180)
            button.BackgroundColor3=Color3.fromRGB(35,120,90)
            button.Text="2x\nJUMP"
            button.TextColor3=Color3.new(1,1,1)
            button.TextScaled=true
            button.Parent=floatGui
            Instance.new("UICorner",button).CornerRadius=UDim.new(1,0)
            button.Activated:Connect(tryDoubleJump)
        elseif floatGui then
            floatGui.Enabled=v
        end
    end})
    ctx:Track(UIS.JumpRequest:Connect(tryDoubleJump))
    ctx:Track(UIS.InputBegan:Connect(function(input)
        if input.KeyCode==Enum.KeyCode.Space then tryDoubleJump() end
    end))

    tab:Toggle({Title="Noclip", Value=false, Callback=function(v)
        noclipOn=v
        if not v then
            for part,original in pairs(savedCollision) do
                if part.Parent then part.CanCollide=original end
            end
            table.clear(savedCollision)
        end
    end})
    ctx:Track(RunService.Stepped:Connect(function()
        if noclipOn then
            local c=player.Character
            if c then
                for _,part in ipairs(c:GetDescendants()) do
                    if part:IsA("BasePart") then
                        if savedCollision[part]==nil then savedCollision[part]=part.CanCollide end
                        part.CanCollide=false
                    end
                end
            end
        end
    end))

    local function applyFullbright()
        Lighting.Brightness=2
        Lighting.ClockTime=14
        Lighting.FogStart=100000
        Lighting.FogEnd=1000000
        Lighting.GlobalShadows=false
        Lighting.Ambient=Color3.fromRGB(190,190,190)
        Lighting.OutdoorAmbient=Color3.fromRGB(190,190,190)
        local atmosphere=Lighting:FindFirstChildOfClass("Atmosphere")
        if atmosphere then atmosphere.Density=0 end
    end
    tab:Toggle({Title="Fullbright", Value=false, Callback=function(v)
        fullbrightOn=v
        if v then
            local atmosphere=Lighting:FindFirstChildOfClass("Atmosphere")
            savedLighting={
                Brightness=Lighting.Brightness, ClockTime=Lighting.ClockTime,
                FogStart=Lighting.FogStart, FogEnd=Lighting.FogEnd,
                GlobalShadows=Lighting.GlobalShadows, Ambient=Lighting.Ambient,
                OutdoorAmbient=Lighting.OutdoorAmbient,
                Density=atmosphere and atmosphere.Density,
            }
            applyFullbright()
        elseif savedLighting then
            for property,value in pairs(savedLighting) do
                if property~="Density" then pcall(function() Lighting[property]=value end) end
            end
            local atmosphere=Lighting:FindFirstChildOfClass("Atmosphere")
            if atmosphere and savedLighting.Density~=nil then atmosphere.Density=savedLighting.Density end
        end
    end})
    ctx:Track(RunService.Heartbeat:Connect(function()
        if fullbrightOn then pcall(applyFullbright) end
        local h=humanoid()
        if h and speedOn and h.WalkSpeed~=speedValue then h.WalkSpeed=speedValue end
        if h then
            local state=h:GetState()
            if h.FloorMaterial~=Enum.Material.Air or state==Enum.HumanoidStateType.Landed or state==Enum.HumanoidStateType.Running then
                extraJump=1
                lastGround=os.clock()
            end
        end
    end))

    tab:Toggle({Title="Anti-AFK", Value=true, Callback=function(v) antiAfkOn=v end})
    ctx:Track(player.Idled:Connect(function()
        if antiAfkOn then
            pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new(0,0)) end)
        end
    end))
    ctx:Track(player.CharacterAdded:Connect(function()
        task.wait(0.5)
        applySpeed()
    end))
end
