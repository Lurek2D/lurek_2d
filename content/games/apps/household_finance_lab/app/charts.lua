local Charts = {}

local function color(c)
    lurek.render.setColor(c[1], c[2], c[3], c[4] or 1)
end

local function max_value(rows, keys)
    local max_v = 1
    for _, row in ipairs(rows or {}) do
        for _, key in ipairs(keys) do
            local v = math.abs(tonumber(row[key]) or 0)
            if v > max_v then max_v = v end
        end
    end
    return max_v
end

function Charts.line(rows, x, y, w, h, keys, colors)
    color({ 0.18, 0.20, 0.23, 1 })
    lurek.render.rectangle("fill", x, y, w, h, 4, 4)
    color({ 0.28, 0.31, 0.35, 1 })
    lurek.render.rectangle("line", x, y, w, h, 4, 4)
    local max_v = max_value(rows, keys)
    local count = math.max(1, #rows - 1)
    for series, key in ipairs(keys) do
        color(colors[series])
        local last_x, last_y = nil, nil
        for index, row in ipairs(rows or {}) do
            local px = x + 12 + (index - 1) / count * (w - 24)
            local py = y + h - 12 - ((tonumber(row[key]) or 0) / max_v) * (h - 28)
            if last_x then lurek.render.line(last_x, last_y, px, py) end
            last_x, last_y = px, py
        end
    end
end

function Charts.sparkline(rows, x, y, w, h, key, c)
    Charts.line(rows, x, y, w, h, { key }, { c })
end

function Charts.bars(items, x, y, w, h, label_key, value_key, C, limit)
    color({ 0.18, 0.20, 0.23, 1 })
    lurek.render.rectangle("fill", x, y, w, h, 4, 4)
    local max_v = 1
    for index = 1, math.min(limit or 10, #items) do
        max_v = math.max(max_v, tonumber(items[index][value_key]) or 0)
    end
    local row_h = math.floor((h - 18) / math.max(1, math.min(limit or 10, #items)))
    for index = 1, math.min(limit or 10, #items) do
        local item = items[index]
        local label = tostring(item[label_key] or item.label or "")
        local value = tonumber(item[value_key]) or tonumber(item.value) or 0
        local c = C.CATEGORY_COLORS[label] or C.COLORS.blue
        local bar_w = (w - 150) * value / max_v
        local py = y + 10 + (index - 1) * row_h
        color(c)
        lurek.render.rectangle("fill", x + 118, py + 3, bar_w, math.max(5, row_h - 7), 2, 2)
        color(C.COLORS.muted)
        lurek.render.print(label, x + 8, py + 1, 1)
        lurek.render.print(string.format("%.0f", value), x + w - 58, py + 1, 1)
    end
end

function Charts.payment_mix(items, x, y, w, h, C)
    local total = 0
    for _, item in ipairs(items or {}) do total = total + (tonumber(item.value) or 0) end
    total = math.max(total, 1)
    color({ 0.18, 0.20, 0.23, 1 })
    lurek.render.rectangle("fill", x, y, w, h, 4, 4)
    local px = x + 10
    local palette = { C.COLORS.blue, C.COLORS.green, C.COLORS.amber, C.COLORS.violet, C.COLORS.cyan, C.COLORS.red }
    for index, item in ipairs(items or {}) do
        local segment = (tonumber(item.value) or 0) / total * (w - 20)
        color(palette[((index - 1) % #palette) + 1])
        lurek.render.rectangle("fill", px, y + 18, segment, 24, 2, 2)
        px = px + segment
    end
    local ly = y + 54
    for index, item in ipairs(items or {}) do
        color(palette[((index - 1) % #palette) + 1])
        lurek.render.rectangle("fill", x + 12, ly + 4, 8, 8, 1, 1)
        color(C.COLORS.text)
        lurek.render.print(tostring(item.label), x + 26, ly, 1)
        color(C.COLORS.muted)
        lurek.render.print(string.format("%.1f%%", ((tonumber(item.value) or 0) / total) * 100), x + w - 58, ly, 1)
        ly = ly + 18
    end
end

function Charts.heatmap(heatmap, x, y, w, h, C)
    color({ 0.18, 0.20, 0.23, 1 })
    lurek.render.rectangle("fill", x, y, w, h, 4, 4)
    local cell_w = (w - 130) / 60
    local cell_h = (h - 24) / 8
    for _, cell in ipairs((heatmap and heatmap.cells) or {}) do
        local c = C.CATEGORY_COLORS[cell.category] or C.COLORS.blue
        local t = math.min(1, (tonumber(cell.value) or 0) / math.max(1, heatmap.max or 1))
        lurek.render.setColor(c[1] * (0.20 + t * 0.80), c[2] * (0.20 + t * 0.80), c[3] * (0.25 + t * 0.75), 1)
        lurek.render.rectangle("fill", x + 118 + (cell.x - 1) * cell_w, y + 12 + (cell.y - 1) * cell_h, math.max(1, cell_w - 1), math.max(1, cell_h - 1))
    end
    for index = 1, math.min(8, #((heatmap and heatmap.categories) or {})) do
        color(C.COLORS.muted)
        lurek.render.print(heatmap.categories[index].label, x + 8, y + 8 + (index - 1) * cell_h, 1)
    end
end

return Charts