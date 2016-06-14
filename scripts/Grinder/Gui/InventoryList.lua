---------------------------------------------
-- Variables
---------------------------------------------

InventoryList = {}
InventoryList.Visible = false

ShowDurability = false
ShowDurabilityColor = false

---------------------------------------------
-- InventoryList Functions
---------------------------------------------

function InventoryList.DrawInventoryList()
	if InventoryList.Visible then
		_, InventoryList.Visible = ImGui.Begin("Inventory list", InventoryList.Visible, ImVec2(500, 400), -1.0, ImGuiWindowFlags_MenuBar)
		local selfPlayer = GetSelfPlayer()

		if ImGui.BeginMenuBar() then
			if ImGui.BeginMenu("Options") then
				if ImGui.MenuItem("Show durability next to name", "", ShowDurability) then
					if ShowDurability then
						ShowDurability = false
					else
						ShowDurability = true
					end
				end
				if ImGui.MenuItem("Change name color based on durability", "", ShowDurabilityColor) then
					if ShowDurabilityColor then
						ShowDurabilityColor = false
					else
						ShowDurabilityColor = true
					end
				end
			    ImGui.EndMenu()
			end
			ImGui.EndMenuBar()
		end

		if selfPlayer then
			ImGui.Columns(2)
			ImGui.Separator()
			ImGui.Text("Item Name")
			ImGui.NextColumn()
			ImGui.Text("Details")
			ImGui.NextColumn()
			ImGui.Separator()

			for k,v in pairs(selfPlayer.Inventory.Items) do
				if v.ItemEnchantStaticStatus.Type == 2 then -- consumanble
					if ImGui.Button("Use" .. tostring(v.InventoryIndex)) then
						v:UseItem()
					end
					ImGui.SameLine()
				end

				if v.ItemEnchantStaticStatus.Type == 1 then
					local item = nil

					if ShowDurability then
						item = v.ItemEnchantStaticStatus.Name .. " " .. v.Endurance .. "/" .. v.MaxEndurance
					else
						item = v.ItemEnchantStaticStatus.Name
					end

					if ImGui.Button("Equip" .. tostring(v.InventoryIndex)) then
						v:UseItem()
					end
					ImGui.SameLine()

					if ShowDurabilityColor then
						if (v.Endurance == v.MaxEndurance) or v.EndurancePercent == 100 then
							ImGui.TextColored(ImVec4(0.2,1,0.2,1), item) -- green
						elseif (v.EndurancePercent > 50 and v.EndurancePercent < 100) then
							ImGui.TextColored(ImVec4(1,0.5,0.5,1), item) -- yellow
						elseif (v.EndurancePercent > 0 and v.EndurancePercent <= 50) then
							ImGui.TextColored(ImVec4(1,0.8,0.5,1), item) -- orange
						elseif v.Endurance == 0 then
							ImGui.TextColored(ImVec4(1,0.2,0.2,1), "[Broken] " .. item) -- red
						end
					else
						ImGui.Text(item)
					end
				else
					ImGui.Text(v.ItemEnchantStaticStatus.Name)
				end

				if v.ItemEnchantStaticStatus.Type == 2 or
					v.ItemEnchantStaticStatus.ItemId == 44164 or -- bronze keys
					v.ItemEnchantStaticStatus.ItemId == 44165 or -- silver keys
					v.ItemEnchantStaticStatus.ItemId == 44166	 -- gold keys
				then
					ImGui.SameLine()
					ImGui.Text("x" .. v.Count)
				end
				ImGui.NextColumn()

				if ImGui.CollapsingHeader("More info##id_guid_inv_list_detail", tostring(v.InventoryIndex)) then
					if Bot.EnableDebug and Bot.EnableDebugInventory then
						ImGui.Text("ItemId :")
						ImGui.SameLine();
						ImGui.Text(v.ItemEnchantStaticStatus.ItemId)

						ImGui.Text("Count:") -- quantity
						ImGui.SameLine()
						ImGui.Text(v.Count)

						ImGui.Text("Type:") -- category
						ImGui.SameLine()
						ImGui.Text(v.ItemEnchantStaticStatus.Type)

						ImGui.Text("Classify:")
						ImGui.SameLine();
						ImGui.Text(v.ItemEnchantStaticStatus.Classify)

						ImGui.Text("Grade:") -- quality
						ImGui.SameLine()
						ImGui.Text(v.ItemEnchantStaticStatus.Grade)

						ImGui.Text("Endurance:") -- durability
						ImGui.SameLine()
						ImGui.Text(v.Endurance .. "/" .. v.MaxEndurance)

						ImGui.Text("IsFishingRod :")
						ImGui.SameLine();
						ImGui.Text(tostring(v.ItemEnchantStaticStatus.IsFishingRod))

						ImGui.Text("IsTradeAble") -- can be sold to trader
						ImGui.SameLine()
						ImGui.Text(tostring(v.ItemEnchantStaticStatus.IsTradeAble))

						ImGui.Text("CommerceType :")
						ImGui.SameLine();
						ImGui.Text(tostring(v.ItemEnchantStaticStatus.CommerceType))
					else
						ImGui.Text("Category:") -- Type
						ImGui.SameLine()
						if v.ItemEnchantStaticStatus.Type == 0 then
							ImGui.Text("General")
						elseif v.ItemEnchantStaticStatus.Type == 1 then
							ImGui.Text("Equipement")
						elseif v.ItemEnchantStaticStatus.Type == 2 then
							ImGui.Text("Consumable")
						elseif v.ItemEnchantStaticStatus.Type == 8 then
							ImGui.Text("Crafting Material")
						else
							if Bot.EnableDebug then
								ImGui.Text(v.ItemEnchantStaticStatus.Type .. " <- Report this number")
							end
						end

						ImGui.Text("Quality:") -- Grade
						ImGui.SameLine()
						if v.ItemEnchantStaticStatus.Grade == ITEM_GRADE_WHITE then
							ImGui.Text("White")
						elseif v.ItemEnchantStaticStatus.Grade == ITEM_GRADE_GREEN then
							ImGui.TextColored(ImVec4(0.2,1,0.2,1), "Green")
						elseif v.ItemEnchantStaticStatus.Grade == ITEM_GRADE_BLUE then
							ImGui.TextColored(ImVec4(0.4,0.6,1,1), "Blue")
						elseif v.ItemEnchantStaticStatus.Grade == ITEM_GRADE_GOLD then
							ImGui.TextColored(ImVec4(1,0.8,0,1), "Gold")
						else
							if Bot.EnableDebug then
								ImGui.Text(v.ItemEnchantStaticStatus.Grade .. " <- Report this number")
							end
						end

						if v.ItemEnchantStaticStatus.Type == 1 then -- Endurance
							ImGui.Text("Durability:")
							ImGui.SameLine()
							ImGui.Text(v.Endurance .. "/" .. v.MaxEndurance)
						elseif v.Endurance <= 32767 or v.MaxEndurance <= 32767 then -- it's for a lot of items
						else
							if Bot.EnableDebug then
								ImGui.Text("Durability:")
								ImGui.SameLine()
								ImGui.Text(v.Endurance .. " <- Report this number")
							end
						end

						if v.ItemEnchantStaticStatus.IsTradeAble then
							ImGui.Text("Can be sold to trader") -- IsTradeAble
						end
					end
				end
				ImGui.NextColumn()
			end
			ImGui.Columns(1)
			ImGui.Separator()
		end
		ImGui.End()
	end
end

function InventoryList.OnDrawGuiCallback()
	InventoryList.DrawInventoryList()
end