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
    self.Settings = { TakeLoot = true, LootRadius = 4000, SkipLootPlayer = false }
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

    local actors = GetActors()
    table.sort(actors, function(a, b) return a.Position:GetDistance3D(selfPlayerPosition) < b.Position:GetDistance3D(selfPlayerPosition) end)
    for k, v in pairs(actors) do
        if v.IsLootable and
            v.Position.Distance3DFromMe < self.Settings.LootRadius and
            (not self.BlacklistActors[v.Guid] or Pyx.Win32.GetTickCount() - self.BlacklistActors[v.Guid] < 2000) and
--            (not nearestAttacker or v.Position.Distance3DFromMe < nearestAttacker.Position.Distance3DFromMe / 2) and
--            ((self.CurrentLootActor ~= nil and self.CurrentLootActor.Key == v.Key) or v.IsLineOfSight) and
            Navigator.CanMoveTo(v.Position)
        then 
			if self.Settings.SkipLootPlayer and Bot.DetectPlayer() then
				print("Skipped loot because of Player")
				self.BlacklistActors[v.Guid] = Pyx.Win32.GetTickCount() - 30 * 1000
				return false
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
        local numLoots = Looting.ItemCount
        for i=0,numLoots-1 do 
            local lootItem = Looting.GetItemByIndex(i)
            if lootItem then
                print("Loot item : " .. lootItem.ItemEnchantStaticStatus.Name)
                Looting.Take(i)
            end
        end
        Looting.Close();
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
        self.CurrentLootActor:RequestDropItems()
        
        if not self.CurrentLootActor.IsLootInteraction then
            print("Not lootable yet, black list !"  )
            self.BlacklistActors[self.CurrentLootActor.Guid] = Pyx.Win32.GetTickCount() - 30 * 1000 -- Not lootable for now
            return false
        end
        
        if not self.BlacklistActors[self.CurrentLootActor.Guid] then
            self.BlacklistActors[self.CurrentLootActor.Guid] = Pyx.Win32.GetTickCount()
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
