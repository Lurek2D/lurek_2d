-- Headless contract test for postfx_demo (content/games/showcase/postfx_demo)
dofile("tests/lua/demos/_common_checks.lua")

-- @describe demo: postfx_demo
describe("demo: postfx_demo", function()
    local DEMO = "content/games/showcase/postfx_demo"

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
