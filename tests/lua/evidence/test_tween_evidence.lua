-- Evidence tests: tween module
-- Evidence validates lurek.tween interpolation and control flow.

local OUT = "tests/output/tween/"

-- @describe Evidence: lurek.tween API
describe("Evidence: lurek.tween API", function()
    before_each(function()
        ensure_evidence_dir("tween")
    end)

    -- @evidence file
    it("TXT: property tween progression", function()
        local target = { x = 0, y = 0 }
        local tw = lurek.tween.tween(1.0, target, { x = 100, y = 50 }, "inOutQuad")

        for _ = 1, 30 do
            lurek.tween.update(1 / 60)
        end

        local mid_x, mid_y = target.x, target.y
        expect_true(mid_x > 0)
        expect_true(mid_y > 0)

        for _ = 1, 60 do
            lurek.tween.update(1 / 60)
        end

        local path = OUT .. "tween_progression.txt"
        local lines = {
            "mid_x=" .. tostring(mid_x),
            "mid_y=" .. tostring(mid_y),
            "end_x=" .. tostring(target.x),
            "end_y=" .. tostring(target.y),
        }
        lurek.filesystem.write(path, table.concat(lines, "\n") .. "\n")
        expect_evidence_created(path)
    end)

    -- @evidence file
    it("TXT: pause and resume", function()
        local target = { x = 0 }
        local tw = lurek.tween.tween(1.0, target, { x = 100 }, "linear")

        for _ = 1, 15 do
            lurek.tween.update(1 / 60)
        end
        tw:pause()
        local paused_x = target.x

        for _ = 1, 20 do
            lurek.tween.update(1 / 60)
        end
        local still_paused_x = target.x
        expect_near(paused_x, still_paused_x, 0.001)

        tw:resume()
        for _ = 1, 60 do
            lurek.tween.update(1 / 60)
        end

        local path = OUT .. "tween_pause_resume.txt"
        local lines = {
            "paused_x=" .. tostring(paused_x),
            "still_paused_x=" .. tostring(still_paused_x),
            "end_x=" .. tostring(target.x),
        }
        lurek.filesystem.write(path, table.concat(lines, "\n") .. "\n")
        expect_evidence_created(path)
    end)

    -- @evidence file
    it("TXT: sequence execution", function()
        local target = { x = 0 }
        local seq = lurek.tween.sequence()
        seq:tween(0.3, target, { x = 30 }, "linear")
        seq:delay(0.1)
        seq:tween(0.3, target, { x = 60 }, "linear")
        seq:start()

        for _ = 1, 80 do
            lurek.tween.update(1 / 60)
        end

        local path = OUT .. "tween_sequence.txt"
        lurek.filesystem.write(path, "end_x=" .. tostring(target.x) .. "\n")
        expect_evidence_created(path)
    end)
end)

test_summary()
