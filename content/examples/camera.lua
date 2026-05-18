-- content/examples/camera.lua
-- lurek.camera API examples.
-- Run: cargo run -- content/examples/camera.lua
--@api-stub: lurek.camera.new
-- Creates a 2D camera with optional virtual viewport size.
do
  -- Use a virtual viewport that matches the game design resolution.
  local cam = lurek.camera.new(1280, 720)
  cam:setPosition(0, 0)

  local x, y = cam:getPosition()
  local vx, vy, vw, vh = cam:getVisibleArea()
  lurek.log.info(string.format("camera %.0f,%.0f sees %.0f,%.0f %.0fx%.0f", x, y, vx, vy, vw, vh), "camera")
end
--@api-stub: lurek.camera.newCamera
-- Creates a 2D camera; this is an alias for lurek.camera.new.
do
  -- Use the longer alias when a script already has a local new() helper.
  local cam = lurek.camera.newCamera(800, 600)
  cam:setPosition(400, 300)

  local sx, sy = cam:toScreen(450, 350)
  lurek.log.debug(string.format("world marker appears at %.0f,%.0f", sx, sy), "camera")
end
--@api-stub: lurek.camera.newRig
-- Creates an empty named camera rig for split views and inset cameras.
do
  -- A rig manages named cameras and can assign standard viewport layouts.
  local rig = lurek.camera.newRig()
  rig:splitScreen(1280, 720)

  local names = rig:names()
  table.sort(names)
  lurek.log.info("rig cameras: " .. table.concat(names, ", "), "camera")
end
--@api-stub: LCamera:apply
-- Appends render commands that apply this camera transform.
do
  -- Draw world-space content after apply(), then reset before HUD work.
  local cam = lurek.camera.new(800, 600)
  cam:setPosition(200, 120)
  cam:setZoom(1.5)
  cam:apply()
  cam:reset()
  lurek.log.debug("camera apply/reset queued", "camera")
end
--@api-stub: LCamera:attach
-- Appends render commands that attach this camera transform.
do
  -- attach/detach is the same scoped render pattern as apply/reset.
  local cam = lurek.camera.new(800, 600)
  cam:setPosition(64, 32)
  cam:attach()
  cam:detach()
  lurek.log.debug("camera attach/detach queued", "camera")
end
--@api-stub: LCamera:clearParallaxFactors
-- Clears all named parallax factor overrides.
do
  -- After clearing, every layer reads back as 1.0 until a new override is set.
  local cam = lurek.camera.new(800, 600)
  cam:setParallaxFactor("sky", 0.1)
  cam:setParallaxFactor("hills", 0.45)
  cam:clearParallaxFactors()

  lurek.log.debug("sky parallax reset=" .. cam:getParallaxFactor("sky"), "camera")
end
--@api-stub: LCamera:clearTarget
-- Clears the active follow target.
do
  -- Use this when switching from automatic follow to manual camera panning.
  local cam = lurek.camera.new(800, 600)
  cam:setTarget(500, 250)
  cam:clearTarget()

  local has_target = cam:getTarget()
  lurek.log.debug("target cleared=" .. tostring(not has_target), "camera")
end
--@api-stub: LCamera:detach
-- Appends a render command that detaches the active camera transform.
do
  -- Always pair detach() with attach() so later UI drawing stays screen-relative.
  local cam = lurek.camera.new(800, 600)
  cam:attach()
  cam:detach()
  lurek.log.info("camera detached", "camera")
end
--@api-stub: LCamera:followPath
-- Starts camera movement along an array of waypoint tables.
do
  -- Waypoints use numeric indices: {x, y}. Duration is total path time.
  local cam = lurek.camera.new(800, 600)
  local path = {{0, 0}, {320, 120}, {640, 120}}
  cam:followPath(path, 3.0)
  cam:updatePath(0.5)

  lurek.log.debug(string.format("path progress %.0f%%", cam:pathProgress() * 100), "camera")
end
--@api-stub: LCamera:getBounds
-- Returns camera bounds with a leading availability flag.
do
  -- Return order is has_bounds, x, y, width, height.
  local cam = lurek.camera.new(800, 600)
  cam:setBounds(0, 0, 3200, 1800)

  local has_bounds, x, y, w, h = cam:getBounds()
  if has_bounds then
    lurek.log.info(string.format("bounds %.0f,%.0f %.0fx%.0f", x, y, w, h), "camera")
  end
