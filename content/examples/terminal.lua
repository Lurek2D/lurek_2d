-- content/examples/terminal.lua
-- Auto-generated from content/examples2/terminal_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/terminal.lua






--@api: lurek.terminal.newTerminal
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(80, 24)
    local cols, rows = term:getDimensions()
    local cell_w, cell_h = term:getCellSize()
    local prompt_char = string.char(term:get(1, 1))
    terminal_log("newTerminal grid=" .. cols .. "x" .. rows .. " cell=" .. cell_w .. "x" .. cell_h .. " prompt=" .. prompt_char)
end

--@api: LTerminal:set
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(32, 8)
    term:set(5, 3, "!", 1, 0.3, 0.2, 1, 0.1, 0.1, 0.1, 1)
    local ch, fr, fg, fb = term:get(5, 3)
    local glyph = string.char(ch)
    terminal_log("set alert glyph=" .. glyph .. " fg=" .. fr .. "," .. fg .. "," .. fb)
end

--@api: LTerminal:trySet
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(32, 8)
    local ok, err = term:trySet(5, 3, "A", 1, 1, 1, 1, 0, 0, 0, 0)
    local bad_ok, bad_err = term:trySet(99, 1, string.byte("A"), 1, 1, 1, 1, 0, 0, 0, 0)
    terminal_log("trySet success=" .. tostring(ok) .. " err=" .. tostring(err))
    terminal_log("trySet invalid=" .. tostring(bad_ok) .. " reason=" .. tostring(bad_err))
end

--@api: LTerminal:get
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(32, 8)
    term:print(3, 4, "HP 84")
    local ch = term:get(4, 4)
    local ahead = term:get(5, 4)
    local pair = string.char(ch) .. string.char(ahead)
    terminal_log("get status pair=" .. pair)
end

--@api: LTerminal:print
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(40, 10)
    term:print(1, 4, "scan sector beta")
    term:print(1, 5, "fuel line stable")
    local first = string.char(term:get(1, 4))
    local second = string.char(term:get(6, 4))
    terminal_log("print wrote line prefix=" .. first .. second)
end

--@api: LTerminal:clear
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(40, 10)
    term:print(1, 6, "temporary warning")
    local before = string.char(term:get(1, 6))
    term:clear()
    local after = string.char(term:get(1, 6))
    terminal_log("clear reset row6 from " .. before .. " to " .. after)
end

--@api: LTerminal:getCellSize
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(30, 8)
    term:setCellSize(12, 20)
    local w, h = term:getCellSize()
    local cols, rows = term:getDimensions()
    terminal_log("getCellSize override=" .. w .. "x" .. h .. " for grid=" .. cols .. "x" .. rows)
end

--@api: LTerminal:setCellSize
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(30, 8)
    local before_w, before_h = term:getCellSize()
    term:setCellSize(10, 18)
    local after_w, after_h = term:getCellSize()
    terminal_log("setCellSize changed " .. before_w .. "x" .. before_h .. " to " .. after_w .. "x" .. after_h)
end

--@api: LTerminal:resetCellSize
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(30, 8)
    term:setCellSize(10, 18)
    term:resetCellSize()
    local w, h = term:getCellSize()
    local cols, rows = term:getDimensions()
    terminal_log("resetCellSize restored cell=" .. w .. "x" .. h .. " for " .. cols .. "x" .. rows)
end

--@api: LTerminal:setFont
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(30, 8)
    term:setFont(16)
    local large_w, large_h = term:getCellSize()
    term:setFont(12)
    local small_w, small_h = term:getCellSize()
    terminal_log("setFont 16px=" .. large_w .. "x" .. large_h .. " 12px=" .. small_w .. "x" .. small_h)
end

--@api: LTerminal:render
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(32, 8)
    term:print(1, 7, "rendering diagnostics")
    term:render()
    local cols, rows = term:getDimensions()
    terminal_log("render submitted terminal at " .. cols .. "x" .. rows)
end

--@api: LTerminal:renderImage
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(32, 8)
    term:print(1, 7, "image diagnostics")
    local img = term:renderImage(256, 128)
    local width = img:getWidth()
    local height = img:getHeight()
    terminal_log("renderImage produced " .. width .. "x" .. height .. " image")
end

--@api: LTerminal:getRenderStats
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(32, 8)
    local list = make_inventory_list()
    term:addWidget(list)
    term:render()
    local stats = term:getRenderStats()
    terminal_log("render stats cells=" .. tostring(stats.cells_composed))
    terminal_log("render stats widgets=" .. tostring(stats.widgets_drawn))
    terminal_log("render stats list_items=" .. tostring(stats.list_items_drawn))
end

--@api: LTerminal:autoResize
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(50, 18)
    term:setCellSize(9, 16)
    term:autoResize()
    local cols, rows = term:getDimensions()
    local w, h = term:getCellSize()
    terminal_log("autoResize fit window for " .. cols .. "x" .. rows .. " using " .. w .. "x" .. h .. " cells")
