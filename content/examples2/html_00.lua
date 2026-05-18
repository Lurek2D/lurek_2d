--- HTML Module Part 1: factory, LHtmlDocument methods

--@api-stub: lurek.html.newDocument
-- Creates a new empty HTML document.
do
    local doc = lurek.html.newDocument()
    print("doc type = " .. doc:type())
end

--@api-stub: lurek.html.newDocument (with source)
-- Creates a document from HTML text.
do
    local doc = lurek.html.newDocument("<div id='root'>Hello</div>")
    print("doc html = " .. doc:getHtml())
end

--@api-stub: lurek.html.newDocument (with options)
-- Creates a document with CSS and viewport options.
do
    local doc = lurek.html.newDocument("<p>styled</p>", {
        css = "p { color: red; }",
        width = 800,
        height = 600,
    })
    print("doc created with options")
end

--@api-stub: lurek.html.loadDocument
-- Loads a document from an HTML file path.
do
    local doc = lurek.html.loadDocument("content/layouts/menu.html")
    print("loaded doc type = " .. doc:type())
end

--@api-stub: lurek.html.supports
-- Checks if an HTML feature is supported.
do
    local ok = lurek.html.supports("flexbox")
    print("flexbox supported = " .. tostring(ok))
end

--@api-stub: lurek.html.preventDefault
-- Prevents default behavior for the current event.
do
    lurek.html.preventDefault()
    print("default prevented")
end

--@api-stub: lurek.html.stopPropagation
-- Stops event propagation.
do
    lurek.html.stopPropagation()
    print("propagation stopped")
end

--@api-stub: lurek.html.isDefaultPrevented
-- Returns whether default was prevented.
do
    local prevented = lurek.html.isDefaultPrevented()
    print("prevented = " .. tostring(prevented))
end

--@api-stub: LHtmlDocument:setHtml
-- Sets the document body HTML.
do
    local doc = lurek.html.newDocument()
    doc:setHtml("<h1>Title</h1><p>Body text</p>")
    print("html set")
end

--@api-stub: LHtmlDocument:getHtml
-- Returns the current document HTML.
do
    local doc = lurek.html.newDocument("<span>test</span>")
    local html = doc:getHtml()
    print("html = " .. html)
end

--@api-stub: LHtmlDocument:setCss
-- Replaces the document stylesheet.
do
    local doc = lurek.html.newDocument("<div class='box'>X</div>")
    doc:setCss(".box { width: 100px; height: 100px; }")
    print("css set")
end

--@api-stub: LHtmlDocument:addCss
-- Appends CSS rules.
do
    local doc = lurek.html.newDocument("<p>styled</p>")
    doc:addCss("p { font-size: 16px; }")
    doc:addCss("p { margin: 10px; }")
    print("css appended")
end

--@api-stub: LHtmlDocument:clearCss
-- Removes all CSS rules.
do
    local doc = lurek.html.newDocument("<p>unstyled</p>")
    doc:setCss("p { color: red; }")
    doc:clearCss()
    print("css cleared")
end

--@api-stub: LHtmlDocument:setViewport
-- Sets the layout viewport size.
do
    local doc = lurek.html.newDocument()
    doc:setViewport(1024, 768)
    print("viewport set to 1024x768")
end

--@api-stub: LHtmlDocument:getViewport
-- Returns viewport width and height.
do
    local doc = lurek.html.newDocument()
    doc:setViewport(800, 600)
    local w, h = doc:getViewport()
    print("viewport = " .. w .. "x" .. h)
end

--@api-stub: LHtmlDocument:getElementById
-- Finds an element by its id attribute.
do
    local doc = lurek.html.newDocument("<div id='hero'>Player</div>")
    local el = doc:getElementById("hero")
    if el then
        print("found: " .. el:getText())
    end
end

--@api-stub: LHtmlDocument:getRoot
-- Returns the root element.
do
    local doc = lurek.html.newDocument("<div>root child</div>")
    local root = doc:getRoot()
    print("root tag = " .. root:getTagName())
end

