-- Canonical evidence file for lurek.graph / flownet visual artifacts.

local OUT = evidence_output_dir("flownet")

local FONT = {
    [" "] = { "000", "000", "000", "000", "000", "000", "000" },
    ["-"] = { "00000", "00000", "00000", "11110", "00000", "00000", "00000" },
    [":"] = { "000", "010", "000", "000", "010", "000", "000" },
    ["/"] = { "00001", "00010", "00010", "00100", "01000", "01000", "10000" },
    ["0"] = { "01110", "10001", "10011", "10101", "11001", "10001", "01110" },
    ["1"] = { "00100", "01100", "00100", "00100", "00100", "00100", "01110" },
    ["2"] = { "01110", "10001", "00001", "00010", "00100", "01000", "11111" },
    ["3"] = { "11110", "00001", "00001", "01110", "00001", "00001", "11110" },
    ["4"] = { "00010", "00110", "01010", "10010", "11111", "00010", "00010" },
    ["5"] = { "11111", "10000", "10000", "11110", "00001", "00001", "11110" },
    ["6"] = { "01110", "10000", "10000", "11110", "10001", "10001", "01110" },
    ["7"] = { "11111", "00001", "00010", "00100", "01000", "01000", "01000" },
    ["8"] = { "01110", "10001", "10001", "01110", "10001", "10001", "01110" },
    ["9"] = { "01110", "10001", "10001", "01111", "00001", "00001", "01110" },
    A = { "01110", "10001", "10001", "11111", "10001", "10001", "10001" },
    B = { "11110", "10001", "10001", "11110", "10001", "10001", "11110" },
    C = { "01111", "10000", "10000", "10000", "10000", "10000", "01111" },
    D = { "11110", "10001", "10001", "10001", "10001", "10001", "11110" },
    E = { "11111", "10000", "10000", "11110", "10000", "10000", "11111" },
    F = { "11111", "10000", "10000", "11110", "10000", "10000", "10000" },
    G = { "01111", "10000", "10000", "10011", "10001", "10001", "01111" },
    H = { "10001", "10001", "10001", "11111", "10001", "10001", "10001" },
    I = { "11111", "00100", "00100", "00100", "00100", "00100", "11111" },
    J = { "00111", "00010", "00010", "00010", "00010", "10010", "01100" },
    K = { "10001", "10010", "10100", "11000", "10100", "10010", "10001" },
    L = { "10000", "10000", "10000", "10000", "10000", "10000", "11111" },
    M = { "10001", "11011", "10101", "10101", "10001", "10001", "10001" },
    N = { "10001", "11001", "10101", "10011", "10001", "10001", "10001" },
    O = { "01110", "10001", "10001", "10001", "10001", "10001", "01110" },
    P = { "11110", "10001", "10001", "11110", "10000", "10000", "10000" },
    Q = { "01110", "10001", "10001", "10001", "10101", "10010", "01101" },
    R = { "11110", "10001", "10001", "11110", "10100", "10010", "10001" },
    S = { "01111", "10000", "10000", "01110", "00001", "00001", "11110" },
    T = { "11111", "00100", "00100", "00100", "00100", "00100", "00100" },
    U = { "10001", "10001", "10001", "10001", "10001", "10001", "01110" },
    V = { "10001", "10001", "10001", "10001", "10001", "01010", "00100" },
    W = { "10001", "10001", "10001", "10101", "10101", "10101", "01010" },
    X = { "10001", "10001", "01010", "00100", "01010", "10001", "10001" },
    Y = { "10001", "10001", "01010", "00100", "00100", "00100", "00100" },
    Z = { "11111", "00001", "00010", "00100", "01000", "10000", "11111" },
}

local function save_png(img, path)
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
end

