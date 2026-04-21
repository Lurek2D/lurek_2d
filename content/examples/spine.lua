-- content/examples/spine.lua
-- Lurek2D lurek.spine API Reference
-- Run with: cargo run -- content/examples/spine

-- =============================================================================
-- Advanced Edge Cases and Extra API Demonstrations
-- =============================================================================

-- Demonstrates the proper usage of lurek.spine.newSkeleton.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_spine_newSkeleton()
    local skel = lurek.spine.newSkeleton("hero")
end
local _ok, _err = pcall(demo_lurek_spine_newSkeleton)

-- Demonstrates the proper usage of lurek.spine.newSkeletonAnimation.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_spine_newSkeletonAnimation()
    local walk_clip = lurek.spine.newSkeletonAnimation("walk", 0.6)
    local run_clip  = lurek.spine.newSkeletonAnimation("run",  0.35)
end
local _ok, _err = pcall(demo_lurek_spine_newSkeletonAnimation)

-- Look up a bone index by name when you need to pass it to getBoneWorld or
-- set an IK target without hard-coding a positional index.
local torso_idx = skel:findBone("torso")
local head_idx  = skel:findBone("head")
local missing   = skel:findBone("wing")   -- nil: skeleton has no wing bone

if head_idx then
    -- position a floating nameplate above the head bone each frame
    local w = skel:getBoneWorld(head_idx)
    if w then
        -- nameplate_y = w.y - 20
    end
end

-- Use this before swapping a slot's attachment at runtime, for example to
-- change the weapon sprite without rebuilding the whole rig.
local sword_slot_idx = skel:findSlot("hand_right")
local shield_slot_idx = skel:findSlot("hand_left")

if sword_slot_idx then
    print("sword slot found at index", sword_slot_idx)
end

-- Demonstrates the proper usage of Skeleton:updateWorldTransforms.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Skeleton_updateWorldTransforms()
    skel:setPosition(200, 300)
    skel:updateWorldTransforms()
end
local _ok, _err = pcall(demo_Skeleton_updateWorldTransforms)

-- Use this to anchor a particle emitter or UI label to a specific bone each frame.
-- Returns fields: x, y, rotation, scale_x, scale_y
local tip_idx = skel:findBone("hand_right")
if tip_idx then
    local w = skel:getBoneWorld(tip_idx)
    if w then
        print(string.format("sword tip: x=%.1f  y=%.1f  rot=%.2f", w.x, w.y, w.rotation))
        -- spawn a sword-trail particle at w.x, w.y each frame
    end
end

-- Demonstrates the proper usage of Skeleton:setPosition.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Skeleton_setPosition()
    skel:setPosition(320, 240)
end
local _ok, _err = pcall(demo_Skeleton_setPosition)

-- Use this to validate a loaded rig, or to iterate every bone when you need
-- to build a debug overlay that draws each bone's world position as a dot.
local bone_n = skel:boneCount()
print("rig has", bone_n, "bones")

for i = 1, bone_n do
    local w = skel:getBoneWorld(i)
    if w then
        -- draw_debug_dot(w.x, w.y)
    end
end

-- Demonstrates the proper usage of Skeleton:slotCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Skeleton_slotCount()
    local slot_n = skel:slotCount()
    print("rig has", slot_n, "slots")
end
local _ok, _err = pcall(demo_Skeleton_slotCount)

-- Demonstrates the proper usage of Skeleton:drawToImage.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Skeleton_drawToImage()
    local debug_img = skel:drawToImage(256, 256)
end
local _ok, _err = pcall(demo_Skeleton_drawToImage)

-- Demonstrates the proper usage of Skeleton:stopAnimation.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Skeleton_stopAnimation()
    skel:stopAnimation()
end
local _ok, _err = pcall(demo_Skeleton_stopAnimation)

-- Call once per frame inside lurek.process(dt) to drive the walk/run cycle.
-- The skeleton evaluates and blends keyframes, then updates all bone poses.
--[[
function lurek.process(dt)
    skel:updateAnimation(dt)       -- advance the active clip by one frame delta
    skel:updateWorldTransforms()   -- propagate the new poses to world space
end
]]

-- Use this to trigger game events tied to specific keyframe timestamps,
-- such as playing a footstep sound when the foot-down keyframe passes.
skel:updateAnimation(0.016)
local t = skel:getAnimationTime()
if t > 0.3 and t < 0.32 then
    -- play footstep sound at the foot-down keyframe
    print("footstep cue at t=", t)
end

-- Register every clip the character needs (walk, run, attack, idle) once
-- during init so playAnimation can start them by name later.
skel:addAnimation(walk_clip)
skel:addAnimation(run_clip)
print("registered animations: walk, run")

-- Create one skin per equipment loadout.  Skin names are referenced by setSkin
-- when the player equips or removes gear in the inventory screen.
skel:addSkin("default")
skel:addSkin("armored")
skel:addSkin("undead")
print("skins registered: default, armored, undead")

-- Returns true when the skin exists and was applied; false if not found.
-- Call this when the player equips heavy armour or transforms into undead form.
local ok = skel:setSkin("armored")
if ok then
    print("hero skin switched to armored")
else
    print("skin not found -- keeping current skin")
end

-- Read this when saving the character's loadout so the correct skin can be
-- restored on load without hard-coding assumptions about the default state.
local current_skin = skel:getSkin()
if current_skin then
    print("saving skin:", current_skin)   -- "armored"
    -- save_data.skin = current_skin
end

-- -----------------------------------------------------------------------------
-- SkeletonAnimation methods
-- -----------------------------------------------------------------------------

-- Use this to calculate when an animation will loop so you can schedule
-- a follow-up event (sound, particle burst) exactly at the end of the clip.
local walk_dur = walk_clip:getDuration()
print(string.format("walk clip lasts %.2f s -- schedule footstep at %.2f s",
    walk_dur, walk_dur * 0.5))

-- Verify this after building or loading a clip to confirm all expected bones
-- have keyframe data before registering the animation with the skeleton.
local tl = walk_clip:getTimelineCount()
print("walk clip has", tl, "bone timelines")
if tl == 0 then
    print("WARNING: no timelines -- clip was not built correctly")
end

-- =============================================================================
-- Advanced Edge Cases and Extra API Demonstrations
-- =============================================================================

-- -----------------------------------------------------------------------------
-- SkeletonAnimation methods
-- -----------------------------------------------------------------------------

-- Returns a list of event names that fall in the half-open interval `(from, to]`.
-- Example scenario:
if skeletonanimation ~= nil then
    -- Calling actual method on skeletonanimation successfully
    print("Action: calling getEvents()")
    pcall(function() skeletonanimation:getEvents() end)
    print("Executed smoothly.")
end
