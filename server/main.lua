--[[ ===================================================== ]] --
--[[           MH Cash As Item Script by MaDHouSe          ]] --
--[[ ===================================================== ]] --
local QBCore = exports['qb-core']:GetCoreObject()

--- Item Box
---@param item table
---@param player table
---@param amount number
---@param action string
local function ItemBox(item, player, amount, action)
    if Config.useItemBox and (Config.useAddBox or Config.useRemoveBox) then
        TriggerClientEvent('inventory:client:ItemBox', player.PlayerData.source, QBCore.Shared.Items[item], action, amount)
    end
end

--- Add Cash Item
---@param player table
---@param amount number
---@param slot number
local function AddItem(item, player, amount, slot)
    if slot ~= nil or slot ~= 0 then player.Functions.AddItem(item, amount, slot) else player.Functions.AddItem(item, amount, nil) end
    ItemBox(item, player, amount, "add")
end

--- Update Cash Item
---@param id number
local function UpdateCashItem(src, moneyType)
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
                ItemBox(lastItem, Player, itemCount, "remove")
                AddItem(moneyType, Player, cash, lastSlot)
            elseif itemCount <= 0 and cash >= 1 then
                AddItem(moneyType, Player, cash, lastSlot)
            end
        end
    end
end

--- RegisterNetEvent update Cash
---@param id number
---@param item table
---@param amount number
---@param action string
---@param display boolean
RegisterNetEvent('mh-cashasitem:server:updateCash', function(source, item, amount, action, display)
    local Player = QBCore.Functions.GetPlayer(source)
    if display == nil then display = true end
    if Player then
        if item and Config.CashItems[item.name] and display then
            if action == "add" then
                Player.Functions.AddMoney(item.name, amount, nil)
            elseif action == "remove" then
                Player.Functions.RemoveMoney(item.name, amount, nil)
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
    UpdateCashItem(src, 'cash')
    UpdateCashItem(src, 'blackmoney')
end)

--- RegisterNetEvent OnMoneyChange
---@param source number
---@param moneyType string
---@param amount number
---@param set string
---@param reason string
RegisterNetEvent("QBCore:Server:OnMoneyChange", function(source, moneyType, amount, set, reason)
    if moneyType ~= 'bank' then UpdateCashItem(source, moneyType) end
end)
