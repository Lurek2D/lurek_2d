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

print("html_01.lua")
