-- tests/lua/unit/test_terminal.lua
-- BDD tests for the luna.terminal.* API (headless -- no GPU, no window).
--
-- NOTE: All method calls use DOT syntax (obj.method(args)) rather than
-- COLON syntax (obj:method(args)) because the terminal API registers plain
-- functions that do not accept a self parameter. This is a known API issue
-- (methods should accept self for idiomatic Lua colon-call usage).

require("tests/lua/init")

-- Module existence

describe("luna.terminal module", function()
    it("luna.terminal is a table", function()
        expect_type("table", luna.terminal)
    end)

    it("newTerminal is a function", function()
        expect_type("function", luna.terminal.newTerminal)
    end)

    it("newLabel is a function", function()
        expect_type("function", luna.terminal.newLabel)
    end)

    it("newButton is a function", function()
        expect_type("function", luna.terminal.newButton)
    end)

    it("newTextBox is a function", function()
        expect_type("function", luna.terminal.newTextBox)
    end)

    it("newList is a function", function()
        expect_type("function", luna.terminal.newList)
    end)

    it("newBorder is a function", function()
        expect_type("function", luna.terminal.newBorder)
    end)

    it("newPanel is a function", function()
        expect_type("function", luna.terminal.newPanel)
    end)
end)

-- Terminal construction

describe("luna.terminal.newTerminal", function()
    it("creates a terminal with default dimensions (80x40)", function()
        local t = luna.terminal.newTerminal()
        local cols, rows = t.getDimensions()
        expect_equal(cols, 80)
        expect_equal(rows, 40)
    end)

    it("creates a terminal with custom dimensions", function()
        local t = luna.terminal.newTerminal(40, 20)
        local cols, rows = t.getDimensions()
        expect_equal(cols, 40)
        expect_equal(rows, 20)
    end)

    it("clamps terminal dimensions to max (512x256)", function()
        local t = luna.terminal.newTerminal(1000, 500)
        local cols, rows = t.getDimensions()
        expect_equal(cols, 512)
        expect_equal(rows, 256)
    end)

    it("clamps terminal dimensions to min (1x1)", function()
        local t = luna.terminal.newTerminal(0, 0)
        local cols, rows = t.getDimensions()
        expect_equal(cols >= 1, true)
        expect_equal(rows >= 1, true)
    end)
end)

-- Cell operations

describe("Terminal cell operations", function()
    it("sets and gets a character by string", function()
        local t = luna.terminal.newTerminal(10, 5)
        t.set(1, 1, "A")
        local ch = t.get(1, 1)
        expect_equal(ch, string.byte("A"))
    end)

    it("sets and gets a character by codepoint", function()
        local t = luna.terminal.newTerminal(10, 5)
        t.set(2, 2, 66)  -- 'B'
        local ch = t.get(2, 2)
        expect_equal(ch, 66)
    end)

    it("sets cell with custom colors", function()
        local t = luna.terminal.newTerminal(10, 10)
        t.set(1, 1, "X", 1, 0, 0, 1, 0, 0, 1, 1)
        local ch, fr, fg, fb, fa, br, bg, bb, ba = t.get(1, 1)
        expect_equal(ch, string.byte("X"))
        expect_near(fr, 1.0, 0.01)
        expect_near(fg, 0.0, 0.01)
    end)

    it("clear resets all cells to space", function()
        local t = luna.terminal.newTerminal(5, 3)
        t.set(1, 1, "X")
        t.clear()
        local ch = t.get(1, 1)
        expect_equal(ch, string.byte(" "))
    end)

    it("out-of-bounds get returns default values", function()
        local t = luna.terminal.newTerminal(5, 3)
        local ch = t.get(0, 1)
        expect_equal(ch, string.byte(" "))
    end)

    it("out-of-bounds set does not crash", function()
        local t = luna.terminal.newTerminal(5, 3)
        t.set(100, 100, "X")
        expect_equal(true, true)
    end)
end)

-- Label widget

describe("TLabel widget", function()
    it("getText returns initial text", function()
        local lbl = luna.terminal.newLabel(1, 1, "Hello")
        expect_equal(lbl.getText(), "Hello")
    end)

    it("setText updates text", function()
        local lbl = luna.terminal.newLabel(1, 1, "initial")
        lbl.setText("updated")
        expect_equal(lbl.getText(), "updated")
    end)

    it("getPosition returns 1-based position", function()
        local lbl = luna.terminal.newLabel(5, 3, "x")
        local col, row = lbl.getPosition()
        expect_equal(col, 5)
        expect_equal(row, 3)
    end)

    it("setPosition updates position", function()
        local lbl = luna.terminal.newLabel(1, 1, "x")
        lbl.setPosition(10, 8)
        local col, row = lbl.getPosition()
        expect_equal(col, 10)
        expect_equal(row, 8)
    end)

    it("isVisible is true by default", function()
        local lbl = luna.terminal.newLabel(1, 1)
        expect_equal(lbl.isVisible(), true)
    end)

    it("setVisible false hides the widget", function()
        local lbl = luna.terminal.newLabel(1, 1)
        lbl.setVisible(false)
        expect_equal(lbl.isVisible(), false)
    end)

    it("isEnabled is true by default", function()
        local lbl = luna.terminal.newLabel(1, 1)
        expect_equal(lbl.isEnabled(), true)
    end)

    it("setTag and getTag roundtrip", function()
        local lbl = luna.terminal.newLabel(1, 1)
        lbl.setTag("my_label")
        expect_equal(lbl.getTag(), "my_label")
    end)
end)

