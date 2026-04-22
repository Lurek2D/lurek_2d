-- content/examples/parallax.lua
-- love2d-style usage snippets for the lurek.parallax API (43 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/parallax.lua

-- ── lurek.parallax.* functions ──

--@api-stub: lurek.parallax.newLayer
-- Creates a new parallax background layer from an options table.
-- Build once at startup; reuse across frames.
local layer = lurek.parallax.newLayer({ x = 0, y = 0 })
print("created", layer)
return layer

--@api-stub: lurek.parallax.newSet
-- Creates a new empty parallax set with the given name.
-- Build once at startup; reuse across frames.
local set = lurek.parallax.newSet("main")
print("created", set)
return set

-- ── ParallaxLayer methods ──

--@api-stub: ParallaxLayer:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local parallaxLayer = lurek.parallax.newParallaxLayer()
parallaxLayer:type()
print("ParallaxLayer:type done")

--@api-stub: ParallaxLayer:update
-- Advances the autonomous scroll accumulator by `dt` seconds.
-- Apply at startup or in response to user input.
local parallaxLayer = lurek.parallax.newParallaxLayer()
parallaxLayer:update(dt)
print("ParallaxLayer:update applied")

--@api-stub: ParallaxLayer:render
-- Draws the layer using an explicit camera world position.
-- See the module spec for detailed semantics.
local parallaxLayer = lurek.parallax.newParallaxLayer()
parallaxLayer:render(cam_x, cam_y)
print("ParallaxLayer:render done")

--@api-stub: ParallaxLayer:renderAuto
-- Draws the layer using the engine active camera position automatically.
-- See the module spec for detailed semantics.
local parallaxLayer = lurek.parallax.newParallaxLayer()
parallaxLayer:renderAuto()
print("ParallaxLayer:renderAuto done")

--@api-stub: ParallaxLayer:resetAutoscroll
-- Resets the autonomous scroll accumulator to zero.
-- Pair with the matching constructor to free resources.
local parallaxLayer = lurek.parallax.newParallaxLayer()
parallaxLayer:resetAutoscroll()
-- parallaxLayer is now released
print("ok")

--@api-stub: ParallaxLayer:setScrollFactor
-- Sets the scroll factor relative to camera movement on each axis.
-- Apply at startup or in response to user input.
local parallaxLayer = lurek.parallax.newParallaxLayer()
parallaxLayer:setScrollFactor(100, 100)
print("ParallaxLayer:setScrollFactor applied")

--@api-stub: ParallaxLayer:getScrollFactor
-- Returns the scroll factor as `(x, y)`.
-- Cheap to call; safe inside callbacks.
local parallaxLayer = lurek.parallax.newParallaxLayer()  -- or your existing handle
local value = parallaxLayer:getScrollFactor()
print("ParallaxLayer:getScrollFactor ->", value)

--@api-stub: ParallaxLayer:setOffset
-- Sets the static world-pixel position bias added on top of camera scroll.
-- Apply at startup or in response to user input.
local parallaxLayer = lurek.parallax.newParallaxLayer()
parallaxLayer:setOffset(100, 100)
print("ParallaxLayer:setOffset applied")

--@api-stub: ParallaxLayer:getOffset
-- Returns the static offset as `(x, y)`.
-- Cheap to call; safe inside callbacks.
local parallaxLayer = lurek.parallax.newParallaxLayer()  -- or your existing handle
local value = parallaxLayer:getOffset()
print("ParallaxLayer:getOffset ->", value)

--@api-stub: ParallaxLayer:setAutoscroll
-- Sets the autonomous scroll velocity in world-pixels per second.
-- Apply at startup or in response to user input.
local parallaxLayer = lurek.parallax.newParallaxLayer()
parallaxLayer:setAutoscroll(100, 100)
print("ParallaxLayer:setAutoscroll applied")

--@api-stub: ParallaxLayer:getAutoscroll
-- Returns the autoscroll velocity as `(vx, vy)`.
-- Cheap to call; safe inside callbacks.
local parallaxLayer = lurek.parallax.newParallaxLayer()  -- or your existing handle
local value = parallaxLayer:getAutoscroll()
print("ParallaxLayer:getAutoscroll ->", value)

--@api-stub: ParallaxLayer:setRepeat
-- Sets whether the layer tiles on the X and Y axes.
-- Apply at startup or in response to user input.
local parallaxLayer = lurek.parallax.newParallaxLayer()
parallaxLayer:setRepeat(rx, ry)
print("ParallaxLayer:setRepeat applied")

--@api-stub: ParallaxLayer:setScale
-- Sets the texture display scale factor on each axis.
-- Apply at startup or in response to user input.
local parallaxLayer = lurek.parallax.newParallaxLayer()
parallaxLayer:setScale(sx, sy)
print("ParallaxLayer:setScale applied")

--@api-stub: ParallaxLayer:setZ
-- Sets the draw-order depth.
-- Apply at startup or in response to user input.
local parallaxLayer = lurek.parallax.newParallaxLayer()
parallaxLayer:setZ(0)
print("ParallaxLayer:setZ applied")

--@api-stub: ParallaxLayer:getZ
-- Returns the draw-order depth.
-- Cheap to call; safe inside callbacks.
local parallaxLayer = lurek.parallax.newParallaxLayer()  -- or your existing handle
local value = parallaxLayer:getZ()
print("ParallaxLayer:getZ ->", value)

--@api-stub: ParallaxLayer:setOpacity
-- Sets the layer-wide opacity override in `[0.0, 1.0]`.
-- Apply at startup or in response to user input.
local parallaxLayer = lurek.parallax.newParallaxLayer()
parallaxLayer:setOpacity(1)
print("ParallaxLayer:setOpacity applied")

--@api-stub: ParallaxLayer:getOpacity
-- Returns the current opacity.
-- Cheap to call; safe inside callbacks.
local parallaxLayer = lurek.parallax.newParallaxLayer()  -- or your existing handle
local value = parallaxLayer:getOpacity()
print("ParallaxLayer:getOpacity ->", value)

--@api-stub: ParallaxLayer:setTint
-- Sets the multiplicative RGBA tint applied to all pixels of this layer.
-- Apply at startup or in response to user input.
local parallaxLayer = lurek.parallax.newParallaxLayer()
parallaxLayer:setTint(1, 0.5, 0, 1)
print("ParallaxLayer:setTint applied")

--@api-stub: ParallaxLayer:getTint
-- Returns the current tint as `(r, g, b, a)`.
-- Cheap to call; safe inside callbacks.
local parallaxLayer = lurek.parallax.newParallaxLayer()  -- or your existing handle
local value = parallaxLayer:getTint()
print("ParallaxLayer:getTint ->", value)

--@api-stub: ParallaxLayer:setBlendMode
-- Sets the GPU blend mode for this layer.
-- Apply at startup or in response to user input.
local parallaxLayer = lurek.parallax.newParallaxLayer()
parallaxLayer:setBlendMode(mode)
print("ParallaxLayer:setBlendMode applied")

--@api-stub: ParallaxLayer:getBlendMode
-- Returns the current blend mode as a string.
-- Cheap to call; safe inside callbacks.
local parallaxLayer = lurek.parallax.newParallaxLayer()  -- or your existing handle
local value = parallaxLayer:getBlendMode()
print("ParallaxLayer:getBlendMode ->", value)

--@api-stub: ParallaxLayer:setVisible
-- Shows or hides this layer.
-- Apply at startup or in response to user input.
local parallaxLayer = lurek.parallax.newParallaxLayer()
parallaxLayer:setVisible(v)
print("ParallaxLayer:setVisible applied")

--@api-stub: ParallaxLayer:isVisible
-- Returns `true` if the layer is currently visible.
-- Use as a guard inside lurek.update or event handlers.
local parallaxLayer = lurek.parallax.newParallaxLayer()
if parallaxLayer:isVisible() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: ParallaxLayer:clearClamp
-- Removes scroll clamping so the layer scrolls freely.
-- Pair with the matching constructor to free resources.
local parallaxLayer = lurek.parallax.newParallaxLayer()
parallaxLayer:clearClamp()
-- parallaxLayer is now released
print("ok")

--@api-stub: ParallaxLayer:setTiling
-- Enables or disables seamless infinite tiling on both axes simultaneously.
-- Apply at startup or in response to user input.
local parallaxLayer = lurek.parallax.newParallaxLayer()
parallaxLayer:setTiling(enabled)
print("ParallaxLayer:setTiling applied")

--@api-stub: ParallaxLayer:getTiling
-- Returns `true` if seamless infinite tiling is enabled.
-- Cheap to call; safe inside callbacks.
local parallaxLayer = lurek.parallax.newParallaxLayer()  -- or your existing handle
local value = parallaxLayer:getTiling()
print("ParallaxLayer:getTiling ->", value)

--@api-stub: ParallaxLayer:setTileSize
-- Sets explicit tile dimensions in logical pixels, overriding the default.
-- Apply at startup or in response to user input.
local parallaxLayer = lurek.parallax.newParallaxLayer()
parallaxLayer:setTileSize(64, 64)
print("ParallaxLayer:setTileSize applied")

--@api-stub: ParallaxLayer:setDepth
-- Sets the floating-point draw depth for fine-grained layer ordering.
-- Apply at startup or in response to user input.
local parallaxLayer = lurek.parallax.newParallaxLayer()
parallaxLayer:setDepth(0)
print("ParallaxLayer:setDepth applied")

--@api-stub: ParallaxLayer:getDepth
-- Returns the current floating-point depth.
-- Cheap to call; safe inside callbacks.
local parallaxLayer = lurek.parallax.newParallaxLayer()  -- or your existing handle
local value = parallaxLayer:getDepth()
print("ParallaxLayer:getDepth ->", value)

-- ── ParallaxSet methods ──

--@api-stub: ParallaxSet:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local parallaxSet = lurek.parallax.newParallaxSet()
parallaxSet:type()
print("ParallaxSet:type done")

--@api-stub: ParallaxSet:addLayer
-- Adds a layer to this set.
-- Side-effecting; safe to call any time after init.
local parallaxSet = lurek.parallax.newParallaxSet()
parallaxSet:addLayer(layer)
print("ParallaxSet:addLayer done")

--@api-stub: ParallaxSet:removeLayerAt
-- Removes the layer at the given 1-based index.
-- Pair with the matching constructor to free resources.
local parallaxSet = lurek.parallax.newParallaxSet()
parallaxSet:removeLayerAt(1)
-- parallaxSet is now released
print("ok")

--@api-stub: ParallaxSet:layerCount
-- Returns the number of layers in this set.
-- See the module spec for detailed semantics.
local parallaxSet = lurek.parallax.newParallaxSet()
parallaxSet:layerCount()
print("ParallaxSet:layerCount done")

--@api-stub: ParallaxSet:sortByZ
-- Re-sorts all layers by ascending `z` value.
-- See the module spec for detailed semantics.
local parallaxSet = lurek.parallax.newParallaxSet()
parallaxSet:sortByZ()
print("ParallaxSet:sortByZ done")

--@api-stub: ParallaxSet:setVisible
-- Shows or hides all layers in this set.
-- Apply at startup or in response to user input.
local parallaxSet = lurek.parallax.newParallaxSet()
parallaxSet:setVisible(v)
print("ParallaxSet:setVisible applied")

--@api-stub: ParallaxSet:isVisible
-- Returns `true` if the set is currently visible.
-- Use as a guard inside lurek.update or event handlers.
local parallaxSet = lurek.parallax.newParallaxSet()
if parallaxSet:isVisible() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: ParallaxSet:update
-- Advances the autoscroll accumulator of every layer by `dt` seconds.
-- Apply at startup or in response to user input.
local parallaxSet = lurek.parallax.newParallaxSet()
parallaxSet:update(dt)
print("ParallaxSet:update applied")

--@api-stub: ParallaxSet:render
-- Draws all visible layers in ascending `z` order using an explicit camera position.
-- See the module spec for detailed semantics.
local parallaxSet = lurek.parallax.newParallaxSet()
parallaxSet:render(cam_x, cam_y)
print("ParallaxSet:render done")

--@api-stub: ParallaxSet:renderAuto
-- Draws all visible layers using the engine active camera position.
-- See the module spec for detailed semantics.
local parallaxSet = lurek.parallax.newParallaxSet()
parallaxSet:renderAuto()
print("ParallaxSet:renderAuto done")

--@api-stub: ParallaxSet:getName
-- Returns the name of this set.
-- Cheap to call; safe inside callbacks.
local parallaxSet = lurek.parallax.newParallaxSet()  -- or your existing handle
local value = parallaxSet:getName()
print("ParallaxSet:getName ->", value)

--@api-stub: ParallaxSet:setName
-- Sets the name of this set.
-- Apply at startup or in response to user input.
local parallaxSet = lurek.parallax.newParallaxSet()
parallaxSet:setName("main")
print("ParallaxSet:setName applied")

