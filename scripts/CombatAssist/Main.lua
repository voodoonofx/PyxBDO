Pyx.Scripting.CurrentScript:RegisterCallback("Pyx.OnScriptStart", function()
    LoadSettings()
 end)
 
Pyx.Scripting.CurrentScript:RegisterCallback("Pyx.OnScriptStop", function()
    SaveSettings()
 end)

Pyx.Scripting.CurrentScript:RegisterCallback("ImGui.OnRender", function() 
    MainWindow.OnDrawGuiCallback()
end)

Pyx.Scripting.CurrentScript:RegisterCallback("PyxBDO.OnPulse", function()
    MainWindow.OnPulse()
end)

Pyx.Scripting.CurrentScript:RegisterCallback("PyxBDO.OnRender3D", function()

end)

-- Overwrite

function Navigator.MoveTo(destination, forceRecalculate)
    Navigator.MoveToStraight(destination)
    return true
end

function Navigator.CanMoveTo(destination)
    return true
end
