-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_ui_core_unit.lua
do
-- Canonical unit coverage for lurek.ui.

local function make_basic_widget(opts)
    return lurek.ui.newCustomWidget(opts or {
        x = 1,
        y = 2,
        width = 40,
        height = 20,
        id = "widget",
    })
end

local function ui_shader_code()
    return [[
@fragment
fn fs(
    @location(0) color: vec4<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) pixel: vec2<f32>,
    @location(3) resolution: vec2<f32>,
    @location(4) texel: vec2<f32>
) -> @location(0) vec4<f32> {
    _ = uv;
    _ = pixel;
    _ = resolution;
    _ = texel;
    return color;
}
]]
end

-- @describe lurek.ui module
describe("lurek.ui module", function()
    -- @covers lurek.ui.loadLayout
    it("loadLayout creates widgets from a layout table", function()
        local before = lurek.ui.getWidgetCount()
        local idx = lurek.ui.loadLayout({
            type = "panel",
            id = "hud_root",
            children = {
                {
                    type = "label",
                    id = "hp_label",
                    text = "HP",
                    icon = "health",
                    iconPosition = "left",
                    iconSize = 16,
                    padding = { 1, 2, 3, 4 },
                    margin = { 5, 6, 7, 8 },
                    textAlign = "center",
                    textVAlign = "bottom",
                    textWrap = true,
                    textEllipsis = false,
                    flexGrow = 1,
                    flexShrink = 2,
                },
            },
        })
        expect_type("number", idx)
        expect_true(lurek.ui.getWidgetCount() > before)
        local label = lurek.ui.getRoot():findById("hp_label")
        expect_equal("center", label:getTextAlign())
        expect_equal("health", label:getIcon())
        expect_equal("left", label:getIconPosition())
        expect_equal(16, label:getIconSize())
        local pt, pr, pb, pl = label:getPadding()
        expect_equal(1, pt)
        expect_equal(2, pr)
        expect_equal(3, pb)
        expect_equal(4, pl)
        local mt, mr, mb, ml = label:getMargin()
        expect_equal(5, mt)
        expect_equal(6, mr)
        expect_equal(7, mb)
        expect_equal(8, ml)
        expect_equal(1, label:getFlexGrow())
        expect_equal(2, label:getFlexShrink())
    end)

    -- @covers lurek.ui.loadLayout
    it("loadLayout accepts Godot-like TOML parity fields in Lua tables", function()
        lurek.ui.loadLayout({
            type = "panel",
            id = "ui_contract_root",
            children = {
                {
                    type = "richlabel",
                    id = "notes_label",
                    text = "[b]Notes[/b]",
                    labelFor = "notes_area",
                    styleClass = "form-label",
                    mouseFilter = "ignore",
                    zOrder = 2,
                    tabIndex = 1,
                    focusGroup = "form",
                    ariaName = "Notes label",
                    bind = "profile.notes",
                },
                {
                    type = "textarea",
                    id = "notes_area",
                    text = "Line one\nLine two",
                    placeholder = "Notes",
                    focusNeighbors = { right = "mode_combo" },
                    anchorLeft = 16,
                    anchorTop = 48,
                    anchorRight = 16,
                    anchorBottom = 16,
                    anchorCenter = { 0.5, 0.5 },
                },
                {
                    type = "combobox",
                    id = "mode_combo",
                    items = { "Write", "Review" },
                    focusNeighbors = { left = "notes_area" },
                },
                {
                    type = "guitable",
                    id = "table",
                    columns = {
                        { header = "Name", width = 120 },
                        { header = "State", width = 80 },
                    },
                    rows = {
                        { "TextArea", "Ready" },
                    },
                },
                {
                    type = "treeview",
                    id = "tree",
                    nodes = {
                        { text = "Root", expanded = true },
                        { text = "Child", parent = 0 },
                    },
                },
                {
                    type = "aspectcontainer",
                    id = "aspect",
                    ratio = 1.5,
                    fit = "cover",
                },
            },
        })
        local root = lurek.ui.getRoot()
        local text_area = root:findById("notes_area")
        expect_equal("LTextArea", text_area:type())
        expect_equal("Line one\nLine two", text_area:getText())
        expect_equal("Notes", text_area:getPlaceholder())
        local rich = root:findById("notes_label")
        expect_equal("LRichLabel", rich:type())
        expect_equal("Notes", rich:getPlainText())
        local aspect = root:findById("aspect")
        expect_equal("LAspectRatioContainer", aspect:type())
        expect_equal("cover", aspect:getFit())
    end)

    -- @covers lurek.ui.loadLayoutFile
    it("loadLayoutFile is callable", function()
        expect_type("function", lurek.ui.loadLayoutFile)
    end)

    -- @covers lurek.ui.getWidgetCount
    it("getWidgetCount returns a numeric widget count", function()
        expect_type("number", lurek.ui.getWidgetCount())
    end)

    -- @covers lurek.ui.getRoot
    it("getRoot returns the root widget object", function()
        lurek.ui.loadLayout({
            type = "panel",
            id = "root_for_lookup",
            children = {
                { type = "button", id = "attack_button", text = "Attack" },
            },
        })
        local root = lurek.ui.getRoot()
        expect_not_nil(root)
        expect_not_nil(root:findById("attack_button"))
    end)

    -- @covers lurek.ui.newCustomWidget
    it("newCustomWidget returns a widget handle", function()
        expect_not_nil(make_basic_widget())
    end)

    -- @covers lurek.ui.newTextArea
    it("newTextArea exposes multi-line text methods", function()
        local area = lurek.ui.newTextArea()
        expect_equal("LTextArea", area:type())
        area:setText("A\nB")
        area:setPlaceholder("Body")
        area:setMaxLength(8)
        expect_equal("A\nB", area:getText())
        expect_equal("Body", area:getPlaceholder())
        expect_type("number", area:getCursorPosition())
    end)

    -- @covers lurek.ui.newRichLabel
    it("newRichLabel exposes rich and plain text", function()
        local label = lurek.ui.newRichLabel("[b]Alert[/b]")
        expect_equal("LRichLabel", label:type())
        expect_equal("[b]Alert[/b]", label:getText())
        expect_equal("Alert", label:getPlainText())
    end)

    -- @covers lurek.ui.newAspectRatioContainer
    it("newAspectRatioContainer exposes ratio and fit", function()
        local container = lurek.ui.newAspectRatioContainer()
        expect_equal("LAspectRatioContainer", container:type())
        container:setRatio(1.777)
        container:setFit("cover")
        expect_equal("cover", container:getFit())
        expect_true(container:getRatio() > 1.7)
    end)

    -- @covers lurek.ui.draw
    it("draw triggers custom onDraw callbacks", function()
        local called = false
        local widget = make_basic_widget()
        widget:setOnDraw(function()
            called = true
        end)
        lurek.ui.draw()
        expect_true(called)
    end)

    -- @covers LUiWidget:setShader
    it("setShader accepts ui shaders and rejects other targets", function()
        local widget = make_basic_widget()
        local shader = lurek.render.newShader(ui_shader_code(), { target = "ui" })
        expect_no_error(function()
            widget:setShader(shader)
            lurek.ui.draw()
            widget:setShader(nil)
        end)
        expect_error(function()
            widget:setShader(lurek.render.newShader(ui_shader_code(), { target = "overlay" }))
        end)
    end)

    -- @covers LUiWidget:setShaderLayer
    it("setShaderLayer accepts named ui shader layers and rejects empty names", function()
        local widget = make_basic_widget()
        local shader = lurek.render.newShader(ui_shader_code(), { target = "ui" })
        expect_no_error(function()
            widget:setShaderLayer("hover_glow", shader)
            lurek.ui.draw()
            widget:setShaderLayer("hover_glow", nil)
        end)
        expect_error(function()
            widget:setShaderLayer("", shader)
        end)
        expect_error(function()
            widget:setShaderLayer("bad", lurek.render.newShader(ui_shader_code(), { target = "draw" }))
        end)
    end)

    -- @covers lurek.ui.drawToImage
    it("drawToImage returns an image with the requested size", function()
        local img = lurek.ui.drawToImage(64, 48)
        expect_equal(64, img:getWidth())
        expect_equal(48, img:getHeight())
    end)

    -- @covers lurek.ui.renderToImage
    it("renderToImage writes an image without throwing", function()
        expect_no_error(function()
            lurek.ui.renderToImage("save/ui_render_unit.png", 96, 64)
        end)
    end)

    -- @covers lurek.ui.parseWidgetState
    it("parseWidgetState accepts known states and rejects unknown ones", function()
        expect_equal("normal", lurek.ui.parseWidgetState("normal"))
        expect_equal("hovered", lurek.ui.parseWidgetState("hovered"))
        expect_nil(lurek.ui.parseWidgetState("bogus"))
    end)

    -- @covers lurek.ui.setDefaultTheme
    it("setDefaultTheme is callable", function()
        expect_no_error(function()
            lurek.ui.setDefaultTheme()
        end)
    end)

    -- @covers lurek.ui.setViewport
    it("setViewport is callable", function()
        expect_no_error(function()
            lurek.ui.setViewport(1280, 720)
        end)
    end)

    -- @covers lurek.ui.flushCache
    it("flushCache returns a boolean", function()
        expect_type("boolean", lurek.ui.flushCache())
    end)

    -- @covers lurek.ui.setAutoInput
    it("setAutoInput toggles automatic UI input forwarding", function()
        lurek.ui.setAutoInput(false)
        expect_false(lurek.ui.hasAutoInput())
        lurek.ui.setAutoInput(true)
    end)

    -- @covers lurek.ui.hasAutoInput
    it("hasAutoInput reports automatic UI input forwarding", function()
        lurek.ui.setAutoInput(true)
        expect_true(lurek.ui.hasAutoInput())
    end)

    -- @covers lurek.ui.setAutoUpdate
    it("setAutoUpdate toggles automatic UI updates", function()
        lurek.ui.setAutoUpdate(false)
        expect_false(lurek.ui.hasAutoUpdate())
        lurek.ui.setAutoUpdate(true)
    end)

    -- @covers lurek.ui.hasAutoUpdate
    it("hasAutoUpdate reports automatic UI updates", function()
        lurek.ui.setAutoUpdate(true)
        expect_true(lurek.ui.hasAutoUpdate())
    end)

    -- @covers lurek.ui.getIconNames
    it("getIconNames returns the built-in icon catalog", function()
        local names = lurek.ui.getIconNames()
        expect_type("table", names)
        expect_true(#names >= 120)
        expect_equal("new-file", names[1])
    end)

    -- @covers lurek.ui.hasIcon
    it("hasIcon resolves built-in icon names", function()
        expect_true(lurek.ui.hasIcon("save"))
        expect_true(lurek.ui.hasIcon("Inventory"))
        expect_false(lurek.ui.hasIcon("missing-icon"))
    end)

    -- @covers lurek.ui.getIconGlyph
    it("getIconGlyph returns the renderer glyph", function()
        expect_equal("S", lurek.ui.getIconGlyph("save"))
        expect_equal("IV", lurek.ui.getIconGlyph("inventory"))
        expect_nil(lurek.ui.getIconGlyph("missing-icon"))
    end)

    -- @covers lurek.ui.newIcon
    it("newIcon creates an icon-only label widget", function()
        local icon = lurek.ui.newIcon("settings")
        expect_not_nil(icon)
        expect_equal("settings", icon:getIcon())
        expect_equal("only", icon:getIconPosition())
        expect_nil(lurek.ui.newIcon("missing-icon"))
    end)

    -- @covers lurek.ui.addToast
    it("addToast accepts a toast object", function()
        local toast = lurek.ui.newToast("Hello", 1.0)
        expect_no_error(function()
            lurek.ui.addToast(toast)
        end)
    end)

    -- @covers lurek.ui.getToastCount
    it("getToastCount returns a numeric count", function()
        expect_type("number", lurek.ui.getToastCount())
    end)
end)

-- @describe base widget methods
describe("base widget methods", function()
    -- @covers LUiWidget:setPosition
    it("setPosition updates widget coordinates", function()
        local w = make_basic_widget()
        w:setPosition(12, 34)
        local x, y = w:getPosition()
        expect_equal(12, x)
        expect_equal(34, y)
    end)

    -- @covers LUiWidget:getPosition
    it("getPosition returns initial coordinates", function()
        local x, y = make_basic_widget({ x = 7, y = 9, width = 10, height = 10 }):getPosition()
        expect_equal(7, x)
        expect_equal(9, y)
    end)

    -- @covers LUiWidget:setSize
    it("setSize updates widget dimensions", function()
        local w = make_basic_widget()
        w:setSize(88, 44)
        local width, height = w:getSize()
        expect_equal(88, width)
        expect_equal(44, height)
    end)

    -- @covers LUiWidget:getSize
    it("getSize returns initial dimensions", function()
        local width, height = make_basic_widget({ x = 0, y = 0, width = 13, height = 21 }):getSize()
        expect_equal(13, width)
        expect_equal(21, height)
    end)

    -- @covers LUiWidget:setVisible
    it("setVisible toggles visibility", function()
        local w = make_basic_widget()
        w:setVisible(false)
        expect_false(w:isVisible())
    end)

    -- @covers LUiWidget:isVisible
    it("isVisible reports the default visible state", function()
        expect_type("boolean", make_basic_widget():isVisible())
    end)

    -- @covers LUiWidget:setEnabled
    it("setEnabled toggles interactivity", function()
        local w = make_basic_widget()
        w:setEnabled(false)
        expect_false(w:isEnabled())
    end)

    -- @covers LUiWidget:isEnabled
    it("isEnabled reports the enabled state", function()
        expect_type("boolean", make_basic_widget():isEnabled())
    end)

    -- @covers LUiWidget:setId
    it("setId changes the widget identifier", function()
        local w = make_basic_widget()
        w:setId("changed_id")
        expect_equal("changed_id", w:getId())
    end)

    -- @covers LUiWidget:getId
    it("getId returns the current widget identifier", function()
        expect_equal("seed_id", make_basic_widget({ x = 0, y = 0, width = 10, height = 10, id = "seed_id" }):getId())
    end)

    -- @covers LUiWidget:setTooltip
    it("setTooltip stores tooltip text", function()
        local w = make_basic_widget()
        w:setTooltip("tooltip text")
        expect_equal("tooltip text", w:getTooltip())
    end)

    -- @covers LUiWidget:getTooltip
    it("getTooltip returns tooltip text", function()
        local w = make_basic_widget()
        w:setTooltip("tip")
        expect_equal("tip", w:getTooltip())
    end)

    -- @covers LUiWidget:getRect
    it("getRect returns x y width height", function()
        local x, y, width, height = make_basic_widget():getRect()
        expect_type("number", x)
        expect_type("number", y)
        expect_type("number", width)
        expect_type("number", height)
    end)

    -- @covers LUiWidget:type
    it("type returns LUiWidget", function()
        expect_equal("LWidget", make_basic_widget():type())
    end)

    -- @covers LUiWidget:typeOf
    it("typeOf reports widget inheritance", function()
        expect_true(make_basic_widget():typeOf("LWidget"))
    end)

    -- @covers LUiWidget:getState
    it("getState returns a widget state string", function()
        expect_type("string", make_basic_widget():getState())
    end)

    -- @covers LUiWidget:addChild
    it("addChild attaches a child widget", function()
        local parent = make_basic_widget()
        expect_no_error(function()
            parent:addChild(make_basic_widget())
        end)
    end)

    -- @covers LUiWidget:getChildCount
    it("getChildCount returns the number of children", function()
        lurek.ui.loadLayout({
            type = "panel",
            id = "child_count_root",
            children = {
                { type = "label", id = "child_a", text = "A" },
                { type = "label", id = "child_b", text = "B" },
            },
        })
        expect_true(lurek.ui.getRoot():getChildCount() >= 2)
    end)

    -- @covers LUiWidget:getChildren
    it("getChildren returns a lua table of children", function()
        lurek.ui.loadLayout({
            type = "panel",
            id = "children_root",
            children = {
                { type = "label", id = "child_table", text = "A" },
            },
        })
        expect_type("table", lurek.ui.getRoot():getChildren())
    end)

    -- @covers LUiWidget:removeChild
    it("removeChild detaches an attached child", function()
        local parent = make_basic_widget()
        local child = make_basic_widget()
        parent:addChild(child)
        parent:removeChild(child)
        expect_equal(0, parent:getChildCount())
    end)

    -- @covers LUiWidget:findById
    it("findById finds attached children recursively", function()
        lurek.ui.loadLayout({
            type = "panel",
            id = "lookup_root",
            children = {
                { type = "button", id = "lookup_child", text = "Find me" },
            },
        })
        expect_not_nil(lurek.ui.getRoot():findById("lookup_child"))
    end)

    -- @covers LUiWidget:setOnClick
    it("setOnClick accepts a callback", function()
        expect_no_error(function()
            make_basic_widget():setOnClick(function() end)
        end)
    end)

    -- @covers LUiWidget:setOnChange
    it("setOnChange accepts a callback", function()
        expect_no_error(function()
            make_basic_widget():setOnChange(function() end)
        end)
    end)

    -- @covers LUiWidget:setOnDraw
    it("setOnDraw accepts a callback", function()
        expect_no_error(function()
            make_basic_widget():setOnDraw(function() end)
        end)
    end)

    -- @covers LUiWidget:containsPoint
    it("containsPoint matches coordinates inside the rect", function()
        local w = make_basic_widget({ x = 10, y = 10, width = 20, height = 20, id = "hitbox" })
        expect_true(w:containsPoint(15, 15))
        expect_false(w:containsPoint(100, 100))
    end)

    -- @covers LUiWidget:setPadding
    it("setPadding stores padding values", function()
        local w = make_basic_widget()
        w:setPadding(1, 2, 3, 4)
        local t, r, b, l = w:getPadding()
        expect_equal(1, t)
        expect_equal(4, l)
    end)

    -- @covers LUiWidget:getPadding
    it("getPadding returns the stored padding", function()
        local w = make_basic_widget()
        w:setPadding(5, 6, 7, 8)
        local t, r, b, l = w:getPadding()
        expect_equal(5, t)
        expect_equal(8, l)
    end)

    -- @covers LUiWidget:setMargin
    it("setMargin stores margin values", function()
        local w = make_basic_widget()
        w:setMargin(5, 6, 7, 8)
        local t, r, b, l = w:getMargin()
        expect_equal(5, t)
        expect_equal(8, l)
    end)

    -- @covers LUiWidget:getMargin
    it("getMargin returns the stored margins", function()
        local w = make_basic_widget()
        w:setMargin(9, 10, 11, 12)
        local t, r, b, l = w:getMargin()
        expect_equal(9, t)
        expect_equal(12, l)
    end)

    -- @covers LUiWidget:setZOrder
    it("setZOrder updates the widget z order", function()
        local w = make_basic_widget()
        w:setZOrder(9)
        expect_equal(9, w:getZOrder())
    end)

    -- @covers LUiWidget:getZOrder
    it("getZOrder returns a numeric depth", function()
        expect_type("number", make_basic_widget():getZOrder())
    end)

    -- @covers LUiWidget:setMinSize
    it("setMinSize stores minimum bounds", function()
        local w = make_basic_widget()
        w:setMinSize(11, 12)
        local minw, minh = w:getMinSize()
        expect_equal(11, minw)
        expect_equal(12, minh)
    end)

    -- @covers LUiWidget:getMinSize
    it("getMinSize returns minimum bounds", function()
        local w = make_basic_widget()
        w:setMinSize(13, 14)
        local minw, minh = w:getMinSize()
        expect_equal(13, minw)
        expect_equal(14, minh)
    end)

    -- @covers LUiWidget:setMaxSize
    it("setMaxSize stores maximum bounds", function()
        local w = make_basic_widget()
        w:setMaxSize(99, 120)
        local maxw, maxh = w:getMaxSize()
        expect_equal(99, maxw)
        expect_equal(120, maxh)
    end)

    -- @covers LUiWidget:getMaxSize
    it("getMaxSize returns maximum bounds", function()
        local w = make_basic_widget()
        w:setMaxSize(77, 88)
        local maxw, maxh = w:getMaxSize()
        expect_equal(77, maxw)
        expect_equal(88, maxh)
    end)

    -- @covers LUiWidget:setAnchor
    it("setAnchor is callable", function()
        expect_no_error(function()
            make_basic_widget():setAnchor(1, 2, 3, 4)
        end)
    end)

    -- @covers LUiWidget:setAnchorCenter
    it("setAnchorCenter is callable", function()
        expect_no_error(function()
            make_basic_widget():setAnchorCenter(5, 6)
        end)
    end)

    -- @covers LUiWidget:clearAnchor
    it("clearAnchor is callable after anchoring", function()
        local w = make_basic_widget()
        w:setAnchor(1, 2, 3, 4)
        expect_no_error(function()
            w:clearAnchor()
        end)
    end)

    -- @covers LUiWidget:setFlexGrow
    it("setFlexGrow updates the grow factor", function()
        local w = make_basic_widget()
        w:setFlexGrow(2.5)
        expect_equal(2.5, w:getFlexGrow())
    end)

    -- @covers LUiWidget:getFlexGrow
    it("getFlexGrow returns the stored grow factor", function()
        local w = make_basic_widget()
        w:setFlexGrow(1.5)
        expect_equal(1.5, w:getFlexGrow())
    end)

    -- @covers LUiWidget:setFlexShrink
    it("setFlexShrink updates the shrink factor", function()
        local w = make_basic_widget()
        w:setFlexShrink(0.5)
        expect_equal(0.5, w:getFlexShrink())
    end)

    -- @covers LUiWidget:getFlexShrink
    it("getFlexShrink returns the stored shrink factor", function()
        local w = make_basic_widget()
        w:setFlexShrink(0.25)
        expect_equal(0.25, w:getFlexShrink())
    end)

    -- @covers LUiWidget:bind
    it("bind attaches a binding key", function()
        expect_no_error(function()
            make_basic_widget():bind("hp")
        end)
    end)

    -- @covers LUiWidget:unbind
    it("unbind clears a previous binding", function()
        local w = make_basic_widget()
        w:bind("hp")
        expect_no_error(function()
            w:unbind()
        end)
    end)

    -- @covers LUiWidget:setAlpha
    it("setAlpha updates widget opacity", function()
        local w = make_basic_widget()
        w:setAlpha(0.25)
        expect_equal(0.25, w:getAlpha())
    end)

    -- @covers LUiWidget:getAlpha
    it("getAlpha returns the stored opacity", function()
        local w = make_basic_widget()
        w:setAlpha(0.75)
        expect_equal(0.75, w:getAlpha())
    end)

    -- @covers LUiWidget:fadeIn
    it("fadeIn restores full opacity", function()
        local w = make_basic_widget()
        w:setAlpha(0.1)
        w:fadeIn()
        expect_equal(1.0, w:getAlpha())
    end)

    -- @covers LUiWidget:fadeOut
    it("fadeOut clears opacity", function()
        local w = make_basic_widget()
        w:setAlpha(0.9)
        w:fadeOut()
        expect_equal(0.0, w:getAlpha())
    end)

    -- @covers LUiWidget:slideIn
    it("slideIn is callable", function()
        expect_no_error(function()
            make_basic_widget():slideIn(10, 20)
        end)
    end)

    -- @covers LUiWidget:slideOut
    it("slideOut is callable", function()
        expect_no_error(function()
            make_basic_widget():slideOut(-10, -20)
        end)
    end)

    -- @covers LUiWidget:attachToEntity
    it("attachToEntity is callable", function()
        expect_no_error(function()
            make_basic_widget():attachToEntity(1)
        end)
    end)

    -- @covers LUiWidget:detachFromEntity
    it("detachFromEntity is callable", function()
        local w = make_basic_widget()
        w:attachToEntity(1)
        expect_no_error(function()
            w:detachFromEntity()
        end)
    end)
end)

-- @describe common ui controls
describe("common ui controls", function()
    -- @covers lurek.ui.newButton
    it("newButton creates a button widget", function()
        expect_not_nil(lurek.ui.newButton("Play"))
    end)

    -- @covers LButton:setText
    it("button setText updates the label", function()
        local button = lurek.ui.newButton("Old")
        button:setText("New")
        expect_equal("New", button:getText())
    end)

    -- @covers LButton:getText
    it("button getText returns the label", function()
        expect_equal("Play", lurek.ui.newButton("Play"):getText())
    end)

    -- @covers lurek.ui.newLabel
    it("newLabel creates a label widget", function()
        expect_not_nil(lurek.ui.newLabel("Score"))
    end)

    -- @covers LLabel:setText
    it("label setText updates the caption", function()
        local label = lurek.ui.newLabel("Old")
        label:setText("New")
        expect_equal("New", label:getText())
    end)

    -- @covers LLabel:getText
    it("label getText returns the caption", function()
        expect_equal("Score", lurek.ui.newLabel("Score"):getText())
    end)

    -- @covers lurek.ui.newTextInput
    it("newTextInput creates a text input", function()
        expect_not_nil(lurek.ui.newTextInput())
    end)

    -- @covers LTextInput:setText
    it("text input setText stores the value", function()
        local input = lurek.ui.newTextInput()
        input:setText("abc")
        expect_equal("abc", input:getText())
    end)

    -- @covers LTextInput:getText
    it("text input getText returns the current value", function()
        local input = lurek.ui.newTextInput()
        input:setText("xyz")
        expect_equal("xyz", input:getText())
    end)

    -- @covers LTextInput:setPlaceholder
    it("text input setPlaceholder stores placeholder text", function()
        local input = lurek.ui.newTextInput()
        input:setPlaceholder("type here")
        expect_equal("type here", input:getPlaceholder())
    end)

    -- @covers LTextInput:getPlaceholder
    it("text input getPlaceholder returns placeholder text", function()
        local input = lurek.ui.newTextInput()
        input:setPlaceholder("search")
        expect_equal("search", input:getPlaceholder())
    end)

    -- @covers LTextInput:setMaxLength
    it("text input setMaxLength is callable", function()
        expect_no_error(function()
            lurek.ui.newTextInput():setMaxLength(12)
        end)
    end)

    -- @covers LTextInput:setSubmitOnEnter
    it("text input setSubmitOnEnter updates the submit_on_enter flag", function()
        local input = lurek.ui.newTextInput()
        input:setSubmitOnEnter(false)
        expect_equal(false, input:getSubmitOnEnter())
    end)

    -- @covers LTextInput:getSubmitOnEnter
    it("text input getSubmitOnEnter returns the current submit_on_enter flag", function()
        local input = lurek.ui.newTextInput()
        input:setSubmitOnEnter(false)
        expect_equal(false, input:getSubmitOnEnter())
    end)

    -- @covers LTextInput:isFocused
    it("text input isFocused returns a boolean", function()
        expect_type("boolean", lurek.ui.newTextInput():isFocused())
    end)

    -- @covers lurek.ui.newCheckbox
    it("newCheckbox creates a checkbox", function()
        expect_not_nil(lurek.ui.newCheckbox("Enabled"))
    end)

    -- @covers LCheckbox:setChecked
    it("checkbox setChecked updates the toggle state", function()
        local checkbox = lurek.ui.newCheckbox("Enabled")
        checkbox:setChecked(true)
        expect_true(checkbox:isChecked())
    end)

    -- @covers LCheckbox:isChecked
    it("checkbox isChecked returns the toggle state", function()
        local checkbox = lurek.ui.newCheckbox("Enabled")
        checkbox:setChecked(false)
        expect_false(checkbox:isChecked())
    end)

    -- @covers LCheckbox:setText
    it("checkbox setText updates the label", function()
        local checkbox = lurek.ui.newCheckbox("Old")
        checkbox:setText("New")
        expect_equal("New", checkbox:getText())
    end)

    -- @covers LCheckbox:getText
    it("checkbox getText returns the label", function()
        expect_equal("Check", lurek.ui.newCheckbox("Check"):getText())
    end)

    -- @covers lurek.ui.newSlider
    it("newSlider creates a slider", function()
        expect_not_nil(lurek.ui.newSlider(0, 10))
    end)

    -- @covers LSlider:setRange
    it("slider setRange updates min and max", function()
        local slider = lurek.ui.newSlider(0, 10)
        slider:setRange(5, 25)
        expect_equal(5, slider:getMin())
        expect_equal(25, slider:getMax())
    end)

    -- @covers LSlider:setStep
    it("slider setStep is callable", function()
        expect_no_error(function()
            lurek.ui.newSlider(0, 10):setStep(2)
        end)
    end)

    -- @covers LSlider:setValue
    it("slider setValue updates the current value", function()
        local slider = lurek.ui.newSlider(0, 10)
        slider:setValue(7)
        expect_equal(7, slider:getValue())
    end)

    -- @covers LSlider:getValue
    it("slider getValue returns the current value", function()
        local slider = lurek.ui.newSlider(0, 10)
        slider:setValue(3)
        expect_equal(3, slider:getValue())
    end)

    -- @covers LSlider:getMin
    it("slider getMin returns the lower bound", function()
        expect_equal(0, lurek.ui.newSlider(0, 10):getMin())
    end)

    -- @covers LSlider:getMax
    it("slider getMax returns the upper bound", function()
        expect_equal(10, lurek.ui.newSlider(0, 10):getMax())
    end)

    -- @covers lurek.ui.newProgressBar
    it("newProgressBar creates a progress bar", function()
        expect_not_nil(lurek.ui.newProgressBar(0, 100))
    end)

    -- @covers LProgressBar:setRange
    it("progress bar setRange updates min and max", function()
        local bar = lurek.ui.newProgressBar(0, 100)
        bar:setRange(0, 200)
        expect_equal(200, bar:getMax())
    end)

    -- @covers LProgressBar:setValue
    it("progress bar setValue stores a value", function()
        local bar = lurek.ui.newProgressBar(0, 100)
        bar:setValue(50)
        expect_equal(50, bar:getValue())
    end)

    -- @covers LProgressBar:getValue
    it("progress bar getValue returns the current value", function()
        local bar = lurek.ui.newProgressBar(0, 100)
        bar:setValue(20)
        expect_equal(20, bar:getValue())
    end)

    -- @covers LProgressBar:getProgress
    it("progress bar getProgress returns a numeric ratio", function()
        local bar = lurek.ui.newProgressBar(0, 100)
        bar:setValue(25)
        expect_type("number", bar:getProgress())
    end)

    -- @covers LProgressBar:getMin
    it("progress bar getMin returns the lower bound", function()
        expect_equal(0, lurek.ui.newProgressBar(0, 100):getMin())
    end)

    -- @covers LProgressBar:getMax
    it("progress bar getMax returns the upper bound", function()
        expect_equal(100, lurek.ui.newProgressBar(0, 100):getMax())
    end)
end)

-- @describe compound widgets and helpers
describe("compound widgets and helpers", function()
    -- @covers lurek.ui.newComboBox
    it("newComboBox creates a combo box", function()
        expect_not_nil(lurek.ui.newComboBox())
    end)

    -- @covers LComboBox:addItem
    it("combo box addItem appends entries", function()
        local combo = lurek.ui.newComboBox()
        combo:addItem("One")
        expect_equal(1, combo:getItemCount())
    end)

    -- @covers LComboBox:removeItem
    it("combo box removeItem deletes an entry", function()
        local combo = lurek.ui.newComboBox()
        combo:addItem("One")
        combo:removeItem(1)
        expect_equal(0, combo:getItemCount())
    end)

    -- @covers LComboBox:clearItems
    it("combo box clearItems removes all entries", function()
        local combo = lurek.ui.newComboBox()
        combo:addItem("One")
        combo:addItem("Two")
        combo:clearItems()
        expect_equal(0, combo:getItemCount())
    end)

    -- @covers LComboBox:getItemCount
    it("combo box getItemCount returns the number of entries", function()
        local combo = lurek.ui.newComboBox()
        combo:addItem("One")
        combo:addItem("Two")
        expect_equal(2, combo:getItemCount())
    end)

    -- @covers LComboBox:getItem
    it("combo box getItem returns an entry by index", function()
        local combo = lurek.ui.newComboBox()
        combo:addItem("One")
        combo:addItem("Two")
        expect_equal("Two", combo:getItem(2))
    end)

    -- @covers LComboBox:setSelectedIndex
    it("combo box setSelectedIndex updates selection", function()
        local combo = lurek.ui.newComboBox()
        combo:addItem("One")
        combo:addItem("Two")
        combo:setSelectedIndex(2)
        expect_equal(2, combo:getSelectedIndex())
    end)

    -- @covers LComboBox:getSelectedIndex
    it("combo box getSelectedIndex returns current selection", function()
        local combo = lurek.ui.newComboBox()
        combo:addItem("One")
        combo:setSelectedIndex(1)
        expect_equal(1, combo:getSelectedIndex())
    end)

    -- @covers LComboBox:getSelectedItem
    it("combo box getSelectedItem returns the selected label", function()
        local combo = lurek.ui.newComboBox()
        combo:addItem("One")
        combo:addItem("Two")
        combo:setSelectedIndex(2)
        expect_equal("Two", combo:getSelectedItem())
    end)

    -- @covers LComboBox:setMaxVisibleItems
    it("combo box setMaxVisibleItems updates the visible item cap", function()
        local combo = lurek.ui.newComboBox()
        combo:setMaxVisibleItems(3)
        expect_equal(3, combo:getMaxVisibleItems())
    end)

    -- @covers LComboBox:getMaxVisibleItems
    it("combo box getMaxVisibleItems returns the current visible item cap", function()
        local combo = lurek.ui.newComboBox()
        combo:setMaxVisibleItems(3)
        expect_equal(3, combo:getMaxVisibleItems())
    end)

    -- @covers lurek.ui.textinput
    it("textinput updates focused text inputs and combo-box typeahead", function()
        lurek.ui.clear()
        local input = lurek.ui.newTextInput()
        lurek.ui.setFocus(input)
        expect_true(lurek.ui.textinput("hello"))
        expect_equal("hello", input:getText())

        lurek.ui.clear()
        local combo = lurek.ui.newComboBox()
        combo:addItem("Apple")
        combo:addItem("Banana")
        combo:addItem("Blueberry")
        lurek.ui.setFocus(combo)
        expect_true(lurek.ui.textinput("b"))
        expect_true(lurek.ui.textinput("l"))
        expect_equal(3, combo:getSelectedIndex())
    end)

    -- @covers lurek.ui.newList
    it("newList creates a list box", function()
        expect_not_nil(lurek.ui.newList())
    end)

    -- @covers LListBox:addItem
    it("list box addItem appends entries", function()
        local list = lurek.ui.newList()
        list:addItem("Alpha")
        expect_equal(1, list:getItemCount())
    end)

    -- @covers LListBox:removeItem
    it("list box removeItem deletes entries", function()
        local list = lurek.ui.newList()
        list:addItem("Alpha")
        list:removeItem(1)
        expect_equal(0, list:getItemCount())
    end)

    -- @covers LListBox:clearItems
    it("list box clearItems removes all entries", function()
        local list = lurek.ui.newList()
        list:addItem("Alpha")
        list:clearItems()
        expect_equal(0, list:getItemCount())
    end)

    -- @covers LListBox:getItemCount
    it("list box getItemCount returns the number of entries", function()
        local list = lurek.ui.newList()
        list:addItem("Alpha")
        list:addItem("Beta")
        expect_equal(2, list:getItemCount())
    end)

    -- @covers LListBox:getItem
    it("list box getItem returns an entry by index", function()
        local list = lurek.ui.newList()
        list:addItem("Alpha")
        expect_equal("Alpha", list:getItem(1))
    end)

    -- @covers LListBox:setSelectedIndex
    it("list box setSelectedIndex updates selection", function()
        local list = lurek.ui.newList()
        list:addItem("Alpha")
        list:setSelectedIndex(1)
        expect_equal(1, list:getSelectedIndex())
    end)

    -- @covers LListBox:getSelectedIndex
    it("list box getSelectedIndex returns the selection", function()
        local list = lurek.ui.newList()
        list:addItem("Alpha")
        list:setSelectedIndex(1)
        expect_equal(1, list:getSelectedIndex())
    end)

    -- @covers LListBox:setItemHeight
    it("list box setItemHeight is callable", function()
        expect_no_error(function()
            lurek.ui.newList():setItemHeight(24)
        end)
    end)

    -- @covers lurek.ui.newTabBar
    it("newTabBar creates a tab bar", function()
        expect_not_nil(lurek.ui.newTabBar())
    end)

    -- @covers LTabBar:addTab
    it("tab bar addTab appends a tab", function()
        local tabs = lurek.ui.newTabBar()
        tabs:addTab("Home")
        expect_equal(1, tabs:getTabCount())
    end)

    -- @covers LTabBar:removeTab
    it("tab bar removeTab deletes a tab", function()
        local tabs = lurek.ui.newTabBar()
        tabs:addTab("Home")
        tabs:removeTab(1)
        expect_equal(0, tabs:getTabCount())
    end)

    -- @covers LTabBar:getTabCount
    it("tab bar getTabCount returns the number of tabs", function()
        local tabs = lurek.ui.newTabBar()
        tabs:addTab("Home")
        tabs:addTab("Settings")
        expect_equal(2, tabs:getTabCount())
    end)

    -- @covers LTabBar:getTab
    it("tab bar getTab returns a tab label", function()
        local tabs = lurek.ui.newTabBar()
        tabs:addTab("Home")
        expect_equal("Home", tabs:getTab(1))
    end)

    -- @covers LTabBar:setActiveTab
    it("tab bar setActiveTab updates the active index", function()
        local tabs = lurek.ui.newTabBar()
        tabs:addTab("Home")
        tabs:addTab("Settings")
        tabs:setActiveTab(2)
        expect_equal(2, tabs:getActiveTab())
    end)

    -- @covers LTabBar:getActiveTab
    it("tab bar getActiveTab returns the active index", function()
        local tabs = lurek.ui.newTabBar()
        tabs:addTab("Home")
        tabs:setActiveTab(1)
        expect_equal(1, tabs:getActiveTab())
    end)

    -- @covers lurek.ui.newSpinBox
    it("newSpinBox creates a spin box", function()
        expect_not_nil(lurek.ui.newSpinBox(0, 10))
    end)

    -- @covers LSpinBox:setRange
    it("spin box setRange updates min and max", function()
        local spin = lurek.ui.newSpinBox(0, 10)
        spin:setRange(5, 15)
        spin:setValue(10)
        expect_equal(10, spin:getValue())
    end)

    -- @covers LSpinBox:setStep
    it("spin box setStep is callable", function()
        expect_no_error(function()
            lurek.ui.newSpinBox(0, 10):setStep(2)
        end)
    end)

    -- @covers LSpinBox:setValue
    it("spin box setValue stores the value", function()
        local spin = lurek.ui.newSpinBox(0, 10)
        spin:setValue(6)
        expect_equal(6, spin:getValue())
    end)

    -- @covers LSpinBox:getValue
    it("spin box getValue returns the current value", function()
        local spin = lurek.ui.newSpinBox(0, 10)
        spin:setValue(4)
        expect_equal(4, spin:getValue())
    end)

    -- @covers LSpinBox:increment
    it("spin box increment increases the value", function()
        local spin = lurek.ui.newSpinBox(0, 10)
        spin:setValue(3)
        spin:increment()
        expect_true(spin:getValue() >= 3)
    end)

    -- @covers LSpinBox:decrement
    it("spin box decrement decreases the value", function()
        local spin = lurek.ui.newSpinBox(0, 10)
        spin:setValue(3)
        spin:decrement()
        expect_true(spin:getValue() <= 3)
    end)

    -- @covers lurek.ui.newSwitch
    it("newSwitch creates a switch", function()
        expect_not_nil(lurek.ui.newSwitch(false))
    end)

    -- @covers LSwitch:setOn
    it("switch setOn updates the boolean state", function()
        local sw = lurek.ui.newSwitch(false)
        sw:setOn(true)
        expect_true(sw:isOn())
    end)

    -- @covers LSwitch:isOn
    it("switch isOn returns the boolean state", function()
        expect_true(lurek.ui.newSwitch(true):isOn())
    end)

    -- @covers LSwitch:toggle
    it("switch toggle flips the boolean state", function()
        local sw = lurek.ui.newSwitch(false)
        sw:toggle()
        expect_true(sw:isOn())
    end)

    -- @covers lurek.ui.newBadge
    it("newBadge creates a badge", function()
        expect_not_nil(lurek.ui.newBadge(3))
    end)

    -- @covers LBadge:setCount
    it("badge setCount updates the counter", function()
        local badge = lurek.ui.newBadge(0)
        badge:setCount(7)
        expect_equal(7, badge:getCount())
    end)

    -- @covers LBadge:getCount
    it("badge getCount returns the count", function()
        expect_equal(5, lurek.ui.newBadge(5):getCount())
    end)

    -- @covers LBadge:getDisplayText
    it("badge getDisplayText returns a string", function()
        expect_type("string", lurek.ui.newBadge(42):getDisplayText())
    end)

    -- @covers lurek.ui.newPanel
    it("newPanel creates a panel widget", function()
        expect_not_nil(lurek.ui.newPanel())
    end)

    -- @covers LPanel:setTitle
    it("panel setTitle updates the title", function()
        local panel = lurek.ui.newPanel()
        panel:setTitle("Inventory")
        expect_equal("Inventory", panel:getTitle())
    end)

    -- @covers LPanel:getTitle
    it("panel getTitle returns the title", function()
        local panel = lurek.ui.newPanel()
        panel:setTitle("Stats")
        expect_equal("Stats", panel:getTitle())
    end)

    -- @covers LPanel:setScrollable
    it("panel setScrollable is callable", function()
        expect_no_error(function()
            lurek.ui.newPanel():setScrollable(true)
        end)
    end)

    -- @covers lurek.ui.newLayout
    it("newLayout creates a layout widget", function()
        expect_not_nil(lurek.ui.newLayout("vertical"))
    end)

    -- @covers lurek.ui.newVBoxContainer
    it("newVBoxContainer creates a vertical layout container", function()
        local layout = lurek.ui.newVBoxContainer()
        expect_equal("vertical", layout:getDirection())
    end)

    -- @covers lurek.ui.newHBoxContainer
    it("newHBoxContainer creates a horizontal layout container", function()
        local layout = lurek.ui.newHBoxContainer()
        expect_equal("horizontal", layout:getDirection())
    end)

    -- @covers lurek.ui.newGridContainer
    it("newGridContainer creates a grid layout with columns", function()
        local layout = lurek.ui.newGridContainer(3)
        expect_equal("grid", layout:getDirection())
    end)

    -- @covers lurek.ui.newMarginContainer
    it("newMarginContainer applies padding shorthand", function()
        local layout = lurek.ui.newMarginContainer(4, 8)
        local top, right, bottom, left = layout:getPadding()
        expect_equal(4, top)
        expect_equal(8, right)
        expect_equal(4, bottom)
        expect_equal(8, left)
    end)

    -- @covers lurek.ui.newCenterContainer
    it("newCenterContainer centers children by default", function()
        local layout = lurek.ui.newCenterContainer()
        expect_equal("center", layout:getAlign())
        expect_equal("center", layout:getJustify())
    end)

    -- @covers LLayout:setDirection
    it("layout setDirection updates direction", function()
        local layout = lurek.ui.newLayout("vertical")
        layout:setDirection("horizontal")
        expect_equal("horizontal", layout:getDirection())
    end)

    -- @covers LLayout:getDirection
    it("layout getDirection returns the direction", function()
        expect_equal("vertical", lurek.ui.newLayout("vertical"):getDirection())
    end)

    -- @covers LLayout:setSpacing
    it("layout setSpacing updates spacing", function()
        local layout = lurek.ui.newLayout("vertical")
        layout:setSpacing(12)
        expect_equal(12, layout:getSpacing())
    end)

    -- @covers LLayout:getSpacing
    it("layout getSpacing returns spacing", function()
        local layout = lurek.ui.newLayout("vertical")
        layout:setSpacing(6)
        expect_equal(6, layout:getSpacing())
    end)

    -- @covers lurek.ui.newTable
    it("newTable creates a table widget", function()
        expect_not_nil(lurek.ui.newTable())
    end)

    -- @covers LGuiTable:addColumn
    it("table addColumn appends a column", function()
        local table_widget = lurek.ui.newTable()
        table_widget:addColumn("Name", 100)
        expect_equal(1, table_widget:getColumnCount())
    end)

    -- @covers LGuiTable:getColumnCount
    it("table getColumnCount returns the number of columns", function()
        local table_widget = lurek.ui.newTable()
        table_widget:addColumn("Name", 100)
        table_widget:addColumn("Score", 80)
        expect_equal(2, table_widget:getColumnCount())
    end)

    -- @covers LGuiTable:addRow
    it("table addRow appends a row", function()
        local table_widget = lurek.ui.newTable()
        table_widget:addColumn("Name", 100)
        table_widget:addRow({ "Alice" })
        expect_equal(1, table_widget:getRowCount())
    end)

    -- @covers LGuiTable:getRowCount
    it("table getRowCount returns the number of rows", function()
        local table_widget = lurek.ui.newTable()
        table_widget:addColumn("Name", 100)
        table_widget:addRow({ "Alice" })
        table_widget:addRow({ "Bob" })
        expect_equal(2, table_widget:getRowCount())
    end)

    -- @covers LGuiTable:getSelectedRow
    it("table getSelectedRow returns current selection", function()
        local table_widget = lurek.ui.newTable()
        table_widget:setSelectedRow(1)
        expect_equal(1, table_widget:getSelectedRow())
    end)

    -- @covers LGuiTable:setSelectedRow
    it("table setSelectedRow updates selection", function()
        local table_widget = lurek.ui.newTable()
        table_widget:setSelectedRow(2)
        expect_equal(2, table_widget:getSelectedRow())
    end)

    -- @covers LGuiTable:isSortable
    it("table isSortable returns a boolean", function()
        expect_type("boolean", lurek.ui.newTable():isSortable())
    end)

    -- @covers LGuiTable:setSortable
    it("table setSortable is callable", function()
        expect_no_error(function()
            lurek.ui.newTable():setSortable(true)
        end)
    end)

    -- @covers lurek.ui.newImageWidget
    it("newImageWidget creates an image widget", function()
        expect_not_nil(lurek.ui.newImageWidget())
    end)

    -- @covers LImageWidget:setScaleMode
    it("image widget setScaleMode updates the mode", function()
        local widget = lurek.ui.newImageWidget()
        widget:setScaleMode("fit")
        expect_equal("fit", widget:getScaleMode())
    end)

    -- @covers LImageWidget:getScaleMode
    it("image widget getScaleMode returns the current mode", function()
        local widget = lurek.ui.newImageWidget()
        widget:setScaleMode("stretch")
        expect_equal("stretch", widget:getScaleMode())
    end)

    -- @covers LImageWidget:setTint
    it("image widget setTint updates color channels", function()
        local widget = lurek.ui.newImageWidget()
        widget:setTint(0.5, 0.2, 0.8, 1.0)
        local r, g, b, a = widget:getTint()
        expect_near(0.5, r, 0.001)
        expect_near(1.0, a, 0.001)
    end)

    -- @covers LImageWidget:getTint
    it("image widget getTint returns color channels", function()
        local r, g, b, a = lurek.ui.newImageWidget():getTint()
        expect_type("number", r)
        expect_type("number", a)
    end)

    -- @covers lurek.ui.newScrollPanel
    it("newScrollPanel creates a scroll panel", function()
        expect_not_nil(lurek.ui.newScrollPanel())
    end)

    -- @covers lurek.ui.newScrollContainer
    it("newScrollContainer creates a scroll panel alias", function()
        local panel = lurek.ui.newScrollContainer()
        panel:setContentSize(300, 200)
        local width, height = panel:getContentSize()
        expect_equal(300, width)
        expect_equal(200, height)
    end)

    -- @covers LScrollPanel:setContentSize
    it("scroll panel setContentSize updates scrollable bounds", function()
        local panel = lurek.ui.newScrollPanel()
        panel:setContentSize(500, 300)
        local width, height = panel:getContentSize()
        expect_equal(500, width)
        expect_equal(300, height)
    end)

    -- @covers LScrollPanel:getContentSize
    it("scroll panel getContentSize returns content dimensions", function()
        local panel = lurek.ui.newScrollPanel()
        panel:setContentSize(250, 125)
        local width, height = panel:getContentSize()
        expect_equal(250, width)
        expect_equal(125, height)
    end)

    -- @covers LScrollPanel:setScrollPosition
    it("scroll panel setScrollPosition updates scroll offsets", function()
        local panel = lurek.ui.newScrollPanel()
        panel:setContentSize(500, 300)
        expect_no_error(function()
            panel:setScrollPosition(10, 20)
        end)
    end)

    -- @covers LScrollPanel:getScrollPosition
    it("scroll panel getScrollPosition returns current offsets", function()
        local panel = lurek.ui.newScrollPanel()
        panel:setContentSize(500, 300)
        panel:setScrollPosition(3, 4)
        local x, y = panel:getScrollPosition()
        expect_type("number", x)
        expect_type("number", y)
    end)

    -- @covers LScrollPanel:getMaxScroll
    it("scroll panel getMaxScroll returns numeric bounds", function()
        local panel = lurek.ui.newScrollPanel()
        local x, y = panel:getMaxScroll()
        expect_type("number", x)
        expect_type("number", y)
    end)

    -- @covers LScrollPanel:setScrollSpeed
    it("scroll panel setScrollSpeed is callable", function()
        expect_no_error(function()
            lurek.ui.newScrollPanel():setScrollSpeed(2.0)
        end)
    end)

    -- @covers LScrollPanel:getScrollSpeed
    it("scroll panel getScrollSpeed returns the configured speed", function()
        local panel = lurek.ui.newScrollPanel()
        panel:setScrollSpeed(3.5)
        expect_equal(3.5, panel:getScrollSpeed())
    end)

    -- @covers lurek.ui.newSeparator
    it("newSeparator creates a separator", function()
        expect_not_nil(lurek.ui.newSeparator(true))
    end)

    -- @covers LSeparator:setVertical
    it("separator setVertical updates orientation", function()
        local sep = lurek.ui.newSeparator(false)
        sep:setVertical(true)
        expect_true(sep:isVertical())
    end)

    -- @covers LSeparator:isVertical
    it("separator isVertical returns orientation", function()
        expect_true(lurek.ui.newSeparator(true):isVertical())
    end)

    -- @covers LSeparator:setThickness
    it("separator setThickness is callable", function()
        expect_no_error(function()
            lurek.ui.newSeparator(false):setThickness(3)
        end)
    end)

    -- @covers LSeparator:getThickness
    it("separator getThickness returns a numeric width", function()
        expect_type("number", lurek.ui.newSeparator(false):getThickness())
    end)

    -- @covers lurek.ui.newToast
    it("newToast creates a toast object", function()
        expect_not_nil(lurek.ui.newToast("Hello", 5.0))
    end)

    -- @covers LToast:getProgress
    it("toast getProgress returns a numeric lifecycle value", function()
        expect_type("number", lurek.ui.newToast("Hello", 5.0):getProgress())
    end)

    -- @covers LToast:isExpired
    it("toast isExpired returns false for a fresh toast", function()
        expect_false(lurek.ui.newToast("Hello", 5.0):isExpired())
    end)

end)
end
-- END test_ui_core_unit.lua

-- BEGIN test_ui_font_unit.lua
do
-- Lurek2D UI font integration tests.

-- @describe lurek.ui font selection
describe("lurek.ui font selection", function()
    -- @covers lurek.ui.setFont
    it("setFont stores the global UI font", function()
        local font = lurek.render.newFont("font_12")
        lurek.ui.setFont(font)
        expect_type("userdata", lurek.ui.getFont())
    end)

    -- @covers lurek.ui.getFont
    it("getFont returns the configured global UI font", function()
        local font = lurek.render.newFont("font_12")
        lurek.ui.setFont(font)
        local current = lurek.ui.getFont()
        expect_type("userdata", current)
    end)

    -- @covers lurek.ui.clearFont
    it("clearFont removes the global UI font", function()
        local font = lurek.render.newFont("font_12")
        lurek.ui.setFont(font)
        lurek.ui.clearFont()
        expect_equal(nil, lurek.ui.getFont())
    end)

    -- @covers lurek.ui.getWidgetFont
    it("getWidgetFont returns the widget override and then nil after clear", function()
        local widget = lurek.ui.newCustomWidget({ x = 1, y = 2, width = 32, height = 16 })
        local font = lurek.render.newFont("fontb_10")
        widget:setFont(font)
        local current = lurek.ui.getWidgetFont(widget)
        expect_type("userdata", current)
        widget:clearFont()
        expect_equal(nil, lurek.ui.getWidgetFont(widget))
    end)
end)
end
-- END test_ui_font_unit.lua

-- BEGIN test_ui_features_unit.lua
do
-- tests/lua/unit/test_ui_features_unit.lua
-- Unit: lurek.ui (layout, focus, resolution, virtualization, animation)
-- Tests new UI features: spatial focus, resolution scaling, visible range, extended animations.

local describe = describe or function(n,f) f() end
local it = it or function(n,f) f() end

-- @describe ui spatial focus navigation
describe("ui spatial focus navigation", function()
    -- @covers lurek.ui.focusDirection
    it("moves focus when a neighbor exists and returns false otherwise", function()
        -- Create two buttons side by side
        local btn1 = lurek.ui.newButton("Left")
        btn1:setPosition(10, 50)
        btn1:setSize(80, 30)

        local btn2 = lurek.ui.newButton("Right")
        btn2:setPosition(200, 50)
        btn2:setSize(80, 30)

        lurek.ui.update(0.0)
        lurek.ui.setFocus(btn1)

        -- Move focus right
        local moved = lurek.ui.focusDirection(1.0, 0.0)
        expect_type("boolean", moved)
        local btn = lurek.ui.newButton("Solo")
        btn:setPosition(500, 500)
        btn:setSize(80, 30)

        lurek.ui.update(0.0)
        lurek.ui.setFocus(btn)

        -- Try to move in direction with nothing
        local isolated = lurek.ui.focusDirection(0.0, -1.0)
        expect_equal(false, isolated)
    end)
end)

-- @describe ui resolution scaling
describe("ui resolution scaling", function()
    -- @covers lurek.ui.setBaseResolution
    it("computes scale factor from base and current resolution", function()
        lurek.ui.setBaseResolution(1920, 1080)
        lurek.ui.updateResolution(1920, 1080)
        local factor = lurek.ui.getScaleFactor()
        expect_near(1.0, factor, 0.01)
    end)

    -- @covers lurek.ui.updateResolution
    it("scale factor changes when resolution changes", function()
        lurek.ui.setBaseResolution(1920, 1080)
        lurek.ui.updateResolution(1280, 720)
        local factor = lurek.ui.getScaleFactor()
        -- 720 / 1080 = 0.667
        expect_near(0.667, factor, 0.01)
    end)

    -- @covers lurek.ui.getScaleFactor
    it("doubling resolution doubles scale factor", function()
        lurek.ui.setBaseResolution(1920, 1080)
        lurek.ui.updateResolution(3840, 2160)
        local factor = lurek.ui.getScaleFactor()
        expect_near(2.0, factor, 0.01)
    end)
end)

-- @describe ui visible range virtualization
describe("ui visible range virtualization", function()
    -- @covers lurek.ui.visibleRange
    it("computes visible item range for list box", function()
        local list = lurek.ui.newList()
        list:setPosition(10, 10)
        list:setSize(200, 100)
        lurek.ui.update(0.0)

        local start_idx, end_idx = lurek.ui.visibleRange(list, 50, 20.0)
        expect_type("number", start_idx)
        expect_type("number", end_idx)
        -- viewport 100px / 20px per item = 5 visible items + 1 = 6 max
        expect_true(end_idx - start_idx <= 7, "visible range should be bounded by viewport")
        expect_true(end_idx <= 50, "end should not exceed item count")
    end)
end)

-- @describe ui extended animations
describe("ui extended animations", function()
    -- @covers lurek.ui.animateScale
    it("starts scale animation on valid widgets and rejects invalid indices", function()
        local panel = lurek.ui.newPanel()
        local result = lurek.ui.animateScale(panel._idx, 1.0, 1.0, 2.0, 2.0, 0.5, "cubic_out")
        expect_true(result, "animateScale should return true for valid widget")
        local invalid = lurek.ui.animateScale(99999, 1.0, 1.0, 2.0, 2.0, 0.5)
        expect_equal(false, invalid)
    end)

    -- @covers lurek.ui.animateRotation
    it("starts rotation animation with explicit and default easing", function()
        local panel = lurek.ui.newPanel()
        local result = lurek.ui.animateRotation(panel._idx, 0.0, 3.14, 1.0, "bounce_out")
        expect_true(result, "animateRotation should return true for valid widget")
        local fallback = lurek.ui.animateRotation(panel._idx, 0.0, 1.57, 1.0)
        expect_true(fallback, "should accept nil easing (defaults to linear)")
    end)

    -- @covers lurek.ui.animateColor
    it("starts color tint animation on widget", function()
        local panel = lurek.ui.newPanel()
        local from = { r = 1.0, g = 0.0, b = 0.0, a = 1.0 }
        local to = { r = 0.0, g = 1.0, b = 0.0, a = 1.0 }
        local result = lurek.ui.animateColor(panel._idx, from, to, 0.8, "sine_in_out")
        expect_true(result, "animateColor should return true for valid widget")
    end)

end)
end
-- END test_ui_features_unit.lua

-- BEGIN test_ui_missing_unit.lua
do
local function basic_widget()
    return lurek.ui.newCustomWidget({
        x = 10,
        y = 10,
        width = 80,
        height = 24,
        id = "missing_widget",
    })
end

-- @describe supplementary ui module coverage
describe("supplementary ui module coverage", function()
    -- @covers lurek.ui.newNinePatch
    it("newNinePatch creates a nine-patch widget", function()
        expect_not_nil(lurek.ui.newNinePatch())
    end)

    -- @covers lurek.ui.newSpacer
    it("newSpacer creates a spacer widget", function()
        expect_not_nil(lurek.ui.newSpacer(20, 10))
    end)

    -- @covers lurek.ui.newTreeView
    it("newTreeView creates a tree view widget", function()
        expect_not_nil(lurek.ui.newTreeView())
    end)

    -- @covers lurek.ui.newRadioButton
    it("newRadioButton creates a radio button widget", function()
        expect_not_nil(lurek.ui.newRadioButton("Option A", "group1"))
    end)

    -- @covers lurek.ui.newScrollBar
    it("newScrollBar creates a scroll bar widget", function()
        expect_not_nil(lurek.ui.newScrollBar(true))
    end)

    -- @covers lurek.ui.newWindow
    it("newWindow creates a window widget", function()
        expect_not_nil(lurek.ui.newWindow("Inspector"))
    end)

    -- @covers lurek.ui.newSplitPanel
    it("newSplitPanel creates a split panel widget", function()
        expect_not_nil(lurek.ui.newSplitPanel("horizontal"))
    end)

    -- @covers lurek.ui.newDockPanel
    it("newDockPanel creates a dock panel widget", function()
        expect_not_nil(lurek.ui.newDockPanel())
    end)

    -- @covers lurek.ui.newToolbar
    it("newToolbar creates a toolbar widget", function()
        expect_not_nil(lurek.ui.newToolbar("horizontal"))
    end)

    -- @covers lurek.ui.newMenuBar
    it("newMenuBar creates a menu bar widget", function()
        expect_not_nil(lurek.ui.newMenuBar())
    end)

    -- @covers lurek.ui.newMenuItem
    it("newMenuItem creates a menu item widget", function()
        expect_not_nil(lurek.ui.newMenuItem("File"))
    end)

    -- @covers lurek.ui.newDialog
    it("newDialog creates a dialog widget", function()
        expect_not_nil(lurek.ui.newDialog("Confirm"))
    end)

    -- @covers lurek.ui.newStatusBar
    it("newStatusBar creates a status bar widget", function()
        expect_not_nil(lurek.ui.newStatusBar())
    end)

    -- @covers lurek.ui.newAccordion
    it("newAccordion creates an accordion widget", function()
        expect_not_nil(lurek.ui.newAccordion())
    end)

    -- @covers lurek.ui.newTooltipPanel
    it("newTooltipPanel creates a tooltip panel widget", function()
        expect_not_nil(lurek.ui.newTooltipPanel("Hover info"))
    end)

    -- @covers lurek.ui.newColorPicker
    it("newColorPicker creates a color picker widget", function()
        expect_not_nil(lurek.ui.newColorPicker())
    end)

    -- @covers lurek.ui.newTheme
    it("newTheme creates a theme object", function()
        expect_not_nil(lurek.ui.newTheme())
    end)

    -- @covers lurek.ui.setTheme
    it("setTheme accepts a theme object", function()
        local theme = lurek.ui.newTheme()
        expect_no_error(function()
            lurek.ui.setTheme(theme)
        end)
    end)

    -- @covers lurek.ui.getTheme
    it("getTheme returns the active theme object", function()
        local theme = lurek.ui.newTheme()
        lurek.ui.setTheme(theme)
        expect_not_nil(lurek.ui.getTheme())
    end)

    -- @covers lurek.ui.setFocus
    it("setFocus accepts a widget object", function()
        local button = lurek.ui.newButton("Focus me")
        expect_no_error(function()
            lurek.ui.setFocus(button)
        end)
    end)

    -- @covers lurek.ui.getFocus
    it("getFocus returns the currently focused widget or nil", function()
        local button = lurek.ui.newButton("Focus me")
        lurek.ui.setFocus(button)
        expect_not_nil(lurek.ui.getFocus())
    end)

    -- @covers lurek.ui.focusNext
    it("focusNext advances focus across focusable widgets", function()
        local a = lurek.ui.newButton("A")
        local b = lurek.ui.newButton("B")
        lurek.ui.setFocus(a)
        expect_no_error(function()
            lurek.ui.focusNext()
        end)
        expect_not_nil(lurek.ui.getFocus())
    end)

    -- @covers lurek.ui.focusPrev
    it("focusPrev moves focus backward across focusable widgets", function()
        local a = lurek.ui.newButton("A")
        local b = lurek.ui.newButton("B")
        lurek.ui.setFocus(b)
        expect_no_error(function()
            lurek.ui.focusPrev()
        end)
    end)

    -- @covers lurek.ui.focusNeighbor
    it("focusNeighbor uses explicit neighbor links when present", function()
        local a = lurek.ui.newButton("A")
        local b = lurek.ui.newButton("B")
        a:setFocusNeighbor("right", b._idx)
        lurek.ui.setFocus(a)
        expect_type("boolean", lurek.ui.focusNeighbor("right"))
    end)

    -- @covers lurek.ui.clear
    it("clear removes widget state without throwing", function()
        expect_no_error(function()
            lurek.ui.clear()
        end)
    end)

    -- @covers lurek.ui.clearFocus
    it("clearFocus clears the current focus state", function()
        local button = lurek.ui.newButton("Focus me")
        lurek.ui.setFocus(button)
        lurek.ui.clearFocus()
        expect_equal(nil, lurek.ui.getFocus())
    end)

    -- @covers lurek.ui.mousepressed
    it("mousepressed presses a hit widget and consumes input", function()
        lurek.ui.clear()
        local button = lurek.ui.newButton("Hit")
        button:setPosition(20, 20)
        button:setSize(80, 30)
        expect_true(lurek.ui.mousepressed(25, 25, 1))
        expect_equal("pressed", button:getState())
    end)

    -- @covers lurek.ui.mousereleased
    it("mousereleased activates a pressed button", function()
        lurek.ui.clear()
        local clicked = false
        local button = lurek.ui.newButton("Release")
        button:setPosition(20, 20)
        button:setSize(100, 30)
        button:setOnClick(function()
            clicked = true
        end)
        expect_true(lurek.ui.mousepressed(25, 25, 1))
        expect_true(lurek.ui.mousereleased(25, 25, 1))
        lurek.ui.update(0)
        expect_true(clicked)
    end)

    -- @covers lurek.ui.mousemoved
    it("mousemoved updates hover state for hit widgets", function()
        lurek.ui.clear()
        local button = lurek.ui.newButton("Hover")
        button:setPosition(30, 40)
        button:setSize(100, 30)
        expect_true(lurek.ui.mousemoved(32, 48))
        expect_equal("hovered", button:getState())
    end)

    -- @covers lurek.ui.keypressed
    it("keypressed handles editing, selection shortcuts, and word navigation for focused inputs", function()
        lurek.ui.clear()
        local input = lurek.ui.newTextInput()
        lurek.ui.setFocus(input)
        expect_true(lurek.ui.textinput("ab"))
        expect_true(lurek.ui.keypressed("backspace"))
        expect_equal("a", input:getText())

        lurek.ui.clear()
        input = lurek.ui.newTextInput()
        lurek.ui.setFocus(input)
        expect_true(lurek.ui.textinput("abcd"))
        expect_true(lurek.ui.keypressed("shift+left"))
        expect_true(lurek.ui.keypressed("shift+left"))
        expect_true(lurek.ui.keypressed("backspace"))
        expect_equal("ab", input:getText())
        expect_true(lurek.ui.keypressed("ctrl+a"))
        expect_true(lurek.ui.textinput("Z"))
        expect_equal("Z", input:getText())

        lurek.ui.clear()
        input = lurek.ui.newTextInput()
        lurek.ui.setFocus(input)
        expect_true(lurek.ui.textinput("alpha beta gamma"))
        expect_true(lurek.ui.keypressed("ctrl+left"))
        expect_equal(11, input:getCursorPosition())
        expect_true(lurek.ui.keypressed("ctrl+left"))
        expect_equal(6, input:getCursorPosition())
        expect_true(lurek.ui.keypressed("ctrl+right"))
        expect_equal(11, input:getCursorPosition())
    end)


    -- @covers LTextInput:getCursorPosition
    it("getCursorPosition reports character indices for UTF-8 text", function()
        local input = lurek.ui.newTextInput()
        input:setText("ąż")
        expect_equal(2, input:getCursorPosition())
    end)

    -- @covers lurek.ui.wheelmoved
    it("wheelmoved scrolls the focused scroll panel", function()
        lurek.ui.clear()
        local panel = lurek.ui.newScrollPanel()
        panel:setSize(100, 50)
        panel:setContentSize(100, 250)
        panel:setScrollSpeed(10)
        lurek.ui.setFocus(panel)
        expect_true(lurek.ui.wheelmoved(0, -1))
        local _x, y = panel:getScrollPosition()
        expect_equal(10, y)
    end)

    -- @covers lurek.ui.beginDrag
    it("beginDrag accepts a widget object", function()
        local w = lurek.ui.newButton("Drag")
        expect_no_error(function()
            lurek.ui.beginDrag(w)
        end)
    end)

    -- @covers lurek.ui.getActiveDrag
    it("getActiveDrag returns active drag state after beginDrag", function()
        local w = lurek.ui.newButton("Drag")
        lurek.ui.beginDrag(w)
        expect_not_nil(lurek.ui.getActiveDrag())
    end)

    -- @covers lurek.ui.dropOn
    it("dropOn accepts a drop target widget", function()
        local source = lurek.ui.newButton("Source")
        local target = lurek.ui.newButton("Target")
        lurek.ui.beginDrag(source)
        expect_no_error(function()
            lurek.ui.dropOn(target)
        end)
    end)

    -- @covers lurek.ui.endDrag
    it("endDrag clears the active drag state", function()
        local w = lurek.ui.newButton("Drag")
        lurek.ui.beginDrag(w)
        lurek.ui.endDrag()
        expect_equal(nil, lurek.ui.getActiveDrag())
    end)

    -- @covers lurek.ui.update_bindings
    it("update_bindings accepts a values table and returns a count", function()
        local w = basic_widget()
        w:bind("hp")
        expect_type("number", lurek.ui.update_bindings({ hp = 10 }))
    end)

    -- @covers lurek.ui.updateBindings
    it("updateBindings accepts a values table and returns a count", function()
        local w = basic_widget()
        w:bind("hp")
        expect_type("number", lurek.ui.updateBindings({ hp = 15 }))
    end)

    -- @covers lurek.ui.loadLayoutGameFile
    it("loadLayoutGameFile loads a sample TOML layout", function()
        expect_no_error(function()
            lurek.ui.loadLayoutGameFile("content/examples/assets/layouts/sample_main_menu.toml")
        end)
    end)

    -- @covers lurek.ui.getStyleToken
    it("getStyleToken returns configured design tokens when present", function()
        local spacing = lurek.ui.getStyleToken("spacing_md")
        expect_true(spacing == nil or type(spacing) == "number" or type(spacing) == "string" or type(spacing) == "table")
    end)
end)

-- @describe supplemental widget coverage
describe("supplemental widget coverage", function()
    -- @covers LUiWidget:clearFont
    it("clearFont removes a widget font override", function()
        local widget = basic_widget()
        local font = lurek.render.newFont("fontb_10")
        widget:setFont(font)
        widget:clearFont()
        expect_equal(nil, lurek.ui.getWidgetFont(widget))
    end)

    -- @covers LUiWidget:setStyleClass
    it("setStyleClass stores a css-like style class", function()
        local widget = basic_widget()
        widget:setStyleClass("inventory")
        expect_equal("inventory", widget:getStyleClass())
    end)

    -- @covers LUiWidget:getStyleClass
    it("getStyleClass returns the current style class", function()
        local widget = basic_widget()
        widget:setStyleClass("inventory")
        expect_equal("inventory", widget:getStyleClass())
    end)

    -- @covers LUiWidget:setIcon
    it("setIcon stores a known built-in icon name", function()
        local widget = basic_widget()
        expect_true(widget:setIcon("save"))
        expect_equal("save", widget:getIcon())
        expect_false(widget:setIcon("missing-icon"))
        expect_equal("save", widget:getIcon())
    end)

    -- @covers LUiWidget:getIcon
    it("getIcon returns nil until an icon is assigned", function()
        local widget = basic_widget()
        expect_nil(widget:getIcon())
        widget:setIcon("map")
        expect_equal("map", widget:getIcon())
    end)

    -- @covers LUiWidget:clearIcon
    it("clearIcon removes the assigned icon", function()
        local widget = basic_widget()
        widget:setIcon("settings")
        widget:clearIcon()
        expect_nil(widget:getIcon())
    end)

    -- @covers LUiWidget:setIconPosition
    it("setIconPosition accepts supported placements", function()
        local widget = basic_widget()
        expect_true(widget:setIconPosition("right"))
        expect_equal("right", widget:getIconPosition())
        expect_false(widget:setIconPosition("diagonal"))
        expect_equal("right", widget:getIconPosition())
    end)

    -- @covers LUiWidget:getIconPosition
    it("getIconPosition returns the default placement", function()
        expect_equal("left", basic_widget():getIconPosition())
    end)

    -- @covers LUiWidget:setIconSize
    it("setIconSize stores a finite non-negative size", function()
        local widget = basic_widget()
        expect_true(widget:setIconSize(18))
        expect_equal(18, widget:getIconSize())
        expect_false(widget:setIconSize(-1))
        expect_equal(18, widget:getIconSize())
    end)

    -- @covers LUiWidget:getIconSize
    it("getIconSize returns zero before override", function()
        expect_equal(0, basic_widget():getIconSize())
    end)

    -- @covers LUiWidget:setMouseFilter
    it("setMouseFilter stores mouse filtering policy", function()
        local widget = basic_widget()
        widget:setMouseFilter("ignore")
        expect_equal("ignore", widget:getMouseFilter())
    end)

    -- @covers LUiWidget:getMouseFilter
    it("getMouseFilter returns the current mouse filtering policy", function()
        local widget = basic_widget()
        widget:setMouseFilter("ignore")
        expect_equal("ignore", widget:getMouseFilter())
    end)

    -- @covers LUiWidget:setTextWrap
    it("setTextWrap is callable", function()
        expect_no_error(function()
            basic_widget():setTextWrap(true)
        end)
    end)

    -- @covers LUiWidget:setTextEllipsis
    it("setTextEllipsis is callable", function()
        expect_no_error(function()
            basic_widget():setTextEllipsis(true)
        end)
    end)

    -- @covers LUiWidget:setTextVAlign
    it("setTextVAlign is callable", function()
        expect_no_error(function()
            basic_widget():setTextVAlign("center")
        end)
    end)

    -- @covers LUiWidget:setTextAlign
    it("setTextAlign updates horizontal text alignment", function()
        local widget = basic_widget()
        expect_true(widget:setTextAlign("right"))
        expect_equal("right", widget:getTextAlign())
        expect_false(widget:setTextAlign("invalid"))
        expect_equal("right", widget:getTextAlign())
    end)

    -- @covers LUiWidget:getTextAlign
    it("getTextAlign returns the default horizontal text alignment", function()
        expect_equal("center", basic_widget():getTextAlign())
    end)

    -- @covers LUiWidget:setFocusable
    it("setFocusable is callable", function()
        expect_no_error(function()
            basic_widget():setFocusable(true)
        end)
    end)

    -- @covers LUiWidget:setTabIndex
    it("setTabIndex is callable", function()
        expect_no_error(function()
            basic_widget():setTabIndex(3)
        end)
    end)

    -- @covers LUiWidget:setFocusGroup
    it("setFocusGroup is callable", function()
        expect_no_error(function()
            basic_widget():setFocusGroup("menu")
        end)
    end)

    -- @covers LUiWidget:setFocusNeighbor
    it("setFocusNeighbor accepts neighbor widget indices", function()
        local a = basic_widget()
        local b = basic_widget()
        expect_no_error(function()
            a:setFocusNeighbor("right", b._idx)
        end)
    end)

    -- @covers LUiWidget:setRole
    it("setRole is callable", function()
        expect_no_error(function()
            basic_widget():setRole("button")
        end)
    end)

    -- @covers LUiWidget:getRole
    it("getRole returns the stored semantic role", function()
        local widget = basic_widget()
        widget:setRole("button")
        expect_equal("button", widget:getRole())
    end)

    -- @covers LUiWidget:setAriaName
    it("setAriaName is callable", function()
        expect_no_error(function()
            basic_widget():setAriaName("primary action")
        end)
    end)

    -- @covers LUiWidget:getAriaName
    it("getAriaName returns the stored accessible name", function()
        local widget = basic_widget()
        widget:setAriaName("primary action")
        expect_equal("primary action", widget:getAriaName())
    end)

    -- @covers LUiWidget:setLabelFor
    it("setLabelFor stores widget linkage for accessibility", function()
        local label = lurek.ui.newLabel("Name")
        local input = lurek.ui.newTextInput()
        label:setLabelFor(input._idx)
        expect_equal(input._idx, label:getLabelFor())
    end)

    -- @covers LUiWidget:getLabelFor
    it("getLabelFor returns the linked widget index", function()
        local label = lurek.ui.newLabel("Name")
        local input = lurek.ui.newTextInput()
        label:setLabelFor(input._idx)
        expect_equal(input._idx, label:getLabelFor())
    end)

    -- @covers lurek.ui.getAccessibilityTree
    it("accessibility tree exposes fallback names and validateUx reports warnings", function()
        local label = lurek.ui.newLabel("Name")
        local input = lurek.ui.newTextInput()
        label:setLabelFor(input._idx)

        local panel = basic_widget()
        panel:setFocusable(true)
        panel:setId("dup_accessibility")

        local button = basic_widget()
        button:setId("dup_accessibility")
        button:setRole("button")
        button:setAriaName("Save")

        local nodes = lurek.ui.getAccessibilityTree()
        local input_node = nil
        for i = 1, #nodes do
            if nodes[i].widget_idx == input._idx then
                input_node = nodes[i]
                break
            end
        end

        expect_not_nil(input_node)
        expect_equal("Name", input_node.name)
        expect_equal("textbox", input_node.role)

        local diagnostics = lurek.ui.validateUx()
        local saw_duplicate = false
        local saw_missing_name = false
        for i = 1, #diagnostics do
            local message = diagnostics[i].message or ""
            if message:find("duplicates widget", 1, true) then
                saw_duplicate = true
            end
            if diagnostics[i].widget_idx == panel._idx and message:find("no accessible name", 1, true) then
                saw_missing_name = true
            end
        end

        expect_true(saw_duplicate)
        expect_true(saw_missing_name)
    end)

    -- @covers lurek.ui.validateUx
    it("validateUx reports dialog, popup, and touch-target warnings", function()
        lurek.ui.clear()
        lurek.ui.setViewport(100, 100)
        local dialog = lurek.ui.newDialog("Confirm")
        dialog:open()
        dialog:setModal(true)
        dialog:setCloseable(false)
        dialog:setPosition(-20, 10)
        dialog:setSize(120, 90)
        dialog:setZOrder(10)

        local window = lurek.ui.newWindow("Inspector")
        window:setVisible(true)
        window:setPosition(-15, 20)
        window:setSize(160, 120)
        window:setZOrder(10)

        local button = lurek.ui.newButton("Tiny")
        button:setSize(30, 20)

        local diagnostics = lurek.ui.validateUx()
        local saw_default = false
        local saw_cancel = false
        local saw_offscreen = false
        local saw_zorder = false
        local saw_touch = false
        for i = 1, #diagnostics do
            local message = diagnostics[i].message or ""
            if diagnostics[i].widget_idx == dialog._idx and message:find("no default action", 1, true) then
                saw_default = true
            end
            if diagnostics[i].widget_idx == dialog._idx and message:find("no cancel action", 1, true) then
                saw_cancel = true
            end
            if message:find("outside the active viewport", 1, true) then
                saw_offscreen = true
            end
            if message:find("shares z-order", 1, true) then
                saw_zorder = true
            end
            if diagnostics[i].widget_idx == button._idx and message:find("touch target", 1, true) then
                saw_touch = true
            end
        end
        expect_true(saw_default)
        expect_true(saw_cancel)
        expect_true(saw_offscreen)
        expect_true(saw_zorder)
        expect_true(saw_touch)
    end)

    -- @covers LUiWidget:setBindKey
    it("setBindKey is callable", function()
        expect_no_error(function()
            basic_widget():setBindKey("hp")
        end)
    end)

    -- @covers LUiWidget:animateAlpha
    it("animateAlpha starts a widget alpha animation", function()
        local widget = basic_widget()
        expect_no_error(function()
            widget:animateAlpha(0.0, 1.0, 0.5, "linear")
        end)
    end)

    -- @covers LUiWidget:animatePosition
    it("animatePosition starts a widget position animation", function()
        local widget = basic_widget()
        expect_no_error(function()
            widget:animatePosition(10, 10, 40, 50, 0.5, "linear")
        end)
    end)

    -- @covers LUiWidget:isAnimating
    it("isAnimating returns a boolean animation state", function()
        expect_type("boolean", basic_widget():isAnimating())
    end)

    -- @covers LUiWidget:cancelAnimations
    it("cancelAnimations is callable after scheduling animations", function()
        local widget = basic_widget()
        widget:animateAlpha(0.0, 1.0, 0.5, "linear")
        expect_no_error(function()
            widget:cancelAnimations()
        end)
    end)
end)

-- @describe supplemental compound widgets
describe("supplemental compound widgets", function()
    -- @covers LLayout:setColumns
    it("layout setColumns updates the column count", function()
        local layout = lurek.ui.newLayout("grid")
        expect_no_error(function()
            layout:setColumns(3)
        end)
    end)

    -- @covers LLayout:setWrap
    it("layout setWrap updates wrapping behavior", function()
        local layout = lurek.ui.newLayout("horizontal")
        layout:setWrap(true)
        expect_true(layout:getWrap())
    end)

    -- @covers LLayout:getWrap
    it("layout getWrap returns wrapping behavior", function()
        local layout = lurek.ui.newLayout("horizontal")
        layout:setWrap(true)
        expect_true(layout:getWrap())
    end)

    -- @covers LLayout:setAlign
    it("layout setAlign updates cross-axis alignment", function()
        local layout = lurek.ui.newLayout("horizontal")
        layout:setAlign("center")
        expect_equal("center", layout:getAlign())
    end)

    -- @covers LLayout:getAlign
    it("layout getAlign returns cross-axis alignment", function()
        local layout = lurek.ui.newLayout("horizontal")
        layout:setAlign("center")
        expect_equal("center", layout:getAlign())
    end)

    -- @covers LLayout:setJustify
    it("layout setJustify updates main-axis justification", function()
        local layout = lurek.ui.newLayout("horizontal")
        layout:setJustify("space_between")
        expect_equal("space_between", layout:getJustify())
    end)

    -- @covers LLayout:getJustify
    it("layout getJustify returns main-axis justification", function()
        local layout = lurek.ui.newLayout("horizontal")
        layout:setJustify("space_between")
        expect_equal("space_between", layout:getJustify())
    end)

    -- @covers LNinePatch:setInsets
    it("nine-patch setInsets stores slice inset values", function()
        local patch = lurek.ui.newNinePatch()
        patch:setInsets(2, 3, 4, 5)
        local t, r, b, l = patch:getInsets()
        expect_equal(2, t)
        expect_equal(5, l)
    end)

    -- @covers LNinePatch:getInsets
    it("nine-patch getInsets returns slice inset values", function()
        local patch = lurek.ui.newNinePatch()
        patch:setInsets(2, 3, 4, 5)
        local t, r, b, l = patch:getInsets()
        expect_equal(3, r)
        expect_equal(4, b)
    end)

    -- @covers LNinePatch:setImageDimensions
    it("nine-patch setImageDimensions stores source image size", function()
        local patch = lurek.ui.newNinePatch()
        patch:setImageDimensions(64, 32)
        local w, h = patch:getImageDimensions()
        expect_equal(64, w)
        expect_equal(32, h)
    end)

    -- @covers LNinePatch:getImageDimensions
    it("nine-patch getImageDimensions returns source image size", function()
        local patch = lurek.ui.newNinePatch()
        patch:setImageDimensions(64, 32)
        local w, h = patch:getImageDimensions()
        expect_equal(64, w)
        expect_equal(32, h)
    end)

    -- @covers LNinePatch:getSlices
    it("nine-patch getSlices returns a table of slice rectangles", function()
        local patch = lurek.ui.newNinePatch()
        expect_type("table", patch:getSlices())
    end)

    -- @covers LToast:setMessage
    it("toast setMessage updates the message text", function()
        local toast = lurek.ui.newToast("old", 5.0)
        toast:setMessage("new")
        expect_equal("new", toast:getMessage())
    end)

    -- @covers LToast:getMessage
    it("toast getMessage returns the current message text", function()
        local toast = lurek.ui.newToast("hello", 5.0)
        expect_equal("hello", toast:getMessage())
    end)

    -- @covers LToast:setDuration
    it("toast setDuration updates its lifetime", function()
        local toast = lurek.ui.newToast("hello", 5.0)
        toast:setDuration(2.5)
        expect_equal(2.5, toast:getDuration())
    end)

    -- @covers LToast:getDuration
    it("toast getDuration returns its configured lifetime", function()
        local toast = lurek.ui.newToast("hello", 5.0)
        expect_equal(5.0, toast:getDuration())
    end)
end)

local function image_has_drawn_pixels(img)
    for y = 0, img:getHeight() - 1 do
        for x = 0, img:getWidth() - 1 do
            local r, g, b, a = img:getPixel(x, y)
            if r ~= 0 or g ~= 0 or b ~= 0 or a ~= 0 then
                return true
            end
        end
    end
    return false
end

local function expect_chart_draws(chart, width, height)
    local img = lurek.image.newImageData(width, height)
    chart:drawToImage(img)
    expect_true(image_has_drawn_pixels(img))
end

local function make_dialog(title)
    return lurek.ui.newDialog(title or "Dialog")
end

-- @describe additional ui owner coverage
describe("additional ui owner coverage", function()
    -- @covers lurek.ui.update
    it("update dispatches queued close callbacks", function()
        local called = false
        local dialog = make_dialog("Update owner")
        dialog:setOnClose(function(widget_idx)
            called = widget_idx == dialog._idx
        end)
        dialog:open()
        dialog:close()
        expect_false(called)
        lurek.ui.update(0.0)
        expect_true(called)
    end)

    -- @covers LUiWidget:setFont
    it("widget setFont stores a widget-local font override", function()
        local widget = basic_widget()
        local font = lurek.render.newFont("font_12")
        widget:setFont(font)
        expect_type("userdata", lurek.ui.getWidgetFont(widget))
    end)

    -- @covers LTheme:setStyle
    it("theme setStyle accepts widget state style tables", function()
        local theme = lurek.ui.newTheme()
        expect_true(theme:setStyle("button", "normal", {
            bg = { 0.2, 0.3, 0.4, 1.0 },
            fg = { 1.0, 1.0, 1.0, 1.0 },
            borderWidth = 2,
        }))
    end)

    -- @covers LTheme:type
    it("theme type returns LTheme", function()
        expect_equal("LTheme", lurek.ui.newTheme():type())
    end)

    -- @covers LTheme:typeOf
    it("theme typeOf recognizes LTheme", function()
        expect_true(lurek.ui.newTheme():typeOf("LTheme"))
    end)
end)

-- @describe ui dialog owner coverage
describe("ui dialog owner coverage", function()
    -- @covers LDialog:getTitle
    it("dialog getTitle returns the current title", function()
        expect_equal("My Dialog", make_dialog("My Dialog"):getTitle())
    end)

    -- @covers LDialog:setTitle
    it("dialog setTitle updates the title", function()
        local dialog = make_dialog("Old")
        dialog:setTitle("New Title")
        expect_equal("New Title", dialog:getTitle())
    end)

    -- @covers LDialog:isModal
    it("dialog isModal reports the modal flag", function()
        local dialog = make_dialog("Modal")
        dialog:setModal(true)
        expect_true(dialog:isModal())
    end)

    -- @covers LDialog:setModal
    it("dialog setModal updates the modal flag", function()
        local dialog = make_dialog("Modal")
        dialog:setModal(false)
        expect_false(dialog:isModal())
    end)

    -- @covers LDialog:isOpen
    it("dialog isOpen reports whether the dialog is open", function()
        local dialog = make_dialog("Open")
        dialog:open()
        expect_true(dialog:isOpen())
    end)

    -- @covers LDialog:open
    it("dialog open marks the dialog as open", function()
        local dialog = make_dialog("Open")
        dialog:open()
        expect_true(dialog:isOpen())
    end)

    -- @covers LDialog:close
    it("dialog close marks the dialog as closed", function()
        local dialog = make_dialog("Close")
        dialog:open()
        dialog:close()
        expect_false(dialog:isOpen())
    end)

    -- @covers LDialog:setOnClose
    it("dialog setOnClose registers a callback fired on close", function()
        local called = false
        local dialog = make_dialog("Close callback")
        dialog:setOnClose(function(widget_idx)
            called = widget_idx == dialog._idx
        end)
        dialog:open()
        dialog:close()
        lurek.ui.update(0.0)
        expect_true(called)
    end)

    -- @covers LDialog:setContent
    it("dialog setContent stores the content widget index", function()
        local dialog = make_dialog("Content")
        local panel = lurek.ui.newPanel()
        dialog:setContent(panel._idx)
        expect_equal(panel._idx, dialog:getContent())
    end)

    -- @covers LDialog:getContent
    it("dialog getContent returns the configured content widget index", function()
        local dialog = make_dialog("Content")
        local panel = lurek.ui.newPanel()
        dialog:setContent(panel._idx)
        expect_equal(panel._idx, dialog:getContent())
    end)

    -- @covers LDialog:setFooter
    it("dialog setFooter stores the footer widget index", function()
        local dialog = make_dialog("Footer")
        local footer = lurek.ui.newPanel()
        dialog:setFooter(footer._idx)
        expect_equal(footer._idx, dialog:getFooter())
    end)

    -- @covers LDialog:getFooter
    it("dialog getFooter returns the configured footer widget index", function()
        local dialog = make_dialog("Footer")
        local footer = lurek.ui.newPanel()
        dialog:setFooter(footer._idx)
        expect_equal(footer._idx, dialog:getFooter())
    end)

    -- @covers LDialog:isCloseable
    it("dialog isCloseable reports the closeable flag", function()
        local dialog = make_dialog("Closeable")
        dialog:setCloseable(false)
        expect_false(dialog:isCloseable())
    end)

    -- @covers LDialog:setCloseable
    it("dialog setCloseable updates the closeable flag", function()
        local dialog = make_dialog("Closeable")
        dialog:setCloseable(false)
        expect_false(dialog:isCloseable())
    end)

    -- @covers LDialog:isDraggable
    it("dialog isDraggable reports the draggable flag", function()
        local dialog = make_dialog("Draggable")
        dialog:setDraggable(false)
        expect_false(dialog:isDraggable())
    end)

    -- @covers LDialog:setDraggable
    it("dialog setDraggable updates the draggable flag", function()
        local dialog = make_dialog("Draggable")
        dialog:setDraggable(true)
        expect_true(dialog:isDraggable())
    end)

    -- @covers LDialog:isResizable
    it("dialog isResizable reports the resizable flag", function()
        local dialog = make_dialog("Resizable")
        dialog:setResizable(false)
        expect_false(dialog:isResizable())
    end)

    -- @covers LDialog:setResizable
    it("dialog setResizable updates the resizable flag", function()
        local dialog = make_dialog("Resizable")
        dialog:setResizable(true)
        expect_true(dialog:isResizable())
    end)

    -- @covers LDialog:setMinSize
    it("dialog setMinSize stores minimum popup dimensions", function()
        local dialog = make_dialog("Min size")
        dialog:setMinSize(220, 140)
        local w, h = dialog:getMinSize()
        expect_equal(220, w)
        expect_equal(140, h)
    end)

    -- @covers LDialog:getMinSize
    it("dialog getMinSize returns the configured minimum size", function()
        local dialog = make_dialog("Min size")
        dialog:setMinSize(200, 120)
        local w, h = dialog:getMinSize()
        expect_equal(200, w)
        expect_equal(120, h)
    end)

    -- @covers LDialog:setMaxSize
    it("dialog setMaxSize stores maximum popup dimensions", function()
        local dialog = make_dialog("Max size")
        dialog:setMaxSize(420, 260)
        local w, h = dialog:getMaxSize()
        expect_equal(420, w)
        expect_equal(260, h)
    end)

    -- @covers LDialog:getMaxSize
    it("dialog getMaxSize returns the configured maximum size", function()
        local dialog = make_dialog("Max size")
        dialog:setMaxSize(480, 320)
        local w, h = dialog:getMaxSize()
        expect_equal(480, w)
        expect_equal(320, h)
    end)

    -- @covers LDialog:setDismissOnOutsideClick
    it("dialog setDismissOnOutsideClick updates outside dismiss behavior", function()
        local dialog = make_dialog("Dismiss")
        dialog:setDismissOnOutsideClick(true)
        expect_true(dialog:getDismissOnOutsideClick())
    end)

    -- @covers LDialog:getDismissOnOutsideClick
    it("dialog getDismissOnOutsideClick reports outside dismiss behavior", function()
        local dialog = make_dialog("Dismiss")
        dialog:setDismissOnOutsideClick(true)
        expect_true(dialog:getDismissOnOutsideClick())
    end)

    -- @covers LDialog:setCenterOnOpen
    it("dialog setCenterOnOpen updates center-on-open behavior", function()
        local dialog = make_dialog("Center on open")
        dialog:setCenterOnOpen(false)
        expect_false(dialog:getCenterOnOpen())
    end)

    -- @covers LDialog:getCenterOnOpen
    it("dialog getCenterOnOpen reports center-on-open behavior", function()
        local dialog = make_dialog("Center on open")
        dialog:setCenterOnOpen(false)
        expect_false(dialog:getCenterOnOpen())
    end)

    -- @covers LDialog:centerInViewport
    it("dialog centerInViewport moves the dialog away from the origin", function()
        local dialog = make_dialog("Center now")
        lurek.ui.setViewport(800, 600)
        dialog:setSize(200, 100)
        dialog:setPosition(0, 0)
        dialog:centerInViewport()
        local x, y = dialog:getPosition()
        expect_true(x > 0)
        expect_true(y > 0)
    end)

    -- @covers LDialog:addAction
    it("dialog addAction returns a 1 based action index", function()
        local dialog = make_dialog("Actions")
        expect_equal(1, dialog:addAction("Apply", nil, "default", true))
    end)

    -- @covers LDialog:addButton
    it("dialog addButton returns a 1 based action index", function()
        local dialog = make_dialog("Buttons")
        expect_equal(1, dialog:addButton("OK"))
    end)

    -- @covers LDialog:setDefaultAction
    it("dialog setDefaultAction stores the default action", function()
        local dialog = make_dialog("Default")
        local idx = dialog:addAction("Confirm", nil, "default", true)
        dialog:setDefaultAction(idx)
        expect_equal(idx, dialog:getDefaultAction())
    end)

    -- @covers LDialog:getDefaultAction
    it("dialog getDefaultAction returns the configured default action", function()
        local dialog = make_dialog("Default")
        local idx = dialog:addAction("Confirm", nil, "default", true)
        dialog:setDefaultAction(idx)
        expect_equal(idx, dialog:getDefaultAction())
    end)

    -- @covers LDialog:setCancelAction
    it("dialog setCancelAction stores the cancel action", function()
        local dialog = make_dialog("Cancel")
        local idx = dialog:addAction("Abort", nil, "cancel", true)
        dialog:setCancelAction(idx)
        expect_equal(idx, dialog:getCancelAction())
    end)

    -- @covers LDialog:getCancelAction
    it("dialog getCancelAction returns the configured cancel action", function()
        local dialog = make_dialog("Cancel")
        local idx = dialog:addAction("Abort", nil, "cancel", true)
        dialog:setCancelAction(idx)
        expect_equal(idx, dialog:getCancelAction())
    end)
end)

-- @describe ui retained widget owner coverage
describe("ui retained widget owner coverage", function()
    -- @covers LTreeView:addNode
    it("tree view addNode returns a 1 based node index", function()
        local tree = lurek.ui.newTreeView()
        expect_equal(1, tree:addNode("Root"))
    end)

    -- @covers LTreeView:toggleNode
    it("tree view toggleNode toggles expanded state", function()
        local tree = lurek.ui.newTreeView()
        local root = tree:addNode("Root")
        tree:addNode("Child", root)
        expect_true(tree:toggleNode(root))
    end)

    -- @covers LTreeView:isExpanded
    it("tree view isExpanded reports the root expanded state", function()
        local tree = lurek.ui.newTreeView()
        local root = tree:addNode("Root")
        tree:addNode("Child", root)
        tree:expandNode(root)
        expect_true(tree:isExpanded(root))
    end)

    -- @covers LTreeView:getNodeCount
    it("tree view getNodeCount returns the total node count", function()
        local tree = lurek.ui.newTreeView()
        local root = tree:addNode("Root")
        tree:addNode("Child", root)
        expect_equal(2, tree:getNodeCount())
    end)

    -- @covers LTreeView:removeNode
    it("tree view removeNode removes an existing node", function()
        local tree = lurek.ui.newTreeView()
        local root = tree:addNode("Root")
        expect_true(tree:removeNode(root))
    end)

    -- @covers LTreeView:clearNodes
    it("tree view clearNodes removes all nodes", function()
        local tree = lurek.ui.newTreeView()
        local root = tree:addNode("Root")
        tree:addNode("Child", root)
        tree:clearNodes()
        expect_equal(0, tree:getNodeCount())
    end)

    -- @covers LTreeView:getNodeText
    it("tree view getNodeText returns the node label", function()
        local tree = lurek.ui.newTreeView()
        local root = tree:addNode("Root")
        expect_equal("Root", tree:getNodeText(root))
    end)

    -- @covers LTreeView:setNodeText
    it("tree view setNodeText updates the node label", function()
        local tree = lurek.ui.newTreeView()
        local root = tree:addNode("Root")
        expect_true(tree:setNodeText(root, "Renamed"))
        expect_equal("Renamed", tree:getNodeText(root))
    end)

    -- @covers LTreeView:setNodeIcon
    it("tree view setNodeIcon accepts an icon identifier", function()
        local tree = lurek.ui.newTreeView()
        local root = tree:addNode("Root")
        expect_true(tree:setNodeIcon(root, "folder"))
    end)

    -- @covers LTreeView:expandNode
    it("tree view expandNode expands a collapsed node", function()
        local tree = lurek.ui.newTreeView()
        local root = tree:addNode("Root")
        tree:addNode("Child", root)
        expect_true(tree:expandNode(root))
    end)

    -- @covers LTreeView:collapseNode
    it("tree view collapseNode collapses an expanded node", function()
        local tree = lurek.ui.newTreeView()
        local root = tree:addNode("Root")
        tree:addNode("Child", root)
        tree:expandNode(root)
        expect_true(tree:collapseNode(root))
    end)

    -- @covers LTreeView:isNodeExpanded
    it("tree view isNodeExpanded returns the expanded state or nil", function()
        local tree = lurek.ui.newTreeView()
        local root = tree:addNode("Root")
        tree:addNode("Child", root)
        tree:expandNode(root)
        expect_true(tree:isNodeExpanded(root))
    end)

    -- @covers LTreeView:expandAll
    it("tree view expandAll expands every expandable node", function()
        local tree = lurek.ui.newTreeView()
        local root = tree:addNode("Root")
        tree:addNode("Child", root)
        tree:expandAll()
        expect_true(tree:isNodeExpanded(root))
    end)

    -- @covers LTreeView:collapseAll
    it("tree view collapseAll collapses expanded nodes", function()
        local tree = lurek.ui.newTreeView()
        local root = tree:addNode("Root")
        tree:addNode("Child", root)
        tree:expandAll()
        tree:collapseAll()
        expect_false(tree:isNodeExpanded(root))
    end)

    -- @covers LTreeView:setSelectedNode
    it("tree view setSelectedNode stores the selected node", function()
        local tree = lurek.ui.newTreeView()
        local root = tree:addNode("Root")
        expect_true(tree:setSelectedNode(root))
        expect_equal(root, tree:getSelectedNode())
    end)

    -- @covers LTreeView:getSelectedNode
    it("tree view getSelectedNode returns the selected node index", function()
        local tree = lurek.ui.newTreeView()
        local root = tree:addNode("Root")
        tree:setSelectedNode(root)
        expect_equal(root, tree:getSelectedNode())
    end)

    -- @covers LTreeView:getChildNodes
    it("tree view getChildNodes returns 1 based child indices", function()
        local tree = lurek.ui.newTreeView()
        local root = tree:addNode("Root")
        local child = tree:addNode("Child", root)
        local children = tree:getChildNodes(root)
        expect_equal(1, #children)
        expect_equal(child, children[1])
    end)

    -- @covers LTreeView:getParentNode
    it("tree view getParentNode returns the 1 based parent index", function()
        local tree = lurek.ui.newTreeView()
        local root = tree:addNode("Root")
        local child = tree:addNode("Child", root)
        expect_equal(root, tree:getParentNode(child))
    end)

    -- @covers LTreeView:getNodeDepth
    it("tree view getNodeDepth returns 0 for root and 1 for child", function()
        local tree = lurek.ui.newTreeView()
        local root = tree:addNode("Root")
        local child = tree:addNode("Child", root)
        expect_equal(1, tree:getNodeDepth(child))
    end)

    -- @covers LRadioButton:getText
    it("radio button getText returns its label", function()
        expect_equal("Option A", lurek.ui.newRadioButton("Option A", "group1"):getText())
    end)

    -- @covers LRadioButton:setText
    it("radio button setText updates its label", function()
        local radio = lurek.ui.newRadioButton("Old", "group1")
        radio:setText("New")
        expect_equal("New", radio:getText())
    end)

    -- @covers LRadioButton:isSelected
    it("radio button isSelected reports the current selection flag", function()
        local radio = lurek.ui.newRadioButton("Option A", "group1")
        radio:setSelected(true)
        expect_true(radio:isSelected())
    end)

    -- @covers LRadioButton:setSelected
    it("radio button setSelected updates the selection flag", function()
        local radio = lurek.ui.newRadioButton("Option A", "group1")
        radio:setSelected(true)
        expect_true(radio:isSelected())
    end)

    -- @covers LRadioButton:getGroup
    it("radio button getGroup returns the group name", function()
        expect_equal("group1", lurek.ui.newRadioButton("Option A", "group1"):getGroup())
    end)

    -- @covers LRadioButton:setGroup
    it("radio button setGroup updates the group name", function()
        local radio = lurek.ui.newRadioButton("Option A", "group1")
        radio:setGroup("group2")
        expect_equal("group2", radio:getGroup())
    end)

    -- @covers LRadioButton:setOnChange
    it("radio button setOnChange accepts a change callback", function()
        local radio = lurek.ui.newRadioButton("Option A", "group1")
        expect_no_error(function()
            radio:setOnChange(function() end)
        end)
    end)

    -- @covers LScrollBar:getScrollPosition
    it("scroll bar getScrollPosition returns the current position", function()
        local scroll = lurek.ui.newScrollBar(true)
        scroll:setContentSize(300)
        scroll:setViewSize(100)
        scroll:setScrollPosition(40)
        expect_equal(40, scroll:getScrollPosition())
    end)

    -- @covers LScrollBar:setScrollPosition
    it("scroll bar setScrollPosition clamps and stores the position", function()
        local scroll = lurek.ui.newScrollBar(true)
        scroll:setContentSize(300)
        scroll:setViewSize(100)
        scroll:setScrollPosition(500)
        expect_equal(200, scroll:getScrollPosition())
    end)

    -- @covers LScrollBar:getContentSize
    it("scroll bar getContentSize returns the tracked content size", function()
        local scroll = lurek.ui.newScrollBar(true)
        scroll:setContentSize(250)
        expect_equal(250, scroll:getContentSize())
    end)

    -- @covers LScrollBar:setContentSize
    it("scroll bar setContentSize updates the tracked content size", function()
        local scroll = lurek.ui.newScrollBar(true)
        scroll:setContentSize(250)
        expect_equal(250, scroll:getContentSize())
    end)

    -- @covers LScrollBar:getViewSize
    it("scroll bar getViewSize returns the viewport size", function()
        local scroll = lurek.ui.newScrollBar(true)
        scroll:setViewSize(90)
        expect_equal(90, scroll:getViewSize())
    end)

    -- @covers LScrollBar:setViewSize
    it("scroll bar setViewSize updates the viewport size", function()
        local scroll = lurek.ui.newScrollBar(true)
        scroll:setViewSize(90)
        expect_equal(90, scroll:getViewSize())
    end)

    -- @covers LScrollBar:isVertical
    it("scroll bar isVertical reflects constructor orientation", function()
        expect_true(lurek.ui.newScrollBar(true):isVertical())
    end)

    -- @covers LScrollBar:setOnChange
    it("scroll bar setOnChange accepts a change callback", function()
        local scroll = lurek.ui.newScrollBar(true)
        expect_no_error(function()
            scroll:setOnChange(function() end)
        end)
    end)

    -- @covers LGuiWindow:getTitle
    it("gui window getTitle returns the title text", function()
        expect_equal("Inspector", lurek.ui.newWindow("Inspector"):getTitle())
    end)

    -- @covers LGuiWindow:setTitle
    it("gui window setTitle updates the title text", function()
        local window = lurek.ui.newWindow("Old")
        window:setTitle("New")
        expect_equal("New", window:getTitle())
    end)

    -- @covers LGuiWindow:isCloseable
    it("gui window isCloseable reports the closeable flag", function()
        local window = lurek.ui.newWindow("Window")
        window:setCloseable(false)
        expect_false(window:isCloseable())
    end)

    -- @covers LGuiWindow:setCloseable
    it("gui window setCloseable updates the closeable flag", function()
        local window = lurek.ui.newWindow("Window")
        window:setCloseable(true)
        expect_true(window:isCloseable())
    end)

    -- @covers LGuiWindow:isDraggable
    it("gui window isDraggable reports the draggable flag", function()
        local window = lurek.ui.newWindow("Window")
        window:setDraggable(false)
        expect_false(window:isDraggable())
    end)

    -- @covers LGuiWindow:setDraggable
    it("gui window setDraggable updates the draggable flag", function()
        local window = lurek.ui.newWindow("Window")
        window:setDraggable(true)
        expect_true(window:isDraggable())
    end)

    -- @covers LGuiWindow:isResizable
    it("gui window isResizable reports the resizable flag", function()
        local window = lurek.ui.newWindow("Window")
        window:setResizable(false)
        expect_false(window:isResizable())
    end)

    -- @covers LGuiWindow:setResizable
    it("gui window setResizable updates the resizable flag", function()
        local window = lurek.ui.newWindow("Window")
        window:setResizable(true)
        expect_true(window:isResizable())
    end)

    -- @covers LGuiWindow:setOnClose
    it("gui window setOnClose accepts a close callback", function()
        local window = lurek.ui.newWindow("Window")
        expect_no_error(function()
            window:setOnClose(function() end)
        end)
    end)

    -- @covers lurek.ui.newSplitContainer
    it("newSplitContainer creates a split panel alias", function()
        local split = lurek.ui.newSplitContainer("vertical")
        expect_equal("vertical", split:getOrientation())
    end)

    -- @covers lurek.ui.newStackContainer
    it("newStackContainer creates a layered page container", function()
        local stack = lurek.ui.newStackContainer()
        stack:addChild(lurek.ui.newPanel())
        expect_equal(1, stack:getChildCount())
    end)

    -- @covers LStackContainer:setActiveIndex
    it("stack container setActiveIndex selects a child page", function()
        local stack = lurek.ui.newStackContainer()
        local first = lurek.ui.newPanel()
        local second = lurek.ui.newPanel()
        stack:addChild(first)
        stack:addChild(second)
        expect_true(stack:setActiveIndex(2))
        expect_equal(2, stack:getActiveIndex())
    end)

    -- @covers LStackContainer:getActiveIndex
    it("stack container getActiveIndex returns the active page", function()
        local stack = lurek.ui.newStackContainer()
        stack:addChild(lurek.ui.newPanel())
        expect_equal(1, stack:getActiveIndex())
    end)

    -- @covers LStackContainer:getActiveChild
    it("stack container getActiveChild returns the active widget index", function()
        local stack = lurek.ui.newStackContainer()
        local child = lurek.ui.newPanel()
        stack:addChild(child)
        expect_equal(child._idx, stack:getActiveChild())
    end)

    -- @covers LStackContainer:addTab
    it("stack container addTab appends a page label", function()
        local stack = lurek.ui.newStackContainer()
        stack:addTab("Inventory")
        expect_equal(1, stack:getTabCount())
    end)

    -- @covers LStackContainer:getTab
    it("stack container getTab returns a page label", function()
        local stack = lurek.ui.newStackContainer()
        stack:addTab("Map")
        expect_equal("Map", stack:getTab(1))
    end)

    -- @covers LStackContainer:getTabCount
    it("stack container getTabCount returns the page label count", function()
        local stack = lurek.ui.newStackContainer()
        stack:addTab("Stats")
        stack:addTab("Equipment")
        expect_equal(2, stack:getTabCount())
    end)

    -- @covers lurek.ui.newTabContainer
    it("newTabContainer creates a tabbed page container", function()
        local tabs = lurek.ui.newTabContainer()
        expect_not_nil(tabs)
        expect_equal(0, tabs:getTabCount())
    end)

    -- @covers LTabContainer:setActiveIndex
    it("tab container setActiveIndex selects a child page", function()
        local tabs = lurek.ui.newTabContainer()
        local first = lurek.ui.newPanel()
        local second = lurek.ui.newPanel()
        tabs:addChild(first)
        tabs:addChild(second)
        expect_true(tabs:setActiveIndex(2))
        expect_equal(2, tabs:getActiveIndex())
    end)

    -- @covers LTabContainer:getActiveIndex
    it("tab container getActiveIndex returns the active page", function()
        local tabs = lurek.ui.newTabContainer()
        tabs:addChild(lurek.ui.newPanel())
        expect_equal(1, tabs:getActiveIndex())
    end)

    -- @covers LTabContainer:getActiveChild
    it("tab container getActiveChild returns the active widget index", function()
        local tabs = lurek.ui.newTabContainer()
        local child = lurek.ui.newPanel()
        tabs:addChild(child)
        expect_equal(child._idx, tabs:getActiveChild())
    end)

    -- @covers LTabContainer:addTab
    it("tab container addTab appends a label", function()
        local tabs = lurek.ui.newTabContainer()
        tabs:addTab("Video")
        expect_equal(1, tabs:getTabCount())
    end)

    -- @covers LTabContainer:getTab
    it("tab container getTab returns a label", function()
        local tabs = lurek.ui.newTabContainer()
        tabs:addTab("Audio")
        expect_equal("Audio", tabs:getTab(1))
    end)

    -- @covers LTabContainer:getTabCount
    it("tab container getTabCount returns label count", function()
        local tabs = lurek.ui.newTabContainer()
        tabs:addTab("Video")
        tabs:addTab("Controls")
        expect_equal(2, tabs:getTabCount())
    end)

    -- @covers LSplitPanel:getOrientation
    it("split panel getOrientation returns the current orientation", function()
        expect_equal("horizontal", lurek.ui.newSplitPanel("horizontal"):getOrientation())
    end)

    -- @covers LSplitPanel:setOrientation
    it("split panel setOrientation updates the orientation", function()
        local split = lurek.ui.newSplitPanel("horizontal")
        split:setOrientation("vertical")
        expect_equal("vertical", split:getOrientation())
    end)

    -- @covers LSplitPanel:getSplitPosition
    it("split panel getSplitPosition returns the split fraction", function()
        local split = lurek.ui.newSplitPanel("horizontal")
        split:setSplitPosition(0.25)
        expect_equal(0.25, split:getSplitPosition())
    end)

    -- @covers LSplitPanel:setSplitPosition
    it("split panel setSplitPosition clamps the split fraction", function()
        local split = lurek.ui.newSplitPanel("horizontal")
        split:setSplitPosition(5.0)
        expect_equal(1.0, split:getSplitPosition())
    end)

    -- @covers LSplitPanel:getMinPanelSize
    it("split panel getMinPanelSize returns the minimum panel size", function()
        local split = lurek.ui.newSplitPanel("horizontal")
        split:setMinPanelSize(90)
        expect_equal(90, split:getMinPanelSize())
    end)

    -- @covers LSplitPanel:setMinPanelSize
    it("split panel setMinPanelSize updates the minimum panel size", function()
        local split = lurek.ui.newSplitPanel("horizontal")
        split:setMinPanelSize(90)
        expect_equal(90, split:getMinPanelSize())
    end)

    -- @covers LSplitPanel:setFirstChild
    it("split panel setFirstChild stores the first child index", function()
        local split = lurek.ui.newSplitPanel("horizontal")
        local child = lurek.ui.newPanel()
        split:setFirstChild(child._idx)
        expect_equal(child._idx, split:getFirstChild())
    end)

    -- @covers LSplitPanel:setSecondChild
    it("split panel setSecondChild stores the second child index", function()
        local split = lurek.ui.newSplitPanel("horizontal")
        local child = lurek.ui.newPanel()
        split:setSecondChild(child._idx)
        expect_equal(child._idx, split:getSecondChild())
    end)

    -- @covers LSplitPanel:getFirstChild
    it("split panel getFirstChild returns the stored first child index", function()
        local split = lurek.ui.newSplitPanel("horizontal")
        local child = lurek.ui.newPanel()
        split:setFirstChild(child._idx)
        expect_equal(child._idx, split:getFirstChild())
    end)

    -- @covers LSplitPanel:getSecondChild
    it("split panel getSecondChild returns the stored second child index", function()
        local split = lurek.ui.newSplitPanel("horizontal")
        local child = lurek.ui.newPanel()
        split:setSecondChild(child._idx)
        expect_equal(child._idx, split:getSecondChild())
    end)

    -- @covers LDockPanel:dock
    it("dock panel dock adds a child to the dock set", function()
        local dock = lurek.ui.newDockPanel()
        local child = lurek.ui.newPanel()
        dock:dock(child._idx, "left")
        expect_equal(1, dock:getDockedCount())
    end)

    -- @covers LDockPanel:undock
    it("dock panel undock removes a docked child", function()
        local dock = lurek.ui.newDockPanel()
        local child = lurek.ui.newPanel()
        dock:dock(child._idx, "left")
        dock:undock(child._idx)
        expect_equal(0, dock:getDockedCount())
    end)

    -- @covers LDockPanel:getDockedCount
    it("dock panel getDockedCount returns the docked child count", function()
        local dock = lurek.ui.newDockPanel()
        local child = lurek.ui.newPanel()
        dock:dock(child._idx, "left")
        expect_equal(1, dock:getDockedCount())
    end)

    -- @covers LDockPanel:setSplitSize
    it("dock panel setSplitSize stores per side split sizes", function()
        local dock = lurek.ui.newDockPanel()
        dock:setSplitSize("left", 200)
        expect_equal(200, dock:getSplitSize("left"))
    end)

    -- @covers LDockPanel:getSplitSize
    it("dock panel getSplitSize returns the configured side size", function()
        local dock = lurek.ui.newDockPanel()
        dock:setSplitSize("left", 200)
        expect_equal(200, dock:getSplitSize("left"))
    end)
end)

-- @describe ui utility widget owner coverage
describe("ui utility widget owner coverage", function()
    -- @covers LToolbar:getOrientation
    it("toolbar getOrientation returns the current orientation", function()
        expect_equal("horizontal", lurek.ui.newToolbar("horizontal"):getOrientation())
    end)

    -- @covers LToolbar:setOrientation
    it("toolbar setOrientation updates the orientation", function()
        local toolbar = lurek.ui.newToolbar("horizontal")
        toolbar:setOrientation("vertical")
        expect_equal("vertical", toolbar:getOrientation())
    end)

    -- @covers LToolbar:addButton
    it("toolbar addButton returns a 1 based button index", function()
        local toolbar = lurek.ui.newToolbar("horizontal")
        expect_equal(1, toolbar:addButton("save", "Save current file"))
    end)

    -- @covers LToolbar:addSeparator
    it("toolbar addSeparator is callable", function()
        local toolbar = lurek.ui.newToolbar("horizontal")
        expect_no_error(function()
            toolbar:addSeparator()
        end)
    end)

    -- @covers LToolbar:addSpacer
    it("toolbar addSpacer is callable", function()
        local toolbar = lurek.ui.newToolbar("horizontal")
        expect_no_error(function()
            toolbar:addSpacer(12)
        end)
    end)

    -- @covers LToolbar:getButton
    it("toolbar getButton returns button metadata by id", function()
        local toolbar = lurek.ui.newToolbar("horizontal")
        toolbar:addButton("save", "Save current file")
        local button = toolbar:getButton("save")
        expect_equal("save", button.id)
        expect_equal("Save current file", button.tooltip)
    end)

    -- @covers LToolbar:setButtonEnabled
    it("toolbar setButtonEnabled updates button enabled state", function()
        local toolbar = lurek.ui.newToolbar("horizontal")
        toolbar:addButton("save", "Save current file")
        expect_true(toolbar:setButtonEnabled("save", false))
        expect_false(toolbar:getButton("save").enabled)
    end)

    -- @covers LToolbar:setButtonToggled
    it("toolbar setButtonToggled updates button toggle state", function()
        local toolbar = lurek.ui.newToolbar("horizontal")
        toolbar:addButton("snap", "Toggle snapping")
        expect_true(toolbar:setButtonToggled("snap", true))
        expect_true(toolbar:getButton("snap").toggled)
    end)

    -- @covers LToolbar:isButtonToggled
    it("toolbar isButtonToggled reports the current toggle state", function()
        local toolbar = lurek.ui.newToolbar("horizontal")
        toolbar:addButton("snap", "Toggle snapping")
        toolbar:setButtonToggled("snap", true)
        expect_true(toolbar:isButtonToggled("snap"))
    end)

    -- @covers LMenuBar:addMenu
    it("menu bar addMenu stores a menu widget index", function()
        local menu_bar = lurek.ui.newMenuBar()
        local file_menu = lurek.ui.newMenuItem("File")
        menu_bar:addMenu(file_menu._idx)
        expect_equal(1, menu_bar:getMenuCount())
    end)

    -- @covers LMenuBar:removeMenu
    it("menu bar removeMenu removes a stored menu widget index", function()
        local menu_bar = lurek.ui.newMenuBar()
        local file_menu = lurek.ui.newMenuItem("File")
        menu_bar:addMenu(file_menu._idx)
        expect_true(menu_bar:removeMenu(file_menu._idx))
        expect_equal(0, menu_bar:getMenuCount())
    end)

    -- @covers LMenuBar:getMenus
    it("menu bar getMenus returns stored menu widget indices", function()
        local menu_bar = lurek.ui.newMenuBar()
        local file_menu = lurek.ui.newMenuItem("File")
        menu_bar:addMenu(file_menu._idx)
        local menus = menu_bar:getMenus()
        expect_equal(1, #menus)
        expect_equal(file_menu._idx, menus[1])
    end)

    -- @covers LMenuBar:getMenuCount
    it("menu bar getMenuCount returns the number of stored menus", function()
        local menu_bar = lurek.ui.newMenuBar()
        local file_menu = lurek.ui.newMenuItem("File")
        menu_bar:addMenu(file_menu._idx)
        expect_equal(1, menu_bar:getMenuCount())
    end)

    -- @covers LMenuItem:getText
    it("menu item getText returns the display label", function()
        expect_equal("File", lurek.ui.newMenuItem("File"):getText())
    end)

    -- @covers LMenuItem:setText
    it("menu item setText updates the display label", function()
        local item = lurek.ui.newMenuItem("Old")
        item:setText("New")
        expect_equal("New", item:getText())
    end)

    -- @covers LMenuItem:getShortcut
    it("menu item getShortcut returns the assigned shortcut text", function()
        local item = lurek.ui.newMenuItem("Save")
        item:setShortcut("Ctrl+S")
        expect_equal("Ctrl+S", item:getShortcut())
    end)

    -- @covers LMenuItem:setShortcut
    it("menu item setShortcut updates the shortcut text", function()
        local item = lurek.ui.newMenuItem("Save")
        item:setShortcut("Ctrl+S")
        expect_equal("Ctrl+S", item:getShortcut())
    end)

    -- @covers LMenuItem:isChecked
    it("menu item isChecked reports the checked state", function()
        local item = lurek.ui.newMenuItem("Autosave")
        item:setChecked(true)
        expect_true(item:isChecked())
    end)

    -- @covers LMenuItem:setChecked
    it("menu item setChecked updates the checked state", function()
        local item = lurek.ui.newMenuItem("Autosave")
        item:setChecked(true)
        expect_true(item:isChecked())
    end)

    -- @covers LMenuItem:addSubItem
    it("menu item addSubItem stores a submenu widget index", function()
        local parent = lurek.ui.newMenuItem("File")
        local child = lurek.ui.newMenuItem("Save")
        parent:addSubItem(child._idx)
        expect_equal(1, #parent:getSubItems())
    end)

    -- @covers LMenuItem:getSubItems
    it("menu item getSubItems returns submenu widget indices", function()
        local parent = lurek.ui.newMenuItem("File")
        local child = lurek.ui.newMenuItem("Save")
        parent:addSubItem(child._idx)
        local items = parent:getSubItems()
        expect_equal(child._idx, items[1])
    end)

    -- @covers LMenuItem:setOnClick
    it("menu item setOnClick accepts a click callback", function()
        local item = lurek.ui.newMenuItem("Save")
        expect_no_error(function()
            item:setOnClick(function() end)
        end)
    end)

    -- @covers LStatusBar:addSection
    it("status bar addSection appends a section", function()
        local status = lurek.ui.newStatusBar()
        status:addSection("Ready", 120)
        expect_equal(1, status:getSectionCount())
    end)

    -- @covers LStatusBar:setSectionText
    it("status bar setSectionText updates section text", function()
        local status = lurek.ui.newStatusBar()
        status:addSection("Ready", 120)
        status:setSectionText(1, "Busy")
        expect_equal("Busy", status:getSectionText(1))
    end)

    -- @covers LStatusBar:getSectionText
    it("status bar getSectionText returns section text", function()
        local status = lurek.ui.newStatusBar()
        status:addSection("Ready", 120)
        expect_equal("Ready", status:getSectionText(1))
    end)

    -- @covers LStatusBar:getSectionCount
    it("status bar getSectionCount returns section count", function()
        local status = lurek.ui.newStatusBar()
        status:addSection("Ready", 120)
        expect_equal(1, status:getSectionCount())
    end)

    -- @covers LStatusBar:setSectionCount
    it("status bar setSectionCount resizes the section list", function()
        local status = lurek.ui.newStatusBar()
        status:setSectionCount(3)
        expect_equal(3, status:getSectionCount())
    end)

    -- @covers LStatusBar:setSectionWidget
    it("status bar setSectionWidget is callable", function()
        local status = lurek.ui.newStatusBar()
        status:setSectionCount(1)
        local widget = lurek.ui.newPanel()
        expect_no_error(function()
            status:setSectionWidget(1, widget)
        end)
    end)

    -- @covers LAccordion:addSection
    it("accordion addSection appends a titled section", function()
        local accordion = lurek.ui.newAccordion()
        accordion:addSection("Gameplay")
        expect_equal(1, accordion:getSectionCount())
    end)

    -- @covers LAccordion:getSectionCount
    it("accordion getSectionCount returns section count", function()
        local accordion = lurek.ui.newAccordion()
        accordion:addSection("Gameplay")
        expect_equal(1, accordion:getSectionCount())
    end)

    -- @covers LAccordion:toggleSection
    it("accordion toggleSection toggles expansion state", function()
        local accordion = lurek.ui.newAccordion()
        accordion:addSection("Gameplay")
        expect_true(accordion:toggleSection(1))
    end)

    -- @covers LAccordion:isSectionExpanded
    it("accordion isSectionExpanded reports section state", function()
        local accordion = lurek.ui.newAccordion()
        accordion:addSection("Gameplay")
        accordion:toggleSection(1)
        expect_true(accordion:isSectionExpanded(1))
    end)

    -- @covers LAccordion:isExclusive
    it("accordion isExclusive reports exclusive mode", function()
        local accordion = lurek.ui.newAccordion()
        accordion:setExclusive(true)
        expect_true(accordion:isExclusive())
    end)

    -- @covers LAccordion:setExclusive
    it("accordion setExclusive updates exclusive mode", function()
        local accordion = lurek.ui.newAccordion()
        accordion:setExclusive(true)
        expect_true(accordion:isExclusive())
    end)

    -- @covers LAccordion:getSectionTitle
    it("accordion getSectionTitle returns section titles", function()
        local accordion = lurek.ui.newAccordion()
        accordion:addSection("Gameplay")
        expect_equal("Gameplay", accordion:getSectionTitle(1))
    end)

    -- @covers LTooltipPanel:getText
    it("tooltip panel getText returns the tooltip text", function()
        expect_equal("Hover info", lurek.ui.newTooltipPanel("Hover info"):getText())
    end)

    -- @covers LTooltipPanel:setText
    it("tooltip panel setText updates the tooltip text", function()
        local tooltip = lurek.ui.newTooltipPanel("Old")
        tooltip:setText("New")
        expect_equal("New", tooltip:getText())
    end)

    -- @covers LTooltipPanel:getDelay
    it("tooltip panel getDelay returns the configured delay", function()
        local tooltip = lurek.ui.newTooltipPanel("Info")
        tooltip:setDelay(0.75)
        expect_equal(0.75, tooltip:getDelay())
    end)

    -- @covers LTooltipPanel:setDelay
    it("tooltip panel setDelay updates the configured delay", function()
        local tooltip = lurek.ui.newTooltipPanel("Info")
        tooltip:setDelay(0.75)
        expect_equal(0.75, tooltip:getDelay())
    end)

    -- @covers LTooltipPanel:getTarget
    it("tooltip panel getTarget returns the attached widget index", function()
        local tooltip = lurek.ui.newTooltipPanel("Info")
        local target = lurek.ui.newButton("Hover me")
        tooltip:setTarget(target._idx)
        expect_equal(target._idx, tooltip:getTarget())
    end)

    -- @covers LTooltipPanel:setTarget
    it("tooltip panel setTarget stores the attached widget index", function()
        local tooltip = lurek.ui.newTooltipPanel("Info")
        local target = lurek.ui.newButton("Hover me")
        tooltip:setTarget(target._idx)
        expect_equal(target._idx, tooltip:getTarget())
    end)

    -- @covers LColorPicker:getColor
    it("color picker getColor returns rgba values", function()
        local picker = lurek.ui.newColorPicker()
        picker:setColor(1.0, 0.5, 0.25, 0.75)
        local r, g, b, a = picker:getColor()
        expect_near(1.0, r, 0.001)
        expect_near(0.75, a, 0.001)
    end)

    -- @covers LColorPicker:setColor
    it("color picker setColor updates rgba values", function()
        local picker = lurek.ui.newColorPicker()
        picker:setColor(0.2, 0.8, 0.4, 1.0)
        local r, g, b, a = picker:getColor()
        expect_near(0.2, r, 0.001)
        expect_near(0.8, g, 0.001)
        expect_near(0.4, b, 0.001)
        expect_near(1.0, a, 0.001)
    end)

    -- @covers LColorPicker:getShowAlpha
    it("color picker getShowAlpha reports alpha slider visibility", function()
        local picker = lurek.ui.newColorPicker()
        picker:setShowAlpha(false)
        expect_false(picker:getShowAlpha())
    end)

    -- @covers LColorPicker:setShowAlpha
    it("color picker setShowAlpha updates alpha slider visibility", function()
        local picker = lurek.ui.newColorPicker()
        picker:setShowAlpha(false)
        expect_false(picker:getShowAlpha())
    end)

    -- @covers LColorPicker:getColorMode
    it("color picker getColorMode returns the configured mode", function()
        local picker = lurek.ui.newColorPicker()
        picker:setColorMode("hsv")
        expect_equal("hsv", picker:getColorMode())
    end)

    -- @covers LColorPicker:setColorMode
    it("color picker setColorMode updates the mode", function()
        local picker = lurek.ui.newColorPicker()
        picker:setColorMode("hsv")
        expect_equal("hsv", picker:getColorMode())
    end)

    -- @covers LColorPicker:setOnChange
    it("color picker setOnChange accepts a change callback", function()
        local picker = lurek.ui.newColorPicker()
        expect_no_error(function()
            picker:setOnChange(function() end)
        end)
    end)

    -- @covers LGuiTable:clearRows
    it("gui table clearRows removes all rows", function()
        local tbl = lurek.ui.newTable()
        tbl:addColumn("Name", 120)
        tbl:addRow({ "Alice" })
        tbl:clearRows()
        expect_equal(0, tbl:getRowCount())
    end)

    -- @covers LGuiTable:setRows
    it("gui table setRows replaces rows and returns the new row count", function()
        local tbl = lurek.ui.newTable()
        tbl:addColumn("Category", 120)
        tbl:addColumn("Amount", 80)
        expect_equal(2, tbl:setRows({ { "Food", 420 }, { "Rent", 1200 } }))
    end)

    -- @covers LGuiTable:setDataFrame
    it("gui table setDataFrame populates rows from a dataframe", function()
        local tbl = lurek.ui.newTable()
        local df = lurek.dataframe.fromRows({ "category", "amount" }, {
            { "Food", 420 },
            { "Rent", 1200 },
        })
        local count = tbl:setDataFrame(df, {
            columns = { "category", "amount" },
            maxRows = 2,
        })
        expect_equal(2, count)
        expect_equal("Food", tbl:getCell(1, 1))
    end)

    -- @covers LGuiTable:getCell
    it("gui table getCell returns the stringified cell value", function()
        local tbl = lurek.ui.newTable()
        tbl:addColumn("Name", 120)
        tbl:addColumn("Score", 80)
        tbl:addRow({ "Alice", "42" })
        expect_equal("Alice", tbl:getCell(1, 1))
    end)

    -- @covers LGuiTable:setCell
    it("gui table setCell updates the stringified cell value", function()
        local tbl = lurek.ui.newTable()
        tbl:addColumn("Name", 120)
        tbl:addColumn("Score", 80)
        tbl:addRow({ "Alice", "42" })
        tbl:setCell(1, 2, "99")
        expect_equal("99", tbl:getCell(1, 2))
    end)

    -- @covers LGuiTable:setOnSelect
    it("gui table setOnSelect accepts a row selection callback", function()
        local tbl = lurek.ui.newTable()
        expect_no_error(function()
            tbl:setOnSelect(function() end)
        end)
    end)

    -- @covers lurek.ui.newPropertyWidget
    it("newPropertyWidget creates a property inspector widget", function()
        local props = lurek.ui.newPropertyWidget()
        expect_equal("LPropertyWidget", props:type())
        expect_true(props:typeOf("LPropertyWidget"))
    end)

    -- @covers LPropertyWidget:addGroup
    it("property widget addGroup returns a group index", function()
        local props = lurek.ui.newPropertyWidget()
        expect_equal(1, props:addGroup("Video", false))
    end)

    -- @covers LPropertyWidget:getGroupCount
    it("property widget getGroupCount returns the number of groups", function()
        local props = lurek.ui.newPropertyWidget()
        props:addGroup("Video", false)
        props:addGroup("Audio", true)
        expect_equal(2, props:getGroupCount())
    end)

    -- @covers LPropertyWidget:toggleGroup
    it("property widget toggleGroup toggles collapsed state", function()
        local props = lurek.ui.newPropertyWidget()
        props:addGroup("Video", false)
        expect_true(props:toggleGroup(1))
    end)

    -- @covers LPropertyWidget:isGroupCollapsed
    it("property widget isGroupCollapsed reports collapsed state", function()
        local props = lurek.ui.newPropertyWidget()
        props:addGroup("Audio", true)
        expect_true(props:isGroupCollapsed(1))
    end)

    -- @covers LPropertyWidget:addProperty
    it("property widget addProperty stores typed rows", function()
        local props = lurek.ui.newPropertyWidget()
        local group = props:addGroup("Video", false)
        expect_equal(1, props:addProperty(group, "Resolution", "UHD", "select", { "HD", "UHD" }))
    end)

    -- @covers LPropertyWidget:getPropertyCount
    it("property widget getPropertyCount returns row count", function()
        local props = lurek.ui.newPropertyWidget()
        local group = props:addGroup("Video", false)
        props:addProperty(group, "Bits", 10, "number")
        props:addProperty(group, "Alpha", false, "bool")
        expect_equal(2, props:getPropertyCount(group))
    end)

    -- @covers LPropertyWidget:getPropertyValue
    it("property widget getPropertyValue returns stringified values", function()
        local props = lurek.ui.newPropertyWidget()
        local group = props:addGroup("Audio", false)
        props:addProperty(group, "Channels", 2, "number")
        expect_equal("2", props:getPropertyValue("Channels"))
    end)

    -- @covers LPropertyWidget:setPropertyValue
    it("property widget setPropertyValue updates a row", function()
        local props = lurek.ui.newPropertyWidget()
        local group = props:addGroup("Audio", false)
        props:addProperty(group, "Delay", 4, "number")
        expect_true(props:setPropertyValue("Delay", 8))
        expect_equal("8", props:getPropertyValue("Delay"))
    end)

    -- @covers LPropertyWidget:getPropertyType
    it("property widget getPropertyType returns canonical editor type", function()
        local props = lurek.ui.newPropertyWidget()
        local group = props:addGroup("Colorimetry", false)
        props:addProperty(group, "Enabled", true, "boolean")
        expect_equal("bool", props:getPropertyType("Enabled"))
    end)

    -- @covers LPropertyWidget:getPropertyOptions
    it("property widget getPropertyOptions returns select choices", function()
        local props = lurek.ui.newPropertyWidget()
        local group = props:addGroup("Video", false)
        props:addProperty(group, "Mode", "SDI", "select", { "SDI", "HDMI" })
        local options = props:getPropertyOptions("Mode")
        expect_equal("SDI", options[1])
        expect_equal("HDMI", options[2])
    end)

    -- @covers LPropertyWidget:setLabelWidth
    it("property widget setLabelWidth updates the label column", function()
        local props = lurek.ui.newPropertyWidget()
        props:setLabelWidth(180)
        expect_equal(180, props:getLabelWidth())
    end)

    -- @covers LPropertyWidget:getLabelWidth
    it("property widget getLabelWidth returns the label column", function()
        local props = lurek.ui.newPropertyWidget()
        props:setLabelWidth(156)
        expect_equal(156, props:getLabelWidth())
    end)
end)
end
-- END test_ui_missing_unit.lua

test_summary()
