local Shared = require 'shared/c-config'
local notify = JobUtilsNotify
local function SpawnPed()
    for _, p in pairs(Shared.Duty) do
        local model = p.model
        local coords = p.coords
        local heading = p.heading

        RequestModel(model) 
        while not HasModelLoaded(model) do
            Wait(10)
        end

        local ped = CreatePed(4, model, coords.x, coords.y, coords.z - 1.0, heading, true, true)

        SetEntityInvincible(ped, false) 

        SetBlockingOfNonTemporaryEvents(ped, true)
        FreezeEntityPosition(ped, false)

        -- Model niet meer nodig
        SetModelAsNoLongerNeeded(model)

        -- Logic voor target
        exports.ox_target:addLocalEntity(ped, {
            {
                name = p.name,
                label = p.label,
                distance = p.distance,
                icon = p.icon,
                onSelect = function()
                    --local player = Ox.GetPlayer()
                    TriggerServerEvent('jobutils:duty:toggle')

                    if Config.Debug then
                        print("duty toggle debug")
                    end
                    
                    notify({ description = 'Het is gelukt!', type = 'success'})
                end
            }
        })


        return ped
    end
end

local function DeletePedSafe(ped)
    if ped and DoesEntityExist(ped) then
        DeleteEntity(ped)
    end
end

local spawnedPed = nil

local function Zones()
    for _, z in pairs(Shared.Duty) do
        lib.zones.box({
            name = "spawnped_zone",
            coords = z.zonecoords,
            size = z.zonesize,
            rotation = 90.0,
            debug = false,

            onEnter = function()
                if not spawnedPed then
                    spawnedPed = SpawnPed()
                    if Config.Debug then 
                        print("Ped gespawned!")
                    end
                end
            end,

            onExit = function()
                if spawnedPed then
                    DeletePedSafe(spawnedPed)
                    spawnedPed = nil
                    if Config.Debug then
                        print("Ped verwijderd!")
                    end
                end
            end
        })
    end
end

local zone = Zones()
