-- content/examples/camera.lua
-- lurek.camera API examples.
-- Run: cargo run -- content/examples/camera.lua

--@api-stub: lurek.camera.new -- Creates a 2D camera with optional virtual viewport size
do -- lurek.camera.new
  local cam = lurek.camera.new(1280, 720)
  cam:setPosition(0, 0)
  lurek.log.info("camera viewport=" .. 1280 .. "x" .. 720, "camera")
end

-- == Camera2D methods ==

--@api-stub: Camera2D:setPosition
do -- Camera2D:setPosition
  local cam = lurek.camera.new(800, 600)
  local player_x, player_y = 512, 384
  cam:setPosition(player_x - 400, player_y - 300)
end

--@api-stub: Camera2D:getPosition
do -- Camera2D:getPosition
  local cam = lurek.camera.new(800, 600)
  cam:setPosition(120, 240)
  local cx, cy = cam:getPosition()
  lurek.log.debug("camera at " .. cx .. "," .. cy, "camera")
end

--@api-stub: Camera2D:setZoom
do -- Camera2D:setZoom
  local cam = lurek.camera.new(800, 600)
  cam:setZoom(2.0)
end

--@api-stub: Camera2D:getZoom
do -- Camera2D:getZoom
  local cam = lurek.camera.new(800, 600)
  cam:setZoom(1.5)
  local z = cam:getZoom()
  if z > 1.0 then lurek.log.info("zoomed in: " .. z, "camera") end
end

--@api-stub: Camera2D:setRotation
do -- Camera2D:setRotation
  local cam = lurek.camera.new(800, 600)
  cam:setRotation(math.pi / 8)
end

--@api-stub: Camera2D:getRotation
do -- Camera2D:getRotation
  local cam = lurek.camera.new(800, 600)
  cam:setRotation(0.5)
  local r = cam:getRotation()
  lurek.log.debug("rotation rad=" .. r .. " deg=" .. math.deg(r), "camera")
end

--@api-stub: Camera2D:getViewport
do -- Camera2D:getViewport
  local cam = lurek.camera.new(1280, 720)
  local vx, vy, vw, vh = cam:getViewport()
  lurek.log.info("viewport=" .. vx .. "," .. vy .. " " .. vw .. "x" .. vh, "camera")
end

--@api-stub: Camera2D:removeBounds
do -- Camera2D:removeBounds
  local cam = lurek.camera.new(800, 600)
  cam:setBounds(0, 0, 4096, 2048)
  cam:removeBounds()
end

--@api-stub: Camera2D:setTarget
do -- Camera2D:setTarget
  local cam = lurek.camera.new(800, 600)
  local enemy = { x = 1024, y = 512 }
  cam:setTarget(enemy.x, enemy.y)
end

--@api-stub: Camera2D:clearTarget
do -- Camera2D:clearTarget
  local cam = lurek.camera.new(800, 600)
  cam:setTarget(500, 500)
  cam:clearTarget()
end

--@api-stub: Camera2D:setFollowSmooth
do -- Camera2D:setFollowSmooth
  local cam = lurek.camera.new(800, 600)
  cam:setFollowSmooth(6.0)
end

--@api-stub: Camera2D:setDeadZone
do -- Camera2D:setDeadZone
  local cam = lurek.camera.new(800, 600)
  cam:setDeadZone(40, 24)
end

--@api-stub: Camera2D:setLookAhead
do -- Camera2D:setLookAhead
  local cam = lurek.camera.new(800, 600)
  cam:setLookAhead(0.25)
end

--@api-stub: Camera2D:shake
do -- Camera2D:shake
  local cam = lurek.camera.new(800, 600)
  cam:shake(8.0, 0.35)
end

--@api-stub: Camera2D:update
do -- Camera2D:update
  local cam = lurek.camera.new(800, 600)
  function lurek.process(dt) cam:update(dt) end
end

--@api-stub: Camera2D:toWorld
do -- Camera2D:toWorld
  local cam = lurek.camera.new(800, 600)
  cam:setPosition(200, 100)
  local wx, wy = cam:toWorld(400, 300)
  lurek.log.debug("click world=" .. wx .. "," .. wy, "input")
end

--@api-stub: Camera2D:toScreen
do -- Camera2D:toScreen
  local cam = lurek.camera.new(800, 600)
  local enemy_wx, enemy_wy = 1024, 512
  local sx, sy = cam:toScreen(enemy_wx, enemy_wy)
  if sx >= 0 and sx < 800 then lurek.log.debug("enemy on-screen at " .. sx .. "," .. sy, "hud") end
end

--@api-stub: Camera2D:getVisibleArea
do -- Camera2D:getVisibleArea
  local cam = lurek.camera.new(800, 600)
  local vx, vy, vw, vh = cam:getVisibleArea()
  lurek.log.info("visible " .. vx .. "," .. vy .. " " .. vw .. "x" .. vh, "render")
end

--@api-stub: Camera2D:lookAt
do -- Camera2D:lookAt
  local cam = lurek.camera.new(800, 600)
  cam:lookAt(2048, 1024)
end

--@api-stub: Camera2D:move
do -- Camera2D:move
  local cam = lurek.camera.new(800, 600)
  function lurek.process(dt) cam:move(200 * dt, 0) end
end

--@api-stub: Camera2D:stopPath
do -- Camera2D:stopPath
  local cam = lurek.camera.new(800, 600)
  cam:followPath({ {0, 0}, {500, 500} }, 3.0)
  cam:stopPath()
