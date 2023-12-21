## **INSTALL FOR PS INVENTORY**

# Add in ps-inventory/client/main.lua from line 136
```lua
local function OpenTrunk()
    local vehicle = QBCore.Functions.GetClosestVehicle()
    LoadAnimDict("amb@prop_human_bum_bin@idle_b")
    TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "idle_d", 4.0, 4.0, -1, 50, 0, false, false, false)
    if IsBackEngine(GetEntityModel(vehicle)) then
        SetVehicleDoorOpen(vehicle, 4, false, false)
    else
        SetVehicleDoorOpen(vehicle, 5, false, false)
    end
end

local function isAllowToOpen(vehicle)
    if GetVehicleClass(vehicle) == 18 then
        if PlayerData.job.name == 'police' or PlayerData.job.name == 'ambulance' then
            return true
        end
    else 
        return true
    end
end
```

# Replace this code below in ps-inventory/client/main.lua
```lua
RegisterCommand('inventory', function()
    if not isCrafting and not inInventory then
        if not PlayerData.metadata["isdead"] and not PlayerData.metadata["inlaststand"] and not PlayerData.metadata["ishandcuffed"] and not IsPauseMenuActive() then
            local ped = PlayerPedId()
            local curVeh = nil
            local VendingMachine = GetClosestVending()

            if IsPedInAnyVehicle(ped) then -- Is Player In Vehicle
                local vehicle = GetVehiclePedIsIn(ped, false)
                CurrentGlovebox = QBCore.Functions.GetPlate(vehicle)
                curVeh = vehicle
                CurrentVehicle = nil
            else
                local vehicle = QBCore.Functions.GetClosestVehicle()
                if vehicle ~= 0 and vehicle ~= nil then
                    local pos = GetEntityCoords(ped)
                    local trunkpos = GetOffsetFromEntityInWorldCoords(vehicle, 0, -2.5, 0)
                    if (IsBackEngine(GetEntityModel(vehicle))) then
                        trunkpos = GetOffsetFromEntityInWorldCoords(vehicle, 0, 2.5, 0)
                    end
                    if #(pos - trunkpos) < 2.0 and not IsPedInAnyVehicle(ped) then
                        if GetVehicleDoorLockStatus(vehicle) < 2 then
                            CurrentVehicle = QBCore.Functions.GetPlate(vehicle)
                            curVeh = vehicle
                            CurrentGlovebox = nil
                        else
                            QBCore.Functions.Notify("Vehicle Locked", "error")
                            return
                        end
                    else
                        CurrentVehicle = nil
                    end
                else
                    CurrentVehicle = nil
                end
            end
            if CurrentVehicle then -- Trunk
                local vehicleClass = GetVehicleClass(curVeh)
                local maxweight = Config.TrunkSpace[vehicleClass].weight
                local slots = Config.TrunkSpace[vehicleClass].slots
                local other = {
                    maxweight = maxweight,
                    slots = slots,
                }
                if Config.OnlyJobCanOpenJobVehicleTrucks then
                    local canOpen = isAllowToOpen(curVeh)
                    if canOpen then 
                        TriggerServerEvent("inventory:server:OpenInventory", "trunk", CurrentVehicle, other)
                        OpenTrunk()
                    else
                        QBCore.Functions.Notify("No access", "error", 5000)
                    end
                else
                    TriggerServerEvent("inventory:server:OpenInventory", "trunk", CurrentVehicle, other)
                    OpenTrunk()
                end
            elseif CurrentGlovebox then
                TriggerServerEvent("inventory:server:OpenInventory", "glovebox", CurrentGlovebox)
            elseif CurrentDrop then
                TriggerServerEvent("inventory:server:OpenInventory", "drop", CurrentDrop)
            elseif VendingMachine then
                local ShopItems = {}
                ShopItems.label = "Vending Machine"
                ShopItems.items = Config.VendingItem
                ShopItems.slots = #Config.VendingItem
                TriggerServerEvent("inventory:server:OpenInventory", "shop", "Vendingshop_"..math.random(1, 99), ShopItems)
            else
                openAnim()
                TriggerServerEvent("inventory:server:OpenInventory")
            end
        end
    end
end)
```
- Change code in ps-inventory/server.lua

# Add 2x this code in ps-inventory/server/main.lua
- Find: `inventory:server:UseItemSlot`
```lua
if Config.Stashes[itemData.name:lower()] then lastUsedStashItem = itemData end
```
# It should look like this
```lua
RegisterNetEvent('inventory:server:UseItemSlot', function(slot)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local itemData = Player.Functions.GetItemBySlot(slot)
    if itemData then
        local itemInfo = QBCore.Shared.Items[itemData.name]
        if itemData.type == "weapon" then
            if itemData.info.quality then
                if itemData.info.quality > 0 then
                    TriggerClientEvent("inventory:client:UseWeapon", src, itemData, true)
                else
                    TriggerClientEvent("inventory:client:UseWeapon", src, itemData, false)
                end
            else
                TriggerClientEvent("inventory:client:UseWeapon", src, itemData, true)
            end
            TriggerClientEvent('inventory:client:ItemBox', src, itemInfo, "use")
        elseif itemData.useable then
            if itemData.info.quality then
                if itemData.info.quality > 0 then
                    if Config.Stashes[itemData.name:lower()] then lastUsedStashItem = itemData end --<-- ADD HERE
                    UseItem(itemData.name, src, itemData)
                    TriggerClientEvent('inventory:client:ItemBox', src, itemInfo, "use")
                else
                    if itemInfo['delete'] and RemoveItem(src, itemData.name, 1, slot) then
                        TriggerClientEvent('inventory:client:ItemBox', src, itemInfo, "remove")
                    else
                        TriggerClientEvent("QBCore:Notify", src, "You can't use this item", "error")
                    end
                end
            else
                if itemData.name == "weapon_hazardcan" or itemData.name == "weapon_petrolcan" or itemData.name == "weapon_fireextinguisher" then
                    TriggerClientEvent("inventory:client:UseWeapon", src, itemData, true)
                end
                if Config.Stashes[itemData.name:lower()] then lastUsedStashItem = itemData end --<-- ADD HERE
                UseItem(itemData.name, src, itemData)
                TriggerClientEvent('inventory:client:ItemBox', src, itemInfo, "use")
            end
        end
    end
end)
```

# Add 1x this code in ps-inventory/server/main.lua
- Find: `inventory:server:UseItem`
```lua
if Config.Stashes[itemData.name:lower()] then lastUsedStashItem = itemData end
```
# It should look like this
```lua
RegisterNetEvent('inventory:server:UseItem', function(inventory, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if inventory == "player" or inventory == "hotbar" then
        local itemData = Player.Functions.GetItemBySlot(item.slot)
        if itemData then
            local itemInfo = QBCore.Shared.Items[itemData.name]
            if itemData.type ~= "weapon" then
                if itemData.info.quality then
                    if itemData.info.quality <= 0 then
                        if itemInfo['delete'] and RemoveItem(src, itemData.name, 1, item.slot) then
                            TriggerClientEvent("QBCore:Notify", src, "You can't use this item", "error")
                            TriggerClientEvent('inventory:client:ItemBox', src, itemInfo, "remove")
                            return
                        else
                            TriggerClientEvent("QBCore:Notify", src, "You can't use this item", "error")
                            return
                        end
                    end
                end
            elseif itemData.type == "weapon" then
                if itemData.name == "weapon_hazardcan" or itemData.name == "weapon_petrolcan" or itemData.name == "weapon_fireextinguisher" then
                    TriggerClientEvent("inventory:client:UseWeapon", src, itemData, true)
                end
            end
            if Config.Stashes[itemData.name:lower()] then lastUsedStashItem = itemData end --<-- ADD HERE
            UseItem(itemData.name, src, itemData)
            TriggerClientEvent('inventory:client:ItemBox', src, itemInfo, "use")
        end
    end
end)
```

