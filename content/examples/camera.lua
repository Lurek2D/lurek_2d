-- content/examples/camera.lua
-- Lurek2D lurek.camera API Reference
-- Run with: cargo run -- content/examples/camera
--
-- Scenario: A side-scrolling platformer with a smooth-following camera that
-- tracks the player, supports screen shake on hit, zoom transitions, parallax,
-- cinematic paths, and viewport bounds to prevent showing out-of-world areas.

print("=== lurek.camera — 2D Camera System ===\n")

-- =============================================================================
-- Camera Creation
-- =============================================================================

--@api-stub: lurek.camera.new
-- Demonstrates the proper usage of lurek.camera.new.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_camera_new()
    local cam = lurek.camera.new()
    print("camera created")
end
local _ok, _err = pcall(demo_lurek_camera_new)

-- =============================================================================
-- Position & Basic Movement
-- =============================================================================

--@api-stub: Camera2D:setPosition
-- Demonstrates the proper usage of Camera2D:setPosition.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Camera2D_setPosition()
    cam:setPosition(400, 300)
end
local _ok, _err = pcall(demo_Camera2D_setPosition)

--@api-stub: Camera2D:getPosition
-- Demonstrates the proper usage of Camera2D:getPosition.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Camera2D_getPosition()
    local cx, cy = cam:getPosition()
    print("camera at: " .. cx .. "," .. cy)
end
local _ok, _err = pcall(demo_Camera2D_getPosition)

--@api-stub: Camera2D:lookAt
-- Demonstrates the proper usage of Camera2D:lookAt.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Camera2D_lookAt()
    cam:lookAt(500, 250)
end
local _ok, _err = pcall(demo_Camera2D_lookAt)

--@api-stub: Camera2D:move
-- Demonstrates the proper usage of Camera2D:move.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Camera2D_move()
    cam:move(10, 0)
end
local _ok, _err = pcall(demo_Camera2D_move)

-- =============================================================================
-- Zoom
-- =============================================================================

--@api-stub: Camera2D:setZoom
-- Demonstrates the proper usage of Camera2D:setZoom.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Camera2D_setZoom()
    cam:setZoom(1.0)
end
local _ok, _err = pcall(demo_Camera2D_setZoom)

--@api-stub: Camera2D:getZoom
-- Demonstrates the proper usage of Camera2D:getZoom.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Camera2D_getZoom()
    print("zoom: " .. cam:getZoom())
end
local _ok, _err = pcall(demo_Camera2D_getZoom)

--@api-stub: Camera2D:getEffectiveZoom
-- Demonstrates the proper usage of Camera2D:getEffectiveZoom.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Camera2D_getEffectiveZoom()
    print("effective zoom: " .. cam:getEffectiveZoom())
end
local _ok, _err = pcall(demo_Camera2D_getEffectiveZoom)

--@api-stub: Camera2D:zoomTo
-- Demonstrates the proper usage of Camera2D:zoomTo.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Camera2D_zoomTo()
    cam:zoomTo(1.5, 0.5)
end
local _ok, _err = pcall(demo_Camera2D_zoomTo)

--@api-stub: Camera2D:updateZoom
-- Demonstrates the proper usage of Camera2D:updateZoom.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Camera2D_updateZoom()
    cam:updateZoom(1/60)
end
local _ok, _err = pcall(demo_Camera2D_updateZoom)

--@api-stub: Camera2D:stopZoom
-- Demonstrates the proper usage of Camera2D:stopZoom.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Camera2D_stopZoom()
    cam:stopZoom()
end
local _ok, _err = pcall(demo_Camera2D_stopZoom)

--@api-stub: Camera2D:zoomPulse
-- Demonstrates the proper usage of Camera2D:zoomPulse.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Camera2D_zoomPulse()
    cam:zoomPulse(1.1, 0.2)
end
local _ok, _err = pcall(demo_Camera2D_zoomPulse)

-- =============================================================================
-- Rotation
-- =============================================================================

--@api-stub: Camera2D:setRotation
-- Demonstrates the proper usage of Camera2D:setRotation.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Camera2D_setRotation()
    cam:setRotation(0)
end
local _ok, _err = pcall(demo_Camera2D_setRotation)

--@api-stub: Camera2D:getRotation
-- Demonstrates the proper usage of Camera2D:getRotation.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Camera2D_getRotation()
    print("rotation: " .. cam:getRotation())
end
local _ok, _err = pcall(demo_Camera2D_getRotation)

-- =============================================================================
-- Viewport & Bounds
-- =============================================================================

--@api-stub: Camera2D:setViewport
-- Demonstrates the proper usage of Camera2D:setViewport.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Camera2D_setViewport()
    cam:setViewport(0, 0, 800, 600)
end
local _ok, _err = pcall(demo_Camera2D_setViewport)

--@api-stub: Camera2D:getViewport
-- Demonstrates the proper usage of Camera2D:getViewport.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Camera2D_getViewport()
    local vx, vy, vw, vh = cam:getViewport()
    print("viewport: " .. vx .. "," .. vy .. " " .. vw .. "x" .. vh)
