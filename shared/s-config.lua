Shared = {}

Shared.DutyGroups = {
    police = true,
    ambulance = true,
    mechanic = true,
}

-- hoe vaak salaris komt (in minuten)
Shared.PayoutInterval = 10

-- Salarissen per groep + grade
-- Gebruik exact de group-naam zoals ox_core 'm leest
Shared.Salaries = {
    police = {
        [1] = 700,   -- grade 1
        [2] = 900,   -- grade 2 (sergeant)
        [3] = 1200,  -- grade 3 (command)
    },

    ambulance = {
        [0] = 400,
        [1] = 650,
        [2] = 850,
    },

    mechanic = {
        [0] = 350,
        [1] = 500,
    },

    lawyer = {
        [1] = 400,
        [2] = 500
    }
}



return Shared 