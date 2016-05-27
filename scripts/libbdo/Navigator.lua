Navigator = { }
Navigator.Running = false
Navigator.Destination = Vector3(0, 0, 0)
Navigator.Waypoints = { }
Navigator.ApproachDistance = 100
Navigator.LastObstacleCheckTick = 0
Navigator.LastFindPathTick = 0
Navigator.LastStuckCheckTickcount = 0
Navigator.LastStuckTimer = PyxTimer:New(0.5)
Navigator.LastStuckCheckPosition = Vector3(0, 0, 0)
Navigator.LastMoveTo = Vector3(0, 0, 0)
Navigator.LastPosition = Vector3(0, 0, 0)
Navigator.LastWayPoint = false
Navigator.StuckCount = 0
Navigator.OnStuckCall = nil
Navigator.PlayerRun = false
Navigator.MeshConnects = { }
Navigator.MeshConnectEnabled = false


function Navigator.MeshConnectToVector3(meshConnect)
    local newpath = { }
    for key, value in pairs(meshConnect) do
        newpath[#newpath + 1] = Vector3(value.X, value.Y, value.Z)
    end

    return newpath
end

function Navigator.AppendPath(patha, pathb)
    local newpath = { }
    for key, value in pairs(patha) do
        newpath[#newpath + 1] = value
    end
    for key, value in pairs(pathb) do
        newpath[#newpath + 1] = value
    end
    return newpath
end

function Navigator.StartPathAtKey(key, path)
    local newpath = { }
    local tlength = table.length(path)

    for cnt = key, tlength do
        newpath[#newpath + 1] = path[cnt]
    end
    return newpath
end


function Navigator.ReversePath(path)
    local newpath = { }
    local tlength = table.length(path)

    for cnt = 1, tlength do
        newpath[#newpath + 1] = path[tlength - cnt + 1]
    end


    return newpath
end


function Navigator.FindClosestPoint(path, position)
    local tlength = table.length(path)
    local key = 0
    local lastlength = 0
    for cnt = 1, tlength do
        if key == 0 or lastlength >= path[cnt].Distance3DFromMe then
            key = cnt
            lastlength = path[cnt].Distance3DFromMe

        end

    end
    return key
end


function Navigator.GetPath(startPoint, endPoint)
    local selfPlayer = GetSelfPlayer()
    local waypoints = Navigation.FindPath(startPoint, endPoint)

    if table.length(waypoints) > 0 and waypoints[#waypoints]:GetDistance3D(endPoint) < 500 then
        return waypoints
    end
    -- no direct path lets check mesh connects
    --    print ("sp "..tostring(startPoint.IsOnMesh))
    --    print ("ep "..tostring(endPoint.IsOnMesh))

    if startPoint.IsOnMesh == true and endPoint.IsOnMesh == true then
        for key, value in pairs(Navigator.MeshConnects) do

            local canmesha = Navigation.FindPath(startPoint, Vector3(value[1].X, value[1].Y, value[1].Z))
            local canmeshb = Navigation.FindPath(Vector3(value[#value].X, value[#value].Y, value[#value].Z), endPoint)

            local canmeshc = Navigation.FindPath(startPoint, Vector3(value[#value].X, value[#value].Y, value[#value].Z))
            local canmeshd = Navigation.FindPath(Vector3(value[1].X, value[1].Y, value[1].Z), endPoint)

            if (table.length(canmesha) > 0 and canmesha[#canmesha]:GetDistance3D(Vector3(value[1].X, value[1].Y, value[1].Z)) < 500) and
                (table.length(canmeshb) > 0 and canmeshb[#canmeshb]:GetDistance3D(endPoint) < 500) then
--                print("Forward Connect")
                return Navigator.AppendPath(Navigator.AppendPath(canmesha, Navigator.MeshConnectToVector3(value)), canmeshb)
            end
            if ((table.length(canmeshc) > 0 and canmeshc[#canmeshc]:GetDistance3D(Vector3(value[#value].X, value[#value].Y, value[#value].Z)) < 500)) and
                ((table.length(canmeshd) > 0 and canmeshd[#canmeshd]:GetDistance3D(endPoint) < 500)) then
--                print("Reverse Connect")

                local testb = Navigator.MeshConnectToVector3(Navigator.ReversePath(value))
                --return testb
                        return Navigator.AppendPath(Navigator.AppendPath(canmeshc, testb),canmeshd)

            end
        end
    elseif endPoint.IsOnMesh == true then
        for key, value in pairs(Navigator.MeshConnects) do
            local canmesha = Navigation.FindPath(Vector3(value[#value].X, value[#value].Y, value[#value].Z), endPoint)
            local canmeshb = Navigation.FindPath(Vector3(value[1].X, value[1].Y, value[1].Z), endPoint)
            --        print ("A: "..tostring(table.length(canmesha)).." "..tostring(canmesha[#canmesha]:GetDistance3D(endPoint)))
            --        print ("B: "..tostring(table.length(canmeshb)).." "..tostring(canmeshb[#canmeshb]:GetDistance3D(endPoint)))
            if (table.length(canmesha) > 0 and canmesha[#canmesha]:GetDistance3D(endPoint) < 500) then
--                print("Connects forward")
                local point = Navigator.MeshConnectToVector3(value)
                local closestPoint = Navigator.FindClosestPoint(point)
                if (point[closestPoint].Distance3DFromMe < 500) then
                    return Navigator.StartPathAtKey(closestPoint, Navigator.AppendPath(point, canmesha))
                end
            end
            if (table.length(canmeshb) > 0 and canmeshb[#canmeshb]:GetDistance3D(endPoint) < 500) then
  --              print("Connects reverse")
                local point = Navigator.ReversePath(Navigator.MeshConnectToVector3(value))
                local closestPoint = Navigator.FindClosestPoint(point)
                if (point[closestPoint].Distance3DFromMe < 500) then
                    return Navigator.StartPathAtKey(closestPoint, Navigator.AppendPath(point, canmeshb))
                end
            end
        end
    else
        print("At least the endpoint must be on a mesh")
    end

    -- check MeshConnect here


    return nil
end

function Navigator.CanMoveTo(destination)
    local selfPlayer = GetSelfPlayer()

    if not selfPlayer then
        return false
    end

    local waypoints = Navigator.GetPath(selfPlayer.Position, destination)

    if waypoints == nil then
        return false
    end

    return true

end

function Navigator.MoveToStraight(destination)
    local selfPlayer = GetSelfPlayer()
    Navigator.Waypoints = { }
    table.insert(Navigator.Waypoints, destination)
    Navigator.Destination = destination
    Navigator.Running = true
    return true
end


function Navigator.MoveTo(destination, forceRecalculate, playerRun)

    local selfPlayer = GetSelfPlayer()
    local currentPosition = selfPlayer.Position

    if not selfPlayer then
        return false
    end

    if playerRun == nil or playerRun == false then
        Navigator.PlayerRun = false
    else
        Navigator.PlayerRun = true
    end

    if (forceRecalculate == nil or forceRecalculate == false) and
        Navigator.Destination.X == destination.X and
        Navigator.Destination.Y == destination.Y and
        Navigator.Destination.Z == destination.Z and
        --        Pyx.Win32.GetTickCount() - Navigator.LastFindPathTick < 500 and
        (table.length(Navigator.Waypoints) > 0 or Navigator.LastWayPoint == true) and
        Navigator.LastPosition.Distance2DFromMe < 150
         then
        return true
    end

    local waypoints = Navigator.GetPath(selfPlayer.Position, destination)

    if waypoints == nil then
        print("Cannot find path !")
        return false
    end

    if waypoints[#waypoints]:GetDistance3D(destination) > Navigator.ApproachDistance then
        table.insert(waypoints, destination)
    end

    while waypoints[1] and waypoints[1].Distance3DFromMe <= Navigator.ApproachDistance do
        table.remove(waypoints, 1)
    end

    Navigator.LastFindPathTick = Pyx.Win32.GetTickCount()
    Navigator.Waypoints = waypoints
    Navigator.Destination = destination
    Navigator.Running = true
    return true

end

function Navigator.Stop()
    Navigator.Waypoints = { }
    Navigator.Running = false
    Navigator.Destination = Vector3(0, 0, 0)
    Navigator.LastWayPoint = false
    Navigator.StuckCount = 0

    local selfPlayer = GetSelfPlayer()
    if selfPlayer then
        selfPlayer:MoveTo(Vector3(0, 0, 0))
    end
end

function Navigator.OnPulse()
    local selfPlayer = GetSelfPlayer()

    if selfPlayer ~= nil and selfPlayer.IsRunning == false and selfPlayer.IsSwimming == false then
        --        Navigator.LastStuckCheckTickcount = Pyx.Win32.GetTickCount()
        Navigator.LastStuckTimer:Reset()
        Navigator.LastStuckTimer:Start()
        Navigator.LastStuckCheckPosition = selfPlayer.Position
    end

    if Navigator.Running and selfPlayer then
        Navigator.LastPosition = selfPlayer.Position

        if Pyx.Win32.GetTickCount() - Navigator.LastObstacleCheckTick > 1000 then
            -- Navigation.UpdateObstacles() -- Do not use for now, it's coming :)
            Navigator.LastObstacleCheckTick = Pyx.Win32.GetTickCount()
        end

        if Navigator.LastStuckTimer:Expired() == true then
            if (Navigator.LastStuckCheckPosition.Distance2DFromMe < 35) then
                print("I'm stuck, jump forward !")
                if Navigator.StuckCount < 20 then
                Keybindings.HoldByActionId(KEYBINDING_ACTION_JUMP, 500)
                --[[
                    if selfPlayer.IsBattleMode == false and selfPlayer.IsSwimming == false then
                        selfPlayer:DoAction("JUMP_F_A")
                    elseif selfPlayer.IsBattleMode == false and selfPlayer.IsSwimming == true then
                        selfPlayer:DoAction("WATER_HIGH_WALL")
                    else
                        selfPlayer:DoAction("BT_JUMP_F_A")
                    end
                    --]]
                end
                Navigator.StuckCount = Navigator.StuckCount + 1
                if Navigator.StuckCount == 3 then
                    print("Still stuck. lets try to re-generate path")
                    Navigator.MoveTo(Navigator.Destination, true)
                end
                if Navigator.OnStuckCall ~= nil then
                    Navigator.OnStuckCall()
                end
            else
                Navigator.StuckCount = 0
            end
            Navigator.LastStuckTimer:Reset()
            Navigator.LastStuckTimer:Start()
            Navigator.LastStuckCheckPosition = selfPlayer.Position
        end

        local nextWaypoint = Navigator.Waypoints[1]

        if nextWaypoint then
            if nextWaypoint.Distance2DFromMe > Navigator.ApproachDistance then
                selfPlayer:MoveTo(nextWaypoint)
            else
                table.remove(Navigator.Waypoints, 1)
                if table.length(Navigator.Waypoints) == 0 then
                    Navigator.LastWayPoint = true
                else
                    Navigator.LastWayPoint = false
                end
            end
        end
        if Navigator.LastWayPoint == false and Navigator.PlayerRun == true and selfPlayer.StaminaPercent >= 100 and selfPlayer.IsSwimming == false and table.length(Navigator.Waypoints) > 6 then
         if selfPlayer.IsBattleMode == false then
               selfPlayer:DoAction("RUN_SPRINT_FAST_ST")
            else
                selfPlayer:DoAction("BT_RUN_SPRINT")
            end
        end
    end

end


function Navigator.OnRender3D()
    local selfPlayer = GetSelfPlayer()
    if selfPlayer then
        local linesList = { }
        for k, v in pairs(Navigator.Waypoints) do
            Renderer.Draw3DTrianglesList(GetInvertedTriangleList(v.X, v.Y + 20, v.Z, 10, 20, 0xFFFFFFFF, 0xFFFFFFFF))
        end
        local firstPoint = Navigator.Waypoints[1]
        if firstPoint then
            table.insert(linesList, { selfPlayer.Position.X, selfPlayer.Position.Y + 20, selfPlayer.Position.Z, 0xFFFFFFFF })
            table.insert(linesList, { firstPoint.X, firstPoint.Y + 20, firstPoint.Z, 0xFFFFFFFF })
        end
        for k, v in ipairs(Navigator.Waypoints) do
            local nextPoint = Navigator.Waypoints[k + 1]
            if nextPoint then
                table.insert(linesList, { v.X, v.Y + 20, v.Z, 0xFFFFFFFF })
                table.insert(linesList, { nextPoint.X, nextPoint.Y + 20, nextPoint.Z, 0xFFFFFFFF })
            end
        end
        if table.length(linesList) > 0 then
            Renderer.Draw3DLinesList(linesList)
        end
    end
end
