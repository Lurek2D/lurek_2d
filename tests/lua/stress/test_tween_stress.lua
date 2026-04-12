-- Lurek2D Stress Test: Tween Update Throughput
-- Measures active tween update rate under heavy load.

-- @description Covers suite: stress: many active tweens updated simultaneously.
describe("stress: many active tweens updated simultaneously", function()
    -- @covers lurek.tween.newTween
    -- @covers Tween:setDuration
    -- @covers Tween:setEasing
    -- @covers Tween:setFrom
    -- @covers Tween:setTo
    -- @covers Tween:update
    -- @stress Allocates 1000 tweens and advances all of them through 100 update passes.
    -- @description Stresses bulk tween stepping by preconfiguring a large tween pool and running nested update loops over every active tween.
    it("1000 tweens Ă— 100 updates each: <5s", function()
        local N_TWEENS  = 1000
        local N_UPDATES = 100
        local tweens    = {}

        for i = 1, N_TWEENS do
            local tw = lurek.tween.newTween()
            tw:setDuration(2.0)
            tw:setEasing("linear")
            tw:setFrom(0)
            tw:setTo(i)
            tweens[i] = tw
        end

        local start = os.clock()
        for _ = 1, N_UPDATES do
            for _, tw in ipairs(tweens) do
                tw:update(0.02)
            end
        end
        local elapsed = os.clock() - start
        local ops     = N_TWEENS * N_UPDATES
        print(string.format("[STRESS] %d tween updates in %.4fs (%.0f updates/sec)",
            ops, elapsed, ops / elapsed))

        expect_true(elapsed < 5.0, "tween update budget: " .. elapsed .. "s")
    end)

    -- @covers lurek.tween.newTween
    -- @covers Tween:seek
    -- @stress Performs 5000 random seek calls on one configured tween.
    -- @description Stresses direct timeline repositioning by reusing a single tween and jumping to random normalized positions in a measured loop.
    it("5000 instant tween seek calls: <5s", function()
        local tw    = lurek.tween.newTween()
        local COUNT = 5000

        tw:setDuration(1.0)
        tw:setEasing("linear")
        tw:setFrom(0)
        tw:setTo(100)

        local elapsed = measure("tween:seek x" .. COUNT, COUNT, function()
            tw:seek(math.random())
        end)

        expect_true(elapsed < 5.0, "tween seek budget: " .. elapsed .. "s")
    end)

    -- @covers lurek.tween.newTween
    -- @covers Tween:onComplete
    -- @covers Tween:update
    -- @stress Configures 200 short tweens with callbacks and advances each one past completion once.
    -- @description Stresses callback dispatch correctness by completing many tweens in one pass and verifying every onComplete handler fires exactly once.
    it("tween onComplete callbacks fire exactly once each", function()
        local TWEENS   = 200
        local finished = 0

        local tweens = {}
        for _ = 1, TWEENS do
            local tw = lurek.tween.newTween()
            tw:setDuration(0.1)
            tw:setEasing("linear")
            tw:setFrom(0)
            tw:setTo(1)
            tw:onComplete(function() finished = finished + 1 end)
            tweens[#tweens + 1] = tw
        end

        -- Advance past end
        for _, tw in ipairs(tweens) do
            tw:update(0.2)
        end

        expect_equal(TWEENS, finished, "all onComplete callbacks fired")
    end)
end)

test_summary()
