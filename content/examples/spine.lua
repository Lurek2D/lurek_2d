-- content/examples/spine.lua
-- love2d-style usage snippets for the lurek.spine API (20 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/spine.lua

-- ── lurek.spine.* functions ──

--@api-stub: lurek.spine.newSkeleton
-- Creates a new empty skeleton with the given name.
-- Build once at startup; reuse across frames.
local skeleton = lurek.spine.newSkeleton("main")
print("created", skeleton)
return skeleton

--@api-stub: lurek.spine.newSkeletonAnimation
-- Creates a new empty SkeletonAnimation clip with the given name and duration.
-- Build once at startup; reuse across frames.
local skeletonanimation = lurek.spine.newSkeletonAnimation("main", 1.0)
print("created", skeletonanimation)
return skeletonanimation

-- ── Skeleton methods ──

--@api-stub: Skeleton:findBone
-- Returns the index of the named bone, or nil if not found.
-- Cheap to call; safe inside callbacks.
local skeleton = lurek.spine.newSkeleton()  -- or your existing handle
local value = skeleton:findBone("main")
print("Skeleton:findBone ->", value)

--@api-stub: Skeleton:findSlot
-- Returns the index of the named slot, or nil if not found.
-- Cheap to call; safe inside callbacks.
local skeleton = lurek.spine.newSkeleton()  -- or your existing handle
local value = skeleton:findSlot("main")
print("Skeleton:findSlot ->", value)

--@api-stub: Skeleton:updateWorldTransforms
-- Propagates local transforms down the bone hierarchy to compute world positions.
-- Apply at startup or in response to user input.
local skeleton = lurek.spine.newSkeleton()
skeleton:updateWorldTransforms()
print("Skeleton:updateWorldTransforms applied")

--@api-stub: Skeleton:getBoneWorld
-- Returns the world-space transform of a bone as a table, or nil if out of range.
-- Cheap to call; safe inside callbacks.
local skeleton = lurek.spine.newSkeleton()  -- or your existing handle
local value = skeleton:getBoneWorld(1)
print("Skeleton:getBoneWorld ->", value)

--@api-stub: Skeleton:setPosition
-- Sets the root bone position and propagates world transforms.
-- Apply at startup or in response to user input.
local skeleton = lurek.spine.newSkeleton()
skeleton:setPosition(100, 100)
print("Skeleton:setPosition applied")

--@api-stub: Skeleton:boneCount
-- Returns the total number of bones.
-- See the module spec for detailed semantics.
local skeleton = lurek.spine.newSkeleton()
skeleton:boneCount()
print("Skeleton:boneCount done")

--@api-stub: Skeleton:slotCount
-- Returns the total number of slots.
-- See the module spec for detailed semantics.
local skeleton = lurek.spine.newSkeleton()
skeleton:slotCount()
print("Skeleton:slotCount done")

--@api-stub: Skeleton:drawToImage
-- Renders the skeleton as a stick-figure debug view into a new ImageData.
-- Place inside `function lurek.render() ... end`.
local skeleton = lurek.spine.newSkeleton()
skeleton:drawToImage(64, 64)
print("Skeleton:drawToImage done")

--@api-stub: Skeleton:stopAnimation
-- Stops the current skeletal animation.
-- Trigger from input, timers, or game events.
local skeleton = lurek.spine.newSkeleton()
skeleton:stopAnimation()
-- trigger from input, timer, or event
print("ok")

--@api-stub: Skeleton:updateAnimation
-- Advances the playing animation by `dt` seconds and applies keyframes.
-- Apply at startup or in response to user input.
local skeleton = lurek.spine.newSkeleton()
skeleton:updateAnimation(dt)
print("Skeleton:updateAnimation applied")

--@api-stub: Skeleton:getAnimationTime
-- Returns the current playback time in seconds of the active animation.
-- Cheap to call; safe inside callbacks.
local skeleton = lurek.spine.newSkeleton()  -- or your existing handle
local value = skeleton:getAnimationTime()
print("Skeleton:getAnimationTime ->", value)

--@api-stub: Skeleton:addAnimation
-- Adds a SkeletonAnimation to this skeleton's library.
-- Side-effecting; safe to call any time after init.
local skeleton = lurek.spine.newSkeleton()
skeleton:addAnimation(anim_ud)
print("Skeleton:addAnimation done")

--@api-stub: Skeleton:addSkin
-- Registers a new empty skin by name.
-- Side-effecting; safe to call any time after init.
local skeleton = lurek.spine.newSkeleton()
skeleton:addSkin("main")
print("Skeleton:addSkin done")

--@api-stub: Skeleton:setSkin
-- Activates the named skin for attachment lookups.
-- Apply at startup or in response to user input.
local skeleton = lurek.spine.newSkeleton()
skeleton:setSkin("main")
print("Skeleton:setSkin applied")

--@api-stub: Skeleton:getSkin
-- Returns the name of the currently active skin, or nil.
-- Cheap to call; safe inside callbacks.
local skeleton = lurek.spine.newSkeleton()  -- or your existing handle
local value = skeleton:getSkin()
print("Skeleton:getSkin ->", value)

-- ── SkeletonAnimation methods ──

--@api-stub: SkeletonAnimation:getDuration
-- Returns the total duration of the animation in seconds.
-- Cheap to call; safe inside callbacks.
local skeletonAnimation = lurek.spine.newSkeletonAnimation()  -- or your existing handle
local value = skeletonAnimation:getDuration()
print("SkeletonAnimation:getDuration ->", value)

--@api-stub: SkeletonAnimation:getEvents
-- Returns a list of event names that fall in the half-open interval `(from, to]`.
-- Cheap to call; safe inside callbacks.
local skeletonAnimation = lurek.spine.newSkeletonAnimation()  -- or your existing handle
local value = skeletonAnimation:getEvents(from, to)
print("SkeletonAnimation:getEvents ->", value)

--@api-stub: SkeletonAnimation:getTimelineCount
-- Returns the number of bone timelines in this animation.
-- Cheap to call; safe inside callbacks.
local skeletonAnimation = lurek.spine.newSkeletonAnimation()  -- or your existing handle
local value = skeletonAnimation:getTimelineCount()
print("SkeletonAnimation:getTimelineCount ->", value)

