--[[ ===================================================== ]]--
--[[           MH Cash As Item Script by MaDHouSe          ]]--
--[[ ===================================================== ]]--

local QBCore = exports['qb-core']:GetCoreObject()

--- Inventory ItemBox Popup
---@param amount int
---@param action string
local function ItemBox(player, amount, action)
    if Config.useItemBox and (Config.useAddBox or Config.useRemoveBox) then
        TriggerClientEvent('inventory:client:ItemBox', player.PlayerData.source, MHCore.QBCore.Shared.Items[Config.cashItem:lower()], action, amount)
    end
end

--- Get Player Cash
---@param player object
local function GetMoney(player)
    return player.Functions.GetMoney('cash')
end

--- Add Player Cash
---@param player object
---@param amount int
local function AddMoney(player, amount)
    return player.Functions.AddMoney("cash", amount, nil)
end

--- Remove Player Cash
---@param player object
---@param amount int
local function RemoveMoney(player, amount)
    return player.Functions.RemoveMoney("cash", amount, nil)
end

---Add Cash Item
---@param player object
---@param amount int
---@param slot int
local function AddItem(player, amount, slot)
    if slot ~= nil or slot ~= 0 then
        player.Functions.AddItem(Config.cashItem:lower(), amount, slot)
    else
        player.Functions.AddItem(Config.cashItem:lower(), amount, nil)
    end
    ItemBox(player, amount, "add")
end

---Remove Cash Item
---@param player object
---@param amount int
---@param slot int
local function RemoveItem(player, amount, slot)
    return player.Functions.RemoveItem(Config.cashItem:lower(), amount, slot)
end

---Update Cash Item
---@param id int
local function UpdateCashItem(id)
    local player = QBCore.Functions.GetPlayer(id)
    if player and Config.useCashAsItem then
        local cash = GetMoney(player)
        local itemCount = 0
        local lastslot = nil
        for _, item in pairs(player.PlayerData.items) do
            if item and item.name:lower() == Config.cashItem:lower() then
                itemCount = itemCount + item.amount
                lastslot = item.slot
                RemoveItem(player, item.amount, item.slot)
            end
        end
        if itemCount >= 1 and cash >= 1 then
            ItemBox(player, itemCount, "remove")
            AddItem(player, cash, lastslot)
        elseif itemCount <= 0 and cash >= 1 then
            AddItem(player, cash, lastslot)
        end
    end
end

RegisterNetEvent('mh-cashasitem:server:updateCash', function(id, item, amount, action, display)
    local player = QBCore.Functions.GetPlayer(id)
    if display == nil then display = true end
    if player and Config.useCashAsItem then
        if item and item.name == Config.cashItem and display then
            if action == "add" then
                AddMoney(player, amount, nil)
            elseif action == "remove" then
                RemoveMoney(player, amount, nil)
            end
        end
    end
end)

RegisterNetEvent('inventory:server:OpenInventory', function(name, id, other)
    local src = source
    if Config.useCashAsItem then UpdateCashItem(src) end
end)

RegisterNetEvent("QBCore:Server:OnMoneyChange", function(source, moneyType, amount, set, reason)
    local src = source
    if Config.useCashAsItem then UpdateCashItem(src) end
end)
