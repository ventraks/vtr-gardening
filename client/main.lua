local QBCore = exports['qb-core']:GetCoreObject()
local inJob = false
local paycheck = 0

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    paycheck = 0
    inJob = false
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    paycheck = 0
    inJob = false
end)

RegisterNetEvent('vtr-gardening:client:setState', function(curShrub)
    Shrubs[curShrub]["isBusy"] = true
    Wait(Config.Cooldown * 1000)  
    Shrubs[curShrub]["isBusy"] = false
    inJob = false
    Wait(7)
    inJob = true
    TriggerEvent('vtr-gardening:client:drawMarkers')
end)

RegisterNetEvent('vtr-gardening:client:drawMarkers', function()
    for k, v in pairs(Shrubs) do
        CreateThread(function()
            while inJob == true and Shrubs[k]["isBusy"] == false do
                local pos = GetEntityCoords(PlayerPedId())
                local dist = #(pos - v.coords)
                local sleep = 2000

                if dist < 5.0 then
                    sleep = 7

                    if dist < 3.0 then
                        DrawMarker(21 , v.coords.x, v.coords.y, v.coords.z - 0.4, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.15, 0.15, 0.15, 4, 205, 0, 222, true, false, false, false, false, false, false)
                    end
                end
                Wait(sleep)
            end
        end)	
    end
end)

RegisterNetEvent('vtr-gardening:client:pruneShrub', function(curShrub)
    TriggerServerEvent('vtr-gardening:server:checkStatus', curShrub)
end)

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(5)
    end
end

RegisterNetEvent('vtr-gardening:client:pruningShrub', function(curShrub)
    loadAnimDict("amb@world_human_bum_wash@male@low@idle_a")
    TaskPlayAnim(PlayerPedId(), 'amb@world_human_bum_wash@male@low@idle_a', 'idle_a' , 3.0, 3.0, -1, 1, 0, false, false, false)
    QBCore.Functions.Progressbar("prune_shrub", "Pruning shrub ..", 10000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        StopAnimTask(PlayerPedId(), "amb@world_human_bum_wash@male@low@idle_a", "idle_a", 1.0)
        TriggerServerEvent('vtr-gardening:server:setState', curShrub)
        TriggerEvent('vtr-gardening:client:setState', curShrub)
        paycheck = paycheck + Config.Paycheck
        if Config.CurrentPaycheck then
            QBCore.Functions.Notify("Your current paycheck: $".. paycheck, "success")
        end
        end, function()
    end)
end)

RegisterNetEvent('vtr-gardening:client:joinJob', function()
    if not inJob then
        inJob = true
        TriggerEvent('vtr-gardening:client:drawMarkers')
        QBCore.Functions.Notify("You started working here ", "success")
    end
end)

RegisterNetEvent('vtr-gardening:client:leaveJob', function()
    if paycheck > 0 then
        QBCore.Functions.Notify("You have some work done here, take your money first! ", "error")
    else
        QBCore.Functions.Notify("You're no longer working here!", "success")
        inJob = false
    end
end)
 
RegisterNetEvent('vtr-gardening:client:paycheck', function()
    TriggerServerEvent('vtr-gardening:server:paycheck', paycheck)
    paycheck = 0
end)

CreateThread(function()
    for k, v in pairs(Shrubs) do
        exports['qb-target']:AddBoxZone(k, vector3(v.coords), v.lenght, v.width, {
        name = k, 
        heading = v.heading, 
        debugPoly = false, 
        minZ = 36.7, 
        maxZ = 37.9, 
        }, {
            options = {
                {
                    icon = 'fas fa-cut',
                    label = 'Prune shrub',
                    canInteract = function()
                        if Shrubs[k]["isBusy"] and not inJob then
                            return false
                        elseif not Shrubs[k]["isBusy"] and inJob then
                            return true
                        end
                    end,
                    action = function()
                        TriggerEvent('vtr-gardening:client:pruneShrub', k)
                    end,
                }
            },
            distance = 1.5,
        })
    end
end)

CreateThread(function()
    exports['qb-target']:SpawnPed({
        model = 's_m_m_gardener_01',
        coords = vector4(-540.42, -205.34, 37.65, 209.09),
        minusOne = true,
        freeze = true,
        invincible = true,
        blockevents = true,
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        target = {
            options = {
                {
                    type = "server",
                    event = "vtr-gardening:server:work",
                    icon = 'fas fa-angle-double-right',
                    label = 'Ask For Job',
                    canInteract = function()
                        if inJob then
                            return false
                        else
                            return true
                        end
                    end,
                },
                {
                    type = "server",
                    event = "vtr-gardening:server:leave",
                    icon = 'fas fa-angle-double-left',
                    label = 'Leave Job',
                    canInteract = function()
                        if not inJob then
                            return false
                        else
                            return true
                        end
                    end,
                },
                {
                    type = "client",
                    event = "vtr-gardening:client:paycheck",
                    icon = 'fas fa-hand-holding-usd',
                    label = 'Take Money',
                    canInteract = function()
                        if paycheck <= 0 then
                            return false
                        else
                            return true
                        end
                    end,
                }
            },
            distance = 1.5,
        }
    })
end)
