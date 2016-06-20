Pather = { }
Pather.__index = Pather

function Pather:New(myGraph)

    local o = {
        Graph = myGraph,
        Fallback = true,

        CurrentPath = { },
        CurrentPosition = 0,
        CustomStuckFunction = nil,
        ReportStuckFunction = nil,
        ToFarDistance = 1000,
        _lastPosition = nil,
        _lastMoveTo = nil,
        _currentPath = { },
        _currenPathIndex = 1,
        _pathMode = 1,
        -- 1 is Nav system, 3 is BDO Internal
        StuckCount = 0,
        Running = false,
        Destination = Vector3(0,0,0),
        LastStuckTimer = PyxTimer:New(0.5),
        LastStuckCheckPosition = Vector3(0,0,0),
        ApproachDistance = 190,
        DirectLosDistance = 2500,
        SentAutoPath = PyxTimer:New(3)

    }
    setmetatable(o, self)
    return o
end

function Pather:SendBDOMove(destination, playerRun)
    print("Send BDO Move")
    local selfPlayer = GetSelfPlayer()
    --    selfPlayer:ClearActionState()
    local myDistance = destination.Distance3DFromMe
    if myDistance < self.DirectLosDistance and destination.IsLineOfSight then
        selfPlayer:MoveTo(destination)

    else

        local code = string.format([[
                                                                                                                ToClient_DeleteNaviGuideByGroup(0)
                                                                                                                local target = float3(%f, %f, %f)
                                                                                                                local repairNaviKey = ToClient_WorldMapNaviStart( target, NavigationGuideParam(), true, true )
                                                                                                                local selfPlayer = getSelfPlayer():get()
                                                                                                                selfPlayer:setNavigationMovePath(key)
                                                                                                                selfPlayer:checkNaviPathUI(key)
                                                                                                            ]], destination.X, destination.Y, destination.Z)
        BDOLua.Execute(code)
    end
    self.SentAutoPath:Reset()
    self.SentAutoPath:Start()
    self._pathMode = 3

    self.Destination = destination
    self.Running = true


end

function Pather:Pulse()
    local selfPlayer = GetSelfPlayer()

    if selfPlayer == nil then
        return
    end

    if selfPlayer ~= nil and(self.Running == false and selfPlayer.IsSwimming == false) or(string.find(selfPlayer.CurrentActionName, "STANCE_CHANGE", 1) ~= nil) then
        self.LastStuckTimer:Reset()
        self.LastStuckTimer:Start()
        self.LastStuckCheckPosition = selfPlayer.Position
    end

    if self.Running == true and selfPlayer ~= nil then
        self.LastPosition = selfPlayer.Position



        if self.LastStuckTimer:Expired() == true then
            if (self.LastStuckCheckPosition.Distance2DFromMe < 35) then
                self:StuckHandler()
            else
                self.StuckCount = 0
            end
            self.LastStuckTimer:Reset()
            self.LastStuckTimer:Start()
            self.LastStuckCheckPosition = selfPlayer.Position
        end

        if self._pathMode == 3 then
            local myDistance = self.Destination.Distance3DFromMe
            if myDistance > 500 then
                if string.find(selfPlayer.CurrentActionName, "AUTO_RUN", 1) == nil
                    and string.find(selfPlayer.CurrentActionName, "RUN_SPRINT_FAST", 1) == nil
                    and(self.SentAutoPath:IsRunning() == false or self.SentAutoPath:Expired() == true) then
                    if self.Destination.IsLineOfSight then
                        selfPlayer:MoveTo(self.Destination)
                    else
                        --                        print(self.Destination.IsLineOfSight)
                        local code = string.format([[
                                                                                                                                                                                                                        ToClient_DeleteNaviGuideByGroup(0)
                                                                                                                                                                                                                        local target = float3(%f, %f, %f)
                                                                                                                                                                                                                        local repairNaviKey = ToClient_WorldMapNaviStart( target, NavigationGuideParam(), true, true )
                                                                                                                                                                                                                        local selfPlayer = getSelfPlayer():get()
                                                                                                                                                                                                                        selfPlayer:setNavigationMovePath(key)
                                                                                                                                                                                                                        selfPlayer:checkNaviPathUI(key)
                                                                                                                                                                                                                    ]], self.Destination.X, self.Destination.Y, self.Destination.Z)
                        BDOLua.Execute(code)

                    end
                end
                return
            end
--            if myDistance > self.ApproachDistance then
                selfPlayer:MoveTo(self.Destination)
--            else
--                selfPlayer:ClearActionState()
--                self:Stop()
--            end

            return
        end

        if self._pathMode == 1 then
            local nextWaypoint = Vector3(self.CurrentPath[self._currenPathIndex].X, self.CurrentPath[self._currenPathIndex].Y, self.CurrentPath[self._currenPathIndex].Z)
            if nextWaypoint then
                if nextWaypoint.Distance2DFromMe > self.ApproachDistance or self._currenPathIndex == table.length(self.CurrentPath) then
                    selfPlayer:MoveTo(nextWaypoint)
                else
                    if self._currenPathIndex >= table.length(self.CurrentPath) then
                        self._currenPathIndex = table.length(self.CurrentPath)
                    else
                        self._currenPathIndex = self._currenPathIndex + 1
                    end
                end
            end
        end

    end

