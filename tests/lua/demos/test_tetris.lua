-- Headless contract test for tetris (content/games/arcade/tetris)
dofile("tests/lua/demos/_common_checks.lua")

-- @describe demo: tetris
describe("demo: tetris", function()
    local DEMO = "content/games/arcade/tetris"

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
