-- tests/lua/integration/test_province_integration.lua
-- Integration tests for province properties used in multi-province game scenarios.

-- @describe Province properties integration with game logic
describe("lurek.province integration", function()
    -- @integration lurek.province.setProperty
    -- @integration lurek.province.getProperty
    it("province properties support multi-province independent state", function()
        -- Setup multiple provinces with different properties
        for i = 1, 5 do
            lurek.province.setProperty(i, "population", i * 100.0)
            lurek.province.setProperty(i, "food", i * 50.0)
            lurek.province.setAttr(i, "name", "Province_" .. i)
        end

        -- Verify independence
        expect_near(100.0, lurek.province.getProperty(1, "population"), 0.001)
        expect_near(500.0, lurek.province.getProperty(5, "population"), 0.001)
        expect_equal("Province_3", lurek.province.getAttr(3, "name"))

        -- Modify one doesn't affect others
        lurek.province.setProperty(3, "population", 999.0)
        expect_near(200.0, lurek.province.getProperty(2, "population"), 0.001)
        expect_near(999.0, lurek.province.getProperty(3, "population"), 0.001)
    end)

    -- @integration lurek.province.setProperty
    -- @integration lurek.province.setFlag
    -- @integration lurek.province.hasFlag
    it("combines numeric properties and flags for game state", function()
        local id = 50
        lurek.province.setProperty(id, "gold", 1000.0)
        lurek.province.setFlag(id, 0, true)  -- flag 0 = "has_castle"
        lurek.province.setFlag(id, 1, true)  -- flag 1 = "has_port"

        expect_near(1000.0, lurek.province.getProperty(id, "gold"), 0.001)
        expect_true(lurek.province.hasFlag(id, 0))
        expect_true(lurek.province.hasFlag(id, 1))
        expect_false(lurek.province.hasFlag(id, 2))  -- no market
    end)

    -- @integration lurek.province.setProperty
    -- @integration lurek.province.clearProperties
    it("clearProperties resets province for reuse", function()
        local id = 60
        lurek.province.setProperty(id, "army", 500.0)
        lurek.province.setAttr(id, "owner", "player1")
        lurek.province.setFlag(id, 3, true)

        -- Simulate province being captured and reset
        lurek.province.clearProperties(id)
        lurek.province.setProperty(id, "army", 100.0)
        lurek.province.setAttr(id, "owner", "player2")

        expect_near(100.0, lurek.province.getProperty(id, "army"), 0.001)
        expect_equal("player2", lurek.province.getAttr(id, "owner"))
        expect_false(lurek.province.hasFlag(id, 3))
    end)

    -- @integration lurek.province.setProperty
    -- @integration lurek.province.getProperty
    it("simulates economic tick across provinces", function()
        -- Setup initial state
        for i = 100, 104 do
            lurek.province.setProperty(i, "gold", 0.0)
            lurek.province.setProperty(i, "income", (i - 99) * 10.0)
        end

        -- Simulate one economic tick: gold += income
        for i = 100, 104 do
            local gold = lurek.province.getProperty(i, "gold")
            local income = lurek.province.getProperty(i, "income")
            lurek.province.setProperty(i, "gold", gold + income)
        end

        expect_near(10.0, lurek.province.getProperty(100, "gold"), 0.001)
        expect_near(50.0, lurek.province.getProperty(104, "gold"), 0.001)
    end)
end)

test_summary()
