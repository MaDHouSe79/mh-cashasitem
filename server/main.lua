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

--- Only to use when move/add/remove items in the inventory. (server side only)
--- Use: exports['mh-cashasitem']:UpdateCash(source, itemData, amount, action)
---@param source number id of the player
---@param item string or table for the cash item
---@param amount number for the item
---@param action string `add` or `remove`
local function UpdateCash(source, item, amount, action)
    local Player = QBCore.Functions.GetPlayer(source)
    -- get item name as sting
    local tmpItem = GetItemName(item)
    if Player and tmpItem ~= nil then
        -- if tmpItem is a cash item
        if tmpItem == 'cash' or tmpItem == 'black_money' or tmpItem == 'crypto' then
            if action == "add" then
                -- In the function `Player.Functions.Addmoney` the trigger `QBCore:Server:OnMoneyChange` gets triggered
                Player.Functions.AddMoney(tmpItem, amount, 'mh-cashasitem-update-'..tmpItem)
            elseif action == "remove" then
                -- In the function `Player.Functions.RemoveMoney` the trigger `QBCore:Server:OnMoneyChange` gets triggered
                Player.Functions.RemoveMoney(tmpItem, amount, 'mh-cashasitem-update-'..tmpItem)
            end
        end
    end
end
exports('UpdateCash', UpdateCash)

--- Remove all related moneyType items and add 1 item moneyType with the total moneyType amount left.
--- This function gets automaticly triggered,
--- when money changes happens `QBCore:Server:OnMoneyChange`
--- or when open the inventory `qb-inventory:client:openInventory`
--- NOTE do not update money here, this is only to update the item for the inventory.
---@param src number
---@param moneyType string ('cash', 'black_money', 'crypto')
local function UpdateItem(src, moneyType)
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        
        -- Remove all related moneyType items, we only want to know the last used item.slot, cause we need this to add a new item on that slot.
        local lastSlot = nil
        for _, item in pairs(Player.PlayerData.items) do
            if item and item.name:lower() == moneyType:lower() then
                lastSlot = item.slot
                Player.Functions.RemoveItem(item.name, item.amount, item.slot)
            end
        end
        
        -- We now have zero moneyType items and we want to add one item moneyType with the amount of moneyType we have left.
        local amount = Player.Functions.GetMoney(moneyType)
        if amount >= 1 then Player.Functions.AddItem(moneyType, amount, lastSlot) end
    end
end

--- Open Inventory
--- This will trigger when the inventory gets open.
RegisterNetEvent('qb-inventory:server:openInventory', function(source)
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
    if moneyType ~= 'bank' then UpdateItem(source, moneyType) end
end)

--- This execute every server start of script load.
--- it does nothing if all data is already set.
---@param resource any
AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        if not QBCore.Config.Money.MoneyTypes['black_money'] then -- check if qb-core does not have a black_money currency
            print("~r~["..GetCurrentResourceName().."] - ERROR - You forgot to add 'black_money' in the 'resources/[qb]/qb-core/config.lua' file at line 9 and 10.~w~")
        elseif QBCore.Config.Money.MoneyTypes['black_money'] then -- check if qb-core have a black_money currency
            -- check if player has a black_money currency
            MySQL.Async.fetchAll("SELECT * FROM players", function(rs)
                for k, v in pairs(rs) do
                    local list = json.decode(v.money)
                    -- if black_money is not found
                    if not list['black_money'] then
                        -- add black_money to player currency
                        list['black_money'] = 0
                        -- update player currency
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
    if GetResourceState("es_extended") ~= 'missing' then
        TriggerClientEvent('hud:client:ShowAccounts', source, 'crypto', amount)
    elseif GetResourceState("qb-hud") == 'missing' then
        QBCore.Functions.Notify(source, 'You have '..amount..' crypto', 'primary')
    end
end)
