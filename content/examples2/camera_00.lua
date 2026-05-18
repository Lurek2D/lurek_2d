--- Camera Examples Part 1: Creation, position, zoom, rotation, viewport, bounds, target, follow, deadzone, lookahead, shake, update, coordinate transforms, visible area, path, parallax

--@api-stub: lurek.camera.new
-- Creates a new camera with the given viewport dimensions.
do
    local cam = lurek.camera.new(800, 600)
    print("camera created = " .. tostring(cam ~= nil))
end

--@api-stub: lurek.camera.newCamera
-- Alternative constructor for a camera with viewport size.
do
    local cam = lurek.camera.newCamera(1280, 720)
    print("camera = " .. tostring(cam ~= nil))
end

--@api-stub: lurek.camera.newRig
-- Creates a camera rig for multi-camera management.
do
    local rig = lurek.camera.newRig()
    print("rig = " .. tostring(rig ~= nil))
end

--@api-stub: LCamera:setPosition
-- Sets the camera position in world coordinates.
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(200, 150)
    local x, y = cam:getPosition()
    print("pos = " .. x .. ", " .. y)
end

--@api-stub: LCamera:getPosition
-- Returns the current camera position.
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(100, 50)
    local x, y = cam:getPosition()
    print("x=" .. x .. " y=" .. y)
end

--@api-stub: LCamera:setZoom
-- Sets the camera zoom level (1.0 = no zoom).
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoom(2.0)
    print("zoom = " .. cam:getZoom())
end

--@api-stub: LCamera:getZoom
-- Returns the current zoom level.
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoom(0.5)
    local z = cam:getZoom()
    print("zoom = " .. z)
end

--@api-stub: LCamera:setRotation
-- Sets the camera rotation in radians.
do
    local cam = lurek.camera.new(800, 600)
    cam:setRotation(math.pi / 4)
    print("rotation = " .. cam:getRotation())
end

--@api-stub: LCamera:getRotation
-- Returns the current camera rotation.
do
    local cam = lurek.camera.new(800, 600)
    cam:setRotation(1.5)
    local r = cam:getRotation()
    print("rotation = " .. r)
end

--@api-stub: LCamera:setViewport
-- Sets the viewport rectangle on screen.
do
    local cam = lurek.camera.new(800, 600)
    cam:setViewport(0, 0, 400, 300)
    print("viewport set to 400x300")
end

--@api-stub: LCamera:getViewport
-- Returns the current viewport rectangle.
do
    local cam = lurek.camera.new(800, 600)
    cam:setViewport(10, 10, 780, 580)
    local x, y, w, h = cam:getViewport()
    print("viewport = " .. x .. "," .. y .. "," .. w .. "," .. h)
end

--@api-stub: LCamera:getBounds
-- Returns the camera movement bounds.
do
    local cam = lurek.camera.new(800, 600)
    cam:setBounds(0, 0, 2000, 1500)
    local bx, by, bw, bh = cam:getBounds()
    print("bounds = " .. bx .. "," .. by .. "," .. bw .. "," .. bh)
end

--@api-stub: LCamera:hasBounds
-- Returns true if bounds are set on the camera.
do
    local cam = lurek.camera.new(800, 600)
    print("has bounds = " .. tostring(cam:hasBounds()))
    cam:setBounds(0, 0, 1000, 1000)
    print("has bounds = " .. tostring(cam:hasBounds()))
end

--@api-stub: LCamera:setBounds
-- Sets the movement bounds that clamp camera position.
do
    local cam = lurek.camera.new(800, 600)
    cam:setBounds(0, 0, 3200, 2400)
    print("bounds set to 3200x2400")
end

--@api-stub: LCamera:removeBounds
-- Removes the movement bounds from the camera.
do
    local cam = lurek.camera.new(800, 600)
    cam:setBounds(0, 0, 1000, 1000)
    cam:removeBounds()
    print("bounds removed = " .. tostring(not cam:hasBounds()))
end

--@api-stub: LCamera:setTarget
-- Sets the target position the camera should follow.
do
    local cam = lurek.camera.new(800, 600)
    cam:setTarget(500, 300)
    local tx, ty = cam:getTarget()
    print("target = " .. tx .. ", " .. ty)
end

--@api-stub: LCamera:getTarget
-- Returns the current follow target position.
do
    local cam = lurek.camera.new(800, 600)
    cam:setTarget(250, 125)
    local tx, ty = cam:getTarget()
    print("target = " .. tx .. ", " .. ty)
