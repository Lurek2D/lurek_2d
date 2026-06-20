local M = {}
local R = lurek.render
local function text(s, x, y, scale) R.setColor(1,1,1,1); R.print(tostring(s), x, y, scale or 1) end
function M.draw(config, app)
    R.setColor(0.08, 0.10, 0.14, 1); R.rectangle("fill", 32, 64, 896, 412)
    R.setColor(0.20, 0.26, 0.34, 1); R.rectangle("line", 32, 64, 896, 412)
    text(config.title, 40, 24, 1.2)
    if config.kind == "calculator" then
        R.setColor(0.02, 0.03, 0.04, 1); R.rectangle("fill", 80, 96, 360, 72)
        text(app.display, 104, 120, 2)
        local keys = {{"7","8","9","/"},{"4","5","6","*"},{"1","2","3","-"},{"0","c","=","+"}}
        for r,row in ipairs(keys) do for c,k in ipairs(row) do
            local x,y=80+(c-1)*88,190+(r-1)*58
            R.setColor(0.18,0.23,0.31,1); R.rectangle("fill",x,y,76,44)
            text(k,x+30,y+13,1)
        end end
        for i,h in ipairs(app.history) do text(h, 520, 104+i*26, 1) end
    elseif config.kind == "csv_table_browser" then
        text("Filter revenue >= " .. tostring(app.filter_min) .. "  Mean " .. string.format("%.1f", app.mean or 0), 56, 82, 1)
        text("month        region      revenue    cost", 64, 124, 1)
        for i,row in ipairs(app.rows or {{}}) do text(string.format("%-12s %-10s %-9s %s", row.month or "", row.region or "", row.revenue or "", row.cost or ""), 64, 150+i*28, 1) end
    elseif config.kind == "music_timeline" then
        text("BPM " .. app.bpm .. "  Space play/pause", 56, 82, 1)
        for p=1,10 do for s=1,16 do
            local x,y=72+s*46,112+(10-p)*28
            R.setColor(0.12,0.15,0.20,1); R.rectangle("line",x,y,38,22)
        end end
        for _,n in ipairs(app.notes) do R.setColor(0.2,0.8,1,1); R.rectangle("fill",72+n.step*46,112+(10-n.pitch)*28,38*n.len,22) end
        R.setColor(1,0.8,0.2,1); R.line(72+math.floor(app.cursor)*46,108,72+math.floor(app.cursor)*46,402)
    else
        text("Rate " .. app.rate .. "  Lifetime " .. app.life_min .. "-" .. app.life_max, 56, 82, 1)
        R.setColor(0.1,0.12,0.18,1); R.circle("line", app.x, app.y, 90)
        app.particles:render()
    end
end
return M
