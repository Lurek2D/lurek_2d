-- content/examples/html.lua
-- Auto-generated from content/examples2/html_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/html.lua

--- HTML Module Part 1: factory, LHtmlDocument methods

--@api: lurek.html.newDocument
do
    local doc = lurek.html.newDocument()
    print("doc created = " .. tostring(doc ~= nil))
end

--@api: lurek.html.loadDocument
do
    local ok, doc = pcall(lurek.html.loadDocument, "content/examples/assets/layouts/sample_menu.html")
    print("loaded document = " .. tostring(ok))
    if ok then
        print("loaded doc type = " .. doc:type())
    end
end

--@api: lurek.html.supports
do
    local ok = lurek.html.supports("css-flex")
    print("css-flex supported = " .. tostring(ok))
end

--@api: lurek.html.preventDefault
do
    local doc = lurek.html.newDocument("<button id='btn'>Go</button>")
    doc:on("click", function(ev)
        print("event preventDefault = " .. tostring(type(ev.preventDefault) == "function"))
    end)
    print("module preventDefault = " .. tostring(type(lurek.html.preventDefault)))
end

--@api: lurek.html.stopPropagation
do
    local doc = lurek.html.newDocument("<button id='btn'>Go</button>")
    doc:on("click", function(ev)
        print("event stopPropagation = " .. tostring(type(ev.stopPropagation) == "function"))
    end)
    print("module stopPropagation = " .. tostring(type(lurek.html.stopPropagation)))
end

--@api: lurek.html.isDefaultPrevented
do
    local doc = lurek.html.newDocument("<button id='btn'>Go</button>")
    doc:on("click", function(ev)
        print("event isDefaultPrevented = " .. tostring(type(ev.isDefaultPrevented) == "function"))
    end)
    print("module isDefaultPrevented = " .. tostring(type(lurek.html.isDefaultPrevented)))
end

--@api: LHtmlDocument:setHtml
do
    local doc = lurek.html.newDocument()
    doc:setHtml("<h1>Title</h1><p>Body text</p>")
    print("html set")
end

--@api: LHtmlDocument:getHtml
do
    local doc = lurek.html.newDocument("<span>test</span>")
    local html = doc:getHtml()
    print("html = " .. html)
end

--@api: LHtmlDocument:setCss
do
    local doc = lurek.html.newDocument("<div class='box'>X</div>")
    doc:setCss(".box { width: 100px; height: 100px; }")
    print("css set")
end

--@api: LHtmlDocument:addCss
do
    local doc = lurek.html.newDocument("<p>styled</p>")
    doc:addCss("p { font-size: 16px; }")
    doc:addCss("p { margin: 10px; }")
    print("css appended")
end

--@api: LHtmlDocument:clearCss
do
    local doc = lurek.html.newDocument("<p>unstyled</p>")
    doc:setCss("p { color: red; }")
    doc:clearCss()
    print("css cleared")
end

--@api: LHtmlDocument:setViewport
do
    local doc = lurek.html.newDocument()
    doc:setViewport(1024, 768)
    print("viewport set to 1024x768")
end

--@api: LHtmlDocument:getViewport
do
    local doc = lurek.html.newDocument()
    doc:setViewport(800, 600)
    local w, h = doc:getViewport()
    print("viewport = " .. w .. "x" .. h)
end

--@api: LHtmlDocument:getElementById
do
    local doc = lurek.html.newDocument("<div id='hero'>Player</div>")
    local el = doc:getElementById("hero")
    if el then
        print("found: " .. el:getText())
    end
end

--@api: LHtmlDocument:getRoot
do
    local doc = lurek.html.newDocument("<div>root child</div>")
    local root = doc:getRoot()
    print("root tag = " .. root:getTagName())
end

--@api: LHtmlDocument:query
do
    local doc = lurek.html.newDocument("<p class='intro'>Hello</p><p>World</p>")
    local el = doc:query(".intro")
    if el then
        print("query found: " .. el:getText())
    end
end

