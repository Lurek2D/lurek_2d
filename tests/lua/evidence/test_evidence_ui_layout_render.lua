-- test_evidence_ui_layout_render.lua
-- Evidence test: lurek.ui.loadLayout + lurek.ui.renderToImage
--
-- This test MUST call the layout-loader domain code to produce its output.
-- Evidence contract: if src/ui/layout_loader.rs were deleted, the PNG
-- output would NOT be produced — satisfying the litmus test.
--
-- Produces:
--   tests/lua/evidence/output/ui_layout/simple_hud.png
--   tests/lua/evidence/output/ui_layout/nested_panel.png

local OUT = "tests/lua/evidence/output/ui_layout/"

-- @description Evidence tests for lurek.ui.loadLayout + renderToImage.
describe("Evidence: lurek.ui layout loader renderToImage", function()

    -- @covers lurek.ui.loadLayout
    -- @covers lurek.ui.renderToImage
    -- @evidence file
    -- @description Renders a simple HUD-style layout (label + button + progress
    -- bar) to PNG via renderToImage to prove the layout loader produces visible
    -- widget rectangles.
    it("PNG: simple_hud.png -- label, button, progressbar via loadLayout", function()
        local W, H = 320, 120
        lurek.ui.loadLayout({
            type    = "panel",
            x = 0, y = 0, w = W, h = H,
            children = {
                { type = "label",       text = "HP",       x = 10,  y = 10, w = 80,  h = 24 },
                { type = "progressbar", min = 0, max = 100, value = 75,
                  x = 100, y = 10, w = 200, h = 24 },
                { type = "label",       text = "MP",       x = 10,  y = 46, w = 80,  h = 24 },
                { type = "progressbar", min = 0, max = 100, value = 40,
                  x = 100, y = 46, w = 200, h = 24 },
                { type = "button",      text = "Attack",   x = 10,  y = 82, w = 100, h = 28 },
                { type = "button",      text = "Defend",   x = 120, y = 82, w = 100, h = 28 },
            }
        })
        lurek.ui.renderToImage(W, H, OUT .. "simple_hud.png")
        expect_evidence_created(OUT .. "simple_hud.png")
    end)

    -- @covers lurek.ui.loadLayout
    -- @covers lurek.ui.renderToImage
    -- @evidence file
    -- @description Renders a nested-panel layout (panel containing a label,
    -- slider, and checkbox) to PNG to prove recursive child loading works
    -- end-to-end through renderToImage.
    it("PNG: nested_panel.png -- nested panel with slider and checkbox", function()
        local W, H = 280, 200
        lurek.ui.loadLayout({
            type = "panel",
            x = 0, y = 0, w = W, h = H,
            children = {
                {
                    type = "panel",
                    x = 10, y = 10, w = 260, h = 170,
                    children = {
                        { type = "label",    text = "Volume",  x = 10, y = 10, w = 80,  h = 22 },
                        { type = "slider",   min = 0, max = 100, value = 60,
                          x = 100, y = 10, w = 140, h = 22 },
                        { type = "label",    text = "Mute",    x = 10, y = 50, w = 80,  h = 22 },
                        { type = "checkbox", text = "Mute",    checked = false,
                          x = 100, y = 50, w = 100, h = 22 },
                        { type = "button",   text = "Apply",   x = 10, y = 100, w = 100, h = 30 },
                    }
                }
            }
        })
        lurek.ui.renderToImage(W, H, OUT .. "nested_panel.png")
        expect_evidence_created(OUT .. "nested_panel.png")
    end)

end)

test_summary()
