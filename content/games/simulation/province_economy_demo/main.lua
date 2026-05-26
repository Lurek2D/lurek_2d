-- Province Economy Demo
-- Demonstrates province-level economic simulation using lurek.province.
-- Three provinces run monthly ticks: food consumption, tax, starvation,
-- population growth, and happiness tracking.

-- ── Economy helpers (formerly library/province_economy) ──────────────────────

local CONFIG = {
    food_per_capita          = 0.1,
    base_tax_per_10_pop      = 1.0,
    base_growth_rate         = 0.02,
    housing_capacity         = 30,
    base_capacity            = 30,
    happiness_low_threshold  = 5,
    happiness_high_threshold = 15,
    low_productivity         = 0.75,
    high_productivity        = 1.25,
}

local function initProvince(id, opts)
    opts = opts or {}
    lurek.province.setProperty(id, "population",     opts.population or 100)
    lurek.province.setProperty(id, "food_stockpile", opts.food       or 50)
    lurek.province.setProperty(id, "gold_stockpile", opts.gold       or 10)
    lurek.province.setProperty(id, "happiness",      opts.happiness  or 10)
    lurek.province.setProperty(id, "farm_count",     opts.farms      or 1)
    lurek.province.setProperty(id, "housing_count",  opts.housing    or 1)
    lurek.province.setProperty(id, "tax_level",      opts.tax_level  or 1.0)
end

local function monthlyTick(id)
    local pop       = lurek.province.getProperty(id, "population")     or 0
    local food      = lurek.province.getProperty(id, "food_stockpile") or 0
    local gold      = lurek.province.getProperty(id, "gold_stockpile") or 0
    local happiness = lurek.province.getProperty(id, "happiness")      or 10
    local housing   = lurek.province.getProperty(id, "housing_count")  or 0
    local farms     = lurek.province.getProperty(id, "farm_count")     or 0

    local report = {}

    -- Food consumption
    local need     = pop * CONFIG.food_per_capita
    local consumed = math.min(need, food)
    food           = food - consumed
    report.food_consumed = consumed

    -- Starvation
    local deaths = 0
    if consumed < need then
        deaths    = math.floor((need - consumed) / CONFIG.food_per_capita * 0.1)
        pop       = math.max(0, pop - deaths)
        happiness = math.max(0, happiness - 2)
    end
    report.starvation_deaths = deaths

    -- Tax with happiness multiplier
    local raw_tax = math.floor(pop / 10) * CONFIG.base_tax_per_10_pop
    local mult    = 1.0
    if happiness < CONFIG.happiness_low_threshold then
        mult = CONFIG.low_productivity
    elseif happiness >= CONFIG.happiness_high_threshold then
        mult = CONFIG.high_productivity
    end
    local tax_collected = math.floor(raw_tax * mult)
    gold                = gold + tax_collected
    report.tax_collected = tax_collected

    -- Population growth
    local cap    = CONFIG.base_capacity + housing * CONFIG.housing_capacity
    local growth = 0
    if pop < cap and food > 0 then
        growth = math.floor((CONFIG.base_growth_rate + farms * 0.01) * pop)
        growth = math.min(growth, cap - pop)
        pop    = pop + growth
    end
    report.growth = growth
    report.population_after = pop

    lurek.province.setProperty(id, "population",     pop)
    lurek.province.setProperty(id, "food_stockpile", food)
    lurek.province.setProperty(id, "gold_stockpile", gold)
    lurek.province.setProperty(id, "happiness",      happiness)

    return report
end

-- ── Game state ────────────────────────────────────────────────────────────────

local PROVINCES = {
    { id = 1, name = "Ironhollow",   food_color = 0x4caf50ff, pop_color = 0x2196f3ff },
    { id = 2, name = "Ashfield",     food_color = 0xff9800ff, pop_color = 0xe91e63ff },
    { id = 3, name = "Brightwater",  food_color = 0x00bcd4ff, pop_color = 0x9c27b0ff },
}

local month       = 1
local year        = 1
local tick_timer  = 0
local TICK_SEC    = 3.0   -- one month per 3 real seconds
local last_reports = {}
local history     = {}    -- {month, reports} log

local function label_month(m, y)
    local names = { "Jan","Feb","Mar","Apr","May","Jun",
                    "Jul","Aug","Sep","Oct","Nov","Dec" }
    return string.format("%s Y%d", names[((m - 1) % 12) + 1], y)
end

-- ── Init ─────────────────────────────────────────────────────────────────────

