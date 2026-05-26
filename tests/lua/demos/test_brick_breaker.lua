-- Headless contract test for brick_breaker (content/games/action/brick_breaker)
dofile("tests/lua/demos/_common_checks.lua")

-- @describe demo: brick_breaker
describe("demo: brick_breaker", function()
    local DEMO = "content/games/action/brick_breaker"

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
