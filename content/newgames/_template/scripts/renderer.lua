local M = {}

local R = lurek.render
local sprite = nil

local function color(c)
    R.setColor(c[1], c[2], c[3], c[4] or 1)
end

function M.load(cfg)
    if R.newImage then
        local ok, image = pcall(R.newImage, cfg.SPRITE_PATH)
        if ok then
            sprite = image
        end
    end
end

local function draw_grid(a)
    color({ 0.07, 0.09, 0.13, 1 })
    R.rectangle("fill", a.x, a.y, a.w, a.h)
    color({ 0.14, 0.18, 0.25, 1 })
    for x = a.x, a.x + a.w, 48 do
        R.line(x, a.y, x, a.y + a.h)
    end
    for y = a.y, a.y + a.h, 48 do
        R.line(a.x, y, a.x + a.w, y)
    end
    color({ 0.38, 0.50, 0.68, 1 })
    R.rectangle("line", a.x, a.y, a.w, a.h)
end

local function draw_ship(p)
    if sprite then
        color({ 1, 1, 1, 1 })
        R.draw(sprite, p.x - 16, p.y - 16, 0, 1, 1)
        return
    end
    color({ 0.26, 0.78, 1.0, 1 })
    R.polygon("fill", p.x, p.y - 18, p.x - 16, p.y + 14, p.x + 16, p.y + 14)
    color({ 0.84, 0.96, 1.0, 1 })
    R.polygon("line", p.x, p.y - 18, p.x - 16, p.y + 14, p.x + 16, p.y + 14)
end

local function draw_cells(game)
    for _, cell in ipairs(game.cells) do
        if not cell.taken then
            color({ 0.13, 0.92, 0.65, 1 })
            R.circle("fill", cell.x, cell.y, 10)
            color({ 0.72, 1.0, 0.86, 1 })
            R.circle("line", cell.x, cell.y, 16)
        end
    end
end

local function draw_sentries(game)
    for _, sentry in ipairs(game.sentries) do
        color({ 0.95, 0.28, 0.22, 0.22 })
        R.circle("fill", sentry.x, sentry.y, sentry.radius + 28)
        color({ 0.95, 0.28, 0.22, 1 })
        R.circle("fill", sentry.x, sentry.y, sentry.radius)
        color({ 1.0, 0.72, 0.62, 1 })
        R.circle("line", sentry.x, sentry.y, sentry.radius + 4)
    end
end

local function draw_obstacles(game)
    for _, rect in ipairs(game.obstacles) do
        color({ 0.24, 0.27, 0.34, 1 })
        R.rectangle("fill", rect.x, rect.y, rect.w, rect.h)
        color({ 0.48, 0.54, 0.66, 1 })
        R.rectangle("line", rect.x, rect.y, rect.w, rect.h)
    end
end

local function draw_extract(game)
    local e = game.extract
    if e.open then
        color({ 0.32, 0.88, 1.0, 0.34 })
    else
        color({ 0.45, 0.47, 0.52, 0.28 })
    end
    R.circle("fill", e.x, e.y, e.radius)
    color(e.open and { 0.62, 0.96, 1.0, 1 } or { 0.62, 0.64, 0.70, 1 })
    R.circle("line", e.x, e.y, e.radius + 6)
end

function M.draw(game)
    local a = game.cfg.ARENA
    draw_grid(a)
    draw_extract(game)
    draw_obstacles(game)
    draw_cells(game)
    draw_sentries(game)
    draw_ship(game.player)

    if game.particles and game.particles.render then
        game.particles:render()
    end
end

return M
