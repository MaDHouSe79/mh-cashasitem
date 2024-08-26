<p align="center">
    <img width="140" src="https://icons.iconarchive.com/icons/iconarchive/red-orb-alphabet/128/Letter-M-icon.png" />  
    <h1 align="center">Hi 👋, I'm MaDHouSe</h1>
    <h3 align="center">A passionate allround developer </h3>    
</p>

<p align="center">
    <a href="https://github.com/MaDHouSe79/mh-cashasitem/issues">
        <img src="https://img.shields.io/github/issues/MaDHouSe79/mh-cashasitem"/> 
    </a>
    <a href="https://github.com/MaDHouSe79/mh-cashasitem/watchers">
        <img src="https://img.shields.io/github/watchers/MaDHouSe79/mh-cashasitem"/> 
    </a> 
    <a href="https://github.com/MaDHouSe79/mh-cashasitem/network/members">
        <img src="https://img.shields.io/github/forks/MaDHouSe79/mh-cashasitem"/> 
    </a>  
    <a href="https://github.com/MaDHouSe79/mh-cashasitem/stargazers">
        <img src="https://img.shields.io/github/stars/MaDHouSe79/mh-cashasitem?color=white"/> 
    </a>
    <a href="https://github.com/MaDHouSe79/mh-cashasitem/blob/main/LICENSE">
        <img src="https://img.shields.io/github/license/MaDHouSe79/mh-cashasitem?color=black"/> 
    </a>      
</p>

# My Youtube Channel and Discord
- [Subscribe](https://www.youtube.com/c/@MaDHouSe79) 
- [Discord](https://discord.gg/vJ9EukCmJQ)

# mh-cashasitem
- Before you start, `BACKUP` your `resources` folder cause when something is wrong you have a backup.
- This is the best cash/blackmoney/crypto item script for your qbcore server.

# NOTE you need coding experience.
- This is not just a plug and play script, you need some coding experience to install this script.

# Dependencies
- [qb-core](https://github.com/qbcore-framework/qb-core)
- [qb-inventory](https://github.com/qbcore-framework/qb-inventory)

# Optional
- [qb-hud](https://github.com/qbcore-framework/qb-hud)
- [mh-blackmarket](https://github.com/MaDHouSe79/mh-blackmarket)
- [mh-moneywash](https://github.com/MaDHouSe79/mh-moneywash)

# Install
- Add in your server.cfg `ensure mh-cashasitem`, make sure this is above `ensure [qb]`
- Make sure you read the readme files for install, and only when you are done you can restart the server.

# Server.cfg example
```conf
ensure qb-core
ensure mh-cashasitem -- add here
ensure [qb]
ensure [standalone]
ensure [voice]
ensure [defaultmaps]
ensure [mh]
```

# Command
- `/cash` to see the amount
- `/bank` to see the amount
- `/blackmoney` to see the amount
- `/crypto` to see the amount

# Video
[Youtube](https://www.youtube.com/watch?v=sWYkV-PeqU4)

![alttext](https://github.com/MaDHouSe79/mh-cashasitem/blob/main/image/cash.png?raw=true)
![alttext](https://github.com/MaDHouSe79/mh-cashasitem/blob/main/image/black_money.png?raw=true)
![alttext](https://github.com/MaDHouSe79/mh-cashasitem/blob/main/image/crypto.png?raw=true)

# Note for using blackmoney
- first you need to edit the qb-core/config.lua to this below
- add black_money to this tables
```lua
QBConfig.Money.MoneyTypes = { cash = 500, bank = 5000, crypto = 0, black_money = 0 } -- type = startamount - Add or remove money types for your server (for ex. blackmoney = 0), remember once added it will not be removed from the database!
QBConfig.Money.DontAllowMinus = { 'cash', 'crypto', 'black_money' } -- Money that is not allowed going in minus
```

# Exports you can use for your own inventory.
- use this server side only when you add or delete an item from and to a inventory.
- use this for item movment in the inventory
```lua
-- true at the end of the export is to display money change at the right top of your screen
-- if false you don't see a change but it will change the money amount.
exports['mh-cashasitem']:UpdateCashItem(targetId, itemData, amount, 'add', true)

-- true at the end of the export is to display money change at the right top of your screen
-- if false you don't see a change but it will change the money amount.
exports['mh-cashasitem']:UpdateCashItem(targetId, itemData, amount, 'remove', true)
```

# Example
```lua
-- Add Item
Player.Functions.AddItem(playerId, itemInfo["name"], toAmount, fromSlot, toItemData.info)
exports['mh-cashasitem']:UpdateCashItem(playerId, toItemData, toAmount, "add")

-- Remove Item
Player.Functions.RemoveItem(src, toItemData.name, toAmount, toSlot)
exports['mh-cashasitem']:UpdateCashItem(src, toItemData, toAmount, "remove")
```


# Add in `[qb]/qb-core/shared/items.lua` 
- and don't forgot the add the `cash.png` and `blackmoney.png` and `crypto.png` in to your inventory image folder.
```lua
cash                         = { name = 'cash', label = 'Cash', weight = 0, type = 'item', image = 'cash.png', unique = false, useable = false, shouldClose = true, combinable = nil, description = 'Cash'  },
black_money                  = { name = 'black_money', label = 'Black Money', weight = 0, type = 'item', image = 'black_money.png', unique = false, useable = false, shouldClose = true, combinable = nil, description = 'Black Money?' },
crypto                       = { name = 'crypto', label = 'Crypto', weight = 0, type = 'item', image = 'crypto.png', unique = false, useable = false, shouldClose = true, combinable = nil, description = 'Crypto' },
```

# How to change marketbills to black_money 
- The black_money uses the item amount as a number, 
- and the marketbills uses the item amount as a table.
- so you need to edit that part of the code.

- from this
```lua
local worth = {value=10} -- table
Player.Functions.AddItem('marketbills', worth) -- to add marketbills
Player.Functions.RemoveItem('marketbills', worth)-- to remove marketbills
```
- to this
```lua
local amount = 10 -- number
Player.Functions.AddMoney('black_money', amount) -- to add blackmoney
Player.Functions.RemoveMoney('black_money', amount)  -- to remove blackmoney
```

## **INSTALL FOR QB INVENTORY AND QB-HUD**
- [READ-ME](https://github.com/MaDHouSe79/mh-cashasitem/blob/main/readme/)

# LICENSE
[GPL LICENSE](./LICENSE)<br />
&copy; [MaDHouSe79](https://www.youtube.com/@MaDHouSe79)
