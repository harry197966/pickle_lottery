local Games = {
    keno = {
        game_id = 0,
        games = {},
    },
    moneyball = {
        game_id = 0,
        games = {},
    }
}

local activeRedemptions = {}

function GiveReceipt(source, ticket)
    local data = ticket
    if data.game == "keno" then 
        local game = Config.Games[data.game]
        data.wager = game.wagers[data.wager]
        data.games = game.games[data.games]
        data.gameStart = Games.keno.game_id + 1
        data.gameEnd = data.gameStart + (data.games - 1)
    elseif data.game == "moneyball" then
        local game = Config.Games[data.game]
        data.gameStart = Games.moneyball.game_id + 1
    else
        return
    end
    data.date = os.date(Config.Lottery.dateFormat)
    MySQL.Async.insert("INSERT INTO lottery_receipts (type, data) VALUES (@type, @data);", {
        ["@type"] = data.game,
        ["@data"] = json.encode(data)
    }, function(id)
        data.id = id
        Inventory.AddItem(source, "lottery_receipt", 1, data)
    end)
end

function GetUniqueNumber(range, data)
    if not range or not range[1] or not range[2] or range[1] > range[2] then return nil end
    local maxPossible = range[2] - range[1] + 1
    if data and #data >= maxPossible then return nil end
    for attempt = 1, 1000 do 
        local num = math.random(range[1], range[2])
        local found = false
        if data then
            for j=1, #data do 
                if data[j] == num then 
                    found = true
                    break
                end
            end
        end
        if not found then
            return num
        end
    end
    for num = range[1], range[2] do
        local found = false
        if data then
            for j=1, #data do
                if data[j] == num then
                    found = true
                    break
                end
            end
        end
        if not found then
            return num
        end
    end
    return nil
end

function GenerateScratchoff(source, item)
    local cfg = Config.Items[item]
    if not cfg or cfg.game ~= "scratch" then return end
    local ticket = {
        item = item,
        game = "scratch",
        winningNumbers = {},
        numbers = {},
        background = cfg.image,
        prizes = cfg.prizes,
        eachRow = cfg.numbers.eachRow
    }
    for i=1, #cfg.prizes do 
        local num = GetUniqueNumber(cfg.numbers.range, ticket.winningNumbers)
        if num then
            ticket.winningNumbers[i] = num
        end
    end
    table.sort(ticket.winningNumbers, function(num, num2)
        return num < num2
    end)
    for i=1, (cfg.numbers.rows * cfg.numbers.eachRow) do 
        local num = GetUniqueNumber(cfg.numbers.range, ticket.numbers)
        if num then
            ticket.numbers[i] = num
        end
    end
    MySQL.Async.insert("INSERT INTO lottery_receipts (type, data) VALUES (@type, @data);", {
        ["@type"] = "scratch",
        ["@data"] = json.encode(ticket)
    }, function(id)
        ticket.id = id
        Inventory.AddItem(source, item, 1, ticket)
    end)
end

