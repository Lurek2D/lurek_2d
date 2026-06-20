return {
    title = "Snake",
    ui = "content/newgames/snake/ui.toml",
    screen = { w = 640, h = 600 },
    grid = { cols = 32, rows = 28, cell = 20, hud_h = 40 },
    rules = { base_speed = 8, food_count = 3, speed_step = 1.5, speed_every = 5 },
    colors = {
        background = { 0.035, 0.055, 0.035 },
        board = { 0.055, 0.08, 0.055 },
        grid = { 0.09, 0.12, 0.09 },
        food = { 1.0, 0.18, 0.16 },
        stem = { 0.18, 0.78, 0.22 },
        head = { 0.35, 1.0, 0.35 },
        tail = { 0.18, 0.55, 0.22 },
    },
    sounds = {
        eat = "assets/audio/confirm.wav",
        death = "assets/audio/confirm.wav",
    },
}
