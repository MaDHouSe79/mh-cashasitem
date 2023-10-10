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

# Install
- Create a folder `[mh]` in resources,
- Put the folder mh-cashasitem in the [mh] folder
- Add in your server.cfg `ensure [mh]`, make sure this is below `ensure [standalone]`
- Don't forget to use [mh-inventiory](https://github.com/MaDHouSe79/mh-inventory) and read the readme.

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
```

# LICENSE
[GPL LICENSE](./LICENSE)<br />
&copy; [MaDHouSe79](https://www.youtube.com/@MaDHouSe79)
