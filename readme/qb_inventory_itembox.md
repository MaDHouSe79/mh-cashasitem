## **INSTALL FOR QB Inventory ItemBox** (Optinal)

# Edit For Item amount in ItemBox popup in qb-inventory
- Example: Used 1x, Received 10x, Removed 10x

# Replace code
- Find the trigger 'inventory:client:ItemBox' in 'qb-inventory/client/main.lua'
- Replace it with the code below
```lua
RegisterNetEvent('qb-inventory:client:ItemBox', function(itemData, type, amount)
    SendNUIMessage({
        action = 'itemBox',
        item = itemData,
        amount = amount,
        type = type
    })
end)
```

# Replace code
- find the function `Inventory.UseItem` in `qb-inventory/html/js/app.js`
- Replace it with the code below
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
TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items['cash'], "add", 10)  -- 10 is the item amount, change this to your script needs
TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items['cash'], "remove", 10) -- 10 is the item amount, change this to your script needs
```