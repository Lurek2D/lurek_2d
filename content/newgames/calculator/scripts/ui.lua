local M = {}
function M.load(config, app)
    if lurek.ui and lurek.ui.loadLayoutFile then pcall(lurek.ui.loadLayoutFile, config.ui) end
end
function M.update(config, app) end
function M.draw_fallback(config, app)
    lurek.render.setColor(1,1,1,1)
    lurek.render.print("Esc quit", 820, 24)
end
return M
