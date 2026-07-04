-- process_map.lua - helper that downsamples the authored EU2 province map.
-- Run it as main.lua inside content/games/eu2 when you want fresh processed
-- outputs under save/eu2/.

local MAP_IN = "map.png"
local MAP_OUT = "save/eu2/map2.png"
local MARKER_OUT = "save/eu2/map2_markers.png"

local WHITE_THRESH = 240
local MAGENTA_R_MIN = 180
local MAGENTA_G_MAX = 60
local BLACK_MAX = 40

local DIRS = {
    { -1, 0 },
    { 1, 0 },
    { 0, -1 },
    { 0, 1 },
}

local function is_white(r, g, b)
    return r >= WHITE_THRESH and g >= WHITE_THRESH and b >= WHITE_THRESH
end

local function is_magenta(r, g, b)
    return r >= MAGENTA_R_MIN and g <= MAGENTA_G_MAX and b >= MAGENTA_R_MIN
end

local function is_black(r, g, b)
    return r < BLACK_MAX and g < BLACK_MAX and b < BLACK_MAX
end

local function is_province(r, g, b)
    return not is_white(r, g, b) and not is_magenta(r, g, b) and not is_black(r, g, b)
end

local function ck(r, g, b)
    return r * 65536 + g * 256 + b
end

local function ck_rgb(k)
    local r = math.floor(k / 65536)
    local g = math.floor((k / 256) % 256)
    local b = k % 256
    return r, g, b
end

local function has_4_same(img, x, y, r, g, b, w, h)
    if x <= 0 or x >= w - 1 or y <= 0 or y >= h - 1 then
        return false
    end
    for _, d in ipairs(DIRS) do
        local nr, ng, nb = img:getPixel(x + d[1], y + d[2])
        if nr ~= r or ng ~= g or nb ~= b then
            return false
        end
    end
    return true
end

local function smooth_once(img, w, h)
    local next = lurek.image.newImageData(w, h)
    for y = 0, h - 1 do
        for x = 0, w - 1 do
            local r, g, b, a = img:getPixel(x, y)
            if is_black(r, g, b) then
                next:setPixel(x, y, r, g, b, a)
            else
                local sk = ck(r, g, b)
                local votes = { [sk] = 2 }
                for _, d in ipairs(DIRS) do
                    local nx = x + d[1]
                    local ny = y + d[2]
                    if nx >= 0 and nx < w and ny >= 0 and ny < h then
                        local nr, ng, nb = img:getPixel(nx, ny)
                        if not is_black(nr, ng, nb) then
                            local nk = ck(nr, ng, nb)
                            votes[nk] = (votes[nk] or 0) + 1
                        end
                    end
                end
                local bk, bv = sk, 0
                for k, v in pairs(votes) do
                    if v > bv then
                        bk, bv = k, v
                    end
                end
                local fr, fg, fb = ck_rgb(bk)
                next:setPixel(x, y, fr, fg, fb, 255)
            end
        end
    end
    return next
end

local function remember_point(store, key, x, y)
    store[key] = store[key] or { list = {}, seen = {} }
    local dedupe_key = tostring(x) .. ":" .. tostring(y)
    if store[key].seen[dedupe_key] then
        return
    end
    store[key].seen[dedupe_key] = true
    table.insert(store[key].list, { x = x, y = y })
end

local function nearest_same_pixel(img, x, y, r, g, b, w, h, prefer_interior)
    local function match_at(px, py)
        local pr, pg, pb = img:getPixel(px, py)
        if pr ~= r or pg ~= g or pb ~= b then
            return false
        end
        if prefer_interior then
            return has_4_same(img, px, py, r, g, b, w, h)
        end
        return true
    end

    if x >= 0 and x < w and y >= 0 and y < h and match_at(x, y) then
        return x, y
    end

    for radius = 1, 12 do
        for dy = -radius, radius do
            for dx = -radius, radius do
                if math.abs(dx) ~= radius and math.abs(dy) ~= radius then
                    goto continue
                end
                local px = x + dx
                local py = y + dy
                if px >= 0 and px < w and py >= 0 and py < h and match_at(px, py) then
                    return px, py
                end
                ::continue::
            end
        end
    end

    if prefer_interior then
        return nearest_same_pixel(img, x, y, r, g, b, w, h, false)
    end
    return nil, nil
end

local function farthest_pair(points)
    if not points or #points < 2 then
        return nil, nil
    end
    local best = -1
    local a = points[1]
    local b = points[2]
    for i = 1, #points - 1 do
        for j = i + 1, #points do
            local dx = points[j].x - points[i].x
            local dy = points[j].y - points[i].y
            local d2 = dx * dx + dy * dy
            if d2 > best then
                best = d2
                a = points[i]
                b = points[j]
            end
        end
    end
    return a, b
