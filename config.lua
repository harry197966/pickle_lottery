Config = {}

Config.Debug = false

Config.Language = "en" -- Language to use.

Config.RenderDistance = 100.0 -- Scenario display Radius.

Config.InteractDistance = 2.0 -- Interact Radius

Config.UseTarget = true -- When set to true, it'll use targeting instead of key-presses to interact.

Config.NoModelTargeting = true -- When set to true and using Target, it'll spawn a small invisible prop so you can third-eye when no entity is defined.

Config.Marker = { -- This will only be used if enabled, not using target, and no model is defined in the interaction.
    enabled = true,
    id = 2,
    scale = 0.25, 
    color = {255, 255, 255, 127}
}

Config.DefaultStore = {
    label = "Lottery Store",
    accounts = { -- Percent of purchases 0-100 to each society's account, note that there is no automatic adjustment, so anything that is over 100% will still be that percentage.
        ["police"] = 50, -- 50% cut of purchases.
        ["ambulance"] = 50, -- 50% cut of purchases.
    },
    items = {
        {
            label = "Keno Ticket",
            description = "Fill out the options, save the ticket, then insert it.",
            item = "lottery_keno",
            price = 0 -- This is the price to get a keno slip, should always be free as they only pay when inserting.
        },
        {
            label = "Moneyball Ticket",
            description = "Fill out the options, save the ticket, then insert it.",
            item = "lottery_moneyball",
            price = 0 -- This is the price to get a moneyball slip, should always be free as they only pay when inserting.
        },
        {
            label = "Pickle's Scratch-off",
            item = "lottery_pickle",
            description = "Scratch-off the ticket and redeem it for your prize!",
            price = 2
        },
        {
            label = "Wild Cherry Scratch-off",
            item = "lottery_wildcherry",
            description = "Scratch-off the ticket and redeem it for your prize!",
            price = 5
        },
        {
            label = "Lucky 7's Scratch-off",
            item = "lottery_luckyseven",
            description = "Scratch-off the ticket and redeem it for your prize!",
            price = 10
        },
    }
}

