# QB Inventory 2.0.0

# Replace code in qb-inventory (server side)
- In `qb-inventory/server/functions.lua` and find the function `OpenInventoryById(source, targetId)`
- Replace that function to this function below
```lua
function OpenInventoryById(source, targetId)
    local QBPlayer = QBCore.Functions.GetPlayer(source)
    local TargetPlayer = QBCore.Functions.GetPlayer(tonumber(targetId))
    if not QBPlayer or not TargetPlayer then return end

    if GetResourceState("mh-cashasitem") ~= 'missing' then
        exports['mh-cashasitem']:UpdateItem(source, 'cash')
        exports['mh-cashasitem']:UpdateItem(source, 'black_money')
        exports['mh-cashasitem']:UpdateItem(source, 'crypto')

        exports['mh-cashasitem']:UpdateItem(targetId, 'cash')
        exports['mh-cashasitem']:UpdateItem(targetId, 'black_money')
        exports['mh-cashasitem']:UpdateItem(targetId, 'crypto')
    end

    if Player(targetId).state.inv_busy then CloseInventory(targetId) end
    local playerItems = QBPlayer.PlayerData.items
    local targetItems = TargetPlayer.PlayerData.items
    local formattedInventory = {
        name = 'otherplayer-' .. targetId,
        label = GetPlayerName(targetId),
        maxweight = Config.MaxWeight,
        slots = Config.MaxSlots,
        inventory = targetItems
    }
    Wait(1500)
    Player(targetId).state.inv_busy = true
    TriggerClientEvent('qb-inventory:client:openInventory', source, playerItems, formattedInventory)
end
```

# Replace code in qb-inventory (server side)
- In `qb-inventory/server/functions.lua` and find the function `function OpenInventory(source, identifier, data)`
- Replace that function to this function below
```lua
function OpenInventory(source, identifier, data)
    if Player(source).state.inv_busy then return end

    local QBPlayer = QBCore.Functions.GetPlayer(source)
    if not QBPlayer then return end
    
    if GetResourceState("mh-cashasitem") ~= 'missing' then
        exports['mh-cashasitem']:UpdateItem(source, 'cash')
        exports['mh-cashasitem']:UpdateItem(source, 'black_money')
        exports['mh-cashasitem']:UpdateItem(source, 'crypto')
    end
    
    if not identifier then
        Player(source).state.inv_busy = true
        TriggerClientEvent('qb-inventory:client:openInventory', source, QBPlayer.PlayerData.items)
        return
    end

    if type(identifier) ~= 'string' then
        print('Inventory tried to open an invalid identifier')
        return
    end

    local inventory = Inventories[identifier]

    if inventory and inventory.isOpen then
        TriggerClientEvent('QBCore:Notify', source, 'This inventory is currently in use', 'error')
        return
    end
    if not inventory then inventory = InitializeInventory(identifier, data) end
    inventory.maxweight = (inventory and inventory.maxweight) or (data and data.maxweight) or Config.StashSize.maxweight
    inventory.slots = (inventory and inventory.slots) or (data and data.slots) or Config.StashSize.slots
    inventory.label = (inventory and inventory.label) or (data and data.label) or identifier
    inventory.isOpen = source

    local formattedInventory = {
        name = identifier,
        label = inventory.label,
        maxweight = inventory.maxweight,
        slots = inventory.slots,
        inventory = inventory.items
    }
    TriggerClientEvent('qb-inventory:client:openInventory', source, QBPlayer.PlayerData.items, formattedInventory)
end
```

# Replace code in qb-inventory (server side)
- In `qb-inventory/server/main.lua` around line 282
```lua
QBCore.Functions.CreateCallback('qb-inventory:server:createDrop', function(source, cb, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then
        cb(false)
        return
    end
    local playerPed = GetPlayerPed(src)
    local playerCoords = GetEntityCoords(playerPed)

    if RemoveItem(src, item.name, item.amount, item.fromSlot, 'dropped item') then
        if GetResourceState("mh-cashasitem") ~= 'missing' then
            exports['mh-cashasitem']:UpdateCash(src, item.name, item.amount, 'remove')
        end
        if item.type == 'weapon' then checkWeapon(src, item) end
        TaskPlayAnim(playerPed, 'pickup_object', 'pickup_low', 8.0, -8.0, 2000, 0, 0, false, false, false)
        local bag = CreateObjectNoOffset(Config.ItemDropObject, playerCoords.x + 0.5, playerCoords.y + 0.5, playerCoords.z, true, true, false)
        local dropId = NetworkGetNetworkIdFromEntity(bag)
        local newDropId = 'drop-' .. dropId
        if not Drops[newDropId] then
            Drops[newDropId] = {
                name = newDropId,
                label = 'Drop',
                items = { item },
                entityId = dropId,
                createdTime = os.time(),
                coords = playerCoords,
                maxweight = Config.DropSize.maxweight,
                slots = Config.DropSize.slots,
                isOpen = true
            }
            TriggerClientEvent('qb-inventory:client:setupDropTarget', -1, dropId)
        else
            table.insert(Drops[newDropId].items, item)
        end
        cb(dropId)
    else
        cb(false)
    end
end)
```

