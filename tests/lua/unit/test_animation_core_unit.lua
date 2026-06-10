-- tests/lua/unit/test_animation_core_unit.lua
-- Canonical unit coverage for lurek.animation and related userdata APIs.

local IMAGE_PATH = "content/examples/assets/images/sample_texture.png"

local function load_image()
    return lurek.render.newImage(IMAGE_PATH)
end

local function make_basic_animation()
    local anim = lurek.animation.new()
    anim:addFramesFromGrid(64, 32, 32, 32, 0, 2)
    anim:addClip("idle", { 0, 1 }, 4, true, "forward")
    anim:addClip("run", { 1, 0 }, 8, true, "forward")
    return anim
end

local function make_state_machine()
    local anim = make_basic_animation()
    local sm = lurek.animation.newStateMachine(anim, "idle")
    sm:addState("idle", "idle", true)
    sm:addState("run", "run", true)
    return sm
end

-- @describe lurek.animation functions
describe("lurek.animation functions", function()
    -- @covers lurek.animation.buildCharacter
    it("buildCharacter returns animation and state machine handles", function()
        local char = lurek.animation.buildCharacter({
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
        })
        expect_not_nil(char.animation)
        expect_not_nil(char.stateMachine)
    end)

    -- @covers lurek.animation.fromAseprite
    it("fromAseprite parses a minimal Aseprite JSON export", function()
        local json = '{"frames":[{"filename":"f0","frame":{"x":0,"y":0,"w":16,"h":16}}],"meta":{"size":{"w":16,"h":16},"frameTags":[]}}'
        local anim = lurek.animation.fromAseprite(json)
        expect_not_nil(anim)
        expect_true(anim:getFrameCount() >= 1)
    end)

    -- @covers lurek.animation.new
    it("new creates an empty animation handle", function()
        local anim = lurek.animation.new()
        expect_equal(0, anim:getFrameCount())
        expect_equal(0, anim:getClipCount())
    end)

    -- @covers lurek.animation.newBlendLayerSet
    it("newBlendLayerSet creates an empty blend layer set", function()
        local set = lurek.animation.newBlendLayerSet()
        expect_equal(0, set:len())
    end)

    -- @covers lurek.animation.newCurve
    it("newCurve creates an empty animation curve", function()
        local curve = lurek.animation.newCurve()
        expect_equal(0, curve:keyframeCount())
    end)

    -- @covers lurek.animation.newStateMachine
    it("newStateMachine creates a state machine for an animation", function()
        local sm = make_state_machine()
        expect_equal("idle", sm:getState())
    end)

    -- @covers lurek.animation.newSyncGroup
    it("newSyncGroup creates an empty animation sync group", function()
        local group = lurek.animation.newSyncGroup()
        expect_equal(0, group:memberCount())
    end)
end)

