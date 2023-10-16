--[[ ===================================================== ]] --
--[[           MH Cash As Item Script by MaDHouSe          ]] --
--[[ ===================================================== ]] --
local QBCore = exports['qb-core']:GetCoreObject()
--- Inventory ItemBox Popup
---@param amount number
---@param action string
local function ItemBox(player, amount, action)
    if Config.useItemBox and (Config.useAddBox or Config.useRemoveBox) then
        TriggerClientEvent('inventory:client:ItemBox', player.PlayerData.source,
            QBCore.Shared.Items[Config.cashItem:lower()], action, amount)
    end
end

---Add Cash Item
---@param player table
---@param amount number
---@param slot number
local function AddItem(item, player, amount, slot)
    if slot ~= nil or slot ~= 0 then
        player.Functions.AddItem(item, amount, slot)
    else
        player.Functions.AddItem(item, amount, nil)
    end
    ItemBox(player, amount, "add")
end

---Remove Cash Item
---@param player table
---@param amount number
---@param slot number
local function RemoveItem(item, player, amount, slot)
    return player.Functions.RemoveItem(item, amount, slot)
end

--- Get Player Cash
---@param player table
local function GetMoney(player)
    return player.Functions.GetMoney('cash')
end

--- Add Player Cash
---@param player table
---@param amount number
local function AddMoney(player, amount)
    return player.Functions.AddMoney("cash", amount, nil)
end

--- Remove Player Cash
---@param player table
---@param amount number
local function RemoveMoney(player, amount)
    return player.Functions.RemoveMoney("cash", amount, nil)
end

---Update Cash Item
---@param id number
local function UpdateCashItem(id)
    local player = QBCore.Functions.GetPlayer(id)
    if player and Config.useCashAsItem then
        local cash = GetMoney(player)
        local itemCount = 0
        local lastslot = nil
        for _, item in pairs(player.PlayerData.items) do
            if item and item.name:lower() == 'cash' then
                itemCount = itemCount + item.amount
                lastslot = item.slot
                RemoveItem(item.name, player, item.amount, item.slot)
            end
        end
        if itemCount >= 1 and cash >= 1 then
            ItemBox(player, itemCount, "remove")
            AddItem('cash', player, cash, lastslot)
        elseif itemCount <= 0 and cash >= 1 then
            AddItem('cash', player, cash, lastslot)
        end
    end
end

--- Get Player Black Money
---@param player table
local function GetBlackMoney(player)
    return player.Functions.GetMoney('blackmoney')
end

--- Add Player Black Money
---@param player table
---@param amount number
local function AddBlackMoney(player, amount)
    return player.Functions.AddMoney("blackmoney", amount, nil)
end

--- Remove Player Black Money
---@param player table
---@param amount number
local function RemoveBlackMoney(player, amount)
    return player.Functions.RemoveMoney("blackmoney", amount, nil)
end

---Update Black Money Item
---@param id number
local function UpdateBlackMoneyItem(id)
    local player = QBCore.Functions.GetPlayer(id)
    if player and Config.useCashAsItem then
        local cash = GetBlackMoney(player)
        local itemCount = 0
        local lastslot = nil
        for _, item in pairs(player.PlayerData.items) do
            if item and item.name:lower() == 'blackmoney' then
                itemCount = itemCount + item.amount
                lastslot = item.slot
                RemoveItem(item.name, player, item.amount, item.slot)
            end
        end
        if itemCount >= 1 and cash >= 1 then
            ItemBox(player, itemCount, "remove")
            AddItem('blackmoney', player, cash, lastslot)
        elseif itemCount <= 0 and cash >= 1 then
            AddItem('blackmoney', player, cash, lastslot)
        end
    end
end

--- RegisterNetEvent update Cash
---@param id number
---@param item table
---@param amount number
---@param action string
---@param display boolean
RegisterNetEvent('mh-cashasitem:server:updateCash', function(id, item, amount, action, display)
    local player = QBCore.Functions.GetPlayer(id)
    if display == nil then
        display = true
    end
    if player and Config.useCashAsItem then
        if item and Config.CashItems[item.name] and display then
            if item.name == 'cash' then
                if action == "add" then
                    AddMoney(player, amount, nil)
                elseif action == "remove" then
                    RemoveMoney(player, amount, nil)
                end
            elseif item.name == 'blackmoney' then
                if action == "add" then
                    AddBlackMoney(player, amount, nil)
                elseif action == "remove" then
                    RemoveBlackMoney(player, amount, nil)
                end
            end
        end
    end
end)

--- RegisterNetEvent OpenInventory
---@param name string
---@param id number
---@param other table
RegisterNetEvent('inventory:server:OpenInventory', function(name, id, other)
    local src = source
    if Config.useCashAsItem then
        UpdateCashItem(src)
        UpdateBlackMoneyItem(src)
    end
end)

--- RegisterNetEvent OnMoneyChange
---@param source number
---@param moneyType string
---@param amount number
---@param set string
---@param reason string
RegisterNetEvent("QBCore:Server:OnMoneyChange", function(source, moneyType, amount, set, reason)
    local src = source
    if Config.useCashAsItem then
        if moneyType == 'cash' then
            UpdateCashItem(src)
        elseif moneyType == 'blackmoney' then
            UpdateBlackMoneyItem(src)
        end
    end
end)

QBCore.Commands.Add('blackmoney', "Check Your Blackmoney Balance", {}, false, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    local amount = Player.PlayerData.money.blackmoney
    TriggerClientEvent('hud:client:ShowAccounts', source, 'blackmoney', amount)
end)

RegisterNetEvent('mh-cashasitem:server:buyitemwithblackmoney', function(id, data)
    local src = id
    local Player = QBCore.Functions.GetPlayer(src)
    local blackmoney = exports['qb-inventory']:GetItemByName(src, "blackmoney")
    if blackmoney.amount >= data.price then
        Player.Functions.RemoveItem('blackmoney', data.price)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['blackmoney'], "remove", data.price)
        Player.Functions.AddItem(data.item, data.amount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[data.item], "add", data.amount)
        local itemInfo = QBCore.Shared.Items[data.item:lower()]
        QBCore.Functions.Notify(src, itemInfo["label"] .. " bought!", "success")
        TriggerEvent("qb-log:server:CreateLog", "shops", "Shop item bought", "green",
            "**" .. GetPlayerName(src) .. "** bought a " .. itemInfo["label"] .. " for $" .. data.price)
    else
        TriggerClientEvent('QBCore:Notify', src, "You Don't Have Enough money", 'error')
    end
end)
