--[[ ===================================================== ]] --
--[[           MH Cash As Item Script by MaDHouSe          ]] --
--[[ ===================================================== ]] --
Config = {}

-- inventory itembox popup when you add or remove items.
Config.useItemBox = false -- true if you want to use the itembox popup 
Config.useAddBox = false -- true if you want to see the add itembox popup (only works if useItemBox = true)
Config.useRemoveBox = false -- true if you want to see the remove itembox popup (only works if useItemBox = true)

Config.CashItem = 'cash'
Config.BlackmoneyItem = 'black_money'
Config.CryptoItem = "crypto"

Config.CashItems = {
    [Config.CashItem] = true,
    [Config.BlackmoneyItem] = true,
    [Config.CryptoItem] = true,
}


-- You can change this trigger for more protection.
-- if you change this don't forget to change the `CashAsItemUpdateTrigger` in qb-inventory server.lua
-- create an unknow trigger for this.
Config.UpdateTrigger = "mh-cashasitem:server:updateCash"
