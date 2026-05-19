-- content/examples/animation.lua
-- Auto-generated from content/examples2/animation_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/animation.lua

--- Animation Examples Part 1: Constructors, LAnimation methods, LAnimStateMachine, LBlendLayerSet


--@api-stub: lurek.animation.new
-- Creates a new empty animation object.
do
    local anim = lurek.animation.new()
    print("animation created, frames = " .. anim:getFrameCount())
end

--@api-stub: lurek.animation.fromAseprite
-- Creates an animation from an Aseprite JSON export string.
do
    local json = '{"frames":[{"filename":"f0","frame":{"x":0,"y":0,"w":16,"h":16}}],"meta":{"size":{"w":16,"h":16},"frameTags":[]}}'
    local anim = lurek.animation.fromAseprite(json)
    if anim then
        print("from aseprite, clips = " .. anim:getClipCount())
    end
end

--@api-stub: lurek.animation.newStateMachine
-- Creates an animation state machine bound to an animation.
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("idle", { 0 }, 1, true)
    local sm = lurek.animation.newStateMachine(anim, "idle")
    print("state machine created = " .. tostring(sm ~= nil))
end

--@api-stub: lurek.animation.newCurve
-- Creates a new animation curve for interpolating values over time.
do
    local curve = lurek.animation.newCurve()
    print("curve created = " .. tostring(curve ~= nil))
end

--@api-stub: lurek.animation.newSyncGroup
-- Creates a sync group for synchronizing multiple animations.
do
    local sg = lurek.animation.newSyncGroup()
    print("sync group created = " .. tostring(sg ~= nil))
end

--@api-stub: lurek.animation.newBlendLayerSet
-- Creates a new blend layer set for layered animation blending.
do
    local bls = lurek.animation.newBlendLayerSet()
    print("blend layer set created = " .. tostring(bls ~= nil))
end

--@api-stub: lurek.animation.buildCharacter
-- Builds a character animation setup from a configuration table.
do
    local cfg = {
        texW = 64,
        texH = 16,
        frameW = 16,
        frameH = 16,
        clips = {
            { name = "idle", start = 0, count = 2, fps = 4, looping = true, mode = "forward" },
        },
        states = {
            { name = "idle", clip = "idle", looping = true },
        },
        initialState = "idle",
    }
    local char = lurek.animation.buildCharacter(cfg)
    print("character built = " .. tostring(char ~= nil))
end

--@api-stub: LAnimation:addFrame
-- Adds a single frame defined by a pixel rectangle on the source texture.
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    print("frames = " .. anim:getFrameCount())
end

--@api-stub: LAnimation:addFramesFromGrid
-- Adds multiple frames by slicing a texture into a grid of cells.
do
    local anim = lurek.animation.new()
    local count = anim:addFramesFromGrid(256, 256, 32, 32, 0, 8)
    print("added " .. count .. " frames from grid")
end

--@api-stub: LAnimation:addFramesFromRects
-- Adds frames from a table of rectangle definitions.
do
    local anim = lurek.animation.new()
    anim:addFramesFromRects({
        { x = 0, y = 0, w = 16, h = 16 },
        { x = 16, y = 0, w = 16, h = 16 },
    })
    print("frames from rects = " .. anim:getFrameCount())
end

--@api-stub: LAnimation:addClip
-- Defines a named clip from existing frame indices with playback settings.
do
    local anim = lurek.animation.new()
    anim:addFramesFromGrid(128, 32, 32, 32, 0, 4)
    anim:addClip("walk", { 0, 1, 2, 3 }, 10, true, "forward")
    print("clips = " .. anim:getClipCount())
end

--@api-stub: LAnimation:setClipMode
-- Changes the playback mode of an existing clip.
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("test", { 0 }, 5, true, "forward")
    anim:setClipMode("test", "reverse")
    print("clip mode set to reverse")
end

--@api-stub: LAnimation:getClipMode
-- Returns the playback mode of a named clip.
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("run", { 0 }, 12, true, "pingpong")
    local mode = anim:getClipMode("run")
    print("run mode = " .. mode)
end

--@api-stub: LAnimation:addClipFromGrid
-- Adds frames from a grid and creates a clip from them in one call.
do
    local anim = lurek.animation.new()
    anim:addClipFromGrid("sprint", 256, 64, 32, 32, 0, 8, 15, true)
    print("clip from grid, frames = " .. anim:getFrameCount())
end

--@api-stub: LAnimation:play
-- Starts playing a named clip from the beginning.
do
    local anim = lurek.animation.new()
    anim:addFramesFromGrid(128, 32, 32, 32, 0, 4)
    anim:addClip("idle", { 0, 1, 2, 3 }, 8, true)
    anim:play("idle")
    print("playing = " .. tostring(anim:isPlaying()))
