-- content/examples/camera.lua
-- Auto-generated from content/examples2/camera_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/camera.lua

--- Camera Examples Part 1: Creation, position, zoom, rotation, viewport, bounds, target, follow, deadzone, lookahead, shake, update, coordinate transforms, visible area, path, parallax

local function example_print_log(...)
    local parts = {}
    for i = 1, select("#", ...) do
        parts[i] = tostring(select(i, ...))
    end
    lurek.log.info(table.concat(parts, " "))
end

--@api: lurek.camera.new
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(320, 180)
    cam:setZoom(1.25)
    local x, y = cam:getPosition()
    lurek.log.info("arena camera created=" .. tostring(cam ~= nil))
    lurek.log.info("arena camera type=" .. cam:type() .. " pos=" .. x .. "," .. y .. " zoom=" .. cam:getZoom())
end

--@api: lurek.camera.newCamera
do
    local cam = lurek.camera.newCamera(1280, 720)
    cam:setViewport(0, 0, 1280, 720)
    cam:setPosition(640, 360)
    local _, _, w, h = cam:getViewport()
    lurek.log.info("cutscene camera created=" .. tostring(cam ~= nil))
    lurek.log.info("cutscene viewport=" .. w .. "x" .. h .. " center=" .. table.concat({ cam:getPosition() }, ","))
end

