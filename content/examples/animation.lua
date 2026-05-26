-- content/examples/animation.lua
-- Auto-generated from content/examples2/animation_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/animation.lua

--- Animation Examples Part 1: Constructors, LAnimation methods, LAnimStateMachine, LBlendLayerSet

--@api-stub: lurek.animation.new
do
    local anim = lurek.animation.new()
    print("animation created, frames = " .. anim:getFrameCount())
    print("animation type = " .. anim:type())
end

--@api-stub: lurek.animation.fromAseprite
do
    local json = '{"frames":[{"filename":"f0","frame":{"x":0,"y":0,"w":16,"h":16}}],"meta":{"size":{"w":16,"h":16},"frameTags":[]}}'
    local anim = lurek.animation.fromAseprite(json)
    if anim then
        print("from aseprite, clips = " .. anim:getClipCount())
        print("from aseprite, frames = " .. anim:getFrameCount())
    end
end

--@api-stub: lurek.animation.newStateMachine
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("idle", { 0 }, 1, true)
    local sm = lurek.animation.newStateMachine(anim, "idle")
    print("state machine created = " .. tostring(sm ~= nil))
    print("state machine type = " .. sm:type())
end

--@api-stub: lurek.animation.newCurve
do
    local curve = lurek.animation.newCurve()
    print("curve created = " .. tostring(curve ~= nil))
    print("curve type = " .. curve:type())
end

--@api-stub: lurek.animation.newSyncGroup
do
    local sg = lurek.animation.newSyncGroup()
    print("sync group created = " .. tostring(sg ~= nil))
    print("sync group members = " .. sg:memberCount())
end

--@api-stub: lurek.animation.newBlendLayerSet
do
    local bls = lurek.animation.newBlendLayerSet()
    print("blend layer set created = " .. tostring(bls ~= nil))
    print("blend layer count = " .. bls:len())
end

--@api-stub: lurek.animation.buildCharacter
do
    local char = lurek.animation.buildCharacter({
        texW = 64,
        texH = 16,
        frameW = 16,
        frameH = 16,
        clips = {
            { name = "idle", start = 0, count = 2, fps = 4, looping = true, mode = "forward" }
        },
        states = {
            { name = "idle", clip = "idle", looping = true }
        },
        initialState = "idle"
    })
    print("character built = " .. tostring(char ~= nil))
    print("has animation = " .. tostring(char.animation ~= nil))
end

--@api-stub: LAnimation:addFrame
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    print("frames = " .. anim:getFrameCount())
    print("current frame = " .. anim:getCurrentFrame())
end

--@api-stub: LAnimation:addFramesFromGrid
do
    local anim = lurek.animation.new()
    local count = anim:addFramesFromGrid(256, 256, 32, 32, 0, 8)
    print("added " .. count .. " frames from grid")
    print("frame count = " .. anim:getFrameCount())
end

--@api-stub: LAnimation:addFramesFromRects
do
    local anim = lurek.animation.new()
    anim:addFramesFromRects({ { x = 0, y = 0, w = 16, h = 16 }, { x = 16, y = 0, w = 16, h = 16 } })
    print("frames from rects = " .. anim:getFrameCount())
    print("animation type = " .. anim:type())
end

--@api-stub: LAnimation:addClip
do
    local anim = lurek.animation.new()
    anim:addFramesFromGrid(128, 32, 32, 32, 0, 4)
    anim:addClip("walk", { 0, 1, 2, 3 }, 10, true, "forward")
    print("clips = " .. anim:getClipCount())
    print("walk mode = " .. tostring(anim:getClipMode("walk")))
end

--@api-stub: LAnimation:setClipMode
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("test", { 0 }, 5, true, "forward")
    anim:setClipMode("test", "reverse")
    print("clip mode set to reverse")
    print("clip mode now = " .. tostring(anim:getClipMode("test")))
end

--@api-stub: LAnimation:getClipMode
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("run", { 0 }, 12, true, "pingpong")
    local mode = anim:getClipMode("run")
    print("run mode = " .. mode)
