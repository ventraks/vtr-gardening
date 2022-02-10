local QBCore = exports['qb-core']:GetCoreObject()
local jobPlayers = 0
local isBusy = false

RegisterNetEvent('vtr-gardening:server:work', function()
    if Config.MaxPlayers => 0 then
        if jobPlayers < Config.MaxPlayers then
            jobPlayers = jobPlayers + 1
            TriggerClientEvent('vtr-gardening:client:joinJob', source)
        else
            TriggerClientEvent('QBCore:Notify', source, "Job is full ", "error")
        end
    else
        TriggerClientEvent('vtr-gardening:client:joinJob', source)
    end
end)

RegisterNetEvent('vtr-gardening:server:leave', function()
    jobPlayers = jobPlayers - 1
    TriggerClientEvent('vtr-gardening:client:leaveJob', source)
end)

RegisterNetEvent('vtr-gardening:server:setState', function(curShrub)
    Shrubs[curShrub]["isBusy"] = true
    Wait(Config.Cooldown * 1000)  
    Shrubs[curShrub]["isBusy"] = false
end)

RegisterNetEvent('vtr-gardening:server:checkStatus', function(curShrub)
    if not Shrubs[curShrub]["isBusy"] then
        TriggerClientEvent('vtr-gardening:client:pruningShrub', source, curShrub)
    else
        TriggerClientEvent('QBCore:Notify', source, "You can't prune this right now!", "error")
    end
end)

RegisterNetEvent('vtr-gardening:server:paycheck', function(paycheck)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Config.Cash then
        if paycheck <= 0 then
            TriggerClientEvent('QBCore:Notify', source, "Are you kidding me? Go back to work!", "error")
        else
            Player.Functions.AddMoney('cash', paycheck)
        end
    else
        if paycheck <= 0 then
            TriggerClientEvent('QBCore:Notify', source, "Are you kidding me? Go back to work!", "error")
        else
            Player.Functions.AddMoney('bank', paycheck)
        end
    end
end)
