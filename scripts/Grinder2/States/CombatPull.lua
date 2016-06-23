CombatPullState = { }
CombatPullState.__index = CombatPullState
CombatPullState.Name = "Pull"

setmetatable(CombatPullState, {
    __call = function(cls, ...)
        return cls.new(...)
    end,
} )

function CombatPullState.new()
    local self = setmetatable( { }, CombatPullState)
    self.CurrentCombatActor = { Key = 0 }
    self._pullStarted = nil
    self._newTarget = false
    self.MobIgnoreList = PyxTimedList:New()
    self.Enabled = true
    self.Settings = { DontPull = { }, SkipPullPlayer = true, PullSecondsUntillIgnore = 10 }
    self.Stuck = false
    self.DidPull = nil
    return self
end

function CombatPullState:Exit()
    local selfPlayer = GetSelfPlayer()
    if selfPlayer then
        selfPlayer:ClearActionState()
    end
end

function CombatPullState:NeedToRun()
    local selfPlayer = GetSelfPlayer()

    if not selfPlayer or self.Enabled == false then
        return false
    end

    if not selfPlayer.IsAlive or selfPlayer.IsSwimming then
        return false
    end

    if self.Stuck == true then
        self.Stuck = false
        if self.CurrentCombatActor ~= nil then
            print("Pull: Stuck pulling skip mob")
            self.MobIgnoreList:Add(self.CurrentCombatActor.Guid, 600)
        end
    end
    if self.DidPull ~= nill and self.DidPull:Expired() == false then
        return true
    end

    self.DidPull = nil

    local selfPlayerPosition = selfPlayer.Position
    local monsters = GetMonsters()
    table.sort(monsters, function(a, b) return a.Position:GetDistance3D(selfPlayerPosition) < b.Position:GetDistance3D(selfPlayerPosition) end)
    for k, v in pairs(monsters) do
        if v.IsVisible == true and
            v.IsAlive == true and
            v.HealthPercent == 100 and
            v.IsAggro == false and
            v.CanAttack == true and
            self.MobIgnoreList:Contains(v.Guid) == false and
            table.find(Bot.Settings.PullSettings.DontPull, v.Name) == nil and
            v.Position.Distance3DFromMe <= Bot.Settings.Advanced.PullDistance and
            (Bot.MeshDisabled == true or Bot.Settings.Advanced.IgnorePullBetweenHotSpots == false or
            Bot.Settings.Advanced.IgnorePullBetweenHotSpots == true and ProfileEditor.CurrentProfile:IsPositionNearHotspots(v.Position, Bot.Settings.Advanced.HotSpotRadius)) and
            ProfileEditor.CurrentProfile:CanAttackMonster(v) == true and
            ((self.CurrentCombatActor ~= nil and self.CurrentCombatActor.Guid == v.Guid) or v.IsLineOfSight == true) and
            (self.Settings.SkipPullPlayer == false or self.Settings.SkipPullPlayer == true and Bot.DetectPlayerAt(v.Position, 2000) == false)
        then
            if v.Guid ~= self.CurrentCombatActor.Guid then
                self._newTarget = true
            else
                self._newTarget = false
            end

            if self._newTarget == false and v.IsLineOfSight == false then
                print("Pull target lost LOS temp ignore")
                self.MobIgnoreList:Add(self.CurrentCombatActor.Guid, 600)
            else
                self.CurrentCombatActor = v
                return true
            end
        end
    end

    return false
end

function CombatPullState:Run()
    if self._pullStarted == nil or self._newTarget == true then

        self._pullStarted = PyxTimer:New(self.Settings.PullSecondsUntillIgnore)
        self._pullStarted:Start()
        self._newTarget = false
    end


    if self._pullStarted:Expired() == true then
        self.MobIgnoreList:Add(self.CurrentCombatActor.Guid, 600)
        print("Pull Added :" .. self.CurrentCombatActor.Guid .. " to Ignore list")
        return
    end

    if self.CurrentCombatActor.HealthPercent < 100 then
        return
    end

    Bot.CallCombatAttack(self.CurrentCombatActor, true)
    self.DidPull = PyxTimer:New(2)
    self.DidPull:Start()
end
