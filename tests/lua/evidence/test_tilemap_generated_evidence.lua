-- Evidence tests: additional tilemap cases
-- Artifacts are generated through lurek.tilemap drawToImage and map APIs.


local OUT = "tests/output/tilemap/"

-- @describe Evidence: additional lurek.tilemap API
describe("Evidence: additional lurek.tilemap API", function()
    before_each(function()
        ensure_evidence_dir("tilemap")
    end)

    local function save_tm(tm, tile_size, name)
        local img = tm:drawToImage(tile_size)
        local path = OUT .. name
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end

    -- @evidence file
    it("TM01 PNG: autotile 8-neighbor", function()
        local ts = lurek.tilemap.newTileSet(1, 128, 8, 16, 16)
        for mask = 0, 255 do
            ts:setAutoTileRule8("terrain8", mask, (mask % 16) + 1)
        end

        local tm = lurek.tilemap.newTileMap(16, 16)
        tm:addTileSet(ts)
        local layer = tm:addLayer("auto8", 12, 10)
        tm:fill(layer, 0)
        for y = 2, 9 do
            for x = 2, 11 do
                tm:setTile(layer, x, y, 1)
            end
        end
        tm:applyAutoTile8(layer, "terrain8")

        save_tm(tm, 12, "tm01_autotile8.png")
    end)

    -- @evidence file
    it("TM02 PNG: per-tile tint", function()
        local tm = lurek.tilemap.newTileMap(16, 16)
        local layer = tm:addLayer("tint", 10, 10)
        tm:fill(layer, 2)

        for y = 1, 10 do
            for x = 1, 10 do
                local t = (x + y) / 20
                tm:setTileTint(layer, x, y, 0.5 + t * 0.5, 0.4 + t * 0.4, 0.8, 1.0)
            end
        end

        save_tm(tm, 12, "tm02_tile_tint.png")
    end)

    -- @evidence file
    it("TM03 PNG: viewport crop", function()
        local tm = lurek.tilemap.newTileMap(8, 8)
        local layer = tm:addLayer("world", 30, 20)

        for y = 1, 20 do
            for x = 1, 30 do
                tm:setTile(layer, x, y, ((x * 5 + y * 3) % 6) + 1)
            end
        end

        tm:setViewport(48, 24, 96, 64)
        save_tm(tm, 8, "tm03_viewport_crop.png")
    end)

    -- @evidence file
    it("TM04 PNG: layer visibility toggle", function()
        local tm = lurek.tilemap.newTileMap(16, 16)
        local base = tm:addLayer("base", 12, 8)
        local deco = tm:addLayer("deco", 12, 8)

        tm:fill(base, 1)
        tm:fill(deco, 0)
        for x = 2, 11 do
            tm:setTile(deco, x, 4, 7)
        end

        tm:setLayerVisible(deco, false)
        save_tm(tm, 14, "tm04_layer_hidden.png")

        tm:setLayerVisible(deco, true)
        save_tm(tm, 14, "tm04_layer_visible.png")
    end)

    -- @evidence file
    it("TM05 PNG: orientation staggered", function()
        local tm = lurek.tilemap.newTileMap(16, 16)
        tm:setOrientation("staggered")
        local layer = tm:addLayer("staggered", 10, 8)
        tm:fill(layer, 1)
        for y = 1, 8 do
            for x = 1, 10 do
                if (x + y) % 2 == 0 then
                    tm:setTile(layer, x, y, 4)
                end
            end
        end
        save_tm(tm, 12, "tm05_staggered.png")
    end)
end)

test_summary()
