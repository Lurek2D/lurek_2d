describe("eu2 playable slice", function()
    local function load_demo_module(name)
        local candidates = {
            "scripts/" .. name,
            "content/games/eu2/scripts/" .. name,
        }
        for _, path in ipairs(candidates) do
            local ok, chunk = pcall(lurek.filesystem.load, path)
            if ok and type(chunk) == "function" then
                return chunk()
            end
        end
        error("cannot load demo module " .. name)
    end

    it("required runtime APIs exist", function()
        assert(type(lurek.province.newFromPng) == "function", "province registry loader must exist")
        assert(type(lurek.filesystem.load) == "function", "module loader must exist")
        assert(type(lurek.render.newCanvas) == "function", "canvas rendering must exist")
        assert(type(lurek.log.warn) == "function", "structured warning log must exist")
        assert(type(lurek.ui.newPanel) == "function", "retained UI widgets must exist")
        assert(type(lurek.ui.newLabel) == "function", "retained UI labels must exist")
        assert(type(lurek.minimap.newMinimap) == "function", "minimap module must exist")
    end)

    it("local gameplay modules load", function()
        local scenario = load_demo_module("scenario.lua")
        local state = load_demo_module("state.lua")
        local map_modes = load_demo_module("map_modes.lua")
        local input = load_demo_module("input.lua")
        assert(type(scenario.build) == "function", "scenario.build must exist")
        assert(type(state.new) == "function", "state.new must exist")
        assert(type(state.monthly_tick) == "function", "state.monthly_tick must exist")
        assert(type(state.order_move) == "function", "state.order_move must exist")
        assert(type(map_modes.apply) == "function", "map_modes.apply must exist")
        assert(type(input.handle_key) == "function", "input.handle_key must exist")
    end)

    it("map modes prepare registry colors and palette-driven borders", function()
        local map_modes = load_demo_module("map_modes.lua")
        local border_styles = {}
        local colors = {}
        local reg = {
            adjacencies = function()
                return {
                    { province_a = 1, province_b = 2 },
                    { province_a = 1, province_b = 3 },
                    { province_a = 2, province_b = 4 },
                }
            end,
            setBorderPairStyle = function(_, a, b, style)
                border_styles[tostring(a) .. ":" .. tostring(b)] = style
            end,
            setVisibilityState = function() end,
            setPoliticalColor = function(_, id, r, g, b, a)
                colors[id] = { r, g, b, a }
                return true
            end,
        }
        local state = {
            player_tag = "POL",
            countries = {
                POL = { color = { 0.78, 0.16, 0.20, 1.0 } },
                LIT = { color = { 0.42, 0.30, 0.62, 1.0 } },
                SEA = { color = { 0.24, 0.49, 0.72, 1.0 } },
            },
            provinces = {
                [1] = { owner = "POL", terrain = "forest", income = 4, unrest = 1 },
                [2] = { owner = "LIT", terrain = "plains", income = 3, unrest = 0 },
                [3] = { owner = "SEA", terrain = "sea", income = 0, unrest = 0 },
                [4] = { owner = "LIT", terrain = "plains", income = 3, unrest = 0 },
            },
            style_revision = 1,
            border_revision = 1,
            revision = 1,
        }

        local mode, tints = map_modes.apply(reg, state, "political")

        assert(mode == "political", "GPU province renderer should consume prepared political colors")
        assert(tints == nil, "EU2 should not send per-frame province_tints for stable map modes")
        assert(colors[1] ~= nil and colors[2] ~= nil, "registry colors should be updated")
        assert(colors[1][1] == state.countries.POL.color[1], "political fill should use country color")
        assert(colors[2][3] == state.countries.LIT.color[3], "political fill should distinguish country ownership")
        assert(colors[3][3] > colors[3][1], "sea fill should stay blue")
        assert(border_styles["1:2"].flags[1] == "country", "land owner border should stay a country border")
        assert(border_styles["1:2"].color == nil, "country border color should come from render border_palette")
        assert(border_styles["1:3"].color == nil, "coast border color should come from render border_palette")
        assert(border_styles["1:3"].thickness == 1.0, "coast borders should use normal palette thickness")
        assert(border_styles["2:4"].color == nil, "local borders should use palette province color")
    end)

    it("army movement consumes the province route adapter for non-neighbor targets", function()
        local state_module = load_demo_module("state.lua")
        local route_requests = 0
        local state = {
            log = {},
            provinces = {
                [1] = { name = "Krakow", owner = "POL", terrain = "plains", neighbors = { 2 } },
                [2] = { name = "Mazovia", owner = "POL", terrain = "forest", neighbors = { 1, 3 } },
                [3] = { name = "Danzig", owner = "TEU", terrain = "plains", neighbors = { 2 } },
            },
            armies = {
                { id = "pol_1", name = "Crown Army", tag = "POL", province_id = 1 },
            },
            reg = {
                findRoute = function(_, from_id, to_id)
                    route_requests = route_requests + 1
                    assert(from_id == 1, "route should start at the army province")
                    assert(to_id == 3, "route should target the clicked province")
                    return { 1, 2, 3 }
                end,
            },
            date_string = function()
                return "Jan 1419"
            end,
        }

        local ok = state_module.order_move(state, "pol_1", 3)

        assert(ok == true, "movement order should be accepted")
        assert(route_requests == 1, "non-neighbor movement should query the province route adapter")
        assert(state.armies[1].target_id == 2, "army should move to the next route hop")
        assert(state.armies[1].eta == 5, "movement cost should use next-hop terrain")
    end)

    it("province positions prefer imported capital markers over centroids", function()
        local state_module = load_demo_module("state.lua")
        local reg = {
            provinceIds = function()
                return { 7 }
            end,
            getProvince = function()
                return {
                    attrs = {
                        name = "Krakow",
                        terrain = "plains",
                        income = "4",
                        manpower = "1000",
                    },
                    capital = { x = 321.5, y = 123.5 },
                    centroid = { x = 300.0, y = 100.0 },
                }
            end,
            getNeighbors = function()
                return {}
            end,
            setAttr = function()
                return true
            end,
        }
        local scenario = {
            player_tag = "POL",
            start_date = { year = 1419, month = 1, day = 1 },
            countries = {
                POL = { name = "Poland", color = { 0.78, 0.16, 0.20, 1.0 } },
            },
            starting_armies = {},
            assign_owner = function()
                return "POL"
            end,
        }

        local state = state_module.new(reg, scenario)
        local province = state.provinces[7]

        assert(province ~= nil, "province should be imported into demo state")
        assert(province.cx == 321.5, "demo province x should use imported capital marker")
        assert(province.cy == 123.5, "demo province y should use imported capital marker")
    end)
end)
