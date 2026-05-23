-- Headless contract test for html-dialog (content/games/showcase/html-dialog)
dofile("tests/lua/demos/_common_checks.lua")

-- @describe demo: html-dialog
describe("demo: html-dialog", function()
    local DEMO = "content/games/showcase/html-dialog"

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
