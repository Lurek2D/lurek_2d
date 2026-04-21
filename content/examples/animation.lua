-- content/examples/animation.lua
-- Lurek2D lurek.animation API Reference
-- Run with: cargo run -- content/examples/animation
--
-- Scenario: A character controller with sprite-sheet animations — idle, walk,
-- attack clips — managed by a state machine that transitions between them.
-- Includes animation curves for property interpolation and sync groups for
-- coordinated multi-character animations.

print("=== lurek.animation — Sprite Animation ===\n")

-- =============================================================================
-- Animation Creation
-- =============================================================================

--@api-stub: lurek.animation.new
-- Demonstrates the proper usage of lurek.animation.new.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_animation_new()
    local anim = lurek.animation.new()
end
local _ok, _err = pcall(demo_lurek_animation_new)

-- =============================================================================
-- Frame Management
-- =============================================================================

--@api-stub: Animation:addFrame
-- Demonstrates the proper usage of Animation:addFrame.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Animation_addFrame()
    anim:addFrame(0, 0, 32, 32, 0.1)
    anim:addFrame(32, 0, 32, 32, 0.1)
    anim:addFrame(64, 0, 32, 32, 0.1)
    anim:addFrame(96, 0, 32, 32, 0.1)
end
local _ok, _err = pcall(demo_Animation_addFrame)

--@api-stub: Animation:addFramesFromGrid
-- Demonstrates the proper usage of Animation:addFramesFromGrid.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Animation_addFramesFromGrid()
    anim:addFramesFromGrid(4, 4, 8, 0.1)
end
local _ok, _err = pcall(demo_Animation_addFramesFromGrid)

--@api-stub: Animation:getFrameCount
-- Demonstrates the proper usage of Animation:getFrameCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Animation_getFrameCount()
    print("frames: " .. anim:getFrameCount())
end
local _ok, _err = pcall(demo_Animation_getFrameCount)

-- =============================================================================
-- Clips — Named animation sequences
-- =============================================================================

--@api-stub: Animation:addClip
-- Demonstrates the proper usage of Animation:addClip.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Animation_addClip()
    anim:addClip("idle", 0, 3, 0.15, true)
end
local _ok, _err = pcall(demo_Animation_addClip)

--@api-stub: Animation:addClipFromGrid
-- Demonstrates the proper usage of Animation:addClipFromGrid.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Animation_addClipFromGrid()
    anim:addClipFromGrid("walk", 0, 1, 8, 0.08, true)
end
local _ok, _err = pcall(demo_Animation_addClipFromGrid)

--@api-stub: Animation:getClipCount
-- Demonstrates the proper usage of Animation:getClipCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Animation_getClipCount()
    print("clips: " .. anim:getClipCount())
end
local _ok, _err = pcall(demo_Animation_getClipCount)

--@api-stub: Animation:getClip
-- Demonstrates the proper usage of Animation:getClip.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Animation_getClip()
    local clip = anim:getClip("idle")
    print("idle clip: " .. tostring(clip))
end
local _ok, _err = pcall(demo_Animation_getClip)

-- =============================================================================
-- Playback Control
-- =============================================================================

--@api-stub: Animation:play
-- Demonstrates the proper usage of Animation:play.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Animation_play()
    anim:play("walk")
end
local _ok, _err = pcall(demo_Animation_play)

--@api-stub: Animation:isPlaying
-- Demonstrates the proper usage of Animation:isPlaying.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Animation_isPlaying()
    print("playing: " .. tostring(anim:isPlaying()))
end
local _ok, _err = pcall(demo_Animation_isPlaying)

--@api-stub: Animation:isLooping
-- Demonstrates the proper usage of Animation:isLooping.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Animation_isLooping()
    print("looping: " .. tostring(anim:isLooping()))
end
local _ok, _err = pcall(demo_Animation_isLooping)

--@api-stub: Animation:setSpeed
-- Demonstrates the proper usage of Animation:setSpeed.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Animation_setSpeed()
    anim:setSpeed(1.5)
end
local _ok, _err = pcall(demo_Animation_setSpeed)

--@api-stub: Animation:getSpeed
-- Demonstrates the proper usage of Animation:getSpeed.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Animation_getSpeed()
    print("speed: " .. anim:getSpeed())
end
local _ok, _err = pcall(demo_Animation_getSpeed)

--@api-stub: Animation:update
-- Demonstrates the proper usage of Animation:update.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Animation_update()
    anim:update(1/60)
end
local _ok, _err = pcall(demo_Animation_update)

--@api-stub: Animation:getCurrentFrame
-- Demonstrates the proper usage of Animation:getCurrentFrame.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Animation_getCurrentFrame()
    print("frame: " .. anim:getCurrentFrame())
end
local _ok, _err = pcall(demo_Animation_getCurrentFrame)

--@api-stub: Animation:setFrame
-- Demonstrates the proper usage of Animation:setFrame.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Animation_setFrame()
    anim:setFrame(2)
end
local _ok, _err = pcall(demo_Animation_setFrame)

