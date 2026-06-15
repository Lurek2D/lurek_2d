-- content/examples/camera.lua
-- Auto-generated from content/examples2/camera_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/camera.lua

--- Camera Examples Part 1: Creation, position, zoom, rotation, viewport, bounds, target, follow, deadzone, lookahead, shake, update, coordinate transforms, visible area, path, parallax

--@api: lurek.camera.new
do
    local cam = lurek.camera.new(800, 600)
    print("camera created = " .. tostring(cam ~= nil))
    print("camera type = " .. cam:type())
end

--@api: lurek.camera.newCamera
do
    local cam = lurek.camera.newCamera(1280, 720)
    print("camera created = " .. tostring(cam ~= nil))
    print("viewport width = " .. select(3, cam:getViewport()))
end

--@api: lurek.camera.newRig
do
    local rig = lurek.camera.newRig()
    print("rig created = " .. tostring(rig ~= nil))
    print("rig type = " .. rig:type())
end

--@api: LCamera:setPosition
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(200, 150)
    local x, y = cam:getPosition()
    print("pos = " .. x .. ", " .. y)
end

--@api: LCamera:getPosition
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(100, 50)
    local x, y = cam:getPosition()
    print("x=" .. x .. " y=" .. y)
end

--@api: LCamera:setZoom
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoom(2.0)
    print("zoom = " .. cam:getZoom())
end

--@api: LCamera:getZoom
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoom(0.5)
    local z = cam:getZoom()
    print("zoom = " .. z)
end

--@api: LCamera:setRotation
do
    local cam = lurek.camera.new(800, 600)
    cam:setRotation(math.pi / 4)
    print("rotation = " .. cam:getRotation())
end

--@api: LCamera:getRotation
do
    local cam = lurek.camera.new(800, 600)
    cam:setRotation(1.5)
    local r = cam:getRotation()
    print("rotation = " .. r)
end

--@api: LCamera:setViewport
do
    local cam = lurek.camera.new(800, 600)
    cam:setViewport(0, 0, 400, 300)
    local x, y, w, h = cam:getViewport()
    print("viewport x,y = " .. x .. ", " .. y)
    print("viewport size = " .. w .. "x" .. h)
end

--@api: LCamera:getViewport
do
    local cam = lurek.camera.new(800, 600)
    cam:setViewport(10, 10, 780, 580)
    local x, y, w, h = cam:getViewport()
    print("viewport = " .. x .. "," .. y .. "," .. w .. "," .. h)
end

--@api: LCamera:getBounds
do
    local cam = lurek.camera.new(800, 600)
    cam:setBounds(0, 0, 2000, 1500)
    local ok, bx, by, bw, bh = cam:getBounds()
    print("bounds = " .. tostring(ok) .. "," .. tostring(bx) .. "," .. tostring(by) .. "," .. tostring(bw) .. "," .. tostring(bh))
end

--@api: LCamera:hasBounds
do
    local cam = lurek.camera.new(800, 600)
    cam:setBounds(0, 0, 1000, 1000)
    print("has bounds = " .. tostring(cam:hasBounds()))
end

--@api: LCamera:setBounds
do
    local cam = lurek.camera.new(800, 600)
    cam:setBounds(0, 0, 3200, 2400)
    print("has bounds = " .. tostring(cam:hasBounds()))
    print("bounds set to 3200x2400")
end

--@api: LCamera:removeBounds
do
    local cam = lurek.camera.new(800, 600)
    cam:setBounds(0, 0, 1000, 1000)
    cam:removeBounds()
    print("bounds removed = " .. tostring(not cam:hasBounds()))
end

--@api: LCamera:setTarget
do
    local cam = lurek.camera.new(800, 600)
    cam:setTarget(500, 300)
    local ok, tx, ty = cam:getTarget()
    print("target = " .. tostring(ok) .. ", " .. tostring(tx) .. ", " .. tostring(ty))
end

--@api: LCamera:getTarget
do
    local cam = lurek.camera.new(800, 600)
    cam:setTarget(250, 125)
    local ok, tx, ty = cam:getTarget()
    print("target = " .. tostring(ok) .. ", " .. tostring(tx) .. ", " .. tostring(ty))
