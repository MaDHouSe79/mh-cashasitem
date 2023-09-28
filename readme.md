<p align="center">
    <img width="140" src="https://icons.iconarchive.com/icons/iconarchive/red-orb-alphabet/128/Letter-M-icon.png" />  
    <h1 align="center">Hi 👋, I'm MaDHouSe</h1>
    <h3 align="center">A passionate allround developer </h3>    
</p>

<p align="center">
  <a href="https://github.com/MaDHouSe79/mh-cashasitem/issues">
    <img src="https://img.shields.io/github/issues/MaDHouSe79/mh-cashasitem"/> 
  </a>
  <a href="https://github.com/MaDHouSe79/mh-cashasitem/watchers">
    <img src="https://img.shields.io/github/watchers/MaDHouSe79/mh-cashasitem"/> 
  </a> 
  <a href="https://github.com/MaDHouSe79/mh-cashasitem/network/members">
    <img src="https://img.shields.io/github/forks/MaDHouSe79/mh-cashasitem"/> 
  </a>  
  <a href="https://github.com/MaDHouSe79/mh-cashasitem/stargazers">
    <img src="https://img.shields.io/github/stars/MaDHouSe79/mh-cashasitem?color=white"/> 
  </a>
  <a href="https://github.com/MaDHouSe79/mh-cashasitem/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/MaDHouSe79/mh-cashasitem?color=black"/> 
  </a>      
</p>

# mh-cashasitem
- Use cash as item for qb-core servers!

