local Shared = require 'shared/c-config'
local notify = JobUtilsNotify


local function managementMenu()

    -- menu registration 

    lib.registerContext({
    id = 'management_menu',
    title = 'Job Management Menu',
    options = {
        {
            title = 'Aannemen',
            description = 'Spelers in de buurt aannemen',
            icon = 'fa-solid fa-briefcase',
            onSelect = function()
                print('Debug event functie werkt kut')
            end
        },
    }
    })

    for _, p in pairs(Shared.Bossmenu) do
        exports.ox_target:addBoxZone({
            coords = p.coords,
            name = p.boxname,
            size = vector3(2, 2, 2),
            options = {
                label = p.label,
                distance = 2.0,
                icon = 'fa-solid fa-briefcase',
                onSelect = function()
                    lib.showContext('management_menu')
                    print('Target event debug')
                end
            }
        })
    end
end

local menu = managementMenu()

--[[
---- Vanuit qbox 
---
--@return table
local function findPlayers()
    local coords = GetEntityCoords(cache.ped)
    local closePlayers = lib.getNearbyPlayers(coords, 10, false)
    for _, v in pairs(closePlayers) do
        v.id = GetPlayerServerId(v.id)
    end
    return lib.callback.await('qbx_management:server:getPlayers', false, closePlayers)
end

-- Presents a menu to manage a specific employee including changing grade or firing them
--@param player table Player data for managing a specific employee
--@param groupName string Name of job/gang of employee being managed
--@param groupType GroupType
local function manageEmployee(player, groupName, groupType)
    local employeeMenu = {}
    local employeeLoop = groupType == 'gang' and GANGS[groupName].grades or JOBS[groupName].grades
    for groupGrade, gradeTitle in pairs(employeeLoop) do
        employeeMenu[#employeeMenu + 1] = {
            title = gradeTitle.name,
            description = locale('menu.grade')..groupGrade,
            onSelect = function()
                lib.callback.await('qbx_management:server:updateGrade', false, player.cid, player.grade, tonumber(groupGrade), groupType)
                OpenBossMenu(groupType)
            end,
        }
    end

    table.sort(employeeMenu, function(a, b)
        return a.description < b.description
    end)

    employeeMenu[#employeeMenu + 1] = {
        title = groupType == 'gang' and locale('menu.expel_gang') or locale('menu.fire_employee'),
        icon = 'user-large-slash',
        onSelect = function()
            lib.callback.await('qbx_management:server:fireEmployee', false, player.cid, groupType)
            OpenBossMenu(groupType)
        end,
    }

    lib.registerContext({
        id = 'memberMenu',
        title = player.name,
        menu = 'memberListMenu',
        options = employeeMenu,
    })

    lib.showContext('memberMenu')
end

---Opens a menu to edit a grade
--@param groupType GroupType
--@param groupData Job|Gang
--@param grade integer
local function editGrade(groupType, groupData, grade)
    local gradeData = groupData.grades[grade]
    local rows = {
        { type = 'input', label = locale('grade.label'), default = gradeData.name, required = true },
    }
    if groupType == 'job' then
        rows[#rows+1] = { type = 'number', label = locale('grade.pay'), default = gradeData.payment }
        rows[#rows+1] = { type = 'checkbox', label = locale('grade.boss'), checked = gradeData.isboss }
        rows[#rows+1] = { type = 'checkbox', label = locale('grade.bank'), checked = gradeData.bankAuth }
    end
    local data = lib.inputDialog(("%s: %s"):format(groupData.label, gradeData.name), rows)

    if data then
        gradeData.name = data[1]
        if groupType == 'job' then
            gradeData.payment = data[2]
            gradeData.isboss = data[3]
            gradeData.bankAuth = data[4]
        end
        lib.callback.await('qbx_management:server:modifyGrade', nil, groupType, grade, gradeData)
    end

    lib.showContext('openBossMenu')
end

-- Presents a menu of employees the work for a job or gang.
-- Allows selection of an employee to perform further actions
--@param groupType GroupType
local function employeeList(groupType)
    local employeesMenu = {}
    local groupName = QBX.PlayerData[groupType].name
    local employees = lib.callback.await('qbx_management:server:getEmployees', false, groupName, groupType)
    for _, employee in pairs(employees) do
        local employeesData = {
            title = employee.name,
            description = groupType == 'job' and JOBS[groupName].grades[employee.grade].name or GANGS[groupName].grades[employee.grade].name,
            onSelect = function()
                manageEmployee(employee, groupName, groupType)
            end,
        }
        if employee.hours and employee.last_checkin then
            employeesData.metadata = {
                { label = locale('menu.employee_status'), value = employee.onduty and locale('menu.on_duty') or locale('menu.off_duty') },
                { label = locale('menu.hours_in_days'), value = employee.hours },
                { label = locale('menu.last_checkin'), value = employee.last_checkin },
            }
        end
        employeesMenu[#employeesMenu + 1] = employeesData
    end

    lib.registerContext({
        id = 'memberListMenu',
        title = groupType == 'gang' and locale('menu.manage_gang') or locale('menu.manage_employees'),
        menu = 'openBossMenu',
        options = employeesMenu,
    })

    lib.showContext('memberListMenu')
end

-- Presents a list of possible employees to hire for a job or gang.
--@param groupType GroupType
local function showHireMenu(groupType)
    local hireMenu = {}
    local players = findPlayers()
    local hireName = QBX.PlayerData[groupType].name
    for _, player in pairs(players) do
        if player[groupType].name ~= hireName then
            hireMenu[#hireMenu + 1] = {
                title = player.name,
                description = locale('menu.citizen_id')..player.citizenid..' - '..locale('menu.id')..player.source,
                onSelect = function()
                    lib.callback.await('qbx_management:server:hireEmployee', false, player.source, groupType)
                    OpenBossMenu(groupType)
                end,
            }
        end
    end

    lib.registerContext({
        id = 'hireMenu',
        title = groupType == 'gang' and locale('menu.hire_gang') or locale('menu.hire_civilians'),
        menu = 'openBossMenu',
        options = hireMenu,
    })

    lib.showContext('hireMenu')
end

---Opens grade management menu
--@param groupType GroupType
local function showGradeMenu(groupType)
    local gradeOpts = {}
    local groupName = QBX.PlayerData[groupType].name
    local groupData = groupType == 'gang' and GANGS[groupName] or JOBS[groupName]

    for i = 0, #groupData.grades do
        local grade = groupData.grades[i]
        gradeOpts[#gradeOpts+1] = {
            title = grade.name,
            description = locale(("menu.manage_%s_grade"):format(groupType)),
            icon = 'pen-to-square',
            disabled = QBX.PlayerData[groupType].grade.level < i,
            onSelect = function()
                editGrade(groupType, groupData, i)
            end,
        }
    end

    lib.registerContext({
        id = 'gradeMenu',
        title = locale(("menu.manage_%s_grades"):format(groupType)),
        menu = 'openBossMenu',
        options = gradeOpts,
    })

    lib.showContext('gradeMenu')
end
--]]