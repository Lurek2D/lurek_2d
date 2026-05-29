-- tests/lua/unit/test_beat_clock_unit.lua
-- lurek.audio.newBeatClock unit tests (TST-06)

local T = ...
local audio = lurek.audio

T.group("lurek.audio.newBeatClock", function()
    T.test("creates clock at given bpm", function()
        local bc = audio.newBeatClock(120.0, 4)
        T.assert_equal(bc:bpm(), 120.0)
        T.assert_equal(bc:beatsPerBar(), 4)
    end)

    T.test("starts stopped, no crossings on tick", function()
        local bc = audio.newBeatClock(120.0)
        local crossings = bc:tick(1.0)
        T.assert_equal(#crossings, 0, "stopped clock must not tick")
    end)

    T.test("start / tick produces beat crossings at 60 bpm", function()
        local bc = audio.newBeatClock(60.0, 4)
        bc:start()
        -- At 60 bpm, 1 beat = 1 second
        -- tick(2.5) => crosses beats 1 and 2
        local crossings = bc:tick(2.5)
        T.assert_equal(#crossings, 2)
    end)

    T.test("position fields are present", function()
        local bc = audio.newBeatClock(120.0, 4)
        bc:start()
        bc:tick(0.5)
        local pos = bc:position()
        T.assert_not_nil(pos.beat)
        T.assert_not_nil(pos.bar)
        T.assert_not_nil(pos.beat_in_bar)
        T.assert_not_nil(pos.phase)
    end)

    T.test("stop pauses the clock", function()
        local bc = audio.newBeatClock(120.0, 4)
        bc:start()
        bc:tick(0.5)
        bc:stop()
        local b1 = bc:position().beat
        bc:tick(1.0)
        local b2 = bc:position().beat
        T.assert_equal(b1, b2, "stopped clock must not advance")
    end)

    T.test("reset clears elapsed time", function()
        local bc = audio.newBeatClock(120.0)
        bc:start()
        bc:tick(2.0)
        bc:reset()
        T.assert_true(bc:position().beat < 0.001)
    end)

    T.test("setBpm changes rate", function()
        local bc = audio.newBeatClock(120.0)
        bc:setBpm(240.0)
        T.assert_equal(bc:bpm(), 240.0)
    end)

    T.test("setBeatsPerBar changes signature", function()
        local bc = audio.newBeatClock(120.0, 4)
        bc:setBeatsPerBar(3)
        T.assert_equal(bc:beatsPerBar(), 3)
    end)

    T.test("tap returns bpm estimate after 2 taps", function()
        local bc = audio.newBeatClock(120.0)
        bc:tap(0.0)
        local bpm = bc:tap(0.5)  -- 0.5s interval => 120 bpm
        T.assert_true(bpm > 100 and bpm < 140, "tap bpm out of range: " .. bpm)
    end)

    T.test("scheduleAt fires via drainFired", function()
        local bc = audio.newBeatClock(60.0)
        bc:start()
        bc:scheduleAt(1.0)
        bc:tick(1.1)  -- passes beat 1
        local fired = bc:drainFired()
        T.assert_equal(#fired, 1)
    end)

    T.test("every invokes callback on each crossed division step", function()
        local bc = audio.newBeatClock(60.0)
        bc:start()
        local steps = {}
        bc:every(4, function(step_index)
            steps[#steps + 1] = step_index
        end)
        bc:update(1.05)
        T.assert_true(#steps >= 4, "expected at least 4 callbacks, got " .. tostring(#steps))
    end)

    T.test("at invokes callback once when beat is crossed", function()
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

    T.test("pattern invokes callback on active slots", function()
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

    T.test("cancel stops future scheduled callbacks", function()
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

    T.test("cancelAll clears all callback schedules", function()
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

    T.test("secondsPerBeat is reciprocal of bpm", function()
        local bc = audio.newBeatClock(60.0)
        T.assert_true(math.abs(bc:secondsPerBeat() - 1.0) < 1e-6)
    end)

    T.test("quantise rounds to grid", function()
        local bc = audio.newBeatClock(120.0)
        local q = bc:quantise(1.3, 0.25)
        T.assert_true(math.abs(q - 1.25) < 1e-9 or math.abs(q - 1.5) < 1e-9)
    end)

    T.test("isRunning reflects state", function()
        local bc = audio.newBeatClock(120.0)
        T.assert_false(bc:isRunning())
        bc:start()
        T.assert_true(bc:isRunning())
        bc:stop()
        T.assert_false(bc:isRunning())
    end)

    T.test("typeOf returns LBeatClock", function()
        local bc = audio.newBeatClock(120.0)
        T.assert_true(bc:typeOf("LBeatClock"))
        T.assert_true(bc:typeOf("LObject"))
        T.assert_false(bc:typeOf("LLootTable"))
    end)

    T.test("newBeatClock accepts opts table and exposes extended position helpers", function()
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

    T.test("rampBpm updates bpm over time", function()
        local bc = audio.newBeatClock(120.0)
        bc:start()
        bc:rampBpm(180.0, 0.5)
        bc:update(0.5)
        T.assert_true(bc:getBpm() > 120.0)
    end)

    T.test("judgeBeat and global judgement windows are available", function()
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

    T.test("dump returns snapshot table", function()
        local bc = audio.newBeatClock(100.0)
        local snap = bc:dump()
        T.assert_not_nil(snap.bpm)
        T.assert_not_nil(snap.beat)
        T.assert_not_nil(snap.bar)
        T.assert_not_nil(snap.phase)
        T.assert_not_nil(snap.running)
    end)
end)

test_summary()
