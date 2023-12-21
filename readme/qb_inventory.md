## **INSTALL FOR QB INVENTORY**

# Add in qb-inventory/client/main.lua from line 136
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

# Replace this code below in qb-inventory/client/main.lua
```lua
RegisterCommand('inventory', function()
    if IsNuiFocused() then return end
    if not isCrafting and not inInventory then
        if not PlayerData.metadata['isdead'] and not PlayerData.metadata['inlaststand'] and
            not PlayerData.metadata['ishandcuffed'] and not IsPauseMenuActive() then
            local ped = PlayerPedId()
            local curVeh = nil
            local VendingMachine = nil
            if not Config.UseTarget then
                VendingMachine = GetClosestVending()
            end
            if IsPedInAnyVehicle(ped, false) then -- Is Player In Vehicle
                local vehicle = GetVehiclePedIsIn(ped, false)
                CurrentGlovebox = QBCore.Functions.GetPlate(vehicle)
                curVeh = vehicle
                CurrentVehicle = nil
            else
                local vehicle = QBCore.Functions.GetClosestVehicle()
                if vehicle ~= 0 and vehicle ~= nil then
                    local pos = GetEntityCoords(ped)
                    local dimensionMin, dimensionMax = GetModelDimensions(GetEntityModel(vehicle))
                    local trunkpos = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, (dimensionMin.y), 0.0)
                    if (IsBackEngine(GetEntityModel(vehicle))) then
                        trunkpos = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, (dimensionMax.y), 0.0)
                    end
                    if #(pos - trunkpos) < 1.5 and not IsPedInAnyVehicle(ped) then
                        if GetVehicleDoorLockStatus(vehicle) < 2 then
                            CurrentVehicle = QBCore.Functions.GetPlate(vehicle)
                            curVeh = vehicle
                            CurrentGlovebox = nil
                        else
                            QBCore.Functions.Notify(Lang:t('notify.vlocked'), 'error')
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
                local trunkConfig = Config.TrunkSpace[vehicleClass] or Config.TrunkSpace['default']
                if not trunkConfig then return print('Cannot get the vehicle trunk config') end
                local slots = trunkConfig.slots
                local maxweight = trunkConfig.maxWeight
                if not slots or not maxweight then return print('Cannot get the vehicle slots and maxweight') end
                local other = { maxweight = maxweight, slots = slots }
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
                TriggerServerEvent('inventory:server:OpenInventory', 'glovebox', CurrentGlovebox)
            elseif CurrentDrop ~= 0 then
                TriggerServerEvent('inventory:server:OpenInventory', 'drop', CurrentDrop)
            elseif VendingMachine then
                local ShopItems = {}
                ShopItems.label = 'Vending Machine'
                ShopItems.items = Config.VendingItem
                ShopItems.slots = #Config.VendingItem
                TriggerServerEvent('inventory:server:OpenInventory', 'shop', 'Vendingshop_' .. math.random(1, 99), ShopItems)
            else
                openAnim()
                TriggerServerEvent('inventory:server:OpenInventory')
            end
        end
    end
end, false)
```
- Change code in qb-inventory/server.lua

# Add this code in qb-inventory/server/main.lua
- find: `inventory:server:UseItemSlot`
```lua
if Config.Stashes[itemData.name] then lastUsedStashItem = itemData end
```
# It should look like this
```lua
RegisterNetEvent('inventory:server:UseItemSlot', function(slot)
    local src = source
    local itemData = GetItemBySlot(src, slot)
    if not itemData then return end
    local itemInfo = QBCore.Shared.Items[itemData.name]
    if itemData.type == 'weapon' then
        TriggerClientEvent('inventory:client:UseWeapon', src, itemData, itemData.info.quality and itemData.info.quality > 0)
        TriggerClientEvent('inventory:client:ItemBox', src, itemInfo, 'use')
    elseif itemData.useable then
        if Config.Stashes[itemData.name] then lastUsedStashItem = itemData end -- <-- ADD HERE
        UseItem(itemData.name, src, itemData)
        TriggerClientEvent('inventory:client:ItemBox', src, itemInfo, 'use')
    end
end)
```

# Add this code in qb-inventory/server/main.lua
- find: `inventory:server:UseItem`
```lua
if Config.Stashes[itemData.name] then lastUsedStashItem = itemData end
```
# It should look like this
```lua
RegisterNetEvent('inventory:server:UseItem', function(inventory, item)
    local src = source
    if inventory ~= 'player' and inventory ~= 'hotbar' then return end
    local itemData = GetItemBySlot(src, item.slot)
    if not itemData then return end
    local itemInfo = QBCore.Shared.Items[itemData.name]
    if itemData.type == 'weapon' then
        TriggerClientEvent('inventory:client:UseWeapon', src, itemData, itemData.info.quality and itemData.info.quality > 0)
        TriggerClientEvent('inventory:client:ItemBox', src, itemInfo, 'use')
    else
        if Config.Stashes[itemData.name] then lastUsedStashItem = itemData end -- <-- ADD HERE
        UseItem(itemData.name, src, itemData)
        TriggerClientEvent('inventory:client:ItemBox', src, itemInfo, 'use')
    end
end)
```

