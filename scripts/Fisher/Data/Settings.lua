Settings = { }
Settings.__index = Settings

setmetatable(Settings, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function Settings.new()
  local self = setmetatable({}, Settings)
    
    self.LastProfileName = ""
    self.CombatScript = ""
    
   
    self.VendorafterTradeManager = true

    self.WarehouseAfterVendor = true
    self.WarehouseAfterTradeManager = true

    self.WarehouseSettings = {}
    self.VendorSettings = {}

    self.TradeManagerSettings = {}
    self.ConsumablesSettings = {}

    self.InventoryDeleteSettings = {}
    self.DeleteUsedRods = false

    self.IgnoreUntradeAbleItems = false
    self.RepairFishingRod = false

    self.LibConsumablesSettings = {}

    self.StartFishingSettings = {}
    self.HookFishHandleGameSettings = {}

    self.RepairSettings = {}
    self.DeathSettings = {}

    self.LootWhite = true
    self.LootGreen = true
    self.LootBlue = true
    self.LootKey = true
    self.LootRelic = true
    self.LootAndDeleteUnwantedFish = false    
    
  return self
end

