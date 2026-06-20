local M = {}

local ui = {}

local function find(root, id)
    if not root or not root.findById then
        return nil
    end
    local ok, node = pcall(function() return root:findById(id) end)
    if ok then
        return node
    end
    return nil
end

function M.load(cfg)
    if not lurek.ui or not lurek.ui.loadLayoutFile then
        return
    end
    local ok, root = pcall(lurek.ui.loadLayoutFile, cfg.UI_LAYOUT_PATH)
    if not ok then
        return
    end
    ui.root = root
    ui.title = find(root, "title_screen")
    ui.hud = find(root, "hud")
    ui.end_screen = find(root, "end_screen")
    ui.score = find(root, "score")
    ui.fuel = find(root, "fuel")
    ui.shield = find(root, "shield")
    ui.time = find(root, "time")
    ui.message = find(root, "message")
    ui.end_title = find(root, "end_title")
    ui.end_message = find(root, "end_message")
end

local function set_text(node, value)
    if not node then
        return
    end
    if node.setText then
        node:setText(value)
    else
        node.text = value
    end
end

function M.update(game)
    if not ui.root then
        return
    end
    local playing = game.mode == "playing"
    local ended = game.mode == "won" or game.mode == "lost"

    if ui.title then ui.title.visible = game.mode == "title" end
    if ui.hud then ui.hud.visible = playing end
    if ui.end_screen then ui.end_screen.visible = ended end

    set_text(ui.score, "Score " .. tostring(game.score))
    set_text(ui.fuel, "Fuel " .. tostring(game.fuel) .. "/" .. tostring(game.cfg.FUEL_REQUIRED))
    set_text(ui.shield, "Shield " .. tostring(math.floor(game.player.shield)))
    set_text(ui.time, "Time " .. tostring(math.ceil(game.time)))
    set_text(ui.message, game.message)

    if ended then
        set_text(ui.end_title, game.mode == "won" and "EXTRACTED" or "MISSION FAILED")
        set_text(ui.end_message, game.message .. "  Score " .. tostring(game.score))
    end
end

function M.draw_fallback(game)
    if ui.root then
        return
    end
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.print("Sector Runner", 24, 18)
    lurek.render.print("Score " .. tostring(game.score), 24, 42)
    lurek.render.print("Fuel " .. tostring(game.fuel) .. "/" .. tostring(game.cfg.FUEL_REQUIRED), 150, 42)
    lurek.render.print("Shield " .. tostring(math.floor(game.player.shield)), 260, 42)
    lurek.render.print(game.message, 24, 500)
    if lurek.timer and lurek.timer.getFPS then
        lurek.render.print("FPS " .. tostring(math.floor(lurek.timer.getFPS())), 840, 18)
    end
end

return M