--@api-stub: LHtmlDocument:query
-- Finds the first element matching a CSS selector.
do
    local doc = lurek.html.newDocument("<p class='intro'>Hello</p><p>World</p>")
    local el = doc:query(".intro")
    if el then
        print("query found: " .. el:getText())
    end
end

--@api-stub: LHtmlDocument:queryAll
-- Finds all elements matching a CSS selector.
do
    local doc = lurek.html.newDocument("<li>A</li><li>B</li><li>C</li>")
    local items = doc:queryAll("li")
    print("items = " .. #items)
end

--@api-stub: LHtmlDocument:isDirty
-- Returns whether the layout needs recomputation.
do
    local doc = lurek.html.newDocument("<p>X</p>")
    doc:setHtml("<p>Y</p>")
    print("dirty = " .. tostring(doc:isDirty()))
end

--@api-stub: LHtmlDocument:relayout
-- Recomputes the document layout.
do
    local doc = lurek.html.newDocument("<div>content</div>")
    doc:relayout()
    print("relayout done")
end

--@api-stub: LHtmlDocument:draw
-- Draws the document at optional x, y offset.
do
    local doc = lurek.html.newDocument("<p>Hello</p>")
    doc:draw(10, 20)
    print("drawn at 10,20")
end

--@api-stub: LHtmlDocument:render
-- Renders the document (alias for draw).
do
    local doc = lurek.html.newDocument("<p>World</p>")
    doc:render(0, 0)
    print("rendered")
end

--@api-stub: LHtmlDocument:update
-- Advances document animations and timers.
do
    local doc = lurek.html.newDocument()
    doc:update(0.016)
    print("updated")
end

--@api-stub: LHtmlDocument:on
-- Registers a document-level event callback.
do
    local doc = lurek.html.newDocument("<button id='btn'>Click</button>")
    local handle = doc:on("click", function(ev)
        print("clicked!")
    end)
    print("registered handle = " .. handle)
end

--@api-stub: LHtmlDocument:off
-- Removes a registered event callback.
do
    local doc = lurek.html.newDocument()
    local h = doc:on("hover", function() end)
    doc:off(h)
    print("unregistered")
end

--@api-stub: LHtmlDocument:mousemoved
-- Sends a mouse move event.
do
    local doc = lurek.html.newDocument("<div>hover me</div>")
    local handled = doc:mousemoved(100, 50)
    print("mousemoved handled = " .. tostring(handled))
end

--@api-stub: LHtmlDocument:mousepressed
-- Sends a mouse press event.
do
    local doc = lurek.html.newDocument("<button>click</button>")
    local handled = doc:mousepressed(100, 50, 1)
    print("mousepressed handled = " .. tostring(handled))
end

--@api-stub: LHtmlDocument:mousereleased
-- Sends a mouse release event.
do
    local doc = lurek.html.newDocument("<button>click</button>")
    local handled = doc:mousereleased(100, 50, 1)
    print("mousereleased handled = " .. tostring(handled))
end

--@api-stub: LHtmlDocument:keypressed
-- Sends a key press event.
do
    local doc = lurek.html.newDocument("<input id='in'/>")
    local handled = doc:keypressed("return")
    print("keypressed handled = " .. tostring(handled))
end

--@api-stub: LHtmlDocument:textinput
-- Sends text input.
do
    local doc = lurek.html.newDocument("<input/>")
    local handled = doc:textinput("A")
    print("textinput handled = " .. tostring(handled))
end

--@api-stub: LHtmlDocument:wheelmoved
-- Sends a scroll wheel event.
do
    local doc = lurek.html.newDocument("<div style='overflow:scroll;height:100px'><p>long</p></div>")
    local handled = doc:wheelmoved(0, -3)
    print("wheelmoved handled = " .. tostring(handled))
end

--@api-stub: LHtmlDocument:type
-- Returns the type name "LHtmlDocument".
do
    local doc = lurek.html.newDocument()
    print("type = " .. doc:type())
end

--@api-stub: LHtmlDocument:typeOf
-- Returns whether this document matches a type name.
do
    local doc = lurek.html.newDocument()
    print("is HtmlDocument = " .. tostring(doc:typeOf("HtmlDocument")))
end

print("html_00.lua")
