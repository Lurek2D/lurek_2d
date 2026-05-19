--@api-stub: LShape:arc
--@api-stub: LShape:circle
--@api-stub: LShape:setColor
-- LShape: arc, circle, and color.
do
    local s = lurek.render.newShape()
    s:setColor(1, 0.5, 0, 1)
    s:arc("fill", 100, 100, 40, 0, math.pi)
    s:circle("line", 200, 200, 30)
    local c = s:getCommandCount()
    print("shape cmds:", c)
end

--@api-stub: LShape:ellipse
--@api-stub: LShape:line
--@api-stub: LShape:rectangle
-- LShape: ellipse, line, rectangle drawing.
do
    local s = lurek.render.newShape()
    s:ellipse("fill", 100, 100, 50, 30)
    s:line(10, 10, 90, 90)
    s:rectangle("fill", 20, 20, 60, 40)
    local c = s:getCommandCount()
    print("shape ellipse+line+rect cmds:", c)
end

--@api-stub: LShape:triangle
--@api-stub: LShape:draw
--@api-stub: LShape:setLineWidth
-- LShape: triangle, draw and line width.
do
    local s = lurek.render.newShape()
    s:setLineWidth(2)
    s:triangle("line", 0, 0, 50, 0, 25, 50)
    s:draw(100, 100, 0, 1, 1, 0, 0)
    local c = s:getCommandCount()
    print("shape triangle+draw cmds:", c)
end

--@api-stub: LShape:getCommandCount
-- LShape: getCommandCount after clear.
do
    local s = lurek.render.newShape()
    s:circle("fill", 0, 0, 10)
    s:circle("fill", 50, 50, 10)
    local before = s:getCommandCount()
    s:clear()
    local after = s:getCommandCount()
    print("getCommandCount before:", before, "after clear:", after)
end