Config.Locations = {
    {
        coords = vector3(34.1786, -1343.2672, 29.4970), -- Strawberry 24/7
        heading = -90.3685,
        blip = { label = "Lottery", id = 500, display = 4, scale = 0.5, color = 2 },
        model = {modelType = "prop", hash = `prop_park_ticket_01`},
        store = {
            label = "Lottery Store",
            accounts = { -- Percent of purchases 0-100 to each society's account, note that there is no automatic adjustment, so anything that is over 100% will still be that percentage.
                ["police"] = 50, -- 50% cut of purchases.
                ["ambulance"] = 50, -- 50% cut of purchases.
            },
            items = {
                {
                    label = "Keno Ticket",
                    description = "Fill out the options, save the ticket, then insert it.",
                    item = "lottery_keno",
                    price = 0 -- This is the price to get a keno slip, should always be free as they only pay when inserting.
                },
                {
                    label = "Moneyball Ticket",
                    description = "Fill out the options, save the ticket, then insert it.",
                    item = "lottery_moneyball",
                    price = 0 -- This is the price to get a moneyball slip, should always be free as they only pay when inserting.
                },
                {
                    label = "Pickle's Scratch-off",
                    item = "lottery_pickle",
                    description = "Scratch-off the ticket and redeem it for your prize!",
                    price = 2
                },
                {
                    label = "Wild Cherry Scratch-off",
                    item = "lottery_wildcherry",
                    description = "Scratch-off the ticket and redeem it for your prize!",
                    price = 5
                },
                {
                    label = "Lucky 7's Scratch-off",
                    item = "lottery_luckyseven",
                    description = "Scratch-off the ticket and redeem it for your prize!",
                    price = 10
                },
            }
        }
    },
    {
        coords = vector3(920.2538, 40.0376, 81.0959), -- Casino
        heading = 237.4434,
        blip = { label = "Lottery", id = 500, display = 4, scale = 0.5, color = 2 },
        model = {modelType = "prop", hash = `prop_park_ticket_01`},
        store = {
            label = "Lottery Store",
            accounts = { -- Percent of purchases 0-100 to each society's account, note that there is no automatic adjustment, so anything that is over 100% will still be that percentage.
                ["police"] = 50, -- 50% cut of purchases.
                ["ambulance"] = 50, -- 50% cut of purchases.
            },
            items = {
                {
                    label = "Keno Ticket",
                    description = "Fill out the options, save the ticket, then insert it.",
                    item = "lottery_keno",
                    price = 0 -- This is the price to get a keno slip, should always be free as they only pay when inserting.
                },
                {
                    label = "Moneyball Ticket",
                    description = "Fill out the options, save the ticket, then insert it.",
                    item = "lottery_moneyball",
                    price = 0 -- This is the price to get a moneyball slip, should always be free as they only pay when inserting.
                },
                {
                    label = "Pickle's Scratch-off",
                    item = "lottery_pickle",
                    description = "Scratch-off the ticket and redeem it for your prize!",
                    price = 2
                },
                {
                    label = "Wild Cherry Scratch-off",
                    item = "lottery_wildcherry",
                    description = "Scratch-off the ticket and redeem it for your prize!",
                    price = 5
                },
                {
                    label = "Lucky 7's Scratch-off",
                    item = "lottery_luckyseven",
                    description = "Scratch-off the ticket and redeem it for your prize!",
                    price = 10
                },
            }
        }
    },
    {
        coords = vector3(-49.2994, -1760.2704, 29.4396), -- LTD Gas Station Grove
        heading = 318.6361,
        blip = { label = "Lottery", id = 500, display = 4, scale = 0.5, color = 2 },
        model = {modelType = "prop", hash = `prop_park_ticket_01`},
        store = {
            label = "Lottery Store",
            accounts = { -- Percent of purchases 0-100 to each society's account, note that there is no automatic adjustment, so anything that is over 100% will still be that percentage.
                ["police"] = 50, -- 50% cut of purchases.
                ["ambulance"] = 50, -- 50% cut of purchases.
            },
            items = {
                {
                    label = "Keno Ticket",
                    description = "Fill out the options, save the ticket, then insert it.",
                    item = "lottery_keno",
                    price = 0 -- This is the price to get a keno slip, should always be free as they only pay when inserting.
                },
                {
                    label = "Moneyball Ticket",
                    description = "Fill out the options, save the ticket, then insert it.",
                    item = "lottery_moneyball",
                    price = 0 -- This is the price to get a moneyball slip, should always be free as they only pay when inserting.
                },
                {
                    label = "Pickle's Scratch-off",
                    item = "lottery_pickle",
                    description = "Scratch-off the ticket and redeem it for your prize!",
                    price = 2
                },
                {
                    label = "Wild Cherry Scratch-off",
                    item = "lottery_wildcherry",
                    description = "Scratch-off the ticket and redeem it for your prize!",
                    price = 5
                },
                {
                    label = "Lucky 7's Scratch-off",
                    item = "lottery_luckyseven",
                    description = "Scratch-off the ticket and redeem it for your prize!",
                    price = 10
                },
            }
        }
    },
    {
        coords = vector3(-707.8763, -917.1802, 19.2143), -- LTD Gas Station Little Seoul
        heading = 358.3544,
        blip = { label = "Lottery", id = 500, display = 4, scale = 0.5, color = 2 },
        model = {modelType = "prop", hash = `prop_park_ticket_01`},
        store = {
            label = "Lottery Store",
            accounts = { -- Percent of purchases 0-100 to each society's account, note that there is no automatic adjustment, so anything that is over 100% will still be that percentage.
                ["police"] = 50, -- 50% cut of purchases.
                ["ambulance"] = 50, -- 50% cut of purchases.
            },
            items = {
                {
                    label = "Keno Ticket",
                    description = "Fill out the options, save the ticket, then insert it.",
                    item = "lottery_keno",
                    price = 0 -- This is the price to get a keno slip, should always be free as they only pay when inserting.
                },
                {
                    label = "Moneyball Ticket",
                    description = "Fill out the options, save the ticket, then insert it.",
                    item = "lottery_moneyball",
                    price = 0 -- This is the price to get a moneyball slip, should always be free as they only pay when inserting.
                },
                {
                    label = "Pickle's Scratch-off",
                    item = "lottery_pickle",
                    description = "Scratch-off the ticket and redeem it for your prize!",
                    price = 2
                },
                {
                    label = "Wild Cherry Scratch-off",
                    item = "lottery_wildcherry",
                    description = "Scratch-off the ticket and redeem it for your prize!",
                    price = 5
                },
                {
                    label = "Lucky 7's Scratch-off",
                    item = "lottery_luckyseven",
                    description = "Scratch-off the ticket and redeem it for your prize!",
                    price = 10
                },
            }
        }
    },
    {
        coords = vector3(1163.5985, -326.5771, 69.2379), -- LTD Gas Station Mirror Park
        heading = 10.6814,
        blip = { label = "Lottery", id = 500, display = 4, scale = 0.5, color = 2 },
        model = {modelType = "prop", hash = `prop_park_ticket_01`},
        store = {
            label = "Lottery Store",
            accounts = { -- Percent of purchases 0-100 to each society's account, note that there is no automatic adjustment, so anything that is over 100% will still be that percentage.
                ["police"] = 50, -- 50% cut of purchases.
                ["ambulance"] = 50, -- 50% cut of purchases.
            },
            items = {
                {
                    label = "Keno Ticket",
                    description = "Fill out the options, save the ticket, then insert it.",
                    item = "lottery_keno",
                    price = 0 -- This is the price to get a keno slip, should always be free as they only pay when inserting.
                },
                {
                    label = "Moneyball Ticket",
                    description = "Fill out the options, save the ticket, then insert it.",
                    item = "lottery_moneyball",
                    price = 0 -- This is the price to get a moneyball slip, should always be free as they only pay when inserting.
                },
                {
                    label = "Pickle's Scratch-off",
                    item = "lottery_pickle",
                    description = "Scratch-off the ticket and redeem it for your prize!",
                    price = 2
                },
                {
                    label = "Wild Cherry Scratch-off",
                    item = "lottery_wildcherry",
                    description = "Scratch-off the ticket and redeem it for your prize!",
                    price = 5
                },
                {
                    label = "Lucky 7's Scratch-off",
                    item = "lottery_luckyseven",
                    description = "Scratch-off the ticket and redeem it for your prize!",
                    price = 10
                },
            }
        }
    },
}

