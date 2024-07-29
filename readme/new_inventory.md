# New QB Inventory

# Server.cfg
```conf
# QBCore & Extra stuff
ensure qb-core
ensure mh-cashasitem -- ADD HERE
ensure [qb]
ensure [standalone]
ensure [voice]
ensure [defaultmaps]

ensure [mh]
```


# Edit this code below Client side 
- in `qb-inventory/client/main.lua` around line 163
- From
```lua
RegisterNetEvent('qb-inventory:client:openInventory', function(items, other)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        inventory = items,
        slots = Config.MaxSlots,
        maxweight = Config.MaxWeight,
        other = other
    })
end)
```
- To 
```lua
RegisterNetEvent('qb-inventory:client:openInventory', function(items, other)
    TriggerServerEvent('inventory:server:OpenInventory') -- ADD THIS HERE
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        inventory = items,
        slots = Config.MaxSlots,
        maxweight = Config.MaxWeight,
        other = other
    })
end)
```

# Edit this code from (server side) 
- in `qb-inventory/server/main.lua` around line 416
- From
```lua
RegisterNetEvent('qb-inventory:server:SetInventoryData', function(fromInventory, toInventory, fromSlot, toSlot, fromAmount, toAmount)
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
            end
        elseif not toItem and toAmount < fromAmount then
            if RemoveItem(fromId, fromItem.name, toAmount, fromSlot, 'split item') then
                AddItem(toId, fromItem.name, toAmount, toSlot, fromItem.info, 'split item')
            end
        else
            if toItem then
                if RemoveItem(fromId, fromItem.name, fromAmount, fromSlot, 'swapped item') and RemoveItem(toId, toItem.name, toAmount, toSlot, 'swapped item') then
                    AddItem(toId, fromItem.name, fromAmount, toSlot, fromItem.info, 'swapped item')
                    AddItem(fromId, toItem.name, toAmount, fromSlot, toItem.info, 'swapped item')
                end
            else
                if RemoveItem(fromId, fromItem.name, toAmount, fromSlot, 'moved item') then
                    AddItem(toId, fromItem.name, toAmount, toSlot, fromItem.info, 'moved item')
                end
            end
        end
    end
end)
```
- To
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
                exports['mh-cashasitem']:UpdateCashItem(fromId, fromItem, toAmount, 'remove', true)
                if AddItem(toId, toItem.name, toAmount, toSlot, toItem.info, 'stacked item') then
                    exports['mh-cashasitem']:UpdateCashItem(toId, toItem, toAmount, 'add', true)
                end
            end
        elseif not toItem and toAmount < fromAmount then
            if RemoveItem(fromId, fromItem.name, toAmount, fromSlot, 'split item') then
                exports['mh-cashasitem']:UpdateCashItem(fromId, fromItem, toAmount, 'remove', true)
                if AddItem(toId, fromItem.name, toAmount, toSlot, fromItem.info, 'split item') then
                    exports['mh-cashasitem']:UpdateCashItem(toId, fromItem, toAmount, 'add', true)
                end
            end
        else
            if toItem then
                if RemoveItem(fromId, fromItem.name, fromAmount, fromSlot, 'swapped item') and RemoveItem(toId, toItem.name, toAmount, toSlot, 'swapped item') then
                    exports['mh-cashasitem']:UpdateCashItem(fromId, fromItem, fromAmount, 'remove', true)
                    exports['mh-cashasitem']:UpdateCashItem(toId, toItem, toAmount, 'remove', true)
                    if AddItem(toId, fromItem.name, fromAmount, toSlot, fromItem.info, 'swapped item') and AddItem(fromId, toItem.name, toAmount, fromSlot, toItem.info, 'swapped item') then
                        exports['mh-cashasitem']:UpdateCashItem(toId, fromItem, fromAmount, 'add', true)
                        exports['mh-cashasitem']:UpdateCashItem(fromId, toItem, toAmount, 'add', true)
                    end
                end
            else
                if RemoveItem(fromId, fromItem.name, toAmount, fromSlot, 'moved item') then
                    exports['mh-cashasitem']:UpdateCashItem(fromId, fromItem, toAmount, 'remove', false)
                    if AddItem(toId, fromItem.name, toAmount, toSlot, fromItem.info, 'moved item') then
                        exports['mh-cashasitem']:UpdateCashItem(toId, fromItem, toAmount, 'add', false)
                    end
                end
            end
        end
    end
end)
```

# Replace Code (Server side)
- `qb-inventory/server/main.lua` around line 230
- From
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

- To
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

    if item.name == 'cash' or item.name == 'black_money' or item.name == 'crypto' then 
        cb(false) 
        return 
    end

    if RemoveItem(src, item.name, item.amount, item.fromSlot, 'dropped item') then
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
