--[[ ===================================================== ]]--
--[[           MH Cash As Item Script by MaDHouSe          ]]--
--[[ ===================================================== ]]--

local QBCore = exports['qb-core']:GetCoreObject()
local debug = false        -- true only for debug.
--
local useCashAsItem = true -- true if you want to use cash as item
local cashItem = "cash"    -- the cash item for the inventory

-- inventory itembox popup when you add or remove items.
local useItemBox = false   -- true if you want to use the itembox popup 
local useAddBox = false    -- true if you want to see the add itembox popup (only works if useItemBox = true)
local useRemoveBox = false -- true if you want to see the remove itembox popup (only works if useItemBox = true)
--

--- Inventory ItemBox Popup
---@param amount int
---@param action string
local function ItemBox(player, amount, action)
    if useItemBox and (useAddBox or useRemoveBox) then
        TriggerClientEvent('inventory:client:ItemBox', player.PlayerData.source, QBCore.Shared.Items[cashItem:lower()], action, amount)
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
        player.Functions.AddItem(cashItem:lower(), amount, slot)
    else
        player.Functions.AddItem(cashItem:lower(), amount, nil)
    end
    ItemBox(player, amount, "add")
end

---Remove Cash Item
---@param player object
---@param amount int
---@param slot int
local function RemoveItem(player, amount, slot)
    return player.Functions.RemoveItem(cashItem:lower(), amount, slot)
end

---Update Cash Item
---@param id int
local function UpdateCashItem(id)
    local player = QBCore.Functions.GetPlayer(id)
    if player and useCashAsItem then
        local cash = GetMoney(player)
        local itemCount = 0
        local lastslot = nil
        for _, item in pairs(player.PlayerData.items) do
            if item and item.name:lower() == cashItem:lower() then
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
    if player and useCashAsItem then
        if item and item.name == cashItem and display then
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
    if useCashAsItem then
        UpdateCashItem(src)
    end
end)

RegisterNetEvent("QBCore:Server:OnMoneyChange", function(source, moneyType, amount, set, reason)
    local src = source
    if useCashAsItem then
        UpdateCashItem(src)
    end
end)
