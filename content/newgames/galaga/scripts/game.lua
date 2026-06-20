local cfg = require("content.games.arcade.galaga.modules.config")
local UIOverlay = require("content.games.arcade.galaga.modules.ui_overlay")
local Gameplay = require("content.games.arcade.galaga.modules.gameplay")

local ui = UIOverlay.new(cfg)

---@type any
local menu_scene = nil
---@type any
local game_scene = nil
---@type any
local game_over_scene = nil
---@type any
local pending_scene = nil
local menu_state = {
    selected = 1,
    hover = nil,
    nav_timer = 0,
}

local function key_down(...)
    local keys = { ... }
    for i = 1, #keys do
        if lurek.input.keyboard.isDown(keys[i]) then
            return true
        end
    end
    return false
end

local function point_in_rect(x, y, rx, ry, rw, rh)
    return x >= rx and x <= (rx + rw) and y >= ry and y <= (ry + rh)
end

local function menu_button_rects()
    local bw, bh = 280, 44
    local bx = (cfg.SCREEN_W - bw) * 0.5
    local y1 = 220
    local y2 = 276
    return {
        { x = bx, y = y1, w = bw, h = bh },
        { x = bx, y = y2, w = bw, h = bh },
    }
end

local function confirm_pressed()
    return lurek.input.wasActionPressed("start")
        or lurek.input.wasActionPressed("confirm")
        or key_down("return", "kp_enter")
        or lurek.input.mouse.isDown(1)
end

local function update_menu_input(dt)
    if Gameplay.get_state() ~= cfg.STATE.TITLE then
        return
    end

    menu_state.nav_timer = math.max(0, menu_state.nav_timer - dt)

    local mx, my = lurek.input.mouse.getPosition()
    local rects = menu_button_rects()
    menu_state.hover = nil
    for i = 1, #rects do
        local r = rects[i]
        if point_in_rect(mx, my, r.x, r.y, r.w, r.h) then
            menu_state.hover = i
            menu_state.selected = i
            break
        end
    end

    if menu_state.nav_timer <= 0 then
        if key_down("up", "w") then
            menu_state.selected = math.max(1, menu_state.selected - 1)
            menu_state.nav_timer = 0.14
        elseif key_down("down", "s") then
            menu_state.selected = math.min(2, menu_state.selected + 1)
            menu_state.nav_timer = 0.14
        end
    end

    if confirm_pressed() then
        if menu_state.selected == 1 then
            Gameplay.on_ui_primary_action()
        else
            Gameplay.on_ui_quit_action()
        end
    end
end

local function queue_scene(scene)
    pending_scene = scene
end

local function flush_scene_switch()
    if pending_scene then
        lurek.scene.switchTo(pending_scene)
        pending_scene = nil
    end
end

function lurek.init()
    ui:load(function()
        Gameplay.on_ui_primary_action()
    end, function()
        Gameplay.on_ui_quit_action()
    end)
    Gameplay.bind_ui(ui)
    Gameplay.init()
    menu_state.selected = 1
    menu_state.hover = nil
    menu_state.nav_timer = 0

    menu_scene = lurek.scene.new({
        name = "menu",
        process = function(_, dt)
            Gameplay.process(dt)
            update_menu_input(dt)
            if Gameplay.get_state() == cfg.STATE.PLAYING then
                queue_scene(game_scene)
            end
        end,
        draw = function()
            Gameplay.draw()
        end,
    })

    game_scene = lurek.scene.new({
        name = "game",
        process = function(_, dt)
            Gameplay.process(dt)
            local s = Gameplay.get_state()
            if s == cfg.STATE.GAME_OVER then
                queue_scene(game_over_scene)
            elseif s == cfg.STATE.TITLE then
                queue_scene(menu_scene)
            end
        end,
        draw = function()
            Gameplay.draw()
        end,
    })

    game_over_scene = lurek.scene.new({
        name = "game_over",
        process = function(_, dt)
            Gameplay.process(dt)
            local s = Gameplay.get_state()
            if s == cfg.STATE.PLAYING then
                queue_scene(game_scene)
            elseif s == cfg.STATE.TITLE then
                queue_scene(menu_scene)
            end
        end,
        draw = function()
            Gameplay.draw()
        end,
    })

    lurek.scene.clear()
    lurek.scene.push(menu_scene)
end

function lurek.process(dt)
    if lurek.automation then
        lurek.automation.update(dt)
    end
    lurek.scene.process(dt)
    flush_scene_switch()
end

function lurek.draw()
    lurek.scene.draw()
end

function lurek.draw_ui()
    -- HUD and menus are rendered by TOML UI layout.
end

function lurek.mousepressed(x, y, button)
    if lurek.ui and type(lurek.ui.mousepressed) == "function" then
        return lurek.ui.mousepressed(x, y, button)
    end
end

function lurek.mousereleased(x, y, button)
    if lurek.ui and type(lurek.ui.mousereleased) == "function" then
        return lurek.ui.mousereleased(x, y, button)
    end
end