end

--@api: LCamera:clearTarget
do
    local cam = lurek.camera.new(800, 600)
    cam:setTarget(100, 100)
    cam:clearTarget()
    local ok = cam:getTarget()
    print("target cleared")
    print("has target = " .. tostring(ok))
end

--@api: LCamera:setFollowSmooth
do
    local cam = lurek.camera.new(800, 600)
    cam:setFollowSmooth(5.0)
    print("smooth = " .. cam:getFollowSmooth())
end

--@api: LCamera:getFollowSmooth
do
    local cam = lurek.camera.new(800, 600)
    cam:setFollowSmooth(3.0)
    local s = cam:getFollowSmooth()
    print("follow smooth = " .. s)
end

--@api: LCamera:setFollowEasing
do
    local cam = lurek.camera.new(800, 600)
    cam:setFollowEasing("quadOut")
    print("easing = " .. cam:getFollowEasing())
end

--@api: LCamera:getFollowEasing
do
    local cam = lurek.camera.new(800, 600)
    cam:setFollowEasing("linear")
    local e = cam:getFollowEasing()
    print("easing = " .. e)
end

--@api: LCamera:setDeadZone
do
    local cam = lurek.camera.new(800, 600)
    cam:setDeadZone(50, 30)
    local ok, w, h = cam:getDeadZone()
    print("dead zone active = " .. tostring(ok))
    print("dead zone = " .. tostring(w) .. "x" .. tostring(h))
end

--@api: LCamera:getDeadZone
do
    local cam = lurek.camera.new(800, 600)
    cam:setDeadZone(40, 20)
    local ok, w, h = cam:getDeadZone()
    print("dead zone = " .. tostring(ok) .. "," .. tostring(w) .. "x" .. tostring(h))
end

--@api: LCamera:setLookAhead
do
    local cam = lurek.camera.new(800, 600)
    cam:setLookAhead(1.5)
    print("look ahead = " .. cam:getLookAhead())
end

--@api: LCamera:getLookAhead
do
    local cam = lurek.camera.new(800, 600)
    cam:setLookAhead(2.0)
    local la = cam:getLookAhead()
    print("look ahead = " .. la)
end

--@api: LCamera:onWindowResize
do
    local cam = lurek.camera.new(800, 600)
    cam:onWindowResize(1920, 1080)
    local _, _, w, h = cam:getViewport()
    print("resized to 1920x1080")
    print("viewport size = " .. w .. "x" .. h)
end

--@api: LCamera:onWindowResizeScaled
do
    local cam = lurek.camera.new(800, 600)
    cam:onWindowResizeScaled(800, 600, 1920, 1080, "letterbox")
    local x, y, w, h = cam:getViewport()
    print("scaled resize applied")
    print("viewport = " .. x .. "," .. y .. "," .. w .. "," .. h)
end

--@api: LCamera:shake
do
    local cam = lurek.camera.new(800, 600)
    cam:shake(10.0, 0.5)
    print("shaking for 0.5s at intensity 10")
end

--@api: LCamera:update
do
    local cam = lurek.camera.new(800, 600)
    cam:setTarget(200, 100)
    cam:setFollowSmooth(4.0)
    cam:update(0.016)
    local x, y = cam:getPosition()
    print("camera updated")
    print("position = " .. x .. ", " .. y)
end

--@api: LCamera:toWorld
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(100, 100)
    local wx, wy = cam:toWorld(400, 300)
    print("world = " .. wx .. ", " .. wy)
end

--@api: LCamera:toScreen
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(100, 100)
    local sx, sy = cam:toScreen(500, 400)
    print("screen = " .. sx .. ", " .. sy)
end

--@api: LCamera:getVisibleArea
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(400, 300)
    local x, y, w, h = cam:getVisibleArea()
    print("visible = " .. x .. "," .. y .. " " .. w .. "x" .. h)
end

