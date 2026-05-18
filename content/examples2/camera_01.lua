--- Camera Examples Part 2: Sway, breathing, effects, constraints, presets, CameraRig

--@api-stub: LCamera:startSway
-- Starts a sway oscillation effect on the camera.
do
    local cam = lurek.camera.new(800, 600)
    cam:startSway(3.0, 2.0, 1.5, 0.5)
    print("sway started")
end

--@api-stub: LCamera:stopSway
-- Stops the sway effect.
do
    local cam = lurek.camera.new(800, 600)
    cam:startSway(2.0, 1.0, 1.0, 0.3)
    cam:stopSway()
    print("sway stopped")
end

--@api-stub: LCamera:isSway
-- Returns true if sway is active.
do
    local cam = lurek.camera.new(800, 600)
    cam:startSway(1.0, 1.0, 1.0, 0.5)
    print("is sway = " .. tostring(cam:isSway()))
end

--@api-stub: LCamera:startBreathing
-- Starts a subtle breathing zoom effect.
do
    local cam = lurek.camera.new(800, 600)
    cam:startBreathing(0.02, 0.5)
    print("breathing started")
end

--@api-stub: LCamera:stopBreathing
-- Stops the breathing effect.
do
    local cam = lurek.camera.new(800, 600)
    cam:startBreathing(0.01, 0.3)
    cam:stopBreathing()
    print("breathing stopped")
end

--@api-stub: LCamera:isBreathing
-- Returns true if breathing effect is active.
do
    local cam = lurek.camera.new(800, 600)
    cam:startBreathing(0.02, 0.5)
    print("breathing = " .. tostring(cam:isBreathing()))
end

--@api-stub: LCamera:getEffectiveZoom
-- Returns the zoom level including all effects.
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoom(2.0)
    local ez = cam:getEffectiveZoom()
    print("effective zoom = " .. ez)
end

--@api-stub: LCamera:getEffectOffset
-- Returns the combined effect offset applied to the camera.
do
    local cam = lurek.camera.new(800, 600)
    local ox, oy = cam:getEffectOffset()
    print("effect offset = " .. ox .. ", " .. oy)
end

--@api-stub: LCamera:getShakeOffset
-- Returns the current shake offset and rotation.
do
    local cam = lurek.camera.new(800, 600)
    cam:shake(5.0, 0.5)
    cam:update(0.01)
    local sx, sy, sr = cam:getShakeOffset()
    print("shake = " .. sx .. ", " .. sy .. " rot=" .. sr)
end

--@api-stub: LCamera:getRenderOffset
-- Returns the final render offset for drawing.
do
    local cam = lurek.camera.new(800, 600)
    local rx, ry = cam:getRenderOffset()
    print("render offset = " .. rx .. ", " .. ry)
end

--@api-stub: LCamera:setZoomConstraints
-- Sets minimum and maximum zoom bounds.
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoomConstraints(0.5, 4.0)
    print("zoom constrained to [0.5, 4.0]")
end

--@api-stub: LCamera:getZoomConstraints
-- Returns the min and max zoom constraints.
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoomConstraints(0.25, 3.0)
    local mn, mx = cam:getZoomConstraints()
    print("zoom range = " .. mn .. " to " .. mx)
end

--@api-stub: LCamera:setZoomDamping
-- Sets the damping factor for zoom changes.
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoomDamping(0.9)
    print("zoom damping = " .. cam:getZoomDamping())
end

--@api-stub: LCamera:getZoomDamping
-- Returns the current zoom damping factor.
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoomDamping(0.8)
    local d = cam:getZoomDamping()
    print("damping = " .. d)
end

--@api-stub: LCamera:setRotationConstraints
-- Sets minimum and maximum rotation bounds.
do
    local cam = lurek.camera.new(800, 600)
    cam:setRotationConstraints(-0.5, 0.5)
    print("rotation constrained to [-0.5, 0.5]")
end

--@api-stub: LCamera:getRotationConstraints
-- Returns the min and max rotation constraints.
do
    local cam = lurek.camera.new(800, 600)
    cam:setRotationConstraints(-1.0, 1.0)
    local mn, mx = cam:getRotationConstraints()
    print("rotation range = " .. mn .. " to " .. mx)
end

--@api-stub: LCamera:setRotationDamping
-- Sets the damping factor for rotation changes.
do
    local cam = lurek.camera.new(800, 600)
    cam:setRotationDamping(0.85)
    print("rotation damping = " .. cam:getRotationDamping())
end

--@api-stub: LCamera:getRotationDamping
-- Returns the current rotation damping factor.
do
    local cam = lurek.camera.new(800, 600)
    cam:setRotationDamping(0.7)
    local d = cam:getRotationDamping()
    print("rot damping = " .. d)
end

--@api-stub: LCamera:presetTightFollow
-- Applies a tight follow preset (very responsive).
do
    local cam = lurek.camera.new(800, 600)
    cam:presetTightFollow()
    print("tight follow preset applied")
end