end
--@api-stub: LCamera:getDeadZone
-- Returns follow dead-zone dimensions with a leading availability flag.
do
  -- Dead zones prevent small target movement from constantly pulling the camera.
  local cam = lurek.camera.new(800, 600)
  cam:setDeadZone(96, 48)

  local has_zone, w, h = cam:getDeadZone()
  lurek.log.debug("dead zone set=" .. tostring(has_zone) .. " size=" .. w .. "x" .. h, "camera")
end
--@api-stub: LCamera:getEffectOffset
-- Returns the combined camera effect offset.
do
  -- This combines sway and shake offsets for diagnostics.
  local cam = lurek.camera.new(800, 600)
  cam:startSway(4, 2, 0.75, 1.0)
  cam:shake(2, 0.3)
  cam:update(0.016)

  local ox, oy = cam:getEffectOffset()
  lurek.log.debug(string.format("effect offset %.2f,%.2f", ox, oy), "camera")
end
--@api-stub: LCamera:getEffectiveZoom
-- Returns zoom after camera effects are applied.
do
  -- getZoom() is the base value; getEffectiveZoom() includes pulse and breathing.
  local cam = lurek.camera.new(800, 600)
  cam:setZoom(1.25)
  cam:zoomPulse(0.08, 0.25)
  cam:update(0.016)

  lurek.log.debug("effective zoom=" .. cam:getEffectiveZoom(), "camera")
end
--@api-stub: LCamera:getFollowEasing
-- Returns the target follow easing mode.
do
  -- Valid values are linear, smoothstep, and easeout.
  local cam = lurek.camera.new(800, 600)
  cam:setFollowEasing("easeout")

  lurek.log.info("follow easing=" .. cam:getFollowEasing(), "camera")
end
--@api-stub: LCamera:getFollowSmooth
-- Returns follow smoothing speed.
do
  -- Higher values catch up faster; lower values create a slower cinematic follow.
  local cam = lurek.camera.new(800, 600)
  cam:setFollowSmooth(5.5)

  lurek.log.debug("follow smooth=" .. cam:getFollowSmooth(), "camera")
end
--@api-stub: LCamera:getLookAhead
-- Returns follow look-ahead multiplier.
do
  -- Look-ahead shifts the view toward the target movement direction.
  local cam = lurek.camera.new(800, 600)
  cam:setLookAhead(0.35)

  lurek.log.debug("look ahead=" .. cam:getLookAhead(), "camera")
end
--@api-stub: LCamera:getParallaxFactor
-- Returns a parallax factor for a named layer.
do
  -- Missing layers return 1.0, meaning they move fully with the camera.
  local cam = lurek.camera.new(800, 600)
  cam:setParallaxFactor("clouds", 0.2)

  lurek.log.debug("clouds=" .. cam:getParallaxFactor("clouds"), "camera")
  lurek.log.debug("foreground=" .. cam:getParallaxFactor("foreground"), "camera")
end
--@api-stub: LCamera:getPosition
-- Returns the camera world position.
do
  -- The returned position is the top-left world coordinate of the view.
  local cam = lurek.camera.new(800, 600)
  cam:setPosition(120, 240)

  local x, y = cam:getPosition()
  lurek.log.debug(string.format("camera origin %.0f,%.0f", x, y), "camera")
end
--@api-stub: LCamera:getRenderOffset
-- Returns current render offset after camera effects.
do
  -- Use this when a debug overlay needs to report final effect offset.
  local cam = lurek.camera.new(800, 600)
  cam:shake(3.0, 0.4)
  cam:update(0.05)

  local x, y = cam:getRenderOffset()
  lurek.log.debug(string.format("render offset %.2f,%.2f", x, y), "camera")
end
--@api-stub: LCamera:getRotation
-- Returns the camera rotation in radians.
do
  -- Convert to degrees only for human-readable logs or debug UI.
  local cam = lurek.camera.new(800, 600)
  cam:setRotation(math.rad(12))

  local r = cam:getRotation()
  lurek.log.debug(string.format("rotation %.2f rad %.1f deg", r, math.deg(r)), "camera")
end
--@api-stub: LCamera:getRotationConstraints
-- Returns rotation constraints with availability flags.
do
  -- Return order is has_min, min, has_max, max.
  local cam = lurek.camera.new(800, 600)
  cam:setRotationConstraints(-0.25, 0.25)

  local has_min, min_r, has_max, max_r = cam:getRotationConstraints()
  lurek.log.info("rotation constraints=" .. tostring(has_min) .. ":" .. min_r .. " " .. tostring(has_max) .. ":" .. max_r, "camera")
