-- Evidence tests: layers module
-- Evidence is generated from lurek.image.newLayeredImage compositing APIs.

local OUT = "tests/output/layers/"

-- @describe evidence: layers
describe("evidence: layers", function()
    before_each(function()
        ensure_evidence_dir("layers")
    end)

    -- @evidence file
    it("PNG: merged three-layer scene", function()
        local w, h = 160, 120
        local layers = lurek.image.newLayeredImage(w, h)

        local bg_idx = layers:addLayer("background")
        local bg = layers:getLayer(bg_idx)
        bg:fill(100, 150, 220, 255)

        local mg_idx = layers:addLayer("midground")
        local mg = layers:getLayer(mg_idx)
        mg:fill(0, 0, 0, 0)
        mg:drawRect(0, 80, w, 40, 60, 160, 60, 255)

        local fg_idx = layers:addLayer("foreground")
        local fg = layers:getLayer(fg_idx)
        fg:fill(0, 0, 0, 0)
        fg:drawCircle(80, 70, 18, 220, 60, 60, 255)

        local merged = layers:merge()
        local path = OUT .. "merged_layers.png"
        lurek.image.savePNG(merged, path)
        expect_evidence_created(path)
    end)

    -- @evidence file
    it("PNG: opacity and visibility", function()
        local w, h = 160, 120
        local layers = lurek.image.newLayeredImage(w, h)

        local a_idx = layers:addLayer("alpha_layer")
        layers:getLayer(a_idx):fill(200, 80, 80, 255)

        local b_idx = layers:addLayer("hidden_layer")
        layers:getLayer(b_idx):fill(80, 200, 80, 255)
        layers:setVisible(b_idx, false)
        expect_false(layers:isVisible(b_idx))

        local c_idx = layers:addLayer("half_opaque")
        layers:getLayer(c_idx):fill(80, 80, 200, 255)
        layers:setOpacity(c_idx, 0.5)
        expect_true(math.abs(layers:getOpacity(c_idx) - 0.5) < 0.01)

        local merged = layers:merge()
        local path = OUT .. "opacity_visibility.png"
        lurek.image.savePNG(merged, path)
        expect_evidence_created(path)
    end)

    -- @evidence file
    it("LIMG: swap and save", function()
        local layers = lurek.image.newLayeredImage(64, 64)
        local i1 = layers:addLayer("first")
        layers:getLayer(i1):fill(255, 0, 0, 255)
        local i2 = layers:addLayer("second")
        layers:getLayer(i2):fill(0, 0, 255, 255)
        layers:swapLayers(i1, i2)

        local path = OUT .. "swapped.limg"
        layers:save(path)
        expect_evidence_created(path)
    end)
end)

test_summary()
