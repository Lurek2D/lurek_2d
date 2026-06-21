-- test_province_evidence.lua
-- Canonical evidence file for lurek.province topology and property artifacts.

local Fixture = lurek.filesystem.load("tests/fixtures/province_evidence_fixture.lua")()
local OUT = evidence_output_dir("province")

local function write_text(path, text)
    if write_file then
        write_file(path, text)
    else
        lurek.filesystem.write(path, text)
    end
    expect_evidence_created(path)
end

local function registry_name()
    return "province_evidence_fixture_" .. tostring(math.floor(os.clock() * 1000000))
end

local ECON_CONFIG = {
    food_per_capita = 0.1,
    base_tax_per_10_pop = 1.0,
    base_growth_rate = 0.02,
    housing_capacity = 30,
    base_capacity = 30,
    happiness_low_threshold = 5,
    happiness_high_threshold = 15,
    low_productivity = 0.75,
    high_productivity = 1.25,
}

local function init_province(id, opts)
    lurek.province.setProperty(id, "population", opts.population)
    lurek.province.setProperty(id, "food_stockpile", opts.food)
    lurek.province.setProperty(id, "gold_stockpile", opts.gold)
    lurek.province.setProperty(id, "happiness", opts.happiness or 10)
    lurek.province.setProperty(id, "farm_count", opts.farms or 1)
    lurek.province.setProperty(id, "housing_count", opts.housing or 1)
    lurek.province.setProperty(id, "tax_level", opts.tax_level or 1.0)
end

local function monthly_tick(id)
    local pop = lurek.province.getProperty(id, "population") or 0
    local food = lurek.province.getProperty(id, "food_stockpile") or 0
    local gold = lurek.province.getProperty(id, "gold_stockpile") or 0
    local happiness = lurek.province.getProperty(id, "happiness") or 10
    local housing = lurek.province.getProperty(id, "housing_count") or 0
    local farms = lurek.province.getProperty(id, "farm_count") or 0

    local need = pop * ECON_CONFIG.food_per_capita
    local consumed = math.min(need, food)
    food = food - consumed

    local deaths = 0
    if consumed < need then
        deaths = math.floor((need - consumed) / ECON_CONFIG.food_per_capita * 0.1)
        pop = math.max(0, pop - deaths)
        happiness = math.max(0, happiness - 2)
    end

    local raw_tax = math.floor(pop / 10) * ECON_CONFIG.base_tax_per_10_pop
    local productivity = 1.0
    if happiness < ECON_CONFIG.happiness_low_threshold then
        productivity = ECON_CONFIG.low_productivity
    elseif happiness >= ECON_CONFIG.happiness_high_threshold then
        productivity = ECON_CONFIG.high_productivity
    end
    local tax_collected = math.floor(raw_tax * productivity)
    gold = gold + tax_collected

    local cap = ECON_CONFIG.base_capacity + housing * ECON_CONFIG.housing_capacity
    local growth = 0
    if pop < cap and food > 0 then
        growth = math.floor((ECON_CONFIG.base_growth_rate + farms * 0.01) * pop)
        growth = math.min(growth, cap - pop)
        pop = pop + growth
    end

    lurek.province.setProperty(id, "population", pop)
    lurek.province.setProperty(id, "food_stockpile", food)
    lurek.province.setProperty(id, "gold_stockpile", gold)
    lurek.province.setProperty(id, "happiness", happiness)

    return {
        consumed = consumed,
        deaths = deaths,
        tax = tax_collected,
        growth = growth,
        pop = pop,
        food = food,
        gold = gold,
        happiness = happiness,
    }
end