Config.Lottery = {
    redeemExpiration = 7, -- How many days a ticket can be unclaimed before deletion.
    dateFormat = "%m/%d/%Y %I:%M %p", -- Check https://www.lua.org/pil/22.1.html for more information.
    canSocietyLose = false, -- Remove money from society when a player wins.
    -- Which resource handles society / job bank accounts on QBCore-family
    -- servers. 'auto' picks the first one of these that's started, in this
    -- order: Renewed-Banking, qb-banking, qb-management. Set to one of those
    -- strings to force a specific resource (e.g. you run two and want to
    -- override the autodetect), or 'none' to disable society payouts.
    societyResource = 'auto',
}

Config.Items = {
    -- You may modify and add to these.
    ["lottery_pickle"] = {
        game = "scratch",
        image = "pickle.png",
        numbers = {
            rows = 3, -- Amount of rows.
            eachRow = 3, -- Amount of numbers to place on each row. (rows multiplied by count is the amount of numbers)
            range = {1, 45} -- Range of numbers randomized for each number. The max range must be larger than the total numbers.
        },
        prizes = {2, 4,  8, 16, 32, 1000000}, -- Index = Numbers Matched (1 Number = $2, 6 Numbers = $1 Million)
    },
    ["lottery_wildcherry"] = {
        game = "scratch",
        image = "wildcherry.png",
        numbers = {
            rows = 4, -- Amount of rows.
            eachRow = 6, -- Amount of numbers to place on each row. (rows multiplied by count is the amount of numbers)
            range = {1, 65} -- Range of numbers randomized for each number. The max range must be larger than the total numbers.
        },
        prizes = {3, 6, 12, 24, 48, 2000000}, -- Index = Numbers Matched (1 Number = $2, 6 Numbers = $1 Million)
    },
    ["lottery_luckyseven"] = {
        game = "scratch",
        image = "luckyseven.png",
        numbers = {
            rows = 4, -- Amount of rows.
            eachRow = 6, -- Amount of numbers to place on each row. (rows multiplied by count is the amount of numbers)
            range = {1, 80} -- Range of numbers randomized for each number. The max range must be larger than the total numbers.
        },
        prizes = {4, 8, 16, 32, 64, 4000000}, -- Index = Numbers Matched (1 Number = $2, 6 Numbers = $1 Million)
    },
    -- Do not remove or modify these three unless you're an expert, you do this at your own risk.
    ["lottery_keno"] = {
        game = "keno"
    },
    ["lottery_moneyball"] = {
        game = "moneyball"
    },
    ["lottery_receipt"] = {
        game = "receipt"
    }
}

Config.Games = { -- Do not remove any of these, these are not optional. To disable the game, just remove it from the stores.
    ["keno"] = {
        prizes = { -- 0-12 Spot Match, follow the below template for prizes.
            {0, 3},
            {0, 1, 5},
            {0, 0, 3, 25},
            {0, 0, 1, 4, 100},
            {0, 0, 0, 2, 20, 450},
            {0, 0, 0, 1, 7, 50, 1600},
            {0, 0, 0, 1, 3, 20, 100, 5000},
            {0, 0, 0, 0, 2, 10, 50, 1000, 15000},
            {0, 0, 0, 0, 1, 5, 25, 200, 4000, 40000},
            {2, 0, 0, 0, 0, 2, 20, 80, 500, 10000, 100000},
            {2, 0, 0, 0, 0, 1, 10, 50, 250, 1500, 15000, 500000},
            {4, 0, 0, 0, 0, 0, 5, 25, 150, 1000, 2500, 25000, 1000000},
        },
        drawCount = 20, -- 20 Balls are drawn
        ballCount = 80, -- 1-80 are selectable numbers.
        wagers = {1, 5, 10, 20, 30}, -- Wager selection for each game.
        games = {1, 5, 10, 20, 30}, -- Game selection for how many games to play.
        drawingFrequency = "*/1 * * * * *", -- How often to draw a new game (Default: Every 5 Minutes, generate a frequency here: https://www.freeformatter.com/cron-expression-generator-quartz.html)
    },
    ["moneyball"] = {
        prizes = {10, 50, 100, 20000, 100000, 1000000}, -- Prizes Template (1 - 5 + moneyball)
        panelCount = 4, -- Max amount of panels you can play.
        ballCount = 70, -- Max Number for ball selection.
        moneyballCount = 21, -- Max Number for Moneyball selection.
        price = 1, -- Price for each panel played.
        games = {1, 5, 10, 20, 30}, -- Game selection for how many games to play.
        drawingFrequency = "*/1 * * * * *", -- How often to draw a new game (Default: Every 5 Minutes, generate a frequency here: https://www.freeformatter.com/cron-expression-generator-quartz.html)
    },
}