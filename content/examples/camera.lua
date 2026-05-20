-- content/examples/camera.lua
-- Auto-generated from content/examples2/camera_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/camera.lua

--- Camera Examples Part 1: Creation, position, zoom, rotation, viewport, bounds, target, follow, deadzone, lookahead, shake, update, coordinate transforms, visible area, path, parallax


--@api-stub: lurek.camera.new
do
    local cam = lurek.camera.new(800, 600)
    print("camera created = " .. tostring(cam ~= nil))
end

--@api-stub: lurek.camera.newCamera
do
    local cam = lurek.camera.newCamera(1280, 720)
    print("camera = " .. tostring(cam ~= nil))
end

--@api-stub: lurek.camera.newRig
do
    local rig = lurek.camera.newRig()
    print("rig = " .. tostring(rig ~= nil))
end

--@api-stub: LCamera:setPosition
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(200, 150)
    local x, y = cam:getPosition()
    print("pos = " .. x .. ", " .. y)
end

--@api-stub: LCamera:getPosition
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(100, 50)
    local x, y = cam:getPosition()
    print("x=" .. x .. " y=" .. y)
end

--@api-stub: LCamera:setZoom
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoom(2.0)
    print("zoom = " .. cam:getZoom())
end

--@api-stub: LCamera:getZoom
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoom(0.5)
    local z = cam:getZoom()
    print("zoom = " .. z)
end

--@api-stub: LCamera:setRotation
do
    local cam = lurek.camera.new(800, 600)
    cam:setRotation(math.pi / 4)
    print("rotation = " .. cam:getRotation())
end

--@api-stub: LCamera:getRotation
do
    local cam = lurek.camera.new(800, 600)
    cam:setRotation(1.5)
    local r = cam:getRotation()
    print("rotation = " .. r)
end

--@api-stub: LCamera:setViewport
do
    local cam = lurek.camera.new(800, 600)
    cam:setViewport(0, 0, 400, 300)
    print("viewport set to 400x300")
end

--@api-stub: LCamera:getViewport
do
    local cam = lurek.camera.new(800, 600)
    cam:setViewport(10, 10, 780, 580)
    local x, y, w, h = cam:getViewport()
    print("viewport = " .. x .. "," .. y .. "," .. w .. "," .. h)
end

--@api-stub: LCamera:getBounds
do
    local cam = lurek.camera.new(800, 600)
    cam:setBounds(0, 0, 2000, 1500)
    local ok, bx, by, bw, bh = cam:getBounds()
    print("bounds = " .. tostring(ok) .. "," .. tostring(bx) .. "," .. tostring(by) .. "," .. tostring(bw) .. "," .. tostring(bh))
end

--@api-stub: LCamera:hasBounds
do
    local cam = lurek.camera.new(800, 600)
    cam:setBounds(0, 0, 1000, 1000)
    print("has bounds = " .. tostring(cam:hasBounds()))
end

--@api-stub: LCamera:setBounds
do
    local cam = lurek.camera.new(800, 600)
    cam:setBounds(0, 0, 3200, 2400)
    print("bounds set to 3200x2400")
end

--@api-stub: LCamera:removeBounds
do
    local cam = lurek.camera.new(800, 600)
    cam:setBounds(0, 0, 1000, 1000)
    cam:removeBounds()
    print("bounds removed = " .. tostring(not cam:hasBounds()))
end

--@api-stub: LCamera:setTarget
do
    local cam = lurek.camera.new(800, 600)
    cam:setTarget(500, 300)
    local ok, tx, ty = cam:getTarget()
    print("target = " .. tostring(ok) .. ", " .. tostring(tx) .. ", " .. tostring(ty))
end

--@api-stub: LCamera:getTarget
do
    local cam = lurek.camera.new(800, 600)
    cam:setTarget(250, 125)
    local ok, tx, ty = cam:getTarget()
    print("target = " .. tostring(ok) .. ", " .. tostring(tx) .. ", " .. tostring(ty))
end

--@api-stub: LCamera:clearTarget
do
    local cam = lurek.camera.new(800, 600)
    cam:setTarget(100, 100)
    cam:clearTarget()
    print("target cleared")
end

--@api-stub: LCamera:setFollowSmooth
do
    local cam = lurek.camera.new(800, 600)
    cam:setFollowSmooth(5.0)
    print("smooth = " .. cam:getFollowSmooth())
end

--@api-stub: LCamera:getFollowSmooth
do
    local cam = lurek.camera.new(800, 600)
    cam:setFollowSmooth(3.0)
    local s = cam:getFollowSmooth()
    print("follow smooth = " .. s)
end

--@api-stub: LCamera:setFollowEasing
do
    local cam = lurek.camera.new(800, 600)
    cam:setFollowEasing("quadOut")
    print("easing = " .. cam:getFollowEasing())
end

