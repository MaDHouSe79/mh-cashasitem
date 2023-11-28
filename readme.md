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

# My Youtube Channel
- [Subscribe](https://www.youtube.com/c/@MaDHouSe79) 

# mh-cashasitem
- This is the best cash/blackmoney item script for your qbcore server.
- Use cash and or blackmonmey as item for qb-core
- It also a blackmoney item as option you can use instead of MarkedBills

# Dependencies
- [qb-core](https://github.com/qbcore-framework/qb-core)
- [qb-hud](https://github.com/qbcore-framework/qb-hud)
- [mh-inventiory](https://github.com/MaDHouSe79/mh-inventory) or [qb-inventiory](https://github.com/MaDHouSe79/qb-inventory) or [ps-inventory](https://github.com/Project-Sloth/ps-inventory)

# Optional
- [mh-blackmarket](https://github.com/MaDHouSe79/mh-blackmarket)

# Install
- Create a folder `[mh]` in resources,
- Put the folder mh-cashasitem in the [mh] folder
- Add in your server.cfg `ensure [mh]`, make sure this is below `ensure [standalone]`
- Make sure you read the readme files for install, and only when you are done you can restart the server.

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
![alttext](https://github.com/MaDHouSe79/mh-cashasitem/blob/main/image/blackmoney.png?raw=true)

# Add in `[qb]/qb-core/shared/items.lua` 
- and don't forgot the add the `cash.png` and `blackmoney.png` in to your inventory image folder.
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
    ['default'] = { -- All the vehicle class that not listed here will use this as default
        slots = 35,
        maxWeight = 60000
    },
    [0] = { -- Compacts
        slots = 30,
        maxWeight = 38000
    },
    [1] = { -- Sedans
        slots = 40,
        maxWeight = 50000
    },
    [2] = { -- SUVs
        slots = 50,
        maxWeight = 75000
    },
    [3] = { -- Coupes
        slots = 35,
        maxWeight = 42000
    },
    [4] = { -- Muscle
        slots = 30,
        maxWeight = 38000
    },
    [5] = { -- Sports Classics
        slots = 25,
        maxWeight = 30000
    },
    [6] = { -- Sports
        slots = 25,
        maxWeight = 30000
    },
    [7] = { -- Super
        slots = 25,
        maxWeight = 30000
    },
    [8] = { -- Motorcycles
        slots = 15,
        maxWeight = 15000
    },
    [9] = { -- Off-road
        slots = 35,
        maxWeight = 60000
    },
    [12] = { -- Vans
        slots = 35,
        maxWeight = 120000
    },
    [13] = { -- Cycles
        slots = 0,
        maxWeight = 0
    },
    [14] = { -- Boats
        slots = 50,
        maxWeight = 120000
    },
    [15] = { -- Helicopters
        slots = 50,
        maxWeight = 120000
    },
    [16] = { -- Planes
        slots = 50,
        maxWeight = 120000
    },
}
```

# Add To your inventory server side someware on the top
```lua
local lastUsedStashItem = nil

local function IsItemAllowedToAdd(src, stash, item)
    if Config.Stashes[stash] then
        if lastUsedStashItem ~= nil then
            if lastUsedStashItem.info.allowedItems ~= nil then
                if not lastUsedStashItem.info.allowedItems[item.name] then
                    TriggerEvent('mh-stashes:server:allowed_items_error', src, lastUsedStashItem.info.allowedItems)
                    lastUsedStashItem = nil
                    return false
                end
            end
        end
    end
    return true
end

local function IsStashItemLootable(src, stash, item)
    if Config.Stashes[stash] then
        if lastUsedStashItem ~= nil then
            if lastUsedStashItem and lastUsedStashItem.info then
                if not lastUsedStashItem.info.canloot then
                    TriggerEvent('mh-stashes:server:not_allowed_to_loot', src)
                    lastUsedStashItem = nil
                    return false
                elseif lastUsedStashItem.info.isOnMission then
                    TriggerEvent('mh-stashes:server:not_allowed_to_loot', src)
                    lastUsedStashItem = nil
                    return false
                end
            end
        end
    end
    return true
end
```

## **INSTALL FOR QB INVENTORY AND QB-HUD**
- [READ-ME](https://github.com/MaDHouSe79/mh-cashasitem/blob/main/readme/)

## **INSTALL FOR PS INVENTORY**
- [READ-ME](https://github.com/MaDHouSe79/mh-cashasitem/blob/main/readme/)

# Contributers
<a href="https://github.com/MaDHouSe79/mh-cashasitem/graphs/contributors">
  <img src="https://contributors-img.web.app/image?repo=MaDHouSe79/mh-cashasitem" />
</a>

# LICENSE
[GPL LICENSE](./LICENSE)<br />
&copy; [MaDHouSe79](https://www.youtube.com/@MaDHouSe79)
