-----------------------------------------------------------------------------
-- Variables
-----------------------------------------------------------------------------

AdvancedSettings = {}
AdvancedSettings.Visible = false

-----------------------------------------------------------------------------
-- AdvancedSettings Functions
-----------------------------------------------------------------------------

function AdvancedSettings.DrawAdvancedSettings()
	if AdvancedSettings.Visible then
	-- _, ProfileEditor.Visible = ImGui.Begin("Profile editor", ProfileEditor.Visible, ImVec2(300, 400), -1.0)
		_, AdvancedSettings.Visible = ImGui.Begin("Advanced Settings", AdvancedSettings.Visible, ImVec2(350, 400), -1.0, ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoResize)
		if ImGui.Button("Save settings", ImVec2(ImGui.GetContentRegionAvailWidth() / 2, 20)) then
			Bot.SaveSettings()
			print("Settings saved")
		end
		ImGui.SameLine()
		if ImGui.Button("Load settings", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
			Bot.LoadSettings()
			print("Settings loaded")
		end

		ImGui.Columns(2)
		ImGui.Spacing()

	_, Bot.Settings.RunToHotSpots = ImGui.Checkbox("Run To Hotspots##id_guid_advanced_run_HotSpots", Bot.Settings.RunToHotSpots)
            ImGui.NextColumn()
            _, Bot.Settings.VendorSettings.PlayerRun = ImGui.Checkbox("Run To Vendor##id_guid_advanced_run_Vendor", Bot.Settings.VendorSettings.PlayerRun)
            ImGui.NextColumn()
            _, Bot.Settings.RepairSettings.PlayerRun = ImGui.Checkbox("Run To Repair##id_guid_advanced_run_Repair", Bot.Settings.RepairSettings.PlayerRun)
            ImGui.NextColumn()
            _, Bot.Settings.WarehouseSettings.PlayerRun = ImGui.Checkbox("Run To Warehouse##id_guid_advanced_run_Warehouse", Bot.Settings.WarehouseSettings.PlayerRun)
	    ImGui.NextColumn()
            _, Bot.Settings.TurninSettings.PlayerRun = ImGui.Checkbox("Run To Exchange##id_guid_advanced_run_Turnin", Bot.Settings.TurninSettings.PlayerRun)


			ImGui.Columns(1)
            ImGui.Text(" ")
            ImGui.Text("Change with caution!!!")
            ImGui.Text(" ")
            _, Bot.Settings.PatherFallBack = ImGui.Checkbox("Pather Fallback to bdo pathing##id_guid_advanced_pather_fallback", Bot.Settings.PatherFallBack)
--          _, Bot.Settings.PathingMode = ImGui.Checkbox("Fallback to BDO Nav##id_guid_advanced_fall_back", Bot.Settings.PathingMode)
  --             valueChanged, Bot.Settings.PathingMode = ImGui.Combo("Pathing System##id_guid_adv_path_mode", Bot.Settings.PathingMode, {"Pyx", "BDO Internal"})

            _, Bot.Settings.Advanced.PvpAttackRadius = ImGui.SliderInt("Pvp Attack Radius##id_gui_advanced_pvp_radius", Bot.Settings.Advanced.PvpAttackRadius, 500, 10000)
            _, Bot.Settings.Advanced.HotSpotRadius = ImGui.SliderInt("Hotspot Radius##id_gui_advanced_hs_radius", Bot.Settings.Advanced.HotSpotRadius, 500, 10000)
            _, Bot.Settings.LootSettings.LootRadius = ImGui.SliderInt("Loot Radius##id_gui_advanced_loot_radius", Bot.Settings.LootSettings.LootRadius, 500, 10000)
            _, Bot.Settings.Advanced.PullDistance = ImGui.SliderInt("Pull Distance##id_gui_advanced_pull_distance", Bot.Settings.Advanced.PullDistance, 500, 10000)
            _, Bot.Settings.PullSettings.PullSecondsUntillIgnore = ImGui.SliderInt("Pull Seconds untill ignore##id_gui_advanced_pull_seconds", Bot.Settings.PullSettings.PullSecondsUntillIgnore, 5, 30)
            _, Bot.Settings.Advanced.CombatMaxDistanceFromMe = ImGui.SliderInt("Combat Max Distance##id_gui_advanced_combat_maxdistance", Bot.Settings.Advanced.CombatMaxDistanceFromMe, 1000, 5000)
            _, Bot.Settings.Advanced.IgnoreInCombatBetweenHotSpots = ImGui.Checkbox("Ignore in combat between hotspots##id_guid_advanced_ignore_in_combat",
						Bot.Settings.Advanced.IgnoreInCombatBetweenHotSpots)
						_, Bot.Settings.Advanced.IgnoreCombatOnVendor = ImGui.Checkbox("Ignore in combat when Vendoring##id_guid_advanced_ignore_in_combat_vend", Bot.Settings.Advanced.IgnoreCombatOnVendor)
				    _, Bot.Settings.Advanced.IgnoreCombatOnRepair = ImGui.Checkbox("Ignore in combat when repairing##id_guid_advanced_ignore_in_combat_bep", Bot.Settings.Advanced.IgnoreCombatOnRepair)

					  _, Bot.Settings.Advanced.IgnorePullBetweenHotSpots = ImGui.Checkbox("Skip Pull between hotspots##id_guid_advanced_pull_ignore_hotspots", Bot.Settings.Advanced.IgnorePullBetweenHotSpots)
		ImGui.End()
	end
end

function AdvancedSettings.OnDrawGuiCallback()
	AdvancedSettings.DrawAdvancedSettings()
end