--@api-stub: LCamera:getFollowEasing
do
    local cam = lurek.camera.new(800, 600)
    cam:setFollowEasing("linear")
    local e = cam:getFollowEasing()
    print("easing = " .. e)
end

--@api-stub: LCamera:setDeadZone
do
    local cam = lurek.camera.new(800, 600)
    cam:setDeadZone(50, 30)
    print("dead zone set")
end

--@api-stub: LCamera:getDeadZone
do
    local cam = lurek.camera.new(800, 600)
    cam:setDeadZone(40, 20)
    local ok, w, h = cam:getDeadZone()
    print("dead zone = " .. tostring(ok) .. "," .. tostring(w) .. "x" .. tostring(h))
end

--@api-stub: LCamera:setLookAhead
do
    local cam = lurek.camera.new(800, 600)
    cam:setLookAhead(1.5)
    print("look ahead = " .. cam:getLookAhead())
end

--@api-stub: LCamera:getLookAhead
do
    local cam = lurek.camera.new(800, 600)
    cam:setLookAhead(2.0)
    local la = cam:getLookAhead()
    print("look ahead = " .. la)
end

--@api-stub: LCamera:onWindowResize
do
    local cam = lurek.camera.new(800, 600)
    cam:onWindowResize(1920, 1080)
    print("resized to 1920x1080")
end

--@api-stub: LCamera:onWindowResizeScaled
do
    local cam = lurek.camera.new(800, 600)
    cam:onWindowResizeScaled(800, 600, 1920, 1080, "letterbox")
    print("scaled resize applied")
end

--@api-stub: LCamera:shake
do
    local cam = lurek.camera.new(800, 600)
    cam:shake(10.0, 0.5)
    print("shaking for 0.5s at intensity 10")
end

--@api-stub: LCamera:update
do
    local cam = lurek.camera.new(800, 600)
    cam:setTarget(200, 100)
    cam:setFollowSmooth(4.0)
    cam:update(0.016)
    print("camera updated")
end

--@api-stub: LCamera:toWorld
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(100, 100)
    local wx, wy = cam:toWorld(400, 300)
    print("world = " .. wx .. ", " .. wy)
end

--@api-stub: LCamera:toScreen
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(100, 100)
    local sx, sy = cam:toScreen(500, 400)
    print("screen = " .. sx .. ", " .. sy)
end

--@api-stub: LCamera:getVisibleArea
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(400, 300)
    local x, y, w, h = cam:getVisibleArea()
    print("visible = " .. x .. "," .. y .. " " .. w .. "x" .. h)
end

--@api-stub: LCamera:lookAt
do
    local cam = lurek.camera.new(800, 600)
    cam:lookAt(500, 250)
    local x, y = cam:getPosition()
    print("looking at " .. x .. ", " .. y)
end

--@api-stub: LCamera:move
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(100, 100)
    cam:move(50, -25)
    local x, y = cam:getPosition()
    print("moved to " .. x .. ", " .. y)
end

--@api-stub: LCamera:followPath
do
    local cam = lurek.camera.new(800, 600)
    local points = { { x = 0, y = 0 }, { x = 400, y = 200 }, { x = 800, y = 0 } }
    cam:followPath(points, 3.0)
    print("following path over 3s")
end

--@api-stub: LCamera:stopPath
do
    local cam = lurek.camera.new(800, 600)
    local points = { { x = 0, y = 0 }, { x = 100, y = 100 } }
    cam:followPath(points, 2.0)
    cam:stopPath()
    print("path stopped")
end

--@api-stub: LCamera:updatePath
do
    local cam = lurek.camera.new(800, 600)
    local points = { { x = 0, y = 0 }, { x = 200, y = 200 } }
    cam:followPath(points, 2.0)
    cam:updatePath(0.5)
    print("path progress = " .. cam:pathProgress())
end

--@api-stub: LCamera:pathProgress
do
    local cam = lurek.camera.new(800, 600)
    local points = {{ x = 0, y = 0 }, { x = 100, y = 100 }}
    cam:followPath(points, 1.0)
    cam:updatePath(0.5); local p = cam:pathProgress()
    print("progress = " .. p)
end

--@api-stub: LCamera:zoomTo
do
    local cam = lurek.camera.new(800, 600)
    cam:zoomTo(2.0, 1.0, "quadOut")
    print("zooming to 2x over 1s")
end

--@api-stub: LCamera:stopZoom
do
    local cam = lurek.camera.new(800, 600)
    cam:zoomTo(3.0, 2.0, "linear")
    cam:stopZoom()
    print("zoom stopped")
end

--@api-stub: LCamera:updateZoom
do
    local cam = lurek.camera.new(800, 600)
    cam:zoomTo(2.0, 1.0, "linear")
    cam:updateZoom(0.5)
    print("zoom after 0.5s = " .. cam:getZoom())
