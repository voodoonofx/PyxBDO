LootActorState = { }
LootActorState.__index = LootActorState
LootActorState.Name = "LootActor"

setmetatable(LootActorState, {
    __call = function(cls, ...)
        return cls.new(...)
    end,
} )

function LootActorState.new()
    local self = setmetatable( { }, LootActorState)
    self._myTarget = nil
    self.BlacklistActors = PyxTimedList:New()

    self.Settings = { TakeLoot = true, LootRadius = 4000, SkipLootPlayer = false, LogLoot = false, IgnoreBodyName = { } }
    self.State = 0
    self.Stuck = false
    self.ItemCheckFunction = nil
    self.CallWhenCompleted = nil
    self.CallWhileMoving = nil
    self._state = 1
    self.LootAreaList = nil
    -- Format {Guid, Position}
    self._sleepTimer = nil
    self.Stuck = false
    return self
end

function LootActorState:Enter()
end

function LootActorState:Exit()
end

function LootActorState:KillNear(position, radius)
    if self.LootAreaList == nil then
        print("lootarea nil")
        return true
    end
    for k, v in pairs(self.LootAreaList._table) do
--        print(v.Object)
--        print(v.Object.Position)
        if position:GetDistance3D(v.Object.Position) < radius then
            return true
        end

    end
    return false
end

function LootActorState:NeedToRun()

    if self.Settings.TakeLoot == false then
        return false
    end

    local selfPlayer = GetSelfPlayer()

    if not selfPlayer then
        return false
    end

    if not selfPlayer.IsAlive then
        return false
    end

    local selfPlayerPosition = selfPlayer.Position

    if selfPlayer.Inventory.FreeSlots == 0 then
        return false
    end

    if self.Stuck == true then
        self.Stuck = false
        if self._myTarget ~= nil then
            print("Loot: Stuck skip loot")
            self.BlacklistActors:Add(self._myTarget.Guid, 600)
        end
    end


    --    local nearestAttacker = self:GetNeareastAttacker()

    local actors = { }
    for i, v in ipairs(GetActors()) do
        if v.IsLootable and self.Settings.IgnoreBodyName[self:GetBodyName(v)] == nil then
            table.insert(actors, v)
        end
    end

    table.sort(actors, function(a, b) return a.Position:GetDistance3D(selfPlayerPosition) < b.Position:GetDistance3D(selfPlayerPosition) end)
    if self._myTarget ~= nil then
        for k, v in pairs(actors) do
            if self.BlacklistActors:Contains(v.Guid) == false and v.Guid == self._myTarget.Guid and v.Position.Distance3DFromMe < self.Settings.LootRadius then
                --                print("loot Have Me")
                self._myTarget = v
                return true

            end
        end
        self._myTarget = nil
    end

    self._state = 1
    self._sleepTimer = nil
    for k, v in pairs(actors) do


        if v.Position.Distance3DFromMe < self.Settings.LootRadius and
            self.BlacklistActors:Contains(v.Guid) == false
            --         and   (v == self._myTarget or Bot.Pather:CanMoveTo(v.Position))
        then
            print(self:KillNear(v.Position, 800))
            if self:KillNear(v.Position, 800) == false then
                print("I didn't Kill anything near loot skipping")
                self.BlacklistActors:Add(v.Guid, 600)
            end

            if self.Settings.SkipLootPlayer == true and v.Position.Distance3DFromMe > 500 and Bot.DetectPlayerAt(v.Position, 1000) == true then
                print("Skipped loot because of Player")
                self.BlacklistActors:Add(v.Guid, 15)
            else
                self._myTarget = v
                return true
            end

        end
    end

    return false
end

function LootActorState:Run()

    local selfPlayer = GetSelfPlayer()
    if self._myTarget == nil then
        print("myTarget in Loot nil")
        return
    end

    local actorPosition = self._myTarget.Position



    if self._state >= 2 and Looting.IsLooting then
        local looted = { }
        local numLoots = Looting.ItemCount
        print("Loot in it")

        for i = 0, numLoots - 1 do
            local lootItem = Looting.GetItemByIndex(i)
            if lootItem then
                print("Loot item : " .. lootItem.ItemEnchantStaticStatus.Name)
                Looting.Take(i)
                if lootItem.ItemEnchantStaticStatus.Grade >= 1 then
                    table.insert(looted, lootItem.ItemEnchantStaticStatus.Name)
                end
            end
            if Looting.IsLooting == false then
                return false
            end
        end
        Looting.Close()
        self.State = 4
        self._sleepTimer = PyxTimer:New(0.5)
        self._sleepTimer:Start()
        return true

    end

    if self._state >= 2 and self._sleepTimer ~= nil and self._sleepTimer:IsRunning() and not self._sleepTimer:Expired() then
        return true
    end

    if self._state == 4 then
        self.BlacklistActors:Add(self._myTarget.Guid, 600)
        if self.CallWhenCompleted then
            self.CallWhenCompleted(self)
        end

        self._myTarget = nil
        self._sleepTimer = nil
        return true
    end

    if self._state == 2 and actorPosition.Distance3DFromMe <= 150 then
        self._sleepTimer = PyxTimer:New(1)
        self._sleepTimer:Start()
        self._myTarget:Interact(7)

        self._state = 3
        return true
    end

    if self._state == 3 then
        print("Too long to pickup skip")
        self.BlacklistActors:Add(self._myTarget.Guid, 5)
    end

    local action = selfPlayer.CurrentActionName


    if actorPosition.Distance3DFromMe > 150 then
        if self.CallWhileMoving then
            self:CallWhileMoving()
        end
        Bot.Pather:MoveDirectTo(actorPosition)
--        print("loot move")
        self._state = 1
    elseif self._state == 1 then
--        print("loot stop")
        Bot.Pather:Stop()
        if string.find(selfPlayer.CurrentActionName, "WAIT") == nil then
            -- ~= "WAIT" and selfPlayer.CurrentActionName ~= "BT_WAIT" then
--            print("Loot Wait")
            return true
        end
        selfPlayer:ClearActionState()
        --        selfPlayer:FacePosition(self._myTarget.Position)
        self._sleepTimer = PyxTimer:New(2)
        self._sleepTimer:Start()
        self._state = 2
        --        selfPlayer:Interact(self._myTarget)
        self._myTarget:Interact(7)
        return true
    end
end


function LootActorState:GetBodyName(actor)
    return BDOLua.Execute(string.format("return getActor(%i):get():getStaticStatusName()", actor.Key)) or ""
end