end

--@api-stub: Camera2D:updatePath
do -- Camera2D:updatePath
  local cam = lurek.camera.new(800, 600)
  cam:followPath({ {0, 0}, {800, 600}, {0, 600} }, 4.0)
  function lurek.process(dt) if not cam:updatePath(dt) then cam:setTarget(400, 300) end end
end

--@api-stub: Camera2D:pathProgress
do -- Camera2D:pathProgress
  local cam = lurek.camera.new(800, 600)
  cam:followPath({ {0, 0}, {1000, 0} }, 2.0)
  local p = cam:pathProgress()
  lurek.log.debug("path " .. math.floor(p * 100) .. "%", "cutscene")
end

--@api-stub: Camera2D:zoomTo
do -- Camera2D:zoomTo
  local cam = lurek.camera.new(800, 600)
  cam:zoomTo(2.5, 0.8)
end

--@api-stub: Camera2D:stopZoom
do -- Camera2D:stopZoom
  local cam = lurek.camera.new(800, 600)
  cam:zoomTo(3.0, 1.0)
  cam:stopZoom()
end

--@api-stub: Camera2D:updateZoom
do -- Camera2D:updateZoom
  local cam = lurek.camera.new(800, 600)
  cam:zoomTo(1.5, 0.6)
  function lurek.process(dt) if not cam:updateZoom(dt) then lurek.log.debug("zoom done", "camera") end end
end

--@api-stub: Camera2D:getParallaxFactor
do -- Camera2D:getParallaxFactor
  local cam = lurek.camera.new(800, 600)
  cam:setParallaxFactor("clouds", 0.2)
  local f = cam:getParallaxFactor("clouds")
  lurek.log.debug("clouds parallax=" .. f, "render")
end

--@api-stub: Camera2D:clearParallaxFactors
do -- Camera2D:clearParallaxFactors
  local cam = lurek.camera.new(800, 600)
  cam:setParallaxFactor("sky", 0.1)
  cam:clearParallaxFactors()
end

--@api-stub: Camera2D:zoomPulse
do -- Camera2D:zoomPulse
  local cam = lurek.camera.new(800, 600)
  cam:zoomPulse(0.08, 0.25)
end

--@api-stub: Camera2D:stopSway
do -- Camera2D:stopSway
  local cam = lurek.camera.new(800, 600)
  cam:startSway(4, 2, 0.8)
  cam:stopSway()
end

--@api-stub: Camera2D:isSway
do -- Camera2D:isSway
  local cam = lurek.camera.new(800, 600)
  cam:startSway(3, 1.5, 0.5)
  if cam:isSway() then lurek.log.debug("on swaying surface", "camera") end
end

--@api-stub: Camera2D:stopBreathing
do -- Camera2D:stopBreathing
  local cam = lurek.camera.new(800, 600)
  cam:startBreathing(0.005, 0.2)
  cam:stopBreathing()
end

--@api-stub: Camera2D:isBreathing
do -- Camera2D:isBreathing
  local cam = lurek.camera.new(800, 600)
  cam:startBreathing()
  if cam:isBreathing() then lurek.log.debug("breathing on", "camera") end
end

--@api-stub: Camera2D:getEffectiveZoom
do -- Camera2D:getEffectiveZoom
  local cam = lurek.camera.new(800, 600)
  cam:setZoom(1.5)
  cam:zoomPulse(0.1, 0.3)
  local ez = cam:getEffectiveZoom()
  lurek.log.debug("effective zoom=" .. ez, "render")
end

--@api-stub: Camera2D:getEffectOffset
do -- Camera2D:getEffectOffset
  local cam = lurek.camera.new(800, 600)
  cam:startSway(6, 3, 0.6)
  local ox, oy = cam:getEffectOffset()
  lurek.log.debug("sway offset " .. ox .. "," .. oy, "camera")
end

--@api-stub: Camera2D:apply
do -- Camera2D:apply
  local cam = lurek.camera.new()
  cam:setPosition(400, 300)
  cam:setZoom(1.5)
  cam:apply()
  lurek.log.info("camera applied", "camera")
end

--@api-stub: Camera2D:attach
do -- Camera2D:attach
  local cam = lurek.camera.new()
  cam:setPosition(200, 150)
  cam:attach()
  lurek.log.info("camera attached", "camera")
end

--@api-stub: Camera2D:detach
do -- Camera2D:detach
  local cam = lurek.camera.new()
  cam:attach()
  cam:detach()
  lurek.log.info("camera detached", "camera")
end

--@api-stub: Camera2D:followPath
do -- Camera2D:followPath
  local cam = lurek.camera.new()
  local path = {{x=0,y=0},{x=200,y=100},{x=400,y=0}}
  cam:followPath(path, 120)
  lurek.log.info("following path", "camera")
end

--@api-stub: lurek.camera.newCamera -- Creates a 2D camera with optional virtual viewport size
do -- lurek.camera.newCamera
  local cam = lurek.camera.newCamera(800, 600)
  cam:setPosition(400, 300)
  cam:setZoom(1.0)
  lurek.log.info("named camera created", "camera")
end

--@api-stub: Camera2D:reset
do -- Camera2D:reset
  local cam = lurek.camera.new()
  cam:setZoom(2.5)
  cam:reset()
  lurek.log.info("zoom after reset: " .. cam:getZoom(), "camera")
