--[[ ===================================================== ]]--
--[[           MH Cash As Item Script by MaDHouSe          ]]--
--[[ ===================================================== ]]--

local QBCore = exports['qb-core']:GetCoreObject()
--
local useCashAsItem = true -- true if you want to use cash as item
local cashItem = "cash"    -- the cash item for the inventory

-- inventory itembox popup when you add or remove items.
local useItemBox = true    -- true is you want to use the itembox popup 
local useAddBox = true     -- true if you want to see the add itembox popup (only works if useItemBox = true)
local useRemoveBox = false -- true if you want to see the remove itembox popup (only works if useItemBox = true)
--
local lastUsedSlot = nil   -- dont edit this must be nil
local debug = false        -- true only for debug.

local function ItemBox(amount, action)
    TriggerClientEvent('inventory:client:ItemBox', player.PlayerData.source, QBCore.Shared.Items[cashItem:lower()], action, amount)
end

local function GetMoney(player)
    return player.Functions.GetMoney('cash')
end

local function AddMoney(player, amount)
    return player.Functions.AddMoney("cash", amount, nil)
end

local function RemoveMoney(player, amount)
    return player.Functions.RemoveMoney("cash", amount, nil)
end

local function AddItem(player, amount, slot)
    if slot ~= nil or slot ~= 0 then
        player.Functions.AddItem(cashItem:lower(), amount, slot)
    else
        player.Functions.AddItem(cashItem:lower(), amount, nil)
    end
    if useItemBox and useAddBox then ItemBox(amount, "add") end
end

local function RemoveItem(player, amount, slot)
    return player.Functions.RemoveItem(cashItem:lower(), amount, slot)
end

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
            if useItemBox and useRemoveBox then ItemBox(itemCount, "remove") end
            AddItem(player, cash, lastslot)
        elseif itemCount <= 0 and cash >= 1 then
            AddItem(player, cash, lastslot)
        end
    end
end

RegisterNetEvent('mh-cashasitem:server:updateCash', function(id, item, amount, action)
    local player = QBCore.Functions.GetPlayer(id)
    if player and useCashAsItem then 
        if item and item.name == cashItem then
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
    UpdateCashItem(src)
end)

RegisterNetEvent("QBCore:Server:OnMoneyChange", function(source, moneyType, amount, set, reason)
    local src = source
    UpdateCashItem(src)
end)

local count = 0
RegisterNetEvent('inventory:server:SetInventoryData', function(fromInventory, toInventory, fromSlot, toSlot, fromAmount, toAmount)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    fromSlot = tonumber(fromSlot)
    toSlot = tonumber(toSlot)
    if (fromInventory == "player" or fromInventory == "hotbar") and (QBCore.Shared.SplitStr(toInventory, "-")[1] == "itemshop" or toInventory == "crafting") then return end
    if debug then
        count = count + 1
        print("----------------"..count.."----------------")
        print("From Inventory "..tostring(fromInventory))
        print("To Inventory "..tostring(toInventory))
        print("From Slot "..tostring(fromSlot))
        print("To Slot "..tostring(toSlot))
        print("From Amount "..tostring(fromAmount))
        print("To Amount "..tostring(toAmount))
        print("Last Used Slot "..tostring(lastUsedSlot))
        print("------------------------------------------")
    end
end)
