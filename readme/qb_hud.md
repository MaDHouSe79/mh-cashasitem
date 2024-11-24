## **INSTALL FOR QB HUD**
# Add in top of qb-hud/client.lua
- around line 15
```lua
local blackAmount = 0
local cryptoAmount = 0
```

# Replace this code below in qb-hud/client.lua
- around line 863
```lua
RegisterNetEvent('hud:client:ShowAccounts', function(type, amount)
    if amount == nil then amount = 0 end
    if type == 'cash' then
        SendNUIMessage({
            action = 'show',
            type = 'cash',
            cash = Round(amount)
        })
    elseif type == 'black_money' then
        SendNUIMessage({
            action = 'show',
            type = 'blackmoney',
            blackmoney = Round(amount)
        })
    elseif type == 'crypto' then
        SendNUIMessage({
            action = 'show',
            type = 'crypto',
            crypto = Round(amount)
        })
    else
        SendNUIMessage({
            action = 'show',
            type = 'bank',
            bank = Round(amount)
        })
    end
end)
```

# Replace this code below in qb-hud/client.lua
- around line 886
```lua
RegisterNetEvent('hud:client:OnMoneyChange', function(type, amount, isMinus)
    cashAmount = PlayerData.money['cash']
    bankAmount = PlayerData.money['bank']
    blackAmount = PlayerData.money['black_money']
    cryptoAmount = PlayerData.money['crypto']
    SendNUIMessage({
        action = 'updatemoney',
        cash = Round(cashAmount),
        bank = Round(bankAmount),
        blackmoney = Round(blackAmount),
        crypto = Round(cryptoAmount),
        amount = Round(amount),
        minus = isMinus,
        type = type
    })
end)
```

# Replace this code below in qb-hud/html/app.js
- around line 622
```js
// MONEY HUD
const moneyHud = Vue.createApp({
    data() {
        return {
            cash: 0,
            bank: 0,
            blackmoney: 0,
            crypto: 0,
            amount: 0,
            plus: false,
            minus: false,
            showCash: false,
            showBank: false,
            showBlack: false,
            showCrypto: false,
            showUpdate: false,
        };
    },
    destroyed() {
        window.removeEventListener("message", this.listener);
    },
    mounted() {
        this.listener = window.addEventListener("message", (event) => {
            switch (event.data.action) {
                case "showconstant":
                    this.showConstant(event.data);
                    break;
                case "updatemoney":
                    this.update(event.data);
                    break;
                case "show":
                    this.showAccounts(event.data);
                    break;
            }
        });
    },
    methods: {
        // CONFIGURE YOUR CURRENCY HERE
        // https://www.w3schools.com/tags/ref_language_codes.asp LANGUAGE CODES
        // https://www.w3schools.com/tags/ref_country_codes.asp COUNTRY CODES
        formatMoney(value) {
            const formatter = new Intl.NumberFormat("en-US", {
                style: "currency",
                currency: "USD",
                minimumFractionDigits: 0,
            });
            return formatter.format(value);
        },
        showConstant(data) {
            this.showCash = true;
            this.showBank = true;
            this.showBlack = true;
            this.showCrypto = true;
            this.cash = data.cash;
            this.bank = data.bank;
            this.blackmoney = data.blackmoney;
            this.crypto = data.crypto;
        },
        update(data) {
            this.showUpdate = true;
            this.amount = data.amount;
            this.bank = data.bank;
            this.cash = data.cash;
            this.blackmoney = data.blackmoney;
            this.crypto = data.crypto;
            this.minus = data.minus;
            this.plus = data.plus;
            if (data.type === "cash") {
                if (data.minus) {
                    this.showCash = true;
                    this.minus = true;
                    setTimeout(() => (this.showUpdate = false), 1000);
                    setTimeout(() => (this.showCash = false), 2000);
                } else {
                    this.showCash = true;
                    this.plus = true;
                    setTimeout(() => (this.showUpdate = false), 1000);
                    setTimeout(() => (this.showCash = false), 2000);
                }
            }
            if (data.type === "bank") {
                if (data.minus) {
                    this.showBank = true;
                    this.minus = true;
                    setTimeout(() => (this.showUpdate = false), 1000);
                    setTimeout(() => (this.showBank = false), 2000);
                } else {
                    this.showBank = true;
                    this.plus = true;
                    setTimeout(() => (this.showUpdate = false), 1000);
                    setTimeout(() => (this.showBank = false), 2000);
                }
            }
            if (data.type === "black_money") {
                if (data.minus) {
                    this.showBlack = true;
                    this.minus = true;
                    setTimeout(() => (this.showUpdate = false), 1000);
                    setTimeout(() => (this.showBlack = false), 2000);
                } else {
                    this.showBlack = true;
                    this.plus = true;
                    setTimeout(() => (this.showUpdate = false), 1000);
                    setTimeout(() => (this.showBlack = false), 2000);
                }
            }
            if (data.type === "crypto") {
                if (data.minus) {
                    this.showCrypto = true;
                    this.minus = true;
                    setTimeout(() => (this.showUpdate = false), 1000);
                    setTimeout(() => (this.showCrypto = false), 2000);
                } else {
                    this.showCrypto = true;
                    this.plus = true;
                    setTimeout(() => (this.showUpdate = false), 1000);
                    setTimeout(() => (this.showCrypto = false), 2000);
                }
            }
        },
        showAccounts(data) {
            if (data.type === "cash" && !this.showCash) {
                this.showCash = true;
                this.cash = data.cash;
                setTimeout(() => (this.showCash = false), 3500);
            } else if (data.type === "bank" && !this.showBank) {
                this.showBank = true;
                this.bank = data.bank;
                setTimeout(() => (this.showBank = false), 3500);
            }else if (data.type === "blackmoney" && !this.showBlack) {
                this.showBlack = true;
                this.blackmoney = data.blackmoney;
                setTimeout(() => (this.showBlack = false), 3500);
            }else if (data.type === "crypto" && !this.showCrypto) {
                this.showCrypto = true;
                this.crypto = data.crypto;
                setTimeout(() => (this.showCrypto = false), 3500);
            }
        },
    },
}).mount("#money-container");
```


# Add this code below in qb-hud/html/index.html
- around line 205
```html
<div id="money-cash">
    <transition name="slide-fade">
        <p v-if="showBlack"><span id="sign">$&nbsp;</span><span id="money">{{(blackmoney)}}</span></p>
    </transition>
</div>

<div id="money-cash">
    <transition name="slide-fade">
        <p v-if="showCrypto"><span id="sign">₿&nbsp;</span><span id="money">{{(crypto)}}</span></p>
    </transition>
</div>
```