end

--@api: lurek.terminal.newLabel
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local label = lurek.terminal.newLabel(3, 2, "Shields 100%")
    local col, row = label:getPosition()
    local text = label:getText()
    local kind = label:type()
    terminal_log("newLabel type=" .. kind .. " text='" .. text .. "' at " .. col .. "," .. row)
end

--@api: lurek.terminal.newButton
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local button = lurek.terminal.newButton(4, 6, 14, 1, "Launch Drone")
    local width, height = button:getSize()
    local enabled = button:isEnabled()
    local text = button:getText()
    terminal_log("newButton '" .. text .. "' size=" .. width .. "x" .. height .. " enabled=" .. tostring(enabled))
end

--@api: lurek.terminal.newTextBox
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local input = lurek.terminal.newTextBox(2, 8, 20)
    input:setText("scan --sector beta")
    input:setMaxLength(32)
    local text = input:getText()
    local max_length = input:getMaxLength()
    terminal_log("newTextBox text='" .. text .. "' max=" .. max_length)
end

--@api: LWidget:trySetText
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local input = lurek.terminal.newTextBox(2, 8, 20)
    local ok, err = input:trySetText("reroute convoy")
    terminal_log("trySetText ok=" .. tostring(ok) .. " err=" .. tostring(err))
    terminal_log("trySetText value='" .. tostring(input:getText()) .. "'")
    terminal_log("trySetText max=" .. tostring(input:getMaxLength()))
end

--@api: lurek.terminal.newList
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local list = make_inventory_list()
    list:setSelected(2)
    local first = list:getItem(1)
    local selected = list:getSelected()
    local count = list:getItemCount()
    terminal_log("newList items=" .. count .. " first=" .. first .. " selected=" .. selected)
end

--@api: lurek.terminal.newBorder
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local border = lurek.terminal.newBorder(1, 1, 26, 9)
    border:setStyle("double")
    border:setTitle("Cargo Hold")
    local style = border:getStyle()
    local title = border:getTitle()
    terminal_log("newBorder style=" .. style .. " title='" .. title .. "'")
end

--@api: lurek.terminal.newPanel
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local panel, title, footer = make_status_panel()
    local children = panel:getChildCount()
    local header = title:getText()
    local state = footer:getText()
    terminal_log("newPanel children=" .. children .. " header='" .. header .. "' state='" .. state .. "'")
end

--@api: LTerminal:addWidget
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(48, 16)
    local panel = lurek.terminal.newPanel(1, 4, 24, 8)
    local button = lurek.terminal.newButton(3, 6, 12, 1, "Acknowledge")
    term:addWidget(panel)
    term:addWidget(button)
    terminal_log("addWidget count=" .. term:getWidgetCount())
end

--@api: LTerminal:removeWidget
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(48, 16)
    local button = lurek.terminal.newButton(3, 6, 12, 1, "Acknowledge")
    term:addWidget(lurek.terminal.newLabel(2, 4, "Warning"))
    term:addWidget(button)
    term:removeWidget(button)
    terminal_log("removeWidget remaining=" .. term:getWidgetCount())
end

--@api: LTerminal:getWidgetCount
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(48, 16)
    term:addWidget(lurek.terminal.newLabel(2, 4, "Engine Temp"))
    term:addWidget(lurek.terminal.newButton(2, 6, 12, 1, "Reset"))
    local count = term:getWidgetCount()
    terminal_log("getWidgetCount total=" .. count)
end

--@api: LTerminal:clearWidgets
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(48, 16)
    term:addWidget(lurek.terminal.newLabel(2, 4, "Engine Temp"))
    term:addWidget(lurek.terminal.newButton(2, 6, 12, 1, "Reset"))
    term:clearWidgets()
    local count = term:getWidgetCount()
    terminal_log("clearWidgets remaining=" .. count)
end

--@api: LTerminal:setFocus
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(48, 16)
    local name_box = lurek.terminal.newTextBox(2, 4, 18)
    local route_box = lurek.terminal.newTextBox(2, 6, 18)
    term:addWidget(name_box)
    term:addWidget(route_box)
    term:setFocus(route_box)
    terminal_log("setFocus route_box=" .. tostring(term:getFocused() == route_box))
end

--@api: LTerminal:getFocused
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(48, 16)
    local button = lurek.terminal.newButton(2, 4, 10, 1, "Accept")
    term:addWidget(button)
    term:setFocus(button)
    local focused = term:getFocused()
    local focused_type = focused and focused:type() or "nil"
    terminal_log("getFocused type=" .. focused_type)
end

--@api: LTerminal:keypressed
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(48, 16)
    local input = lurek.terminal.newTextBox(2, 4, 20)
    term:addWidget(input)
    term:setFocus(input)
    term:textinput("alpha beta")
    local handled = term:keypressed("ctrl+backspace")
    terminal_log("keypressed handled=" .. tostring(handled) .. " text='" .. input:getText() .. "'")
