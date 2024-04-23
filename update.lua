# NEW SERVER TRIGGER
- you can change this triggers for more protection.
- be sure that these 2 triggers are the same, otherwise the script will not work.
```lua
Config.UpdateTrigger = "mh-cashasitem:server:updateCash" --(in mh-cashasitem/config.lua)
local CashAsItemUpdateTrigger = "mh-cashasitem:server:updateCash" -- (in qb-inventory/server.lua)
```

if you already have cashasitem installed you can also use this but you need to replace some lines in qb-inventory/server.lua
first you need to add in `qb-inventory/server.lua` someware at the top of the file
```lua
local CashAsItemUpdateTrigger = "mh-cashasitem:server:updateCash"
```  
then you need to replace all the lines from `"mh-cashasitem:server:updateCash"` to `CashAsItemUpdateTrigger`