end
--@api-stub: LCamera:getRotationDamping
-- Returns rotation damping.
do
  -- Damping smooths fast rotation changes before they reach the final camera state.
  local cam = lurek.camera.new(800, 600)
  cam:setRotationDamping(0.3)

  lurek.log.debug("rotation damping=" .. cam:getRotationDamping(), "camera")
end
--@api-stub: LCamera:getShakeOffset
-- Returns current camera shake offset.
do
  -- Shake offset is frame-dependent and changes as update(dt) advances the effect.
  local cam = lurek.camera.new(800, 600)
  cam:shake(6.0, 0.25)
  cam:update(0.016)

  local x, y = cam:getShakeOffset()
  lurek.log.debug(string.format("shake offset %.2f,%.2f", x, y), "camera")
end
--@api-stub: LCamera:getTarget
-- Returns the follow target with a leading availability flag.
do
  -- The target is a world-space point that update(dt) follows when active.
  local cam = lurek.camera.new(800, 600)
  cam:setTarget(640, 360)

  local has_target, x, y = cam:getTarget()
  if has_target then
    lurek.log.info(string.format("target %.0f,%.0f", x, y), "camera")
  end
end
--@api-stub: LCamera:getViewport
-- Returns the camera viewport rectangle.
do
  -- The viewport is screen-space and decides where the camera draws.
  local cam = lurek.camera.new(1280, 720)
  cam:setViewport(40, 30, 640, 360)

  local x, y, w, h = cam:getViewport()
  lurek.log.info(string.format("viewport %.0f,%.0f %.0fx%.0f", x, y, w, h), "camera")
end
--@api-stub: LCamera:getVisibleArea
-- Returns the world-space area visible through this camera.
do
  -- Use this rectangle for simple culling before issuing draw calls.
  local cam = lurek.camera.new(800, 600)
  cam:setPosition(300, 200)
  cam:setZoom(1.25)

  local x, y, w, h = cam:getVisibleArea()
  lurek.log.info(string.format("visible %.0f,%.0f %.0fx%.0f", x, y, w, h), "camera")
end
--@api-stub: LCamera:getZoom
-- Returns the camera zoom factor.
do
  -- Values above 1 zoom in; values below 1 show more world area.
  local cam = lurek.camera.new(800, 600)
  cam:setZoom(1.5)

  lurek.log.debug("zoom=" .. cam:getZoom(), "camera")
end
--@api-stub: LCamera:getZoomConstraints
-- Returns zoom constraints with availability flags.
do
  -- Return order is has_min, min, has_max, max.
  local cam = lurek.camera.new(800, 600)
  cam:setZoomConstraints(0.5, 3.0)

  local has_min, min_z, has_max, max_z = cam:getZoomConstraints()
  lurek.log.info("zoom constraints=" .. tostring(has_min) .. ":" .. min_z .. " " .. tostring(has_max) .. ":" .. max_z, "camera")
end
--@api-stub: LCamera:getZoomDamping
-- Returns zoom damping.
do
  -- Damping smooths direct zoom changes, useful for mouse wheel zoom.
  local cam = lurek.camera.new(800, 600)
  cam:setZoomDamping(0.2)

  lurek.log.debug("zoom damping=" .. cam:getZoomDamping(), "camera")
end
--@api-stub: LCamera:hasBounds
-- Returns whether camera bounds are active.
do
  -- Bounds are commonly enabled for gameplay and disabled for debug free camera.
  local cam = lurek.camera.new(800, 600)
  local before = cam:hasBounds()
  cam:setBounds(0, 0, 2048, 1024)

  lurek.log.info("bounds before=" .. tostring(before) .. " after=" .. tostring(cam:hasBounds()), "camera")
end
--@api-stub: LCamera:isBreathing
-- Returns whether breathing zoom animation is active.
do
  -- Breathing is a subtle periodic zoom effect for idle or ambient views.
  local cam = lurek.camera.new(800, 600)
  cam:startBreathing(0.005, 0.2)

  lurek.log.debug("breathing=" .. tostring(cam:isBreathing()), "camera")
end
--@api-stub: LCamera:isSway
-- Returns whether camera sway is active.
do
  -- Sway creates a slow position offset, useful for boats, wind, or unstable ground.
  local cam = lurek.camera.new(800, 600)
  cam:startSway(3, 1.5, 0.6, 1.0)

  lurek.log.debug("sway=" .. tostring(cam:isSway()), "camera")