-- @describe LAnimCurve methods
describe("LAnimCurve methods", function()
    -- @covers LAnimCurve:addKeyframe
    it("addKeyframe stores keyframes on the curve", function()
        local curve = lurek.animation.newCurve()
        curve:addKeyframe(0.0, 0.0)
        curve:addKeyframe(1.0, 10.0)
        expect_equal(2, curve:keyframeCount())
    end)

    -- @covers LAnimCurve:clear
    it("clear removes all curve keyframes", function()
        local curve = lurek.animation.newCurve()
        curve:addKeyframe(0.0, 1.0)
        curve:addKeyframe(1.0, 2.0)
        curve:clear()
        expect_equal(0, curve:keyframeCount())
    end)

    -- @covers LAnimCurve:eval
    it("eval interpolates between keyframes", function()
        local curve = lurek.animation.newCurve()
        curve:addKeyframe(0.0, 0.0)
        curve:addKeyframe(1.0, 10.0)
        expect_near(5.0, curve:eval(0.5), 1e-5)
    end)

    -- @covers LAnimCurve:keyframeCount
    it("keyframeCount reports the number of stored keyframes", function()
        local curve = lurek.animation.newCurve()
        curve:addKeyframe(0.0, 0.0)
        curve:addKeyframe(0.25, 5.0)
        expect_equal(2, curve:keyframeCount())
    end)

    -- @covers LAnimCurve:setCustomEasing
    it("setCustomEasing uses a Lua callback for interpolation", function()
        local curve = lurek.animation.newCurve()
        curve:addKeyframe(0.0, 0.0)
        curve:addKeyframe(1.0, 100.0)
        curve:setCustomEasing(function(t)
            return t * t
        end)
        expect_near(0.25, curve:eval(0.5), 1e-5)
    end)

    -- @covers LAnimCurve:setEasing
    it("setEasing accepts a built-in easing mode", function()
        local curve = lurek.animation.newCurve()
        curve:addKeyframe(0.0, 0.0)
        curve:addKeyframe(1.0, 1.0)
        curve:setEasing("ease_in_out")
        local value = curve:eval(0.5)
        expect_true(value >= 0.0 and value <= 1.0)
    end)

    -- @covers LAnimCurve:type
    it("type returns the curve userdata name", function()
        local curve = lurek.animation.newCurve()
        expect_equal("LAnimCurve", curve:type())
    end)

    -- @covers LAnimCurve:typeOf
    it("typeOf accepts the curve type name", function()
        local curve = lurek.animation.newCurve()
        expect_true(curve:typeOf("LAnimCurve"))
    end)
end)

-- @describe LAnimStateMachine methods
describe("LAnimStateMachine methods", function()
    -- @covers LAnimStateMachine:addState
    it("addState registers named states on the machine", function()
        local sm = make_state_machine()
        expect_equal("idle", sm:getState())
    end)

    -- @covers LAnimStateMachine:addTransition
    it("addTransition enables parameter-driven state changes", function()
        local sm = make_state_machine()
        sm:addTransition("idle", "run", "speed > 0.1")
        sm:setParam("speed", 2.5)
        sm:update(0.016)
        expect_equal("run", sm:getState())
    end)

    -- @covers LAnimStateMachine:draw
    it("draw returns a boolean when asked to render the current state", function()
        local sm = make_state_machine()
        local queued = sm:draw(load_image(), 48, 24, { scale = 2.0 })
        expect_type("boolean", queued)
    end)

    -- @covers LAnimStateMachine:forceState
    it("forceState switches to a named state", function()
        local sm = make_state_machine()
        expect_true(sm:forceState("run"))
        expect_equal("run", sm:getState())
    end)

    -- @covers LAnimStateMachine:getQuad
    it("getQuad returns the current frame rectangle", function()
        local sm = make_state_machine()
        expect_true(sm:forceState("idle"))
        local quad = sm:getQuad()
        expect_type("table", quad)
        expect_type("number", quad.x)
    end)

    -- @covers LAnimStateMachine:getState
    it("getState returns the active state name", function()
        local sm = make_state_machine()
        expect_equal("idle", sm:getState())
    end)

    -- @covers LAnimStateMachine:setImage
    it("setImage stores an image so draw can be called without an explicit image argument", function()
        local sm = make_state_machine()
        sm:setImage(load_image())
        local queued = sm:draw(48, 24, { scale = 2.0 })
        expect_type("boolean", queued)
    end)

    -- @covers LAnimStateMachine:setParam
    it("setParam stores machine parameters without crashing", function()
        local sm = make_state_machine()
        expect_no_error(function()
            sm:setParam("speed", 2.5)
        end)
    end)

    -- @covers LAnimStateMachine:type
    it("type returns the state machine userdata name", function()
        local sm = make_state_machine()
        expect_equal("LAnimStateMachine", sm:type())
    end)

    -- @covers LAnimStateMachine:typeOf
    it("typeOf accepts the state machine type name", function()
        local sm = make_state_machine()
        expect_true(sm:typeOf("LAnimStateMachine"))
    end)

    -- @covers LAnimStateMachine:update
    it("update advances the owned animation without error", function()
        local sm = make_state_machine()
        expect_no_error(function()
            sm:update(0.016)
        end)
    end)
end)

