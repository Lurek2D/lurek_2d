local M = {}

M.TITLE = "Sector Runner Template"
M.ROOT = "content/newgames/_template"
M.UI_LAYOUT_PATH = M.ROOT .. "/ui.toml"
M.SPRITE_PATH = "assets/sprites/sector_runner.png"

M.SOUNDS = {
    pickup = "assets/audio/pickup.wav",
    hit = "assets/audio/hit.wav",
    win = "assets/audio/win.wav",
}

M.ARENA = {
    x = 64,
    y = 64,
    w = 832,
    h = 400,
}

M.PLAYER = {
    speed = 245,
    radius = 14,
    shield = 100,
}

M.GAME_SECONDS = 75
M.FUEL_REQUIRED = 3

return M
