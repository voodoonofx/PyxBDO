Pyx.Scripting.CurrentScript:RegisterCallback("Pyx.OnScriptStart", function()
    Bot.LoadSettings()
 end)
 
Pyx.Scripting.CurrentScript:RegisterCallback("Pyx.OnScriptStop", function()
    Bot.SaveSettings()
    Navigation.MesherEnabled = false
    Navigation.RenderMesh = false
    Navigation.ClearMesh()
 end)

Pyx.Scripting.CurrentScript:RegisterCallback("ImGui.OnRender", function() 
    MainWindow:OnDrawGuiCallback()
    ProfileEditor.OnDrawGuiCallback()
    LibConsumableWindow:OnDrawGuiCallback()
    LibConsumableAddWindow:OnDrawGuiCallback()

end)

Pyx.Scripting.CurrentScript:RegisterCallback("PyxBDO.OnPulse", function()
    Bot.OnPulse()
end)

Pyx.Scripting.CurrentScript:RegisterCallback("PyxBDO.OnRender3D", function()
    ProfileEditor.OnRender3D()
end)