-- @describe LAnimSyncGroup methods
describe("LAnimSyncGroup methods", function()
    -- @covers LAnimSyncGroup:add
    it("add accepts a handle argument without changing the current stubbed member count", function()
        local group = lurek.animation.newSyncGroup()
        group:add(1)
        expect_equal(0, group:memberCount())
    end)

    -- @covers LAnimSyncGroup:clear
    it("clear removes all sync-group members", function()
        local group = lurek.animation.newSyncGroup()
        group:add(1)
        group:clear()
        expect_equal(0, group:memberCount())
    end)

    -- @covers LAnimSyncGroup:memberCount
    it("memberCount reports the current stubbed count", function()
        local group = lurek.animation.newSyncGroup()
        group:add(1)
        expect_equal(0, group:memberCount())
    end)

    -- @covers LAnimSyncGroup:remove
    it("remove deletes a member from the sync group", function()
        local group = lurek.animation.newSyncGroup()
        group:add(1)
        group:remove(1)
        expect_equal(0, group:memberCount())
    end)

    -- @covers LAnimSyncGroup:type
    it("type returns the sync-group userdata name", function()
        local group = lurek.animation.newSyncGroup()
        expect_equal("LAnimSyncGroup", group:type())
    end)

    -- @covers LAnimSyncGroup:typeOf
    it("typeOf accepts the sync-group type name", function()
        local group = lurek.animation.newSyncGroup()
        expect_true(group:typeOf("LAnimSyncGroup"))
    end)
end)

