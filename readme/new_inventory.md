# New QB Inventory

# Edit this code below (Server side)
- From
```lua
function OpenInventoryById(source, targetId)
    local QBPlayer = QBCore.Functions.GetPlayer(source)
    local TargetPlayer = QBCore.Functions.GetPlayer(tonumber(targetId))
    if not QBPlayer or not TargetPlayer then return end
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
- To 
```lua
function OpenInventoryById(source, targetId)
    local QBPlayer = QBCore.Functions.GetPlayer(source)
    local TargetPlayer = QBCore.Functions.GetPlayer(tonumber(targetId))
    if not QBPlayer or not TargetPlayer then return end
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
    TriggerEvent('inventory:server:OpenInventory', source) -- ADD HERE
    TriggerClientEvent('qb-inventory:client:openInventory', source, playerItems, formattedInventory)
end
```

# Edit this code from (server side)
- From
```lua
local CashAsItemUpdateTrigger = "mh-cashasitem:server:updateCash"

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
                TriggerEvent(CashAsItemUpdateTrigger, fromId, fromItem, toAmount, "remove", true)
                TriggerEvent(CashAsItemUpdateTrigger, toId, toItem, toAmount, "add", true)
                AddItem(toId, toItem.name, toAmount, toSlot, toItem.info, 'stacked item')
            end
        elseif not toItem and toAmount < fromAmount then
            if RemoveItem(fromId, fromItem.name, toAmount, fromSlot, 'split item') then
                TriggerEvent(CashAsItemUpdateTrigger, fromId, fromItem, toAmount, "remove", true)
                TriggerEvent(CashAsItemUpdateTrigger, toId, toItem, toAmount, "add", true)
                AddItem(toId, fromItem.name, toAmount, toSlot, fromItem.info, 'split item')
            end
        else
            if toItem then
                if RemoveItem(fromId, fromItem.name, fromAmount, fromSlot, 'swapped item') and RemoveItem(toId, toItem.name, toAmount, toSlot, 'swapped item') then
                    TriggerEvent(CashAsItemUpdateTrigger, fromId, fromItem, fromAmount, "remove", true)
                    TriggerEvent(CashAsItemUpdateTrigger, toId, toItem, toAmount, "remove", true)
                    TriggerEvent(CashAsItemUpdateTrigger, toId, fromItem, fromAmount, "add", true)
                    TriggerEvent(CashAsItemUpdateTrigger, fromId, toItem, toAmount, "add", true)
                    AddItem(toId, fromItem.name, fromAmount, toSlot, fromItem.info, 'swapped item')
                    AddItem(fromId, toItem.name, toAmount, fromSlot, toItem.info, 'swapped item')
                end
            else
                if RemoveItem(fromId, fromItem.name, toAmount, fromSlot, 'moved item') then
                    TriggerEvent(CashAsItemUpdateTrigger, fromId, fromItem, toAmount, "remove", false)
                    TriggerEvent(CashAsItemUpdateTrigger, toId, fromItem, toAmount, "add", false)
                    AddItem(toId, fromItem.name, toAmount, toSlot, fromItem.info, 'moved item')
                end
            end
        end
    end
end)
```

# Edit this code from (server side)
- From
```lua
RegisterNetEvent('qb-inventory:server:useItem', function(item)
    local itemData = GetItemBySlot(source, item.slot)
    if not itemData then return end
    local itemInfo = QBCore.Shared.Items[itemData.name]
    if itemData.type == 'weapon' then
        TriggerClientEvent('qb-weapons:client:UseWeapon', source, itemData, itemData.info.quality and itemData.info.quality > 0)
        TriggerClientEvent('qb-inventory:client:ItemBox', source, itemInfo, 'use')
    else
        UseItem(itemData.name, source, itemData)
        TriggerClientEvent('qb-inventory:client:ItemBox', source, itemInfo, 'use')
    end
end)
```
- to 
```lua
RegisterNetEvent('qb-inventory:server:useItem', function(item)
    local itemData = GetItemBySlot(source, item.slot)
    if not itemData then return end
    local itemInfo = QBCore.Shared.Items[itemData.name]
    if itemData.type == 'weapon' then
        TriggerClientEvent('qb-weapons:client:UseWeapon', source, itemData, itemData.info.quality and itemData.info.quality > 0)
        TriggerClientEvent('qb-inventory:client:ItemBox', source, itemInfo, 'use')
    else
        if Config.Stashes[itemData.name] then lastUsedStashItem = itemData end -- ADD HERE
        UseItem(itemData.name, source, itemData)
        TriggerClientEvent('qb-inventory:client:ItemBox', source, itemInfo, 'use')
    end
end)
```
