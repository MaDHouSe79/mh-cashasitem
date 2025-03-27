--[[ ===================================================== ]] --
--[[           MH Cash As Item Script by MaDHouSe          ]] --
--[[ ===================================================== ]] --
local QBCore = exports['qb-core']:GetCoreObject()

local function GetItemName(item)
    local tmpItem = nil
    if type(item) == 'string' and item ~= nil then tmpItem = item:lower()
    elseif type(item) == 'table' and item.name ~= nil then tmpItem = item.name:lower()
    else tmpItem = nil end
    return tmpItem
end

local function UpdateItem(src, moneyType)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if moneyType ~= nil and (moneyType == 'cash' or moneyType == 'black_money' or moneyType == 'crypto') then
        local found = false
        local lastSlot = nil
        local current = Player.Functions.GetMoney(moneyType)
        local items = exports['qb-inventory']:GetItemsByName(src, moneyType) or {}
        if type(items) == 'table' and #items > 0 then
            for _, item in pairs(items) do
                if item ~= nil and item.name:lower() == moneyType:lower() then
                    found = true
                    lastSlot = item.slot
                    Player.Functions.RemoveItem(moneyType, item.amount, item.slot)
                end
            end
            if found and current > 0 then
                Player.Functions.AddItem(moneyType, current, lastSlot, false)
            end
        end
        if not found and current > 0 then
            Player.Functions.AddItem(moneyType, current, lastSlot, false)
        end
    end
end
exports('UpdateItem', UpdateItem)

local function UpdateCash(src, item, amount, action)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local tmpItem = GetItemName(item)
    if tmpItem ~= nil then
        local current = Player.Functions.GetMoney(tmpItem)
        if action == "add" and amount > 0 then
            Player.Functions.AddMoney(tmpItem, amount, 'mh-cashasitem-update-'..tmpItem)
        elseif action == "remove" and current >= amount then
            Player.Functions.RemoveMoney(tmpItem, amount, 'mh-cashasitem-update-'..tmpItem)
        end
    end
end
exports('UpdateCash', UpdateCash)

RegisterNetEvent("QBCore:Server:OnMoneyChange", function(playerId, moneyType, amount, set, reason)
    if moneyType == 'bank' then UpdateItem(playerId, 'cash') else UpdateItem(playerId, moneyType) end
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
