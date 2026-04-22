-- content/examples/camera.lua
-- love2d-style usage snippets for the lurek.camera API (36 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/camera.lua

-- ── lurek.camera.* functions ──

--@api-stub: lurek.camera.new
-- Creates a new Camera2D with the given viewport dimensions.
-- Build once at startup; reuse across frames.
local obj = lurek.camera.new(vw, vh)
print("created", obj)
return obj

-- ── Camera2D methods ──

--@api-stub: Camera2D:setPosition
-- Sets the camera's world-space position.
-- Apply at startup or in response to user input.
local camera2D = lurek.camera.newCamera2D()
camera2D:setPosition(100, 100)
print("Camera2D:setPosition applied")

--@api-stub: Camera2D:getPosition
-- Returns the camera's world-space position as x, y.
-- Cheap to call; safe inside callbacks.
local camera2D = lurek.camera.newCamera2D()  -- or your existing handle
local value = camera2D:getPosition()
print("Camera2D:getPosition ->", value)

--@api-stub: Camera2D:setZoom
-- Sets the uniform zoom factor (1.0 = natural size).
-- Apply at startup or in response to user input.
local camera2D = lurek.camera.newCamera2D()
camera2D:setZoom(zoom)
print("Camera2D:setZoom applied")

--@api-stub: Camera2D:getZoom
-- Returns the current zoom factor.
-- Cheap to call; safe inside callbacks.
local camera2D = lurek.camera.newCamera2D()  -- or your existing handle
local value = camera2D:getZoom()
print("Camera2D:getZoom ->", value)

--@api-stub: Camera2D:setRotation
-- Sets the rotation in radians.
-- Apply at startup or in response to user input.
local camera2D = lurek.camera.newCamera2D()
camera2D:setRotation(1)
print("Camera2D:setRotation applied")

--@api-stub: Camera2D:getRotation
-- Returns the rotation in radians.
-- Cheap to call; safe inside callbacks.
local camera2D = lurek.camera.newCamera2D()  -- or your existing handle
local value = camera2D:getRotation()
print("Camera2D:getRotation ->", value)

--@api-stub: Camera2D:getViewport
-- Returns the current viewport as x, y, w, h.
-- Cheap to call; safe inside callbacks.
local camera2D = lurek.camera.newCamera2D()  -- or your existing handle
local value = camera2D:getViewport()
print("Camera2D:getViewport ->", value)

--@api-stub: Camera2D:removeBounds
-- Removes previously set world-space bounds.
-- Pair with the matching constructor to free resources.
local camera2D = lurek.camera.newCamera2D()
camera2D:removeBounds()
-- camera2D is now released
print("ok")

--@api-stub: Camera2D:setTarget
-- Sets the follow target position.
-- Apply at startup or in response to user input.
local camera2D = lurek.camera.newCamera2D()
camera2D:setTarget(100, 100)
print("Camera2D:setTarget applied")

--@api-stub: Camera2D:clearTarget
-- Clears the follow target so the camera stops tracking.
-- Pair with the matching constructor to free resources.
local camera2D = lurek.camera.newCamera2D()
camera2D:clearTarget()
-- camera2D is now released
print("ok")

--@api-stub: Camera2D:setFollowSmooth
-- Sets the follow smooth interpolation speed (0.0 = instant snap).
-- Apply at startup or in response to user input.
local camera2D = lurek.camera.newCamera2D()
camera2D:setFollowSmooth(speed)
print("Camera2D:setFollowSmooth applied")

--@api-stub: Camera2D:setDeadZone
-- Sets the dead zone half-extents for camera follow.
-- Apply at startup or in response to user input.
local camera2D = lurek.camera.newCamera2D()
camera2D:setDeadZone(64, 64)
print("Camera2D:setDeadZone applied")

--@api-stub: Camera2D:setLookAhead
-- Sets the look-ahead multiplier for follow prediction.
-- Apply at startup or in response to user input.
local camera2D = lurek.camera.newCamera2D()
camera2D:setLookAhead(mul)
print("Camera2D:setLookAhead applied")

--@api-stub: Camera2D:shake
-- Starts a screen-shake effect.
-- See the module spec for detailed semantics.
local camera2D = lurek.camera.newCamera2D()
camera2D:shake(intensity, 1.0)
print("Camera2D:shake done")

--@api-stub: Camera2D:update
-- Advances the camera simulation by dt seconds.
-- Apply at startup or in response to user input.
local camera2D = lurek.camera.newCamera2D()
camera2D:update(dt)
print("Camera2D:update applied")

--@api-stub: Camera2D:toWorld
-- Converts screen coordinates to world coordinates.
-- See the module spec for detailed semantics.
local camera2D = lurek.camera.newCamera2D()
camera2D:toWorld(sx, sy)
print("Camera2D:toWorld done")

--@api-stub: Camera2D:toScreen
-- Converts world coordinates to screen coordinates.
-- See the module spec for detailed semantics.
local camera2D = lurek.camera.newCamera2D()
camera2D:toScreen(wx, wy)
print("Camera2D:toScreen done")

--@api-stub: Camera2D:getVisibleArea
-- Returns the visible world area as x, y, w, h.
-- Cheap to call; safe inside callbacks.
local camera2D = lurek.camera.newCamera2D()  -- or your existing handle
local value = camera2D:getVisibleArea()
print("Camera2D:getVisibleArea ->", value)

--@api-stub: Camera2D:lookAt
-- Instantly moves the camera to look at the given position.
-- See the module spec for detailed semantics.
local camera2D = lurek.camera.newCamera2D()
camera2D:lookAt(100, 100)
print("Camera2D:lookAt done")

--@api-stub: Camera2D:move
-- Translates the camera by dx, dy in world space.
-- See the module spec for detailed semantics.
local camera2D = lurek.camera.newCamera2D()
camera2D:move(100, 100)
print("Camera2D:move done")

--@api-stub: Camera2D:stopPath
-- Cancels the active camera path animation.
-- Trigger from input, timers, or game events.
local camera2D = lurek.camera.newCamera2D()
camera2D:stopPath()
-- trigger from input, timer, or event
print("ok")

--@api-stub: Camera2D:updatePath
-- Advances the path animation by `dt` seconds and applies the.
-- Apply at startup or in response to user input.
local camera2D = lurek.camera.newCamera2D()
camera2D:updatePath(dt)
print("Camera2D:updatePath applied")

--@api-stub: Camera2D:pathProgress
-- Returns the fractional progress `[0, 1]` of the active path, or.
-- See the module spec for detailed semantics.
local camera2D = lurek.camera.newCamera2D()
camera2D:pathProgress()
print("Camera2D:pathProgress done")

--@api-stub: Camera2D:zoomTo
-- Smoothly tweens the camera zoom from its current level to.
-- See the module spec for detailed semantics.
local camera2D = lurek.camera.newCamera2D()
camera2D:zoomTo(target_zoom, 1.0)
print("Camera2D:zoomTo done")

--@api-stub: Camera2D:stopZoom
-- Cancels the active zoom tween.
-- Trigger from input, timers, or game events.
local camera2D = lurek.camera.newCamera2D()
camera2D:stopZoom()
-- trigger from input, timer, or event
print("ok")

--@api-stub: Camera2D:updateZoom
-- Advances the zoom tween by `dt` seconds and applies the resulting.
-- Apply at startup or in response to user input.
local camera2D = lurek.camera.newCamera2D()
camera2D:updateZoom(dt)
print("Camera2D:updateZoom applied")

--@api-stub: Camera2D:getParallaxFactor
-- Returns the parallax factor for the named layer, or `1.0` if unset.
-- Cheap to call; safe inside callbacks.
local camera2D = lurek.camera.newCamera2D()  -- or your existing handle
local value = camera2D:getParallaxFactor(layer)
print("Camera2D:getParallaxFactor ->", value)

--@api-stub: Camera2D:clearParallaxFactors
-- Removes all parallax factor overrides.
-- Pair with the matching constructor to free resources.
local camera2D = lurek.camera.newCamera2D()
camera2D:clearParallaxFactors()
-- camera2D is now released
print("ok")

--@api-stub: Camera2D:zoomPulse
-- Triggers a momentary zoom-in that decays back via a sine envelope.
-- See the module spec for detailed semantics.
local camera2D = lurek.camera.newCamera2D()
camera2D:zoomPulse(amplitude, 1.0)
print("Camera2D:zoomPulse done")

--@api-stub: Camera2D:stopSway
-- Stops the active sway effect immediately.
-- Trigger from input, timers, or game events.
local camera2D = lurek.camera.newCamera2D()
camera2D:stopSway()
-- trigger from input, timer, or event
print("ok")

--@api-stub: Camera2D:isSway
-- Returns true if the sway effect is currently active.
-- Use as a guard inside lurek.update or event handlers.
local camera2D = lurek.camera.newCamera2D()
if camera2D:isSway() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Camera2D:stopBreathing
-- Stops the active breathing effect.
-- Trigger from input, timers, or game events.
local camera2D = lurek.camera.newCamera2D()
camera2D:stopBreathing()
-- trigger from input, timer, or event
print("ok")

--@api-stub: Camera2D:isBreathing
-- Returns true if the breathing effect is currently active.
-- Use as a guard inside lurek.update or event handlers.
local camera2D = lurek.camera.newCamera2D()
if camera2D:isBreathing() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Camera2D:getEffectiveZoom
-- Returns the current zoom level including zoom pulse and breathing deltas.
-- Cheap to call; safe inside callbacks.
local camera2D = lurek.camera.newCamera2D()  -- or your existing handle
local value = camera2D:getEffectiveZoom()
print("Camera2D:getEffectiveZoom ->", value)

--@api-stub: Camera2D:getEffectOffset
-- Returns the current sway x, y world-space offset.
-- Cheap to call; safe inside callbacks.
local camera2D = lurek.camera.newCamera2D()  -- or your existing handle
local value = camera2D:getEffectOffset()
print("Camera2D:getEffectOffset ->", value)