# Replace this code in qb-inventory/server/main.lua
```lua
RegisterNetEvent('inventory:server:SetInventoryData',
    function(fromInventory, toInventory, fromSlot, toSlot, fromAmount, toAmount)
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)
        fromSlot = tonumber(fromSlot)
        toSlot = tonumber(toSlot)
        if (fromInventory == "player" or fromInventory == "hotbar") and
            (QBCore.Shared.SplitStr(toInventory, "-")[1] == "itemshop" or toInventory == "crafting") then
            return
        end
        if fromInventory == "player" or fromInventory == "hotbar" then
            local fromItemData = Player.Functions.GetItemBySlot(fromSlot)
            local fromAmount = tonumber(fromAmount) ~= nil and tonumber(fromAmount) or fromItemData.amount
            if fromItemData ~= nil and fromItemData.amount >= fromAmount then
                if toInventory == "player" or toInventory == "hotbar" then
                    local toItemData = Player.Functions.GetItemBySlot(toSlot)
                    Player.Functions.RemoveItem(fromItemData.name, fromAmount, fromSlot)
                    TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "remove", false)
                    TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
                    if toItemData ~= nil then
                        local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                        if toItemData.name ~= fromItemData.name then
                            Player.Functions.RemoveItem(toItemData.name, toAmount, toSlot)
                            TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "remove", false)
                            Player.Functions.AddItem(toItemData.name, toAmount, fromSlot, toItemData.info)
                            TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "add", false)
                        end
                    end
                    Player.Functions.AddItem(fromItemData.name, fromAmount, toSlot, fromItemData.info)
                    TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", false)
                elseif QBCore.Shared.SplitStr(toInventory, "-")[1] == "otherplayer" then
                    local playerId = tonumber(QBCore.Shared.SplitStr(toInventory, "-")[2])
                    local OtherPlayer = QBCore.Functions.GetPlayer(playerId)
                    local toItemData = OtherPlayer.PlayerData.items[toSlot]
                    Player.Functions.RemoveItem(fromItemData.name, fromAmount, fromSlot)
                    TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "remove", true)
                    TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
                    if toItemData ~= nil then
                        local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                        local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                        if toItemData.name ~= fromItemData.name then
                            OtherPlayer.Functions.RemoveItem(itemInfo["name"], toAmount, fromSlot)
                            TriggerEvent('mh-cashasitem:server:updateCash', playerId, toItemData, toAmount, "remove",
                                true)
                            Player.Functions.AddItem(toItemData.name, toAmount, fromSlot, toItemData.info)
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
                        local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                        TriggerEvent("qb-log:server:CreateLog", "robbing", "Dropped Item", "red",
                            "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid .. "* | *" ..
                                src .. "*) dropped new item; name: **" .. itemInfo["name"] .. "**, amount: **" ..
                                fromAmount .. "** to player: **" .. GetPlayerName(OtherPlayer.PlayerData.source) ..
                                "** (citizenid: *" .. OtherPlayer.PlayerData.citizenid .. "* | id: *" ..
                                OtherPlayer.PlayerData.source .. "*)")
                    end
                    local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                    OtherPlayer.Functions.AddItem(itemInfo["name"], fromAmount, toSlot, fromItemData.info)
                    TriggerEvent('mh-cashasitem:server:updateCash', playerId, fromItemData, fromAmount, "add", true)
                elseif QBCore.Shared.SplitStr(toInventory, "-")[1] == "trunk" then
                    local plate = QBCore.Shared.SplitStr(toInventory, "-")[2]
                    local toItemData = Trunks[plate].items[toSlot]
                    Player.Functions.RemoveItem(fromItemData.name, fromAmount, fromSlot)
                    TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "remove", true)
                    TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
                    if toItemData ~= nil then
                        local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                        local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                        if toItemData.name ~= fromItemData.name then
                            RemoveFromTrunk(plate, fromSlot, itemInfo["name"], toAmount)
                            Player.Functions.AddItem(toItemData.name, toAmount, fromSlot, toItemData.info)
                            TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "add", true)
                            TriggerEvent("qb-log:server:CreateLog", "trunk", "Swapped Item", "orange",
                                "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                    "* | id: *" .. src .. "*) swapped item; name: **" .. itemInfo["name"] ..
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
                    AddToTrunk(plate, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info)
                elseif QBCore.Shared.SplitStr(toInventory, "-")[1] == "glovebox" then
                    local plate = QBCore.Shared.SplitStr(toInventory, "-")[2]
                    local toItemData = Gloveboxes[plate].items[toSlot]
                    Player.Functions.RemoveItem(fromItemData.name, fromAmount, fromSlot)
                    if Config.Stashes[fromItemData.name:lower()] then
                        TriggerEvent('mh-stashes:client:RemoveProp', src)
                    end
                    TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "remove", true)
                    TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
                    if toItemData ~= nil then
                        local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                        local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                        if toItemData.name ~= fromItemData.name then
                            RemoveFromGlovebox(plate, fromSlot, itemInfo["name"], toAmount)
                            Player.Functions.AddItem(toItemData.name, toAmount, fromSlot, toItemData.info)
                            TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "add", true)
                            TriggerEvent("qb-log:server:CreateLog", "glovebox", "Swapped Item", "orange",
                                "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                    "* | id: *" .. src .. "*) swapped item; name: **" .. itemInfo["name"] ..
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
                    AddToGlovebox(plate, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info)
                elseif QBCore.Shared.SplitStr(toInventory, "-")[1] == "stash" then
                    local stashId = QBCore.Shared.SplitStr(toInventory, "-")[2]
                    local toItemData = Stashes[stashId].items[toSlot]
                    Player.Functions.RemoveItem(fromItemData.name, fromAmount, fromSlot)
                    TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "remove", true)
                    TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
                    if toItemData ~= nil then
                        local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                        local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                        if toItemData.name ~= fromItemData.name then
                            RemoveFromStash(stashId, toSlot, itemInfo["name"], toAmount)
                            Player.Functions.AddItem(toItemData.name, toAmount, fromSlot, toItemData.info)
                            TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "add", true)
                            TriggerEvent("qb-log:server:CreateLog", "stash", "Swapped Item", "orange",
                                "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                    "* | id: *" .. src .. "*) swapped item; name: **" .. itemInfo["name"] ..
                                    "**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name ..
                                    "**, amount: **" .. fromAmount .. "** - stash: *" .. stashId .. "*")
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
                elseif QBCore.Shared.SplitStr(toInventory, "-")[1] == "traphouse" then
                    -- Traphouse
                    local traphouseId = QBCore.Shared.SplitStr(toInventory, "-")[2]
                    local toItemData = exports['qb-traphouse']:GetInventoryData(traphouseId, toSlot)
                    local IsItemValid = exports['qb-traphouse']:CanItemBeSaled(fromItemData.name:lower())
                    if IsItemValid then
                        Player.Functions.RemoveItem(fromItemData.name, fromAmount, fromSlot)
                        TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "remove", true)
                        TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
                        if toItemData ~= nil then
                            local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                            local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                            if toItemData.name ~= fromItemData.name then
                                exports['qb-traphouse']:RemoveHouseItem(traphouseId, fromSlot, itemInfo["name"],
                                    toAmount)
                                Player.Functions.AddItem(toItemData.name, toAmount, fromSlot, toItemData.info)
                                TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "add", true)
                                TriggerEvent("qb-log:server:CreateLog", "traphouse", "Swapped Item", "orange",
                                    "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                        "* | id: *" .. src .. "*) swapped item; name: **" .. itemInfo["name"] ..
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
                        TriggerClientEvent('QBCore:Notify', src, "You can\'t sell this item..", 'error')
                    end
                else
                    -- drop
                    toInventory = tonumber(toInventory)
                    if toInventory == nil or toInventory == 0 then
                        CreateNewDrop(src, fromSlot, toSlot, fromAmount)
                        TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "remove", true)
                    else
                        local toItemData = Drops[toInventory].items[toSlot]
                        Player.Functions.RemoveItem(fromItemData.name, fromAmount, fromSlot)
                        TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "remove", true)
                        TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
                        if toItemData ~= nil then
                            local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                            local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                            if toItemData.name ~= fromItemData.name then
                                Player.Functions.AddItem(toItemData.name, toAmount, fromSlot, toItemData.info)
                                TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add",
                                    true)
                                RemoveFromDrop(toInventory, fromSlot, itemInfo["name"], toAmount)
                                TriggerEvent("qb-log:server:CreateLog", "drop", "Swapped Item", "orange",
                                    "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                        "* | id: *" .. src .. "*) swapped item; name: **" .. itemInfo["name"] ..
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
                        AddToDrop(toInventory, toSlot, itemInfo["name"], fromAmount, fromItemData.info)
                        if itemInfo["name"] == "radio" then
                            TriggerClientEvent('Radio.Set', src, false)
                        end
                    end
                end
            else
                TriggerClientEvent("QBCore:Notify", src, "You don\'t have this item!", "error")
            end
        elseif QBCore.Shared.SplitStr(fromInventory, "-")[1] == "otherplayer" then
            local playerId = tonumber(QBCore.Shared.SplitStr(fromInventory, "-")[2])
            local OtherPlayer = QBCore.Functions.GetPlayer(playerId)
            local fromItemData = OtherPlayer.PlayerData.items[fromSlot]
            local fromAmount = tonumber(fromAmount) ~= nil and tonumber(fromAmount) or fromItemData.amount
            if fromItemData ~= nil and fromItemData.amount >= fromAmount then
                local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                if toInventory == "player" or toInventory == "hotbar" then
                    local toItemData = Player.Functions.GetItemBySlot(toSlot)
                    OtherPlayer.Functions.RemoveItem(itemInfo["name"], fromAmount, fromSlot)
                    TriggerEvent('mh-cashasitem:server:updateCash', playerId, fromItemData, fromAmount, "remove", true)
                    TriggerClientEvent("inventory:client:CheckWeapon", OtherPlayer.PlayerData.source, fromItemData.name)
                    if toItemData ~= nil then
                        local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                        local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                        if toItemData.name ~= fromItemData.name then
                            Player.Functions.RemoveItem(toItemData.name, toAmount, toSlot)
                            TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "remove", true)

                            OtherPlayer.Functions.AddItem(itemInfo["name"], toAmount, fromSlot, toItemData.info)
                            TriggerEvent('mh-cashasitem:server:updateCash', playerId, toItemData, toAmount, "add", true)
                            TriggerEvent("qb-log:server:CreateLog", "robbing", "Swapped Item", "orange",
                                "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                    "* | id: *" .. src .. "*) swapped item; name: **" .. toItemData.name ..
                                    "**, amount: **" .. toAmount .. "** with item; **" .. itemInfo["name"] ..
                                    "**, amount: **" .. toAmount .. "** from player: **" ..
                                    GetPlayerName(OtherPlayer.PlayerData.source) .. "** (citizenid: *" ..
                                    OtherPlayer.PlayerData.citizenid .. "* | *" .. OtherPlayer.PlayerData.source .. "*)")
                        end
                    else
                        TriggerEvent("qb-log:server:CreateLog", "robbing", "Retrieved Item", "green",
                            "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                "* | id: *" .. src .. "*) took item; name: **" .. fromItemData.name .. "**, amount: **" ..
                                fromAmount .. "** from player: **" .. GetPlayerName(OtherPlayer.PlayerData.source) ..
                                "** (citizenid: *" .. OtherPlayer.PlayerData.citizenid .. "* | *" ..
                                OtherPlayer.PlayerData.source .. "*)")
                    end
                    Player.Functions.AddItem(fromItemData.name, fromAmount, toSlot, fromItemData.info)
                    TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", true)
                else
                    local toItemData = OtherPlayer.PlayerData.items[toSlot]
                    OtherPlayer.Functions.RemoveItem(itemInfo["name"], fromAmount, fromSlot)
                    TriggerEvent('mh-cashasitem:server:updateCash', playerId, toItemData, fromAmount, "remove", true)
                    if toItemData ~= nil then
                        local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                        local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                        if toItemData.name ~= fromItemData.name then
                            local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                            OtherPlayer.Functions.RemoveItem(itemInfo["name"], toAmount, toSlot)
                            TriggerEvent('mh-cashasitem:server:updateCash', playerId, toItemData, toAmount, "remove",
                                true)
                            OtherPlayer.Functions.AddItem(itemInfo["name"], toAmount, fromSlot, toItemData.info)
                            TriggerEvent('mh-cashasitem:server:updateCash', playerId, toItemData, toAmount, "add", true)
                        end
                    end
                    local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                    OtherPlayer.Functions.AddItem(itemInfo["name"], fromAmount, toSlot, fromItemData.info)
                    TriggerEvent('mh-cashasitem:server:updateCash', playerId, fromItemData, fromAmount, "add", true)
                end
            else
                TriggerClientEvent("QBCore:Notify", src, "Item doesn\'t exist??", "error")
            end
        elseif QBCore.Shared.SplitStr(fromInventory, "-")[1] == "trunk" then
            local plate = QBCore.Shared.SplitStr(fromInventory, "-")[2]
            local fromItemData = Trunks[plate].items[fromSlot]
            local fromAmount = tonumber(fromAmount) ~= nil and tonumber(fromAmount) or fromItemData.amount
            if fromItemData ~= nil and fromItemData.amount >= fromAmount then
                local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                if toInventory == "player" or toInventory == "hotbar" then
                    local toItemData = Player.Functions.GetItemBySlot(toSlot)
                    RemoveFromTrunk(plate, fromSlot, itemInfo["name"], fromAmount)
                    if toItemData ~= nil then
                        local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                        local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                        if toItemData.name ~= fromItemData.name then
                            Player.Functions.RemoveItem(toItemData.name, toAmount, toSlot)
                            TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "remove", true)
                            AddToTrunk(plate, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info)
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
                        TriggerEvent("qb-log:server:CreateLog", "trunk", "Received Item", "green",
                            "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                "* | id: *" .. src .. "*) received item; name: **" .. fromItemData.name ..
                                "**, amount: **" .. fromAmount .. "** plate: *" .. plate .. "*")
                    end
                    Player.Functions.AddItem(fromItemData.name, fromAmount, toSlot, fromItemData.info)
                    TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", true)
                else
                    local toItemData = Trunks[plate].items[toSlot]
                    RemoveFromTrunk(plate, fromSlot, itemInfo["name"], fromAmount)
                    if toItemData ~= nil then
                        local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                        local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                        if toItemData.name ~= fromItemData.name then
                            local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                            RemoveFromTrunk(plate, toSlot, itemInfo["name"], toAmount)
                            AddToTrunk(plate, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info)
                        end
                    end
                    local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                    AddToTrunk(plate, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info)
                end
            else
                TriggerClientEvent("QBCore:Notify", src, "Item doesn\'t exist??", "error")
            end
        elseif QBCore.Shared.SplitStr(fromInventory, "-")[1] == "glovebox" then
            local plate = QBCore.Shared.SplitStr(fromInventory, "-")[2]
            local fromItemData = Gloveboxes[plate].items[fromSlot]
            local fromAmount = tonumber(fromAmount) ~= nil and tonumber(fromAmount) or fromItemData.amount
            if fromItemData ~= nil and fromItemData.amount >= fromAmount then
                local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                if toInventory == "player" or toInventory == "hotbar" then
                    local toItemData = Player.Functions.GetItemBySlot(toSlot)
                    RemoveFromGlovebox(plate, fromSlot, itemInfo["name"], fromAmount)
                    if toItemData ~= nil then
                        local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                        local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                        if toItemData.name ~= fromItemData.name then
                            Player.Functions.RemoveItem(toItemData.name, toAmount, toSlot)
                            TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "remove", true)
                            AddToGlovebox(plate, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info)
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
                        TriggerEvent("qb-log:server:CreateLog", "glovebox", "Received Item", "green",
                            "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                "* | id: *" .. src .. "*) received item; name: **" .. fromItemData.name ..
                                "**, amount: **" .. fromAmount .. "** plate: *" .. plate .. "*")
                    end
                    Player.Functions.AddItem(fromItemData.name, fromAmount, toSlot, fromItemData.info)
                    TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", true)
                else
                    local toItemData = Gloveboxes[plate].items[toSlot]
                    RemoveFromGlovebox(plate, fromSlot, itemInfo["name"], fromAmount)
                    if toItemData ~= nil then
                        local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                        local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                        if toItemData.name ~= fromItemData.name then
                            local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                            RemoveFromGlovebox(plate, toSlot, itemInfo["name"], toAmount)
                            AddToGlovebox(plate, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info)
                        end
                    end
                    local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                    AddToGlovebox(plate, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info)
                end
            else
                TriggerClientEvent("QBCore:Notify", src, "Item doesn\'t exist??", "error")
            end
        elseif QBCore.Shared.SplitStr(fromInventory, "-")[1] == "stash" then
            local stashId = QBCore.Shared.SplitStr(fromInventory, "-")[2]
            local fromItemData = Stashes[stashId].items[fromSlot]
            local fromAmount = tonumber(fromAmount) ~= nil and tonumber(fromAmount) or fromItemData.amount
            if fromItemData ~= nil and fromItemData.amount >= fromAmount then
                local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                if toInventory == "player" or toInventory == "hotbar" then
                    local toItemData = Player.Functions.GetItemBySlot(toSlot)
                    if Config.Stashes[fromItemData.name:lower()] then
                        local hasItem = QBCore.Functions.HasItem(src, fromItemData.name:lower(), 1)
                        if hasItem then
                            TriggerEvent('mh-stashes:server:max_carry_item', src)
                        else
                            RemoveFromStash(stashId, fromSlot, itemInfo["name"], fromAmount)
                            if toItemData ~= nil then
                                local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                                local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                                if toItemData.name ~= fromItemData.name then
                                    Player.Functions.RemoveItem(toItemData.name, toAmount, toSlot)
                                    TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "remove",
                                        true)
                                    AddToStash(stashId, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info)
                                    TriggerEvent("qb-log:server:CreateLog", "stash", "Swapped Item", "orange",
                                        "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                            "* | id: *" .. src .. "*) swapped item; name: **" .. toItemData.name ..
                                            "**, amount: **" .. toAmount .. "** with item; name: **" ..
                                            fromItemData.name .. "**, amount: **" .. fromAmount .. "** stash: *" ..
                                            stashId .. "*")
                                else
                                    TriggerEvent("qb-log:server:CreateLog", "stash", "Stacked Item", "orange",
                                        "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                            "* | id: *" .. src .. "*) stacked item; name: **" .. toItemData.name ..
                                            "**, amount: **" .. toAmount .. "** from stash: *" .. stashId .. "*")
                                end
                            else
                                TriggerEvent("qb-log:server:CreateLog", "stash", "Received Item", "green",
                                    "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                        "* | id: *" .. src .. "*) received item; name: **" .. fromItemData.name ..
                                        "**, amount: **" .. fromAmount .. "** stash: *" .. stashId .. "*")
                            end
                            SaveStashItems(stashId, Stashes[stashId].items)
                            Player.Functions.AddItem(fromItemData.name, fromAmount, toSlot, fromItemData.info)
                            TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", true)
                        end
                    else
                        RemoveFromStash(stashId, fromSlot, itemInfo["name"], fromAmount)
                        if toItemData ~= nil then
                            local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                            local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                            if toItemData.name ~= fromItemData.name then
                                Player.Functions.RemoveItem(toItemData.name, toAmount, toSlot)
                                TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "remove",
                                    true)
                                AddToStash(stashId, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info)
                                TriggerEvent("qb-log:server:CreateLog", "stash", "Swapped Item", "orange",
                                    "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                        "* | id: *" .. src .. "*) swapped item; name: **" .. toItemData.name ..
                                        "**, amount: **" .. toAmount .. "** with item; name: **" .. fromItemData.name ..
                                        "**, amount: **" .. fromAmount .. "** stash: *" .. stashId .. "*")
                            else
                                TriggerEvent("qb-log:server:CreateLog", "stash", "Stacked Item", "orange",
                                    "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                        "* | id: *" .. src .. "*) stacked item; name: **" .. toItemData.name ..
                                        "**, amount: **" .. toAmount .. "** from stash: *" .. stashId .. "*")
                            end
                        else
                            TriggerEvent("qb-log:server:CreateLog", "stash", "Received Item", "green",
                                "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                    "* | id: *" .. src .. "*) received item; name: **" .. fromItemData.name ..
                                    "**, amount: **" .. fromAmount .. "** stash: *" .. stashId .. "*")
                        end
                        SaveStashItems(stashId, Stashes[stashId].items)
                        Player.Functions.AddItem(fromItemData.name, fromAmount, toSlot, fromItemData.info)
                        TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", true)
                    end
                else
                    local toItemData = Stashes[stashId].items[toSlot]
                    RemoveFromStash(stashId, fromSlot, itemInfo["name"], fromAmount)
                    if toItemData ~= nil then
                        local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                        local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                        if toItemData.name ~= fromItemData.name then
                            local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                            RemoveFromStash(stashId, toSlot, itemInfo["name"], toAmount)
                            AddToStash(stashId, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info)
                        end
                    end
                    local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                    AddToStash(stashId, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info)
                end
            else
                TriggerClientEvent("QBCore:Notify", src, "Item doesn\'t exist??", "error")
            end
        elseif QBCore.Shared.SplitStr(fromInventory, "-")[1] == "traphouse" then
            local traphouseId = QBCore.Shared.SplitStr(fromInventory, "-")[2]
            local fromItemData = exports['qb-traphouse']:GetInventoryData(traphouseId, fromSlot)
            local fromAmount = tonumber(fromAmount) ~= nil and tonumber(fromAmount) or fromItemData.amount
            if fromItemData ~= nil and fromItemData.amount >= fromAmount then
                local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                if toInventory == "player" or toInventory == "hotbar" then
                    local toItemData = Player.Functions.GetItemBySlot(toSlot)
                    exports['qb-traphouse']:RemoveHouseItem(traphouseId, fromSlot, itemInfo["name"], fromAmount)
                    if toItemData ~= nil then
                        local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                        local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                        if toItemData.name ~= fromItemData.name then
                            Player.Functions.RemoveItem(toItemData.name, toAmount, toSlot)
                            TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "remove", true)
                            exports['qb-traphouse']:AddHouseItem(traphouseId, fromSlot, itemInfo["name"], toAmount,
                                toItemData.info, src)
                            TriggerEvent("qb-log:server:CreateLog", "stash", "Swapped Item", "orange",
                                "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                    "* | id: *" .. src .. "*) swapped item; name: **" .. toItemData.name ..
                                    "**, amount: **" .. toAmount .. "** with item; name: **" .. fromItemData.name ..
                                    "**, amount: **" .. fromAmount .. "** stash: *" .. traphouseId .. "*")
                        else
                            TriggerEvent("qb-log:server:CreateLog", "stash", "Stacked Item", "orange",
                                "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                    "* | id: *" .. src .. "*) stacked item; name: **" .. toItemData.name ..
                                    "**, amount: **" .. toAmount .. "** from stash: *" .. traphouseId .. "*")
                        end
                    else
                        TriggerEvent("qb-log:server:CreateLog", "stash", "Received Item", "green",
                            "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                "* | id: *" .. src .. "*) received item; name: **" .. fromItemData.name ..
                                "**, amount: **" .. fromAmount .. "** stash: *" .. traphouseId .. "*")
                    end
                    Player.Functions.AddItem(fromItemData.name, fromAmount, toSlot, fromItemData.info)
                    TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", true)
                else
                    local toItemData = exports['qb-traphouse']:GetInventoryData(traphouseId, toSlot)
                    exports['qb-traphouse']:RemoveHouseItem(traphouseId, fromSlot, itemInfo["name"], fromAmount)
                    if toItemData ~= nil then
                        local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                        local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                        if toItemData.name ~= fromItemData.name then
                            local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                            exports['qb-traphouse']:RemoveHouseItem(traphouseId, toSlot, itemInfo["name"], toAmount)
                            exports['qb-traphouse']:AddHouseItem(traphouseId, fromSlot, itemInfo["name"], toAmount,
                                toItemData.info, src)
                        end
                    end
                    local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                    exports['qb-traphouse']:AddHouseItem(traphouseId, toSlot, itemInfo["name"], fromAmount,
                        fromItemData.info, src)
                end
            else
                TriggerClientEvent("QBCore:Notify", src, "Item doesn't exist??", "error")
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
                        Player.Functions.AddItem(itemData.name, 1, toSlot, itemData.info)
                        TriggerClientEvent('qb-drugs:client:updateDealerItems', src, itemData, 1)
                        TriggerClientEvent('QBCore:Notify', src, itemInfo["label"] .. " bought!", "success")
                        TriggerEvent("qb-log:server:CreateLog", "dealers", "Dealer item bought", "green", "**" ..
                            GetPlayerName(src) .. "** bought a " .. itemInfo["label"] .. " for $" .. price)
                    else
                        TriggerClientEvent('QBCore:Notify', src, "You don\'t have enough cash..", "error")
                    end
                else
                    if Player.Functions.RemoveMoney("cash", price, "dealer-item-bought") then
                        Player.Functions.AddItem(itemData.name, fromAmount, toSlot, itemData.info)
                        TriggerClientEvent('qb-drugs:client:updateDealerItems', src, itemData, fromAmount)
                        TriggerClientEvent('QBCore:Notify', src, itemInfo["label"] .. " bought!", "success")
                        TriggerEvent("qb-log:server:CreateLog", "dealers", "Dealer item bought", "green", "**" ..
                            GetPlayerName(src) .. "** bought a " .. itemInfo["label"] .. "  for $" .. price)
                    else
                        TriggerClientEvent('QBCore:Notify', src, "You don't have enough cash..", "error")
                    end
                end
            elseif QBCore.Shared.SplitStr(shopType, "_")[1] == "Itemshop" then
                if Player.Functions.RemoveMoney("cash", price, "itemshop-bought-item") then
                    if QBCore.Shared.SplitStr(itemData.name, "_")[1] == "weapon" then
                        itemData.info.serie = tostring(QBCore.Shared.RandomInt(2) .. QBCore.Shared.RandomStr(3) ..
                                                           QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) ..
                                                           QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(4))
                    end
                    if itemData.name:lower() == 'wallet' then
                        itemData.info.walletid = math.random(11111, 99999)
                    end
                    Player.Functions.AddItem(itemData.name, fromAmount, toSlot, itemData.info)
                    TriggerClientEvent('qb-shops:client:UpdateShop', src, QBCore.Shared.SplitStr(shopType, "_")[2],
                        itemData, fromAmount)
                    TriggerClientEvent('QBCore:Notify', src, itemInfo["label"] .. " bought!", "success")
                    TriggerEvent("qb-log:server:CreateLog", "shops", "Shop item bought", "green",
                        "**" .. GetPlayerName(src) .. "** bought a " .. itemInfo["label"] .. " for $" .. price)
                elseif bankBalance >= price then
                    Player.Functions.RemoveMoney("bank", price, "itemshop-bought-item")
                    if QBCore.Shared.SplitStr(itemData.name, "_")[1] == "weapon" then
                        itemData.info.serie = tostring(QBCore.Shared.RandomInt(2) .. QBCore.Shared.RandomStr(3) ..
                                                           QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) ..
                                                           QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(4))
                    end
                    if itemData.name:lower() == 'wallet' then
                        itemData.info.walletid = math.random(11111, 99999)
                    end
                    Player.Functions.AddItem(itemData.name, fromAmount, toSlot, itemData.info)
                    TriggerClientEvent('qb-shops:client:UpdateShop', src, QBCore.Shared.SplitStr(shopType, "_")[2],
                        itemData, fromAmount)
                    TriggerClientEvent('QBCore:Notify', src, itemInfo["label"] .. " bought!", "success")
                    TriggerEvent("qb-log:server:CreateLog", "shops", "Shop item bought", "green",
                        "**" .. GetPlayerName(src) .. "** bought a " .. itemInfo["label"] .. " for $" .. price)
                else
                    TriggerClientEvent('QBCore:Notify', src, "You don't have enough cash..", "error")
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
                    Player.Functions.AddItem(itemData.name, fromAmount, toSlot, itemData.info)
                    TriggerClientEvent('QBCore:Notify', src, itemInfo["label"] .. " bought!", "success")
                    TriggerEvent("qb-log:server:CreateLog", "shops", "Shop item bought", "green",
                        "**" .. GetPlayerName(src) .. "** bought a " .. itemInfo["label"] .. " for $" .. price)
                elseif bankBalance >= price then
                    Player.Functions.RemoveMoney("bank", price, "unkown-itemshop-bought-item")
                    Player.Functions.AddItem(itemData.name, fromAmount, toSlot, itemData.info)
                    TriggerClientEvent('QBCore:Notify', src, itemInfo["label"] .. " bought!", "success")
                    TriggerEvent("qb-log:server:CreateLog", "shops", "Shop item bought", "green",
                        "**" .. GetPlayerName(src) .. "** bought a " .. itemInfo["label"] .. " for $" .. price)
                else
                    TriggerClientEvent('QBCore:Notify', src, "You don\'t have enough cash..", "error")
                end
            end
        elseif fromInventory == "crafting" then
            local itemData = Config.CraftingItems[fromSlot]
            if hasCraftItems(src, itemData.costs, fromAmount) then
                TriggerClientEvent("inventory:client:CraftItems", src, itemData.name, itemData.costs, fromAmount,
                    toSlot, itemData.points)
            else
                TriggerClientEvent("inventory:client:UpdatePlayerInventory", src, true)
                TriggerClientEvent('QBCore:Notify', src, "You don't have the right items..", "error")
            end
        elseif fromInventory == "attachment_crafting" then
            local itemData = Config.AttachmentCrafting["items"][fromSlot]
            if hasCraftItems(src, itemData.costs, fromAmount) then
                TriggerClientEvent("inventory:client:CraftAttachment", src, itemData.name, itemData.costs, fromAmount,
                    toSlot, itemData.points)
            else
                TriggerClientEvent("inventory:client:UpdatePlayerInventory", src, true)
                TriggerClientEvent('QBCore:Notify', src, "You don't have the right items..", "error")
            end
        else
            -- drop
            fromInventory = tonumber(fromInventory)
            local fromItemData = Drops[fromInventory].items[fromSlot]
            local fromAmount = tonumber(fromAmount) ~= nil and tonumber(fromAmount) or fromItemData.amount
            if fromItemData ~= nil and fromItemData.amount >= fromAmount then
                local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                if toInventory == "player" or toInventory == "hotbar" then
                    local toItemData = Player.Functions.GetItemBySlot(toSlot)
                    RemoveFromDrop(fromInventory, fromSlot, itemInfo["name"], fromAmount)
                    if toItemData ~= nil then
                        local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                        if toItemData.name ~= fromItemData.name then
                            Player.Functions.RemoveItem(toItemData.name, toAmount, toSlot)
                            TriggerEvent('mh-cashasitem:server:updateCash', src, toItemData, toAmount, "remove", true)
                            AddToDrop(fromInventory, toSlot, itemInfo["name"], toAmount, toItemData.info)
                            if itemInfo["name"] == "radio" then
                                TriggerClientEvent('Radio.Set', src, false)
                            end
                            TriggerEvent("qb-log:server:CreateLog", "drop", "Swapped Item", "orange",
                                "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                    "* | id: *" .. src .. "*) swapped item; name: **" .. toItemData.name ..
                                    "**, amount: **" .. toAmount .. "** with item; name: **" .. fromItemData.name ..
                                    "**, amount: **" .. fromAmount .. "** - dropid: *" .. fromInventory .. "*")
                        else
                            TriggerEvent("qb-log:server:CreateLog", "drop", "Stacked Item", "orange",
                                "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                    "* | id: *" .. src .. "*) stacked item; name: **" .. toItemData.name ..
                                    "**, amount: **" .. toAmount .. "** - from dropid: *" .. fromInventory .. "*")
                        end
                    else
                        TriggerEvent("qb-log:server:CreateLog", "drop", "Received Item", "green",
                            "**" .. GetPlayerName(src) .. "** (citizenid: *" .. Player.PlayerData.citizenid ..
                                "* | id: *" .. src .. "*) received item; name: **" .. fromItemData.name ..
                                "**, amount: **" .. fromAmount .. "** -  dropid: *" .. fromInventory .. "*")
                    end
                    Player.Functions.AddItem(fromItemData.name, fromAmount, toSlot, fromItemData.info)
                    TriggerEvent('mh-cashasitem:server:updateCash', src, fromItemData, fromAmount, "add", true)
                else
                    toInventory = tonumber(toInventory)
                    local toItemData = Drops[toInventory].items[toSlot]
                    RemoveFromDrop(fromInventory, fromSlot, itemInfo["name"], fromAmount)
                    if toItemData ~= nil then
                        local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                        local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
                        if toItemData.name ~= fromItemData.name then
                            local itemInfo = QBCore.Shared.Items[toItemData.name:lower()]
                            RemoveFromDrop(toInventory, toSlot, itemInfo["name"], toAmount)
                            AddToDrop(fromInventory, fromSlot, itemInfo["name"], toAmount, toItemData.info)
                            if itemInfo["name"] == "radio" then
                                TriggerClientEvent('Radio.Set', src, false)
                            end
                        end
                    end
                    local itemInfo = QBCore.Shared.Items[fromItemData.name:lower()]
                    AddToDrop(toInventory, toSlot, itemInfo["name"], fromAmount, fromItemData.info)
                    if itemInfo["name"] == "radio" then
                        TriggerClientEvent('Radio.Set', src, false)
                    end
                end
            else
                TriggerClientEvent("QBCore:Notify", src, "Item doesn't exist??", "error")
            end
        end
    end)
```

