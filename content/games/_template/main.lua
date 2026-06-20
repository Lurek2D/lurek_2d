local App = {
    state = "title",
    score = 0,
    player = { x = 400, y = 300, speed = 220 },
    pickups = {},
    timer = 0,
}

local function reset_game()
    App.state = "playing"
    App.score = 0
    App.timer = 0
    App.player.x = 400
    App.player.y = 300
    App.pickups = {
        { x = 220, y = 180, r = 10, taken = false },
        { x = 580, y = 170, r = 10, taken = false },
        { x = 320, y = 430, r = 10, taken = false },
        { x = 610, y = 410, r = 10, taken = false },
    }
end

local function bind_inputs()
    lurek.input.bind("left", { "a", "left" })
    lurek.input.bind("right", { "d", "right" })
    lurek.input.bind("up", { "w", "up" })
    lurek.input.bind("down", { "s", "down" })
    lurek.input.bind("confirm", { "return", "space" })
    lurek.input.bind("restart", { "r" })
    lurek.input.bind("quit", { "escape" })
end

local function clamp(value, min_value, max_value)
    if value < min_value then return min_value end
    if value > max_value then return max_value end
    return value
end

local function update_player(dt)
    local dx, dy = 0, 0
    if lurek.input.isActionDown("left") then dx = dx - 1 end
    if lurek.input.isActionDown("right") then dx = dx + 1 end
    if lurek.input.isActionDown("up") then dy = dy - 1 end
    if lurek.input.isActionDown("down") then dy = dy + 1 end

    if dx ~= 0 and dy ~= 0 then
        dx = dx * 0.7071
        dy = dy * 0.7071
    end

    App.player.x = clamp(App.player.x + dx * App.player.speed * dt, 32, 768)
    App.player.y = clamp(App.player.y + dy * App.player.speed * dt, 72, 568)
end

local function update_pickups()
    local remaining = 0
    for _, pickup in ipairs(App.pickups) do
        if not pickup.taken then
            local dx = pickup.x - App.player.x
            local dy = pickup.y - App.player.y
            if dx * dx + dy * dy < (pickup.r + 12) * (pickup.r + 12) then
                pickup.taken = true
                App.score = App.score + 100
            else
                remaining = remaining + 1
            end
        end
    end
    if remaining == 0 then
        App.state = "complete"
    end
end

function lurek.init()
    lurek.window.setTitle("Demo Template - Lurek2D")
    lurek.render.setBackgroundColor(0.05, 0.06, 0.08)
    bind_inputs()
    reset_game()
end

function lurek.process(dt)
    if lurek.input.wasActionPressed("quit") then
        lurek.event.quit()
        return
    end

    if lurek.input.wasActionPressed("restart") then
        reset_game()
        return
    end

    if App.state == "title" then
        if lurek.input.wasActionPressed("confirm") then
            reset_game()
        end
        return
    end

    if App.state == "complete" then
        if lurek.input.wasActionPressed("confirm") then
            reset_game()
        end
        return
    end

    App.timer = App.timer + dt
    update_player(dt)
    update_pickups()
end

local function draw_pickups()
    for _, pickup in ipairs(App.pickups) do
        if not pickup.taken then
            lurek.render.setColor(0.15, 0.85, 0.72, 1)
            lurek.render.circle("fill", pickup.x, pickup.y, pickup.r)
            lurek.render.setColor(0.75, 1.0, 0.94, 1)
            lurek.render.circle("line", pickup.x, pickup.y, pickup.r + 4)
        end
    end
end

local function draw_player()
    lurek.render.setColor(0.95, 0.76, 0.22, 1)
    lurek.render.rectangle("fill", App.player.x - 12, App.player.y - 12, 24, 24)
    lurek.render.setColor(1, 0.95, 0.65, 1)
    lurek.render.rectangle("line", App.player.x - 15, App.player.y - 15, 30, 30)
end

function lurek.draw()
    lurek.render.setColor(0.13, 0.15, 0.19, 1)
    lurek.render.rectangle("fill", 24, 64, 752, 512)

    lurek.render.setColor(0.22, 0.25, 0.31, 1)
    for x = 64, 736, 64 do
        lurek.render.line(x, 64, x, 576)
    end
    for y = 128, 544, 64 do
        lurek.render.line(24, y, 776, y)
    end

    draw_pickups()
    draw_player()

    lurek.render.setColor(1, 1, 1, 1)
    if App.state == "complete" then
        lurek.render.print("Complete - press Space to restart", 260, 304)
    else
        lurek.render.print("Collect every marker", 284, 304)
    end
end

function lurek.draw_ui()
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.print("Demo Template", 24, 20)
    lurek.render.print("Score: " .. tostring(App.score), 24, 42)
    lurek.render.print("WASD/Arrows move  R restart  Esc quit", 430, 42)
end
