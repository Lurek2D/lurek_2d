# Spine

- The `spine` module is an advanced Feature Systems tier component that provides a complete, high-performance runtime for 2D skeletal animation.

Moving beyond traditional frame-by-frame sprites, this module enables fluid, dynamic animations using hierarchical bone trees and slot-based attachments. Central to the system is the `Skeleton` struct, which maintains an ordered array of `Bone` elements. Each bone stores local transform properties (position, rotation, scale) and automatically computes accumulated world-space transforms as they propagate down the parent-child hierarchy. Visual representation is handled via `Slot` attachments, which bind graphical content—such as sprite regions, meshes, or bounding boxes—to specific bones with precise draw-order and blend-mode configurations, ensuring correct back-to-front rendering even in complex layered characters.

To achieve sophisticated, procedural motion, the module features a dedicated Inverse Kinematics (IK) system. The `IKConstraint` solver calculates the necessary joint rotations for a two-bone chain (e.g., an arm or leg) to reach a specific world-space target, vastly simplifying dynamic interactions like foot placement on uneven terrain or aiming weapons. The animation pipeline itself is driven by `SkeletonAnimation` clips, which organize multiple `BoneTimeline` and `SlotTimeline` sequences containing keyed property changes. The runtime efficiently interpolates between these keyframes using various easing curves (linear, stepped, bezier) and applies the resulting poses to the skeleton. Animations can be blended together using configurable weights, allowing for smooth transitions between states (like transitioning from a run cycle to a jump).

The module also supports extensive customization and event handling. The Skin system allows developers to group specific slot attachments into switchable visual sets, enabling character customization (e.g., changing armor or weapons) without duplicating the underlying animation rig. Furthermore, `EventKeyframe` markers can be embedded within timelines to trigger Lua callbacks at precise moments, perfect for syncing footstep audio or hit-box activation. Fully exposed through the `lurek.spine.*` API, this module provides the robust tooling necessary to bring complex, expressive, and interactive 2D characters to life.

## Functions

### `lurek.spine.animationFromJson`

Parses a JSON string into a SkeletonAnimation. Returns nil if parsing fails or the format is invalid.

```lua
-- signature
lurek.spine.animationFromJson(json)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `json` | `string` | JSON string describing the animation (Spine-compatible format). |

**Returns**

| Type | Description |
|------|-------------|
| `LSkeletonAnimation` | Parsed animation userdata, or nil on failure. |

**Example**

```lua
do
    local jsonData = '{"name":"idle_bounce","duration":1.2,"timelines":[{"bone":0,"property":"y","keys":[{"time":0,"value":0},{"time":1.2,"value":0}]}]}'
    local anim = lurek.spine.animationFromJson(jsonData)
    print("timelines = " .. (anim and tostring(anim:getTimelineCount()) or "nil"))