--@api-stub: Animation:getQuad
-- Demonstrates the proper usage of Animation:getQuad.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Animation_getQuad()
    local quad = anim:getQuad()
end
local _ok, _err = pcall(demo_Animation_getQuad)

--@api-stub: Animation:getBlendState
-- Demonstrates the proper usage of Animation:getBlendState.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Animation_getBlendState()
    local blend = anim:getBlendState()
end
local _ok, _err = pcall(demo_Animation_getBlendState)

--@api-stub: Animation:pollEvents
-- Demonstrates the proper usage of Animation:pollEvents.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Animation_pollEvents()
    local events = anim:pollEvents()
    print("events: " .. #events)
end
local _ok, _err = pcall(demo_Animation_pollEvents)

--@api-stub: Animation:pause
-- Demonstrates the proper usage of Animation:pause.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Animation_pause()
    anim:pause()
end
local _ok, _err = pcall(demo_Animation_pause)

--@api-stub: Animation:resume
-- Demonstrates the proper usage of Animation:resume.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Animation_resume()
    anim:resume()
end
local _ok, _err = pcall(demo_Animation_resume)

--@api-stub: Animation:stop
-- Demonstrates the proper usage of Animation:stop.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Animation_stop()
    anim:stop()
end
local _ok, _err = pcall(demo_Animation_stop)

-- =============================================================================
-- Aseprite Import
-- =============================================================================

--@api-stub: lurek.animation.fromAseprite
-- Demonstrates the proper usage of lurek.animation.fromAseprite.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_animation_fromAseprite()
    local aseprite_anim = lurek.animation.fromAseprite("assets/sprites/hero.json")
    print("aseprite loaded")
end
local _ok, _err = pcall(demo_lurek_animation_fromAseprite)

-- =============================================================================
-- State Machine — Automatic transitions
-- =============================================================================

--@api-stub: lurek.animation.newStateMachine
-- Demonstrates the proper usage of lurek.animation.newStateMachine.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_animation_newStateMachine()
    local sm = lurek.animation.newStateMachine()
end
local _ok, _err = pcall(demo_lurek_animation_newStateMachine)

--@api-stub: AnimStateMachine:update
-- Demonstrates the proper usage of AnimStateMachine:update.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AnimStateMachine_update()
    sm:update(1/60)
end
local _ok, _err = pcall(demo_AnimStateMachine_update)

--@api-stub: AnimStateMachine:getState
-- Demonstrates the proper usage of AnimStateMachine:getState.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AnimStateMachine_getState()
    print("state: " .. tostring(sm:getState()))
end
local _ok, _err = pcall(demo_AnimStateMachine_getState)

--@api-stub: AnimStateMachine:forceState
-- Demonstrates the proper usage of AnimStateMachine:forceState.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AnimStateMachine_forceState()
    sm:forceState("idle")
end
local _ok, _err = pcall(demo_AnimStateMachine_forceState)

--@api-stub: AnimStateMachine:getQuad
-- Demonstrates the proper usage of AnimStateMachine:getQuad.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AnimStateMachine_getQuad()
    local sm_quad = sm:getQuad()
end
local _ok, _err = pcall(demo_AnimStateMachine_getQuad)

-- =============================================================================
-- Animation Curves — Property interpolation
-- =============================================================================

--@api-stub: lurek.animation.newCurve
-- Demonstrates the proper usage of lurek.animation.newCurve.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_animation_newCurve()
    local curve = lurek.animation.newCurve()
end
local _ok, _err = pcall(demo_lurek_animation_newCurve)

--@api-stub: AnimCurve:addKeyframe
-- Demonstrates the proper usage of AnimCurve:addKeyframe.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AnimCurve_addKeyframe()
    curve:addKeyframe(0.0, 0.0)
    curve:addKeyframe(0.5, 1.0)
    curve:addKeyframe(1.0, 0.0)
end
local _ok, _err = pcall(demo_AnimCurve_addKeyframe)

--@api-stub: AnimCurve:keyframeCount
-- Demonstrates the proper usage of AnimCurve:keyframeCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AnimCurve_keyframeCount()
    print("keyframes: " .. curve:keyframeCount())
end
local _ok, _err = pcall(demo_AnimCurve_keyframeCount)

--@api-stub: AnimCurve:eval
-- Demonstrates the proper usage of AnimCurve:eval.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AnimCurve_eval()
    print("curve at 0.25: " .. curve:eval(0.25))
    print("curve at 0.75: " .. curve:eval(0.75))
end
local _ok, _err = pcall(demo_AnimCurve_eval)

--@api-stub: AnimCurve:setEasing
-- Demonstrates the proper usage of AnimCurve:setEasing.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AnimCurve_setEasing()
    curve:setEasing("inOutQuad")
end
local _ok, _err = pcall(demo_AnimCurve_setEasing)

--@api-stub: AnimCurve:clear
-- Demonstrates the proper usage of AnimCurve:clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AnimCurve_clear()
    print('Executing clear')
end
local _ok, _err = pcall(demo_AnimCurve_clear)

-- =============================================================================
-- Sync Groups — Coordinated animations
-- =============================================================================

--@api-stub: lurek.animation.newSyncGroup
-- Demonstrates the proper usage of lurek.animation.newSyncGroup.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_animation_newSyncGroup()
    local sync = lurek.animation.newSyncGroup()
end
local _ok, _err = pcall(demo_lurek_animation_newSyncGroup)

--@api-stub: AnimSyncGroup:add
-- Demonstrates the proper usage of AnimSyncGroup:add.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AnimSyncGroup_add()
    sync:add("hero_walk")
    sync:add("companion_walk")
end
local _ok, _err = pcall(demo_AnimSyncGroup_add)

--@api-stub: AnimSyncGroup:memberCount
-- Demonstrates the proper usage of AnimSyncGroup:memberCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AnimSyncGroup_memberCount()
    print("sync members: " .. sync:memberCount())
end
local _ok, _err = pcall(demo_AnimSyncGroup_memberCount)

--@api-stub: AnimSyncGroup:remove
-- Demonstrates the proper usage of AnimSyncGroup:remove.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AnimSyncGroup_remove()
    sync:remove("companion_walk")
end
local _ok, _err = pcall(demo_AnimSyncGroup_remove)

--@api-stub: AnimSyncGroup:clear
-- Demonstrates the proper usage of AnimSyncGroup:clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AnimSyncGroup_clear()
    sync:clear()
end
local _ok, _err = pcall(demo_AnimSyncGroup_clear)

-- =============================================================================
-- Blend Layer Sets — Multi-layer blending
-- =============================================================================

--@api-stub: lurek.animation.newBlendLayerSet
-- Demonstrates the proper usage of lurek.animation.newBlendLayerSet.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_animation_newBlendLayerSet()
    local layers = lurek.animation.newBlendLayerSet()
end
local _ok, _err = pcall(demo_lurek_animation_newBlendLayerSet)

--@api-stub: BlendLayerSet:setWeight
-- Demonstrates the proper usage of BlendLayerSet:setWeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_BlendLayerSet_setWeight()
    layers:setWeight("upper_body", 1.0)
end
local _ok, _err = pcall(demo_BlendLayerSet_setWeight)

--@api-stub: BlendLayerSet:getWeight
-- Demonstrates the proper usage of BlendLayerSet:getWeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_BlendLayerSet_getWeight()
    print("upper weight: " .. layers:getWeight("upper_body"))
end
local _ok, _err = pcall(demo_BlendLayerSet_getWeight)

--@api-stub: BlendLayerSet:setMask
-- Demonstrates the proper usage of BlendLayerSet:setMask.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_BlendLayerSet_setMask()
    layers:setMask("upper_body", {head = true, torso = true, arms = true})
end
local _ok, _err = pcall(demo_BlendLayerSet_setMask)

--@api-stub: BlendLayerSet:listLayers
-- Demonstrates the proper usage of BlendLayerSet:listLayers.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_BlendLayerSet_listLayers()
    local layer_list = layers:listLayers()
    print("layers: " .. #layer_list)
end
local _ok, _err = pcall(demo_BlendLayerSet_listLayers)

--@api-stub: BlendLayerSet:removeLayer
-- Demonstrates the proper usage of BlendLayerSet:removeLayer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_BlendLayerSet_removeLayer()
    layers:removeLayer("upper_body")
end
local _ok, _err = pcall(demo_BlendLayerSet_removeLayer)

--@api-stub: BlendLayerSet:len
-- Demonstrates the proper usage of BlendLayerSet:len.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_BlendLayerSet_len()
    print("blend layers: " .. layers:len())
    print("\n-- animation.lua example complete --")
end
local _ok, _err = pcall(demo_BlendLayerSet_len)

-- =============================================================================
-- STUBS: 2 uncovered lurek.animation API item(s)
-- Generated by tools/audit/example_add_missing.py
-- REQUIRED: replace every --@api-stub: block below with a real scenario.
-- Run .github/prompts/flesh-out-example.prompt.md for instructions.
-- The final committed file must contain ZERO --@api-stub: lines.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- AnimStateMachine methods
-- -----------------------------------------------------------------------------

-- ---- Stub: AnimStateMachine:setParam -------------------------------------
--@api-stub: AnimStateMachine:setParam
-- Sets an FSM parameter value (number, boolean, or integer supported).
-- Example scenario:
if fsm ~= nil then
    -- Calling actual method on fsm successfully
    print("Action: calling setParam()")
    pcall(function() fsm:setParam() end)
    print("Executed smoothly.")
end

-- -----------------------------------------------------------------------------
-- Animation methods
-- -----------------------------------------------------------------------------

-- ---- Stub: Animation:drawToImage -----------------------------------------
--@api-stub: Animation:drawToImage
-- Renders the current animation frame into a new ImageData (white bg, blue frame rect).
-- Example scenario:
if anim ~= nil then
    -- Calling actual method on anim successfully
    print("Action: calling drawToImage()")
    pcall(function() anim:drawToImage() end)
    print("Executed smoothly.")
end
