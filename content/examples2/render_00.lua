--- Render Module Part 1: basic drawing — print, rectangle, circle, line, polygon, points, arc, ellipse, triangle

--@api-stub: lurek.render.print / basic text
-- Drawing text to the screen.
do
    lurek.render.print("Hello, Lurek2D!", 10, 10)
    lurek.render.print("Scaled text", 10, 30, 2.0)
    lurek.render.print("Small text", 10, 60, 0.5)
    lurek.render.print("", 0, 0)
end

--@api-stub: lurek.render.printf / word-wrapped text
-- Drawing aligned, word-wrapped text.
do
    lurek.render.printf("Left-aligned paragraph that wraps at 200 pixels width.", 10, 100, 200, "left")
    lurek.render.printf("Centered text within a 300px box.", 10, 140, 300, "center")
    lurek.render.printf("Right-aligned text example.", 10, 180, 250, "right")
    lurek.render.printf("Justified paragraph with multiple words.", 10, 220, 200, "justify")
end

--@api-stub: lurek.render.printRotated
-- Drawing rotated text around its center.
do
    lurek.render.printRotated("Rotated!", 200, 200, math.pi / 4)
    lurek.render.printRotated("Upside down", 300, 200, math.pi)
    lurek.render.printRotated("Scaled rotated", 400, 200, -math.pi / 6, 1.5)
end

--@api-stub: lurek.render.printRich
-- Drawing rich text with per-span styling.
do
    local spans = {
        { text = "Red ",   r = 1, g = 0, b = 0, a = 1, scale = 1 },
        { text = "Green ", r = 0, g = 1, b = 0, a = 1, scale = 1 },
        { text = "Blue",   r = 0, g = 0, b = 1, a = 1, scale = 1.5 },
    }
    lurek.render.printRich(spans, 10, 260)
end

--@api-stub: lurek.render.rectangle / filled and outlined
-- Drawing rectangles in fill and line modes.
do
    lurek.render.setColor(1, 0, 0, 1)
    lurek.render.rectangle("fill", 50, 300, 100, 60)
    lurek.render.setColor(0, 1, 0, 1)
    lurek.render.rectangle("line", 50, 300, 100, 60)
    lurek.render.setColor(0, 0, 1, 0.5)
    lurek.render.rectangle("fill", 80, 320, 100, 60)
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: lurek.render.rectangle / rounded
-- Drawing rounded rectangles.
do
    lurek.render.setColor(0.8, 0.2, 0.8, 1)
    lurek.render.rectangle("fill", 200, 300, 120, 80, 12)
    lurek.render.setColor(1, 1, 0, 1)
    lurek.render.rectangle("line", 200, 300, 120, 80, 12, 6)
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: lurek.render.circle / filled and outlined
-- Drawing circles.
do
    lurek.render.setColor(1, 0.5, 0, 1)
    lurek.render.circle("fill", 500, 340, 40)
    lurek.render.setColor(0, 1, 1, 1)
    lurek.render.circle("line", 500, 340, 40)
    lurek.render.setColor(0.5, 0.5, 0.5, 1)
    lurek.render.circle("fill", 600, 340, 20)
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: lurek.render.ellipse / filled and outlined
-- Drawing ellipses.
do
    lurek.render.setColor(0.2, 0.6, 0.9, 1)
    lurek.render.ellipse("fill", 150, 450, 60, 30)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.ellipse("line", 150, 450, 60, 30)
    lurek.render.setColor(0.9, 0.3, 0.1, 1)
    lurek.render.ellipse("fill", 300, 450, 30, 60)
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: lurek.render.arc / filled and outlined
-- Drawing arc segments.
do
    lurek.render.setColor(1, 0.8, 0, 1)
    lurek.render.arc("fill", 500, 450, 50, 0, math.pi / 2)
    lurek.render.setColor(0, 0.8, 0.3, 1)
    lurek.render.arc("line", 500, 450, 50, math.pi, math.pi * 1.5, 16)
    lurek.render.setColor(0.5, 0, 1, 1)
    lurek.render.arc("fill", 620, 450, 40, 0, math.pi * 2, 64)
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: lurek.render.line / two-point and polyline
-- Drawing lines and polylines.
do
    lurek.render.setColor(1, 1, 0, 1)
    lurek.render.line(10, 520, 200, 520)
    lurek.render.setColor(0, 1, 1, 1)
    lurek.render.line(10, 540, 50, 560, 90, 540, 130, 560, 170, 540, 200, 560)
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: lurek.render.polygon / filled and outlined
-- Drawing polygons from vertex lists.
do
    lurek.render.setColor(0.8, 0.1, 0.5, 1)
    lurek.render.polygon("fill", 300, 520, 350, 500, 400, 520, 380, 570, 320, 570)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.polygon("line", 300, 520, 350, 500, 400, 520, 380, 570, 320, 570)