end

--@api-stub: LAnimation:stop
-- Stops playback and resets to the first frame of the current clip.
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("a", { 0 }, 5, true)
    anim:play("a")
    anim:stop()
    print("playing after stop = " .. tostring(anim:isPlaying()))
end

--@api-stub: LAnimation:pause
-- Pauses playback at the current frame.
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("b", { 0 }, 5, true)
    anim:play("b")
    anim:pause()
    print("playing after pause = " .. tostring(anim:isPlaying()))
end

--@api-stub: LAnimation:resume
-- Resumes playback from a paused state.
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("c", { 0 }, 5, true)
    anim:play("c")
    anim:pause()
    anim:resume()
    print("playing after resume = " .. tostring(anim:isPlaying()))
end

--@api-stub: LAnimation:update
-- Advances the animation by dt seconds.
do
    local anim = lurek.animation.new()
    anim:addFramesFromGrid(64, 32, 32, 32, 0, 2)
    anim:addClip("tick", { 0, 1 }, 2, true)
    anim:play("tick")
    anim:update(0.6)
    print("current frame after update = " .. anim:getCurrentFrame())
end

--@api-stub: LAnimation:getQuad
-- Returns the current frame quad for drawing.
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("single", { 0 }, 1, false)
    anim:play("single")
    local q = anim:getQuad()
    print("quad = " .. tostring(q ~= nil))
end

--@api-stub: LAnimation:pollEvents
-- Returns and clears any queued animation events (clip end, loop, etc.).
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
-- Returns true if the animation is currently playing.
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("x", { 0 }, 1, false)
    anim:play("x")
    print("after play = " .. tostring(anim:isPlaying()))
end

--@api-stub: LAnimation:isLooping
-- Returns true if the current clip is set to loop.
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("loop_clip", { 0 }, 5, true)
    anim:play("loop_clip")
    print("looping = " .. tostring(anim:isLooping()))
end

--@api-stub: LAnimation:getClip
-- Returns the name of the currently active clip.
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("walk", { 0 }, 8, true)
    anim:play("walk")
    print("clip = " .. anim:getClip())
end

--@api-stub: LAnimation:getSpeed
-- Returns the current playback speed multiplier.
do
    local anim = lurek.animation.new()
    print("default speed = " .. anim:getSpeed())
end

--@api-stub: LAnimation:setSpeed
-- Sets the playback speed multiplier (1.0 = normal, 2.0 = double speed).
do
    local anim = lurek.animation.new()
    anim:setSpeed(2.0)
    print("speed = " .. anim:getSpeed())
end

--@api-stub: LAnimation:getFrameCount
-- Returns the total number of frames in the animation.
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addFrame(32, 0, 32, 32)
    print("frame count = " .. anim:getFrameCount())
end

--@api-stub: LAnimation:getClipCount
-- Returns the number of defined clips.
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("a", { 0 }, 5, false)
    anim:addClip("b", { 0 }, 5, true)
    print("clip count = " .. anim:getClipCount())
end

--@api-stub: LAnimation:getCurrentFrame
-- Returns the zero-based index of the current frame.
do
    local anim = lurek.animation.new()
    anim:addFramesFromGrid(64, 32, 32, 32, 0, 2)
    anim:addClip("pair", { 0, 1 }, 4, true)
    anim:play("pair")
    print("current frame = " .. anim:getCurrentFrame())
end

--@api-stub: LAnimation:setFrame
-- Jumps to a specific frame index within the current clip.
do
    local anim = lurek.animation.new()
    anim:addFramesFromGrid(128, 32, 32, 32, 0, 4)
    anim:addClip("seq", { 0, 1, 2, 3 }, 8, true)
    anim:play("seq")
    anim:setFrame(2)
    print("frame after setFrame = " .. anim:getCurrentFrame())
end

--@api-stub: LAnimation:crossfade
-- Crossfades from the current clip to another over a duration.
do
    local anim = lurek.animation.new()
    anim:addFramesFromGrid(128, 32, 32, 32, 0, 4)
    anim:addClip("idle", { 0, 1 }, 4, true)
    anim:addClip("run", { 2, 3 }, 8, true)
    anim:play("idle")
    anim:crossfade("run", 0.3)
    print("crossfading to run")
end

--@api-stub: LAnimation:getBlendState
-- Returns a table describing the current blend transition state.
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("a", { 0 }, 5, true)
    anim:play("a")
    local bs = anim:getBlendState()
    print("blend state = " .. tostring(bs ~= nil))
