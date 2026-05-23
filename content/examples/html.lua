-- content/examples/html.lua
-- Auto-generated from content/examples2/html_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/html.lua

--- HTML Module Part 1: factory, LHtmlDocument methods


--@api-stub: lurek.html.newDocument
do
    local doc = lurek.html.newDocument()
    print("doc created = " .. tostring(doc ~= nil))
end

--@api-stub: lurek.html.loadDocument
do
    local doc = lurek.html.loadDocument("content/examples/assets/layouts/sample_menu.html")
    print("loaded doc type = " .. doc:type())
end

--@api-stub: lurek.html.supports
do
    local ok = lurek.html.supports("flexbox")
    print("flexbox supported = " .. tostring(ok))
end

--@api-stub: lurek.html.preventDefault
do
    print("preventDefault available = " .. tostring(type(lurek.html.preventDefault) == "function"))
end

--@api-stub: lurek.html.stopPropagation
do
    print("stopPropagation available = " .. tostring(type(lurek.html.stopPropagation) == "function"))
end

--@api-stub: lurek.html.isDefaultPrevented
do
    print("isDefaultPrevented available = " .. tostring(type(lurek.html.isDefaultPrevented) == "function"))
end

--@api-stub: LHtmlDocument:setHtml
do
    local doc = lurek.html.newDocument()
    doc:setHtml("<h1>Title</h1><p>Body text</p>")
    print("html set")
end

--@api-stub: LHtmlDocument:getHtml
do
    local doc = lurek.html.newDocument("<span>test</span>")
    local html = doc:getHtml()
    print("html = " .. html)
end

--@api-stub: LHtmlDocument:setCss
do
    local doc = lurek.html.newDocument("<div class='box'>X</div>")
    doc:setCss(".box { width: 100px; height: 100px; }")
    print("css set")
end

--@api-stub: LHtmlDocument:addCss
do
    local doc = lurek.html.newDocument("<p>styled</p>")
    doc:addCss("p { font-size: 16px; }")
    doc:addCss("p { margin: 10px; }")
    print("css appended")
end

--@api-stub: LHtmlDocument:clearCss
do
    local doc = lurek.html.newDocument("<p>unstyled</p>")
    doc:setCss("p { color: red; }")
    doc:clearCss()
    print("css cleared")
end

--@api-stub: LHtmlDocument:setViewport
do
    local doc = lurek.html.newDocument()
    doc:setViewport(1024, 768)
    print("viewport set to 1024x768")
end

--@api-stub: LHtmlDocument:getViewport
do
    local doc = lurek.html.newDocument()
    doc:setViewport(800, 600)
    local w, h = doc:getViewport()
    print("viewport = " .. w .. "x" .. h)
end

--@api-stub: LHtmlDocument:getElementById
do
    local doc = lurek.html.newDocument("<div id='hero'>Player</div>")
    local el = doc:getElementById("hero")
    if el then
        print("found: " .. el:getText())
    end
end

--@api-stub: LHtmlDocument:getRoot
do
    local doc = lurek.html.newDocument("<div>root child</div>")
    local root = doc:getRoot()
    print("root tag = " .. root:getTagName())
end

--@api-stub: LHtmlDocument:query
do
    local doc = lurek.html.newDocument("<p class='intro'>Hello</p><p>World</p>")
    local el = doc:query(".intro")
    if el then
        print("query found: " .. el:getText())
    end
end