-- @describe LAnimation methods
describe("LAnimation methods", function()
    -- @covers LAnimation:addClip
    it("addClip registers a named clip over existing frames", function()
        local anim = lurek.animation.new()
        anim:addFramesFromGrid(128, 32, 32, 32, 0, 4)
        anim:addClip("walk", { 0, 1, 2, 3 }, 10, true, "forward")
        expect_equal(1, anim:getClipCount())
    end)

    -- @covers LAnimation:addClipFromGrid
    it("addClipFromGrid creates frames and a clip in one call", function()
        local anim = lurek.animation.new()
        anim:addClipFromGrid("sprint", 256, 64, 32, 32, 0, 8, 15, true)
        expect_true(anim:getFrameCount() >= 8)
        expect_equal(1, anim:getClipCount())
    end)

    -- @covers LAnimation:addFrame
    it("addFrame appends one frame rectangle", function()
        local anim = lurek.animation.new()
        local index = anim:addFrame(0, 0, 32, 32)
        expect_equal(0, index)
        expect_equal(1, anim:getFrameCount())
    end)

    -- @covers LAnimation:addFramesFromGrid
    it("addFramesFromGrid slices a grid into multiple frames", function()
        local anim = lurek.animation.new()
        local count = anim:addFramesFromGrid(256, 256, 32, 32, 0, 8)
        expect_equal(8, count)
        expect_equal(8, anim:getFrameCount())
    end)

    -- @covers LAnimation:addFramesFromRects
    it("addFramesFromRects accepts an array of explicit rectangles", function()
        local anim = lurek.animation.new()
        anim:addFramesFromRects({
            { x = 0, y = 0, w = 16, h = 16 },
            { x = 16, y = 0, w = 16, h = 16 },
        })
        expect_equal(2, anim:getFrameCount())
    end)

    -- @covers LAnimation:crossfade
    it("crossfade starts a blend toward another clip", function()
        local anim = make_basic_animation()
        anim:play("idle")
        expect_true(anim:crossfade("run", 0.3))
    end)

    -- @covers LAnimation:draw
    it("draw returns a boolean for the current frame", function()
        local anim = make_basic_animation()
        anim:play("idle")
        local queued = anim:draw(load_image(), 20, 24, { scale = 2.0 })
        expect_type("boolean", queued)
    end)

    -- @covers LAnimation:drawPreviewGrid
    it("drawPreviewGrid rasterizes preview frames into image data", function()
        local anim = make_basic_animation()
        local img = anim:drawPreviewGrid(4, 36)
        expect_type("userdata", img)
    end)

    -- @covers LAnimation:drawToImage
    it("drawToImage rasterizes the current frame into image data", function()
        local anim = make_basic_animation()
        anim:play("idle")
        local img = anim:drawToImage(64, 64)
        expect_type("userdata", img)
    end)

    -- @covers LAnimation:getBlendState
    it("getBlendState returns data after crossfade starts", function()
        local anim = make_basic_animation()
        anim:play("idle")
        anim:crossfade("run", 0.3)
        expect_not_nil(anim:getBlendState())
    end)

    -- @covers LAnimation:getClip
    it("getClip returns the active clip name", function()
        local anim = make_basic_animation()
        anim:play("idle")
        expect_equal("idle", anim:getClip())
    end)

    -- @covers LAnimation:getClipCount
    it("getClipCount returns the number of named clips", function()
        local anim = make_basic_animation()
        expect_equal(2, anim:getClipCount())
    end)

    -- @covers LAnimation:getClipMode
    it("getClipMode returns the configured playback mode", function()
        local anim = make_basic_animation()
        expect_equal("forward", anim:getClipMode("idle"))
    end)

    -- @covers LAnimation:getCurrentFrame
    it("getCurrentFrame returns the current frame index", function()
        local anim = make_basic_animation()
        anim:play("idle")
        expect_type("number", anim:getCurrentFrame())
    end)

    -- @covers LAnimation:getFrameCount
    it("getFrameCount returns the number of stored frames", function()
        local anim = make_basic_animation()
        expect_equal(2, anim:getFrameCount())
    end)

    -- @covers LAnimation:getQuad
    it("getQuad returns the current frame rectangle", function()
        local anim = make_basic_animation()
        anim:play("idle")
        local quad = anim:getQuad()
        expect_type("table", quad)
        expect_type("number", quad.w)
    end)

    -- @covers LAnimation:getSpeed
    it("getSpeed returns the animation playback multiplier", function()
        local anim = lurek.animation.new()
        expect_type("number", anim:getSpeed())
    end)

    -- @covers LAnimation:isLooping
    it("isLooping reflects whether the active clip loops", function()
        local anim = make_basic_animation()
        anim:play("idle")
        expect_true(anim:isLooping())
    end)

    -- @covers LAnimation:isPlaying
    it("isPlaying returns true after play is called", function()
        local anim = make_basic_animation()
        anim:play("idle")
        expect_true(anim:isPlaying())
    end)

    -- @covers LAnimation:pause
    it("pause stops playback without clearing the active clip", function()
        local anim = make_basic_animation()
        anim:play("idle")
        anim:pause()
        expect_false(anim:isPlaying())
        expect_equal("idle", anim:getClip())
    end)

    -- @covers LAnimation:play
    it("play activates a named clip", function()
        local anim = make_basic_animation()
        expect_true(anim:play("idle"))
        expect_equal("idle", anim:getClip())
    end)

    -- @covers LAnimation:pollEvents
    it("pollEvents drains animation events after update", function()
        local anim = lurek.animation.new()
        anim:addFrame(0, 0, 32, 32)
        anim:addClip("once", { 0 }, 10, false)
        anim:play("once")
        anim:update(1.0)
        expect_type("table", anim:pollEvents())
    end)

    -- @covers LAnimation:resume
    it("resume restarts playback after pause", function()
        local anim = make_basic_animation()
        anim:play("idle")
        anim:pause()
        anim:resume()
        expect_true(anim:isPlaying())
    end)

    -- @covers LAnimation:setClipMode
    it("setClipMode changes the playback mode for a clip", function()
        local anim = make_basic_animation()
        expect_true(anim:setClipMode("idle", "reverse"))
        expect_equal("reverse", anim:getClipMode("idle"))
    end)

    -- @covers LAnimation:setFrame
    it("setFrame updates the current frame directly", function()
        local anim = make_basic_animation()
        anim:play("idle")
        anim:setFrame(1)
        expect_equal(1, anim:getCurrentFrame())
    end)

    -- @covers LAnimation:setImage
    it("setImage stores an image so draw can omit the explicit atlas argument", function()
        local anim = make_basic_animation()
        anim:play("idle")
        anim:setImage(load_image())
        local queued = anim:draw(20, 24, { scale = 2.0 })
        expect_type("boolean", queued)
    end)

    -- @covers LAnimation:setSpeed
    it("setSpeed updates the playback speed multiplier", function()
        local anim = lurek.animation.new()
        anim:setSpeed(2.0)
        expect_near(2.0, anim:getSpeed(), 1e-5)
    end)

    -- @covers LAnimation:stop
    it("stop halts playback and resets animation state", function()
        local anim = make_basic_animation()
        anim:play("idle")
        anim:stop()
        expect_false(anim:isPlaying())
    end)

    -- @covers LAnimation:type
    it("type returns the animation userdata name", function()
        local anim = lurek.animation.new()
        expect_equal("LAnimation", anim:type())
    end)

    -- @covers LAnimation:typeOf
    it("typeOf accepts the animation type name", function()
        local anim = lurek.animation.new()
        expect_true(anim:typeOf("LAnimation"))
    end)

    -- @covers LAnimation:update
    it("update advances playback over time", function()
        local anim = make_basic_animation()
        anim:play("idle")
        anim:update(0.6)
        expect_type("number", anim:getCurrentFrame())
    end)
end)

