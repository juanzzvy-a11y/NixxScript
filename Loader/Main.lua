-- NIXXSCRIPT | GITHUB MAIN LOADER
-- Replace GITHUB_USERNAME with your GitHub username.
-- Repository: NixxScript | Branch: main
-- Load this file using its own raw.githubusercontent.com URL.

local GITHUB_USERNAME = "GITHUB_USERNAME"
local REPO = "NixxScript"
local BRANCH = "main"
local BASE_URL = "https://raw.githubusercontent.com/" .. GITHUB_USERNAME .. "/" .. REPO .. "/" .. BRANCH .. "/"
local WINDUI_URL = "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"

local MODULES = {
    {name="Blade • Player Info", path="BladeSpin/Info/UserInfo.lua"},
    {name="Blade • Teleport", path="BladeSpin/Teleport/PlayerTeleport.lua"},
    {name="Blade • System", path="BladeSpin/System/SystemTools.lua"},
    {name="Blade • Server", path="BladeSpin/Server/ServerTools.lua"},
    {name="Blade • Game Actions", path="BladeSpin/GameActions/GameActions.lua"},
    {name="Blade • Credits", path="BladeSpin/Credits/Credits.lua"},
    {name="Opah • ESP", path="Opah/ESP/ESP.lua"},
    {name="Opah • Radar & Info", path="Opah/Info/RadarPasscode.lua"},
    {name="Opah • Movement", path="Opah/Misc/MovementVisual.lua"},
    {name="Opah • Auto", path="Opah/Auto/KeyEscape.lua"},
    {name="Integration • Telegram Logger", path="Integrations/Telegram/TelegramLogger.lua"},
}

local function safeNotify(WindUI, title, content)
    pcall(function()
        WindUI:Notify({Title=title, Content=content, Duration=4})
    end)
end

if GITHUB_USERNAME == "GITHUB_USERNAME" then
    warn("[NixxScript] Edit GITHUB_USERNAME in Loader/Main.lua before running.")
    return
end

local downloaded, windSource = pcall(function()
    return game:HttpGet(WINDUI_URL)
end)
if not downloaded or type(windSource) ~= "string" then
    warn("[NixxScript] WindUI download failed:", windSource)
    return
end

local compiled, windFactory = pcall(loadstring, windSource)
if not compiled or type(windFactory) ~= "function" then
    warn("[NixxScript] WindUI compile failed:", windFactory)
    return
end

local started, WindUI = pcall(windFactory)
if not started or not WindUI then
    warn("[NixxScript] WindUI initialization failed:", WindUI)
    return
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Window = WindUI:CreateWindow({
    Title = "NixxScript",
    Author = "NixxTeam • Blade Spin x Opah",
    Folder = "NixxScript",
    Size = UDim2.fromOffset(560, 430),
    Transparent = true,
    Theme = "Crimson",
    SideBarWidth = 170,
    HasOutline = true,
})

pcall(function()
    Window:EditOpenButton({
        Title = "NixxScript",
        Icon = "bot",
        CornerRadius = UDim.new(0, 16),
        StrokeThickness = 2,
        Color = ColorSequence.new(Color3.fromRGB(255,49,49), Color3.fromRGB(255,96,97)),
        OnlyMobile = true,
        Enabled = true,
        Draggable = true,
    })
end)

local Home = Window:Tab({Title="Home", Icon="layout-dashboard"})
Home:Paragraph({
    Title="Blade Spin x Opah",
    Desc="GitHub modular build. Menu dibuat lebih dahulu, lalu semua modul dimuat paralel.",
})
local statusParagraphs = {}
for _, item in ipairs(MODULES) do
    statusParagraphs[item.name] = Home:Paragraph({Title=item.name, Desc="Menunggu..."})
end

local Context = {
    Window=Window,
    WindUI=WindUI,
    Players=Players,
    LocalPlayer=LocalPlayer,
    Services={
        RunService=game:GetService("RunService"),
        UserInputService=game:GetService("UserInputService"),
        TeleportService=game:GetService("TeleportService"),
        HttpService=game:GetService("HttpService"),
        Lighting=game:GetService("Lighting"),
        VirtualUser=game:GetService("VirtualUser"),
        Stats=game:GetService("Stats"),
        Workspace=workspace,
        MarketplaceService=game:GetService("MarketplaceService"),
    },
    Connections={},
}
function Context:Track(connection)
    table.insert(self.Connections, connection)
    return connection
end

for _, item in ipairs(MODULES) do
    task.spawn(function()
        local url = BASE_URL .. item.path
        local fetchOK, moduleSource = pcall(function()
            return game:HttpGet(url)
        end)
        if not fetchOK or type(moduleSource) ~= "string" then
            statusParagraphs[item.name]:SetDesc("Gagal download. Periksa file GitHub / branch.")
            warn("[NixxScript] Download error:", item.name, moduleSource)
            return
        end

        local compileOK, moduleChunk = pcall(loadstring, moduleSource)
        if not compileOK or type(moduleChunk) ~= "function" then
            statusParagraphs[item.name]:SetDesc("Compile gagal. Periksa sintaks Lua.")
            warn("[NixxScript] Compile error:", item.name, moduleChunk)
            return
        end

        local runOK, initializer = pcall(moduleChunk)
        if not runOK or type(initializer) ~= "function" then
            statusParagraphs[item.name]:SetDesc("Format salah: modul harus return function(ctx).")
            warn("[NixxScript] Module contract error:", item.name, initializer)
            return
        end

        local initOK, initError = pcall(initializer, Context)
        if not initOK then
            statusParagraphs[item.name]:SetDesc("Init gagal: " .. tostring(initError))
            warn("[NixxScript] Init error:", item.name, initError)
            return
        end
        statusParagraphs[item.name]:SetDesc("Loaded ✓")
    end)
end

safeNotify(WindUI, "NixxScript", "Menu utama berhasil dibuat.")
