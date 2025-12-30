local function callSkillCheck(difficulties, inputs)
    if lib ~= nil and type(lib.skillCheck) == 'function' then
        return lib.skillCheck(difficulties, inputs)
    end
    if exports ~= nil and exports.ox_lib ~= nil then
        local ok, res = pcall(function() return exports.ox_lib:skillCheck(difficulties, inputs) end)
        if ok then return res end
    end
    if exports ~= nil and exports['ox_lib'] ~= nil then
        local ok, res = pcall(function() return exports['ox_lib']:skillCheck(difficulties, inputs) end)
        if ok then return res end
    end
    return false
end

local function showNotify(text)
    if lib ~= nil and type(lib.notify) == 'function' then
        lib.notify({title = "Schneeball", description = text, type = "success"})
        return
    end
    if exports ~= nil and exports.ox_lib ~= nil and type(exports.ox_lib.notify) == 'function' then
        exports.ox_lib:notify({title = "Schneeball", description = text, type = "success"})
        return
    end
    if exports ~= nil and exports['ox_lib'] ~= nil then
        local ok = pcall(function() exports['ox_lib']:notify({title = "Schneeball", description = text, type = "success"}) end)
        if ok then return end
    end
    SetNotificationTextEntry("STRING")
    AddTextComponentSubstringPlayerName(text)
    DrawNotification(false, true)
end
    local snowHandledVehicles = {}

    local function applySnowGrip(veh)
        if not DoesEntityExist(veh) then return end
        if snowHandledVehicles[veh] then return end
        local ok, orig = pcall(function()
            return {
                fTractionCurveMin = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fTractionCurveMin'),
                fTractionCurveMax = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fTractionCurveMax'),
                fLowSpeedTractionLossMult = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fLowSpeedTractionLossMult')
            }
        end)
        if not ok then return end
        snowHandledVehicles[veh] = orig
        if Config.SnowHandling and Config.SnowHandling.Enabled then
            local cfg = Config.SnowHandling
            SetVehicleHandlingFloat(veh, 'CHandlingData', 'fTractionCurveMin', orig.fTractionCurveMin * cfg.TractionMultiplier)
            SetVehicleHandlingFloat(veh, 'CHandlingData', 'fTractionCurveMax', orig.fTractionCurveMax * cfg.TractionMultiplier)
            SetVehicleHandlingFloat(veh, 'CHandlingData', 'fLowSpeedTractionLossMult', orig.fLowSpeedTractionLossMult * cfg.LowSpeedTractionLossMultiplier)
        end
    end

    local function resetSnowGrip(veh)
        if not DoesEntityExist(veh) then return end
        if not snowHandledVehicles[veh] then return end
        local orig = snowHandledVehicles[veh]
        SetVehicleHandlingFloat(veh, 'CHandlingData', 'fTractionCurveMin', orig.fTractionCurveMin)
        SetVehicleHandlingFloat(veh, 'CHandlingData', 'fTractionCurveMax', orig.fTractionCurveMax)
        SetVehicleHandlingFloat(veh, 'CHandlingData', 'fLowSpeedTractionLossMult', orig.fLowSpeedTractionLossMult)
        snowHandledVehicles[veh] = nil
    end
Citizen.CreateThread(function()
    
    local showHelp = true
    local loaded = false
    
    while true do
        if Config.Weather then
            SetWeatherTypeNowPersist('XMAS')
        end
        Citizen.Wait(0)
        if IsNextWeatherType('XMAS') then 
            N_0xc54a08c85ae4d410(3.0)
            
            SetForceVehicleTrails(true)
            SetForcePedFootstepsTracks(true)
            local playerPed = PlayerPedId()
            if IsPedInAnyVehicle(playerPed, false) then
                local veh = GetVehiclePedIsIn(playerPed, false)
                applySnowGrip(veh)
            end
            
            if not loaded then
                RequestScriptAudioBank("ICE_FOOTSTEPS", false)
                RequestScriptAudioBank("SNOW_FOOTSTEPS", false)
                RequestNamedPtfxAsset("core_snow")
                while not HasNamedPtfxAssetLoaded("core_snow") do
                    Citizen.Wait(0)
                end
                UseParticleFxAssetNextCall("core_snow")
                loaded = true
            end
            RequestAnimDict('anim@mp_snowball')
            if IsControlJustReleased(0, 47) and not IsPedInAnyVehicle(GetPlayerPed(-1), true) and not IsPlayerFreeAiming(PlayerId()) and not IsPedSwimming(PlayerPedId()) and not IsPedSwimmingUnderWater(PlayerPedId()) and not IsPedRagdoll(PlayerPedId()) and not IsPedFalling(PlayerPedId()) and not IsPedRunning(PlayerPedId()) and not IsPedSprinting(PlayerPedId()) and GetInteriorFromEntity(PlayerPedId()) == 0 and not IsPedShooting(PlayerPedId()) and not IsPedUsingAnyScenario(PlayerPedId()) and not IsPedInCover(PlayerPedId(), 0) then -- check if the snowball should be picked up
                    RequestAnimDict('anim@mp_snowball')
                    while not HasAnimDictLoaded('anim@mp_snowball') do Citizen.Wait(0) end
                    TaskPlayAnim(PlayerPedId(), 'anim@mp_snowball', 'pickup_snowball', 8.0, -1, -1, 1, 0, 0, 0, 0)
                    local success = callSkillCheck({'easy', 'easy', 'medium',}, {'e'})
                    ClearPedTasks(PlayerPedId())
                    if success then
                        if Config.ESX then
                            TriggerServerEvent('snowballs:add-item', source)
                            showNotify('Du hast einen perfekten Schneeball bekommen!')
                        else
                            GiveWeaponToPed(GetPlayerPed(-1), GetHashKey('WEAPON_SNOWBALL'), 1, false, true)
                            showNotify('Du hast einen perfekten Schneeball bekommen!')
                        end
                    else
                        showNotify('Der Schneeball ist auseinandergefallen. Suche dir eine neue Stelle mit besserem Schnee.')
                    end
                    Citizen.Wait(1950)
                end
        else
            if loaded then N_0xc54a08c85ae4d410(0.0) end
            loaded = false
            RemoveNamedPtfxAsset("core_snow")
            ReleaseNamedScriptAudioBank("ICE_FOOTSTEPS")
            ReleaseNamedScriptAudioBank("SNOW_FOOTSTEPS")
            SetForceVehicleTrails(false)
            SetForcePedFootstepsTracks(false)
            for veh,_ in pairs(snowHandledVehicles) do
                resetSnowGrip(veh)
            end
        end
        if GetSelectedPedWeapon(PlayerPedId()) == GetHashKey('WEAPON_SNOWBALL') then
            SetPlayerWeaponDamageModifier(PlayerId(), Config.Damage)
        end
    end
end)

