# QB Inventory 2.0.0

# Example Server.cfg
```conf
# QBCore & Extra stuff
ensure qb-core
ensure mh-cashasitem -- ADD HERE
ensure [qb]
ensure [standalone]
ensure [voice]
ensure [defaultmaps]
```

# Replace this code below (server side)
- in `qb-inventory/server/functions.lua` and find the function `function OpenInventory(source, identifier, data)`
- add below `if Player(source).state.inv_busy then return end`
```lua
if GetResourceState("mh-cashasitem") ~= 'missing' then
    exports['mh-cashasitem']:UpdateItem(source, 'cash')
    exports['mh-cashasitem']:UpdateItem(source, 'black_money')
    exports['mh-cashasitem']:UpdateItem(source, 'crypto')
end
```

# Replace this code below (Server side)
- in `qb-inventory/server/main.lua` around line 282
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

# Replace this code below (server side) 
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

# Replace this code below (Server side)
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

    if GetResourceState("mh-cashasitem") ~= 'missing' then
        exports['mh-cashasitem']:UpdateCash(source, item, giveAmount, 'remove')
    end

    if GetResourceState("mh-cashasitem") ~= 'missing' then
        exports['mh-cashasitem']:UpdateCash(target, item, giveAmount, 'add')
    end

    if itemInfo.type == 'weapon' then checkWeapon(source, item) end
    TriggerClientEvent('qb-inventory:client:giveAnim', source)
    TriggerClientEvent('qb-inventory:client:ItemBox', source, itemInfo, 'remove', giveAmount)
    TriggerClientEvent('qb-inventory:client:giveAnim', target)
    TriggerClientEvent('qb-inventory:client:ItemBox', target, itemInfo, 'add', giveAmount)
    
    if Player(target).state.inv_busy then TriggerClientEvent('qb-inventory:client:updateInventory', target) end

    cb(true)
end)
```