end

--@api-stub: LAnimation:addClipFromGrid
do
    local anim = lurek.animation.new()
    anim:addClipFromGrid("sprint", 256, 64, 32, 32, 0, 8, 15, true)
    print("clip from grid, frames = " .. anim:getFrameCount())
    print("clip count = " .. anim:getClipCount())
end

--@api-stub: LAnimation:play
do
    local anim = lurek.animation.new()
    anim:addFramesFromGrid(128, 32, 32, 32, 0, 4)
    anim:addClip("idle", { 0, 1, 2, 3 }, 8, true)
    anim:play("idle")
    print("playing = " .. tostring(anim:isPlaying()))
end

--@api-stub: LAnimation:stop
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("a", { 0 }, 5, true)
    anim:play("a")
    anim:stop()
    print("playing after stop = " .. tostring(anim:isPlaying()))
    print("current frame after stop = " .. anim:getCurrentFrame())
end

--@api-stub: LAnimation:pause
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("b", { 0 }, 5, true)
    anim:play("b")
    anim:pause()
    print("playing after pause = " .. tostring(anim:isPlaying()))
    print("clip after pause = " .. tostring(anim:getClip()))
end

--@api-stub: LAnimation:resume
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("c", { 0 }, 5, true)
    anim:play("c")
    anim:pause()
    anim:resume()
    print("playing after resume = " .. tostring(anim:isPlaying()))
    print("clip after resume = " .. tostring(anim:getClip()))
end

--@api-stub: LAnimation:update
do
    local anim = lurek.animation.new()
    anim:addFramesFromGrid(64, 32, 32, 32, 0, 2)
    anim:addClip("tick", { 0, 1 }, 2, true)
    anim:play("tick")
    anim:update(0.6)
    print("current frame after update = " .. anim:getCurrentFrame())
end

--@api-stub: LAnimation:getQuad
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("single", { 0 }, 1, false)
    anim:play("single")
    local q = anim:getQuad()
    print("quad = " .. tostring(q ~= nil))
    print("frame = " .. anim:getCurrentFrame())
end

--@api-stub: LAnimation:draw
do
    local atlas = lurek.render.newImage("assets/icon.png")
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("idle", { 0 }, 1, true)
    anim:play("idle")
    local queued = anim:draw(atlas, 20, 24, { scale = 2.0 })
    print("animation draw queued = " .. tostring(queued))
    anim:setImage(atlas)
    local queued2 = anim:draw(20, 24, { scale = 2.0 })
    print("animation draw (stored image) queued = " .. tostring(queued2))
end

--@api-stub: LAnimation:setImage
do
    local atlas = lurek.render.newImage("assets/icon.png")
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("idle", { 0 }, 1, true)
    anim:play("idle")
    anim:setImage(atlas)
    local queued = anim:draw(20, 24)
    print("setImage draw queued = " .. tostring(queued))
end

