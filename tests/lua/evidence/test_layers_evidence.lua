-- Evidence tests: layers module
-- Produces PNG artifacts from lurek.image.newLayeredImage layer compositing.
-- @module layers
-- @description Evidence suite for lurek.image.LayeredImage: addLayer, getLayer, merge, save.

describe("evidence: layers", function()
    before_each(function()
        ensure_evidence_dir("layers")
    end)

    -- @covers lurek.image.newLayeredImage
    -- @covers LayeredImage:addLayer
    -- @covers LayeredImage:getLayer
    -- @covers LayeredImage:merge
    -- @evidence file
    -- @description Creates a three-layer image (background, midground, foreground), merges, saves PNG.
    it("produces a merged three-layer PNG", function()
        local dir  = evidence_output_dir("layers")
        local path = dir .. "merged_layers.png"
        local W, H = 160, 120
        local layers = lurek.image.newLayeredImage(W, H)

        -- Background layer: solid blue sky
        local bg_idx = layers:addLayer("background")
        local bg = layers:getLayer(bg_idx)
        bg:fill(100, 150, 220, 255)

        -- Midground layer: green ground strip
        local mg_idx = layers:addLayer("midground")
        local mg = layers:getLayer(mg_idx)
        mg:fill(0, 0, 0, 0)
        mg:drawRect(0, 80, W, 40, 60, 160, 60, 255)

        -- Foreground layer: red circle (character placeholder)
        local fg_idx = layers:addLayer("foreground")
        local fg = layers:getLayer(fg_idx)
        fg:fill(0, 0, 0, 0)
        fg:drawCircle(80, 70, 18, 220, 60, 60, 255)

        local merged = layers:merge()
        lurek.image.savePNG(merged, path)
        expect_evidence_created(path)
    end)

    -- @covers LayeredImage:addLayer
    -- @covers LayeredImage:setOpacity
    -- @covers LayeredImage:getOpacity
    -- @covers LayeredImage:setVisible
    -- @covers LayeredImage:isVisible
    -- @covers LayeredImage:merge
    -- @evidence file
    -- @description Tests layer visibility and opacity, then renders the final composited PNG.
    it("produces a composited image respecting opacity and visibility", function()
        local dir  = evidence_output_dir("layers")
        local path = dir .. "opacity_visibility.png"
        local W, H = 160, 120
        local layers = lurek.image.newLayeredImage(W, H)

        local a_idx = layers:addLayer("alpha_layer")
        local al = layers:getLayer(a_idx)
        al:fill(200, 80, 80, 255)

        local b_idx = layers:addLayer("hidden_layer")
        local bl = layers:getLayer(b_idx)
        bl:fill(80, 200, 80, 255)
        layers:setVisible(b_idx, false)
        assert(not layers:isVisible(b_idx), "hidden_layer must be not visible")

        local c_idx = layers:addLayer("half_opaque")
        local cl = layers:getLayer(c_idx)
        cl:fill(80, 80, 200, 255)
        layers:setOpacity(c_idx, 0.5)
        assert(math.abs(layers:getOpacity(c_idx) - 0.5) < 0.01, "opacity must be ~0.5")

        local merged = layers:merge()
        lurek.image.savePNG(merged, path)
        expect_evidence_created(path)
    end)

    -- @covers LayeredImage:save
    -- @covers LayeredImage:swapLayers
    -- @evidence file
    -- @description Swaps two layers and saves the LayeredImage as a .limg binary artifact.
    it("saves a .limg artifact after layer swap", function()
        local dir  = evidence_output_dir("layers")
        local path = dir .. "swapped.limg"
        local W, H = 64, 64
        local layers = lurek.image.newLayeredImage(W, H)
        local i1 = layers:addLayer("first")
        layers:getLayer(i1):fill(255, 0, 0, 255)
        local i2 = layers:addLayer("second")
        layers:getLayer(i2):fill(0, 0, 255, 255)
        layers:swapLayers(i1, i2)
        layers:save(path)
        expect_evidence_created(path)
    end)
end)

test_summary()
