-----------------------------------------------------------------------------
-- Variables
-----------------------------------------------------------------------------

BotSettings = {}
BotSettings.Visible = false

BotSettings.InventoryComboSelectedIndex = 0
BotSettings.InventorySelectedIndex = 0
BotSettings.InventoryName = {}

BotSettings.WarehouseComboSelectedIndex = 0
BotSettings.WarehouseSelectedIndex = 0
BotSettings.WarehouseName = {}

BotSettings.DontPullComboSelectedIndex = 0
BotSettings.MonsterNames = { }
BotSettings.DontPullSelectedIndex = 0

BotSettings.TurninComboSelectedIndex = 0
BotSettings.TurninSelectedIndex = 0
BotSettings.TurninName = { }
BotSettings.TurninName = { }

BotSettings.IgnoreBodyComboSelectedIndex = 0
BotSettings.DeleteIgnoreBodyIndex = 0

-----------------------------------------------------------------------------
-- BotSettings Functions
-----------------------------------------------------------------------------

function BotSettings.DrawBotSettings()
	local valueChanged = false

	if BotSettings.Visible then

		_, BotSettings.Visible = ImGui.Begin("Settings", BotSettings.Visible, ImVec2(400, 400), -1.0)
		if ImGui.Button("Save settings", ImVec2(ImGui.GetContentRegionAvailWidth() / 2, 20)) then
			Bot.SaveSettings()
			print("Settings saved")
		end
		ImGui.SameLine()
		if ImGui.Button("Load settings", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
			Bot.LoadSettings()
			print("Settings loaded")
		end

		ImGui.Spacing()

		ImGui.Columns(1)
		ImGui.Spacing()

		    if ImGui.CollapsingHeader("Combat", "id_gui_combats", true, false) then
            BotSettings.UpdateMonsters()

            if not table.find(BotSettings.AvailablesCombats, Bot.Settings.CombatName) then
                table.insert(BotSettings.AvailablesCombats, Bot.Settings.CombatName)
            end
            valueChanged, BotSettings.CombatsComboBoxSelected = ImGui.Combo("Combat script##id_gui_combat_script", table.findIndex(BotSettings.AvailablesCombats, Bot.Settings.CombatScript), BotSettings.AvailablesCombats)
            if valueChanged then
                Bot.Settings.CombatScript = BotSettings.AvailablesCombats[BotSettings.CombatsComboBoxSelected]
                print("Combat script selected : " .. Bot.Settings.CombatScript)
                Bot.LoadCombat()
            end
			   if Bot.Combat ~=nil and Bot.Combat.Gui then
            if Bot.Combat.Gui.ShowGui then
                if ImGui.Button("Close Rotation Settings", ImVec2(ImGui.GetContentRegionAvailWidth() / 2, 20)) then
                    Bot.Combat.Gui.ShowGui = false
                end
            else
                if ImGui.Button("Open Rotation Settings", ImVec2(ImGui.GetContentRegionAvailWidth() / 2, 20)) then
                    Bot.Combat.Gui.ShowGui = true
                end
            end
            ImGui.SameLine()
            if ImGui.Button("Save Rotation Settings", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
                BotSettings.SaveCombatSettings()
            end
        end
           _, Bot.Settings.AttackPvpFlagged = ImGui.Checkbox("Attack Pvp Flagged Players##id_guid_combat_attack_pvp", Bot.Settings.AttackPvpFlagged)
		   _, Bot.Settings.PullSettings.SkipPullPlayer = ImGui.Checkbox("Skip pull if player in range##id_guid_combat_skip_pullplayer", Bot.Settings.PullSettings.SkipPullPlayer)

            valueChanged, BotSettings.DontPullComboSelectedIndex = ImGui.Combo("Don't Pull##id_guid_dont_pull_combo_select", BotSettings.DontPullComboSelectedIndex, BotSettings.MonsterNames)
            if valueChanged then
                local monsterName = BotSettings.MonsterNames[BotSettings.DontPullComboSelectedIndex]
                if not table.find(Bot.Settings.PullSettings.DontPull, monsterName) then

                    table.insert(Bot.Settings.PullSettings.DontPull, monsterName)
                end
                BotSettings.DontPullComboSelectedIndex = 0
            end
            _, BotSettings.DontPullSelectedIndex = ImGui.ListBox("##id_guid_spull_Delete", BotSettings.DontPullSelectedIndex,Bot.Settings.PullSettings.DontPull, 5)
            if ImGui.Button("Remove Item##id_guid_combat_delete_remove", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
                if BotSettings.DontPullSelectedIndex > 0 and BotSettings.DontPullSelectedIndex <= table.length(Bot.Settings.PullSettings.DontPull) then
                    table.remove(Bot.Settings.PullSettings.DontPull, BotSettings.DontPullSelectedIndex)
                    BotSettings.DontPullSelectedIndex = 0
                end
            end

        end


		if ImGui.CollapsingHeader("Looting", "id_gui_looting", true, false) then
			BotSettings.UpdateInventoryList()
            _, Bot.Settings.LootSettings.TakeLoot = ImGui.Checkbox("Take loots##id_guid_looting_take_loot", Bot.Settings.LootSettings.TakeLoot)
			_, Bot.Settings.LootSettings.SkipLootPlayer = ImGui.Checkbox("Skip loot if player in range##id_guid_looting_IgnorePlayers", Bot.Settings.LootSettings.SkipLootPlayer)
			_, Bot.Settings.LootSettings.CombatLoot = ImGui.Checkbox("Loot while in Combat##id_guid_looting_combat", Bot.Settings.LootSettings.CombatLoot)
			_, Bot.Settings.LootSettings.LogLoot = ImGui.Checkbox("Log loot##id_guid_looting_log_loot", Bot.Settings.LootSettings.LogLoot)


            ImGui.Text("Always Delete these Items")
            valueChanged, BotSettings.InventoryComboSelectedIndex = ImGui.Combo("##id_guid_inv_inventory_combo_select", BotSettings.InventoryComboSelectedIndex, BotSettings.InventoryName)
            if valueChanged then
                local inventoryName = BotSettings.InventoryName[BotSettings.InventoryComboSelectedIndex]
                if not table.find(Bot.Settings.InventoryDeleteSettings.DeleteItems, inventoryName) then

                    table.insert(Bot.Settings.InventoryDeleteSettings.DeleteItems, inventoryName)
                end
                BotSettings.InventoryComboSelectedIndex = 0
            end
            _, BotSettings.InventorySelectedIndex = ImGui.ListBox("##id_guid_inv_Delete", BotSettings.InventorySelectedIndex, Bot.Settings.InventoryDeleteSettings.DeleteItems, 5)
            if ImGui.Button("Remove Item##id_guid_inv_delete_remove", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
                if BotSettings.InventorySelectedIndex > 0 and BotSettings.InventorySelectedIndex <= table.length(Bot.Settings.InventoryDeleteSettings.DeleteItems) then
                    table.remove(Bot.Settings.InventoryDeleteSettings.DeleteItems, BotSettings.InventorySelectedIndex)
                    BotSettings.InventorySelectedIndex = 0
                end
            end

            ImGui.Text("Do not loot these bodies")
            BotSettings.UpdateMonsters()
            valueChanged, BotSettings.IgnoreBodyComboSelectedIndex = ImGui.Combo("##id_guid_ignore_body_combo_select", BotSettings.IgnoreBodyComboSelectedIndex, BotSettings.MonsterNames)
            if valueChanged and BotSettings.IgnoreBodyComboSelectedIndex > 0 then
                local monsterName = BotSettings.MonsterNames[BotSettings.IgnoreBodyComboSelectedIndex]
                Bot.Settings.LootSettings.IgnoreBodyName[monsterName] = true
                BotSettings.IgnoreBodyComboSelectedIndex = 0
            end

            local ignoreBodyList = {}
            for k,v in pairs(Bot.Settings.LootSettings.IgnoreBodyName) do
            	table.insert(ignoreBodyList, k)
        	end
        	table.sort(ignoreBodyList)

            _, BotSettings.DeleteIgnoreBodyIndex = ImGui.ListBox("##id_guid_delete_ignore_body", BotSettings.DeleteIgnoreBodyIndex, ignoreBodyList, 5)
            if ImGui.Button("Remove Body##id_guid_remove_ignore_body", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
                if BotSettings.DeleteIgnoreBodyIndex > 0 then
                	local name = ignoreBodyList[BotSettings.DeleteIgnoreBodyIndex]
                	Bot.Settings.LootSettings.IgnoreBodyName[name] = nil
                	BotSettings.DeleteIgnoreBodyIndex = 0
            	end
            end
        end


		if ImGui.CollapsingHeader("NPCs options", "id_gui_npc_option", true, false) then
				BotSettings.UpdateInventoryList()

				ImGui.Columns(2)
				_, Bot.Settings.WarehouseSettings.Enabled = ImGui.Checkbox("##id_gui_npc_option_enable_warehouse", Bot.Settings.WarehouseSettings.Enabled)
				ImGui.SameLine()
				ImGui.Text("Enable Warehouse")
				_, Bot.Settings.TurninSettings.Enabled = ImGui.Checkbox("##id_gui_npc_option_enable_exchange", Bot.Settings.TurninSettings.Enabled)
				ImGui.SameLine()
				ImGui.Text("Enable Exchange")
				ImGui.NextColumn()
				_, Bot.Settings.VendorSettings.Enabled = ImGui.Checkbox("##id_gui_npc_option_enable_vendor", Bot.Settings.VendorSettings.Enabled)
				ImGui.SameLine()
				ImGui.Text("Enable Vendor")
				_, Bot.Settings.RepairSettings.Enabled = ImGui.Checkbox("##id_gui_npc_option_enable_repair", Bot.Settings.RepairSettings.Enabled)
				ImGui.SameLine()
				ImGui.Text("Enable Repair")
				ImGui.Columns(1)

				ImGui.Separator()

				if Bot.Settings.WarehouseSettings.Enabled then
					if ImGui.TreeNode("Warehouse") then
					_, Bot.Settings.WarehouseAfterVendor = ImGui.Checkbox("Warehouse after Vendor##id_guid_warehouse_after_vendor", Bot.Settings.WarehouseAfterVendor)
						-- if ImGui.RadioButton("Deposit after Vendor##id_guid_warehouse_after_vendor", Bot.Settings.WarehouseSettings.DepositMethod == WarehouseState.SETTINGS_ON_DEPOSIT_AFTER_VENDOR) then
							-- Bot.Settings.WarehouseSettings.DepositMethod = WarehouseState.SETTINGS_ON_DEPOSIT_AFTER_VENDOR
						-- end
						-- if ImGui.RadioButton("Deposit after Trader##id_guid_warehouse_after_trader", Bot.Settings.WarehouseSettings.DepositMethod == WarehouseState.SETTINGS_ON_DEPOSIT_AFTER_TRADER) then
							-- Bot.Settings.WarehouseSettings.DepositMethod = WarehouseState.SETTINGS_ON_DEPOSIT_AFTER_TRADER
						-- end
						-- if ImGui.RadioButton("Deposit after Repair##id_guid_warehouse_repair_after_trader", Bot.Settings.WarehouseSettings.DepositMethod == WarehouseState.SETTINGS_ON_DEPOSIT_AFTER_REPAIR) then
							-- Bot.Settings.WarehouseSettings.DepositMethod = WarehouseState.SETTINGS_ON_DEPOSIT_AFTER_REPAIR
						-- end
						 _, Bot.Settings.WarehouseSettings.ExchangeGold = ImGui.Checkbox("Exchange Money for Gold##id_guid_warehouse_exchange_money", Bot.Settings.WarehouseSettings.ExchangeGold)

						_, Bot.Settings.WarehouseSettings.DepositMoney = ImGui.Checkbox("##id_guid_warehouse_deposit_money", Bot.Settings.WarehouseSettings.DepositMoney)
						ImGui.SameLine()
						ImGui.Text("Deposit money")

						ImGui.Spacing()

						ImGui.Text("Money to keep")
						ImGui.SameLine()
						_, Bot.Settings.WarehouseSettings.MoneyToKeep = ImGui.SliderInt("##id_gui_warehouse_keep_money", Bot.Settings.WarehouseSettings.MoneyToKeep, 0, 1000000)

						_, Bot.Settings.WarehouseSettings.DepositItems = ImGui.Checkbox("##id_guid_warehouse_deposit_items", Bot.Settings.WarehouseSettings.DepositItems)
						ImGui.SameLine()
						ImGui.Text("Deposit items")

						ImGui.Spacing()

						ImGui.Text("Never deposit these items")
						valueChanged, BotSettings.WarehouseComboSelectedIndex = ImGui.Combo("##id_guid_warehouse_inventory_combo_select", BotSettings.WarehouseComboSelectedIndex, BotSettings.InventoryName)
						if valueChanged then
							local inventoryName = BotSettings.InventoryName[BotSettings.WarehouseComboSelectedIndex]

							if not table.find(Bot.Settings.WarehouseSettings.IgnoreItemsNamed, inventoryName) then
								table.insert(Bot.Settings.WarehouseSettings.IgnoreItemsNamed, inventoryName)
							end

							BotSettings.WarehouseComboSelectedIndex = 0
						end

						_, BotSettings.WarehouseSelectedIndex = ImGui.ListBox("##id_guid_warehouse_neverdeposit", BotSettings.WarehouseSelectedIndex, Bot.Settings.WarehouseSettings.IgnoreItemsNamed, 5)
						if ImGui.Button("Remove Item##id_guid_warehouse_neverdeposit_remove", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
							if BotSettings.WarehouseSelectedIndex > 0 and BotSettings.WarehouseSelectedIndex <= table.length(Bot.Settings.WarehouseSettings.IgnoreItemsNamed) then
								table.remove(Bot.Settings.WarehouseSettings.IgnoreItemsNamed, BotSettings.WarehouseSelectedIndex)
								BotSettings.WarehouseSelectedIndex = 0
							end
						end
						ImGui.TreePop()
					end
				end

				if Bot.Settings.VendorSettings.Enabled then
					if ImGui.TreeNode("Vendor") then


						ImGui.Separator()
						_, Bot.Settings.VendorSettings.BuyEnabled = ImGui.Checkbox("Enable Buying", Bot.Settings.VendorSettings.BuyEnabled)
						ImGui.Separator()
						if Bot.Settings.VendorSettings.BuyEnabled then
							ImGui.Columns(1)
							ImGui.Text("Select item")
							ImGui.SameLine()
							valueChanged, BotSettings.InventoryComboSelectedIndex = ImGui.Combo("##id_guid_vendor_buy_combo_select", BotSettings.InventoryComboSelectedIndex, BotSettings.InventoryName)
							if valueChanged then
								local inventoryName = BotSettings.InventoryName[BotSettings.InventoryComboSelectedIndex]
								local found = false

								for key, value in pairs(Bot.VendorState.Settings.BuyItems) do
									if value.Name == inventoryName then
										found = true
									end
								end

								if not found then
									table.insert(Bot.VendorState.Settings.BuyItems, { Name = inventoryName, BuyAt = 0, BuyMax = 1 })
								end

								BotSettings.InventoryComboSelectedIndex = 0
							end

							ImGui.Columns(3)
							ImGui.Text("Name")
							ImGui.NextColumn()
							ImGui.Text("Buy at")
							ImGui.NextColumn()
							ImGui.Text("Total")
							ImGui.NextColumn()
							local count = table.length(Bot.VendorState.Settings.BuyItems)
							for key = 1, count do
								local value = Bot.VendorState.Settings.BuyItems[key]
								local erase = false

								if ImGui.SmallButton("x##id_guid_vendor_buy_del_items" .. key) then
									erase = true
								end

								ImGui.SameLine()

								if value ~= nil then
									ImGui.Text(value.Name)
									ImGui.NextColumn()
--									ImGui.PushItemWidth(90)
									valueChanged, Bot.VendorState.Settings.BuyItems[key].BuyAt = ImGui.InputFloat("Min##id_guid_vendor_buy_min_items" .. key, Bot.VendorState.Settings.BuyItems[key].BuyAt, 1,10,0,0)
									if valueChanged then
										if Bot.VendorState.Settings.BuyItems[key].BuyAt < 0 then
											Bot.VendorState.Settings.BuyItems[key].BuyAt = 0
										end

										if Bot.VendorState.Settings.BuyItems[key].BuyAt > 100 then
											Bot.VendorState.Settings.BuyItems[key].BuyAt = 100
										end
									end
									ImGui.NextColumn()
--									ImGui.PushItemWidth(90)
									valueChanged, Bot.VendorState.Settings.BuyItems[key].BuyMax = ImGui.InputFloat("Max##id_guid_vendor_buy_max_items" .. key, Bot.VendorState.Settings.BuyItems[key].BuyMax, 1,10,0,0)
									if valueChanged then
										if Bot.VendorState.Settings.BuyItems[key].BuyMax < 1 then
											Bot.VendorState.Settings.BuyItems[key].BuyMax = 1
										end

										if Bot.VendorState.Settings.BuyItems[key].BuyMax > 500 then
											Bot.VendorState.Settings.BuyItems[key].BuyMax = 500
										end
									end
									ImGui.NextColumn()

									if erase then
										table.remove(Bot.VendorState.Settings.BuyItems,key)
										count = count -1
									end
								end
							end

--							ImGui.Spacing()
						end
						ImGui.Columns(1)

						ImGui.Separator()
						_, Bot.Settings.VendorSettings.SellEnabled = ImGui.Checkbox("Enable Selling", Bot.Settings.VendorSettings.SellEnabled)
						ImGui.Separator()
						if Bot.Settings.VendorSettings.SellEnabled then
							_, Bot.Settings.VendorSettings.VendorOnInventoryFull = ImGui.Checkbox("##id_guid_vendor_sell_full_inventory", Bot.Settings.VendorSettings.VendorOnInventoryFull)
							ImGui.SameLine()
							ImGui.Text("Go to Vendor when inventory is full")

							_, Bot.Settings.VendorSettings.VendorOnWeight = ImGui.Checkbox("##id_guid_vendor_sell_weight", Bot.Settings.VendorSettings.VendorOnWeight)
							ImGui.SameLine()
							ImGui.Text("Sell to Vendor when you are too heavy")

							_, Bot.Settings.VendorSettings.VendorWhite = ImGui.Checkbox("##id_guid_vendor_sell_white", Bot.Settings.VendorSettings.VendorWhite)
							ImGui.SameLine()
							ImGui.TextColored(ImVec4(1,1,1,1), "Sell white")
							ImGui.SameLine()
							_, Bot.Settings.VendorSettings.VendorGreen = ImGui.Checkbox("##id_guid_vendor_sell_green", Bot.Settings.VendorSettings.VendorGreen)
							ImGui.SameLine()
							ImGui.TextColored(ImVec4(0.2,1,0.2,1), "Sell green")
							ImGui.SameLine()
							_, Bot.Settings.VendorSettings.VendorBlue = ImGui.Checkbox("##id_guid_vendor_sell_blue", Bot.Settings.VendorSettings.VendorBlue)
							ImGui.SameLine()
							ImGui.TextColored(ImVec4(0.4,0.6,1,1), "Sell blue")

							ImGui.Spacing()

							ImGui.Text("Items ignored")
							valueChanged, BotSettings.InventoryComboSelectedIndex = ImGui.Combo("##id_guid_vendor_ignore_items", BotSettings.InventoryComboSelectedIndex, BotSettings.InventoryName)
							if valueChanged then
								local inventoryName = BotSettings.InventoryName[BotSettings.InventoryComboSelectedIndex]
								if not table.find(Bot.Settings.VendorSettings.IgnoreItemsNamed, inventoryName) then
									table.insert(Bot.Settings.VendorSettings.IgnoreItemsNamed, inventoryName)
								end

								BotSettings.InventoryComboSelectedIndex = 0
							end

							_, BotSettings.InventorySelectedIndex = ImGui.ListBox("##id_guid_vendor_neversell", BotSettings.InventorySelectedIndex, Bot.Settings.VendorSettings.IgnoreItemsNamed, 5)
							if ImGui.Button("Remove Item##id_guid_vendor_neversell_remove", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
								if BotSettings.InventorySelectedIndex > 0 and BotSettings.InventorySelectedIndex <= table.length(Bot.Settings.VendorSettings.IgnoreItemsNamed) then
									table.remove(Bot.Settings.VendorSettings.IgnoreItemsNamed, BotSettings.InventorySelectedIndex)
									BotSettings.InventorySelectedIndex = 0
								end
							end
						end
						ImGui.TreePop()
					end
				end

				if Bot.Settings.RepairSettings.Enabled then
					if ImGui.TreeNode("Repair") then
						-- if ImGui.RadioButton("Repair after Warehouse##id_guid_repair_after_warehouse", Bot.Settings.RepairSettings.RepairMethod == RepairState.SETTINGS_ON_REPAIR_AFTER_WAREHOUSE) then
							-- Bot.Settings.RepairSettings.RepairMethod = RepairState.SETTINGS_ON_REPAIR_AFTER_WAREHOUSE
						-- end
						_, Bot.Settings.RepairAfterWarehouse = ImGui.Checkbox("Repair after Warehouse##id_guid_repair_after_warehouse", Bot.Settings.RepairAfterWarehouse)
						_, Bot.Settings.RepairSettings.UseWarehouseMoney = ImGui.Checkbox("Use Warehouse Money", Bot.Settings.RepairSettings.UseWarehouseMoney)
						ImGui.TreePop()
					end
				end
						ImGui.Columns(1)

				if Bot.Settings.TurninSettings.Enabled then

					if ImGui.TreeNode("Exchange") then
					_, Bot.Settings.TurninSettings.TurninCount = ImGui.SliderInt("Amount needed##id_gui_turnin_count", Bot.Settings.TurninSettings.TurninCount, 30, 1500)
					_, Bot.Settings.VendorAfterTurnin = ImGui.Checkbox("Vendor after Exchange##id_guid_vendor_after_turnin", Bot.Settings.VendorAfterTurnin)
					_, Bot.Settings.TurninSettings.TurninOnWeight = ImGui.Checkbox("Exchange when too heavy##id_guid_vendor_weight", Bot.Settings.TurninSettings.TurninOnWeight)
					ImGui.Text("Try to Exchange these Items")
					valueChanged, BotSettings.TurninComboSelectedIndex = ImGui.Combo("##id_guid_turnin_inventory_combo_select", BotSettings.TurninComboSelectedIndex, BotSettings.InventoryName)
					if valueChanged then
						local inventoryName = BotSettings.InventoryName[BotSettings.TurninComboSelectedIndex]
						if not table.find(Bot.Settings.TurninSettings.TurninItemsNamed, inventoryName) then
							table.insert(Bot.Settings.TurninSettings.TurninItemsNamed, inventoryName)
							end
							BotSettings.TurninComboSelectedIndex = 0
						end
						_, BotSettings.TurninSelectedIndex = ImGui.ListBox("##id_guid_turnin_items", BotSettings.TurninSelectedIndex, Bot.Settings.TurninSettings.TurninItemsNamed, 5)
						if ImGui.Button("Remove Item##id_guid_turnin_neverdeposit_remove", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
							if BotSettings.TurninSelectedIndex > 0 and BotSettings.TurninSelectedIndex <= table.length(Bot.Settings.TurninSettings.TurninItemsNamed) then
								table.remove(Bot.Settings.TurninSettings.TurninItemsNamed, BotSettings.TurninSelectedIndex)
								BotSettings.TurninSelectedIndex = 0
							end
						end
					end
			end
		end
						ImGui.Columns(1)

		if ImGui.CollapsingHeader("Death action", "id_gui_death_action", true, false) then
			if ImGui.RadioButton("Stop bot##id_guid_death_action_stop_bot", Bot.Settings.DeathSettings.ReviveMethod == DeathState.SETTINGS_ON_DEATH_ONLY_CALL_WHEN_COMPLETED) then
				Bot.Settings.DeathSettings.ReviveMethod = DeathState.SETTINGS_ON_DEATH_ONLY_CALL_WHEN_COMPLETED
			end
			if ImGui.RadioButton("Revive at nearest node##id_guid_death_action_revive_node", Bot.Settings.DeathSettings.ReviveMethod == DeathState.SETTINGS_ON_DEATH_REVIVE_NODE) then
				Bot.Settings.DeathSettings.ReviveMethod = DeathState.SETTINGS_ON_DEATH_REVIVE_NODE
			end
			if ImGui.RadioButton("Revive at nearest village##id_guid_death_action_revive_village", Bot.Settings.DeathSettings.ReviveMethod == DeathState.SETTINGS_ON_DEATH_REVIVE_VILLAGE) then
				Bot.Settings.DeathSettings.ReviveMethod = DeathState.SETTINGS_ON_DEATH_REVIVE_VILLAGE
			end
		end

		if ImGui.CollapsingHeader("Security BETA/Experimental", "id_gui_Security", true, false) then
           _, Bot.Settings.SecuritySettings.PlayerDetection = ImGui.Checkbox("Player Detection##id_guid_security_player_detection", Bot.Settings.SecuritySettings.PlayerDetection)
           _, Bot.Settings.SecuritySettings.PlayerRange = ImGui.SliderInt("Player Detection Radius##id_guid_security_player_detection_radius", Bot.Settings.SecuritySettings.PlayerRange, 500, 5000)
           _, Bot.Settings.SecuritySettings.PlayerTimeAlarmSeconds = ImGui.SliderInt("Seconds in range until alarm##id_guid_security_player_detection_alarmsecs", Bot.Settings.SecuritySettings.PlayerTimeAlarmSeconds, 1, 30)
           _, Bot.Settings.SecuritySettings.PlayerRemoveAfterSeconds = ImGui.SliderInt("Seconds out of range until forget##id_guid_security_player_detection_forgetsecs", Bot.Settings.SecuritySettings.PlayerRemoveAfterSeconds, 1, 120)
--           _, Bot.Settings.SecurityPlayerChangeChannel = ImGui.Checkbox("Change Channel##id_guid_security_player_detection_changechannel", Bot.Settings.SecurityPlayerChangeChannel)
           _, Bot.Settings.SecurityPlayerMakeSound = ImGui.Checkbox("Make Sound##id_guid_security_player_detection_makesound", Bot.Settings.SecurityPlayerMakeSound)
           _, Bot.Settings.SecurityPlayerChangeHotSpot = ImGui.Checkbox("Change Hotspot##id_guid_security_player_detection_changehspot", Bot.Settings.SecurityPlayerChangeHotSpot)
           _, Bot.Settings.SecurityPlayerGoVendor = ImGui.Checkbox("Go Vendor##id_guid_security_player_detection_govendor", Bot.Settings.SecurityPlayerGoVendor)
           _, Bot.Settings.SecurityPlayerStopBot = ImGui.Checkbox("Stop Bot##id_guid_security_player_detection_stopbot", Bot.Settings.SecurityPlayerStopBot)
           ImGui.Text("")
           _, Bot.Settings.SecuritySettings.TeleportDetection = ImGui.Checkbox("Teleport Detection##id_guid_security_teleport_detection", Bot.Settings.SecuritySettings.TeleportDetection)
           _, Bot.Settings.SecuritySettings.TeleportDistance = ImGui.SliderInt("Min Teleport Distance##id_guid_security_teleport_detection_distance", Bot.Settings.SecuritySettings.TeleportDistance, 100, 1000)
           _, Bot.Settings.SecurityTeleportMakeSound = ImGui.Checkbox("Make Sound##id_guid_security_teleport_detection_makesound", Bot.Settings.SecurityTeleportMakeSound)
           _, Bot.Settings.SecurityTeleportStopBot = ImGui.Checkbox("Stop Bot##id_guid_security_teleport_detection_stopbot", Bot.Settings.SecurityTeleportStopBot)
           _, Bot.Settings.SecurityTeleportKillGame = ImGui.Checkbox("Kill Game##id_guid_security_teleport_detection_killgame", Bot.Settings.SecurityTeleportKillGame)

    end


		ImGui.End()
	end
end

function BotSettings.UpdateInventoryList()
	local selfPlayer = GetSelfPlayer()

	if selfPlayer then
		for k,v in pairs(selfPlayer.Inventory.Items) do
			if not table.find(BotSettings.InventoryName, v.ItemEnchantStaticStatus.Name) then
				table.insert(BotSettings.InventoryName, v.ItemEnchantStaticStatus.Name)
			end
		end
	end
end

function BotSettings.UpdateMonsters()
    BotSettings.MonsterNames = { }
    local selfPlayer = GetSelfPlayer()
    if selfPlayer then
        for k, v in pairs(GetMonsters()) do

            if not table.find(BotSettings.MonsterNames, v.Name) then
                table.insert(BotSettings.MonsterNames, v.Name)
            end
        end
        table.sort(BotSettings.MonsterNames)
    end

end

function BotSettings.SaveCombatSettings()
    local json = JSON:new()
    local string = Bot.Settings.CombatScript
    local settings = string.gsub(string, ".lua", "")
    Pyx.FileSystem.WriteFile("Combats\\Configs\\"..settings..".json", json:encode_pretty(Bot.Combat.Gui))
end

function BotSettings.LoadCombatSettings()
    local json = JSON:new()
    local string = Bot.Settings.CombatScript
    local settings = string.gsub(string, ".lua", "")
    table.merge(Bot.Combat.Gui,json:decode(Pyx.FileSystem.ReadFile("Combats\\Configs\\"..settings..".json")))
end

function BotSettings.RefreshAvailableProfiles()
    BotSettings.AvailablesCombats = { }
    for k, v in pairs(Pyx.FileSystem.GetFiles("Combats\\*.lua")) do
        table.insert(BotSettings.AvailablesCombats, v)

    end
end

BotSettings.RefreshAvailableProfiles()

function BotSettings.OnDrawGuiCallback()
	BotSettings.DrawBotSettings()
end
