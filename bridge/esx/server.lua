if GetResourceState('es_extended') ~= 'started' then return end

ESX = exports.es_extended:getSharedObject()

function RegisterUsableItem(name, cb)
    ESX.RegisterUsableItem(name, function(source, item, data) 
        if Config and Config.Debug then
            print("VARS: ", source, item, data)
        end
        local itemData = data
        if type(item) == "table" then
            itemData = item
        end
        if itemData and itemData.info then
            itemData.metadata = itemData.info
            itemData.info = nil
        end
        if cb then
            cb(source, item, itemData)
        else
            TriggerClientEvent("pickle_lottery:interactItem", source, name, itemData)
        end
    end)
end

function ShowNotification(target, text)
	TriggerClientEvent(GetCurrentResourceName()..":showNotification", target, text)
end

function GetIdentifier(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    return xPlayer and xPlayer.identifier or nil
end

function SetPlayerMetadata(source, key, data)
    -- No player metadata in ESX.
end

function AddMoney(source, count)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        xPlayer.addMoney(count)
    end
end

function RemoveMoney(source, count)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        xPlayer.removeMoney(count)
    end
end

function GetMoney(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    return xPlayer and xPlayer.getMoney() or 0
end

function CheckPermission(source, permission)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    local name = xPlayer.job and xPlayer.job.name
    local rank = xPlayer.job and xPlayer.job.grade or 0
    local group = xPlayer.getGroup and xPlayer.getGroup()
    if permission.jobs and permission.jobs[name] and permission.jobs[name] <= rank then 
        return true
    end
    if permission.groups then
        for i=1, #permission.groups do 
            if group == permission.groups[i] then 
                return true 
            end
        end
    end
    return false
end

-- Society Funds

function AddSocietyMoney(name, amount)
    TriggerEvent('esx_addonaccount:getSharedAccount', "society_" .. name, function(account)
        if account then
            account.addMoney(amount)
        end
    end)
end

function RemoveSocietyMoney(name, amount)
    TriggerEvent('esx_addonaccount:getSharedAccount', "society_" .. name, function(account)
        if account then
            account.removeMoney(amount)
        end
    end)
end

-- Inventory Fallback

CreateThread(function()
    Wait(100)

    if InitializeInventory then return InitializeInventory() end -- Already loaded through inventory folder.

    print("The only supported inventory for ESX is ox_inventory and qs-inventory, if you would like to port to a different inventory, please use the example shown in the inventory folder.")
end)
