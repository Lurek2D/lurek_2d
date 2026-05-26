-- tests/lua/unit/test_province_properties_unit.lua
-- Unit tests for the province generic property system (setProperty, getProperty, setAttr, getAttr, setFlag, hasFlag, clearProperties).

-- @describe Province generic properties system
describe("lurek.province properties", function()
    -- @covers lurek.province.setProperty
    -- @covers lurek.province.getProperty
    it("sets and gets numeric property", function()
        lurek.province.setProperty(1, "population", 1500.0)
        local val = lurek.province.getProperty(1, "population")
        expect_near(1500.0, val, 0.001)
    end)

    -- @covers lurek.province.getProperty
    it("returns nil for unset property", function()
        local val = lurek.province.getProperty(999, "nonexistent")
        expect_nil(val)
    end)

    -- @covers lurek.province.setProperty
    -- @covers lurek.province.getProperty
    it("overwrites existing property", function()
        lurek.province.setProperty(2, "gold", 100.0)
        lurek.province.setProperty(2, "gold", 250.0)
        expect_near(250.0, lurek.province.getProperty(2, "gold"), 0.001)
    end)

    -- @covers lurek.province.setAttr
    -- @covers lurek.province.getAttr
    it("sets and gets string attribute", function()
        lurek.province.setAttr(1, "culture", "germanic")
        expect_equal("germanic", lurek.province.getAttr(1, "culture"))
    end)

    -- @covers lurek.province.getAttr
    it("returns nil for unset attribute", function()
        expect_nil(lurek.province.getAttr(888, "missing"))
    end)

    -- @covers lurek.province.setAttr
    -- @covers lurek.province.getAttr
    it("overwrites existing attribute", function()
        lurek.province.setAttr(6, "terrain", "plains")
        lurek.province.setAttr(6, "terrain", "forest")
        expect_equal("forest", lurek.province.getAttr(6, "terrain"))
    end)

    -- @covers lurek.province.setFlag
    -- @covers lurek.province.hasFlag
    it("sets and checks flag bits", function()
        lurek.province.setFlag(3, 0, true)
        lurek.province.setFlag(3, 5, true)
        expect_true(lurek.province.hasFlag(3, 0))
        expect_true(lurek.province.hasFlag(3, 5))
        expect_false(lurek.province.hasFlag(3, 1))
    end)

    -- @covers lurek.province.setFlag
    -- @covers lurek.province.hasFlag
    it("can clear a flag bit", function()
        lurek.province.setFlag(4, 2, true)
        expect_true(lurek.province.hasFlag(4, 2))
        lurek.province.setFlag(4, 2, false)
        expect_false(lurek.province.hasFlag(4, 2))
    end)

    -- @covers lurek.province.setFlag
    -- @covers lurek.province.hasFlag
    it("supports high bit index (63)", function()
        lurek.province.setFlag(5, 63, true)
        expect_true(lurek.province.hasFlag(5, 63))
    end)

    -- @covers lurek.province.clearProperties
    it("clears all properties for a province", function()
        lurek.province.setProperty(10, "pop", 500.0)
        lurek.province.setAttr(10, "name", "test")
        lurek.province.setFlag(10, 0, true)
        lurek.province.clearProperties(10)
        expect_nil(lurek.province.getProperty(10, "pop"))
        expect_nil(lurek.province.getAttr(10, "name"))
        expect_false(lurek.province.hasFlag(10, 0))
    end)

    -- @covers lurek.province.setProperty
    -- @covers lurek.province.getProperty
    it("handles multiple provinces independently", function()
        lurek.province.setProperty(20, "food", 100.0)
        lurek.province.setProperty(21, "food", 200.0)
        expect_near(100.0, lurek.province.getProperty(20, "food"), 0.001)
        expect_near(200.0, lurek.province.getProperty(21, "food"), 0.001)
    end)

    -- @covers lurek.province.clearProperties
    it("clearProperties does not affect other provinces", function()
        lurek.province.setProperty(30, "gold", 50.0)
        lurek.province.setProperty(31, "gold", 75.0)
        lurek.province.clearProperties(30)
        expect_nil(lurek.province.getProperty(30, "gold"))
        expect_near(75.0, lurek.province.getProperty(31, "gold"), 0.001)
    end)
end)

test_summary()