--@api-stub: LCamera:presetCinematicFollow
-- Applies a cinematic follow preset (slow, smooth).
do
    local cam = lurek.camera.new(800, 600)
    cam:presetCinematicFollow()
    print("cinematic follow preset applied")
end

--@api-stub: LCamera:presetBalancedFollow
-- Applies a balanced follow preset (medium responsiveness).
do
    local cam = lurek.camera.new(800, 600)
    cam:presetBalancedFollow()
    print("balanced follow preset applied")
end

--@api-stub: LCamera:presetAggressiveFollow
-- Applies an aggressive follow preset (almost instant snap).
do
    local cam = lurek.camera.new(800, 600)
    cam:presetAggressiveFollow()
    print("aggressive follow preset applied")
end

--@api-stub: LCamera:type
-- Returns the type name of this object ("LCamera").
do
    local cam = lurek.camera.new(800, 600)
    print("type = " .. cam:type())
end

--@api-stub: LCamera:typeOf
-- Checks whether this object matches a given type name.
do
    local cam = lurek.camera.new(800, 600)
    print("is LCamera = " .. tostring(cam:typeOf("LCamera")))
end

--@api-stub: LCameraRig:splitScreen
-- Applies a split-screen layout using the current window size.
do
    local rig = lurek.camera.newRig()
    rig:setPosition("player1", 100, 100)
    rig:setPosition("player2", 500, 300)
    rig:splitScreen(1280, 720)
    print("split screen layout applied")
end

--@api-stub: LCameraRig:minimap
-- Applies a minimap layout using the current window size.
do
    local rig = lurek.camera.newRig()
    rig:setPosition("main", 400, 300)
    rig:minimap(1280, 720, 0.25)
    print("minimap layout applied")
end

--@api-stub: LCameraRig:pictureInPicture
-- Applies a picture-in-picture layout using optional inset size.
do
    local rig = lurek.camera.newRig()
    rig:setPosition("main", 200, 200)
    rig:pictureInPicture(1280, 720, 320, 180)
    print("PiP layout applied")
end

--@api-stub: LCameraRig:setPosition
-- Sets the position of a named camera, creating it if needed.
do
    local rig = lurek.camera.newRig()
    rig:setPosition("left", 100, 200)
    rig:setPosition("right", 600, 200)
    print("cameras positioned")
end

--@api-stub: LCameraRig:setZoom
-- Sets the zoom of a named camera, creating it if needed.
do
    local rig = lurek.camera.newRig()
    rig:setPosition("a", 0, 0)
    rig:setZoom("a", 1.5)
    print("zoom set on camera a")
end

--@api-stub: LCameraRig:setTarget
-- Sets the follow target of a named camera.
do
    local rig = lurek.camera.newRig()
    rig:setPosition("cam1", 0, 0)
    rig:setTarget("cam1", 400, 300)
    print("target set on cam1")
end

--@api-stub: LCameraRig:updateAll
-- Advances every camera in this rig by a time delta.
do
    local rig = lurek.camera.newRig()
    rig:setPosition("a", 0, 0)
    rig:setTarget("a", 200, 200)
    rig:updateAll(0.016)
    print("all cameras updated")
end

--@api-stub: LCameraRig:apply
-- Appends render commands for a named camera.
do
    local rig = lurek.camera.newRig()
    rig:setPosition("main", 400, 300)
    local ok = rig:apply("main")
    print("applied main = " .. tostring(ok))
end

--@api-stub: LCameraRig:getViewport
-- Returns a named camera's viewport (has flag + x, y, w, h).
do
    local rig = lurek.camera.newRig()
    rig:setPosition("left", 0, 0)
    rig:splitScreen(800, 600)
    local has, x, y, w, h = rig:getViewport("left")
    print("has=" .. tostring(has) .. " vp=" .. x .. "," .. y .. "," .. w .. "," .. h)
end

--@api-stub: LCameraRig:names
-- Returns all camera names in this rig.
do
    local rig = lurek.camera.newRig()
    rig:setPosition("p1", 0, 0)
    rig:setPosition("p2", 100, 100)
    local list = rig:names()
    print("cameras = " .. #list)
end

--@api-stub: LCameraRig:remove
-- Removes a named camera from the rig.
do
    local rig = lurek.camera.newRig()
    rig:setPosition("temp", 0, 0)
    local ok = rig:remove("temp")
    print("removed = " .. tostring(ok))
end

--@api-stub: LCameraRig:has
-- Returns whether this rig contains a named camera.
do
    local rig = lurek.camera.newRig()
    rig:setPosition("x", 0, 0)
    print("has x = " .. tostring(rig:has("x")))
    print("has z = " .. tostring(rig:has("z")))
end

--@api-stub: LCameraRig:type
-- Returns the type name ("LCameraRig").
do
    local rig = lurek.camera.newRig()
    print("type = " .. rig:type())
end

--@api-stub: LCameraRig:typeOf
-- Checks whether this object matches a given type name.
do
    local rig = lurek.camera.newRig()
    print("is LCameraRig = " .. tostring(rig:typeOf("LCameraRig")))
end

print("camera_01.lua")
