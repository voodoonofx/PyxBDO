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
    self.Settings = { TakeLoot = true, LootRadius = 4000, SkipLootPlayer = false, LogLoot = false, IgnoreBodyName = {}}
    self.State = 0

    self.ItemCheckFunction = nil
    self.CallWhenCompleted = nil
    self.CallWhileMoving = nil

    return self
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
            (not self.BlacklistActors[v.Guid] or Pyx.Win32.GetTickCount() - self.BlacklistActors[v.Guid] > 0) and
--            (not nearestAttacker or v.Position.Distance3DFromMe < nearestAttacker.Position.Distance3DFromMe / 2) and
--            ((self.CurrentLootActor ~= nil and self.CurrentLootActor.Key == v.Key) or v.IsLineOfSight) and
            Navigator.CanMoveTo(v.Position)
        then 
        
            if self.Settings.SkipLootPlayer == true and v.Position.Distance3DFromMe > 500 and Bot.DetectPlayerAt(v.Position,1000) == true then
                print("Skipped loot because of Player")
                self.BlacklistActors[v.Guid] = Pyx.Win32.GetTickCount() + 30 * 1000
--              return false
                else
                self.CurrentLootActor = v
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

        if self.Settings.LogLoot and #looted > 0 then
            local f = io.open(Pyx.Scripting.CurrentScript.Directory.."loot.txt", "a")
            local bodyName = self:GetBodyName(self.CurrentLootActor.Key)
            local msg = string.format("%s %s - %s\n", os.date(), bodyName, table.concat(looted, ","))
            f:write(msg)
            f:close()
        end

        if self.CallWhenCompleted then
            self.CallWhenCompleted(self)
        end
        
        return true
    end    

    if actorPosition.Distance3DFromMe > self.CurrentLootActor.BodySize + 150 then
        if self.CallWhileMoving then
            self:CallWhileMoving()
        end
        Navigator.MoveTo(actorPosition)
    else
        Navigator.Stop()
        selfPlayer:Interact(self.CurrentLootActor)
        --self.CurrentLootActor:RequestDropItems()
        
        if not self.CurrentLootActor.IsLootInteraction then
            print("Not lootable yet, black list !"  )
            self.BlacklistActors[self.CurrentLootActor.Guid] = Pyx.Win32.GetTickCount() + 30 * 1000 -- Not lootable for now
            return false
        end
        
        if not self.BlacklistActors[self.CurrentLootActor.Guid] then
            self.BlacklistActors[self.CurrentLootActor.Guid] = Pyx.Win32.GetTickCount() + 3000
            return false
        end
        
    end
    
    return true

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