end
--@api-stub: LCamera:lookAt
-- Centers the camera on a world position.
do
  -- lookAt takes the desired center point, unlike setPosition which uses top-left.
  local cam = lurek.camera.new(800, 600)
  cam:lookAt(2048, 1024)

  local x, y = cam:getPosition()
  lurek.log.debug(string.format("lookAt placed origin %.0f,%.0f", x, y), "camera")
end
--@api-stub: LCamera:move
-- Moves the camera by a delta.
do
  -- Multiply movement by dt in real process callbacks for frame-rate stable panning.
  local cam = lurek.camera.new(800, 600)
  cam:setPosition(100, 100)
  cam:move(50, -20)

  local x, y = cam:getPosition()
  lurek.log.info(string.format("after move %.0f,%.0f", x, y), "camera")
end
--@api-stub: LCamera:onWindowResize
-- Updates camera viewport state after a window resize.
do
  -- Call this from a resize callback when the camera should fill the new window.
  local cam = lurek.camera.new(800, 600)
  cam:onWindowResize(1920, 1080)

  local _, _, w, h = cam:getViewport()
  lurek.log.info("resized viewport=" .. w .. "x" .. h, "camera")
end
--@api-stub: LCamera:onWindowResizeScaled
-- Updates camera viewport state using a virtual game size and scale mode.
do
  -- letterbox preserves aspect ratio; stretch fills the window; pixelperfect uses integer scale.
  local cam = lurek.camera.new(800, 600)
  cam:onWindowResizeScaled(800, 600, 1280, 720, "letterbox")

  local x, y, w, h = cam:getViewport()
  lurek.log.info(string.format("scaled viewport %.0f,%.0f %.0fx%.0f", x, y, w, h), "camera")
end
--@api-stub: LCamera:pathProgress
-- Returns active path progress.
do
  -- With no active path this returns 1.0, meaning nothing is left to play.
  local cam = lurek.camera.new(800, 600)
  cam:followPath({{0, 0}, {400, 0}}, 4.0)
  cam:updatePath(1.0)

  lurek.log.debug(string.format("path %.0f%%", cam:pathProgress() * 100), "camera")
end
--@api-stub: LCamera:presetAggressiveFollow
-- Applies the aggressive follow camera preset.
do
  -- This preset favors fast convergence and minimal lag for fast action games.
  local cam = lurek.camera.new(800, 600)
  cam:presetAggressiveFollow()

  lurek.log.info("aggressive follow smooth=" .. cam:getFollowSmooth(), "camera")
end
--@api-stub: LCamera:presetBalancedFollow
-- Applies the balanced follow camera preset.
do
  -- Balanced is a good default while gameplay tuning is still in progress.
  local cam = lurek.camera.new(800, 600)
  cam:presetBalancedFollow()

  lurek.log.info("balanced follow easing=" .. cam:getFollowEasing(), "camera")
end
--@api-stub: LCamera:presetCinematicFollow
-- Applies the cinematic follow camera preset.
do
  -- Cinematic follow is slower and better for exploration or story scenes.
  local cam = lurek.camera.new(800, 600)
  cam:presetCinematicFollow()

  lurek.log.info("cinematic look ahead=" .. cam:getLookAhead(), "camera")
end
--@api-stub: LCamera:presetTightFollow
-- Applies the tight follow camera preset.
do
  -- Tight follow keeps the camera close to the target with a small dead zone.
  local cam = lurek.camera.new(800, 600)
  cam:presetTightFollow()

  lurek.log.info("tight follow smooth=" .. cam:getFollowSmooth(), "camera")
end
--@api-stub: LCamera:removeBounds
-- Removes active camera bounds.
do
  -- Remove bounds for debug free-camera mode or cutscenes outside the map rectangle.
  local cam = lurek.camera.new(800, 600)
  cam:setBounds(0, 0, 4096, 2048)
  cam:removeBounds()

  lurek.log.debug("bounds active=" .. tostring(cam:hasBounds()), "camera")
end
--@api-stub: LCamera:reset
-- Appends a render command that removes the active camera transform.
do
  -- reset() should follow apply() after world rendering.
  local cam = lurek.camera.new(800, 600)
  cam:apply()
  cam:reset()

  lurek.log.debug("camera transform reset", "camera")
end
--@api-stub: LCamera:setBounds
-- Sets camera world bounds.
do
  -- Bounds stop the camera from showing space outside a level or tilemap.
  local cam = lurek.camera.new(800, 600)
  cam:setBounds(0, 0, 3200, 2400)
  cam:setPosition(5000, 5000)

  local x, y = cam:getPosition()
  lurek.log.info(string.format("bounded position %.0f,%.0f", x, y), "camera")
