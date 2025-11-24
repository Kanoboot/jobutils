-- Bridge funncties voor in de toekomst te kunnen bridgen


RegisterNetEvent('jobutils:notify', function(data)
    if Config.Notify == 'ox' then 
        lib.notify(data)
    end
end)

-- Helper functie zodat je ook client-side direct kan gebruiken
function JobUtilsNotify(data)
    if Config.Notify == 'ox' then 
        lib.notify(data)
    end
end

