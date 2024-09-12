
RegisterNetEvent('tempest_emoji:sharingEmoji', function(elink)
    local source = source
    TriggerClientEvent('tempest_emoji:sharedEmoji', -1, source, elink)
end)