end
--@api-stub: LCamera:setDeadZone
-- Sets follow dead-zone dimensions.
do
  -- A wider horizontal dead zone works well for side-scrolling platformers.
  local cam = lurek.camera.new(800, 600)
  cam:setDeadZone(120, 40)

  local _, w, h = cam:getDeadZone()
  lurek.log.debug("dead zone=" .. w .. "x" .. h, "camera")
end
--@api-stub: LCamera:setFollowEasing
-- Sets target follow easing mode.
do
  -- smoothstep eases in and out; easeout starts fast and settles softly.
  local cam = lurek.camera.new(800, 600)
  cam:setFollowEasing("smoothstep")

  lurek.log.info("follow easing=" .. cam:getFollowEasing(), "camera")
end
--@api-stub: LCamera:setFollowSmooth
-- Sets follow smoothing speed.
do
  -- Combine smoothing with a target and update(dt) to get interpolated follow motion.
  local cam = lurek.camera.new(800, 600)
  cam:setFollowSmooth(6.0)
  cam:setTarget(300, 200)
  cam:update(0.1)

  lurek.log.debug("follow smooth=" .. cam:getFollowSmooth(), "camera")
end
--@api-stub: LCamera:setLookAhead
-- Sets follow look-ahead multiplier.
do
  -- Small values reveal more space ahead of a moving target without too much overshoot.
  local cam = lurek.camera.new(800, 600)
  cam:setLookAhead(0.25)

  lurek.log.debug("look ahead=" .. cam:getLookAhead(), "camera")
end
--@api-stub: LCamera:setParallaxFactor
-- Sets a parallax factor for a named layer.
do
  -- Distant layers use low factors; foreground layers usually stay near 1.0.
  local cam = lurek.camera.new(800, 600)
  cam:setParallaxFactor("mountains", 0.25)
  cam:setParallaxFactor("clouds", 0.1)

  lurek.log.info("mountain parallax=" .. cam:getParallaxFactor("mountains"), "camera")
end
--@api-stub: LCamera:setPosition
-- Sets the camera world position.
do
  -- Position is the top-left world coordinate of the visible area.
  local cam = lurek.camera.new(800, 600)
  local player_x, player_y = 512, 384
  cam:setPosition(player_x - 400, player_y - 300)

  local x, y = cam:getPosition()
  lurek.log.debug(string.format("camera origin %.0f,%.0f", x, y), "camera")
end
--@api-stub: LCamera:setRotation
-- Sets the camera rotation in radians.
do
  -- Use small values for impact tilt, vehicle banking, or scene tension.
  local cam = lurek.camera.new(800, 600)
  cam:setRotation(math.rad(10))

  lurek.log.debug("rotation degrees=" .. math.deg(cam:getRotation()), "camera")
end
--@api-stub: LCamera:setRotationConstraints
-- Sets optional minimum and maximum rotation constraints.
do
  -- Clamp camera tilt so strong effects cannot rotate the scene too far.
  local cam = lurek.camera.new(800, 600)
  cam:setRotationConstraints(-math.rad(12), math.rad(12))

  local _, min_r, _, max_r = cam:getRotationConstraints()
  lurek.log.info(string.format("rotation range %.2f..%.2f", min_r, max_r), "camera")
end
--@api-stub: LCamera:setRotationDamping
-- Sets rotation damping.
do
  -- Damping is useful when rotation follows velocity or scripted events.
  local cam = lurek.camera.new(800, 600)
  cam:setRotationDamping(0.35)

  lurek.log.debug("rotation damping=" .. cam:getRotationDamping(), "camera")
end
--@api-stub: LCamera:setTarget
-- Sets a world-space follow target.
do
  -- update(dt) moves the camera toward this point using follow settings.
  local cam = lurek.camera.new(800, 600)
  local player = { x = 1024, y = 512 }
  cam:setFollowSmooth(6.0)
  cam:setTarget(player.x, player.y)
  cam:update(0.016)

  local has_target = cam:getTarget()
  lurek.log.debug("target active=" .. tostring(has_target), "camera")
end
--@api-stub: LCamera:setViewport
-- Sets the camera viewport rectangle.
do
  -- Use viewports for split-screen, minimaps, and scene previews.
  local cam = lurek.camera.new(1280, 720)
  cam:setViewport(0, 0, 640, 360)

  local _, _, w, h = cam:getViewport()
  lurek.log.info("viewport size=" .. w .. "x" .. h, "camera")
