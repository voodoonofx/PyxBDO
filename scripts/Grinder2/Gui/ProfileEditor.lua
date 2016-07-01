------------------------------------------------------------------------------
-- Variables
-----------------------------------------------------------------------------

ProfileEditor = { }
ProfileEditor.Visible = false
ProfileEditor.CurrentProfile = Profile()
ProfileEditor.AvailablesProfilesSelectedIndex = 0
ProfileEditor.AvailablesProfiles = { }
ProfileEditor.AttackableMonstersSelectedIndex = 0
ProfileEditor.AttackableMonstersComboSelectedIndex = 0
ProfileEditor.MonstersName = { }
ProfileEditor.CurrentProfileSaveName = "Unamed"
ProfileEditor.DrawPath = false
ProfileEditor.PathRecorder = PathRecorder:New(MyGraph())

-----------------------------------------------------------------------------
-- ProfileEditor Functions
-----------------------------------------------------------------------------



function ProfileEditor.DrawProfileEditor()
    local shouldDraw
    local selfPlayer = GetSelfPlayer()



    if Bot.Running then
        ProfileEditor.WindowName = "Profile"
    elseif not Bot.Running then
        ProfileEditor.WindowName = "Profile Editor"
    end


    if ProfileEditor.Visible then
        _, ProfileEditor.Visible = ImGui.Begin(ProfileEditor.WindowName, ProfileEditor.Visible, ImVec2(500, 400), -1.0)

        _, ProfileEditor.CurrentProfileSaveName = ImGui.InputText("##profile_save_name", ProfileEditor.CurrentProfileSaveName)
        ImGui.SameLine()
        if ImGui.Button("Save") then
            ProfileEditor.SaveProfile(ProfileEditor.CurrentProfileSaveName)
        end

        _, ProfileEditor.AvailablesProfilesSelectedIndex = ImGui.Combo("##profile_load_combo", ProfileEditor.AvailablesProfilesSelectedIndex, ProfileEditor.AvailablesProfiles)
        ImGui.SameLine()
        if ImGui.Button("Load") then
            ProfileEditor.LoadProfile(ProfileEditor.AvailablesProfiles[ProfileEditor.AvailablesProfilesSelectedIndex])
        end

        if ImGui.Button("Clear profile##id_profile_clear", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
            ProfileEditor.PathRecorder:Reset()
            ProfileEditor.PathRecorder.Graph = MyGraph()
            ProfileEditor.CurrentProfile = Profile()
            ProfileEditor.CurrentProfile.HostSpots = { }
            ProfileEditor.CurrentProfileSaveName = "Unamed"
        end
        if ImGui.Button("Clear Path##id_mesh_clear", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
            ProfileEditor.PathRecorder.Graph = MyGraph()

        end

        if ImGui.CollapsingHeader("Pather", "id_profile_editor_mesh", true, true) then
            ImGui.Columns(2)

            _, ProfileEditor.PathRecorder.Enabled = ImGui.Checkbox("Enable Pather##profile_enable_mesher", ProfileEditor.PathRecorder.Enabled)
            ImGui.NextColumn()

            _, ProfileEditor.DrawPath = ImGui.Checkbox("Draw Path##profile_draw_mesher", ProfileEditor.DrawPath)
            ImGui.NextColumn()
            _, ProfileEditor.PathRecorder.SnapToNode = ImGui.Checkbox("Snap to Node##profile_snaptonode", ProfileEditor.PathRecorder.SnapToNode)
            --            ImGui.SameLine();
            --            _, ProfileEditor.OneWay = ImGui.Checkbox("One Way##profile_oneway", ProfileEditor.OneWay)
            ImGui.Columns(1)
            if ImGui.Button("Remove Nodes") then
                ProfileEditor.PathRecorder.Graph:RemoveNodesConnectionsInRadius(selfPlayer.Position.X, selfPlayer.Position.Y, selfPlayer.Position.Z, ProfileEditor.PathRecorder.RemoveRadius)
            end
            ImGui.Text("")
            _, ProfileEditor.PathRecorder.RemoveRadius = ImGui.SliderInt("Remove Radius##profile_remove_redius", ProfileEditor.PathRecorder.RemoveRadius, 100, 1000)
            _, ProfileEditor.PathRecorder.SnapDistance = ImGui.SliderInt("Snap Distance##profile_snap_Dist", ProfileEditor.PathRecorder.RemoveRadius, 100, 800)

        end

        if ImGui.CollapsingHeader("Hotspots", "id_profile_editor_hotspots", true, false) then
            if ImGui.Button("Add hotspot") then
                local selfPlayer = GetSelfPlayer()
                if selfPlayer then
                    local selfPlayerPosition = selfPlayer.Position
                    table.insert(ProfileEditor.CurrentProfile.Hotspots, { X = selfPlayerPosition.X, Y = selfPlayerPosition.Y, Z = selfPlayerPosition.Z, MinLevel = 1, MaxLevel = 100 })
                end
            end
            local currentHotspotIndex = 1
            ImGui.Columns(3)
            ImGui.Text("Name")
            ImGui.NextColumn()
            ImGui.Text("Min Level")
            ImGui.NextColumn()
            ImGui.Text("Max Level")
            ImGui.NextColumn()

            for key, v in pairs(ProfileEditor.CurrentProfile.Hotspots) do
                if ProfileEditor.CurrentProfile.Hotspots[key].MinLevel == nil or ProfileEditor.CurrentProfile.Hotspots[key].MaxLevel == nil then
                    ProfileEditor.CurrentProfile.Hotspots[key].MinLevel = 1
                    ProfileEditor.CurrentProfile.Hotspots[key].MaxLevel = 100
                end
                local pos = Vector3(v.X,v.Y,v.Z)
                if ImGui.SmallButton("x##id_profile_editor_delete_hotspot" .. tostring(key)) then
                    ProfileEditor.CurrentProfile.Hotspots[key] = nil
                    ImGui.NextColumn()
                    ImGui.NextColumn()
                else
                    ImGui.SameLine()
                    ImGui.Text("HS #" .. tostring(key) .. " (" .. tostring(math.floor(pos.Distance3DFromMe / 100)) .. "y)")
                    ImGui.NextColumn()
                    _, ProfileEditor.CurrentProfile.Hotspots[key].MinLevel = ImGui.SliderInt("Min##id_gui_hs_minlevel_" .. tostring(key), ProfileEditor.CurrentProfile.Hotspots[key].MinLevel, 1, ProfileEditor.CurrentProfile.Hotspots[key].MaxLevel)
                    ImGui.NextColumn()
                    _, ProfileEditor.CurrentProfile.Hotspots[key].MaxLevel = ImGui.SliderInt("Max##id_gui_hs_maxlevel_" .. tostring(key), ProfileEditor.CurrentProfile.Hotspots[key].MaxLevel, ProfileEditor.CurrentProfile.Hotspots[key].MinLevel, 100)
                    ImGui.NextColumn()

                end

                --[[
                ImGui.Text("Hotspot #" .. tostring(currentHotspotIndex) .. " (" .. tostring(math.floor(v.Distance3DFromMe / 100)) .. "y)")
                ImGui.SameLine()
                if ImGui.Button("Move to##id_profile_editor_moveto_hotspot" .. tostring(currentHotspotIndex)) then
                    --Navigator.MoveTo(v)
                end
                ImGui.SameLine()
                if ImGui.Button("Delete##id_profile_editor_delete_hotspot" .. tostring(currentHotspotIndex)) then
                    table.remove(ProfileEditor.CurrentProfile.Hotspots, currentHotspotIndex)
                end
                currentHotspotIndex = currentHotspotIndex + 1
                --]]
            end
            ImGui.Columns(1)
        end


        if ImGui.CollapsingHeader("Vendor npc", "id_profile_editor_Vendor", true, false) then
            if string.len(ProfileEditor.CurrentProfile.VendorNpcName) > 0 then
                ImGui.Text("Name : " .. ProfileEditor.CurrentProfile.VendorNpcName .. " (" .. math.floor(ProfileEditor.CurrentProfile:GetVendorPosition().Distance3DFromMe / 100) .. "y)")
            else
                ImGui.Text("Name : Not set")
            end
            if ImGui.Button("Set##id_profile_set_Vendor", ImVec2(ImGui.GetContentRegionAvailWidth() / 2, 20)) then
                local npcs = GetNpcs()
                if table.length(npcs) > 0 then
                    local VendorNpc = npcs[1]
                    ProfileEditor.CurrentProfile.VendorNpcName = VendorNpc.Name
                    ProfileEditor.CurrentProfile.VendorNpcPosition.X = VendorNpc.Position.X
                    ProfileEditor.CurrentProfile.VendorNpcPosition.Y = VendorNpc.Position.Y
                    ProfileEditor.CurrentProfile.VendorNpcPosition.Z = VendorNpc.Position.Z
                end
            end
            ImGui.SameLine()
            if ImGui.Button("Clear##id_profile_clear_Vendor", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
                ProfileEditor.CurrentProfile.VendorNpcName = ""
                ProfileEditor.CurrentProfile.VendorNpcPosition.X = 0
                ProfileEditor.CurrentProfile.VendorNpcPosition.Y = 0
                ProfileEditor.CurrentProfile.VendorNpcPosition.Z = 0
            end
        end

        if ImGui.CollapsingHeader("Repair npc", "id_profile_editor_Repair", true, false) then
            if string.len(ProfileEditor.CurrentProfile.RepairNpcName) > 0 then
                ImGui.Text("Name : " .. ProfileEditor.CurrentProfile.RepairNpcName .. " (" .. math.floor(ProfileEditor.CurrentProfile:GetRepairPosition().Distance3DFromMe / 100) .. "y)")
            else
                ImGui.Text("Name : Not set")
            end
            if ImGui.Button("Set##id_profile_set_Repair", ImVec2(ImGui.GetContentRegionAvailWidth() / 2, 20)) then
                local npcs = GetNpcs()
                if table.length(npcs) > 0 then
                    local RepairNpc = npcs[1]
                    ProfileEditor.CurrentProfile.RepairNpcName = RepairNpc.Name
                    ProfileEditor.CurrentProfile.RepairNpcPosition.X = RepairNpc.Position.X
                    ProfileEditor.CurrentProfile.RepairNpcPosition.Y = RepairNpc.Position.Y
                    ProfileEditor.CurrentProfile.RepairNpcPosition.Z = RepairNpc.Position.Z
                end
            end
            ImGui.SameLine()
            if ImGui.Button("Clear##id_profile_clear_Repair", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
                ProfileEditor.CurrentProfile.RepairNpcName = ""
                ProfileEditor.CurrentProfile.RepairNpcPosition.X = 0
                ProfileEditor.CurrentProfile.RepairNpcPosition.Y = 0
                ProfileEditor.CurrentProfile.RepairNpcPosition.Z = 0
            end
        end

        if ImGui.CollapsingHeader("Warehouse npc", "id_profile_editor_Warehouse", true, false) then
            if string.len(ProfileEditor.CurrentProfile.WarehouseNpcName) > 0 then
                ImGui.Text("Name : " .. ProfileEditor.CurrentProfile.WarehouseNpcName .. " (" .. math.floor(ProfileEditor.CurrentProfile:GetWarehousePosition().Distance3DFromMe / 100) .. "y)")
            else
                ImGui.Text("Warehouse : Not set")
            end
            if ImGui.Button("Set##id_profile_set_Warehouse", ImVec2(ImGui.GetContentRegionAvailWidth() / 2, 20)) then
                local npcs = GetNpcs()
                if table.length(npcs) > 0 then
                    local WarehouseNpc = npcs[1]
                    ProfileEditor.CurrentProfile.WarehouseNpcName = WarehouseNpc.Name
                    ProfileEditor.CurrentProfile.WarehouseNpcPosition.X = WarehouseNpc.Position.X
                    ProfileEditor.CurrentProfile.WarehouseNpcPosition.Y = WarehouseNpc.Position.Y
                    ProfileEditor.CurrentProfile.WarehouseNpcPosition.Z = WarehouseNpc.Position.Z
                end
            end
            ImGui.SameLine()
            if ImGui.Button("Clear##id_profile_clear_Warehouse", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
                ProfileEditor.CurrentProfile.WarehouseNpcName = ""
                ProfileEditor.CurrentProfile.WarehouseNpcPosition.X = 0
                ProfileEditor.CurrentProfile.WarehouseNpcPosition.Y = 0
                ProfileEditor.CurrentProfile.WarehouseNpcPosition.Z = 0
            end
        end

        if ImGui.CollapsingHeader("TurnIn npc", "id_profile_editor_Turnin", true, false) then
            if string.len(ProfileEditor.CurrentProfile.TurninNpcName) > 0 then
                ImGui.Text("Name : " .. ProfileEditor.CurrentProfile.TurninNpcName .. " (" .. math.floor(ProfileEditor.CurrentProfile:GetTurninPosition().Distance3DFromMe / 100) .. "y)")
            else
                ImGui.Text("Turnin : Not set")
            end
            if ImGui.Button("Set##id_profile_set_Turnin", ImVec2(ImGui.GetContentRegionAvailWidth() / 2, 20)) then
                local npcs = GetNpcs()
                if table.length(npcs) > 0 then
                    local TurninNpc = npcs[1]
                    ProfileEditor.CurrentProfile.TurninNpcName = TurninNpc.Name
                    ProfileEditor.CurrentProfile.TurninNpcPosition.X = TurninNpc.Position.X
                    ProfileEditor.CurrentProfile.TurninNpcPosition.Y = TurninNpc.Position.Y
                    ProfileEditor.CurrentProfile.TurninNpcPosition.Z = TurninNpc.Position.Z
                end
            end
            ImGui.SameLine()
            if ImGui.Button("Clear##id_profile_clear_Turnin", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
                ProfileEditor.CurrentProfile.TurninNpcName = ""
                ProfileEditor.CurrentProfile.TurninNpcPosition.X = 0
                ProfileEditor.CurrentProfile.TurninNpcPosition.Y = 0
                ProfileEditor.CurrentProfile.TurninNpcPosition.Z = 0
            end
        end
        ImGui.End()
    end
end


function ProfileEditor.RefreshAvailableProfiles()
    ProfileEditor.AvailablesProfiles = { }
    for k, v in pairs(Pyx.FileSystem.GetFiles("Profiles\\*.json2")) do
        v = string.gsub(v, ".json2", "")
        table.insert(ProfileEditor.AvailablesProfiles, v)
    end
end

function ProfileEditor.SaveProfile(name)

    local profileFilename = "\\Profiles\\" .. name .. ".json2"
    local meshFilename = "\\Profiles\\" .. name .. ".graph"


    Bot.Settings.LastProfileName = name

    local json = JSON:new()
    Pyx.FileSystem.WriteFile(profileFilename, json:encode_pretty(ProfileEditor.CurrentProfile))

    Pyx.FileSystem.WriteFile(meshFilename, MyGraph.GetJSONFromGraph(ProfileEditor.PathRecorder.Graph))

    ProfileEditor.RefreshAvailableProfiles()

end

function ProfileEditor.LoadProfile(name)

    local profileFilename = "\\Profiles\\" .. name .. ".json2"
    local meshFilename = "\\Profiles\\" .. name .. ".graph"

    print("Load graph : " .. meshFilename)

    Bot.Settings.LastProfileName = name
    ProfileEditor.CurrentProfileSaveName = name

    ProfileEditor.AttackableMonstersSelectedIndex = 0
    ProfileEditor.AttackableMonstersComboSelectedIndex = 0


    local json = JSON:new()
    ProfileEditor.CurrentProfile = Profile()
    table.merge(ProfileEditor.CurrentProfile, json:decode(Pyx.FileSystem.ReadFile(profileFilename)))

    if ProfileEditor.CurrentProfile.HotSpots ~= nil then
    for key, v in pairs(ProfileEditor.CurrentProfile.HotSpots) do
        if v.MinLevel == nil or v.MaxLevel == nil then
            v.MinLevel = 1
            v.MaxLevel = 100
        end
    end
    end

    print("Graph")
    local graph = MyGraph.LoadGraphFromJSON(Pyx.FileSystem.ReadFile(meshFilename))
    print(graph)

    ProfileEditor.PathRecorder.Graph = graph

end

function ProfileEditor.UpdateMonstersList()
    ProfileEditor.MonstersName = { }
    local selfPlayer = GetSelfPlayer()
    if selfPlayer then
        for k, v in pairs(GetMonsters()) do
            if not table.find(ProfileEditor.MonstersName, v.Name) and not table.find(ProfileEditor.CurrentProfile.AttackMonsters, v.Name) then
                table.insert(ProfileEditor.MonstersName, v.Name)
            end
        end
    end
end

function ProfileEditor.OnDrawGuiCallback()
    ProfileEditor.DrawProfileEditor()
end

function ProfileEditor.OnRender3D()

    local selfPlayer = GetSelfPlayer()
    local maxDistance = 20000
    local selfPlayer = GetSelfPlayer()

    ProfileEditor.PathRecorder:Pulse()

    if ProfileEditor.DrawPath and selfPlayer then
        local myPosition = MyNode(selfPlayer.Position.X, selfPlayer.Position.Y, selfPlayer.Position.Z)

        for k, v in pairs(ProfileEditor.CurrentProfile.Hotspots) do
            if selfPlayer.Position:GetDistance3D(Vector3(v.X,v.Y,v.Z)) <= maxDistance then
                Renderer.Draw3DTrianglesList(GetInvertedTriangleList(v.X, v.Y + 100, v.Z, 100, 150, 0xAAFF0000, 0xAAFF00FF))
            end
        end

        for key, v in pairs(ProfileEditor.PathRecorder.Graph:GetNodes()) do
            if myPosition:GetDistance3D(v) <= maxDistance then
                Renderer.Draw3DTrianglesList(GetInvertedTriangleList(v.X, v.Y + 25, v.Z, 25, 38, 0xAAFF0000, 0xAAFF00FF))
            end
        end

        local linesList = { }

        for key, v in pairs(ProfileEditor.PathRecorder.Graph:GetConnectionsList()) do
            if v.FromNode ~= nil and v.ToNode ~= nil then
                if myPosition:GetDistance3D(v.FromNode) <= maxDistance and myPosition:GetDistance3D(v.ToNode) <= maxDistance then
                    table.insert(linesList, { v.ToNode.X, v.ToNode.Y + 20, v.ToNode.Z, 0xFFFFFFFF })
                    table.insert(linesList, { v.FromNode.X, v.FromNode.Y + 20, v.FromNode.Z, 0xFFFFFFFF })

                end
            end
        end



        if table.length(linesList) > 0 then
            Renderer.Draw3DLinesList(linesList)
        end

    end
    --[[
             for k, v in pairs(Bot.Pather._pathRecorder.Graph:GetNodes()) do
                Renderer.Draw3DTrianglesList(GetInvertedTriangleList(v.X, v.Y + 25, v.Z, 25, 38, 0xAA0000FF, 0xAA0000FF))
        end
        --]]

end

ProfileEditor.RefreshAvailableProfiles()

if table.length(ProfileEditor.AvailablesProfiles) > 0 then
    ProfileEditor.AvailablesProfilesSelectedIndex = 1
end