end

--@api-stub: LCamera:clearTarget
-- Clears the follow target so the camera stays still.
do
    local cam = lurek.camera.new(800, 600)
    cam:setTarget(100, 100)
    cam:clearTarget()
    print("target cleared")
end

--@api-stub: LCamera:setFollowSmooth
-- Sets the follow smoothing speed (higher = snappier).
do
    local cam = lurek.camera.new(800, 600)
    cam:setFollowSmooth(5.0)
    print("smooth = " .. cam:getFollowSmooth())
end

--@api-stub: LCamera:getFollowSmooth
-- Returns the current follow smoothing speed.
do
    local cam = lurek.camera.new(800, 600)
    cam:setFollowSmooth(3.0)
    local s = cam:getFollowSmooth()
    print("follow smooth = " .. s)
end

--@api-stub: LCamera:setFollowEasing
-- Sets the easing function name for follow interpolation.
do
    local cam = lurek.camera.new(800, 600)
    cam:setFollowEasing("quadOut")
    print("easing = " .. cam:getFollowEasing())
end

--@api-stub: LCamera:getFollowEasing
-- Returns the current follow easing function name.
do
    local cam = lurek.camera.new(800, 600)
    cam:setFollowEasing("linear")
    local e = cam:getFollowEasing()
    print("easing = " .. e)
end

--@api-stub: LCamera:setDeadZone
-- Sets the dead zone size around the target.
do
    local cam = lurek.camera.new(800, 600)
    cam:setDeadZone(50, 30)
    print("dead zone set")
end

--@api-stub: LCamera:getDeadZone
-- Returns the current dead zone dimensions.
do
    local cam = lurek.camera.new(800, 600)
    cam:setDeadZone(40, 20)
    local w, h = cam:getDeadZone()
    print("dead zone = " .. w .. "x" .. h)
end

--@api-stub: LCamera:setLookAhead
-- Sets the look-ahead multiplier for follow direction.
do
    local cam = lurek.camera.new(800, 600)
    cam:setLookAhead(1.5)
    print("look ahead = " .. cam:getLookAhead())
end

--@api-stub: LCamera:getLookAhead
-- Returns the current look-ahead multiplier.
do
    local cam = lurek.camera.new(800, 600)
    cam:setLookAhead(2.0)
    local la = cam:getLookAhead()
    print("look ahead = " .. la)
end

--@api-stub: LCamera:onWindowResize
-- Handles a window resize by adjusting the viewport.
do
    local cam = lurek.camera.new(800, 600)
    cam:onWindowResize(1920, 1080)
    print("resized to 1920x1080")
end

--@api-stub: LCamera:onWindowResizeScaled
-- Handles window resize with scaling to fit game dimensions.
do
    local cam = lurek.camera.new(800, 600)
    cam:onWindowResizeScaled(800, 600, 1920, 1080, "letterbox")
    print("scaled resize applied")
end

--@api-stub: LCamera:shake
-- Starts a screen shake effect with intensity and duration.
do
    local cam = lurek.camera.new(800, 600)
    cam:shake(10.0, 0.5)
    print("shaking for 0.5s at intensity 10")
end

--@api-stub: LCamera:update
-- Updates the camera state (follow, shake, path) by a time delta.
do
    local cam = lurek.camera.new(800, 600)
    cam:setTarget(200, 100)
    cam:setFollowSmooth(4.0)
    cam:update(0.016)
    print("camera updated")
end

--@api-stub: LCamera:toWorld
-- Converts a screen coordinate to world space.
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(100, 100)
    local wx, wy = cam:toWorld(400, 300)
    print("world = " .. wx .. ", " .. wy)
end

--@api-stub: LCamera:toScreen
-- Converts a world coordinate to screen space.
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(100, 100)
    local sx, sy = cam:toScreen(500, 400)
    print("screen = " .. sx .. ", " .. sy)
end

--@api-stub: LCamera:getVisibleArea
-- Returns the world-space rectangle currently visible.
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(400, 300)
    local x, y, w, h = cam:getVisibleArea()
    print("visible = " .. x .. "," .. y .. " " .. w .. "x" .. h)
end

--@api-stub: LCamera:lookAt
-- Immediately centers the camera on a world position.
do
    local cam = lurek.camera.new(800, 600)
    cam:lookAt(500, 250)
    local x, y = cam:getPosition()
    print("looking at " .. x .. ", " .. y)
