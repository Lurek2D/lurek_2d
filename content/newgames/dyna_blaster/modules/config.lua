local M = {
    SCREEN_W = 960,
    SCREEN_H = 640,
    TILE = 40,
    GRID_W = 15,
    GRID_H = 13,
    ORIGIN_X = 180,
    ORIGIN_Y = 60,

    GID_EMPTY = 0,
    GID_WALL = 1,
    GID_CRATE = 2,
}

function M.grid_to_screen(gx, gy)
    return M.ORIGIN_X + (gx - 1) * M.TILE, M.ORIGIN_Y + (gy - 1) * M.TILE
end

function M.in_bounds(gx, gy)
    return gx >= 1 and gx <= M.GRID_W and gy >= 1 and gy <= M.GRID_H
end

return M