end
--@api-stub: LCamera:setZoom
-- Sets the camera zoom factor.
do
  -- Keep gameplay zoom values modest to avoid culling surprises.
  local cam = lurek.camera.new(800, 600)
  cam:setZoom(2.0)

  local _, _, w, h = cam:getVisibleArea()
  lurek.log.info(string.format("2x zoom sees %.0fx%.0f", w, h), "camera")
end
--@api-stub: LCamera:setZoomConstraints
-- Sets optional minimum and maximum zoom constraints.
do
  -- Constraints keep player-controlled zoom inside useful readability limits.
  local cam = lurek.camera.new(800, 600)
  cam:setZoomConstraints(0.6, 2.4)

  local _, min_z, _, max_z = cam:getZoomConstraints()
  lurek.log.info(string.format("zoom range %.1f..%.1f", min_z, max_z), "camera")
end
--@api-stub: LCamera:setZoomDamping
-- Sets zoom damping.
do
  -- Damping softens direct zoom changes such as mouse wheel input.
  local cam = lurek.camera.new(800, 600)
  cam:setZoomDamping(0.25)

  lurek.log.debug("zoom damping=" .. cam:getZoomDamping(), "camera")
end
--@api-stub: LCamera:shake
-- Starts a camera shake effect.
do
  -- Use short shakes for impacts. Long shakes make aiming and UI reading harder.
  local cam = lurek.camera.new(800, 600)
  cam:shake(8.0, 0.35)
  cam:update(0.016)

  local x, y = cam:getShakeOffset()
  lurek.log.debug(string.format("shake offset %.2f,%.2f", x, y), "camera")
end
--@api-stub: LCamera:startBreathing
-- Starts subtle breathing zoom animation.
do
  -- Small amplitude values work best. 0.005 is a half-percent zoom wobble.
  local cam = lurek.camera.new(800, 600)
  cam:startBreathing(0.005, 0.2)
  cam:update(0.016)

  lurek.log.info("breathing active=" .. tostring(cam:isBreathing()), "camera")
end
--@api-stub: LCamera:startSway
-- Starts camera sway offset animation.
do
  -- Sway gives ambient motion to boats, wind scenes, and unstable platforms.
  local cam = lurek.camera.new(800, 600)
  cam:startSway(4.0, 1.5, 0.6, 1.0)
  cam:update(0.016)

  lurek.log.info("sway active=" .. tostring(cam:isSway()), "camera")
end
--@api-stub: LCamera:stopBreathing
-- Stops breathing zoom animation.
do
  -- Stop breathing before exact screenshot comparisons or precise UI captures.
  local cam = lurek.camera.new(800, 600)
  cam:startBreathing(0.005, 0.2)
  cam:stopBreathing()

  lurek.log.debug("breathing active=" .. tostring(cam:isBreathing()), "camera")
end
--@api-stub: LCamera:stopPath
-- Stops the active camera path.
do
  -- Use this when the player skips a cutscene or regains manual control.
  local cam = lurek.camera.new(800, 600)
  cam:followPath({{0, 0}, {500, 500}}, 5.0)
  cam:updatePath(1.0)
  cam:stopPath()

  lurek.log.debug("path progress after stop=" .. cam:pathProgress(), "camera")
end
--@api-stub: LCamera:stopSway
-- Stops camera sway offset animation.
do
  -- Stop sway as soon as the vehicle, wind, or earthquake state ends.
  local cam = lurek.camera.new(800, 600)
  cam:startSway(3.0, 1.0, 0.5, 1.0)
  cam:stopSway()

  lurek.log.debug("sway active=" .. tostring(cam:isSway()), "camera")
end
--@api-stub: LCamera:stopZoom
-- Stops the active zoom tween.
do
  -- This freezes zoom at its current tweened value.
  local cam = lurek.camera.new(800, 600)
  cam:zoomTo(2.5, 1.0, "smoothstep")
  cam:updateZoom(0.25)
  cam:stopZoom()

  lurek.log.debug("zoom after stop=" .. cam:getZoom(), "camera")
end
--@api-stub: LCamera:toScreen
-- Converts world coordinates to screen coordinates.
do
  -- Use this for labels, health bars, and indicators anchored to world objects.
  local cam = lurek.camera.new(800, 600)
  cam:setPosition(200, 100)

  local sx, sy = cam:toScreen(1024, 512)
  lurek.log.debug(string.format("marker screen %.0f,%.0f", sx, sy), "camera")
