-- Headless contract test for tower_defense (content/games/strategy/tower_defense)
dofile("tests/lua/demos/_common_checks.lua")

-- @describe demo: tower_defense
describe("demo: tower_defense", function()
    local DEMO = "content/games/strategy/tower_defense"

    it("main.lua defines lifecycle callbacks", function()
        demo_check_lifecycle(DEMO)
    end)

    it("conf.toml is valid when present", function()
        demo_check_conf_optional(DEMO)
    end)

    it("main.lua avoids direct window present calls", function()
        demo_check_no_direct_present(DEMO)
    end)
end)

test_summary()
