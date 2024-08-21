-- Variables
local config = require 'config.client'
local sharedConfig = require 'config.shared'
local isLoggedIn = LocalPlayer.state.isLoggedIn
local meterIsOpen = false
local meterActive = false
local lastLocation = nil
local mouseActive = false
local currentVehicle, pickupLoc, dropoffLoc = nil, nil, nil
local garageZone, taxiParkingZone = nil, nil

-- used for polyzones
local isInsidePickupZone = false
local isInsideDropZone = false

local meterData = {
    fareAmount = 6,
    currentFare = 0,
    distanceTraveled = 0,
    currentFair = 0
}

local NpcData = {
    Active = false,
    CurrentNpc = nil,
    LastNpc = nil,
    CurrentDeliver = nil,
    LastDeliver = nil,
    Npc = nil,
    NpcBlip = nil,
    DeliveryBlip = nil,
    NpcTaken = false,
    NpcDelivered = false,
    CountDown = 180
}

local taxiPed = nil

local function resetNpcTask()
    NpcData = {
        Active = false,
        CurrentNpc = nil,
        LastNpc = nil,
        CurrentDeliver = nil,
        LastDeliver = nil,
        Npc = nil,
        NpcBlip = nil,
        DeliveryBlip = nil,
        NpcTaken = false,
        NpcDelivered = false
    }
end

local function resetMeter()
    meterData = {
        fareAmount = 6,
        currentFare = 0,
        distanceTraveled = 0,
        currentFair = 0
    }
    pickupLoc = nil
    dropoffLoc = nil
end

local function whitelistedPassengerVehicle(ped)
    local veh = GetEntityModel(GetVehiclePedIsIn(ped))
    local retval = false

    for i = 1, #config.allowedVehicles, 1 do
        if veh == joaat(config.allowedVehicles[i].model) then
            retval = true
            currentVehicle = i
        end
    end

    return retval
end

local function whitelistedVehicle()
    local veh = GetEntityModel(cache.vehicle)
    local retval = false

    for i = 1, #config.allowedVehicles, 1 do
        if veh == joaat(config.allowedVehicles[i].model) then
            retval = true
            currentVehicle = i
        end
    end

    return retval
end

local function isDriver()
    return cache.seat == -1
end

local zone
local deliveryZone