--@api: lurek.camera.newRig
do
    local rig = lurek.camera.newRig()
    rig:setPosition("main", 320, 180)
    rig:setZoom("main", 1.5)
    local names = rig:names()
    lurek.log.info("rig created=" .. tostring(rig ~= nil))
    lurek.log.info("rig type=" .. rig:type() .. " cameras=" .. tostring(#names))
end

--@api: LCamera:setPosition
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(200, 150)
    cam:setTarget(260, 180)
    local x, y = cam:getPosition()
    local hasTarget, tx, ty = cam:getTarget()
    lurek.log.info("player spawn camera pos=" .. x .. "," .. y)
    lurek.log.info("follow target=" .. tostring(hasTarget) .. " " .. tostring(tx) .. "," .. tostring(ty))
end

--@api: LCamera:getPosition
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(100, 50)
    cam:move(24, -8)
    local x, y = cam:getPosition()
    cam:setZoom(1.1)
    lurek.log.info("spectator cam x=" .. x .. " y=" .. y)
    lurek.log.info("spectator zoom=" .. cam:getZoom())
end

--@api: LCamera:setZoom
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoom(2.0)
    cam:setPosition(480, 320)
    local x, y = cam:getPosition()
    local zoom = cam:getZoom()
    lurek.log.info("sniper zoom=" .. zoom)
    lurek.log.info("sniper anchor=" .. x .. "," .. y)
end

--@api: LCamera:getZoom
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoom(0.5)
    local z = cam:getZoom()
    cam:setViewport(0, 0, 400, 300)
    local _, _, w, h = cam:getViewport()
    lurek.log.info("minimap zoom=" .. z)
    lurek.log.info("minimap viewport=" .. w .. "x" .. h)
end

--@api: LCamera:setRotation
do
    local cam = lurek.camera.new(800, 600)
    cam:setRotation(math.pi / 4)
    cam:setPosition(600, 240)
    local x, y = cam:getPosition()
    lurek.log.info("falling bridge rotation=" .. cam:getRotation())
    lurek.log.info("falling bridge focus=" .. x .. "," .. y)
end

--@api: LCamera:getRotation
do
    local cam = lurek.camera.new(800, 600)
    cam:setRotation(1.5)
    local r = cam:getRotation()
    cam:setZoom(1.2)
    lurek.log.info("boss intro rotation=" .. r)
    lurek.log.info("boss intro zoom=" .. cam:getZoom())
end

--@api: LCamera:setViewport
do
    local cam = lurek.camera.new(800, 600)
    cam:setViewport(0, 0, 400, 300)
    local x, y, w, h = cam:getViewport()
    example_print_log("viewport x,y = " .. x .. ", " .. y)
    example_print_log("viewport size = " .. w .. "x" .. h)
end

--@api: LCamera:getViewport
do
    local cam = lurek.camera.new(800, 600)
    cam:setViewport(10, 10, 780, 580)
    local x, y, w, h = cam:getViewport()
    cam:setPosition(390, 290)
    lurek.log.info("hud-safe viewport=" .. x .. "," .. y .. "," .. w .. "," .. h)
    lurek.log.info("hud-safe center=" .. table.concat({ cam:getPosition() }, ","))
end

--@api: LCamera:getBounds
do
    local cam = lurek.camera.new(800, 600)
    cam:setBounds(0, 0, 2000, 1500)
    local ok, bx, by, bw, bh = cam:getBounds()
    cam:setPosition(1900, 1400)
    lurek.log.info("world bounds active=" .. tostring(ok))
    lurek.log.info("world bounds rect=" .. tostring(bx) .. "," .. tostring(by) .. "," .. tostring(bw) .. "," .. tostring(bh))
    lurek.log.info("world cam pos=" .. table.concat({ cam:getPosition() }, ","))
end

--@api: LCamera:hasBounds
do
    local cam = lurek.camera.new(800, 600)
    cam:setBounds(0, 0, 1000, 1000)
    cam:setPosition(900, 900)
    local x, y = cam:getPosition()
    lurek.log.info("arena bounds=" .. tostring(cam:hasBounds()))
    lurek.log.info("arena pos=" .. x .. "," .. y)
end

--@api: LCamera:setBounds
do
    local cam = lurek.camera.new(800, 600)
    cam:setBounds(0, 0, 3200, 2400)
    cam:setPosition(3100, 2300)
    local ok, bx, by, bw, bh = cam:getBounds()
    lurek.log.info("overworld bounds=" .. tostring(cam:hasBounds()))
    lurek.log.info("overworld rect=" .. tostring(ok) .. "," .. tostring(bx) .. "," .. tostring(by) .. "," .. tostring(bw) .. "," .. tostring(bh))
end

--@api: LCamera:removeBounds
do
    local cam = lurek.camera.new(800, 600)
    cam:setBounds(0, 0, 1000, 1000)
    lurek.log.info("bounds before remove=" .. tostring(cam:hasBounds()))
    cam:removeBounds()
    cam:setPosition(1400, 1400)
    local x, y = cam:getPosition()
    lurek.log.info("bounds removed=" .. tostring(not cam:hasBounds()))
    lurek.log.info("free cam pos=" .. x .. "," .. y)
end

--@api: LCamera:setTarget
do
    local cam = lurek.camera.new(800, 600)
    cam:setTarget(500, 300)
    cam:setFollowSmooth(6.0)
    local ok, tx, ty = cam:getTarget()
    cam:update(0.016)
    lurek.log.info("chase target=" .. tostring(ok) .. "," .. tostring(tx) .. "," .. tostring(ty))
    lurek.log.info("chase camera pos=" .. table.concat({ cam:getPosition() }, ","))
end

--@api: LCamera:getTarget
do
    local cam = lurek.camera.new(800, 600)
    cam:setTarget(250, 125)
    local ok, tx, ty = cam:getTarget()
    cam:setLookAhead(1.5)
    cam:update(0.016)
    lurek.log.info("escort target=" .. tostring(ok) .. "," .. tostring(tx) .. "," .. tostring(ty))
    lurek.log.info("escort lookahead=" .. cam:getLookAhead())
end

--@api: LCamera:clearTarget
do
    local cam = lurek.camera.new(800, 600)
    cam:setTarget(100, 100)
    cam:clearTarget()
    local ok = cam:getTarget()
    example_print_log("target cleared")
    example_print_log("has target = " .. tostring(ok))
end

--@api: LCamera:setFollowSmooth
do
    local cam = lurek.camera.new(800, 600)
    cam:setFollowSmooth(5.0)
    cam:setTarget(600, 300)
    cam:update(0.033)
    lurek.log.info("follow smooth=" .. cam:getFollowSmooth())
    lurek.log.info("follow pos=" .. table.concat({ cam:getPosition() }, ","))
end

--@api: LCamera:getFollowSmooth
do
    local cam = lurek.camera.new(800, 600)
    cam:setFollowSmooth(3.0)
    local s = cam:getFollowSmooth()
    cam:setTarget(128, 96)
    cam:update(0.05)
    lurek.log.info("dialog follow smooth=" .. s)
    lurek.log.info("dialog follow pos=" .. table.concat({ cam:getPosition() }, ","))
end

--@api: LCamera:setFollowEasing
do
    local cam = lurek.camera.new(800, 600)
    cam:setFollowEasing("quadOut")
    cam:setTarget(220, 140)
    cam:update(0.05)
    lurek.log.info("follow easing=" .. cam:getFollowEasing())
    lurek.log.info("follow pos=" .. table.concat({ cam:getPosition() }, ","))
end

--@api: LCamera:getFollowEasing
do
    local cam = lurek.camera.new(800, 600)
    cam:setFollowEasing("linear")
    local e = cam:getFollowEasing()
    cam:setTarget(300, 200)
    cam:update(0.05)
    lurek.log.info("platform easing=" .. e)
    lurek.log.info("platform pos=" .. table.concat({ cam:getPosition() }, ","))
end

--@api: LCamera:setDeadZone
do
    local cam = lurek.camera.new(800, 600)
    cam:setDeadZone(50, 30)
    local ok, w, h = cam:getDeadZone()
    example_print_log("dead zone active = " .. tostring(ok))
    example_print_log("dead zone = " .. tostring(w) .. "x" .. tostring(h))
end

--@api: LCamera:getDeadZone
do
    local cam = lurek.camera.new(800, 600)
    cam:setDeadZone(40, 20)
    local ok, w, h = cam:getDeadZone()
    cam:setTarget(500, 300)
    cam:update(0.016)
    lurek.log.info("runner dead zone=" .. tostring(ok) .. "," .. tostring(w) .. "x" .. tostring(h))
    lurek.log.info("runner cam pos=" .. table.concat({ cam:getPosition() }, ","))
end

--@api: LCamera:setLookAhead
do
    local cam = lurek.camera.new(800, 600)
    cam:setLookAhead(1.5)
    cam:setTarget(420, 240)
    cam:update(0.016)
    lurek.log.info("look ahead=" .. cam:getLookAhead())
    lurek.log.info("look ahead cam=" .. table.concat({ cam:getPosition() }, ","))
end

--@api: LCamera:getLookAhead
do
    local cam = lurek.camera.new(800, 600)
    cam:setLookAhead(2.0)
    local la = cam:getLookAhead()
    cam:setTarget(520, 260)
    cam:update(0.016)
    lurek.log.info("scout look ahead=" .. la)
    lurek.log.info("scout cam=" .. table.concat({ cam:getPosition() }, ","))
end

--@api: LCamera:onWindowResize
do
    local cam = lurek.camera.new(800, 600)
    cam:onWindowResize(1920, 1080)
    local _, _, w, h = cam:getViewport()
    example_print_log("resized to 1920x1080")
    example_print_log("viewport size = " .. w .. "x" .. h)
end

--@api: LCamera:onWindowResizeScaled
do
    local cam = lurek.camera.new(800, 600)
    cam:onWindowResizeScaled(800, 600, 1920, 1080, "letterbox")
    local x, y, w, h = cam:getViewport()
    example_print_log("scaled resize applied")
    example_print_log("viewport = " .. x .. "," .. y .. "," .. w .. "," .. h)
end

--@api: LCamera:shake
do
    local cam = lurek.camera.new(800, 600)
    cam:shake(10.0, 0.5)
    cam:update(0.1)
    local sx, sy = cam:getShakeOffset()
    lurek.log.info("impact shake active")
    lurek.log.info("impact offset=" .. sx .. "," .. sy)
    lurek.log.info("impact render offset=" .. table.concat({ cam:getRenderOffset() }, ","))
end

--@api: LCamera:update
do
    local cam = lurek.camera.new(800, 600)
    cam:setTarget(200, 100)
    cam:setFollowSmooth(4.0)
    cam:update(0.016)
    local x, y = cam:getPosition()
    example_print_log("camera updated")
    example_print_log("position = " .. x .. ", " .. y)
end

--@api: LCamera:toWorld
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(100, 100)
    local wx, wy = cam:toWorld(400, 300)
    local sx, sy = cam:toScreen(wx, wy)
    lurek.log.info("cursor world=" .. wx .. "," .. wy)
    lurek.log.info("cursor roundtrip screen=" .. sx .. "," .. sy)
end

--@api: LCamera:toScreen
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(100, 100)
    local sx, sy = cam:toScreen(500, 400)
    local wx, wy = cam:toWorld(sx, sy)
    lurek.log.info("marker screen=" .. sx .. "," .. sy)
    lurek.log.info("marker roundtrip world=" .. wx .. "," .. wy)
end

--@api: LCamera:getVisibleArea
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(400, 300)
    local x, y, w, h = cam:getVisibleArea()
    cam:setZoom(1.25)
    local zx, zy, zw, zh = cam:getVisibleArea()
    lurek.log.info("visible area base=" .. x .. "," .. y .. " " .. w .. "x" .. h)
    lurek.log.info("visible area zoomed=" .. zx .. "," .. zy .. " " .. zw .. "x" .. zh)
end

--@api: LCamera:lookAt
do
    local cam = lurek.camera.new(800, 600)
    cam:lookAt(500, 250)
    local x, y = cam:getPosition()
    cam:setZoom(1.4)
    local areaX, areaY, areaW, areaH = cam:getVisibleArea()
    lurek.log.info("lookAt center=" .. x .. "," .. y)
    lurek.log.info("lookAt visible=" .. areaX .. "," .. areaY .. " " .. areaW .. "x" .. areaH)
end

--@api: LCamera:move
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(100, 100)
    cam:move(50, -25)
    local x, y = cam:getPosition()
    example_print_log("moved to " .. x .. ", " .. y)
end

--@api: LCamera:followPath
do
    local cam = lurek.camera.new(800, 600)
    local points = { { 0, 0 }, { 400, 200 }, { 800, 0 } }
    cam:followPath(points, 3.0)
    example_print_log("following path over 3s")
    example_print_log("path progress = " .. tostring(cam:pathProgress()))
end

--@api: LCamera:stopPath
do
    local cam = lurek.camera.new(800, 600)
    local points = { { 0, 0 }, { 100, 100 } }
    cam:followPath(points, 2.0)
    cam:stopPath()
    example_print_log("path stopped")
    example_print_log("path progress = " .. tostring(cam:pathProgress()))
end

--@api: LCamera:updatePath
do
    local cam = lurek.camera.new(800, 600)
    local points = { { 0, 0 }, { 200, 200 } }
    cam:followPath(points, 2.0)
    cam:updatePath(0.5)
    local x, y = cam:getPosition()
    example_print_log("path progress = " .. cam:pathProgress())
    example_print_log("position = " .. x .. ", " .. y)
end

--@api: LCamera:pathProgress
do
    local cam = lurek.camera.new(800, 600)
    local points = { { 0, 0 }, { 100, 100 } }
    cam:followPath(points, 1.0)
    cam:updatePath(0.5)
    local p = cam:pathProgress()
    example_print_log("progress = " .. p)
    example_print_log("progress halfway = " .. tostring(p > 0 and p < 1))
end

--@api: LCamera:zoomTo
do
    local cam = lurek.camera.new(800, 600)
    cam:zoomTo(2.0, 1.0, "quadOut")
    cam:updateZoom(0.5)
    lurek.log.info("boss reveal zoom=" .. cam:getZoom())
    cam:updateZoom(0.5)
    lurek.log.info("boss reveal final zoom=" .. cam:getZoom())
end

--@api: LCamera:stopZoom
do
    local cam = lurek.camera.new(800, 600)
    cam:zoomTo(3.0, 2.0, "linear")
    cam:updateZoom(0.5)
    cam:stopZoom()
    local zoom = cam:getZoom()
    local continued = cam:updateZoom(0.5)
    lurek.log.info("zoom stopped at=" .. zoom)
    lurek.log.info("zoom tween continued=" .. tostring(continued))
end

--@api: LCamera:updateZoom
do
    local cam = lurek.camera.new(800, 600)
    cam:zoomTo(2.0, 1.0, "linear")
    local runningMid = cam:updateZoom(0.5)
    local midZoom = cam:getZoom()
    local runningEnd = cam:updateZoom(0.5)
    lurek.log.info("mid zoom=" .. midZoom .. " running=" .. tostring(runningMid))
    lurek.log.info("end zoom=" .. cam:getZoom() .. " running=" .. tostring(runningEnd))
end

--@api: LCamera:setParallaxFactor
do
    local cam = lurek.camera.new(800, 600)
    cam:setParallaxFactor("background", 0.5)
    cam:setParallaxFactor("foreground", 1.2)
    local bg = cam:getParallaxFactor("background")
    local fg = cam:getParallaxFactor("foreground")
    lurek.log.info("parallax bg=" .. bg)
    lurek.log.info("parallax fg=" .. fg)
end

--@api: LCamera:getParallaxFactor
do
    local cam = lurek.camera.new(800, 600)
    cam:setParallaxFactor("clouds", 0.3)
    local f = cam:getParallaxFactor("clouds")
    cam:setParallaxFactor("mountains", 0.6)
    lurek.log.info("clouds parallax=" .. f)
    lurek.log.info("mountains parallax=" .. cam:getParallaxFactor("mountains"))
end

--@api: LCamera:clearParallaxFactors
do
    local cam = lurek.camera.new(800, 600)
    cam:setParallaxFactor("fg", 1.2)
    cam:clearParallaxFactors()
    example_print_log("parallax cleared")
    example_print_log("fg parallax = " .. tostring(cam:getParallaxFactor("fg")))
end

--@api: LCamera:apply
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(400, 300)
    cam:apply()
    local x, y = cam:getPosition()
    example_print_log("camera applied")
    example_print_log("position = " .. x .. ", " .. y)
end

--@api: LCamera:reset
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(500, 500)
    cam:setZoom(3.0)
    cam:reset()
    example_print_log("camera reset command queued")
    example_print_log("zoom still readable = " .. tostring(cam:getZoom()))
end

--@api: LCamera:attach
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(480, 270)
    cam:setZoom(1.5)
    cam:attach()
    lurek.log.info("attach camera pos=" .. table.concat({ cam:getPosition() }, ","))
    lurek.log.info("attach camera zoom=" .. cam:getZoom())
end

--@api: LCamera:detach
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(480, 270)
    cam:attach()
    cam:detach()
    lurek.log.info("detach camera pos=" .. table.concat({ cam:getPosition() }, ","))
    lurek.log.info("detach issued")
end

--@api: LCamera:zoomPulse
do
    local cam = lurek.camera.new(800, 600)
    cam:zoomPulse(0.2, 0.3)
    local before = cam:getEffectiveZoom()
    cam:update(0.1)
    local during = cam:getEffectiveZoom()
    cam:update(0.3)
    lurek.log.info("pulse zoom before=" .. tostring(before) .. " during=" .. tostring(during))
    lurek.log.info("pulse zoom after=" .. tostring(cam:getEffectiveZoom()))
end

--- Camera Examples Part 2: Sway, breathing, effects, constraints, presets, CameraRig

--@api: LCamera:startSway
do
    local cam = lurek.camera.new(800, 600)
    cam:startSway(3.0, 2.0, 1.5, 0.5)
    cam:update(0.1)
    local ox, oy = cam:getEffectOffset()
    lurek.log.info("boat sway active=" .. tostring(cam:isSway()))
    lurek.log.info("boat sway offset=" .. ox .. "," .. oy)
end

--@api: LCamera:stopSway
do
    local cam = lurek.camera.new(800, 600)
    cam:startSway(2.0, 1.0, 1.0, 0.3)
    cam:update(0.1)
    cam:stopSway()
    local ox, oy = cam:getEffectOffset()
    lurek.log.info("sway stopped=" .. tostring(not cam:isSway()))
    lurek.log.info("post-sway offset=" .. ox .. "," .. oy)
end

--@api: LCamera:isSway
do
    local cam = lurek.camera.new(800, 600)
    cam:startSway(1.0, 1.0, 1.0, 0.5)
    cam:update(0.1)
    local ox, oy = cam:getEffectOffset()
    lurek.log.info("torch sway=" .. tostring(cam:isSway()))
    lurek.log.info("torch offset=" .. ox .. "," .. oy)
end

--@api: LCamera:startBreathing
do
    local cam = lurek.camera.new(800, 600)
    cam:startBreathing(0.02, 0.5)
    cam:update(0.1)
    local ez = cam:getEffectiveZoom()
    lurek.log.info("breathing started=" .. tostring(cam:isBreathing()))
    lurek.log.info("breathing effective zoom=" .. ez)
end

--@api: LCamera:stopBreathing
do
    local cam = lurek.camera.new(800, 600)
    cam:startBreathing(0.01, 0.3)
    cam:update(0.1)
    cam:stopBreathing()
    local ez = cam:getEffectiveZoom()
    lurek.log.info("breathing stopped=" .. tostring(not cam:isBreathing()))
    lurek.log.info("breathing effective zoom=" .. ez)
end

--@api: LCamera:isBreathing
do
    local cam = lurek.camera.new(800, 600)
    cam:startBreathing(0.02, 0.5)
    cam:update(0.1)
    lurek.log.info("breathing active=" .. tostring(cam:isBreathing()))
    lurek.log.info("breathing zoom=" .. cam:getEffectiveZoom())
end

--@api: LCamera:getEffectiveZoom
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoom(2.0)
    local ez = cam:getEffectiveZoom()
    example_print_log("effective zoom = " .. ez)
    example_print_log("base zoom = " .. tostring(cam:getZoom()))
end

--@api: LCamera:getEffectOffset
do
    local cam = lurek.camera.new(800, 600)
    local ox, oy = cam:getEffectOffset()
    cam:startSway(1.0, 0.5, 1.0, 0.5)
    cam:update(0.1)
    local swayX, swayY = cam:getEffectOffset()
    lurek.log.info("effect offset base=" .. ox .. "," .. oy)
    lurek.log.info("effect offset sway=" .. swayX .. "," .. swayY)
end

--@api: LCamera:getShakeOffset
do
    local cam = lurek.camera.new(800, 600)
    cam:shake(5.0, 0.5)
    cam:update(0.01)
    local sx, sy = cam:getShakeOffset()
    example_print_log("shake = " .. sx .. ", " .. sy)
end

--@api: LCamera:getRenderOffset
do
    local cam = lurek.camera.new(800, 600)
    local rx, ry = cam:getRenderOffset()
    cam:shake(3.0, 0.2)
    cam:update(0.05)
    local shakeRx, shakeRy = cam:getRenderOffset()
    lurek.log.info("render offset base=" .. rx .. "," .. ry)
    lurek.log.info("render offset shaken=" .. shakeRx .. "," .. shakeRy)
end

--@api: LCamera:setZoomConstraints
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoomConstraints(0.5, 4.0)
    local has_min, min_z, has_max, max_z = cam:getZoomConstraints()
    example_print_log("has min/max = " .. tostring(has_min) .. "/" .. tostring(has_max))
    example_print_log("zoom constrained to [" .. min_z .. ", " .. max_z .. "]")
end

--@api: LCamera:getZoomConstraints
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoomConstraints(0.25, 3.0)
    local _, mn, _, mx = cam:getZoomConstraints()
    cam:setZoom(5.0)
    lurek.log.info("zoom range=" .. mn .. " to " .. mx)
    lurek.log.info("zoom after clamp request=" .. cam:getZoom())
end

--@api: LCamera:setZoomDamping
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoomDamping(0.9)
    cam:zoomTo(2.0, 0.5, "linear")
    cam:updateZoom(0.25)
    lurek.log.info("zoom damping=" .. cam:getZoomDamping())
    lurek.log.info("zoom in progress=" .. cam:getZoom())
end

--@api: LCamera:getZoomDamping
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoomDamping(0.8)
    local d = cam:getZoomDamping()
    cam:zoomTo(1.5, 0.5, "linear")
    cam:updateZoom(0.25)
    lurek.log.info("photo mode damping=" .. d)
    lurek.log.info("photo mode zoom=" .. cam:getZoom())
end

--@api: LCamera:setRotationConstraints
do
    local cam = lurek.camera.new(800, 600)
    cam:setRotationConstraints(-0.5, 0.5)
    local has_min, min_r, has_max, max_r = cam:getRotationConstraints()
    example_print_log("has min/max = " .. tostring(has_min) .. "/" .. tostring(has_max))
    example_print_log("rotation constrained to [" .. min_r .. ", " .. max_r .. "]")
end

--@api: LCamera:getRotationConstraints
do
    local cam = lurek.camera.new(800, 600)
    cam:setRotationConstraints(-1.0, 1.0)
    local has_min, mn, has_max, mx = cam:getRotationConstraints()
    example_print_log("rotation min enabled = " .. tostring(has_min) .. " value = " .. mn)
    example_print_log("rotation max enabled = " .. tostring(has_max) .. " value = " .. mx)
end

--@api: LCamera:setRotationDamping
do
    local cam = lurek.camera.new(800, 600)
    cam:setRotationDamping(0.85)
    cam:setRotation(math.pi / 6)
    cam:update(0.1)
    lurek.log.info("rotation damping=" .. cam:getRotationDamping())
    lurek.log.info("rotation state=" .. cam:getRotation())
end

--@api: LCamera:getRotationDamping
do
    local cam = lurek.camera.new(800, 600)
    cam:setRotationDamping(0.7)
    local d = cam:getRotationDamping()
    cam:setRotation(-math.pi / 8)
    cam:update(0.1)
    lurek.log.info("aim cam damping=" .. d)
    lurek.log.info("aim cam rotation=" .. cam:getRotation())
end

--@api: LCamera:presetTightFollow
do
    local cam = lurek.camera.new(800, 600)
    cam:presetTightFollow()
    cam:setTarget(180, 120)
    cam:update(0.016)
    lurek.log.info("tight preset smooth=" .. cam:getFollowSmooth())
    lurek.log.info("tight preset pos=" .. table.concat({ cam:getPosition() }, ","))
end

--@api: LCamera:presetCinematicFollow
do
    local cam = lurek.camera.new(800, 600)
    cam:presetCinematicFollow()
    cam:setTarget(640, 240)
    cam:update(0.016)
    lurek.log.info("cinematic preset smooth=" .. cam:getFollowSmooth())
    lurek.log.info("cinematic preset lookahead=" .. cam:getLookAhead())
end

--@api: LCamera:presetBalancedFollow
do
    local cam = lurek.camera.new(800, 600)
    cam:presetBalancedFollow()
    cam:setTarget(420, 220)
    cam:update(0.016)
    lurek.log.info("balanced preset smooth=" .. cam:getFollowSmooth())
    lurek.log.info("balanced preset lookahead=" .. cam:getLookAhead())
end

--@api: LCamera:presetAggressiveFollow
do
    local cam = lurek.camera.new(800, 600)
    cam:presetAggressiveFollow()
    cam:setTarget(720, 260)
    cam:update(0.016)
    lurek.log.info("aggressive preset smooth=" .. cam:getFollowSmooth())
    lurek.log.info("aggressive preset lookahead=" .. cam:getLookAhead())
end

--@api: LCamera:type
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(200, 120)
    cam:setZoom(1.1)
    lurek.log.info("camera type=" .. cam:type())
    lurek.log.info("camera pos=" .. table.concat({ cam:getPosition() }, ",") .. " zoom=" .. cam:getZoom())
end

--@api: LCamera:typeOf
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(200, 120)
    cam:setZoom(1.1)
    lurek.log.info("is LCamera=" .. tostring(cam:typeOf("LCamera")))
    lurek.log.info("is Object=" .. tostring(cam:typeOf("Object")))
end

--@api: LCameraRig:splitScreen
do
    local rig = lurek.camera.newRig()
    rig:setPosition("player1", 100, 100)
    rig:setPosition("player2", 500, 300)
    rig:splitScreen(1280, 720)
    example_print_log("split screen layout applied")
end

--@api: LCameraRig:minimap
do
    local rig = lurek.camera.newRig()
    rig:setPosition("main", 400, 300)
    rig:minimap(1280, 720, 0.25)
    local has, x, y, w, h = rig:getViewport("minimap")
    lurek.log.info("minimap layout applied=" .. tostring(has))
    lurek.log.info("minimap viewport=" .. x .. "," .. y .. "," .. w .. "," .. h)
end

--@api: LCameraRig:pictureInPicture
do
    local rig = lurek.camera.newRig()
    rig:setPosition("main", 200, 200)
    rig:pictureInPicture(1280, 720, 320, 180)
    local has, x, y, w, h = rig:getViewport("pip")
    lurek.log.info("pip layout applied=" .. tostring(has))
    lurek.log.info("pip viewport=" .. x .. "," .. y .. "," .. w .. "," .. h)
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
    example_print_log("walker created = " .. tostring(walker ~= nil))
    example_print_log("walker type = " .. walker:type())
end

--@api: LCameraWalker:setPosition
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local walker = lurek.camera.newWalker(map)
    walker:setPosition(128, 96)
    local x, y = walker:getPosition()
    example_print_log("walker pos = " .. x .. ", " .. y)
end

--@api: LCameraWalker:getTilePosition
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local walker = lurek.camera.newWalker(map, { tile_w = 32, tile_h = 32 })
    walker:setTilePosition(3, 2)
    local tx, ty = walker:getTilePosition()
    example_print_log("walker tile = " .. tx .. ", " .. ty)
end

--@api: LCameraWalker:moveUp
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local walker = lurek.camera.newWalker(map, { speed = 50, x = 100, y = 100 })
    walker:moveUp(1.0)
    local _, y = walker:getPosition()
    example_print_log("moved up, new y = " .. y)
end

--@api: LCameraWalker:moveDown
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local walker = lurek.camera.newWalker(map, { speed = 50, x = 100, y = 100 })
    walker:moveDown(1.0)
    local _, y = walker:getPosition()
    example_print_log("moved down, new y = " .. y)
end

--@api: LCameraWalker:moveLeft
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local walker = lurek.camera.newWalker(map, { speed = 50, x = 100, y = 100 })
    walker:moveLeft(1.0)
    local x, _ = walker:getPosition()
    example_print_log("moved left, new x = " .. x)
end

--@api: LCameraWalker:moveRight
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local walker = lurek.camera.newWalker(map, { speed = 50, x = 100, y = 100 })
    walker:moveRight(1.0)
    local x, _ = walker:getPosition()
    example_print_log("moved right, new x = " .. x)
end

--@api: LCameraWalker:update
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local walker = lurek.camera.newWalker(map)
    walker:setPosition(50, 50)
    walker:update(0.016)  -- Update at ~60 FPS
    local x, y = walker:getPosition()
    example_print_log("walker updated, pos = " .. x .. ", " .. y)
end

--@api: LCameraWalker:getCamera
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local walker = lurek.camera.newWalker(map)
    local cam = walker:getCamera()
    walker:setPosition(64, 96)
    local x, y = walker:getPosition()
    lurek.log.info("walker camera type=" .. cam:type())
    lurek.log.info("walker pos=" .. x .. "," .. y)
end

--@api: LCameraWalker:getPosition
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local walker = lurek.camera.newWalker(map)
    walker:setPosition(96, 128)
    local x, y = walker:getPosition()
    example_print_log("walker pos = " .. x .. ", " .. y)
end

--@api: LCameraWalker:setTilePosition
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local walker = lurek.camera.newWalker(map, { tile_w = 32, tile_h = 32 })
    walker:setTilePosition(5, 4)
    local tx, ty = walker:getTilePosition()
    example_print_log("walker tile = " .. tx .. ", " .. ty)
end

--@api: LCameraWalker:type
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local walker = lurek.camera.newWalker(map)
    walker:setPosition(32, 48)
    local tx, ty = walker:getTilePosition()
    lurek.log.info("walker type=" .. walker:type())
    lurek.log.info("walker tile=" .. tx .. "," .. ty)
end

--@api: LCameraWalker:typeOf
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local walker = lurek.camera.newWalker(map)
    walker:setPosition(32, 48)
    lurek.log.info("is walker type=" .. tostring(walker:typeOf("LCameraWalker")))
    lurek.log.info("is object type=" .. tostring(walker:typeOf("Object")))
end

--@api: LCameraRig:setPosition
do
    local rig = lurek.camera.newRig()
    rig:setPosition("left", 100, 200)
    rig:setZoom("left", 1.2)
    local names = rig:names()
    lurek.log.info("camera positioned left=" .. tostring(rig:has("left")))
    lurek.log.info("rig names=" .. table.concat(names, ","))
end

--@api: LCameraRig:setZoom
do
    local rig = lurek.camera.newRig()
    rig:setPosition("a", 0, 0)
    rig:setZoom("a", 1.5)
    local list = rig:names()
    example_print_log("zoom set on camera a")
    example_print_log("camera count = " .. tostring(#list))
end

--@api: LCameraRig:setTarget
do
    local rig = lurek.camera.newRig()
    rig:setPosition("cam1", 0, 0)
    rig:setTarget("cam1", 400, 300)
    example_print_log("target set on cam1")
    example_print_log("rig has cam1 = " .. tostring(rig:has("cam1")))
end

--@api: LCameraRig:updateAll
do
    local rig = lurek.camera.newRig()
    rig:setPosition("a", 0, 0)
    rig:setTarget("a", 200, 200)
    rig:updateAll(0.016)
    example_print_log("all cameras updated")
    example_print_log("camera count = " .. tostring(#rig:names()))
end

--@api: LCameraRig:apply
do
    local rig = lurek.camera.newRig()
    rig:setPosition("main", 400, 300)
    local ok = rig:apply("main")
    local has, x, y, w, h = rig:getViewport("main")
    lurek.log.info("applied main=" .. tostring(ok))
    lurek.log.info("main viewport present=" .. tostring(has) .. " " .. tostring(x) .. "," .. tostring(y) .. "," .. tostring(w) .. "," .. tostring(h))
end

--@api: LCameraRig:getViewport
do
    local rig = lurek.camera.newRig()
    rig:setPosition("left", 0, 0)
    rig:splitScreen(800, 600)
    local has, x, y, w, h = rig:getViewport("left")
    example_print_log("has=" .. tostring(has) .. " vp=" .. x .. "," .. y .. "," .. w .. "," .. h)
end

--@api: LCameraRig:names
do
    local rig = lurek.camera.newRig()
    rig:setPosition("p1", 0, 0)
    local list = rig:names()
    example_print_log("cameras = " .. #list)
    example_print_log("first name = " .. tostring(list[1]))
end

--@api: LCameraRig:remove
do
    local rig = lurek.camera.newRig()
    rig:setPosition("temp", 0, 0)
    local ok = rig:remove("temp")
    local names = rig:names()
    lurek.log.info("removed temp=" .. tostring(ok))
    lurek.log.info("remaining rig cameras=" .. tostring(#names))
end

--@api: LCameraRig:has
do
    local rig = lurek.camera.newRig()
    rig:setPosition("x", 0, 0)
    rig:setPosition("y", 64, 64)
    lurek.log.info("has x=" .. tostring(rig:has("x")))
    lurek.log.info("has boss cam=" .. tostring(rig:has("boss")))
end

--@api: LCameraRig:type
do
    local rig = lurek.camera.newRig()
    rig:setPosition("debug", 0, 0)
    rig:setZoom("debug", 1.25)
    lurek.log.info("rig type=" .. rig:type())
    lurek.log.info("rig names=" .. table.concat(rig:names(), ","))
    lurek.log.info("rig has debug=" .. tostring(rig:has("debug")))
end

--@api: LCameraRig:typeOf
do
    local rig = lurek.camera.newRig()
    rig:setPosition("debug", 0, 0)
    rig:setTarget("debug", 64, 96)
    lurek.log.info("is LCameraRig=" .. tostring(rig:typeOf("LCameraRig")))
    lurek.log.info("is Object=" .. tostring(rig:typeOf("Object")))
    lurek.log.info("rig has debug=" .. tostring(rig:has("debug")))
end