end

--@api-stub: LCamera:setParallaxFactor
do
    local cam = lurek.camera.new(800, 600)
    cam:setParallaxFactor("background", 0.5)
    print("parallax bg = " .. cam:getParallaxFactor("background"))
end

--@api-stub: LCamera:getParallaxFactor
do
    local cam = lurek.camera.new(800, 600)
    cam:setParallaxFactor("clouds", 0.3)
    local f = cam:getParallaxFactor("clouds")
    print("clouds parallax = " .. f)
end

--@api-stub: LCamera:clearParallaxFactors
do
    local cam = lurek.camera.new(800, 600)
    cam:setParallaxFactor("fg", 1.2)
    cam:clearParallaxFactors()
    print("parallax cleared")
end

--@api-stub: LCamera:apply
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(400, 300)
    cam:apply()
    print("camera applied")
end

--@api-stub: LCamera:reset
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(500, 500)
    cam:setZoom(3.0)
    cam:reset()
    print("camera reset")
end

--@api-stub: LCamera:attach
do
    local cam = lurek.camera.new(800, 600)
    cam:attach()
    print("camera attached")
end

--@api-stub: LCamera:detach
do
    local cam = lurek.camera.new(800, 600)
    cam:attach()
    cam:detach()
    print("camera detached")
end

--@api-stub: LCamera:zoomPulse
do
    local cam = lurek.camera.new(800, 600)
    cam:zoomPulse(0.2, 0.3)
    print("zoom pulse: amplitude=0.2, dur=0.3s")
end

--- Camera Examples Part 2: Sway, breathing, effects, constraints, presets, CameraRig


--@api-stub: LCamera:startSway
do
    local cam = lurek.camera.new(800, 600)
    cam:startSway(3.0, 2.0, 1.5, 0.5)
    print("sway started")
end

--@api-stub: LCamera:stopSway
do
    local cam = lurek.camera.new(800, 600)
    cam:startSway(2.0, 1.0, 1.0, 0.3)
    cam:stopSway()
    print("sway stopped")
end

--@api-stub: LCamera:isSway
do
    local cam = lurek.camera.new(800, 600)
    cam:startSway(1.0, 1.0, 1.0, 0.5)
    print("is sway = " .. tostring(cam:isSway()))
end

--@api-stub: LCamera:startBreathing
do
    local cam = lurek.camera.new(800, 600)
    cam:startBreathing(0.02, 0.5)
    print("breathing started")
end

--@api-stub: LCamera:stopBreathing
do
    local cam = lurek.camera.new(800, 600)
    cam:startBreathing(0.01, 0.3)
    cam:stopBreathing()
    print("breathing stopped")
end

--@api-stub: LCamera:isBreathing
do
    local cam = lurek.camera.new(800, 600)
    cam:startBreathing(0.02, 0.5)
    print("breathing = " .. tostring(cam:isBreathing()))
end

--@api-stub: LCamera:getEffectiveZoom
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoom(2.0)
    local ez = cam:getEffectiveZoom()
    print("effective zoom = " .. ez)
end

--@api-stub: LCamera:getEffectOffset
do
    local cam = lurek.camera.new(800, 600)
    local ox, oy = cam:getEffectOffset()
    print("effect offset = " .. ox .. ", " .. oy)
end

--@api-stub: LCamera:getShakeOffset
do
    local cam = lurek.camera.new(800, 600)
    cam:shake(5.0, 0.5)
    cam:update(0.01)
    local sx, sy = cam:getShakeOffset()
    print("shake = " .. sx .. ", " .. sy)
end

--@api-stub: LCamera:getRenderOffset
do
    local cam = lurek.camera.new(800, 600)
    local rx, ry = cam:getRenderOffset()
    print("render offset = " .. rx .. ", " .. ry)
end

--@api-stub: LCamera:setZoomConstraints
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoomConstraints(0.5, 4.0)
    print("zoom constrained to [0.5, 4.0]")
end

--@api-stub: LCamera:getZoomConstraints
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoomConstraints(0.25, 3.0)
    local mn, mx = cam:getZoomConstraints()
    print("zoom range = " .. mn .. " to " .. mx)
end

--@api-stub: LCamera:setZoomDamping
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoomDamping(0.9)
    print("zoom damping = " .. cam:getZoomDamping())
end

--@api-stub: LCamera:getZoomDamping
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoomDamping(0.8)
    local d = cam:getZoomDamping()
    print("damping = " .. d)
end

--@api-stub: LCamera:setRotationConstraints
do
    local cam = lurek.camera.new(800, 600)
    cam:setRotationConstraints(-0.5, 0.5)
    print("rotation constrained to [-0.5, 0.5]")
end

--@api-stub: LCamera:getRotationConstraints
do
    local cam = lurek.camera.new(800, 600)
    cam:setRotationConstraints(-1.0, 1.0)
    local mn, mx = cam:getRotationConstraints()
    print("rotation range = " .. mn .. " to " .. mx)
