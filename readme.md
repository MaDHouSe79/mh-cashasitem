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

# Youtube 🙈
- [Youtube](https://www.youtube.com/c/@MaDHouSe79)

# mh-cashasitem
- Use cash as item for qb-core

# Dependencies
- [qb-core](https://github.com/qbcore-framework/qb-core)
- [mh-inventiory](https://github.com/MaDHouSe79/mh-inventory)

# Optional
- [mh-blackmarket](https://github.com/MaDHouSe79/mh-blackmarket)

# Install
- Create a folder `[mh]` in resources,
- Put the folder mh-cashasitem in the [mh] folder
- Add in your server.cfg `ensure [mh]`, make sure this is below `ensure [standalone]`
- Don't forget to use [mh-inventiory](https://github.com/MaDHouSe79/mh-inventory) and read the readme.

# Command
- /blackmoney to see the amount

# Note for using blackmoney as an item
- first you need to edit the qb-core/config.lua to this below
- add blackmoney to this table
```lua
QBConfig.Money.MoneyTypes = { cash = 500, bank = 5000, crypto = 0, blackmoney = 0 } -- type = startamount - Add or remove money types for your server (for ex. blackmoney = 0), remember once added it will not be removed from the database!
QBConfig.Money.DontAllowMinus = { 'cash', 'crypto', 'blackmoney' } -- Money that is not allowed going in minus
```

# Triggers you can use for your own inventory
- use this server side only!
- most used in trigger `inventory:server:SetInventoryData` and `inventory:server:GiveItem`
```lua
-- true and the end is to display money change, if false you dont see a change but it wil change the money amount
TriggerEvent('mh-cashasitem:server:updateCash', src, itemData, amount, "add", true)

-- true and the end is to display money change, if false you dont see a change but it wil change the money amount
TriggerEvent('mh-cashasitem:server:updateCash', src, itemData, amount, "remove", true) 
```

# buy item with blackmoney
```lua
TriggerEvent('mh-cashasitem:server:buyitemwithblackmoney', src, itemData)
```

# Video
https://www.youtube.com/watch?v=sWYkV-PeqU4

# Check in server file config
- inventory itembox popup when you add or remove items.
- set it all to false if you don't want it.
```lua
local useItemBox = true    -- true if you want to use the itembox popup 
local useAddBox = true     -- true if you want to see the add itembox popup (only works if useItemBox = true)
local useRemoveBox = false -- true if you want to see the remove itembox popup (only works if useItemBox = true)
```

# Add in `[qb]/qb-core/shared/items.lua` 
- and don't forgot the add the cash.png in to your inventory image folder.
```lua
['cash'] = {
    ['name'] = 'cash', 
    ['label'] = 'Cash', 
    ['weight'] = 0, 
    ['type'] = 'item', 
    ['image'] = 'cash.png', 
    ['unique'] = false,
    ['useable'] = false,
    ['shouldClose'] = true,
    ['combinable'] = nil,
    ['description'] = 'Cash'
},
['blackmoney'] = {
    ['name'] = 'blackmoney',
    ['label'] = 'Black Money',
    ['weight'] = 0,
    ['type'] = 'item',
    ['image'] = 'blackmoney.png',
    ['unique'] = false,
    ['useable'] = false,
    ['shouldClose'] = true,
    ['combinable'] = nil,
    ['description'] = 'Black Money?'
},
```

# Contributers
<a href="https://github.com/MaDHouSe79/mh-carlift/graphs/contributors">
  <img src="https://contributors-img.web.app/image?repo=MaDHouSe79/mh-carlift" />
</a>

# LICENSE
[GPL LICENSE](./LICENSE)<br />
&copy; [MaDHouSe79](https://www.youtube.com/@MaDHouSe79)
