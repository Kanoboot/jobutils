local Shared = require 'shared/s-config'

--- To-do
--- Functies checken van automatische uitbetaling, lib.logger toevoegen bij paysalary functie, debugs weg configgen


local function PaySalary(playerId)
    local player = GetPlayer(playerId)
    local account = GetAccount(playerId)

    if Config.Debug then 
        print(">>> Player object:", player)
    end 
    
    if not player then return end

    local groups = player.getGroups()

    if Config.Debug then 
        print(">>> Groups:", json.encode(groups))
    end
    

    local selectedGroup = nil
    local grade = nil

    for groupName, groupGrade in pairs(groups) do
        if Shared.Salaries[groupName] then
            selectedGroup = groupName
            grade = groupGrade
            break
        end
    end

    if not selectedGroup then
        print("^1Geen geldige salary group gevonden voor speler^0")
        return
    end

    if Config.Debug then
        print(">>> Using group:", selectedGroup, "grade:", grade)
    end
    

    -- Salaris opzoeken
    local amount = Shared.Salaries[selectedGroup] and Shared.Salaries[selectedGroup][grade]
    if Config.Debug then 
        print(">>> Salary amount:", amount)
    end

    if not amount then
        print("^1Geen salary gevonden voor grade^0")
        return
    end

    account.addBalance({ amount = amount, message = ('Salary payout (%s grade %s)'):format(selectedGroup, grade) })
    --lib.logger(playerId, 'Salaris', ('Salaris Uitbetaald %s'):format(amount))

    TriggerClientEvent('jobutils:notify', playerId, {type = 'success', description = ('Je hebt je salaris ontvangen: $%s'):format(amount)})

    if Config.Debug then 
        print(('^2[SALARY] %s kreeg $%s voor %s grade %s^0'):format(playerId, amount, selectedGroup, grade))
    end
end

-- interval = the timer from config

CreateThread(function()
    local interval = Shared.PayoutInterval * 60000

    if Config.Debug then 
        print(('^3[SALARY] Salary system gestart (%s min)^0'):format(Shared.PayoutInterval))
    end
    
    while true do
        Wait(interval)

        if Config.Debug then
            print('^2[SALARY] Weekly payout cycle gestart^0')
        end
        
        local players = GetPlayers() -- Fivem Function not in bridge or something 

        for _, src in ipairs(players) do
            src = tonumber(src) 

            local oxPlayer = GetPlayer(src)

            if oxPlayer then
                PaySalary(src)
            else
                print(("^1[SALARY] Geen ox player voor id %s (skip)^0"):format(src))
            end
        end
    end
end)

--- Debug salary test
RegisterCommand('salaristest', function(playerId)
    PaySalary(playerId)
    print('Salaris uitbetaling debug')
end, false)
