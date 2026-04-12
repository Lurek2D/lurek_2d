-- test_evidence_gui.lua
-- Evidence test: lurek.ui widget system rendered via drawToImage
-- Produces: button_states.png, panel_layout.png, hud_bars.png
--
-- NOTE: UI widgets are plain Lua tables (not UserData), so all method
-- calls use DOT syntax (widget.method(args)) rather than colon syntax.

local OUT = "tests/lua/evidence/output/gui/"

-- @description: Test suite for Evidence: lurek.ui widgets via drawToImage
-- @category: describe
describe("Evidence: lurek.ui widgets via drawToImage", function()

    -- API surface checks (no PNG output) ------------------------------------

    -- @covers lurek.ui.newButton
    -- @covers lurek.ui.newLabel
    -- @covers lurek.ui.newProgressBar
    -- @description: Test case covering: newButton creates a widget table with setPosition
    -- @category: it
    it("newButton creates a widget table with setPosition", function()
        local btn = lurek.ui.newButton("Test")
        btn.setPosition(10, 20)
        local x, y = btn.getPosition()
        expect_equal(10.0, x)
        expect_equal(20.0, y)
    end)

    -- @covers lurek.ui.newLabel
    -- @covers lurek.ui.newProgressBar
    -- @covers lurek.ui.newSlider
    -- @description: Test case covering: newLabel creates a widget table with setSize
    -- @category: it
    it("newLabel creates a widget table with setSize", function()
        local lbl = lurek.ui.newLabel("Hello")
        lbl.setSize(150, 24)
        local w, h = lbl.getSize()
        expect_equal(150.0, w)
        expect_equal(24.0, h)
    end)

    -- @covers lurek.ui.newButton
    -- @covers lurek.ui.newPanel
    -- @covers lurek.ui.newProgressBar
    -- @covers lurek.ui.newSlider
    -- @description: Test case covering: newProgressBar setValue and getValue round-trip
    -- @category: it
    it("newProgressBar setValue and getValue round-trip", function()
        local bar = lurek.ui.newProgressBar(0, 100)
        bar.setValue(75)
        expect_near(75.0, bar.getValue(), 0.001)
    end)

    -- @covers lurek.ui.getRoot
    -- @covers lurek.ui.newButton
    -- @covers lurek.ui.newPanel
    -- @covers lurek.ui.newSlider
    -- @description: Test case covering: newSlider setValue and getValue round-trip
    -- @category: it
    it("newSlider setValue and getValue round-trip", function()
        local sl = lurek.ui.newSlider(0.0, 1.0)
        sl.setValue(0.4)
        expect_near(0.4, sl.getValue(), 0.001)
    end)

    -- @covers lurek.ui.getRoot
    -- @covers lurek.ui.newButton
    -- @covers lurek.ui.newPanel
    -- @description: Adds and removes a child widget on a panel to cover UI container bookkeeping without writing file evidence.
    -- @category: it
    it("newPanel addChild and getChildCount", function()
        local panel = lurek.ui.newPanel()
        local btn   = lurek.ui.newButton("Child")
        panel.addChild(btn)
        expect_equal(1, panel.getChildCount())
        panel.removeChild(btn)
        expect_equal(0, panel.getChildCount())
    end)

    -- @covers lurek.ui.getRoot
    -- @description: Reads and mutates the root widget dimensions to prove the singleton root behaves like a normal widget table.
    -- @category: it
    it("getRoot returns a valid widget table", function()
        local root = lurek.ui.getRoot()
        root.setSize(800, 600)
        local w, h = root.getSize()
        expect_equal(800.0, w)
        expect_equal(600.0, h)
    end)

    -- PNG evidence ---------------------------------------------------------

    -- @covers lurek.ui.drawToImage
    -- @covers lurek.ui.getRoot
    -- @covers lurek.ui.newButton
    -- @covers lurek.ui.newLabel
    -- @evidence file
    -- @description: Renders enabled and disabled buttons with a label into one PNG to prove the widget tree rasterizes through drawToImage.
    -- @category: it
    it("PNG: button_states.png -- button and label widgets via drawToImage", function()
        local root = lurek.ui.getRoot()
        local W, H = 300, 80

        local b1 = lurek.ui.newButton("Normal")
        b1.setPosition(10, 10)
        b1.setSize(120, 28)
        root.addChild(b1)

        local b2 = lurek.ui.newButton("Disabled")
        b2.setPosition(160, 10)
        b2.setSize(120, 28)
        b2.setEnabled(false)
        root.addChild(b2)

        local lbl = lurek.ui.newLabel("UI button widget evidence")
        lbl.setPosition(10, 50)
        lbl.setSize(280, 20)
        root.addChild(lbl)

        local img = lurek.ui.drawToImage(W, H)
        lurek.img.savePNG(img, OUT .. "button_states.png")
        expect_evidence_created(OUT .. "button_states.png")

        root.removeChild(lbl)
        root.removeChild(b2)
        root.removeChild(b1)
    end)

    -- @covers lurek.ui.drawToImage
    -- @covers lurek.ui.getRoot
    -- @covers lurek.ui.newProgressBar
    -- @evidence file
    -- @description: Renders three progress bars at different fill levels to produce HUD-style bar evidence in one PNG.
    -- @category: it
    it("PNG: hud_bars.png -- progress bar widgets via drawToImage", function()
        local root = lurek.ui.getRoot()
        local W, H = 220, 90

        local hp = lurek.ui.newProgressBar(0, 100)
        hp.setPosition(10, 10)
        hp.setSize(200, 18)
        hp.setValue(80)
        root.addChild(hp)

        local mp = lurek.ui.newProgressBar(0, 100)
        mp.setPosition(10, 36)
        mp.setSize(200, 18)
        mp.setValue(55)
        root.addChild(mp)

        local sp = lurek.ui.newProgressBar(0, 100)
        sp.setPosition(10, 62)
        sp.setSize(200, 18)
        sp.setValue(30)
        root.addChild(sp)

        local img = lurek.ui.drawToImage(W, H)
        lurek.img.savePNG(img, OUT .. "hud_bars.png")
        expect_evidence_created(OUT .. "hud_bars.png")

        root.removeChild(sp)
        root.removeChild(mp)
        root.removeChild(hp)
    end)

    -- @covers lurek.ui.drawToImage
    -- @covers lurek.ui.getRoot
    -- @covers lurek.ui.newButton
    -- @covers lurek.ui.newLabel
    -- @covers lurek.ui.newPanel
    -- @covers lurek.ui.newSlider
    -- @evidence file
    -- @description: Builds a nested panel layout with several child widget types and saves the composed UI tree as PNG evidence.
    -- @category: it
    it("PNG: panel_layout.png -- panel with nested button, label, slider", function()
        local root = lurek.ui.getRoot()
        local W, H = 210, 160

        local panel = lurek.ui.newPanel()
        panel.setPosition(10, 10)
        panel.setSize(190, 140)
        root.addChild(panel)

        local title = lurek.ui.newLabel("Panel Layout")
        title.setPosition(20, 20)
        title.setSize(150, 22)
        panel.addChild(title)

        local btn = lurek.ui.newButton("Action")
        btn.setPosition(20, 50)
        btn.setSize(140, 28)
        panel.addChild(btn)

        local slider = lurek.ui.newSlider(0, 100)
        slider.setPosition(20, 90)
        slider.setSize(140, 22)
        slider.setValue(60)
        panel.addChild(slider)

        local img = lurek.ui.drawToImage(W, H)
        lurek.img.savePNG(img, OUT .. "panel_layout.png")
        expect_evidence_created(OUT .. "panel_layout.png")

        root.removeChild(panel)
    end)

end)

test_summary()
