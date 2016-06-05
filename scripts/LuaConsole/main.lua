Pyx.Scripting.CurrentScript:RegisterCallback("Pyx.OnScriptStart", function()
    --    Bot.LoadSettings()
end )

Pyx.Scripting.CurrentScript:RegisterCallback("Pyx.OnScriptStop", function()
    --    Bot.SaveSettings()
end )

Pyx.Scripting.CurrentScript:RegisterCallback("ImGui.OnRender", function()
    LuaMainWindow:OnDrawGuiCallback()
end )

Pyx.Scripting.CurrentScript:RegisterCallback("PyxBDO.OnPulse", function()
    -- Navigator.OnPulse()
    --    Bot.OnPulse()
end )