end

--@api-stub: Camera2D:setBounds
do -- Camera2D:setBounds
  local cam = lurek.camera.new()
  cam:setBounds(0, 0, 3200, 2400)
  cam:setPosition(400, 300)
  lurek.log.info("bounds set", "camera")
end

--@api-stub: Camera2D:setParallaxFactor
do -- Camera2D:setParallaxFactor
  local cam = lurek.camera.new()
  cam:setParallaxFactor("bg_mountains", 0.3)
  cam:setParallaxFactor("bg_clouds", 0.15)
  lurek.log.info("parallax factors set", "camera")
end

--@api-stub: Camera2D:setViewport
do -- Camera2D:setViewport
  local cam = lurek.camera.new()
  cam:setViewport(0, 0, 640, 480)
  lurek.log.info("viewport set", "camera")
end

--@api-stub: Camera2D:startBreathing
do -- Camera2D:startBreathing
  local cam = lurek.camera.new()
  cam:startBreathing(2.0, 4.0)
  lurek.log.info("breathing: " .. tostring(cam:isBreathing()), "camera")
end

--@api-stub: Camera2D:startSway
do -- Camera2D:startSway
  local cam = lurek.camera.new()
  cam:startSway(5.0, 0.8, 0.95)
  lurek.log.info("sway active: " .. tostring(cam:isSway()), "camera")
end

-- =============================================================================
-- COVERAGE: 2 uncovered lurek.camera API item(s)
-- Generated by tools/audit/example_add_missing.py
-- REQUIRED: replace every --@api-stub: block below with a real scenario.
-- Run .github/prompts/flesh-out-example.prompt.md for instructions.
-- The final committed file must contain ZERO --@api-stub: lines.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Camera2D methods
-- -----------------------------------------------------------------------------

--@api-stub: Camera2D:type
do -- Camera2D:type
  local cam = lurek.camera.new(800, 600)
  local t = cam:type()
  lurek.log.info("Camera2D:type=" .. t, "camera")
end
--@api-stub: Camera2D:typeOf
do -- Camera2D:typeOf
  local cam = lurek.camera.new(800, 600)
  lurek.log.info("is Camera2D: " .. tostring(cam:typeOf("Camera2D")), "camera")
  lurek.log.info("is wrong: " .. tostring(cam:typeOf("Unknown")), "camera")
end
-- =============================================================================

-- -----------------------------------------------------------------------------
-- LCamera methods
-- -----------------------------------------------------------------------------

--@api-stub: LCamera:type -- Returns the Lua-visible type name for this camera handle
do -- LCamera:type
  local camera_obj = lurek.camera.new(800, 600)
  local t = camera_obj:type()
  lurek.log.info("LCamera:type = " .. t, "camera")
end
--@api-stub: LCamera:typeOf -- Returns whether this camera handle matches a supported type name
do -- LCamera:typeOf
  local camera_obj = lurek.camera.new(800, 600)
  lurek.log.info("is LCamera: " .. tostring(camera_obj:typeOf("LCamera")), "camera")
  lurek.log.info("is wrong: " .. tostring(camera_obj:typeOf("Unknown")), "camera")
end
-- =============================================================================

-- -----------------------------------------------------------------------------
-- LCamera methods
-- -----------------------------------------------------------------------------

--@api-stub: LCamera:setPosition -- Sets the camera world position
do -- LCamera:setPosition
  local cam = lurek.camera.new(800, 600)
  cam:setPosition(256, 128)
  local x, y = cam:getPosition()
  lurek.log.info("position=" .. x .. "," .. y, "camera")
end
--@api-stub: LCamera:getPosition -- Returns the camera world position
do -- LCamera:getPosition
  local cam = lurek.camera.new(800, 600)
  cam:setPosition(100, 200)
  local x, y = cam:getPosition()
  lurek.log.info("x=" .. x .. " y=" .. y, "camera")
end
--@api-stub: LCamera:setZoom -- Sets the camera zoom factor
do -- LCamera:setZoom
  local cam = lurek.camera.new(800, 600)
  cam:setZoom(2.0)   -- 2Ă— magnification
  lurek.log.info("zoom=" .. cam:getZoom(), "camera")
end
--@api-stub: LCamera:getZoom -- Returns the camera zoom factor
do -- LCamera:getZoom
  local cam = lurek.camera.new(800, 600)
  cam:setZoom(0.5)
  lurek.log.info("zoom=" .. cam:getZoom(), "camera")
end
--@api-stub: LCamera:setRotation -- Sets the camera rotation
do -- LCamera:setRotation
  local cam = lurek.camera.new(800, 600)
  cam:setRotation(math.pi / 8)
  lurek.log.info("rotation=" .. cam:getRotation(), "camera")
end
--@api-stub: LCamera:getRotation -- Returns the camera rotation
do -- LCamera:getRotation
  local cam = lurek.camera.new(800, 600)
  cam:setRotation(math.pi / 4)
  lurek.log.info("rotation=" .. cam:getRotation(), "camera")
end
--@api-stub: LCamera:setViewport -- Sets the camera viewport rectangle
do -- LCamera:setViewport
  local cam = lurek.camera.new(800, 600)
  cam:setViewport(0, 0, 640, 480)
  local x, y, w, h = cam:getViewport()
  lurek.log.info("viewport=" .. w .. "x" .. h, "camera")
