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
    self.Settings = { DontPull = { }, SkipPullPlayer = true }
    return self
end

function CombatPullState:Enter()
    if Bot.Combat.PullEnter then
        Bot.Combat:PullEnter(self)
        return
    end
end

function CombatPullState:Exit()
    if Bot.Combat.PullExit then
        Bot.Combat:PullExit(self)
        return
    end

    local selfPlayer = GetSelfPlayer()
    if selfPlayer then
        selfPlayer:ClearActionState()
    end
end

function CombatPullState:NeedToRun()
    if Bot.Combat.PullNeedToRun then
        return Bot.Combat:PullNeedToRun(self)
    end

    local selfPlayer = GetSelfPlayer()

    if not selfPlayer or self.Enabled == false then
        return false
    end

    if not selfPlayer.IsAlive or selfPlayer.IsSwimming then
        return false
    end

    local selfPlayerPosition = selfPlayer.Position
    local monsters = GetMonsters()
    table.sort(monsters, function(a, b) return a.Position:GetDistance3D(selfPlayerPosition) < b.Position:GetDistance3D(selfPlayerPosition) end)
    for k, v in pairs(monsters) do
        if v.IsVisible == true and
            v.IsAlive == true and
            v.HealthPercent == 100 and
            v.IsAggro == false and
            --            math.abs(selfPlayer.Position.Y - v.Position.Y) < 250 and
            -- v.CharacterStaticStatus.TribeType ~= TRIBE_TYPE_UNTRIBE and
            v.CanAttack == true and
            self.MobIgnoreList:Contains(v.Key) == false and
            table.find(Bot.Settings.PullSettings.DontPull, v.Name) == nil and
            v.Position.Distance3DFromMe <= Bot.Settings.Advanced.PullDistance and
            (Bot.MeshDisabled == true or Bot.Settings.Advanced.IgnorePullBetweenHotSpots == false or
            Bot.Settings.Advanced.IgnorePullBetweenHotSpots == true and ProfileEditor.CurrentProfile:IsPositionNearHotspots(v.Position, Bot.Settings.Advanced.HotSpotRadius)) and
            ProfileEditor.CurrentProfile:CanAttackMonster(v) == true and
            ((self.CurrentCombatActor ~= nil and self.CurrentCombatActor.Key == v.Key) or v.IsLineOfSight == true) and
            Navigator.CanMoveTo(v.Position) == true
            and(self.Settings.SkipPullPlayer == false or self.Settings.SkipPullPlayer == true and Bot.DetectPlayerAt(v.Position, 2000) == false)
        then

            if v.Key ~= self.CurrentCombatActor.Key then
                self._newTarget = true
            else
                self._newTarget = false
            end

            self.CurrentCombatActor = v
            return true
        end
    end

    return false
end

function CombatPullState:Run()
    if Bot.Combat.PullRun then
        Bot.Combat:PullRun(self)
        return
    end

    if self._pullStarted == nil or self._newTarget == true then
        self._pullStarted = PyxTimer:New(Bot.Settings.Advanced.PullSecondsUntillIgnore)
        self._pullStarted:Start()
    end

    local selfPlayer = GetSelfPlayer()
    if selfPlayer ~= nil and string.find(selfPlayer.CurrentActionName, "ACTION_CHANGE", 1) then
        return
    end
    --[[
    if selfPlayer and selfPlayer.IsBattleMode == false then
        if selfPlayer.IsActionPending then
            return
        end
        Keybindings.HoldByActionId(KEYBINDING_ACTION_WEAPON_IN_OUT, 500)
        --        selfPlayer:SwitchBattleMode()
        print("Combat pull switch modes: ")
        return
    end
    --]]
    --[[
    if selfPlayer and not selfPlayer.IsActionPending and not selfPlayer.IsBattleMode then
        print("Combat Pull: Switch to battle mode !")
Keybindings.HoldByActionId(KEYBINDING_ACTION_WEAPON_IN_OUT, 300)
--        selfPlayer:SwitchBattleMode()
    end
    --]]
    if self._pullStarted:Expired() == true then
        self.MobIgnoreList:Add(self.CurrentCombatActor.Key, 600)
        print("Pull Added :" .. self.CurrentCombatActor.Key .. " to Ignore list")
        return
    end
    if Looting.IsLooting then
        Looting.Close()
        return
    end

    Bot.CallCombatAttack(self.CurrentCombatActor, true)
end