end

--@api-stub: LAnimation:drawToImage
-- Renders the current frame to an image of specified dimensions.
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("snap", { 0 }, 1, false)
    anim:play("snap")
    local img = anim:drawToImage(64, 64)
    print("drawn to image = " .. tostring(img ~= nil))
end

--@api-stub: LAnimation:drawPreviewGrid
-- Draws all frames in a grid layout for debugging and preview.
do
    local anim = lurek.animation.new()
    anim:addFramesFromGrid(128, 32, 32, 32, 0, 4)
    anim:drawPreviewGrid(4, 36)
    print("preview grid drawn")
end

--@api-stub: LAnimation:type
-- Returns the type name string "LAnimation".
do
    local anim = lurek.animation.new()
    print("type = " .. anim:type())
end

--@api-stub: LAnimation:typeOf
-- Checks whether this object is of the given type name.
do
    local anim = lurek.animation.new()
    print("is LAnimation = " .. tostring(anim:typeOf("LAnimation")))
end

--@api-stub: LAnimStateMachine:update
-- Advances the state machine by dt, evaluating transitions and updating the animation.
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
-- Returns the name of the current state.
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("stand", { 0 }, 1, true)
    local sm = lurek.animation.newStateMachine(anim, "stand")
    sm:addState("stand", "stand", true)
    print("state = " .. sm:getState())
end

--@api-stub: LAnimStateMachine:forceState
-- Forces an immediate state transition without checking conditions.
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
-- Registers a named state tied to a clip with a looping flag.
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("idle", { 0 }, 5, true)
    local sm = lurek.animation.newStateMachine(anim, "idle")
    sm:addState("idle", "idle", true)
    print("states added")
end

--@api-stub: LAnimStateMachine:addTransition
-- Adds a condition-based transition between two states.
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
-- Sets a parameter value used in transition condition expressions.
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("idle", { 0 }, 5, true)
    local sm = lurek.animation.newStateMachine(anim, "idle")
    sm:addState("idle", "idle", true)
    sm:setParam("speed", 2.5)
    print("params set")
end

--@api-stub: LAnimStateMachine:getQuad
-- Returns the current frame quad from the active state's animation.
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("idle", { 0 }, 5, true)
    local sm = lurek.animation.newStateMachine(anim, "idle")
    sm:addState("idle", "idle", true)
    sm:update(0.0)
    local q = sm:getQuad()
    print("sm quad = " .. tostring(q ~= nil))
end

--@api-stub: LAnimStateMachine:type
-- Returns the type name string "LAnimStateMachine".
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("idle", { 0 }, 5, true)
    local sm = lurek.animation.newStateMachine(anim, "idle")
    print("type = " .. sm:type())
end

--@api-stub: LAnimStateMachine:typeOf
-- Checks whether this object is of the given type name.
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("idle", { 0 }, 5, true)
    local sm = lurek.animation.newStateMachine(anim, "idle")
    print("is LAnimStateMachine = " .. tostring(sm:typeOf("LAnimStateMachine")))
end

--@api-stub: LBlendLayerSet:addLayer
-- Adds a named animation layer with a clip, weight, and optional bone mask.
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("base", "idle", 1.0)
    print("layers added")
end

--@api-stub: LBlendLayerSet:removeLayer
-- Removes a named layer from the blend set.
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("temp", "idle", 1.0)
    bls:removeLayer("temp")
    print("layer removed")
end

--@api-stub: LBlendLayerSet:setWeight
-- Sets the blend weight of a named layer.
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("walk", "walk_clip", 0.5)
    bls:setWeight("walk", 0.8)
    print("weight = " .. bls:getWeight("walk"))
end

--@api-stub: LBlendLayerSet:getWeight
-- Returns the current blend weight of a named layer.
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("run", "run_clip", 0.7)
    local w = bls:getWeight("run")
    print("run weight = " .. w)
end

--@api-stub: LBlendLayerSet:setMask
-- Sets the bone mask for a named layer.
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("arms", "swing", 1.0)
    bls:setMask("arms", { "shoulder_l", "arm_l", "hand_l" })
    print("mask set for arms layer")
end

--- Animation Examples Part 2: Blend Layer Set (cont.), Animation Curve, Sync Group


