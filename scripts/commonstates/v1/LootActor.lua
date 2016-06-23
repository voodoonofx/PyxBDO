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
    self.CurrentLootActor = { }
    self.BlacklistActors = { }
    self.LootStartTime = { }
    self.Settings = { TakeLoot = true, LootRadius = 4000, SkipLootPlayer = false, LogLoot = false, IgnoreBodyName = {}}
    self.State = 1

    self.ItemCheckFunction = nil
    self.CallWhenCompleted = nil
    self.CallWhileMoving = nil

    self.LastCanceledLootTime = 0
    self.WaitForLootTime = 0

    return self
end

function LootActorState:Enter()
    self.LootStartTime = { }
end

function LootActorState:Exit()
    -- if looting was interrupted, delay looting to prevent flipflop from combat to looting
    -- NOTE this does not prevent looting from flipflopping between 2 items
    if self.CurrentLootActor.IsLootInteraction then
        self.LastCanceledLootTime = os.clock()
    end
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
    
    if os.clock() - self.LastCanceledLootTime < 1 then
        --print("preventing looting flip flop")
        return false
    end

    if os.clock() < self.WaitForLootTime then
        return true
    end

--    local nearestAttacker = self:GetNeareastAttacker()

    local actors = {}
    for i,v in ipairs(GetActors()) do
        if v.IsLootable and self.Settings.IgnoreBodyName[self:GetBodyName(v)] == nil then
            table.insert(actors, v)
        end
    end

    table.sort(actors, function(a, b) return a.Position:GetDistance3D(selfPlayerPosition) < b.Position:GetDistance3D(selfPlayerPosition) end)
    for k, v in pairs(actors) do
        if v.Position.Distance3DFromMe < self.Settings.LootRadius and
            (self.BlacklistActors[v.Guid] == nil or os.clock() - self.BlacklistActors[v.Guid] > 0) and
            Navigator.CanMoveTo(v.Position)
        then 
        
            if self.Settings.SkipLootPlayer == true and v.Position.Distance3DFromMe > 500 and Bot.DetectPlayerAt(v.Position,1000) == true then
                print("Skipped loot because of Player")
                self.BlacklistActors[v.Guid] = os.clock() + 30
            else
                if self.CurrentLootActor.Guid ~= v.Guid then
                    -- new body
                    -- check if previous body wasn't looted, if so then blacklist it for a few seconds
                    if self.CurrentLootActor.IsLootInteraction then
                        local bodyName = self:GetBodyName(self.CurrentLootActor)
                        print(string.format("Loot flipflop on %s. Blacklisting temporarily", bodyName))
                        self.BlacklistActors[self.CurrentLootActor.Guid] = os.clock() + 1
                        self.CurrentLootActor = {}
                    end
                    self.CurrentLootActor = v
                    self.LootStartTime[v.Guid] = os.clock()
                else
                    -- same body, blacklist if it takes too long to loot
                    local lootStartTime = self.LootStartTime[v.Guid]
                    if lootStartTime ~= nil and os.clock() - lootStartTime > 10 then
                        local bodyName = self:GetBodyName(v)
                        print(string.format("Loot taking too long. Blacklisting %s (%i)", bodyName, v.Guid))
                        self.BlacklistActors[v.Guid] = os.clock() + 60 * 2
                        self.CurrentLootActor = {}
                    end
                end
                return true
            end
            
        end
    end

    return false
end

function LootActorState:Run()

    local selfPlayer = GetSelfPlayer()
    local actorPosition = self.CurrentLootActor.Position

    if Looting.IsLooting then
        local looted = {}
        local numLoots = Looting.ItemCount
        for i=0,numLoots-1 do 
            local lootItem = Looting.GetItemByIndex(i)
            if lootItem then
                print("Loot item : " .. lootItem.ItemEnchantStaticStatus.Name)
                Looting.Take(i)
                if lootItem.ItemEnchantStaticStatus.Grade >= 1 then
                    table.insert(looted, lootItem.ItemEnchantStaticStatus.Name)
                end
            end
        end
        Looting.Close()

        if self.Settings.LogLoot and #looted > 0 and self.LastLoggedBody ~= self.CurrentLootActor.Guid then
            self.LastLoggedBody = self.CurrentLootActor.Guid
            local f = io.open(Pyx.Scripting.CurrentScript.Directory.."loot.txt", "a")
            local bodyName = self:GetBodyName(self.CurrentLootActor)
            local msg = string.format("%s %s - %s\n", os.date(), bodyName, table.concat(looted, ","))
            f:write(msg)
            f:close()
        end

        if self.CallWhenCompleted then
            self.CallWhenCompleted(self)
        end
        
        self.CurrentLootActor = {}
        self.WaitForLootTime = 0
        return true
    end

    local action = selfPlayer.CurrentActionName

    if os.clock() < self.WaitForLootTime then

        if action ~= "WAIT" and action ~= "BT_WAIT" then
            return true
        else
            -- sometimes looting will be interrupted by combat 
            -- but sometimes it will just stutter step all over the body, not sure why so we fall back on the animation bypassing loot
            if not self.CurrentLootActor.IsLootInteraction then
                print("body disappeared")
                self.WaitForLootTime = 0
                self.BlacklistActors[self.CurrentLootActor.Guid] = os.clock() + 30 
                self.CurrentLootActor = {}
                return true
            end
            print("looting didn't start, trying no-animation loot")
            Navigator.Stop()
            self.CurrentLootActor:RequestDropItems()
            return true
        end
    end    

    if actorPosition.Distance3DFromMe > 500 or (actorPosition.Distance2DFromMe - self.CurrentLootActor.BodySize - selfPlayer.BodySize > 80) then
        if self.CallWhileMoving then
            self:CallWhileMoving()
        end
        Navigator.MoveTo(actorPosition)
    else
        Navigator.Stop()

        selfPlayer:Interact(self.CurrentLootActor)
        
        if not self.CurrentLootActor.IsLootInteraction then
            print("Not lootable yet, black list !"  )
            self.BlacklistActors[self.CurrentLootActor.Guid] = os.clock() + 30 -- Not lootable for now
            self.CurrentLootActor = {}
            return false
        end
        
        -- wait up to 2 seconds for the loot window to pop
        self.WaitForLootTime = os.clock() + 2.0
        self.BlacklistActors[self.CurrentLootActor.Guid] = os.clock() + 5
        return true
    end
end

function LootActorState:GetNeareastAttacker()
    for k,v in pairs(GetMonsters()) do
        if v.IsAggro and v.CanAttack and v.IsLineOfSight then
            return v
        end
    end
    return nil
end

function LootActorState:GetBodyName(actor)
    return BDOLua.Execute(string.format("return getActor(%i):get():getStaticStatusName()", actor.Key)) or ""
end