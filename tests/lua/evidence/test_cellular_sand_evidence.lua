-- Evidence tests: cellular_sand module
-- Produces PNG artifacts from lurek.procgen.cellularAutomata.
-- @module cellular_sand
-- @description Evidence suite for lurek.procgen cellular automata: cave/dungeon map generation visualised as PNG.

describe("evidence: cellular_sand", function()
    before_each(function()
        ensure_evidence_dir("cellular_sand")
    end)

    -- @covers lurek.procgen.cellularAutomata
    -- @evidence file
    -- @description Generates a 64x64 cave map via cellularAutomata and renders it to a greyscale PNG.
    it("generates a cellular automata cave map PNG", function()
        local dir  = evidence_output_dir("cellular_sand")
        local path = dir .. "cave_map.png"
        local W, H = 64, 64
        local data = lurek.procgen.cellularAutomata(W, H, {
            wall_chance   = 0.45,
            birth_limit   = 5,
            survival_limit = 4,
            iterations    = 5,
        })
        assert(type(data) == "table", "cellularAutomata must return a table")
        assert(#data == W * H, "data length must equal W*H (" .. W * H .. "), got " .. #data)
        local img = lurek.image.newImageData(W, H)
        for y = 0, H - 1 do
            for x = 0, W - 1 do
                local v = data[y * W + x + 1]
                if v == 1 then
                    img:setPixel(x, y, 20,  20,  20,  255) -- wall: dark
                else
                    img:setPixel(x, y, 200, 200, 200, 255) -- floor: light
                end
            end
        end
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- @covers lurek.procgen.cellularAutomata
    -- @evidence file
    -- @description Generates a 96x64 cellular automata map with high wall density and renders it.
    it("generates a high-density cellular automata map PNG", function()
        local dir  = evidence_output_dir("cellular_sand")
        local path = dir .. "dense_map.png"
        local W, H = 96, 64
        local data = lurek.procgen.cellularAutomata(W, H, {
            wall_chance    = 0.62,
            birth_limit    = 4,
            survival_limit = 3,
            iterations     = 3,
        })
        assert(#data == W * H, "data length mismatch")
        local img = lurek.image.newImageData(W, H)
        for y = 0, H - 1 do
            for x = 0, W - 1 do
                local v = data[y * W + x + 1]
                if v == 1 then
                    img:setPixel(x, y, 50, 30, 10, 255)
                else
                    img:setPixel(x, y, 180, 160, 130, 255)
                end
            end
        end
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)
end)

test_summary()
