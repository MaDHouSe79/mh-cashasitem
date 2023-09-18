--[[ ===================================================== ]]--
--[[           MH Cash As Item Script by MaDHouSe          ]]--
--[[ ===================================================== ]]--

local QBCore = exports['qb-core']:GetCoreObject()

-- Config
local useCashAsItem = true -- true if you want to use cash as item
local cashItem = "cash"    -- the cash item for the inventory
local lastUsedSlot = nil   -- last used slot number, the slot number where you put the cash last in.
local debug = false        -- true only for debug.

local function GetMoney(player)
    return player.Functions.GetMoney('cash')
end

local function AddMoney(player, amount)
    return player.Functions.AddMoney("cash", amount, nil)
end

local function RemoveMoney(player, amount)
    return player.Functions.RemoveMoney("cash", amount, nil)
end

local function AddItem(player, item, amount)
    if lastUsedSlot ~= nil then
        player.Functions.AddItem(item, amount, lastUsedSlot)
    else
        player.Functions.AddItem(item, amount, nil)
    end
    TriggerClientEvent('inventory:client:ItemBox', player.PlayerData.source, QBCore.Shared.Items[item], "add", amount)
end

local function RemoveItem(player, item, amount, slot)
    return player.Functions.RemoveItem(item, amount, slot)
end

local function UpdateCashItem(id)
    local player = QBCore.Functions.GetPlayer(id)
    if player and useCashAsItem then
        local cash = GetMoney(player)
        local itemCount = 0
        for _, item in pairs(player.PlayerData.items) do
            if item and item.name:lower() == cashItem:lower() then
                itemCount = itemCount + item.amount
                RemoveItem(player, cashItem, item.amount, item.slot)
            end
        end
        if itemCount >= 1 and cash >= 1 then
            AddItem(player, cashItem, cash)
        elseif itemCount <= 0 and cash >= 1 then
            AddItem(player, cashItem, cash)
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
    if (fromInventory == "player" or fromInventory == "hotbar") and (QBCore.Shared.SplitStr(toInventory, "-")[1] == "itemshop" or toInventory == "crafting") then
        return
    end
    if fromInventory == "player" or fromInventory == "hotbar" then
        if toInventory == "player" or toInventory == "hotbar" then
            lastUsedSlot = toSlot
        end
    else
        if toInventory == nil or toInventory == 0 then
        else
            lastUsedSlot = toSlot
        end
    end
    if debug then
        count = counr + 1
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
