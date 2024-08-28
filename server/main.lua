--[[ ===================================================== ]] --
--[[           MH Cash As Item Script by MaDHouSe          ]] --
--[[ ===================================================== ]] --
QBCore = exports['qb-core']:GetCoreObject()

--- Get Item Type
---@param item string or table
local function GetItemType(item)
    local tmpItem = nil
    if type(item) == 'string' then tmpItem = item:lower()
    elseif type(item) == 'table' then tmpItem = item.name:lower()
    else tmpItem = nil end
    return tmpItem
end

--- Update Cash Item, only to use when moving items in the inventory.
--- Use: exports['mh-cashasitem']:UpdateCashItem(source, itemData, amount, action)
---@param source id of the player
---@param item the cash item
---@param amount for the item
---@param action for add or remove
local function UpdateCashItem(source, item, amount, action)
    local Player = QBCore.Functions.GetPlayer(source)
    local tmpItem = GetItemType(item)
    if Player and tmpItem ~= nil then
        if tmpItem == 'cash' or tmpItem == 'black_money' or tmpItem == 'crypto' then
            if action == "add" then
                Player.Functions.AddMoney(tmpItem, amount, 'mh-cashasitem-update-'..tmpItem)
            elseif action == "remove" then
                Player.Functions.RemoveMoney(tmpItem, amount, 'mh-cashasitem-update-'..tmpItem)
            end
        end
    end
end
exports('UpdateCashItem', UpdateCashItem)

--- Update Item
--- Remove all related moneyType items and add 1 item moneyType with the total cash amount left.
---@param src number
---@param moneyType string
local function UpdateItem(src, moneyType)
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local lastSlot, itemAmount = nil, 0
        -- Remove all related moneyType items
        for _, item in pairs(Player.PlayerData.items) do
            if item and item.name:lower() == moneyType:lower() then
                itemAmount = itemAmount + item.amount
                lastSlot = item.slot
                Player.Functions.RemoveItem(src, item.name, item.amount, item.slot)
            end
        end
        -- we now have zero items and we want to add one item with the amount of moneyType we have left.
        local amount = Player.Functions.GetMoney(moneyType)
        if amount >= 1 then Player.Functions.AddItem(src, moneyType, amount, lastSlot) end
    end
end

--- Open Inventory
--- This wil trigger when the inventory gets open.
RegisterNetEvent('mh-cashasitem:server:openInventory', function()
    local src = source
    UpdateItem(src, 'cash')
    UpdateItem(src, 'black_money')
    UpdateItem(src, 'crypto')
end)

--- On Money Change
--- This wil trigger when money changes happens
---@param source number
---@param moneyType string
---@param amount number
---@param set string
---@param reason string
RegisterNetEvent("QBCore:Server:OnMoneyChange", function(source, moneyType, amount, set, reason)
    UpdateItem(source, moneyType)
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