end
--@api-stub: LCamera:getViewport -- Returns the camera viewport rectangle
do -- LCamera:getViewport
  local cam = lurek.camera.new(800, 600)
  cam:setViewport(0, 0, 800, 600)
  local x, y, w, h = cam:getViewport()
  lurek.log.info("viewport " .. w .. "x" .. h, "camera")
end
--@api-stub: LCamera:setBounds -- Sets camera world bounds
do -- LCamera:setBounds
  local cam = lurek.camera.new(800, 600)
  cam:setBounds(0, 0, 2048, 1024)   -- constrain to 2048Ă—1024 world
  lurek.log.info("bounds set", "camera")
end
--@api-stub: LCamera:removeBounds -- Removes active camera bounds
do -- LCamera:removeBounds
  local cam = lurek.camera.new(800, 600)
  cam:setBounds(0, 0, 1024, 768)
  cam:removeBounds()
  lurek.log.info("bounds removed", "camera")
end
--@api-stub: LCamera:setTarget -- Sets a world-space follow target
do -- LCamera:setTarget
  local cam = lurek.camera.new(800, 600)
  cam:setFollowSmooth(5.0)
  cam:setTarget(320, 240)
  cam:update(0.016)
  local x, y = cam:getPosition()
  lurek.log.info("after follow: x=" .. x .. " y=" .. y, "camera")
end
--@api-stub: LCamera:clearTarget -- Clears the follow target
do -- LCamera:clearTarget
  local cam = lurek.camera.new(800, 600)
  cam:setTarget(400, 300)
  cam:clearTarget()
  lurek.log.info("follow target cleared", "camera")
end
--@api-stub: LCamera:setFollowSmooth -- Sets follow smoothing speed
do -- LCamera:setFollowSmooth
  local cam = lurek.camera.new(800, 600)
  cam:setFollowSmooth(4.0)   -- smooth follow, 4 units/s lag
  cam:setTarget(200, 100)
  cam:update(0.1)
  local x, y = cam:getPosition()
  lurek.log.info("smoothed pos=" .. x .. "," .. y, "camera")
end
--@api-stub: LCamera:setDeadZone -- Sets follow dead-zone dimensions
do -- LCamera:setDeadZone
  local cam = lurek.camera.new(800, 600)
  cam:setFollowSmooth(10.0)
  cam:setDeadZone(64, 32)   -- 64px horizontal, 32px vertical dead zone
  cam:setTarget(100, 100)
  cam:update(0.1)
  lurek.log.info("dead zone configured", "camera")
end
--@api-stub: LCamera:setLookAhead -- Sets follow look-ahead multiplier
do -- LCamera:setLookAhead
  local cam = lurek.camera.new(800, 600)
  cam:setFollowSmooth(5.0)
  cam:setLookAhead(2.0)   -- show 2Ă— velocity ahead of target
  cam:setTarget(400, 300)
  cam:update(0.016)
  lurek.log.info("look-ahead set", "camera")
end
--@api-stub: LCamera:shake -- Starts a camera shake effect
do -- LCamera:shake
  local cam = lurek.camera.new(800, 600)
  cam:shake(0.5, 8.0)   -- shake for 0.5s with amplitude 8 pixels
  lurek.log.info("shake started", "camera")
end
--@api-stub: LCamera:update -- Advances camera follow, shake, and effect state
do -- LCamera:update
  local cam = lurek.camera.new(800, 600)
  cam:shake(1.0, 4.0)
  cam:update(0.016)   -- advance one frame at 60 fps
  lurek.log.info("camera updated", "camera")
end
--@api-stub: LCamera:toWorld -- Converts screen coordinates to world coordinates
do -- LCamera:toWorld
  local cam = lurek.camera.new(800, 600)
  cam:setPosition(100, 100)
  cam:setZoom(2.0)
  local wx, wy = cam:toWorld(400, 300)   -- screen center
  lurek.log.info("world(" .. wx .. "," .. wy .. ")", "camera")
end
--@api-stub: LCamera:toScreen -- Converts world coordinates to screen coordinates
do -- LCamera:toScreen
  local cam = lurek.camera.new(800, 600)
  cam:setPosition(0, 0)
  cam:setZoom(1.0)
  local sx, sy = cam:toScreen(100, 50)
  lurek.log.info("screen(" .. sx .. "," .. sy .. ")", "camera")
end
--@api-stub: LCamera:getVisibleArea -- Returns the world-space area visible through this camera
do -- LCamera:getVisibleArea
  local cam = lurek.camera.new(800, 600)
  cam:setPosition(0, 0)
  cam:setZoom(1.0)
  local x, y, w, h = cam:getVisibleArea()
  lurek.log.info("visible=" .. w .. "x" .. h .. " at " .. x .. "," .. y, "camera")
end
--@api-stub: LCamera:lookAt -- Centers the camera on a world position
do -- LCamera:lookAt
  local cam = lurek.camera.new(800, 600)
  cam:lookAt(512, 256)
  local x, y = cam:getPosition()
  lurek.log.info("camera now at " .. x .. "," .. y, "camera")
end
--@api-stub: LCamera:move -- Moves the camera by a delta
do -- LCamera:move
  local cam = lurek.camera.new(800, 600)
  cam:lookAt(0, 0)
  cam:move(50, 25)
  local x, y = cam:getPosition()
  lurek.log.info("after move: " .. x .. "," .. y, "camera")
