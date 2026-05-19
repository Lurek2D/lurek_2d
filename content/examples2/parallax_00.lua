--- Parallax Module Part 1: layer creation, scroll, visibility, tiling, depth

--@api-stub: lurek.parallax.newLayer
-- Creates a parallax layer from options.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({
        texture = "bg_mountains.png",
        scrollFactor = {0.3, 0.1},
        z = 10,
        opacity = 0.9,
    })
    print("type = " .. layer:type())
    print("z = " .. layer:getZ())
    print("opacity = " .. layer:getOpacity())
end

--@api-stub: lurek.parallax.newPresetLayer
-- Creates a layer from a named preset.
do
    ---@type LImage
    local img = lurek.render.newImage("assets/textures/ray_water.png")
    ---@type LParallaxLayer
    local far = lurek.parallax.newPresetLayer("far", img)
    ---@type LParallaxLayer
    local mid = lurek.parallax.newPresetLayer("mid", img)
    ---@type LParallaxLayer
    local fog = lurek.parallax.newPresetLayer("fog", img)
    print("far depth = " .. far:getDepth())
    print("mid depth = " .. mid:getDepth())
    print("fog depth = " .. fog:getDepth())
end

--@api-stub: LParallaxLayer:setScrollFactor
--@api-stub: LParallaxLayer:getScrollFactor
-- Controls parallax scrolling speed.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = "bg.png"})
    layer:setScrollFactor(0.5, 0.2)
    local sx, sy = layer:getScrollFactor()
    print("scroll = " .. sx .. "," .. sy)
end

--@api-stub: LParallaxLayer:setOffset
--@api-stub: LParallaxLayer:getOffset
-- Pixel offset for fine positioning.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = "bg.png"})
    layer:setOffset(10, -5)
    local ox, oy = layer:getOffset()
    print("offset = " .. ox .. "," .. oy)
end

--@api-stub: LParallaxLayer:setDepth
--@api-stub: LParallaxLayer:getDepth
-- Depth value for sorting and parallax strength.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = "bg.png"})
    layer:setDepth(0.5)
    print("depth = " .. layer:getDepth())
end

--@api-stub: LParallaxLayer:setZ
--@api-stub: LParallaxLayer:getZ
-- Z order for rendering order.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = "bg.png"})
    layer:setZ(-5)
    print("z = " .. layer:getZ())
end

--@api-stub: LParallaxLayer:setVisible
--@api-stub: LParallaxLayer:isVisible
-- Visibility toggle.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = "bg.png"})
    layer:setVisible(false)
    print("visible = " .. tostring(layer:isVisible()))
    layer:setVisible(true)
    print("visible = " .. tostring(layer:isVisible()))
end

--@api-stub: LParallaxLayer:setOpacity
--@api-stub: LParallaxLayer:getOpacity
-- Layer opacity (0-1).
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = "bg.png"})
    layer:setOpacity(0.7)
    print("opacity = " .. layer:getOpacity())
end

--@api-stub: LParallaxLayer:setTiling
--@api-stub: LParallaxLayer:getTiling
--@api-stub: LParallaxLayer:setTileSize
-- Tiling configuration.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = "tile_bg.png"})
    layer:setTiling(true)
    layer:setTileSize(64, 64)
    print("tiling = " .. tostring(layer:getTiling()))
end

--@api-stub: LParallaxLayer:setRepeat
-- Repeat flags per axis.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = "bg.png"})
    layer:setRepeat(true, false)
    print("repeat set: horizontal only")
end

--@api-stub: LParallaxLayer:setScale
-- Layer scale factor.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = "bg.png"})
    layer:setScale(2.0, 2.0)
    print("scaled 2x")
end

--@api-stub: LParallaxLayer:setTint
--@api-stub: LParallaxLayer:getTint
-- Color tinting.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = "bg.png"})
    layer:setTint(1.0, 0.8, 0.6, 1.0)
    local r, g, b, a = layer:getTint()
    print("tint = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LParallaxLayer:setBlendMode
--@api-stub: LParallaxLayer:getBlendMode
-- Blend mode selection.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = "bg.png"})
    layer:setBlendMode("add")
    print("blend = " .. layer:getBlendMode())
    layer:setBlendMode("alpha")
    print("blend = " .. layer:getBlendMode())
end

--@api-stub: LParallaxLayer:setClamp
--@api-stub: LParallaxLayer:clearClamp
-- Movement bounds.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = "bg.png"})
    layer:setClamp(-100, -50, 100, 50)
    print("clamped")
    layer:clearClamp()
    print("clamp cleared")
end

print("parallax_00.lua")
