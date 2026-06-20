local M = {}

M.PI2 = math.pi * 2

function M.wrap(v, max)
    return (v + max) % max
end

function M.dist2(ax, ay, bx, by)
    local dx, dy = ax - bx, ay - by
    return dx * dx + dy * dy
end

function M.circle_hit(ax, ay, ar, bx, by, br)
    return M.dist2(ax, ay, bx, by) <= (ar + br) * (ar + br)
end

return M