--@api: LHtmlDocument:queryAll
do
    local doc = lurek.html.newDocument("<li>A</li><li>B</li><li>C</li>")
    local items = doc:queryAll("li")
    print("items = " .. #items)
end

--@api: LHtmlDocument:isDirty
do
    local doc = lurek.html.newDocument("<p>X</p>")
    doc:setHtml("<p>Y</p>")
    print("dirty = " .. tostring(doc:isDirty()))
end

--@api: LHtmlDocument:relayout
do
    local doc = lurek.html.newDocument("<div>content</div>")
    doc:relayout()
    print("relayout done")
end

--@api: LHtmlDocument:draw
do
    local doc = lurek.html.newDocument("<p>Hello</p>")
    doc:draw(10, 20)
    print("drawn at 10,20")
end

--@api: LHtmlDocument:render
do
    local doc = lurek.html.newDocument("<p>World</p>")
    doc:render(0, 0)
    print("rendered")
end

--@api: LHtmlDocument:update
do
    local doc = lurek.html.newDocument()
    doc:update(0.016)
    print("updated")
end

--@api: LHtmlDocument:on
do
    local doc = lurek.html.newDocument("<button id='btn'>Click</button>")
    local handle = doc:on("click", function(ev)
        print("clicked!")
    end)
    print("registered handle = " .. handle)
end

--@api: LHtmlDocument:off
do
    local doc = lurek.html.newDocument()
    local h = doc:on("hover", function() end)
    doc:off(h)
    print("unregistered")
end

--@api: LHtmlDocument:mousemoved
do
    local doc = lurek.html.newDocument("<div>hover me</div>")
    local handled = doc:mousemoved(100, 50)
    print("mousemoved handled = " .. tostring(handled))
end

--@api: LHtmlDocument:mousepressed
do
    local doc = lurek.html.newDocument("<button>click</button>")
    local handled = doc:mousepressed(100, 50, 1)
    print("mousepressed handled = " .. tostring(handled))
end

--@api: LHtmlDocument:mousereleased
do
    local doc = lurek.html.newDocument("<button>click</button>")
    local handled = doc:mousereleased(100, 50, 1)
    print("mousereleased handled = " .. tostring(handled))
end

--@api: LHtmlDocument:keypressed
do
    local doc = lurek.html.newDocument("<input id='in'/>")
    local handled = doc:keypressed("return")
    print("keypressed handled = " .. tostring(handled))
end

--@api: LHtmlDocument:textinput
do
    local doc = lurek.html.newDocument("<input/>")
    local handled = doc:textinput("A")
    print("textinput handled = " .. tostring(handled))
end

--@api: LHtmlDocument:wheelmoved
do
    local doc = lurek.html.newDocument("<div style='overflow:scroll;height:100px'><p>long</p></div>")
    local handled = doc:wheelmoved(0, -3)
    print("wheelmoved handled = " .. tostring(handled))
end

--@api: LHtmlDocument:type
do
    local doc = lurek.html.newDocument()
    print("type = " .. doc:type())
end

--@api: LHtmlDocument:typeOf
do
    local doc = lurek.html.newDocument()
    print("is HtmlDocument = " .. tostring(doc:typeOf("LHtmlDocument")))
end

--- HTML Module Part 2: LHtmlElement methods

--@api: LHtmlElement:getId
do
    local doc = lurek.html.newDocument("<div id='main'>content</div>")
    local el = doc:getElementById("main")
    if el then
        print("id = " .. tostring(el:getId()))
    end
end

--@api: LHtmlElement:setId
do
    local doc = lurek.html.newDocument("<div>content</div>")
    local root = doc:getRoot()
    root:setId("container")
    print("id set")
end

--@api: LHtmlElement:getTagName
do
    local doc = lurek.html.newDocument("<section>stuff</section>")
    local root = doc:getRoot()
    print("tag = " .. root:getTagName())
end

--@api: LHtmlElement:getAttribute
do
    local doc = lurek.html.newDocument("<a href='#top'>link</a>")
    local el = doc:query("a")
    print("href = " .. tostring(el and el:getAttribute("href")))
end

--@api: LHtmlElement:setAttribute
do
    local doc = lurek.html.newDocument("<img/>")
    local el = doc:query("img")
    if el then el:setAttribute("src", "content/examples/assets/images/sample_icon.png") end
    print("src set")
end

--@api: LHtmlElement:removeAttribute
do
    local doc = lurek.html.newDocument("<div data-x='1'>X</div>")
    local el = doc:query("div")
    if el then el:removeAttribute("data-x") end
    print("data-x removed")
end

--@api: LHtmlElement:getStyle
do
    local doc = lurek.html.newDocument("<div style='color:red'>R</div>")
    local el = doc:query("div")
    print("color = " .. tostring(el and el:getStyle("color")))
end

--@api: LHtmlElement:setStyle
do
    local doc = lurek.html.newDocument("<p>text</p>")
    local el = doc:query("p")
    if el then el:setStyle("font-size", "20px") end
    print("style set")
end

--@api: LHtmlElement:addClass
do
    local doc = lurek.html.newDocument("<div>box</div>")
    local el = doc:query("div")
    if el then el:addClass("highlight") end
    print("class added")
end

--@api: LHtmlElement:removeClass
do
    local doc = lurek.html.newDocument("<div class='active old'>X</div>")
    local el = doc:query("div")
    if el then el:removeClass("old") end
    print("class removed")
end

--@api: LHtmlElement:hasClass
do
    local doc = lurek.html.newDocument("<div class='visible'>Y</div>")
    local el = doc:query("div")
    if el then
        print("has visible = " .. tostring(el:hasClass("visible")))
    end
end

--@api: LHtmlElement:toggleClass
do
    local doc = lurek.html.newDocument("<div class='on'>Z</div>")
    local el = doc:query("div")
    print("toggle result = " .. tostring(el and el:toggleClass("on")))
end

--@api: LHtmlElement:getHtml
do
    local doc = lurek.html.newDocument("<div><span>inner</span></div>")
    local el = doc:query("div")
    if el then
        print("html = " .. el:getHtml())
    end
end

--@api: LHtmlElement:setHtml
do
    local doc = lurek.html.newDocument("<div>old</div>")
    local el = doc:query("div")
    if el then el:setHtml("<b>new</b>") end
    print("html updated")
end

--@api: LHtmlElement:appendHtml
do
    local doc = lurek.html.newDocument("<ul><li>first</li></ul>")
    local el = doc:query("ul")
    if el then el:appendHtml("<li>second</li>") end
    print("html appended")
end

--@api: LHtmlElement:getText
do
    local doc = lurek.html.newDocument("<p>Hello World</p>")
    local el = doc:query("p")
    if el then
        print("text = " .. el:getText())
    end
end

--@api: LHtmlElement:setText
do
    local doc = lurek.html.newDocument("<span>old</span>")
    local el = doc:query("span")
    if el then el:setText("new text") end
    print("text set")
end

--@api: LHtmlElement:getRect
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

--@api: LHtmlElement:getDocument
do
    local doc = lurek.html.newDocument("<p>owned</p>")
    local el = doc:query("p")
    if el then
        print("owner type = " .. el:getDocument():type())
    end
end

--@api: LHtmlElement:query
do
    local doc = lurek.html.newDocument("<div><span class='x'>found</span></div>")
    local div = doc:query("div")
    local span = div and div:query(".x")
    print("child query = " .. tostring(span and span:getText()))
end

--@api: LHtmlElement:queryAll
do
    local doc = lurek.html.newDocument("<ul><li>A</li><li>B</li></ul>")
    local ul = doc:query("ul")
    print("child items = " .. #(ul and ul:queryAll("li") or {}))
end

--@api: LHtmlElement:on
do
    local doc = lurek.html.newDocument("<button id='btn'>Go</button>")
    local el = doc:getElementById("btn")
    if el then
        local handle = el:on("click", function()
            print("button clicked")
        end)
        print("element handle = " .. handle)
    end
end

--@api: LHtmlElement:off
do
    local doc = lurek.html.newDocument("<div id='d'>X</div>")
    local el = doc:getElementById("d")
    if el then
        local h = el:on("hover", function()
        end)
        el:off(h)
    end
    print("handler removed")
end

--@api: LHtmlElement:focus
do
    local doc = lurek.html.newDocument("<input id='field'/>")
    local el = doc:getElementById("field")
    if el then el:focus() end
    print("focused")
end

--@api: LHtmlElement:blur
do
    local doc = lurek.html.newDocument("<input id='field2'/>")
    local el = doc:getElementById("field2")
    if el then
        el:focus()
        el:blur()
    end
    print("blurred")
end

--@api: LHtmlElement:remove
do
    local doc = lurek.html.newDocument("<div><p id='del'>gone</p></div>")
    local el = doc:getElementById("del")
    if el then el:remove() end
    print("element removed")
end

--@api: LHtmlElement:type
do
    local doc = lurek.html.newDocument("<div>X</div>")
    local el = doc:getRoot()
    print("type = " .. el:type())
end

--@api: LHtmlElement:typeOf
do
    local doc = lurek.html.newDocument("<div>X</div>")
    local el = doc:getRoot()
    print("is HtmlElement = " .. tostring(el:typeOf("LHtmlElement")))
end
