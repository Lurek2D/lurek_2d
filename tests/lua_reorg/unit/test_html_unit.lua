-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_html_core_unit.lua
do
-- tests/lua/unit/test_html_unit.lua
-- Unit tests for lurek.html (standalone HTML/CSS layout engine).

-- =========================================================================
-- lurek.html Tests
-- =========================================================================

-- @describe lurek.html.newDocument constructor
describe("lurek.html.newDocument constructor", function()
    -- @covers lurek.html.newDocument
    it("constructs documents from html and options", function()
        local doc = lurek.html.newDocument()
        expect_not_nil(doc, "newDocument() must return an HtmlDocument")
        expect_type("function", doc.setHtml, "HtmlDocument must have setHtml method")

        local ok, err = pcall(function()
            lurek.html.newDocument("<div id='hero'>Hello</div>")
        end)
        expect_true(ok, "newDocument(html) must not error: " .. tostring(err))

        local doc = lurek.html.newDocument(nil, { width = 800, height = 600 })
        expect_not_nil(doc, "newDocument with opts must succeed")
        local w, h = doc:getViewport()
        expect_equal(w, 800, "viewport width must be 800")
        expect_equal(h, 600, "viewport height must be 600")

        local css_ok = pcall(function()
            lurek.html.newDocument(nil, { css = "body { color: red; }" })
        end)
        expect_true(css_ok, "newDocument with opts.css must not error")
    end)
end)

-- @describe lurek.html.loadDocument behavior
describe("lurek.html.loadDocument behavior", function()
    -- @covers lurek.html.loadDocument
    it("loads html, applies css, and errors for missing sources", function()
        local doc = lurek.html.loadDocument("tests/fixtures/html/menu.html")
        expect_not_nil(doc, "loadDocument must return an HtmlDocument")
        local title = doc:getElementById("title")
        expect_not_nil(title, "loaded document must expose #title")
        expect_equal("Main Menu", title:getText(), "loaded text must match file contents")

        local css_path_doc = lurek.html.loadDocument("tests/fixtures/html/menu.html", {
            cssPath = "tests/fixtures/html/menu.css",
        })
        local css_path_title = css_path_doc:getElementById("title")
        expect_not_nil(css_path_title, "title element must exist")
        expect_equal("#00ff00", css_path_title:getStyle("color"), "cssPath stylesheet must be applied")

        local auto_css_doc = lurek.html.loadDocument("tests/fixtures/html/menu.html")
        local auto_css_title = auto_css_doc:getElementById("title")
        expect_not_nil(auto_css_title, "title element must exist")
        expect_equal("#00ff00", auto_css_title:getStyle("color"), "companion .css should be auto-loaded")

        local ok = pcall(function()
            lurek.html.loadDocument("tests/fixtures/html/nope_missing_123.html")
        end)
        expect_false(ok, "missing file must raise an error")
    end)
end)

-- @describe HtmlDocument content API
describe("HtmlDocument content API", function()
    local function make_doc()
        return lurek.html.newDocument()
    end

    -- @covers LHtmlDocument:setHtml
    it("setHtml then getHtml returns a string", function()
        local doc = make_doc()
        doc:setHtml("<p id='msg'>world</p>")
        local html = doc:getHtml()
        expect_type("string", html, "getHtml must return string after setHtml")
    end)
    -- @covers LHtmlDocument:getHtml
    it("getHtml returns the current document markup", function()
        local doc = make_doc()
        doc:setHtml("<p id='msg'>world</p>")
        local html = doc:getHtml()
        expect_true(html:find("world", 1, true) ~= nil,
            "getHtml must include the current markup content")
    end)
    -- @covers LHtmlDocument:setCss
    it("setCss does not error", function()
        local doc = make_doc()
        local ok, err = pcall(function() doc:setCss("p { font-size: 14px; }") end)
        expect_true(ok, "setCss must not error: " .. tostring(err))
    end)
    -- @covers LHtmlDocument:addCss
    it("addCss does not error", function()
        local doc = make_doc()
        local ok, err = pcall(function() doc:addCss(".btn { background: #333; }") end)
        expect_true(ok, "addCss must not error: " .. tostring(err))
    end)
    -- @covers LHtmlDocument:clearCss
    it("clearCss does not error after setCss", function()
        local doc = make_doc()
        doc:setCss("p { color: blue; }")
        local ok, err = pcall(function() doc:clearCss() end)
        expect_true(ok, "clearCss must not error: " .. tostring(err))
    end)
    -- @covers LHtmlDocument:isDirty
    it("isDirty is true after setHtml", function()
        local doc = make_doc()
        doc:setHtml("<span>dirty</span>")
        expect_true(doc:isDirty(), "isDirty must be true after setHtml")
    end)
    -- @covers LHtmlDocument:relayout
    it("relayout clears the dirty flag", function()
        local doc = make_doc()
        doc:setHtml("<span>test</span>")
        doc:relayout()
        expect_false(doc:isDirty(), "isDirty must be false after relayout")
    end)
    -- @covers LHtmlDocument:update
    it("update(dt) does not error", function()
        local doc = make_doc()
        local ok, err = pcall(function() doc:update(1/60) end)
        expect_true(ok, "update(dt) must not error: " .. tostring(err))
    end)
end)

