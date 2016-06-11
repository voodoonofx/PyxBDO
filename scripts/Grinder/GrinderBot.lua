Bot = { }
Bot.Settings = Settings()
Bot.Running = false
Bot.Fsm = FSM()
Bot.Combat = nil
Bot.CombatPull = nil
-- Converted to CommonStates
Bot.WarehouseState = WarehouseState()
Bot.TurninState = TurninState()
Bot.VendorState = VendorState()
Bot.DeathState = DeathState()
Bot.RepairState = RepairState()
Bot.LootState = LootActorState()
Bot.BuildNavigationState = BuildNavigationState()
Bot.InventoryDeleteState = InventoryDeleteState()
Bot.SecurityState = SecurityState()
Bot.RoamingState = RoamingState()
Bot.DoReset = false
Bot.PlayerAudioPause = PyxTimer:New(1.5)
Bot.PlayerChangeHotSpotPause = PyxTimer:New(60)

-- Not Converted yet
Bot.CombatFightState = CombatFightState()
Bot.CombatPullState = CombatPullState()

-- Bot.Fsm:AddState(RoamingState())
-- Bot.Fsm:AddState(IdleState())


function Bot.GetPlayers(onlyPvpFlagged)
    local actors = GetActors()
    local players = { }

    for key, value in pairs(actors) do
        if value.IsPlayer then
            if (onlyPvpFlagged == nil or onlyPvpFlagged == false) or(onlyPvpFlagged == true and value.IsPvpEnable == true) then
                players[#players] = value
            end

        end
    end
    return players
end

function Bot.LoadCombat()
    local combatScriptFile = Bot.Settings.CombatScript
    local code = Pyx.FileSystem.ReadFile("Combats/" .. combatScriptFile)
    combatScriptFunc, combatScriptError = load(code)
    if combatScriptFunc == nil then
        print(string.format("Unable to load combat script: func %s err %s", tostring(combatScriptFunc), tostring(combatScriptError)))
        return
    end
    Bot.Combat = combatScriptFunc()

    if not Bot.Combat then
        print("Unable to load combat script !")
        return
    end

    if not Bot.Combat.Attack then
        print("Combat script doesn't have .Attack function !")
        return
    end

    if Bot.Combat.Gui then
        MainWindow.LoadCombatSettings()
    end
end

function Bot.Start()
    if not Bot.Running then
        Bot.ResetStats()
        Bot.RepairState.Forced = false
        Bot.WarehouseState.Forced = false
        Bot.TurninState.Forced = false
        Bot.VendorState.Forced = false
        Bot.SaveSettings()

        local currentProfile = ProfileEditor.CurrentProfile

        if not currentProfile then
            print("No profile loaded !")
            return
        end

        if Bot.MeshDisabled ~= true and table.length(currentProfile:GetHotspots()) < 2 then
            print("Profile requires at least 2 hotspots !")
            return
        end
        if Bot.MeshDisabled == true then
            Navigator.RealMoveTo = Navigator.MoveTo
            Navigator.MoveTo = function(p)
                GetSelfPlayer():MoveTo(p)
            end
            Navigator.RealCanMoveTo = Navigator.CanMoveTo
            Navigator.CanMoveTo = function(p) return true end
        end

        ProfileEditor.MeshConnectEnabled = false
        Navigator.MeshConnects = ProfileEditor.CurrentProfile.MeshConnects

        Bot.WarehouseState:Reset()
        Bot.TurninState:Reset()
        Bot.VendorState:Reset()
        Bot.RepairState:Reset()
        Bot.DeathState:Reset()
        Bot.SecurityState:Reset()

        Bot.WarehouseState.Settings.NpcName = currentProfile.WarehouseNpcName
        Bot.WarehouseState.Settings.NpcPosition = currentProfile.WarehouseNpcPosition
        Bot.WarehouseState.CallWhenCompleted = Bot.StateComplete
        Bot.WarehouseState.CallWhileMoving = Bot.StateMoving

        Bot.TurninState.Settings.NpcName = currentProfile.TurninNpcName
        Bot.TurninState.Settings.NpcPosition = currentProfile.TurninNpcPosition
        Bot.TurninState.CallWhenCompleted = Bot.StateComplete
        Bot.TurninState.CallWhileMoving = Bot.StateMoving

        Bot.VendorState.Settings.NpcName = currentProfile.VendorNpcName
        Bot.VendorState.Settings.NpcPosition = currentProfile.VendorNpcPosition
        Bot.VendorState.CallWhenCompleted = Bot.StateComplete
        Bot.VendorState.CallWhileMoving = Bot.StateMoving

        Bot.DeathState.CallWhenCompleted = Bot.Death

        Bot.RepairState.Settings.NpcName = currentProfile.RepairNpcName
        Bot.RepairState.Settings.NpcPosition = currentProfile.RepairNpcPosition
        Bot.RepairState.CallWhileMoving = Bot.StateMoving

        Bot.LootState.CallWhileMoving = Bot.StateMoving

        Bot.SecurityState.PlayerDetectedFunction = Bot.PlayerAlarm
        Bot.SecurityState.TeleportDetectedFunction = Bot.TeleportAlarm

        if Bot.MeshDisabled ~= true then
            ProfileEditor.Visible = false
            Navigation.MesherEnabled = false
        end
        Navigator.OnStuckCall = Bot.OnStuck
        Bot.Fsm = FSM()
        Bot.Fsm.ShowOutput = true

        if Bot.MeshDisabled ~= true then
            Bot.Fsm:AddState(Bot.BuildNavigationState)
            Bot.Fsm:AddState(Bot.SecurityState)
            Bot.Fsm:AddState(Bot.DeathState)
            Bot.Fsm:AddState(LibConsumables.ConsumablesState)
            Bot.Fsm:AddState(Bot.CombatFightState)
            Bot.Fsm:AddState(Bot.TurninState)
            Bot.Fsm:AddState(Bot.VendorState)
            Bot.Fsm:AddState(Bot.WarehouseState)
            Bot.Fsm:AddState(Bot.RepairState)
            Bot.Fsm:AddState(Bot.LootState)
            Bot.Fsm:AddState(Bot.InventoryDeleteState)
            Bot.Fsm:AddState(Bot.CombatPullState)
            Bot.Fsm:AddState(Bot.RoamingState)
            Bot.Fsm:AddState(IdleState())
        else
            Bot.Fsm:AddState(Bot.DeathState)
            Bot.Fsm:AddState(PlayerPressState())
            Bot.Fsm:AddState(LibConsumables.ConsumablesState)
            Bot.Fsm:AddState(Bot.LootState)
            Bot.Fsm:AddState(Bot.CombatFightState)
            Bot.Fsm:AddState(Bot.InventoryDeleteState)
            Bot.Fsm:AddState(Bot.CombatPullState)
            Bot.Fsm:AddState(IdleState())
        end

        Bot.Running = true
    end
end

function Bot.Death(state)
    Bot.DoReset = true
    if Bot.DeathState.Settings.ReviveMethod == DeathState.SETTINGS_ON_DEATH_ONLY_CALL_WHEN_COMPLETED then
        Bot.Stop()
    else
        Bot.TurninState:Reset()
        Bot.WarehouseState:Reset()
        Bot.VendorState:Reset()
        Bot.RepairState:Reset()
        Bot.SecurityState:Reset()
        Bot.SecurityState.PauseTelerportDetectionTimer = PyxTimer:New(60)
    end
end

function Bot.Stop()
    Navigator.Stop(true)
    Bot.Running = false

    if Navigator.RealMoveTo ~= nil then
        Navigator.MoveTo = Navigator.RealMoveTo
        Navigator.RealMoveTo = nil

        Navigator.CanMoveTo = Navigator.RealCanMoveTo
        Navigator.RealCanMoveTo = nil
    end
end

function Bot.ResetStats()

end

function Bot.OnPulse()
    if Pyx.Input.IsGameForeground() then
        -- pause to start or stop bot
        if Pyx.Input.IsKeyDown(0x12) and Pyx.Input.IsKeyDown(string.byte('S')) then
            if Bot._startHotKeyPressed ~= true then
                Bot._startHotKeyPressed = true
                if Bot.Running then
                    print("stopping bot from hotkey")
                    Bot.Stop()
                else
                    print("starting bot from hotkey")
                    Bot.Start()
                end
            end
        else
            Bot._startHotKeyPressed = false
        end

        -- alt+F hotspot adding
        if Pyx.Input.IsKeyDown(0x12) and Pyx.Input.IsKeyDown(string.byte('F')) then
            if Bot._addHotKeyPressed ~= true then
                Bot._addHotKeyPressed = true
                print("Adding hotspot through hotkey")
                local selfPlayer = GetSelfPlayer()
                if selfPlayer then
                    local selfPlayerPosition = selfPlayer.Position
                    table.insert(ProfileEditor.CurrentProfile.Hotspots, { X = selfPlayerPosition.X, Y = selfPlayerPosition.Y, Z = selfPlayerPosition.Z })
                end
            end
        else
            Bot._addHotKeyPressed = false
        end
    end

    if Bot.Running then
        if Bot.DoReset == true then
            Bot.Fsm.Reset = true
            Navigator.Reset()
            Bot.DoReset = false
        end
        Bot.Fsm:Pulse()

        if Bot.VendorState.Forced == true or Bot.RepairState.Forced == true or Bot.WarehouseState.Forced == true or Bot.TurninState.Forced then
            Bot.CombatPullState.Enabled = false
        else
            Bot.CombatPullState.Enabled = true
        end
    end
end

function Bot.CallCombatAttack(monsterActor, isPull)
    if Bot.Combat and Bot.Combat.Attack then
        Bot.Combat:Attack(monsterActor, isPull)
    end
end

function Bot.CallCombatRoaming()
    if Bot.Combat and Bot.Combat.Roaming then
        Bot.Combat:Roaming()
    end
end

function Bot.CallGui()
    if Bot.Combat and Bot.Combat.UserInterface then
        Bot.Combat:UserInterface()
    end
end

function Bot.SaveSettings()
    local json = JSON:new()
    Pyx.FileSystem.WriteFile("Settings.json", json:encode_pretty(Bot.Settings))
end

function Bot.LoadSettings()
    local json = JSON:new()
    Bot.Settings = Settings()
    Bot.Settings.WarehouseSettings = Bot.WarehouseState.Settings
    Bot.Settings.TurninSettings = Bot.TurninState.Settings
    Bot.Settings.VendorSettings = Bot.VendorState.Settings
    Bot.Settings.DeathSettings = Bot.DeathState.Settings
    Bot.Settings.RepairSettings = Bot.RepairState.Settings
    Bot.Settings.LootSettings = Bot.LootState.Settings
    Bot.Settings.InventoryDeleteSettings = Bot.InventoryDeleteState.Settings
    Bot.Settings.LibConsumablesSettings = LibConsumables.Settings
    Bot.Settings.PullSettings = Bot.CombatPullState.Settings
    Bot.Settings.SecuritySettings = Bot.SecurityState.Settings

    table.merge(Bot.Settings, json:decode(Pyx.FileSystem.ReadFile("Settings.json")))
    if string.len(Bot.Settings.LastProfileName) > 0 then
        ProfileEditor.LoadProfile(Bot.Settings.LastProfileName)
    end
end

function Bot.StateMoving(state)
    Bot.CallCombatRoaming()
end


function Bot.OnStuck()
    if Navigator.StuckCount > 15 then
        print("We are too stuck try rescue")
        BDOLua.Execute("callRescue()")
        Bot.SecurityState.PauseTelerportDetectionTimer = PyxTimer:New(60)
    end
end

function Bot.PlayerAlarm()
    if (Bot.PlayerAudioPause:Expired() == true or Bot.PlayerAudioPause:IsRunning() == false) and Bot.Settings.SecurityPlayerMakeSound == true then
        print("Player Alarm: Play Noise")
        BDOLua.Execute("audioPostEvent_SystemUi(0,8)")
        Bot.PlayerAudioPause:Reset()
        Bot.PlayerAudioPause:Start()
    end

    if Bot.Settings.SecurityPlayerChangeChannel == true then

    end

    if (Bot.PlayerChangeHotSpotPause:Expired() or Bot.PlayerChangeHotSpotPause:IsRunning() == false) and Bot.Settings.SecurityPlayerChangeHotSpot == true then
        print("Player Alarm: Change Hotspot")
        Bot.RoamingState:ChangeHotSpot()
        Bot.PlayerChangeHotSpotPause:Reset()
        Bot.PlayerChangeHotSpotPause:Start()
    end

    if Bot.Settings.SecurityPlayerGoVendor == true then
        print("Player Alarm: Force Vendors")
        Bot.VendorState.Forced = true
        Bot.RepairState.Forced = true
        Bot.WarehouseState.Forced = true
    end


    if Bot.Settings.SecurityPlayerStopBot == true then
        print("Player Alarm: Stop Bot")
        Bot.Stop()
    end

    return false
end


function Bot.TeleportAlarm()

    if Bot.Settings.SecurityTeleportMakeSound == true then
        print("Teleport Alarm: Play Audio")
        BDOLua.Execute("audioPostEvent_SystemUi(0,8)")
    end

    if Bot.Settings.SecurityTeleportStopBot == true then
        print("Teleport Alarm: Stop Bot")
        Bot.Stop()
    end

    if Bot.Settings.SecurityTeleportKillGame == true then
        print("Teleport Alarm: Kill Process")
        Pyx.Win32.TerminateProcess()
    end

    return false
end

function Bot.StateComplete(state)

    if state == Bot.VendorState then
        if Bot.Settings.WarehouseAfterVendor == true then
            Bot.WarehouseState.Forced = true
        end
    end

    if state == Bot.TurninState then
        if Bot.Settings.VendorAfterTurnin == true then
            Bot.VendorState.Forced = true
        end
    end

    if state == Bot.WarehouseState then
        if Bot.Settings.RepairAfterWarehouse == true then
            Bot.RepairState.Forced = true
        end
    end

end


Bot.ResetStats()