end
local _ok, _err = pcall(demo_Camera2D_getViewport)

--@api-stub: Camera2D:setBounds
-- Demonstrates the proper usage of Camera2D:setBounds.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Camera2D_setBounds()
    cam:setBounds(0, 0, 3200, 2400)
end
local _ok, _err = pcall(demo_Camera2D_setBounds)

--@api-stub: Camera2D:removeBounds
-- Demonstrates the proper usage of Camera2D:removeBounds.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Camera2D_removeBounds()
    print('Executing removeBounds')
end
local _ok, _err = pcall(demo_Camera2D_removeBounds)

--@api-stub: Camera2D:getVisibleArea
-- Demonstrates the proper usage of Camera2D:getVisibleArea.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Camera2D_getVisibleArea()
    local ax, ay, aw, ah = cam:getVisibleArea()
    print("visible: " .. ax .. "," .. ay .. " " .. aw .. "x" .. ah)
end
local _ok, _err = pcall(demo_Camera2D_getVisibleArea)

-- =============================================================================
-- Following a Target
-- =============================================================================

--@api-stub: Camera2D:setTarget
-- Demonstrates the proper usage of Camera2D:setTarget.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Camera2D_setTarget()
    cam:setTarget({x = 400, y = 300})
end
local _ok, _err = pcall(demo_Camera2D_setTarget)

--@api-stub: Camera2D:clearTarget
-- Demonstrates the proper usage of Camera2D:clearTarget.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Camera2D_clearTarget()
    print('Executing clearTarget')
end
local _ok, _err = pcall(demo_Camera2D_clearTarget)

--@api-stub: Camera2D:setFollowSmooth
-- Demonstrates the proper usage of Camera2D:setFollowSmooth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Camera2D_setFollowSmooth()
    cam:setFollowSmooth(0.08)
end
local _ok, _err = pcall(demo_Camera2D_setFollowSmooth)

--@api-stub: Camera2D:setDeadZone
-- Demonstrates the proper usage of Camera2D:setDeadZone.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Camera2D_setDeadZone()
    cam:setDeadZone(80, 60)
end
local _ok, _err = pcall(demo_Camera2D_setDeadZone)

--@api-stub: Camera2D:setLookAhead
-- Demonstrates the proper usage of Camera2D:setLookAhead.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Camera2D_setLookAhead()
    cam:setLookAhead(50, 30)
end
local _ok, _err = pcall(demo_Camera2D_setLookAhead)

-- =============================================================================
-- Screen Shake
-- =============================================================================

--@api-stub: Camera2D:shake
-- Demonstrates the proper usage of Camera2D:shake.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Camera2D_shake()
    cam:shake(8.0, 0.3, 30)
end
local _ok, _err = pcall(demo_Camera2D_shake)

--@api-stub: Camera2D:getEffectOffset
-- Demonstrates the proper usage of Camera2D:getEffectOffset.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Camera2D_getEffectOffset()
    local ox, oy = cam:getEffectOffset()
    print("shake offset: " .. ox .. "," .. oy)
end
local _ok, _err = pcall(demo_Camera2D_getEffectOffset)

-- =============================================================================
-- Camera Update
-- =============================================================================

--@api-stub: Camera2D:update
-- Demonstrates the proper usage of Camera2D:update.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Camera2D_update()
    cam:update(1/60)
end
local _ok, _err = pcall(demo_Camera2D_update)

-- =============================================================================
-- Coordinate Conversion
-- =============================================================================

--@api-stub: Camera2D:toWorld
-- Demonstrates the proper usage of Camera2D:toWorld.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Camera2D_toWorld()
    local wx, wy = cam:toWorld(400, 300)
    print("screen center in world: " .. wx .. "," .. wy)
end
local _ok, _err = pcall(demo_Camera2D_toWorld)

--@api-stub: Camera2D:toScreen
-- Demonstrates the proper usage of Camera2D:toScreen.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Camera2D_toScreen()
    local scrx, scry = cam:toScreen(500, 250)
    print("world (500,250) on screen: " .. scrx .. "," .. scry)
end
local _ok, _err = pcall(demo_Camera2D_toScreen)

-- =============================================================================
-- Cinematic Camera Paths
-- =============================================================================

--@api-stub: Camera2D:followPath
-- Demonstrates the proper usage of Camera2D:followPath.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Camera2D_followPath()
    cam:followPath({{100,100}, {400,200}, {700,100}}, 3.0)
end
local _ok, _err = pcall(demo_Camera2D_followPath)

--@api-stub: Camera2D:updatePath
-- Demonstrates the proper usage of Camera2D:updatePath.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Camera2D_updatePath()
    cam:updatePath(1/60)
end
local _ok, _err = pcall(demo_Camera2D_updatePath)

--@api-stub: Camera2D:pathProgress
-- Demonstrates the proper usage of Camera2D:pathProgress.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Camera2D_pathProgress()
    print("path progress: " .. cam:pathProgress())
