-- NIXXSCRIPT INTEGRATION: TELEGRAM LOGGER (OPT-IN)
-- Requires a private HTTPS relay endpoint you control.
-- This module sends only Roblox username, user ID, and Place ID after the user
-- explicitly enables the toggle. It does NOT collect IP, location, ISP,
-- executor name, or hidden device identifiers.
return function(ctx)
    local HttpService = ctx.Services.HttpService
    local player = ctx.LocalPlayer
    local tab = ctx.Window:Tab({Title="Telegram Logger", Icon="send"})
    local enabled = false
    local busy = false

    -- Set this to YOUR private HTTPS relay endpoint.
    -- Never put a Telegram bot token in a public GitHub repository or client script.
    local RELAY_URL = "https://YOUR-PRIVATE-RELAY.example/telegram-log"

    tab:Paragraph({
        Title="PRIVACY NOTICE",
        Desc="Saat diaktifkan, modul mengirim Username, User ID, dan Place ID ke relay Telegram milik pemilik script. Tidak mengirim IP, lokasi, ISP, atau nama executor. Nonaktif secara default.",
    })

    local function sendLog()
        if busy then return end
        if RELAY_URL:find("YOUR%-PRIVATE%-RELAY") then
            ctx.WindUI:Notify({
                Title="Telegram Logger",
                Content="Isi RELAY_URL dengan endpoint privat milikmu terlebih dahulu.",
                Duration=5,
            })
            return
        end
        local requestFn = request or http_request or (syn and syn.request)
        if type(requestFn) ~= "function" then
            ctx.WindUI:Notify({
                Title="Telegram Logger",
                Content="Executor tidak menyediakan HTTP request.",
                Duration=4,
            })
            return
        end

        busy = true
        local payload = HttpService:JSONEncode({
            event = "nixxscript_opt_in",
            username = tostring(player.Name),
            userId = tonumber(player.UserId),
            placeId = tonumber(game.PlaceId),
        })

        local ok, response = pcall(function()
            return requestFn({
                Url = RELAY_URL,
                Method = "POST",
                Headers = {["Content-Type"]="application/json"},
                Body = payload,
            })
        end)
        busy = false

        local status = ok and tonumber(response and (response.StatusCode or response.status_code) or 0) or 0
        if ok and status >= 200 and status < 300 then
            ctx.WindUI:Notify({Title="Telegram Logger", Content="Info dasar berhasil dikirim.", Duration=4})
        else
            ctx.WindUI:Notify({Title="Telegram Logger", Content="Gagal mengirim. Periksa endpoint relay.", Duration=4})
        end
    end

    tab:Toggle({
        Title="Izinkan kirim info dasar ke Telegram",
        Value=false,
        Callback=function(value)
            enabled = value == true
            if enabled then
                sendLog()
            end
        end,
    })
    tab:Button({
        Title="Kirim ulang info dasar",
        Icon="send",
        Callback=function()
            if not enabled then
                ctx.WindUI:Notify({Title="Telegram Logger", Content="Aktifkan persetujuan terlebih dahulu.", Duration=4})
                return
            end
            sendLog()
        end,
    })
end