end
--@api-stub: LCamera:toWorld
-- Converts screen coordinates to world coordinates.
do
  -- Convert mouse clicks before selection, placement, or aiming logic.
  local cam = lurek.camera.new(800, 600)
  cam:setPosition(200, 100)
  cam:setZoom(2.0)

  local wx, wy = cam:toWorld(400, 300)
  lurek.log.debug(string.format("screen center world %.1f,%.1f", wx, wy), "camera")
end
--@api-stub: LCamera:type
-- Returns the Lua-visible type name for this camera handle.
do
  -- Type strings are useful for debug output and polymorphic helper checks.
  local cam = lurek.camera.new(800, 600)
  lurek.log.info("camera type=" .. cam:type(), "camera")
end
--@api-stub: LCamera:typeOf
-- Returns whether this camera handle matches a supported type name.
do
  -- LCamera and Object both match; unrelated userdata type names do not.
  local cam = lurek.camera.new(800, 600)
  local is_camera = cam:typeOf("LCamera")
  local is_object = cam:typeOf("Object")
  local is_image = cam:typeOf("LImage")

  lurek.log.info("camera=" .. tostring(is_camera) .. " object=" .. tostring(is_object) .. " image=" .. tostring(is_image), "camera")
end
--@api-stub: LCamera:update
-- Advances camera follow, shake, and effect state.
do
  -- Call once per frame so target following and effects keep moving.
  local cam = lurek.camera.new(800, 600)
  cam:setTarget(500, 260)
  cam:setFollowSmooth(5.0)
  cam:shake(2.0, 0.2)
  cam:update(1 / 60)

  lurek.log.debug("camera updated", "camera")
end
--@api-stub: LCamera:updatePath
-- Advances the active camera path and applies its position.
do
  -- The boolean return says whether a path position was applied this frame.
  local cam = lurek.camera.new(800, 600)
  cam:followPath({{0, 0}, {800, 300}}, 2.0)

  local applied = cam:updatePath(0.5)
  lurek.log.info("path applied=" .. tostring(applied) .. " progress=" .. cam:pathProgress(), "camera")
end
--@api-stub: LCamera:updateZoom
-- Advances the active zoom tween and applies its zoom value.
do
  -- Call once per frame while a zoom tween is active.
  local cam = lurek.camera.new(800, 600)
  cam:zoomTo(1.8, 0.6, "easeout")

  local applied = cam:updateZoom(0.2)
  lurek.log.info("zoom applied=" .. tostring(applied) .. " value=" .. cam:getZoom(), "camera")
end
--@api-stub: LCamera:zoomPulse
-- Triggers a temporary zoom pulse effect.
do
  -- Use pulses for pickups, critical hits, or music beats.
  local cam = lurek.camera.new(800, 600)
  cam:zoomPulse(0.12, 0.25)
  cam:update(0.016)

  lurek.log.debug("pulse effective zoom=" .. cam:getEffectiveZoom(), "camera")
end
--@api-stub: LCamera:zoomTo
-- Starts a zoom tween toward a target zoom factor.
do
  -- The optional easing string accepts linear, smoothstep, and easeout.
  local cam = lurek.camera.new(800, 600)
  cam:setZoom(1.0)
  cam:zoomTo(2.0, 0.75, "smoothstep")
  cam:updateZoom(0.25)

  lurek.log.info("zoom tween value=" .. cam:getZoom(), "camera")
end
--@api-stub: LCameraRig:apply
-- Appends render commands for a named camera in this rig.
do
  -- apply returns false when the requested camera name does not exist.
  local rig = lurek.camera.newRig()
  rig:splitScreen(1280, 720)

  local ok = rig:apply("left")
  lurek.camera.new():reset()
  lurek.log.info("left camera applied=" .. tostring(ok), "camera")
end
--@api-stub: LCameraRig:getViewport
-- Returns a named rig camera viewport with a leading availability flag.
do
  -- Return order is has_camera, x, y, width, height.
  local rig = lurek.camera.newRig()
  rig:splitScreen(1280, 720)

  local ok, x, y, w, h = rig:getViewport("right")
  if ok then
    lurek.log.info(string.format("right viewport %.0f,%.0f %.0fx%.0f", x, y, w, h), "camera")
  end
end
--@api-stub: LCameraRig:has
-- Returns whether this rig contains a named camera.
do
  -- Use has before applying optional cameras such as a minimap or picture-in-picture feed.
  local rig = lurek.camera.newRig()
  rig:minimap(1280, 720, 0.25)

  lurek.log.info("has minimap=" .. tostring(rig:has("minimap")), "camera")