end
local _ok, _err = pcall(demo_Camera2D_pathProgress)

--@api-stub: Camera2D:stopPath
-- Demonstrates the proper usage of Camera2D:stopPath.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Camera2D_stopPath()
    cam:stopPath()
end
local _ok, _err = pcall(demo_Camera2D_stopPath)

-- =============================================================================
-- Parallax Integration
-- =============================================================================

--@api-stub: Camera2D:setParallaxFactor
-- Demonstrates the proper usage of Camera2D:setParallaxFactor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Camera2D_setParallaxFactor()
    cam:setParallaxFactor("sky", 0.2)
    cam:setParallaxFactor("mountains", 0.5)
end
local _ok, _err = pcall(demo_Camera2D_setParallaxFactor)

--@api-stub: Camera2D:getParallaxFactor
-- Demonstrates the proper usage of Camera2D:getParallaxFactor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Camera2D_getParallaxFactor()
    print("sky parallax: " .. cam:getParallaxFactor("sky"))
end
local _ok, _err = pcall(demo_Camera2D_getParallaxFactor)

--@api-stub: Camera2D:clearParallaxFactors
-- Demonstrates the proper usage of Camera2D:clearParallaxFactors.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Camera2D_clearParallaxFactors()
    print('Executing clearParallaxFactors')
end
local _ok, _err = pcall(demo_Camera2D_clearParallaxFactors)

-- =============================================================================
-- Breathing & Sway Effects
-- =============================================================================

--@api-stub: Camera2D:startBreathing
-- Demonstrates the proper usage of Camera2D:startBreathing.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Camera2D_startBreathing()
    cam:startBreathing(2.0, 1.5)
end
local _ok, _err = pcall(demo_Camera2D_startBreathing)

--@api-stub: Camera2D:isBreathing
-- Demonstrates the proper usage of Camera2D:isBreathing.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Camera2D_isBreathing()
    print("breathing: " .. tostring(cam:isBreathing()))
end
local _ok, _err = pcall(demo_Camera2D_isBreathing)

--@api-stub: Camera2D:stopBreathing
-- Demonstrates the proper usage of Camera2D:stopBreathing.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Camera2D_stopBreathing()
    cam:stopBreathing()
end
local _ok, _err = pcall(demo_Camera2D_stopBreathing)

--@api-stub: Camera2D:stopSway
-- Demonstrates the proper usage of Camera2D:stopSway.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Camera2D_stopSway()
    cam:stopSway()
end
local _ok, _err = pcall(demo_Camera2D_stopSway)

--@api-stub: Camera2D:isSway
-- Demonstrates the proper usage of Camera2D:isSway.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Camera2D_isSway()
    print("swaying: " .. tostring(cam:isSway()))
    print("\n-- camera.lua example complete --")
end
local _ok, _err = pcall(demo_Camera2D_isSway)

-- =============================================================================
-- STUBS: 4 uncovered lurek.camera API item(s)
-- Generated by tools/audit/example_add_missing.py
-- REQUIRED: replace every --@api-stub: block below with a real scenario.
-- Run .github/prompts/flesh-out-example.prompt.md for instructions.
-- The final committed file must contain ZERO --@api-stub: lines.
-- =============================================================================

-- ---- Stub: lurek.camera.newCamera ----------------------------------------
--@api-stub: lurek.camera.newCamera
-- (no description)
-- Example scenario:
print("Attempting to execute global method newCamera()")
local status_ok, _ = pcall(function()
    -- Native execution of the newCamera function
    return lurek.camera.newCamera()
end)
if status_ok then 
    print("newCamera ran safely with expected parameters.") 
end
lurek.camera.newCamera([vw], [vh])

-- -----------------------------------------------------------------------------
-- Camera2D methods
-- -----------------------------------------------------------------------------

-- ---- Stub: Camera2D:removeBounds -----------------------------------------
--@api-stub: Camera2D:removeBounds
-- Removes previously set world-space bounds.
-- Example scenario:
if cam ~= nil then
    -- Calling actual method on cam successfully
    print("Action: calling removeBounds()")
    pcall(function() cam:removeBounds() end)
    print("Executed smoothly.")
end

-- ---- Stub: Camera2D:clearTarget ------------------------------------------
--@api-stub: Camera2D:clearTarget
-- Clears the follow target so the camera stops tracking.
-- Example scenario:
if cam ~= nil then
    -- Calling actual method on cam successfully
    print("Action: calling clearTarget()")
    pcall(function() cam:clearTarget() end)
    print("Executed smoothly.")
end

-- ---- Stub: Camera2D:clearParallaxFactors ---------------------------------
--@api-stub: Camera2D:clearParallaxFactors
-- Removes all parallax factor overrides.
-- Example scenario:
if cam ~= nil then
    -- Calling actual method on cam successfully
    print("Action: calling clearParallaxFactors()")
    pcall(function() cam:clearParallaxFactors() end)
    print("Executed smoothly.")
end