end

--@api-stub: LCamera:move
-- Moves the camera by a relative offset.
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(100, 100)
    cam:move(50, -25)
    local x, y = cam:getPosition()
    print("moved to " .. x .. ", " .. y)
end

--@api-stub: LCamera:followPath
-- Starts the camera along a path of waypoints over a duration.
do
    local cam = lurek.camera.new(800, 600)
    local points = { { x = 0, y = 0 }, { x = 400, y = 200 }, { x = 800, y = 0 } }
    cam:followPath(points, 3.0)
    print("following path over 3s")
end

--@api-stub: LCamera:stopPath
-- Stops path following immediately.
do
    local cam = lurek.camera.new(800, 600)
    local points = { { x = 0, y = 0 }, { x = 100, y = 100 } }
    cam:followPath(points, 2.0)
    cam:stopPath()
    print("path stopped")
end

--@api-stub: LCamera:updatePath
-- Advances path following by a time delta.
do
    local cam = lurek.camera.new(800, 600)
    local points = { { x = 0, y = 0 }, { x = 200, y = 200 } }
    cam:followPath(points, 2.0)
    cam:updatePath(0.5)
    print("path progress = " .. cam:pathProgress())
end

--@api-stub: LCamera:pathProgress
-- Returns the normalized path progress (0 to 1).
do
    local cam = lurek.camera.new(800, 600)
    local points = { { x = 0, y = 0 }, { x = 100, y = 100 } }
    cam:followPath(points, 1.0)
    cam:updatePath(0.5)
    local p = cam:pathProgress()
    print("progress = " .. p)
end

--@api-stub: LCamera:zoomTo
-- Animates the zoom to a target level over a duration.
do
    local cam = lurek.camera.new(800, 600)
    cam:zoomTo(2.0, 1.0, "quadOut")
    print("zooming to 2x over 1s")
end

--@api-stub: LCamera:stopZoom
-- Stops an active zoom animation.
do
    local cam = lurek.camera.new(800, 600)
    cam:zoomTo(3.0, 2.0, "linear")
    cam:stopZoom()
    print("zoom stopped")
end

--@api-stub: LCamera:updateZoom
-- Advances the zoom animation by a time delta.
do
    local cam = lurek.camera.new(800, 600)
    cam:zoomTo(2.0, 1.0, "linear")
    cam:updateZoom(0.5)
    print("zoom after 0.5s = " .. cam:getZoom())
end

--@api-stub: LCamera:setParallaxFactor
-- Sets a parallax scrolling factor for a named layer.
do
    local cam = lurek.camera.new(800, 600)
    cam:setParallaxFactor("background", 0.5)
    print("parallax bg = " .. cam:getParallaxFactor("background"))
end

--@api-stub: LCamera:getParallaxFactor
-- Returns the parallax factor for a named layer.
do
    local cam = lurek.camera.new(800, 600)
    cam:setParallaxFactor("clouds", 0.3)
    local f = cam:getParallaxFactor("clouds")
    print("clouds parallax = " .. f)
end

--@api-stub: LCamera:clearParallaxFactors
-- Removes all parallax factor settings.
do
    local cam = lurek.camera.new(800, 600)
    cam:setParallaxFactor("fg", 1.2)
    cam:clearParallaxFactors()
    print("parallax cleared")
end

--@api-stub: LCamera:apply
-- Applies the camera transform for rendering.
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(400, 300)
    cam:apply()
    print("camera applied")
end

--@api-stub: LCamera:reset
-- Resets the camera to default position, zoom, and rotation.
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(500, 500)
    cam:setZoom(3.0)
    cam:reset()
    print("camera reset")
end

--@api-stub: LCamera:attach
-- Attaches the camera transform (push matrix).
do
    local cam = lurek.camera.new(800, 600)
    cam:attach()
    print("camera attached")
end

--@api-stub: LCamera:detach
-- Detaches the camera transform (pop matrix).
do
    local cam = lurek.camera.new(800, 600)
    cam:attach()
    cam:detach()
    print("camera detached")
end

--@api-stub: LCamera:zoomPulse
-- Creates a quick zoom pulse effect (e.g. on hit).
do
    local cam = lurek.camera.new(800, 600)
    cam:zoomPulse(0.2, 0.3)
    print("zoom pulse: amplitude=0.2, dur=0.3s")
end

print("camera_00.lua")
