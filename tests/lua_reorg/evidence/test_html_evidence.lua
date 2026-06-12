-- Canonical evidence file for lurek.html data outputs.

local OUT = evidence_output_dir("html")

local function write_text(path, text)
    if write_file then
        write_file(path, text)
    else
        lurek.filesystem.write(path, text)
    end
    expect_evidence_created(path)
end

-- @describe evidence: html
describe("evidence: html", function()
    before_each(function()
        ensure_evidence_dir("html")
    end)

    -- @evidence lurek.html.newDocument
    -- @evidence LHtmlDocument:getHtml
    it("exports markup snapshot", function()
        local path = OUT .. "html_document_markup_snapshot.txt"
        local doc = lurek.html.newDocument([[<body><div id="header" class="bar">Title</div><div id="content"><p>Hello</p></div></body>]], { width = 800, height = 600 })
        write_text(path, doc:getHtml() or "")
    end)

    -- @evidence lurek.html.loadDocument
    -- @evidence LHtmlDocument:getElementById
    -- @evidence LHtmlElement:getText
    it("exports loaded document snapshot", function()
        local src = "save/html_evidence_fixture.html"
        local css = "save/html_evidence_fixture.css"
        lurek.filesystem.write(src, "<body><h1 id='title'>Fixture Title</h1><p id='body'>Loaded text</p></body>")
        lurek.filesystem.write(css, "#title { color: #00ff00; }")
        local doc = lurek.html.loadDocument(src, { cssPath = css })
        local title = doc:getElementById("title")
        local body = doc:getElementById("body")
        local text = table.concat({
            "title=" .. tostring(title and title:getText() or ""),
            "body=" .. tostring(body and body:getText() or ""),
            "title_color=" .. tostring(title and title:getStyle("color") or ""),
        }, "\n") .. "\n"
        write_text(OUT .. "html_loaded_document_snapshot.txt", text)
    end)

    -- @evidence lurek.html.supports
    -- @evidence LHtmlDocument:render
    -- @evidence LHtmlDocument:type
    -- @evidence LHtmlDocument:typeOf
    it("exports support and render trace", function()
        local path = OUT .. "html_support_render_trace.txt"
        local doc = lurek.html.newDocument("<p id='r'>render</p>")
        local render_ok = pcall(function()
            doc:render(0, 0)
        end)
        local text = table.concat({
            "supports_basic=" .. tostring(lurek.html.supports("basic")),
            "render_ok=" .. tostring(render_ok),
            "doc_type=" .. tostring(doc:type()),
            "doc_typeof=" .. tostring(doc:typeOf("LHtmlDocument")),
        }, "\n") .. "\n"
        write_text(path, text)
    end)

    -- @evidence LHtmlDocument:setCss
    -- @evidence LHtmlDocument:relayout
    -- @evidence LHtmlDocument:getElementById
    -- @evidence LHtmlElement:getRect
    -- @evidence LHtmlElement:hasClass
    -- @evidence LHtmlElement:addClass
    it("exports element rect and class state", function()
        local path = OUT .. "html_element_state.json"
        local doc = lurek.html.newDocument([[<body><div id="box" class="a b" style="width:100px;height:50px;padding:10px;">Box</div></body>]], { width = 400, height = 300 })
        doc:setCss("body { margin: 0; }")
        doc:relayout()

        local el = doc:getElementById("box")
        local x, y, w, h = 0, 0, 0, 0
        local has_a, has_c = false, false
        if el then
            x, y, w, h = el:getRect()
            has_a = el:hasClass("a")
            el:addClass("c")
            has_c = el:hasClass("c")
        end

        local json = string.format(
            '{"x":%d,"y":%d,"w":%d,"h":%d,"has_a":%s,"has_c":%s}',
            x or 0,
            y or 0,
            w or 0,
            h or 0,
            has_a and "true" or "false",
            has_c and "true" or "false"
        )
        write_text(path, json)
    end)

    -- @evidence LHtmlDocument:queryAll
    -- @evidence LHtmlDocument:setViewport
    -- @evidence LHtmlDocument:getViewport
    -- @evidence LHtmlElement:getText
    -- @evidence LHtmlDocument:getRoot
    it("exports queryAll and viewport evidence", function()
        local path = OUT .. "html_query_viewport_snapshot.json"
        local doc = lurek.html.newDocument([[<body><ul><li class="item">Apple</li><li class="item">Banana</li><li class="item">Cherry</li></ul></body>]], { width = 640, height = 480 })

        local root = doc:getRoot()
        local items = doc:queryAll(".item") or {}
        doc:setViewport(1920, 1080)
        local vw, vh = doc:getViewport()

        local names = {}
        for i, el in ipairs(items) do
            names[i] = '"' .. tostring(el:getText() or "") .. '"'
        end

        local json = string.format(
            '{"count":%d,"items":[%s],"viewport":{"w":%d,"h":%d},"root_tag":"%s"}',
            #items,
            table.concat(names, ","),
            vw or 0,
            vh or 0,
            tostring(root and root:getTagName() or "")
        )
        write_text(path, json)
    end)

    -- @evidence LHtmlDocument:mousepressed
    -- @evidence lurek.html.preventDefault
    -- @evidence lurek.html.isDefaultPrevented
    -- @evidence lurek.html.stopPropagation
    it("exports HTML click event trace", function()
        local path = OUT .. "html_click_event_trace.txt"
        local doc = lurek.html.newDocument([[<body><button id="btn" style="width:120px;height:40px;">Click</button></body>]], { width = 320, height = 200 })
        doc:relayout()
        local btn = doc:getElementById("btn")
        local x, y = btn:getRect()

        local lines = {}
        doc:on("click", function(evt)
            evt.preventDefault()
            evt.stopPropagation()
            lines[#lines + 1] = "click prevented=" .. tostring(evt.isDefaultPrevented())
        end)

        doc:mousepressed(x + 2, y + 2, 1)
        write_text(path, table.concat(lines, "\n") .. "\n")
    end)

    -- @evidence LHtmlElement:setHtml
    -- @evidence LHtmlElement:setText
    -- @evidence LHtmlElement:setAttribute
    -- @evidence LHtmlElement:getAttribute
    -- @evidence LHtmlElement:addClass
    -- @evidence LHtmlElement:toggleClass
    -- @evidence LHtmlElement:query
    it("exports HTML mutation snapshot", function()
        local path = OUT .. "html_mutation_snapshot.txt"
        local doc = lurek.html.newDocument([[<body><div id="card" class="base"><span id="label">Old</span></div></body>]], { width = 480, height = 240 })
        local card = doc:getElementById("card")
        local label = doc:getElementById("label")

        card:setAttribute("data-state", "ready")
        card:addClass("active")
        card:toggleClass("highlight")
        label:setText("Updated")
        local label_text = label:getText()
        card:setHtml("<p id='inner'>Inner <b>markup</b></p>")

        local inner = card:query("#inner")
        local lines = {
            "card_state=" .. tostring(card:getAttribute("data-state")),
            "card_active=" .. tostring(card:hasClass("active")),
            "card_highlight=" .. tostring(card:hasClass("highlight")),
            "label_text=" .. tostring(label_text),
            "inner_text=" .. tostring(inner and inner:getText() or ""),
        }
        write_text(path, table.concat(lines, "\n") .. "\n")
    end)

    -- @evidence LHtmlDocument:addCss
    -- @evidence LHtmlDocument:clearCss
    -- @evidence LHtmlDocument:isDirty
    -- @evidence LHtmlDocument:update
    -- @evidence LHtmlDocument:query
    -- @evidence LHtmlDocument:off
    -- @evidence LHtmlDocument:mousereleased
    -- @evidence LHtmlDocument:mousemoved
    -- @evidence LHtmlDocument:wheelmoved
    -- @evidence LHtmlDocument:keypressed
    -- @evidence LHtmlDocument:textinput
    -- @evidence LHtmlDocument:draw
    -- @evidence LHtmlElement:getTagName
    -- @evidence LHtmlElement:getId
    -- @evidence LHtmlElement:setId
    -- @evidence LHtmlElement:getHtml
    -- @evidence LHtmlElement:removeAttribute
    -- @evidence LHtmlElement:removeClass
    -- @evidence LHtmlElement:setStyle
    -- @evidence LHtmlElement:focus
    -- @evidence LHtmlElement:blur
    -- @evidence LHtmlElement:getDocument
    -- @evidence LHtmlElement:queryAll
    -- @evidence LHtmlElement:appendHtml
    -- @evidence LHtmlElement:remove
    it("exports HTML lifecycle trace", function()
        local path = OUT .. "html_lifecycle_trace.txt"
        local doc = lurek.html.newDocument([[<body><section id="panel" class="card"><p class="row">One</p></section></body>]], { width = 480, height = 240 })
        doc:addCss(".card { border: 1px solid #fff; }")
        local dirty_after_add = doc:isDirty()
        doc:clearCss()
        doc:update(0.016)
        local panel = doc:query("#panel")
        local rows = panel:queryAll(".row")
        panel:setId("main-panel")
        panel:setStyle("background", "#112233")
        panel:setAttribute("data-mode", "active")
        panel:removeAttribute("data-mode")
        panel:addClass("selected")
        panel:removeClass("selected")
        panel:appendHtml("<span class='row'>Two</span>")
        local root = panel:getDocument():getRoot()
        panel:focus()
        panel:blur()
        local click_handle = doc:on("click", function() end)
        doc:off(click_handle)
        doc:mousemoved(10, 12)
        doc:mousereleased(10, 12, 1)
        doc:wheelmoved(0, 1)
        doc:keypressed("enter")
        doc:textinput("a")
        doc:draw(0, 0)

        local panel_html = panel:getHtml()
        local row_count = #(panel:queryAll(".row") or {})
        local panel_tag = panel:getTagName()
        local panel_id = panel:getId()
        panel:remove()
        local lines = {
            "dirty_after_add_css=" .. tostring(dirty_after_add),
            "panel_tag=" .. tostring(panel_tag),
            "panel_id=" .. tostring(panel_id),
            "row_count_before_remove=" .. tostring(row_count),
            "rows_initial=" .. tostring(#rows),
            "panel_html_len=" .. tostring(#(panel_html or "")),
            "root_tag=" .. tostring(root and root:getTagName() or ""),
        }
        write_text(path, table.concat(lines, "\n") .. "\n")
    end)
end)
test_summary()
