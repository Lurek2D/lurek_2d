# Spine

## Summary

- The `spine` module is the skeletal-animation surface for users who want bone-based rigs, slots, skins, and timeline-driven pose changes inside the engine.
- Bones, IK constraints, importers, skeleton state, slots, timelines, and render bridges work together so the same module can load authored rigs, pose them at runtime, and expose the result to the rest of the visual stack.
- That matters because skeletal animation is more than playback: projects also need skin changes, attachment control, hierarchy updates, and pose solving that stay coherent across several animation clips.
- Import support makes the module practical for authored content workflows, while runtime skeleton control keeps it useful for gameplay-driven animation changes after import.
- Runtime events, attachment swaps, and skin changes are especially important because skeletal content often needs to react to equipment, status, or scripted actions without reauthoring the rig itself.
- Constraint solving is a major part of the value, because believable skeletal motion often depends on live bone relationships rather than on clip playback alone.
- That keeps imported rigs flexible at runtime.
- Read `spine` as the owner of skeletal rig state and timeline evaluation.

## Functions

### `lurek.spine.animationFromJson`

Parses a JSON string into a SkeletonAnimation. Returns nil if parsing fails or the format is invalid.

```lua
lurek.spine.animationFromJson(json)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `json` | string | JSON string describing the animation (Spine-compatible format). |

**Returns**

| Type | Description |
|------|-------------|
| [LSkeletonAnimation](#lskeletonanimation) | Parsed animation userdata, or nil on failure. |

**Example**

```lua
do
    local jsonData = '{"name":"idle_bounce","duration":1.2,"timelines":[{"bone":0,"property":"y","keys":[{"time":0,"value":0},{"time":1.2,"value":0}]}]}'
    local anim = lurek.spine.animationFromJson(jsonData)
    local timelines = anim and anim:getTimelineCount() or -1
    local duration = anim and anim:getDuration() or -1
    local reversed = anim and anim:reverse() or nil
    local reversed_duration = reversed and reversed:getDuration() or -1
    spine_log("animationFromJson timelines=" .. tostring(timelines) .. " duration=" .. tostring(duration) .. " reversed=" .. tostring(reversed_duration))