-- Button widget

describe("TButton widget", function()
    it("getText returns initial text", function()
        local btn = luna.terminal.newButton(1, 1, 10, 1, "Action")
        expect_equal(btn.getText(), "Action")
    end)

    it("getSize returns expected dimensions", function()
        local btn = luna.terminal.newButton(1, 1, 10, 2, "X")
        local w, h = btn.getSize()
        expect_equal(w, 10)
        expect_equal(h, 2)
    end)

    it("setOnClick accepts a function", function()
        local btn = luna.terminal.newButton(1, 1, 5, 1, "OK")
        btn.setOnClick(function() end)
        expect_equal(true, true)
    end)
end)

-- TextBox widget

describe("TTextBox widget", function()
    it("getText returns empty string initially", function()
        local tb = luna.terminal.newTextBox(1, 1, 20)
        expect_equal(tb.getText(), "")
    end)

    it("setText and getText roundtrip", function()
        local tb = luna.terminal.newTextBox(1, 1, 20)
        tb.setText("entered text")
        expect_equal(tb.getText(), "entered text")
    end)

    it("getSize width matches constructor", function()
        local tb = luna.terminal.newTextBox(1, 1, 15)
        local w, _ = tb.getSize()
        expect_equal(w, 15)
    end)

    it("setMaxLength and getMaxLength roundtrip", function()
        local tb = luna.terminal.newTextBox(1, 1, 20)
        tb.setMaxLength(5)
        expect_equal(tb.getMaxLength(), 5)
    end)
end)

-- List widget

describe("TList widget", function()
    it("getItemCount starts at 0", function()
        local list = luna.terminal.newList(1, 1, 20, 10)
        expect_equal(list.getItemCount(), 0)
    end)

    it("addItem increases count", function()
        local list = luna.terminal.newList(1, 1, 20, 10)
        list.addItem("Sword")
        expect_equal(list.getItemCount(), 1)
    end)

    it("getItem returns correct item (1-based)", function()
        local list = luna.terminal.newList(1, 1, 20, 10)
        list.addItem("Alpha")
        list.addItem("Beta")
        expect_equal(list.getItem(1), "Alpha")
        expect_equal(list.getItem(2), "Beta")
    end)

    it("removeItem removes item by index (1-based)", function()
        local list = luna.terminal.newList(1, 1, 20, 10)
        list.addItem("A")
        list.addItem("B")
        list.addItem("C")
        list.removeItem(2)
        expect_equal(list.getItemCount(), 2)
        expect_equal(list.getItem(2), "C")
    end)

    it("clearItems empties the list", function()
        local list = luna.terminal.newList(1, 1, 20, 10)
        list.addItem("x")
        list.clearItems()
        expect_equal(list.getItemCount(), 0)
    end)

    it("setSelected and getSelected roundtrip (1-based)", function()
        local list = luna.terminal.newList(1, 1, 20, 10)
        list.addItem("A")
        list.addItem("B")
        list.setSelected(2)
        expect_equal(list.getSelected(), 2)
    end)

    it("setSelected nil clears selection", function()
        local list = luna.terminal.newList(1, 1, 20, 10)
        list.addItem("A")
        list.setSelected(1)
        list.setSelected(nil)
        expect_equal(list.getSelected(), nil)
    end)
end)

-- Border widget

describe("TBorder widget", function()
    it("getSize matches constructor", function()
        local b = luna.terminal.newBorder(2, 2, 30, 10)
        local w, h = b.getSize()
        expect_equal(w, 30)
        expect_equal(h, 10)
    end)

    it("getStyle returns single by default", function()
        local b = luna.terminal.newBorder(1, 1, 10, 5)
        expect_equal(b.getStyle(), "single")
    end)

    it("setStyle changes the style", function()
        local b = luna.terminal.newBorder(1, 1, 10, 5)
        b.setStyle("double")
        expect_equal(b.getStyle(), "double")
        b.setStyle("ascii")
        expect_equal(b.getStyle(), "ascii")
    end)
end)

-- Panel widget

describe("TPanel widget", function()
    it("getChildCount starts at 0", function()
        local panel = luna.terminal.newPanel(1, 1, 20, 10)
        expect_equal(panel.getChildCount(), 0)
    end)

    it("addChild increases count", function()
        local panel = luna.terminal.newPanel(1, 1, 20, 10)
        local lbl = luna.terminal.newLabel(1, 1, "Child")
        panel.addChild(lbl)
        expect_equal(panel.getChildCount(), 1)
    end)

    it("clearChildren empties children list", function()
        local panel = luna.terminal.newPanel(1, 1, 20, 10)
        local lbl = luna.terminal.newLabel(1, 1, "Child")
        panel.addChild(lbl)
        panel.clearChildren()
        expect_equal(panel.getChildCount(), 0)
    end)
end)

-- Terminal input routing

describe("Terminal input routing", function()
    it("keypressed returns boolean", function()
        local t = luna.terminal.newTerminal(40, 20)
        local consumed = t.keypressed("a")
        expect_type("boolean", consumed)
    end)

    it("textinput returns boolean", function()
        local t = luna.terminal.newTerminal(40, 20)
        local consumed = t.textinput("a")
        expect_type("boolean", consumed)
    end)

    it("mousepressed does not crash", function()
        local t = luna.terminal.newTerminal(40, 20)
        t.mousepressed(10, 20, 1)
        expect_equal(true, true)
    end)
end)

test_summary()