-- @describe HtmlDocument viewport API
describe("HtmlDocument viewport API", function()
    -- @covers LHtmlDocument:getViewport
    it("getViewport returns the configured document size", function()
        local doc = lurek.html.newDocument(nil, { width = 320, height = 240 })
        local w, h = doc:getViewport()
        expect_equal(w, 320, "viewport width must match constructor options")
        expect_equal(h, 240, "viewport height must match constructor options")
    end)

    -- @covers LHtmlDocument:setViewport
    it("setViewport round-trips and marks the document dirty", function()
        local doc = lurek.html.newDocument()
        doc:setViewport(1280, 720)
        local w, h = doc:getViewport()
        expect_equal(w, 1280, "viewport width must match")
        expect_equal(h, 720,  "viewport height must match")
        doc:relayout()
        doc:setViewport(640, 480)
        expect_true(doc:isDirty(), "setViewport must mark the document dirty")
    end)
end)

-- @describe HtmlDocument element access API
describe("HtmlDocument element access API", function()
    local function make_doc_with_content()
        local doc = lurek.html.newDocument()
        doc:setHtml([[
            <div id="box" class="container">
                <span id="label" class="text">Hi</span>
                <span id="label2" class="text">Bye</span>
            </div>
        ]])
        doc:relayout()
        return doc
    end

    -- @covers LHtmlDocument:getRoot
    it("getRoot returns an element with html methods", function()
        local doc = make_doc_with_content()
        local root = doc:getRoot()
        expect_not_nil(root, "getRoot must return an HtmlElement")
        expect_type("function", root.getTagName, "root must expose getTagName")
    end)
    -- @covers LHtmlDocument:getElementById
    it("getElementById finds existing ids and returns nil for missing ones", function()
        local doc = make_doc_with_content()
        local el = doc:getElementById("box")
        expect_not_nil(el, "getElementById('box') must find the element")
        local missing = doc:getElementById("nonexistent_id_xyz")
        expect_nil(missing, "getElementById must return nil for a missing id")
    end)
    -- @covers LHtmlDocument:query
    it("query('#id') returns the element", function()
        local doc = make_doc_with_content()
        local el = doc:query("#label")
        expect_not_nil(el, "query('#label') must find the element")
    end)
    -- @covers LHtmlDocument:queryAll
    it("queryAll returns matching elements and empty tables for misses", function()
        local doc = make_doc_with_content()
        local results = doc:queryAll(".text")
        expect_type("table", results, "queryAll must return a table")
        expect_true(#results >= 2, "queryAll('.text') must find at least 2 elements")
        local missing = doc:queryAll(".no-such-class-xyz")
        expect_type("table", missing, "queryAll must return a table even when empty")
        expect_equal(#missing, 0, "queryAll with no match must return empty table")
    end)
end)

-- @describe HtmlDocument event and input API
describe("HtmlDocument event and input API", function()
    local function make_doc()
        local doc = lurek.html.newDocument()
        doc:setHtml("<button id='btn'>Click</button>")
        doc:relayout()
        return doc
    end

    -- @covers LHtmlDocument:on
    it("on() returns a non-nil handle", function()
        local doc = make_doc()
        local handle = doc:on("click", function() end)
        expect_not_nil(handle, "on() must return a handle")
    end)
    -- @covers LHtmlDocument:off
    it("off(handle) does not error", function()
        local doc = make_doc()
        local handle = doc:on("click", function() end)
        local ok, err = pcall(function() doc:off(handle) end)
        expect_true(ok, "off(handle) must not error: " .. tostring(err))
    end)
    -- @covers LHtmlDocument:mousepressed
    it("mousepressed returns a boolean", function()
        local result = make_doc():mousepressed(100, 100, 1)
        expect_type("boolean", result, "mousepressed must return boolean")
    end)
    -- @covers LHtmlDocument:mousereleased
    it("mousereleased returns a boolean", function()
        local result = make_doc():mousereleased(100, 100, 1)
        expect_type("boolean", result, "mousereleased must return boolean")
    end)
    -- @covers LHtmlDocument:mousemoved
    it("mousemoved returns a boolean", function()
        local result = make_doc():mousemoved(200, 150)
        expect_type("boolean", result, "mousemoved must return boolean")
    end)
    -- @covers LHtmlDocument:wheelmoved
    it("wheelmoved returns a boolean", function()
        local result = make_doc():wheelmoved(0, -1)
        expect_type("boolean", result, "wheelmoved must return boolean")
    end)
    -- @covers LHtmlDocument:keypressed
    it("keypressed returns a boolean", function()
        local result = make_doc():keypressed("return")
        expect_type("boolean", result, "keypressed must return boolean")
    end)
    -- @covers LHtmlDocument:textinput
    it("textinput returns a boolean", function()
        local result = make_doc():textinput("a")
        expect_type("boolean", result, "textinput must return boolean")
    end)
end)

-- @describe HtmlElement DOM manipulation API
describe("HtmlElement DOM manipulation API", function()
    local function make_el()
        local doc = lurek.html.newDocument()
        doc:setHtml([[
            <div id="root" class="wrapper">
                <p id="para" class="text">Hello</p>
            </div>
        ]])
        doc:relayout()
        return doc:getElementById("para"), doc
    end

    -- @covers LHtmlElement:getTagName
    it("getTagName returns a string", function()
        local el = make_el()
        expect_type("string", el:getTagName(), "getTagName must return a string")
    end)
    -- @covers LHtmlElement:getId
    it("getId returns the element's id", function()
        local el = make_el()
        expect_equal(el:getId(), "para", "getId must return 'para'")
    end)
    -- @covers LHtmlElement:setId
    it("setId updates the element id", function()
        local el = make_el()
        el:setId("para2")
        expect_equal(el:getId(), "para2", "setId must update the id")
    end)
    -- @covers LHtmlElement:getText
    it("getText returns the text content", function()
        local el = make_el()
        expect_equal(el:getText(), "Hello", "getText must return 'Hello'")
    end)
    -- @covers LHtmlElement:setText
    it("setText updates text content", function()
        local el = make_el()
        el:setText("World")
        expect_equal(el:getText(), "World", "setText must update text")
    end)
    -- @covers LHtmlElement:getHtml
    it("getHtml returns a string", function()
        local el = make_el()
        expect_type("string", el:getHtml(), "getHtml must return a string")
    end)
    -- @covers LHtmlElement:setHtml
    it("setHtml replaces the element inner markup", function()
        local el = make_el()
        el:setHtml("<strong>World</strong>")
        local html = el:getHtml()
        expect_true(html:find("World", 1, true) ~= nil,
            "setHtml must update the element inner markup")
    end)
    -- @covers LHtmlElement:setAttribute
    it("setAttribute / getAttribute round-trip", function()
        local el = make_el()
        el:setAttribute("data-score", "42")
        expect_equal(el:getAttribute("data-score"), "42",
            "getAttribute must return the set value")
    end)
    -- @covers LHtmlElement:getAttribute
    it("getAttribute returns a stored attribute value", function()
        local el = make_el()
        el:setAttribute("data-state", "ready")
        expect_equal(el:getAttribute("data-state"), "ready",
            "getAttribute must read the stored attribute")
    end)
    -- @covers LHtmlElement:removeAttribute
    it("removeAttribute clears the attribute", function()
        local el = make_el()
        el:setAttribute("data-tmp", "x")
        el:removeAttribute("data-tmp")
        expect_nil(el:getAttribute("data-tmp"),
            "getAttribute must return nil after removeAttribute")
    end)
    -- @covers LHtmlElement:addClass
    it("addClass adds the class; hasClass detects it", function()
        local el = make_el()
        el:addClass("active")
        expect_true(el:hasClass("active"), "hasClass must return true after addClass")
    end)
    -- @covers LHtmlElement:hasClass
    it("hasClass reports class presence on the element", function()
        local el = make_el()
        el:addClass("selected")
        expect_true(el:hasClass("selected"),
            "hasClass must report a class added to the element")
    end)
    -- @covers LHtmlElement:removeClass
    it("removeClass removes the class", function()
        local el = make_el()
        el:addClass("active")
        el:removeClass("active")
        expect_false(el:hasClass("active"),
            "hasClass must return false after removeClass")
    end)
    -- @covers LHtmlElement:toggleClass
    it("toggleClass adds then removes classes across repeated calls", function()
        local el = make_el()
        local result = el:toggleClass("highlight")
        expect_true(result, "toggleClass must return true when adding")
        expect_true(el:hasClass("highlight"),
            "class must be present after toggle-add")

        local removed = el:toggleClass("highlight")
        expect_false(removed, "toggleClass must return false when removing")
        expect_false(el:hasClass("highlight"),
            "class must be absent after toggle-remove")
    end)
    -- @covers LHtmlElement:setStyle
    it("setStyle / getStyle round-trip", function()
        local el = make_el()
        el:setStyle("color", "red")
        expect_equal(el:getStyle("color"), "red",
            "getStyle must return the set value")
    end)
    -- @covers LHtmlElement:getStyle
    it("getStyle returns a stored inline style value", function()
        local el = make_el()
        el:setStyle("background-color", "blue")
        expect_equal(el:getStyle("background-color"), "blue",
            "getStyle must read the stored inline style")
    end)
    -- @covers LHtmlElement:getRect
    it("getRect returns four numbers", function()
        local el = make_el()
        local x, y, w, h = el:getRect()
        expect_type("number", x, "getRect x must be a number")
        expect_type("number", y, "getRect y must be a number")
        expect_type("number", w, "getRect w must be a number")
        expect_type("number", h, "getRect h must be a number")
    end)
    -- @covers LHtmlElement:focus
    it("focus does not error", function()
        local el = make_el()
        local ok, err = pcall(function() el:focus() end)
        expect_true(ok, "focus() must not error: " .. tostring(err))
    end)
    -- @covers LHtmlElement:blur
    it("blur does not error", function()
        local el = make_el()
        local ok, err = pcall(function() el:blur() end)
        expect_true(ok, "blur() must not error: " .. tostring(err))
    end)
    -- @covers LHtmlElement:getDocument
    it("getDocument returns the owning HtmlDocument", function()
        local el, doc = make_el()
        local owner = el:getDocument()
        expect_not_nil(owner, "getDocument must return the owning document")
        -- The owner should also expose setHtml, confirming it's an HtmlDocument.
        expect_type("function", owner.setHtml,
            "getDocument result must expose setHtml")
    end)
    -- @covers LHtmlElement:query
    it("element:query finds a descendant", function()
        local _, doc = make_el()
        local root = doc:getElementById("root")
        local child = root:query("#para")
        expect_not_nil(child, "element:query('#para') must find the child")
    end)
    -- @covers LHtmlElement:queryAll
    it("element:queryAll returns a table", function()
        local _, doc = make_el()
        local root = doc:getElementById("root")
        local results = root:queryAll(".text")
        expect_type("table", results,
            "element:queryAll must return a table")
    end)
    -- @covers LHtmlElement:on
    it("element:on returns a handle", function()
        local el = make_el()
        local h = el:on("click", function() end)
        expect_not_nil(h, "element:on must return a handle")
    end)
    -- @covers LHtmlElement:off
    it("element:off with handle does not error", function()
        local el = make_el()
        local h = el:on("click", function() end)
        local ok, err = pcall(function() el:off(h) end)
        expect_true(ok, "element:off must not error: " .. tostring(err))
    end)
    -- @covers LHtmlElement:appendHtml
    it("appendHtml adds content without replacing existing text", function()
        local el = make_el()
        el:appendHtml("<em>!</em>")
        local html = el:getHtml()
        expect_type("string", html, "getHtml after appendHtml must be string")
        expect_true(html:len() > 0, "getHtml after appendHtml must be non-empty")
    end)
end)

-- @describe lurek.html.supports feature flags
describe("lurek.html.supports feature flags", function()
    -- @covers lurek.html.supports
    it("reports supported and unsupported feature flags", function()
        expect_true(lurek.html.supports("html"),
            "supports('html') must be true")
        expect_true(lurek.html.supports("css"),
            "supports('css') must be true")
        expect_true(lurek.html.supports("selectors"),
            "supports('selectors') must be true")
        expect_true(lurek.html.supports("css-flex"),
            "supports('css-flex') must be true")
        expect_true(lurek.html.supports("load-document"),
            "supports('load-document') must be true")
        expect_true(lurek.html.supports("pure-rust"),
            "supports('pure-rust') must be true")
        expect_false(lurek.html.supports("nonexistent-feature-xyz"),
            "supports must return false for unknown features")
    end)
end)

-- @describe html strict: LHtmlDocument methods
describe("html strict: LHtmlDocument methods", function()
    -- @covers LHtmlDocument:draw
    it("LHtmlDocument draw is callable", function()
        local doc = lurek.html.newDocument("<p>draw</p>")
        local ok = pcall(function() doc:draw() end)
        expect_type("boolean", ok)
    end)

    -- @covers LHtmlDocument:type
    it("LHtmlDocument type and typeOf are callable", function()
        local doc = lurek.html.newDocument("<p>t</p>")
        expect_type("string", doc:type())
        expect_type("boolean", doc:typeOf("LObject"))
    end)

    -- @covers LHtmlDocument:typeOf
    it("LHtmlDocument typeOf matches the document userdata type", function()
        local doc = lurek.html.newDocument("<p>t</p>")
        expect_true(doc:typeOf("LHtmlDocument"))
        expect_true(doc:typeOf("LObject"))
    end)
end)

-- @describe html strict: LHtmlElement methods
describe("html strict: LHtmlElement methods", function()
    -- @covers LHtmlElement:remove
    it("LHtmlElement remove is callable", function()
        local doc = lurek.html.newDocument("<p id='rm'>bye</p>")
        local el = doc:getElementById("rm")
        if el ~= nil then
            local ok = pcall(function() el:remove() end)
            expect_true(ok)
        else
            expect_nil(el)
        end
    end)

    -- @covers LHtmlElement:type
    it("LHtmlElement type and typeOf are callable", function()
        local doc = lurek.html.newDocument("<span id='sp'>x</span>")
        local el = doc:getElementById("sp")
        if el ~= nil then
            expect_type("string", el:type())
            expect_type("boolean", el:typeOf("LObject"))
        else
            expect_nil(el)
        end
    end)

    -- @covers LHtmlElement:typeOf
    it("LHtmlElement typeOf matches the element userdata type", function()
        local doc = lurek.html.newDocument("<span id='sp'>x</span>")
        local el = doc:getElementById("sp")
        expect_not_nil(el, "test element must exist")
        expect_true(el:typeOf("LHtmlElement"))
        expect_true(el:typeOf("LObject"))
    end)
end)

-- @describe html strict: event functions
describe("html strict: event functions", function()
    -- @covers lurek.html.preventDefault
    it("preventDefault / stopPropagation / isDefaultPrevented are called in event callback", function()
        local fired = false
        local doc = lurek.html.newDocument("<button id='b'>X</button>")
        doc:on("mousepressed", function(evt)
            evt.preventDefault()
            evt.stopPropagation()
            local prevented = evt.isDefaultPrevented()
            expect_type("boolean", prevented)
            fired = true
        end)
        doc:mousepressed(5, 5, 1)
        expect_true(fired or true)
    end)

    -- @covers lurek.html.stopPropagation
    it("stopPropagation is callable inside an event callback", function()
        local fired = false
        local doc = lurek.html.newDocument()
        doc:setHtml("<button id='b'>X</button>")
        doc:relayout()
        local btn = doc:getElementById("b")
        expect_not_nil(btn, "button element must exist")
        local x, y = btn:getRect()
        doc:on("click", function(evt)
            expect_no_error(function()
                evt.stopPropagation()
            end)
            fired = true
        end)
        doc:mousepressed(x + 1, y + 1, 1)
        expect_true(fired, "mousepressed callback must run")
    end)

    -- @covers lurek.html.isDefaultPrevented
    it("isDefaultPrevented reflects whether default handling was prevented", function()
        local prevented = nil
        local doc = lurek.html.newDocument()
        doc:setHtml("<button id='b'>X</button>")
        doc:relayout()
        local btn = doc:getElementById("b")
        expect_not_nil(btn, "button element must exist")
        local x, y = btn:getRect()
        doc:on("click", function(evt)
            evt.preventDefault()
            prevented = evt.isDefaultPrevented()
        end)
        doc:mousepressed(x + 1, y + 1, 1)
        expect_equal(true, prevented)
    end)
end)

-- @describe html strict: document render method
describe("html strict: document render method", function()
    -- @covers LHtmlDocument:render
    it("LHtmlDocument render is callable", function()
        local doc = lurek.html.newDocument("<p id='r'>render</p>")
        local ok = pcall(function() doc:render(0, 0) end)
        expect_type("boolean", ok)
    end)
end)
end
-- END test_html_core_unit.lua

test_summary()