end
```

---

### `lurek.spine.newSkeleton`

Creates a new empty skeleton with the given name. Add bones and slots to build the hierarchy.

```lua
lurek.spine.newSkeleton(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Name identifier for this skeleton. |

**Returns**

| Type | Description |
|------|-------------|
| [LSkeleton](#lskeleton) | A new skeleton userdata. |

**Example**

```lua
do
    local skel, root, torso, slot = make_demo_skeleton("hero")
    local type_name = skel:type()
    local bones = skel:boneCount()
    local slots = skel:slotCount()
    spine_log("newSkeleton type=" .. type_name .. " root=" .. tostring(root) .. " torso=" .. tostring(torso) .. " slot=" .. tostring(slot) .. " bones=" .. tostring(bones) .. " slots=" .. tostring(slots))
end
```

---

### `lurek.spine.newSkeletonAnimation`

Creates a new empty animation with the given name and duration. Add keyframes to define motion.

```lua
lurek.spine.newSkeletonAnimation(name, duration)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Name identifier for this animation (used with playAnimation). |
| `duration` | number | Total duration of the animation in seconds. |

**Returns**

| Type | Description |
|------|-------------|
| [LSkeletonAnimation](#lskeletonanimation) | A new animation userdata. |

**Example**

```lua
do
    local anim = lurek.spine.newSkeletonAnimation("walk_cycle", 0.8)
    anim:addKeyframe(0, "x", 0.0, 0.0)
    anim:addKeyframe(0, "x", 0.8, 12.0)
    local type_name = anim:type()
    local duration = anim:getDuration()
    local timelines = anim:getTimelineCount()
    spine_log("newSkeletonAnimation type=" .. type_name .. " duration=" .. tostring(duration) .. " timelines=" .. tostring(timelines))
end
```

---

### `lurek.spine.skeletonFromJson`

Parses a Spine or DragonBones JSON string into a full runtime skeleton.

```lua
lurek.spine.skeletonFromJson(json)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `json` | string | JSON string in standard Spine (bones/slots/animations) or DragonBones (armature) shape. |

**Returns**

| Type | Description |
|------|-------------|
| [LSkeleton](#lskeleton) | Parsed skeleton userdata. |

**Example**

```lua
do
        local jsonData = [[
        {
            "skeleton": {"name": "example_import"},
            "bones": [
                {"name": "root"},
                {"name": "torso", "parent": "root", "x": 4.0, "y": -6.0}
            ],
            "slots": [
                {"name": "body", "bone": "torso", "attachment": "body_idle"}
            ],
            "animations": {
                "idle": {
                    "bones": {
                        "torso": {
                            "translate": [
                                {"time": 0.0, "x": 0.0, "y": 0.0},
                                {"time": 1.0, "x": 1.0, "y": 0.0}
                            ]
                        }
                    }
                }
            }
        }
        ]]
        local importer = rawget(lurek.spine, "skeletonFromJson")
        local imported = importer and importer(jsonData)
        example_print_log("imported bones = " .. imported:boneCount())
        example_print_log("imported slots = " .. imported:slotCount())
end
```

---

## Module Fields

*No module-level fields documented.*

## Callbacks

*No callback parameters documented in this module.*

## Enums

*No module-specific enums documented.*

## Types

- [LSkeleton](#lskeleton)
- [LSkeletonAnimation](#lskeletonanimation)

## LSkeleton

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LSkeleton:addAnimation`

Registers a SkeletonAnimation object with this skeleton so it can be played by name.

```lua
LSkeleton:addAnimation(anim)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `anim` | [LSkeletonAnimation](#lskeletonanimation) | The animation userdata to register. Consumed by this call. |

**Example**

```lua
do
    local skel, _, _, _ = make_demo_skeleton("animated")
    local idle = make_walk_animation("idle", 1.0)
    local timelines = idle:getTimelineCount()
    skel:addAnimation(idle)
    local started = skel:playAnimation("idle", true)
    local time = skel:getAnimationTime()
    spine_log("addAnimation started=" .. tostring(started) .. " time=" .. tostring(time) .. " timelines=" .. tostring(timelines))
end
```

---

#### `LSkeleton:addBone`

Adds a root-level bone to the skeleton with optional transform properties.

```lua
LSkeleton:addBone(name, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Unique name for this bone. |
| `opts?` | table | Optional table with keys: x, y, rotation, scale_x, scale_y. |

**Returns**

| Type | Description |
|------|-------------|
| number | Zero-based index of the newly added bone. |

**Example**

```lua
do
    local skel = lurek.spine.newSkeleton("character")
    local root = skel:addBone("root", { x = 0, y = 0, rotation = 0, scale_x = 1, scale_y = 1 })
    local chest = skel:addBone("chest", { x = 0, y = -12, rotation = 0.1 })
    skel:updateWorldTransforms()
    local world = skel:getBoneWorld(root)
    local bones = skel:boneCount()
    spine_log("addBone root=" .. tostring(root) .. " chest=" .. tostring(chest) .. " bones=" .. tostring(bones) .. " world=" .. tostring(world and world.x) .. "," .. tostring(world and world.y))
end
```

---

#### `LSkeleton:addChildBone`

Adds a bone as a child of an existing bone, inheriting its parent's world transform.

```lua
LSkeleton:addChildBone(name, parent_idx, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Unique name for this bone. |
| `parent_idx` | number | Zero-based index of the parent bone. |
| `opts?` | table | Optional table with keys: x, y, rotation, scale_x, scale_y (local offsets from parent). |

**Returns**

| Type | Description |
|------|-------------|
| number | Zero-based index of the newly added child bone. |

**Example**

```lua
do
    local skel = lurek.spine.newSkeleton("character")
    local root = skel:addBone("root", { x = 0, y = 0, rotation = 0, scale_x = 1, scale_y = 1 })
    local spine_bone = skel:addChildBone("spine", root, { x = 0, y = -20 })
    local head = skel:addChildBone("head", spine_bone, { x = 0, y = -10 })
    skel:updateWorldTransforms()
    local world = skel:getBoneWorld(head)
    spine_log("addChildBone root=" .. tostring(root) .. " spine=" .. tostring(spine_bone) .. " head=" .. tostring(head) .. " world_y=" .. tostring(world and world.y))
end
```

---

#### `LSkeleton:addIKConstraint`

Adds an inverse-kinematics constraint that controls a chain of bones to reach a target position.

```lua
LSkeleton:addIKConstraint(name, chain, bend_positive)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Unique name for this IK constraint (used with setIKTarget). |
| `chain` | table | Array of bone indices forming the IK chain from root to tip. |
| `bend_positive?` | boolean | Whether the joint bends in the positive direction. Defaults to true. |

**Returns**

| Type | Description |
|------|-------------|
| number | Index of the newly added constraint. |

**Example**

```lua
do
    local skel = lurek.spine.newSkeleton("ik_demo")
    local root = skel:addBone("root")
    local upper = skel:addChildBone("upper_arm", root, { x = 20 })
    local lower = skel:addChildBone("lower_arm", upper, { x = 20 })
    example_print_log("ik constraint id = " .. skel:addIKConstraint("arm_ik", { upper, lower }, true))
end
```

---

#### `LSkeleton:addSkin`

Registers a new named skin on this skeleton. Skins remap slot attachments for visual variants.

```lua
LSkeleton:addSkin(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Unique name for the skin. |

**Example**

```lua
do
    local skel, _, torso, _ = make_demo_skeleton("skinned")
    skel:addSkin("default")
    skel:setSkinMapping("default", "torso_slot", "torso_idle")
    local activated = skel:setSkin("default")
    local skin = skel:getSkin()
    spine_log("addSkin torso=" .. tostring(torso) .. " activated=" .. tostring(activated) .. " skin=" .. tostring(skin))
end
```

---

#### `LSkeleton:addSlot`

Adds a slot attached to a specific bone, optionally assigning a default attachment name.

```lua
LSkeleton:addSlot(name, bone_idx, attachment)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Unique name for this slot. |
| `bone_idx` | number | Zero-based index of the bone this slot is attached to. |
| `attachment?` | string | Optional default attachment name for this slot. |

**Returns**

| Type | Description |
|------|-------------|
| number | Zero-based index of the newly added slot. |

**Example**

```lua
do
    local skel = lurek.spine.newSkeleton("slotted")
    local bone = skel:addBone("torso", { y = -10 })
    local body_slot = skel:addSlot("body_slot", bone, "body_image")
    local hand_slot = skel:addSlot("hand_slot", bone, "hand_image")
    local slot_count = skel:slotCount()
    local found = skel:findSlot("hand_slot")
    spine_log("addSlot body=" .. tostring(body_slot) .. " hand=" .. tostring(hand_slot) .. " slots=" .. tostring(slot_count) .. " found=" .. tostring(found))
end
```

---

#### `LSkeleton:blendAnimation`

Blends an animation pose onto the skeleton at a given time with a weight factor for smooth transitions.

```lua
LSkeleton:blendAnimation(anim, time, blend_weight)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `anim` | [LSkeletonAnimation](#lskeletonanimation) | The animation to sample and blend from. |
| `time` | number | The time position to sample within the animation. |
| `blend_weight?` | number | Blend factor from 0.0 (no effect) to 1.0 (full). Defaults to 1.0. |

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
    example_print_log("blended run")
end
```

---

#### `LSkeleton:boneCount`

Returns the total number of bones in the skeleton.

```lua
LSkeleton:boneCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Bone count. |

**Example**

```lua
do
    local skel = lurek.spine.newSkeleton("hero")
    skel:addBone("root", {})
    skel:addBone("arm", {})
    local bones = skel:boneCount()
    local arm = skel:findBone("arm")
    local root = skel:findBone("root")
    spine_log("boneCount bones=" .. tostring(bones) .. " root=" .. tostring(root) .. " arm=" .. tostring(arm))
end
```

---

#### `LSkeleton:drawToImage`

Renders the skeleton into an in-memory image of the given dimensions and returns it as [LImageData](render.md#limagedata) userdata.

```lua
LSkeleton:drawToImage(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Width of the output image in pixels. |
| `h` | number | Height of the output image in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](render.md#limagedata) | A new image data object containing the rendered skeleton. |

**Example**

```lua
do
    local skel = lurek.spine.newSkeleton("render_test")
    local root = skel:addBone("root", { x = 64, y = 64 })
    skel:addChildBone("body", root, { y = -20 })
    skel:updateWorldTransforms()
    local img = skel:drawToImage(128, 128)
    example_print_log("image size = " .. img:getWidth() .. "x" .. img:getHeight())
end
```

---

#### `LSkeleton:findBone`

Searches for a bone by name and returns its zero-based index, or nil if not found.

```lua
LSkeleton:findBone(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Name of the bone to find. |

**Returns**

| Type | Description |
|------|-------------|
| number | Zero-based bone index, or nil if no bone with that name exists. |

**Example**

```lua
do
    local skel = lurek.spine.newSkeleton("query")
    skel:addBone("root", { x = 100, y = 200 })
    skel:addBone("arm", { x = 30, y = 0 })
    local arm = skel:findBone("arm")
    local missing = skel:findBone("leg")
    spine_log("findBone arm=" .. tostring(arm) .. " missing=" .. tostring(missing) .. " bones=" .. tostring(skel:boneCount()))
end
```

---

#### `LSkeleton:findSlot`

Searches for a slot by name and returns its zero-based index, or nil if not found.

```lua
LSkeleton:findSlot(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Name of the slot to find. |

**Returns**

| Type | Description |
|------|-------------|
| number | Zero-based slot index, or nil if no slot with that name exists. |

**Example**

```lua
do
    local skel = lurek.spine.newSkeleton("query")
    local arm = skel:addBone("arm", { x = 30, y = 0 })
    skel:addSlot("arm_slot", arm, "arm_img")
    local found = skel:findSlot("arm_slot")
    local missing = skel:findSlot("shield_slot")
    local slots = skel:slotCount()
    spine_log("findSlot found=" .. tostring(found) .. " missing=" .. tostring(missing) .. " slots=" .. tostring(slots))
end
```

---

#### `LSkeleton:getAnimationTime`

Returns the current playback time of the active animation in seconds.

```lua
LSkeleton:getAnimationTime()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current animation time position. |

**Example**

```lua
do
    local skel = lurek.spine.newSkeleton("animated")
    skel:addBone("root")
    skel:addAnimation(lurek.spine.newSkeletonAnimation("idle", 1.0))
    skel:playAnimation("idle", true)
    example_print_log("time = " .. string.format("%.1f", skel:getAnimationTime()))
end
```

---

#### `LSkeleton:getBoneWorld`

Returns the final world-space transform of a bone after hierarchy resolution.

```lua
LSkeleton:getBoneWorld(idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Zero-based bone index. |

**Returns**

| Type | Description |
|------|-------------|
| LSkeletonGetBoneWorldResult | Table with keys x, y, rotation, scale_x, scale_y â€” or nil if the index is invalid. |

**Example**

```lua
do
    local skel = lurek.spine.newSkeleton("query")
    local root = skel:addBone("root", { x = 100, y = 200 })
    skel:updateWorldTransforms()
    local world = skel:getBoneWorld(root)
    example_print_log("root world = " .. string.format("%.0f, %.0f", world.x, world.y))
end
```

---

#### `LSkeleton:getSkin`

Returns the name of the currently active skin, or nil if no skin is set.

```lua
LSkeleton:getSkin()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Active skin name or nil. |

**Example**

```lua
do
    local skel, _, _, _ = make_demo_skeleton("skinned")
    skel:addSkin("default")
    skel:addSkin("warrior")
    skel:setSkin("warrior")
    local current = skel:getSkin()
    local has_default = skel:setSkin("default")
    local restored = skel:getSkin()
    spine_log("getSkin current=" .. tostring(current) .. " switched_default=" .. tostring(has_default) .. " restored=" .. tostring(restored))
end
```

---

#### `LSkeleton:playAnimation`

Starts playing a named animation on this skeleton. Optionally loops.

```lua
LSkeleton:playAnimation(name, looping)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Name of the animation to play (must have been added via addAnimation). |
| `looping?` | boolean | Whether to loop the animation. Defaults to true. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the animation was found and started, false otherwise. |

**Example**

```lua
do
    local skel = lurek.spine.newSkeleton("animated")
    skel:addBone("root")
    skel:addAnimation(lurek.spine.newSkeletonAnimation("idle", 1.0))
    local started = skel:playAnimation("idle", true)
    example_print_log("started = " .. tostring(started))
    example_print_log("time = " .. skel:getAnimationTime())
end
```

---

#### `LSkeleton:setIKTarget`

Sets the world-space target position for a named IK constraint. Call updateWorldTransforms after.

```lua
LSkeleton:setIKTarget(name, x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Name of the IK constraint to update. |
| `x` | number | Target world X coordinate. |
| `y` | number | Target world Y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the constraint was found and updated, false otherwise. |

**Example**

```lua
do
    local skel = lurek.spine.newSkeleton("ik_demo")
    local root = skel:addBone("root")
    local upper = skel:addChildBone("upper_arm", root, { x = 20 })
    local lower = skel:addChildBone("lower_arm", upper, { x = 20 })
    skel:addIKConstraint("arm_ik", { upper, lower }, true)
    local ok = skel:setIKTarget("arm_ik", 60, -30)
    example_print_log("IK target set = " .. tostring(ok))
end
```

---

#### `LSkeleton:setPosition`

Sets the root bone world position, shifting the entire skeleton.

```lua
LSkeleton:setPosition(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | World X coordinate. |
| `y` | number | World Y coordinate. |

**Example**

```lua
do
    local skel, root, _, _ = make_demo_skeleton("query")
    skel:setPosition(200, 300)
    skel:updateWorldTransforms()
    local world = skel:getBoneWorld(root)
    local before = skel:getAnimationTime()
    spine_log("setPosition root=" .. tostring(root) .. " world=" .. tostring(world and world.x) .. "," .. tostring(world and world.y) .. " time=" .. tostring(before))
end
```

---

#### `LSkeleton:setSkin`

Activates a named skin, applying its slot-attachment mappings to the skeleton.

```lua
LSkeleton:setSkin(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Name of the skin to activate (must have been added via addSkin). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the skin was found and activated, false otherwise. |

**Example**

```lua
do
    local skel, _, _, _ = make_demo_skeleton("skinned")
    skel:addSkin("default")
    skel:addSkin("warrior")
    skel:setSkinMapping("warrior", "torso_slot", "warrior_body")
    local switched = skel:setSkin("warrior")
    local current = skel:getSkin()
    spine_log("setSkin switched=" .. tostring(switched) .. " current=" .. tostring(current) .. " slots=" .. tostring(skel:slotCount()))
end
```

---

#### `LSkeleton:setSkinMapping`

Maps a slot to a specific attachment name within a skin. When that skin is active, the slot shows this attachment.

```lua
LSkeleton:setSkinMapping(skin, slot, attachment)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `skin` | string | Name of the skin to add the mapping to. |
| `slot` | string | Name of the slot to remap. |
| `attachment` | string | Attachment name to display in that slot when the skin is active. |

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
    example_print_log("current skin = " .. tostring(skel:getSkin()))
end
```

---

#### `LSkeleton:slotCount`

Returns the total number of slots in the skeleton.

```lua
LSkeleton:slotCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Slot count. |

**Example**

```lua
do
    local skel = lurek.spine.newSkeleton("hero")
    local arm = skel:addBone("arm", {})
    skel:addSlot("arm_slot", arm, nil)
    skel:addSlot("weapon_slot", arm, "sword")
    local slots = skel:slotCount()
    local found = skel:findSlot("weapon_slot")
    spine_log("slotCount slots=" .. tostring(slots) .. " weapon=" .. tostring(found))
end
```

---

#### `LSkeleton:stopAnimation`

Stops the currently playing animation and resets playback state.

```lua
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
    example_print_log("stopped at time = " .. skel:getAnimationTime())
end
```

---

#### `LSkeleton:type`

Returns the type name of this userdata object.

```lua
LSkeleton:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always "[LSkeleton](#lskeleton)". |

**Example**

```lua
do
    local skel, _, _, _ = make_demo_skeleton("hero")
    local type_name = skel:type()
    local is_skeleton = skel:typeOf("LSkeleton")
    local bones = skel:boneCount()
    spine_log("LSkeleton:type name=" .. type_name .. " is_skeleton=" .. tostring(is_skeleton) .. " bones=" .. tostring(bones))
end
```

---

#### `LSkeleton:typeOf`

Checks whether this object is of the given type name. Supports "[LSkeleton](#lskeleton)" and "Object".

```lua
LSkeleton:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if this object matches the given type. |

**Example**

```lua
do
    local skel, _, _, _ = make_demo_skeleton("hero")
    local is_skeleton = skel:typeOf("LSkeleton")
    local is_object = skel:typeOf("Object")
    local is_anim = skel:typeOf("LSkeletonAnimation")
    spine_log("LSkeleton:typeOf skeleton=" .. tostring(is_skeleton) .. " object=" .. tostring(is_object) .. " anim=" .. tostring(is_anim))
end
```

---

#### `LSkeleton:updateAnimation`

Advances the current animation by a delta time, applying bone transforms to the skeleton.

```lua
LSkeleton:updateAnimation(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Time step in seconds (e.g. from lurek.timer.getDelta()). |

**Example**

```lua
do
    local skel = lurek.spine.newSkeleton("frame_loop")
    skel:addBone("root")
    local anim = lurek.spine.newSkeletonAnimation("walk", 1.0)
    anim:addKeyframe(0, "x", 0.0, 0.0)
    anim:addKeyframe(0, "x", 1.0, 10.0)
    skel:addAnimation(anim)
    skel:playAnimation("walk", true)
    for _ = 1, 60 do
        skel:updateAnimation(1.0 / 60.0)
        skel:updateWorldTransforms()
    end
    example_print_log("frame loop time = " .. string.format("%.3f", skel:getAnimationTime()))
end
```

---

#### `LSkeleton:updateWorldTransforms`

Recomputes world transforms for all bones in hierarchy order. Call after modifying bone locals or IK targets.

```lua
LSkeleton:updateWorldTransforms()
```

**Example**

```lua
do
    local skel, root, torso, _ = make_demo_skeleton("query")
    skel:setPosition(100, 200)
    skel:updateWorldTransforms()
    local root_world = skel:getBoneWorld(root)
    local torso_world = skel:getBoneWorld(torso)
    spine_log("updateWorldTransforms root=" .. tostring(root_world and root_world.x) .. "," .. tostring(root_world and root_world.y) .. " torso=" .. tostring(torso_world and torso_world.x) .. "," .. tostring(torso_world and torso_world.y))
end
```

---

## LSkeletonAnimation

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LSkeletonAnimation:addEventKey`

Inserts an event trigger at a specific time within the animation timeline.

```lua
LSkeletonAnimation:addEventKey(time, name, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `time` | number | Time position in seconds when the event fires. |
| `name` | string | Name of the event (used to identify it when querying). |
| `value?` | number | Optional numeric payload for the event. Defaults to 0. |

**Example**

```lua
do
    local anim = lurek.spine.newSkeletonAnimation("attack", 0.5)
    anim:addEventKey(0.2, "whoosh", 1)
    anim:addEventKey(0.3, "hit", 2)
    anim:addEventKey(0.45, "recover", 3)
    local events = anim:getEvents(0.0, 0.5)
    local partial = anim:getEvents(0.25, 0.5)
    spine_log("addEventKey events=" .. tostring(#events) .. " partial=" .. tostring(#partial))
end
```

---

#### `LSkeletonAnimation:addKeyframe`

Adds a keyframe to a bone's property timeline at a specific time with a value and easing curve.

```lua
LSkeletonAnimation:addKeyframe(bone_idx, property, time, value, easing)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bone_idx` | number | Zero-based index of the target bone. |
| `property` | string | Bone property: "x", "y", "rotation", "scale_x", or "scale_y". |
| `time` | number | Time position in seconds for this keyframe. |
| `value` | number | Value of the property at this keyframe. |
| `easing?` | string | Easing type: "linear" (default), "ease_in", "ease_out", "ease_in_out", or "step". |

**Example**

```lua
do
    local anim = lurek.spine.newSkeletonAnimation("bob", 1.0)
    anim:addKeyframe(0, "y", 0.0, 0)
    anim:addKeyframe(0, "y", 1.0, 0, "ease_in")
    anim:addKeyframe(0, "rotation", 0.5, 12, "linear")
    local pose = anim:poseAt(0.5)
    local timelines = anim:getTimelineCount()
    spine_log("addKeyframe timelines=" .. tostring(timelines) .. " pose_entries=" .. tostring(#pose))
end
```

---

#### `LSkeletonAnimation:getDuration`

Returns the total duration of this animation in seconds.

```lua
LSkeletonAnimation:getDuration()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Duration in seconds. |

**Example**

```lua
do
    local anim = lurek.spine.newSkeletonAnimation("run", 0.8)
    anim:addKeyframe(0, "x", 0.0, 0.0)
    anim:addKeyframe(0, "x", 0.8, 12.0)
    local duration = anim:getDuration()
    local timelines = anim:getTimelineCount()
    spine_log("getDuration duration=" .. tostring(duration) .. " timelines=" .. tostring(timelines))
end
```

---

#### `LSkeletonAnimation:getEvents`

Collects all events that fire within a time range. Useful for triggering sound effects or gameplay actions.

```lua
LSkeletonAnimation:getEvents(from, to)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from` | number | Start time in seconds (inclusive). |
| `to` | number | End time in seconds (exclusive). |

**Returns**

| Type | Description |
|------|-------------|
| LSkeletonAnimationGetEventsResult | Array of tables, each with "name" (string) and "value" (number) fields. |

**Example**

```lua
do
    local anim = lurek.spine.newSkeletonAnimation("attack", 0.5)
    anim:addEventKey(0.2, "whoosh", 1)
    anim:addEventKey(0.3, "hit", 2)
    anim:addEventKey(0.45, "recover", 3)
    local partial = anim:getEvents(0.15, 0.35)
    local later = anim:getEvents(0.35, 0.5)
    local first = partial[1] and partial[1].name or "none"
    spine_log("getEvents partial=" .. tostring(#partial) .. " later=" .. tostring(#later) .. " first=" .. first)
end
```

---

#### `LSkeletonAnimation:getTimelineCount`

Returns the number of bone-property timelines in this animation.

```lua
LSkeletonAnimation:getTimelineCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Timeline count. |

**Example**

```lua
do
    local anim = lurek.spine.newSkeletonAnimation("run", 0.8)
    anim:addKeyframe(0, "rotation", 0.0, 0.0, "linear")
    anim:addKeyframe(0, "rotation", 0.8, 15.0, "ease_in_out")
    local timelines = anim:getTimelineCount()
    local pose = anim:poseAt(0.4)
    spine_log("getTimelineCount timelines=" .. tostring(timelines) .. " pose=" .. tostring(#pose))
end
```

---

#### `LSkeletonAnimation:poseAt`

Samples all timelines at a given time and returns the computed pose as an array of bone-property-value entries.

```lua
LSkeletonAnimation:poseAt(time)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `time` | number | Time position in seconds to sample. |

**Returns**

| Type | Description |
|------|-------------|
| LSkeletonAnimationPoseAtResult | Array of tables, each with "bone_idx" (integer), "property" (string), and "value" (number). |

**Example**

```lua
do
    local anim = lurek.spine.newSkeletonAnimation("run", 0.8)
    anim:addKeyframe(0, "rotation", 0.0, 0.0, "linear")
    anim:addKeyframe(0, "rotation", 0.8, 15.0, "linear")
    local pose = anim:poseAt(0.3)
    local first = pose[1]
    local property = first and first.property or "none"
    local value = first and first.value or -1
    spine_log("poseAt entries=" .. tostring(#pose) .. " property=" .. property .. " value=" .. tostring(value))
end
```

---

#### `LSkeletonAnimation:reverse`

Creates a new animation that plays this animation's keyframes in reverse order.

```lua
LSkeletonAnimation:reverse()
```

**Returns**

| Type | Description |
|------|-------------|
| [LSkeletonAnimation](#lskeletonanimation) | A new reversed copy of this animation. |

**Example**

```lua
do
    local anim = lurek.spine.newSkeletonAnimation("swing", 0.6)
    anim:addKeyframe(0, "rotation", 0.0, 0)
    anim:addKeyframe(0, "rotation", 0.6, 0)
    local reversed = anim:reverse()
    example_print_log("reversed duration = " .. reversed:getDuration())
end
```

---

#### `LSkeletonAnimation:type`

Returns the type name of this userdata object.

```lua
LSkeletonAnimation:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always "[LSkeletonAnimation](#lskeletonanimation)". |

**Example**

```lua
do
    local anim = lurek.spine.newSkeletonAnimation("run", 0.8)
    anim:addKeyframe(0, "x", 0.0, 0.0)
    local type_name = anim:type()
    local is_anim = anim:typeOf("LSkeletonAnimation")
    local timelines = anim:getTimelineCount()
    spine_log("LSkeletonAnimation:type name=" .. type_name .. " is_anim=" .. tostring(is_anim) .. " timelines=" .. tostring(timelines))
end
```

---

#### `LSkeletonAnimation:typeOf`

Checks whether this object is of the given type name. Supports "[LSkeletonAnimation](#lskeletonanimation)" and "Object".

```lua
LSkeletonAnimation:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if this object matches the given type. |

**Example**

```lua
do
    local anim = lurek.spine.newSkeletonAnimation("run", 0.8)
    local is_anim = anim:typeOf("LSkeletonAnimation")
    local is_object = anim:typeOf("Object")
    local is_skeleton = anim:typeOf("LSkeleton")
    anim:addEventKey(0.2, "step", 1)
    spine_log("LSkeletonAnimation:typeOf anim=" .. tostring(is_anim) .. " object=" .. tostring(is_object) .. " skeleton=" .. tostring(is_skeleton))
end
```

---