end

function lurek.init()
    print("[process_map] loading " .. MAP_IN .. " ...")
    local src = lurek.image.loadImage(MAP_IN)
    assert(src, "cannot load " .. MAP_IN)

    local w = src:getWidth()
    local h = src:getHeight()
    local w2 = math.floor(w / 2)
    local h2 = math.floor(h / 2)

    print(string.format("[process_map] %dx%d -> %dx%d", w, h, w2, h2))

    local color_out = lurek.image.newImageData(w2, h2)
    local province_white = {}
    local province_magenta = {}

    for oy = 0, h2 - 1 do
        for ox = 0, w2 - 1 do
            local sx = ox * 2
            local sy = oy * 2

            local votes = {}
            local found_white = false
            local found_magenta = false

            for dy = 0, 1 do
                for dx = 0, 1 do
                    local px = sx + dx
                    local py = sy + dy
                    if px < w and py < h then
                        local r, g, b = src:getPixel(px, py)
                        if is_white(r, g, b) then
                            found_white = true
                        elseif is_magenta(r, g, b) then
                            found_magenta = true
                        elseif is_province(r, g, b) then
                            local key = ck(r, g, b)
                            votes[key] = (votes[key] or 0) + 1
                        end
                    end
                end
            end

            local best_k, best_v = 0, 0
            for key, value in pairs(votes) do
                if value > best_v then
                    best_k, best_v = key, value
                end
            end

            local r, g, b
            if best_v > 0 then
                r, g, b = ck_rgb(best_k)
                if found_white and province_white[best_k] == nil then
                    province_white[best_k] = { x = ox, y = oy }
                end
                if found_magenta then
                    remember_point(province_magenta, best_k, ox, oy)
                end
            else
                r, g, b = src:getPixel(sx, sy)
                if is_magenta(r, g, b) or is_white(r, g, b) then
                    r, g, b = 0, 0, 0
                end
            end

            color_out:setPixel(ox, oy, r, g, b, 255)
        end
    end

    print("[process_map] smoothing province colors ...")
    color_out = smooth_once(color_out, w2, h2)
    color_out = smooth_once(color_out, w2, h2)

    local marker_out = lurek.image.newImageData(w2, h2)
    for y = 0, h2 - 1 do
        for x = 0, w2 - 1 do
            local r, g, b, a = color_out:getPixel(x, y)
            marker_out:setPixel(x, y, r, g, b, a)
        end
    end

    local capitals_set = 0
    local capitals_skipped = 0
    for key, point in pairs(province_white) do
        local pr, pg, pb = ck_rgb(key)
        local px, py = nearest_same_pixel(color_out, point.x, point.y, pr, pg, pb, w2, h2, true)
        if px ~= nil then
            marker_out:setPixel(px, py, 255, 255, 255, 255)
            capitals_set = capitals_set + 1
        else
            capitals_skipped = capitals_skipped + 1
        end
    end

    local labels_set = 0
    local labels_skipped = 0
    for key, entry in pairs(province_magenta) do
        local a, b = farthest_pair(entry.list)
        if a and b then
            local pr, pg, pb = ck_rgb(key)
            local ax, ay = nearest_same_pixel(color_out, a.x, a.y, pr, pg, pb, w2, h2, false)
            local bx, by = nearest_same_pixel(color_out, b.x, b.y, pr, pg, pb, w2, h2, false)
            if ax ~= nil and bx ~= nil then
                marker_out:setPixel(ax, ay, 255, 0, 255, 255)
                marker_out:setPixel(bx, by, 255, 0, 255, 255)
                labels_set = labels_set + 1
            else
                labels_skipped = labels_skipped + 1
            end
        else
            labels_skipped = labels_skipped + 1
        end
    end

    print(string.format(
        "[process_map] capitals=%d skipped=%d labels=%d skipped=%d",
        capitals_set,
        capitals_skipped,
        labels_set,
        labels_skipped
    ))

    print("[process_map] saving " .. MAP_OUT)
    lurek.image.savePNG(color_out, MAP_OUT)
    print("[process_map] saving " .. MARKER_OUT)
    lurek.image.savePNG(marker_out, MARKER_OUT)
    print("[process_map] done")

    lurek.event.quit()
end

function lurek.process(dt) end

function lurek.draw()
    lurek.render.clear(0, 0, 0)
    lurek.render.print("[process_map] processing map, see console", 10, 10)
end
