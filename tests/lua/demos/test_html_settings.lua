-- Headless contract test for html-settings (content/games/showcase/html-settings)
dofile("tests/lua/demos/_common_checks.lua")

-- @describe demo: html-settings
describe("demo: html-settings", function()
    local DEMO = "content/games/showcase/html-settings"

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