--@api-stub: LHtmlDocument:queryAll
do
    local doc = lurek.html.newDocument("<li>A</li><li>B</li><li>C</li>")
    local items = doc:queryAll("li")
    print("items = " .. #items)
end

--@api-stub: LHtmlDocument:isDirty
do
    local doc = lurek.html.newDocument("<p>X</p>")
    doc:setHtml("<p>Y</p>")
    print("dirty = " .. tostring(doc:isDirty()))
end

--@api-stub: LHtmlDocument:relayout
do
    local doc = lurek.html.newDocument("<div>content</div>")
    doc:relayout()
    print("relayout done")
end

--@api-stub: LHtmlDocument:draw
do
    local doc = lurek.html.newDocument("<p>Hello</p>")
    doc:draw(10, 20)
    print("drawn at 10,20")
end

--@api-stub: LHtmlDocument:render
do
    local doc = lurek.html.newDocument("<p>World</p>")
    doc:render(0, 0)
    print("rendered")
end

--@api-stub: LHtmlDocument:update
do
    local doc = lurek.html.newDocument()
    doc:update(0.016)
    print("updated")
end

--@api-stub: LHtmlDocument:on
do
    local doc = lurek.html.newDocument("<button id='btn'>Click</button>")
    local handle = doc:on("click", function(ev)
        print("clicked!")
    end)
    print("registered handle = " .. handle)
end

--@api-stub: LHtmlDocument:off
do
    local doc = lurek.html.newDocument()
    local h = doc:on("hover", function() end)
    doc:off(h)
    print("unregistered")
end

--@api-stub: LHtmlDocument:mousemoved
do
    local doc = lurek.html.newDocument("<div>hover me</div>")
    local handled = doc:mousemoved(100, 50)
    print("mousemoved handled = " .. tostring(handled))
end

--@api-stub: LHtmlDocument:mousepressed
do
    local doc = lurek.html.newDocument("<button>click</button>")
    local handled = doc:mousepressed(100, 50, 1)
    print("mousepressed handled = " .. tostring(handled))
end

--@api-stub: LHtmlDocument:mousereleased
do
    local doc = lurek.html.newDocument("<button>click</button>")
    local handled = doc:mousereleased(100, 50, 1)
    print("mousereleased handled = " .. tostring(handled))
end

--@api-stub: LHtmlDocument:keypressed
do
    local doc = lurek.html.newDocument("<input id='in'/>")
    local handled = doc:keypressed("return")
    print("keypressed handled = " .. tostring(handled))
end

--@api-stub: LHtmlDocument:textinput
do
    local doc = lurek.html.newDocument("<input/>")
    local handled = doc:textinput("A")
    print("textinput handled = " .. tostring(handled))
end

--@api-stub: LHtmlDocument:wheelmoved
do
    local doc = lurek.html.newDocument("<div style='overflow:scroll;height:100px'><p>long</p></div>")
    local handled = doc:wheelmoved(0, -3)
    print("wheelmoved handled = " .. tostring(handled))
end

--@api-stub: LHtmlDocument:type
do
    local doc = lurek.html.newDocument()
    print("type = " .. doc:type())
end

--@api-stub: LHtmlDocument:typeOf
do
    local doc = lurek.html.newDocument()
    print("is HtmlDocument = " .. tostring(doc:typeOf("LHtmlDocument")))
end

--- HTML Module Part 2: LHtmlElement methods


--@api-stub: LHtmlElement:getId
do
    local doc = lurek.html.newDocument("<div id='main'>content</div>")
    local el = doc:getElementById("main")
    if el then
        print("id = " .. tostring(el:getId()))
    end
end

--@api-stub: LHtmlElement:setId
do
    local doc = lurek.html.newDocument("<div>content</div>")
    local root = doc:getRoot()
    root:setId("container")
    print("id set")
end

--@api-stub: LHtmlElement:getTagName
do
    local doc = lurek.html.newDocument("<section>stuff</section>")
    local root = doc:getRoot()
    print("tag = " .. root:getTagName())
end

--@api-stub: LHtmlElement:getAttribute
do
    local doc = lurek.html.newDocument("<a href='#top'>link</a>")
    local el = doc:query("a")
    print("href = " .. tostring(el and el:getAttribute("href")))
end

--@api-stub: LHtmlElement:setAttribute
do
    local doc = lurek.html.newDocument("<img/>")
    local el = doc:query("img")
    if el then el:setAttribute("src", "content/examples/assets/images/sample_icon.png") end
    print("src set")
end

--@api-stub: LHtmlElement:removeAttribute
do
    local doc = lurek.html.newDocument("<div data-x='1'>X</div>")
    local el = doc:query("div")
    if el then el:removeAttribute("data-x") end
    print("data-x removed")
end

--@api-stub: LHtmlElement:getStyle
do
    local doc = lurek.html.newDocument("<div style='color:red'>R</div>")
    local el = doc:query("div")
    print("color = " .. tostring(el and el:getStyle("color")))
end

--@api-stub: LHtmlElement:setStyle
do
    local doc = lurek.html.newDocument("<p>text</p>")
    local el = doc:query("p")
    if el then el:setStyle("font-size", "20px") end
    print("style set")
end

--@api-stub: LHtmlElement:addClass
do
    local doc = lurek.html.newDocument("<div>box</div>")
    local el = doc:query("div")
    if el then el:addClass("highlight") end
    print("class added")
end

--@api-stub: LHtmlElement:removeClass
do
    local doc = lurek.html.newDocument("<div class='active old'>X</div>")
    local el = doc:query("div")
    if el then el:removeClass("old") end
    print("class removed")
end

--@api-stub: LHtmlElement:hasClass
do
    local doc = lurek.html.newDocument("<div class='visible'>Y</div>")
    local el = doc:query("div")
    if el then
        print("has visible = " .. tostring(el:hasClass("visible")))
    end
end

--@api-stub: LHtmlElement:toggleClass
do
    local doc = lurek.html.newDocument("<div class='on'>Z</div>")
    local el = doc:query("div")
    print("toggle result = " .. tostring(el and el:toggleClass("on")))
end

--@api-stub: LHtmlElement:getHtml
do
    local doc = lurek.html.newDocument("<div><span>inner</span></div>")
    local el = doc:query("div")
    if el then
        print("html = " .. el:getHtml())
    end
end

--@api-stub: LHtmlElement:setHtml
do
    local doc = lurek.html.newDocument("<div>old</div>")
    local el = doc:query("div")
    if el then el:setHtml("<b>new</b>") end
    print("html updated")
end

--@api-stub: LHtmlElement:appendHtml
do
    local doc = lurek.html.newDocument("<ul><li>first</li></ul>")
    local el = doc:query("ul")
    if el then el:appendHtml("<li>second</li>") end
    print("html appended")
end

--@api-stub: LHtmlElement:getText
do
    local doc = lurek.html.newDocument("<p>Hello World</p>")
    local el = doc:query("p")
    if el then
        print("text = " .. el:getText())
    end
end

--@api-stub: LHtmlElement:setText
do
    local doc = lurek.html.newDocument("<span>old</span>")
    local el = doc:query("span")
    if el then el:setText("new text") end
    print("text set")
end

--@api-stub: LHtmlElement:getRect
do
    local doc = lurek.html.newDocument("<div style='width:100px;height:50px'>box</div>")
    doc:setViewport(800, 600); doc:relayout()
    local el = doc:query("div")
    if el then local x, y, w, h = el:getRect(); print("rect = " .. x .. "," .. y .. " " .. w .. "x" .. h) end
end

--@api-stub: LHtmlElement:getDocument
do
    local doc = lurek.html.newDocument("<p>owned</p>")
    local el = doc:query("p")
    if el then print("owner type = " .. el:getDocument():type()) end
end

--@api-stub: LHtmlElement:query
do
    local doc = lurek.html.newDocument("<div><span class='x'>found</span></div>")
    local div = doc:query("div")
    local span = div and div:query(".x")
    print("child query = " .. tostring(span and span:getText()))
end

--@api-stub: LHtmlElement:queryAll
do
    local doc = lurek.html.newDocument("<ul><li>A</li><li>B</li></ul>")
    local ul = doc:query("ul")
    print("child items = " .. #(ul and ul:queryAll("li") or {}))
end

--@api-stub: LHtmlElement:on
do
    local doc = lurek.html.newDocument("<button id='btn'>Go</button>")
    local el = doc:getElementById("btn")
    if el then print("element handle = " .. el:on("click", function() print("button clicked") end)) end
end

--@api-stub: LHtmlElement:off
do
    local doc = lurek.html.newDocument("<div id='d'>X</div>")
    local el = doc:getElementById("d")
    if el then local h = el:on("hover", function() end); el:off(h) end
    print("handler removed")
end

--@api-stub: LHtmlElement:focus
do
    local doc = lurek.html.newDocument("<input id='field'/>")
    local el = doc:getElementById("field")
    if el then el:focus() end
    print("focused")
end

--@api-stub: LHtmlElement:blur
do
    local doc = lurek.html.newDocument("<input id='field2'/>")
    local el = doc:getElementById("field2")
    if el then el:focus(); el:blur() end
    print("blurred")
end

--@api-stub: LHtmlElement:remove
do
    local doc = lurek.html.newDocument("<div><p id='del'>gone</p></div>")
    local el = doc:getElementById("del")
    if el then el:remove() end
    print("element removed")
end

--@api-stub: LHtmlElement:type
do
    local doc = lurek.html.newDocument("<div>X</div>")
    local el = doc:getRoot()
    print("type = " .. el:type())
end

--@api-stub: LHtmlElement:typeOf
do
    local doc = lurek.html.newDocument("<div>X</div>")
    local el = doc:getRoot()
    print("is HtmlElement = " .. tostring(el:typeOf("LHtmlElement")))
end

print("content/examples/html.lua")

