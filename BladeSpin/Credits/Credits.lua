-- BLADE SPIN MODULE: CREDITS
return function(ctx)
    local tab=ctx.Window:Tab({Title="Credits", Icon="newspaper"})
    tab:Paragraph({Title="Developer", Desc="- NixxTeam\n- TeamXCode Community\n- Since: 2024 ©"})
    tab:Divider()
    tab:Paragraph({Title="Special Thanks", Desc="- WindUI Library\n- Roblox Community\n- Script Contributors"})
    tab:Divider()
    tab:Paragraph({Title="Partnership", Desc="- NixxTeam"})
    tab:Divider()
    tab:Paragraph({Title="Community", Desc="- Discord Server\n- NixxTeam Community\n- Support & Feedback"})
    local function copy(label,value)
        local ok=pcall(function()
            if setclipboard then setclipboard(value)
            elseif toclipboard then toclipboard(value)
            else error("clipboard unavailable") end
        end)
        ctx.WindUI:Notify({Title=ok and "Success" or "Failed", Content=ok and (label.." copied") or "Clipboard not available", Duration=3})
    end
    tab:Button({Title="Contact NixxTeam", Icon="link", Callback=function() copy("Contact Link","wa.me/6283182791150") end})
    tab:Button({Title="Website Link", Icon="link", Callback=function() copy("Website Link","https://nixcooll.biz.id/") end})
    tab:Button({Title="Discord Server", Icon="link", Callback=function() copy("Discord Server","https://discord.gg/e4yQCm2u") end})
    tab:Paragraph({Title="Note", Desc="Use this script wisely. All risks are borne by the user."})
end
