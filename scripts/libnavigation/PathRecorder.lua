PathRecorder = {}
PathRecorder.__index = PathRecorder

function PathRecorder:New(myGraph)

    local o = {
    Graph = myGraph,
    Enabled = false,
    ConnectDistance = 300,
    NodeDistance = 200,
    SnapToNode = true,
    SnapDistance = 400,
    _lastAddVector3 = Vector3(0, 0, 0),
    _lastAddNode = nil,
    OneWay = false,
    RemoveRadius = 500,
  }
  setmetatable(o, self)
  return o
end

function PathRecorder:Reset()
    self.Enabled = false
    self.ConnectDistance = 300
    self.NodeDistance = 200
    self.SnapToNode = true
    self.SnapDistance = 400
    self._lastAddVector3 = Vector3(0, 0, 0)
    self._lastAddNode = nil
    self.OneWay = false

end

function PathRecorder:Pulse()
    if self.Enabled == false then
        return
    end

    if self._lastAddNode ~= nil and self._lastAddVector3.Distance3DFromMe <self.NodeDistance then
        return
    end

    local selfPlayer = GetSelfPlayer()
    if not selfPlayer then
    return
    end

    local currentPosition = MyNode(selfPlayer.Position.X, selfPlayer.Position.Y, selfPlayer.Position.Z)

    if self.SnapToNode == true then
        local tnode = self.Graph:FindClosestNode(selfPlayer.Position.X, selfPlayer.Position.Y, selfPlayer.Position.Z, self.SnapDistance, true)
        if tnode ~= nil then
            currentPosition = tnode
        end


    end

    currentPosition = self.Graph:AddNode(currentPosition)
--    local positionPtr = graph:NodeExists(currentPosition.X, currentPosition.Y, currentPosition.Z)

    if currentPosition == nil then
        print("Hmm can't find node just added")
        return
    end

--    currentPosition = positionPtr;

    if self._lastAddNode ~= nil then
        self.Graph:ConnectNode(self._lastAddNode, currentPosition, not self.OneWay)
    end

    if ProfileEditor.OneWay == false then
        self.Graph:ConnectNodeRadius(currentPosition, self.ConnectDistance, true)
    end

    self._lastAddNode = currentPosition
    self._lastAddVector3 = selfPlayer.Position

end

