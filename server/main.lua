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
    local player = QBCore.Functions.GetPlayer(src)
    if player then
        if moneyType ~= 'bank' then
            local cash, itemCount, lastSlot, lastItem = 0, 0, nil, nil
            cash = player.Functions.GetMoney(moneyType)
            for _, item in pairs(player.PlayerData.items) do
                if item and item.name:lower() == moneyType then
                    itemCount = itemCount + item.amount
                    lastSlot = item.slot
                    lastItem = item.name
                    player.Functions.RemoveItem(item.name, item.amount, item.slot)
                end
            end
            if itemCount >= 1 and cash >= 1 then
                ItemBox(lastItem, player, itemCount, "remove")
                AddItem(moneyType, player, cash, lastSlot)
            elseif itemCount <= 0 and cash >= 1 then
                AddItem(moneyType, player, cash, lastSlot)
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
    local player = QBCore.Functions.GetPlayer(source)
    if display == nil then display = true end
    if player then
        if item and Config.CashItems[item.name] and display then
            if action == "add" then
                player.Functions.AddMoney(item.name, amount, nil)
            elseif action == "remove" then
                player.Functions.RemoveMoney(item.name, amount, nil)
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
    local src = source
    UpdateCashItem(src, moneyType)
end)
