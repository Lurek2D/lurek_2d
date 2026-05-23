-- Headless contract test for asteroids (content/games/arcade/asteroids)
dofile("tests/lua/demos/_common_checks.lua")

-- @describe demo: asteroids
describe("demo: asteroids", function()
    local DEMO = "content/games/arcade/asteroids"

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
