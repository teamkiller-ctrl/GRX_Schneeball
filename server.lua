local ESX
if GetResourceState('es_extended') == 'started' then
    ESX = exports['es_extended']:getSharedObject()
end

RegisterNetEvent('snowballs:add-item', function()
    local src = source
    if Config.ESX and ESX then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            xPlayer.addInventoryItem('WEAPON_SNOWBALL', 1)
        end
        return
    end

    if exports ~= nil and exports.ox_inventory ~= nil then
        local ok, res = pcall(function()
            return exports.ox_inventory:AddItem(src, 'WEAPON_SNOWBALL', 1, {durability = Config.StartDurability})
        end)
        if not ok then
            print('schneeball: failed to add item via ox_inventory', res)
        end
    else
        print('schneeball: no supported inventory found to add item')
    end
end)

-- Usable item (ESX): right-click/use the snowball to attempt building a snowman
if Config.ESX and ESX then
    ESX.RegisterUsableItem('WEAPON_SNOWBALL', function(source)
        TriggerClientEvent('schneeball:attempt_build', source)
    end)
end

-- Generic server event that client or inventory UI can call to attempt building a snowman
RegisterNetEvent('schneeball:try_build', function()
    local src = source
    -- Immediately spawn a snowman for the caller; no items required or removed
    TriggerClientEvent('schneeball:spawn_snowman', src)
end)

-- Finalize build: remove 5 snowballs (if available) and spawn the snowman for the player
RegisterNetEvent('schneeball:complete_build', function()
    local src = source
    local needed = 5

    -- ESX handling
    if Config.ESX and ESX then
        local xPlayer = ESX.GetPlayerFromId(src)
        if not xPlayer then return end
        local count_weapon = xPlayer.getInventoryItem('WEAPON_SNOWBALL') and xPlayer.getInventoryItem('WEAPON_SNOWBALL').count or 0
        if count_weapon >= needed then
            xPlayer.removeInventoryItem('WEAPON_SNOWBALL', needed)
            TriggerClientEvent('schneeball:spawn_snowman', src)
        else
            TriggerClientEvent('schneeball:clientNotify', src, 'Du brauchst '..needed..' Schneebälle um einen Schneemann zu bauen')
        end
        return
    end

    -- ox_inventory handling
    if exports ~= nil and exports.ox_inventory ~= nil then
        local okW, resW = pcall(function()
            return exports.ox_inventory:GetItemCount(src, 'WEAPON_SNOWBALL')
        end)
        if okW and type(resW) == 'number' and resW >= needed then
            local ok2, res2 = pcall(function()
                return exports.ox_inventory:RemoveItem(src, 'WEAPON_SNOWBALL', needed)
            end)
            if ok2 then
                TriggerClientEvent('schneeball:spawn_snowman', src)
            else
                TriggerClientEvent('schneeball:clientNotify', src, 'Fehler beim Entfernen der Schneebälle')
            end
        else
            TriggerClientEvent('schneeball:clientNotify', src, 'Du brauchst '..needed..' Schneebälle um einen Schneemann zu bauen')
        end
        return
    end

    -- Fallback: no inventory system
    TriggerClientEvent('schneeball:clientNotify', src, 'Kein Inventarsystem gefunden, Schneemann kann nicht gebaut werden')
end)

if Config.MeltEnabled then
    CreateThread(function()
        while true do
            local waitTime = (Config.MeltIntervalSeconds or 60) * 1000
            Wait(waitTime)
            local players = GetPlayers()
            for _, pid in ipairs(players) do
                local playerId = tonumber(pid)
                if not playerId then goto continue_player end

                if exports == nil or exports.ox_inventory == nil then
                    if Config.Debug then print('schneeball: ox_inventory not available') end
                    goto continue_player
                end

                local itemNames = {'WEAPON_SNOWBALL'}
                for _, itemName in ipairs(itemNames) do
                    local ok, slots = pcall(function()
                        return exports.ox_inventory:GetSlotsWithItem(playerId, itemName)
                    end)
                    if not ok then
                        if Config.Debug then print(('schneeball: GetSlotsWithItem failed for %s: %s'):format(itemName, tostring(slots))) end
                    else
                        if slots and next(slots) then
                            for k, slot in pairs(slots) do
                                local meta = slot.metadata or {}
                                local cur = tonumber(meta.durability) or nil
                                if cur ~= nil then
                                    if Config.Debug then print(('schneeball: player %s slot %s (%s) durability %s'):format(playerId, tostring(k), tostring(slot.slot), tostring(cur))) end
                                    local newDur = cur - (Config.MeltAmount or 10)
                                    if cur > (Config.StartDurability / 2) and newDur <= (Config.StartDurability / 2) then
                                        TriggerClientEvent('schneeball:clientNotify', playerId, 'Dein Schneeball ist zur Hälfte geschmolzen')
                                    end
                                    if newDur <= 0 then
                                        local ok2, res2 = pcall(function()
                                            return exports.ox_inventory:RemoveItem(playerId, slot.name or itemName, 1, nil, slot.slot)
                                        end)
                                        if ok2 then
                                            TriggerClientEvent('schneeball:clientNotify', playerId, 'Dein Schneeball ist geschmolzen')
                                        end
                                        if Config.Debug and not ok2 then print('schneeball: RemoveItem failed', res2) end
                                    else
                                        local ok3, res3 = pcall(function()
                                            return exports.ox_inventory:SetDurability(playerId, slot.slot, newDur)
                                        end)
                                        if Config.Debug and not ok3 then print('schneeball: SetDurability failed', res3) end
                                    end
                                else
                                    if Config.Debug then print(('schneeball: player %s slot %s has no durability metadata'):format(playerId, tostring(k))) end
                                end
                            end
                        end
                    end
                end
                ::continue_player::
            end
        end
    end)
