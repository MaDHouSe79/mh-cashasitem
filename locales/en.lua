--[[ ===================================================== ]] --
--[[           MH Cash As Item Script by MaDHouSe          ]] --
--[[ ===================================================== ]] --
local Translations = {
    notify = {
        ['no_cash'] = "You don't have enough money",
        ['item_bought'] = "%{item} bought!",
    },
    log = {
        title = "Blackmarket item bought",
        txt = "**%{player}** bought a %{item} for $%{price}"
    },
    command = {
        description = "Check Your Blackmoney Balance",
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})

