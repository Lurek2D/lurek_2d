-- content/examples/animation.lua
-- Auto-generated from content/examples2/animation_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/animation.lua

--- Animation Examples Part 1: Constructors, LAnimation methods, LAnimStateMachine, LBlendLayerSet

local function example_print_log(...)
    local parts = {}
    for i = 1, select("#", ...) do
        parts[i] = tostring(select(i, ...))
    end
    lurek.log.info(table.concat(parts, " "))
end

--@api: lurek.animation.new
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("idle", { 0 }, 4, true)
    local frameCount = anim:getFrameCount()
    local clipCount = anim:getClipCount()
    lurek.log.info("empty actor animation frame count=" .. tostring(frameCount))
    lurek.log.info("empty actor animation clip count=" .. tostring(clipCount))
end

--@api: lurek.animation.fromAseprite
do
    local json = '{"frames":[{"filename":"f0","frame":{"x":0,"y":0,"w":16,"h":16}}],"meta":{"size":{"w":16,"h":16},"frameTags":[]}}'
    local anim = lurek.animation.fromAseprite(json)
    if anim then
        example_print_log("from aseprite, clips = " .. anim:getClipCount())
        example_print_log("from aseprite, frames = " .. anim:getFrameCount())
    end
end

--@api: lurek.animation.newStateMachine
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("idle", { 0 }, 1, true)
    local sm = lurek.animation.newStateMachine(anim, "idle")
    example_print_log("state machine created = " .. tostring(sm ~= nil))
    example_print_log("state machine type = " .. sm:type())
end

--@api: lurek.animation.newCurve
do
    local curve = lurek.animation.newCurve()
    curve:addKeyframe(0.0, 0.0)
    curve:addKeyframe(1.0, 1.0)
    local midValue = curve:eval(0.5)
    local keyframeCount = curve:keyframeCount()
    lurek.log.info("camera shake curve midpoint=" .. tostring(midValue))
    lurek.log.info("camera shake curve keyframes=" .. tostring(keyframeCount))
end

--@api: lurek.animation.newSyncGroup
do
    local sg = lurek.animation.newSyncGroup()
    sg:add(101)
    sg:add(102)
    local memberCount = sg:memberCount()
    local typeName = sg:type()
    lurek.log.info("squad sync group members=" .. tostring(memberCount))
    lurek.log.info("squad sync group type=" .. tostring(typeName))
end

--@api: lurek.animation.newBlendLayerSet
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("base", "idle", 1.0)
    bls:addLayer("upper", "aim", 0.4)
    local layerCount = bls:len()
    local upperWeight = bls:getWeight("upper")
    lurek.log.info("blend layer set count=" .. tostring(layerCount))
    lurek.log.info("upper body weight=" .. tostring(upperWeight))
end

--@api: lurek.animation.buildCharacter
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
    example_print_log("character built = " .. tostring(char ~= nil))
    example_print_log("has animation = " .. tostring(char.animation ~= nil))
end

--@api: LAnimation:addFrame
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addFrame(32, 0, 32, 32)
    anim:addClip("blink", { 0, 1 }, 6, true)
    local frameCount = anim:getFrameCount()
    local clipCount = anim:getClipCount()
    lurek.log.info("npc blink frames=" .. tostring(frameCount))
    lurek.log.info("npc blink clips=" .. tostring(clipCount))
end

--@api: LAnimation:addFramesFromGrid
do
    local anim = lurek.animation.new()
    local count = anim:addFramesFromGrid(256, 256, 32, 32, 0, 8)
    anim:addClip("run", { 0, 1, 2, 3 }, 12, true)
    local frameCount = anim:getFrameCount()
    local clipCount = anim:getClipCount()
    lurek.log.info("run sheet slices added=" .. tostring(count))
    lurek.log.info("run sheet frame count=" .. tostring(frameCount) .. " clips=" .. tostring(clipCount))
end

--@api: LAnimation:addFramesFromRects
do
    local anim = lurek.animation.new()
    anim:addFramesFromRects({ { x = 0, y = 0, w = 16, h = 16 }, { x = 16, y = 0, w = 16, h = 16 } })
    anim:addClip("pickup_spin", { 0, 1 }, 10, true)
    local frameCount = anim:getFrameCount()
    local clipName = anim:getClip()
    anim:play("pickup_spin")
    lurek.log.info("pickup rect frames=" .. tostring(frameCount))
    lurek.log.info("pickup active clip before play=" .. tostring(clipName) .. " after play=" .. tostring(anim:getClip()))