end
```

---

### `lurek.spine.newSkeleton`

Creates a new empty skeleton with the given name. Add bones and slots to build the hierarchy.

```lua
-- signature
lurek.spine.newSkeleton(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Name identifier for this skeleton. |

**Returns**

| Type | Description |
|------|-------------|
| `LSkeleton` | A new skeleton userdata. |

**Example**

```lua
do
    ---@type LSkeleton
    local skel = lurek.spine.newSkeleton("hero")
    print("type = " .. skel:type())
    print("bone count = " .. skel:boneCount())
    print("slot count = " .. skel:slotCount())
end
```

---

### `lurek.spine.newSkeletonAnimation`

Creates a new empty animation with the given name and duration. Add keyframes to define motion.

```lua
-- signature
lurek.spine.newSkeletonAnimation(name, duration)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Name identifier for this animation (used with playAnimation). |
| `duration` | `number` | Total duration of the animation in seconds. |

**Returns**

| Type | Description |
|------|-------------|
| `LSkeletonAnimation` | A new animation userdata. |

**Example**

```lua
do
    local anim = lurek.spine.newSkeletonAnimation("walk_cycle", 0.8)
    print("type = " .. anim:type())
    print("duration = " .. anim:getDuration())
    print("timelines = " .. anim:getTimelineCount())
end
```

---

## LSkeleton

### `LSkeleton:addAnimation`

Registers a SkeletonAnimation object with this skeleton so it can be played by name.

```lua
-- signature
LSkeleton:addAnimation(anim)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `anim` | `LSkeletonAnimation` | The animation userdata to register. Consumed by this call. |

**Example**

```lua
do
    local skel = lurek.spine.newSkeleton("animated")
    skel:addBone("root")
    skel:addAnimation(lurek.spine.newSkeletonAnimation("idle", 1.0))
    print("animation time = " .. skel:getAnimationTime())
end
```

---

### `LSkeleton:addBone`

Adds a root-level bone to the skeleton with optional transform properties.

```lua
-- signature
LSkeleton:addBone(name, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Unique name for this bone. |
| `opts?` | `table` | Optional table with keys: x, y, rotation, scale_x, scale_y. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Zero-based index of the newly added bone. |

**Example**

```lua
do
    ---@type LSkeleton
    local skel = lurek.spine.newSkeleton("character")
    local root = skel:addBone("root", { x = 0, y = 0, rotation = 0, scale_x = 1, scale_y = 1 })
    print("root bone index = " .. root)
end
```

---

### `LSkeleton:addChildBone`

Adds a bone as a child of an existing bone, inheriting its parent's world transform.

```lua
-- signature
LSkeleton:addChildBone(name, parent_idx, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Unique name for this bone. |
| `parent_idx` | `number` | Zero-based index of the parent bone. |
| `opts?` | `table` | Optional table with keys: x, y, rotation, scale_x, scale_y (local offsets from parent). |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Zero-based index of the newly added child bone. |

**Example**

```lua
do
    ---@type LSkeleton
    local skel = lurek.spine.newSkeleton("character")
    local root = skel:addBone("root", { x = 0, y = 0, rotation = 0, scale_x = 1, scale_y = 1 })
    local spine_bone = skel:addChildBone("spine", root, { x = 0, y = -20 })
    print("spine bone index = " .. spine_bone)
end
```

---

### `LSkeleton:addIKConstraint`

Adds an inverse-kinematics constraint that controls a chain of bones to reach a target position.

```lua
-- signature
LSkeleton:addIKConstraint(name, chain, bend_positive)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Unique name for this IK constraint (used with setIKTarget). |
| `chain` | `table` | Array of bone indices forming the IK chain from root to tip. |
| `bend_positive?` | `boolean` | Whether the joint bends in the positive direction. Defaults to true. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Index of the newly added constraint. |

**Example**

```lua
do
    local skel = lurek.spine.newSkeleton("ik_demo")
    local root = skel:addBone("root")
    local upper = skel:addChildBone("upper_arm", root, { x = 20 })
    local lower = skel:addChildBone("lower_arm", upper, { x = 20 })
    print("ik constraint id = " .. skel:addIKConstraint("arm_ik", { upper, lower }, true))
end
```

---

### `LSkeleton:addSkin`

Registers a new named skin on this skeleton. Skins remap slot attachments for visual variants.

```lua
-- signature
LSkeleton:addSkin(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Unique name for the skin. |

**Example**

```lua
do
    local skel = lurek.spine.newSkeleton("skinned")
    skel:addBone("root")
    skel:addSkin("default")
    print("skin added")
end
```

---

### `LSkeleton:addSlot`

Adds a slot attached to a specific bone, optionally assigning a default attachment name.

```lua
-- signature
LSkeleton:addSlot(name, bone_idx, attachment)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Unique name for this slot. |
| `bone_idx` | `number` | Zero-based index of the bone this slot is attached to. |
| `attachment?` | `string` | Optional default attachment name for this slot. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Zero-based index of the newly added slot. |

**Example**

```lua
do
    local skel = lurek.spine.newSkeleton("slotted")
    local bone = skel:addBone("torso", { y = -10 })
    print("body slot = " .. skel:addSlot("body_slot", bone, "body_image"))
    print("slot count = " .. skel:slotCount())
end
```

---

### `LSkeleton:blendAnimation`

Blends an animation pose onto the skeleton at a given time with a weight factor for smooth transitions.

```lua
-- signature
LSkeleton:blendAnimation(anim, time, blend_weight)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `anim` | `LSkeletonAnimation` | The animation to sample and blend from. |
| `time` | `number` | The time position to sample within the animation. |
| `blend_weight?` | `number` | Blend factor from 0.0 (no effect) to 1.0 (full). Defaults to 1.0. |

**Example**

```lua
do
    local skel = lurek.spine.newSkeleton("animated")
    skel:addBone("root")
    skel:addAnimation(lurek.spine.newSkeletonAnimation("idle", 1.0))
    skel:playAnimation("idle", true)
    local run = lurek.spine.newSkeletonAnimation("run", 0.5)
    run:addKeyframe(0, "x", 0.0, 0)
    run:addKeyframe(0, "x", 0.5, 10)
    skel:updateAnimation(0.2)
    skel:blendAnimation(run, 0.25, 0.5)
    print("blended run")
end
```

---

### `LSkeleton:boneCount`

Returns the total number of bones in the skeleton.

```lua
-- signature
LSkeleton:boneCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Bone count. |

**Example**

```lua
do
    local skel = lurek.spine.newSkeleton("hero")
    skel:addBone("root", {})
    skel:addBone("arm", {})
    print("bones = " .. skel:boneCount())
end
```

---

### `LSkeleton:drawToImage`

Renders the skeleton into an in-memory image of the given dimensions and returns it as LImageData userdata.

```lua
-- signature
LSkeleton:drawToImage(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | `number` | Width of the output image in pixels. |
| `h` | `number` | Height of the output image in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| `LImageData` | A new image data object containing the rendered skeleton. |

**Example**

```lua
do
    local skel = lurek.spine.newSkeleton("render_test")
    local root = skel:addBone("root", { x = 64, y = 64 })
    skel:addChildBone("body", root, { y = -20 })
    skel:updateWorldTransforms()
    local img = skel:drawToImage(128, 128)
    print("image size = " .. img:getWidth() .. "x" .. img:getHeight())
end
```

---

### `LSkeleton:findBone`

Searches for a bone by name and returns its zero-based index, or nil if not found.

```lua
-- signature
LSkeleton:findBone(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Name of the bone to find. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Zero-based bone index, or nil if no bone with that name exists. |

**Example**

```lua
do
    local skel = lurek.spine.newSkeleton("query")
    skel:addBone("root", { x = 100, y = 200 })
    skel:addBone("arm", { x = 30, y = 0 })
    print("found arm = " .. skel:findBone("arm"))
end
```

---

### `LSkeleton:findSlot`

Searches for a slot by name and returns its zero-based index, or nil if not found.

```lua
-- signature
LSkeleton:findSlot(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Name of the slot to find. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Zero-based slot index, or nil if no slot with that name exists. |

**Example**

```lua
do
    local skel = lurek.spine.newSkeleton("query")
    local arm = skel:addBone("arm", { x = 30, y = 0 })
    skel:addSlot("arm_slot", arm, "arm_img")
    print("found slot = " .. skel:findSlot("arm_slot"))
end
```

---

### `LSkeleton:getAnimationTime`

Returns the current playback time of the active animation in seconds.

```lua
-- signature
LSkeleton:getAnimationTime()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current animation time position. |

**Example**

```lua
do
    local skel = lurek.spine.newSkeleton("animated")
    skel:addBone("root")
    skel:addAnimation(lurek.spine.newSkeletonAnimation("idle", 1.0))
    skel:playAnimation("idle", true)
    print("time = " .. string.format("%.1f", skel:getAnimationTime()))
end
```

---

### `LSkeleton:getBoneWorld`

Returns the final world-space transform of a bone after hierarchy resolution.

```lua
-- signature
LSkeleton:getBoneWorld(idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | `number` | Zero-based bone index. |

**Returns**

| Type | Description |
|------|-------------|
| `LSkeletonGetBoneWorldResult` | Table with keys x, y, rotation, scale_x, scale_y — or nil if the index is invalid. |

**Example**

```lua
do
    local skel = lurek.spine.newSkeleton("query")
    local root = skel:addBone("root", { x = 100, y = 200 })
    skel:updateWorldTransforms()
    local world = skel:getBoneWorld(root)
    print("root world = " .. string.format("%.0f, %.0f", world.x, world.y))
end
```

---

### `LSkeleton:getSkin`

Returns the name of the currently active skin, or nil if no skin is set.

```lua
-- signature
LSkeleton:getSkin()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Active skin name or nil. |

**Example**

```lua
do
    local skel = lurek.spine.newSkeleton("skinned")
    skel:addSkin("warrior")
    skel:setSkin("warrior")
    print("current skin = " .. skel:getSkin())
end
```

---

### `LSkeleton:playAnimation`

Starts playing a named animation on this skeleton. Optionally loops.

```lua
-- signature
LSkeleton:playAnimation(name, looping)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Name of the animation to play (must have been added via addAnimation). |
| `looping?` | `boolean` | Whether to loop the animation. Defaults to true. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the animation was found and started, false otherwise. |

**Example**

```lua
do
    local skel = lurek.spine.newSkeleton("animated")
    skel:addBone("root")
    skel:addAnimation(lurek.spine.newSkeletonAnimation("idle", 1.0))
    local started = skel:playAnimation("idle", true)
    print("started = " .. tostring(started))
    print("time = " .. skel:getAnimationTime())
end
```

---

### `LSkeleton:setIKTarget`

Sets the world-space target position for a named IK constraint. Call updateWorldTransforms after.

```lua
-- signature
LSkeleton:setIKTarget(name, x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Name of the IK constraint to update. |
| `x` | `number` | Target world X coordinate. |
| `y` | `number` | Target world Y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the constraint was found and updated, false otherwise. |

**Example**

```lua
do
    local skel = lurek.spine.newSkeleton("ik_demo")
    local root = skel:addBone("root")
    local upper = skel:addChildBone("upper_arm", root, { x = 20 })
    local lower = skel:addChildBone("lower_arm", upper, { x = 20 })
    skel:addIKConstraint("arm_ik", { upper, lower }, true)
    local ok = skel:setIKTarget("arm_ik", 60, -30)
    print("IK target set = " .. tostring(ok))
end
```

---

### `LSkeleton:setPosition`

Sets the root bone world position, shifting the entire skeleton.

```lua
-- signature
LSkeleton:setPosition(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | World X coordinate. |
| `y` | `number` | World Y coordinate. |

**Example**

```lua
do
    local skel = lurek.spine.newSkeleton("query")
    skel:setPosition(200, 300)
    print("position set")
end
```

---

### `LSkeleton:setSkin`

Activates a named skin, applying its slot-attachment mappings to the skeleton.

```lua
-- signature
LSkeleton:setSkin(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Name of the skin to activate (must have been added via addSkin). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the skin was found and activated, false otherwise. |

**Example**

```lua
do
    local skel = lurek.spine.newSkeleton("skinned")
    skel:addSkin("default")
    skel:setSkin("default")
    print("current skin = " .. skel:getSkin())
end
```

---

### `LSkeleton:setSkinMapping`

Maps a slot to a specific attachment name within a skin. When that skin is active, the slot shows this attachment.

```lua
-- signature
LSkeleton:setSkinMapping(skin, slot, attachment)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `skin` | `string` | Name of the skin to add the mapping to. |
| `slot` | `string` | Name of the slot to remap. |
| `attachment` | `string` | Attachment name to display in that slot when the skin is active. |

**Example**

```lua
do
    local skel = lurek.spine.newSkeleton("skinned")
    local body = skel:addBone("body")
    skel:addSlot("body_slot", body, "default_body")
    skel:addSkin("default")
    skel:addSkin("warrior")
    skel:setSkinMapping("warrior", "body_slot", "warrior_body")
    skel:setSkin("warrior")
    print("current skin = " .. tostring(skel:getSkin()))
end
```

---

### `LSkeleton:slotCount`

Returns the total number of slots in the skeleton.

```lua
-- signature
LSkeleton:slotCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Slot count. |

**Example**

```lua
do
    local skel = lurek.spine.newSkeleton("hero")
    local arm = skel:addBone("arm", {})
    skel:addSlot("arm_slot", arm, nil)
    print("slots = " .. skel:slotCount())
end
```

---

### `LSkeleton:stopAnimation`

Stops the currently playing animation and resets playback state.

```lua
-- signature
LSkeleton:stopAnimation()
```

**Example**

```lua
do
    local skel = lurek.spine.newSkeleton("animated")
    skel:addBone("root")
    skel:addAnimation(lurek.spine.newSkeletonAnimation("idle", 1.0))
    skel:playAnimation("idle", true)
    skel:stopAnimation()
    print("stopped at time = " .. skel:getAnimationTime())
end
```

---

### `LSkeleton:type`

Returns the type name of this userdata object.

```lua
-- signature
LSkeleton:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always "LSkeleton". |

**Example**

```lua
do
    local skel = lurek.spine.newSkeleton("hero")
    print("type = " .. skel:type())
end
```

---

### `LSkeleton:typeOf`

Checks whether this object is of the given type name. Supports "LSkeleton" and "Object".

```lua
-- signature
LSkeleton:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if this object matches the given type. |

**Example**

```lua
do
    local skel = lurek.spine.newSkeleton("hero")
    print("is LSkeleton = " .. tostring(skel:typeOf("LSkeleton")))
end
```

---

### `LSkeleton:updateAnimation`

Advances the current animation by a delta time, applying bone transforms to the skeleton.

```lua
-- signature
LSkeleton:updateAnimation(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | `number` | Time step in seconds (e.g. from lurek.timer.getDelta()). |

**Example**

```lua
do
    local skel = lurek.spine.newSkeleton("animated")
    skel:addBone("root")
    skel:addAnimation(lurek.spine.newSkeletonAnimation("idle", 1.0))
    skel:playAnimation("idle", true)
    skel:updateAnimation(0.5)
    print("time = " .. string.format("%.1f", skel:getAnimationTime()))
end
```

---

### `LSkeleton:updateWorldTransforms`

Recomputes world transforms for all bones in hierarchy order. Call after modifying bone locals or IK targets.

```lua
-- signature
LSkeleton:updateWorldTransforms()
```

**Example**

```lua
do
    local skel = lurek.spine.newSkeleton("query")
    skel:addBone("root", { x = 100, y = 200 })
    skel:updateWorldTransforms()
    print("world transforms updated")
end
```

---

## LSkeletonAnimation

### `LSkeletonAnimation:addEventKey`

Inserts an event trigger at a specific time within the animation timeline.

```lua
-- signature
LSkeletonAnimation:addEventKey(time, name, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `time` | `number` | Time position in seconds when the event fires. |
| `name` | `string` | Name of the event (used to identify it when querying). |
| `value?` | `number` | Optional numeric payload for the event. Defaults to 0. |

**Example**

```lua
do
    local anim = lurek.spine.newSkeletonAnimation("attack", 0.5)
    anim:addEventKey(0.2, "whoosh", 1)
    anim:addEventKey(0.3, "hit", 2)
    print("events = " .. #anim:getEvents(0.0, 0.5))
end
```

---

### `LSkeletonAnimation:addKeyframe`

Adds a keyframe to a bone's property timeline at a specific time with a value and easing curve.

```lua
-- signature
LSkeletonAnimation:addKeyframe(bone_idx, property, time, value, easing)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bone_idx` | `number` | Zero-based index of the target bone. |
| `property` | `string` | Bone property: "x", "y", "rotation", "scale_x", or "scale_y". |
| `time` | `number` | Time position in seconds for this keyframe. |
| `value` | `number` | Value of the property at this keyframe. |
| `easing?` | `string` | Easing type: "linear" (default), "ease_in", "ease_out", "ease_in_out", or "step". |

**Example**

```lua
do
    local anim = lurek.spine.newSkeletonAnimation("bob", 1.0)
    anim:addKeyframe(0, "y", 0.0, 0)
    anim:addKeyframe(0, "y", 1.0, 0, "ease_in")
    print("timeline count = " .. anim:getTimelineCount())
end
```

---

### `LSkeletonAnimation:getDuration`

Returns the total duration of this animation in seconds.

```lua
-- signature
LSkeletonAnimation:getDuration()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Duration in seconds. |

**Example**

```lua
do
    local anim = lurek.spine.newSkeletonAnimation("run", 0.8)
    print("duration=" .. anim:getDuration())
end
```

---

### `LSkeletonAnimation:getEvents`

Collects all events that fire within a time range. Useful for triggering sound effects or gameplay actions.

```lua
-- signature
LSkeletonAnimation:getEvents(from, to)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from` | `number` | Start time in seconds (inclusive). |
| `to` | `number` | End time in seconds (exclusive). |

**Returns**

| Type | Description |
|------|-------------|
| `LSkeletonAnimationGetEventsResult` | Array of tables, each with "name" (string) and "value" (number) fields. |

**Example**

```lua
do
    local anim = lurek.spine.newSkeletonAnimation("attack", 0.5)
    anim:addEventKey(0.2, "whoosh", 1)
    anim:addEventKey(0.3, "hit", 2)
    print("partial events = " .. #anim:getEvents(0.15, 0.35))
end
```

---

### `LSkeletonAnimation:getTimelineCount`

Returns the number of bone-property timelines in this animation.

```lua
-- signature
LSkeletonAnimation:getTimelineCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Timeline count. |

**Example**

```lua
do
    local anim = lurek.spine.newSkeletonAnimation("run", 0.8)
    anim:addKeyframe(0, "rotation", 0.0, 0.0, "linear")
    print("timelines=" .. anim:getTimelineCount())
end
```

---

### `LSkeletonAnimation:poseAt`

Samples all timelines at a given time and returns the computed pose as an array of bone-property-value entries.

```lua
-- signature
LSkeletonAnimation:poseAt(time)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `time` | `number` | Time position in seconds to sample. |

**Returns**

| Type | Description |
|------|-------------|
| `LSkeletonAnimationPoseAtResult` | Array of tables, each with "bone_idx" (integer), "property" (string), and "value" (number). |

**Example**

```lua
do
    local anim = lurek.spine.newSkeletonAnimation("run", 0.8)
    anim:addKeyframe(0, "rotation", 0.0, 0.0, "linear")
    local pose = anim:poseAt(0.3)
    print("pose type=" .. type(pose))
end
```

---

### `LSkeletonAnimation:reverse`

Creates a new animation that plays this animation's keyframes in reverse order.

```lua
-- signature
LSkeletonAnimation:reverse()
```

**Returns**

| Type | Description |
|------|-------------|
| `LSkeletonAnimation` | A new reversed copy of this animation. |

**Example**

```lua
do
    local anim = lurek.spine.newSkeletonAnimation("swing", 0.6)
    anim:addKeyframe(0, "rotation", 0.0, 0)
    anim:addKeyframe(0, "rotation", 0.6, 0)
    local reversed = anim:reverse()
    print("reversed duration = " .. reversed:getDuration())
end
```

---

### `LSkeletonAnimation:type`

Returns the type name of this userdata object.

```lua
-- signature
LSkeletonAnimation:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always "LSkeletonAnimation". |

**Example**

```lua
do
    local anim = lurek.spine.newSkeletonAnimation("run", 0.8)
    print("type=" .. anim:type())
end
```

---

### `LSkeletonAnimation:typeOf`

Checks whether this object is of the given type name. Supports "LSkeletonAnimation" and "Object".

```lua
-- signature
LSkeletonAnimation:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if this object matches the given type. |

**Example**

```lua
do
    local anim = lurek.spine.newSkeletonAnimation("run", 0.8)
    print("typeOf=" .. tostring(anim:typeOf("LSkeletonAnimation")))
end
```

---
