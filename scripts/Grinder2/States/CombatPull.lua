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
    self.CurrentCombatActor = nil
    self._pullStarted = nil
    self._newTarget = false
    self.MobIgnoreList = PyxTimedList:New()
    self.Enabled = true
    self.Settings = { DontPull = { }, SkipPullPlayer = true, PullSecondsUntillIgnore = 10 }
    self.Stuck = false
    self.DidPull = nil
    self._switchTimer = PyxTimer:New(3)
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
            Bot.KillList:Remove( { Guid = self.CurrentCombatActor.Guid, Position = self.CurrentCombatActor.Position })
        end
    end
    --[[
    if self.DidPull ~= nill and self.DidPull:Expired() == false then
        return true
    end
    --]]
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
            if self.CurrentCombatActor == nil or v.Guid ~= self.CurrentCombatActor.Guid then
                self._newTarget = true
            else
                self._newTarget = false
            end

            if self._newTarget == false and(v.IsLineOfSight == false or v.HealthPercent ~= 100) then
                print("Pull target lost LOS or health temp ignore")
                self.MobIgnoreList:Add(self.CurrentCombatActor.Guid, 600)
                Bot.KillList:Remove( { Guid = self.CurrentCombatActor.Guid, Position = self.CurrentCombatActor.Position })
            else
                self.CurrentCombatActor = v
                return true
            end
        end
    end
    self.CurrentCombatActor = nil
    return false
end

function CombatPullState:Run()
local selfPlayer = GetSelfPlayer()

    if self._pullStarted == nil or self._newTarget == true then
        self._pullStarted = PyxTimer:New(self.Settings.PullSecondsUntillIgnore)
        self._pullStarted:Start()
        self._newTarget = false
    end

    if self._pullStarted:Expired() == true then
        self.MobIgnoreList:Add(self.CurrentCombatActor.Guid, 600)
        print("Pull Added :" .. self.CurrentCombatActor.Guid .. " to Ignore list")
        Bot.KillList:Remove( { Guid = self.CurrentCombatActor.Guid, Position = self.CurrentCombatActor.Position })

        return
    end

        if Looting.IsLooting then
        Looting.Close()
        return
    end

        if selfPlayer.CurrentActionName == "ITEM_PICK_ING" then
--    print("Loot bug")
    GetSelfPlayer():SetActionState(ACTION_FLAG_MOVE_FORWARD, 50)
    return
    end


    if selfPlayer ~= nil and (string.find(selfPlayer.CurrentActionName, "ACTION_CHANGE", 1) or
    string.find(selfPlayer.CurrentActionName, "ITEM", 1)) then
        return
    end


    if selfPlayer and selfPlayer.IsBattleMode == false then
        if selfPlayer.IsActionPending then
            return
        end
        if self._switchTimer:IsRunning() == false or self._switchTimer:Expired() == true then
        Keybindings.HoldByActionId(KEYBINDING_ACTION_WEAPON_IN_OUT, 500)
        print("Combat pull switch modes: "..tostring(selfPlayer.IsBattleMode).." "..tostring(selfPlayer.CurrentActionName))
        self._switchTimer:Reset()
        self._switchTimer:Start()
        end
        return
    end

    --     print("Pull 3")
    --[[ causing crash as ptr can disapear if quick kill
    if self.CurrentCombatActor == nil or self.CurrentCombatActor.HealthPercent < 100 then
        return
    end
    --]]
    if Looting.IsLooting then
        Looting.Close()
        return
    end


    Bot.KillList:Add( { Guid = self.CurrentCombatActor.Guid, Position = Vector3(self.CurrentCombatActor.Position.X, self.CurrentCombatActor.Position.Y, self.CurrentCombatActor.Position.Z) }, 300)
    Bot.CallCombatAttack(self.CurrentCombatActor, true)

    self.DidPull = PyxTimer:New(2)
    self.DidPull:Start()
end
