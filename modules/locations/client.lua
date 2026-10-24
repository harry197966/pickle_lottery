local locationEntities = {}
local insideMenu
local disableCam

function DisableCamera(bool)
    if disableCam and bool then return end
    disableCam = bool
    if bool then
        CreateThread(function()
            while disableCam do 
                DisableControlAction(1, 1, true)
                DisableControlAction(1, 2, true)
                Wait(0)
            end
        end)
    end
end

function DeleteLocationEntity(index)
    if locationEntities[index] and DoesEntityExist(locationEntities[index]) then 
        DeleteEntity(locationEntities[index])
        locationEntities[index] = nil
    end
end

function GetLocationEntity(index) 
    return locationEntities[index]
end

function EnsureLocationEntity(index)
    local entity = GetLocationEntity(index)
    if entity and DoesEntityExist(entity) then return entity end
    local cfg = Config.Locations[index]
    if cfg.entity.type == "object" then 
        entity = CreateProp(cfg.entity.model, cfg.location.x, cfg.location.y, cfg.location.z, false, true, false)
        SetEntityHeading(entity, cfg.entity.heading)
    elseif cfg.entity.type == "ped" then
        entity = CreateNPC(26, cfg.entity.model, cfg.location.x, cfg.location.y, cfg.location.z, cfg.entity.heading, false, true)
        SetEntityHeading(entity, cfg.entity.heading)
        SetEntityInvincible(entity, true)
        SetBlockingOfNonTemporaryEvents(entity, true)
    end
    FreezeEntityPosition(entity, true)
    locationEntities[index] = entity
    return entity
end

