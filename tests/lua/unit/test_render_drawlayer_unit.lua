-- tests/lua/unit/test_render_drawlayer_unit.lua
-- Lurek2D BDD tests for lurek.render.newDrawLayer().

-- @describe DrawLayer creation
describe("DrawLayer creation", function()
    -- @covers lurek.render.newDrawLayer
    it("creates a DrawLayer userdata", function()
        local layer = lurek.render.newDrawLayer()
        expect_type("userdata", layer)
    end)
end)

-- @describe DrawLayer queue
describe("DrawLayer queue", function()
    -- @covers LDrawLayer:getCount
    it("getCount reflects empty, queued, flushed, and cleared states", function()
        local layer = lurek.render.newDrawLayer()
        expect_equal(0, layer:getCount())
        layer:queue(1.0, function() end)
        layer:queue(2.0, function() end)
        expect_equal(2, layer:getCount())
        layer:flush()
        expect_equal(0, layer:getCount())
        layer:queue(3.0, function() end)
        expect_equal(1, layer:getCount())
        layer:clear()
        expect_equal(0, layer:getCount())
    end)

    -- @covers LDrawLayer:queue
    it("queue accepts positive, zero, and negative z-order values", function()
        local layer = lurek.render.newDrawLayer()
        layer:queue(1.0, function() end)
        layer:queue(0.0, function() end)
        layer:queue(-5.0, function() end)
        expect_equal(3, layer:getCount())
    end)
end)

-- @describe DrawLayer flush
describe("DrawLayer flush", function()
    -- @covers LDrawLayer:flush
    it("flush orders callbacks by z and supports reuse across cycles", function()
        local layer = lurek.render.newDrawLayer()
        local order = {}

        layer:flush()

        layer:queue(3.0, function() table.insert(order, "C1") end)
        layer:queue(1.0, function() table.insert(order, "A1") end)
        layer:queue(2.0, function() table.insert(order, "B1") end)
        layer:queue(-1.0, function() table.insert(order, "N1") end)
        layer:queue(2.0, function() table.insert(order, "B2") end)
        layer:flush()

        expect_equal(5, #order)
        expect_equal("N1", order[1])
        expect_equal("A1", order[2])
        expect_equal("B1", order[3])
        expect_equal("B2", order[4])
        expect_equal("C1", order[5])

        local second_cycle = {}
        layer:queue(4.0, function() table.insert(second_cycle, "D2") end)
        layer:queue(3.0, function() table.insert(second_cycle, "C2") end)
        layer:flush()
        expect_equal("C2", second_cycle[1])
        expect_equal("D2", second_cycle[2])

        local sum = 0
        for i = 100, 1, -1 do
            layer:queue(i, function() sum = sum + 1 end)
        end
        layer:flush()
        expect_equal(100, sum)
    end)
end)

-- @describe DrawLayer clear
describe("DrawLayer clear", function()
    -- @covers LDrawLayer:clear
    it("clear removes queued callbacks, is safe on empty layers, and allows reuse", function()
        local layer = lurek.render.newDrawLayer()
        local called = false

        layer:clear()
        expect_equal(0, layer:getCount())

        layer:queue(1.0, function() called = true end)
        layer:queue(2.0, function() called = true end)
        layer:clear()
        expect_equal(0, layer:getCount())

        layer:flush()
        expect_false(called)

        layer:queue(5.0, function() called = true end)
        expect_equal(1, layer:getCount())
    end)
end)

-- @describe DrawLayer type system
describe("DrawLayer type system", function()
    -- @covers LDrawLayer:type
    it("type returns LDrawLayer", function()
        local layer = lurek.render.newDrawLayer()
        expect_equal("LDrawLayer", layer:type())
    end)

    -- @covers LDrawLayer:typeOf
    it("typeOf matches DrawLayer and Object but rejects unrelated types", function()
        local layer = lurek.render.newDrawLayer()
        expect_true(layer:typeOf("LObject"))
        expect_true(layer:typeOf("LDrawLayer"))
        expect_false(layer:typeOf("LImage"))
    end)
end)

test_summary()
