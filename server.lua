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
            return exports.ox_inventory:AddItem(src, 'snowball', 1, {durability = Config.StartDurability})
        end)
        if not ok then
            print('schneeball: failed to add item via ox_inventory', res)
        end
    else
        print('schneeball: no supported inventory found to add item')
    end
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

                local itemNames = {'snowball', 'WEAPON_SNOWBALL'}
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

