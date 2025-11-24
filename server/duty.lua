local Shared = require 'shared/s-config'
--local Ox = exports.ox_core

-- Toggle duty status
RegisterNetEvent('jobutils:duty:toggle', function()
    local player = GetPlayer(source)
    local src = source

    local duty = player.get('duty')

    if duty == 1 then
        player.set('duty', 0, false)
        TriggerClientEvent('jobutils:notify', src, {type = 'success', description = 'Je bent uit dienst gegaan'})
    elseif duty == 0 or nil then 
        player.set('duty', 1, false)
        TriggerClientEvent('jobutils:notify', src, {type = 'success', description = 'Je bent in dienst gegaan'})
    end
end)

-- so to chatgpt
-- Duty debug command
RegisterCommand('dutydebug', function(source)
    local player = GetPlayer(source) 
    if not player then
        print("^1[DUTYDEBUG] Geen speler object gevonden.^0")
        return
    end

    local duty = player.get('duty')

    print("^3[DUTYDEBUG] Player:", source)
    print("^3[DUTYDEBUG] Duty metadata waarde:", tostring(duty))

    -- Extra debug: vergelijk de waarde
    if duty == 1 then
        print("^2[DUTYDEBUG] DUTY = 1 (speler staat IN dienst)^0")
    elseif duty == nil then
        print("^1[DUTYDEBUG] Duty is NIL (nooit gezet)^0")
    else
        print("^3[DUTYDEBUG] Duty is andere waarde:", duty, "^0")
    end
end, false)

