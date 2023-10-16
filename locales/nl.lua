--[[ ===================================================== ]] --
--[[           MH Cash As Item Script by MaDHouSe          ]] --
--[[ ===================================================== ]] --
local Translations = {
    notify = {
        ['no_cash'] = "Je hebt niet genoeg geld bij je.",
        ['item_bought'] = "%{item} bought!",
    },
    log = {
        title = "Blackmarket item gekocht",
        txt = "**%{player}** kocht een %{item} voor $%{price}"
    },
    command = {
        description = "Bekijk je Blackmoney balance",
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