end

--@api: LAnimation:addClip
do
    local anim = lurek.animation.new()
    anim:addFramesFromGrid(128, 32, 32, 32, 0, 4)
    anim:addClip("walk", { 0, 1, 2, 3 }, 10, true, "forward")
    example_print_log("clips = " .. anim:getClipCount())
    example_print_log("walk mode = " .. tostring(anim:getClipMode("walk")))
end

--@api: LAnimation:setClipMode
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("test", { 0 }, 5, true, "forward")
    anim:setClipMode("test", "reverse")
    example_print_log("clip mode set to reverse")
    example_print_log("clip mode now = " .. tostring(anim:getClipMode("test")))
end

--@api: LAnimation:getClipMode
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("run", { 0 }, 12, true, "pingpong")
    local mode = anim:getClipMode("run")
    example_print_log("run mode = " .. mode)
end

--@api: LAnimation:addClipFromGrid
do
    local anim = lurek.animation.new()
    anim:addClipFromGrid("sprint", 256, 64, 32, 32, 0, 8, 15, true)
    anim:play("sprint")
    local frameCount = anim:getFrameCount()
    local clipCount = anim:getClipCount()
    local playing = anim:isPlaying()
    lurek.log.info("sprint clip frames=" .. tostring(frameCount))
    lurek.log.info("sprint clip count=" .. tostring(clipCount) .. " playing=" .. tostring(playing))
end

--@api: LAnimation:play
do
    local anim = lurek.animation.new()
    anim:addFramesFromGrid(128, 32, 32, 32, 0, 4)
    anim:addClip("idle", { 0, 1, 2, 3 }, 8, true)
    anim:play("idle")
    example_print_log("playing = " .. tostring(anim:isPlaying()))
end

--@api: LAnimation:stop
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("a", { 0 }, 5, true)
    anim:play("a")
    anim:stop()
    example_print_log("playing after stop = " .. tostring(anim:isPlaying()))
    example_print_log("current frame after stop = " .. anim:getCurrentFrame())
end

--@api: LAnimation:pause
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("b", { 0 }, 5, true)
    anim:play("b")
    anim:pause()
    example_print_log("playing after pause = " .. tostring(anim:isPlaying()))
    example_print_log("clip after pause = " .. tostring(anim:getClip()))
end

--@api: LAnimation:resume
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("c", { 0 }, 5, true)
    anim:play("c")
    anim:pause()
    anim:resume()
    example_print_log("playing after resume = " .. tostring(anim:isPlaying()))
    example_print_log("clip after resume = " .. tostring(anim:getClip()))
end

--@api: LAnimation:update
do
    local anim = lurek.animation.new()
    anim:addFramesFromGrid(64, 32, 32, 32, 0, 2)
    anim:addClip("tick", { 0, 1 }, 2, true)
    anim:play("tick")
    anim:update(0.6)
    example_print_log("current frame after update = " .. anim:getCurrentFrame())
end

--@api: LAnimation:getQuad
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("single", { 0 }, 1, false)
    anim:play("single")
    local q = anim:getQuad()
    example_print_log("quad = " .. tostring(q ~= nil))
    example_print_log("frame = " .. anim:getCurrentFrame())
end

--@api: LAnimation:draw
do
    local atlas = lurek.render.newImage("content/examples/assets/images/sample_icon.png")
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("idle", { 0 }, 1, true)
    anim:play("idle")
    local queued = anim:draw(atlas, 20, 24, { scale = 2.0 })
    example_print_log("animation draw queued = " .. tostring(queued))
    anim:setImage(atlas)
    local queued2 = anim:draw(20, 24, { scale = 2.0 })
    example_print_log("animation draw (stored image) queued = " .. tostring(queued2))
end

--@api: LAnimation:setImage
do
    local atlas = lurek.render.newImage("content/examples/assets/images/sample_icon.png")
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("idle", { 0 }, 1, true)
    anim:play("idle")
    anim:setImage(atlas)
    local queued = anim:draw(20, 24)
    example_print_log("setImage draw queued = " .. tostring(queued))
end

