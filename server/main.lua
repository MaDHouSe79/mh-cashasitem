--[[ ===================================================== ]] --
--[[           MH Cash As Item Script by MaDHouSe          ]] --
--[[ ===================================================== ]] --
local QBCore = exports['qb-core']:GetCoreObject()

---Add Cash Item
---@param player table
---@param amount number
---@param slot number
local function AddItem(item, player, amount, slot)
    if slot ~= nil or slot ~= 0 then player.Functions.AddItem(item, amount, slot) else player.Functions.AddItem(item, amount, nil) end
    if Config.useItemBox and (Config.useAddBox or Config.useRemoveBox) then
        TriggerClientEvent('inventory:client:ItemBox', player.PlayerData.source, QBCore.Shared.Items[item], "add", amount)
    end
end

---Update Cash Item
---@param id number
local function UpdateCashItem(id, type)
    local player = QBCore.Functions.GetPlayer(id)
    if player then
        local cash = player.Functions.GetMoney(type)
        local itemCount, lastSlot, lastItem = 0, nil, nil
        for _, item in pairs(player.PlayerData.items) do
            if item and item.name:lower() == type then
                itemCount = itemCount + item.amount
                lastSlot = item.slot
                lastItem = item.name
                player.Functions.RemoveItem(item.name, item.amount, item.slot)
            end
        end
        if itemCount >= 1 and cash >= 1 then
            if Config.useItemBox and (Config.useAddBox or Config.useRemoveBox) then
                TriggerClientEvent('inventory:client:ItemBox', player.PlayerData.source, QBCore.Shared.Items[lastItem], "remove", itemCount)
            end
            AddItem(type, player, cash, lastSlot)
        elseif itemCount <= 0 and cash >= 1 then
            AddItem(type, player, cash, lastSlot)
        end
    end
end

--- RegisterNetEvent update Cash
---@param id number
---@param item table
---@param amount number
---@param action string
---@param display boolean
RegisterNetEvent('mh-cashasitem:server:updateCash', function(id, item, amount, action, display)
    local player = QBCore.Functions.GetPlayer(id)
    if display == nil then display = true end
    if player then
        if item and Config.CashItems[item.name] and display then
            if item.name == 'cash' then
                if action == "add" then
                    player.Functions.AddMoney('cash', amount, nil)
                elseif action == "remove" then
                    player.Functions.RemoveMoney('cash', amount, nil)
                end
            elseif item.name == 'blackmoney' then
                if action == "add" then
                    player.Functions.AddMoney('blackmoney', amount, nil)
                elseif action == "remove" then
                    player.Functions.RemoveMoney('blackmoney', amount, nil)
                end
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