end

function Pather:MoveDirectTo(to)
       local  path = { MyNode(to.X, to.Y, to.Z) }
        if self._pathMode == 3 then
            self:Stop()

        end
        self.Destination = to
        self.CurrentPath = path
        self._pathMode = 1
        self._currenPathIndex = 1
        self.Running = true
        print("Going Direct have los")

end

function Pather:MoveTo(to)
    local selfPlayer = GetSelfPlayer()

    if selfPlayer == nil then
        return false
    end

    if self.Destination.X == to.X and self.Destination.Y == to.Y and self.Destination.Z == to.Z and table.length(self.CurrentPath) > 0 then
--        print("Same Dest have a path")
        self.Running = true
        return true
    end
    local path = { }
    if selfPlayer.Position:GetDistance3D(to) < self.DirectLosDistance and to.IsLineOfSight then
        self:MoveDirectTo(to)
        return true
    else
        path = self:GeneratePath(selfPlayer.Position, to)
    end

    if table.length(path) > 0 then
        if self._pathMode == 3 then
            self:Stop()

        end
        self.Destination = to
        self.CurrentPath = path
        self._pathMode = 1
        self._currenPathIndex = 1
        self.Running = true

        return true
    elseif self.Fallback == true then
        if self.Destination.X == to.X and self.Destination.Y == to.Y and self.Destination.Z == to.Z and self.Running == false then
            self:SendBDOMove(to, false)
            self.SentAutoPath:Reset()
            self.SentAutoPath:Start()

        end
        self.Destination = to
        self.CurrentPath = { }
        self._pathMode = 3
        self._currenPathIndex = 1
        self.Running = true
    end
    return false
end

function Pather:GeneratePath(from, to)
    local selfPlayer = GetSelfPlayer()

    local path = { }

    if selfPlayer == nil then
        return path
    end


    local startNode = self.Graph:FindClosestNode(from.X, from.Y, from.Z, 1000, true)
    local endNode = self.Graph:FindClosestNode(to.X, to.Y, to.Z, 1000, true)

    if (startNode == nil or endNode == nil) then
        return path
    end


    local astar = MyAStar(self.Graph)
    local path = astar:SearchForPath(startNode, endNode, true, true)

    return path
end


function Pather:CanMoveTo(to)
    local selfPlayer = GetSelfPlayer()
    if selfPlayer == nil then
        return false
    end

    if self.Fallback == true then
        return true
    end

    if to.Distance3DFromMe < self.DirectLosDistance and  to.IsLineOfSight then
    return true
    end

    return table.length(self:GeneratePath(from, to)) > 0

end

function Pather:StuckHandler()
    --[[
--                print("I'm stuck")
                -- , jump forward !")
--                print(selfPlayer.CurrentActionName)
                if Navigator.StuckCount == 2 or Navigator.StuckCount == 7 or Navigator.StuckCount == 20 or Navigator.StuckCount == 30 then
                    print("Set Move Forward")
                    selfPlayer:SetActionState(ACTION_FLAG_MOVE_FORWARD, 1000)
                elseif Navigator.StuckCount == 4 or Navigator.StuckCount == 10 then
                    print("Jump Forward")
                    Keybindings.HoldByActionId(KEYBINDING_ACTION_JUMP, 500)
                elseif Navigator.StuckCount == 15  then
                    print("Move Right")
                    selfPlayer:SetActionState(ACTION_FLAG_MOVE_RIGHT, 1000)
                elseif Navigator.StuckCount == 25  then
                    print("Move Left")
                    selfPlayer:SetActionState(ACTION_FLAG_MOVE_LEFT, 1000)
                end
                Navigator.StuckCount = Navigator.StuckCount + 1
                if Navigator.StuckCount == 30 and Navigator.PathingMode == 1 then
                    print("Still stuck. lets try to re-generate path")
                    Navigator.MoveTo(Navigator.Destination, true)
                end
                if Navigator.OnStuckCall ~= nil then
                    Navigator.OnStuckCall()
                end

--]]
end

function Pather:Stop()
    local selfPlayer = GetSelfPlayer()
    self.Running = false
    self.CurrentPath = { }
    self.Destination = Vector3(0, 0, 0)
    self.LastWayPoint = false
    self.StuckCount = 0
    self.LastStuckTimer:Reset()
    self.LastStuckTimer:Start()
    self.LastStuckCheckPosition = selfPlayer.Position

    if selfPlayer then
        selfPlayer:MoveTo(Vector3(0, 0, 0))
    end

end