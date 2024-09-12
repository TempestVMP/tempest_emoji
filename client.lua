local emojiMenuState = false
local emojiActive = {}
local emojiBusy = false

RegisterKeyMapping('emojiMenu', 'Open emoji menu', 'keyboard', Cfg.openMenuKey)

RegisterCommand('emojiMenu', function()
    emojiMenuState = not emojiMenuState
    SetNuiFocus(emojiMenuState, emojiMenuState)
    SendNUIMessage({
        action = 'uiState',
        enable = emojiMenuState
    })
end, false)

RegisterNUICallback('nuiReady', function(_, resultCallback)
    resultCallback(Cfg.emoji)
end)

RegisterNUICallback('exit', function(_, resultCallback)
    emojiMenuState = false
    SetNuiFocus(emojiMenuState, emojiMenuState)
    resultCallback('ok')
end)

RegisterNUICallback('selectedEmoji', function(body, resultCallback)
    if body.link then
        if not emojiBusy then
            emojiBusy = true
            TriggerServerEvent('tempest_emoji:sharingEmoji', body.link)
            Wait(Cfg.duration)
            emojiBusy = false
        else
            print('Cooldown.')
        end
    end
    resultCallback('ok')
end)

RegisterNetEvent('tempest_emoji:sharedEmoji', function(playerId, link)
    emojiActive[tonumber(playerId)] = {link = link, time = GetGameTimer() + Cfg.duration}
end)

CreateThread(function()
    local htmlTemp = ''
    local distance = Cfg.distance
    Cfg.distance = nil
    while true do
        local sleep = 500
        local currentTime, html = GetGameTimer(), ''
        for k, v in pairs(emojiActive) do
            local player = GetPlayerFromServerId(k)
            if NetworkIsPlayerActive(player) then
                local playerId = PlayerId()
                local sourcePed, targetPed = GetPlayerPed(player), PlayerPedId()
                local sourceCoords, targetCoords = GetEntityCoords(sourcePed), GetEntityCoords(targetPed)
                local pedCoords = GetPedBoneCoords(sourcePed, 12844, 0.0, 0.0, 0.0)
                if player == playerId or #(sourceCoords - targetCoords) < distance then
                    local onScreen, xS, yS = GetHudScreenPositionFromWorldPosition(pedCoords.x, pedCoords.y, pedCoords.z + 0.49)
                    if not onScreen then
                        sleep = 10
                        html = '<span class="emoji-activated" style=\"left: '.. xS * 88 ..'%;top: '.. yS * 98 ..'%; \"><img src="'..v.link..'"></span>'
                    end
                end
            end
            if v.time <= currentTime then
                emojiActive[k] = nil
            end
        end
        if htmlTemp ~= html then
            SendNUIMessage({ action = 'draw', html = html })
            htmlTemp = html
        end
        Wait(sleep)
    end
end)
