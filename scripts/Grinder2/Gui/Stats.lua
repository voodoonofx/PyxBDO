---------------------------------------------
-- Variables
---------------------------------------------

Stats = {}
Stats.Visible = false

SilverInitial = GetSelfPlayer().Inventory.Money
SilverGained = 0
KillIgnoreList = PyxTimedList:New()

---------------------------------------------
-- Stats Functions
---------------------------------------------

-- function Stats.DrawStats()
	-- Disabled for now.
	-- if Stats.Visible then
		-- _, Stats.Visible = ImGui.Begin("Stats", Stats.Visible, ImVec2(350, 260), -1.0, ImGuiWindowFlags_NoResize)

		-- if Bot.Stats.Loots > 0 then
			-- statsWhites = string.format("%i - %.02f%%%%", Bot.Stats.LootQuality[0] or 0, (Bot.Stats.LootQuality[0] or 0) / Bot.Stats.Loots * 100)
			-- statsGreens = string.format("%i - %.02f%%%%", Bot.Stats.LootQuality[1] or 0, (Bot.Stats.LootQuality[1] or 0) / Bot.Stats.Loots * 100)
			-- statsBlues = string.format("%i - %.02f%%%%", Bot.Stats.LootQuality[2] or 0, (Bot.Stats.LootQuality[2] or 0) / Bot.Stats.Loots * 100)
			-- statsGolds = string.format("%i - %.02f%%%%", Bot.Stats.LootQuality[3] or 0, (Bot.Stats.LootQuality[3] or 0) / Bot.Stats.Loots * 100)
			-- statsOranges = string.format("%i - %.02f%%%%", Bot.Stats.LootQuality[4] or 0, (Bot.Stats.LootQuality[4] or 0) / Bot.Stats.Loots * 100)
			-- statsFishes = string.format("%i - %.02f%%%%", Bot.Stats.Fishes, Bot.Stats.Fishes / Bot.Stats.Loots * 100)
			-- statsTrashes = string.format("%i - %.02f%%%%", Bot.Stats.Trashes, Bot.Stats.Trashes / Bot.Stats.Loots * 100)
			-- statsKeys = string.format("%i - %.02f%%%%", Bot.Stats.Keys, Bot.Stats.Keys / Bot.Stats.Loots * 100)
			-- statsShards = string.format("%i - %.02f%%%%", Bot.Stats.Shards, Bot.Stats.Shards / Bot.Stats.Loots * 100)
			-- statsEggs = string.format("%i - %.02f%%%%", Bot.Stats.Eggs, Bot.Stats.Eggs / Bot.Stats.Loots * 100)
		-- else
			-- statsWhites = "0 - 0.00%%"
			-- statsGreens = "0 - 0.00%%"
			-- statsBlues = "0 - 0.00%%"
			-- statsGolds = "0 - 0.00%%"
			-- statsOranges = "0 - 0.00%%"
			-- statsFishes = "0 - 0.00%%"
			-- statsTrashes = "0 - 0.00%%"
			-- statsKeys = "0 - 0.00%%"
			-- statsShards = "0 - 0.00%%"
			-- statsEggs = "0 - 0.00%%"
		-- end

		-- ImGui.Columns(3)
		-- ImGui.Text("Time " .. string.format("%02.f:%02.f:%02.f", Bot.Hours, Bot.Minutes, Bot.Seconds))
		-- ImGui.NextColumn()
		-- ImGui.Text("Loots: " .. string.format("%i", Bot.Stats.Loots))
		-- ImGui.NextColumn()
		-- ImGui.Text("Avg: " .. Bot.Stats.AverageLootTime .. "s")

		-- ImGui.Columns(1)
		-- ImGui.Separator()

		-- ImGui.Columns(1)
		-- ImGui.Text("Silver Gained: " .. Bot.FormatMoney(Bot.Stats.SilverGained))

		-- ImGui.Columns(1)
		-- ImGui.Separator()

		-- ImGui.Columns(2)
		-- ImGui.Text("Fishes: " .. statsFishes)
		-- ImGui.NextColumn()
		-- ImGui.Text("Trashes: " .. statsTrashes)

		-- ImGui.Columns(1)
		-- ImGui.Separator()

		-- ImGui.Columns(2)
		-- if Bot.Settings.LootSettings.LootKeys then
			-- ImGui.TextColored(ImVec4(0.2,1,0.2,1), "Keys: " .. statsKeys)
		-- else
			-- ImGui.TextColored(ImVec4(1,0.2,0.2,1), "Keys: " .. statsKeys)
		-- end
		-- ImGui.NextColumn()
		-- if Bot.Settings.LootSettings.LootShards then
			-- ImGui.TextColored(ImVec4(0.2,1,0.2,1), "Shards: " .. statsShards)
		-- else
			-- ImGui.TextColored(ImVec4(1,0.2,0.2,1), "Shards: " .. statsShards)
		-- end

		-- ImGui.Columns(1)
		-- ImGui.Separator()

		-- ImGui.Columns(1)
		-- if ImGui.CollapsingHeader("Fish quality", "id_gui_loot_quality", true, false) then
			-- ImGui.Columns(2)
			-- if Bot.Settings.LootSettings.LootWhite then
				-- ImGui.TextColored(ImVec4(0.2,1,0.2,1), "Whites: " .. statsWhites)
			-- else
				-- ImGui.TextColored(ImVec4(1,0.2,0.2,1), "Whites: " .. statsWhites)
			-- end
			-- ImGui.NextColumn()
			-- if Bot.Settings.LootSettings.LootGreen then
				-- ImGui.TextColored(ImVec4(0.2,1,0.2,1), "Greens: " .. statsGreens)
			-- else
				-- ImGui.TextColored(ImVec4(1,0.2,0.2,1), "Greens: " .. statsGreens)
			-- end

			-- ImGui.Columns(1)
			-- ImGui.Separator()

			-- ImGui.Columns(2)
			-- if Bot.Settings.LootSettings.LootBlue then
				-- ImGui.TextColored(ImVec4(0.2,1,0.2,1), "Blues: " .. statsBlues)
			-- else
				-- ImGui.TextColored(ImVec4(1,0.2,0.2,1), "Blues: " .. statsBlues)
			-- end
			-- ImGui.NextColumn()
			-- if Bot.Settings.LootSettings.LootGold then
				-- ImGui.TextColored(ImVec4(0.2,1,0.2,1), "Golds: " .. statsGolds)
			-- else
				-- ImGui.TextColored(ImVec4(1,0.2,0.2,1), "Golds: " .. statsGolds)
			-- end

			-- ImGui.Columns(1)
			-- ImGui.Separator()

			-- ImGui.Columns(1)
			-- if Bot.Settings.LootSettings.LootOrange then
				-- ImGui.TextColored(ImVec4(0.2,1,0.2,1), "Oranges: " .. statsOranges)
			-- else
				-- ImGui.TextColored(ImVec4(1,0.2,0.2,1), "Oranges: " .. statsOranges)
			-- end

			-- ImGui.Columns(1)
			-- ImGui.Separator()
		-- end

		-- ImGui.Columns(1)
		-- ImGui.Spacing()

		-- if ImGui.Button("Reset Stats##id_guid_reset_stats", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
			-- Bot.ResetStats()
		-- end

		-- ImGui.End()
	-- end
-- end

function Stats.GetKills()
	if PulseTimer == nil or PulseTimer:Expired() then
            PulseTimer = PyxTimer:New(0.5)
            PulseTimer:Start()
	table.sort(GetMonsters(), function(a,b) return a.Position.Distance3DFromMe < b.Position.Distance3DFromMe end)
        for k,v in pairs(GetMonsters()) do
            if v.IsMonster and not v.IsAlive and not KillIgnoreList:Contains(v.Key) and math.floor(v.Position.Distance3DFromMe) < 2900
            then
                Bot.Stats.KillCount = Bot.Stats.KillCount + 1
				KillIgnoreList:Add(v.Key, 60)
				else
				if v.IsMonster and not v.IsAlive and not KillIgnoreList:Contains(v.Key) and math.floor(v.Position.Distance3DFromMe) >= 2900 then
				KillIgnoreList:Add(v.Key, 60)
				end
            end
        end 
	end
	return KillCount
	end

function Stats.OnDrawGuiCallback()
	-- Stats.DrawStats()
end