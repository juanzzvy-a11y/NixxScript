-- OPAH MODULE: AUTO KUNCI / KABUR / PENGAMAN OPAH
-- Uses local Workspace object discovery and normal character movement.
-- Prompt/click activation is attempted only through supported in-game interaction APIs.
return function(ctx)
    local player=ctx.LocalPlayer
    local Workspace=ctx.Services.Workspace
    local Players=ctx.Players
    local tab=ctx.Window:Tab({Title="Opah Auto", Icon="zap"})
    local autoOn=false
    local guardOn=true
    local session=0
    local safePosition
    local status

    local function setStatus(text)
        if status then status:SetDesc("Status: "..text) end
    end
    local function root()
        local c=player.Character
        return c and c:FindFirstChild("HumanoidRootPart")
    end
    local function humanoid()
        local c=player.Character
        return c and c:FindFirstChildOfClass("Humanoid")
    end
    local function partOf(obj)
        if obj:IsA("BasePart") then return obj end
        if obj:IsA("Model") then return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart",true) end
        return nil
    end
    local function isKey(obj)
        local n=obj.Name:lower()
        return (n:find("key",1,true) or n:find("kunci",1,true))
            and not n:find("monkey",1,true) and not n:find("keypad",1,true)
            and not n:find("keyboard",1,true) and not n:find("keyhole",1,true)
    end
    local function isMine(obj)
        local c=player.Character
        local backpack=player:FindFirstChildOfClass("Backpack")
        return (c and obj:IsDescendantOf(c)) or (backpack and obj:IsDescendantOf(backpack))
    end
    local function getKeys()
        local result={}
        for _,obj in ipairs(Workspace:GetDescendants()) do
            if (obj:IsA("Model") or obj:IsA("BasePart") or obj:IsA("Tool")) and isKey(obj) and not isMine(obj) then
                local part=partOf(obj)
                if part then table.insert(result,{obj=obj,part=part}) end
            end
        end
        return result
    end
    local function findOpah()
        local myRoot=root()
        local best,bestDist=nil,math.huge
        for _,obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name:lower():find("opah",1,true)
                and not obj.Name:lower():find("motor",1,true) and not obj.Name:lower():find("vehicle",1,true) then
                local part=partOf(obj)
                if part and myRoot then
                    local d=(part.Position-myRoot.Position).Magnitude
                    if d<bestDist then best,bestDist=obj,d end
                end
            end
        end
        return best,bestDist
    end
    local function findExit()
        local myRoot=root()
        local best,bestPart,bestDist=nil,nil,math.huge
        local words={"exit","keluar","escape","kabur","gerbang","finish","gate"}
        for _,obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") or obj:IsA("BasePart") then
                local name=obj.Name:lower()
                local match=false
                for _,word in ipairs(words) do if name:find(word,1,true) then match=true break end end
                if match then
                    local part=partOf(obj)
                    if part then
                        local d=myRoot and (part.Position-myRoot.Position).Magnitude or 0
                        if d<bestDist then best,bestPart,bestDist=obj,part,d end
                    end
                end
            end
        end
        if best then return best,bestPart end
        for _,prompt in ipairs(Workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                local text=(prompt.ActionText.." "..prompt.ObjectText.." "..prompt.Name):lower()
                local match=false
                for _,word in ipairs(words) do if text:find(word,1,true) then match=true break end end
                if match then
                    local parent=prompt.Parent
                    local part=parent and (parent:IsA("BasePart") and parent or parent:FindFirstChildWhichIsA("BasePart",true))
                    if part then return prompt,part end
                end
            end
        end
        return nil,nil
    end
    local function teleportTo(position, height)
        local r=root()
        if not r then return false end
        r.AssemblyLinearVelocity=Vector3.zero
        r.CFrame=CFrame.new(position+Vector3.new(0,height or 3,0))
        return true
    end
    local function activateTarget(obj,part)
        local prompt=obj:IsA("ProximityPrompt") and obj or obj:FindFirstChildWhichIsA("ProximityPrompt",true)
        if prompt and prompt.Enabled then
            pcall(function()
                if fireproximityprompt then fireproximityprompt(prompt)
                else prompt:InputHoldBegin(); task.wait(0.1); prompt:InputHoldEnd() end
            end)
        end
        local click=obj:FindFirstChildWhichIsA("ClickDetector",true)
        if click and fireclickdetector then pcall(fireclickdetector,click) end
        local r=root()
        if firetouchinterest and r and part then
            pcall(function() firetouchinterest(r,part,0); task.wait(0.05); firetouchinterest(r,part,1) end)
        end
    end
    local function guard(mySession)
        if not guardOn then return end
        local started=os.clock()
        while session==mySession do
            local _,distance=findOpah()
            if distance==nil or distance>=35 then return end
            if os.clock()-started>30 then
                setStatus("Opah masih dekat, batas tunggu tercapai")
                return
            end
            if distance<20 and safePosition then
                setStatus("Opah dekat ("..math.floor(distance).." studs), kembali ke titik aman")
                teleportTo(safePosition,3)
            else
                setStatus("Menunggu Opah menjauh ("..math.floor(distance).." studs)")
            end
            task.wait(0.5)
        end
    end
    local function markSafe()
        local r=root()
        if r then safePosition=r.Position end
    end
    local function collectKeys(mySession)
        local keys=getKeys()
        local collected,total=0,#keys
        for index,item in ipairs(keys) do
            if session~=mySession then return collected,total end
            guard(mySession)
            if session~=mySession then return collected,total end
            setStatus("menuju kunci "..index.."/"..total)
            teleportTo(item.part.Position,3)
            task.wait(0.25)
            activateTarget(item.obj,item.part)
            task.wait(0.5)
            if not item.obj:IsDescendantOf(Workspace) or isMine(item.obj) then
                collected+=1
            end
        end
        return collected,total
    end
    local function openExit(mySession)
        local object,part=findExit()
        if not object or not part then setStatus("pintu keluar tidak ditemukan"); return end
        for attempt=1,3 do
            if session~=mySession then return end
            guard(mySession)
            if session~=mySession then return end
            setStatus("menuju pintu keluar ("..attempt.."/3)")
            teleportTo(part.Position,3)
            task.wait(0.3)
            activateTarget(object,part)
            task.wait(0.6)
        end
        setStatus("percobaan membuka pintu selesai, periksa hasil di game")
    end
    tab:Toggle({Title="AUTO KUNCI + KABUR", Value=false, Callback=function(value)
        session+=1
        local current=session
        if not value then
            autoOn=false
            setStatus("dihentikan")
            return
        end
        autoOn=true
        markSafe()
        task.spawn(function()
            local got,total=collectKeys(current)
            if session~=current then return end
            setStatus("kunci terambil "..got.."/"..total..", menuju pintu keluar")
            task.wait(0.5)
            openExit(current)
            if session==current then
                autoOn=false
                setStatus("proses selesai")
            end
        end)
    end})
    tab:Button({Title="AMBIL SEMUA KUNCI SAJA", Icon="key-round", Callback=function()
        session+=1
        local current=session
        autoOn=false
        markSafe()
        task.spawn(function()
            local got,total=collectKeys(current)
            if session==current then setStatus("selesai: "..got.."/"..total.." kunci") end
        end)
    end})
    tab:Button({Title="TELEPORT + BUKA PINTU KELUAR", Icon="door-open", Callback=function()
        session+=1
        local current=session
        markSafe()
        task.spawn(function() openExit(current) end)
    end})
    tab:Toggle({Title="PENGAMAN OPAH", Value=true, Callback=function(v) guardOn=v end})
    tab:Button({Title="COPY INFO SEKITAR (DEBUG)", Icon="copy", Callback=function()
        local lines={}
        local r=root()
        if r then
            local p=r.Position
            table.insert(lines,string.format("POS: %d, %d, %d",math.floor(p.X),math.floor(p.Y),math.floor(p.Z)))
        end
        local keys=getKeys()
        table.insert(lines,"KEYS: "..#keys)
        for _,item in ipairs(keys) do table.insert(lines,"KEY | "..item.obj:GetFullName()) end
        local exitObject=findExit()
        table.insert(lines,"EXIT: "..(exitObject and exitObject:GetFullName() or "tidak ditemukan"))
        local text=table.concat(lines,"\n")
        print("NixxScript Opah Debug:\n"..text)
        local ok=pcall(function()
            if setclipboard then setclipboard(text)
            elseif toclipboard then toclipboard(text)
            else error("clipboard unavailable") end
        end)
        ctx.WindUI:Notify({Title=ok and "Debug Copied" or "Debug Printed", Content=ok and "Info disalin ke clipboard." or "Lihat console F9.", Duration=3})
    end})
end