end

--@api-stub: LCamera:setRotationDamping
do
    local cam = lurek.camera.new(800, 600)
    cam:setRotationDamping(0.85)
    print("rotation damping = " .. cam:getRotationDamping())
end

--@api-stub: LCamera:getRotationDamping
do
    local cam = lurek.camera.new(800, 600)
    cam:setRotationDamping(0.7)
    local d = cam:getRotationDamping()
    print("rot damping = " .. d)
end

--@api-stub: LCamera:presetTightFollow
do
    local cam = lurek.camera.new(800, 600)
    cam:presetTightFollow()
    print("tight follow preset applied")
end

--@api-stub: LCamera:presetCinematicFollow
do
    local cam = lurek.camera.new(800, 600)
    cam:presetCinematicFollow()
    print("cinematic follow preset applied")
end

--@api-stub: LCamera:presetBalancedFollow
do
    local cam = lurek.camera.new(800, 600)
    cam:presetBalancedFollow()
    print("balanced follow preset applied")
end

--@api-stub: LCamera:presetAggressiveFollow
do
    local cam = lurek.camera.new(800, 600)
    cam:presetAggressiveFollow()
    print("aggressive follow preset applied")
end

--@api-stub: LCamera:type
do
    local cam = lurek.camera.new(800, 600)
    print("type = " .. cam:type())
end

--@api-stub: LCamera:typeOf
do
    local cam = lurek.camera.new(800, 600)
    print("is LCamera = " .. tostring(cam:typeOf("LCamera")))
end

--@api-stub: LCameraRig:splitScreen
do
    local rig = lurek.camera.newRig()
    rig:setPosition("player1", 100, 100)
    rig:setPosition("player2", 500, 300)
    rig:splitScreen(1280, 720)
    print("split screen layout applied")
end

--@api-stub: LCameraRig:minimap
do
    local rig = lurek.camera.newRig()
    rig:setPosition("main", 400, 300)
    rig:minimap(1280, 720, 0.25)
    print("minimap layout applied")
end

--@api-stub: LCameraRig:pictureInPicture
do
    local rig = lurek.camera.newRig()
    rig:setPosition("main", 200, 200)
    rig:pictureInPicture(1280, 720, 320, 180)
    print("PiP layout applied")
end

--@api-stub: LCameraRig:setPosition
do
    local rig = lurek.camera.newRig()
    rig:setPosition("left", 100, 200)
    print("camera positioned: left")
end

--@api-stub: LCameraRig:setZoom
do
    local rig = lurek.camera.newRig()
    rig:setPosition("a", 0, 0)
    rig:setZoom("a", 1.5)
    print("zoom set on camera a")
end

--@api-stub: LCameraRig:setTarget
do
    local rig = lurek.camera.newRig()
    rig:setPosition("cam1", 0, 0)
    rig:setTarget("cam1", 400, 300)
    print("target set on cam1")
end

--@api-stub: LCameraRig:updateAll
do
    local rig = lurek.camera.newRig()
    rig:setPosition("a", 0, 0)
    rig:setTarget("a", 200, 200)
    rig:updateAll(0.016)
    print("all cameras updated")
end

--@api-stub: LCameraRig:apply
do
    local rig = lurek.camera.newRig()
    rig:setPosition("main", 400, 300)
    local ok = rig:apply("main")
    print("applied main = " .. tostring(ok))
end

--@api-stub: LCameraRig:getViewport
do
    local rig = lurek.camera.newRig()
    rig:setPosition("left", 0, 0)
    rig:splitScreen(800, 600)
    local has, x, y, w, h = rig:getViewport("left")
    print("has=" .. tostring(has) .. " vp=" .. x .. "," .. y .. "," .. w .. "," .. h)
end

--@api-stub: LCameraRig:names
do
    local rig = lurek.camera.newRig()
    rig:setPosition("p1", 0, 0)
    local list = rig:names()
    print("cameras = " .. #list)
end

--@api-stub: LCameraRig:remove
do
    local rig = lurek.camera.newRig()
    rig:setPosition("temp", 0, 0)
    local ok = rig:remove("temp")
    print("removed = " .. tostring(ok))
end

--@api-stub: LCameraRig:has
do
    local rig = lurek.camera.newRig()
    rig:setPosition("x", 0, 0)
    print("has x = " .. tostring(rig:has("x")))
end

--@api-stub: LCameraRig:type
do
    local rig = lurek.camera.newRig()
    print("type = " .. rig:type())
end

--@api-stub: LCameraRig:typeOf
do
    local rig = lurek.camera.newRig()
    print("is LCameraRig = " .. tostring(rig:typeOf("LCameraRig")))
end

print("content/examples/camera.lua")
