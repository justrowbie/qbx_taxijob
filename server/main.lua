local sharedConfig = require 'config.shared'
local ITEMS = exports.ox_inventory:Items()

local function nearTaxi(src)
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    for _, v in pairs(sharedConfig.npcLocations.deliverLocations) do
        local dist = #(coords - v.xyz)
        if dist < 20 then
            return true
        end
    end
end

lib.callback.register('qb-taxi:server:spawnTaxi', function(source, model, coords)
    local netId, veh = qbx.spawnVehicle({
        model = model,
        spawnSource = coords,
        warp = GetPlayerPed(source --[[@as number]]),
    })

    local plate = 'TAXI' .. math.random(1000, 9999)
    SetVehicleNumberPlateText(veh, plate)
    TriggerClientEvent('vehiclekeys:client:SetOwner', source, plate)
    return netId
end)

RegisterNetEvent('qb-taxi:server:payRentTaxi', function(amount, type)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if player.Functions.RemoveMoney(type, amount) then
        exports.qbx_core:Notify(src, Lang:t('success.rent_taxi'), 'success', 7500)
    end
end)

RegisterNetEvent('qb-taxi:server:returnRentTaxi', function(amount, type)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if player.Functions.AddMoney(type, amount * (sharedConfig.returnVehPercentage/100)) then
        exports.qbx_core:Notify(src, Lang:t('success.return_taxi'), 'success', 7500)
    end
end)

RegisterNetEvent('qb-taxi:server:NpcPay', function(payment, fairpayment)
    local src = source
    local fairPayment = fairpayment
    local payment = payment
    local player = exports.qbx_core:GetPlayer(src)
    if sharedConfig.usingJob then
        if player.PlayerData.job.name == 'taxi' then
            if nearTaxi(src) then
                if payment > (fairPayment + sharedConfig.tolerance) then
                    player.Functions.AddMoney('cash', payment)
                    player.Functions.RemoveMoney('bank', sharedConfig.fairPenalty)
                    TriggerClientEvent('qbx_taxijob:client:sentEmail', src, 'notfair', fairPayment, payment, sharedConfig.fairPenalty)
                else
                    player.Functions.AddMoney('cash', payment)
                    if payment == 0 or math.random(0,10) > 8 then
                        player.Functions.AddMoney('bank', sharedConfig.fairBonus)
                        TriggerClientEvent('qbx_taxijob:client:sentEmail', src, 'fair', fairPayment, payment, sharedConfig.fairBonus)
                    end
                end
            else
                DropPlayer(src, 'Attempting To Exploit')
            end
        else
            DropPlayer(src, 'Attempting To Exploit')
        end
    else
        if nearTaxi(src) then
            if payment > (fairPayment + sharedConfig.tolerance) then
                player.Functions.AddMoney('cash', payment)
                player.Functions.RemoveMoney('bank', sharedConfig.fairPenalty)
                TriggerClientEvent('qbx_taxijob:client:sentEmail', src, 'notfair', fairPayment, payment, sharedConfig.fairPenalty)
            else
                player.Functions.AddMoney('cash', payment)
                if payment == 0 or math.random(0,10) > 8 then
                    player.Functions.AddMoney('bank', sharedConfig.fairBonus)
                    TriggerClientEvent('qbx_taxijob:client:sentEmail', src, 'fair', fairPayment, payment, sharedConfig.fairBonus)
                end
            end
        else
            DropPlayer(src, 'Attempting To Exploit')
        end
    end
end)

RegisterNetEvent('qb-taxi:server:showMeterPass', function(nearPlayer)
    TriggerClientEvent('qb-taxi:client:showMeterPass', nearPlayer.id, nearPlayer)
end)