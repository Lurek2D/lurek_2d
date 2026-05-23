-- Evidence tests: cellular_sand module
-- Evidence comes from lurek.procgen.cellularAutomata outputs.
-- @covers lurek.filesystem.write
-- @covers lurek.image.newImageData
-- @covers lurek.image.savePNG
-- @covers lurek.procgen.cellularAutomata


local OUT = "tests/output/cellular_sand/"

local function save_map_png(data, w, h, path)
    local img = lurek.image.newImageData(w, h)
    for y = 0, h - 1 do
        for x = 0, w - 1 do
            local v = data[y * w + x + 1] or 0
            if v == 1 then
                img:setPixel(x, y, 24, 24, 26, 255)
            else
                img:setPixel(x, y, 205, 205, 198, 255)
            end
        end
    end
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
end

-- @describe evidence: cellular_sand
describe("evidence: cellular_sand", function()
    before_each(function()
        ensure_evidence_dir("cellular_sand")
    end)

    -- @evidence file
    it("generates cave map PNG + stats", function()
        local w, h = 64, 64
        local data = lurek.procgen.cellularAutomata(w, h, {
            wall_chance = 0.45,
            birth_limit = 5,
            survival_limit = 4,
            iterations = 5,
        })

        expect_true(type(data) == "table")
        expect_equal(w * h, #data)

        local walls = 0
        for i = 1, #data do
            if data[i] == 1 then
                walls = walls + 1
            end
        end

        local png = OUT .. "cave_map.png"
        save_map_png(data, w, h, png)

        local txt = OUT .. "cave_map_stats.txt"
        local lines = {
            "width=" .. tostring(w),
            "height=" .. tostring(h),
            "walls=" .. tostring(walls),
            "floors=" .. tostring((w * h) - walls),
        }
        lurek.filesystem.write(txt, table.concat(lines, "\n") .. "\n")
        expect_evidence_created(txt)
    end)

    -- @evidence file
    it("generates dense map PNG", function()
        local w, h = 96, 64
        local data = lurek.procgen.cellularAutomata(w, h, {
            wall_chance = 0.62,
            birth_limit = 4,
            survival_limit = 3,
            iterations = 3,
        })

        expect_equal(w * h, #data)
        save_map_png(data, w, h, OUT .. "dense_map.png")
    end)
end)

test_summary()