end

--@api: LTerminal:textinput
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(48, 16)
    local input = lurek.terminal.newTextBox(2, 4, 20)
    term:addWidget(input)
    term:setFocus(input)
    local handled = term:textinput("warp")
    terminal_log("textinput handled=" .. tostring(handled) .. " text='" .. input:getText() .. "'")
end

--@api: LTerminal:getDiagnostics
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = lurek.terminal.newTerminal(10, 5)
    local input = lurek.terminal.newTextBox(1, 1, 5)
    input:setMaxLength(3)
    term:addWidget(input)
    term:setFocus(input)
    term:clearDiagnostics()
    term:set(0, 1, "A", 1, 1, 1, 1, 0, 0, 0, 0)
    term:textinput("abcdef")
    local diagnostics = term:getDiagnostics()
    terminal_log("diagnostics oob=" .. tostring(diagnostics.out_of_bounds_writes))
    terminal_log("diagnostics clipped=" .. tostring(diagnostics.clipped_text))
end

--@api: LTerminal:clearDiagnostics
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = lurek.terminal.newTerminal(10, 5)
    term:set(0, 1, "A", 1, 1, 1, 1, 0, 0, 0, 0)
    local before = term:getDiagnostics()
    term:clearDiagnostics()
    local after = term:getDiagnostics()
    terminal_log("clearDiagnostics before=" .. tostring(before.out_of_bounds_writes))
    terminal_log("clearDiagnostics after=" .. tostring(after.out_of_bounds_writes))
end