# Replace this code in qb-inventory/server/main.lua
```lua
RegisterServerEvent("inventory:server:GiveItem", function(target, name, amount, slot)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local OtherPlayer = QBCore.Functions.GetPlayer(tonumber(target))
    local dist = #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(target)))
    if Player == OtherPlayer then
        return TriggerClientEvent('QBCore:Notify', src, "You can't give yourself an item?")
    end
    if dist > 2 then
        return TriggerClientEvent('QBCore:Notify', src, "You are too far away to give items!")
    end
    local item = Player.Functions.GetItemBySlot(slot)
    if not item then
        TriggerClientEvent('QBCore:Notify', src, "Item you tried giving not found!");
        return
    end
    if item.name ~= name then
        TriggerClientEvent('QBCore:Notify', src, "Incorrect item found try again!");
        return
    end
    if amount <= item.amount then
        if amount == 0 then
            amount = item.amount
        end
        if Player.Functions.RemoveItem(item.name, amount, item.slot) then
            TriggerEvent('mh-cashasitem:server:updateCash', src, item, amount, "remove", true)
            if OtherPlayer.Functions.AddItem(item.name, amount, false, item.info) then
                TriggerEvent('mh-cashasitem:server:updateCash', target, item, amount, "add", true)
                TriggerClientEvent('inventory:client:ItemBox', target, QBCore.Shared.Items[item.name], "add")
                TriggerClientEvent('QBCore:Notify', target,
                    "You Received " .. amount .. ' ' .. item.label .. " From " .. Player.PlayerData.charinfo.firstname ..
                        " " .. Player.PlayerData.charinfo.lastname)
                TriggerClientEvent("inventory:client:UpdatePlayerInventory", target, true)
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item.name], "remove")
                TriggerClientEvent('QBCore:Notify', src,
                    "You gave " .. OtherPlayer.PlayerData.charinfo.firstname .. " " ..
                        OtherPlayer.PlayerData.charinfo.lastname .. " " .. amount .. " " .. item.label .. "!")
                TriggerClientEvent("inventory:client:UpdatePlayerInventory", src, true)
                TriggerClientEvent('qb-inventory:client:giveAnim', src)
                TriggerClientEvent('qb-inventory:client:giveAnim', target)
            else
                Player.Functions.AddItem(item.name, amount, item.slot, item.info)
                TriggerEvent('mh-cashasitem:server:updateCash', src, item, amount, "add", true)
                TriggerClientEvent('QBCore:Notify', src, "The other players inventory is full!", "error")
                TriggerClientEvent('QBCore:Notify', target, "Your inventory is full!", "error")
                TriggerClientEvent("inventory:client:UpdatePlayerInventory", src, false)
                TriggerClientEvent("inventory:client:UpdatePlayerInventory", target, false)
            end
        else
            TriggerClientEvent('QBCore:Notify', src, "You do not have enough of the item", "error")
        end
    else
        TriggerClientEvent('QBCore:Notify', src, "You do not have enough items to transfer")
    end
end)
```
