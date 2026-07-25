-- Canonical evidence file for lurek.layout visual artifacts.
-- @covers lurek.filesystem.write
-- @covers lurek.image.newImageData
-- @covers lurek.image.savePNG
-- @covers lurek.layout.centerInArea
-- @covers lurek.layout.circular
-- @covers lurek.layout.dag
-- @covers lurek.layout.force
-- @covers lurek.layout.grid
-- @covers lurek.layout.radial
-- @covers lurek.layout.snapToGrid
-- @covers lurek.layout.spiral
-- @covers lurek.layout.stress
-- @covers lurek.layout.tree


local OUT = evidence_output_dir("layout")

local FONT = {
    [" "] = { "000", "000", "000", "000", "000", "000", "000" },
    ["-"] = { "00000", "00000", "00000", "11110", "00000", "00000", "00000" },
    [":"] = { "000", "010", "000", "000", "010", "000", "000" },
    ["."] = { "000", "000", "000", "000", "000", "010", "000" },
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

local function save_text(path, text)
    if write_file then
        write_file(path, text)
    else
        lurek.filesystem.write(path, text)
    end
    expect_evidence_created(path)
end

local function overlaps(a, b, padding)
    padding = padding or 0
    return a.x < b.x + b.width + padding
        and a.x + a.width + padding > b.x
        and a.y < b.y + b.height + padding
        and a.y + a.height + padding > b.y
end

local function overlap_count(result, padding)
    local count = 0
    for i = 1, #(result.nodes or {}) do
        for j = i + 1, #(result.nodes or {}) do
            if overlaps(result.nodes[i], result.nodes[j], padding or 0) then
                count = count + 1
            end
        end
    end
    return count
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

local function by_id(result)
    local out = {}
    for _, node in ipairs(result.nodes or {}) do
        out[node.id] = node
    end
    return out
end

local function transform(result, x, y, w, h)
    local min_x, min_y, max_x, max_y = 1e9, 1e9, -1e9, -1e9
    for _, n in ipairs(result.nodes or {}) do
        min_x = math.min(min_x, n.x or 0)
        min_y = math.min(min_y, n.y or 0)
        max_x = math.max(max_x, (n.x or 0) + (n.width or 40))
        max_y = math.max(max_y, (n.y or 0) + (n.height or 24))
    end
    local bw = math.max(1, max_x - min_x)
    local bh = math.max(1, max_y - min_y)
    local scale = math.min(w / bw, h / bh)
    local extra_x = (w - bw * scale) / 2
    local extra_y = (h - bh * scale) / 2
    return function(px, py)
        return math.floor(x + extra_x + (px - min_x) * scale), math.floor(y + extra_y + (py - min_y) * scale)
    end, scale
end

local function draw_arrow(img, x1, y1, x2, y2, r, g, b)
    img:drawLine(x1, y1, x2, y2, r, g, b, 255)
    local dx, dy = x2 - x1, y2 - y1
    local len = math.sqrt(dx * dx + dy * dy)
    if len > 0 then
        dx, dy = dx / len, dy / len
        local px, py = -dy, dx
        img:drawLine(x2, y2, math.floor(x2 - dx * 10 + px * 5), math.floor(y2 - dy * 10 + py * 5), r, g, b, 255)
        img:drawLine(x2, y2, math.floor(x2 - dx * 10 - px * 5), math.floor(y2 - dy * 10 - py * 5), r, g, b, 255)
    end
end

local function render_graph(result, edges, title, path, palette)
    local img = lurek.image.newImageData(760, 440)
    img:fill(16, 18, 24, 255)
    img:drawRect(18, 18, 724, 42, 28, 34, 46, 255)
    draw_text(img, title, 34, 32, 2, 232, 238, 245)
    img:drawRect(18, 76, 724, 344, 22, 25, 34, 255)
    outline(img, 18, 76, 724, 344, 76, 86, 104)

    local pos = by_id(result)
    local map, scale = transform(result, 58, 108, 644, 260)
    local centers = {}
    for _, n in ipairs(result.nodes or {}) do
        local x, y = map(n.x, n.y)
        local w = math.max(42, math.floor((n.width or 60) * scale))
        local h = math.max(28, math.floor((n.height or 30) * scale))
        centers[n.id] = { x + math.floor(w / 2), y + math.floor(h / 2) }
    end

    for _, e in ipairs(edges or {}) do
        local a = centers[e.from]
        local b = centers[e.to]
        if a and b then
            draw_arrow(img, a[1], a[2], b[1], b[2], 114, 132, 158)
        end
    end

    for _, n in ipairs(result.nodes or {}) do
        local x, y = map(n.x, n.y)
        local w = math.max(42, math.floor((n.width or 60) * scale))
        local h = math.max(28, math.floor((n.height or 30) * scale))
        local color = palette and palette[n.id] or { 72, 124, 186 }
        img:drawRect(x, y, w, h, color[1], color[2], color[3], 255)
        outline(img, x, y, w, h, 218, 226, 236)
        local label = n.label or tostring(n.id)
        local ts = text_width(label, 1) <= w - 8 and 1 or 1
        draw_text(img, label, x + math.max(4, math.floor((w - text_width(label, ts)) / 2)), y + math.floor((h - 7 * ts) / 2), ts, 245, 248, 252)
    end

    img:drawRect(34, 386, math.max(1, math.floor((result.width or 1) % 680)), 8, 255, 209, 102, 255)
    draw_text(img, "RESULT NODES " .. tostring(#(result.nodes or {})), 34, 402, 1, 180, 190, 205)
    save_png(img, path)
end

-- @describe evidence: layout
describe("evidence: layout", function()
    before_each(function()
        ensure_evidence_dir("layout")
    end)

    -- Does: Runs lurek.layout.tree on a rooted hierarchy and rasterizes the returned node coordinates.
    -- Shows: The root is centered above recursively placed child spans, with deterministic sibling order and spacing.
    -- Artifact: tests/artifacts/current/layout/layout_tree_hierarchy.png
    -- Why: This proves the tree algorithm turns parent-child data into readable 2D hierarchy coordinates instead of requiring hand placement.
    it("PNG: tree hierarchy coordinates", function()
        local nodes = {
            { id = 1, width = 78, height = 34, label = "ROOT" },
            { id = 2, width = 72, height = 30, label = "HUD" },
            { id = 3, width = 78, height = 30, label = "WORLD" },
            { id = 4, width = 72, height = 30, label = "TOOLS" },
            { id = 5, width = 70, height = 28, label = "MAP" },
            { id = 6, width = 70, height = 28, label = "INV" },
            { id = 7, width = 70, height = 28, label = "LOG" },
        }
        local children = { [1] = { 2, 3, 4 }, [2] = { 5, 6 }, [4] = { 7 } }
        local edges = {
            { from = 1, to = 2 }, { from = 1, to = 3 }, { from = 1, to = 4 },
            { from = 2, to = 5 }, { from = 2, to = 6 }, { from = 4, to = 7 },
        }
        local result = lurek.layout.tree(nodes, children, 1, { hSpacing = 58, vSpacing = 92, margin = 20 })
        render_graph(result, edges, "TREE ROOTED HIERARCHY", OUT .. "layout_tree_hierarchy.png", {
            [1] = { 94, 132, 206 }, [2] = { 65, 150, 136 }, [3] = { 180, 114, 82 }, [4] = { 145, 104, 190 },
        })
    end)

    -- Does: Runs lurek.layout.dag on a dependency pipeline and rasterizes the layered layout.
    -- Shows: Source nodes appear in earlier ranks, dependent work moves down the diagram, and parallel nodes share a layer.
    -- Artifact: tests/artifacts/current/layout/layout_dag_pipeline.png
    -- Why: This demonstrates the Sugiyama-style DAG placement promised by the spec, including rank construction and edge direction.
    it("PNG: dag layered pipeline", function()
        local nodes = {
            { id = 1, width = 74, height = 30, label = "INPUT" },
            { id = 2, width = 70, height = 30, label = "BUILD" },
            { id = 3, width = 70, height = 30, label = "LINT" },
            { id = 4, width = 70, height = 30, label = "UNIT" },
            { id = 5, width = 70, height = 30, label = "PACK" },
            { id = 6, width = 76, height = 30, label = "SHIP" },
        }
        local edges = {
            { from = 1, to = 2 }, { from = 1, to = 3 }, { from = 2, to = 4 },
            { from = 3, to = 4 }, { from = 4, to = 5 }, { from = 5, to = 6 },
        }
        local result = lurek.layout.dag(nodes, edges, { hSpacing = 86, vSpacing = 86, margin = 24 })
        render_graph(result, edges, "DAG LAYERED PIPELINE", OUT .. "layout_dag_pipeline.png", {
            [1] = { 76, 134, 198 }, [2] = { 90, 150, 120 }, [3] = { 90, 150, 120 }, [4] = { 190, 136, 74 },
            [5] = { 150, 116, 196 }, [6] = { 206, 94, 104 },
        })
    end)

    -- Does: Runs lurek.layout.force on a cyclic clustered graph and rasterizes the settled positions.
    -- Shows: Connected nodes pull into groups while repulsion keeps every node readable inside the configured area.
    -- Artifact: tests/artifacts/current/layout/layout_force_cluster.png
    -- Why: This makes the force-directed algorithm inspectable as an organic graph layout, distinct from tree and DAG ranking.
    it("PNG: force directed cluster", function()
        local nodes = {
            { id = 1, width = 58, height = 28, label = "CORE" }, { id = 2, width = 58, height = 28, label = "AI" },
            { id = 3, width = 58, height = 28, label = "SIM" }, { id = 4, width = 58, height = 28, label = "SAVE" },
            { id = 5, width = 58, height = 28, label = "UI" }, { id = 6, width = 58, height = 28, label = "LOG" },
            { id = 7, width = 58, height = 28, label = "MAP" }, { id = 8, width = 58, height = 28, label = "PATH" },
        }
        local edges = {
            { from = 1, to = 2, weight = 1.5 }, { from = 1, to = 3, weight = 1.5 }, { from = 3, to = 4, weight = 1.0 },
            { from = 2, to = 5, weight = 0.7 }, { from = 5, to = 6, weight = 0.6 }, { from = 7, to = 8, weight = 1.4 },
            { from = 3, to = 8, weight = 0.9 }, { from = 1, to = 7, weight = 0.8 }, { from = 2, to = 3, weight = 0.7 },
        }
        local result = lurek.layout.force(nodes, edges, {
            iterations = 70, repulsion = 9000, attraction = 0.018, cooling = 0.92, areaWidth = 620, areaHeight = 310,
        })
        render_graph(result, edges, "FORCE CLUSTER SETTLE", OUT .. "layout_force_cluster.png", {
            [1] = { 235, 148, 82 }, [2] = { 94, 144, 214 }, [3] = { 94, 176, 126 }, [4] = { 176, 124, 210 },
            [5] = { 210, 100, 130 }, [7] = { 70, 150, 160 }, [8] = { 70, 150, 160 },
        })
    end)

    -- Does: Runs lurek.layout.snapToGrid on off-grid coordinates and draws before/after positions against a visible grid.
    -- Shows: Raw points are irregular, while snapped node boxes land on exact grid intersections without losing labels or sizes.
    -- Artifact: tests/artifacts/current/layout/layout_snap_to_grid.png
    -- Why: This proves the finishing pass regularizes arbitrary coordinates for presentation and authoring workflows.
    it("PNG: snap to grid before and after", function()
        local raw = {
            nodes = {
                { id = 1, x = 37, y = 42, width = 52, height = 26, label = "A" },
                { id = 2, x = 118, y = 79, width = 52, height = 26, label = "B" },
                { id = 3, x = 209, y = 133, width = 52, height = 26, label = "C" },
                { id = 4, x = 235, y = 55, width = 52, height = 26, label = "D" },
            },
            width = 360,
            height = 210,
        }
        local snapped = lurek.layout.snapToGrid(raw, 32)
        local img = lurek.image.newImageData(760, 440)
        img:fill(16, 18, 24, 255)
        draw_text(img, "SNAP TO GRID", 34, 32, 2, 232, 238, 245)
        for panel = 0, 1 do
            local ox = 38 + panel * 360
            local oy = 92
            img:drawRect(ox, oy, 300, 260, 22, 25, 34, 255)
            for gx = 0, 9 do img:drawLine(ox + gx * 32, oy, ox + gx * 32, oy + 256, 54, 60, 74, 255) end
            for gy = 0, 8 do img:drawLine(ox, oy + gy * 32, ox + 288, oy + gy * 32, 54, 60, 74, 255) end
            outline(img, ox, oy, 300, 260, 88, 98, 118)
            draw_text(img, panel == 0 and "RAW" or "SNAPPED", ox, oy + 276, 1, 180, 190, 205)
        end
        for _, n in ipairs(raw.nodes) do
            img:drawCircle(38 + n.x, 92 + n.y, 5, 235, 112, 92, 255)
            draw_text(img, n.label, 38 + n.x + 8, 92 + n.y - 4, 1, 235, 112, 92)
        end
        for _, n in ipairs(snapped.nodes) do
            img:drawRect(398 + n.x, 92 + n.y, n.width, n.height, 80, 158, 210, 255)
            outline(img, 398 + n.x, 92 + n.y, n.width, n.height, 224, 232, 240)
            draw_text(img, n.label, 398 + n.x + 20, 92 + n.y + 9, 1, 245, 248, 252)
        end
        save_png(img, OUT .. "layout_snap_to_grid.png")
    end)

    -- Does: Runs lurek.layout.centerInArea on an existing layout result and draws the old and recentered bounds.
    -- Shows: The same node cluster is translated into the target rectangle center while preserving relative spacing.
    -- Artifact: tests/artifacts/current/layout/layout_center_in_area.png
    -- Why: This proves the post-layout centering pass can prepare arbitrary algorithm output for a fixed viewport.
    it("PNG: center in area viewport", function()
        local result = lurek.layout.dag({
            { id = 1, width = 70, height = 30, label = "PLAN" },
            { id = 2, width = 70, height = 30, label = "MAKE" },
            { id = 3, width = 70, height = 30, label = "TEST" },
            { id = 4, width = 70, height = 30, label = "SHIP" },
        }, {
            { from = 1, to = 2 }, { from = 2, to = 3 }, { from = 3, to = 4 },
        }, { hSpacing = 56, vSpacing = 68, margin = 6 })
        local centered = lurek.layout.centerInArea(result, 620, 300)
        render_graph(centered, {
            { from = 1, to = 2 }, { from = 2, to = 3 }, { from = 3, to = 4 },
        }, "CENTERED VIEWPORT 620X300", OUT .. "layout_center_in_area.png", {
            [1] = { 80, 150, 200 }, [2] = { 94, 166, 124 }, [3] = { 205, 145, 72 }, [4] = { 180, 108, 185 },
        })
    end)

    -- Does: Runs lurek.layout.circular, radial, grid, spiral, and stress on larger graph-shaped inputs and rasterizes each returned coordinate set.
    -- Shows: The PNG artifacts should make each newly added auto-layout method visually reviewable: ring ordering, hop-distance rings, uniform rows, expanding spiral placement, and stress-preserved topology.
    -- Artifact: tests/artifacts/current/layout/layout_circular_cycle_network.png, layout_radial_service_topology.png, layout_grid_inventory_matrix.png, layout_spiral_large_unordered.png, layout_stress_distance_network.png
    -- Why: These new algorithms are meant to auto-organize arbitrary graphs, so evidence needs to prove they produce distinct readable structures on non-trivial node sets.
    it("PNG: additional auto layout gallery", function()
        local circular_nodes = {
            { id = 1, width = 56, height = 28, label = "AUTH" },
            { id = 2, width = 56, height = 28, label = "API" },
            { id = 3, width = 56, height = 28, label = "UI" },
            { id = 4, width = 56, height = 28, label = "CACHE" },
            { id = 5, width = 56, height = 28, label = "QUEUE" },
            { id = 6, width = 56, height = 28, label = "MAIL" },
            { id = 7, width = 56, height = 28, label = "BILL" },
            { id = 8, width = 56, height = 28, label = "DB" },
            { id = 9, width = 56, height = 28, label = "LOG" },
            { id = 10, width = 56, height = 28, label = "OPS" },
        }
        local circular_edges = {
            { from = 1, to = 2 }, { from = 2, to = 3 }, { from = 3, to = 4 }, { from = 4, to = 5 },
            { from = 5, to = 6 }, { from = 6, to = 7 }, { from = 7, to = 8 }, { from = 8, to = 9 },
            { from = 9, to = 10 }, { from = 10, to = 1 }, { from = 2, to = 8 }, { from = 4, to = 9 },
        }
        render_graph(
            lurek.layout.circular(circular_nodes, { hSpacing = 64, vSpacing = 64, margin = 28 }),
            circular_edges,
            "CIRCULAR CYCLE NETWORK",
            OUT .. "layout_circular_cycle_network.png",
            {
                [1] = { 82, 144, 214 }, [2] = { 82, 144, 214 }, [3] = { 94, 166, 124 }, [4] = { 94, 166, 124 },
                [5] = { 205, 145, 72 }, [6] = { 205, 145, 72 }, [7] = { 178, 112, 196 }, [8] = { 178, 112, 196 },
                [9] = { 70, 150, 160 }, [10] = { 70, 150, 160 },
            }
        )

        local radial_nodes = {
            { id = 1, width = 62, height = 30, label = "GATE" },
            { id = 2, width = 58, height = 28, label = "AUTH" },
            { id = 3, width = 58, height = 28, label = "API" },
            { id = 4, width = 58, height = 28, label = "CDN" },
            { id = 5, width = 58, height = 28, label = "USER" },
            { id = 6, width = 58, height = 28, label = "ORDER" },
            { id = 7, width = 58, height = 28, label = "MEDIA" },
            { id = 8, width = 58, height = 28, label = "DB1" },
            { id = 9, width = 58, height = 28, label = "DB2" },
            { id = 10, width = 58, height = 28, label = "OBJ" },
            { id = 11, width = 58, height = 28, label = "MAIL" },
        }
        local radial_edges = {
            { from = 1, to = 2 }, { from = 1, to = 3 }, { from = 1, to = 4 },
            { from = 2, to = 5 }, { from = 3, to = 6 }, { from = 4, to = 7 },
            { from = 5, to = 8 }, { from = 6, to = 9 }, { from = 7, to = 10 }, { from = 6, to = 11 },
        }
        render_graph(
            lurek.layout.radial(radial_nodes, radial_edges, 1, { hSpacing = 54, vSpacing = 92, margin = 28 }),
            radial_edges,
            "RADIAL SERVICE TOPOLOGY",
            OUT .. "layout_radial_service_topology.png",
            {
                [1] = { 235, 148, 82 }, [2] = { 94, 144, 214 }, [3] = { 94, 144, 214 }, [4] = { 94, 144, 214 },
                [5] = { 94, 176, 126 }, [6] = { 94, 176, 126 }, [7] = { 94, 176, 126 },
            }
        )

        local grid_nodes = {}
        for i = 1, 16 do
            grid_nodes[i] = { id = i, width = 58, height = 28, label = "N" .. tostring(i) }
        end
        local grid_edges = {
            { from = 1, to = 2 }, { from = 2, to = 3 }, { from = 5, to = 6 }, { from = 6, to = 7 },
            { from = 9, to = 10 }, { from = 10, to = 11 }, { from = 13, to = 14 }, { from = 14, to = 15 },
        }
        render_graph(
            lurek.layout.grid(grid_nodes, { hSpacing = 34, vSpacing = 38, margin = 24 }),
            grid_edges,
            "GRID INVENTORY MATRIX",
            OUT .. "layout_grid_inventory_matrix.png",
            {
                [1] = { 76, 134, 198 }, [5] = { 90, 150, 120 }, [9] = { 190, 136, 74 }, [13] = { 150, 116, 196 },
            }
        )

        local spiral_nodes = {}
        for i = 1, 18 do
            spiral_nodes[i] = { id = i, width = 54, height = 26, label = "S" .. tostring(i) }
        end
        local spiral_edges = {
            { from = 1, to = 4 }, { from = 2, to = 7 }, { from = 3, to = 11 }, { from = 5, to = 13 },
            { from = 8, to = 17 }, { from = 10, to = 18 },
        }
        render_graph(
            lurek.layout.spiral(spiral_nodes, { hSpacing = 42, vSpacing = 42, margin = 32 }),
            spiral_edges,
            "SPIRAL LARGE UNORDERED",
            OUT .. "layout_spiral_large_unordered.png",
            {
                [1] = { 235, 148, 82 }, [6] = { 94, 144, 214 }, [12] = { 94, 176, 126 }, [18] = { 176, 124, 210 },
            }
        )

        local stress_nodes = {
            { id = 1, width = 58, height = 28, label = "A1" }, { id = 2, width = 58, height = 28, label = "A2" },
            { id = 3, width = 58, height = 28, label = "A3" }, { id = 4, width = 58, height = 28, label = "A4" },
            { id = 5, width = 58, height = 28, label = "B1" }, { id = 6, width = 58, height = 28, label = "B2" },
            { id = 7, width = 58, height = 28, label = "B3" }, { id = 8, width = 58, height = 28, label = "B4" },
            { id = 9, width = 58, height = 28, label = "C1" }, { id = 10, width = 58, height = 28, label = "C2" },
            { id = 11, width = 58, height = 28, label = "C3" }, { id = 12, width = 58, height = 28, label = "C4" },
        }
        local stress_edges = {
            { from = 1, to = 2 }, { from = 2, to = 3 }, { from = 3, to = 4 }, { from = 1, to = 5 },
            { from = 5, to = 6 }, { from = 6, to = 7 }, { from = 7, to = 8 }, { from = 4, to = 8 },
            { from = 5, to = 9 }, { from = 9, to = 10 }, { from = 10, to = 11 }, { from = 11, to = 12 },
            { from = 8, to = 12 }, { from = 3, to = 10 }, { from = 2, to = 6 },
        }
        render_graph(
            lurek.layout.stress(stress_nodes, stress_edges, { iterations = 80, edgeLength = 70, step = 0.05 }),
            stress_edges,
            "STRESS DISTANCE NETWORK",
            OUT .. "layout_stress_distance_network.png",
            {
                [1] = { 76, 134, 198 }, [2] = { 76, 134, 198 }, [3] = { 76, 134, 198 }, [4] = { 76, 134, 198 },
                [5] = { 90, 150, 120 }, [6] = { 90, 150, 120 }, [7] = { 90, 150, 120 }, [8] = { 90, 150, 120 },
                [9] = { 190, 136, 74 }, [10] = { 190, 136, 74 }, [11] = { 190, 136, 74 }, [12] = { 190, 136, 74 },
            }
        )
    end)

    -- Does: Runs every auto-layout method on larger varied-size inputs and writes overlap/bounds metrics.
    -- Shows: Complex layouts keep node rectangles separated instead of only returning trivial coordinates.
    -- Artifact: tests/artifacts/current/layout/layout_quality_metrics.txt
    -- Why: This gives reviewers numeric proof that layout quality improved for dense and irregular node sets.
    it("TXT: complex layout quality metrics", function()
        local varied = {}
        for i = 1, 18 do
            varied[i] = {
                id = i,
                width = 46 + (i % 5) * 17,
                height = 24 + (i % 3) * 11,
                label = "N" .. tostring(i),
            }
        end
        local chain = {}
        for i = 1, 17 do
            chain[i] = { from = i, to = i + 1 }
        end
        local star = {}
        for i = 2, 18 do
            star[#star + 1] = { from = 1, to = i }
        end
        local children = {
            [1] = { 2, 3, 4, 5 },
            [2] = { 6, 7 },
            [3] = { 8, 9, 10 },
            [4] = { 14, 15 },
            [5] = { 11, 12, 13 },
            [6] = { 16, 17, 18 },
        }

        local cases = {
            tree = lurek.layout.tree(varied, children, 1, { hSpacing = 18, vSpacing = 42, margin = 12 }),
            dag = lurek.layout.dag(varied, chain, { hSpacing = 18, vSpacing = 38, margin = 12 }),
            force = lurek.layout.force(varied, chain, { iterations = 90, repulsion = 9000, attraction = 0.018, cooling = 0.92, areaWidth = 860, areaHeight = 560 }),
            circular = lurek.layout.circular(varied, { hSpacing = 24, vSpacing = 24, margin = 12 }),
            radial = lurek.layout.radial(varied, star, 1, { hSpacing = 22, vSpacing = 44, margin = 12 }),
            grid = lurek.layout.grid(varied, { hSpacing = 14, vSpacing = 18, margin = 12 }),
            spiral = lurek.layout.spiral(varied, { hSpacing = 12, vSpacing = 12, margin = 12 }),
            stress = lurek.layout.stress(varied, chain, { iterations = 24, edgeLength = 66, step = 0.06 }),
        }

        local lines = { "layout,nodes,overlaps,width,height" }
        local order = { "tree", "dag", "force", "circular", "radial", "grid", "spiral", "stress" }
        for _, name in ipairs(order) do
            local result = cases[name]
            local overlaps_found = overlap_count(result, 0)
            expect_equal(0, overlaps_found)
            lines[#lines + 1] = table.concat({
                name,
                tostring(#result.nodes),
                tostring(overlaps_found),
                string.format("%.1f", result.width),
                string.format("%.1f", result.height),
            }, ",")
        end
        save_text(OUT .. "layout_quality_metrics.txt", table.concat(lines, "\n") .. "\n")
    end)
end)

test_summary()