--@api: LCamera:lookAt
do
    local cam = lurek.camera.new(800, 600)
    cam:lookAt(500, 250)
    local x, y = cam:getPosition()
    print("looking at " .. x .. ", " .. y)
end

--@api: LCamera:move
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(100, 100)
    cam:move(50, -25)
    local x, y = cam:getPosition()
    print("moved to " .. x .. ", " .. y)
end

--@api: LCamera:followPath
do
    local cam = lurek.camera.new(800, 600)
    local points = { { 0, 0 }, { 400, 200 }, { 800, 0 } }
    cam:followPath(points, 3.0)
    print("following path over 3s")
    print("path progress = " .. tostring(cam:pathProgress()))
end

--@api: LCamera:stopPath
do
    local cam = lurek.camera.new(800, 600)
    local points = { { 0, 0 }, { 100, 100 } }
    cam:followPath(points, 2.0)
    cam:stopPath()
    print("path stopped")
    print("path progress = " .. tostring(cam:pathProgress()))
end

--@api: LCamera:updatePath
do
    local cam = lurek.camera.new(800, 600)
    local points = { { 0, 0 }, { 200, 200 } }
    cam:followPath(points, 2.0)
    cam:updatePath(0.5)
    local x, y = cam:getPosition()
    print("path progress = " .. cam:pathProgress())
    print("position = " .. x .. ", " .. y)
end

--@api: LCamera:pathProgress
do
    local cam = lurek.camera.new(800, 600)
    local points = { { 0, 0 }, { 100, 100 } }
    cam:followPath(points, 1.0)
    cam:updatePath(0.5)
    local p = cam:pathProgress()
    print("progress = " .. p)
    print("progress halfway = " .. tostring(p > 0 and p < 1))
end

--@api: LCamera:zoomTo
do
    local cam = lurek.camera.new(800, 600)
    cam:zoomTo(2.0, 1.0, "quadOut")
    print("zooming to 2x over 1s")
end

--@api: LCamera:stopZoom
do
    local cam = lurek.camera.new(800, 600)
    cam:zoomTo(3.0, 2.0, "linear")
    cam:stopZoom()
    print("zoom stopped")
end

--@api: LCamera:updateZoom
do
    local cam = lurek.camera.new(800, 600)
    cam:zoomTo(2.0, 1.0, "linear")
    cam:updateZoom(0.5)
    print("zoom after 0.5s = " .. cam:getZoom())
end

--@api: LCamera:setParallaxFactor
do
    local cam = lurek.camera.new(800, 600)
    cam:setParallaxFactor("background", 0.5)
    print("parallax bg = " .. cam:getParallaxFactor("background"))
end

--@api: LCamera:getParallaxFactor
do
    local cam = lurek.camera.new(800, 600)
    cam:setParallaxFactor("clouds", 0.3)
    local f = cam:getParallaxFactor("clouds")
    print("clouds parallax = " .. f)
end

--@api: LCamera:clearParallaxFactors
do
    local cam = lurek.camera.new(800, 600)
    cam:setParallaxFactor("fg", 1.2)
    cam:clearParallaxFactors()
    print("parallax cleared")
    print("fg parallax = " .. tostring(cam:getParallaxFactor("fg")))
end

--@api: LCamera:apply
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(400, 300)
    cam:apply()
    local x, y = cam:getPosition()
    print("camera applied")
    print("position = " .. x .. ", " .. y)
end

--@api: LCamera:reset
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(500, 500)
    cam:setZoom(3.0)
    cam:reset()
    print("camera reset command queued")
    print("zoom still readable = " .. tostring(cam:getZoom()))
end

--@api: LCamera:attach
do
    local cam = lurek.camera.new(800, 600)
    cam:attach()
    print("camera attached")
end

--@api: LCamera:detach
do
    local cam = lurek.camera.new(800, 600)
    cam:attach()
    cam:detach()
    print("camera detached")
end

--@api: LCamera:zoomPulse
do
    local cam = lurek.camera.new(800, 600)
    cam:zoomPulse(0.2, 0.3)
    print("zoom pulse: amplitude=0.2, dur=0.3s")
    print("effective zoom = " .. tostring(cam:getEffectiveZoom()))
