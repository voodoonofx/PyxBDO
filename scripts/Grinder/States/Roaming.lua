RoamingState = { }
RoamingState.__index = RoamingState
RoamingState.Name = "Roaming"

setmetatable(RoamingState, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function RoamingState.new()
  local self = setmetatable({}, RoamingState)
  self.Hotspots = ProfileEditor.CurrentProfile:GetHotspots()
  self.CurrentHotspotIndex = 1
  return self
end

function RoamingState:NeedToRun()

    local selfPlayer = GetSelfPlayer()

    if not selfPlayer then
        return false
    end

    if not selfPlayer.IsAlive then
        return false
    end

    return true
end

function RoamingState:Run()

    local hotspot = self.Hotspots[self.CurrentHotspotIndex]
    local selfPlayer = GetSelfPlayer()

    if hotspot == nil then
    print("No valid Hotspot got nil "..tostring(self.CurrentHotspotIndex).." "..tostring(table.length(self.Hotspots)))
    self.Hotspots = ProfileEditor.CurrentProfile:GetHotspots()
    print("Trying to change Hotspot")
    self:ChangeHotSpot()
    return
    end

    if hotspot.Distance3DFromMe > 200 then
        Bot.CallCombatRoaming()

        if Bot.Settings.RunToHotSpots == true and ProfileEditor.CurrentProfile:IsPositionNearHotspots(selfPlayer.Position, Bot.Settings.Advanced.HotSpotRadius*2) == false then
        Navigator.MoveTo(hotspot,false,true)
        else
        Navigator.MoveTo(hotspot,false,false)
        end
    else

    self:ChangeHotSpot()
        print("Moving to hotspot #" .. tostring(self.CurrentHotspotIndex))
    end
end

function RoamingState:ChangeHotSpot()
        if self.CurrentHotspotIndex < table.length(self.Hotspots) then
            self.CurrentHotspotIndex = self.CurrentHotspotIndex + 1
        else
            self.CurrentHotspotIndex = 1
        end

end
