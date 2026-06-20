local M = {}
function M.new(config)
    return { display = "0", acc = 0, op = "+", history = {}, cursor = 1, press = M.press }
end
local function push(app, label)
    app.history[#app.history + 1] = label
    if #app.history > 8 then table.remove(app.history, 1) end
end
function M.press(app, key)
    if key:match("%d") then app.display = app.display == "0" and key or app.display .. key; return end
    if key == "c" then app.display = "0"; app.acc = 0; app.op = "+"; push(app, "Clear"); return end
    local n = tonumber(app.display) or 0
    if key == "=" then
        if app.op == "+" then app.acc = app.acc + n elseif app.op == "-" then app.acc = app.acc - n elseif app.op == "*" then app.acc = app.acc * n elseif app.op == "/" and n ~= 0 then app.acc = app.acc / n end
        app.display = tostring(app.acc); push(app, "= " .. app.display); return
    end
    if key == "+" or key == "-" or key == "*" or key == "/" then app.acc = n; app.op = key; app.display = "0"; push(app, tostring(n) .. " " .. key) end
end
function M.update(app, dt) end
return M