--@api-stub: LAnimation:pollEvents
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("once", { 0 }, 10, false)
    anim:play("once")
    anim:update(1.0)
    local events = anim:pollEvents()
    print("events count = " .. #events)
end

--@api-stub: LAnimation:isPlaying
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("x", { 0 }, 1, false)
    anim:play("x")
    print("after play = " .. tostring(anim:isPlaying()))
end

--@api-stub: LAnimation:isLooping
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("loop_clip", { 0 }, 5, true)
    anim:play("loop_clip")
    print("looping = " .. tostring(anim:isLooping()))
end

--@api-stub: LAnimation:getClip
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("walk", { 0 }, 8, true)
    anim:play("walk")
    print("clip = " .. anim:getClip())
end

--@api-stub: LAnimation:getSpeed
do
    local anim = lurek.animation.new()
    print("default speed = " .. anim:getSpeed())
    print("type = " .. anim:type())
end

--@api-stub: LAnimation:setSpeed
do
    local anim = lurek.animation.new()
    anim:setSpeed(2.0)
    print("speed = " .. anim:getSpeed())
end

--@api-stub: LAnimation:getFrameCount
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addFrame(32, 0, 32, 32)
    print("frame count = " .. anim:getFrameCount())
end

--@api-stub: LAnimation:getClipCount
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("a", { 0 }, 5, false)
    anim:addClip("b", { 0 }, 5, true)
    print("clip count = " .. anim:getClipCount())
end

--@api-stub: LAnimation:getCurrentFrame
do
    local anim = lurek.animation.new()
    anim:addFramesFromGrid(64, 32, 32, 32, 0, 2)
    anim:addClip("pair", { 0, 1 }, 4, true)
    anim:play("pair")
    print("current frame = " .. anim:getCurrentFrame())
end

--@api-stub: LAnimation:setFrame
do
    local anim = lurek.animation.new()
    anim:addFramesFromGrid(128, 32, 32, 32, 0, 4)
    anim:addClip("seq", { 0, 1, 2, 3 }, 8, true)
    anim:play("seq")
    anim:setFrame(2)
    print("frame after setFrame = " .. anim:getCurrentFrame())
end

--@api-stub: LAnimation:crossfade
do
    local anim = lurek.animation.new()
    anim:addFramesFromGrid(128, 32, 32, 32, 0, 4)
    anim:addClip("idle", { 0, 1 }, 4, true)
    anim:addClip("run", { 2, 3 }, 8, true)
    anim:play("idle")
    anim:crossfade("run", 0.3)
    print("crossfading to run")
    print("blend state exists = " .. tostring(anim:getBlendState() ~= nil))
end

--@api-stub: LAnimation:getBlendState
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("a", { 0 }, 5, true)
    anim:play("a")
    local bs = anim:getBlendState()
    print("blend state = " .. tostring(bs ~= nil))
end

--@api-stub: LAnimation:drawToImage
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("snap", { 0 }, 1, false)
    anim:play("snap")
    local img = anim:drawToImage(64, 64)
    print("drawn to image = " .. tostring(img ~= nil))
end

--@api-stub: LAnimation:drawPreviewGrid
do
    local anim = lurek.animation.new()
    anim:addFramesFromGrid(128, 32, 32, 32, 0, 4)
    anim:drawPreviewGrid(4, 36)
    print("preview grid drawn")
end

--@api-stub: LAnimation:type
do
    local anim = lurek.animation.new()
    print("type = " .. anim:type())
    print("matches = " .. tostring(anim:typeOf("LAnimation")))
end

--@api-stub: LAnimation:typeOf
do
    local anim = lurek.animation.new()
    print("is LAnimation = " .. tostring(anim:typeOf("LAnimation")))
end

--@api-stub: LAnimStateMachine:update
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("idle", { 0 }, 5, true)
    local sm = lurek.animation.newStateMachine(anim, "idle")
    sm:addState("idle", "idle", true)
    sm:update(0.016)
    print("sm updated, state = " .. sm:getState())
end

--@api-stub: LAnimStateMachine:getState
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("stand", { 0 }, 1, true)
    local sm = lurek.animation.newStateMachine(anim, "stand")
    sm:addState("stand", "stand", true)
    print("state = " .. sm:getState())
end

--@api-stub: LAnimStateMachine:forceState
do
    local anim = lurek.animation.new()
    anim:addFramesFromGrid(64, 32, 32, 32, 0, 2)
    anim:addClip("a", { 0 }, 5, true)
    anim:addClip("b", { 1 }, 5, true)
    local sm = lurek.animation.newStateMachine(anim, "a")
    sm:addState("a", "a", true)
    sm:addState("b", "b", true)
    sm:forceState("b")
    print("forced to state = " .. sm:getState())
end

--@api-stub: LAnimStateMachine:addState
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("idle", { 0 }, 5, true)
    local sm = lurek.animation.newStateMachine(anim, "idle")
    sm:addState("idle", "idle", true)
    print("states added")
    print("current state = " .. sm:getState())
end

--@api-stub: LAnimStateMachine:addTransition
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("idle", { 0 }, 5, true)
    anim:addClip("run", { 0 }, 10, true)
    local sm = lurek.animation.newStateMachine(anim, "idle")
    sm:addState("idle", "idle", true)
    sm:addState("run", "run", true)
    sm:addTransition("idle", "run", "speed > 0.1")
    print("transition added: idle -> run")
end

--@api-stub: LAnimStateMachine:setParam
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("idle", { 0 }, 5, true)
    local sm = lurek.animation.newStateMachine(anim, "idle")
    sm:addState("idle", "idle", true)
    sm:setParam("speed", 2.5)
    print("params set")
    print("state after param = " .. sm:getState())
end

--@api-stub: LAnimStateMachine:getQuad
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("idle", { 0 }, 5, true)
    local sm = lurek.animation.newStateMachine(anim, "idle")
    sm:addState("idle", "idle", true)
    sm:update(0.0)
    print("sm quad = " .. tostring(sm:getQuad() ~= nil))
end

--@api-stub: LAnimStateMachine:draw
do
    local atlas = lurek.render.newImage("assets/icon.png")
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("idle", { 0 }, 8, true)
    anim:play("idle")
    local sm = lurek.animation.newStateMachine(anim, "idle")
    sm:addState("idle", "idle", true)
    local queued = sm:draw(atlas, 48, 24, { scale = 2.0 })
    print("state machine draw queued = " .. tostring(queued))
    sm:setImage(atlas)
    local queued2 = sm:draw(48, 24, { scale = 2.0 })
    print("state machine draw (stored image) queued = " .. tostring(queued2))
end

--@api-stub: LAnimStateMachine:setImage
do
    local atlas = lurek.render.newImage("assets/icon.png")
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("idle", { 0 }, 8, true)
    anim:play("idle")
    local sm = lurek.animation.newStateMachine(anim, "idle")
    sm:addState("idle", "idle", true)
    sm:setImage(atlas)
    local queued = sm:draw(48, 24)
    print("sm setImage draw queued = " .. tostring(queued))
end

--@api-stub: LAnimStateMachine:type
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("idle", { 0 }, 5, true)
    local sm = lurek.animation.newStateMachine(anim, "idle")
    print("type = " .. sm:type())
    print("matches = " .. tostring(sm:typeOf("LAnimStateMachine")))
end

--@api-stub: LAnimStateMachine:typeOf
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("idle", { 0 }, 5, true)
    local sm = lurek.animation.newStateMachine(anim, "idle")
    print("is LAnimStateMachine = " .. tostring(sm:typeOf("LAnimStateMachine")))
end

--@api-stub: LBlendLayerSet:addLayer
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("base", "idle", 1.0)
    print("layers added")
    print("layer count = " .. bls:len())
end

--@api-stub: LBlendLayerSet:removeLayer
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("temp", "idle", 1.0)
    bls:removeLayer("temp")
    print("layer removed")
    print("layer count = " .. bls:len())
end

--@api-stub: LBlendLayerSet:setWeight
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("walk", "walk_clip", 0.5)
    bls:setWeight("walk", 0.8)
    print("weight = " .. bls:getWeight("walk"))
    print("layer count = " .. bls:len())
end

--@api-stub: LBlendLayerSet:getWeight
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("run", "run_clip", 0.7)
    local w = bls:getWeight("run")
    print("run weight = " .. w)
end

--@api-stub: LBlendLayerSet:setMask
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("arms", "swing", 1.0)
    bls:setMask("arms", { "shoulder_l", "arm_l", "hand_l" })
    print("mask set for arms layer")
    print("layer count = " .. bls:len())
end

--- Animation Examples Part 2: Blend Layer Set (cont.), Animation Curve, Sync Group

--@api-stub: LBlendLayerSet:listLayers
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("base", "idle", 1.0)
    local names = bls:listLayers()
    print("layers = " .. #names)
    print("first layer = " .. tostring(names[1]))
end

--@api-stub: LBlendLayerSet:len
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("a", "clip_a", 1.0)
    print("layer count = " .. bls:len())
    print("type = " .. bls:type())
end

--@api-stub: LBlendLayerSet:type
do
    local bls = lurek.animation.newBlendLayerSet()
    print("type = " .. bls:type())
    print("matches = " .. tostring(bls:typeOf("LBlendLayerSet")))
end

--@api-stub: LBlendLayerSet:typeOf
do
    local bls = lurek.animation.newBlendLayerSet()
    print("is LBlendLayerSet = " .. tostring(bls:typeOf("LBlendLayerSet")))
end

--@api-stub: LAnimCurve:addKeyframe
do
    local curve = lurek.animation.newCurve()
    curve:addKeyframe(0.0, 0.0)
    curve:addKeyframe(0.5, 1.0)
    print("keyframes = " .. curve:keyframeCount())
    print("mid value = " .. curve:eval(0.5))
end

--@api-stub: LAnimCurve:eval
do
    local curve = lurek.animation.newCurve()
    curve:addKeyframe(0.0, 0.0)
    curve:addKeyframe(1.0, 10.0)
    local mid = curve:eval(0.5)
    print("value at 0.5 = " .. mid)
end

--@api-stub: LAnimCurve:setEasing
do
    local curve = lurek.animation.newCurve()
    curve:addKeyframe(0.0, 0.0)
    curve:addKeyframe(1.0, 1.0)
    curve:setEasing("ease_in_out")
    print("eased value at 0.5 = " .. curve:eval(0.5))
end

--@api-stub: LAnimCurve:keyframeCount
do
    local curve = lurek.animation.newCurve()
    curve:addKeyframe(0.0, 0.0)
    curve:addKeyframe(0.25, 5.0)
    print("keyframe count = " .. curve:keyframeCount())
end

--@api-stub: LAnimCurve:setCustomEasing
do
    local curve = lurek.animation.newCurve()
    curve:addKeyframe(0.0, 0.0)
    curve:addKeyframe(1.0, 100.0)
    curve:setCustomEasing(function(t) return t * t end)
    print("custom eased at 0.5 = " .. curve:eval(0.5))
end

--@api-stub: LAnimCurve:clear
do
    local curve = lurek.animation.newCurve()
    curve:addKeyframe(0.0, 1.0)
    curve:addKeyframe(1.0, 2.0)
    curve:clear()
    print("after clear, keyframes = " .. curve:keyframeCount())
end

--@api-stub: LAnimCurve:type
do
    local curve = lurek.animation.newCurve()
    print("type = " .. curve:type())
    print("matches = " .. tostring(curve:typeOf("LAnimCurve")))
end

--@api-stub: LAnimCurve:typeOf
do
    local curve = lurek.animation.newCurve()
    print("is LAnimCurve = " .. tostring(curve:typeOf("LAnimCurve")))
end

--@api-stub: LAnimSyncGroup:add
do
    local sg = lurek.animation.newSyncGroup()
    sg:add(1)
    print("sync group members = " .. sg:memberCount())
    print("sync group type = " .. sg:type())
end

--@api-stub: LAnimSyncGroup:remove
do
    local sg = lurek.animation.newSyncGroup()
    sg:add(1)
    sg:remove(1)
    print("after remove, members = " .. sg:memberCount())
end

--@api-stub: LAnimSyncGroup:clear
do
    local sg = lurek.animation.newSyncGroup()
    sg:add(1)
    sg:clear()
    print("after clear, members = " .. sg:memberCount())
end

--@api-stub: LAnimSyncGroup:memberCount
do
    local sg = lurek.animation.newSyncGroup()
    sg:add(1)
    print("member count = " .. sg:memberCount())
end

--@api-stub: LAnimSyncGroup:type
do
    local sg = lurek.animation.newSyncGroup()
    print("type = " .. sg:type())
    print("matches = " .. tostring(sg:typeOf("LAnimSyncGroup")))
end

--@api-stub: LAnimSyncGroup:typeOf
do
    local sg = lurek.animation.newSyncGroup()
    print("is LAnimSyncGroup = " .. tostring(sg:typeOf("LAnimSyncGroup")))
end