end

--- Camera Examples Part 2: Sway, breathing, effects, constraints, presets, CameraRig

--@api: LCamera:startSway
do
    local cam = lurek.camera.new(800, 600)
    cam:startSway(3.0, 2.0, 1.5, 0.5)
    print("sway started")
    print("is sway = " .. tostring(cam:isSway()))
end

--@api: LCamera:stopSway
do
    local cam = lurek.camera.new(800, 600)
    cam:startSway(2.0, 1.0, 1.0, 0.3)
    cam:stopSway()
    print("sway stopped")
end

--@api: LCamera:isSway
do
    local cam = lurek.camera.new(800, 600)
    cam:startSway(1.0, 1.0, 1.0, 0.5)
    print("is sway = " .. tostring(cam:isSway()))
end

--@api: LCamera:startBreathing
do
    local cam = lurek.camera.new(800, 600)
    cam:startBreathing(0.02, 0.5)
    print("breathing started")
    print("is breathing = " .. tostring(cam:isBreathing()))
end

--@api: LCamera:stopBreathing
do
    local cam = lurek.camera.new(800, 600)
    cam:startBreathing(0.01, 0.3)
    cam:stopBreathing()
    print("breathing stopped")
end

--@api: LCamera:isBreathing
do
    local cam = lurek.camera.new(800, 600)
    cam:startBreathing(0.02, 0.5)
    print("breathing = " .. tostring(cam:isBreathing()))
end

--@api: LCamera:getEffectiveZoom
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoom(2.0)
    local ez = cam:getEffectiveZoom()
    print("effective zoom = " .. ez)
    print("base zoom = " .. tostring(cam:getZoom()))
end

--@api: LCamera:getEffectOffset
do
    local cam = lurek.camera.new(800, 600)
    local ox, oy = cam:getEffectOffset()
    print("effect offset = " .. ox .. ", " .. oy)
end

--@api: LCamera:getShakeOffset
do
    local cam = lurek.camera.new(800, 600)
    cam:shake(5.0, 0.5)
    cam:update(0.01)
    local sx, sy = cam:getShakeOffset()
    print("shake = " .. sx .. ", " .. sy)
end

--@api: LCamera:getRenderOffset
do
    local cam = lurek.camera.new(800, 600)
    local rx, ry = cam:getRenderOffset()
    print("render offset = " .. rx .. ", " .. ry)
end

--@api: LCamera:setZoomConstraints
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoomConstraints(0.5, 4.0)
    local has_min, min_z, has_max, max_z = cam:getZoomConstraints()
    print("has min/max = " .. tostring(has_min) .. "/" .. tostring(has_max))
    print("zoom constrained to [" .. min_z .. ", " .. max_z .. "]")
end

--@api: LCamera:getZoomConstraints
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoomConstraints(0.25, 3.0)
    local _, mn, _, mx = cam:getZoomConstraints()
    print("zoom range = " .. mn .. " to " .. mx)
end

--@api: LCamera:setZoomDamping
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoomDamping(0.9)
    print("zoom damping = " .. cam:getZoomDamping())
end

--@api: LCamera:getZoomDamping
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoomDamping(0.8)
    local d = cam:getZoomDamping()
    print("damping = " .. d)
end

--@api: LCamera:setRotationConstraints
do
    local cam = lurek.camera.new(800, 600)
    cam:setRotationConstraints(-0.5, 0.5)
    local has_min, min_r, has_max, max_r = cam:getRotationConstraints()
    print("has min/max = " .. tostring(has_min) .. "/" .. tostring(has_max))
    print("rotation constrained to [" .. min_r .. ", " .. max_r .. "]")
end

--@api: LCamera:getRotationConstraints
do
    local cam = lurek.camera.new(800, 600)
    cam:setRotationConstraints(-1.0, 1.0)
    local has_min, mn, has_max, mx = cam:getRotationConstraints()
    print("rotation min enabled = " .. tostring(has_min) .. " value = " .. mn)
    print("rotation max enabled = " .. tostring(has_max) .. " value = " .. mx)
