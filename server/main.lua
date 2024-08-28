--[[ ===================================================== ]] --
--[[           MH Cash As Item Script by MaDHouSe          ]] --
--[[ ===================================================== ]] --
QBCore = exports['qb-core']:GetCoreObject()

--- Get Item Type
---@param item any
local function GetItemType(item)
    local tmpItem = nil
    if type(item) == 'string' then
        tmpItem = item
    elseif type(item) == 'table' then
        tmpItem = item.name
    else
        tmpItem = nil
    end
    return tmpItem
end

--- Add Item
---@param player table
---@param amount number
---@param slot number
local function AddItem(src, item, amount, slot)
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        if slot ~= nil or slot ~= 0 then Player.Functions.AddItem(item, amount, slot) else Player.Functions.AddItem(item, amount, nil) end
    end
end

local function RemoveItem(src, item, amount, slot)
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        if Player.Functions.HasItem(item, amount) then
            Player.Functions.RemoveItem(item, amount, slot)
        end
    end
end

--- Update Item
---@param src number
---@param moneyType string
local function UpdateItem(src, moneyType)
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local lastSlot = nil
        for _, item in pairs(Player.PlayerData.items) do
            if item and item.name:lower() == moneyType:lower() then
                lastSlot = item.slot
                RemoveItem(src, item.name, item.amount, item.slot)
            end
        end
        local amount = Player.Functions.GetMoney(moneyType)
        if type(amount) == 'number' and amount >= 1 then
            AddItem(src, moneyType, amount, lastSlot)
        end
    end
end

--- UpdateCashItem, only to use when moving items in the inventory.
---@param source id of the player
---@param item the cash item
---@param amount for the item
---@param action for add or remove
---@param display display hud true or false
local function UpdateCashItem(source, item, amount, action)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        local tmpItem = GetItemType(item)
        if tmpItem ~= nil and (tmpItem == 'cash' or tmpItem == 'black_money' or tmpItem == 'crypto') then
            if action == "add" then
                Player.Functions.AddMoney(tmpItem, amount, nil)
            elseif action == "remove" then
                Player.Functions.RemoveMoney(tmpItem, amount, nil)
            end
        end
        tmpItem = nil
    end
end
exports('UpdateCashItem', UpdateCashItem)

--- Open Inventory
RegisterNetEvent('mh-cashasitem:server:openInventory', function()
    local src = source
    UpdateItem(src, 'cash')
    UpdateItem(src, 'black_money')
    UpdateItem(src, 'crypto')
end)

--- On Money Change
---@param source number
---@param moneyType string
---@param amount number
---@param set string
---@param reason string
RegisterNetEvent("QBCore:Server:OnMoneyChange", function(source, moneyType, amount, set, reason)
    if moneyType ~= 'bank' then UpdateItem(source, moneyType) end
end)

--- onResourceStart
---@param resource any
AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        if not QBCore.Config.Money.MoneyTypes['black_money'] then
            print("~r~["..GetCurrentResourceName().."] - ERROR - You forgot to add 'black_money' in the 'resources/[qb]/qb-core/config.lua' file at line 9 and 10.~w~")
        elseif QBCore.Config.Money.MoneyTypes['black_money'] then
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
    end
end)

QBCore.Commands.Add('blackmoney', 'Check Blackmoney Balance', {}, false, function(source, _)
    local Player = QBCore.Functions.GetPlayer(source)
    local amount = Player.PlayerData.money.black_money
    TriggerClientEvent('hud:client:ShowAccounts', source, 'black_money', amount)
end)

QBCore.Commands.Add('crypto', 'Check Crypto Balance', {}, false, function(source, _)
    local Player = QBCore.Functions.GetPlayer(source)
    local amount = Player.PlayerData.money.crypto
    TriggerClientEvent('hud:client:ShowAccounts', source, 'crypto', amount)
end)
