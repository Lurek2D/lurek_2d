-- content/examples/html.lua
-- Auto-generated from content/examples2/html_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/html.lua

local function html_log(message)
    lurek.log.info("[html.example] " .. tostring(message))
end

--- HTML Module Part 1: factory, LHtmlDocument methods

local function example_print_log(...)
    local parts = {}
    for i = 1, select("#", ...) do
        parts[i] = tostring(select(i, ...))
    end
    lurek.log.info(table.concat(parts, " "))
end

--@api: lurek.html.newDocument
do
    local doc = lurek.html.newDocument("<main id='hud'><h1>HUD</h1><p>Status</p></main>")
    local root = doc:getRoot()
    html_log("doc created=" .. tostring(doc ~= nil))
    html_log("root tag=" .. root:getTagName())
    html_log("html length=" .. #doc:getHtml())
    html_log("type=" .. doc:type())
end

--@api: lurek.html.loadDocument
do
    local ok, doc = pcall(lurek.html.loadDocument, "content/examples/assets/layouts/sample_menu.html")
    example_print_log("loaded document = " .. tostring(ok))
    if ok then
        example_print_log("loaded doc type = " .. doc:type())
    end
end

--@api: lurek.html.supports
do
    local ok = lurek.html.supports("css-flex")
    local query_ok = lurek.html.supports("selectors")
    local bogus = lurek.html.supports("totally-unknown-feature")
    html_log("css-flex supported=" .. tostring(ok))
    html_log("selectors supported=" .. tostring(query_ok))
    html_log("unknown feature supported=" .. tostring(bogus))
    html_log("supports returns booleans for capability probes")
end

--@api: lurek.html.preventDefault
do
    local doc = lurek.html.newDocument("<button id='btn'>Go</button>")
    doc:on("click", function(ev)
        example_print_log("event preventDefault = " .. tostring(type(ev.preventDefault) == "function"))
    end)
    example_print_log("module preventDefault = " .. tostring(type(lurek.html.preventDefault)))
end

--@api: lurek.html.stopPropagation
do
    local doc = lurek.html.newDocument("<button id='btn'>Go</button>")
    doc:on("click", function(ev)
        example_print_log("event stopPropagation = " .. tostring(type(ev.stopPropagation) == "function"))
    end)
    example_print_log("module stopPropagation = " .. tostring(type(lurek.html.stopPropagation)))
end

--@api: lurek.html.isDefaultPrevented
do
    local doc = lurek.html.newDocument("<button id='btn'>Go</button>")
    doc:on("click", function(ev)
        example_print_log("event isDefaultPrevented = " .. tostring(type(ev.isDefaultPrevented) == "function"))
    end)
    example_print_log("module isDefaultPrevented = " .. tostring(type(lurek.html.isDefaultPrevented)))
end

--@api: LHtmlDocument:setHtml
do
    local doc = lurek.html.newDocument()
    doc:setHtml("<h1>Title</h1><p>Body text</p>")
    local heading = doc:query("h1")
    html_log("html set length=" .. #doc:getHtml())
    html_log("dirty after set=" .. tostring(doc:isDirty()))
    html_log("heading text=" .. tostring(heading and heading:getText()))
    html_log("paragraph count=" .. #(doc:queryAll("p")))
end

--@api: LHtmlDocument:getHtml
do
    local doc = lurek.html.newDocument("<span>test</span>")
    local html = doc:getHtml()
    local root = doc:getRoot()
    html_log("html=" .. html)
    html_log("html length=" .. #html)
    html_log("root tag=" .. root:getTagName())
    html_log("dirty=" .. tostring(doc:isDirty()))
end

--@api: LHtmlDocument:setCss
do
    local doc = lurek.html.newDocument("<div class='box'>X</div>")
    doc:setCss(".box { width: 100px; height: 100px; }")
    doc:relayout()
    local el = doc:query(".box")
    html_log("css set for .box")
    html_log("dirty after relayout=" .. tostring(doc:isDirty()))
    html_log("box text=" .. tostring(el and el:getText()))
    html_log("viewport=" .. table.concat({ doc:getViewport() }, "x"))
end

--@api: LHtmlDocument:addCss
do
    local doc = lurek.html.newDocument("<p>styled</p>")
    doc:addCss("p { font-size: 16px; }")
    doc:addCss("p { margin: 10px; }")
    local css_html = doc:getHtml()
    html_log("css appended")
    html_log("dirty=" .. tostring(doc:isDirty()))
    html_log("paragraph count=" .. #(doc:queryAll("p")))
    html_log("html length=" .. #css_html)
end

--@api: LHtmlDocument:clearCss
do
    local doc = lurek.html.newDocument("<p>unstyled</p>")
    doc:setCss("p { color: red; }")
    doc:clearCss()
    doc:relayout()
    html_log("css cleared")
    html_log("dirty after relayout=" .. tostring(doc:isDirty()))
    html_log("paragraph count=" .. #(doc:queryAll("p")))
    html_log("viewport=" .. table.concat({ doc:getViewport() }, "x"))
end

--@api: LHtmlDocument:setViewport
do
    local doc = lurek.html.newDocument()
    doc:setViewport(1024, 768)
    local w, h = doc:getViewport()
    html_log("viewport set=" .. w .. "x" .. h)
    html_log("dirty=" .. tostring(doc:isDirty()))
    html_log("type=" .. doc:type())
    html_log("html length=" .. #doc:getHtml())
end

--@api: LHtmlDocument:getViewport
do
    local doc = lurek.html.newDocument()
    doc:setViewport(800, 600)
    local w, h = doc:getViewport()
    html_log("viewport=" .. w .. "x" .. h)
    html_log("dirty=" .. tostring(doc:isDirty()))
    html_log("type=" .. doc:type())
    html_log("html length=" .. #doc:getHtml())
end

--@api: LHtmlDocument:getElementById
do
    local doc = lurek.html.newDocument("<div id='hero'>Player</div>")
    local el = doc:getElementById("hero")
    if el then
        example_print_log("found: " .. el:getText())
    end
end

--@api: LHtmlDocument:getRoot
do
    local doc = lurek.html.newDocument("<div>root child</div>")
    local root = doc:getRoot()
    html_log("root tag=" .. root:getTagName())
    html_log("root text=" .. root:getText())
    html_log("root type=" .. root:type())
    html_log("document type=" .. root:getDocument():type())
end

--@api: LHtmlDocument:query
do
    local doc = lurek.html.newDocument("<p class='intro'>Hello</p><p>World</p>")
    local el = doc:query(".intro")
    if el then
        example_print_log("query found: " .. el:getText())
    end
end

--@api: LHtmlDocument:queryAll
do
    local doc = lurek.html.newDocument("<li>A</li><li>B</li><li>C</li>")
    local items = doc:queryAll("li")
    html_log("items=" .. #items)
    html_log("first item=" .. tostring(items[1] and items[1]:getText()))
    html_log("second item=" .. tostring(items[2] and items[2]:getText()))
    html_log("third item=" .. tostring(items[3] and items[3]:getText()))
end

--@api: LHtmlDocument:isDirty
do
    local doc = lurek.html.newDocument("<p>X</p>")
    doc:setHtml("<p>Y</p>")
    html_log("dirty after setHtml=" .. tostring(doc:isDirty()))
    doc:relayout()
    html_log("dirty after relayout=" .. tostring(doc:isDirty()))
    html_log("html=" .. doc:getHtml())
    html_log("paragraph count=" .. #(doc:queryAll("p")))
end

--@api: LHtmlDocument:relayout
do
    local doc = lurek.html.newDocument("<div>content</div>")
    doc:setViewport(640, 360)
    doc:relayout()
    html_log("relayout done")
    html_log("dirty=" .. tostring(doc:isDirty()))
    html_log("viewport=" .. table.concat({ doc:getViewport() }, "x"))
    html_log("root tag=" .. doc:getRoot():getTagName())
end

--@api: LHtmlDocument:draw
do
    local doc = lurek.html.newDocument("<p>Hello</p>")
    doc:setViewport(320, 180)
    doc:relayout()
    doc:draw(10, 20)
    html_log("drawn at 10,20")
    html_log("dirty=" .. tostring(doc:isDirty()))
    html_log("viewport=" .. table.concat({ doc:getViewport() }, "x"))
    html_log("text=" .. tostring(doc:query("p") and doc:query("p"):getText()))
end

--@api: LHtmlDocument:render
do
    local doc = lurek.html.newDocument("<p>World</p>")
    doc:setViewport(320, 180)
    doc:relayout()
    doc:render(0, 0)
    html_log("rendered")
    html_log("dirty=" .. tostring(doc:isDirty()))
    html_log("viewport=" .. table.concat({ doc:getViewport() }, "x"))
    html_log("text=" .. tostring(doc:query("p") and doc:query("p"):getText()))
end

--@api: LHtmlDocument:update
do
    local doc = lurek.html.newDocument("<p>Tick</p>")
    doc:update(0.016)
    html_log("updated")
    html_log("dirty=" .. tostring(doc:isDirty()))
    html_log("type=" .. doc:type())
    html_log("html length=" .. #doc:getHtml())
end

--@api: LHtmlDocument:on
do
    local doc = lurek.html.newDocument("<button id='btn'>Click</button>")
    local handle = doc:on("click", function(ev)
        example_print_log("clicked!")
    end)
    example_print_log("registered handle = " .. handle)
end

--@api: LHtmlDocument:off
do
    local doc = lurek.html.newDocument()
    local h = doc:on("hover", function() end)
    doc:off(h)
    local second = doc:on("tick", function() end)
    doc:off(second)
    html_log("unregistered first handle=" .. tostring(h))
    html_log("unregistered second handle=" .. tostring(second))
    html_log("type=" .. doc:type())
    html_log("html length=" .. #doc:getHtml())
end

--@api: LHtmlDocument:mousemoved
do
    local doc = lurek.html.newDocument("<div>hover me</div>")
    local handled = doc:mousemoved(100, 50)
    html_log("mousemoved handled=" .. tostring(handled))
    html_log("root tag=" .. doc:getRoot():getTagName())
    html_log("dirty=" .. tostring(doc:isDirty()))
    html_log("viewport=" .. table.concat({ doc:getViewport() }, "x"))
end

--@api: LHtmlDocument:mousepressed
do
    local doc = lurek.html.newDocument("<button>click</button>")
    local handled = doc:mousepressed(100, 50, 1)
    html_log("mousepressed handled=" .. tostring(handled))
    html_log("button exists=" .. tostring(doc:query("button") ~= nil))
    html_log("dirty=" .. tostring(doc:isDirty()))
    html_log("type=" .. doc:type())
end

--@api: LHtmlDocument:mousereleased
do
    local doc = lurek.html.newDocument("<button>click</button>")
    local handled = doc:mousereleased(100, 50, 1)
    html_log("mousereleased handled=" .. tostring(handled))
    html_log("button exists=" .. tostring(doc:query("button") ~= nil))
    html_log("dirty=" .. tostring(doc:isDirty()))
    html_log("type=" .. doc:type())
end

--@api: LHtmlDocument:keypressed
do
    local doc = lurek.html.newDocument("<input id='in'/>")
    local handled = doc:keypressed("return")
    html_log("keypressed handled=" .. tostring(handled))
    html_log("input exists=" .. tostring(doc:getElementById("in") ~= nil))
    html_log("dirty=" .. tostring(doc:isDirty()))
    html_log("type=" .. doc:type())
end

--@api: LHtmlDocument:textinput
do
    local doc = lurek.html.newDocument("<input/>")
    local handled = doc:textinput("A")
    html_log("textinput handled=" .. tostring(handled))
    html_log("input exists=" .. tostring(doc:query("input") ~= nil))
    html_log("dirty=" .. tostring(doc:isDirty()))
    html_log("type=" .. doc:type())
end

--@api: LHtmlDocument:wheelmoved
do
    local doc = lurek.html.newDocument("<div style='overflow:scroll;height:100px'><p>long</p></div>")
    local handled = doc:wheelmoved(0, -3)
    html_log("wheelmoved handled=" .. tostring(handled))
    html_log("scroll container exists=" .. tostring(doc:query("div") ~= nil))
    html_log("dirty=" .. tostring(doc:isDirty()))
    html_log("type=" .. doc:type())
end

--@api: LHtmlDocument:type
do
    local doc = lurek.html.newDocument()
    html_log("type=" .. doc:type())
    html_log("is document=" .. tostring(doc:typeOf("LHtmlDocument")))
    html_log("viewport=" .. table.concat({ doc:getViewport() }, "x"))
    html_log("html length=" .. #doc:getHtml())
end

--@api: LHtmlDocument:typeOf
do
    local doc = lurek.html.newDocument()
    html_log("is HtmlDocument=" .. tostring(doc:typeOf("LHtmlDocument")))
    html_log("is LObject=" .. tostring(doc:typeOf("LObject")))
    html_log("is HtmlElement=" .. tostring(doc:typeOf("LHtmlElement")))
    html_log("type=" .. doc:type())
end

--- HTML Module Part 2: LHtmlElement methods

--@api: LHtmlElement:getId
do
    local doc = lurek.html.newDocument("<div id='main'>content</div>")
    local el = doc:getElementById("main")
    if el then
        example_print_log("id = " .. tostring(el:getId()))
    end
end

--@api: LHtmlElement:setId
do
    local doc = lurek.html.newDocument("<div>content</div>")
    local root = doc:getRoot()
    root:setId("container")
    html_log("id set to=" .. tostring(root:getId()))
    html_log("lookup works=" .. tostring(doc:getElementById("container") ~= nil))
    html_log("root tag=" .. root:getTagName())
    html_log("root type=" .. root:type())
end

--@api: LHtmlElement:getTagName
do
    local doc = lurek.html.newDocument("<section>stuff</section>")
    local root = doc:getRoot()
    html_log("tag=" .. root:getTagName())
    html_log("text=" .. root:getText())
    html_log("type=" .. root:type())
    html_log("doc type=" .. root:getDocument():type())
end

--@api: LHtmlElement:getAttribute
do
    local doc = lurek.html.newDocument("<a href='#top'>link</a>")
    local el = doc:query("a")
    html_log("href=" .. tostring(el and el:getAttribute("href")))
    html_log("tag=" .. tostring(el and el:getTagName()))
    html_log("text=" .. tostring(el and el:getText()))
    html_log("type=" .. tostring(el and el:type()))
end

--@api: LHtmlElement:setAttribute
do
    local doc = lurek.html.newDocument("<img/>")
    local el = doc:query("img")
    if el then el:setAttribute("src", "content/examples/assets/images/sample_icon.png") end
    html_log("src set=" .. tostring(el and el:getAttribute("src")))
    html_log("tag=" .. tostring(el and el:getTagName()))
    html_log("type=" .. tostring(el and el:type()))
    html_log("doc type=" .. tostring(el and el:getDocument():type()))
end

--@api: LHtmlElement:removeAttribute
do
    local doc = lurek.html.newDocument("<div data-x='1'>X</div>")
    local el = doc:query("div")
    if el then el:removeAttribute("data-x") end
    html_log("data-x removed=" .. tostring(el and el:getAttribute("data-x")))
    html_log("tag=" .. tostring(el and el:getTagName()))
    html_log("text=" .. tostring(el and el:getText()))
    html_log("type=" .. tostring(el and el:type()))
end

--@api: LHtmlElement:getStyle
do
    local doc = lurek.html.newDocument("<div style='color:red'>R</div>")
    local el = doc:query("div")
    html_log("color=" .. tostring(el and el:getStyle("color")))
    html_log("tag=" .. tostring(el and el:getTagName()))
    html_log("text=" .. tostring(el and el:getText()))
    html_log("type=" .. tostring(el and el:type()))
end

--@api: LHtmlElement:setStyle
do
    local doc = lurek.html.newDocument("<p>text</p>")
    local el = doc:query("p")
    if el then el:setStyle("font-size", "20px") end
    html_log("font-size=" .. tostring(el and el:getStyle("font-size")))
    html_log("tag=" .. tostring(el and el:getTagName()))
    html_log("text=" .. tostring(el and el:getText()))
    html_log("type=" .. tostring(el and el:type()))
end

--@api: LHtmlElement:addClass
do
    local doc = lurek.html.newDocument("<div>box</div>")
    local el = doc:query("div")
    if el then el:addClass("highlight") end
    html_log("class added=" .. tostring(el and el:hasClass("highlight")))
    html_log("tag=" .. tostring(el and el:getTagName()))
    html_log("text=" .. tostring(el and el:getText()))
    html_log("type=" .. tostring(el and el:type()))
end

--@api: LHtmlElement:removeClass
do
    local doc = lurek.html.newDocument("<div class='active old'>X</div>")
    local el = doc:query("div")
    if el then el:removeClass("old") end
    html_log("old class removed=" .. tostring(el and el:hasClass("old")))
    html_log("active class remains=" .. tostring(el and el:hasClass("active")))
    html_log("text=" .. tostring(el and el:getText()))
    html_log("type=" .. tostring(el and el:type()))
end

--@api: LHtmlElement:hasClass
do
    local doc = lurek.html.newDocument("<div class='visible'>Y</div>")
    local el = doc:query("div")
    if el then
        example_print_log("has visible = " .. tostring(el:hasClass("visible")))
    end
end

--@api: LHtmlElement:toggleClass
do
    local doc = lurek.html.newDocument("<div class='on'>Z</div>")
    local el = doc:query("div")
    local first = el and el:toggleClass("on")
    local second = el and el:toggleClass("on")
    html_log("toggle result first=" .. tostring(first))
    html_log("toggle result second=" .. tostring(second))
    html_log("has class now=" .. tostring(el and el:hasClass("on")))
    html_log("type=" .. tostring(el and el:type()))
end

--@api: LHtmlElement:getHtml
do
    local doc = lurek.html.newDocument("<div><span>inner</span></div>")
    local el = doc:query("div")
    if el then
        example_print_log("html = " .. el:getHtml())
    end
end

--@api: LHtmlElement:setHtml
do
    local doc = lurek.html.newDocument("<div>old</div>")
    local el = doc:query("div")
    if el then el:setHtml("<b>new</b>") end
    html_log("html updated=" .. tostring(el and el:getHtml()))
    html_log("text=" .. tostring(el and el:getText()))
    html_log("tag=" .. tostring(el and el:getTagName()))
    html_log("type=" .. tostring(el and el:type()))
end

--@api: LHtmlElement:appendHtml
do
    local doc = lurek.html.newDocument("<ul><li>first</li></ul>")
    local el = doc:query("ul")
    if el then el:appendHtml("<li>second</li>") end
    local items = el and el:queryAll("li") or {}
    html_log("html appended item count=" .. #items)
    html_log("first item=" .. tostring(items[1] and items[1]:getText()))
    html_log("second item=" .. tostring(items[2] and items[2]:getText()))
    html_log("type=" .. tostring(el and el:type()))
end

--@api: LHtmlElement:getText
do
    local doc = lurek.html.newDocument("<p>Hello World</p>")
    local el = doc:query("p")
    if el then
        example_print_log("text = " .. el:getText())
    end
end

--@api: LHtmlElement:setText
do
    local doc = lurek.html.newDocument("<span>old</span>")
    local el = doc:query("span")
    if el then el:setText("new text") end
    html_log("text set=" .. tostring(el and el:getText()))
    html_log("html=" .. tostring(el and el:getHtml()))
    html_log("tag=" .. tostring(el and el:getTagName()))
    html_log("type=" .. tostring(el and el:type()))
end

--@api: LHtmlElement:getRect
do
    local doc = lurek.html.newDocument("<div style='width:100px;height:50px'>box</div>")
    doc:setViewport(800, 600)
    doc:relayout()
    local el = doc:query("div")
    if el then
        local x, y, w, h = el:getRect()
        example_print_log("rect = " .. x .. "," .. y .. " " .. w .. "x" .. h)
    end
end

--@api: LHtmlElement:getDocument
do
    local doc = lurek.html.newDocument("<p>owned</p>")
    local el = doc:query("p")
    if el then
        local owner = el:getDocument()
        example_print_log("document owner present = " .. tostring(owner ~= nil))
        example_print_log("document exposes setHtml = " .. tostring(owner and owner.setHtml ~= nil))
    end
end

--@api: LHtmlElement:query
do
    local doc = lurek.html.newDocument("<div><span class='x'>found</span></div>")
    local div = doc:query("div")
    local span = div and div:query(".x")
    html_log("child query=" .. tostring(span and span:getText()))
    html_log("div tag=" .. tostring(div and div:getTagName()))
    html_log("span type=" .. tostring(span and span:type()))
    html_log("span class found=" .. tostring(span ~= nil))
end

--@api: LHtmlElement:queryAll
do
    local doc = lurek.html.newDocument("<ul><li>A</li><li>B</li></ul>")
    local ul = doc:query("ul")
    local items = ul and ul:queryAll("li") or {}
    html_log("child items=" .. #items)
    html_log("first child=" .. tostring(items[1] and items[1]:getText()))
    html_log("second child=" .. tostring(items[2] and items[2]:getText()))
    html_log("parent type=" .. tostring(ul and ul:type()))
end

--@api: LHtmlElement:on
do
    local doc = lurek.html.newDocument("<button id='btn'>Go</button>")
    local el = doc:getElementById("btn")
    if el then
        local handle = el:on("click", function()
            example_print_log("button clicked")
        end)
        example_print_log("element handle = " .. handle)
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
    example_print_log("handler removed")
end

--@api: LHtmlElement:focus
do
    local doc = lurek.html.newDocument("<input id='field'/>")
    local el = doc:getElementById("field")
    if el then el:focus() end
    html_log("focused element exists=" .. tostring(el ~= nil))
    html_log("focused element tag=" .. tostring(el and el:getTagName()))
    html_log("focused element type=" .. tostring(el and el:type()))
    html_log("document type=" .. tostring(el and el:getDocument():type()))
end

--@api: LHtmlElement:blur
do
    local doc = lurek.html.newDocument("<input id='field2'/>")
    local el = doc:getElementById("field2")
    if el then
        el:focus()
        el:blur()
    end
    example_print_log("blurred")
end

--@api: LHtmlElement:remove
do
    local doc = lurek.html.newDocument("<div><p id='del'>gone</p></div>")
    local el = doc:getElementById("del")
    if el then el:remove() end
    html_log("element removed=" .. tostring(doc:getElementById("del") == nil))
    html_log("remaining paragraphs=" .. #(doc:queryAll("p")))
    html_log("root tag=" .. doc:getRoot():getTagName())
    html_log("type=" .. doc:getRoot():type())
end

--@api: LHtmlElement:type
do
    local doc = lurek.html.newDocument("<div>X</div>")
    local el = doc:getRoot()
    html_log("type=" .. el:type())
    html_log("tag=" .. el:getTagName())
    html_log("text=" .. el:getText())
    html_log("document type=" .. el:getDocument():type())
end

--@api: LHtmlElement:typeOf
do
    local doc = lurek.html.newDocument("<div>X</div>")
    local el = doc:getRoot()
    html_log("is HtmlElement=" .. tostring(el:typeOf("LHtmlElement")))
    html_log("is LObject=" .. tostring(el:typeOf("LObject")))
    html_log("is HtmlDocument=" .. tostring(el:typeOf("LHtmlDocument")))
    html_log("type=" .. el:type())
end
