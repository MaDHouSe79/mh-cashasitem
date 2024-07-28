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


# Replace code
- in `qb-inventory/server/commands.lua`
- From
```lua
QBCore.Commands.Add('giveitem', 'Give An Item (Admin Only)', { { name = 'id', help = 'Player ID' }, { name = 'item', help = 'Name of the item (not a label)' }, { name = 'amount', help = 'Amount of items' } }, false, function(source, args)
    local id = tonumber(args[1])
    local player = QBCore.Functions.GetPlayer(id)
    local amount = tonumber(args[3]) or 1
    local itemData = QBCore.Shared.Items[tostring(args[2]):lower()]
    if player then
        if itemData then
            -- check iteminfo
            local info = {}
            if itemData['name'] == 'id_card' then
                info.citizenid = player.PlayerData.citizenid
                info.firstname = player.PlayerData.charinfo.firstname
                info.lastname = player.PlayerData.charinfo.lastname
                info.birthdate = player.PlayerData.charinfo.birthdate
                info.gender = player.PlayerData.charinfo.gender
                info.nationality = player.PlayerData.charinfo.nationality
            elseif itemData['name'] == 'driver_license' then
                info.firstname = player.PlayerData.charinfo.firstname
                info.lastname = player.PlayerData.charinfo.lastname
                info.birthdate = player.PlayerData.charinfo.birthdate
                info.type = 'Class C Driver License'
            elseif itemData['type'] == 'weapon' then
                amount = 1
                info.serie = tostring(QBCore.Shared.RandomInt(2) .. QBCore.Shared.RandomStr(3) .. QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(4))
                info.quality = 100
            elseif itemData['name'] == 'harness' then
                info.uses = 20
            elseif itemData['name'] == 'markedbills' then
                info.worth = math.random(5000, 10000)
            elseif itemData['name'] == 'printerdocument' then
                info.url = 'https://cdn.discordapp.com/attachments/870094209783308299/870104331142189126/Logo_-_Display_Picture_-_Stylized_-_Red.png'
            end

            if AddItem(id, itemData['name'], amount, false, info, 'give item command') then
                QBCore.Functions.Notify(source, Lang:t('notify.yhg') .. GetPlayerName(id) .. ' ' .. amount .. ' ' .. itemData['name'] .. '', 'success')
                TriggerClientEvent('qb-inventory:client:ItemBox', id, itemData, 'add', amount)
                if Player(id).state.inv_busy then TriggerClientEvent('qb-inventory:client:updateInventory', id) end
            else
                QBCore.Functions.Notify(source, Lang:t('notify.cgitem'), 'error')
            end
        else
            QBCore.Functions.Notify(source, Lang:t('notify.idne'), 'error')
        end
    else
        QBCore.Functions.Notify(source, Lang:t('notify.pdne'), 'error')
    end
end, 'admin')

QBCore.Commands.Add('randomitems', 'Receive random items', {}, false, function(source)
    local player = QBCore.Functions.GetPlayer(source)
    local playerInventory = player.PlayerData.items
    local filteredItems = {}
    for k, v in pairs(QBCore.Shared.Items) do
        if QBCore.Shared.Items[k]['type'] ~= 'weapon' then
            filteredItems[#filteredItems + 1] = v
        end
    end
    for _ = 1, 10, 1 do
        local randitem = filteredItems[math.random(1, #filteredItems)]
        local amount = math.random(1, 10)
        if randitem['unique'] then
            amount = 1
        end
        local emptySlot = nil
        for i = 1, Config.MaxSlots do
            if not playerInventory[i] then
                emptySlot = i
                break
            end
        end
        if emptySlot then
            if AddItem(source, randitem.name, amount, emptySlot, false, 'random items command') then
                TriggerClientEvent('qb-inventory:client:ItemBox', source, QBCore.Shared.Items[randitem.name], 'add', amount)
                player = QBCore.Functions.GetPlayer(source)
                playerInventory = player.PlayerData.items
                if Player(source).state.inv_busy then TriggerClientEvent('qb-inventory:client:updateInventory', source) end
            end
            Wait(1000)
        end
    end
end, 'god')
```
- TO
```lua
QBCore.Commands.Add('giveitem', 'Give An Item (Admin Only)', { { name = 'id', help = 'Player ID' }, { name = 'item', help = 'Name of the item (not a label)' }, { name = 'amount', help = 'Amount of items' } }, false, function(source, args)
    local id = tonumber(args[1])
    local player = QBCore.Functions.GetPlayer(id)
    local amount = tonumber(args[3]) or 1
    local itemData = QBCore.Shared.Items[tostring(args[2]):lower()]
    if player then
        if itemData then
            -- check iteminfo
            local info = {}
            if itemData['name'] == 'id_card' then
                info.citizenid = player.PlayerData.citizenid
                info.firstname = player.PlayerData.charinfo.firstname
                info.lastname = player.PlayerData.charinfo.lastname
                info.birthdate = player.PlayerData.charinfo.birthdate
                info.gender = player.PlayerData.charinfo.gender
                info.nationality = player.PlayerData.charinfo.nationality
            elseif itemData['name'] == 'driver_license' then
                info.firstname = player.PlayerData.charinfo.firstname
                info.lastname = player.PlayerData.charinfo.lastname
                info.birthdate = player.PlayerData.charinfo.birthdate
                info.type = 'Class C Driver License'
            elseif itemData['type'] == 'weapon' then
                amount = 1
                info.serie = tostring(QBCore.Shared.RandomInt(2) .. QBCore.Shared.RandomStr(3) .. QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(4))
                info.quality = 100
            elseif itemData['name'] == 'harness' then
                info.uses = 20
            elseif itemData['name'] == 'markedbills' then
                info.worth = math.random(5000, 10000)
            elseif itemData['name'] == 'printerdocument' then
                info.url = 'https://cdn.discordapp.com/attachments/870094209783308299/870104331142189126/Logo_-_Display_Picture_-_Stylized_-_Red.png'
            end

            if AddItem(id, itemData['name'], amount, false, info, 'give item command') then
                exports['mh-cashasitem']:UpdateCashItem(id, itemData, amount, 'add', true)
                QBCore.Functions.Notify(source, Lang:t('notify.yhg') .. GetPlayerName(id) .. ' ' .. amount .. ' ' .. itemData['name'] .. '', 'success')
                TriggerClientEvent('qb-inventory:client:ItemBox', id, itemData, 'add', amount)
                if Player(id).state.inv_busy then TriggerClientEvent('qb-inventory:client:updateInventory', id) end
            else
                QBCore.Functions.Notify(source, Lang:t('notify.cgitem'), 'error')
            end
        else
            QBCore.Functions.Notify(source, Lang:t('notify.idne'), 'error')
        end
    else
        QBCore.Functions.Notify(source, Lang:t('notify.pdne'), 'error')
    end
end, 'admin')

QBCore.Commands.Add('randomitems', 'Receive random items', {}, false, function(source)
    local player = QBCore.Functions.GetPlayer(source)
    local playerInventory = player.PlayerData.items
    local filteredItems = {}
    for k, v in pairs(QBCore.Shared.Items) do
        if QBCore.Shared.Items[k]['type'] ~= 'weapon' then
            filteredItems[#filteredItems + 1] = v
        end
    end
    for _ = 1, 10, 1 do
        local randitem = filteredItems[math.random(1, #filteredItems)]
        local amount = math.random(1, 10)
        if randitem['unique'] then
            amount = 1
        end
        local emptySlot = nil
        for i = 1, Config.MaxSlots do
            if not playerInventory[i] then
                emptySlot = i
                break
            end
        end
        if emptySlot then
            if AddItem(source, randitem.name, amount, emptySlot, false, 'random items command') then
                exports['mh-cashasitem']:UpdateCashItem(source, randitem, amount, 'add', true)
                TriggerClientEvent('qb-inventory:client:ItemBox', source, QBCore.Shared.Items[randitem.name], 'add', amount)
                player = QBCore.Functions.GetPlayer(source)
                playerInventory = player.PlayerData.items
                if Player(source).state.inv_busy then TriggerClientEvent('qb-inventory:client:updateInventory', source) end
            end
            Wait(1000)
        end
    end
end, 'god')
```