local function getDeliveryLocation()
    NpcData.CurrentDeliver = math.random(1, #sharedConfig.npcLocations.deliverLocations)
    if NpcData.LastDeliver then
        while NpcData.LastDeliver ~= NpcData.CurrentDeliver do
            NpcData.CurrentDeliver = math.random(1, #sharedConfig.npcLocations.deliverLocations)
        end
    end

    if NpcData.DeliveryBlip then
        RemoveBlip(NpcData.DeliveryBlip)
    end
    NpcData.DeliveryBlip = AddBlipForCoord(sharedConfig.npcLocations.deliverLocations[NpcData.CurrentDeliver].x, sharedConfig.npcLocations.deliverLocations[NpcData.CurrentDeliver].y, sharedConfig.npcLocations.deliverLocations[NpcData.CurrentDeliver].z)
    SetBlipColour(NpcData.DeliveryBlip, 2)
    SetBlipRoute(NpcData.DeliveryBlip, true)
    SetBlipRouteColour(NpcData.DeliveryBlip, 2)
    NpcData.LastDeliver = NpcData.CurrentDeliver
    dropoffLoc = sharedConfig.npcLocations.deliverLocations[NpcData.CurrentDeliver].xyz
    if not config.useTarget then -- added checks to disable distance checking if polyzone option is used
        CreateThread(function()
            while true do
                local pos = GetEntityCoords(cache.ped)
                local dist = #(pos - vec3(sharedConfig.npcLocations.deliverLocations[NpcData.CurrentDeliver].x, sharedConfig.npcLocations.deliverLocations[NpcData.CurrentDeliver].y, sharedConfig.npcLocations.deliverLocations[NpcData.CurrentDeliver].z))
                if dist < 20 then
                    DrawMarker(2, sharedConfig.npcLocations.deliverLocations[NpcData.CurrentDeliver].x, sharedConfig.npcLocations.deliverLocations[NpcData.CurrentDeliver].y, sharedConfig.npcLocations.deliverLocations[NpcData.CurrentDeliver].z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 255, 255, 255, 255, false, false, 0, true, nil, nil, false)
                    if dist < 5 then
                        qbx.drawText3d({text = Lang:t('info.drop_off_npc'), coords = sharedConfig.npcLocations.deliverLocations[NpcData.CurrentDeliver].xyz})
                        if IsControlJustPressed(0, 38) then
                            TaskLeaveVehicle(NpcData.Npc, cache.vehicle, 0)
                            SetEntityAsMissionEntity(NpcData.Npc, false, true)
                            SetEntityAsNoLongerNeeded(NpcData.Npc)
                            local targetCoords = sharedConfig.npcLocations.takeLocations[NpcData.LastNpc]
                            TaskGoStraightToCoord(NpcData.Npc, targetCoords.x, targetCoords.y, targetCoords.z, 1.0, -1, 0.0, 0.0)
                            SendNUIMessage({
                                action = 'toggleMeter'
                            })
                            TriggerServerEvent('qb-taxi:server:NpcPay', meterData.currentFare, meterData.currentFair)
                            meterActive = false
                            SendNUIMessage({
                                action = 'resetMeter'
                            })
                            exports.qbx_core:Notify(Lang:t('info.person_was_dropped_off'), 'success')
                            if NpcData.DeliveryBlip then
                                RemoveBlip(NpcData.DeliveryBlip)
                            end
                            local RemovePed = function(p)
                                SetTimeout(60000, function()
                                    DeletePed(p)
                                end)
                            end
                            RemovePed(NpcData.Npc)
                            resetNpcTask()
                            break
                        end
                    end
                end
                Wait(0)
            end
        end)
    end
end

local function callNpcPoly()
    CreateThread(function()
        while not NpcData.NpcTaken do
            if isInsidePickupZone then
                if IsControlJustPressed(0, 38) then
                    lib.hideTextUI()
                    local veh = cache.vehicle
                    local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(veh), 0

                    for i= maxSeats - 1, 0, -1 do
                        if IsVehicleSeatFree(veh, i) then
                            freeSeat = i
                            break
                        end
                    end

                    meterIsOpen = true
                    meterActive = true
                    lastLocation = GetEntityCoords(cache.ped)
                    SendNUIMessage({
                        action = 'openMeter',
                        toggle = true,
                        meterData = config.allowedVehicles[currentVehicle]
                    })
                    SendNUIMessage({
                        action = 'toggleMeter'
                    })
                    ClearPedTasksImmediately(NpcData.Npc)
                    FreezeEntityPosition(NpcData.Npc, false)
                    TaskEnterVehicle(NpcData.Npc, veh, -1, freeSeat, 1.0, 0)
                    exports.qbx_core:Notify(Lang:t('info.go_to_location'), 'inform')
                    if NpcData.NpcBlip then
                        RemoveBlip(NpcData.NpcBlip)
                    end
                    getDeliveryLocation()
                    NpcData.NpcTaken = true
                    createNpcDeliveryLocation()
                    zone:remove()
                    lib.hideTextUI()
                end
            end
            Wait(0)
        end
    end)
end

local function onEnterCallZone()
    if whitelistedVehicle() and not isInsidePickupZone and not NpcData.NpcTaken then
        isInsidePickupZone = true
        lib.showTextUI(Lang:t('info.call_npc'), {position = 'left-center'})
        callNpcPoly()
    end
end

local function onExitCallZone()
    lib.hideTextUI()
    isInsidePickupZone = false
end

local function createNpcPickUpLocation()
    zone = lib.zones.box({
        coords = config.pzLocations.takeLocations[NpcData.CurrentNpc].coord,
        size = vec3(config.pzLocations.takeLocations[NpcData.CurrentNpc].height + 2.0, config.pzLocations.takeLocations[NpcData.CurrentNpc].width + 2.0, (config.pzLocations.takeLocations[NpcData.CurrentNpc].maxZ - config.pzLocations.takeLocations[NpcData.CurrentNpc].minZ)),
        rotation = config.pzLocations.takeLocations[NpcData.CurrentNpc].heading,
        debug = config.debugPoly,
        onEnter = onEnterCallZone,
        onExit = onExitCallZone
    })
end

local function enumerateEntitiesWithinDistance(entities, isPlayerEntities, coords, maxDistance)
	local nearbyEntities = {}
	if coords then
		coords = vec3(coords.x, coords.y, coords.z)
	else
		coords = GetEntityCoords(cache.ped)
	end
	for k, entity in pairs(entities) do
		local distance = #(coords - GetEntityCoords(entity))
		if distance <= maxDistance then
			nearbyEntities[#nearbyEntities + 1] = isPlayerEntities and k or entity
		end
	end
	return nearbyEntities
end

local function getVehiclesInArea(coords, maxDistance) -- Vehicle inspection in designated area
	return enumerateEntitiesWithinDistance(GetGamePool('CVehicle'), false, coords, maxDistance)
end

local function isSpawnPointClear(coords, maxDistance) -- Check the spawn point to see if it's empty or not:
	return #getVehiclesInArea(coords, maxDistance) == 0
end

local function getVehicleSpawnPoint()
    local near = nil
	local distance = 10000
	for k, v in pairs(config.cabSpawns) do
        if isSpawnPointClear(vec3(v.x, v.y, v.z), 2.5) then
            local pos = GetEntityCoords(cache.ped)
            local cur_distance = #(pos - vec3(v.x, v.y, v.z))
            if cur_distance < distance then
                distance = cur_distance
                near = k
            end
        end
    end
	return near
end

local function calculateFareAmount()
    if meterIsOpen and meterActive and not NpcData.NpcTaken then -- For RP purposes
        local startPos = lastLocation
        local newPos = GetEntityCoords(cache.ped)
        if startPos ~= newPos then
            local newDistance = #(startPos - newPos)
            lastLocation = newPos
            meterData['distanceTraveled'] += (newDistance / 1000)
            local fareAmount = ((meterData['distanceTraveled']) * config.allowedVehicles[currentVehicle].defaultPrice) + config.allowedVehicles[currentVehicle].startingPrice
            meterData['currentFare'] = math.floor(fareAmount)
            SendNUIMessage({
                action = 'updateMeter',
                meterData = meterData
            })
        end
    end

    if meterIsOpen and meterActive and NpcData.NpcTaken then
        local startPos = lastLocation
        local newPos = GetEntityCoords(cache.ped)
        if startPos ~= newPos then
            local newDistance = #(startPos - newPos)
            lastLocation = newPos

            meterData['distanceTraveled'] += (newDistance / 1000)
            local fareAmount = ((meterData['distanceTraveled']) * config.allowedVehicles[currentVehicle].defaultPrice) + config.allowedVehicles[currentVehicle].startingPrice
            local fairAmount = (#(dropoffLoc-pickupLoc) / 1000 * config.allowedVehicles[currentVehicle].defaultPrice) + config.allowedVehicles[currentVehicle].startingPrice
            meterData['currentFare'] = math.floor(fareAmount)
            meterData['currentFair'] = math.floor(fairAmount)

            SendNUIMessage({
                action = "updateMeter",
                meterData = meterData
            })
        end
    end
end

local function onEnterDropZone()
    if whitelistedVehicle() and not isInsideDropZone and NpcData.NpcTaken then
        isInsideDropZone = true
        lib.showTextUI(Lang:t('info.drop_off_npc'), {position = 'left-center'})
        dropNpcPoly()
    end
end

local function onExitDropZone()
    lib.hideTextUI()
    isInsideDropZone = false

end

function createNpcDeliveryLocation()
    deliveryZone = lib.zones.box({
        coords = config.pzLocations.dropLocations[NpcData.CurrentDeliver].coord,
        size = vec3(config.pzLocations.dropLocations[NpcData.CurrentDeliver].height, config.pzLocations.dropLocations[NpcData.CurrentDeliver].width, (config.pzLocations.dropLocations[NpcData.CurrentDeliver].maxZ - config.pzLocations.dropLocations[NpcData.CurrentDeliver].minZ)),
        rotation = config.pzLocations.dropLocations[NpcData.CurrentDeliver].heading,
        debug = config.debugPoly,
        onEnter = onEnterDropZone,
        onExit = onExitDropZone
    })
end

function dropNpcPoly()
    CreateThread(function()
        while NpcData.NpcTaken do
            if isInsideDropZone then
                if IsControlJustPressed(0, 38) then
                    lib.hideTextUI()
                    local veh = cache.vehicle
                    TaskLeaveVehicle(NpcData.Npc, veh, 0)
                    Wait(1000)
                    SetVehicleDoorShut(veh, 3, false)
                    SetEntityAsMissionEntity(NpcData.Npc, false, true)
                    SetEntityAsNoLongerNeeded(NpcData.Npc)
                    local targetCoords = sharedConfig.npcLocations.takeLocations[NpcData.LastNpc]
                    TaskGoStraightToCoord(NpcData.Npc, targetCoords.x, targetCoords.y, targetCoords.z, 1.0, -1, 0.0, 0.0)
                    SendNUIMessage({
                        action = 'toggleMeter'
                    })
                    TriggerServerEvent('qb-taxi:server:NpcPay', meterData.currentFare, meterData.currentFair)
                    meterActive = false
                    SendNUIMessage({
                        action = 'resetMeter'
                    })
                    exports.qbx_core:Notify(Lang:t('info.person_was_dropped_off'), 'success')
                    if NpcData.DeliveryBlip ~= nil then
                        RemoveBlip(NpcData.DeliveryBlip)
                    end
                    local RemovePed = function(p)
                        SetTimeout(60000, function()
                            DeletePed(p)
                        end)
                    end
                    RemovePed(NpcData.Npc)
                    resetNpcTask()
                    deliveryZone:remove()
                    lib.hideTextUI()
                    break
                end
            end
            Wait(0)
        end
    end)
end

local function stopNpcMission()
    exports.qbx_core:Notify(Lang:t('error.cancel_mission'), 'error')
    SendNUIMessage({
        action = 'resetMeter'
    })
    if NpcData.NpcBlip then
        RemoveBlip(NpcData.NpcBlip)
    end
    local RemovePed = function(p)
        SetTimeout(60000, function()
            DeletePed(p)
        end)
    end
    RemovePed(NpcData.Npc)
    resetNpcTask()
    zone:remove()
end

local function setLocationsBlip()
    if not config.useBlips then return end
    local taxiBlip = AddBlipForCoord(config.locations.main.coords.x, config.locations.main.coords.y, config.locations.main.coords.z)
    SetBlipSprite(taxiBlip, 198)
    SetBlipDisplay(taxiBlip, 4)
    SetBlipScale(taxiBlip, 0.6)
    SetBlipAsShortRange(taxiBlip, true)
    SetBlipColour(taxiBlip, 2)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(Lang:t('info.blip_name'))
    EndTextCommandSetBlipName(taxiBlip)
end

local function taxiGarage()
    local registeredMenu = {
        id = 'garages_depotlist',
        title = Lang:t('menu.taxi_menu_header'),
        options = {}
    }
    local options = {}
    for _, v in pairs(config.allowedVehicles) do

        options[#options + 1] = {
            title = v.label..Lang:t('menu.rent_price')..v.rent,
            event = 'qb-taxi:client:TakeVehicle',
            args = {model = v.model, price = v.rent},
            icon = 'fa-solid fa-taxi'
        }
    end

    registeredMenu['options'] = options
    lib.registerContext(registeredMenu)
    lib.showContext('garages_depotlist')
end

local function setupGarageZone()
    if config.useTarget then
        lib.requestModel(`a_m_m_indian_01`)
        taxiPed = CreatePed(3, `a_m_m_indian_01`, config.pedLoc.x, config.pedLoc.y, config.pedLoc.z, config.pedLoc.w, false, true)
        SetModelAsNoLongerNeeded(`a_m_m_indian_01`)
        SetBlockingOfNonTemporaryEvents(taxiPed, true)
        FreezeEntityPosition(taxiPed, true)
        SetEntityInvincible(taxiPed, true)
        exports.interact:RemoveLocalEntityInteraction(taxiPed, 'qbx_taxijob_ped')
        if sharedConfig.usingJob then
            exports.interact:AddLocalEntityInteraction({
                entity = taxiPed,
                name = 'qbx_taxijob_ped',
                id = 'qbx_taxijob_ped',
                distance = 3.0,
                interactDst = 2.0,
                groups = 'taxi',
                options = {
                    {
                        label = Lang:t('info.request_taxi_target'),
                        event = 'qb-taxijob:client:requestcab',
                    },
                }
            })
        else
            exports.interact:AddLocalEntityInteraction({
                entity = taxiPed,
                name = 'qbx_taxijob_ped',
                id = 'qbx_taxijob_ped',
                distance = 3.0,
                interactDst = 2.0,
                options = {
                    {
                        label = Lang:t('info.request_taxi_target'),
                        event = 'qb-taxijob:client:requestcab',
                    },
                }
            })
        end
    else
        local function onEnter()
            if not cache.vehicle then
                lib.showTextUI(Lang:t('info.request_taxi'))
            end
        end

        local function onExit()
            lib.hideTextUI()
        end

        local function inside()
            if IsControlJustPressed(0, 38) then
                lib.hideTextUI()
                taxiGarage()
                return
            end
        end

        garageZone = lib.zones.box({
            coords = config.locations.garage.coords,
            size = vec3(1.6, 4.0, 2.8),
            rotation = 328.5,
            debug = config.debugPoly,
            inside = inside,
            onEnter = onEnter,
            onExit = onExit
        })
    end
end

local function destroyGarageZone()
    if not garageZone then return end

    garageZone:remove()
    garageZone = nil
end

function setupTaxiParkingZone()
    taxiParkingZone = lib.zones.box({
        coords = vec3(config.locations.main.coords.x, config.locations.main.coords.y, config.locations.main.coords.z),
        size = vec3(4.0, 4.0, 4.0),
        rotation = 55,
        debug = config.debugPoly,
        inside = function()
            if sharedConfig.usingJob then
                if QBX.PlayerData.job.name ~= 'taxi' then return end
            end
            if IsControlJustPressed(0, 38) then
                if whitelistedVehicle() then
                    if meterIsOpen then
                        TriggerEvent('qb-taxi:client:toggleMeter')
                        meterActive = false
                    end
                    for k,v in pairs(config.allowedVehicles) do
                        if GetEntityModel(cache.vehicle) == GetHashKey(v.model) then
                            TriggerEvent('qbx_taxijob:client:returnVehicle', v.rent)
                            break
                        end
                    end
                    DeleteVehicle(cache.vehicle)
                end
            end
        end,
        onEnter = function()
            lib.showTextUI(Lang:t('info.vehicle_parking'))
        end,
        onExit = function()
            lib.hideTextUI()
        end
    })
end

local function destroyTaxiParkingZone()
    if not taxiParkingZone then return end

    taxiParkingZone:remove()
    taxiParkingZone = nil
end

local function checkRentType(data)
    local money = QBX.PlayerData.money
    if money.cash >= data.price then
        return 'cash'
    elseif money.bank >= data.price then
        return 'bank'
    end
    return false
end

RegisterNetEvent('qbx_taxijob:client:returnVehicle', function(rent)
    TriggerServerEvent('qb-taxi:server:returnRentTaxi', rent, 'cash')
end)

RegisterNetEvent('qbx_taxijob:client:sentEmail', function(type, fair, payment, amount)
    if type == 'fair' then
        TriggerServerEvent('qs-smartphone:server:sendNewMail', {
            sender = 'Taksi IPS',
            subject = 'Bonus',
            message = 'Terima kasih telah berlaku fair dalam pengantaran penumpang. Kami telah mengirimkan tambahan <b>Rp '..amount..'</b> ke rekening bank anda.<br><br>Rincian hasil perjalanan sebagai berikut:<br>- Tagihan meter: Rp '..payment..'<br>- Tagihan fair: Rp '..fair..'<br><br>Taksi IPS',
        })
    elseif type == 'notfair' then
        TriggerServerEvent('qs-smartphone:server:sendNewMail', {
            sender = 'Taksi IPS',
            subject = 'Denda',
            message = 'Maaf perilaku tidak fair anda membuat kami harus memberikan denda sebesar <b>Rp '..amount..'</b> dari rekening bank anda.<br><br>Rincian hasil perjalanan sebagai berikut:<br>- Tagihan meter: Rp '..payment..'<br>- Tagihan fair: Rp '..fair..'<br><br>Taksi IPS',
        })
    end
end)

RegisterNetEvent('qb-taxi:client:TakeVehicle', function(data)
    local SpawnPoint = getVehicleSpawnPoint()
    local rentPayType = checkRentType(data)
    if rentPayType then
        TriggerServerEvent('qb-taxi:server:payRentTaxi', data.price, rentPayType)
        if SpawnPoint then
            local coords = config.cabSpawns[SpawnPoint]
            local CanSpawn = isSpawnPointClear(coords, 2.0)
            if CanSpawn then
                local netId = lib.callback.await('qb-taxi:server:spawnTaxi', false, data.model, coords)
                local veh = NetToVeh(netId)
                exports['cdn-fuel']:SetFuel(veh, 100)
                SetVehicleEngineOn(veh, true, true, false)
            else
                exports.qbx_core:Notify(Lang:t('info.no_spawn_point'), 'error')
            end
        else
            exports.qbx_core:Notify(Lang:t('info.no_spawn_point'), 'error')
            return
        end
    else
        exports.qbx_core:Notify(Lang:t('error.no_money'), 'error')
        return
    end
end)

-- Events
RegisterNetEvent('qb-taxi:client:DoTaxiNpc', function()
    if whitelistedVehicle() then
        if not NpcData.Active then
            NpcData.CurrentNpc = math.random(1, #sharedConfig.npcLocations.takeLocations)
            if NpcData.LastNpc ~= nil then
                while NpcData.LastNpc ~= NpcData.CurrentNpc do
                    NpcData.CurrentNpc = math.random(1, #sharedConfig.npcLocations.takeLocations)
                end
            end

            local Gender = math.random(1, #config.npcSkins)
            local PedSkin = math.random(1, #config.npcSkins[Gender])
            local model = GetHashKey(config.npcSkins[Gender][PedSkin])
            lib.requestModel(model)
            NpcData.Npc = CreatePed(3, model, sharedConfig.npcLocations.takeLocations[NpcData.CurrentNpc].x, sharedConfig.npcLocations.takeLocations[NpcData.CurrentNpc].y, sharedConfig.npcLocations.takeLocations[NpcData.CurrentNpc].z - 0.98, sharedConfig.npcLocations.takeLocations[NpcData.CurrentNpc].w, true, true)
            SetModelAsNoLongerNeeded(model)
            PlaceObjectOnGroundProperly(NpcData.Npc)
            FreezeEntityPosition(NpcData.Npc, true)
            if NpcData.NpcBlip ~= nil then
                RemoveBlip(NpcData.NpcBlip)
            end
            exports.qbx_core:Notify(Lang:t('info.npc_on_gps'), 'success')
            pickupLoc = sharedConfig.npcLocations.takeLocations[NpcData.CurrentNpc].xyz

            -- added checks to disable distance checking if polyzone option is used
            if config.useTarget then
                createNpcPickUpLocation()
            end

            NpcData.NpcBlip = AddBlipForCoord(sharedConfig.npcLocations.takeLocations[NpcData.CurrentNpc].x, sharedConfig.npcLocations.takeLocations[NpcData.CurrentNpc].y, sharedConfig.npcLocations.takeLocations[NpcData.CurrentNpc].z)
            SetBlipColour(NpcData.NpcBlip, 2)
            SetBlipRoute(NpcData.NpcBlip, true)
            SetBlipRouteColour(NpcData.NpcBlip, 2)
            NpcData.LastNpc = NpcData.CurrentNpc
            NpcData.Active = true

            -- added checks to disable distance checking if polyzone option is used
            if not config.useTarget then
                CreateThread(function()
                    while not NpcData.NpcTaken do

                        local pos = GetEntityCoords(cache.ped)
                        local dist = #(pos - vec3(sharedConfig.npcLocations.takeLocations[NpcData.CurrentNpc].x, sharedConfig.npcLocations.takeLocations[NpcData.CurrentNpc].y, sharedConfig.npcLocations.takeLocations[NpcData.CurrentNpc].z))

                        if dist < 20 then
                            DrawMarker(2, sharedConfig.npcLocations.takeLocations[NpcData.CurrentNpc].x, sharedConfig.npcLocations.takeLocations[NpcData.CurrentNpc].y, sharedConfig.npcLocations.takeLocations[NpcData.CurrentNpc].z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 255, 255, 255, 255, false, false, 0, true, nil, nil, false)

                            if dist < 5 then
                                qbx.drawText3d({text = Lang:t('info.call_npc'), coords = sharedConfig.npcLocations.takeLocations[NpcData.CurrentNpc].xyz})
                                if IsControlJustPressed(0, 38) then
                                    local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(cache.vehicle), 0

                                    for i=maxSeats - 1, 0, -1 do
                                        if IsVehicleSeatFree(cache.vehicle, i) then
                                            freeSeat = i
                                            break
                                        end
                                    end

                                    meterIsOpen = true
                                    meterActive = true
                                    lastLocation = GetEntityCoords(cache.ped)
                                    SendNUIMessage({
                                        action = 'openMeter',
                                        toggle = true,
                                        meterData = config.meter
                                    })
                                    SendNUIMessage({
                                        action = 'toggleMeter'
                                    })
                                    ClearPedTasksImmediately(NpcData.Npc)
                                    FreezeEntityPosition(NpcData.Npc, false)
                                    TaskEnterVehicle(NpcData.Npc, cache.vehicle, -1, freeSeat, 1.0, 0)
                                    exports.qbx_core:Notify(Lang:t('info.go_to_location'), 'inform')
                                    if NpcData.NpcBlip ~= nil then
                                        RemoveBlip(NpcData.NpcBlip)
                                    end
                                    getDeliveryLocation()
                                    NpcData.NpcTaken = true
                                end
                            end
                        end

                        Wait(0)
                    end
                end)
            end
        else
            exports.qbx_core:Notify(Lang:t('error.already_mission'), 'error')
        end
    else
        exports.qbx_core:Notify(Lang:t('error.not_in_taxi'), 'error')
    end
end)

RegisterNetEvent('qb-taxi:client:showMeterPass', function(nearPlayer)
    if cache.vehicle then
        if whitelistedPassengerVehicle(nearPlayer.ped) then
            if not meterIsOpen then
                SendNUIMessage({
                    action = 'openMeter',
                    toggle = true,
                    meterData = config.allowedVehicles[currentVehicle]
                })
                meterIsOpen = true
            else
                SendNUIMessage({
                    action = 'openMeter',
                    toggle = false
                })
                meterIsOpen = false
            end
        else
            exports.qbx_core:Notify(Lang:t('error.missing_meter'), 'error')
        end
    else
        exports.qbx_core:Notify(Lang:t('error.no_vehicle'), 'error')
    end
end)

RegisterNetEvent('qb-taxi:client:toggleMeter', function()
    if cache.vehicle then
        if whitelistedVehicle() then
            if NpcData.Active then
                if not meterIsOpen and isDriver() then
                    if not NpcData.NpcTaken then
                        SendNUIMessage({
                            action = 'openMeter',
                            toggle = true,
                            meterData = config.allowedVehicles[currentVehicle]
                        })
                        meterIsOpen = true
                    else
                        SendNUIMessage({
                            action = 'openMeter',
                            toggle = false
                        })
                        meterIsOpen = false
                    end
                else
                    if not NpcData.NpcTaken then
                        SendNUIMessage({
                            action = 'openMeter',
                            toggle = false
                        })
                        meterIsOpen = false
                        stopNpcMission()
                    else
                        SendNUIMessage({
                            action = 'openMeter',
                            toggle = false
                        })
                        meterIsOpen = false
                    end
                end
            else
                local nearPlayer = lib.getNearbyPlayers(GetEntityCoords(cache.ped), 5.0, false)
                if not meterIsOpen and isDriver() then
                    SendNUIMessage({
                        action = 'openMeter',
                        toggle = true,
                        meterData = config.allowedVehicles[currentVehicle]
                    })
                    meterIsOpen = true
                else
                    SendNUIMessage({
                        action = 'openMeter',
                        toggle = false
                    })
                    meterIsOpen = false
                    if nearPlayer then
                        TriggerServerEvent('qb-taxi:server:showMeterPass', nearPlayer.id, true)
                    end
                end
                TriggerServerEvent('qb-taxi:server:showMeterPass', nearPlayer)
            end
        else
            exports.qbx_core:Notify(Lang:t('error.missing_meter'), 'error')
        end
    else
        exports.qbx_core:Notify(Lang:t('error.no_vehicle'), 'error')
    end
end)

RegisterNetEvent('qb-taxi:client:enableMeter', function()
    if NpcData.Active then
        exports.qbx_core:Notify(Lang:t('error.already_mission'), 'error')
    else
        if meterIsOpen then
            SendNUIMessage({
                action = 'toggleMeter'
            })
        else
            exports.qbx_core:Notify(Lang:t('error.not_active_meter'), 'error')
        end
    end
end)

RegisterNetEvent('qb-taxi:client:resetMeter', function()
    if NpcData.Active then
        if not NpcData.NpcTaken then
            if meterIsOpen then
                stopNpcMission()
            else
                exports.qbx_core:Notify(Lang:t('error.not_active_meter'), 'success')
            end
        else
            exports.qbx_core:Notify(Lang:t('error.already_mission'), 'error')
        end
    else
        if meterIsOpen then
            resetMeter()
            exports.qbx_core:Notify(Lang:t('error.meter_reset'), 'success')
        else
            exports.qbx_core:Notify(Lang:t('error.not_active_meter'), 'success')
        end
    end
end)

RegisterNetEvent('qb-taxi:client:toggleMuis', function()
    Wait(400)
    if meterIsOpen then
        if not mouseActive then
            SetNuiFocus(true, true)
            mouseActive = true
        end
    else
        exports.qbx_core:Notify(Lang:t('error.no_meter_sight'), 'error')
    end
end)

RegisterNetEvent('qb-taxijob:client:requestcab', function()
    taxiGarage()
end)

-- NUI Callbacks

RegisterNUICallback('enableMeter', function(data, cb)
    meterActive = data.enabled
    if not meterActive then resetMeter() end
    lastLocation = GetEntityCoords(cache.ped)
    cb('ok')
end)

RegisterNUICallback('hideMouse', function(_, cb)
    SetNuiFocus(false, false)
    mouseActive = false
    cb('ok')
end)

-- Threads
CreateThread(function()
    while true do
        Wait(2000)
        calculateFareAmount()
    end
end)

CreateThread(function()
    while true do
        if not cache.vehicle then
            if meterIsOpen then
                SendNUIMessage({
                    action = 'openMeter',
                    toggle = false
                })
                meterIsOpen = false
            end
        end
        Wait(200)
    end
end)

local function init()
    if sharedConfig.usingJob then
        if QBX.PlayerData.job.name == 'taxi' then
            setupGarageZone()
            setupTaxiParkingZone()
            setLocationsBlip()
        end
    else
        setupGarageZone()
        setupTaxiParkingZone()
        setLocationsBlip()
    end
end

RegisterNetEvent('QBCore:Client:OnJobUpdate', function()
    if sharedConfig.usingJob then
        destroyGarageZone()
        destroyTaxiParkingZone()
        init()
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
    init()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
end)

CreateThread(function()
    if not isLoggedIn then return end
    init()
end)