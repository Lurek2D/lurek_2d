-- Headless contract test for physics_sandbox (content/games/simulation/physics_sandbox)
dofile("tests/lua/demos/_common_checks.lua")

-- @describe demo: physics_sandbox
describe("demo: physics_sandbox", function()
    local DEMO = "content/games/simulation/physics_sandbox"

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
