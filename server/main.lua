--[[ ===================================================== ]]--
--[[           MH Cash As Item Script by MaDHouSe          ]]--
--[[ ===================================================== ]]--

local QBCore = exports['qb-core']:GetCoreObject()
local useCashAsItem = true -- true if you want to use cash as item
local cashItem = "cash"    -- the cash item for the inventory

local function UpdateCashItem(id)
    local Player = QBCore.Functions.GetPlayer(id)
    if Player and useCashAsItem then
        local cash = Player.Functions.GetMoney('cash')
        local itemCount = 0
        for _, item in pairs(Player.PlayerData.items) do
            if item and item.name:lower() == cashItem:lower() then
                itemCount = itemCount + item.amount
                Player.Functions.RemoveItem(cashItem, item.amount, item.slot)
            end
        end
        if itemCount >= 1 and cash >= 1 then
            Player.Functions.AddItem(cashItem, cash, nil)
            TriggerClientEvent('inventory:client:ItemBox', id, QBCore.Shared.Items[cashItem], "add", cash)
        else
            if itemCount <= 0 and cash >= 1 then
                Player.Functions.AddItem(cashItem, cash, nil)
                TriggerClientEvent('inventory:client:ItemBox', id, QBCore.Shared.Items[cashItem], "add", cash)
            end
        end
    end
end

RegisterNetEvent('inventory:server:OpenInventory', function(name, id, other)
    local src = source
    UpdateCashItem(src)
end)

RegisterNetEvent("QBCore:Server:OnMoneyChange", function(source, moneyType, amount, set, reason)
    local src = source
    UpdateCashItem(src)
end)

RegisterNetEvent('mh-cashasitem:server:updateCash', function(id, item, amount, action)
    local Player = QBCore.Functions.GetPlayer(id)
    if Player and useCashAsItem then 
        local cash = Player.Functions.GetMoney('cash')
        if item and item.name == cashItem then
            if action == "add" then
		Player.Functions.AddMoney(cashItem, amount, nil)
	    elseif action == "remove" then
		Player.Functions.RemoveMoney(cashItem, amount, nil)
	    end
	end
    end
end)
