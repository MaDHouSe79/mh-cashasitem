--[[ ===================================================== ]] --
--[[           MH Cash As Item Script by MaDHouSe          ]] --
--[[ ===================================================== ]] --
local QBCore = exports['qb-core']:GetCoreObject()

--- Add Item
---@param player table
---@param amount number
---@param slot number
local function AddItem(item, player, amount, slot)
    if slot ~= nil or slot ~= 0 then player.Functions.AddItem(item, amount, slot) else player.Functions.AddItem(item, amount, nil) end
end

--- Update Item
---@param src number
---@param moneyType string
local function UpdateItem(src, moneyType)
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local cash = Player.Functions.GetMoney(moneyType)
        local itemCount, lastSlot, lastItem = 0, nil, nil
        for _, item in pairs(Player.PlayerData.items) do
            if item and item.name:lower() == moneyType then
                itemCount = itemCount + item.amount
                lastSlot = item.slot
                lastItem = item.name
                Player.Functions.RemoveItem(item.name, item.amount, item.slot)
            end
        end
        if type(itemCount) == 'number' and type(cash) == 'number' then
            if itemCount >= 1 and cash >= 1 then
                AddItem(moneyType, Player, cash, lastSlot)
            elseif itemCount <= 0 and cash >= 1 then
                AddItem(moneyType, Player, cash, lastSlot)
            end
        end
    end
end

local function UpdateDatabaseMoney()
    MySQL.Async.fetchAll("SELECT * FROM players", function(rs)
        for k, v in pairs(rs) do
            local list = json.decode(v.money)
            if not list['black_money'] then 
                list['black_money'] = 0
                MySQL.update.await('UPDATE players SET money = ? WHERE citizenid = ?', { json.encode(list), v.citizenid })
            end  
        end
    end)
end

-- exports['mh-cashasitem']:UpdateCashItem(source, item, amount, action, display)
--- UpdateCashItem
---@param source id of the player
---@param item the cash item
---@param amount for the item
---@param action for add or remove
---@param display display hud true or false
local function UpdateCashItem(source, item, amount, action, display)
    local Player = QBCore.Functions.GetPlayer(source)
    if display == nil then display = true end
    if Player then
        local tmpItem = nil
        if type(item) == 'string' then
            tmpItem = item
        elseif type(item) == 'table' then
            tmpItem = item.name
        end
        if tmpItem ~= nil and Config.CashItems[tmpItem] and display then
            if action == "add" then
                Player.Functions.AddMoney(tmpItem, amount, nil)
            elseif action == "remove" then
                Player.Functions.RemoveMoney(tmpItem, amount, nil)
            end
        end
    end
end
exports('UpdateCashItem', UpdateCashItem)

--- OpenInventory
---@param name string
---@param id number
---@param other table
RegisterNetEvent('inventory:server:OpenInventory', function(name, id, other)
    local src = source
    UpdateItem(src, Config.CashItem)
    UpdateItem(src, Config.BlackmoneyItem)
    UpdateItem(src, Config.CryptoItem)
end)

--- OnMoneyChange
---@param source number
---@param moneyType string
---@param amount number
---@param set string
---@param reason string
RegisterNetEvent("QBCore:Server:OnMoneyChange", function(source, moneyType, amount, set, reason)
    if moneyType ~= 'bank' then UpdateItem(source, moneyType) end
end)

local error = false
AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        UpdateDatabaseMoney()
        if not QBCore.Config.Money.MoneyTypes[Config.BlackmoneyItem] then
            error = true
        end
    end
end)

CreateThread(function()
    while true do
        local sleep = 1000
        if error then
            sleep = 50
            print("~r~[mh-cashasitem] - ERROR - You forgot to add "..Config.BlackmoneyItem.." in the qbcore config file.~w~")
        end
        Wait(sleep)
    end
end)