function GetLotteryNumbers(game) 
    local cfg = Config.Games[game]
    if not cfg then return end
    local numbers = {}
    local range = {1, cfg.ballCount}
    local amount
    local extraNumber
    if game == "keno" then
        amount = cfg.drawCount
    elseif game == "moneyball" then
        amount = #cfg.prizes - 1
        extraNumber = math.random(1, cfg.moneyballCount)
    end
    for i=1, amount do
        local num = GetUniqueNumber(range, numbers)
        if num then
            numbers[#numbers + 1] = num
        end
    end
    table.sort(numbers, function(num, num2)
        return num < num2
    end)
    if extraNumber then 
        numbers[#numbers + 1] = extraNumber
    end
    return numbers
end

function GenerateGame(game)
    local data = {
        date = os.date(Config.Lottery.dateFormat),
        numbers = GetLotteryNumbers(game)
    } 
    if game == "keno" then
        MySQL.Async.insert("INSERT INTO lottery_keno (numbers, receipts) VALUES (@numbers, @receipts);", {
            ["@numbers"] = json.encode(data.numbers),
            ["@receipts"] = json.encode({})
        }, function(game_id)
            data.id = game_id
            Games[game].game_id = game_id
            Games[game].games[game_id] = data
            local gameCount = 0
            local lowest
            for k,v in pairs(Games[game].games) do
                if not lowest or k < lowest then
                    lowest = k 
                end 
                gameCount = gameCount + 1
            end
            if lowest and gameCount > 10 then
                Games[game].games[lowest] = nil
            end
            MySQL.Async.fetchAll("SELECT * FROM lottery_receipts WHERE type=@type", {
                ["@type"] = "keno"
            }, function(results)
                local receipts = {}
                for i=1, #results do 
                    local receipt = json.decode(results[i].data)
                    if (receipt and receipt.gameStart and receipt.gameEnd and receipt.gameStart <= game_id and receipt.gameEnd >= game_id) then
                        receipts[#receipts + 1] = results[i].id
                    end
                end
                MySQL.Async.execute("UPDATE lottery_keno SET receipts=@receipts WHERE id=@id", {
                    ["@id"] = game_id,
                    ["@receipts"] = json.encode(receipts)
                })
            end)
            if Discord and Discord.Drawings and Discord.Drawings.enabled and Discord.Drawings.webhook and Discord.Drawings.webhook ~= "WEBHOOK_HERE" then
                local numbers = ""
                for i=1, #data.numbers - 1 do 
                    local num = data.numbers[i]
                    if i ~= #data.numbers - 1 then
                        num = num .. ", "
                    end
                    numbers = numbers .. num
                end
                DiscordNotify("keno_notify", {
                    id = data.id,
                    numbers = numbers
                })
            end
        end)
    elseif game == "moneyball" then 
        MySQL.Async.insert("INSERT INTO lottery_moneyball (numbers, receipts) VALUES (@numbers, @receipts);", {
            ["@numbers"] = json.encode(data.numbers),
            ["@receipts"] = json.encode({})
        }, function(game_id)
            data.id = game_id
            Games[game].game_id = game_id
            Games[game].games[game_id] = data
            local gameCount = 0
            local lowest
            for k,v in pairs(Games[game].games) do
                if not lowest or k < lowest then
                    lowest = k 
                end 
                gameCount = gameCount + 1
            end
            if lowest and gameCount > 10 then
                Games[game].games[lowest] = nil
            end
            MySQL.Async.fetchAll("SELECT * FROM lottery_receipts WHERE type=@type", {
                ["@type"] = "moneyball"
            }, function(results)
                local receipts = {}
                for i=1, #results do 
                    local receipt = json.decode(results[i].data)
                    if (receipt and receipt.gameStart and receipt.gameStart == game_id) then
                        receipts[#receipts + 1] = results[i].id
                    end
                end
                MySQL.Async.execute("UPDATE lottery_moneyball SET receipts=@receipts WHERE id=@id", {
                    ["@id"] = game_id,
                    ["@receipts"] = json.encode(receipts)
                })
            end)
            if Discord and Discord.Drawings and Discord.Drawings.enabled and Discord.Drawings.webhook and Discord.Drawings.webhook ~= "WEBHOOK_HERE" then
                local moneyball = data.numbers[#data.numbers]
                local numbers = ""
                for i=1, #data.numbers - 1 do 
                    local num = data.numbers[i]
                    if i ~= #data.numbers - 1 then
                        num = num .. ", "
                    end
                    numbers = numbers .. num
                end
                DiscordNotify("moneyball_notify", {
                    id = data.id,
                    numbers = numbers,
                    moneyball = moneyball
                })
            end
        end)
    end
end

function WinnerEvent(source, index, prize)
    local playerName = GetPlayerName(source)
    if not playerName then return end
    ShowNotification(source, _L("redeem_won", prize))
    AddMoney(source, prize)
    if index and type(index) == "number" and Config.Locations[index] then
        TriggerClientEvent("pickle_lottery:locationSound", -1, index, "winner")
        if Config.Lottery.canSocietyLose then
            local cfg = Config.Locations[index]
            local store = cfg.store or Config.DefaultStore
            if store and store.accounts then
                for k,v in pairs(store.accounts) do 
                    RemoveSocietyMoney(k, prize * (v * 0.01))
                end
            end
        end
    end

    if Discord and Discord.Drawings and Discord.Drawings.enabled and Discord.Drawings.webhook and Discord.Drawings.webhook ~= "WEBHOOK_HERE" then
        DiscordNotify("winner_notify", {
            playerName = playerName,
            prize = prize
        })
    end
end

function DiscordNotify(notifyType, args)
    if not Discord or not Discord.Drawings or not Discord.Drawings.enabled or not Discord.Drawings.webhook or Discord.Drawings.webhook == "WEBHOOK_HERE" then return end
    local title, description = "", ""
    if notifyType == "keno_notify" then
        title = _L("discord_keno_drawing_title")
        description = _L("discord_keno_drawing_desc", args.id, args.numbers)
    elseif notifyType == "moneyball_notify" then
        title = _L("discord_moneyball_drawing_title")
        description = _L("discord_moneyball_drawing_desc", args.id, args.numbers, args.moneyball)
    end
    PerformHttpRequest(Discord.Drawings.webhook, function(err, text, headers)
    end, 'POST', json.encode({
        username = Discord.Username, 
        avatar_url = Discord.AvatarURL, 
        embeds = {
        {
            ["color"] = 0,
            ["title"] = title, 
            ["description"] = description,
            ["footer"] ={
                ["text"] = os.date("%c"),
            },
        }
    }}), { ['Content-Type']= 'application/json' })
end

RegisterUsableItem("lottery_keno", function(source, item, data) 
    TriggerClientEvent("pickle_lottery:interactItem", source, "lottery_keno", data)
end)

RegisterUsableItem("lottery_moneyball", function(source, item, data) 
    TriggerClientEvent("pickle_lottery:interactItem", source, "lottery_moneyball", data)
end)

for k,v in pairs(Config.Items) do 
    if v.game == "scratch" then 
        RegisterUsableItem(k, function(source, item, data) 
            TriggerClientEvent("pickle_lottery:interactItem", source, k, data)
            if data and data.metadata and data.slot then
                data.metadata.scratched = true
                Inventory.SetMetadata(source, data.slot, data.metadata)
            end
        end)    
    end
end 

RegisterUsableItem("lottery_receipt", function(source, item, data) 
    TriggerClientEvent("pickle_lottery:interactItem", source, "lottery_receipt", data)
end)

RegisterNetEvent("pickle_lottery:saveTicket", function(ticket, itemData)
    local source = source
    if not source or source <= 0 then return end
    if type(itemData) ~= "table" or type(itemData.slot) ~= "number" then return end
    if type(ticket) ~= "table" or type(ticket.game) ~= "string" then return end

    -- Verify player actually owns a blank/fillable ticket in this slot (FIVEM-SEC-002)
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

    local safeTicket = {}
    if serverItem.name == "lottery_keno" and ticket.game == "keno" then
        local cfg = Config.Games.keno
        if type(ticket.wager) ~= "number" or not cfg.wagers[ticket.wager] then return end
        if type(ticket.games) ~= "number" or not cfg.games[ticket.games] then return end
        if type(ticket.spots) ~= "table" or #ticket.spots < 1 or #ticket.spots > #cfg.prizes then return end
        
        local spots = {}
        local seen = {}
        for i=1, #ticket.spots do
            local spot = ticket.spots[i]
            if type(spot) ~= "number" or spot < 1 or spot > cfg.ballCount or seen[spot] then
                return
            end
            seen[spot] = true
            spots[#spots + 1] = spot
        end
        safeTicket = {
            game = "keno",
            spots = spots,
            wager = ticket.wager,
            games = ticket.games
        }
    elseif serverItem.name == "lottery_moneyball" and ticket.game == "moneyball" then
        local cfg = Config.Games.moneyball
        if type(ticket.panels) ~= "table" or #ticket.panels < 1 or #ticket.panels > cfg.panelCount then return end

        local panels = {}
        for i=1, #ticket.panels do
            local panel = ticket.panels[i]
            local reqCount = #cfg.prizes
            if type(panel) ~= "table" or #panel ~= reqCount then return end
            
            local cleanPanel = {}
            local seen = {}
            for j=1, reqCount - 1 do
                local num = panel[j]
                if type(num) ~= "number" or num < 0 or num >= cfg.ballCount or seen[num] then
                    return
                end
                seen[num] = true
                cleanPanel[#cleanPanel + 1] = num
            end
            local mb = panel[reqCount]
            if type(mb) ~= "number" or mb < 0 or mb >= cfg.moneyballCount then
                return
            end
            cleanPanel[#cleanPanel + 1] = mb
            panels[#panels + 1] = cleanPanel
        end
        safeTicket = {
            game = "moneyball",
            panels = panels,
            price = cfg.price
        }
    else
        return
    end

    Inventory.SetMetadata(source, serverItem.slot, safeTicket)
end)

RegisterNetEvent("pickle_lottery:redeemTicket", function(index, itemData)
    local source = source
    if not source or source <= 0 then return end

    -- Proximity validation (FIVEM-SEC-006)
    if not index or type(index) ~= "number" or not Config.Locations[index] then return end
    local ped = GetPlayerPed(source)
    if not ped or ped == 0 then return end
    local pcoords = GetEntityCoords(ped)
    if #(pcoords - Config.Locations[index].coords) > 10.0 then return end

    -- Server-authoritative inventory check (FIVEM-SEC-001)
    if type(itemData) ~= "table" or type(itemData.slot) ~= "number" then return end
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

    local isReceipt = (serverItem.name == "lottery_receipt")
    local isScratch = (Config.Items[serverItem.name] and Config.Items[serverItem.name].game == "scratch")
    if not isReceipt and not isScratch then return end

    local meta = serverItem.metadata
    if not meta or type(meta) ~= "table" then return end
    local receipt_id = meta.id
    if not receipt_id or type(receipt_id) ~= "number" then return end

    -- Concurrency lock per receipt_id to prevent duplicate redemption (FIVEM-SEC-003)
    local lockKey = receipt_id
    if activeRedemptions[lockKey] then return end
    activeRedemptions[lockKey] = true

    local function unlock()
        activeRedemptions[lockKey] = nil
    end

    if meta.game == "keno" and isReceipt then
        local numbers = meta.spots
        if type(numbers) ~= "table" or type(meta.gameStart) ~= "number" or type(meta.gameEnd) ~= "number" then
            unlock()
            return
        end
        MySQL.Async.fetchAll("SELECT * FROM lottery_keno WHERE id >= @gameStart AND id <= @gameEnd;", {
            ["@gameStart"] = meta.gameStart,
            ["@gameEnd"] = meta.gameEnd,
        }, function(results)
            local redeemGames = {}
            local prize = 0
            local maxResult
            for i=1, #results do 
                local receipts = json.decode(results[i].receipts or "[]")
                for j=1, #receipts do 
                    if receipts[j] == receipt_id then
                        redeemGames[#redeemGames + 1] = results[i] 
                        break
                    end
                end
                if not maxResult or results[i].id > maxResult then
                    maxResult = results[i].id
                end
            end
            for i=1, #redeemGames do 
                local game = redeemGames[i]
                local ticketNumbers = json.decode(game.numbers or "[]")
                local spots = 0
                for j=1, #ticketNumbers do 
                    local number = ticketNumbers[j]
                    for k=1, #numbers do 
                        if numbers[k] == number then
                            spots = spots + 1
                            break
                        end
                    end 
                end
                local prizeList = Config.Games.keno.prizes[#numbers]
                if prizeList then
                    local cash = prizeList[spots + 1]
                    if cash then
                        prize = prize + cash
                    end
                end
                local receipts = json.decode(game.receipts or "[]")
                local newReceipts = {}
                for j=1, #receipts do
                    if receipts[j] ~= receipt_id then
                        newReceipts[#newReceipts + 1] = receipts[j]
                    end                    
                end
                MySQL.Async.execute("UPDATE lottery_keno SET receipts=@receipts WHERE id=@id;", {
                    ["@id"] = game.id,
                    ["@receipts"] = json.encode(newReceipts)
                })
            end

            if prize > 0 then
                MySQL.Async.fetchAll("SELECT * FROM lottery_receipts WHERE id=@id;", {
                    ["@id"] = receipt_id,
                }, function(receiptResults)
                    if #receiptResults >= 1 then
                        local recData = json.decode(receiptResults[1].data)
                        local wagerMultiplier = (recData and recData.wager) or 1
                        -- Fixed bug: results[1] instead of out-of-scope results[i] (FIVEM-SEC-009)
                        WinnerEvent(source, index, prize * wagerMultiplier)
                    end
                end)
            else
                ShowNotification(source, _L("redeem_lost"))
            end

            if maxResult == meta.gameEnd then -- Max Games reached
                Inventory.RemoveItem(source, serverItem.name, 1, serverItem.slot)
                MySQL.Async.execute("DELETE FROM lottery_receipts WHERE id=@id;", {
                    ["@id"] = receipt_id
                })
                ShowNotification(source, _L("redeem_games_none"))
            else
                ShowNotification(source, _L("redeem_games_more"))
            end
            unlock()
        end)
    elseif meta.game == "moneyball" and isReceipt then
        if type(meta.gameStart) ~= "number" or type(meta.panels) ~= "table" then
            unlock()
            return
        end
        MySQL.Async.fetchAll("SELECT * FROM lottery_moneyball WHERE id=@gameStart;", {
            ["@gameStart"] = meta.gameStart,
        }, function(results)
            local game = results[1]
            if not game then 
                ShowNotification(source, _L("redeem_games_more"))
                unlock()
                return
            end
            local receipts = json.decode(game.receipts or "[]")
            local foundReceipt = false
            for j=1, #receipts do 
                if receipts[j] == receipt_id then
                    foundReceipt = true
                    break
                end
            end
            if not foundReceipt then
                unlock()
                return
            end

            -- Remove item before paying prize (FIVEM-SEC-010)
            Inventory.RemoveItem(source, serverItem.name, 1, serverItem.slot)

            local panels = meta.panels
            local prize = 0
            local ticketNumbers = json.decode(game.numbers or "[]")
            for i=1, #panels do
                local numbers = panels[i]
                local spots = 0
                local moneyball = (numbers[#numbers] == ticketNumbers[#ticketNumbers])
                for j=1, #ticketNumbers - 1 do 
                    local number = ticketNumbers[j]
                    for k=1, #numbers - 1 do 
                        if numbers[k] == number then
                            spots = spots + 1
                            break
                        end
                    end 
                end
                if spots == (#ticketNumbers - 1) and moneyball then
                    spots = #ticketNumbers
                end
                local cash = (spots > 0 and Config.Games.moneyball.prizes[spots] or 0)
                if cash then
                    prize = prize + cash
                end
            end
            local newReceipts = {}
            for j=1, #receipts do
                if receipts[j] ~= receipt_id then
                    newReceipts[#newReceipts + 1] = receipts[j]
                end                    
            end
            MySQL.Async.execute("UPDATE lottery_moneyball SET receipts=@receipts WHERE id=@id;", {
                ["@id"] = game.id,
                ["@receipts"] = json.encode(newReceipts)
            })
            MySQL.Async.execute("DELETE FROM lottery_receipts WHERE id=@id;", {
                ["@id"] = receipt_id
            })
            if prize > 0 then
                WinnerEvent(source, index, prize)
            else
                ShowNotification(source, _L("redeem_lost"))
            end
            unlock()
        end)
    elseif isScratch then
        MySQL.Async.fetchAll("SELECT * FROM lottery_receipts WHERE id=@id AND type='scratch';", {
            ["@id"] = receipt_id,
        }, function(results)
            if #results < 1 then
                unlock()
                return
            end

            -- Remove item before paying prize (FIVEM-SEC-010)
            Inventory.RemoveItem(source, serverItem.name, 1, serverItem.slot)

            local game = json.decode(results[1].data or "{}")
            local numbers = game.numbers or {}
            local ticketNumbers = game.winningNumbers or {}
            local spots = 0
            for j=1, #ticketNumbers do 
                local number = ticketNumbers[j]
                for k=1, #numbers do 
                    if numbers[k] == number then
                        spots = spots + 1
                        break
                    end
                end 
            end
            -- Read prizes from Config.Items using server-authoritative item definition (FIVEM-SEC-004)
            local itemCfg = Config.Items[serverItem.name]
            local prizeTable = itemCfg and itemCfg.prizes or game.prizes
            local prize = (spots > 0 and prizeTable and prizeTable[spots] or 0)

            MySQL.Async.execute("DELETE FROM lottery_receipts WHERE id=@id;", {
                ["@id"] = results[1].id
            })
            if prize > 0 then
                WinnerEvent(source, index, prize)
            else
                ShowNotification(source, _L("redeem_lost"))
            end
            unlock()
        end)
    else
        unlock()
    end
end)

lib.callback.register("pickle_lottery:getDrawings", function(source, name)
    if name ~= "keno" and name ~= "moneyball" then return end
    local data = Games[name]
    local games = {}
    for k,v in pairs(data.games) do 
        games[#games + 1] = v
    end
    table.sort(games, function(t1, t2)
        return t1.id > t2.id
    end)
    return data.game_id, games 
end)

lib.cron.new(Config.Games.keno.drawingFrequency, function()
    GenerateGame("keno")
end)

lib.cron.new(Config.Games.moneyball.drawingFrequency, function()
    GenerateGame("moneyball")
end)

MySQL.ready(function()
    MySQL.Async.fetchAll("SELECT * FROM lottery_keno ORDER BY id DESC;", {}, function(results)
        if #results > 0 then
            Games.keno.game_id = results[1].id
        end
        for i=1, #results do 
            local time = math.ceil(results[i].date / 1000)
            if i <= 10 then
                local date = os.date(Config.Lottery.dateFormat, time)
                Games.keno.games[results[i].id] = {
                    id = results[i].id,
                    date = date,
                    numbers = json.decode(results[i].numbers)
                }
            else
                local receipts = json.decode(results[i].receipts)
                if not receipts or #receipts < 1 then
                    MySQL.Async.execute("DELETE FROM lottery_keno WHERE id=@id", {["@id"] = results[i].id})
                elseif receipts then
                    if (time - os.time()) > (Config.Lottery.redeemExpiration * (60 * 60 * 24)) then -- Ticket expired.
                        MySQL.Async.execute("DELETE FROM lottery_keno WHERE id=@id", {["@id"] = results[i].id})
                        for i=1, #receipts do 
                            MySQL.Async.execute("DELETE FROM lottery_receipts WHERE id=@id", {["@id"] = receipts[i]})
                        end
                    end
                end
            end
        end
    end)
    MySQL.Async.fetchAll("SELECT * FROM lottery_moneyball ORDER BY id DESC;", {}, function(results)
        if #results > 0 then
            Games.moneyball.game_id = results[1].id
        end
        for i=1, #results do 
            local time = math.ceil(results[i].date / 1000)
            if i <= 10 then
                local date = os.date(Config.Lottery.dateFormat, time)
                Games.moneyball.games[results[i].id] = {
                    id = results[i].id,
                    date = date,
                    numbers = json.decode(results[i].numbers)
                }
            else
                local receipts = json.decode(results[i].receipts)
                if not receipts or #receipts < 1 then
                    MySQL.Async.execute("DELETE FROM lottery_moneyball WHERE id=@id", {["@id"] = results[i].id})
                elseif receipts then
                    if (time - os.time()) > (Config.Lottery.redeemExpiration * (60 * 60 * 24)) then -- Ticket expired.
                        MySQL.Async.execute("DELETE FROM lottery_moneyball WHERE id=@id", {["@id"] = results[i].id})
                        for i=1, #receipts do 
                            MySQL.Async.execute("DELETE FROM lottery_receipts WHERE id=@id", {["@id"] = receipts[i]})
                        end
                    end
                end
            end
        end
    end)
end)

-- Restrict /keno command to authorized personnel (FIVEM-SEC-005)
RegisterCommand("keno", function(source, args)
    if source ~= 0 then
        if not IsPlayerAceAllowed(source, "pickle_lottery.admin") and not CheckPermission(source, {jobs = {}, groups = {"admin", "god"}}) then
            return ShowNotification(source, "You do not have permission to force a drawing.")
        end
    end
    GenerateGame("keno")
end, true)
