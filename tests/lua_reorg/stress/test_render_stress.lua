-- Lurek2D Stress Test: Graphics Draw Commands
-- Tests throughput of draw command generation (headless, no GPU)

-- @describe graphics stress: shape throughput
describe("graphics stress: shape throughput", function()
    -- @stress lurek.render.rectangle
    it("10000 rectangles do not error", function()
        local issued = 0
        expect_no_error(function()
            for i = 1, 10000 do
                lurek.render.rectangle("fill", i % 800, i % 600, 10, 10)
                issued = issued + 1
            end
        end)
        expect_equal(10000, issued, "all rectangle calls completed")
    end)

    -- @stress lurek.render.circle
    it("10000 circles do not error", function()
        local issued = 0
        expect_no_error(function()
            for i = 1, 10000 do
                lurek.render.circle("fill", i % 800, i % 600, 5)
                issued = issued + 1
            end
        end)
        expect_equal(10000, issued, "all circle calls completed")
    end)

    -- @stress lurek.render.line
    it("10000 lines do not error", function()
        local issued = 0
        expect_no_error(function()
            for i = 1, 10000 do
                lurek.render.line(0, 0, i % 800, i % 600)
                issued = issued + 1
            end
        end)
        expect_equal(10000, issued, "all line calls completed")
    end)

    -- @stress lurek.render.setColor
    it("rapid color changes do not error", function()
        local last_r, last_g, last_b, last_a = 1, 1, 1, 1
        for i = 1, 10000 do
            local r = (i % 256) / 255
            local g = ((i * 7) % 256) / 255
            local b = ((i * 13) % 256) / 255
            lurek.render.setColor(r, g, b, 1.0)
            last_r, last_g, last_b, last_a = r, g, b, 1.0
        end
        local r, g, b, a = lurek.render.getColor()
        expect_near(last_r, r, 0.0001, "final red channel preserved")
        expect_near(last_g, g, 0.0001, "final green channel preserved")
        expect_near(last_b, b, 0.0001, "final blue channel preserved")
        expect_near(last_a, a, 0.0001, "final alpha channel preserved")
    end)
end)

-- @describe graphics stress: mixed draw commands
describe("graphics stress: mixed draw commands", function()
    -- @stress lurek.render.arc
    it("5000 arcs do not error", function()
        local issued = 0
        expect_no_error(function()
            for i = 1, 5000 do
                lurek.render.arc("line", i % 400, i % 300, 6, 0, math.pi)
                issued = issued + 1
            end
        end)
        expect_equal(5000, issued, "all arc calls completed")
    end)
end)
test_summary()