-- @describe LBlendLayerSet methods
describe("LBlendLayerSet methods", function()
    -- @covers LBlendLayerSet:addLayer
    it("addLayer inserts a named blend layer", function()
        local set = lurek.animation.newBlendLayerSet()
        expect_true(set:addLayer("base", "idle", 1.0))
        expect_equal(1, set:len())
    end)

    -- @covers LBlendLayerSet:getWeight
    it("getWeight returns the weight for an existing layer", function()
        local set = lurek.animation.newBlendLayerSet()
        set:addLayer("run", "run_clip", 0.7)
        expect_near(0.7, set:getWeight("run"), 1e-5)
    end)

    -- @covers LBlendLayerSet:len
    it("len returns the number of blend layers", function()
        local set = lurek.animation.newBlendLayerSet()
        set:addLayer("a", "clip_a", 1.0)
        expect_equal(1, set:len())
    end)

    -- @covers LBlendLayerSet:listLayers
    it("listLayers returns the stored layer records", function()
        local set = lurek.animation.newBlendLayerSet()
        set:addLayer("base", "idle", 1.0)
        local layers = set:listLayers()
        expect_type("table", layers)
        expect_equal("base", layers[1].name)
    end)

    -- @covers LBlendLayerSet:removeLayer
    it("removeLayer deletes an existing layer", function()
        local set = lurek.animation.newBlendLayerSet()
        set:addLayer("temp", "idle", 1.0)
        expect_true(set:removeLayer("temp"))
        expect_equal(0, set:len())
    end)

    -- @covers LBlendLayerSet:setMask
    it("setMask stores a bone mask for a layer", function()
        local set = lurek.animation.newBlendLayerSet()
        set:addLayer("arms", "swing", 1.0)
        expect_true(set:setMask("arms", { "shoulder_l", "arm_l", "hand_l" }))
        local layers = set:listLayers()
        expect_equal(3, #layers[1].bones)
    end)

    -- @covers LBlendLayerSet:setWeight
    it("setWeight updates the blend weight", function()
        local set = lurek.animation.newBlendLayerSet()
        set:addLayer("walk", "walk_clip", 0.5)
        expect_true(set:setWeight("walk", 0.8))
        expect_near(0.8, set:getWeight("walk"), 1e-5)
    end)

    -- @covers LBlendLayerSet:type
    it("type returns the blend-layer-set userdata name", function()
        local set = lurek.animation.newBlendLayerSet()
        expect_equal("LBlendLayerSet", set:type())
    end)

    -- @covers LBlendLayerSet:typeOf
    it("typeOf accepts the blend-layer-set type name", function()
        local set = lurek.animation.newBlendLayerSet()
        expect_true(set:typeOf("LBlendLayerSet"))
    end)
end)

test_summary()