end

--@api-stub: lurek.render.triangle / filled and outlined
-- Drawing triangles.
do
    lurek.render.setColor(0, 0.7, 0.3, 1)
    lurek.render.triangle("fill", 450, 570, 500, 500, 550, 570)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.triangle("line", 560, 570, 610, 500, 660, 570)
end

--@api-stub: lurek.render.points / individual points
-- Drawing points with different sizes.
do
    lurek.render.setPointSize(4)
    lurek.render.setColor(1, 0, 0, 1)
    lurek.render.points(50, 600, 70, 600, 90, 600, 110, 600, 130, 600)
    lurek.render.setPointSize(8)
    lurek.render.setColor(0, 0, 1, 1)
    lurek.render.points({ { 160, 600 }, { 180, 600 }, { 200, 600 } })
    lurek.render.setPointSize(1)
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: lurek.render.setLineWidth / getLineWidth
-- Controlling line width.
do
    lurek.render.setLineWidth(1)
    lurek.render.line(10, 630, 100, 630)
    lurek.render.setLineWidth(3)
    lurek.render.line(10, 640, 100, 640)
    lurek.render.setLineWidth(5)
    lurek.render.line(10, 650, 100, 650)
    local w = lurek.render.getLineWidth()
    print("line width = " .. w)
    lurek.render.setLineWidth(1)
end

--@api-stub: lurek.render.setPointSize / getPointSize
-- Controlling point size.
do
    lurek.render.setPointSize(2)
    local s = lurek.render.getPointSize()
    print("point size = " .. s)
    lurek.render.setPointSize(1)
end

--@api-stub: lurek.render.drawCubicBezier / drawQuadBezier
-- Drawing Bezier curves.
do
    lurek.render.setColor(1, 0.5, 0, 1)
    lurek.render.drawCubicBezier(120, 630, 160, 580, 220, 680, 260, 630, 24)
    lurek.render.setColor(0, 1, 0.5, 1)
    lurek.render.drawQuadBezier(300, 630, 350, 580, 400, 630, 16)
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: lurek.render.drawPath
-- Drawing vector paths.
do
    local path = {
        { type = "moveTo", x = 450, y = 620 },
        { type = "lineTo", x = 500, y = 600 },
        { type = "quadTo", cx = 550, cy = 580, x = 580, y = 620 },
        { type = "lineTo", x = 560, y = 660 },
        { type = "cubicTo", cx1 = 530, cy1 = 680, cx2 = 480, cy2 = 680, x = 450, y = 660 },
    }
    lurek.render.setColor(0.6, 0.2, 1, 1)
    lurek.render.drawPath(path, "line", true)
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: lurek.render.drawGradientRect
-- Drawing gradient-filled rectangles.
do
    lurek.render.drawGradientRect(10, 680, 150, 40, { 1, 0, 0 }, { 0, 0, 1 }, "horizontal")
    lurek.render.drawGradientRect(170, 680, 150, 40, { 0, 1, 0 }, { 1, 1, 0 }, "vertical")
    lurek.render.drawGradientRect(330, 680, 80, 80, { 1, 1, 1 }, { 0, 0, 0 }, "radial")
end

--@api-stub: lurek.render.drawColoredPolygon
-- Drawing polygons with per-vertex colors.
do
    local verts = { 450, 680, 520, 680, 520, 740, 450, 740 }
    local colors = {
        { 1, 0, 0, 1 },
        { 0, 1, 0, 1 },
        { 0, 0, 1, 1 },
        { 1, 1, 0, 1 },
    }
    lurek.render.drawColoredPolygon(verts, colors, "fill")
end

--@api-stub: lurek.render.drawHexTile
-- Drawing hexagonal tiles.
do
    lurek.render.setColor(0, 0.6, 0.4, 1)
    lurek.render.drawHexTile(600, 700, 25, "pointyTop", "fill")
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.drawHexTile(600, 700, 25, "pointyTop", "line")
    lurek.render.setColor(0.8, 0.4, 0, 1)
    lurek.render.drawHexTile(660, 700, 25, "flatTop", "fill")
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.drawHexTile(660, 700, 25, "flatTop", "line")
end

--@api-stub: lurek.render.drawBevelRect
-- Drawing beveled 3D-style rectangles.
do
    lurek.render.drawBevelRect(10, 750, 100, 40, 3, "raised")
    lurek.render.drawBevelRect(120, 750, 100, 40, 3, "sunken")
    lurek.render.drawBevelRect(230, 750, 100, 40, 2, "groove")
    lurek.render.drawBevelRect(340, 750, 100, 40, 2, "ridge")
    lurek.render.drawBevelRect(450, 750, 100, 40, 2, "flat", {
        fillColor = { 0.2, 0.3, 0.8, 1 }
    })
end

print("render_00.lua")