RegisterNetEvent('schneeball:clientNotify', function(msg)
    if msg and type(msg) == 'string' then
        showNotify(msg)
    end
end)

RegisterNetEvent('schneeball:attempt_build', function()
    showNotify('Versuche Schneemann herzustellen...')
    RequestAnimDict('amb@world_human_gardener_plant@male@enter')
    while not HasAnimDictLoaded('amb@world_human_gardener_plant@male@enter') do Citizen.Wait(0) end
    TaskStartScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_AA_SMOKE', 0, true)
    Citizen.Wait(2000)
    ClearPedTasks(PlayerPedId())
    -- Perform 5 easy skillchecks (uses lib.skillCheck / ox_lib if available, falls back otherwise)
    local rounds = 5
    for i = 1, rounds do
        local ok = callSkillCheck({'easy', 'easy', 'easy'}, {'e'})
        if not ok then
            showNotify(('Skillcheck fehlgeschlagen (%d/%d)'):format(i, rounds))
            return
        end
        Citizen.Wait(200)
    end
    showNotify('Alle Skillchecks bestanden! Baue Schneemann...')
    TriggerServerEvent('schneeball:complete_build')
end)

local spawnedSnowmen = {}

RegisterNetEvent('schneeball:spawn_snowman', function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local forward = GetEntityForwardVector(ped)
    local spawnPos = vector3(pos.x + forward.x * 1.5, pos.y + forward.y * 1.5, pos.z)

    local props = Config.Snowman and Config.Snowman.Props or {'xm3_prop_xm3_snowman_01a','xm3_prop_xm3_snowman_01b','xm3_prop_xm3_snowman_01c'}
    local propName = props[math.random(1, #props)]
    local model = GetHashKey(propName)

    RequestModel(model)
    local tries = 0
    while not HasModelLoaded(model) and tries < 100 do
        Citizen.Wait(10)
        tries = tries + 1
    end
    if not HasModelLoaded(model) then
        showNotify('Fehler: Prop konnte nicht geladen werden')
        return
    end

    local obj = CreateObject(model, spawnPos.x, spawnPos.y, spawnPos.z, true, true, false)
    PlaceObjectOnGroundProperly(obj)
    SetEntityHeading(obj, GetEntityHeading(ped))
    Citizen.Wait(50)
    spawnedSnowmen[#spawnedSnowmen+1] = obj
    showNotify('Du hast einen Schneemann gebaut!')
end)

Citizen.CreateThread(function()
    while true do
        local wait = Config.Snowman and Config.Snowman.CheckInterval or 700
        Citizen.Wait(wait)
        if #spawnedSnowmen == 0 then goto cont end
        for i = #spawnedSnowmen,1,-1 do
            local obj = spawnedSnowmen[i]
            if not obj or not DoesEntityExist(obj) then
                table.remove(spawnedSnowmen, i)
            else
                local objCoords = GetEntityCoords(obj)
                local veh = GetClosestVehicle(objCoords.x, objCoords.y, objCoords.z, 3.5, 0, 70)
                if veh and veh ~= 0 and DoesEntityExist(veh) then
                    local speed = GetEntitySpeed(veh)
                    local breakSpeed = Config.Snowman and Config.Snowman.BreakSpeed or 4.0
                    local dist = #(objCoords - GetEntityCoords(veh))
                    if speed >= breakSpeed and dist <= 3.5 then
                        UseParticleFxAssetNextCall('core_snow')
                        StartParticleFxNonLoopedAtCoord('ent_ray_impact_snow', objCoords.x, objCoords.y, objCoords.z + 0.3, 0.0, 0.0, 0.0, 1.0, false, false, false)
                        DeleteObject(obj)
                        table.remove(spawnedSnowmen, i)
                    end
                end
            end
        end
        ::cont::
    end
end)