end

--@api: LCamera:setRotationDamping
do
    local cam = lurek.camera.new(800, 600)
    cam:setRotationDamping(0.85)
    print("rotation damping = " .. cam:getRotationDamping())
end

--@api: LCamera:getRotationDamping
do
    local cam = lurek.camera.new(800, 600)
    cam:setRotationDamping(0.7)
    local d = cam:getRotationDamping()
    print("rot damping = " .. d)
end

--@api: LCamera:presetTightFollow
do
    local cam = lurek.camera.new(800, 600)
    cam:presetTightFollow()
    print("tight follow preset applied")
end

--@api: LCamera:presetCinematicFollow
do
    local cam = lurek.camera.new(800, 600)
    cam:presetCinematicFollow()
    print("cinematic follow preset applied")
end

--@api: LCamera:presetBalancedFollow
do
    local cam = lurek.camera.new(800, 600)
    cam:presetBalancedFollow()
    print("balanced follow preset applied")
end

--@api: LCamera:presetAggressiveFollow
do
    local cam = lurek.camera.new(800, 600)
    cam:presetAggressiveFollow()
    print("aggressive follow preset applied")
end

--@api: LCamera:type
do
    local cam = lurek.camera.new(800, 600)
    print("type = " .. cam:type())
end

--@api: LCamera:typeOf
do
    local cam = lurek.camera.new(800, 600)
    print("is LCamera = " .. tostring(cam:typeOf("LCamera")))
end

--@api: LCameraRig:splitScreen
do
    local rig = lurek.camera.newRig()
    rig:setPosition("player1", 100, 100)
    rig:setPosition("player2", 500, 300)
    rig:splitScreen(1280, 720)
    print("split screen layout applied")
end

--@api: LCameraRig:minimap
do
    local rig = lurek.camera.newRig()
    rig:setPosition("main", 400, 300)
    rig:minimap(1280, 720, 0.25)
    print("minimap layout applied")
end

--@api: LCameraRig:pictureInPicture
do
    local rig = lurek.camera.newRig()
    rig:setPosition("main", 200, 200)
    rig:pictureInPicture(1280, 720, 320, 180)
    print("PiP layout applied")
end

--@api: lurek.camera.newWalker
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local walker = lurek.camera.newWalker(map, {
        layer = 1,
        tile_w = 32,
        tile_h = 32,
        body_w = 24,
        body_h = 24,
        speed = 100,
        x = 64,
        y = 64
    })
    print("walker created = " .. tostring(walker ~= nil))
    print("walker type = " .. walker:type())
end

--@api: LCameraWalker:setPosition
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local walker = lurek.camera.newWalker(map)
    walker:setPosition(128, 96)
    local x, y = walker:getPosition()
    print("walker pos = " .. x .. ", " .. y)
end

--@api: LCameraWalker:getTilePosition
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local walker = lurek.camera.newWalker(map, { tile_w = 32, tile_h = 32 })
    walker:setTilePosition(3, 2)
    local tx, ty = walker:getTilePosition()
    print("walker tile = " .. tx .. ", " .. ty)
end

--@api: LCameraWalker:moveUp
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local walker = lurek.camera.newWalker(map, { speed = 50, x = 100, y = 100 })
    walker:moveUp(1.0)
    local _, y = walker:getPosition()
    print("moved up, new y = " .. y)
end

--@api: LCameraWalker:moveDown
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local walker = lurek.camera.newWalker(map, { speed = 50, x = 100, y = 100 })
    walker:moveDown(1.0)
    local _, y = walker:getPosition()
    print("moved down, new y = " .. y)
end

--@api: LCameraWalker:moveLeft
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local walker = lurek.camera.newWalker(map, { speed = 50, x = 100, y = 100 })
    walker:moveLeft(1.0)
    local x, _ = walker:getPosition()
    print("moved left, new x = " .. x)
end

--@api: LCameraWalker:moveRight
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local walker = lurek.camera.newWalker(map, { speed = 50, x = 100, y = 100 })
    walker:moveRight(1.0)
    local x, _ = walker:getPosition()
    print("moved right, new x = " .. x)
