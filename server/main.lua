--[[ ===================================================== ]] --
--[[           MH Cash As Item Script by MaDHouSe          ]] --
--[[ ===================================================== ]] --
local QBCore = exports['qb-core']:GetCoreObject()

---@param item string or table
---@return string as the current item name as lowercase string format.
local function GetItemName(item)
    local tmpItem = nil
    if type(item) == 'string' then tmpItem = item:lower()
    elseif type(item) == 'table' then tmpItem = item.name:lower()
    else tmpItem = nil end
    return tmpItem
end

--- Set Item Data
---@param source any
---@param itemName string
---@param key string
---@param val any
local function SetItemData(source, itemName, key, val)
    if not itemName or not key then return false end
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local item = exports['qb-inventory']:GetItemByName(source, itemName)
    if not item then return false end
    item[key] = val
    Player.PlayerData.items[item.slot] = item
    Player.Functions.SetPlayerData('items', Player.PlayerData.items)
end

---@param src number
---@param moneyType string 'cash', 'black_money', 'crypto'
local function UpdateItem(src, moneyType)
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local amount = Player.Functions.GetMoney(moneyType)
        if amount > 0 then SetItemData(src, moneyType, 'amount', amount) end
    end
end
exports('UpdateItem', UpdateItem)

--- Only use when move/add/remove items in the inventory. (server side only)
---@param source number id of the player
---@param item string or table for the cash item
---@param amount number for the item
---@param action string `add` or `remove`
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

--- This will trigger when money changes happens in other scripts
--- React on `Player.Functions.Addmoney` and Player.Functions.RemoveMoney
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
