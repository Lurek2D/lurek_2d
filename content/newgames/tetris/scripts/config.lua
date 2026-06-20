return {
    title = "Falling Blocks",
    ui = "content/newgames/tetris/ui.toml",
    screen = { w = 800, h = 600 },
    board = {
        cols = 10,
        rows = 20,
        cell = 28,
        x = 260,
        y = 40,
    },
    timing = {
        start_drop = 0.52,
        min_drop = 0.08,
        lock_delay = 0.48,
        soft_drop_scale = 10,
    },
    colors = {
        background = { 0.045, 0.05, 0.085 },
        grid = { 0.13, 0.14, 0.20 },
        border = { 0.35, 0.38, 0.58 },
        ghost_alpha = 0.24,
    },
    sounds = {
        move = "assets/audio/confirm.wav",
        rotate = "assets/audio/confirm.wav",
        lock = "assets/audio/confirm.wav",
        clear = "assets/audio/confirm.wav",
    },
}
