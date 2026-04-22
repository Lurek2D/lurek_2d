-- content/examples/animation.lua
-- love2d-style usage snippets for the lurek.animation API (45 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/animation.lua

-- ── lurek.animation.* functions ──

--@api-stub: lurek.animation.new
-- Creates a new, empty Animation controller.
-- Build once at startup; reuse across frames.
local obj = lurek.animation.new()
print("created", obj)
return obj

--@api-stub: lurek.animation.fromAseprite
-- Parses an Aseprite JSON export string and builds an Animation with clips and frames.
-- Build once at startup; reuse across frames.
local fromaseprite = lurek.animation.fromAseprite("hello")
print("created", fromaseprite)
return fromaseprite

--@api-stub: lurek.animation.newStateMachine
-- Creates an animation FSM from an Animation controller and an initial state name.
-- Build once at startup; reuse across frames.
local statemachine = lurek.animation.newStateMachine(anim_ud, initial)
print("created", statemachine)
return statemachine

--@api-stub: lurek.animation.newCurve
-- Creates a new empty [`AnimCurve`] with linear interpolation.
-- Build once at startup; reuse across frames.
local curve = lurek.animation.newCurve()
print("created", curve)
return curve

--@api-stub: lurek.animation.newSyncGroup
-- Creates a new empty [`AnimSyncGroup`].
-- Build once at startup; reuse across frames.
local syncgroup = lurek.animation.newSyncGroup()
print("created", syncgroup)
return syncgroup

--@api-stub: lurek.animation.newBlendLayerSet
-- Creates a new empty [`BlendLayerSet`] for compositing multiple animation clips.
-- Build once at startup; reuse across frames.
local blendlayerset = lurek.animation.newBlendLayerSet()
print("created", blendlayerset)
return blendlayerset

-- ── Animation methods ──

--@api-stub: Animation:addFrame
-- Adds a single frame to the frame pool by source rectangle.
-- Side-effecting; safe to call any time after init.
local animation = lurek.animation.newAnimation()
animation:addFrame(100, 100, 64, 64)
print("Animation:addFrame done")

--@api-stub: Animation:play
-- Starts playback of the named clip.
-- Trigger from input, timers, or game events.
local animation = lurek.animation.newAnimation()
animation:play("main")
-- trigger from input, timer, or event
print("ok")

--@api-stub: Animation:stop
-- Stops playback and resets to frame 0.
-- Trigger from input, timers, or game events.
local animation = lurek.animation.newAnimation()
animation:stop()
-- trigger from input, timer, or event
print("ok")

--@api-stub: Animation:pause
-- Pauses playback at the current frame.
-- Trigger from input, timers, or game events.
local animation = lurek.animation.newAnimation()
animation:pause()
-- trigger from input, timer, or event
print("ok")

--@api-stub: Animation:resume
-- Resumes playback from the current frame.
-- Trigger from input, timers, or game events.
local animation = lurek.animation.newAnimation()
animation:resume()
-- trigger from input, timer, or event
print("ok")

--@api-stub: Animation:update
-- Advances the animation by dt seconds.
-- Apply at startup or in response to user input.
local animation = lurek.animation.newAnimation()
animation:update(dt)
print("Animation:update applied")

--@api-stub: Animation:getQuad
-- Returns the source quad (x, y, w, h) for the current frame, or nil.
-- Cheap to call; safe inside callbacks.
local animation = lurek.animation.newAnimation()  -- or your existing handle
local value = animation:getQuad()
print("Animation:getQuad ->", value)

--@api-stub: Animation:pollEvents
-- Drains and returns all pending animation events as a table.
-- See the module spec for detailed semantics.
local animation = lurek.animation.newAnimation()
animation:pollEvents()
print("Animation:pollEvents done")

--@api-stub: Animation:isPlaying
-- Returns true if a clip is currently playing.
-- Use as a guard inside lurek.update or event handlers.
local animation = lurek.animation.newAnimation()
if animation:isPlaying() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Animation:isLooping
-- Returns true if the current clip is set to loop.
-- Use as a guard inside lurek.update or event handlers.
local animation = lurek.animation.newAnimation()
if animation:isLooping() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Animation:getClip
-- Returns the name of the currently playing clip, or nil.
-- Cheap to call; safe inside callbacks.
local animation = lurek.animation.newAnimation()  -- or your existing handle
local value = animation:getClip()
print("Animation:getClip ->", value)

--@api-stub: Animation:getSpeed
-- Returns the playback speed multiplier.
-- Cheap to call; safe inside callbacks.
local animation = lurek.animation.newAnimation()  -- or your existing handle
local value = animation:getSpeed()
print("Animation:getSpeed ->", value)

--@api-stub: Animation:setSpeed
-- Sets the playback speed multiplier.
-- Apply at startup or in response to user input.
local animation = lurek.animation.newAnimation()
animation:setSpeed(speed)
print("Animation:setSpeed applied")

--@api-stub: Animation:getFrameCount
-- Returns the total number of frames in the frame pool.
-- Cheap to call; safe inside callbacks.
local animation = lurek.animation.newAnimation()  -- or your existing handle
local value = animation:getFrameCount()
print("Animation:getFrameCount ->", value)

--@api-stub: Animation:getClipCount
-- Returns the number of registered clips.
-- Cheap to call; safe inside callbacks.
local animation = lurek.animation.newAnimation()  -- or your existing handle
local value = animation:getClipCount()
print("Animation:getClipCount ->", value)

--@api-stub: Animation:getCurrentFrame
-- Returns the current position within the active clip (0-based).
-- Cheap to call; safe inside callbacks.
local animation = lurek.animation.newAnimation()  -- or your existing handle
local value = animation:getCurrentFrame()
print("Animation:getCurrentFrame ->", value)

--@api-stub: Animation:setFrame
-- Sets the playback position within the current clip.
-- Apply at startup or in response to user input.
local animation = lurek.animation.newAnimation()
animation:setFrame(1)
print("Animation:setFrame applied")

--@api-stub: Animation:getBlendState
-- Returns the two quads and blend factor during a crossfade, or nil when not blending.
-- Cheap to call; safe inside callbacks.
local animation = lurek.animation.newAnimation()  -- or your existing handle
local value = animation:getBlendState()
print("Animation:getBlendState ->", value)

--@api-stub: Animation:drawToImage
-- Renders the current animation frame into a new ImageData (white bg, blue frame rect).
-- Place inside `function lurek.render() ... end`.
local animation = lurek.animation.newAnimation()
animation:drawToImage(64, 64)
print("Animation:drawToImage done")

-- ── AnimStateMachine methods ──

--@api-stub: AnimStateMachine:update
-- Advances the FSM by `dt` seconds, evaluating transitions.
-- Apply at startup or in response to user input.
local animStateMachine = lurek.animation.newAnimStateMachine()
animStateMachine:update(dt)
print("AnimStateMachine:update applied")

--@api-stub: AnimStateMachine:getState
-- Returns the name of the currently active state.
-- Cheap to call; safe inside callbacks.
local animStateMachine = lurek.animation.newAnimStateMachine()  -- or your existing handle
local value = animStateMachine:getState()
print("AnimStateMachine:getState ->", value)

--@api-stub: AnimStateMachine:forceState
-- Immediately jumps to the named state, bypassing transition conditions.
-- See the module spec for detailed semantics.
local animStateMachine = lurek.animation.newAnimStateMachine()
animStateMachine:forceState("main")
print("AnimStateMachine:forceState done")

--@api-stub: AnimStateMachine:setParam
-- Sets an FSM parameter value (number, boolean, or integer supported).
-- Apply at startup or in response to user input.
local animStateMachine = lurek.animation.newAnimStateMachine()
animStateMachine:setParam("main", value)
print("AnimStateMachine:setParam applied")

--@api-stub: AnimStateMachine:getQuad
-- Returns the source quad for the current animation frame, or nil.
-- Cheap to call; safe inside callbacks.
local animStateMachine = lurek.animation.newAnimStateMachine()  -- or your existing handle
local value = animStateMachine:getQuad()
print("AnimStateMachine:getQuad ->", value)

-- ── BlendLayerSet methods ──

--@api-stub: BlendLayerSet:removeLayer
-- Removes a blend layer by name.
-- Pair with the matching constructor to free resources.
local blendLayerSet = lurek.animation.newBlendLayerSet()
blendLayerSet:removeLayer("main")
-- blendLayerSet is now released
print("ok")

--@api-stub: BlendLayerSet:setWeight
-- Sets the blend weight of a named layer (clamped to [0, 1]).
-- Apply at startup or in response to user input.
local blendLayerSet = lurek.animation.newBlendLayerSet()
blendLayerSet:setWeight("main", weight)
print("BlendLayerSet:setWeight applied")

--@api-stub: BlendLayerSet:getWeight
-- Returns the blend weight of a named layer, or nil if not found.
-- Cheap to call; safe inside callbacks.
local blendLayerSet = lurek.animation.newBlendLayerSet()  -- or your existing handle
local value = blendLayerSet:getWeight("main")
print("BlendLayerSet:getWeight ->", value)

--@api-stub: BlendLayerSet:setMask
-- Replaces the bone mask of a layer.
-- Apply at startup or in response to user input.
local blendLayerSet = lurek.animation.newBlendLayerSet()
blendLayerSet:setMask("main", bones)
print("BlendLayerSet:setMask applied")

--@api-stub: BlendLayerSet:listLayers
-- Returns an ordered array of layer info tables: {name, clip_name, weight, bones}.
-- See the module spec for detailed semantics.
local blendLayerSet = lurek.animation.newBlendLayerSet()
blendLayerSet:listLayers()
print("BlendLayerSet:listLayers done")

--@api-stub: BlendLayerSet:len
-- Returns the number of blend layers.
-- See the module spec for detailed semantics.
local blendLayerSet = lurek.animation.newBlendLayerSet()
blendLayerSet:len()
print("BlendLayerSet:len done")

-- ── AnimCurve methods ──

--@api-stub: AnimCurve:addKeyframe
-- Inserts a keyframe at the given time.
-- Side-effecting; safe to call any time after init.
local animCurve = lurek.animation.newAnimCurve()
animCurve:addKeyframe(t, v)
print("AnimCurve:addKeyframe done")

--@api-stub: AnimCurve:eval
-- Returns the interpolated value at the given time using the curve's easing.
-- See the module spec for detailed semantics.
local animCurve = lurek.animation.newAnimCurve()
animCurve:eval(t)
print("AnimCurve:eval done")

--@api-stub: AnimCurve:setEasing
-- Sets the easing kind applied between all keyframe segments.
-- Apply at startup or in response to user input.
local animCurve = lurek.animation.newAnimCurve()
animCurve:setEasing(mode)
print("AnimCurve:setEasing applied")

--@api-stub: AnimCurve:keyframeCount
-- Returns the number of keyframes currently stored.
-- See the module spec for detailed semantics.
local animCurve = lurek.animation.newAnimCurve()
animCurve:keyframeCount()
print("AnimCurve:keyframeCount done")

--@api-stub: AnimCurve:clear
-- Removes all keyframes from this animation curve, resetting it to empty.
-- Pair with the matching constructor to free resources.
local animCurve = lurek.animation.newAnimCurve()
animCurve:clear()
-- animCurve is now released
print("ok")

-- ── AnimSyncGroup methods ──

--@api-stub: AnimSyncGroup:add
-- Adds an animation handle to the group.
-- Side-effecting; safe to call any time after init.
local animSyncGroup = lurek.animation.newAnimSyncGroup()
animSyncGroup:add(handle)
print("AnimSyncGroup:add done")

--@api-stub: AnimSyncGroup:remove
-- Removes an animation handle from the group.
-- Pair with the matching constructor to free resources.
local animSyncGroup = lurek.animation.newAnimSyncGroup()
animSyncGroup:remove(handle)
-- animSyncGroup is now released
print("ok")

--@api-stub: AnimSyncGroup:clear
-- Removes all animation handles from the group.
-- Pair with the matching constructor to free resources.
local animSyncGroup = lurek.animation.newAnimSyncGroup()
animSyncGroup:clear()
-- animSyncGroup is now released
print("ok")

--@api-stub: AnimSyncGroup:memberCount
-- Returns the number of animations currently in the group.
-- See the module spec for detailed semantics.
local animSyncGroup = lurek.animation.newAnimSyncGroup()
animSyncGroup:memberCount()
print("AnimSyncGroup:memberCount done")

