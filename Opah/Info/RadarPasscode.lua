-- OPAH MODULE: RADAR OPAH / PASSCODE / INFO PINTU KELUAR
return function(ctx)
    local player=ctx.LocalPlayer
    local Workspace=ctx.Services.Workspace
    local Players=ctx.Players
    local tab=ctx.Window:Tab({Title="Opah Radar & Info", Icon="radar"})
    local radar=tab:Paragraph({Title="OPAH RADAR", Desc="Mencari Opah..."})
    local codeParagraph=tab:Paragraph({Title="PASSCODE", Desc="----"})
    local function root()
        local c=player.Character
        return c and c:FindFirstChild("HumanoidRootPart")
    end
    local function partOf(obj)
        if obj:IsA("BasePart") then return obj end
        if obj:IsA("Model") then return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart",true) end
    end
    local function nearestOpah()
        local origin=root()
        local best,bestDist=nil,math.huge
        for _,obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") then
                local n=obj.Name:lower()
                if n:find("opah",1,true) and not n:find("motor",1,true) and not n:find("vehicle",1,true) then
                    local part=partOf(obj)
                    if part and origin then
                        local d=(part.Position-origin.Position).Magnitude
                        if d<bestDist then best,bestDist=obj,d end
                    end
                end
            end
        end
        return best,bestDist
    end
    local function findCode()
        local fallback
        for _,obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("TextLabel") or obj:IsA("TextBox") then
                local text=(obj.Text or ""):gsub("%s","")
                if text:match("^%d+$") and #text>=3 and #text<=6 then
                    local p=obj
                    local hasWord=false
                    while p and p~=Workspace do
                        local n=p.Name:lower()
                        if n:find("pass",1,true) or n:find("code",1,true) or n:find("sandi",1,true)
                            or n:find("note",1,true) or n:find("paper",1,true) then hasWord=true break end
                        p=p.Parent
                    end
                    if hasWord then return text end
                    if not fallback and obj:FindFirstAncestorWhichIsA("SurfaceGui") then fallback=text end
                end
            elseif obj:IsA("StringValue") or obj:IsA("IntValue") or obj:IsA("NumberValue") then
                local n=obj.Name:lower()
                if n:find("pass",1,true) or n:find("code",1,true) or n:find("sandi",1,true) then
                    local value=tostring(obj.Value)
                    if value:match("^%d+$") and #value>=3 and #value<=6 then return value end
                end
            end
        end
        return fallback
    end
    tab:Button({Title="Refresh Radar & Passcode", Icon="refresh-cw", Callback=function()
        local opah,distance=nearestOpah()
        radar:SetDesc(opah and (opah.Name.." • "..math.floor(distance).." studs") or "Opah tidak ditemukan.")
        local code=findCode()
        codeParagraph:SetDesc(code or "Passcode belum ditemukan.")
    end})
    tab:Button({Title="Copy Passcode", Icon="copy", Callback=function()
        local code=findCode()
        if not code then
            ctx.WindUI:Notify({Title="Passcode", Content="Kode belum ditemukan.", Duration=3})
            return
        end
        local ok=pcall(function()
            if setclipboard then setclipboard(code)
            elseif toclipboard then toclipboard(code)
            else error("clipboard unavailable") end
        end)
        ctx.WindUI:Notify({Title=ok and "Copied" or "Failed", Content=ok and ("Passcode: "..code) or "Clipboard tidak tersedia.", Duration=3})
    end})
    tab:Button({Title="Info Pintu Keluar", Icon="door-open", Callback=function()
        local found={}
        local words={"exit","keluar","escape","kabur","gerbang","finish","gate"}
        for _,obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") or obj:IsA("BasePart") then
                local n=obj.Name:lower()
                for _,word in ipairs(words) do
                    if n:find(word,1,true) then
                        table.insert(found,obj:GetFullName())
                        break
                    end
                end
                if #found>=12 then break end
            end
        end
        ctx.WindUI:Notify({Title="Pintu Keluar", Content=#found>0 and table.concat(found,"\n") or "Objek pintu keluar tidak ditemukan.", Duration=6})
    end})
    local info=tab:Paragraph({Title="SESSION INFO", Desc="Memuat..."})
    local function updateInfo()
        local gameName="MALAM SAMA OPAH"
        local ping="N/A"
        pcall(function() ping=math.floor(ctx.Services.Stats.Network.ServerStatsItem["Data Ping"]:GetValue()).." ms" end)
        local r=root()
        local pos=r and r.Position
        local posText=pos and string.format("%d, %d, %d",math.floor(pos.X),math.floor(pos.Y),math.floor(pos.Z)) or "N/A"
        info:SetDesc(string.format("Player: %s (@%s)\nPlayers: %d/%d\nPing: %s\nPosition: %s\nPlace ID: %d",player.DisplayName,player.Name,#Players:GetPlayers(),Players.MaxPlayers,ping,posText,game.PlaceId))
    end
    tab:Button({Title="Refresh Session Info", Icon="refresh-cw", Callback=updateInfo})
    updateInfo()
end
