-- content/examples/html.lua
-- Auto-generated from content/examples2/html_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/html.lua

--- HTML Module Part 1: factory, LHtmlDocument methods


--@api-stub: lurek.html.newDocument
-- Creates a new empty HTML document.
do
    local doc = lurek.html.newDocument()
    print("doc created = " .. tostring(doc ~= nil))
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
    print("preventDefault available = " .. tostring(type(lurek.html.preventDefault) == "function"))
end

--@api-stub: lurek.html.stopPropagation
-- Stops event propagation.
do
    print("stopPropagation available = " .. tostring(type(lurek.html.stopPropagation) == "function"))
end

--@api-stub: lurek.html.isDefaultPrevented
-- Returns whether default was prevented.
do
    print("isDefaultPrevented available = " .. tostring(type(lurek.html.isDefaultPrevented) == "function"))
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

--- HTML Module Part 2: LHtmlElement methods


--@api-stub: LHtmlElement:getId
-- Returns the element's id attribute.
do
    local doc = lurek.html.newDocument("<div id='main'>content</div>")
    local el = doc:getElementById("main")
    if el then
        print("id = " .. tostring(el:getId()))
    end
end

--@api-stub: LHtmlElement:setId
-- Sets the element's id attribute.
do
    local doc = lurek.html.newDocument("<div>content</div>")
    local root = doc:getRoot()
    root:setId("container")
    print("id set")
end

--@api-stub: LHtmlElement:getTagName
-- Returns the element's tag name.
do
    local doc = lurek.html.newDocument("<section>stuff</section>")
    local root = doc:getRoot()
    print("tag = " .. root:getTagName())
end

--@api-stub: LHtmlElement:getAttribute
-- Returns a named attribute value.
do
    local doc = lurek.html.newDocument("<a href='#top'>link</a>")
    local el = doc:query("a")
    if el then
        local href = el:getAttribute("href")
        print("href = " .. tostring(href))
    end
end

--@api-stub: LHtmlElement:setAttribute
-- Sets a named attribute.
do
    local doc = lurek.html.newDocument("<img/>")
    local el = doc:query("img")
    if el then
        el:setAttribute("src", "icon.png")
        print("src set")
    end
end

--@api-stub: LHtmlElement:removeAttribute
-- Removes a named attribute.
do
    local doc = lurek.html.newDocument("<div data-x='1'>X</div>")
    local el = doc:query("div")
    if el then
        el:removeAttribute("data-x")
        print("data-x removed")
    end
end

--@api-stub: LHtmlElement:getStyle
-- Returns a computed style property.
do
    local doc = lurek.html.newDocument("<div style='color:red'>R</div>")
    local el = doc:query("div")
    if el then
        local c = el:getStyle("color")
        print("color = " .. tostring(c))
    end
end

--@api-stub: LHtmlElement:setStyle
-- Sets an inline style property.
do
    local doc = lurek.html.newDocument("<p>text</p>")
    local el = doc:query("p")
    if el then
        el:setStyle("font-size", "20px")
        print("style set")
    end
end

--@api-stub: LHtmlElement:addClass
-- Adds a CSS class to the element.
do
    local doc = lurek.html.newDocument("<div>box</div>")
    local el = doc:query("div")
    if el then
        el:addClass("highlight")
        print("class added")
    end
end

--@api-stub: LHtmlElement:removeClass
-- Removes a CSS class from the element.
do
    local doc = lurek.html.newDocument("<div class='active old'>X</div>")
    local el = doc:query("div")
    if el then
        el:removeClass("old")
        print("class removed")
    end
end

--@api-stub: LHtmlElement:hasClass
-- Checks if element has a class.
do
    local doc = lurek.html.newDocument("<div class='visible'>Y</div>")
    local el = doc:query("div")
    if el then
        print("has visible = " .. tostring(el:hasClass("visible")))
    end
end

--@api-stub: LHtmlElement:toggleClass
-- Toggles a CSS class.
do
    local doc = lurek.html.newDocument("<div class='on'>Z</div>")
    local el = doc:query("div")
    if el then
        local result = el:toggleClass("on")
        print("toggle result = " .. tostring(result))
    end
end

--@api-stub: LHtmlElement:getHtml
-- Returns the element's inner HTML.
do
    local doc = lurek.html.newDocument("<div><span>inner</span></div>")
    local el = doc:query("div")
    if el then
        print("html = " .. el:getHtml())
    end