end
--@api-stub: LCamera:followPath -- Starts camera movement along an array of waypoint tables
do -- LCamera:followPath
  local cam = lurek.camera.new(800, 600)
  local waypoints = {{x=0,y=0},{x=200,y=100},{x=400,y=200}}
  cam:followPath(waypoints, 3.0)   -- traverse path over 3 seconds
  lurek.log.info("path started, progress=" .. cam:pathProgress(), "camera")
end
--@api-stub: LCamera:followPath -- Starts camera movement along an array of waypoint tables
do -- LCamera:followPath
  local cam = lurek.camera.new(800, 600)
  cam:followPath({{x=0,y=0},{x=500,y=300}}, 5.0)
  cam:stopPath()
  lurek.log.info("path cancelled", "camera")
end
--@api-stub: LCamera:updatePath -- Advances the active camera path and applies its position
do -- LCamera:updatePath
  local cam = lurek.camera.new(800, 600)
  cam:followPath({{x=0,y=0},{x=200,y=0}}, 2.0)
  cam:updatePath(0.5)
  lurek.log.info("path progress=" .. cam:pathProgress(), "camera")
end
--@api-stub: LCamera:pathProgress -- Returns active path progress
do -- LCamera:pathProgress
  local cam = lurek.camera.new(800, 600)
  cam:followPath({{x=0,y=0},{x=400,y=0}}, 4.0)
  cam:updatePath(1.0)   -- advance 25%
  lurek.log.info("path progress=" .. cam:pathProgress(), "camera")
end
--@api-stub: LCamera:zoomTo -- Starts a zoom tween toward a target zoom factor
do -- LCamera:zoomTo
  local cam = lurek.camera.new(800, 600)
  cam:setZoom(1.0)
  cam:zoomTo(2.5, 0.8)   -- zoom to 2.5Ă— over 0.8 seconds
  cam:updateZoom(0.4)
  lurek.log.info("zoom=" .. cam:getZoom(), "camera")
end
--@api-stub: LCamera:stopZoom -- Stops the active zoom tween
do -- LCamera:stopZoom
  local cam = lurek.camera.new(800, 600)
  cam:zoomTo(3.0, 2.0)
  cam:stopZoom()
  lurek.log.info("zoom tween stopped", "camera")
end
--@api-stub: LCamera:updateZoom -- Advances the active zoom tween and applies its zoom value
do -- LCamera:updateZoom
  local cam = lurek.camera.new(800, 600)
  cam:zoomTo(2.0, 1.0)
  cam:updateZoom(0.5)   -- advance halfway
  lurek.log.info("zoom mid-tween=" .. cam:getZoom(), "camera")
end
--@api-stub: LCamera:setParallaxFactor -- Sets a parallax factor for a named layer
do -- LCamera:setParallaxFactor
  local cam = lurek.camera.new(800, 600)
  cam:setParallaxFactor("bg_clouds", 0.3)
  cam:setParallaxFactor("bg_hills", 0.6)
  lurek.log.info("parallax bg_clouds=" .. cam:getParallaxFactor("bg_clouds"), "camera")
end
--@api-stub: LCamera:getParallaxFactor -- Returns a parallax factor for a named layer
do -- LCamera:getParallaxFactor
  local cam = lurek.camera.new(800, 600)
  cam:setParallaxFactor("sky", 0.1)
  lurek.log.info("sky factor=" .. cam:getParallaxFactor("sky"), "camera")
  lurek.log.info("unset factor=" .. cam:getParallaxFactor("foreground"), "camera")
end
--@api-stub: LCamera:clearParallaxFactors -- Clears all layer parallax factor overrides
do -- LCamera:clearParallaxFactors
  local cam = lurek.camera.new(800, 600)
  cam:setParallaxFactor("clouds", 0.4)
  cam:clearParallaxFactors()
  lurek.log.info("parallax factor after clear=" .. cam:getParallaxFactor("clouds"), "camera")
end
--@api-stub: LCamera:apply -- Appends render commands that apply this camera transform
do -- LCamera:apply
  local cam = lurek.camera.new(800, 600)
  cam:setPosition(100, 50)
  cam:setZoom(1.5)
  cam:apply()
  -- ... draw world-space sprites here ...
  cam:reset()
  lurek.log.info("camera applied and reset", "camera")
end
--@api-stub: LCamera:reset -- Appends a render command that removes the active camera transform
do -- LCamera:reset
  local cam = lurek.camera.new(800, 600)
  cam:apply()
  -- ... draw game world ...
  cam:reset()
  lurek.log.info("render transform restored", "camera")
end
--@api-stub: LCamera:attach -- Appends render commands that attach this camera transform
do -- LCamera:attach
  local cam = lurek.camera.new(800, 600)
  cam:setPosition(0, 0)
  cam:attach()
  -- ... render world geometry ...
  cam:detach()
  lurek.log.info("attach/detach cycle complete", "camera")
end
--@api-stub: LCamera:detach -- Appends a render command that detaches the active camera transform
do -- LCamera:detach
  local cam = lurek.camera.new(800, 600)
  cam:attach()
  cam:detach()
  lurek.log.info("detached, transforms restored", "camera")
end
--@api-stub: LCamera:zoomPulse -- Triggers a temporary zoom pulse effect
do -- LCamera:zoomPulse
  local cam = lurek.camera.new(800, 600)
  cam:zoomPulse(0.3, 0.5)   -- +30% zoom pulse decaying over 0.5s
  cam:update(0.016)
  lurek.log.info("pulse zoom=" .. cam:getEffectiveZoom(), "camera")
