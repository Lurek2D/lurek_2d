-- Headless contract test for dyna_blaster (content/games/arcade/dyna_blaster)
dofile("tests/lua/demos/_common_checks.lua")

-- @describe demo: dyna_blaster
describe("demo: dyna_blaster", function()
    local DEMO = "content/games/arcade/dyna_blaster"

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
