--[[ ===================================================== ]] --
--[[           MH Cash As Item Script by MaDHouSe          ]] --
--[[ ===================================================== ]] --
local QBCore = exports['qb-core']:GetCoreObject()
--- Inventory ItemBox Popup
---@param player table
---@param amount number
---@param action string
local function ItemBox(player, item, amount, action)
    if Config.useItemBox and (Config.useAddBox or Config.useRemoveBox) then
        TriggerClientEvent('inventory:client:ItemBox', player.PlayerData.source, QBCore.Shared.Items[item], action, amount)
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
    ItemBox(player, item, amount, "add")
end

---Remove Cash Item
---@param player table
---@param amount number
---@param slot number
local function RemoveItem(item, player, amount, slot)
    return player.Functions.RemoveItem(item, amount, slot)
end

--- Get Cash
---@param player table
local function GetMoney(player)
    return player.Functions.GetMoney('cash')
end

--- Add Cash
---@param player table
---@param amount number
local function AddMoney(player, amount)
    return player.Functions.AddMoney("cash", amount, nil)
end

--- Remove Cash
---@param player table
---@param amount number
local function RemoveMoney(player, amount)
    return player.Functions.RemoveMoney("cash", amount, nil)
end

---Update Cash Item
---@param id number
local function UpdateCashItem(id)
    local player = QBCore.Functions.GetPlayer(id)
    if player then
        local cash = GetMoney(player)
        local itemCount, lastSlot, lastItem = 0, nil, nil
        for _, item in pairs(player.PlayerData.items) do
            if item and item.name:lower() == 'cash' then
                itemCount = itemCount + item.amount
                lastSlot = item.slot
                lastItem = item.name
                RemoveItem(item.name, player, item.amount, item.slot)
            end
        end
        if itemCount >= 1 and cash >= 1 then
            ItemBox(player, lastItem, itemCount, "remove")
            AddItem('cash', player, cash, lastSlot)
        elseif itemCount <= 0 and cash >= 1 then
            AddItem('cash', player, cash, lastSlot)
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
    if player then
        local cash = GetBlackMoney(player)
        local itemCount, lastSlot, lastItem = 0, nil, nil
        for _, item in pairs(player.PlayerData.items) do
            if item and item.name:lower() == 'blackmoney' then
                itemCount = itemCount + item.amount
                lastSlot = item.slot
                lastItem = item.name
                RemoveItem(item.name, player, item.amount, item.slot)
            end
        end
        if itemCount >= 1 and cash >= 1 then
            ItemBox(player, itemCount, "remove")
            AddItem('blackmoney', player, cash, lastSlot)
        elseif itemCount <= 0 and cash >= 1 then
            AddItem('blackmoney', player, cash, lastSlot)
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
    if player then
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
    UpdateCashItem(src)
    UpdateBlackMoneyItem(src)
end)

--- RegisterNetEvent OnMoneyChange
---@param source number
---@param moneyType string
---@param amount number
---@param set string
---@param reason string
RegisterNetEvent("QBCore:Server:OnMoneyChange", function(source, moneyType, amount, set, reason)
    local src = source
    if moneyType == 'cash' then
        UpdateCashItem(src)
    elseif moneyType == 'blackmoney' then
        UpdateBlackMoneyItem(src)
    end
end)

local error = false
AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        if not QBCore.Config.Money.MoneyTypes.blackmoney then
            error = true
        end
    end
end)

CreateThread(function()
    while true do
        local sleep = 1000
        if error then
            sleep = 1
            print("~r~[mh-cashasitem] - ERROR - You forgot to add blackmoney in the qbcore config file.~w~")
        end
        Wait(sleep)
    end
end)
