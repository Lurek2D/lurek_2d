local M = {}

local MONTH_SECONDS = 3.0
local SPEEDS = { 0, 1, 2, 4 }
local MONTH_NAMES = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" }

local function lower(v)
    return tostring(v or ""):lower()
end

local function clean_name(v)
    return tostring(v or "Unknown"):gsub("_", " ")
end

local function num(v, fallback)
    local n = tonumber(v)
    if n == nil then
        return fallback
    end
    return n
end

local function terrain_income(terrain)
    terrain = lower(terrain)
    if terrain == "sea" or terrain == "river" then return 0 end
    if terrain == "mountain" then return 2 end
    if terrain == "forest" then return 3 end
    if terrain == "desert" then return 1 end
    return 4
end

local function point_from_snap(snap)
    local c = snap and (snap.capital or snap.centroid)
    if type(c) == "table" then
        return c.x or c[1], c.y or c[2]
    end
    return nil, nil
end

local function add_log(state, text)
    table.insert(state.log, 1, state:date_string() .. " - " .. text)
    while #state.log > 8 do
        table.remove(state.log)
    end
end

local function country_copy(src)
    local out = {}
    for k, v in pairs(src) do
        out[k] = v
    end
    out.treasury = src.treasury or 0
    out.manpower = src.manpower or 0
    out.monthly_income = 0
    out.monthly_manpower = 0
    out.province_count = 0
    return out
end

local function province_blob(province)
    return lower(table.concat({
        province.name or "",
        province.continent or "",
        province.region or "",
        province.area or "",
        province.culture or "",
    }, " "))
end