# Replace this code in ps-inventory/server/main.lua
```lua
RegisterNetEvent('inventory:server:SetInventoryData', function(fromInventory, toInventory, fromSlot, toSlot, fromAmount, toAmount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    fromSlot = tonumber(fromSlot)
    toSlot = tonumber(toSlot)
    if (fromInventory == "player" or fromInventory == "hotbar") and
        (QBCore.Shared.SplitStr(toInventory, "-")[1] == "itemshop" or toInventory == "crafting") then
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
                            AddItem(src, toItemData.name, toAmount, fromSlot, toItemData.info)
                            TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "add", false)
                        end
                    else
                        TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red",
                            "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                "* | *" .. src .. "*) swapped item; name: **" .. toItemData.name .. "**, amount: **" ..
                                toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" ..
                                fromAmount .. "**")
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
                TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "remove", true)
                TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
                if toItemData ~= nil then
                    local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                    local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                    if itemDataTest.amount >= toAmount then
                        if toItemData.name ~= fromItemData.name then
                            RemoveItem(playerId, itemInfo["name"], toAmount, fromSlot)
                            TriggerEvent('mh-cashasitem:server:updateCash', playerId, toItemData, toAmount,
                                "remove", true)
                            AddItem(src, toItemData.name, toAmount, fromSlot, toItemData.info)
                            TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "add", true)
                            TriggerEvent("qb-log:server:CreateLog", "robbing", "Swapped Item", "orange",
                                "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                    "* | *" .. src .. "*) swapped item; name: **" .. itemInfo["name"] ..
                                    "**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name ..
                                    "**, amount: **" .. fromAmount .. "** with player: **" ..
                                    GetPlayerName(OtherPlayer.PlayerData.source) .. "** (citizenid: *" ..
                                    OtherPlayer.PlayerData.citizenid .. "* | id: *" .. OtherPlayer.PlayerData.source ..
                                    "*)")
                        end
                    else
                        TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red",
                            "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                "* | *" .. src .. "*) swapped item; name: **" .. itemInfo["name"] ..
                                "**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name ..
                                "**, amount: **" .. fromAmount .. "** with player: **" ..
                                GetPlayerName(OtherPlayer.PlayerData.source) .. "** (citizenid: *" ..
                                OtherPlayer.PlayerData.citizenid .. "* | id: *" .. OtherPlayer.PlayerData.source ..
                                "*)")
                    end
                else
                    local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                    TriggerEvent("qb-log:server:CreateLog", "robbing", "Dropped Item", "red",
                        "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid .. "* | *" ..
                            src .. "*) dropped new item; name: **" .. itemInfo["name"] .. "**, amount: **" ..
                            fromAmount .. "** to player: **" .. GetPlayerName(OtherPlayer.PlayerData.source) ..
                            "** (citizenid: *" .. OtherPlayer.PlayerData.citizenid .. "* | id: *" ..
                            OtherPlayer.PlayerData.source .. "*)")
                end
                local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                TriggerEvent('mh-cashasitem:server:updateCash', playerId, fromItemData, fromAmount, "add", true)
                AddItem(playerId, itemInfo["name"], fromAmount, toSlot, fromItemData.info, itemInfo["created"])
            elseif QBCore.Shared.SplitStr(toInventory, "-")[1] == "trunk" then
                local plate = QBCore.Shared.SplitStr(toInventory, "-")[2]
                local toItemData = Trunks[plate].items[toSlot]
                RemoveItem(src, fromItemData.name, fromAmount, fromSlot)
                TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "remove", true)
                TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
                if Config.Stashes[fromItemData.name:lower()] then
                    TriggerEvent('mh-stashes:client:RemoveProp', src)
                end
                if toItemData ~= nil then
                    local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                    local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                    if toItemData.amount >= toAmount then
                        if toItemData.name ~= fromItemData.name then
                            RemoveFromTrunk(plate, fromSlot, itemInfo["name"], toAmount)
                            AddItem(src, toItemData.name, toAmount, fromSlot, toItemData.info)
                            TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "add", true)
                            TriggerEvent("qb-log:server:CreateLog", "trunk", "Swapped Item", "orange",
                                "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                    "* | id: *" .. src .. "*) swapped item; name: **" .. itemInfo["name"] ..
                                    "**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name ..
                                    "**, amount: **" .. fromAmount .. "** - plate: *" .. plate .. "*")
                        end
                    else
                        TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red",
                            "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                "* | *" .. src .. "*) swapped item; name: **" .. itemInfo["name"] ..
                                "**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name ..
                                "**, amount: **" .. fromAmount .. "** - plate: *" .. plate .. "*")
                    end
                else
                    local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                    TriggerEvent("qb-log:server:CreateLog", "trunk", "Dropped Item", "red",
                        "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                            "* | id: *" .. src .. "*) dropped new item; name: **" .. itemInfo["name"] ..
                            "**, amount: **" .. fromAmount .. "** - plate: *" .. plate .. "*")
                end
                local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                AddToTrunk(plate, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info,
                    itemInfo["created"])
            elseif QBCore.Shared.SplitStr(toInventory, "-")[1] == "glovebox" then
                local plate = QBCore.Shared.SplitStr(toInventory, "-")[2]
                local toItemData = Gloveboxes[plate].items[toSlot]
                RemoveItem(src, fromItemData.name, fromAmount, fromSlot)
                if Config.Stashes[fromItemData.name:lower()] then
                    TriggerEvent('mh-stashes:client:RemoveProp', src)
                end
                TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "remove", true)
                TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
                if toItemData ~= nil then
                    local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                    local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                    if toItemData.amount >= toAmount then
                        if toItemData.name ~= fromItemData.name then
                            RemoveFromGlovebox(plate, fromSlot, itemInfo["name"], toAmount)
                            AddItem(src, toItemData.name, toAmount, fromSlot, toItemData.info)
                            TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "add", true)
                            TriggerEvent("qb-log:server:CreateLog", "glovebox", "Swapped Item", "orange",
                                "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                    "* | id: *" .. src .. "*) swapped item; name: **" .. itemInfo["name"] ..
                                    "**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name ..
                                    "**, amount: **" .. fromAmount .. "** - plate: *" .. plate .. "*")
                        end
                    else
                        TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red",
                            "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                "* | *" .. src .. "*) swapped item; name: **" .. itemInfo["name"] ..
                                "**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name ..
                                "**, amount: **" .. fromAmount .. "** - plate: *" .. plate .. "*")
                    end
                else
                    local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                    TriggerEvent("qb-log:server:CreateLog", "glovebox", "Dropped Item", "red",
                        "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                            "* | id: *" .. src .. "*) dropped new item; name: **" .. itemInfo["name"] ..
                            "**, amount: **" .. fromAmount .. "** - plate: *" .. plate .. "*")
                end
                local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                AddToGlovebox(plate, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info,
                    itemInfo["created"])
            elseif QBCore.Shared.SplitStr(toInventory, "-")[1] == "stash" then
                local stashId = QBCore.Shared.SplitStr(toInventory, "-")[2]
                local toItemData = Stashes[stashId].items[toSlot]

                -- mh-stashes (start)
                local stash = QBCore.Shared.SplitStr(stashId, "_")[1]
                local canuse = IsItemAllowedToAdd(src, stash, fromItemData)
                print("To stash: " .. stash, "Can Use: " .. tostring(canuse))
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
                            TriggerEvent("qb-log:server:CreateLog", "stash", "Swapped Item", "orange",
                                "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                    "* | id: *" .. src .. "*) swapped item; name: **" .. itemInfo["name"] ..
                                    "**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name ..
                                    "**, amount: **" .. fromAmount .. "** - stash: *" .. stashId .. "*")
                        else
                            TriggerEvent("qb-log:server:CreateLog", "stash", "Stacked Item", "orange",
                                "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                    "* | id: *" .. src .. "*) stacked item; name: **" .. toItemData.name ..
                                    "**, amount: **" .. toAmount .. "** - from dropid: *" .. fromInventory .. "*")
                        end
                    else
                        local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                        TriggerEvent("qb-log:server:CreateLog", "stash", "Dropped Item", "red",
                            "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                "* | id: *" .. src .. "*) dropped new item; name: **" .. itemInfo["name"] ..
                                "**, amount: **" .. fromAmount .. "** - stash: *" .. stashId .. "*")
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
                    TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "remove", true)
                    TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
                    if toItemData ~= nil then
                        local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                        local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                        if toItemData.amount >= toAmount then
                            if toItemData.name ~= fromItemData.name then
                                exports['qb-traphouse']:RemoveHouseItem(traphouseId, fromSlot, itemInfo["name"],
                                    toAmount)
                                AddItem(src, toItemData.name, toAmount, fromSlot, toItemData.info)
                                TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "add",
                                    true)
                                TriggerEvent("qb-log:server:CreateLog", "traphouse", "Swapped Item", "orange",
                                    "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                        "* | id: *" .. src .. "*) swapped item; name: **" .. itemInfo["name"] ..
                                        "**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name ..
                                        "**, amount: **" .. fromAmount .. "** - traphouse: *" .. traphouseId .. "*")
                            end
                        else
                            TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red",
                                "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                    "* | *" .. src .. "*) swapped item; name: **" .. itemInfo["name"] ..
                                    "**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name ..
                                    "**, amount: **" .. fromAmount .. "** - traphouse: *" .. traphouseId .. "*")
                        end
                    else
                        local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                        TriggerEvent("qb-log:server:CreateLog", "traphouse", "Dropped Item", "red",
                            "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                "* | id: *" .. src .. "*) dropped new item; name: **" .. itemInfo["name"] ..
                                "**, amount: **" .. fromAmount .. "** - traphouse: *" .. traphouseId .. "*")
                    end
                    local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                    exports['qb-traphouse']:AddHouseItem(traphouseId, toSlot, itemInfo["name"], fromAmount,
                        fromItemData.info, src)
                else
                    QBCore.Functions.Notify(src, Lang:t('notify.can_not_sell_item'), 'error')
                end
            else
                -- drop
                toInventory = tonumber(toInventory)
                if toInventory == nil or toInventory == 0 then
                    if Config.Stashes[fromItemData.name:lower()] then
                        local coords = GetEntityCoords(GetPlayerPed(src))
                        local pos = {
                            ["x"] = coords.x + 0.5,
                            ["y"] = coords.y + 0.5,
                            ["z"] = coords.z
                        }
                        TriggerEvent('mh-stashes:server:dropstash', src, fromItemData, pos)
                    else
                        CreateNewDrop(src, fromSlot, toSlot, fromAmount)
                        TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "remove",
                            true)
                    end
                else
                    local toItemData = Drops[toInventory].items[toSlot]
                    -- mh-stashes (start)
                    local stash = QBCore.Shared.SplitStr(stashId, "_")[1]
                    local canuse = IsStashItemLootable(src, stash, fromItemData)
                    print("To stash: " .. stash, "Can Use: " .. tostring(canuse))
                    -- mh-stashes (end)
                    --if canuse then
                        RemoveItem(src, fromItemData.name, fromAmount, fromSlot)
                        TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "remove", true)
                        TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
                        if toItemData ~= nil then
                            local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                            local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                            if toItemData.amount >= toAmount then
                                if toItemData.name ~= fromItemData.name then
                                    AddItem(toItemData.name, toAmount, fromSlot, toItemData.info)
                                    TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount,
                                        "add", true)
                                    RemoveFromDrop(toInventory, fromSlot, itemInfo["name"], toAmount)
                                    TriggerEvent("qb-log:server:CreateLog", "drop", "Swapped Item", "orange",
                                        "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                            "* | id: *" .. src .. "*) swapped item; name: **" .. itemInfo["name"] ..
                                            "**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name ..
                                            "**, amount: **" .. fromAmount .. "** - dropid: *" .. toInventory .. "*")
                                end
                            else
                                TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red",
                                    "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                        "* | *" .. src .. "*) swapped item; name: **" .. itemInfo["name"] ..
                                        "**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name ..
                                        "**, amount: **" .. fromAmount .. "** - dropid: *" .. toInventory .. "*")
                            end
                        else
                            local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                            TriggerEvent("qb-log:server:CreateLog", "drop", "Dropped Item", "red",
                                "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                    "* | id: *" .. src .. "*) dropped new item; name: **" .. itemInfo["name"] ..
                                    "**, amount: **" .. fromAmount .. "** - dropid: *" .. toInventory .. "*")
                        end
                        local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                        AddToDrop(toInventory, toSlot, itemInfo["name"], fromAmount, fromItemData.info,
                            itemInfo["created"])
                        if itemInfo["name"] == "radio" then
                            TriggerClientEvent('Radio.Set', src, false)
                        end
                    --end
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
                if Config.Stashes[fromItemData.name] then
                    local hasItem = QBCore.Functions.HasItem(src, fromItemData.name:lower(), 1)
                    if hasItem then
                        TriggerEvent('mh-stashes:server:max_carry_item', src)
                    else
                        RemoveItem(playerId, itemInfo["name"], fromAmount, fromSlot)
                        TriggerEvent('mh-cashasitem:server:updateCash', playerId, fromItemData, fromAmount,
                            "remove", true)
                        TriggerClientEvent("inventory:client:CheckWeapon", OtherPlayer.PlayerData.source,
                            fromItemData.name)
                        if toItemData ~= nil then
                            itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                            local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                            if toItemData.amount >= toAmount then
                                if toItemData.name ~= fromItemData.name then
                                    RemoveItem(src, toItemData.name, toAmount, toSlot)
                                    TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount,
                                        "remove", true)
                                    AddItem(playerId, itemInfo["name"], toAmount, fromSlot, toItemData.info)
                                    TriggerEvent('mh-cashasitem:server:updateCash', playerId, toItemData, toAmount,
                                        "add", true)

                                    TriggerEvent("qb-log:server:CreateLog", "robbing", "Swapped Item", "orange",
                                        "**" .. GetPlayerName(src) .. "** (citizenid: *" ..
                                            Player.PlayerData.citizenid .. "* | id: *" .. src ..
                                            "*) swapped item; name: **" .. toItemData.name .. "**, amount: **" ..
                                            toAmount .. "** with item; **" .. itemInfo["name"] .. "**, amount: **" ..
                                            toAmount .. "** from player: **" ..
                                            GetPlayerName(OtherPlayer.PlayerData.source) .. "** (citizenid: *" ..
                                            OtherPlayer.PlayerData.citizenid .. "* | *" ..
                                            OtherPlayer.PlayerData.source .. "*)")
                                end
                            else
                                TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red",
                                    "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                        "* | *" .. src .. "*) swapped item; name: **" .. itemInfo["name"] ..
                                        "**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name ..
                                        "**, amount: **" .. fromAmount .. "** with player: **" ..
                                        GetPlayerName(OtherPlayer.PlayerData.source) .. "** (citizenid: *" ..
                                        OtherPlayer.PlayerData.citizenid .. "* | id: *" ..
                                        OtherPlayer.PlayerData.source .. "*)")
                            end
                        else
                            TriggerEvent("qb-log:server:CreateLog", "robbing", "Retrieved Item", "green",
                                "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                    "* | id: *" .. src .. "*) took item; name: **" .. fromItemData.name ..
                                    "**, amount: **" .. fromAmount .. "** from player: **" ..
                                    GetPlayerName(OtherPlayer.PlayerData.source) .. "** (citizenid: *" ..
                                    OtherPlayer.PlayerData.citizenid .. "* | *" .. OtherPlayer.PlayerData.source ..
                                    "*)")
                        end
                        TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", true)
                        AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info,
                            fromItemData["created"])
                    end
                else
                    RemoveItem(playerId, itemInfo["name"], fromAmount, fromSlot)
                    TriggerEvent('mh-cashasitem:server:updateCash', playerId, fromItemData, fromAmount, "remove",
                        true)
                    TriggerClientEvent("inventory:client:CheckWeapon", OtherPlayer.PlayerData.source,
                        fromItemData.name)
                    if toItemData ~= nil then
                        itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                        local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                        if toItemData.amount >= toAmount then
                            if toItemData.name ~= fromItemData.name then
                                RemoveItem(src, toItemData.name, toAmount, toSlot)
                                TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "remove",
                                    true)
                                AddItem(playerId, itemInfo["name"], toAmount, fromSlot, toItemData.info)
                                TriggerEvent('mh-cashasitem:server:updateCash', playerId, toItemData, toAmount,
                                    "add", true)
                                TriggerEvent("qb-log:server:CreateLog", "robbing", "Swapped Item", "orange",
                                    "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                        "* | id: *" .. src .. "*) swapped item; name: **" .. toItemData.name ..
                                        "**, amount: **" .. toAmount .. "** with item; **" .. itemInfo["name"] ..
                                        "**, amount: **" .. toAmount .. "** from player: **" ..
                                        GetPlayerName(OtherPlayer.PlayerData.source) .. "** (citizenid: *" ..
                                        OtherPlayer.PlayerData.citizenid .. "* | *" .. OtherPlayer.PlayerData.source ..
                                        "*)")
                            end
                        else
                            TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red",
                                "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                    "* | *" .. src .. "*) swapped item; name: **" .. itemInfo["name"] ..
                                    "**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name ..
                                    "**, amount: **" .. fromAmount .. "** with player: **" ..
                                    GetPlayerName(OtherPlayer.PlayerData.source) .. "** (citizenid: *" ..
                                    OtherPlayer.PlayerData.citizenid .. "* | id: *" .. OtherPlayer.PlayerData.source ..
                                    "*)")
                        end
                    else
                        TriggerEvent("qb-log:server:CreateLog", "robbing", "Retrieved Item", "green",
                            "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                "* | id: *" .. src .. "*) took item; name: **" .. fromItemData.name ..
                                "**, amount: **" .. fromAmount .. "** from player: **" ..
                                GetPlayerName(OtherPlayer.PlayerData.source) .. "** (citizenid: *" ..
                                OtherPlayer.PlayerData.citizenid .. "* | *" .. OtherPlayer.PlayerData.source .. "*)")
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
                        TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red",
                            "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                "* | *" .. src .. "*) swapped item; name: **" .. itemInfo["name"] ..
                                "**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name ..
                                "**, amount: **" .. fromAmount .. "** with player: **" ..
                                GetPlayerName(OtherPlayer.PlayerData.source) .. "** (citizenid: *" ..
                                OtherPlayer.PlayerData.citizenid .. "* | id: *" .. OtherPlayer.PlayerData.source ..
                                "*)")
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
                                    TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount,
                                        "remove", true)
                                    AddToTrunk(plate, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info,
                                        itemInfo["created"])
                                    TriggerEvent("qb-log:server:CreateLog", "trunk", "Swapped Item", "orange",
                                        "**" .. GetPlayerName(src) .. "** (citizenid: *" ..
                                            Player.PlayerData.citizenid .. "* | id: *" .. src ..
                                            "*) swapped item; name: **" .. toItemData.name .. "**, amount: **" ..
                                            toAmount .. "** with item; name: **" .. itemInfo["name"] ..
                                            "**, amount: **" .. toAmount .. "** plate: *" .. plate .. "*")
                                else
                                    TriggerEvent("qb-log:server:CreateLog", "trunk", "Stacked Item", "orange",
                                        "**" .. GetPlayerName(src) .. "** (citizenid: *" ..
                                            Player.PlayerData.citizenid .. "* | id: *" .. src ..
                                            "*) stacked item; name: **" .. toItemData.name .. "**, amount: **" ..
                                            toAmount .. "** from plate: *" .. plate .. "*")
                                end
                            else
                                TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red",
                                    "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                        "* | *" .. src .. "*) swapped item; name: **" .. toItemData.name ..
                                        "**, amount: **" .. toAmount .. "** with name: **" .. itemInfo["name"] ..
                                        "**, amount: **" .. toAmount .. "** plate: *" .. plate .. "*")
                            end
                        else
                            TriggerEvent("qb-log:server:CreateLog", "trunk", "Received Item", "green",
                                "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                    "* | id: *" .. src .. "*) received item; name: **" .. fromItemData.name ..
                                    "**, amount: **" .. fromAmount .. "** plate: *" .. plate .. "*")
                        end
                        TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", true)
                        AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info,
                            fromItemData["created"])
                    end
                else
                    RemoveFromTrunk(plate, fromSlot, itemInfo["name"], fromAmount)
                    if toItemData ~= nil then
                        itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                        local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                        if toItemData.amount >= toAmount then
                            if toItemData.name ~= fromItemData.name then
                                RemoveItem(src, toItemData.name, toAmount, toSlot)
                                TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "remove",
                                    true)
                                AddToTrunk(plate, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info,
                                    itemInfo["created"])
                                TriggerEvent("qb-log:server:CreateLog", "trunk", "Swapped Item", "orange",
                                    "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                        "* | id: *" .. src .. "*) swapped item; name: **" .. toItemData.name ..
                                        "**, amount: **" .. toAmount .. "** with item; name: **" .. itemInfo["name"] ..
                                        "**, amount: **" .. toAmount .. "** plate: *" .. plate .. "*")
                            else
                                TriggerEvent("qb-log:server:CreateLog", "trunk", "Stacked Item", "orange",
                                    "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                        "* | id: *" .. src .. "*) stacked item; name: **" .. toItemData.name ..
                                        "**, amount: **" .. toAmount .. "** from plate: *" .. plate .. "*")
                            end
                        else
                            TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red",
                                "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                    "* | *" .. src .. "*) swapped item; name: **" .. toItemData.name ..
                                    "**, amount: **" .. toAmount .. "** with name: **" .. itemInfo["name"] ..
                                    "**, amount: **" .. toAmount .. "** plate: *" .. plate .. "*")
                        end
                    else
                        TriggerEvent("qb-log:server:CreateLog", "trunk", "Received Item", "green",
                            "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                "* | id: *" .. src .. "*) received item; name: **" .. fromItemData.name ..
                                "**, amount: **" .. fromAmount .. "** plate: *" .. plate .. "*")
                    end
                    TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", true)
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
                            AddToTrunk(plate, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info,
                                itemInfo["created"])
                        end
                    else
                        TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red",
                            "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                "* | *" .. src .. "*) swapped item; name: **" .. toItemData.name .. "**, amount: **" ..
                                toAmount .. "** with name: **" .. itemInfo["name"] .. "**, amount: **" .. toAmount ..
                                "** plate: *" .. plate .. "*")
                    end
                end
                itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                AddToTrunk(plate, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info,
                    itemInfo["created"])
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
                                    TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount,
                                        "remove", true)
                                    AddToGlovebox(plate, fromSlot, toSlot, itemInfo["name"], toAmount,
                                        toItemData.info, itemInfo["created"])
                                    TriggerEvent("qb-log:server:CreateLog", "glovebox", "Swapped", "orange",
                                        "**" .. GetPlayerName(src) .. "** (citizenid: *" ..
                                            Player.PlayerData.citizenid .. "* | id: *" .. src ..
                                            ")* swapped item; name: **" .. toItemData.name .. "**, amount: **" ..
                                            toAmount .. "** with item; name: **" .. itemInfo["name"] ..
                                            "**, amount: **" .. toAmount .. "** plate: *" .. plate .. "*")
                                else
                                    TriggerEvent("qb-log:server:CreateLog", "glovebox", "Stacked Item", "orange",
                                        "**" .. GetPlayerName(src) .. "** (citizenid: *" ..
                                            Player.PlayerData.citizenid .. "* | id: *" .. src ..
                                            "*) stacked item; name: **" .. toItemData.name .. "**, amount: **" ..
                                            toAmount .. "** from plate: *" .. plate .. "*")
                                end
                            else
                                TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red",
                                    "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                        "* | *" .. src .. "*) swapped item; name: **" .. toItemData.name ..
                                        "**, amount: **" .. toAmount .. "** with name: **" .. itemInfo["name"] ..
                                        "**, amount: **" .. toAmount .. "** plate: *" .. plate .. "*")
                            end
                        else
                            TriggerEvent("qb-log:server:CreateLog", "glovebox", "Received Item", "green",
                                "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                    "* | id: *" .. src .. "*) received item; name: **" .. fromItemData.name ..
                                    "**, amount: **" .. fromAmount .. "** plate: *" .. plate .. "*")
                        end
                        TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", true)
                        AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info,
                            fromItemData["created"])
                    end
                else
                    RemoveFromGlovebox(plate, fromSlot, itemInfo["name"], fromAmount)
                    if toItemData ~= nil then
                        itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                        local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                        if toItemData.amount >= toAmount then
                            if toItemData.name ~= fromItemData.name then
                                RemoveItem(src, toItemData.name, toAmount, toSlot)
                                TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "remove",
                                    true)
                                AddToGlovebox(plate, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info,
                                    itemInfo["created"])
                                TriggerEvent("qb-log:server:CreateLog", "glovebox", "Swapped", "orange",
                                    "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                        "* | id: *" .. src .. ")* swapped item; name: **" .. toItemData.name ..
                                        "**, amount: **" .. toAmount .. "** with item; name: **" .. itemInfo["name"] ..
                                        "**, amount: **" .. toAmount .. "** plate: *" .. plate .. "*")
                            else
                                TriggerEvent("qb-log:server:CreateLog", "glovebox", "Stacked Item", "orange",
                                    "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                        "* | id: *" .. src .. "*) stacked item; name: **" .. toItemData.name ..
                                        "**, amount: **" .. toAmount .. "** from plate: *" .. plate .. "*")
                            end
                        else
                            TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red",
                                "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                    "* | *" .. src .. "*) swapped item; name: **" .. toItemData.name ..
                                    "**, amount: **" .. toAmount .. "** with name: **" .. itemInfo["name"] ..
                                    "**, amount: **" .. toAmount .. "** plate: *" .. plate .. "*")
                        end
                    else
                        TriggerEvent("qb-log:server:CreateLog", "glovebox", "Received Item", "green",
                            "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                "* | id: *" .. src .. "*) received item; name: **" .. fromItemData.name ..
                                "**, amount: **" .. fromAmount .. "** plate: *" .. plate .. "*")
                    end
                    TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", true)
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
                            AddToGlovebox(plate, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info,
                                itemInfo["created"])
                        end
                    else
                        TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red",
                            "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                "* | *" .. src .. "*) swapped item; name: **" .. toItemData.name .. "**, amount: **" ..
                                toAmount .. "** with name: **" .. itemInfo["name"] .. "**, amount: **" .. toAmount ..
                                "** plate: *" .. plate .. "*")
                    end
                end
                itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                AddToGlovebox(plate, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info,
                    itemInfo["created"])
            end
        else
            QBCore.Functions.Notify(src, Lang:t("notify.itemexist"), "error")
        end
    elseif QBCore.Shared.SplitStr(fromInventory, "-")[1] == "stash" then
        local stashId = QBCore.Shared.SplitStr(fromInventory, "-")[2]
        local fromItemData = Stashes[stashId].items[fromSlot]
        fromAmount = tonumber(fromAmount) or fromItemData.amount

        -- mh-stashes (start)
        local stash = QBCore.Shared.SplitStr(stashId, "_")[1]
        local canuse = IsStashItemLootable(src, stash, fromItemData)
        -- print("To stash: " .. stash, "Can Use: " .. tostring(canuse))
        -- mh-stashes (end)

        if canuse then
            if fromItemData and fromItemData.amount >= fromAmount then
                local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                if toInventory == "player" or toInventory == "hotbar" then
                    local toItemData = GetItemBySlot(src, toSlot)
                    if Config.Stashes[fromItemData.name:lower()] then
                        local hasItem = QBCore.Functions.HasItem(src, fromItemData.name:lower(), 1)
                        if hasItem then
                            TriggerEvent('mh-stashes:server:max_carry_item', src)
                        else
                            RemoveFromStash(stashId, fromSlot, itemInfo["name"], fromAmount)
                            if toItemData ~= nil then
                                itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                                local toAmount =
                                    tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                                if toItemData.amount >= toAmount then
                                    if toItemData.name ~= fromItemData.name then
                                        RemoveItem(src, toItemData.name, toAmount, toSlot)
                                        TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount,
                                            "remove", true)
                                        AddToStash(stashId, fromSlot, toSlot, itemInfo["name"], toAmount,
                                            toItemData.info, itemInfo["created"])
                                        TriggerEvent("qb-log:server:CreateLog", "stash", "Swapped Item", "orange",
                                            "**" .. GetPlayerName(src) .. "** (citizenid: *" ..
                                                Player.PlayerData.citizenid .. "* | id: *" .. src ..
                                                "*) swapped item; name: **" .. toItemData.name .. "**, amount: **" ..
                                                toAmount .. "** with item; name: **" .. fromItemData.name ..
                                                "**, amount: **" .. fromAmount .. "** stash: *" .. stashId .. "*")
                                    else
                                        TriggerEvent("qb-log:server:CreateLog", "stash", "Stacked Item", "orange",
                                            "**" .. GetPlayerName(src) .. "** (citizenid: *" ..
                                                Player.PlayerData.citizenid .. "* | id: *" .. src ..
                                                "*) stacked item; name: **" .. toItemData.name .. "**, amount: **" ..
                                                toAmount .. "** from stash: *" .. stashId .. "*")
                                    end
                                else
                                    TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red",
                                        "**" .. GetPlayerName(src) .. "** (citizenid: *" ..
                                            Player.PlayerData.citizenid .. "* | id: *" .. src ..
                                            "*) swapped item; name: **" .. toItemData.name .. "**, amount: **" ..
                                            toAmount .. "** with item; name: **" .. fromItemData.name ..
                                            "**, amount: **" .. fromAmount .. "** stash: *" .. stashId .. "*")
                                end
                            else
                                TriggerEvent("qb-log:server:CreateLog", "stash", "Received Item", "green",
                                    "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                        "* | id: *" .. src .. "*) received item; name: **" .. fromItemData.name ..
                                        "**, amount: **" .. fromAmount .. "** stash: *" .. stashId .. "*")
                            end
                            SaveStashItems(stashId, Stashes[stashId].items)
                            TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add",
                                true)
                            AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info,
                                fromItemData["created"])
                        end
                    else
                        RemoveFromStash(stashId, fromSlot, itemInfo["name"], fromAmount)
                        if toItemData ~= nil then
                            itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                            local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                            if toItemData.amount >= toAmount then
                                if toItemData.name ~= fromItemData.name then
                                    RemoveItem(src, toItemData.name, toAmount, toSlot)
                                    TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount,
                                        "remove", true)
                                    AddToStash(stashId, fromSlot, toSlot, itemInfo["name"], toAmount,
                                        toItemData.info, itemInfo["created"])
                                    TriggerEvent("qb-log:server:CreateLog", "stash", "Swapped Item", "orange",
                                        "**" .. GetPlayerName(src) .. "** (citizenid: *" ..
                                            Player.PlayerData.citizenid .. "* | id: *" .. src ..
                                            "*) swapped item; name: **" .. toItemData.name .. "**, amount: **" ..
                                            toAmount .. "** with item; name: **" .. fromItemData.name ..
                                            "**, amount: **" .. fromAmount .. "** stash: *" .. stashId .. "*")
                                else
                                    TriggerEvent("qb-log:server:CreateLog", "stash", "Stacked Item", "orange",
                                        "**" .. GetPlayerName(src) .. "** (citizenid: *" ..
                                            Player.PlayerData.citizenid .. "* | id: *" .. src ..
                                            "*) stacked item; name: **" .. toItemData.name .. "**, amount: **" ..
                                            toAmount .. "** from stash: *" .. stashId .. "*")
                                end
                            else
                                TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red",
                                    "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                        "* | id: *" .. src .. "*) swapped item; name: **" .. toItemData.name ..
                                        "**, amount: **" .. toAmount .. "** with item; name: **" ..
                                        fromItemData.name .. "**, amount: **" .. fromAmount .. "** stash: *" ..
                                        stashId .. "*")
                            end
                        else
                            TriggerEvent("qb-log:server:CreateLog", "stash", "Received Item", "green",
                                "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                    "* | id: *" .. src .. "*) received item; name: **" .. fromItemData.name ..
                                    "**, amount: **" .. fromAmount .. "** stash: *" .. stashId .. "*")
                        end
                        SaveStashItems(stashId, Stashes[stashId].items)
                        TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", true)
                        AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info,
                            fromItemData["created"])
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
                                AddToStash(stashId, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info,
                                    itemInfo["created"])
                            end
                        else
                            TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red",
                                "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                    "* | id: *" .. src .. "*) swapped item; name: **" .. toItemData.name ..
                                    "**, amount: **" .. toAmount .. "** with item; name: **" .. fromItemData.name ..
                                    "**, amount: **" .. fromAmount .. "** stash: *" .. stashId .. "*")
                        end
                    end
                    itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                    AddToStash(stashId, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info,
                        itemInfo["created"])
                end
            else
                QBCore.Functions.Notify(src, Lang:t("notify.itemexist"), "error")
            end
        else
            if fromItemData and fromItemData.amount >= fromAmount then
                local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                if toInventory == "player" or toInventory == "hotbar" then
                    local toItemData = GetItemBySlot(src, toSlot)
                    if Config.Stashes[fromItemData.name:lower()] then
                        local hasItem = QBCore.Functions.HasItem(src, fromItemData.name:lower(), 1)
                        if hasItem then
                            TriggerEvent('mh-stashes:server:max_carry_item', src)
                        else
                            RemoveFromStash(stashId, fromSlot, itemInfo["name"], fromAmount)
                            if toItemData ~= nil then
                                itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                                local toAmount =
                                    tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                                if toItemData.amount >= toAmount then
                                    if toItemData.name ~= fromItemData.name then
                                        RemoveItem(src, toItemData.name, toAmount, toSlot)
                                        TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount,
                                            "remove", true)
                                        AddToStash(stashId, fromSlot, toSlot, itemInfo["name"], toAmount,
                                            toItemData.info, itemInfo["created"])
                                        TriggerEvent("qb-log:server:CreateLog", "stash", "Swapped Item", "orange",
                                            "**" .. GetPlayerName(src) .. "** (citizenid: *" ..
                                                Player.PlayerData.citizenid .. "* | id: *" .. src ..
                                                "*) swapped item; name: **" .. toItemData.name .. "**, amount: **" ..
                                                toAmount .. "** with item; name: **" .. fromItemData.name ..
                                                "**, amount: **" .. fromAmount .. "** stash: *" .. stashId .. "*")
                                    else
                                        TriggerEvent("qb-log:server:CreateLog", "stash", "Stacked Item", "orange",
                                            "**" .. GetPlayerName(src) .. "** (citizenid: *" ..
                                                Player.PlayerData.citizenid .. "* | id: *" .. src ..
                                                "*) stacked item; name: **" .. toItemData.name .. "**, amount: **" ..
                                                toAmount .. "** from stash: *" .. stashId .. "*")
                                    end
                                else
                                    TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red",
                                        "**" .. GetPlayerName(src) .. "** (citizenid: *" ..
                                            Player.PlayerData.citizenid .. "* | id: *" .. src ..
                                            "*) swapped item; name: **" .. toItemData.name .. "**, amount: **" ..
                                            toAmount .. "** with item; name: **" .. fromItemData.name ..
                                            "**, amount: **" .. fromAmount .. "** stash: *" .. stashId .. "*")
                                end
                            else
                                TriggerEvent("qb-log:server:CreateLog", "stash", "Received Item", "green",
                                    "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                        "* | id: *" .. src .. "*) received item; name: **" .. fromItemData.name ..
                                        "**, amount: **" .. fromAmount .. "** stash: *" .. stashId .. "*")
                            end
                            SaveStashItems(stashId, Stashes[stashId].items)
                            TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add",
                                true)
                            AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info,
                                fromItemData["created"])
                        end
                    else
                        RemoveFromStash(stashId, fromSlot, itemInfo["name"], fromAmount)
                        if toItemData ~= nil then
                            itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                            local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                            if toItemData.amount >= toAmount then
                                if toItemData.name ~= fromItemData.name then
                                    RemoveItem(src, toItemData.name, toAmount, toSlot)
                                    TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount,
                                        "remove", true)
                                    AddToStash(stashId, fromSlot, toSlot, itemInfo["name"], toAmount,
                                        toItemData.info, itemInfo["created"])
                                    TriggerEvent("qb-log:server:CreateLog", "stash", "Swapped Item", "orange",
                                        "**" .. GetPlayerName(src) .. "** (citizenid: *" ..
                                            Player.PlayerData.citizenid .. "* | id: *" .. src ..
                                            "*) swapped item; name: **" .. toItemData.name .. "**, amount: **" ..
                                            toAmount .. "** with item; name: **" .. fromItemData.name ..
                                            "**, amount: **" .. fromAmount .. "** stash: *" .. stashId .. "*")
                                else
                                    TriggerEvent("qb-log:server:CreateLog", "stash", "Stacked Item", "orange",
                                        "**" .. GetPlayerName(src) .. "** (citizenid: *" ..
                                            Player.PlayerData.citizenid .. "* | id: *" .. src ..
                                            "*) stacked item; name: **" .. toItemData.name .. "**, amount: **" ..
                                            toAmount .. "** from stash: *" .. stashId .. "*")
                                end
                            else
                                TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red",
                                    "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                        "* | id: *" .. src .. "*) swapped item; name: **" .. toItemData.name ..
                                        "**, amount: **" .. toAmount .. "** with item; name: **" ..
                                        fromItemData.name .. "**, amount: **" .. fromAmount .. "** stash: *" ..
                                        stashId .. "*")
                            end
                        else
                            TriggerEvent("qb-log:server:CreateLog", "stash", "Received Item", "green",
                                "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                    "* | id: *" .. src .. "*) received item; name: **" .. fromItemData.name ..
                                    "**, amount: **" .. fromAmount .. "** stash: *" .. stashId .. "*")
                        end
                        SaveStashItems(stashId, Stashes[stashId].items)
                        TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", true)
                        AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info,
                            fromItemData["created"])
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
                                AddToStash(stashId, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info,
                                    itemInfo["created"])
                            end
                        else
                            TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red",
                                "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                    "* | id: *" .. src .. "*) swapped item; name: **" .. toItemData.name ..
                                    "**, amount: **" .. toAmount .. "** with item; name: **" .. fromItemData.name ..
                                    "**, amount: **" .. fromAmount .. "** stash: *" .. stashId .. "*")
                        end
                    end
                    itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                    AddToStash(stashId, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info,
                        itemInfo["created"])
                end
            else
                QBCore.Functions.Notify(src, Lang:t("notify.itemexist"), "error")
            end
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
                                    TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount,
                                        "remove", true)
                                    exports['qb-traphouse']:AddHouseItem(traphouseId, fromSlot, itemInfo["name"],
                                        toAmount, toItemData.info, src)
                                    TriggerEvent("qb-log:server:CreateLog", "stash", "Swapped Item", "orange",
                                        "**" .. GetPlayerName(src) .. "** (citizenid: *" ..
                                            Player.PlayerData.citizenid .. "* | id: *" .. src ..
                                            "*) swapped item; name: **" .. toItemData.name .. "**, amount: **" ..
                                            toAmount .. "** with item; name: **" .. fromItemData.name ..
                                            "**, amount: **" .. fromAmount .. "** stash: *" .. traphouseId .. "*")
                                else
                                    TriggerEvent("qb-log:server:CreateLog", "stash", "Stacked Item", "orange",
                                        "**" .. GetPlayerName(src) .. "** (citizenid: *" ..
                                            Player.PlayerData.citizenid .. "* | id: *" .. src ..
                                            "*) stacked item; name: **" .. toItemData.name .. "**, amount: **" ..
                                            toAmount .. "** from stash: *" .. traphouseId .. "*")
                                end
                            else
                                TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red",
                                    "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                        "* | id: *" .. src .. "*) swapped item; name: **" .. toItemData.name ..
                                        "**, amount: **" .. toAmount .. "** with item; name: **" ..
                                        fromItemData.name .. "**, amount: **" .. fromAmount .. "** stash: *" ..
                                        traphouseId .. "*")
                            end
                        else
                            TriggerEvent("qb-log:server:CreateLog", "stash", "Received Item", "green",
                                "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                    "* | id: *" .. src .. "*) received item; name: **" .. fromItemData.name ..
                                    "**, amount: **" .. fromAmount .. "** stash: *" .. traphouseId .. "*")
                        end
                        TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", true)
                        AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info,
                            fromItemData["created"])
                    end
                else
                    exports['qb-traphouse']:RemoveHouseItem(traphouseId, fromSlot, itemInfo["name"], fromAmount)
                    if toItemData ~= nil then
                        itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                        local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                        if toItemData.amount >= toAmount then
                            if toItemData.name ~= fromItemData.name then
                                RemoveItem(src, toItemData.name, toAmount, toSlot)
                                TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "remove",
                                    true)
                                exports['qb-traphouse']:AddHouseItem(traphouseId, fromSlot, itemInfo["name"],
                                    toAmount, toItemData.info, src)
                                TriggerEvent("qb-log:server:CreateLog", "stash", "Swapped Item", "orange",
                                    "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                        "* | id: *" .. src .. "*) swapped item; name: **" .. toItemData.name ..
                                        "**, amount: **" .. toAmount .. "** with item; name: **" ..
                                        fromItemData.name .. "**, amount: **" .. fromAmount .. "** stash: *" ..
                                        traphouseId .. "*")
                            else
                                TriggerEvent("qb-log:server:CreateLog", "stash", "Stacked Item", "orange",
                                    "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                        "* | id: *" .. src .. "*) stacked item; name: **" .. toItemData.name ..
                                        "**, amount: **" .. toAmount .. "** from stash: *" .. traphouseId .. "*")
                            end
                        else
                            TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red",
                                "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                    "* | id: *" .. src .. "*) swapped item; name: **" .. toItemData.name ..
                                    "**, amount: **" .. toAmount .. "** with item; name: **" .. fromItemData.name ..
                                    "**, amount: **" .. fromAmount .. "** stash: *" .. traphouseId .. "*")
                        end
                    else
                        TriggerEvent("qb-log:server:CreateLog", "stash", "Received Item", "green",
                            "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                "* | id: *" .. src .. "*) received item; name: **" .. fromItemData.name ..
                                "**, amount: **" .. fromAmount .. "** stash: *" .. traphouseId .. "*")
                    end
                    TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", true)
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
                            exports['qb-traphouse']:AddHouseItem(traphouseId, fromSlot, itemInfo["name"], toAmount,
                                toItemData.info, src)
                        end
                    else
                        TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red",
                            "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                "* | id: *" .. src .. "*) swapped item; name: **" .. toItemData.name ..
                                "**, amount: **" .. toAmount .. "** with item; name: **" .. fromItemData.name ..
                                "**, amount: **" .. fromAmount .. "** stash: *" .. traphouseId .. "*")
                    end
                end
                itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                exports['qb-traphouse']:AddHouseItem(traphouseId, toSlot, itemInfo["name"], fromAmount,
                    fromItemData.info, src)
            end
        else
            QBCore.Functions.Notify(src, Lang:t('notify.not_exist'), "error")
        end
    elseif QBCore.Shared.SplitStr(fromInventory, "-")[1] == "itemshop" then
        local shopType = QBCore.Shared.SplitStr(fromInventory, "-")[2]
        local itemData = ShopItems[shopType].items[fromSlot]
        local itemInfo = QBCore.Shared.Items[itemData.name:lower()]
        local bankBalance = Player.PlayerData.money["bank"]
        local price = tonumber((itemData.price * fromAmount))
        if QBCore.Shared.SplitStr(shopType, "_")[1] == "Dealer" then
            if QBCore.Shared.SplitStr(itemData.name, "_")[1] == "weapon" then
                price = tonumber(itemData.price)
                if Player.Functions.RemoveMoney("cash", price, "dealer-item-bought") then
                    itemData.info.serie = tostring(QBCore.Shared.RandomInt(2) .. QBCore.Shared.RandomStr(3) ..
                                                       QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) ..
                                                       QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(4))
                    itemData.info.quality = 100
                    AddItem(src, itemData.name, 1, toSlot, itemData.info)
                    TriggerClientEvent('qb-drugs:client:updateDealerItems', src, itemData, 1)
                    QBCore.Functions.Notify(src, itemInfo["label"] .. " bought!", "success")
                    TriggerEvent("qb-log:server:CreateLog", "dealers", "Dealer item bought", "green", "**" ..
                        GetPlayerName(src) .. "** bought a " .. itemInfo["label"] .. " for $" .. price)
                else
                    QBCore.Functions.Notify(src, Lang:t('notify.no_cash'), "error")
                end
            else
                if Player.Functions.RemoveMoney("cash", price, "dealer-item-bought") then
                    AddItem(src, itemData.name, fromAmount, toSlot, itemData.info)
                    TriggerClientEvent('qb-drugs:client:updateDealerItems', src, itemData, fromAmount)
                    QBCore.Functions.Notify(src, itemInfo["label"] .. " bought!", "success")
                    TriggerEvent("qb-log:server:CreateLog", "dealers", "Dealer item bought", "green", "**" ..
                        GetPlayerName(src) .. "** bought a " .. itemInfo["label"] .. "  for $" .. price)
                else
                    QBCore.Functions.Notify(src, Lang:t('notify.no_cash'), "error")
                end
            end
        elseif QBCore.Shared.SplitStr(shopType, "_")[1] == "Itemshop" then
            if Player.Functions.RemoveMoney("cash", price, "itemshop-bought-item") then
                if QBCore.Shared.SplitStr(itemData.name, "_")[1] == "weapon" then
                    itemData.info.serie = tostring(QBCore.Shared.RandomInt(2) .. QBCore.Shared.RandomStr(3) ..
                                                       QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) ..
                                                       QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(4))
                    itemData.info.quality = 100
                end
                local serial = itemData.info.serie
                local imageurl = ("https://cfx-nui-ps-inventory/html/images/%s.png"):format(itemData.name)
                local notes = "Purchased at Ammunation"
                local owner = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
                local weapClass = 1
                local weapModel = QBCore.Shared.Items[itemData.name].label
                AddItem(src, itemData.name, fromAmount, toSlot, itemData.info)
                TriggerClientEvent('qb-shops:client:UpdateShop', src, QBCore.Shared.SplitStr(shopType, "_")[2],
                    itemData, fromAmount)
                QBCore.Functions.Notify(src, itemInfo["label"] .. " bought!", "success")
                -- exports['ps-mdt']:CreateWeaponInfo(serial, imageurl, notes, owner, weapClass, weapModel)
                TriggerEvent("qb-log:server:CreateLog", "shops", "Shop item bought", "green",
                    "**" .. GetPlayerName(src) .. "** bought a " .. itemInfo["label"] .. " for $" .. price)
            elseif bankBalance >= price then
                Player.Functions.RemoveMoney("bank", price, "itemshop-bought-item")
                if QBCore.Shared.SplitStr(itemData.name, "_")[1] == "weapon" then
                    itemData.info.serie = tostring(QBCore.Shared.RandomInt(2) .. QBCore.Shared.RandomStr(3) ..
                                                       QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) ..
                                                       QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(4))
                    itemData.info.quality = 100
                end
                local serial = itemData.info.serie
                local imageurl = ("https://cfx-nui-ps-inventory/html/images/%s.png"):format(itemData.name)
                local notes = "Purchased at Ammunation"
                local owner = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
                local weapClass = 1
                local weapModel = QBCore.Shared.Items[itemData.name].label
                AddItem(src, itemData.name, fromAmount, toSlot, itemData.info)
                TriggerClientEvent('qb-shops:client:UpdateShop', src, QBCore.Shared.SplitStr(shopType, "_")[2],
                    itemData, fromAmount)
                QBCore.Functions.Notify(src, itemInfo["label"] .. " bought!", "success")
                exports['ps-mdt']:CreateWeaponInfo(serial, imageurl, notes, owner, weapClass, weapModel)
                TriggerEvent("qb-log:server:CreateLog", "shops", "Shop item bought", "green",
                    "**" .. GetPlayerName(src) .. "** bought a " .. itemInfo["label"] .. " for $" .. price)
            else
                QBCore.Functions.Notify(src, Lang:t('notify.no_cash'), "error")
            end

        elseif QBCore.Shared.SplitStr(shopType, "_")[1] == "market" then
            if Player.Functions.RemoveMoney("blackmoney", price, "blackmarket-item-bought") then
                AddItem(src, itemData.name, fromAmount, toSlot, itemData.info)
                TriggerEvent('mh-cashasitem:server:updateCash', src, itemData.name, price, "remove", true)
                QBCore.Functions.Notify(src, itemInfo["label"] .. " bought!", "success")
                TriggerEvent("qb-log:server:CreateLog", "blackmarket", "Blackmarket item bought", "green", "**" ..
                    GetPlayerName(src) .. "** bought a " .. itemInfo["label"] .. "  for $" .. price)
            else
                QBCore.Functions.Notify(src, "You don't have blackmoney", "error")
            end

        else
            if Player.Functions.RemoveMoney("cash", price, "unkown-itemshop-bought-item") then
                if itemData.name:lower() == 'wallet' then
                    itemData.info.walletid = math.random(11111, 99999)
                end
                AddItem(src, itemData.name, fromAmount, toSlot, itemData.info)
                QBCore.Functions.Notify(src, itemInfo["label"] .. " bought!", "success")
                TriggerEvent("qb-log:server:CreateLog", "shops", "Shop item bought", "green",
                    "**" .. GetPlayerName(src) .. "** bought a " .. itemInfo["label"] .. " for $" .. price)
            elseif bankBalance >= price then
                Player.Functions.RemoveMoney("bank", price, "unkown-itemshop-bought-item")
                if itemData.name:lower() == 'wallet' then
                    itemData.info.walletid = math.random(11111, 99999)
                end
                AddItem(src, itemData.name, fromAmount, toSlot, itemData.info)
                QBCore.Functions.Notify(src, itemInfo["label"] .. " bought!", "success")
                TriggerEvent("qb-log:server:CreateLog", "shops", "Shop item bought", "green",
                    "**" .. GetPlayerName(src) .. "** bought a " .. itemInfo["label"] .. " for $" .. price)
            else
                QBCore.Functions.Notify(src, Lang:t('notify.no_cash'), "error")
            end
        end
    elseif fromInventory == "crafting" then
        local itemData = Config.CraftingItems[fromSlot]
        if hasCraftItems(src, itemData.costs, fromAmount) then
            TriggerClientEvent("inventory:client:CraftItems", src, itemData.name, itemData.costs, fromAmount,
                toSlot, itemData.points)
        else
            TriggerClientEvent("inventory:client:UpdatePlayerInventory", src, true)
            QBCore.Functions.Notify(src, Lang:t('notify.not_the_right_items'), "error")
        end
    elseif fromInventory == "attachment_crafting" then
        local itemData = Config.AttachmentCrafting["items"][fromSlot]
        if hasCraftItems(src, itemData.costs, fromAmount) then
            TriggerClientEvent("inventory:client:CraftAttachment", src, itemData.name, itemData.costs, fromAmount,
                toSlot, itemData.points)
        else
            TriggerClientEvent("inventory:client:UpdatePlayerInventory", src, true)
            QBCore.Functions.Notify(src, Lang:t('notify.not_the_right_items'), "error")
        end
    else
        -- drop
        fromInventory = tonumber(fromInventory)
        local fromItemData = Drops[fromInventory].items[fromSlot]
        local stash = QBCore.Shared.SplitStr(stashId, "_")[1]
        local canuse = IsStashItemLootable(src, stash, fromItemData)
        if canuse then
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
                                        TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount,
                                            "remove", true)
                                        AddToDrop(fromInventory, toSlot, itemInfo["name"], toAmount, toItemData.info,
                                            itemInfo["created"])
                                        if itemInfo["name"] == "radio" then
                                            TriggerClientEvent('Radio.Set', src, false)
                                        end
                                        TriggerEvent("qb-log:server:CreateLog", "drop", "Swapped Item", "orange",
                                            "**" .. GetPlayerName(src) .. "** (citizenid: *" ..
                                                Player.PlayerData.citizenid .. "* | id: *" .. src ..
                                                "*) swapped item; name: **" .. toItemData.name .. "**, amount: **" ..
                                                toAmount .. "** with item; name: **" .. fromItemData.name ..
                                                "**, amount: **" .. fromAmount .. "** - dropid: *" .. fromInventory ..
                                                "*")
                                    else
                                        TriggerEvent("qb-log:server:CreateLog", "drop", "Stacked Item", "orange",
                                            "**" .. GetPlayerName(src) .. "** (citizenid: *" ..
                                                Player.PlayerData.citizenid .. "* | id: *" .. src ..
                                                "*) stacked item; name: **" .. toItemData.name .. "**, amount: **" ..
                                                toAmount .. "** - from dropid: *" .. fromInventory .. "*")
                                    end
                                else
                                    TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red",
                                        "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                            "* | id: *" .. src .. "*) swapped item; name: **" .. toItemData.name ..
                                            "**, amount: **" .. toAmount .. "** with item; name: **" ..
                                            fromItemData.name .. "**, amount: **" .. fromAmount .. "** - dropid: *" ..
                                            fromInventory .. "*")
                                end
                            else
                                TriggerEvent("qb-log:server:CreateLog", "drop", "Received Item", "green",
                                    "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                        "* | id: *" .. src .. "*) received item; name: **" .. fromItemData.name ..
                                        "**, amount: **" .. fromAmount .. "** -  dropid: *" .. fromInventory .. "*")
                            end
                            TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", true)
                            AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info,
                                fromItemData["created"])
                        end
                    else
                        RemoveFromDrop(fromInventory, fromSlot, itemInfo["name"], fromAmount)
                        if toItemData ~= nil then
                            toAmount = tonumber(toAmount) and tonumber(toAmount) or toItemData.amount
                            if toItemData.amount >= toAmount then
                                if toItemData.name ~= fromItemData.name then
                                    itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                                    RemoveItem(src, toItemData.name, toAmount, toSlot)
                                    TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "remove",
                                        true)
                                    AddToDrop(fromInventory, toSlot, itemInfo["name"], toAmount, toItemData.info,
                                        itemInfo["created"])
                                    if itemInfo["name"] == "radio" then
                                        TriggerClientEvent('Radio.Set', src, false)
                                    end
                                    TriggerEvent("qb-log:server:CreateLog", "drop", "Swapped Item", "orange",
                                        "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                            "* | id: *" .. src .. "*) swapped item; name: **" .. toItemData.name ..
                                            "**, amount: **" .. toAmount .. "** with item; name: **" ..
                                            fromItemData.name .. "**, amount: **" .. fromAmount .. "** - dropid: *" ..
                                            fromInventory .. "*")
                                else
                                    TriggerEvent("qb-log:server:CreateLog", "drop", "Stacked Item", "orange",
                                        "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                            "* | id: *" .. src .. "*) stacked item; name: **" .. toItemData.name ..
                                            "**, amount: **" .. toAmount .. "** - from dropid: *" .. fromInventory ..
                                            "*")
                                end
                            else
                                TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red",
                                    "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                        "* | id: *" .. src .. "*) swapped item; name: **" .. toItemData.name ..
                                        "**, amount: **" .. toAmount .. "** with item; name: **" .. fromItemData.name ..
                                        "**, amount: **" .. fromAmount .. "** - dropid: *" .. fromInventory .. "*")
                            end
                        else
                            TriggerEvent("qb-log:server:CreateLog", "drop", "Received Item", "green",
                                "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                    "* | id: *" .. src .. "*) received item; name: **" .. fromItemData.name ..
                                    "**, amount: **" .. fromAmount .. "** -  dropid: *" .. fromInventory .. "*")
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
                                AddToDrop(fromInventory, fromSlot, itemInfo["name"], toAmount, toItemData.info,
                                    itemInfo["created"])
                                if itemInfo["name"] == "radio" then
                                    TriggerClientEvent('Radio.Set', src, false)
                                end
                            end
                        else
                            TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red",
                                "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                    "* | id: *" .. src .. "*) swapped item; name: **" .. toItemData.name ..
                                    "**, amount: **" .. toAmount .. "** with item; name: **" .. fromItemData.name ..
                                    "**, amount: **" .. fromAmount .. "** - dropid: *" .. fromInventory .. "*")
                        end
                    end
                    itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                    AddToDrop(toInventory, toSlot, itemInfo["name"], fromAmount, fromItemData.info, itemInfo["created"])
                    if itemInfo["name"] == "radio" then
                        TriggerClientEvent('Radio.Set', src, false)
                    end
                end
            else
                QBCore.Functions.Notify(src, Lang:t('notify.not_exist'), "error")
            end
        else
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
                                        TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount,
                                            "remove", true)
                                        AddToDrop(fromInventory, toSlot, itemInfo["name"], toAmount, toItemData.info,
                                            itemInfo["created"])
                                        if itemInfo["name"] == "radio" then
                                            TriggerClientEvent('Radio.Set', src, false)
                                        end
                                        TriggerEvent("qb-log:server:CreateLog", "drop", "Swapped Item", "orange",
                                            "**" .. GetPlayerName(src) .. "** (citizenid: *" ..
                                                Player.PlayerData.citizenid .. "* | id: *" .. src ..
                                                "*) swapped item; name: **" .. toItemData.name .. "**, amount: **" ..
                                                toAmount .. "** with item; name: **" .. fromItemData.name ..
                                                "**, amount: **" .. fromAmount .. "** - dropid: *" .. fromInventory ..
                                                "*")
                                    else
                                        TriggerEvent("qb-log:server:CreateLog", "drop", "Stacked Item", "orange",
                                            "**" .. GetPlayerName(src) .. "** (citizenid: *" ..
                                                Player.PlayerData.citizenid .. "* | id: *" .. src ..
                                                "*) stacked item; name: **" .. toItemData.name .. "**, amount: **" ..
                                                toAmount .. "** - from dropid: *" .. fromInventory .. "*")
                                    end
                                else
                                    TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red",
                                        "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                            "* | id: *" .. src .. "*) swapped item; name: **" .. toItemData.name ..
                                            "**, amount: **" .. toAmount .. "** with item; name: **" ..
                                            fromItemData.name .. "**, amount: **" .. fromAmount .. "** - dropid: *" ..
                                            fromInventory .. "*")
                                end
                            else
                                TriggerEvent("qb-log:server:CreateLog", "drop", "Received Item", "green",
                                    "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                        "* | id: *" .. src .. "*) received item; name: **" .. fromItemData.name ..
                                        "**, amount: **" .. fromAmount .. "** -  dropid: *" .. fromInventory .. "*")
                            end
                            TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", true)
                            AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info,
                                fromItemData["created"])
                        end
                    else
                        RemoveFromDrop(fromInventory, fromSlot, itemInfo["name"], fromAmount)
                        if toItemData ~= nil then
                            toAmount = tonumber(toAmount) and tonumber(toAmount) or toItemData.amount
                            if toItemData.amount >= toAmount then
                                if toItemData.name ~= fromItemData.name then
                                    itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                                    RemoveItem(src, toItemData.name, toAmount, toSlot)
                                    TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "remove",
                                        true)
                                    AddToDrop(fromInventory, toSlot, itemInfo["name"], toAmount, toItemData.info,
                                        itemInfo["created"])
                                    if itemInfo["name"] == "radio" then
                                        TriggerClientEvent('Radio.Set', src, false)
                                    end
                                    TriggerEvent("qb-log:server:CreateLog", "drop", "Swapped Item", "orange",
                                        "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                            "* | id: *" .. src .. "*) swapped item; name: **" .. toItemData.name ..
                                            "**, amount: **" .. toAmount .. "** with item; name: **" ..
                                            fromItemData.name .. "**, amount: **" .. fromAmount .. "** - dropid: *" ..
                                            fromInventory .. "*")
                                else
                                    TriggerEvent("qb-log:server:CreateLog", "drop", "Stacked Item", "orange",
                                        "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                            "* | id: *" .. src .. "*) stacked item; name: **" .. toItemData.name ..
                                            "**, amount: **" .. toAmount .. "** - from dropid: *" .. fromInventory ..
                                            "*")
                                end
                            else
                                TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red",
                                    "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                        "* | id: *" .. src .. "*) swapped item; name: **" .. toItemData.name ..
                                        "**, amount: **" .. toAmount .. "** with item; name: **" .. fromItemData.name ..
                                        "**, amount: **" .. fromAmount .. "** - dropid: *" .. fromInventory .. "*")
                            end
                        else
                            TriggerEvent("qb-log:server:CreateLog", "drop", "Received Item", "green",
                                "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                    "* | id: *" .. src .. "*) received item; name: **" .. fromItemData.name ..
                                    "**, amount: **" .. fromAmount .. "** -  dropid: *" .. fromInventory .. "*")
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
                                AddToDrop(fromInventory, fromSlot, itemInfo["name"], toAmount, toItemData.info,
                                    itemInfo["created"])
                                if itemInfo["name"] == "radio" then
                                    TriggerClientEvent('Radio.Set', src, false)
                                end
                            end
                        else
                            TriggerEvent("qb-log:server:CreateLog", "anticheat", "Dupe log", "red",
                                "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                    "* | id: *" .. src .. "*) swapped item; name: **" .. toItemData.name ..
                                    "**, amount: **" .. toAmount .. "** with item; name: **" .. fromItemData.name ..
                                    "**, amount: **" .. fromAmount .. "** - dropid: *" .. fromInventory .. "*")
                        end
                    end
                    itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                    AddToDrop(toInventory, toSlot, itemInfo["name"], fromAmount, fromItemData.info, itemInfo["created"])
                    if itemInfo["name"] == "radio" then
                        TriggerClientEvent('Radio.Set', src, false)
                    end
                end
            else
                QBCore.Functions.Notify(src, Lang:t('notify.not_exist'), "error")
            end
        end
    end
end)
```

