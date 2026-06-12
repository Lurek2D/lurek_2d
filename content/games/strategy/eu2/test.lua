describe("eu2 playable slice", function()
    local function load_demo_module(name)
        local candidates = {
            "scripts/" .. name,
            "content/games/strategy/eu2/scripts/" .. name,
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
end)
