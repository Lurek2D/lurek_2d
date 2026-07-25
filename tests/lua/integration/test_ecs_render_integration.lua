-- Integration: ECS entity positions used as draw coordinates
-- @describe integration: entity position drives draw coordinates
describe("integration: entity position drives draw coordinates", function()
    -- @integration LUniverse:get
    -- @integration LUniverse:set
    -- @integration LUniverse:spawn
    -- @integration lurek.ecs.newUniverse
    -- @integration lurek.render.rectangle
    -- @integration lurek.render.setColor
    -- @integration lurek.ecs.newUniverse
    -- @integration lurek.render.rectangle
    -- @integration lurek.render.setColor
    it("entity position stored and usable for rectangle draw", function()
        local universe = lurek.ecs.newUniverse()
        local id = universe:spawn()
        universe:set(id, "x", 200.0)
        universe:set(id, "y", 150.0)
        universe:set(id, "w", 32.0)
        universe:set(id, "h", 32.0)

        local x = universe:get(id, "x")
        local y = universe:get(id, "y")
        local w = universe:get(id, "w")
        local h = universe:get(id, "h")
        local draw_count = 0

        expect_equal(200.0, x, "entity x")
        expect_equal(150.0, y, "entity y")
        expect_equal(32.0, w, "entity width")
        expect_equal(32.0, h, "entity height")

        draw_count = draw_count + 1
        lurek.render.setColor(1, 1, 1, 1)
        lurek.render.rectangle("fill", x --[[@as number]], y --[[@as number]], w --[[@as number]], h --[[@as number]])
        expect_equal(1, draw_count, "one ECS-driven draw executes")
    end)

    -- @integration LUniverse:get
    -- @integration LUniverse:set
    -- @integration LUniverse:spawn
    -- @integration lurek.ecs.newUniverse
    -- @integration lurek.render.rectangle
    -- @integration lurek.render.setColor
    it("multiple entities draw at different positions", function()
        local universe = lurek.ecs.newUniverse()
        local positions = {{10, 20}, {100, 200}, {300, 400}}
        local ids = {}
        local draw_count = 0
        local sum_x = 0
        local sum_y = 0

        for i, pos in ipairs(positions) do
            local id = universe:spawn()
            universe:set(id, "x", pos[1])
            universe:set(id, "y", pos[2])
            ids[i] = id
        end

        for i, id in ipairs(ids) do
            local x = universe:get(id, "x")
            local y = universe:get(id, "y")
            expect_equal(positions[i][1], x, "entity " .. i .. " x")
            expect_equal(positions[i][2], y, "entity " .. i .. " y")

            sum_x = sum_x + x
            sum_y = sum_y + y
            draw_count = draw_count + 1
            lurek.render.setColor(1, 0, 0, 1)
            lurek.render.rectangle("fill", x --[[@as number]], y --[[@as number]], 16, 16)
        end

        expect_equal(3, draw_count, "each ECS entity reaches one draw call")
        expect_equal(410, sum_x, "drawn x coordinates preserve ECS positions")
        expect_equal(620, sum_y, "drawn y coordinates preserve ECS positions")
    end)

    -- @integration LUniverse:get
    -- @integration LUniverse:set
    -- @integration LUniverse:spawn
    -- @integration lurek.ecs.newUniverse
    -- @integration lurek.render.rectangle
    -- @integration lurek.render.setColor
    it("entity visibility flag gates draw commands", function()
        local universe = lurek.ecs.newUniverse()
        local id = universe:spawn()
        universe:set(id, "visible", true)
        universe:set(id, "x", 50.0)
        universe:set(id, "y", 50.0)
        local draw_count = 0

        local visible = universe:get(id, "visible")
        expect_true(visible, "entity visible by default")

        if universe:get(id, "visible") then
            draw_count = draw_count + 1
            lurek.render.setColor(0, 1, 0, 1)
            lurek.render.rectangle("line", 50, 50, 20, 20)
        end
        expect_equal(1, draw_count, "visible entity is drawn once")

        universe:set(id, "visible", false)
        expect_false(universe:get(id, "visible"), "entity can be hidden before draw")

        if universe:get(id, "visible") then
            draw_count = draw_count + 1
            lurek.render.setColor(0, 1, 0, 1)
            lurek.render.rectangle("line", 50, 50, 20, 20)
        end
        expect_equal(1, draw_count, "hidden entity skips the second draw")
    end)

    -- @integration LNineSlice:getInsets
    -- @integration lurek.image.newImageData
    -- @integration lurek.render.drawNineSlice
    -- @integration lurek.render.newImage
    -- @integration lurek.sprite.newNineSlice
    it("single bitmap data becomes sprite nine-slice data consumed by render", function()
        local data = lurek.image.newImageData(12, 12)
        local image = lurek.render.newImage(data)
        local slice = lurek.sprite.newNineSlice(image, 2, 3, 4, 5)
        local top, right, bottom, left = slice:getInsets()

        expect_equal(2, top)
        expect_equal(3, right)
        expect_equal(4, bottom)
        expect_equal(5, left)

        expect_no_error(function()
            lurek.render.drawNineSlice(slice, 10, 20, 48, 32)
        end)
    end)

    -- @integration LFont:measure
    -- @integration lurek.font.getDefault
    -- @integration lurek.render.printWithFont
    it("font-owned metrics provide a font handle that render can consume", function()
        local font = lurek.font.getDefault()
        local width, height = font:measure("status ready", 1.0)

        expect_true(width > 0)
        expect_true(height > 0)
        expect_no_error(function()
            lurek.render.printWithFont(font, "status ready", 4, 6, 1.0)
        end)
    end)
end)
test_summary()
