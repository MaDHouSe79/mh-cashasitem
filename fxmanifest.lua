--[[ ===================================================== ]] --
--[[           MH Cash As Item Script by MaDHouSe          ]] --
--[[ ===================================================== ]] --
fx_version 'cerulean'
game 'gta5'
author 'MaDHouSe79'
description 'MH CashAsItem - use cash black_money and crypto as item.'
version '1.0'
server_only 'yes'
server_scripts {'@oxmysql/lib/MySQL.lua', 'server/main.lua', 'server/commands.lua', 'server/update.lua'}
dependencies {'qb-core', 'qb-inventory'} -- use this only if you use qb-inventory.
--dependencies {'qb-core', 'ps-inventory'} -- use this only if you use ps-inventory.
lua54 'yes'
