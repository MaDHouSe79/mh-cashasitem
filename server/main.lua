--[[ ===================================================== ]] --
--[[           MH Cash As Item Script by MaDHouSe          ]] --
--[[ ===================================================== ]] --
QBCore = exports['qb-core']:GetCoreObject()

--- Get Item Name
---@param item string or table
---@return string - the current item name as string.
local function GetItemName(item)
    local tmpItem = nil
    if type(item) == 'string' then tmpItem = item:lower()
    elseif type(item) == 'table' then tmpItem = item.name:lower()
    else tmpItem = nil end
    return tmpItem
end

--- Update Cash, only to use when moving items in the inventory. (server side only)
--- Use: exports['mh-cashasitem']:UpdateCash(source, itemData, amount, action)
---@param source number id of the player
---@param item string or table for the cash item
---@param amount number for the item
---@param action string for add or remove
local function UpdateCash(source, item, amount, action)
    local Player = QBCore.Functions.GetPlayer(source)
    local tmpItem = GetItemName(item)
    if Player and tmpItem ~= nil then
        if tmpItem == 'cash' or tmpItem == 'black_money' or tmpItem == 'crypto' then
            if action == "add" then
                -- in the function `Player.Functions.Addmoney` the trigger `QBCore:Server:OnMoneyChange` gets triggered
                Player.Functions.AddMoney(tmpItem, amount, 'mh-cashasitem-update-'..tmpItem)
            elseif action == "remove" then
                -- in the function `Player.Functions.RemoveMoney` the trigger `QBCore:Server:OnMoneyChange` gets triggered
                Player.Functions.RemoveMoney(tmpItem, amount, 'mh-cashasitem-update-'..tmpItem)
            end
        end
    end
end
exports('UpdateCash', UpdateCash)

--- Update Item
--- Remove all related moneyType items and add 1 item moneyType with the total moneyType amount left.
--- NOTE do not update money here, this is only to update the item for the inventory.
---@param src number
---@param moneyType string ('cash', 'black_money', 'crypto')
local function UpdateItem(src, moneyType)
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        
        -- Remove all related moneyType items
        -- we only want to know the last slot, cause we need this to add a new item on that slot.
        local lastSlot = nil
        for _, item in pairs(Player.PlayerData.items) do
            if item and item.name:lower() == moneyType:lower() then
                lastSlot = item.slot
                Player.Functions.RemoveItem(src, item.name, item.amount, item.slot)
            end
        end
        
        -- We now have zero moneyType items and we want to add one new item moneyType with the amount of moneyType we have left.
        local amount = Player.Functions.GetMoney(moneyType)
        if amount >= 1 then Player.Functions.AddItem(src, moneyType, amount, lastSlot) end
    end
end

--- Open Inventory
--- This will trigger when the inventory gets open.
RegisterNetEvent('mh-cashasitem:server:openInventory', function()
    local src = source
    UpdateItem(src, 'cash')
    UpdateItem(src, 'black_money')
    UpdateItem(src, 'crypto')
end)

--- On Money Change
--- This will trigger when money changes happens in other scripts
--- React on `Player.Functions.Addmoney` and Player.Functions.RemoveMoney
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
