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
    it("exports queryAll and viewport evidence", function()
        local path = OUT .. "html_query_viewport_snapshot.json"
        local doc = lurek.html.newDocument([[<body><ul><li class="item">Apple</li><li class="item">Banana</li><li class="item">Cherry</li></ul></body>]], { width = 640, height = 480 })

        local items = doc:queryAll(".item") or {}
        doc:setViewport(1920, 1080)
        local vw, vh = doc:getViewport()

        local names = {}
        for i, el in ipairs(items) do
            names[i] = '"' .. tostring(el:getText() or "") .. '"'
        end

        local json = string.format('{"count":%d,"items":[%s],"viewport":{"w":%d,"h":%d}}', #items, table.concat(names, ","), vw or 0, vh or 0)
        write_text(path, json)
    end)

    -- @evidence LHtmlDocument:mousepressed
    -- @evidence LHtmlElement:getRect
    -- @evidence lurek.html.preventDefault
    -- @evidence lurek.html.isDefaultPrevented
    it("exports HTML click event trace", function()
        local path = OUT .. "html_click_event_trace.txt"
        local doc = lurek.html.newDocument([[<body><button id="btn" style="width:120px;height:40px;">Click</button></body>]], { width = 320, height = 200 })
        doc:relayout()
        local btn = doc:getElementById("btn")
        local x, y = btn:getRect()

        local lines = {}
        doc:on("click", function(evt)
            evt.preventDefault()
            lines[#lines + 1] = "click prevented=" .. tostring(evt.isDefaultPrevented())
        end)

        doc:mousepressed(x + 2, y + 2, 1)
        write_text(path, table.concat(lines, "\n") .. "\n")
        expect_evidence_created(path)
    end)

    -- @evidence LHtmlElement:setHtml
    -- @evidence LHtmlElement:setText
    -- @evidence LHtmlElement:setAttribute
    -- @evidence LHtmlElement:addClass
    -- @evidence LHtmlElement:toggleClass
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

        local inner = doc:getElementById("inner")
        local lines = {
            "card_state=" .. tostring(card:getAttribute("data-state")),
            "card_active=" .. tostring(card:hasClass("active")),
            "card_highlight=" .. tostring(card:hasClass("highlight")),
            "label_text=" .. tostring(label_text),
            "inner_text=" .. tostring(inner and inner:getText() or ""),
        }
        write_text(path, table.concat(lines, "\n") .. "\n")
        expect_evidence_created(path)
    end)
end)
test_summary()
