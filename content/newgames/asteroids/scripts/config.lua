return {
    title = "Asteroids",
    ui = "content/newgames/asteroids/ui.toml",
    screen = { w = 800, h = 600 },
    ship = {
        turn_speed = 5.0,
        thrust = 280,
        drag = 0.985,
        radius = 14,
        respawn_time = 2.0,
    },
    bullets = {
        speed = 450,
        lifetime = 1.6,
        max = 4,
        cooldown = 0.16,
    },
    asteroids = {
        start_count = 4,
        radius = { large = 42, medium = 26, small = 15 },
        speed = { large = 55, medium = 95, small = 150 },
        score = { large = 25, medium = 50, small = 100 },
    },
    colors = {
        background = { 0.0, 0.0, 0.025 },
        ship = { 0.95, 0.95, 1.0 },
        bullet = { 1.0, 0.95, 0.65 },
        large = { 0.62, 0.62, 0.68 },
        medium = { 0.72, 0.70, 0.52 },
        small = { 0.82, 0.78, 0.55 },
    },
    sounds = {
        fire = "assets/audio/confirm.wav",
        hit = "assets/audio/confirm.wav",
        death = "assets/audio/confirm.wav",
    },
}
