--- Animation Examples Part 2: Blend Layer Set (cont.), Animation Curve, Sync Group

--@api-stub: LBlendLayerSet:listLayers
-- Returns a table of all layer names in the blend set.
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("base", "idle", 1.0)
    bls:addLayer("overlay", "wave", 0.5)
    local names = bls:listLayers()
    print("layers: " .. table.concat(names, ", "))
end

--@api-stub: LBlendLayerSet:len
-- Returns the number of layers in the blend set.
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("a", "clip_a", 1.0)
    bls:addLayer("b", "clip_b", 0.5)
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
    curve:addKeyframe(1.0, 0.0)
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
    curve:addKeyframe(0.75, 8.0)
    curve:addKeyframe(1.0, 10.0)
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
    sg:add(2)
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
    sg:add(2)
    sg:clear()
    print("after clear, members = " .. sg:memberCount())
end

--@api-stub: LAnimSyncGroup:memberCount
-- Returns the number of animations in the sync group.
do
    local sg = lurek.animation.newSyncGroup()
    sg:add(1)
    sg:add(2)
    sg:add(3)
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

print("animation_01.lua")
