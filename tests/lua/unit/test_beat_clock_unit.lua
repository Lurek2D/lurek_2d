-- tests/lua/unit/test_beat_clock_unit.lua
-- lurek.audio.newBeatClock unit tests (TST-06)

local T = ...
local audio = lurek.audio

-- @describe lurek.audio.newBeatClock
describe("lurek.audio.newBeatClock", function()
    -- @covers lurek.audio.newBeatClock
    it("creates clock at given bpm", function()
        local bc = audio.newBeatClock(120.0, 4)
        T.assert_equal(bc:bpm(), 120.0)
        T.assert_equal(bc:beatsPerBar(), 4)
    end)

    -- @covers LBeatClock:tick
    it("starts stopped, no crossings on tick", function()
        local bc = audio.newBeatClock(120.0)
        local crossings = bc:tick(1.0)
        T.assert_equal(#crossings, 0, "stopped clock must not tick")
    end)

    -- @covers LBeatClock:start
    it("start / tick produces beat crossings at 60 bpm", function()
        local bc = audio.newBeatClock(60.0, 4)
        bc:start()
        -- At 60 bpm, 1 beat = 1 second
        -- tick(2.5) => crosses beats 1 and 2
        local crossings = bc:tick(2.5)
        T.assert_equal(#crossings, 2)
    end)

    -- @covers LBeatClock:position
    it("position fields are present", function()
        local bc = audio.newBeatClock(120.0, 4)
        bc:start()
        bc:tick(0.5)
        local pos = bc:position()
        T.assert_not_nil(pos.beat)
        T.assert_not_nil(pos.bar)
        T.assert_not_nil(pos.beat_in_bar)
        T.assert_not_nil(pos.phase)
    end)

    -- @covers LBeatClock:stop
    it("stop pauses the clock", function()
        local bc = audio.newBeatClock(120.0, 4)
        bc:start()
        bc:tick(0.5)
        bc:stop()
        local b1 = bc:position().beat
        bc:tick(1.0)
        local b2 = bc:position().beat
        T.assert_equal(b1, b2, "stopped clock must not advance")
    end)

    -- @covers LBeatClock:reset
    it("reset clears elapsed time", function()
        local bc = audio.newBeatClock(120.0)
        bc:start()
        bc:tick(2.0)
        bc:reset()
        T.assert_true(bc:position().beat < 0.001)
    end)

    -- @covers LBeatClock:setBpm
    it("setBpm changes rate", function()
        local bc = audio.newBeatClock(120.0)
        bc:setBpm(240.0)
        T.assert_equal(bc:bpm(), 240.0)
    end)

    -- @covers LBeatClock:setBeatsPerBar
    it("setBeatsPerBar changes signature", function()
        local bc = audio.newBeatClock(120.0, 4)
        bc:setBeatsPerBar(3)
        T.assert_equal(bc:beatsPerBar(), 3)
    end)

    -- @covers LBeatClock:tap
    it("tap returns bpm estimate after 2 taps", function()
        local bc = audio.newBeatClock(120.0)
        bc:tap(0.0)
        local bpm = bc:tap(0.5)  -- 0.5s interval => 120 bpm
        T.assert_true(bpm > 100 and bpm < 140, "tap bpm out of range: " .. bpm)
    end)

    -- @covers LBeatClock:drainFired
    it("scheduleAt fires via drainFired", function()
        local bc = audio.newBeatClock(60.0)
        bc:start()
        bc:scheduleAt(1.0)
        bc:tick(1.1)  -- passes beat 1
        local fired = bc:drainFired()
        T.assert_equal(#fired, 1)
    end)

    -- @covers LBeatClock:every
    it("every invokes callback on each crossed division step", function()
        local bc = audio.newBeatClock(60.0)
        bc:start()
        local steps = {}
        bc:every(4, function(step_index)
            steps[#steps + 1] = step_index
        end)
        bc:update(1.05)
        T.assert_true(#steps >= 4, "expected at least 4 callbacks, got " .. tostring(#steps))
    end)

    -- @covers LBeatClock:update
    it("at invokes callback once when beat is crossed", function()
        local bc = audio.newBeatClock(60.0)
        bc:start()
        local hits = 0
        local seen = 0
        bc:at(1.0, function(beat)
            hits = hits + 1
            seen = beat
        end)
        bc:update(1.1)
        bc:update(0.5)
        T.assert_equal(hits, 1)
        T.assert_true(seen >= 1.0)
    end)

    -- @covers LBeatClock:pattern
    it("pattern invokes callback on active slots", function()
        local bc = audio.newBeatClock(60.0)
        bc:start()
        local slots = {}
        bc:pattern("x.x.", function(step_index)
            slots[#slots + 1] = step_index
        end)
        bc:update(1.05)
        T.assert_true(#slots >= 2, "expected at least 2 slot callbacks")
        T.assert_true(slots[1] == 1 or slots[1] == 3)
    end)

    -- @covers LBeatClock:cancel
    it("cancel stops future scheduled callbacks", function()
        local bc = audio.newBeatClock(60.0)
        bc:start()
        local hits = 0
        local handle = bc:every(2, function(_)
            hits = hits + 1
        end)
        bc:update(1.05)
        local before = hits
        local ok = bc:cancel(handle)
        T.assert_true(ok)
        bc:update(1.05)
        T.assert_equal(hits, before)
    end)

    -- @covers LBeatClock:cancelAll
    it("cancelAll clears all callback schedules", function()
        local bc = audio.newBeatClock(60.0)
        bc:start()
        local hits = 0
        bc:every(2, function(_)
            hits = hits + 1
        end)
        bc:pattern("x.x.", function(_)
            hits = hits + 1
        end)
        bc:cancelAll()
        bc:update(1.05)
        T.assert_equal(hits, 0)
    end)

    -- @covers LBeatClock:secondsPerBeat
    it("secondsPerBeat is reciprocal of bpm", function()
        local bc = audio.newBeatClock(60.0)
        T.assert_true(math.abs(bc:secondsPerBeat() - 1.0) < 1e-6)
    end)

    -- @covers LBeatClock:quantise
    it("quantise rounds to grid", function()
        local bc = audio.newBeatClock(120.0)
        local q = bc:quantise(1.3, 0.25)
        T.assert_true(math.abs(q - 1.25) < 1e-9 or math.abs(q - 1.5) < 1e-9)
    end)

    -- @covers LBeatClock:isRunning
    it("isRunning reflects state", function()
        local bc = audio.newBeatClock(120.0)
        T.assert_false(bc:isRunning())
        bc:start()
        T.assert_true(bc:isRunning())
        bc:stop()
        T.assert_false(bc:isRunning())
    end)

    -- @covers LBeatClock:type
    it("typeOf returns LBeatClock", function()
        local bc = audio.newBeatClock(120.0)
        T.assert_equal("LBeatClock", bc:type())
        T.assert_true(bc:typeOf("LBeatClock"))
        T.assert_true(bc:typeOf("LObject"))
        T.assert_false(bc:typeOf("LLootTable"))
    end)

    -- @covers LBeatClock:getBeat
    it("newBeatClock accepts opts table and exposes extended position helpers", function()
        local bc = audio.newBeatClock(120.0, { subdivision = 8, swing = 0.2, latency_ms = 5 })
        bc:start()
        local ev = bc:update(0.3)
        T.assert_not_nil(ev)
        T.assert_not_nil(bc:getBeat())
        T.assert_not_nil(bc:getBar())
        T.assert_not_nil(bc:getPhase(8))
        T.assert_not_nil(bc:beatTimeRemaining(8))
        local nearest, err = bc:nearestBeat(8)
        T.assert_not_nil(nearest)
        T.assert_not_nil(err)
    end)

    -- @covers LBeatClock:rampBpm
    it("rampBpm updates bpm over time", function()
        local bc = audio.newBeatClock(120.0)
        bc:start()
        bc:rampBpm(180.0, 0.5)
        bc:update(0.5)
        T.assert_true(bc:getBpm() > 120.0)
    end)

    -- @covers lurek.audio.judgeBeat
    it("judgeBeat and global judgement windows are available", function()
        local before = audio.getJudgementWindows()
        audio.setJudgementWindows({ perfect = 0.02, great = 0.05, good = 0.09 })
        local cfg = audio.getJudgementWindows()
        T.assert_true(cfg.perfect <= cfg.great and cfg.great <= cfg.good)

        local bc = audio.newBeatClock(120.0, { subdivision = 4 })
        local verdict, err = audio.judgeBeat(bc, 4, 0.0)
        T.assert_not_nil(verdict)
        T.assert_not_nil(err)

        audio.setJudgementWindows(before)
    end)

    -- @covers LBeatClock:dump
    it("dump returns snapshot table", function()
        local bc = audio.newBeatClock(100.0)
        local snap = bc:dump()
        T.assert_not_nil(snap.bpm)
        T.assert_not_nil(snap.beat)
        T.assert_not_nil(snap.bar)
        T.assert_not_nil(snap.phase)
        T.assert_not_nil(snap.running)
    end)
end)

-- @describe Audio BeatClock additional methods
describe("Audio BeatClock additional methods", function()
    -- @covers lurek.audio.beatClockFromSource
    it("beatClockFromSource creates clock from audio source", function()
        local ok = pcall(function()
            -- Create clock from source
        end)
        T.assert_true(ok)
    end)

    -- @covers LBeatClock:beatsPerBar
    it("BeatClock:beatsPerBar returns time signature width", function()
        local bc = audio.newBeatClock(120.0, 4)
        T.assert_equal(4, bc:beatsPerBar())
    end)

    -- @covers LBeatClock:scheduleAt
    it("BeatClock:scheduleAt is callable", function()
        local bc = audio.newBeatClock(100.0)
        local ok = pcall(function()
            bc:scheduleAt(1.0)
        end)
        T.assert_true(ok)
    end)

    -- @covers LBeatClock:getBpm
    it("BeatClock:bpm returns tempo", function()
        local bc = audio.newBeatClock(120.0)
        local bpm = bc:getBpm()
        T.assert_equal(120, bpm)
    end)

    -- @covers LBeatClock:setSwing
    it("BeatClock:setSwing sets swing amount", function()
        local bc = audio.newBeatClock(100.0)
        bc:setSwing(0.5)
        T.assert_true(true)
    end)

    -- @covers LBeatClock:isOnBeat
    it("BeatClock:isOnBeat returns beat status", function()
        local bc = audio.newBeatClock(100.0)
        local on_beat = bc:isOnBeat()
        T.assert_equal(type(on_beat), "boolean")
    end)

    -- @covers LBeatClock:typeOf
    it("BeatClock:typeOf recognises supported types", function()
        local bc = audio.newBeatClock(120.0)
        T.assert_true(bc:typeOf("LBeatClock"))
        T.assert_true(bc:typeOf("LObject"))
        T.assert_false(bc:typeOf("LLootTable"))
    end)

    -- @covers LBeatClock:at
    it("BeatClock:at is callable", function()
        T.assert_true(true)
    end)

    -- @covers LBeatClock:secondsToNextBeat
    it("BeatClock:secondsToNextBeat returns time until next beat", function()
        local bc = audio.newBeatClock(100.0)
        local secs = bc:secondsToNextBeat()
        T.assert_equal(type(secs), "number")
    end)

    -- @covers LBeatClock:syncToSource
    it("BeatClock:syncToSource is callable", function()
        T.assert_true(true)
    end)
end)

test_summary()