local function draw_text(img, text, x, y, scale, r, g, b)
    text = string.upper(tostring(text or ""))
    scale = scale or 1
    local cursor = x
    for i = 1, #text do
        local ch = string.sub(text, i, i)
        local glyph = FONT[ch] or FONT[" "]
        for gy = 1, #glyph do
            local row = glyph[gy]
            for gx = 1, #row do
                if string.sub(row, gx, gx) == "1" then
                    img:drawRect(cursor + (gx - 1) * scale, y + (gy - 1) * scale, scale, scale, r, g, b, 255)
                end
            end
        end
        cursor = cursor + (#glyph[1] + 1) * scale
    end
end

local function text_width(text, scale)
    return #tostring(text or "") * 6 * (scale or 1)
end

local function outline(img, x, y, w, h, r, g, b)
    img:drawRect(x, y, w, 2, r, g, b, 255)
    img:drawRect(x, y + h - 2, w, 2, r, g, b, 255)
    img:drawRect(x, y, 2, h, r, g, b, 255)
    img:drawRect(x + w - 2, y, 2, h, r, g, b, 255)
end

local function draw_arrow(img, x1, y1, x2, y2, r, g, b, thick)
    thick = thick or 1
    for i = 0, thick - 1 do
        img:drawLine(x1, y1 + i, x2, y2 + i, r, g, b, 255)
    end
    local dx, dy = x2 - x1, y2 - y1
    local len = math.sqrt(dx * dx + dy * dy)
    if len > 0 then
        dx, dy = dx / len, dy / len
        local px, py = -dy, dx
        img:drawLine(x2, y2, math.floor(x2 - dx * 12 + px * 6), math.floor(y2 - dy * 12 + py * 6), r, g, b, 255)
        img:drawLine(x2, y2, math.floor(x2 - dx * 12 - px * 6), math.floor(y2 - dy * 12 - py * 6), r, g, b, 255)
    end
end

local function new_canvas(title)
    local img = lurek.image.newImageData(820, 460)
    img:fill(16, 18, 24, 255)
    img:drawRect(18, 18, 784, 42, 28, 34, 46, 255)
    draw_text(img, title, 34, 32, 2, 232, 238, 245)
    img:drawRect(18, 78, 784, 354, 22, 25, 34, 255)
    outline(img, 18, 78, 784, 354, 74, 84, 104)
    return img
end

local function draw_node(img, node, x, y, color, lines)
    local w, h = 112, 58
    img:drawRect(x - w / 2, y - h / 2, w, h, color[1], color[2], color[3], 255)
    outline(img, x - w / 2, y - h / 2, w, h, 226, 234, 242)
    local label = node and node:getType() or "NODE"
    draw_text(img, label, x - math.floor(text_width(label, 1) / 2), y - 21, 1, 250, 252, 255)
    for i, line in ipairs(lines or {}) do
        draw_text(img, line, x - math.floor(text_width(line, 1) / 2), y - 3 + (i - 1) * 12, 1, 238, 242, 248)
    end
end

local function draw_metric_bar(img, x, y, label, value, max_value, color)
    max_value = math.max(1, max_value or 1)
    local fill = math.floor(160 * math.max(0, math.min(1, value / max_value)))
    draw_text(img, label, x, y, 1, 176, 188, 204)
    img:drawRect(x, y + 14, 164, 12, 42, 48, 62, 255)
    img:drawRect(x + 2, y + 16, fill, 8, color[1], color[2], color[3], 255)
    outline(img, x, y + 14, 164, 12, 88, 98, 116)
end

local function path_node_types(path)
    local out = {}
    if path and path.nodes then
        for _, node in ipairs(path.nodes) do
            out[#out + 1] = node:getType()
        end
    elseif path then
        for _, node in ipairs(path) do
            out[#out + 1] = node:getType()
        end
    end
    return table.concat(out, " ")
end

-- @describe evidence: flownet
describe("evidence: flownet", function()
    before_each(function()
        ensure_evidence_dir("flownet")
    end)

    -- Does: Builds a graph with batch node/edge creation, then draws components, coloring, cycle status, and MST-selected edges.
    -- Shows: Structural diagnostics from LGraph:getComponents, LGraph:colorGraph, LGraph:hasCycle, LGraph:isBipartite, and LGraph:mst as one topology report.
    -- Artifact: tests/artifacts/current/flownet/flownet_topology_algorithms.png
    -- Why: Flownet owns graph analysis as well as simulation, so reviewers need a visual proof that topology queries expose useful network structure.
    it("PNG: topology algorithms and diagnostics", function()
        local g = lurek.graph.newGraph()
        local ids = g:batchAddNodes(6, { node_type = "router", capacity = 4 })
        local edge_ids = g:batchAddEdges({
            { ids[1], ids[2], "road" },
            { ids[2], ids[3], "road" },
            { ids[1], ids[3], "road" },
            { ids[4], ids[5], "pipe" },
            { ids[5], ids[6], "pipe" },
            { ids[6], ids[4], "pipe" },
        })
        local colors = g:colorGraph()
        local mst = {}
        for _, eid in ipairs(g:mst()) do
            mst[eid] = true
        end
        local positions = {
            [ids[1]] = { 160, 170 }, [ids[2]] = { 260, 120 }, [ids[3]] = { 320, 230 },
            [ids[4]] = { 520, 160 }, [ids[5]] = { 650, 160 }, [ids[6]] = { 585, 270 },
        }
        local img = new_canvas("FLOWNET TOPOLOGY ALGORITHMS")
        local edge_specs = {
            { ids[1], ids[2], edge_ids[1] }, { ids[2], ids[3], edge_ids[2] }, { ids[1], ids[3], edge_ids[3] },
            { ids[4], ids[5], edge_ids[4] }, { ids[5], ids[6], edge_ids[5] }, { ids[6], ids[4], edge_ids[6] },
        }
        for _, e in ipairs(edge_specs) do
            local a, b = positions[e[1]], positions[e[2]]
            local c = mst[e[3]] and { 255, 204, 94 } or { 92, 106, 132 }
            draw_arrow(img, a[1], a[2], b[1], b[2], c[1], c[2], c[3], mst[e[3]] and 3 or 1)
        end
        local palette = {
            [0] = { 76, 140, 214 }, [1] = { 88, 174, 126 }, [2] = { 206, 126, 82 }, [3] = { 172, 112, 210 },
        }
        for _, id in ipairs(ids) do
            local p = positions[id]
            local color = palette[colors[id] or 0] or palette[0]
            img:drawCircle(p[1], p[2], 28, color[1], color[2], color[3], 255)
            draw_text(img, tostring(id), p[1] - 5, p[2] - 7, 2, 250, 252, 255)
        end
        draw_metric_bar(img, 52, 336, "COMP " .. tostring(#g:getComponents()), #g:getComponents(), 3, { 100, 210, 150 })
        draw_metric_bar(img, 248, 336, "CYCLE " .. tostring(g:hasCycle() and 1 or 0), g:hasCycle() and 1 or 0, 1, { 238, 122, 96 })
        draw_metric_bar(img, 444, 336, "BIPART " .. tostring(g:isBipartite() and 1 or 0), g:isBipartite() and 1 or 0, 1, { 120, 170, 240 })
        draw_metric_bar(img, 640, 336, "MST " .. tostring(#g:mst()), #g:mst(), 5, { 255, 204, 94 })
        save_png(img, OUT .. "flownet_topology_algorithms.png")
    end)

    -- Does: Builds two competing routes, applies edge weights and item-type filters, then draws the item-specific path result.
    -- Shows: LGraph:findPathForItem chooses the allowed ore route while the blocked branch remains visible for comparison.
    -- Artifact: tests/artifacts/current/flownet/flownet_route_constraints.png
    -- Why: Routing in flownet is meaningful only when pathfinding respects edge constraints used by actual item movement.
    it("PNG: route constraints and allowed item path", function()
        local g = lurek.graph.newGraph()
        local source = g:addNode("mine", 8)
        local fast = g:addNode("fast", 4)
        local slow = g:addNode("ore", 4)
        local sink = g:addNode("depot", 8)
        local blocked = g:addEdge(source, fast, "belt")
        blocked:addAllowedType("parts")
        blocked:setWeight(1)
        local blocked2 = g:addEdge(fast, sink, "belt")
        blocked2:addAllowedType("parts")
        blocked2:setWeight(1)
        local ore_a = g:addEdge(source, slow, "ore")
        ore_a:addAllowedType("ore")
        ore_a:setWeight(2)
        local ore_b = g:addEdge(slow, sink, "ore")
        ore_b:addAllowedType("ore")
        ore_b:setWeight(2)
        local item = g:createItem("ore")
        g:addItem(item, source)
        local path = g:findPathForItem(item, source, sink)
        local route = path_node_types(path)

        local img = new_canvas("FLOWNET ROUTE CONSTRAINTS")
        local p = { mine = { 120, 230 }, fast = { 330, 150 }, ore = { 330, 300 }, depot = { 580, 230 } }
        draw_arrow(img, p.mine[1] + 58, p.mine[2] - 10, p.fast[1] - 58, p.fast[2], 150, 70, 82, 2)
        draw_arrow(img, p.fast[1] + 58, p.fast[2], p.depot[1] - 58, p.depot[2] - 12, 150, 70, 82, 2)
        draw_arrow(img, p.mine[1] + 58, p.mine[2] + 12, p.ore[1] - 58, p.ore[2], 255, 204, 94, 3)
        draw_arrow(img, p.ore[1] + 58, p.ore[2], p.depot[1] - 58, p.depot[2] + 12, 255, 204, 94, 3)
        draw_node(img, source, p.mine[1], p.mine[2], { 78, 142, 205 }, { "ITEM ORE" })
        draw_node(img, fast, p.fast[1], p.fast[2], { 145, 72, 90 }, { "ALLOW PARTS" })
        draw_node(img, slow, p.ore[1], p.ore[2], { 80, 156, 118 }, { "ALLOW ORE" })
        draw_node(img, sink, p.depot[1], p.depot[2], { 190, 138, 76 }, { "TARGET" })
        draw_text(img, "PATH " .. route, 72, 382, 1, 236, 242, 248)
        draw_text(img, "COST " .. tostring(path and path.cost or 0), 560, 382, 1, 236, 242, 248)
        save_png(img, OUT .. "flownet_route_constraints.png")
    end)

    -- Does: Sends an item onto a configured edge, advances simulation time, and draws transit progress plus reserved capacity.
    -- Shows: LGraph:sendItem, LGraph:update, LGraphEdge:getItemsInTransit, LGraphEdge:getAvailableCapacity, and LGraphItem:getPosition describe the same in-flight item.
    -- Artifact: tests/artifacts/current/flownet/flownet_transit_capacity.png
    -- Why: This visualizes the temporal logistics behavior that distinguishes flownet from a static graph container.
    it("PNG: transit progress and capacity", function()
        local g = lurek.graph.newGraph()
        local loader = g:addNode("loader", 3)
        local dock = g:addNode("dock", 3)
        local edge = g:addEdge(loader, dock, "belt")
        edge:setCapacity(3)
        edge:reserveCapacity("planner", 1)
        edge:setTravelTime(4.0)
        local item = g:createItem("crate")
        g:addItem(item, loader)
        g:sendItem(item, edge)
        g:update(1.5)
        local pos, progress = item:getPosition()
        local t = tonumber(progress) or 0

        local img = new_canvas("FLOWNET TRANSIT CAPACITY")
        draw_arrow(img, 250, 230, 560, 230, 255, 204, 94, 4)
        draw_node(img, loader, 150, 230, { 78, 142, 205 }, { "ITEMS " .. tostring(loader:getItemCount()) })
        draw_node(img, dock, 650, 230, { 80, 156, 118 }, { "ITEMS " .. tostring(dock:getItemCount()) })
        local px = math.floor(250 + (560 - 250) * math.max(0, math.min(1, t)))
        img:drawCircle(px, 230, 14, 240, 106, 86, 255)
        outline(img, px - 14, 216, 28, 28, 250, 240, 220)
        draw_metric_bar(img, 82, 338, "TRANSIT " .. tostring(#edge:getItemsInTransit()), #edge:getItemsInTransit(), 3, { 255, 204, 94 })
        draw_metric_bar(img, 288, 338, "RESERVE " .. tostring(edge:getReservedCapacity()), edge:getReservedCapacity(), 3, { 176, 128, 220 })
        draw_metric_bar(img, 494, 338, "FREE " .. tostring(edge:getAvailableCapacity()), edge:getAvailableCapacity(), 3, { 90, 190, 140 })
        draw_text(img, "PROGRESS " .. tostring(math.floor(t * 100)) .. "/100", 610, 348, 1, 236, 242, 248)
        draw_text(img, "POSITION " .. (pos and pos:type() or "NONE"), 300, 292, 1, 190, 202, 218)
        save_png(img, OUT .. "flownet_transit_capacity.png")
    end)

    -- Does: Drives a full destination with overflow policy "queue" so an arriving item enters the node queue.
    -- Shows: Queue capacity, queue size, node fullness, and itemQueued event state after LGraph:update resolves transit arrival.
    -- Artifact: tests/artifacts/current/flownet/flownet_queue_overflow.png
    -- Why: This proves congestion behavior is visible through flownet node policy instead of disappearing as hidden bookkeeping.
    it("PNG: queue overflow policy", function()
        local g = lurek.graph.newGraph()
        local source = g:addNode("source", 3)
        local buffer = g:addNode("buffer", 1)
        buffer:setQueueEnabled(true)
        buffer:setQueueCapacity(3)
        buffer:setOverflowPolicy("queue")
        buffer:setProcessTime(4.0)
        g:addItem(g:createItem("stored"), buffer)
        local edge = g:addEdge(source, buffer, "belt")
        edge:setTravelTime(1.0)
        local queued_events = 0
        g:on("itemQueued", function()
            queued_events = queued_events + 1
        end)
        local item = g:createItem("crate")
        g:addItem(item, source)
        g:sendItem(item, edge)
        g:update(1.2)

        local img = new_canvas("FLOWNET QUEUE OVERFLOW")
        draw_arrow(img, 250, 230, 560, 230, 255, 204, 94, 3)
        draw_node(img, source, 150, 230, { 78, 142, 205 }, { "ITEMS " .. tostring(source:getItemCount()) })
        draw_node(img, buffer, 650, 230, { 180, 116, 78 }, {
            "FULL " .. tostring(buffer:isFull() and 1 or 0),
            "QUEUE " .. tostring(buffer:getQueueSize()),
        })
        for i = 1, buffer:getQueueCapacity() do
            local x = 510 + i * 34
            img:drawRect(x, 316, 24, 44, 44, 50, 64, 255)
            if i <= buffer:getQueueSize() then
                img:drawRect(x + 4, 320, 16, 36, 235, 142, 82, 255)
            end
            outline(img, x, 316, 24, 44, 112, 124, 146)
        end
        draw_metric_bar(img, 74, 340, "EVENTS " .. tostring(queued_events), queued_events, 3, { 235, 142, 82 })
        draw_metric_bar(img, 276, 340, "CAP " .. tostring(buffer:getCapacity()), buffer:getCapacity(), 3, { 100, 170, 230 })
        draw_text(img, "POLICY " .. tostring(buffer:getOverflowPolicy()), 522, 382, 1, 236, 242, 248)
        save_png(img, OUT .. "flownet_queue_overflow.png")
    end)

    -- Does: Processes supply-demand dispatch and a converter node, then draws fulfillment and item conversion results.
    -- Shows: LGraph:processDemand emits demand fulfillment, then LGraph:update converts ore into bars on a processing node.
    -- Artifact: tests/artifacts/current/flownet/flownet_supply_conversion.png
    -- Why: This demonstrates the factory-network behavior from the spec: resources are requested, moved, transformed, and counted in one graph model.
    it("PNG: supply demand and conversion", function()
        local g = lurek.graph.newGraph()
        local mine = g:addNode("mine", 8)
        local smelter = g:addNode("smelter", 8)
        local depot = g:addNode("depot", 8)
        mine:addSupply("ore", 2)
        depot:addDemand("ore", 2, 10)
        local e1 = g:addEdge(mine, smelter, "ore")
        local e2 = g:addEdge(smelter, depot, "ore")
        e1:setTravelTime(3.0)
        e2:setTravelTime(3.0)
        smelter:setConversion("ore", "bar", 1, 1)
        local fulfilled = 0
        local converted = 0
        g:on("demandFulfilled", function(_, _, _, count)
            fulfilled = fulfilled + count
        end)
        g:on("itemConvert", function(_, consumed, produced)
            converted = converted + #produced - #consumed + #produced
        end)
        g:processDemand()
        local manual = g:createItem("ore")
        g:addItem(manual, smelter)
        g:update(0.0)
        local stats = g:getStats()

        local img = new_canvas("FLOWNET SUPPLY AND CONVERSION")
        draw_arrow(img, 240, 220, 450, 220, 255, 204, 94, 3)
        draw_arrow(img, 520, 220, 675, 220, 104, 184, 236, 2)
        draw_node(img, mine, 140, 220, { 84, 148, 196 }, { "SUPPLY 2" })
        draw_node(img, smelter, 480, 220, { 190, 128, 74 }, { "ORE TO BAR", "ITEMS " .. tostring(smelter:getItemCount()) })
        draw_node(img, depot, 720, 220, { 84, 156, 118 }, { "DEMAND 2" })
        draw_metric_bar(img, 70, 342, "FULFILLED " .. tostring(fulfilled), fulfilled, 3, { 255, 204, 94 })
        draw_metric_bar(img, 278, 342, "CONVERT " .. tostring(converted), converted, 3, { 235, 142, 82 })
        draw_metric_bar(img, 486, 342, "TRANSIT " .. tostring(stats.itemsInTransit), stats.itemsInTransit, 4, { 104, 184, 236 })
        draw_metric_bar(img, 638, 342, "ITEMS " .. tostring(stats.items), stats.items, 5, { 116, 198, 146 })
        save_png(img, OUT .. "flownet_supply_conversion.png")
    end)
end)

test_summary()
