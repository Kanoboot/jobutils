
-- Ox core 
function GetPlayer(id)
    if Config.Core == 'ox' then 
        return Ox.GetPlayer(id)
    end
end

function GetIdentifier(player)
    if Config.Core == 'ox' then
        return player.stateId
    end
end

function GetAccount(src)
    if Config.Core == 'ox' then
        local player = Ox.GetPlayer(src)
        if not player then return nil end

        local charId = player.charId or player.stateId

        if not charId then
            print("^1[ERROR] Geen charId/stateId gevonden voor speler^0")
            return nil
        end

        return Ox.GetCharacterAccount(charId)
    end
end
