--[[ ===================================================== ]] --
--[[           MH Cash As Item Script by MaDHouSe          ]] --
--[[ ===================================================== ]] --
local QBCore = exports['qb-core']:GetCoreObject()
local updateLocks = {}

local function GetItemName(item)
    local tmpItem = nil
    if type(item) == 'string' and item ~= nil then tmpItem = item:lower()
    elseif type(item) == 'table' and item.name ~= nil then tmpItem = item.name:lower()
    else tmpItem = nil end
    return tmpItem
end

local function GetTotalMoneyInInventory(items, moneyType)
    local totalAmount = 0
    for slot, item in pairs(items) do
        if GetItemName(item) == moneyType then totalAmount = totalAmount + (item.amount or 0) end
    end
    return totalAmount
end

local function SetItemData(src, moneyType)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return false end
    if not (moneyType == 'cash' or moneyType == 'black_money' or moneyType == 'crypto') then return false end
    if updateLocks[src] then return false end
    updateLocks[src] = true
    local currentMoney = Player.Functions.GetMoney(moneyType)
    if currentMoney < 0 then currentMoney = 0 end
    local items = Player.PlayerData.items
    local inventoryTotal = GetTotalMoneyInInventory(items, moneyType)
    if inventoryTotal ~= currentMoney then
        for slot, item in pairs(items) do
            if GetItemName(item) == moneyType then Player.Functions.RemoveItem(moneyType, item.amount, slot) end
        end
        if currentMoney > 0 then Player.Functions.AddItem(moneyType, currentMoney, nil, nil, 'mh-cashasitem sync') end
    end
    updateLocks[src] = nil
end

local function UpdateItem(src, moneyType)
    if updateLocks[src] then return end
    if not (moneyType == 'cash' or moneyType == 'black_money' or moneyType == 'crypto') then return end
    SetItemData(src, moneyType)
end
exports('UpdateItem', UpdateItem)

local function UpdateCash(src, item, amount, action)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local tmpItem = GetItemName(item)
    if not (tmpItem == 'cash' or tmpItem == 'black_money' or tmpItem == 'crypto') then return end
    if updateLocks[src] then return end
    updateLocks[src] = true
    local currentMoney = Player.Functions.GetMoney(tmpItem)
    if action == "add" then
        if amount > 0 then
            Player.Functions.AddMoney(tmpItem, amount, 'mh-cashasitem-update-'..tmpItem)
            SetItemData(src, tmpItem)
        end
    elseif action == "remove" then
        if amount > 0 and currentMoney >= amount then
            Player.Functions.RemoveMoney(tmpItem, amount, 'mh-cashasitem-update-'..tmpItem)
            SetItemData(src, tmpItem)
        end
    end
    updateLocks[src] = nil
end
exports('UpdateCash', UpdateCash)

RegisterNetEvent("QBCore:Server:OnMoneyChange", function(source, moneyType, amount, set, reason)
    if updateLocks[source] then return end
    if moneyType == 'bank' then UpdateItem(source, 'cash') else UpdateItem(source, moneyType) end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        if not QBCore.Config.Money.MoneyTypes['black_money'] then
            print("~r~["..GetCurrentResourceName().."] - ERROR - You forgot to add 'black_money' in the 'resources/[qb]/qb-core/config.lua' file at line 9 and 10.~w~")
        elseif QBCore.Config.Money.MoneyTypes['black_money'] then
            local query = MySQL.Sync.fetchAll("SELECT * FROM players")
            if type(query) == 'table' and #query > 0 then
                for k, v in pairs(query) do
                    local list = json.decode(v.money)
                    if not list['black_money'] then
                        list['black_money'] = 0
                        MySQL.update.await('UPDATE players SET money = ? WHERE citizenid = ?', { json.encode(list), v.citizenid })
                    end
                end
            end
        end
    end
end)

QBCore.Commands.Add('blackmoney', 'Check Blackmoney Balance', {}, false, function(source, _)
    local Player = QBCore.Functions.GetPlayer(source)
    local amount = Player.PlayerData.money.black_money
    if amount < 0 then amount = 0 end
    if GetResourceState("qb-hud") ~= 'missing' then
        TriggerClientEvent('hud:client:ShowAccounts', source, 'black_money', amount)
    elseif GetResourceState("qb-hud") == 'missing' then
        QBCore.Functions.Notify(source, { text = "MH Cash As Item", caption = 'You have '..amount..' blackmoney' }, 'primary')
    end
end)

QBCore.Commands.Add('crypto', 'Check Crypto Balance', {}, false, function(source, _)
    local Player = QBCore.Functions.GetPlayer(source)
    local amount = Player.PlayerData.money.crypto
    if amount < 0 then amount = 0 end
    if GetResourceState("qb-hud") ~= 'missing' then
        TriggerClientEvent('hud:client:ShowAccounts', source, 'crypto', amount)
    elseif GetResourceState("qb-hud") == 'missing' then
        QBCore.Functions.Notify(source, { text = "MH Cash As Item", caption = 'You have '..amount..' crypto' }, 'primary')
    end
end)