function DrawingsMenu(name, index)
    if insideMenu then return end
    insideMenu = index
    lib.callback("pickle_lottery:getDrawings", "", function(game_id, games)
        if not game_id then 
            insideMenu = nil
            SetTimeout(250, function()
                LotteryMenu(index)
            end)
            return
        end
        local options = {}
        for i=1, #games do 
            if name == "keno" then
                local numbers = ""
                for j=1, #games[i].numbers do 
                    if j==1 then 
                        numbers = games[i].numbers[j]
                    else
                        numbers = numbers .. ", " .. games[i].numbers[j]
                    end
                end
                options[#options + 1] = {
                    title = _L("keno_view_title", games[i].id),
                    description = _L("keno_view_desc", numbers, games[i].date)
                }
            elseif name == "moneyball" then
                local numbers = ""
                for j=1, #games[i].numbers - 1 do 
                    if j==1 then 
                        numbers = games[i].numbers[j]
                    else
                        numbers = numbers .. ", " .. games[i].numbers[j]
                    end
                end
                options[#options + 1] = {
                    title = _L("moneyball_view_title", games[i].id),
                    description = _L("moneyball_view_desc", numbers, games[i].numbers[#games[i].numbers], games[i].date)
                }
            end
        end
        if #options < 1 then 
            insideMenu = nil
            ShowNotification(_L("no_drawings"))
            SetTimeout(250, function()
                LotteryMenu(index)
            end)
            return
        end
        lib.registerContext({
            id = 'pickle_lottery_drawings_' .. name,
            title = _L("menu_main_view_" .. name),
            options = options,
            onExit = function() 
                insideMenu = nil
                SetTimeout(250, function()
                    LotteryMenu(index)
                end)
            end
        })
        lib.showContext('pickle_lottery_drawings_' .. name)
    end, name)
end

function PurchaseMenu(index) 
    if insideMenu then return end
    insideMenu = index
    local cfg = Config.Locations[index]
    local store = cfg.store or Config.DefaultStore
    local options = {}
    for i=1, #store.items do
        options[#options + 1] = {
            title = store.items[i].label,
            description = _L("price", store.items[i].price) .. (store.items[i].description and (" - " .. store.items[i].description) or ""),
            onSelect = function()
                lib.hideContext()
                local input = lib.inputDialog(store.items[i].label .. " - " .. _L("price", store.items[i].price), {_L("amount")})

                if not input or not tonumber(input[1]) then 
                    insideMenu = nil
                    SetTimeout(250, function()
                        PurchaseMenu(index) 
                    end)
                    return 
                end
                local amount = tonumber(input[1])
                local alert = lib.alertDialog({
                    content = _L("confirm_payment", store.items[i].price * amount, store.items[i].label, amount),
                    centered = true,
                    cancel = true
                })
                insideMenu = nil
                SetTimeout(250, function()
                    PurchaseMenu(index) 
                end)
                if alert == "confirm" then 
                    TriggerServerEvent("pickle_lottery:shopPurchase", index, i, amount)
                end
            end,
        }
    end
    if #options < 1 then return end
    lib.registerContext({
        id = 'pickle_lottery_purchase',
        title = _L("menu_main_purchase"),
        options = options,
        onExit = function() 
            insideMenu = nil
            SetTimeout(250, function()
                LotteryMenu(index) 
            end)
        end
    })
    lib.showContext('pickle_lottery_purchase')
end

function TicketInventoryMenu(index)
    if insideMenu then return end
    insideMenu = index
    lib.callback("pickle_lottery:getInventory", "", function(result)
        if not result then 
            insideMenu = nil
            SetTimeout(250, function()
                LotteryMenu(index)
            end)
        end
        local tickets = {}
        for i=1, #result do 
            if (result[i].name == "lottery_keno" or result[i].name == "lottery_moneyball") and result[i].metadata?.game then
                tickets[#tickets + 1] = result[i]
            end
        end 
        local options = {}
        for i=1, #tickets do 
            local description
            if (tickets[i].name == "lottery_keno") then
                local numbers = ""
                local data = TicketValues("keno", tickets[i].metadata)
                for j=1, #tickets[i].metadata.spots do 
                    if j==1 then 
                        numbers = tickets[i].metadata.spots[j]
                    else
                        numbers = numbers .. ", " .. tickets[i].metadata.spots[j]
                    end
                end
                description = _L("insert_keno", numbers, data.games, _L("price", data.wager), _L("price", data.wager * data.games))
            elseif (tickets[i].name == "lottery_moneyball") then
                local data = TicketValues("moneyball", tickets[i].metadata)
                local panels = ""
                for j=1, #tickets[i].metadata.panels do
                    local numbers = ""
                    local panel = tickets[i].metadata.panels[j]
                    if j~=1 then
                        panels = panels .. "\n"
                    end
                    for k=1, #panel-1 do    
                        if k==1 then 
                            numbers = (panel[k] + 1)
                        else
                            numbers = numbers .. ", " .. (panel[k] + 1)
                        end
                    end 
                    panels = panels .. _L("moneyball_numbers", j, numbers, panel[#panel] + 1)
                end
                description = _L("insert_moneyball", panels, _L("price", data.price))
            end
            options[#options + 1] = {
                title = tickets[i].label,
                description = description,
                onSelect = function()
                    insideMenu = nil
                    TriggerServerEvent("pickle_lottery:purchaseTicket", index, tickets[i])
                    SetTimeout(250, function()
                        LotteryMenu(index)
                    end)
                end
            }
        end
        if #options < 1 then 
            insideMenu = nil
            ShowNotification(_L("insert_none"))
            return LotteryMenu(index)
        end
        lib.registerContext({
            id = 'pickle_lottery_insert',
            title = _L("menu_main_insert"),
            options = options,
            onExit = function() 
                insideMenu = nil
                SetTimeout(250, function()
                    LotteryMenu(index)
                end)
            end
        })
        lib.showContext('pickle_lottery_insert')
    end)
end

function RedeemInventoryMenu(index)
    if insideMenu then return end
    insideMenu = index
    lib.callback("pickle_lottery:getInventory", "", function(result)
        if not result then 
            insideMenu = nil
            SetTimeout(250, function()
                LotteryMenu(index)
            end)
        end
        local tickets = {}
        for i=1, #result do 
            if result[i].name == "lottery_receipt" or result[i].metadata?.game == "scratch" then
                tickets[#tickets + 1] = result[i]
            end
        end 
        local options = {}
        for i=1, #tickets do 
            local label
            local description
            if (tickets[i].name == "lottery_receipt") then
                if tickets[i].metadata?.game == "keno" then
                    label = _L("keno_ticket")
                    local numbers = ""
                    for j=1, #tickets[i].metadata.spots do 
                        if j==1 then 
                            numbers = tickets[i].metadata.spots[j]
                        else
                            numbers = numbers .. ", " .. tickets[i].metadata.spots[j]
                        end
                    end
                    description = _L("redeem_keno", numbers, "#".. tickets[i].metadata?.gameStart .. (tickets[i].metadata?.gameStart == tickets[i].metadata?.gameEnd and "" or ("-" .. tickets[i].metadata?.gameEnd)))
                elseif tickets[i].metadata?.game == "moneyball" then
                    label = _L("moneyball_ticket")
                    local panels = ""
                    for j=1, #tickets[i].metadata.panels do
                        local numbers = ""
                        local panel = tickets[i].metadata.panels[j]
                        if j~=1 then
                            panels = panels .. "\n"
                        end
                        for k=1, #panel-1 do    
                            if k==1 then 
                                numbers = (panel[k] + 1)
                            else
                                numbers = numbers .. ", " .. (panel[k] + 1)
                            end
                        end 
                        panels = panels .. _L("moneyball_numbers", j, numbers, panel[#panel] + 1)
                    end
                    description = _L("redeem_moneyball", panels, "#".. tickets[i].metadata?.gameStart)
                end
            elseif (tickets[i].metadata?.game == "scratch") then
                label = tickets[i].label
                local numbers = ""
                local winningNumbers = ""
                for j=1, #tickets[i].metadata.numbers do 
                    if j==1 then 
                        numbers = tickets[i].metadata.numbers[j]
                    else
                        numbers = numbers .. ", " .. tickets[i].metadata.numbers[j]
                    end
                end
                for j=1, #tickets[i].metadata.winningNumbers do 
                    if j==1 then 
                        winningNumbers = tickets[i].metadata.winningNumbers[j]
                    else
                        winningNumbers = winningNumbers .. ", " .. tickets[i].metadata.winningNumbers[j]
                    end
                end
                description = _L("redeem_scratch", winningNumbers, numbers)
            end
            options[#options + 1] = {
                title = tickets[i].label,
                description = description,
                onSelect = function()
                    insideMenu = nil
                    TriggerServerEvent("pickle_lottery:redeemTicket", index, tickets[i])
                    SetTimeout(250, function()
                        LotteryMenu(index)
                    end)
                end
            }
        end
        if #options < 1 then 
            insideMenu = nil
            ShowNotification(_L("redeem_none"))
            return LotteryMenu(index)
        end
        lib.registerContext({
            id = 'pickle_lottery_redeem',
            title = _L("menu_main_redeem"),
            options = options,
            onExit = function() 
                insideMenu = nil
                SetTimeout(250, function()
                    LotteryMenu(index)
                end)
            end
        })
        lib.showContext('pickle_lottery_redeem')
    end)
end

function LotteryMenu(index)
    if insideMenu then return end
    DisableCamera(true)
    insideMenu = index
    local cfg = Config.Locations[index]
    local store = cfg.store or Config.DefaultStore
    local options = {
        {
            title = _L("menu_main_view_keno"),
            description = _L("menu_main_view_desc"),
            onSelect = function()
                insideMenu = nil
                SetTimeout(250, function()
                    DrawingsMenu("keno", index) 
                end)
            end
        },
        {
            title = _L("menu_main_view_moneyball"),
            description = _L("menu_main_view_desc"),
            onSelect = function()
                insideMenu = nil
                SetTimeout(250, function()
                    DrawingsMenu("moneyball", index) 
                end)
            end
        },
        {
            title = _L("menu_main_purchase"),
            description = _L("menu_main_purchase_desc"),
            onSelect = function()
                insideMenu = nil
                SetTimeout(250, function()
                    PurchaseMenu(index)
                end)
            end
        },
        {
            title = _L("menu_main_insert"),
            description = _L("menu_main_insert_desc"),
            onSelect = function()
                insideMenu = nil
                SetTimeout(250, function()
                    TicketInventoryMenu(index)
                end)
            end
        },
        {
            title = _L("menu_main_redeem"),
            description = _L("menu_main_redeem_desc"),
            onSelect = function()
                insideMenu = nil
                SetTimeout(250, function()
                    RedeemInventoryMenu(index)
                end)
            end
        },
    }
    if #options < 1 then return end
    lib.registerContext({
        id = 'pickle_lottery_main',
        title = store.label,
        options = options,
        onExit = function() 
            insideMenu = nil
            DisableCamera(false)
        end
    })
    lib.showContext('pickle_lottery_main')
end

RegisterNetEvent("pickle_lottery:locationSound", function(index, name)
    if not index or type(index) ~= "number" then return end
    local store = Config.Locations[index]
    if not store or not store.coords then return end
    local coords = GetEntityCoords(PlayerPedId())
    local dist = #(coords - store.coords)
    local radius = store.soundRadius or 10.0
    local volume = 0.5 - ((dist / radius) / 2)
    if volume < 0 then
        volume = 0
    end
    SendNUIMessage({
        type = "playAudio",
        name = name,
        volume = volume
    })
end)

CreateThread(function() 
    for i=1, #Config.Locations do 
        local location = Config.Locations[i]
        if location.blip then
            location.blip.coords = location.coords
            CreateBlip(location.blip)
        end
        interact = CreateInteraction({
            label = _L("interact_lottery"),
            model = location.model,
            coords = location.coords,
            heading = location.heading or 0.0
        }, function(selected)
            LotteryMenu(i)
        end)
    end
end)