end
--@api-stub: LCamera:startSway -- Starts camera sway offset animation
do -- LCamera:startSway
  local cam = lurek.camera.new(800, 600)
  cam:startSway(4.0, 1.5, 0.3, 2.0)   -- amp_x=4, amp_y=1.5, freq_x=0.3, freq_y=2
  cam:update(0.016)
  lurek.log.info("sway active=" .. tostring(cam:isSway()), "camera")
end
--@api-stub: LCamera:stopSway -- Stops camera sway offset animation
do -- LCamera:stopSway
  local cam = lurek.camera.new(800, 600)
  cam:startSway(3.0, 1.0, 0.5, 1.0)
  cam:stopSway()
  lurek.log.info("sway=" .. tostring(cam:isSway()), "camera")
end
--@api-stub: LCamera:isSway -- Returns whether camera sway is active
do -- LCamera:isSway
  local cam = lurek.camera.new(800, 600)
  lurek.log.info("before sway: " .. tostring(cam:isSway()), "camera")
  cam:startSway(2.0, 1.0, 0.5, 0.5)
  lurek.log.info("after start: " .. tostring(cam:isSway()), "camera")
end
--@api-stub: LCamera:startBreathing -- Starts subtle breathing zoom animation
do -- LCamera:startBreathing
  local cam = lurek.camera.new(800, 600)
  cam:startBreathing(0.02, 0.4)   -- amplitude 2%, freq 0.4 Hz
  cam:update(0.016)
  lurek.log.info("breathing=" .. tostring(cam:isBreathing()), "camera")
end
--@api-stub: LCamera:stopBreathing -- Stops breathing zoom animation
do -- LCamera:stopBreathing
  local cam = lurek.camera.new(800, 600)
  cam:startBreathing(0.02, 0.3)
  cam:stopBreathing()
  lurek.log.info("breathing=" .. tostring(cam:isBreathing()), "camera")
end
--@api-stub: LCamera:isBreathing -- Returns whether breathing zoom animation is active
do -- LCamera:isBreathing
  local cam = lurek.camera.new(800, 600)
  cam:startBreathing(0.01, 0.5)
  lurek.log.info("breathing=" .. tostring(cam:isBreathing()), "camera")
  cam:stopBreathing()
  lurek.log.info("after stop=" .. tostring(cam:isBreathing()), "camera")
end
--@api-stub: LCamera:getEffectiveZoom -- Returns zoom after camera effects are applied
do -- LCamera:getEffectiveZoom
  local cam = lurek.camera.new(800, 600)
  cam:setZoom(1.0)
  cam:zoomPulse(0.2, 1.0)
  cam:update(0.016)
  lurek.log.info("effective_zoom=" .. cam:getEffectiveZoom(), "camera")
end
--@api-stub: LCamera:getEffectOffset -- Returns combined camera effect offset
do -- LCamera:getEffectOffset
  local cam = lurek.camera.new(800, 600)
  cam:startSway(5.0, 2.0, 0.5, 1.0)
  cam:update(0.25)
  local ox, oy = cam:getEffectOffset()
  lurek.log.info("sway_offset=" .. ox .. "," .. oy, "camera")
end

--@api-stub: LCamera:setFollowEasing -- Sets target follow easing mode
do -- LCamera:setFollowEasing
  local cam = lurek.camera.new(800, 600)
  cam:setFollowEasing("smoothstep")
  lurek.log.info("follow easing set", "camera")
end

--@api-stub: LCamera:getFollowEasing -- Returns target follow easing mode
do -- LCamera:getFollowEasing
  local cam = lurek.camera.new(800, 600)
  cam:setFollowEasing("easeout")
  lurek.log.info("follow easing=" .. cam:getFollowEasing(), "camera")
end

--@api-stub: LCamera:onWindowResize -- Updates camera viewport state after a window resize
do -- LCamera:onWindowResize
  local cam = lurek.camera.new(800, 600)
  cam:onWindowResize(1920, 1080)
  local x, y, w, h = cam:getViewport()
  lurek.log.info("resized viewport=" .. x .. "," .. y .. " " .. w .. "x" .. h, "camera")
end

--@api-stub: LCamera:onWindowResizeScaled -- Updates camera viewport state using a virtual game size and scale mode
do -- LCamera:onWindowResizeScaled
  local cam = lurek.camera.new(800, 600)
  cam:onWindowResizeScaled(800, 600, 1200, 600, "letterbox")
  local x, y, w, h = cam:getViewport()
  lurek.log.info("scaled viewport=" .. x .. "," .. y .. " " .. w .. "x" .. h, "camera")
end