# Dependencies
- [qb-core](https://github.com/qbcore-framework/qb-core)
- [qb-inventiory](https://github.com/MaDHouSe79/qb-inventory)

# Compatible
- [ps-inventory](https://github.com/Project-Sloth/ps-inventory)

# Video
https://www.youtube.com/watch?v=sWYkV-PeqU4


# Check in server file config
- inventory itembox popup when you add or remove items.
- set it all to false if you don't want it.
```lua
local useItemBox = true    -- true if you want to use the itembox popup 
local useAddBox = true     -- true if you want to see the add itembox popup (only works if useItemBox = true)
local useRemoveBox = false -- true if you want to see the remove itembox popup (only works if useItemBox = true)
```

# Add in `[qb]/qb-core/shared/items.lua` 
- and don't forgot the add the cash.png in to your inventory image folder.
```lua
['cash'] = {
    ['name'] = 'cash', 
    ['label'] = 'Cash', 
    ['weight'] = 0, 
    ['type'] = 'item', 
    ['image'] = 'cash.png', 
    ['unique'] = false,
    ['useable'] = false,
    ['shouldClose'] = true,
    ['combinable'] = nil,
    ['description'] = 'Cash'
},
```

# Add in inventory config.lua
```lua
-- it works without this, it is for mh-suitecases,
-- but this is needed in the inventory config, or the trigger can give you errors.
Config.Stashes = {
    ['wallet'] = {
        allowedItems = {
            ["cash"] = true,
            ["id_card"] = true,
            ["driver_license"] = true,
            ["lawyerpass"] = true,
            ["weaponlicense"] = true,
            ["visa"] = true,
            ["mastercard"] = true,
            ["security_card_01"] = true,
            ["security_card_02"] = true,
        },
    },
    ["cashsuitcase"] = {
        allowedItems = {
            ["cash"] = true,
        },
    },
    ["drugssuitcase"] = {
        allowedItems = {
            ["meth"] = true,
            ["coke"] = true,
            ["weed"] = true,
        },
    },
    ['weaponsuitcase'] = {
        allowedItems = {
            ["weapon_pistol"] = true,
            ["pistol_ammo"] = true,
        },
    },
}
```

# Replace for qb-inventory
- Find in inventory server/main.lua
- `RegisterNetEvent` `inventory:server:SetInventoryData`
- Replace the code with this code below, and make sure you backup the old code.
```lua
RegisterNetEvent('inventory:server:SetInventoryData', function(fromInventory, toInventory, fromSlot, toSlot, fromAmount, toAmount)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	fromSlot = tonumber(fromSlot)
	toSlot = tonumber(toSlot)

	if (fromInventory == "player" or fromInventory == "hotbar") and (QBCore.Shared.SplitStr(toInventory, "-")[1] == "itemshop" or toInventory == "crafting") then
		return
	end

	if fromInventory == "player" or fromInventory == "hotbar" then
		local fromItemData = GetItemBySlot(src, fromSlot)
		fromAmount = tonumber(fromAmount) or fromItemData.amount
		if fromItemData and fromItemData.amount >= fromAmount then
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = GetItemBySlot(src, toSlot)
				RemoveItem(src, fromItemData.name, fromAmount, fromSlot)
				TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "remove", false)
				TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
				if toItemData then
					toAmount = tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "remove", false)
						RemoveItem(src, toItemData.name, toAmount, toSlot)
						TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "add", false)
						AddItem(src, toItemData.name, toAmount, fromSlot, toItemData.info)
					end
				end
				TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", false)
				AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info)
			elseif QBCore.Shared.SplitStr(toInventory, "-")[1] == "otherplayer" then
				local playerId = tonumber(QBCore.Shared.SplitStr(toInventory, "-")[2])
				local OtherPlayer = QBCore.Functions.GetPlayer(playerId)
				local toItemData = OtherPlayer.PlayerData.items[toSlot]
				RemoveItem(src, fromItemData.name, fromAmount, fromSlot)
				TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "remove")
				TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
				if toItemData then
					local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
					toAmount = tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						RemoveItem(playerId, itemInfo["name"], toAmount, fromSlot)
						TriggerEvent('mh-cashasitem:server:updateCash', playerId, toItemData, toAmount, "remove")
						AddItem(src, toItemData.name, toAmount, fromSlot, toItemData.info)
						TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "add")
						TriggerEvent("qb-log:server:CreateLog", "robbing", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount.. "** with player: **".. GetPlayerName(OtherPlayer.PlayerData.source) .. "** (citizenid: *"..OtherPlayer.PlayerData.citizenid.."* | id: *"..OtherPlayer.PlayerData.source.."*)")
					else
						TriggerEvent("qb-log:server:CreateLog", "robbing", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** - from dropid: *" .. fromInventory .. "*")
					end
				else
					local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
					TriggerEvent("qb-log:server:CreateLog", "robbing", "Dropped Item", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | *"..src.."*) dropped new item; name: **"..itemInfo["name"].."**, amount: **" .. fromAmount .. "** to player: **".. GetPlayerName(OtherPlayer.PlayerData.source) .. "** (citizenid: *"..OtherPlayer.PlayerData.citizenid.."* | id: *"..OtherPlayer.PlayerData.source.."*)")
				end
				local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
				TriggerEvent('mh-cashasitem:server:updateCash', playerId, fromItemData, fromAmount, "add")
				AddItem(playerId, itemInfo["name"], fromAmount, toSlot, fromItemData.info)
			elseif QBCore.Shared.SplitStr(toInventory, "-")[1] == "trunk" then
				local plate = QBCore.Shared.SplitStr(toInventory, "-")[2]
				local toItemData = Trunks[plate].items[toSlot]
				RemoveItem(src, fromItemData.name, fromAmount, fromSlot)
				TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "remove")
				if Config.Stashes[fromItemData.name:lower()] then
					TriggerEvent('mh-stashes:client:RemoveProp', src)
				end	
				TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
				if toItemData then
					local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
					toAmount = tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						RemoveFromTrunk(plate, fromSlot, itemInfo["name"], toAmount)
						AddItem(src, toItemData.name, toAmount, fromSlot, toItemData.info)
						TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "add")
						TriggerEvent("qb-log:server:CreateLog", "trunk", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount .. "** - plate: *" .. plate .. "*")
					else
						TriggerEvent("qb-log:server:CreateLog", "trunk", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** - from dropid: *" .. fromInventory .. "*")
					end
				else
					local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
					TriggerEvent("qb-log:server:CreateLog", "trunk", "Dropped Item", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) dropped new item; name: **"..itemInfo["name"].."**, amount: **" .. fromAmount .. "** - plate: *" .. plate .. "*")
				end
				local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
				AddToTrunk(plate, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info)
			elseif QBCore.Shared.SplitStr(toInventory, "-")[1] == "glovebox" then
				local plate = QBCore.Shared.SplitStr(toInventory, "-")[2]
				local toItemData = Gloveboxes[plate].items[toSlot]
				RemoveItem(src, fromItemData.name, fromAmount, fromSlot)
				if Config.Stashes[fromItemData.name:lower()] then
					TriggerEvent('mh-stashes:client:RemoveProp', src)
				end	
				TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "remove")
				TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
				if toItemData then
					local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
					toAmount = tonumber(toAmount) or toItemData.amount
					
					if toItemData.name ~= fromItemData.name then
						RemoveFromGlovebox(plate, fromSlot, itemInfo["name"], toAmount)
						AddItem(src, toItemData.name, toAmount, fromSlot, toItemData.info)
						TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "add")
						TriggerEvent("qb-log:server:CreateLog", "glovebox", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount .. "** - plate: *" .. plate .. "*")
					else
						TriggerEvent("qb-log:server:CreateLog", "glovebox", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** - from dropid: *" .. fromInventory .. "*")
					end
				else
					local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
					TriggerEvent("qb-log:server:CreateLog", "glovebox", "Dropped Item", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) dropped new item; name: **"..itemInfo["name"].."**, amount: **" .. fromAmount .. "** - plate: *" .. plate .. "*")
				end
				local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
				AddToGlovebox(plate, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info)
			elseif QBCore.Shared.SplitStr(toInventory, "-")[1] == "stash" then
				local stashId = QBCore.Shared.SplitStr(toInventory, "-")[2]
				local toItemData = Stashes[stashId].items[toSlot]
				-- mh-stashes (start)
				local suitcase = QBCore.Shared.SplitStr(stashId, "_")[1]
				local canuse = true
				if Config.Stashes[suitcase] then -- we hebben een koffer
					if Config.Stashes[suitcase].allowedItems then -- zijn er items die we in de koffer mogen doen?
						if not Config.Stashes[suitcase].allowedItems[fromItemData.name:lower()] then -- als het item niet in de koffer mag?
							canuse = false
							TriggerEvent('mh-stashes:server:allowed_items_error', src, Config.Stashes[suitcase].allowedItems)						
						end
					end	
				end
				-- mh-stashes (end)	
				if canuse then
					RemoveItem(src, fromItemData.name, fromAmount, fromSlot)
					TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "remove", true)
					TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
					if toItemData then
						local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
						toAmount = tonumber(toAmount) or toItemData.amount
						if toItemData.name ~= fromItemData.name then
							RemoveFromStash(stashId, toSlot, itemInfo["name"], toAmount)
							AddItem(src, toItemData.name, toAmount, fromSlot, toItemData.info)
							TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "add", true)
							TriggerEvent("qb-log:server:CreateLog", "stash", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount .. "** - stash: *" .. stashId .. "*")
						else
							TriggerEvent("qb-log:server:CreateLog", "stash", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** - from dropid: *" .. fromInventory .. "*")
						end
					else
						local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
						TriggerEvent("qb-log:server:CreateLog", "stash", "Dropped Item", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) dropped new item; name: **"..itemInfo["name"].."**, amount: **" .. fromAmount .. "** - stash: *" .. stashId .. "*")
					end
					local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
					AddToStash(stashId, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info)
				end
			elseif QBCore.Shared.SplitStr(toInventory, "-")[1] == "traphouse" then
				local traphouseId = QBCore.Shared.SplitStr(toInventory, "_")[2]
				local toItemData = exports['qb-traphouse']:GetInventoryData(traphouseId, toSlot)
				local IsItemValid = exports['qb-traphouse']:CanItemBeSaled(fromItemData.name:lower())
				if IsItemValid then
					RemoveItem(src, fromItemData.name, fromAmount, fromSlot)
					TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "remove")
					TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
					if toItemData  then
						local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
						toAmount = tonumber(toAmount) or toItemData.amount
						if toItemData.name ~= fromItemData.name then
							exports['qb-traphouse']:RemoveHouseItem(traphouseId, fromSlot, itemInfo["name"], toAmount)
							AddItem(src, toItemData.name, toAmount, fromSlot, toItemData.info)
							TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "add")
							TriggerEvent("qb-log:server:CreateLog", "traphouse", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount .. "** - traphouse: *" .. traphouseId .. "*")
						else
							TriggerEvent("qb-log:server:CreateLog", "traphouse", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** - from dropid: *" .. fromInventory .. "*")
						end
					else
						local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
						TriggerEvent("qb-log:server:CreateLog", "traphouse", "Dropped Item", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) dropped new item; name: **"..itemInfo["name"].."**, amount: **" .. fromAmount .. "** - traphouse: *" .. traphouseId .. "*")
					end
					local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
					exports['qb-traphouse']:AddHouseItem(traphouseId, toSlot, itemInfo["name"], fromAmount, fromItemData.info, src)
				else
					QBCore.Functions.Notify(src, Lang:t("notify.nosell"), 'error')
				end
			else
				-- from player to drop
				toInventory = tonumber(toInventory)
				if toInventory == nil or toInventory == 0 then
					if Config.Stashes[fromItemData.info.type] then
						local coords = GetEntityCoords(GetPlayerPed(src))
						local pos = {["x"] = coords.x + 0.5, ["y"] = coords.y + 0.5, ["z"] = coords.z}
						print("Player To Drop Inventory", json.encode(fromItemData, {indent = true}))
						TriggerEvent('mh-stashes:server:dropsuitcase', src, fromItemData, pos)
					else
						CreateNewDrop(src, fromSlot, toSlot, fromAmount)
						TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "remove", true)	
					end					
				else
					local toItemData = Drops[toInventory].items[toSlot]
					RemoveItem(src, fromItemData.name, fromAmount, fromSlot)
					TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "remove", true)
					TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
					if toItemData then
						local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
						toAmount = tonumber(toAmount) or toItemData.amount
						if toItemData.name ~= fromItemData.name then
							AddItem(src, toItemData.name, toAmount, fromSlot, toItemData.info)
							TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", true)
							RemoveFromDrop(toInventory, fromSlot, itemInfo["name"], toAmount)
							TriggerEvent("qb-log:server:CreateLog", "drop", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount .. "** - dropid: *" .. toInventory .. "*")
						else
							TriggerEvent("qb-log:server:CreateLog", "drop", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** - from dropid: *" .. fromInventory .. "*")
						end
					else
						local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
						TriggerEvent("qb-log:server:CreateLog", "drop", "Dropped Item", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) dropped new item; name: **"..itemInfo["name"].."**, amount: **" .. fromAmount .. "** - dropid: *" .. toInventory .. "*")
					end
					local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
					AddToDrop(toInventory, toSlot, itemInfo["name"], fromAmount, fromItemData.info)
					if itemInfo["name"] == "radio" then
						TriggerClientEvent('Radio.Set', src, false)
					end
				end
			end
		else
			QBCore.Functions.Notify(src, Lang:t("notify.missitem"), "error")
		end
	elseif QBCore.Shared.SplitStr(fromInventory, "-")[1] == "otherplayer" then
		local playerId = tonumber(QBCore.Shared.SplitStr(fromInventory, "-")[2])
		local OtherPlayer = QBCore.Functions.GetPlayer(playerId)
		local fromItemData = OtherPlayer.PlayerData.items[fromSlot]
		fromAmount = tonumber(fromAmount) or fromItemData.amount
		if fromItemData and fromItemData.amount >= fromAmount then
			local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = GetItemBySlot(src, toSlot)
				if Config.Stashes[toItemData.name] then
					local hasItem = QBCore.Functions.HasItem(src, toItemData.name, 1)
					if hasItem then
						TriggerEvent('mh-stashes:server:max_carry_item', src)
					else
						RemoveItem(playerId, itemInfo["name"], fromAmount, fromSlot)
						TriggerEvent('mh-cashasitem:server:updateCash', playerId, fromItemData, fromAmount, "remove", true)
						TriggerClientEvent("inventory:client:CheckWeapon", OtherPlayer.PlayerData.source, fromItemData.name)
						if toItemData then
							itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
							toAmount = tonumber(toAmount) or toItemData.amount
							if toItemData.name ~= fromItemData.name then
								RemoveItem(src, toItemData.name, toAmount, toSlot)
								TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "remove", true)
								AddItem(playerId, itemInfo["name"], toAmount, fromSlot, toItemData.info)
								TriggerEvent('mh-cashasitem:server:updateCash', playerId, toItemData, toAmount, "add", true)
								TriggerEvent("qb-log:server:CreateLog", "robbing", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** from player: **".. GetPlayerName(OtherPlayer.PlayerData.source) .. "** (citizenid: *"..OtherPlayer.PlayerData.citizenid.."* | *"..OtherPlayer.PlayerData.source.."*)")
							end
						else
							TriggerEvent("qb-log:server:CreateLog", "robbing", "Retrieved Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) took item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** from player: **".. GetPlayerName(OtherPlayer.PlayerData.source) .. "** (citizenid: *"..OtherPlayer.PlayerData.citizenid.."* | *"..OtherPlayer.PlayerData.source.."*)")
						end
						TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", true)
						AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info)
					end 
				else
					RemoveItem(playerId, itemInfo["name"], fromAmount, fromSlot)
					TriggerEvent('mh-cashasitem:server:updateCash', playerId, fromItemData, fromAmount, "remove", true)
					TriggerClientEvent("inventory:client:CheckWeapon", OtherPlayer.PlayerData.source, fromItemData.name)
					if toItemData then
						itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
						toAmount = tonumber(toAmount) or toItemData.amount
						if toItemData.name ~= fromItemData.name then
							RemoveItem(src, toItemData.name, toAmount, toSlot)
							TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "remove", true)
							AddItem(playerId, itemInfo["name"], toAmount, fromSlot, toItemData.info)
							TriggerEvent('mh-cashasitem:server:updateCash', playerId, toItemData, toAmount, "add", true)
							TriggerEvent("qb-log:server:CreateLog", "robbing", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** from player: **".. GetPlayerName(OtherPlayer.PlayerData.source) .. "** (citizenid: *"..OtherPlayer.PlayerData.citizenid.."* | *"..OtherPlayer.PlayerData.source.."*)")
						end
					else
						TriggerEvent("qb-log:server:CreateLog", "robbing", "Retrieved Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) took item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** from player: **".. GetPlayerName(OtherPlayer.PlayerData.source) .. "** (citizenid: *"..OtherPlayer.PlayerData.citizenid.."* | *"..OtherPlayer.PlayerData.source.."*)")
					end
					TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", true)
					AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info)
				end
			else
				local toItemData = OtherPlayer.PlayerData.items[toSlot]
				RemoveItem(playerId, itemInfo["name"], fromAmount, fromSlot)
				if toItemData then
					toAmount = tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
						RemoveItem(playerId, itemInfo["name"], toAmount, toSlot)
						AddItem(playerId, itemInfo["name"], toAmount, fromSlot, toItemData.info)
					end
				end
				itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
				AddItem(playerId, itemInfo["name"], fromAmount, toSlot, fromItemData.info)
			end
		else
			QBCore.Functions.Notify(src, Lang:t("notify.itemexist"), "error")
		end
	elseif QBCore.Shared.SplitStr(fromInventory, "-")[1] == "trunk" then
		local plate = QBCore.Shared.SplitStr(fromInventory, "-")[2]
		local fromItemData = Trunks[plate].items[fromSlot]
		fromAmount = tonumber(fromAmount) or fromItemData.amount
		if fromItemData and fromItemData.amount >= fromAmount then
			local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = GetItemBySlot(src, toSlot)
				if Config.Stashes[fromItemData.name:lower()] then
					local hasItem = QBCore.Functions.HasItem(src, fromItemData.name, 1)
					if hasItem then
						TriggerEvent('mh-stashes:server:max_carry_item', src)
					else
						RemoveFromTrunk(plate, fromSlot, itemInfo["name"], fromAmount)
						if toItemData then
							itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
							toAmount = tonumber(toAmount) or toItemData.amount
							if toItemData.name ~= fromItemData.name then
								RemoveItem(src, toItemData.name, toAmount, toSlot)
								TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "remove", true)
								AddToTrunk(plate, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info)
								TriggerEvent("qb-log:server:CreateLog", "trunk", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** plate: *" .. plate .. "*")
							else
								TriggerEvent("qb-log:server:CreateLog", "trunk", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** from plate: *" .. plate .. "*")
							end
						else
							TriggerEvent("qb-log:server:CreateLog", "trunk", "Received Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) received item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount.. "** plate: *" .. plate .. "*")
						end
						TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", true)
						AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info)
					end 
				else
					RemoveFromTrunk(plate, fromSlot, itemInfo["name"], fromAmount)
					if toItemData then
						itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
						toAmount = tonumber(toAmount) or toItemData.amount
						if toItemData.name ~= fromItemData.name then
							RemoveItem(src, toItemData.name, toAmount, toSlot)
							TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "remove")
							AddToTrunk(plate, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info)
							TriggerEvent("qb-log:server:CreateLog", "trunk", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** plate: *" .. plate .. "*")
						else
							TriggerEvent("qb-log:server:CreateLog", "trunk", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** from plate: *" .. plate .. "*")
						end
					else
						TriggerEvent("qb-log:server:CreateLog", "trunk", "Received Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) received item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount.. "** plate: *" .. plate .. "*")
					end
					TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add")
					AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info)
				end
			else
				local toItemData = Trunks[plate].items[toSlot]
				RemoveFromTrunk(plate, fromSlot, itemInfo["name"], fromAmount)
				if toItemData then
					toAmount = tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
						RemoveFromTrunk(plate, toSlot, itemInfo["name"], toAmount)
						AddToTrunk(plate, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info)
					end
				end
				itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
				AddToTrunk(plate, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info)
			end
		else
			QBCore.Functions.Notify(src, Lang:t("notify.itemexist"), "error")
		end
	elseif QBCore.Shared.SplitStr(fromInventory, "-")[1] == "glovebox" then
		local plate = QBCore.Shared.SplitStr(fromInventory, "-")[2]
		local fromItemData = Gloveboxes[plate].items[fromSlot]
		fromAmount = tonumber(fromAmount) or fromItemData.amount
		if fromItemData and fromItemData.amount >= fromAmount then
			local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = GetItemBySlot(src, toSlot)
				if Config.Stashes[fromItemData.name:lower()] then
					local hasItem = QBCore.Functions.HasItem(src, "suitcase", 1)
					if hasItem then
						TriggerEvent('mh-stashes:server:max_carry_item', src)
					else
						RemoveFromGlovebox(plate, fromSlot, itemInfo["name"], fromAmount)
						if toItemData then
							itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
							toAmount = tonumber(toAmount) or toItemData.amount
							if toItemData.name ~= fromItemData.name then
								RemoveItem(src, toItemData.name, toAmount, toSlot)
								TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "remove", true)
								AddToGlovebox(plate, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info)
								TriggerEvent("qb-log:server:CreateLog", "glovebox", "Swapped", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src..")* swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** plate: *" .. plate .. "*")
							else
								TriggerEvent("qb-log:server:CreateLog", "glovebox", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** from plate: *" .. plate .. "*")
							end
						else
							TriggerEvent("qb-log:server:CreateLog", "glovebox", "Received Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) received item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount.. "** plate: *" .. plate .. "*")
						end
						TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", true)
						AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info)
					end 
				else
					RemoveFromGlovebox(plate, fromSlot, itemInfo["name"], fromAmount)
					if toItemData then
						itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
						toAmount = tonumber(toAmount) or toItemData.amount
						if toItemData.name ~= fromItemData.name then
							RemoveItem(src, toItemData.name, toAmount, toSlot)
							TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "remove")
							AddToGlovebox(plate, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info)
							TriggerEvent("qb-log:server:CreateLog", "glovebox", "Swapped", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src..")* swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** plate: *" .. plate .. "*")
						else
							TriggerEvent("qb-log:server:CreateLog", "glovebox", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** from plate: *" .. plate .. "*")
						end
					else
						TriggerEvent("qb-log:server:CreateLog", "glovebox", "Received Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) received item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount.. "** plate: *" .. plate .. "*")
					end
					TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add")
					AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info)
				end
			else
				local toItemData = Gloveboxes[plate].items[toSlot]
				RemoveFromGlovebox(plate, fromSlot, itemInfo["name"], fromAmount)
				if toItemData then
					toAmount = tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
						RemoveFromGlovebox(plate, toSlot, itemInfo["name"], toAmount)
						AddToGlovebox(plate, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info)
					end
				end
				itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
				AddToGlovebox(plate, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info)
			end
		else
			QBCore.Functions.Notify(src, Lang:t("notify.itemexist"), "error")
		end
	elseif QBCore.Shared.SplitStr(fromInventory, "-")[1] == "stash" then
		local stashId = QBCore.Shared.SplitStr(fromInventory, "-")[2]
		local fromItemData = Stashes[stashId].items[fromSlot]
		fromAmount = tonumber(fromAmount) or fromItemData.amount
		-- mh-stashes (start)
		local suitcase = QBCore.Shared.SplitStr(stashId, "_")[1]
		local canloot = true
		if Config.Stashes[suitcase] then
			if fromItemData and fromItemData.info and fromItemData.info.item == suitcase then
				if not fromItemData.info.canloot then
					canloot = false
				else
					if fromItemData.info.isOnMission then
						canloot = false
					end
				end
			end
		end
		-- mh-stashes (end)

		if canloot then
			if fromItemData and fromItemData.amount >= fromAmount then
				local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
				if toInventory == "player" or toInventory == "hotbar" then
					local toItemData = GetItemBySlot(src, toSlot)
					if Config.Stashes[fromItemData.name:lower()] then
						local hasItem = QBCore.Functions.HasItem(src, fromItemData.name, 1)
						if hasItem then
							TriggerEvent('mh-stashes:server:max_carry_item', src)
						else
							RemoveFromStash(stashId, fromSlot, itemInfo["name"], fromAmount)
							if toItemData then
								itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
								toAmount = tonumber(toAmount) or toItemData.amount
								if toItemData.name ~= fromItemData.name then
									RemoveItem(src, toItemData.name, toAmount, toSlot)
									TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "remove", true)
									AddToStash(stashId, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info)
									TriggerEvent("qb-log:server:CreateLog", "stash", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** stash: *" .. stashId .. "*")
								else
									TriggerEvent("qb-log:server:CreateLog", "stash", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** from stash: *" .. stashId .. "*")
								end
							else
								TriggerEvent("qb-log:server:CreateLog", "stash", "Received Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) received item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount.. "** stash: *" .. stashId .. "*")
							end
							SaveStashItems(stashId, Stashes[stashId].items)
							TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", true)
							AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info)
						end
					else
						RemoveFromStash(stashId, fromSlot, itemInfo["name"], fromAmount)
						if toItemData then
							itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
							toAmount = tonumber(toAmount) or toItemData.amount
							if toItemData.name ~= fromItemData.name then
								RemoveItem(src, toItemData.name, toAmount, toSlot)
								TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "remove", true)
								AddToStash(stashId, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info)
								TriggerEvent("qb-log:server:CreateLog", "stash", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** stash: *" .. stashId .. "*")
							else
								TriggerEvent("qb-log:server:CreateLog", "stash", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** from stash: *" .. stashId .. "*")
							end
						else
							TriggerEvent("qb-log:server:CreateLog", "stash", "Received Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) received item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount.. "** stash: *" .. stashId .. "*")
						end
						SaveStashItems(stashId, Stashes[stashId].items)
						TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", true)
						AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info)
					end
				else
					local toItemData = Stashes[stashId].items[toSlot]
					RemoveFromStash(stashId, fromSlot, itemInfo["name"], fromAmount)
					if toItemData then
						toAmount = tonumber(toAmount) or toItemData.amount
						if toItemData.name ~= fromItemData.name then
							itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
							RemoveFromStash(stashId, toSlot, itemInfo["name"], toAmount)
							AddToStash(stashId, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info)
						end
					end
					itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
					AddToStash(stashId, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info)
				end
			else
				QBCore.Functions.Notify(src, Lang:t("notify.itemexist"), "error")
			end
		end
	elseif QBCore.Shared.SplitStr(fromInventory, "-")[1] == "traphouse" then
		local traphouseId = QBCore.Shared.SplitStr(fromInventory, "-")[2]
		local fromItemData = exports['qb-traphouse']:GetInventoryData(traphouseId, fromSlot)
		fromAmount = tonumber(fromAmount) or fromItemData.amount
		if fromItemData and fromItemData.amount >= fromAmount then
			local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = GetItemBySlot(src, toSlot)
				if Config.Stashes[fromItemData.name:lower()] then
					local hasItem = QBCore.Functions.HasItem(src, fromItemData.name, 1)
					if hasItem then
						TriggerEvent('mh-stashes:server:max_carry_item', src)
					else
						exports['qb-traphouse']:RemoveHouseItem(traphouseId, fromSlot, itemInfo["name"], fromAmount)
						if toItemData then
							itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
							toAmount = tonumber(toAmount) or toItemData.amount
							if toItemData.name ~= fromItemData.name then
								RemoveItem(src, toItemData.name, toAmount, toSlot)
								TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "remove", true)
								exports['qb-traphouse']:AddHouseItem(traphouseId, fromSlot, itemInfo["name"], toAmount, toItemData.info, src)
								TriggerEvent("qb-log:server:CreateLog", "stash", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** stash: *" .. traphouseId .. "*")
							else
								TriggerEvent("qb-log:server:CreateLog", "stash", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** from stash: *" .. traphouseId .. "*")
							end
						else
							TriggerEvent("qb-log:server:CreateLog", "stash", "Received Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) received item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount.. "** stash: *" .. traphouseId .. "*")
						end
						TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", true)
						AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info)
					end 
				else
					exports['qb-traphouse']:RemoveHouseItem(traphouseId, fromSlot, itemInfo["name"], fromAmount)
					if toItemData then
						itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
						toAmount = tonumber(toAmount) or toItemData.amount
						if toItemData.name ~= fromItemData.name then
							RemoveItem(src, toItemData.name, toAmount, toSlot)
							TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "remove")
							exports['qb-traphouse']:AddHouseItem(traphouseId, fromSlot, itemInfo["name"], toAmount, toItemData.info, src)
							TriggerEvent("qb-log:server:CreateLog", "stash", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** stash: *" .. traphouseId .. "*")
						else
							TriggerEvent("qb-log:server:CreateLog", "stash", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** from stash: *" .. traphouseId .. "*")
						end
					else
						TriggerEvent("qb-log:server:CreateLog", "stash", "Received Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) received item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount.. "** stash: *" .. traphouseId .. "*")
					end
					TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add")
					AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info)
				end 
			else
				local toItemData = exports['qb-traphouse']:GetInventoryData(traphouseId, toSlot)
				exports['qb-traphouse']:RemoveHouseItem(traphouseId, fromSlot, itemInfo["name"], fromAmount)
				if toItemData then
					toAmount = tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
						exports['qb-traphouse']:RemoveHouseItem(traphouseId, toSlot, itemInfo["name"], toAmount)
						exports['qb-traphouse']:AddHouseItem(traphouseId, fromSlot, itemInfo["name"], toAmount, toItemData.info, src)
					end
				end
				itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
				exports['qb-traphouse']:AddHouseItem(traphouseId, toSlot, itemInfo["name"], fromAmount, fromItemData.info, src)
			end
		else
			QBCore.Functions.Notify(src, "Item doesn't exist??", "error")
		end
	elseif QBCore.Shared.SplitStr(fromInventory, "-")[1] == "itemshop" then
		local shopType = QBCore.Shared.SplitStr(fromInventory, "-")[2]
		local itemData = ShopItems[shopType].items[fromSlot]
		local itemInfo = QBCore.Shared.Items[itemData.name:lower()]
		local bankBalance = Player.PlayerData.money["bank"]
		local price = tonumber((itemData.price*fromAmount))
		
		if QBCore.Shared.SplitStr(shopType, "_")[1] == "Dealer" then
			if QBCore.Shared.SplitStr(itemData.name, "_")[1] == "weapon" then
				price = tonumber(itemData.price)
				if Player.Functions.RemoveMoney("cash", price, "dealer-item-bought") then
					itemData.info.serie = tostring(QBCore.Shared.RandomInt(2) .. QBCore.Shared.RandomStr(3) .. QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(4))
					itemData.info.quality = 100
					AddItem(src, itemData.name, 1, toSlot, itemData.info)
					TriggerClientEvent('qb-drugs:client:updateDealerItems', src, itemData, 1)
					QBCore.Functions.Notify(src, itemInfo["label"] .. " bought!", "success")
					TriggerEvent("qb-log:server:CreateLog", "dealers", "Dealer item bought", "green", "**"..GetPlayerName(src) .. "** bought a " .. itemInfo["label"] .. " for $"..price)
				else
					QBCore.Functions.Notify(src, Lang:t("notify.notencash"), "error")
				end
			else
				if Player.Functions.RemoveMoney("cash", price, "dealer-item-bought") then
					AddItem(src, itemData.name, fromAmount, toSlot, itemData.info)
					TriggerClientEvent('qb-drugs:client:updateDealerItems', src, itemData, fromAmount)
					QBCore.Functions.Notify(src, itemInfo["label"] .. " bought!", "success")
					TriggerEvent("qb-log:server:CreateLog", "dealers", "Dealer item bought", "green", "**"..GetPlayerName(src) .. "** bought a " .. itemInfo["label"] .. "  for $"..price)
				else
					QBCore.Functions.Notify(src, "You don't have enough cash..", "error")
				end
			end
		elseif QBCore.Shared.SplitStr(shopType, "_")[1] == "Itemshop" then
			if Player.Functions.RemoveMoney("cash", price, "itemshop-bought-item") then
                if QBCore.Shared.SplitStr(itemData.name, "_")[1] == "weapon" then
                    itemData.info.serie = tostring(QBCore.Shared.RandomInt(2) .. QBCore.Shared.RandomStr(3) .. QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(4))
					itemData.info.quality = 100
                end
				AddItem(src, itemData.name, fromAmount, toSlot, itemData.info)
				TriggerClientEvent('qb-shops:client:UpdateShop', src, QBCore.Shared.SplitStr(shopType, "_")[2], itemData, fromAmount)
				QBCore.Functions.Notify(src, itemInfo["label"] .. " bought!", "success")
				TriggerEvent("qb-log:server:CreateLog", "shops", "Shop item bought", "green", "**"..GetPlayerName(src) .. "** bought a " .. itemInfo["label"] .. " for $"..price)
			elseif bankBalance >= price then
				Player.Functions.RemoveMoney("bank", price, "itemshop-bought-item")
                if QBCore.Shared.SplitStr(itemData.name, "_")[1] == "weapon" then
                    itemData.info.serie = tostring(QBCore.Shared.RandomInt(2) .. QBCore.Shared.RandomStr(3) .. QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(4))
					itemData.info.quality = 100
                end
				AddItem(src, itemData.name, fromAmount, toSlot, itemData.info)
				TriggerClientEvent('qb-shops:client:UpdateShop', src, QBCore.Shared.SplitStr(shopType, "_")[2], itemData, fromAmount)
				QBCore.Functions.Notify(src, itemInfo["label"] .. " bought!", "success")
				TriggerEvent("qb-log:server:CreateLog", "shops", "Shop item bought", "green", "**"..GetPlayerName(src) .. "** bought a " .. itemInfo["label"] .. " for $"..price)
			else
				QBCore.Functions.Notify(src, "You don't have enough cash..", "error")
			end
		else
			if Player.Functions.RemoveMoney("cash", price, "unkown-itemshop-bought-item") then
				if itemData.name:lower() == 'wallet' then itemData.info.walletid = math.random(11111, 99999) end
				AddItem(src, itemData.name, fromAmount, toSlot, itemData.info)
				QBCore.Functions.Notify(src, itemInfo["label"] .. " bought!", "success")
				TriggerEvent("qb-log:server:CreateLog", "shops", "Shop item bought", "green", "**"..GetPlayerName(src) .. "** bought a " .. itemInfo["label"] .. " for $"..price)
			elseif bankBalance >= price then
				Player.Functions.RemoveMoney("bank", price, "unkown-itemshop-bought-item")
				if itemData.name:lower() == 'wallet' then itemData.info.walletid = math.random(11111, 99999) end
				AddItem(src, itemData.name, fromAmount, toSlot, itemData.info)
				QBCore.Functions.Notify(src, itemInfo["label"] .. " bought!", "success")
				TriggerEvent("qb-log:server:CreateLog", "shops", "Shop item bought", "green", "**"..GetPlayerName(src) .. "** bought a " .. itemInfo["label"] .. " for $"..price)
			else
				QBCore.Functions.Notify(src, Lang:t("notify.notencash"), "error")
			end
		end
	elseif fromInventory == "crafting" then
		local itemData = Config.CraftingItems[fromSlot]
		if hasCraftItems(src, itemData.costs, fromAmount) then
			TriggerClientEvent("inventory:client:CraftItems", src, itemData.name, itemData.costs, fromAmount, toSlot, itemData.points)
		else
			TriggerClientEvent("inventory:client:UpdatePlayerInventory", src, true)
			QBCore.Functions.Notify(src, Lang:t("notify.noitem"), "error")
		end
	elseif fromInventory == "attachment_crafting" then
		local itemData = Config.AttachmentCrafting["items"][fromSlot]
		if hasCraftItems(src, itemData.costs, fromAmount) then
			TriggerClientEvent("inventory:client:CraftAttachment", src, itemData.name, itemData.costs, fromAmount, toSlot, itemData.points)
		else
			TriggerClientEvent("inventory:client:UpdatePlayerInventory", src, true)
			QBCore.Functions.Notify(src, Lang:t("notify.noitem"), "error")
		end
	else
		-- from drop to player
		fromInventory = tonumber(fromInventory)
		local fromItemData = Drops[fromInventory].items[fromSlot]
		fromAmount = tonumber(fromAmount) or fromItemData.amount
		if fromItemData and fromItemData.amount >= fromAmount then
			local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = GetItemBySlot(src, toSlot)
				if Config.Stashes[fromItemData.name] then
					local hasItem = QBCore.Functions.HasItem(src, fromItemData.name, 1)
					if hasItem then
						TriggerEvent('mh-stashes:server:max_carry_item', src)
					else
						RemoveFromDrop(fromInventory, fromSlot, itemInfo["name"], fromAmount)
						if toItemData then
							toAmount = tonumber(toAmount) and tonumber(toAmount) or toItemData.amount
							if toItemData.name ~= fromItemData.name then
								itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
								RemoveItem(src, toItemData.name, toAmount, toSlot)
								TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "remove", true)
								AddToDrop(fromInventory, toSlot, itemInfo["name"], toAmount, toItemData.info)
								if itemInfo["name"] == "radio" then TriggerClientEvent('Radio.Set', src, false)	end
								TriggerEvent("qb-log:server:CreateLog", "drop", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** - dropid: *" .. fromInventory .. "*")
							else
								TriggerEvent("qb-log:server:CreateLog", "drop", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** - from dropid: *" .. fromInventory .. "*")
							end
						else
							TriggerEvent("qb-log:server:CreateLog", "drop", "Received Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) received item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount.. "** -  dropid: *" .. fromInventory .. "*")
						end
						TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", true)
						AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info)
					end
				else
					RemoveFromDrop(fromInventory, fromSlot, itemInfo["name"], fromAmount)
					if toItemData then
						toAmount = tonumber(toAmount) and tonumber(toAmount) or toItemData.amount
						if toItemData.name ~= fromItemData.name then
							itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
							RemoveItem(src, toItemData.name, toAmount, toSlot)
							TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "remove", true)
							AddToDrop(fromInventory, toSlot, itemInfo["name"], toAmount, toItemData.info)
							if itemInfo["name"] == "radio" then TriggerClientEvent('Radio.Set', src, false)	end
							TriggerEvent("qb-log:server:CreateLog", "drop", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** - dropid: *" .. fromInventory .. "*")
						else
							TriggerEvent("qb-log:server:CreateLog", "drop", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** - from dropid: *" .. fromInventory .. "*")
						end
					else
						TriggerEvent("qb-log:server:CreateLog", "drop", "Received Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) received item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount.. "** -  dropid: *" .. fromInventory .. "*")
					end
					TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", true)
					AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info)
				end
			else
				toInventory = tonumber(toInventory)
				local toItemData = Drops[toInventory].items[toSlot]
				RemoveFromDrop(fromInventory, fromSlot, itemInfo["name"], fromAmount)
				if toItemData then
					toAmount = tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
						RemoveFromDrop(toInventory, toSlot, itemInfo["name"], toAmount)
						AddToDrop(fromInventory, fromSlot, itemInfo["name"], toAmount, toItemData.info)
						if itemInfo["name"] == "radio" then
							TriggerClientEvent('Radio.Set', src, false)
						end
					end
				end
				itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
				AddToDrop(toInventory, toSlot, itemInfo["name"], fromAmount, fromItemData.info)
				if itemInfo["name"] == "radio" then
					TriggerClientEvent('Radio.Set', src, false)
				end
			end
		else
			QBCore.Functions.Notify(src, "Item doesn't exist??", "error")
		end
	end
end)
```

# Replace for ps-inventory
-  Find in inventory server/main.lua
- `RegisterNetEvent` `inventory:server:SetInventoryData`
- Replace the code with this code below, and make sure you backup the old code.
```lua
RegisterNetEvent('inventory:server:SetInventoryData', function(fromInventory, toInventory, fromSlot, toSlot, fromAmount, toAmount)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	fromSlot = tonumber(fromSlot)
	toSlot = tonumber(toSlot)

	if (fromInventory == "player" or fromInventory == "hotbar") and (QBCore.Shared.SplitStr(toInventory, "-")[1] == "itemshop" or toInventory == "crafting") then
		return
	end

	if fromInventory == "player" or fromInventory == "hotbar" then
		local fromItemData = GetItemBySlot(src, fromSlot)
		fromAmount = tonumber(fromAmount) or fromItemData.amount
		if fromItemData and fromItemData.amount >= fromAmount then
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = GetItemBySlot(src, toSlot)
				RemoveItem(src, fromItemData.name, fromAmount, fromSlot)
				TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "remove", false)
				TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
                if toItemData ~= nil then
                    local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                    if toItemData.amount >= toAmount then
						if toItemData.name ~= fromItemData.name then
							TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "remove", false)
							RemoveItem(src, toItemData.name, toAmount, toSlot)
							TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "add", false)
							AddItem(src, toItemData.name, toAmount, fromSlot, toItemData.info)
						end
					else
						TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount.. "**")
					end
                end
				TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", false)
                AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info, fromItemData["created"])
			elseif QBCore.Shared.SplitStr(toInventory, "-")[1] == "otherplayer" then
				local playerId = tonumber(QBCore.Shared.SplitStr(toInventory, "-")[2])
				local OtherPlayer = QBCore.Functions.GetPlayer(playerId)
				local toItemData = OtherPlayer.PlayerData.items[toSlot]
                local itemDataTest = OtherPlayer.Functions.GetItemBySlot(toSlot)
				RemoveItem(src, fromItemData.name, fromAmount, fromSlot)
				TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "remove")
				TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
                if toItemData ~= nil then
					local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                    local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                    if itemDataTest.amount >= toAmount then
						if toItemData.name ~= fromItemData.name then
							RemoveItem(playerId, itemInfo["name"], toAmount, fromSlot)
							TriggerEvent('mh-cashasitem:server:updateCash', playerId, toItemData, toAmount, "remove")
							AddItem(src, toItemData.name, toAmount, fromSlot, toItemData.info)
							TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "add")
							TriggerEvent("qb-log:server:CreateLog", "robbing", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount.. "** with player: **".. GetPlayerName(OtherPlayer.PlayerData.source) .. "** (citizenid: *"..OtherPlayer.PlayerData.citizenid.."* | id: *"..OtherPlayer.PlayerData.source.."*)")
						end
					else
                        TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount.. "** with player: **".. GetPlayerName(OtherPlayer.PlayerData.source) .. "** (citizenid: *"..OtherPlayer.PlayerData.citizenid.."* | id: *"..OtherPlayer.PlayerData.source.."*)")
                    end
                else
					local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
					TriggerEvent("qb-log:server:CreateLog", "robbing", "Dropped Item", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | *"..src.."*) dropped new item; name: **"..itemInfo["name"].."**, amount: **" .. fromAmount .. "** to player: **".. GetPlayerName(OtherPlayer.PlayerData.source) .. "** (citizenid: *"..OtherPlayer.PlayerData.citizenid.."* | id: *"..OtherPlayer.PlayerData.source.."*)")
				end
				local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
				TriggerEvent('mh-cashasitem:server:updateCash', playerId, fromItemData, fromAmount, "add")
                AddItem(playerId, itemInfo["name"], fromAmount, toSlot, fromItemData.info, itemInfo["created"])
			elseif QBCore.Shared.SplitStr(toInventory, "-")[1] == "trunk" then
				local plate = QBCore.Shared.SplitStr(toInventory, "-")[2]
				local toItemData = Trunks[plate].items[toSlot]
				RemoveItem(src, fromItemData.name, fromAmount, fromSlot)
				TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "remove")
				TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
				if Config.Stashes[fromItemData.name:lower()] then TriggerEvent('mh-stashes:client:RemoveProp', src) end	
                if toItemData ~= nil then
					local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                    local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                    if toItemData.amount >= toAmount then
						if toItemData.name ~= fromItemData.name then
							RemoveFromTrunk(plate, fromSlot, itemInfo["name"], toAmount)
							AddItem(src, toItemData.name, toAmount, fromSlot, toItemData.info)
							TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "add")
							TriggerEvent("qb-log:server:CreateLog", "trunk", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount .. "** - plate: *" .. plate .. "*")
						end
					else
                        TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount.. "** - plate: *" .. plate .. "*")
                    end
                else
					local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
					TriggerEvent("qb-log:server:CreateLog", "trunk", "Dropped Item", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) dropped new item; name: **"..itemInfo["name"].."**, amount: **" .. fromAmount .. "** - plate: *" .. plate .. "*")
				end
				local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                AddToTrunk(plate, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info, itemInfo["created"])
			elseif QBCore.Shared.SplitStr(toInventory, "-")[1] == "glovebox" then
				local plate = QBCore.Shared.SplitStr(toInventory, "-")[2]
				local toItemData = Gloveboxes[plate].items[toSlot]
				RemoveItem(src, fromItemData.name, fromAmount, fromSlot)
				if Config.Stashes[fromItemData.name:lower()] then TriggerEvent('mh-stashes:client:RemoveProp', src) end	
				TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "remove")
				TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
                if toItemData ~= nil then
					local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                    local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                    if toItemData.amount >= toAmount then
						if toItemData.name ~= fromItemData.name then
							RemoveFromGlovebox(plate, fromSlot, itemInfo["name"], toAmount)
							AddItem(src, toItemData.name, toAmount, fromSlot, toItemData.info)
							TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "add")
							TriggerEvent("qb-log:server:CreateLog", "glovebox", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount .. "** - plate: *" .. plate .. "*")
						end
					else
                        TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount.. "** - plate: *" .. plate .. "*")
                    end
                else
					local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
					TriggerEvent("qb-log:server:CreateLog", "glovebox", "Dropped Item", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) dropped new item; name: **"..itemInfo["name"].."**, amount: **" .. fromAmount .. "** - plate: *" .. plate .. "*")
				end
				local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                AddToGlovebox(plate, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info, itemInfo["created"])
			elseif QBCore.Shared.SplitStr(toInventory, "-")[1] == "stash" then
				local stashId = QBCore.Shared.SplitStr(toInventory, "-")[2]
				local toItemData = Stashes[stashId].items[toSlot]
				
				-- mh-stashes (start)
				local suitcase = QBCore.Shared.SplitStr(stashId, "_")[1]
				local canuse = true
				if Config.Stashes[suitcase] then -- we hebben een koffer
					if Config.Stashes[suitcase].allowedItems then -- zijn er items die we in de koffer mogen doen?
						if not Config.Stashes[suitcase].allowedItems[fromItemData.name:lower()] then -- als het item niet in de koffer mag?
							canuse = false
							TriggerEvent('mh-stashes:server:allowed_items_error', src, Config.Stashes[suitcase].allowedItems)						
						end
					end	
				end
				-- mh-stashes (end)	
				if canuse then
					RemoveItem(src, fromItemData.name, fromAmount, fromSlot)
					TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "remove", true)
					TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
					if toItemData then
						local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
						toAmount = tonumber(toAmount) or toItemData.amount
						if toItemData.name ~= fromItemData.name then
							RemoveFromStash(stashId, toSlot, itemInfo["name"], toAmount)
							AddItem(src, toItemData.name, toAmount, fromSlot, toItemData.info)
							TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "add", true)
							TriggerEvent("qb-log:server:CreateLog", "stash", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount .. "** - stash: *" .. stashId .. "*")
						else
							TriggerEvent("qb-log:server:CreateLog", "stash", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** - from dropid: *" .. fromInventory .. "*")
						end
					else
						local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
						TriggerEvent("qb-log:server:CreateLog", "stash", "Dropped Item", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) dropped new item; name: **"..itemInfo["name"].."**, amount: **" .. fromAmount .. "** - stash: *" .. stashId .. "*")
					end
					local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
					AddToStash(stashId, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info)
				end
				elseif QBCore.Shared.SplitStr(toInventory, "-")[1] == "traphouse" then
				-- Traphouse
				local traphouseId = QBCore.Shared.SplitStr(toInventory, "_")[2]
				local toItemData = exports['qb-traphouse']:GetInventoryData(traphouseId, toSlot)
				local IsItemValid = exports['qb-traphouse']:CanItemBeSaled(fromItemData.name:lower())
				if IsItemValid then
					RemoveItem(src, fromItemData.name, fromAmount, fromSlot)
					TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "remove")
					TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
                    if toItemData ~= nil then
						local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                        local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                        if toItemData.amount >= toAmount then
							if toItemData.name ~= fromItemData.name then
								exports['qb-traphouse']:RemoveHouseItem(traphouseId, fromSlot, itemInfo["name"], toAmount)
								AddItem(src, toItemData.name, toAmount, fromSlot, toItemData.info)
								TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "add")
								TriggerEvent("qb-log:server:CreateLog", "traphouse", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount .. "** - traphouse: *" .. traphouseId .. "*")
							end
						else
                            TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount.. "** - traphouse: *" .. traphouseId .. "*")
                        end
                    else
						local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
						TriggerEvent("qb-log:server:CreateLog", "traphouse", "Dropped Item", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) dropped new item; name: **"..itemInfo["name"].."**, amount: **" .. fromAmount .. "** - traphouse: *" .. traphouseId .. "*")
					end
					local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
					exports['qb-traphouse']:AddHouseItem(traphouseId, toSlot, itemInfo["name"], fromAmount, fromItemData.info, src)
				else
					QBCore.Functions.Notify(src, Lang:t('notify.can_not_sell_item'), 'error')
				end
			else
				-- drop
				toInventory = tonumber(toInventory)
				if toInventory == nil or toInventory == 0 then
					if Config.Stashes[fromItemData.name:lower()] then
						local coords = GetEntityCoords(GetPlayerPed(src))
						local pos = {["x"] = coords.x + 0.5, ["y"] = coords.y + 0.5, ["z"] = coords.z}
						TriggerEvent('mh-stashes:server:dropsuitcase', src, fromItemData, pos)
					else
						CreateNewDrop(src, fromSlot, toSlot, fromAmount)
						TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "remove", true)	
					end		
				else
					local toItemData = Drops[toInventory].items[toSlot]
					RemoveItem(src, fromItemData.name, fromAmount, fromSlot)
					TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "remove", true)
					TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
                    if toItemData ~= nil then
						local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                        local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                        if toItemData.amount >= toAmount then
							if toItemData.name ~= fromItemData.name then
								AddItem(toItemData.name, toAmount, fromSlot, toItemData.info)
								TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", true)
								RemoveFromDrop(toInventory, fromSlot, itemInfo["name"], toAmount)
								TriggerEvent("qb-log:server:CreateLog", "drop", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount .. "** - dropid: *" .. toInventory .. "*")
							end
						else
                            TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount.. "** - dropid: *" .. toInventory .. "*")
                        end
                    else
						local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
						TriggerEvent("qb-log:server:CreateLog", "drop", "Dropped Item", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) dropped new item; name: **"..itemInfo["name"].."**, amount: **" .. fromAmount .. "** - dropid: *" .. toInventory .. "*")
					end
					local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                    AddToDrop(toInventory, toSlot, itemInfo["name"], fromAmount, fromItemData.info, itemInfo["created"])
					if itemInfo["name"] == "radio" then
						TriggerClientEvent('Radio.Set', src, false)
					end
				end
			end
		else
			QBCore.Functions.Notify(src, Lang:t('notify.no_item'), "error")
		end
	elseif QBCore.Shared.SplitStr(fromInventory, "-")[1] == "otherplayer" then
		local playerId = tonumber(QBCore.Shared.SplitStr(fromInventory, "-")[2])
		local OtherPlayer = QBCore.Functions.GetPlayer(playerId)
		local fromItemData = OtherPlayer.PlayerData.items[fromSlot]
		fromAmount = tonumber(fromAmount) or fromItemData.amount
		if fromItemData and fromItemData.amount >= fromAmount then
			local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = GetItemBySlot(src, toSlot)
				if Config.Stashes[toItemData.name] then
					local hasItem = QBCore.Functions.HasItem(src, toItemData.name:lower(), 1)
					if hasItem then
						TriggerEvent('mh-stashes:server:max_carry_item', src)
					else
						RemoveItem(playerId, itemInfo["name"], fromAmount, fromSlot)
						TriggerEvent('mh-cashasitem:server:updateCash', playerId, fromItemData, fromAmount, "remove", true)
						TriggerClientEvent("inventory:client:CheckWeapon", OtherPlayer.PlayerData.source, fromItemData.name)
						if toItemData ~= nil then
							itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
							local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
							if toItemData.amount >= toAmount then
								if toItemData.name ~= fromItemData.name then
									RemoveItem(src, toItemData.name, toAmount, toSlot)
									TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "remove", true)
									AddItem(playerId, itemInfo["name"], toAmount, fromSlot, toItemData.info)
									TriggerEvent('mh-cashasitem:server:updateCash', playerId, toItemData, toAmount, "add", true)
									
									TriggerEvent("qb-log:server:CreateLog", "robbing", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** from player: **".. GetPlayerName(OtherPlayer.PlayerData.source) .. "** (citizenid: *"..OtherPlayer.PlayerData.citizenid.."* | *"..OtherPlayer.PlayerData.source.."*)")
								end
							else
								TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount.. "** with player: **".. GetPlayerName(OtherPlayer.PlayerData.source) .. "** (citizenid: *"..OtherPlayer.PlayerData.citizenid.."* | id: *"..OtherPlayer.PlayerData.source.."*)")
							end
						else
							TriggerEvent("qb-log:server:CreateLog", "robbing", "Retrieved Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) took item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** from player: **".. GetPlayerName(OtherPlayer.PlayerData.source) .. "** (citizenid: *"..OtherPlayer.PlayerData.citizenid.."* | *"..OtherPlayer.PlayerData.source.."*)")
						end
						TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", true)
						AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info, fromItemData["created"])
					end
				else
					RemoveItem(playerId, itemInfo["name"], fromAmount, fromSlot)
					TriggerEvent('mh-cashasitem:server:updateCash', playerId, fromItemData, fromAmount, "remove", true)
					TriggerClientEvent("inventory:client:CheckWeapon", OtherPlayer.PlayerData.source, fromItemData.name)
					if toItemData ~= nil then
						itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
						local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
						if toItemData.amount >= toAmount then
							if toItemData.name ~= fromItemData.name then
								RemoveItem(src, toItemData.name, toAmount, toSlot)
								TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "remove", true)
								AddItem(playerId, itemInfo["name"], toAmount, fromSlot, toItemData.info)
								TriggerEvent('mh-cashasitem:server:updateCash', playerId, toItemData, toAmount, "add", true)
								TriggerEvent("qb-log:server:CreateLog", "robbing", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** from player: **".. GetPlayerName(OtherPlayer.PlayerData.source) .. "** (citizenid: *"..OtherPlayer.PlayerData.citizenid.."* | *"..OtherPlayer.PlayerData.source.."*)")
							end
						else
							TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount.. "** with player: **".. GetPlayerName(OtherPlayer.PlayerData.source) .. "** (citizenid: *"..OtherPlayer.PlayerData.citizenid.."* | id: *"..OtherPlayer.PlayerData.source.."*)")
						end
					else
						TriggerEvent("qb-log:server:CreateLog", "robbing", "Retrieved Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) took item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** from player: **".. GetPlayerName(OtherPlayer.PlayerData.source) .. "** (citizenid: *"..OtherPlayer.PlayerData.citizenid.."* | *"..OtherPlayer.PlayerData.source.."*)")
					end
					TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", true)
					AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info, fromItemData["created"])
				end
			else
				local toItemData = OtherPlayer.PlayerData.items[toSlot]
                local itemDataTest = OtherPlayer.Functions.GetItemBySlot(toSlot)
				RemoveItem(playerId, itemInfo["name"], fromAmount, fromSlot)
                if toItemData ~= nil then
                    local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                    if itemDataTest.amount >= toAmount then
						if toItemData.name ~= fromItemData.name then
                            local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                            RemoveItem(playerId, itemInfo["name"], toAmount, toSlot)
                            AddItem(playerId, itemInfo["name"], toAmount, fromSlot, toItemData.info)
                        end
                    else
                        TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount.. "** with player: **".. GetPlayerName(OtherPlayer.PlayerData.source) .. "** (citizenid: *"..OtherPlayer.PlayerData.citizenid.."* | id: *"..OtherPlayer.PlayerData.source.."*)")
					end
				end
				itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                AddItem(playerId, itemInfo["name"], fromAmount, toSlot, fromItemData.info, itemInfo["created"])
			end
		else
			QBCore.Functions.Notify(src, Lang:t('notify.not_exist'), "error")
		end
	elseif QBCore.Shared.SplitStr(fromInventory, "-")[1] == "trunk" then
		local plate = QBCore.Shared.SplitStr(fromInventory, "-")[2]
		local fromItemData = Trunks[plate].items[fromSlot]
		fromAmount = tonumber(fromAmount) or fromItemData.amount
		if fromItemData and fromItemData.amount >= fromAmount then
			local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = GetItemBySlot(src, toSlot)
				if Config.Stashes[fromItemData.name:lower()] then
					local hasItem = QBCore.Functions.HasItem(src, fromItemData.name:lower(), 1)
					if hasItem then
						TriggerEvent('mh-stashes:server:max_carry_item', src)
					else
						RemoveFromTrunk(plate, fromSlot, itemInfo["name"], fromAmount)
						if toItemData ~= nil then
							itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
							local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
							if toItemData.amount >= toAmount then
								if toItemData.name ~= fromItemData.name then
									RemoveItem(src, toItemData.name, toAmount, toSlot)
									TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "remove", true)
									AddToTrunk(plate, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info, itemInfo["created"])
									TriggerEvent("qb-log:server:CreateLog", "trunk", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** plate: *" .. plate .. "*")
								else
									TriggerEvent("qb-log:server:CreateLog", "trunk", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** from plate: *" .. plate .. "*")
								end
							else
								TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with name: **" .. itemInfo["name"] .. "**, amount: **" .. toAmount.. "** plate: *" .. plate .. "*")
							end
						else
							TriggerEvent("qb-log:server:CreateLog", "trunk", "Received Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) received item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount.. "** plate: *" .. plate .. "*")
						end
						TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", true)
						AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info, fromItemData["created"])
					end
				else
					RemoveFromTrunk(plate, fromSlot, itemInfo["name"], fromAmount)
					if toItemData ~= nil then
						itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
						local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
						if toItemData.amount >= toAmount then
							if toItemData.name ~= fromItemData.name then
								RemoveItem(src, toItemData.name, toAmount, toSlot)
								TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "remove")
								AddToTrunk(plate, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info, itemInfo["created"])
								TriggerEvent("qb-log:server:CreateLog", "trunk", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** plate: *" .. plate .. "*")
							else
								TriggerEvent("qb-log:server:CreateLog", "trunk", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** from plate: *" .. plate .. "*")
							end
						else
							TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with name: **" .. itemInfo["name"] .. "**, amount: **" .. toAmount.. "** plate: *" .. plate .. "*")
						end
					else
						TriggerEvent("qb-log:server:CreateLog", "trunk", "Received Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) received item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount.. "** plate: *" .. plate .. "*")
					end
					TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add")
					AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info, fromItemData["created"])
				end
			else
				local toItemData = Trunks[plate].items[toSlot]
				RemoveFromTrunk(plate, fromSlot, itemInfo["name"], fromAmount)
                if toItemData ~= nil then
                    local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                    if toItemData.amount >= toAmount then
						if toItemData.name ~= fromItemData.name then
							local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
							RemoveFromTrunk(plate, toSlot, itemInfo["name"], toAmount)
							AddToTrunk(plate, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info, itemInfo["created"])
                        end
                    else
                        TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with name: **" .. itemInfo["name"] .. "**, amount: **" .. toAmount.. "** plate: *" .. plate .. "*")
					end
				end
				itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                AddToTrunk(plate, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info, itemInfo["created"])
			end
		else
            QBCore.Functions.Notify(src, Lang:t("notify.itemexist"), "error")
		end
	elseif QBCore.Shared.SplitStr(fromInventory, "-")[1] == "glovebox" then
		local plate = QBCore.Shared.SplitStr(fromInventory, "-")[2]
		local fromItemData = Gloveboxes[plate].items[fromSlot]
		fromAmount = tonumber(fromAmount) or fromItemData.amount
		if fromItemData and fromItemData.amount >= fromAmount then
			local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = GetItemBySlot(src, toSlot)
				if Config.Stashes[fromItemData.name:lower()] then
					local hasItem = QBCore.Functions.HasItem(src, fromItemData.name:lower(), 1)
					if hasItem then
						TriggerEvent('mh-stashes:server:max_carry_item', src)
					else
						RemoveFromGlovebox(plate, fromSlot, itemInfo["name"], fromAmount)
						if toItemData ~= nil then
							itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
							local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
							if toItemData.amount >= toAmount then
								if toItemData.name ~= fromItemData.name then
									RemoveItem(src, toItemData.name, toAmount, toSlot)
									TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "remove", true)
									AddToGlovebox(plate, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info, itemInfo["created"])
									TriggerEvent("qb-log:server:CreateLog", "glovebox", "Swapped", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src..")* swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** plate: *" .. plate .. "*")
								else
									TriggerEvent("qb-log:server:CreateLog", "glovebox", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** from plate: *" .. plate .. "*")
								end
							else
								TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with name: **" .. itemInfo["name"] .. "**, amount: **" .. toAmount.. "** plate: *" .. plate .. "*")
							end
						else
							TriggerEvent("qb-log:server:CreateLog", "glovebox", "Received Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) received item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount.. "** plate: *" .. plate .. "*")
						end
						TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", true)
						AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info, fromItemData["created"])
					end
				else
					RemoveFromGlovebox(plate, fromSlot, itemInfo["name"], fromAmount)
					if toItemData ~= nil then
						itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
						local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
						if toItemData.amount >= toAmount then
							if toItemData.name ~= fromItemData.name then
								RemoveItem(src, toItemData.name, toAmount, toSlot)
								TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "remove")
								AddToGlovebox(plate, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info, itemInfo["created"])
								TriggerEvent("qb-log:server:CreateLog", "glovebox", "Swapped", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src..")* swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** plate: *" .. plate .. "*")
							else
								TriggerEvent("qb-log:server:CreateLog", "glovebox", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** from plate: *" .. plate .. "*")
							end
						else
							TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with name: **" .. itemInfo["name"] .. "**, amount: **" .. toAmount.. "** plate: *" .. plate .. "*")
						end
					else
						TriggerEvent("qb-log:server:CreateLog", "glovebox", "Received Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) received item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount.. "** plate: *" .. plate .. "*")
					end
					TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add")
					AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info, fromItemData["created"])
				end

			else
				local toItemData = Gloveboxes[plate].items[toSlot]
				RemoveFromGlovebox(plate, fromSlot, itemInfo["name"], fromAmount)
                if toItemData ~= nil then
                    local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                    if toItemData.amount >= toAmount then
						if toItemData.name ~= fromItemData.name then
                            local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
							RemoveFromGlovebox(plate, toSlot, itemInfo["name"], toAmount)
                            AddToGlovebox(plate, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info, itemInfo["created"])
                        end
                    else
                        TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with name: **" .. itemInfo["name"] .. "**, amount: **" .. toAmount.. "** plate: *" .. plate .. "*")
					end
				end
				itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                AddToGlovebox(plate, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info, itemInfo["created"])
			end
		else
            QBCore.Functions.Notify(src, Lang:t("notify.itemexist"), "error")
		end
	elseif QBCore.Shared.SplitStr(fromInventory, "-")[1] == "stash" then
		local stashId = QBCore.Shared.SplitStr(fromInventory, "-")[2]
		local fromItemData = Stashes[stashId].items[fromSlot]
		fromAmount = tonumber(fromAmount) or fromItemData.amount
		
		-- mh-stashes (start)
		local suitcase = QBCore.Shared.SplitStr(stashId, "_")[1]
		local canloot = true
		if Config.Stashes[suitcase] then
			if fromItemData and fromItemData.info and fromItemData.info.item == suitcase then
				if not fromItemData.info.canloot then
					canloot = false
				else
					if fromItemData.info.isOnMission then
						canloot = false
					end
				end
			end
		end
		-- mh-stashes (end)

		if canloot then
			if fromItemData and fromItemData.amount >= fromAmount then
				local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
				if toInventory == "player" or toInventory == "hotbar" then
					local toItemData = GetItemBySlot(src, toSlot)
					if Config.Stashes[fromItemData.name:lower()] then
						local hasItem = QBCore.Functions.HasItem(src, fromItemData.name, 1)
						if hasItem then
							TriggerEvent('mh-stashes:server:max_carry_item', src)
						else
							RemoveFromStash(stashId, fromSlot, itemInfo["name"], fromAmount)
							if toItemData ~= nil then
								itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
								local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
								if toItemData.amount >= toAmount then
									if toItemData.name ~= fromItemData.name then
										RemoveItem(src, toItemData.name, toAmount, toSlot)
										TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "remove", true)
										AddToStash(stashId, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info, itemInfo["created"])
										TriggerEvent("qb-log:server:CreateLog", "stash", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** stash: *" .. stashId .. "*")
									else
										TriggerEvent("qb-log:server:CreateLog", "stash", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** from stash: *" .. stashId .. "*")
									end
								else
									TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** stash: *" .. stashId .. "*")
								end
							else
								TriggerEvent("qb-log:server:CreateLog", "stash", "Received Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) received item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount.. "** stash: *" .. stashId .. "*")
							end
							SaveStashItems(stashId, Stashes[stashId].items)
							TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", true)
							AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info, fromItemData["created"])
						end
					else
						RemoveFromStash(stashId, fromSlot, itemInfo["name"], fromAmount)
						if toItemData ~= nil then
							itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
							local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
							if toItemData.amount >= toAmount then
								if toItemData.name ~= fromItemData.name then
									RemoveItem(src, toItemData.name, toAmount, toSlot)
									TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "remove", true)
									AddToStash(stashId, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info, itemInfo["created"])
									TriggerEvent("qb-log:server:CreateLog", "stash", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** stash: *" .. stashId .. "*")
								else
									TriggerEvent("qb-log:server:CreateLog", "stash", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** from stash: *" .. stashId .. "*")
								end
							else
								TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** stash: *" .. stashId .. "*")
							end
						else
							TriggerEvent("qb-log:server:CreateLog", "stash", "Received Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) received item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount.. "** stash: *" .. stashId .. "*")
						end
						SaveStashItems(stashId, Stashes[stashId].items)
						TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", true)
						AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info, fromItemData["created"])
					end

				else
					local toItemData = Stashes[stashId].items[toSlot]
					RemoveFromStash(stashId, fromSlot, itemInfo["name"], fromAmount)
					if toItemData ~= nil then
						local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
						if toItemData.amount >= toAmount then
							if toItemData.name ~= fromItemData.name then
								local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
								RemoveFromStash(stashId, toSlot, itemInfo["name"], toAmount)
								AddToStash(stashId, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info, itemInfo["created"])
							end
						else
							TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** stash: *" .. stashId .. "*")
						end
					end
					itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
					AddToStash(stashId, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info, itemInfo["created"])
				end
			else
				QBCore.Functions.Notify(src, Lang:t("notify.itemexist"), "error")
			end
		else
			TriggerEvent('mh-stashes:server:not_allowed_to_loot', src)
		end

	elseif QBCore.Shared.SplitStr(fromInventory, "-")[1] == "traphouse" then
		local traphouseId = QBCore.Shared.SplitStr(fromInventory, "_")[2]
		local fromItemData = exports['qb-traphouse']:GetInventoryData(traphouseId, fromSlot)
		fromAmount = tonumber(fromAmount) or fromItemData.amount
		if fromItemData and fromItemData.amount >= fromAmount then
			local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = GetItemBySlot(src, toSlot)
				if Config.Stashes[fromItemData.name:lower()] then
					local hasItem = QBCore.Functions.HasItem(src, fromItemData.name:lower(), 1)
					if hasItem then
						TriggerEvent('mh-stashes:server:max_carry_item', src)
					else
						exports['qb-traphouse']:RemoveHouseItem(traphouseId, fromSlot, itemInfo["name"], fromAmount)
						if toItemData ~= nil then
							itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
							local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
							if toItemData.amount >= toAmount then
								if toItemData.name ~= fromItemData.name then
									RemoveItem(src, toItemData.name, toAmount, toSlot)
									TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "remove", true)
									exports['qb-traphouse']:AddHouseItem(traphouseId, fromSlot, itemInfo["name"], toAmount, toItemData.info, src)
									TriggerEvent("qb-log:server:CreateLog", "stash", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** stash: *" .. traphouseId .. "*")
								else
									TriggerEvent("qb-log:server:CreateLog", "stash", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** from stash: *" .. traphouseId .. "*")
								end
							else
								TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** stash: *" .. traphouseId .. "*")
							end
						else
							TriggerEvent("qb-log:server:CreateLog", "stash", "Received Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) received item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount.. "** stash: *" .. traphouseId .. "*")
						end
						TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", true)
						AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info, fromItemData["created"])
					end
				else
					exports['qb-traphouse']:RemoveHouseItem(traphouseId, fromSlot, itemInfo["name"], fromAmount)
					if toItemData ~= nil then
						itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
						local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
						if toItemData.amount >= toAmount then
							if toItemData.name ~= fromItemData.name then
								RemoveItem(src, toItemData.name, toAmount, toSlot)
								TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "remove")
								exports['qb-traphouse']:AddHouseItem(traphouseId, fromSlot, itemInfo["name"], toAmount, toItemData.info, src)
								TriggerEvent("qb-log:server:CreateLog", "stash", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** stash: *" .. traphouseId .. "*")
							else
								TriggerEvent("qb-log:server:CreateLog", "stash", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** from stash: *" .. traphouseId .. "*")
							end
						else
							TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** stash: *" .. traphouseId .. "*")
						end
					else
						TriggerEvent("qb-log:server:CreateLog", "stash", "Received Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) received item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount.. "** stash: *" .. traphouseId .. "*")
					end
					TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add")
					AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info, fromItemData["created"])
				end
			else
				local toItemData = exports['qb-traphouse']:GetInventoryData(traphouseId, toSlot)
				exports['qb-traphouse']:RemoveHouseItem(traphouseId, fromSlot, itemInfo["name"], fromAmount)
                if toItemData ~= nil then
                    local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                    if toItemData.amount >= toAmount then
						if toItemData.name ~= fromItemData.name then
                            local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
							exports['qb-traphouse']:RemoveHouseItem(traphouseId, toSlot, itemInfo["name"], toAmount)
							exports['qb-traphouse']:AddHouseItem(traphouseId, fromSlot, itemInfo["name"], toAmount, toItemData.info, src)
						end
                    else
                        TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** stash: *" .. traphouseId .. "*")
                    end
				end
				itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
				exports['qb-traphouse']:AddHouseItem(traphouseId, toSlot, itemInfo["name"], fromAmount, fromItemData.info, src)
			end
		else
            QBCore.Functions.Notify(src, Lang:t('notify.not_exist'), "error")
		end
	elseif QBCore.Shared.SplitStr(fromInventory, "-")[1] == "itemshop" then
		local shopType = QBCore.Shared.SplitStr(fromInventory, "-")[2]
		local itemData = ShopItems[shopType].items[fromSlot]
		local itemInfo = QBCore.Shared.Items[itemData.name:lower()]
		local bankBalance = Player.PlayerData.money["bank"]
		local price = tonumber((itemData.price*fromAmount))

		if QBCore.Shared.SplitStr(shopType, "_")[1] == "Dealer" then
			if QBCore.Shared.SplitStr(itemData.name, "_")[1] == "weapon" then
				price = tonumber(itemData.price)
				if Player.Functions.RemoveMoney("cash", price, "dealer-item-bought") then
					itemData.info.serie = tostring(QBCore.Shared.RandomInt(2) .. QBCore.Shared.RandomStr(3) .. QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(4))
					itemData.info.quality = 100
					AddItem(src, itemData.name, 1, toSlot, itemData.info)
					TriggerClientEvent('qb-drugs:client:updateDealerItems', src, itemData, 1)
					QBCore.Functions.Notify(src, itemInfo["label"] .. " bought!", "success")
					TriggerEvent("qb-log:server:CreateLog", "dealers", "Dealer item bought", "green", "**"..GetPlayerName(src) .. "** bought a " .. itemInfo["label"] .. " for $"..price)
				else
					QBCore.Functions.Notify(src, Lang:t('notify.no_cash'), "error")
				end
			else
				if Player.Functions.RemoveMoney("cash", price, "dealer-item-bought") then
					AddItem(src, itemData.name, fromAmount, toSlot, itemData.info)
					TriggerClientEvent('qb-drugs:client:updateDealerItems', src, itemData, fromAmount)
					QBCore.Functions.Notify(src, itemInfo["label"] .. " bought!", "success")
					TriggerEvent("qb-log:server:CreateLog", "dealers", "Dealer item bought", "green", "**"..GetPlayerName(src) .. "** bought a " .. itemInfo["label"] .. "  for $"..price)
				else
					QBCore.Functions.Notify(src, Lang:t('notify.no_cash'), "error")
				end
			end
		elseif QBCore.Shared.SplitStr(shopType, "_")[1] == "Itemshop" then
            if Player.Functions.RemoveMoney("cash", price, "itemshop-bought-item") then
                if QBCore.Shared.SplitStr(itemData.name, "_")[1] == "weapon" then
                    itemData.info.serie = tostring(QBCore.Shared.RandomInt(2) .. QBCore.Shared.RandomStr(3) .. QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(4))
                    itemData.info.quality = 100
                end
                local serial = itemData.info.serie
                local imageurl = ("https://cfx-nui-ps-inventory/html/images/%s.png"):format(itemData.name)
                local notes = "Purchased at Ammunation"
                local owner = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
                local weapClass = 1
                local weapModel = QBCore.Shared.Items[itemData.name].label
                AddItem(src, itemData.name, fromAmount, toSlot, itemData.info)
                TriggerClientEvent('qb-shops:client:UpdateShop', src, QBCore.Shared.SplitStr(shopType, "_")[2], itemData, fromAmount)
                QBCore.Functions.Notify(src, itemInfo["label"] .. " bought!", "success")
                --exports['ps-mdt']:CreateWeaponInfo(serial, imageurl, notes, owner, weapClass, weapModel)
                TriggerEvent("qb-log:server:CreateLog", "shops", "Shop item bought", "green", "**"..GetPlayerName(src) .. "** bought a " .. itemInfo["label"] .. " for $"..price)
        elseif bankBalance >= price then
                Player.Functions.RemoveMoney("bank", price, "itemshop-bought-item")
                if QBCore.Shared.SplitStr(itemData.name, "_")[1] == "weapon" then
                    itemData.info.serie = tostring(QBCore.Shared.RandomInt(2) .. QBCore.Shared.RandomStr(3) .. QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(4))
                    itemData.info.quality = 100
                end
                local serial = itemData.info.serie
                local imageurl = ("https://cfx-nui-ps-inventory/html/images/%s.png"):format(itemData.name)
                local notes = "Purchased at Ammunation"
                local owner = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
                local weapClass = 1
                local weapModel = QBCore.Shared.Items[itemData.name].label
                AddItem(src, itemData.name, fromAmount, toSlot, itemData.info)
                TriggerClientEvent('qb-shops:client:UpdateShop', src, QBCore.Shared.SplitStr(shopType, "_")[2], itemData, fromAmount)
                QBCore.Functions.Notify(src, itemInfo["label"] .. " bought!", "success")
				--exports['ps-mdt']:CreateWeaponInfo(serial, imageurl, notes, owner, weapClass, weapModel)
                TriggerEvent("qb-log:server:CreateLog", "shops", "Shop item bought", "green", "**"..GetPlayerName(src) .. "** bought a " .. itemInfo["label"] .. " for $"..price)
            else
                QBCore.Functions.Notify(src, Lang:t('notify.no_cash'), "error")
            end
		else
			if Player.Functions.RemoveMoney("cash", price, "unkown-itemshop-bought-item") then
				if itemData.name:lower() == 'wallet' then itemData.info.walletid = math.random(11111, 99999) end
				AddItem(src, itemData.name, fromAmount, toSlot, itemData.info)
				QBCore.Functions.Notify(src, itemInfo["label"] .. " bought!", "success")
				TriggerEvent("qb-log:server:CreateLog", "shops", "Shop item bought", "green", "**"..GetPlayerName(src) .. "** bought a " .. itemInfo["label"] .. " for $"..price)
			elseif bankBalance >= price then
				Player.Functions.RemoveMoney("bank", price, "unkown-itemshop-bought-item")
				if itemData.name:lower() == 'wallet' then itemData.info.walletid = math.random(11111, 99999) end
				AddItem(src, itemData.name, fromAmount, toSlot, itemData.info)
				QBCore.Functions.Notify(src, itemInfo["label"] .. " bought!", "success")
				TriggerEvent("qb-log:server:CreateLog", "shops", "Shop item bought", "green", "**"..GetPlayerName(src) .. "** bought a " .. itemInfo["label"] .. " for $"..price)
			else
				QBCore.Functions.Notify(src, Lang:t('notify.no_cash'), "error")
			end
		end
	elseif fromInventory == "crafting" then
		local itemData = Config.CraftingItems[fromSlot]
		if hasCraftItems(src, itemData.costs, fromAmount) then
			TriggerClientEvent("inventory:client:CraftItems", src, itemData.name, itemData.costs, fromAmount, toSlot, itemData.points)
		else
			TriggerClientEvent("inventory:client:UpdatePlayerInventory", src, true)
			QBCore.Functions.Notify(src, Lang:t('notify.not_the_right_items'), "error")
		end
	elseif fromInventory == "attachment_crafting" then
		local itemData = Config.AttachmentCrafting["items"][fromSlot]
		if hasCraftItems(src, itemData.costs, fromAmount) then
			TriggerClientEvent("inventory:client:CraftAttachment", src, itemData.name, itemData.costs, fromAmount, toSlot, itemData.points)
		else
			TriggerClientEvent("inventory:client:UpdatePlayerInventory", src, true)
			QBCore.Functions.Notify(src, Lang:t('notify.not_the_right_items'), "error")
		end
	else
		-- drop
		fromInventory = tonumber(fromInventory)
		local fromItemData = Drops[fromInventory].items[fromSlot]
		fromAmount = tonumber(fromAmount) or fromItemData.amount
		if fromItemData and fromItemData.amount >= fromAmount then
			local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = GetItemBySlot(src, toSlot)
				if Config.Stashes[fromItemData.name:lower()] then
					local hasItem = QBCore.Functions.HasItem(src, fromItemData.name:lower(), 1)
					if hasItem then
						TriggerEvent('mh-stashes:server:max_carry_item', src)
					else
						RemoveFromDrop(fromInventory, fromSlot, itemInfo["name"], fromAmount)
						if toItemData ~= nil then
							toAmount = tonumber(toAmount) and tonumber(toAmount) or toItemData.amount
							if toItemData.amount >= toAmount then
								if toItemData.name ~= fromItemData.name then
									itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
									RemoveItem(src, toItemData.name, toAmount, toSlot)
									TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "remove", true)
									AddToDrop(fromInventory, toSlot, itemInfo["name"], toAmount, toItemData.info, itemInfo["created"])
									if itemInfo["name"] == "radio" then TriggerClientEvent('Radio.Set', src, false) end
									TriggerEvent("qb-log:server:CreateLog", "drop", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** - dropid: *" .. fromInventory .. "*")
								else
									TriggerEvent("qb-log:server:CreateLog", "drop", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** - from dropid: *" .. fromInventory .. "*")
								end
							else
								TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** - dropid: *" .. fromInventory .. "*")
							end
						else
							TriggerEvent("qb-log:server:CreateLog", "drop", "Received Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) received item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount.. "** -  dropid: *" .. fromInventory .. "*")
						end
						TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", true)
						AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info, fromItemData["created"])
					end
				else
					RemoveFromDrop(fromInventory, fromSlot, itemInfo["name"], fromAmount)
					if toItemData ~= nil then
						toAmount = tonumber(toAmount) and tonumber(toAmount) or toItemData.amount
						if toItemData.amount >= toAmount then
							if toItemData.name ~= fromItemData.name then
								itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
								RemoveItem(src, toItemData.name, toAmount, toSlot)
								TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "remove", true)
								AddToDrop(fromInventory, toSlot, itemInfo["name"], toAmount, toItemData.info, itemInfo["created"])
								if itemInfo["name"] == "radio" then TriggerClientEvent('Radio.Set', src, false) end
								TriggerEvent("qb-log:server:CreateLog", "drop", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** - dropid: *" .. fromInventory .. "*")
							else
								TriggerEvent("qb-log:server:CreateLog", "drop", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** - from dropid: *" .. fromInventory .. "*")
							end
						else
							TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** - dropid: *" .. fromInventory .. "*")
						end
					else
						TriggerEvent("qb-log:server:CreateLog", "drop", "Received Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) received item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount.. "** -  dropid: *" .. fromInventory .. "*")
					end
					TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", true)
					AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info, fromItemData["created"])
				end
			else
				toInventory = tonumber(toInventory)
				local toItemData = Drops[toInventory].items[toSlot]
				RemoveFromDrop(fromInventory, fromSlot, itemInfo["name"], fromAmount)
                if toItemData ~= nil then
                    local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                    if toItemData.amount >= toAmount then
						if toItemData.name ~= fromItemData.name then
							local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
							RemoveFromDrop(toInventory, toSlot, itemInfo["name"], toAmount)
							AddToDrop(fromInventory, fromSlot, itemInfo["name"], toAmount, toItemData.info, itemInfo["created"])
							if itemInfo["name"] == "radio" then TriggerClientEvent('Radio.Set', src, false) end
						end
                    else
                        TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** - dropid: *" .. fromInventory .. "*")
                    end
				end
				itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                AddToDrop(toInventory, toSlot, itemInfo["name"], fromAmount, fromItemData.info, itemInfo["created"])
				if itemInfo["name"] == "radio" then TriggerClientEvent('Radio.Set', src, false) end
			end
		else
            QBCore.Functions.Notify(src, Lang:t('notify.not_exist'), "error")
		end
	end
end)
```





## 🙈 Youtube & Discord
- [Youtube](https://www.youtube.com/c/MaDHouSe79)
- [Discord](https://discord.gg/cEMSeE9dgS)

# LICENSE
[GPL LICENSE](./LICENSE)<br />
&copy; [MaDHouSe79](https://www.youtube.com/@MaDHouSe79)
