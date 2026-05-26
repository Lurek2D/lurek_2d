-- Headless contract test for html-hud (content/games/showcase/html-hud)
dofile("tests/lua/demos/_common_checks.lua")

-- @describe demo: html-hud
describe("demo: html-hud", function()
    local DEMO = "content/games/showcase/html-hud"

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
