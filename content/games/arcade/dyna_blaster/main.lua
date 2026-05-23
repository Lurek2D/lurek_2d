-- Dyna Blaster — arcade bomber demo

local cfg = require("content.games.arcade.dyna_blaster.modules.config")
local UI = require("content.games.arcade.dyna_blaster.modules.ui_overlay")
local Gameplay = require("content.games.arcade.dyna_blaster.modules.gameplay")
local gameplay = Gameplay.new(cfg)
local app = gameplay:get_app()

local menu_state = {
    selected = 1,
    hover = nil,
    nav_timer = 0,
}

---@type any
local menu_scene = nil
---@type any
local game_scene = nil
---@type any
local game_over_scene = nil

local function key_down(...)
    local keys = { ... }
    for i = 1, #keys do
        if lurek.input.keyboard.isDown(keys[i]) then
            return true
        end
    end
    return false
end

local function confirm_pressed()
    return lurek.input.wasActionPressed("confirm")
        or key_down("return", "kp_enter")
        or lurek.input.mouse.isDown(1)
end

local function quit_pressed()
    return lurek.input.wasActionPressed("quit") or key_down("escape")
end

local function activate_menu_selection()
    if menu_state.selected == 1 then
        gameplay:reset_run()
        lurek.scene.switchTo(game_scene, "fade", 0.2, "linear")
    else
        lurek.event.quit()
    end
end

local function update_menu_input(dt)
    menu_state.nav_timer = math.max(0, menu_state.nav_timer - dt)

    local mx, my = lurek.input.mouse.getPosition()
    local hover_idx = UI.pick_menu_button(cfg, mx, my)
    menu_state.hover = hover_idx
    if hover_idx then
        menu_state.selected = hover_idx
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
        activate_menu_selection()
    end
end

function lurek.init()
    math.randomseed(1337)

    lurek.window.setTitle("Dyna Blaster — Lurek2D")
    lurek.window.windowConfig({
        width = cfg.SCREEN_W,
        height = cfg.SCREEN_H,
        scaleMode = "none",
        vsync = 1,
    })
    lurek.render.setBackgroundColor(0.06, 0.06, 0.08)

    if lurek.render and type(lurek.render.setDefaultFont) == "function" then
        local ui_font = lurek.render.setDefaultFont(10, true)
        if ui_font and lurek.ui and type(lurek.ui.setFont) == "function" then
            lurek.ui.setFont(ui_font)
        end
    end

    lurek.input.bind("move_up", { "w", "up" })
    lurek.input.bind("move_down", { "s", "down" })
    lurek.input.bind("move_left", { "a", "left" })
    lurek.input.bind("move_right", { "d", "right" })
    lurek.input.bind("place_bomb", { "space" })
    lurek.input.bind("confirm", { "return", "kp_enter" })
    lurek.input.bind("quit", { "escape" })

    gameplay:reset_run()
    menu_state.selected = 1
    menu_state.hover = nil
    menu_state.nav_timer = 0

    menu_scene = lurek.scene.new({
        name = "menu",
        process = function(_, dt)
            update_menu_input(dt)
        end,
        draw = function()
            UI.draw_title_screen(cfg, menu_state.selected, menu_state.hover)
        end,
    })

    game_scene = lurek.scene.new({
        name = "game",
        process = function(_, dt)
            if gameplay:update(dt) then
                lurek.scene.switchTo(game_over_scene, "fade", 0.2, "linear")
            end
        end,
        draw = function()
            gameplay:draw_game_scene()
        end,
    })

    game_over_scene = lurek.scene.new({
        name = "game_over",
        process = function(_)
            if confirm_pressed() then
                gameplay:reset_run()
                lurek.scene.switchTo(game_scene, "fade", 0.2, "linear")
            end
        end,
        draw = function()
            gameplay:draw_game_over_scene()
        end,
    })

    lurek.scene.clear()
    lurek.scene.push(menu_scene)
end

function lurek.process(dt)
    if lurek.automation then
        lurek.automation.update(dt)
    end

    if quit_pressed() then
        lurek.event.quit()
        return
    end

    lurek.scene.process(dt)
end

function lurek.draw()
    lurek.scene.draw()
end
