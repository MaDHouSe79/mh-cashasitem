# QB Inventory

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
            if item.name == 'cash' or item.name == 'black_money' or item.name == 'crypto' then
                exports['mh-cashasitem']:UpdateCashItem(src, item.name, item.amount, 'remove', true)
            end
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

        if GetResourceState("mh-cashasitem") ~= 'missing' then
            if fromItem.name == 'cash' or fromItem.name == 'black_money' or fromItem.name == 'crypto' then
                if fromInventory == 'player' then
                    if toInventory:find('trunk-') or toInventory:find('glovebox-') or toInventory:find('safe-') or toInventory:find('stash-') then
                        exports['mh-cashasitem']:UpdateCashItem(src, fromItem, fromAmount, 'remove', true)
                    elseif toInventory:find('otherplayer-') then
                        exports['mh-cashasitem']:UpdateCashItem(toId, fromItem, fromAmount, 'add', true)
                        exports['mh-cashasitem']:UpdateCashItem(fromId, fromItem, fromAmount, 'remove', true)
                    end
                elseif toInventory == 'player' then
                    if fromInventory:find('trunk-') or fromInventory:find('glovebox-') or fromInventory:find('safe-') or fromInventory:find('stash-') or fromInventory:find('drop-') then
                        exports['mh-cashasitem']:UpdateCashItem(toId, fromItem, fromAmount, 'add', true)
                    elseif fromInventory:find('otherplayer-') then
                        exports['mh-cashasitem']:UpdateCashItem(fromId, fromItem, fromAmount, 'remove', true)
                        exports['mh-cashasitem']:UpdateCashItem(toId, fromItem, fromAmount, 'add', true)
                    end
                end
            end
        end

        if toItem and fromItem.name == toItem.name then
            if RemoveItem(fromId, fromItem.name, toAmount, fromSlot, 'stacked item') then
                AddItem(toId, toItem.name, toAmount, toSlot, toItem.info, 'stacked item')
                if GetResourceState("mh-cashasitem") ~= 'missing' then
                    exports['mh-cashasitem']:UpdateCashItem(fromId, fromItem, toAmount, 'remove', true)
                    exports['mh-cashasitem']:UpdateCashItem(toId, toItem, toAmount, 'add', true)
                end
            end
        elseif not toItem and toAmount < fromAmount then
            if RemoveItem(fromId, fromItem.name, toAmount, fromSlot, 'split item') then
                AddItem(toId, fromItem.name, toAmount, toSlot, fromItem.info, 'split item')
                if GetResourceState("mh-cashasitem") ~= 'missing' then
                    exports['mh-cashasitem']:UpdateCashItem(fromId, fromItem, toAmount, 'remove', true)
                    exports['mh-cashasitem']:UpdateCashItem(toId, fromItem, toAmount, 'add', true)
                end
            end
        else
            if toItem then
                if RemoveItem(fromId, fromItem.name, fromAmount, fromSlot, 'swapped item') and RemoveItem(toId, toItem.name, toAmount, toSlot, 'swapped item') then
                    AddItem(toId, fromItem.name, fromAmount, toSlot, fromItem.info, 'swapped item') 
                    AddItem(fromId, toItem.name, toAmount, fromSlot, toItem.info, 'swapped item')
                    if GetResourceState("mh-cashasitem") ~= 'missing' then
                        exports['mh-cashasitem']:UpdateCashItem(fromId, fromItem, fromAmount, 'remove', true)
                        exports['mh-cashasitem']:UpdateCashItem(toId, toItem, toAmount, 'remove', true)
                        exports['mh-cashasitem']:UpdateCashItem(toId, fromItem, fromAmount, 'add', true)
                        exports['mh-cashasitem']:UpdateCashItem(fromId, toItem, toAmount, 'add', true)
                    end
                end
            else
                if RemoveItem(fromId, fromItem.name, toAmount, fromSlot, 'moved item') then
                    AddItem(toId, fromItem.name, toAmount, toSlot, fromItem.info, 'moved item')
                    if GetResourceState("mh-cashasitem") ~= 'missing' then
                        exports['mh-cashasitem']:UpdateCashItem(fromId, fromItem, toAmount, 'remove', true)
                        exports['mh-cashasitem']:UpdateCashItem(toId, fromItem, toAmount, 'add', true)
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
    if GetResourceState("mh-cashasitem") ~= 'missing' then
        exports['mh-cashasitem']:UpdateCashItem(source, item, giveAmount, 'remove', true)
    end

    local giveItem = AddItem(target, item, giveAmount, false, info, 'Item given from ID #' .. source)
    if not giveItem then
        cb(false)
        return
    end
    if GetResourceState("mh-cashasitem") ~= 'missing' then
        exports['mh-cashasitem']:UpdateCashItem(target, item, giveAmount, 'add', true)
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

# Replace code in app.js around line 217
- `qb-inventory/html/app.js` and find `handleMouseDown(event, slot, inventory)`
- replace with code below
```js
handleMouseDown(event, slot, inventory) {
    if (event.button === 1) return; // skip middle mouse
    event.preventDefault();
    const itemInSlot = this.getItemInSlot(slot, inventory);
    if (event.button === 0) {
        if (event.shiftKey && itemInSlot) {
            this.splitAndPlaceItem(itemInSlot, inventory);
        } else {
            this.startDrag(event, slot, inventory);
        }
    } else if (event.button === 2 && itemInSlot) {
        if (this.otherInventoryName.startsWith("shop-")) {
            this.handlePurchase(slot, itemInSlot.slot, itemInSlot, 1);
            return;
        }

        if (itemInSlot.name == 'cash' || itemInSlot.name == 'black_money' || itemInSlot.name == 'crypto') {
            return;
        }
        
        if (!this.isOtherInventoryEmpty) {
            this.moveItemBetweenInventories(itemInSlot, inventory);
        } else {
            this.showContextMenuOptions(event, itemInSlot);
        }
    }
},
```