--@api-stub: lurek.camera.newRig -- Creates an empty named camera rig
do -- lurek.camera.newRig
  local rig = lurek.camera.newRig()
  rig:splitScreen(1280, 720)
  local names = rig:names()
  lurek.log.info("rig camera count=" .. tostring(#names), "camera")
end

--@api-stub: LCameraRig:splitScreen -- Applies a split-screen layout using the current window size
do -- LCameraRig:splitScreen
  local rig = lurek.camera.newRig()
  rig:splitScreen(1280, 720)
  local ok, x, y, w, h = rig:getViewport("left")
  if ok then
    lurek.log.info("left viewport=" .. x .. "," .. y .. " " .. w .. "x" .. h, "camera")
  end
end

--@api-stub: LCameraRig:minimap -- Applies a minimap layout using the current window size and optional ratio
do -- LCameraRig:minimap
  local rig = lurek.camera.newRig()
  rig:minimap(1280, 720, 0.25)
  local ok, x, y, w, h = rig:getViewport("minimap")
  if ok then
    lurek.log.info("minimap viewport=" .. x .. "," .. y .. " " .. w .. "x" .. h, "camera")
  end
end

--@api-stub: LCameraRig:pictureInPicture -- Applies a picture-in-picture layout using optional inset size
do -- LCameraRig:pictureInPicture
  local rig = lurek.camera.newRig()
  rig:pictureInPicture(1280, 720, 320, 180)
  local ok, x, y, w, h = rig:getViewport("pip")
  if ok then
    lurek.log.info("pip viewport=" .. x .. "," .. y .. " " .. w .. "x" .. h, "camera")
  end
end

--@api-stub: LCamera:getBounds -- Returns camera bounds with a leading availability flag
do -- LCamera:getBounds
  local cam = lurek.camera.new(800, 600)
  cam:setBounds(0, 0, 100, 50)
  local ok, x, y, w, h = cam:getBounds()
  lurek.log.info("getBounds ok=" .. tostring(ok) .. " w=" .. w .. " h=" .. h, "camera")
end

--@api-stub: LCamera:getDeadZone -- Returns follow dead-zone dimensions with a leading availability flag
do -- LCamera:getDeadZone
  local cam = lurek.camera.new(800, 600)
  cam:setDeadZone(40, 20)
  local ok, w, h = cam:getDeadZone()
  lurek.log.info("getDeadZone ok=" .. tostring(ok) .. " " .. w .. "x" .. h, "camera")
end

--@api-stub: LCamera:getFollowSmooth -- Returns follow smoothing speed
do -- LCamera:getFollowSmooth
  local cam = lurek.camera.new(800, 600)
  cam:setFollowSmooth(3.0)
  lurek.log.info("follow smooth=" .. cam:getFollowSmooth(), "camera")
end

--@api-stub: LCamera:getLookAhead -- Returns follow look-ahead multiplier
do -- LCamera:getLookAhead
  local cam = lurek.camera.new(800, 600)
  cam:setLookAhead(0.4)
  lurek.log.info("lookAhead=" .. cam:getLookAhead(), "camera")
end

--@api-stub: LCamera:getRenderOffset -- Returns current render offset after camera effects
do -- LCamera:getRenderOffset
  local cam = lurek.camera.new(800, 600)
  local x, y = cam:getRenderOffset()
  lurek.log.info("render offset=" .. x .. "," .. y, "camera")
end

--@api-stub: LCamera:getRotationConstraints -- Returns rotation constraints with availability flags
do -- LCamera:getRotationConstraints
  local cam = lurek.camera.new(800, 600)
  cam:setRotationConstraints(-1.0, 1.0)
  local has_min, min_v, has_max, max_v = cam:getRotationConstraints()
  lurek.log.info("rot constraints=" .. tostring(has_min) .. "," .. min_v .. "," .. tostring(has_max) .. "," .. max_v, "camera")
end

--@api-stub: LCamera:getRotationDamping -- Returns rotation damping
do -- LCamera:getRotationDamping
  local cam = lurek.camera.new(800, 600)
  cam:setRotationDamping(0.5)
  lurek.log.info("rotation damping=" .. cam:getRotationDamping(), "camera")
end

--@api-stub: LCamera:getShakeOffset -- Returns current camera shake offset
do -- LCamera:getShakeOffset
  local cam = lurek.camera.new(800, 600)
  cam:shake(3.0, 0.4)
  cam:update(0.1)
  local x, y = cam:getShakeOffset()
  lurek.log.info("shake offset=" .. x .. "," .. y, "camera")
end

--@api-stub: LCamera:getTarget -- Returns the follow target with a leading availability flag
do -- LCamera:getTarget
  local cam = lurek.camera.new(800, 600)
  cam:setTarget(12, 34)
  local ok, x, y = cam:getTarget()
  lurek.log.info("target=" .. tostring(ok) .. " " .. x .. "," .. y, "camera")
end

--@api-stub: LCamera:getZoomConstraints -- Returns zoom constraints with availability flags
do -- LCamera:getZoomConstraints
  local cam = lurek.camera.new(800, 600)
  cam:setZoomConstraints(0.5, 2.5)
  local has_min, min_v, has_max, max_v = cam:getZoomConstraints()
  lurek.log.info("zoom constraints=" .. tostring(has_min) .. "," .. min_v .. "," .. tostring(has_max) .. "," .. max_v, "camera")
end

--@api-stub: LCamera:getZoomDamping -- Returns zoom damping
do -- LCamera:getZoomDamping
  local cam = lurek.camera.new(800, 600)
  cam:setZoomDamping(0.25)
  lurek.log.info("zoom damping=" .. cam:getZoomDamping(), "camera")
end

--@api-stub: LCamera:hasBounds -- Returns whether camera bounds are active
do -- LCamera:hasBounds
  local cam = lurek.camera.new(800, 600)
  lurek.log.info("hasBounds(before)=" .. tostring(cam:hasBounds()), "camera")
  cam:setBounds(0, 0, 100, 100)
  lurek.log.info("hasBounds(after)=" .. tostring(cam:hasBounds()), "camera")
end

--@api-stub: LCamera:presetAggressiveFollow -- Applies the aggressive follow camera preset
do -- LCamera:presetAggressiveFollow
  local cam = lurek.camera.new(800, 600)
  cam:presetAggressiveFollow()
  lurek.log.info("preset aggressive", "camera")
end

--@api-stub: LCamera:presetBalancedFollow -- Applies the balanced follow camera preset
do -- LCamera:presetBalancedFollow
  local cam = lurek.camera.new(800, 600)
  cam:presetBalancedFollow()
  lurek.log.info("preset balanced", "camera")
end

--@api-stub: LCamera:presetCinematicFollow -- Applies the cinematic follow camera preset
do -- LCamera:presetCinematicFollow
  local cam = lurek.camera.new(800, 600)
  cam:presetCinematicFollow()
  lurek.log.info("preset cinematic", "camera")
end

--@api-stub: LCamera:presetTightFollow -- Applies the tight follow camera preset
do -- LCamera:presetTightFollow
  local cam = lurek.camera.new(800, 600)
  cam:presetTightFollow()
  lurek.log.info("preset tight", "camera")
end

--@api-stub: LCamera:setRotationConstraints -- Sets optional minimum and maximum rotation constraints
do -- LCamera:setRotationConstraints
  local cam = lurek.camera.new(800, 600)
  cam:setRotationConstraints(-0.2, 0.2)
end

--@api-stub: LCamera:setRotationDamping -- Sets rotation damping
do -- LCamera:setRotationDamping
  local cam = lurek.camera.new(800, 600)
  cam:setRotationDamping(0.3)
end

--@api-stub: LCamera:setZoomConstraints -- Sets optional minimum and maximum zoom constraints
do -- LCamera:setZoomConstraints
  local cam = lurek.camera.new(800, 600)
  cam:setZoomConstraints(0.6, 2.2)
end

--@api-stub: LCamera:setZoomDamping -- Sets zoom damping
do -- LCamera:setZoomDamping
  local cam = lurek.camera.new(800, 600)
  cam:setZoomDamping(0.2)
end

--@api-stub: LCameraRig:apply -- Appends render commands for a named camera in this rig
do -- LCameraRig:apply
  local rig = lurek.camera.newRig()
  rig:splitScreen(1280, 720)
  lurek.log.info("rig apply left=" .. tostring(rig:apply("left")), "camera")
end

--@api-stub: LCameraRig:getViewport -- Returns a named rig camera viewport with a leading availability flag
do -- LCameraRig:getViewport
  local rig = lurek.camera.newRig()
  rig:splitScreen(1280, 720)
  local ok, x, y, w, h = rig:getViewport("right")
  lurek.log.info("rig viewport ok=" .. tostring(ok) .. " " .. w .. "x" .. h, "camera")
end

--@api-stub: LCameraRig:has -- Returns whether this rig contains a named camera
do -- LCameraRig:has
  local rig = lurek.camera.newRig()
  rig:minimap(1280, 720, 0.25)
  lurek.log.info("has minimap=" .. tostring(rig:has("minimap")), "camera")
end

--@api-stub: LCameraRig:names -- Returns all camera names in this rig
do -- LCameraRig:names
  local rig = lurek.camera.newRig()
  rig:splitScreen(1280, 720)
  local names = rig:names()
  lurek.log.info("rig names count=" .. tostring(#names), "camera")
end

--@api-stub: LCameraRig:remove -- Removes a named camera from this rig
do -- LCameraRig:remove
  local rig = lurek.camera.newRig()
  rig:splitScreen(1280, 720)
  lurek.log.info("removed left=" .. tostring(rig:remove("left")), "camera")
end

--@api-stub: LCameraRig:setPosition -- Sets the position of a named rig camera, creating it if needed
do -- LCameraRig:setPosition
  local rig = lurek.camera.newRig()
  rig:splitScreen(1280, 720)
  rig:setPosition("left", 50, 75)
end

--@api-stub: LCameraRig:setTarget -- Sets the follow target of a named rig camera, creating it if needed
do -- LCameraRig:setTarget
  local rig = lurek.camera.newRig()
  rig:splitScreen(1280, 720)
  rig:setTarget("left", 100, 150)
end

--@api-stub: LCameraRig:setZoom -- Sets the zoom of a named rig camera, creating it if needed
do -- LCameraRig:setZoom
  local rig = lurek.camera.newRig()
  rig:splitScreen(1280, 720)
  rig:setZoom("left", 1.2)
end

--@api-stub: LCameraRig:type -- Returns the Lua-visible type name for this camera rig handle
do -- LCameraRig:type
  local rig = lurek.camera.newRig()
  lurek.log.info("rig type=" .. rig:type(), "camera")
end

--@api-stub: LCameraRig:typeOf -- Returns whether this camera rig handle matches a supported type name
do -- LCameraRig:typeOf
  local rig = lurek.camera.newRig()
  lurek.log.info("rig typeOf LCameraRig=" .. tostring(rig:typeOf("LCameraRig")), "camera")
end

--@api-stub: LCameraRig:updateAll -- Advances every camera in this rig
do -- LCameraRig:updateAll
  local rig = lurek.camera.newRig()
  rig:splitScreen(1280, 720)
  rig:updateAll(0.016)
end