function lurek.load()
    initProvince(1, { population = 200, food = 100, gold = 50,  farms = 3, housing = 2 })
    initProvince(2, { population =  80, food =  30, gold =   5, farms = 1, housing = 1 })
    initProvince(3, { population = 500, food = 200, gold = 100, farms = 5, housing = 5 })
end

-- ── Update ────────────────────────────────────────────────────────────────────

function lurek.update(dt)
    tick_timer = tick_timer + dt
    if tick_timer >= TICK_SEC then
        tick_timer = tick_timer - TICK_SEC

        last_reports = {}
        for _, p in ipairs(PROVINCES) do
            last_reports[p.id] = monthlyTick(p.id)
        end
        history[#history + 1] = { label = label_month(month, year), reports = last_reports }
        if #history > 12 then table.remove(history, 1) end

        month = month + 1
        if month > 12 then month = 1 ; year = year + 1 end
    end
end

-- ── Draw ──────────────────────────────────────────────────────────────────────

function lurek.draw()
    local W, H = lurek.window.getSize()

    lurek.render.clear(0x1a1a2eff)

    -- Title
    lurek.render.text(string.format("Province Economy — %s", label_month(month, year)),
        W / 2, 16, { color = 0xffd700ff, align = "center", size = 18 })

    lurek.render.text(string.format("Tick in %.1fs", TICK_SEC - tick_timer),
        W - 12, 16, { color = 0x888888ff, align = "right", size = 13 })

    -- Province panels
    local panel_w = math.floor((W - 40) / 3)
    for i, p in ipairs(PROVINCES) do
        local px = 12 + (i - 1) * (panel_w + 8)
        local py = 50

        -- Panel background
        lurek.render.rect(px, py, panel_w, H - 80,
            { color = 0x0d0d1eff, fill = true })
        lurek.render.rect(px, py, panel_w, H - 80,
            { color = 0x334455ff, fill = false })

        -- Province name
        lurek.render.text(p.name, px + panel_w / 2, py + 10,
            { color = 0xffffffff, align = "center", size = 15 })

        -- Live stats
        local pop  = lurek.province.getProperty(p.id, "population")     or 0
        local food = lurek.province.getProperty(p.id, "food_stockpile") or 0
        local gold = lurek.province.getProperty(p.id, "gold_stockpile") or 0
        local hap  = lurek.province.getProperty(p.id, "happiness")      or 0

        local function stat_row(label, value, color, row)
            lurek.render.text(label, px + 10, py + 36 + row * 18,
                { color = 0x999999ff, size = 12 })
            lurek.render.text(tostring(value), px + panel_w - 10, py + 36 + row * 18,
                { color = color, align = "right", size = 12 })
        end

        stat_row("Population",  pop,  0xffd700ff, 0)
        stat_row("Food",        math.floor(food), p.food_color, 1)
        stat_row("Gold",        math.floor(gold), 0xffd700ff, 2)
        stat_row("Happiness",   hap,  hap < 5 and 0xff4444ff or hap >= 15 and 0x44ff88ff or 0xffffff88, 3)

        -- Last tick report
        local rep = last_reports[p.id]
        if rep then
            lurek.render.text("Last tick:", px + 10, py + 118,
                { color = 0x666666ff, size = 11 })
            stat_row("Tax collected", rep.tax_collected,      0xffd700ff,  6)
            stat_row("Food consumed", math.floor(rep.food_consumed or 0), p.food_color, 7)
            stat_row("Growth",        rep.growth,             0x44cc88ff,  8)
            if (rep.starvation_deaths or 0) > 0 then
                stat_row("Deaths", rep.starvation_deaths, 0xff4444ff, 9)
            end
        end
    end

    -- History bar chart (gold collected)
    if #history > 1 then
        local chart_y  = H - 28
        local bar_w    = math.floor((W - 40) / #history)
        local max_gold = 1
        for _, h in ipairs(history) do
            local total = 0
            for _, r in pairs(h.reports) do total = total + (r.tax_collected or 0) end
            if total > max_gold then max_gold = total end
        end
        lurek.render.text("Tax/month", 14, chart_y - 30,
            { color = 0x555555ff, size = 11 })
        for j, h in ipairs(history) do
            local total = 0
            for _, r in pairs(h.reports) do total = total + (r.tax_collected or 0) end
            local bar_h = math.floor(total / max_gold * 24)
            lurek.render.rect(14 + (j - 1) * bar_w, chart_y - bar_h, bar_w - 1, bar_h,
                { color = 0xffd70088, fill = true })
        end
    end
end
