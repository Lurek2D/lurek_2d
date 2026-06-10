-- tests/lua/unit/test_shape.lua
-- Lurek2D BDD tests for lurek.render.newShape()  - CompoundShape builder

local function run_tests()

-- Constructor

    -- @describe newShape constructor
    describe("newShape constructor", function()
        -- @covers lurek.render.newShape
        it("returns a non-nil userdata", function()
            local shape = lurek.render.newShape()
            expect_not_nil(shape)
        end)

        -- @covers LShape:getCommandCount
        it("tracks command counts across independent shapes and accumulated builders", function()
            local shape = lurek.render.newShape()
            expect_equal(0, shape:getCommandCount())
            local s1 = lurek.render.newShape()
            local s2 = lurek.render.newShape()
            s1:circle("fill", 0, 0, 30)
            expect_equal(1, s1:getCommandCount())
            expect_equal(0, s2:getCommandCount())
            shape:rectangle("fill", 0, 0, 100, 50)
            shape:circle("line", 50, 50, 20)
            shape:line(0, 0, 100, 100)
            expect_equal(3, shape:getCommandCount())
            expect_type("number", shape:getCommandCount())
        end)
    end)

-- Primitive builder methods

    -- @describe primitive builder methods
    describe("primitive builder methods", function()
        -- @covers LShape:rectangle
        it("rectangle accepts fill and line modes", function()
            local shape = lurek.render.newShape()
            shape:rectangle("fill", 0, 0, 100, 50)
            expect_equal(1, shape:getCommandCount())
            shape:rectangle("line", 10, 10, 80, 40)
            expect_equal(2, shape:getCommandCount())
        end)

        -- @covers LShape:roundedRectangle
        it("roundedRectangle supports default and explicit radii", function()
            local shape = lurek.render.newShape()
            shape:roundedRectangle("fill", 0, 0, 100, 50, 10)
            expect_equal(1, shape:getCommandCount())
            shape:roundedRectangle("line", 0, 0, 100, 50, 12, 8)
            expect_equal(2, shape:getCommandCount())
        end)

        -- @covers LShape:circle
        it("circle adds one command", function()
            local shape = lurek.render.newShape()
            shape:circle("fill", 0, 0, 30)
            expect_equal(1, shape:getCommandCount())
        end)

        -- @covers LShape:ellipse
        it("ellipse adds one command", function()
            local shape = lurek.render.newShape()
            shape:ellipse("fill", 0, 0, 40, 25)
            expect_equal(1, shape:getCommandCount())
        end)

        -- @covers LShape:triangle
        it("triangle adds one command", function()
            local shape = lurek.render.newShape()
            shape:triangle("fill", 0, 0, 50, 0, 25, 50)
            expect_equal(1, shape:getCommandCount())
        end)

        -- @covers LShape:polygon
        it("polygon adds commands and rejects invalid vertex lists", function()
            local shape = lurek.render.newShape()
            shape:polygon("fill", 0, 0, 50, 0, 50, 50)
            expect_equal(1, shape:getCommandCount())
            shape:polygon("fill", 0, 0, 100, 0, 100, 100, 0, 100)
            expect_equal(2, shape:getCommandCount())
            expect_error(function()
                shape:polygon("fill", 0, 0, 50, 0)
            end)
            expect_equal(2, shape:getCommandCount())
        end)

        -- @covers LShape:line
        it("line adds one command", function()
            local shape = lurek.render.newShape()
            shape:line(0, 0, 100, 100)
            expect_equal(1, shape:getCommandCount())
        end)

        -- @covers LShape:polyline
        it("polyline accepts valid inputs and rejects invalid ones", function()
            local shape = lurek.render.newShape()
            shape:polyline(0, 0, 100, 100, 200, 0)
            expect_equal(1, shape:getCommandCount())
            shape:polyline(0, 0, 100, 100)
            expect_equal(2, shape:getCommandCount())
            expect_error(function()
                shape:polyline(0, 0)
            end)
            expect_equal(2, shape:getCommandCount())
        end)

        -- @covers LShape:arc
        it("arc supports implicit and explicit segment counts", function()
            local shape = lurek.render.newShape()
            shape:arc("fill", 0, 0, 50, 0, math.pi)
            expect_equal(1, shape:getCommandCount())
            shape:arc("line", 0, 0, 50, 0, math.pi, 64)
            expect_equal(2, shape:getCommandCount())
        end)
    end)

-- State builder methods

    -- @describe state builder methods
    describe("state builder methods", function()
        -- @covers LShape:setColor
        it("tracks color commands with and without alpha and across chained builders", function()
            local shape = lurek.render.newShape()
            shape:setColor(1, 0, 0)
            expect_equal(1, shape:getCommandCount())
            shape:setColor(0, 1, 0, 0.5)
            expect_equal(2, shape:getCommandCount())
            shape:rectangle("fill", 0, 0, 100, 50)
            shape:setColor(0, 0, 1)
            shape:circle("line", 50, 50, 25)
            expect_equal(5, shape:getCommandCount())
        end)

        -- @covers LShape:setLineWidth
        it("adds line width commands alongside other builder state", function()
            local shape = lurek.render.newShape()
            shape:setLineWidth(3.0)
            expect_equal(1, shape:getCommandCount())
            shape:rectangle("fill", 0, 0, 100, 50)
            shape:setColor(0, 0, 1)
            shape:circle("line", 50, 50, 20)
            expect_equal(4, shape:getCommandCount())
            shape:setLineWidth(2)
            expect_equal(5, shape:getCommandCount())
        end)
    end)

-- draw dispatch

    -- @describe draw dispatch
    describe("draw dispatch", function()
        -- @covers LShape:draw
        it("supports empty, populated, minimal, and transformed draws without mutating commands", function()
            local shape = lurek.render.newShape()
            expect_no_error(function()
                shape:draw(100, 200)
            end)
            expect_no_error(function()
                shape:draw(0, 0, 0.5, 2.0, 2.0, 10, 10)
            end)
            expect_no_error(function()
                shape:draw(0, 0)
            end)
            shape:circle("fill", 0, 0, 30)
            expect_no_error(function()
                shape:draw(100, 100)
            end)
            expect_equal(1, shape:getCommandCount())
        end)
    end)

-- clear

    -- @describe clear
    describe("clear", function()
        -- @covers LShape:clear
        it("clears populated and empty shapes and allows rebuilding", function()
            local shape = lurek.render.newShape()
            shape:rectangle("fill", 0, 0, 100, 50)
            shape:circle("line", 50, 50, 20)
            shape:line(0, 0, 100, 100)
            shape:clear()
            expect_equal(0, shape:getCommandCount())
            shape:rectangle("fill", 0, 0, 100, 50)
            expect_equal(1, shape:getCommandCount())
            expect_no_error(function()
                shape:draw(0, 0)
            end)
            expect_no_error(function()
                shape:clear()
            end)
            expect_equal(0, shape:getCommandCount())
        end)
    end)

end

run_tests()
test_summary()