-- @describe Evidence: lurek.province fixture-derived artifacts
describe("Evidence: lurek.province fixture-derived artifacts", function()
    before_each(function()
        ensure_evidence_dir("province")
    end)

    -- Does: Generates a dedicated province atlas fixture, sanitizes its marker map, imports metadata, and renders standalone topology views.
    -- Shows: The PNG and text report let a reviewer inspect marker sanitization, metadata import, adjacency, route tracing, and revision changes without touching any game-owned map.
    -- Artifact: tests/artifacts/current/province/province_sanitized_map.png, province_border_segments.png, province_capitals_centroids.png, province_route_trace.png, province_registry_topology_trace.txt
    -- Why: This is meaningful because every input file comes from a local evidence fixture rather than from a playable package.
    it("PNG+TXT: province fixture sanitization and topology trace", function()
        local assets = Fixture.ensure()
        local sanitized_path = OUT .. "province_sanitized_map.png"
        local summary = lurek.province.sanitizeMarkedPng(
            assets.marker_png,
            sanitized_path
        )
        expect_type("table", summary)
        expect_true((summary.replaced_pixels or 0) > 0)
        expect_evidence_created(sanitized_path)

        local reg = lurek.province.newFromPng(registry_name(), sanitized_path)
        local imported = reg:importMetadataFromFiles({
            color_map_png = sanitized_path,
            marker_png = assets.marker_png,
            color_csv = assets.color_csv,
            province_toml = assets.province_toml,
        })

        local ids = reg:provinceIds()
        local first_id = ids[1]
        local first_neighbors = reg:getNeighbors(first_id)
        local pairs = reg:adjacencies()
        local pair = pairs[1]
        local route = reg:findRoute(pair.province_a, pair.province_b)
        local rev_before = reg:getRevision()

        reg:setPoliticalColor(first_id, 0.82, 0.34, 0.28, 1.0)
        reg:setAttr(first_id, "owner", "player")
        reg:setLabelText(first_id, "Evidence Province")

        local changes = reg:getChangesSince(rev_before)
        local province = reg:getProvince(first_id)
        local borders = Fixture.render_border_segments(reg, sanitized_path)
        local capitals = Fixture.render_capitals_centroids(reg, sanitized_path)
        local route_img = Fixture.render_route_trace(reg, sanitized_path)
        lurek.image.savePNG(borders, OUT .. "province_border_segments.png")
        lurek.image.savePNG(capitals, OUT .. "province_capitals_centroids.png")
        lurek.image.savePNG(route_img, OUT .. "province_route_trace.png")
        expect_evidence_created(OUT .. "province_border_segments.png")
        expect_evidence_created(OUT .. "province_capitals_centroids.png")
        expect_evidence_created(OUT .. "province_route_trace.png")

        local lines = {
            string.format("sanitize replaced_pixels=%s unresolved_pixels=%s", tostring(summary.replaced_pixels), tostring(summary.unresolved_pixels)),
            string.format("import mapped_provinces=%s capitals_set=%s labels_set=%s label_lines_set=%s", tostring(imported.mapped_provinces), tostring(imported.capitals_set), tostring(imported.labels_set), tostring(imported.label_lines_set)),
            string.format("registry size=%dx%d province_count=%d", reg:getWidth(), reg:getHeight(), reg:provinceCount()),
            string.format("first_id=%s neighbors=%d attrs_owner=%s", tostring(first_id), #first_neighbors, tostring(province.attrs.owner)),
            string.format("first_pair=%s-%s route_len=%d", tostring(pair.province_a), tostring(pair.province_b), type(route) == "table" and #route or 0),
            string.format("changes_since=%d revision_now=%d", #changes, reg:getRevision()),
            string.format("snapshot label=%s political_rgba=%.2f,%.2f,%.2f,%.2f", tostring(province.attrs.name or province.attrs.owner or "n/a"), province.style.political_color[1], province.style.political_color[2], province.style.political_color[3], province.style.political_color[4]),
        }
        write_text(OUT .. "province_registry_topology_trace.txt", table.concat(lines, "\n") .. "\n")
    end)

    -- Does: Runs a deterministic property simulation on evidence-owned province ids.
    -- Shows: The text artifact shows food consumption, tax gain, growth, starvation handling, and final province properties without borrowing any external scenario package.
    -- Artifact: tests/artifacts/current/province/province_economy_properties_trace.txt
    -- Why: This is meaningful because every number in the trace is driven by lurek.province setProperty and getProperty state updates on the local fixture provinces.

    it("TXT: province_economy_properties_trace -- monthly property simulation", function()
        init_province(11, { population = 200, food = 100, gold = 50, farms = 3, housing = 2 })
        init_province(12, { population = 80, food = 30, gold = 5, farms = 1, housing = 1 })
        init_province(13, { population = 500, food = 200, gold = 100, farms = 5, housing = 5 })

        local labels = {
            [11] = "North March",
            [12] = "Green Hollow",
            [13] = "Sun Keep",
        }

        local lines = {}
        for month = 1, 4 do
            lines[#lines + 1] = "month=" .. tostring(month)
            for _, id in ipairs({ 11, 12, 13 }) do
                local report = monthly_tick(id)
                lines[#lines + 1] = string.format(
                    "  %s pop=%d food=%.1f gold=%.1f happy=%.1f tax=%d growth=%d deaths=%d consumed=%.1f",
                    labels[id],
                    report.pop,
                    report.food,
                    report.gold,
                    report.happiness,
                    report.tax,
                    report.growth,
                    report.deaths,
                    report.consumed
                )
            end
        end

        write_text(OUT .. "province_economy_properties_trace.txt", table.concat(lines, "\n") .. "\n")
    end)
end)

test_summary()
