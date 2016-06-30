RoamingState = { }
RoamingState.__index = RoamingState
RoamingState.Name = "Roaming"

setmetatable(RoamingState, {
    __call = function(cls, ...)
        return cls.new(...)
    end,
} )

function RoamingState.new()
    local self = setmetatable( { }, RoamingState)
    self.Hotspots = { }
    self.CurrentHotspotIndex = 1
    self.Pather = nil
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
        print("No valid Hotspot got nil " .. tostring(self.CurrentHotspotIndex) .. " " .. tostring(table.length(self.Hotspots)))
        self.Hotspots = ProfileEditor.CurrentProfile.HostSpots
        print("Trying to change Hotspot")
        self:ChangeHotSpot()
        return
    end
    local hotspotPos = Vector3(hotspot.X,hotspot.Y,hotspot.Z)

    if hotspotPos.Distance3DFromMe > 200 then
        Bot.CallCombatRoaming()

        if Bot.Settings.RunToHotSpots == true and ProfileEditor.CurrentProfile:IsPositionNearHotspots(selfPlayer.Position, Bot.Settings.Advanced.HotSpotRadius * 2) == false then
            Bot.Pather:PathTo(hotspotPos)
        else
            Bot.Pather:PathTo(hotspotPos)
        end
    else

        self:ChangeHotSpot()
        print("Moving to hotspot #" .. tostring(self.CurrentHotspotIndex))
    end

end

function RoamingState:ChangeHotSpot()
    local selfPlayer = GetSelfPlayer()
    local lastvalid = 0
    local nextvalid = 0
    local firstvalid = 0

    print("Change Hotspot My Level: "..tostring(selfPlayer.Level))

    for key, v in pairs(self.Hotspots) do
    print("Hotpost :"..tostring(v.MinLevel).." "..tostring(v.MaxLevel))
    if v.MinLevel == nil or v.MaxLevel == nil then
    v.MinLevel = 1
    v.MaxLevel = 100
    end
        if v.MinLevel <= selfPlayer.Level and v.MaxLevel >= selfPlayer.Level then
            if firstvalid == 0 then
                firstvalid = key
            end
            print("HS check "..tostring(key).." "..tostring(self.CurrentHotspotIndex))
            if key < self.CurrentHotspotIndex then
                lastvalid = key
            elseif key > self.CurrentHotspotIndex and nextvalid == 0 then
                nextvalid = key
            end
        end
    end
    -- No valid next or last hotspot
    if lastvalid == 0 and nextvalid == 0 then
    print("No Hotspots in my level range use all")
        if self.CurrentHotspotIndex < table.length(self.Hotspots) then
            self.CurrentHotspotIndex = self.CurrentHotspotIndex + 1
        else
            self.CurrentHotspotIndex = 1
        end
    elseif nextvalid > 0 then
        print("Found Next Hotspot")

        self.CurrentHotspotIndex = nextvalid
    else
        print("go to First Hotspot")
        self.CurrentHotspotIndex = firstvalid
    end

end
--[[
function RoamingState:ChangeHotSpot()
    local selfPlayer = GetSelfPlayer()
    local nextHotSpot = self.CurrentHotspotIndex




    if nextHotSpot < table.length(self.Hotspots) then
        nextHotSpot = nextHotSpot + 1
    else
        nextHotSpot = 1
    end

end
--]]
function RoamingState:Reset()
    self.CurrentHotspotIndex = 1
    self.Pather = nil
end