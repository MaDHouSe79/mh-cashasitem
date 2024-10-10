--[[ ===================================================== ]] --
--[[           MH Cash As Item Script by MaDHouSe          ]] --
--[[ ===================================================== ]] --
local QBCore = exports['qb-core']:GetCoreObject()
local inventory = 'qb-inventory'

local function GetItemName(item)
    local tmpItem = nil
    if type(item) == 'string' then tmpItem = item:lower()
    elseif type(item) == 'table' then tmpItem = item.name:lower()
    else tmpItem = nil end
    return tmpItem
end

local function UpdateItem(src, moneyType)
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        if moneyType == 'cash' or moneyType == 'black_money' or moneyType == 'crypto' then
            local current = Player.Functions.GetMoney(moneyType)
            local lastSlot = nil
            for _, item in pairs(Player.PlayerData.items) do
                if item and item.name == moneyType then
                    lastSlot = item.slot
                    Player.Functions.RemoveItem(item.name, item.amount, item.slot)
                end
            end
            if current >= 1 then Player.Functions.AddItem(moneyType, current, nil, nil, nil) end
        end
    end
end
exports('UpdateItem', UpdateItem)

local function UpdateCash(source, item, amount, action)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        local tmpItem = GetItemName(item)
        if tmpItem ~= nil and tmpItem == 'cash' or tmpItem == 'black_money' or tmpItem == 'crypto' then
            if action == "add" then
                Player.Functions.AddMoney(tmpItem, amount, 'mh-cashasitem-update-'..tmpItem)
            elseif action == "remove" then
                Player.Functions.RemoveMoney(tmpItem, amount, 'mh-cashasitem-update-'..tmpItem)
            end
        end
    end
end
exports('UpdateCash', UpdateCash)

RegisterNetEvent("QBCore:Server:OnMoneyChange", function(source, moneyType, amount, set, reason)
    if moneyType == 'bank' then UpdateItem(source, 'cash') else UpdateItem(source, moneyType) end
end)

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
    if amount < 0 then amount = 0 end
    if GetResourceState("qb-hud") ~= 'missing' then
        TriggerClientEvent('hud:client:ShowAccounts', source, 'black_money', amount)
    elseif GetResourceState("qb-hud") == 'missing' then
        QBCore.Functions.Notify(source, 'You have '..amount..' blackmoney', 'primary')
    end
end)

QBCore.Commands.Add('crypto', 'Check Crypto Balance', {}, false, function(source, _)
    local Player = QBCore.Functions.GetPlayer(source)
    local amount = Player.PlayerData.money.crypto
    if amount < 0 then amount = 0 end
    if GetResourceState("qb-hud") ~= 'missing' then
        TriggerClientEvent('hud:client:ShowAccounts', source, 'crypto', amount)
    elseif GetResourceState("qb-hud") == 'missing' then
        QBCore.Functions.Notify(source, 'You have '..amount..' crypto', 'primary')
    end
end)