end

--@api-stub: LHtmlElement:setHtml
-- Sets the element's inner HTML.
do
    local doc = lurek.html.newDocument("<div>old</div>")
    local el = doc:query("div")
    if el then
        el:setHtml("<b>new</b>")
        print("html updated")
    end
end

--@api-stub: LHtmlElement:appendHtml
-- Appends HTML content to the element.
do
    local doc = lurek.html.newDocument("<ul><li>first</li></ul>")
    local el = doc:query("ul")
    if el then
        el:appendHtml("<li>second</li>")
        print("html appended")
    end
end

--@api-stub: LHtmlElement:getText
-- Returns the element's text content.
do
    local doc = lurek.html.newDocument("<p>Hello World</p>")
    local el = doc:query("p")
    if el then
        print("text = " .. el:getText())
    end
end

--@api-stub: LHtmlElement:setText
-- Sets the element's text content.
do
    local doc = lurek.html.newDocument("<span>old</span>")
    local el = doc:query("span")
    if el then
        el:setText("new text")
        print("text set")
    end
end

--@api-stub: LHtmlElement:getRect
-- Returns the element's layout rectangle.
do
    local doc = lurek.html.newDocument("<div style='width:100px;height:50px'>box</div>")
    doc:setViewport(800, 600)
    doc:relayout()
    local el = doc:query("div")
    if el then
        local x, y, w, h = el:getRect()
        print("rect = " .. x .. "," .. y .. " " .. w .. "x" .. h)
    end
end

--@api-stub: LHtmlElement:getDocument
-- Returns the owning document.
do
    local doc = lurek.html.newDocument("<p>owned</p>")
    local el = doc:query("p")
    if el then
        local owner = el:getDocument()
        print("owner type = " .. owner:type())
    end
end

--@api-stub: LHtmlElement:query
-- Finds first child matching a selector.
do
    local doc = lurek.html.newDocument("<div><span class='x'>found</span></div>")
    local div = doc:query("div")
    if div then
        local span = div:query(".x")
        if span then
            print("child query = " .. span:getText())
        end
    end
end

--@api-stub: LHtmlElement:queryAll
-- Finds all children matching a selector.
do
    local doc = lurek.html.newDocument("<ul><li>A</li><li>B</li></ul>")
    local ul = doc:query("ul")
    if ul then
        local items = ul:queryAll("li")
        print("child items = " .. #items)
    end
end

--@api-stub: LHtmlElement:on
-- Registers an event callback on the element.
do
    local doc = lurek.html.newDocument("<button id='btn'>Go</button>")
    local el = doc:getElementById("btn")
    if el then
        local h = el:on("click", function()
            print("button clicked")
        end)
        print("element handle = " .. h)
    end
end

--@api-stub: LHtmlElement:off
-- Removes an event callback from the element.
do
    local doc = lurek.html.newDocument("<div id='d'>X</div>")
    local el = doc:getElementById("d")
    if el then
        local h = el:on("hover", function() end)
        el:off(h)
        print("handler removed")
    end
end

--@api-stub: LHtmlElement:focus
-- Gives keyboard focus to this element.
do
    local doc = lurek.html.newDocument("<input id='field'/>")
    local el = doc:getElementById("field")
    if el then
        el:focus()
        print("focused")
    end
end

--@api-stub: LHtmlElement:blur
-- Removes keyboard focus from this element.
do
    local doc = lurek.html.newDocument("<input id='field2'/>")
    local el = doc:getElementById("field2")
    if el then
        el:focus()
        el:blur()
        print("blurred")
    end
end

--@api-stub: LHtmlElement:remove
-- Removes this element from the document.
do
    local doc = lurek.html.newDocument("<div><p id='del'>gone</p></div>")
    local el = doc:getElementById("del")
    if el then
        el:remove()
        print("element removed")
    end
end

--@api-stub: LHtmlElement:type
-- Returns the type name "LHtmlElement".
do
    local doc = lurek.html.newDocument("<div>X</div>")
    local el = doc:getRoot()
    print("type = " .. el:type())
end

--@api-stub: LHtmlElement:typeOf
-- Returns whether this element matches a type name.
do
    local doc = lurek.html.newDocument("<div>X</div>")
    local el = doc:getRoot()
    print("is HtmlElement = " .. tostring(el:typeOf("HtmlElement")))
end

print("content/examples/html.lua")