--@api: LAnimation:pollEvents
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("once", { 0 }, 10, false)
    anim:play("once")
    anim:update(1.0)
    local events = anim:pollEvents()
    example_print_log("events count = " .. #events)
end

--@api: LAnimation:isPlaying
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("x", { 0 }, 1, false)
    anim:play("x")
    example_print_log("after play = " .. tostring(anim:isPlaying()))
end

--@api: LAnimation:isLooping
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("loop_clip", { 0 }, 5, true)
    anim:play("loop_clip")
    example_print_log("looping = " .. tostring(anim:isLooping()))
end

--@api: LAnimation:getClip
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("walk", { 0 }, 8, true)
    anim:play("walk")
    example_print_log("clip = " .. anim:getClip())
end

--@api: LAnimation:getSpeed
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("idle", { 0 }, 4, true)
    local defaultSpeed = anim:getSpeed()
    anim:setSpeed(1.5)
    lurek.log.info("default playback speed=" .. tostring(defaultSpeed))
    lurek.log.info("boosted playback speed=" .. tostring(anim:getSpeed()))
end

--@api: LAnimation:setSpeed
do
    local anim = lurek.animation.new()
    anim:setSpeed(2.0)
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("dash", { 0 }, 12, true)
    local boostedSpeed = anim:getSpeed()
    anim:setSpeed(0.5)
    lurek.log.info("dash speed boosted=" .. tostring(boostedSpeed))
    lurek.log.info("dash speed slowed=" .. tostring(anim:getSpeed()))
end

--@api: LAnimation:getFrameCount
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addFrame(32, 0, 32, 32)
    anim:addClip("turn", { 0, 1 }, 8, false)
    local frameCount = anim:getFrameCount()
    local clipCount = anim:getClipCount()
    lurek.log.info("turn animation frame count=" .. tostring(frameCount))
    lurek.log.info("turn animation clip count=" .. tostring(clipCount))
end

--@api: LAnimation:getClipCount
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("a", { 0 }, 5, false)
    anim:addClip("b", { 0 }, 5, true)
    example_print_log("clip count = " .. anim:getClipCount())
end

--@api: LAnimation:getCurrentFrame
do
    local anim = lurek.animation.new()
    anim:addFramesFromGrid(64, 32, 32, 32, 0, 2)
    anim:addClip("pair", { 0, 1 }, 4, true)
    anim:play("pair")
    example_print_log("current frame = " .. anim:getCurrentFrame())
end

--@api: LAnimation:setFrame
do
    local anim = lurek.animation.new()
    anim:addFramesFromGrid(128, 32, 32, 32, 0, 4)
    anim:addClip("seq", { 0, 1, 2, 3 }, 8, true)
    anim:play("seq")
    anim:setFrame(2)
    example_print_log("frame after setFrame = " .. anim:getCurrentFrame())
end

--@api: LAnimation:crossfade
do
    local anim = lurek.animation.new()
    anim:addFramesFromGrid(128, 32, 32, 32, 0, 4)
    anim:addClip("idle", { 0, 1 }, 4, true)
    anim:addClip("run", { 2, 3 }, 8, true)
    anim:play("idle")
    anim:crossfade("run", 0.3)
    example_print_log("crossfading to run")
    example_print_log("blend state exists = " .. tostring(anim:getBlendState() ~= nil))
end

--@api: LAnimation:getBlendState
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("a", { 0 }, 5, true)
    anim:play("a")
    local bs = anim:getBlendState()
    example_print_log("blend state = " .. tostring(bs ~= nil))
end

--@api: LAnimation:drawToImage
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("snap", { 0 }, 1, false)
    anim:play("snap")
    local img = anim:drawToImage(64, 64)
    example_print_log("drawn to image = " .. tostring(img ~= nil))
end

--@api: LAnimation:drawPreviewGrid
do
    local anim = lurek.animation.new()
    anim:addFramesFromGrid(128, 32, 32, 32, 0, 4)
    anim:addClip("preview", { 0, 1, 2, 3 }, 8, true)
    local previewImage = anim:drawPreviewGrid(4, 36)
    local frameCount = anim:getFrameCount()
    lurek.log.info("preview grid generated=" .. tostring(previewImage ~= nil))
    lurek.log.info("preview grid frame count=" .. tostring(frameCount))
end

--@api: LAnimation:type
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("idle", { 0 }, 1, true)
    local typeName = anim:type()
    local isAnimation = anim:typeOf("LAnimation")
    lurek.log.info("animation type=" .. tostring(typeName))
    lurek.log.info("is LAnimation=" .. tostring(isAnimation))
end

--@api: LAnimation:typeOf
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("idle", { 0 }, 1, true)
    local isAnimation = anim:typeOf("LAnimation")
    local isCurve = anim:typeOf("LAnimCurve")
    lurek.log.info("is animation=" .. tostring(isAnimation))
    lurek.log.info("is curve=" .. tostring(isCurve))
end

--@api: LAnimStateMachine:update
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("idle", { 0 }, 5, true)
    local sm = lurek.animation.newStateMachine(anim, "idle")
    sm:addState("idle", "idle", true)
    sm:update(0.016)
    example_print_log("sm updated, state = " .. sm:getState())
end

--@api: LAnimStateMachine:getState
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("stand", { 0 }, 1, true)
    local sm = lurek.animation.newStateMachine(anim, "stand")
    sm:addState("stand", "stand", true)
    example_print_log("state = " .. sm:getState())
end

--@api: LAnimStateMachine:forceState
do
    local anim = lurek.animation.new()
    anim:addFramesFromGrid(64, 32, 32, 32, 0, 2)
    anim:addClip("a", { 0 }, 5, true)
    anim:addClip("b", { 1 }, 5, true)
    local sm = lurek.animation.newStateMachine(anim, "a")
    sm:addState("a", "a", true)
    sm:addState("b", "b", true)
    sm:forceState("b")
    example_print_log("forced to state = " .. sm:getState())
end

--@api: LAnimStateMachine:addState
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("idle", { 0 }, 5, true)
    local sm = lurek.animation.newStateMachine(anim, "idle")
    sm:addState("idle", "idle", true)
    example_print_log("states added")
    example_print_log("current state = " .. sm:getState())
end

--@api: LAnimStateMachine:addTransition
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("idle", { 0 }, 5, true)
    anim:addClip("run", { 0 }, 10, true)
    local sm = lurek.animation.newStateMachine(anim, "idle")
    sm:addState("idle", "idle", true)
    sm:addState("run", "run", true)
    sm:addTransition("idle", "run", "speed > 0.1")
    example_print_log("transition added: idle -> run")
end

--@api: LAnimStateMachine:setParam
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("idle", { 0 }, 5, true)
    local sm = lurek.animation.newStateMachine(anim, "idle")
    sm:addState("idle", "idle", true)
    sm:setParam("speed", 2.5)
    example_print_log("params set")
    example_print_log("state after param = " .. sm:getState())
end

--@api: LAnimStateMachine:getQuad
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("idle", { 0 }, 5, true)
    local sm = lurek.animation.newStateMachine(anim, "idle")
    sm:addState("idle", "idle", true)
    sm:update(0.0)
    example_print_log("sm quad = " .. tostring(sm:getQuad() ~= nil))
end

--@api: LAnimStateMachine:draw
do
    local atlas = lurek.render.newImage("content/examples/assets/images/sample_icon.png")
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("idle", { 0 }, 8, true)
    anim:play("idle")
    local sm = lurek.animation.newStateMachine(anim, "idle")
    sm:addState("idle", "idle", true)
    local queued = sm:draw(atlas, 48, 24, { scale = 2.0 })
    example_print_log("state machine draw queued = " .. tostring(queued))
    sm:setImage(atlas)
    local queued2 = sm:draw(48, 24, { scale = 2.0 })
    example_print_log("state machine draw (stored image) queued = " .. tostring(queued2))
end

--@api: LAnimStateMachine:setImage
do
    local atlas = lurek.render.newImage("content/examples/assets/images/sample_icon.png")
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("idle", { 0 }, 8, true)
    anim:play("idle")
    local sm = lurek.animation.newStateMachine(anim, "idle")
    sm:addState("idle", "idle", true)
    sm:setImage(atlas)
    local queued = sm:draw(48, 24)
    example_print_log("sm setImage draw queued = " .. tostring(queued))
end

--@api: LAnimStateMachine:type
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("idle", { 0 }, 5, true)
    local sm = lurek.animation.newStateMachine(anim, "idle")
    example_print_log("type = " .. sm:type())
    example_print_log("matches = " .. tostring(sm:typeOf("LAnimStateMachine")))
end

--@api: LAnimStateMachine:typeOf
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("idle", { 0 }, 5, true)
    local sm = lurek.animation.newStateMachine(anim, "idle")
    example_print_log("is LAnimStateMachine = " .. tostring(sm:typeOf("LAnimStateMachine")))
end

--@api: LBlendLayerSet:addLayer
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("base", "idle", 1.0)
    bls:addLayer("upper_body", "aim", 0.35)
    local layerCount = bls:len()
    local upperWeight = bls:getWeight("upper_body")
    lurek.log.info("blend layers added=" .. tostring(layerCount))
    lurek.log.info("upper body aim weight=" .. tostring(upperWeight))
end

--@api: LBlendLayerSet:removeLayer
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("temp", "idle", 1.0)
    bls:removeLayer("temp")
    example_print_log("layer removed")
    example_print_log("layer count = " .. bls:len())
end

--@api: LBlendLayerSet:setWeight
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("walk", "walk_clip", 0.5)
    bls:setWeight("walk", 0.8)
    example_print_log("weight = " .. bls:getWeight("walk"))
    example_print_log("layer count = " .. bls:len())
end

--@api: LBlendLayerSet:getWeight
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("run", "run_clip", 0.7)
    bls:addLayer("lean", "lean_clip", 0.25)
    local runWeight = bls:getWeight("run")
    local leanWeight = bls:getWeight("lean")
    lurek.log.info("run layer weight=" .. tostring(runWeight))
    lurek.log.info("lean layer weight=" .. tostring(leanWeight))
end

--@api: LBlendLayerSet:setMask
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("arms", "swing", 1.0)
    bls:setMask("arms", { "shoulder_l", "arm_l", "hand_l" })
    example_print_log("mask set for arms layer")
    example_print_log("layer count = " .. bls:len())
end

--- Animation Examples Part 2: Blend Layer Set (cont.), Animation Curve, Sync Group

--@api: LBlendLayerSet:listLayers
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("base", "idle", 1.0)
    local names = bls:listLayers()
    example_print_log("layers = " .. #names)
    example_print_log("first layer = " .. tostring(names[1]))
end

--@api: LBlendLayerSet:len
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("a", "clip_a", 1.0)
    bls:addLayer("b", "clip_b", 0.5)
    local layerCount = bls:len()
    local secondWeight = bls:getWeight("b")
    lurek.log.info("blend layer count=" .. tostring(layerCount))
    lurek.log.info("second layer weight=" .. tostring(secondWeight))
end

--@api: LBlendLayerSet:type
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("base", "idle", 1.0)
    local typeName = bls:type()
    local isBlendSet = bls:typeOf("LBlendLayerSet")
    local layerCount = bls:len()
    lurek.log.info("blend set type=" .. tostring(typeName))
    lurek.log.info("is blend set=" .. tostring(isBlendSet) .. " layers=" .. tostring(layerCount))
end

--@api: LBlendLayerSet:typeOf
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("base", "idle", 1.0)
    local isBlendSet = bls:typeOf("LBlendLayerSet")
    local isAnimation = bls:typeOf("LAnimation")
    lurek.log.info("is blend layer set=" .. tostring(isBlendSet))
    lurek.log.info("is animation=" .. tostring(isAnimation))
end

--@api: LAnimCurve:addKeyframe
do
    local curve = lurek.animation.newCurve()
    curve:addKeyframe(0.0, 0.0)
    curve:addKeyframe(0.5, 1.0)
    example_print_log("keyframes = " .. curve:keyframeCount())
    example_print_log("mid value = " .. curve:eval(0.5))
end

--@api: LAnimCurve:eval
do
    local curve = lurek.animation.newCurve()
    curve:addKeyframe(0.0, 0.0)
    curve:addKeyframe(1.0, 10.0)
    local mid = curve:eval(0.5)
    example_print_log("value at 0.5 = " .. mid)
end

--@api: LAnimCurve:setEasing
do
    local curve = lurek.animation.newCurve()
    curve:addKeyframe(0.0, 0.0)
    curve:addKeyframe(1.0, 1.0)
    curve:setEasing("ease_in_out")
    example_print_log("eased value at 0.5 = " .. curve:eval(0.5))
end

--@api: LAnimCurve:keyframeCount
do
    local curve = lurek.animation.newCurve()
    curve:addKeyframe(0.0, 0.0)
    curve:addKeyframe(0.25, 5.0)
    curve:addKeyframe(1.0, 10.0)
    local keyframeCount = curve:keyframeCount()
    local halfValue = curve:eval(0.5)
    lurek.log.info("jump arc keyframes=" .. tostring(keyframeCount))
    lurek.log.info("jump arc midpoint=" .. tostring(halfValue))
end

--@api: LAnimCurve:setCustomEasing
do
    local curve = lurek.animation.newCurve()
    curve:addKeyframe(0.0, 0.0)
    curve:addKeyframe(1.0, 100.0)
    curve:setCustomEasing(function(t) return t * t end)
    example_print_log("custom eased at 0.5 = " .. curve:eval(0.5))
end

--@api: LAnimCurve:clear
do
    local curve = lurek.animation.newCurve()
    curve:addKeyframe(0.0, 1.0)
    curve:addKeyframe(1.0, 2.0)
    curve:clear()
    example_print_log("after clear, keyframes = " .. curve:keyframeCount())
end

--@api: LAnimCurve:type
do
    local curve = lurek.animation.newCurve()
    curve:addKeyframe(0.0, 0.0)
    curve:addKeyframe(1.0, 1.0)
    local typeName = curve:type()
    local isCurve = curve:typeOf("LAnimCurve")
    lurek.log.info("curve type=" .. tostring(typeName))
    lurek.log.info("is curve=" .. tostring(isCurve))
end

--@api: LAnimCurve:typeOf
do
    local curve = lurek.animation.newCurve()
    curve:addKeyframe(0.0, 0.0)
    curve:addKeyframe(1.0, 1.0)
    local isCurve = curve:typeOf("LAnimCurve")
    local isBlendSet = curve:typeOf("LBlendLayerSet")
    lurek.log.info("is curve=" .. tostring(isCurve))
    lurek.log.info("is blend set=" .. tostring(isBlendSet))
end

--@api: LAnimSyncGroup:add
do
    local sg = lurek.animation.newSyncGroup()
    sg:add(1)
    sg:add(2)
    local memberCount = sg:memberCount()
    local typeName = sg:type()
    lurek.log.info("sync group members after add=" .. tostring(memberCount))
    lurek.log.info("sync group type=" .. tostring(typeName))
end

--@api: LAnimSyncGroup:remove
do
    local sg = lurek.animation.newSyncGroup()
    sg:add(1)
    sg:add(2)
    sg:remove(1)
    local memberCount = sg:memberCount()
    local stillHasSecond = memberCount > 0
    lurek.log.info("sync members after remove=" .. tostring(memberCount))
    lurek.log.info("second handle still tracked=" .. tostring(stillHasSecond))
end

--@api: LAnimSyncGroup:clear
do
    local sg = lurek.animation.newSyncGroup()
    sg:add(1)
    sg:add(2)
    sg:clear()
    local memberCount = sg:memberCount()
    local typeName = sg:type()
    lurek.log.info("sync members after clear=" .. tostring(memberCount))
    lurek.log.info("sync group type after clear=" .. tostring(typeName))
end

--@api: LAnimSyncGroup:memberCount
do
    local sg = lurek.animation.newSyncGroup()
    sg:add(1)
    sg:add(2)
    local memberCount = sg:memberCount()
    sg:remove(2)
    lurek.log.info("members before trim=" .. tostring(memberCount))
    lurek.log.info("members after trim=" .. tostring(sg:memberCount()))
end

--@api: LAnimSyncGroup:type
do
    local sg = lurek.animation.newSyncGroup()
    sg:add(11)
    local typeName = sg:type()
    local isSyncGroup = sg:typeOf("LAnimSyncGroup")
    local memberCount = sg:memberCount()
    lurek.log.info("sync group type=" .. tostring(typeName))
    lurek.log.info("is sync group=" .. tostring(isSyncGroup) .. " members=" .. tostring(memberCount))
end

--@api: LAnimSyncGroup:typeOf
do
    local sg = lurek.animation.newSyncGroup()
    sg:add(12)
    local isSyncGroup = sg:typeOf("LAnimSyncGroup")
    local isCurve = sg:typeOf("LAnimCurve")
    lurek.log.info("is sync group=" .. tostring(isSyncGroup))
    lurek.log.info("is curve=" .. tostring(isCurve))
end
