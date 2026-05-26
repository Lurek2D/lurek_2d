local M = {}

M.SCREEN_W = 800
M.SCREEN_H = 600

M.STATE = {
    TITLE = 1,
    PLAYING = 2,
    GAME_OVER = 3,
}

M.FORM_COLS = 10
M.FORM_ROWS = 4
M.ENEMY_W = 24
M.ENEMY_H = 20
M.FORM_GAP_X = 14
M.FORM_GAP_Y = 12
M.FORM_START_Y = 70

M.ROW_CFG = {
    { color = { 1.0, 0.2, 0.2 }, pts = 400, hp = 2, is_boss = true },
    { color = { 0.9, 0.6, 0.1 }, pts = 150, hp = 1, is_boss = false },
    { color = { 0.2, 0.7, 1.0 }, pts = 100, hp = 1, is_boss = false },
    { color = { 0.3, 1.0, 0.3 }, pts = 50, hp = 1, is_boss = false },
}
M.BOSS_HIT_COLOR = { 1.0, 0.7, 0.9 }

M.PLAYER_W = 36
M.PLAYER_H = 14
M.PLAYER_TURRET_W = 6
M.PLAYER_TURRET_H = 10
M.PLAYER_Y = M.SCREEN_H - 50
M.PLAYER_SPEED = 300
M.MAX_PLAYER_BULLETS = 2

M.BULLET_W = 3
M.BULLET_H = 10
M.BULLET_SPEED = 420
M.ENEMY_BULLET_SPEED = 220

M.CHALLENGE_INTERVAL = 3
M.TRACTOR_W = 40
M.TRACTOR_H = 80

M.STAR_LAYER_COUNT = 3
M.STARS_PER_LAYER = { 40, 30, 20 }
M.STAR_SPEEDS = { 30, 60, 100 }
M.STAR_SIZES = { 1, 2, 2 }
M.STAR_ALPHAS = { 0.3, 0.5, 0.8 }

M.FLY_IN_SPEED = 280
M.UI_LAYOUT_PATH = "content/games/arcade/galaga/ui.toml"

return M