# Replace code in qb-inventory (server side)
- in `qb-inventory/server/main.lua` around line 472
```lua
RegisterNetEvent('qb-inventory:server:SetInventoryData', function(fromInventory, toInventory, fromSlot, toSlot, fromAmount, toAmount)
    if toInventory:find('shop-') then return end
    if not fromInventory or not toInventory or not fromSlot or not toSlot or not fromAmount or not toAmount then return end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    fromSlot, toSlot, fromAmount, toAmount = tonumber(fromSlot), tonumber(toSlot), tonumber(fromAmount), tonumber(toAmount)
    
    local fromItem = getItem(fromInventory, src, fromSlot)
    local toItem = getItem(toInventory, src, toSlot)

    if fromItem then
        if not toItem and toAmount > fromItem.amount then return end
        if fromInventory == 'player' and toInventory ~= 'player' then checkWeapon(src, fromItem) end
        local fromId = getIdentifier(fromInventory, src)
        local toId = getIdentifier(toInventory, src)

        if toItem and fromItem.name == toItem.name then
            if RemoveItem(fromId, fromItem.name, toAmount, fromSlot, 'stacked item') then
                AddItem(toId, toItem.name, toAmount, toSlot, toItem.info, 'stacked item')
                if GetResourceState("mh-cashasitem") ~= 'missing' then
                    exports['mh-cashasitem']:UpdateCash(fromId, fromItem, toAmount, 'remove')
                    exports['mh-cashasitem']:UpdateCash(toId, toItem, toAmount, 'add')
                end
            end
        elseif not toItem and toAmount < fromAmount then
            if RemoveItem(fromId, fromItem.name, toAmount, fromSlot, 'split item') then
                AddItem(toId, fromItem.name, toAmount, toSlot, fromItem.info, 'split item')
                if GetResourceState("mh-cashasitem") ~= 'missing' then
                    exports['mh-cashasitem']:UpdateCash(fromId, fromItem, toAmount, 'remove')
                    exports['mh-cashasitem']:UpdateCash(toId, fromItem, toAmount, 'add')
                end
            end
        else
            if toItem then
                if RemoveItem(fromId, fromItem.name, fromAmount, fromSlot, 'swapped item') and RemoveItem(toId, toItem.name, toAmount, toSlot, 'swapped item') then
                    AddItem(toId, fromItem.name, fromAmount, toSlot, fromItem.info, 'swapped item') 
                    AddItem(fromId, toItem.name, toAmount, fromSlot, toItem.info, 'swapped item')
                    if GetResourceState("mh-cashasitem") ~= 'missing' then
                        exports['mh-cashasitem']:UpdateCash(fromId, fromItem, fromAmount, 'remove')
                        exports['mh-cashasitem']:UpdateCash(toId, toItem, toAmount, 'remove')
                        exports['mh-cashasitem']:UpdateCash(toId, fromItem, fromAmount, 'add')
                        exports['mh-cashasitem']:UpdateCash(fromId, toItem, toAmount, 'add')
                    end
                end
            else
                if RemoveItem(fromId, fromItem.name, toAmount, fromSlot, 'moved item') then
                    AddItem(toId, fromItem.name, toAmount, toSlot, fromItem.info, 'moved item')
                    if GetResourceState("mh-cashasitem") ~= 'missing' then
                        exports['mh-cashasitem']:UpdateCash(fromId, fromItem, toAmount, 'remove')
                        exports['mh-cashasitem']:UpdateCash(toId, fromItem, toAmount, 'add')
                    end
                end
            end
        end
    end
end)
```

# Replace code in qb-inventory (server side)
- in `qb-inventory/server/main.lua` around line 318
```lua
QBCore.Functions.CreateCallback('qb-inventory:server:giveItem', function(source, cb, target, item, amount, slot, info)
    local player = QBCore.Functions.GetPlayer(source)
    if not player or player.PlayerData.metadata['isdead'] or player.PlayerData.metadata['inlaststand'] or player.PlayerData.metadata['ishandcuffed'] then
        cb(false)
        return
    end
    local playerPed = GetPlayerPed(source)

    local Target = QBCore.Functions.GetPlayer(target)
    if not Target or Target.PlayerData.metadata['isdead'] or Target.PlayerData.metadata['inlaststand'] or Target.PlayerData.metadata['ishandcuffed'] then
        cb(false)
        return
    end
    local targetPed = GetPlayerPed(target)

    local pCoords = GetEntityCoords(playerPed)
    local tCoords = GetEntityCoords(targetPed)
    if #(pCoords - tCoords) > 5 then
        cb(false)
        return
    end

    local itemInfo = QBCore.Shared.Items[item:lower()]
    if not itemInfo then
        cb(false)
        return
    end

    local hasItem = HasItem(source, item)
    if not hasItem then
        cb(false)
        return
    end

    local itemAmount = GetItemByName(source, item).amount
    if itemAmount <= 0 then
        cb(false)
        return
    end

    local giveAmount = tonumber(amount)
    if giveAmount > itemAmount then
        cb(false)
        return
    end

    local removeItem = RemoveItem(source, item, giveAmount, slot, 'Item given to ID #' .. target)
    if not removeItem then
        cb(false)
        return
    end

    local giveItem = AddItem(target, item, giveAmount, false, info, 'Item given from ID #' .. source)
    if not giveItem then
        cb(false)
        return
    end

    if itemInfo.type == 'weapon' then checkWeapon(source, item) end

    if GetResourceState("mh-cashasitem") ~= 'missing' then
        exports['mh-cashasitem']:UpdateCash(source, item, giveAmount, 'remove')
    end

    if GetResourceState("mh-cashasitem") ~= 'missing' then
        exports['mh-cashasitem']:UpdateCash(target, item, giveAmount, 'add')
    end

    TriggerClientEvent('qb-inventory:client:giveAnim', source)
    TriggerClientEvent('qb-inventory:client:ItemBox', source, itemInfo, 'remove', giveAmount)
    TriggerClientEvent('qb-inventory:client:giveAnim', target)
    TriggerClientEvent('qb-inventory:client:ItemBox', target, itemInfo, 'add', giveAmount)
    
    if Player(target).state.inv_busy then TriggerClientEvent('qb-inventory:client:updateInventory', target) end

    cb(true)
end)
```