# Replace this code in ps-inventory/server/main.lua
```lua
RegisterServerEvent("inventory:server:GiveItem", function(target, name, amount, slot)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    target = tonumber(target)
    local OtherPlayer = QBCore.Functions.GetPlayer(target)
    local dist = #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(target)))
    if Player == OtherPlayer then
        return QBCore.Functions.Notify(src, Lang:t("notify.gsitem"))
    end
    if dist > 2 then
        return QBCore.Functions.Notify(src, Lang:t("notify.tftgitem"))
    end
    local item = GetItemBySlot(src, slot)
    if not item then
        QBCore.Functions.Notify(src, Lang:t("notify.infound"));
        return
    end
    if item.name ~= name then
        QBCore.Functions.Notify(src, Lang:t("notify.iifound"));
        return
    end
    if amount <= item.amount then
        if amount == 0 then
            amount = item.amount
        end
        if RemoveItem(src, item.name, amount, item.slot) then
            TriggerEvent('mh-cashasitem:server:updateCash', src, item, amount, "remove", true)
            if AddItem(target, item.name, amount, false, item.info) then
                TriggerEvent('mh-cashasitem:server:updateCash', target, item, amount, "add", true)
                TriggerClientEvent('inventory:client:ItemBox', target, QBCore.Shared.Items[item.name], "add")
                QBCore.Functions.Notify(target,
                    Lang:t("notify.gitemrec") .. amount .. ' ' .. item.label .. Lang:t("notify.gitemfrom") ..
                        Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname)
                TriggerClientEvent("inventory:client:UpdatePlayerInventory", target, true)
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item.name], "remove")
                QBCore.Functions.Notify(src,
                    Lang:t("notify.gitemyg") .. OtherPlayer.PlayerData.charinfo.firstname .. " " ..
                        OtherPlayer.PlayerData.charinfo.lastname .. " " .. amount .. " " .. item.label .. "!")
                TriggerClientEvent("inventory:client:UpdatePlayerInventory", src, true)
                TriggerClientEvent('qb-inventory:client:giveAnim', src)
                TriggerClientEvent('qb-inventory:client:giveAnim', target)
            else
                AddItem(src, item.name, amount, item.slot, item.info)
                TriggerEvent('mh-cashasitem:server:updateCash', src, item, amount, "add", true)
                QBCore.Functions.Notify(src, Lang:t("notify.gitinvfull"), "error")
                QBCore.Functions.Notify(target, Lang:t("notify.giymif"), "error")
                TriggerClientEvent("inventory:client:UpdatePlayerInventory", src, false)
                TriggerClientEvent("inventory:client:UpdatePlayerInventory", target, false)
            end
        else
            QBCore.Functions.Notify(src, Lang:t("notify.gitydhei"), "error")
        end
    else
        QBCore.Functions.Notify(src, Lang:t("notify.gitydhitt"))
    end
end)
```

# Add this code below in mh-cashasitem/server/main.lua
- around line 178
```lua
QBCore.Commands.Add('blackmoney', 'Check Blackmoney Balance', {}, false, function(source, _)
    local Player = QBCore.Functions.GetPlayer(source)
    local amount = Player.PlayerData.money.blackmoney
    TriggerClientEvent('hud:client:ShowAccounts', source, 'blackmoney', amount)
end)
```
