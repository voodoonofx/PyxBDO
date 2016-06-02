CombatAutoAttack = { }
CombatAutoAttack.__index = CombatAutoAttack
CombatAutoAttack.Gui = { }
CombatAutoAttack.Gui.ShowGui = false

-- Gui Option Examples
CombatAutoAttack.Gui.CheckboxExample = false
CombatAutoAttack.Gui.SliderExample = 0


setmetatable(CombatAutoAttack, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function CombatAutoAttack.new()
  local self = setmetatable({}, CombatAutoAttack)
  return self
end

function CombatAutoAttack:Attack(monsterActor)
  if monsterActor then
        local selfPlayer = GetSelfPlayer()
        local actorPosition = monsterActor.Position
        if actorPosition.Distance3DFromMe > monsterActor.BodySize + 400 or not monsterActor.IsLineOfSight then
            Navigator.MoveTo(actorPosition)
        else
            Navigator.Stop()
            if not selfPlayer.IsActionPending then
              if CombatAutoAttack.Gui.CheckboxExample then
                selfPlayer:Interact(monsterActor) -- Auto attack for the win !
              end
            end
        end
    end
end

function CombatAutoAttack:UserInterface()
  if CombatAutoAttack.Gui.ShowGui then
    _, CombatAutoAttack.Gui.ShowGui = ImGui.Begin("[Sample] Auto Attack UI Example", true, ImVec2(150, 200), -1.0, ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoResize)
    if ImGui.CollapsingHeader( "Collapsing Header Example","options" ,true ,true) then

      if ImGui.TreeNode("Sameple Tree Node") then

            _, CombatAutoAttack.Gui.CheckboxExample = ImGui.Checkbox("Checkbox Example##id_gui_checkboxexample", CombatAutoAttack.Gui.CheckboxExample)
            _, CombatAutoAttack.Gui.SliderExample = ImGui.SliderInt("Slider Example##id_gui_sliderexample", CombatAutoAttack.Gui.SliderExample, 0, 100)

            ImGui.TreePop()

        end

    end
    ImGui.End()
  end
end

return CombatAutoAttack()