--@api: LTerminal:validateWidgets
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = lurek.terminal.newTerminal(20, 10)
    local panel_a = lurek.terminal.newPanel(1, 1, 10, 4)
    local panel_b = lurek.terminal.newPanel(2, 2, 8, 3)
    local hidden = lurek.terminal.newButton(1, 5, 8, 1, "Hidden")
    hidden:setVisible(false)
    term:addWidget(panel_a)
    term:addWidget(panel_b)
    term:addWidget(hidden)
    term:setFocus(hidden)
    panel_a:addChild(panel_b)
    pcall(function()
        panel_b:addChild(panel_a)
    end)
    local valid, errors = term:validateWidgets()
    terminal_log("validateWidgets valid=" .. tostring(valid))
    terminal_log("validateWidgets errors=" .. tostring(errors and #errors or 0))
end

--@api: LTerminal:mousepressed
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(48, 16)
    local button = lurek.terminal.newButton(2, 4, 14, 1, "Confirm Jump")
    term:addWidget(button)
    click_cell(term, 2, 4, 1)
    local focused = term:getFocused()
    terminal_log("mousepressed focused_button=" .. tostring(focused == button))
end

--@api: lurek.terminal.applyTheme
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = lurek.terminal.newTerminal(40, 12)
    local themes = {"solarized_dark", "monokai", "dracula", "nord", "solarized_light"}
    for _, name in ipairs(themes) do
        lurek.terminal.applyTheme(term, name)
    end
    local cols, rows = term:getDimensions()
    terminal_log("applyTheme cycled " .. #themes .. " themes on " .. cols .. "x" .. rows)
end

--@api: lurek.terminal.pushCmdHistory
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(48, 16)
    lurek.terminal.clearCmdHistory(term)
    lurek.terminal.pushCmdHistory(term, "help")
    lurek.terminal.pushCmdHistory(term, "scan sector-beta")
    local previous = lurek.terminal.prevCmd(term)
    terminal_log("pushCmdHistory last='" .. tostring(previous) .. "' len=" .. lurek.terminal.cmdHistoryLen(term))
end

--@api: lurek.terminal.tryPushCmdHistory
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(48, 16)
    lurek.terminal.clearCmdHistory(term)
    local ok, err = lurek.terminal.tryPushCmdHistory(term, "dock")
    terminal_log("tryPushCmdHistory ok=" .. tostring(ok) .. " err=" .. tostring(err))
    terminal_log("tryPushCmdHistory len=" .. tostring(lurek.terminal.cmdHistoryLen(term)))
end

--@api: lurek.terminal.cmdHistoryLen
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(48, 16)
    lurek.terminal.clearCmdHistory(term)
    lurek.terminal.pushCmdHistory(term, "help")
    lurek.terminal.pushCmdHistory(term, "dock")
    local count = lurek.terminal.cmdHistoryLen(term)
    terminal_log("cmdHistoryLen count=" .. count)
end

--@api: lurek.terminal.pushScrollback
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(48, 16)
    lurek.terminal.setScrollbackCap(term, 8)
    lurek.terminal.pushScrollback(term, "[ok] reactor stable")
    lurek.terminal.pushScrollback(term, "[ok] path locked")
    local lines = lurek.terminal.getScrollback(term, 0, 10)
    terminal_log("pushScrollback first='" .. tostring(lines[1]) .. "' count=" .. #lines)
end

--@api: lurek.terminal.tryPushScrollback
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(48, 16)
    local ok, err = lurek.terminal.tryPushScrollback(term, "[warn] low coolant")
    terminal_log("tryPushScrollback ok=" .. tostring(ok) .. " err=" .. tostring(err))
    terminal_log("tryPushScrollback len=" .. tostring(lurek.terminal.scrollbackLen(term)))
    terminal_log("tryPushScrollback latest='" .. tostring(lurek.terminal.getScrollback(term, 0, 1)[1]) .. "'")
end

--@api: lurek.terminal.setScrollbackCap
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(48, 16)
    lurek.terminal.setScrollbackCap(term, 2)
    lurek.terminal.pushScrollback(term, "line-1")
    lurek.terminal.pushScrollback(term, "line-2")
    lurek.terminal.pushScrollback(term, "line-3")
    terminal_log("setScrollbackCap kept=" .. lurek.terminal.scrollbackLen(term) .. " line(s)")
end

--@api: lurek.terminal.addCompletion
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    lurek.terminal.clearCompletions()
    lurek.terminal.addCompletion("scan")
    lurek.terminal.addCompletion("status")
    local matches = lurek.terminal.getCompletions("s")
    local next_value = lurek.terminal.nextCompletion("s")
    terminal_log("addCompletion matches=" .. #matches .. " first='" .. tostring(next_value) .. "'")
end

--@api: lurek.terminal.nextCompletion
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    lurek.terminal.clearCompletions()
    lurek.terminal.addCompletion("scan")
    lurek.terminal.addCompletion("scope")
    local first = lurek.terminal.nextCompletion("sc")
    local second = lurek.terminal.nextCompletion("sc")
    terminal_log("nextCompletion cycled '" .. tostring(first) .. "' then '" .. tostring(second) .. "'")
end

--@api: lurek.terminal.parseAnsi
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local text = "\27[1m\27[31mALERT\27[0m nominal"
    local spans = lurek.terminal.parseAnsi(text)
    local first = spans[1]
    local second = spans[2]
    local summary = tostring(first and first.text) .. "|" .. tostring(second and second.text)
    terminal_log("parseAnsi span_count=" .. #spans .. " parts=" .. summary)
end

--@api: lurek.terminal.stripAnsi
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local raw = "\27[1m\27[32mwarp ready\27[0m now"
    local stripped = lurek.terminal.stripAnsi(raw)
    local term = make_console(36, 8)
    term:print(1, 4, stripped)
    terminal_log("stripAnsi plain='" .. stripped .. "'")
end

--@api: lurek.terminal.printAnsi
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(48, 16)
    local message = "\27[31mERROR\27[0m coolant low"
    lurek.terminal.printAnsi(term, 1, 5, message)
    local first = string.char(term:get(1, 5))
    local second = string.char(term:get(2, 5))
    terminal_log("printAnsi row5 prefix=" .. first .. second)
end

--@api: lurek.terminal.printHighlighted
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(48, 16)
    local rules = {{pattern = "fuel", fg = {255, 196, 0}}, {pattern = "ok", fg = {0, 255, 0}}}
    lurek.terminal.printHighlighted(term, 1, 6, "fuel ok", rules)
    local first = string.char(term:get(1, 6))
    local fifth = string.char(term:get(5, 6))
    terminal_log("printHighlighted row6 prefix=" .. first .. fifth)
end

--@api: lurek.terminal.getMaxCols
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local max_cols = lurek.terminal.getMaxCols()
    local term = lurek.terminal.newTerminal(math.min(80, max_cols), 10)
    local cols, rows = term:getDimensions()
    term:print(1, 3, "width budget active")
    terminal_log("getMaxCols max=" .. max_cols .. " active=" .. cols .. "x" .. rows)
end

--@api: LLabel:setColor
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local label = lurek.terminal.newLabel(2, 2, "Hull 92%")
    label:setColor(0.3, 0.8, 1.0, 1.0)
    local r, g, b, a = label:getColor()
    local text = label:getText()
    terminal_log("LLabel:setColor text='" .. text .. "' rgba=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LButton:isEnabled
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local button = lurek.terminal.newButton(2, 2, 12, 1, "Dock")
    local before = button:isEnabled()
    button:setEnabled(false)
    local after = button:isEnabled()
    terminal_log("LButton:isEnabled before=" .. tostring(before) .. " after=" .. tostring(after))
end

--@api: LList:addItem
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local list = lurek.terminal.newList(2, 2, 18, 5)
    list:addItem("Repair Kit")
    list:addItem("Antidote")
    local count = list:getItemCount()
    local last = list:getItem(2)
    terminal_log("LList:addItem count=" .. count .. " last='" .. tostring(last) .. "'")
end

--@api: LPanel:addChild
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local panel = lurek.terminal.newPanel(1, 1, 24, 8)
    local label = lurek.terminal.newLabel(2, 2, "Objective")
    local value = lurek.terminal.newLabel(2, 3, "Secure relay")
    panel:addChild(label)
    panel:addChild(value)
    terminal_log("LPanel:addChild children=" .. panel:getChildCount())
end

--@api: LTerminal:getDimensions
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(54, 18)
    local cols, rows = term:getDimensions()
    local cell_w, cell_h = term:getCellSize()
    term:print(1, rows, "footer")
    terminal_log("getDimensions grid=" .. cols .. "x" .. rows .. " cell=" .. cell_w .. "x" .. cell_h)
end

--@api: LTerminal:type
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(24, 6)
    local kind = term:type()
    local cols, rows = term:getDimensions()
    term:print(1, 4, "typed console")
    terminal_log("type kind=" .. kind .. " grid=" .. cols .. "x" .. rows)
end

--@api: LTerminal:typeOf
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(24, 6)
    local is_terminal = term:typeOf("LTerminal")
    local is_object = term:typeOf("LObject")
    local cols, rows = term:getDimensions()
    terminal_log("typeOf LTerminal=" .. tostring(is_terminal) .. " LObject=" .. tostring(is_object) .. " grid=" .. cols .. "x" .. rows)
end

--@api: lurek.terminal.clearCmdHistory
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(36, 10)
    lurek.terminal.pushCmdHistory(term, "status")
    lurek.terminal.pushCmdHistory(term, "dock")
    lurek.terminal.clearCmdHistory(term)
    local count = lurek.terminal.cmdHistoryLen(term)
    terminal_log("clearCmdHistory count=" .. count)
end

--@api: lurek.terminal.prevCmd
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(36, 10)
    lurek.terminal.clearCmdHistory(term)
    lurek.terminal.pushCmdHistory(term, "status")
    lurek.terminal.pushCmdHistory(term, "dock")
    local previous = lurek.terminal.prevCmd(term)
    terminal_log("prevCmd value='" .. tostring(previous) .. "'")
end

--@api: lurek.terminal.nextCmd
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(36, 10)
    lurek.terminal.clearCmdHistory(term)
    lurek.terminal.pushCmdHistory(term, "status")
    lurek.terminal.pushCmdHistory(term, "dock")
    lurek.terminal.prevCmd(term)
    terminal_log("nextCmd value='" .. tostring(lurek.terminal.nextCmd(term)) .. "'")
end

--@api: lurek.terminal.getScrollback
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(36, 10)
    lurek.terminal.setScrollbackCap(term, 6)
    lurek.terminal.pushScrollback(term, "alpha")
    lurek.terminal.pushScrollback(term, "beta")
    local lines = lurek.terminal.getScrollback(term, 0, 2)
    terminal_log("getScrollback first='" .. tostring(lines[1]) .. "' second='" .. tostring(lines[2]) .. "'")
end

--@api: lurek.terminal.scrollbackLen
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(36, 10)
    lurek.terminal.setScrollbackCap(term, 6)
    lurek.terminal.pushScrollback(term, "alpha")
    lurek.terminal.pushScrollback(term, "beta")
    local count = lurek.terminal.scrollbackLen(term)
    terminal_log("scrollbackLen count=" .. count)
end

--@api: lurek.terminal.removeCompletion
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    lurek.terminal.clearCompletions()
    lurek.terminal.addCompletion("scan")
    lurek.terminal.addCompletion("scope")
    lurek.terminal.removeCompletion("scope")
    local matches = lurek.terminal.getCompletions("sc")
    terminal_log("removeCompletion matches=" .. #matches .. " survivor='" .. tostring(matches[1]) .. "'")
end

--@api: lurek.terminal.resetCompletion
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    lurek.terminal.clearCompletions()
    lurek.terminal.addCompletion("scan")
    lurek.terminal.addCompletion("scope")
    local first = lurek.terminal.nextCompletion("sc")
    lurek.terminal.nextCompletion("sc")
    lurek.terminal.resetCompletion()
    terminal_log("resetCompletion restart='" .. tostring(lurek.terminal.nextCompletion("sc")) .. "' first='" .. tostring(first) .. "'")
end

--@api: lurek.terminal.clearCompletions
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    lurek.terminal.clearCompletions()
    lurek.terminal.addCompletion("dock")
    lurek.terminal.addCompletion("drop")
    lurek.terminal.clearCompletions()
    local matches = lurek.terminal.getCompletions("d")
    terminal_log("clearCompletions matches=" .. #matches)
end

--@api: lurek.terminal.getCompletions
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    lurek.terminal.clearCompletions()
    lurek.terminal.addCompletion("scan")
    lurek.terminal.addCompletion("scope")
    lurek.terminal.addCompletion("status")
    local matches = lurek.terminal.getCompletions("sc")
    terminal_log("getCompletions count=" .. #matches .. " second='" .. tostring(matches[2]) .. "'")
end

--@api: lurek.terminal.getMaxRows
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local max_rows = lurek.terminal.getMaxRows()
    local term = lurek.terminal.newTerminal(24, math.min(18, max_rows))
    local cols, rows = term:getDimensions()
    term:print(1, rows, "bottom")
    terminal_log("getMaxRows max=" .. max_rows .. " active=" .. cols .. "x" .. rows)
end

--@api: LWidget:getChild
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local panel, title = make_status_panel()
    local child = panel:getChild(1)
    local text = child and child:getText() or "nil"
    local count = panel:getChildCount()
    terminal_log("getChild count=" .. count .. " first='" .. text .. "' seed='" .. title:getText() .. "'")
end

--@api: LWidget:getChildCount
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local panel, title, footer = make_status_panel()
    local count = panel:getChildCount()
    local first = title:getText()
    local second = footer:getText()
    terminal_log("getChildCount count=" .. count .. " values='" .. first .. "'/'" .. second .. "'")
end

--@api: LWidget:addChild
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local panel = lurek.terminal.newPanel(1, 1, 24, 8)
    local title = lurek.terminal.newLabel(2, 2, "Subsystem")
    local value = lurek.terminal.newLabel(2, 3, "Life Support")
    panel:addChild(title)
    panel:addChild(value)
    terminal_log("addChild children=" .. panel:getChildCount())
end

--@api: LWidget:clearChildren
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local panel = lurek.terminal.newPanel(1, 1, 24, 8)
    panel:addChild(lurek.terminal.newLabel(2, 2, "Subsystem"))
    panel:addChild(lurek.terminal.newLabel(2, 3, "Life Support"))
    panel:clearChildren()
    local count = panel:getChildCount()
    terminal_log("clearChildren count=" .. count)
end

--@api: LWidget:removeChild
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local panel = lurek.terminal.newPanel(1, 1, 24, 8)
    local title = lurek.terminal.newLabel(2, 2, "Subsystem")
    local value = lurek.terminal.newLabel(2, 3, "Life Support")
    panel:addChild(title)
    panel:addChild(value)
    panel:removeChild(title)
    terminal_log("removeChild remaining=" .. panel:getChildCount())
end

--@api: LWidget:addItem
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local list = lurek.terminal.newList(1, 1, 18, 5)
    list:addItem("Bandage")
    list:addItem("Ration Pack")
    list:addItem("Access Card")
    local count = list:getItemCount()
    terminal_log("addItem count=" .. count .. " last='" .. tostring(list:getItem(3)) .. "'")
end

--@api: LWidget:clearItems
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local list = make_inventory_list()
    local before = list:getItemCount()
    list:clearItems()
    local after = list:getItemCount()
    terminal_log("clearItems before=" .. before .. " after=" .. after)
end

--@api: LWidget:getItem
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local list = make_inventory_list()
    list:setSelected(2)
    local first = list:getItem(1)
    local second = list:getItem(2)
    terminal_log("getItem first='" .. tostring(first) .. "' second='" .. tostring(second) .. "'")
end

--@api: LWidget:getItemCount
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local list = make_inventory_list()
    list:addItem("Toolkit")
    local count = list:getItemCount()
    local selected = list:getSelected()
    terminal_log("getItemCount count=" .. count .. " selected=" .. tostring(selected))
end

--@api: LWidget:getColor
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local label = lurek.terminal.newLabel(2, 2, "Beacon")
    label:setColor(0.25, 0.5, 0.75, 0.9)
    local r, g, b, a = label:getColor()
    local text = label:getText()
    terminal_log("getColor text='" .. text .. "' rgba=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LWidget:getStyle
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local border = lurek.terminal.newBorder(1, 1, 22, 8)
    border:setStyle("double")
    border:setTitle("Cargo")
    local style = border:getStyle()
    terminal_log("getStyle style='" .. style .. "' title='" .. border:getTitle() .. "'")
end

--@api: LWidget:getTag
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local label = lurek.terminal.newLabel(2, 2, "Objective")
    label:setTag("hud.objective")
    local tag = label:getTag()
    local text = label:getText()
    terminal_log("getTag tag='" .. tag .. "' text='" .. text .. "'")
end

--@api: LWidget:getText
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local box = lurek.terminal.newTextBox(2, 2, 20)
    box:setText("scan cargo bay")
    local text = box:getText()
    local width, height = box:getSize()
    terminal_log("getText text='" .. text .. "' size=" .. width .. "x" .. height)
end

--@api: LWidget:getTitle
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local border = lurek.terminal.newBorder(1, 1, 22, 8)
    border:setTitle("Mission Log")
    local title = border:getTitle()
    local style = border:getStyle()
    terminal_log("getTitle title='" .. title .. "' style='" .. style .. "'")
end

--@api: LWidget:getMaxLength
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local box = lurek.terminal.newTextBox(2, 2, 18)
    box:setMaxLength(40)
    box:setText("dock")
    local max_length = box:getMaxLength()
    terminal_log("getMaxLength max=" .. max_length .. " text='" .. box:getText() .. "'")
end

--@api: LWidget:getPosition
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local list = lurek.terminal.newList(5, 3, 15, 6)
    local col, row = list:getPosition()
    local width, height = list:getSize()
    local count = list:getItemCount()
    terminal_log("getPosition pos=" .. col .. "," .. row .. " size=" .. width .. "x" .. height .. " items=" .. count)
end

--@api: LWidget:getSize
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local list = lurek.terminal.newList(5, 3, 15, 6)
    local width, height = list:getSize()
    local col, row = list:getPosition()
    local count = list:getItemCount()
    terminal_log("getSize size=" .. width .. "x" .. height .. " at " .. col .. "," .. row .. " items=" .. count)
end

--@api: LWidget:getSelected
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local list = make_inventory_list()
    list:setSelected(2)
    local selected = list:getSelected()
    local item = list:getItem(selected)
    terminal_log("getSelected index=" .. tostring(selected) .. " item='" .. tostring(item) .. "'")
end

--@api: LWidget:isEnabled
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local button = lurek.terminal.newButton(2, 2, 12, 1, "Dock")
    local before = button:isEnabled()
    button:setEnabled(false)
    local after = button:isEnabled()
    terminal_log("isEnabled before=" .. tostring(before) .. " after=" .. tostring(after))
end

--@api: LWidget:isVisible
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local button = lurek.terminal.newButton(2, 2, 12, 1, "Dock")
    local before = button:isVisible()
    button:setVisible(false)
    local after = button:isVisible()
    terminal_log("isVisible before=" .. tostring(before) .. " after=" .. tostring(after))
end

--@api: LWidget:type
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local button = lurek.terminal.newButton(2, 2, 12, 1, "Dock")
    local kind = button:type()
    local text = button:getText()
    local width, height = button:getSize()
    terminal_log("widget type kind=" .. kind .. " text='" .. text .. "' size=" .. width .. "x" .. height)
end

--@api: LWidget:typeOf
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local button = lurek.terminal.newButton(2, 2, 12, 1, "Dock")
    local is_widget = button:typeOf("LWidget")
    local is_object = button:typeOf("LObject")
    local text = button:getText()
    terminal_log("widget typeOf text='" .. text .. "' LWidget=" .. tostring(is_widget) .. " LObject=" .. tostring(is_object))
end

--@api: LWidget:setColor
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local label = lurek.terminal.newLabel(2, 2, "Beacon")
    label:setColor(0.9, 0.7, 0.2, 1.0)
    local r, g, b, a = label:getColor()
    local text = label:getText()
    terminal_log("setColor text='" .. text .. "' rgba=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LWidget:setEnabled
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local label = lurek.terminal.newLabel(2, 2, "Beacon")
    label:setEnabled(false)
    local enabled = label:isEnabled()
    label:setEnabled(true)
    terminal_log("setEnabled restored=" .. tostring(label:isEnabled()) .. " initial_after_disable=" .. tostring(enabled))
end

--@api: LWidget:setVisible
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local label = lurek.terminal.newLabel(2, 2, "Beacon")
    label:setVisible(false)
    local hidden = label:isVisible()
    label:setVisible(true)
    terminal_log("setVisible hidden_state=" .. tostring(hidden) .. " restored=" .. tostring(label:isVisible()))
end

--@api: LWidget:setMaxLength
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local box = lurek.terminal.newTextBox(2, 2, 18)
    box:setMaxLength(12)
    box:setText("dock alpha")
    local max_length = box:getMaxLength()
    terminal_log("setMaxLength max=" .. max_length .. " text='" .. box:getText() .. "'")
end

--@api: LWidget:setPosition
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local box = lurek.terminal.newTextBox(1, 1, 18)
    box:setPosition(4, 6)
    local col, row = box:getPosition()
    local width, height = box:getSize()
    terminal_log("setPosition pos=" .. col .. "," .. row .. " size=" .. width .. "x" .. height)
end

--@api: LWidget:setSize
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local box = lurek.terminal.newTextBox(1, 1, 18)
    box:setSize(24, 1)
    local width, height = box:getSize()
    local text = box:getText()
    terminal_log("setSize size=" .. width .. "x" .. height .. " text='" .. text .. "'")
end

--@api: LWidget:setStyle
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local border = lurek.terminal.newBorder(1, 1, 18, 6)
    border:setStyle("double")
    border:setTitle("Map")
    local style = border:getStyle()
    terminal_log("setStyle style='" .. style .. "' title='" .. border:getTitle() .. "'")
end

--@api: LWidget:setTag
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local border = lurek.terminal.newBorder(1, 1, 18, 6)
    border:setTag("hud.map")
    border:setTitle("Map")
    local tag = border:getTag()
    terminal_log("setTag tag='" .. tag .. "' title='" .. border:getTitle() .. "'")
end

--@api: LWidget:setText
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local button = lurek.terminal.newButton(2, 2, 14, 1, "Undock")
    button:setText("Engage Warp")
    local text = button:getText()
    local width, height = button:getSize()
    terminal_log("setText text='" .. text .. "' size=" .. width .. "x" .. height)
end

--@api: LWidget:setTitle
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local border = lurek.terminal.newBorder(1, 1, 22, 8)
    border:setTitle("Subsystems")
    local title = border:getTitle()
    local style = border:getStyle()
    terminal_log("setTitle title='" .. title .. "' style='" .. style .. "'")
end

--@api: LWidget:setSelected
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local list = make_inventory_list()
    list:setSelected(3)
    local selected = list:getSelected()
    local item = list:getItem(selected)
    terminal_log("setSelected index=" .. tostring(selected) .. " item='" .. tostring(item) .. "'")
end

--@api: LWidget:setOnChange
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(48, 16)
    local input = lurek.terminal.newTextBox(2, 4, 20)
    local changes = 0
    input:setOnChange(function() changes = changes + 1 end)
    term:addWidget(input)
    term:setFocus(input)
    input:setText("dock")
    terminal_log("setOnChange changes=" .. changes .. " text='" .. input:getText() .. "'")
end

--@api: LWidget:setOnClick
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local term = make_console(48, 16)
    local button = lurek.terminal.newButton(2, 4, 14, 1, "Confirm")
    local clicks = 0
    button:setOnClick(function() clicks = clicks + 1 end)
    term:addWidget(button)
    click_cell(term, 2, 4, 1)
    terminal_log("setOnClick clicks=" .. clicks .. " text='" .. button:getText() .. "'")
end

--@api: LWidget:setOnSelect
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local list = make_inventory_list()
    local selections = 0
    list:setOnSelect(function() selections = selections + 1 end)
    list:setSelected(2)
    local item = list:getItem(list:getSelected())
    terminal_log("setOnSelect callbacks=" .. selections .. " item='" .. tostring(item) .. "'")
end

--@api: LWidget:removeItem
do
    local function terminal_log(message)
        lurek.log.info("[terminal] " .. message)
    end
    local function click_cell(term, col, row, button)
        local cell_w, cell_h = term:getCellSize()
        term:mousepressed((col - 1) * cell_w + 1, (row - 1) * cell_h + 1, button or 1)
    end
    local function make_console(cols, rows)
        local term = lurek.terminal.newTerminal(cols or 48, rows or 16)
        lurek.terminal.applyTheme(term, "nord")
        term:print(1, 1, "> status")
        term:print(1, 2, "bridge online")
        return term
    end
    local function make_inventory_list()
        local list = lurek.terminal.newList(2, 3, 18, 5)
        list:addItem("Potion")
        list:addItem("Keycard")
        list:addItem("Battery")
        return list
    end
    local function make_status_panel()
        local panel = lurek.terminal.newPanel(1, 1, 24, 8)
        local title = lurek.terminal.newLabel(2, 2, "Bridge Status")
        local footer = lurek.terminal.newLabel(2, 4, "Docking: ready")
        panel:addChild(title)
        panel:addChild(footer)
        return panel, title, footer
    end

    local list = make_inventory_list()
    local before = list:getItemCount()
    list:removeItem(1)
    local after = list:getItemCount()
    local first = list:getItem(1)
    terminal_log("removeItem before=" .. before .. " after=" .. after .. " first='" .. tostring(first) .. "'")
end

--@api: LTerminal:setShader
do
    local shader_code = [[
@fragment
fn fs(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>, @location(2) pixel: vec2<f32>) -> @location(0) vec4<f32> {
    _ = uv;
    let band = select(0.72, 1.0, (i32(pixel.y) & 1) == 0);
    return vec4<f32>(color.rgb * band + vec3<f32>(0.02, 0.08, 0.06), color.a);
}
]]
    local shader = lurek.render.newShader(shader_code, { target = "ui" })
    local term = lurek.terminal.newTerminal(40, 8)
    term:setShader(shader)
    term:print(1, 1, "terminal ui shader")
    term:print(1, 2, "CRT scanline material")
    term:render(16, 24)
    lurek.log.info("[terminal] setShader target=" .. term:getShader():getTarget())
end

--@api: LTerminal:getShader
do
    local shader_code = [[
@fragment
fn fs(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>, @location(3) resolution: vec2<f32>) -> @location(0) vec4<f32> {
    _ = uv;
    let fade = clamp(resolution.x / max(resolution.x, 1.0), 0.0, 1.0);
    return vec4<f32>(color.rgb * fade, color.a);
}
]]
    local shader = lurek.render.newShader(shader_code, { target = "ui" })
    local term = lurek.terminal.newTerminal(32, 6)
    local before = term:getShader()
    term:setShader(shader)
    local after = term:getShader()
    term:print(1, 1, "before=" .. tostring(before))
    term:print(1, 2, "after=" .. after:getTarget())
    term:render(8, 8)
end
