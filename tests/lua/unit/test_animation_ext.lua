-- Lurek2D Lua BDD tests for lurek.animation extended API
-- Covers: crossfade, getBlendState, drawToImage, fromAseprite, newStateMachine.
-- Headless: no GPU, no audio, no window.

-- Helper: build a minimal animation with two named clips.
local function make_anim()
    local a = lurek.animation.new()
    a:addFrame(0, 0, 16, 16)   -- frame 0
    a:addFrame(16, 0, 16, 16)  -- frame 1
    a:addClip("idle", {0}, 8, true)
    a:addClip("run",  {1}, 8, true)
    return a
end

-- @description Covers suite: lurek.animation extended features.
describe("lurek.animation extended", function()
    -- ── module interface ──────────────────────────────────────────────────

    -- @description Covers suite: new API factories.
    describe("new API factories", function()
        -- @covers lurek.animation.fromAseprite
        -- @description Verifies the fromAseprite factory is exposed on the module.
        it("exposes fromAseprite factory", function()
            expect_type("function", lurek.animation.fromAseprite)
        end)

        -- @covers lurek.animation.newStateMachine
        -- @description Verifies the newStateMachine factory is exposed on the module.
        it("exposes newStateMachine factory", function()
            expect_type("function", lurek.animation.newStateMachine)
        end)
    end)

    -- ── crossfade ─────────────────────────────────────────────────────────

    -- @description Covers suite: crossfade().
    describe("crossfade()", function()
        -- @covers lurek.animation.crossfade
        -- @description Verifies crossfade returns true when switching to a valid clip.
        it("returns true for an existing clip", function()
            local a = make_anim()
            a:play("idle")
            local ok = a:crossfade("run", 0.2)
            expect_equal(true, ok)
        end)

        -- @covers lurek.animation.crossfade
        -- @description Verifies crossfade returns false when the target clip does not exist.
        it("returns false for an unknown clip", function()
            local a = make_anim()
            a:play("idle")
            local ok = a:crossfade("ghost", 0.2)
            expect_equal(false, ok)
        end)

        -- @covers lurek.animation.crossfade
        -- @covers lurek.animation.getBlendState
        -- @description Verifies getBlendState returns a table immediately after starting a crossfade.
        it("getBlendState returns blend table during crossfade", function()
            local a = make_anim()
            a:play("idle")
            a:crossfade("run", 0.5)
            local bs = a:getBlendState()
            expect_type("table", bs)
        end)
    end)

    -- ── getBlendState ─────────────────────────────────────────────────────

    -- @description Covers suite: getBlendState().
    describe("getBlendState()", function()
        -- @covers lurek.animation.getBlendState
        -- @description Verifies getBlendState returns nil when not crossfading.
        it("returns nil when not crossfading", function()
            local a = make_anim()
            a:play("idle")
            local bs = a:getBlendState()
            expect_equal(nil, bs)
        end)

        -- @covers lurek.animation.crossfade
        -- @covers lurek.animation.getBlendState
        -- @description Verifies blend state table has from, to, and blend fields.
        it("blend table has from/to/blend fields", function()
            local a = make_anim()
            a:play("idle")
            a:crossfade("run", 0.5)
            local bs = a:getBlendState()
            expect_type("table", bs.from)
            expect_type("table", bs.to)
            expect_type("number", bs.blend)
        end)

        -- @covers lurek.animation.crossfade
        -- @covers lurek.animation.getBlendState
        -- @description Verifies blend value starts near 0 right after initiating a crossfade.
        it("blend starts near 0 at crossfade start", function()
            local a = make_anim()
            a:play("idle")
            a:crossfade("run", 0.5)
            local bs = a:getBlendState()
            expect_near(0.0, bs.blend, 0.05)
        end)
    end)

    -- ── drawToImage ───────────────────────────────────────────────────────

    -- @description Covers suite: Animation:drawToImage().
    describe("Animation:drawToImage()", function()
        -- @covers lurek.animation.drawToImage
        -- @description Verifies drawToImage returns a userdata (ImageData).
        it("returns a userdata", function()
            local a = make_anim()
            local img = a:drawToImage(32, 32)
            expect_type("userdata", img)
        end)
    end)

    -- ── fromAseprite ──────────────────────────────────────────────────────

    -- @description Covers suite: fromAseprite().
    describe("fromAseprite()", function()
        -- Minimal two-frame Aseprite JSON export
        local ASEPRITE_JSON = [[{
            "frames": [
                {"filename":"idle_0","frame":{"x":0,"y":0,"w":16,"h":16},"duration":100},
                {"filename":"idle_1","frame":{"x":16,"y":0,"w":16,"h":16},"duration":100}
            ],
            "meta": {
                "frameTags":[{"name":"idle","from":0,"to":1,"direction":"forward"}]
            }
        }]]

        -- @covers lurek.animation.fromAseprite
        -- @description Confirms fromAseprite returns animation userdata for valid input.
        it("returns animation userdata for valid JSON", function()
            local a = lurek.animation.fromAseprite(ASEPRITE_JSON)
            expect_type("userdata", a)
        end)

        -- @covers lurek.animation.fromAseprite
        -- @covers lurek.animation.getFrameCount
        -- @description Confirms fromAseprite imports the correct number of frames.
        it("imports the correct frame count", function()
            local a = lurek.animation.fromAseprite(ASEPRITE_JSON)
            expect_equal(2, a:getFrameCount())
        end)

        -- @covers lurek.animation.fromAseprite
        -- @covers lurek.animation.getClipCount
        -- @description Confirms fromAseprite registers clips from frameTags.
        it("registers named clips from frameTags", function()
            local a = lurek.animation.fromAseprite(ASEPRITE_JSON)
            expect_true(a:getClipCount() >= 1, "expected at least one clip")
        end)

        -- @covers lurek.animation.fromAseprite
        -- @description Confirms fromAseprite raises an error for invalid JSON.
        it("errors on invalid JSON", function()
            expect_error(function()
                lurek.animation.fromAseprite("not json")
            end)
        end)
    end)

    -- ── newStateMachine ───────────────────────────────────────────────────

    -- @description Covers suite: newStateMachine().
    describe("newStateMachine()", function()
        -- @covers lurek.animation.newStateMachine
        -- @description Confirms newStateMachine returns an FSM userdata.
        it("returns a userdata", function()
            local a = make_anim()
            a:play("idle")
            local fsm = lurek.animation.newStateMachine(a, "idle")
            expect_type("userdata", fsm)
        end)

        -- @covers lurek.animation.newStateMachine
        -- @covers lurek.animation.getState
        -- @description Confirms the initial state matches the provided initial state name.
        it("getState returns initial state name", function()
            local a = make_anim()
            a:play("idle")
            local fsm = lurek.animation.newStateMachine(a, "idle")
            expect_equal("idle", fsm:getState())
        end)

        -- @covers lurek.animation.newStateMachine
        -- @covers lurek.animation.addState
        -- @covers lurek.animation.forceState
        -- @covers lurek.animation.getState
        -- @description Confirms forceState immediately transitions to the target state.
        it("forceState switches the current state", function()
            local a = make_anim()
            local fsm = lurek.animation.newStateMachine(a, "idle")
            fsm:addState("run", "run", true)
            fsm:forceState("run")
            expect_equal("run", fsm:getState())
        end)

        -- @covers lurek.animation.newStateMachine
        -- @covers lurek.animation.setParam
        -- @covers lurek.animation.addTransition
        -- @covers lurek.animation.update
        -- @covers lurek.animation.getState
        -- @description Confirms a boolean param triggers a registered transition on update.
        it("transition fires when boolean param is set", function()
            local a = make_anim()
            local fsm = lurek.animation.newStateMachine(a, "idle")
            fsm:addState("run", "run", true)
            fsm:addTransition("idle", "run", "moving")
            fsm:setParam("moving", true)
            fsm:update(0.016)
            expect_equal("run", fsm:getState())
        end)

        -- @covers lurek.animation.newStateMachine
        -- @covers lurek.animation.getQuad
        -- @description Confirms getQuad returns a table when the FSM has an active animation state.
        it("getQuad returns a table", function()
            local a = make_anim()
            a:play("idle")
            local fsm = lurek.animation.newStateMachine(a, "idle")
            expect_type("table", fsm:getQuad())
        end)
    end)
end)

test_summary()
