-- Evidence tests: html module
-- Output-only evidence from direct lurek.html API calls.

local function write_text(path, text)
    local f = io and io.open and io.open(path, "w") or nil
    if f then
        f:write(text)
        f:close()
    end
end

describe("evidence: html", function()
    before_each(function()
        ensure_evidence_dir("html")
    end)

    -- @evidence file
    it("exports markup snapshot", function()
        local dir = evidence_output_dir("html")
        local path = dir .. "document_markup.txt"
        local doc = lurek.html.newDocument([[<body><div id="header" class="bar">Title</div><div id="content"><p>Hello</p></div></body>]], { width = 800, height = 600 })
        write_text(path, doc:getHtml() or "")
    end)

    -- @evidence file
    it("exports element rect and class state", function()
        local dir = evidence_output_dir("html")
        local path = dir .. "element_state.json"
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

    -- @evidence file
    it("exports queryAll and viewport evidence", function()
        local dir = evidence_output_dir("html")
        local path = dir .. "query_viewport.json"
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
end)

test_summary()
