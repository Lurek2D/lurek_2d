-- Lurek2D Stress Test: Timer Operations
-- Measures timer query throughput under heavy polling.

-- @describe stress: timer query throughput
describe("stress: timer query throughput", function()
    -- @stress lurek.timer.getTime
    it("getTime called 100000 times in <5s", function()
        local COUNT   = 100000
        local elapsed = measure("timer.getTime x" .. COUNT, COUNT, function()
            local _ = lurek.timer.getTime()
        end)
        expect_true(elapsed < 5.0, "getTime budget: " .. elapsed .. "s")
    end)

    -- @stress lurek.timer.getDelta
    it("getDelta called 100000 times in <5s", function()
        local COUNT   = 100000
        local elapsed = measure("timer.getDelta x" .. COUNT, COUNT, function()
            local _ = lurek.timer.getDelta()
        end)
        expect_true(elapsed < 5.0, "getDelta budget: " .. elapsed .. "s")
    end)

    -- @stress lurek.timer.getFPS
    it("getFPS called 100000 times in <5s", function()
        local COUNT   = 100000
        local elapsed = measure("timer.getFPS x" .. COUNT, COUNT, function()
            local _ = lurek.timer.getFPS()
        end)
        expect_true(elapsed < 5.0, "getFPS budget: " .. elapsed .. "s")
    end)

    -- @stress lurek.timer.getFrameCount
    it("getFrameCount called 100000 times in <5s", function()
        local COUNT   = 100000
        local elapsed = measure("timer.getFrameCount x" .. COUNT, COUNT, function()
            local _ = lurek.timer.getFrameCount()
        end)
        expect_true(elapsed < 5.0, "getFrameCount budget: " .. elapsed .. "s")
    end)
end)
test_summary()
