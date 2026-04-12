-- Lurek2D Lua BDD tests for lurek.animation
-- Headless: no GPU, no audio, no window.
-- @covers lurek.animation.new
-- @covers lurek.animation.addFrame
-- @covers lurek.animation.addFramesFromGrid
-- @covers lurek.animation.addClip
-- @covers lurek.animation.addClipFromGrid
-- @covers lurek.animation.play
-- @covers lurek.animation.stop
-- @covers lurek.animation.pause
-- @covers lurek.animation.resume
-- @covers lurek.animation.update
-- @covers lurek.animation.getQuad
-- @covers lurek.animation.pollEvents
-- @covers lurek.animation.isPlaying
-- @covers lurek.animation.isLooping
-- @covers lurek.animation.getClip
-- @covers lurek.animation.getSpeed
-- @covers lurek.animation.setSpeed
-- @covers lurek.animation.getFrameCount
-- @covers lurek.animation.getClipCount
-- @covers lurek.animation.getCurrentFrame
-- @covers lurek.animation.setFrame


-- @description Covers suite: lurek.animation.
describe("lurek.animation", function()
    -- @description Covers suite: module interface.
    describe("module interface", function()
        -- @covers lurek.animation.new
        -- @description Verifies the animation module exposes the new() factory used to create animation userdata.
        it("exposes new factory", function()
            expect_type("function", lurek.animation.new)
        end)
    end)

    -- @description Covers suite: new().
    describe("new()", function()
        -- @covers lurek.animation.new
        -- @description Confirms lurek.animation.new returns animation userdata rather than a plain Lua table.
        it("returns a userdata object", function()
            local a = lurek.animation.new()
            expect_type("userdata", a)
        end)

        -- @covers lurek.animation.new
        -- @covers lurek.animation.getFrameCount
        -- @description Checks that a freshly created animation reports zero frames before any frame data is added.
        it("getFrameCount returns 0 on empty animation", function()
            local a = lurek.animation.new()
            expect_equal(0, a:getFrameCount())
        end)

        -- @covers lurek.animation.new
        -- @covers lurek.animation.getClipCount
        -- @description Checks that a new animation starts with no named clips registered.
        it("getClipCount returns 0 with no clips", function()
            local a = lurek.animation.new()
            expect_equal(0, a:getClipCount())
        end)

        -- @covers lurek.animation.new
        -- @covers lurek.animation.isPlaying
        -- @description Verifies isPlaying() stays false until playback is explicitly started.
        it("isPlaying returns false before play()", function()
            local a = lurek.animation.new()
            expect_equal(false, a:isPlaying())
        end)

        -- @covers lurek.animation.new
        -- @covers lurek.animation.getClip
        -- @description Verifies getClip() returns nil when no clip has been selected for playback.
        it("getClip returns nil before play()", function()
            local a = lurek.animation.new()
            expect_equal(nil, a:getClip())
        end)

        -- @covers lurek.animation.new
        -- @covers lurek.animation.getSpeed
        -- @description Confirms newly created animations start with the default playback speed of 1.0.
        it("getSpeed returns default 1.0", function()
            local a = lurek.animation.new()
            expect_near(1.0, a:getSpeed(), 0.001)
        end)
    end)

    -- @description Covers suite: addFrame().
    describe("addFrame()", function()
        -- @covers lurek.animation.new
        -- @covers lurek.animation.addFrame
        -- @description Verifies the first added frame is assigned index 0.
        it("returns an index starting from 0", function()
            local a = lurek.animation.new()
            local idx = a:addFrame(0, 0, 32, 32)
            expect_equal(0, idx)
        end)

        -- @covers lurek.animation.new
        -- @covers lurek.animation.addFrame
        -- @covers lurek.animation.getFrameCount
        -- @description Confirms each addFrame() call increments the animation frame count.
        it("increments frame count", function()
            local a = lurek.animation.new()
            a:addFrame(0, 0, 16, 16)
            a:addFrame(16, 0, 16, 16)
            expect_equal(2, a:getFrameCount())
        end)
    end)

    -- @description Covers suite: addFramesFromGrid().
    describe("addFramesFromGrid()", function()
        -- @covers lurek.animation.new
        -- @covers lurek.animation.addFramesFromGrid
        -- @description Verifies addFramesFromGrid() returns the number of frames it generated from the grid slice.
        it("returns the number of frames added", function()
            local a = lurek.animation.new()
            local n = a:addFramesFromGrid(128, 128, 32, 32, 0, 4)
            expect_equal(4, n)
        end)

        -- @covers lurek.animation.new
        -- @covers lurek.animation.addFramesFromGrid
        -- @covers lurek.animation.getFrameCount
        -- @description Confirms grid-imported frames become visible through getFrameCount().
        it("increases frame count by the returned amount", function()
            local a = lurek.animation.new()
            local n = a:addFramesFromGrid(64, 64, 32, 32, 0, 2)
            expect_equal(n, a:getFrameCount())
        end)
    end)

    -- @description Covers suite: addClip().
    describe("addClip()", function()
        -- @covers lurek.animation.new
        -- @covers lurek.animation.addFrame
        -- @covers lurek.animation.addClip
        -- @covers lurek.animation.getClipCount
        -- @description Verifies addClip() registers a named clip once the referenced frames exist.
        it("increases clip count by one", function()
            local a = lurek.animation.new()
            a:addFrame(0, 0, 16, 16)
            a:addClip("idle", {0}, 12, false)
            expect_equal(1, a:getClipCount())
        end)
    end)

    -- @description Covers suite: play() / stop().
    describe("play() / stop()", function()
        -- @covers lurek.animation.new
        -- @covers lurek.animation.addFrame
        -- @covers lurek.animation.addClip
        -- @covers lurek.animation.play
        -- @covers lurek.animation.isPlaying
        -- @description Confirms play() succeeds for a valid clip and flips isPlaying() to true.
        it("play transitions isPlaying to true", function()
            local a = lurek.animation.new()
            a:addFrame(0, 0, 16, 16)
            a:addClip("idle", {0}, 12, true)
            local ok = a:play("idle")
            expect_equal(true, ok)
            expect_equal(true, a:isPlaying())
        end)

        -- @covers lurek.animation.new
        -- @covers lurek.animation.play
        -- @description Verifies play() returns false instead of starting playback when the clip name is unknown.
        it("play returns false for unknown clip", function()
            local a = lurek.animation.new()
            local ok = a:play("nonexistent")
            expect_equal(false, ok)
        end)

        -- @covers lurek.animation.new
        -- @covers lurek.animation.addFrame
        -- @covers lurek.animation.addClip
        -- @covers lurek.animation.play
        -- @covers lurek.animation.stop
        -- @covers lurek.animation.isPlaying
        -- @description Confirms stop() halts an active clip and makes isPlaying() report false again.
        it("stop makes isPlaying false", function()
            local a = lurek.animation.new()
            a:addFrame(0, 0, 16, 16)
            a:addClip("run", {0}, 12, true)
            a:play("run")
            a:stop()
            expect_equal(false, a:isPlaying())
        end)
    end)

    -- @description Covers suite: setSpeed() / getSpeed().
    describe("setSpeed() / getSpeed()", function()
        -- @covers lurek.animation.new
        -- @covers lurek.animation.setSpeed
        -- @covers lurek.animation.getSpeed
        -- @description Verifies setSpeed() persists the requested playback speed for later reads.
        it("round-trips the speed value", function()
            local a = lurek.animation.new()
            a:setSpeed(2.5)
            expect_near(2.5, a:getSpeed(), 0.001)
        end)
    end)

    -- @description Covers suite: update() + getQuad().
    describe("update() + getQuad()", function()
        -- @covers lurek.animation.new
        -- @covers lurek.animation.addFrame
        -- @covers lurek.animation.addClip
        -- @covers lurek.animation.play
        -- @covers lurek.animation.update
        -- @covers lurek.animation.getQuad
        -- @description Confirms update() prepares the current frame quad once a valid clip is playing.
        it("getQuad returns a table after play + update", function()
            local a = lurek.animation.new()
            a:addFrame(0, 0, 32, 32)
            a:addClip("idle", {0}, 12, true)
            a:play("idle")
            a:update(0.0)
            local q = a:getQuad()
            expect_type("table", q)
            expect_type("number", q.x)
            expect_type("number", q.y)
            expect_type("number", q.w)
            expect_type("number", q.h)
        end)

        -- @covers lurek.animation.new
        -- @covers lurek.animation.getQuad
        -- @description Verifies getQuad() returns nil when no clip is currently playing.
        it("getQuad returns nil when not playing", function()
            local a = lurek.animation.new()
            local q = a:getQuad()
            expect_equal(nil, q)
        end)
    end)

    -- @description Covers suite: pollEvents().
    describe("pollEvents()", function()
        -- @covers lurek.animation.new
        -- @covers lurek.animation.pollEvents
        -- @description Confirms pollEvents() always returns a Lua table, even when no events are pending.
        it("returns a table", function()
            local a = lurek.animation.new()
            local evs = a:pollEvents()
            expect_type("table", evs)
        end)

        -- @covers lurek.animation.new
        -- @covers lurek.animation.pollEvents
        -- @description Verifies idle animations produce an empty event queue.
        it("returns empty table when idle", function()
            local a = lurek.animation.new()
            local evs = a:pollEvents()
            expect_equal(0, #evs)
        end)
    end)

    -- â”€â”€ pause / resume â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    -- @description Covers suite: pause and resume.
    describe("pause and resume", function()
        -- @covers lurek.animation.new
        -- @covers lurek.animation.addFrame
        -- @covers lurek.animation.addClip
        -- @covers lurek.animation.play
        -- @covers lurek.animation.pause
        -- @covers lurek.animation.isPlaying
        -- @covers lurek.animation.getCurrentFrame
        -- @covers lurek.animation.update
        -- @description Verifies pause() freezes playback state so update() no longer advances the current frame.
        it("pause stops advancement", function()
            local a = lurek.animation.new()
            a:addFrame(0, 0, 16, 16)
            a:addFrame(16, 0, 16, 16)
            a:addClip("walk", {0, 1}, 10, true)
            a:play("walk")
            a:pause()
            expect_false(a:isPlaying())
            local f_before = a:getCurrentFrame()
            a:update(1.0)
            expect_equal(f_before, a:getCurrentFrame())
        end)

        -- @covers lurek.animation.new
        -- @covers lurek.animation.addFrame
        -- @covers lurek.animation.addClip
        -- @covers lurek.animation.play
        -- @covers lurek.animation.pause
        -- @covers lurek.animation.resume
        -- @covers lurek.animation.isPlaying
        -- @covers lurek.animation.getCurrentFrame
        -- @description Confirms resume() restarts playback without rewinding the paused frame index.
        it("resume continues from paused frame", function()
            local a = lurek.animation.new()
            a:addFrame(0, 0, 16, 16)
            a:addFrame(16, 0, 16, 16)
            a:addClip("walk", {0, 1}, 10, true)
            a:play("walk")
            a:pause()
            local f_paused = a:getCurrentFrame()
            a:resume()
            expect_true(a:isPlaying())
            expect_equal(f_paused, a:getCurrentFrame())
        end)
    end)

    -- â”€â”€ setFrame â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    -- @description Covers suite: setFrame.
    describe("setFrame", function()
        -- @covers lurek.animation.new
        -- @covers lurek.animation.addFrame
        -- @covers lurek.animation.addClip
        -- @covers lurek.animation.play
        -- @covers lurek.animation.setFrame
        -- @covers lurek.animation.getCurrentFrame
        -- @description Verifies setFrame() jumps playback to the requested frame index inside the active clip.
        it("sets playback to a specific frame index", function()
            local a = lurek.animation.new()
            a:addFrame(0, 0, 16, 16)
            a:addFrame(16, 0, 16, 16)
            a:addFrame(32, 0, 16, 16)
            a:addClip("run", {0, 1, 2}, 10, false)
            a:play("run")
            a:setFrame(2)
            expect_equal(2, a:getCurrentFrame())
        end)
    end)

    -- â”€â”€ getCurrentFrame â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    -- @description Covers suite: getCurrentFrame.
    describe("getCurrentFrame", function()
        -- @covers lurek.animation.new
        -- @covers lurek.animation.addFrame
        -- @covers lurek.animation.addClip
        -- @covers lurek.animation.play
        -- @covers lurek.animation.getCurrentFrame
        -- @description Confirms a freshly started clip begins on frame 0.
        it("returns 0 at start of clip", function()
            local a = lurek.animation.new()
            a:addFrame(0, 0, 16, 16)
            a:addFrame(16, 0, 16, 16)
            a:addClip("idle", {0, 1}, 10, true)
            a:play("idle")
            expect_equal(0, a:getCurrentFrame())
        end)
    end)

    -- â”€â”€ isLooping â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    -- @description Covers suite: isLooping.
    describe("isLooping", function()
        -- @covers lurek.animation.new
        -- @covers lurek.animation.addFrame
        -- @covers lurek.animation.addClip
        -- @covers lurek.animation.play
        -- @covers lurek.animation.isLooping
        -- @description Verifies isLooping() reports true for a looping clip definition.
        it("returns true for looping clip", function()
            local a = lurek.animation.new()
            a:addFrame(0, 0, 16, 16)
            a:addClip("idle", {0}, 10, true)
            a:play("idle")
            expect_true(a:isLooping())
        end)

        -- @covers lurek.animation.new
        -- @covers lurek.animation.addFrame
        -- @covers lurek.animation.addClip
        -- @covers lurek.animation.play
        -- @covers lurek.animation.isLooping
        -- @description Verifies isLooping() reports false for a non-looping clip definition.
        it("returns false for non-looping clip", function()
            local a = lurek.animation.new()
            a:addFrame(0, 0, 16, 16)
            a:addClip("once", {0}, 10, false)
            a:play("once")
            expect_false(a:isLooping())
        end)
    end)

    -- â”€â”€ event lifecycle â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    -- @description Covers suite: event lifecycle.
    describe("event lifecycle", function()
        -- @covers lurek.animation.new
        -- @covers lurek.animation.addFrame
        -- @covers lurek.animation.addClip
        -- @covers lurek.animation.play
        -- @covers lurek.animation.update
        -- @covers lurek.animation.pollEvents
        -- @description Confirms a non-looping clip emits a finished event after advancing past its final frame.
        it("non-looping clip emits Finished event", function()
            local a = lurek.animation.new()
            a:addFrame(0, 0, 16, 16)
            a:addClip("once", {0}, 10, false)
            a:play("once")
            a:update(1.0) -- well past single frame
            local evs = a:pollEvents()
            local found = false
            for _, e in ipairs(evs) do
                if e.type == "finished" then found = true end
            end
            expect_true(found, "expected Finished event")
        end)

        -- @covers lurek.animation.new
        -- @covers lurek.animation.addFrame
        -- @covers lurek.animation.addClip
        -- @covers lurek.animation.play
        -- @covers lurek.animation.update
        -- @covers lurek.animation.pollEvents
        -- @description Confirms a looping clip emits a looped event after playback wraps to the start.
        it("looping clip emits Looped event", function()
            local a = lurek.animation.new()
            a:addFrame(0, 0, 16, 16)
            a:addClip("loop", {0}, 10, true)
            a:play("loop")
            a:update(1.0) -- enough to loop
            local evs = a:pollEvents()
            local found = false
            for _, e in ipairs(evs) do
                if e.type == "looped" then found = true end
            end
            expect_true(found, "expected Looped event")
        end)

        -- @covers lurek.animation.new
        -- @covers lurek.animation.addFrame
        -- @covers lurek.animation.addClip
        -- @covers lurek.animation.play
        -- @covers lurek.animation.update
        -- @covers lurek.animation.pollEvents
        -- @description Verifies pollEvents() drains queued playback events so a second poll is empty.
        it("pollEvents drains events", function()
            local a = lurek.animation.new()
            a:addFrame(0, 0, 16, 16)
            a:addClip("once", {0}, 10, false)
            a:play("once")
            a:update(1.0)
            a:pollEvents() -- drain
            local evs2 = a:pollEvents()
            expect_equal(0, #evs2)
        end)
    end)

    -- â”€â”€ speed edge cases â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    -- @description Covers suite: speed edge cases.
    describe("speed edge cases", function()
        -- @covers lurek.animation.new
        -- @covers lurek.animation.addFrame
        -- @covers lurek.animation.addClip
        -- @covers lurek.animation.play
        -- @covers lurek.animation.setSpeed
        -- @covers lurek.animation.update
        -- @covers lurek.animation.getCurrentFrame
        -- @description Confirms a playback speed of 0 freezes the current frame across update() calls.
        it("speed 0 freezes playback", function()
            local a = lurek.animation.new()
            a:addFrame(0, 0, 16, 16)
            a:addFrame(16, 0, 16, 16)
            a:addClip("walk", {0, 1}, 10, true)
            a:play("walk")
            a:setSpeed(0)
            local f0 = a:getCurrentFrame()
            a:update(1.0)
            expect_equal(f0, a:getCurrentFrame())
        end)

        -- @covers lurek.animation.new
        -- @covers lurek.animation.setSpeed
        -- @covers lurek.animation.getSpeed
        -- @description Verifies negative speed inputs are clamped so the stored speed never goes below zero.
        it("setSpeed clamps negative to 0", function()
            local a = lurek.animation.new()
            a:setSpeed(-5)
            expect_true(a:getSpeed() >= 0)
        end)
    end)

    -- â”€â”€ clip switching â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    -- @description Covers suite: clip switching.
    describe("clip switching", function()
        -- @covers lurek.animation.new
        -- @covers lurek.animation.addFrame
        -- @covers lurek.animation.addClip
        -- @covers lurek.animation.play
        -- @covers lurek.animation.update
        -- @covers lurek.animation.getCurrentFrame
        -- @description Confirms starting a different clip resets playback to the new clip's first frame.
        it("switching clips resets frame to 0", function()
            local a = lurek.animation.new()
            a:addFrame(0, 0, 16, 16)
            a:addFrame(16, 0, 16, 16)
            a:addClip("a", {0, 1}, 10, true)
            a:addClip("b", {0, 1}, 10, true)
            a:play("a")
            a:update(0.5)
            a:play("b")
            expect_equal(0, a:getCurrentFrame())
        end)
    end)

    -- â”€â”€ addClipFromGrid â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    -- @description Covers suite: addClipFromGrid.
    describe("addClipFromGrid", function()
        -- @covers lurek.animation.new
        -- @covers lurek.animation.addClipFromGrid
        -- @covers lurek.animation.getClipCount
        -- @covers lurek.animation.getFrameCount
        -- @description Verifies addClipFromGrid() creates both the clip entry and its backing frames in one call.
        it("creates clip from grid in one call", function()
            local a = lurek.animation.new()
            expect_no_error(function()
                a:addClipFromGrid("walk", 128, 128, 32, 32, 0, 4, 12, true)
            end)
            expect_equal(1, a:getClipCount())
            expect_equal(4, a:getFrameCount())
        end)
    end)

    -- â”€â”€ frame advancement precision â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    -- @description Covers suite: frame advancement.
    describe("frame advancement", function()
        -- @covers lurek.animation.new
        -- @covers lurek.animation.addFrame
        -- @covers lurek.animation.addClip
        -- @covers lurek.animation.play
        -- @covers lurek.animation.update
        -- @covers lurek.animation.getCurrentFrame
        -- @description Confirms update(0) leaves the current frame unchanged.
        it("zero dt does not advance frame", function()
            local a = lurek.animation.new()
            a:addFrame(0, 0, 16, 16)
            a:addFrame(16, 0, 16, 16)
            a:addClip("walk", {0, 1}, 10, true)
            a:play("walk")
            a:update(0)
            expect_equal(0, a:getCurrentFrame())
        end)
    end)
end)

test_summary()
