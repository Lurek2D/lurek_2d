local M = {}

local WHITE = {1, 1, 1, 1}

local function set_tint(tint, alpha)
    tint = tint or WHITE
    lurek.render.setColor(tint[1] or 1, tint[2] or 1, tint[3] or 1, alpha or tint[4] or 1)
end

function M.draw(image, x, y, angle, sx, sy, tint, alpha)
    if not image then return false end
    set_tint(tint, alpha)
    lurek.render.draw(image, x, y, angle or 0, sx or 1, sy or sx or 1)
    set_tint(WHITE)
    return true
end

function M.draw_centered(image, x, y, angle, sx, sy, tint, alpha)
    if not image then return false end
    sx, sy = sx or 1, sy or sx or 1
    local width, height = image:getDimensions()
    return M.draw(image, x - width * sx * 0.5, y - height * sy * 0.5, angle, sx, sy, tint, alpha)
end

return M