--@api-stub: LBlendLayerSet:listLayers
-- Returns a table of all layer names in the blend set.
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("base", "idle", 1.0)
    local names = bls:listLayers()
    print("layers = " .. #names)
    print("first layer = " .. tostring(names[1]))
end

--@api-stub: LBlendLayerSet:len
-- Returns the number of layers in the blend set.
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("a", "clip_a", 1.0)
    print("layer count = " .. bls:len())
end

--@api-stub: LBlendLayerSet:type
-- Returns the type name string "LBlendLayerSet".
do
    local bls = lurek.animation.newBlendLayerSet()
    print("type = " .. bls:type())
end

--@api-stub: LBlendLayerSet:typeOf
-- Checks whether this object is of the given type name.
do
    local bls = lurek.animation.newBlendLayerSet()
    print("is LBlendLayerSet = " .. tostring(bls:typeOf("LBlendLayerSet")))
end

--@api-stub: LAnimCurve:addKeyframe
-- Adds a time-value keyframe to the curve.
do
    local curve = lurek.animation.newCurve()
    curve:addKeyframe(0.0, 0.0)
    curve:addKeyframe(0.5, 1.0)
    print("keyframes = " .. curve:keyframeCount())
end

--@api-stub: LAnimCurve:eval
-- Evaluates the curve at a given time, interpolating between keyframes.
do
    local curve = lurek.animation.newCurve()
    curve:addKeyframe(0.0, 0.0)
    curve:addKeyframe(1.0, 10.0)
    local mid = curve:eval(0.5)
    print("value at 0.5 = " .. mid)
end

--@api-stub: LAnimCurve:setEasing
-- Sets the easing mode for interpolation between keyframes.
do
    local curve = lurek.animation.newCurve()
    curve:addKeyframe(0.0, 0.0)
    curve:addKeyframe(1.0, 1.0)
    curve:setEasing("ease_in_out")
    local val = curve:eval(0.5)
    print("eased value at 0.5 = " .. val)
end

--@api-stub: LAnimCurve:keyframeCount
-- Returns the number of keyframes in the curve.
do
    local curve = lurek.animation.newCurve()
    curve:addKeyframe(0.0, 0.0)
    curve:addKeyframe(0.25, 5.0)
    print("keyframe count = " .. curve:keyframeCount())
end

--@api-stub: LAnimCurve:setCustomEasing
-- Sets a custom easing function that maps t (0..1) to an output value.
do
    local curve = lurek.animation.newCurve()
    curve:addKeyframe(0.0, 0.0)
    curve:addKeyframe(1.0, 100.0)
    curve:setCustomEasing(function(t) return t * t end)
    local val = curve:eval(0.5)
    print("custom eased at 0.5 = " .. val)
end

--@api-stub: LAnimCurve:clear
-- Removes all keyframes from the curve.
do
    local curve = lurek.animation.newCurve()
    curve:addKeyframe(0.0, 1.0)
    curve:addKeyframe(1.0, 2.0)
    curve:clear()
    print("after clear, keyframes = " .. curve:keyframeCount())
end

--@api-stub: LAnimCurve:type
-- Returns the type name string "LAnimCurve".
do
    local curve = lurek.animation.newCurve()
    print("type = " .. curve:type())
end

--@api-stub: LAnimCurve:typeOf
-- Checks whether this object is of the given type name.
do
    local curve = lurek.animation.newCurve()
    print("is LAnimCurve = " .. tostring(curve:typeOf("LAnimCurve")))
end

--@api-stub: LAnimSyncGroup:add
-- Adds an animation handle to the sync group.
do
    local sg = lurek.animation.newSyncGroup()
    sg:add(1)
    print("sync group members = " .. sg:memberCount())
end

--@api-stub: LAnimSyncGroup:remove
-- Removes an animation handle from the sync group.
do
    local sg = lurek.animation.newSyncGroup()
    sg:add(1)
    sg:remove(1)
    print("after remove, members = " .. sg:memberCount())
end

--@api-stub: LAnimSyncGroup:clear
-- Removes all members from the sync group.
do
    local sg = lurek.animation.newSyncGroup()
    sg:add(1)
    sg:clear()
    print("after clear, members = " .. sg:memberCount())
end

--@api-stub: LAnimSyncGroup:memberCount
-- Returns the number of animations in the sync group.
do
    local sg = lurek.animation.newSyncGroup()
    sg:add(1)
    print("member count = " .. sg:memberCount())
end

--@api-stub: LAnimSyncGroup:type
-- Returns the type name string "LAnimSyncGroup".
do
    local sg = lurek.animation.newSyncGroup()
    print("type = " .. sg:type())
end

--@api-stub: LAnimSyncGroup:typeOf
-- Checks whether this object is of the given type name.
do
    local sg = lurek.animation.newSyncGroup()
    print("is LAnimSyncGroup = " .. tostring(sg:typeOf("LAnimSyncGroup")))
end

print("content/examples/animation.lua")
