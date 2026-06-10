-- tests/lua/unit/test_province_properties_unit.lua
-- Unit tests for the province generic property system (setProperty, getProperty, setAttr, getAttr, setFlag, hasFlag, clearProperties).

-- @describe Province generic properties system
describe("lurek.province properties", function()
    -- @covers lurek.province.setProperty
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

    -- @covers lurek.province.setAttr
    it("sets and gets string attribute", function()
        lurek.province.setAttr(1, "culture", "germanic")
        expect_equal("germanic", lurek.province.getAttr(1, "culture"))
    end)

    -- @covers lurek.province.getAttr
    it("returns nil for unset attribute", function()
        expect_nil(lurek.province.getAttr(888, "missing"))
    end)

    -- @covers lurek.province.setFlag
    it("sets and checks flag bits", function()
        lurek.province.setFlag(3, 0, true)
        lurek.province.setFlag(3, 5, true)
        expect_true(lurek.province.hasFlag(3, 0))
        expect_true(lurek.province.hasFlag(3, 5))
        expect_false(lurek.province.hasFlag(3, 1))
    end)

    -- @covers lurek.province.hasFlag
    it("can clear a flag bit", function()
        lurek.province.setFlag(4, 2, true)
        expect_true(lurek.province.hasFlag(4, 2))
        lurek.province.setFlag(4, 2, false)
        expect_false(lurek.province.hasFlag(4, 2))
    end)


    -- @covers lurek.province.clearProperties
    it("clears one province without affecting another", function()
        lurek.province.setProperty(10, "pop", 500.0)
        lurek.province.setAttr(10, "name", "test")
        lurek.province.setFlag(10, 0, true)
        lurek.province.setProperty(11, "pop", 750.0)
        lurek.province.clearProperties(10)
        expect_nil(lurek.province.getProperty(10, "pop"))
        expect_nil(lurek.province.getAttr(10, "name"))
        expect_false(lurek.province.hasFlag(10, 0))
        expect_near(750.0, lurek.province.getProperty(11, "pop"), 0.001)
    end)

end)
test_summary()
