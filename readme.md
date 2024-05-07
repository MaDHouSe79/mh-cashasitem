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

# Special Thanks to @Bravedevelopment for this install video
- [@Bravedevelopment](https://www.youtube.com/@Bravedevelopment)
- [Install Video](https://www.youtube.com/watch?v=Z_TruT7s-Ec)

# mh-cashasitem
- Before you start, `BACKUP` your `resources` folder cause when something is wrong you have a backup.
- This is the best cash/blackmoney/crypto item script for your qbcore server.
- for Exsisted user: Read the [UPDATE.MD](https://github.com/MaDHouSe79/mh-cashasitem/blob/main/update.md) if you have to change something.


# Dependencies
- [qb-core](https://github.com/qbcore-framework/qb-core)
- [qb-hud](https://github.com/qbcore-framework/qb-hud)
- [qb-inventiory](https://github.com/qbcore-framework/qb-inventory) 

# Optional
- [mh-blackmarket](https://github.com/MaDHouSe79/mh-blackmarket)
- [mh-moneywash](https://github.com/MaDHouSe79/mh-moneywash)

# Install
- Create a folder `[mh]` in resources,
- Put the folder `mh-cashasitem` in the `[mh]` folder
- Add in your server.cfg `ensure [mh]`, make sure this is below `ensure [standalone]`
- Make sure you read the readme files for install, and only when you are done you can restart the server.

# Command
- `/cash` to see the amount
- `/bank` to see the amount
- `/blackmoney` to see the amount
- `/crypto` to see the amount

# Note for using blackmoney as an item
- first you need to edit the qb-core/config.lua to this below
- add black_money to this table
```lua
QBConfig.Money.MoneyTypes = { cash = 500, bank = 5000, crypto = 0, black_money = 0 } -- type = startamount - Add or remove money types for your server (for ex. blackmoney = 0), remember once added it will not be removed from the database!
QBConfig.Money.DontAllowMinus = { 'cash', 'crypto', 'black_money' } -- Money that is not allowed going in minus
```

# NOTE FOR SERVER TRIGGER
- Read the [UPDATE.MD](https://github.com/MaDHouSe79/mh-cashasitem/blob/main/update.md)

# Triggers you can use for your own inventory
- use this server side only when you add or delete an item from and to your inventory.
```lua
-- true at the end of the trigger is to display money change at the right top of your screen
-- if false you don't see a change but it will change the money amount
TriggerEvent('mh-cashasitem:server:updateCash', src, itemData, amount, "add", true) -- this true

-- true at the end of the trigger is to display money change at the right top of your screen
-- if false you don't see a change but it will change the money amount
TriggerEvent('mh-cashasitem:server:updateCash', src, itemData, amount, "remove", true) -- this true
```

# Video
[Youtube](https://www.youtube.com/watch?v=sWYkV-PeqU4)

# Check in server file config
- inventory itembox popup when you add or remove items.
- set it all to false if you don't want it.
```lua
local useItemBox = false   -- true if you want to use the itembox popup 
local useAddBox = false    -- true if you want to see the add itembox popup (only works if useItemBox = true)
local useRemoveBox = false -- true if you want to see the remove itembox popup (only works if useItemBox = true)
```

![alttext](https://github.com/MaDHouSe79/mh-cashasitem/blob/main/image/cash.png?raw=true)
![alttext](https://github.com/MaDHouSe79/mh-cashasitem/blob/main/image/black_money.png?raw=true)
![alttext](https://github.com/MaDHouSe79/mh-cashasitem/blob/main/image/crypto.png?raw=true)

# Add in `[qb]/qb-core/shared/items.lua` 
- and don't forgot the add the `cash.png` and `blackmoney.png` and `crypto.png` in to your inventory image folder.
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
['black_money'] = {
    ['name'] = 'black_money',
    ['label'] = 'Black Money',
    ['weight'] = 0,
    ['type'] = 'item',
    ['image'] = 'black_money.png',
    ['unique'] = false,
    ['useable'] = false,
    ['shouldClose'] = true,
    ['combinable'] = nil,
    ['description'] = 'Black Money?'
},
['crypto'] = {
    ['name'] = 'crypto',
    ['label'] = 'Crypto',
    ['weight'] = 0,
    ['type'] = 'item',
    ['image'] = 'crypto.png',
    ['unique'] = false,
    ['useable'] = false,
    ['shouldClose'] = true,
    ['combinable'] = nil,
    ['description'] = 'Crypto'
},
```

# To add in your inventory config.lua file.
```lua
-- it works but this is for mh-stashes but this script is not released yet.
-- this is needed in the inventory config, or the get many errors.
-- all default true.
Config.Stashes = { 
    ["walletstash"] = true, 
    ["cashstash"] = true, 
    ["drugsstash"] = true, 
    ["weaponstash"] = true,
    ['smallbagstash'] = true,
    ['mediumbagstash'] = true,
    ['largebagstash'] = true,
    ["missionstash"] = true,
}

-- only jobs can open trunks of job vehicles,
-- if you are driving a police car you need to be a police to able to open this trunk, same for the amulance
-- this so other players can't steel stuff.
Config.OnlyJobCanOpenJobVehicleTrucks = true -- defailt true

-- vehicle class max trunk weight and slots
 
Config.TrunkSpace = {
    ['default'] = {  slots = 35, maxWeight = 60000 }, -- All the vehicle class that not listed here will use this as default
    [0] = { slots = 30, maxWeight = 38000 },   -- Compacts
    [1] = { slots = 40, maxWeight = 50000 },   -- Sedans
    [2] = { slots = 50, maxWeight = 75000 },   -- SUVs
    [3] = { slots = 35, maxWeight = 42000 },   -- Coupes
    [4] = { slots = 30, maxWeight = 38000 },   -- Muscle
    [5] = { slots = 25, maxWeight = 30000 },   -- Sports Classics
    [6] = { slots = 25, maxWeight = 30000 },   -- Sports
    [7] = { slots = 25, maxWeight = 30000 },   -- Super
    [8] = { slots = 15, maxWeight = 15000 },   -- Motorcycles
    [9] = { slots = 35, maxWeight = 60000 },   -- Off-road
    [12] = { slots = 35, maxWeight = 120000 }, -- Vans
    [13] = { slots = 0, maxWeight = 0 },       -- Cycles
    [14] = { slots = 50, maxWeight = 120000 }, -- Boats
    [15] = { slots = 50, maxWeight = 120000 }, -- Helicopters
    [16] = { slots = 50, maxWeight = 120000 }, -- Planes
}
```

# Add To your inventory server side someware on the top
```lua
-- you can change this trigger for protection.
-- if you change this dont forget to change,
-- the `Config.UpdateTrigger` in `mh-cashasitem` config.lua
local CashAsItemUpdateTrigger = "mh-cashasitem:server:updateCash"

local lastUsedStashItem = nil
local function IsItemAllowedToAdd(src, stash, item)
    if Config.Stashes[stash] then
        if lastUsedStashItem ~= nil and lastUsedStashItem.info.allowedItems ~= nil and
            not lastUsedStashItem.info.allowedItems[item] then
            TriggerEvent('mh-stashes:server:allowed_items_error', src, lastUsedStashItem.info.allowedItems)
            lastUsedStashItem = nil
            return false
        end
    end
    return true
end

local function IsStashItemLootable(src, stash)
    if Config.Stashes[stash] and lastUsedStashItem ~= nil and lastUsedStashItem.info and
        not lastUsedStashItem.info.canloot then
        lastUsedStashItem = nil
        TriggerEvent('mh-stashes:server:not_allowed_to_loot', src)
        return false
    end
    return true
end
```

# Money Wash from marketbills to blackmoney item
- The blackmoney uses the item amount as a number, 
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

# Edit For Item amount in ItemBox popup 
- Example: Used 1x, Received 10x, Removed 10x

# Replace code 1
- Find the trigger 'inventory:client:ItemBox' in 'qb-inventory/client/main.lua'
- replace the code with below
```lua
RegisterNetEvent('inventory:client:ItemBox', function(itemData, type, amount)
    SendNUIMessage({
        action = 'itemBox',
        item = itemData,
        amount = amount,
        type = type
    })
end)
```

# Replace code 2
- find the function `Inventory.UseItem` in `qb-inventory/html/js/app.js`
- replace the code below
```js
Inventory.itemBox = function (data) {
    if (itemBoxtimer !== null) {
        clearTimeout(itemBoxtimer);
    }
    var type = "Used " + data.amount + "x";
    if (data.type == "add") {
        type = "Received " + data.amount + "x";
    } else if (data.type == "remove") {
        type = "Removed " + data.amount + "x";
    }
    var itemboxHTML = '<div class="item-slot"><div class="item-slot-amount"><p>' + type + '</p></div><div class="item-slot-label"><p>' + data.item.label + '</p></div><div class="item-slot-img"><img src="images/' + data.item.image + '" alt="' + data.item.name + '" /></div></div>';
    var $itembox = $(itemboxHTML);
    $(".itemboxes-container").prepend($itembox);
    $itembox.fadeIn(250);
    setTimeout(function () {
        $.when($itembox.fadeOut(300)).done(function () {
            $itembox.remove();
        });
    }, 3000);
};
```

# Example.
```lua
TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['cash'], "add", 10)  -- 10 is the item amount, change this to your script needs
TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['cash'], "remove", 10) -- 10 is the item amount, change this to your script needs
```

## **INSTALL FOR QB INVENTORY AND QB-HUD**
- [READ-ME](https://github.com/MaDHouSe79/mh-cashasitem/blob/main/readme/)

# Contributers
<a href="https://github.com/MaDHouSe79/mh-cashasitem/graphs/contributors">
  <img src="https://contributors-img.web.app/image?repo=MaDHouSe79/mh-cashasitem" />
</a>

# LICENSE
[GPL LICENSE](./LICENSE)<br />
&copy; [MaDHouSe79](https://www.youtube.com/@MaDHouSe79)
