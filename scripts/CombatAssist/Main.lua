Pyx.Scripting.CurrentScript:RegisterCallback("Pyx.OnScriptStart", function()
    LoadSettings()
    MainWindow.LoadCombat()
 end)

Pyx.Scripting.CurrentScript:RegisterCallback("Pyx.OnScriptStop", function()
    SaveSettings()
    if MainWindow.Combat.Gui then
        MainWindow.SaveCombatSettings()
    end
 end)

Pyx.Scripting.CurrentScript:RegisterCallback("ImGui.OnRender", function()
    MainWindow.OnDrawGuiCallback()
    if MainWindow.Combat.Gui then
        if MainWindow.Combat.Gui.ShowGui then
            MainWindow.CallGui()
        end
    end
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
