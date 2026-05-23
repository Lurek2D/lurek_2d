local M = {}

local function button_hit(x, y, w, h, mx, my)
    return mx >= x and mx <= x + w and my >= y and my <= y + h
end

function M.menu_buttons(cfg)
    local bw, bh = 260, 58
    local x = (cfg.SCREEN_W - bw) * 0.5
    local y1 = 320
    local y2 = y1 + 74
    return {
        { id = "play", text = "PLAY", x = x, y = y1, w = bw, h = bh },
        { id = "quit", text = "QUIT", x = x, y = y2, w = bw, h = bh },
    }
end

function M.pick_menu_button(cfg, mx, my)
    local buttons = M.menu_buttons(cfg)
    for i = 1, #buttons do
        local b = buttons[i]
        if button_hit(b.x, b.y, b.w, b.h, mx, my) then
            return i, b.id
        end
    end
    return nil, nil
end

function M.draw_title_screen(cfg, selected_idx, hover_idx)
    lurek.render.setColor(0.06, 0.07, 0.11, 1)
    lurek.render.rectangle("fill", 0, 0, cfg.SCREEN_W, cfg.SCREEN_H)
    lurek.render.setColor(0.12, 0.14, 0.20, 1)
    lurek.render.rectangle("fill", 100, 90, cfg.SCREEN_W - 200, cfg.SCREEN_H - 180)
    lurek.render.setColor(0.28, 0.34, 0.50, 1)
    lurek.render.rectangle("line", 100, 90, cfg.SCREEN_W - 200, cfg.SCREEN_H - 180)

    lurek.render.setColor(1.0, 0.95, 0.35, 1)
    lurek.render.print("DYNA BLASTER", 318, 160, 1)
    lurek.render.setColor(0.84, 0.90, 1.0, 1)
    lurek.render.print("Arcade Bomber Demo", 360, 220, 1)

    local buttons = M.menu_buttons(cfg)
    for i = 1, #buttons do
        local b = buttons[i]
        local active = (i == selected_idx) or (i == hover_idx)
        if active then
            lurek.render.setColor(0.95, 0.75, 0.24, 1)
        else
            lurek.render.setColor(0.26, 0.30, 0.42, 1)
        end
        lurek.render.rectangle("fill", b.x, b.y, b.w, b.h)

        if active then
            lurek.render.setColor(1.0, 0.95, 0.78, 1)
        else
            lurek.render.setColor(0.73, 0.80, 0.95, 1)
        end
        lurek.render.rectangle("line", b.x, b.y, b.w, b.h)

        lurek.render.setColor(0.05, 0.06, 0.10, 1)
        lurek.render.print(b.text, b.x + 104, b.y + 20, 1)
    end

    lurek.render.setColor(0.70, 0.76, 0.90, 1)
    lurek.render.print("Enter/Click = Select   Esc = Quit", 318, 470, 1)
end

function M.draw_hud(app, cfg)
    lurek.render.setColor(0.0, 0.0, 0.0, 0.5)
    lurek.render.rectangle("fill", 12, 10, 350, 40)
    lurek.render.setColor(0.95, 0.95, 0.95, 1)
    lurek.render.print("Score: " .. app.score, 20, 20, 1)
    lurek.render.print("Lives: " .. app.lives, 190, 20, 1)

    lurek.render.setColor(0.0, 0.0, 0.0, 0.45)
    lurek.render.rectangle("fill", cfg.SCREEN_W - 380, 10, 368, 34)
    lurek.render.setColor(0.78, 0.84, 0.95, 1)
    lurek.render.print("Move: WASD/Arrows  Bomb: Space", cfg.SCREEN_W - 372, 18, 1)
end

function M.draw_game_over_overlay(app, cfg)
    local box_w, box_h = 640, 210
    local x = (cfg.SCREEN_W - box_w) * 0.5
    local y = (cfg.SCREEN_H - box_h) * 0.5

    lurek.render.setColor(0.11, 0.07, 0.08, 0.94)
    lurek.render.rectangle("fill", x, y, box_w, box_h)
    lurek.render.setColor(0.6, 0.26, 0.3, 1)
    lurek.render.rectangle("line", x, y, box_w, box_h)

    lurek.render.setColor(1.0, 0.35, 0.35, 1)
    lurek.render.print(app.game_over_reason ~= "" and app.game_over_reason or "GAME OVER", x + 140, y + 54, 1)

    lurek.render.setColor(0.95, 0.95, 0.95, 1)
    lurek.render.print("Final score: " .. tostring(app.score), x + 175, y + 120, 1)
    lurek.render.setColor(0.86, 0.9, 1.0, 1)
    lurek.render.print("Press Enter or Left Mouse to restart", x + 130, y + 160, 1)
end

return M
