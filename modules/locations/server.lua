local shopLocks = {}
local purchaseLocks = {}

local function IsPlayerNearLocation(source, index)
    if not index or type(index) ~= "number" then return false end
    local location = Config.Locations[index]
    if not location or not location.coords then return false end
    local ped = GetPlayerPed(source)
    if not ped or ped == 0 then return false end
    local pcoords = GetEntityCoords(ped)
    local dist = #(pcoords - location.coords)
    return dist <= 10.0
end

function SocietyProfit(accounts, amount)
    if not accounts or type(accounts) ~= "table" or not amount or amount <= 0 then return end
    for k,v in pairs(accounts) do 
        AddSocietyMoney(k, amount * (v * 0.01))
    end
end

RegisterNetEvent("pickle_lottery:shopPurchase", function(index, itemIndex, amount)
    local source = source
    if not source or source <= 0 then return end

    -- Proximity validation (FIVEM-SEC-006)
    if not IsPlayerNearLocation(source, index) then return end

    -- Strict input validation (FIVEM-SEC-007)
    if type(itemIndex) ~= "number" or itemIndex ~= math.floor(itemIndex) then return end
    if type(amount) ~= "number" or amount ~= math.floor(amount) or amount < 1 or amount > 50 then return end

    local cfg = Config.Locations[index]
    if not cfg then return end
    local store = cfg.store or Config.DefaultStore
    if not store or not store.items then return end
    local item = store.items[itemIndex]
    if not item or not item.item or type(item.price) ~= "number" or item.price < 0 then return end

    local itemCFG = Config.Items[item.item] or {}
    local totalCost = amount * item.price

    if not Inventory.CanCarryItem(source, item.item, amount) then
        ShowNotification(source, _L("no_room"))
        return
    end

    if shopLocks[source] then return end
    shopLocks[source] = true

    local remaining = GetMoney(source) - totalCost
    if remaining < 0 then 
        shopLocks[source] = nil
        ShowNotification(source, _L("no_afford", math.ceil(remaining * -1)))
        return
    end

    RemoveMoney(source, totalCost)
    if store.accounts and totalCost > 0 then
        SocietyProfit(store.accounts, totalCost)
    end

    if itemCFG?.game == "scratch" then
        for i=1, amount do
            GenerateScratchoff(source, item.item)
        end
    else
        Inventory.AddItem(source, item.item, amount)
    end

    shopLocks[source] = nil
end)

RegisterNetEvent("pickle_lottery:purchaseTicket", function(index, itemData)
    local source = source
    if not source or source <= 0 then return end

    -- Proximity validation (FIVEM-SEC-006)
    if not IsPlayerNearLocation(source, index) then return end

    -- Client payload validation
    if type(itemData) ~= "table" or type(itemData.slot) ~= "number" then return end

    -- Server-authoritative inventory item lookup (FIVEM-SEC-001)
    local inv = Inventory.GetInventory(source)
    local serverItem
    if inv then
        for i=1, #inv do
            if inv[i].slot == itemData.slot then
                serverItem = inv[i]
                break
            end
        end
    end

    if not serverItem then return end
    if serverItem.name ~= "lottery_keno" and serverItem.name ~= "lottery_moneyball" then return end

    local ticket = serverItem.metadata
    if not ticket or type(ticket) ~= "table" then return end

    local game = ticket.game
    if not game or (game ~= "keno" and game ~= "moneyball") then return end

    local cfg = Config.Games[game]
    if not cfg then return end

    local price
    if game == "keno" then
        if type(ticket.games) ~= "number" or type(ticket.wager) ~= "number" then return end
        local numGames = cfg.games[ticket.games]
        local wagerAmt = cfg.wagers[ticket.wager]
        if not numGames or not wagerAmt or numGames <= 0 or wagerAmt <= 0 then return end
        if type(ticket.spots) ~= "table" or #ticket.spots < 1 or #ticket.spots > #cfg.prizes then return end
        price = numGames * wagerAmt
    elseif game == "moneyball" then
        -- Enforce non-empty panels array (FIVEM-SEC-008)
        if type(ticket.panels) ~= "table" or #ticket.panels < 1 or #ticket.panels > cfg.panelCount then return end
        price = cfg.price * #ticket.panels
    end

    if not price or price <= 0 then return end

    if not Inventory.CanCarryItem(source, "lottery_receipt", 1) then
        ShowNotification(source, _L("no_room"))
        return
    end

    if purchaseLocks[source] then return end
    purchaseLocks[source] = true

    local remaining = GetMoney(source) - price
    if remaining < 0 then 
        purchaseLocks[source] = nil
        ShowNotification(source, _L("no_afford", math.ceil(remaining * -1)))
        return
    end

    -- Remove the ticket slip from inventory
    Inventory.RemoveItem(source, serverItem.name, 1, serverItem.slot)

    RemoveMoney(source, price)

    local store = Config.Locations[index] and Config.Locations[index].store or Config.DefaultStore
    if store.accounts and price > 0 then
        SocietyProfit(store.accounts, price)
    end

    GiveReceipt(source, ticket)

    purchaseLocks[source] = nil
end)