end

--@api: LCameraWalker:update
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local walker = lurek.camera.newWalker(map)
    walker:setPosition(50, 50)
    walker:update(0.016)  -- Update at ~60 FPS
    local x, y = walker:getPosition()
    print("walker updated, pos = " .. x .. ", " .. y)
end

--@api: LCameraWalker:getCamera
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local walker = lurek.camera.newWalker(map)
    local cam = walker:getCamera()
    print("camera type = " .. cam:type())
end

--@api: LCameraWalker:getPosition
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local walker = lurek.camera.newWalker(map)
    walker:setPosition(96, 128)
    local x, y = walker:getPosition()
    print("walker pos = " .. x .. ", " .. y)
end

--@api: LCameraWalker:setTilePosition
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local walker = lurek.camera.newWalker(map, { tile_w = 32, tile_h = 32 })
    walker:setTilePosition(5, 4)
    local tx, ty = walker:getTilePosition()
    print("walker tile = " .. tx .. ", " .. ty)
end

--@api: LCameraWalker:type
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local walker = lurek.camera.newWalker(map)
    print("walker type = " .. walker:type())
end

--@api: LCameraWalker:typeOf
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local walker = lurek.camera.newWalker(map)
    print("is LCameraWalker = " .. tostring(walker:typeOf("LCameraWalker")))
end

--@api: LCameraRig:setPosition
do
    local rig = lurek.camera.newRig()
    rig:setPosition("left", 100, 200)
    print("camera positioned: left")
    print("rig has left = " .. tostring(rig:has("left")))
end

--@api: LCameraRig:setZoom
do
    local rig = lurek.camera.newRig()
    rig:setPosition("a", 0, 0)
    rig:setZoom("a", 1.5)
    local list = rig:names()
    print("zoom set on camera a")
    print("camera count = " .. tostring(#list))
end

--@api: LCameraRig:setTarget
do
    local rig = lurek.camera.newRig()
    rig:setPosition("cam1", 0, 0)
    rig:setTarget("cam1", 400, 300)
    print("target set on cam1")
    print("rig has cam1 = " .. tostring(rig:has("cam1")))
end

--@api: LCameraRig:updateAll
do
    local rig = lurek.camera.newRig()
    rig:setPosition("a", 0, 0)
    rig:setTarget("a", 200, 200)
    rig:updateAll(0.016)
    print("all cameras updated")
    print("camera count = " .. tostring(#rig:names()))
end

--@api: LCameraRig:apply
do
    local rig = lurek.camera.newRig()
    rig:setPosition("main", 400, 300)
    local ok = rig:apply("main")
    print("applied main = " .. tostring(ok))
end

--@api: LCameraRig:getViewport
do
    local rig = lurek.camera.newRig()
    rig:setPosition("left", 0, 0)
    rig:splitScreen(800, 600)
    local has, x, y, w, h = rig:getViewport("left")
    print("has=" .. tostring(has) .. " vp=" .. x .. "," .. y .. "," .. w .. "," .. h)
end

--@api: LCameraRig:names
do
    local rig = lurek.camera.newRig()
    rig:setPosition("p1", 0, 0)
    local list = rig:names()
    print("cameras = " .. #list)
    print("first name = " .. tostring(list[1]))
end

--@api: LCameraRig:remove
do
    local rig = lurek.camera.newRig()
    rig:setPosition("temp", 0, 0)
    local ok = rig:remove("temp")
    print("removed = " .. tostring(ok))
end

--@api: LCameraRig:has
do
    local rig = lurek.camera.newRig()
    rig:setPosition("x", 0, 0)
    print("has x = " .. tostring(rig:has("x")))
end

--@api: LCameraRig:type
do
    local rig = lurek.camera.newRig()
    print("type = " .. rig:type())
end

--@api: LCameraRig:typeOf
do
    local rig = lurek.camera.newRig()
    print("is LCameraRig = " .. tostring(rig:typeOf("LCameraRig")))
end