end

local savedFile = 'saved_snowmen.json'
local savedSnowmen = {}

local function loadSaved()
    local data = LoadResourceFile(GetCurrentResourceName(), savedFile)
    if data and data ~= '' then
        local ok, parsed = pcall(function() return json.decode(data) end)
        if ok and type(parsed) == 'table' then
            savedSnowmen = parsed
        else
            savedSnowmen = {}
        end
    else
        savedSnowmen = {}
    end
end

local function saveSaved()
    local ok, err = pcall(function()
        SaveResourceFile(GetCurrentResourceName(), savedFile, json.encode(savedSnowmen), -1)
    end)
    if not ok then print('schneeball: failed to save saved_snowmen.json', err) end
end

loadSaved()

RegisterNetEvent('schneeball:request_saved', function()
    local src = source
    local toSend = {}
    for _, v in ipairs(savedSnowmen) do
        if not v.destroyed then table.insert(toSend, v) end
    end
    TriggerClientEvent('schneeball:load_saved_snowmen', src, toSend)
end)

RegisterNetEvent('schneeball:register_snowman', function(data)
    if not data or type(data) ~= 'table' then return end
    data.destroyed = false
    table.insert(savedSnowmen, data)
    saveSaved()
end)

RegisterNetEvent('schneeball:mark_destroyed', function(data)
    if not data or type(data) ~= 'table' then return end
    for _, v in ipairs(savedSnowmen) do
        if v.model == data.model then
            local dx = (v.x or 0) - (data.x or 0)
            local dy = (v.y or 0) - (data.y or 0)
            local dz = (v.z or 0) - (data.z or 0)
            if (dx*dx + dy*dy + dz*dz) <= 1.0 then
                v.destroyed = true
            end
        end
    end
    saveSaved()
end)

local function checkForUpdate()
    local repoApi = 'https://api.github.com/repos/teamkiller-ctrl/GRX_Schneeball/releases/latest'
    PerformHttpRequest(repoApi, function(statusCode, response, headers)
        if statusCode == 200 and response then
            local ok, data = pcall(function() return json.decode(response) end)
            if ok and type(data) == 'table' then
                local latest = data.tag_name or data.name
                if latest then
                    local current = Config.Version or '0.0'
                    if tostring(latest) ~= tostring(current) then
                        print(('schneeball: update available — local=%s latest=%s'):format(current, latest))
                        local download_link = data.html_url or data.zipball_url or (data.assets and data.assets[1] and data.assets[1].browser_download_url) or 'https://github.com/teamkiller-ctrl/GRX_Schneeball/releases'
                        print(('schneeball: Neue Version verfügbar (%s) — Download: %s'):format(tostring(latest), tostring(download_link)))
                    else
                        if Config.Debug then print(('schneeball: up-to-date (%s)'):format(current)) end
                    end
                else
                    print('schneeball: no tag_name or name found in the GitHub API response')
                end
            else
                print('schneeball: failed to parse GitHub response')
            end
        else
            print(('schneeball: update check failed, status %s'):format(tostring(statusCode)))
        end
    end, 'GET', '', { ['User-Agent'] = 'FiveM-Schneeball-VersionCheck' })
end

CreateThread(function()
    Wait(5000)
    pcall(checkForUpdate)
    while true do
        Wait(6 * 60 * 60 * 1000)
        pcall(checkForUpdate)
    end
end)
