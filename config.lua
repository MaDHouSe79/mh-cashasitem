--[[ ===================================================== ]] --
--[[           MH Cash As Item Script by MaDHouSe          ]] --
--[[ ===================================================== ]] --
Config = {}

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
-- this will be removed later
Config.UpdateTrigger = "mh-cashasitem:server:updateCash"