end
--@api-stub: LCameraRig:minimap
-- Applies a minimap layout using the current window size and optional ratio.
do
  -- This creates main and minimap cameras. The ratio controls minimap size.
  local rig = lurek.camera.newRig()
  rig:minimap(1280, 720, 0.2)

  local ok, x, y, w, h = rig:getViewport("minimap")
  if ok then
    lurek.log.info(string.format("minimap %.0f,%.0f %.0fx%.0f", x, y, w, h), "camera")
  end
end
--@api-stub: LCameraRig:names
-- Returns all camera names in this rig.
do
  -- Sort the returned table before printing when deterministic logs matter.
  local rig = lurek.camera.newRig()
  rig:splitScreen(1280, 720)

  local names = rig:names()
  table.sort(names)
  lurek.log.info("rig names=" .. table.concat(names, ", "), "camera")
end
--@api-stub: LCameraRig:pictureInPicture
-- Applies a picture-in-picture layout using optional inset size.
do
  -- This creates main and pip cameras. Defaults are 320x180 if sizes are omitted.
  local rig = lurek.camera.newRig()
  rig:pictureInPicture(1280, 720, 320, 180)

  local ok, _, _, w, h = rig:getViewport("pip")
  lurek.log.info("pip exists=" .. tostring(ok) .. " size=" .. w .. "x" .. h, "camera")
end
--@api-stub: LCameraRig:remove
-- Removes a named camera from this rig.
do
  -- remove returns true only when the camera existed.
  local rig = lurek.camera.newRig()
  rig:splitScreen(1280, 720)

  local removed = rig:remove("left")
  lurek.log.info("removed left=" .. tostring(removed), "camera")
end
--@api-stub: LCameraRig:setPosition
-- Sets the position of a named rig camera, creating it if needed.
do
  -- Missing names are created with a default camera size.
  local rig = lurek.camera.newRig()
  rig:setPosition("player_one", 100, 200)

  lurek.log.debug("player_one camera exists=" .. tostring(rig:has("player_one")), "camera")
end
--@api-stub: LCameraRig:setTarget
-- Sets the follow target of a named rig camera, creating it if needed.
do
  -- Each player in split-screen can have an independent target.
  local rig = lurek.camera.newRig()
  rig:splitScreen(1280, 720)
  rig:setTarget("left", 120, 240)
  rig:setTarget("right", 900, 360)

  rig:updateAll(1 / 60)
  lurek.log.debug("split-screen targets updated", "camera")
end
--@api-stub: LCameraRig:setZoom
-- Sets the zoom of a named rig camera, creating it if needed.
do
  -- Different viewports can use different zoom values for local gameplay needs.
  local rig = lurek.camera.newRig()
  rig:splitScreen(1280, 720)
  rig:setZoom("left", 1.25)
  rig:setZoom("right", 0.9)

  lurek.log.info("rig zoom values set", "camera")
end
--@api-stub: LCameraRig:splitScreen
-- Applies a split-screen layout using the current window size.
do
  -- This creates left and right cameras that each cover half the window.
  local rig = lurek.camera.newRig()
  rig:splitScreen(1280, 720)

  local ok, _, _, w, h = rig:getViewport("left")
  lurek.log.info("split left exists=" .. tostring(ok) .. " size=" .. w .. "x" .. h, "camera")
end
--@api-stub: LCameraRig:type
-- Returns the Lua-visible type name for this camera rig handle.
do
  -- Type strings help generic debug panels identify userdata handles.
  local rig = lurek.camera.newRig()
  lurek.log.info("rig type=" .. rig:type(), "camera")
end
--@api-stub: LCameraRig:typeOf
-- Returns whether this camera rig handle matches a supported type name.
do
  -- LCameraRig and Object both match; LCamera does not.
  local rig = lurek.camera.newRig()
  local is_rig = rig:typeOf("LCameraRig")
  local is_object = rig:typeOf("Object")
  local is_camera = rig:typeOf("LCamera")

  lurek.log.info("rig=" .. tostring(is_rig) .. " object=" .. tostring(is_object) .. " camera=" .. tostring(is_camera), "camera")
end
--@api-stub: LCameraRig:updateAll
-- Advances every camera in this rig.
do
  -- Call once per frame so all rig cameras update their follow and effects.
  local rig = lurek.camera.newRig()
  rig:splitScreen(1280, 720)
  rig:setTarget("left", 100, 200)
  rig:setTarget("right", 800, 400)
  rig:updateAll(1 / 60)

  lurek.log.debug("all rig cameras updated", "camera")
end
print("content/examples/camera.lua")