local function sorted_numeric_keys(tbl)
    local keys = {}
    for key in pairs(tbl or {}) do
        if type(key) == "number" then
            keys[#keys + 1] = key
        end
    end
    table.sort(keys)
    return keys
end

local function sorted_string_keys(tbl)
    local keys = {}
    for key in pairs(tbl or {}) do
        if type(key) == "string" then
            keys[#keys + 1] = key
        end
    end
    table.sort(keys)
    return keys
end

local function striped_signature(ids)
    local out = {}
    for id, enabled in pairs(ids or {}) do
        if enabled and type(id) == "number" then
            out[#out + 1] = id
        end
    end
    table.sort(out)
    return table.concat(out, ",")
end

local function find_start_province(state, army_spec)
    local best = nil
    for _, id in ipairs(sorted_numeric_keys(state.provinces)) do
        local province = state.provinces[id]
        if province.owner == army_spec.tag then
            best = best or id
            local blob = province_blob(province)
            for _, keyword in ipairs(army_spec.province_keywords or {}) do
                if blob:find(lower(keyword), 1, true) then
                    return id
                end
            end
        end
    end
    return best
end

local function set_selected_army(state, army_id)
    state.selected_army_id = army_id
    for _, army in ipairs(state.armies) do
        army.selected = army.id == army_id
    end
end

local function owned_enemy_or_neutral(state, army, province)
    return province and province.owner ~= army.tag and province.owner ~= "SEA"
end

local function finish_army_move(state, army)
    army.province_id = army.target_id
    army.target_id = nil
    army.eta = 0
    army.move_total = 0
    local province = state.provinces[army.province_id]
    if owned_enemy_or_neutral(state, army, province) then
        local old_owner = province.owner
        province.owner = army.tag
        province.unrest = math.min(10, province.unrest + 3)
        state.revision = state.revision + 1
        state.style_revision = state.style_revision + 1
        state.border_revision = state.border_revision + 1
        add_log(state, army.name .. " occupies " .. province.name .. " from " .. (state.countries[old_owner] and state.countries[old_owner].name or old_owner))
    else
        add_log(state, army.name .. " arrives in " .. (province and province.name or "unknown province"))
    end
end

local function movement_cost(state, province_id)
    local province = state.provinces[province_id]
    if not province then return 4 end
    local terrain = lower(province.terrain)
    if terrain == "mountain" then return 6 end
    if terrain == "forest" then return 5 end
    if terrain == "desert" then return 5 end
    return 4
end

local function route_next_step(state, from_id, target_id)
    if from_id == target_id then
        return nil
    end
    local current = state.provinces[from_id]
    if not current then
        return nil
    end
    for _, n in ipairs(current.neighbors or {}) do
        if n == target_id then
            return target_id
        end
    end
    if state.reg and state.reg.findRoute then
        local ok, route = pcall(function() return state.reg:findRoute(from_id, target_id) end)
        if ok and type(route) == "table" and route[2] then
            return route[2]
        end
    end
    return nil
end

local function ai_tick(state)
    for _, army in ipairs(state.armies) do
        local country = state.countries[army.tag]
        if country and country.ai and not army.target_id and army.province_id then
            local province = state.provinces[army.province_id]
            local choice = nil
            for _, n in ipairs(province.neighbors or {}) do
                local candidate = state.provinces[n]
                if candidate and candidate.owner ~= "SEA" and candidate.owner ~= army.tag then
                    choice = n
                    break
                end
            end
            choice = choice or province.neighbors[1]
            if choice then
                M.order_move(state, army.id, choice)
            end
        end
    end
end

function M.new(reg, scenario)
    local state = {
        reg = reg,
        scenario = scenario,
        player_tag = scenario.player_tag,
        countries = {},
        provinces = {},
        armies = {},
        selected_province_id = nil,
        selected_army_id = nil,
        map_mode = "political",
        paused = false,
        speed_index = 2,
        month_timer = 0,
        month_count = 0,
        revision = 0,
        style_revision = 0,
        border_revision = 0,
        striped_province_ids = {},
        striped_signature = "",
        log = {},
        date = {
            year = scenario.start_date.year,
            month = scenario.start_date.month,
            day = scenario.start_date.day,
        },
    }

    function state:date_string()
        return string.format("%s %04d", MONTH_NAMES[self.date.month], self.date.year)
    end

    function state:set_striped_pair(first_id, second_id)
        local next = {}
        if type(first_id) == "number" and self.provinces[first_id] then
            next[first_id] = true
        end
        if type(second_id) == "number" and self.provinces[second_id] then
            next[second_id] = true
        end
        local signature = striped_signature(next)
        if signature == self.striped_signature then
            return false
        end
        self.striped_province_ids = next
        self.striped_signature = signature
        self.style_revision = self.style_revision + 1
        return true
    end

    function state:toggle_striped_pair(first_id, second_id)
        local next = {}
        if type(first_id) == "number" and self.provinces[first_id] then
            next[first_id] = true
        end
        if type(second_id) == "number" and self.provinces[second_id] then
            next[second_id] = true
        end
        local signature = striped_signature(next)
        if signature ~= "" and signature == self.striped_signature then
            return self:set_striped_pair(nil, nil)
        end
        return self:set_striped_pair(first_id, second_id)
    end

    for _, tag in ipairs(sorted_string_keys(scenario.countries)) do
        local country = scenario.countries[tag]
        state.countries[tag] = country_copy(country)
    end

    local ids = reg:provinceIds() or {}
    for _, id in ipairs(ids) do
        local snap = reg:getProvince(id)
        local attrs = snap and snap.attrs or {}
        local owner = scenario.assign_owner(attrs, snap, id)
        local cx, cy = point_from_snap(snap)
        local terrain = tostring(attrs.terrain or "unknown")
        local income = num(attrs.income, terrain_income(terrain))
        local manpower = num(attrs.manpower, income * 500)
        local province = {
            id = id,
            game_id = attrs.game_id,
            name = clean_name(attrs.name or ("Province " .. tostring(id))),
            owner = owner,
            terrain = terrain,
            goods = tostring(attrs.goods or "-"),
            income = income,
            manpower = manpower,
            unrest = owner == "NEU" and 1 or 0,
            fort = owner == "SEA" and 0 or 1,
            continent = attrs.continent,
            region = attrs.region,
            area = attrs.area,
            culture = attrs.culture,
            cx = cx,
            cy = cy,
            neighbors = reg:getNeighbors(id) or {},
        }
        state.provinces[id] = province
        local country = state.countries[owner]
        if country and owner ~= "SEA" then
            country.province_count = country.province_count + 1
            country.monthly_income = country.monthly_income + province.income
            country.monthly_manpower = country.monthly_manpower + math.floor(province.manpower / 120)
        end
        if reg.setAttr then
            reg:setAttr(id, "owner", owner)
            reg:setAttr(id, "income", tostring(province.income))
            reg:setAttr(id, "manpower", tostring(province.manpower))
            reg:setAttr(id, "goods", province.goods)
            reg:setAttr(id, "unrest", tostring(province.unrest))
        end
    end

    for i, spec in ipairs(scenario.starting_armies) do
        local pid = find_start_province(state, spec)
        if pid then
            local country = state.countries[spec.tag]
            if country and not country.capital_province_id then
                country.capital_province_id = pid
            end
            table.insert(state.armies, {
                id = i,
                tag = spec.tag,
                name = spec.name,
                size = spec.size,
                province_id = pid,
                target_id = nil,
                eta = 0,
                move_total = 0,
                selected = false,
            })
        end
    end
    if state.armies[1] then
        set_selected_army(state, state.armies[1].id)
    end

    local player_capital = state.countries[state.player_tag] and state.countries[state.player_tag].capital_province_id
    local rival_capital = state.countries.LIT and state.countries.LIT.capital_province_id
    if player_capital or rival_capital then
        state:set_striped_pair(player_capital, rival_capital)
    end

    add_log(state, "The 1419 campaign begins. Poland is the player country.")
    return state
end

function M.update(state, dt)
    local speed = SPEEDS[state.speed_index] or 1
    if state.paused or speed == 0 then
        return
    end
    state.month_timer = state.month_timer + dt * speed
    for _, army in ipairs(state.armies) do
        if army.target_id then
            army.eta = army.eta - dt * speed
            if army.eta <= 0 then
                finish_army_move(state, army)
            end
        end
    end
    while state.month_timer >= MONTH_SECONDS do
        state.month_timer = state.month_timer - MONTH_SECONDS
        M.monthly_tick(state)
    end
end

function M.monthly_tick(state)
    state.month_count = state.month_count + 1
    state.date.month = state.date.month + 1
    if state.date.month > 12 then
        state.date.month = 1
        state.date.year = state.date.year + 1
    end
    for _, tag in ipairs(sorted_string_keys(state.countries)) do
        local country = state.countries[tag]
        if tag ~= "SEA" and tag ~= "NEU" then
            country.treasury = country.treasury + math.floor((country.monthly_income or 0) * 0.12)
            country.manpower = country.manpower + math.floor(country.monthly_manpower or 0)
        end
    end
    for _, id in ipairs(sorted_numeric_keys(state.provinces)) do
        local province = state.provinces[id]
        if province.owner ~= "SEA" then
            province.unrest = math.max(0, province.unrest - 0.08)
        end
    end
    if state.month_count % 6 == 0 then
        ai_tick(state)
    end
    state.revision = state.revision + 1
    add_log(state, "Monthly income and manpower collected.")
end

function M.select_province(state, province_id)
    state.selected_province_id = province_id
    if not province_id then
        return
    end
    for _, army in ipairs(state.armies) do
        if army.province_id == province_id and army.tag == state.player_tag then
            set_selected_army(state, army.id)
            return
        end
    end
end

function M.select_army(state, army_id)
    set_selected_army(state, army_id)
end

function M.cycle_player_army(state)
    local player = {}
    for _, army in ipairs(state.armies) do
        if army.tag == state.player_tag then
            table.insert(player, army)
        end
    end
    if #player == 0 then
        return nil
    end
    local current = 0
    for i, army in ipairs(player) do
        if army.id == state.selected_army_id then
            current = i
        end
    end
    local next_army = player[(current % #player) + 1]
    set_selected_army(state, next_army.id)
    state.selected_province_id = next_army.province_id
    return next_army
end

function M.order_move(state, army_id, target_id)
    local army = nil
    for _, candidate in ipairs(state.armies) do
        if candidate.id == army_id then
            army = candidate
            break
        end
    end
    if not army or not target_id or not state.provinces[target_id] then
        return false
    end
    local step = route_next_step(state, army.province_id, target_id)
    if not step then
        add_log(state, "No land route for " .. army.name .. ".")
        return false
    end
    army.target_id = step
    army.move_total = movement_cost(state, step)
    army.eta = army.move_total
    add_log(state, army.name .. " marches to " .. state.provinces[step].name .. ".")
    return true
end

function M.set_speed(state, index)
    state.speed_index = math.max(1, math.min(#SPEEDS, index))
end

function M.toggle_pause(state)
    state.paused = not state.paused
end

function M.speed_label(state)
    local speed = SPEEDS[state.speed_index] or 1
    if state.paused or speed == 0 then
        return "Paused"
    end
    return tostring(speed) .. "x"
end

function M.set_striped_pair(state, first_id, second_id)
    if state and state.set_striped_pair then
        return state:set_striped_pair(first_id, second_id)
    end
    return false
end

function M.toggle_striped_pair(state, first_id, second_id)
    if state and state.toggle_striped_pair then
        return state:toggle_striped_pair(first_id, second_id)
    end
    return false
end

return M
