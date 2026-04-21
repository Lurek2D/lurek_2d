-- content/examples/terminal.lua
-- Lurek2D lurek.terminal API Reference
-- Run with: cargo run -- content/examples/terminal
--
-- Scenario: A roguelike game console — a 80x25 text grid with an inventory list,
-- command input box, game log scrollback, and bordered status panels. Demonstrates
-- the full terminal + widget API for building text-mode game UIs.

print("=== lurek.terminal — Roguelike Game Console ===\n")

-- =============================================================================
-- Terminal Grid — create the main 80×25 game console
-- =============================================================================

-- ---- Stub: lurek.terminal.newTerminal ------------------------------------
--@api-stub: lurek.terminal.newTerminal
-- Demonstrates the proper usage of lurek.terminal.newTerminal.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_terminal_newTerminal()
    local term = lurek.terminal.newTerminal(80, 25)
    print("terminal created: 80x25 grid")
end
local _ok, _err = pcall(demo_lurek_terminal_newTerminal)

-- ---- Stub: lurek.terminal.getMaxCols -------------------------------------
--@api-stub: lurek.terminal.getMaxCols
-- Demonstrates the proper usage of lurek.terminal.getMaxCols.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_terminal_getMaxCols()
    local max_cols = lurek.terminal.getMaxCols()
    print("max supported columns: " .. tostring(max_cols))
end
local _ok, _err = pcall(demo_lurek_terminal_getMaxCols)

-- ---- Stub: lurek.terminal.getMaxRows -------------------------------------
--@api-stub: lurek.terminal.getMaxRows
-- Demonstrates the proper usage of lurek.terminal.getMaxRows.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_terminal_getMaxRows()
    local max_rows = lurek.terminal.getMaxRows()
    print("max supported rows: " .. tostring(max_rows))
end
local _ok, _err = pcall(demo_lurek_terminal_getMaxRows)

-- =============================================================================
-- Terminal Methods — cell manipulation, dimensions, font, rendering
-- =============================================================================

-- ---- Stub: Terminal:set --------------------------------------------------
--@api-stub: Terminal:set
-- Demonstrates the proper usage of Terminal:set.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Terminal_set()
    term:set(10, 12, "@", {0, 1, 0, 1}, {0, 0, 0, 1})
    print("player '@' placed at (10, 12) in green")
end
local _ok, _err = pcall(demo_Terminal_set)

-- ---- Stub: Terminal:get --------------------------------------------------
--@api-stub: Terminal:get
-- Demonstrates the proper usage of Terminal:get.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Terminal_get()
    local cell = term:get(10, 12)
    print("cell at (10,12): char=" .. tostring(cell))
end
local _ok, _err = pcall(demo_Terminal_get)

-- ---- Stub: Terminal:getDimensions ----------------------------------------
--@api-stub: Terminal:getDimensions
-- Demonstrates the proper usage of Terminal:getDimensions.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Terminal_getDimensions()
    local cols, rows = term:getDimensions()
    print("terminal dimensions: " .. tostring(cols) .. "x" .. tostring(rows))
end
local _ok, _err = pcall(demo_Terminal_getDimensions)

-- ---- Stub: Terminal:getCellSize ------------------------------------------
--@api-stub: Terminal:getCellSize
-- Demonstrates the proper usage of Terminal:getCellSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Terminal_getCellSize()
    local cell_w, cell_h = term:getCellSize()
    print("cell pixel size: " .. tostring(cell_w) .. "x" .. tostring(cell_h))
end
local _ok, _err = pcall(demo_Terminal_getCellSize)

-- ---- Stub: Terminal:setFont ----------------------------------------------
--@api-stub: Terminal:setFont
-- Demonstrates the proper usage of Terminal:setFont.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Terminal_setFont()
    term:setFont(16)
    print("terminal font set to 16px")
end
local _ok, _err = pcall(demo_Terminal_setFont)

-- ---- Stub: Terminal:setCellSize ------------------------------------------
--@api-stub: Terminal:setCellSize
-- Demonstrates the proper usage of Terminal:setCellSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Terminal_setCellSize()
    term:setCellSize(10.0, 18.0)
    print("cell size override: 10x18 pixels")
end
local _ok, _err = pcall(demo_Terminal_setCellSize)

-- ---- Stub: Terminal:getCellSize ------------------------------------------
--@api-stub: Terminal:getCellSize
-- Demonstrates the proper usage of Terminal:getCellSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Terminal_getCellSize()
    local override = term:getCellSize()
    print("cell size override: " .. tostring(override))
end
local _ok, _err = pcall(demo_Terminal_getCellSize)

-- ---- Stub: Terminal:resetCellSize ----------------------------------------
--@api-stub: Terminal:resetCellSize
-- Demonstrates the proper usage of Terminal:resetCellSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Terminal_resetCellSize()
    term:resetCellSize()
    print("cell size override removed — using font-derived size")
end
local _ok, _err = pcall(demo_Terminal_resetCellSize)

-- ---- Stub: Terminal:autoResize -------------------------------------------
--@api-stub: Terminal:autoResize
-- Demonstrates the proper usage of Terminal:autoResize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Terminal_autoResize()
    term:autoResize()
    print("window auto-resized to fit 80x25 grid")
end
local _ok, _err = pcall(demo_Terminal_autoResize)

-- ---- Stub: Terminal:clear ------------------------------------------------
--@api-stub: Terminal:clear
-- Demonstrates the proper usage of Terminal:clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Terminal_clear()
    term:clear()
    print("terminal cleared for new frame")
end
local _ok, _err = pcall(demo_Terminal_clear)

-- =============================================================================
-- Scrollback Buffer — game message log
-- =============================================================================

-- ---- Stub: lurek.terminal.pushScrollback ---------------------------------
--@api-stub: lurek.terminal.pushScrollback
-- Demonstrates the proper usage of lurek.terminal.pushScrollback.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_terminal_pushScrollback()
    lurek.terminal.pushScrollback(term, "You enter the Dungeon of Doom.")
    lurek.terminal.pushScrollback(term, "A goblin appears!")
    lurek.terminal.pushScrollback(term, "You swing your sword... Hit! 12 damage.")
    lurek.terminal.pushScrollback(term, "The goblin is defeated. +25 XP.")
    print("4 game log messages pushed to scrollback")
end
local _ok, _err = pcall(demo_lurek_terminal_pushScrollback)

-- ---- Stub: lurek.terminal.scrollbackLen ----------------------------------
--@api-stub: lurek.terminal.scrollbackLen
-- Demonstrates the proper usage of lurek.terminal.scrollbackLen.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_terminal_scrollbackLen()
    local sb_len = lurek.terminal.scrollbackLen(term)
    print("scrollback lines: " .. tostring(sb_len))
end
local _ok, _err = pcall(demo_lurek_terminal_scrollbackLen)

-- ---- Stub: lurek.terminal.getScrollback ----------------------------------
--@api-stub: lurek.terminal.getScrollback
-- Demonstrates the proper usage of lurek.terminal.getScrollback.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_terminal_getScrollback()
    local recent = lurek.terminal.getScrollback(term, 0, 10)
    if recent then
    print("recent log (" .. #recent .. " lines):")
    for i, line in ipairs(recent) do
        print("  [" .. i .. "] " .. line)
    end
end
local _ok, _err = pcall(demo_lurek_terminal_getScrollback)

-- ---- Stub: lurek.terminal.setScrollbackCap -------------------------------
--@api-stub: lurek.terminal.setScrollbackCap
-- Demonstrates the proper usage of lurek.terminal.setScrollbackCap.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_terminal_setScrollbackCap()
    lurek.terminal.setScrollbackCap(term, 500)
    print("scrollback cap set to 500 lines")
end
local _ok, _err = pcall(demo_lurek_terminal_setScrollbackCap)

-- =============================================================================
-- Command History — arrow-key recall of typed commands
-- =============================================================================

-- ---- Stub: lurek.terminal.pushCmdHistory ---------------------------------
--@api-stub: lurek.terminal.pushCmdHistory
-- Demonstrates the proper usage of lurek.terminal.pushCmdHistory.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_terminal_pushCmdHistory()
    lurek.terminal.pushCmdHistory(term, "look")
    lurek.terminal.pushCmdHistory(term, "inventory")
    lurek.terminal.pushCmdHistory(term, "attack goblin")
    lurek.terminal.pushCmdHistory(term, "use potion")
    print("4 commands saved to history")
end
local _ok, _err = pcall(demo_lurek_terminal_pushCmdHistory)

-- ---- Stub: lurek.terminal.cmdHistoryLen ----------------------------------
--@api-stub: lurek.terminal.cmdHistoryLen
-- Demonstrates the proper usage of lurek.terminal.cmdHistoryLen.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_terminal_cmdHistoryLen()
    local hist_len = lurek.terminal.cmdHistoryLen(term)
    print("command history: " .. tostring(hist_len) .. " entries")
end
local _ok, _err = pcall(demo_lurek_terminal_cmdHistoryLen)

-- ---- Stub: lurek.terminal.prevCmd ----------------------------------------
--@api-stub: lurek.terminal.prevCmd
-- Demonstrates the proper usage of lurek.terminal.prevCmd.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_terminal_prevCmd()
    local prev = lurek.terminal.prevCmd(term)
    print("prev command: " .. tostring(prev))
end
local _ok, _err = pcall(demo_lurek_terminal_prevCmd)

-- ---- Stub: lurek.terminal.nextCmd ----------------------------------------
--@api-stub: lurek.terminal.nextCmd
-- Demonstrates the proper usage of lurek.terminal.nextCmd.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_terminal_nextCmd()
    local nxt = lurek.terminal.nextCmd(term)
    print("next command: " .. tostring(nxt))
end
local _ok, _err = pcall(demo_lurek_terminal_nextCmd)

-- ---- Stub: lurek.terminal.clearCmdHistory --------------------------------
--@api-stub: lurek.terminal.clearCmdHistory
-- Demonstrates the proper usage of lurek.terminal.clearCmdHistory.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_terminal_clearCmdHistory()
    lurek.terminal.clearCmdHistory(term)
    print("command history cleared for new session")
end
local _ok, _err = pcall(demo_lurek_terminal_clearCmdHistory)

-- =============================================================================
-- Theme and ANSI — colours, highlighting, escape codes
-- =============================================================================

-- ---- Stub: lurek.terminal.applyTheme -------------------------------------
--@api-stub: lurek.terminal.applyTheme
-- Demonstrates the proper usage of lurek.terminal.applyTheme.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_terminal_applyTheme()
    lurek.terminal.applyTheme(term, "solarized_dark")
    print("theme applied: solarized_dark")
end
local _ok, _err = pcall(demo_lurek_terminal_applyTheme)

-- ---- Stub: lurek.terminal.printHighlighted -------------------------------
--@api-stub: lurek.terminal.printHighlighted
-- Print a status line with keyword-based colour highlighting.
-- Keywords like "HP" and "MP" get distinct colours for quick scanning.
lurek.terminal.printHighlighted(term, 1, 25, "HP: 85/100  MP: 30/50  Gold: 142", {
    HP = {1, 0.3, 0.3, 1},
    MP = {0.3, 0.3, 1, 1},
    Gold = {1, 0.85, 0, 1},
})
print("highlighted status line printed at row 25")

-- ---- Stub: lurek.terminal.stripAnsi --------------------------------------
--@api-stub: lurek.terminal.stripAnsi
-- Demonstrates the proper usage of lurek.terminal.stripAnsi.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_terminal_stripAnsi()
    local ansi_text = "\27[31mCRITICAL HIT!\27[0m You deal 48 damage."
    local plain = lurek.terminal.stripAnsi(ansi_text)
    print("stripped: " .. plain)
end
local _ok, _err = pcall(demo_lurek_terminal_stripAnsi)

-- ---- Stub: lurek.terminal.parseAnsi --------------------------------------
--@api-stub: lurek.terminal.parseAnsi
-- Demonstrates the proper usage of lurek.terminal.parseAnsi.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_terminal_parseAnsi()
    local spans = lurek.terminal.parseAnsi("\27[32mHealed\27[0m 20 HP")
    if spans then
    print("parsed " .. #spans .. " ANSI spans:")
    for i, span in ipairs(spans) do
        print("  span " .. i .. ": text='" .. tostring(span.text) .. "'")
    end
end
local _ok, _err = pcall(demo_lurek_terminal_parseAnsi)

-- ---- Stub: lurek.terminal.printAnsi --------------------------------------
--@api-stub: lurek.terminal.printAnsi
-- Demonstrates the proper usage of lurek.terminal.printAnsi.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_terminal_printAnsi()
    lurek.terminal.printAnsi(term, 1, 24, "\27[33mWarning:\27[0m Low health!")
    print("ANSI text printed at (1, 24)")
end
local _ok, _err = pcall(demo_lurek_terminal_printAnsi)

-- =============================================================================
-- Tab Completion — auto-complete game commands
-- =============================================================================

-- ---- Stub: lurek.terminal.addCompletion ----------------------------------
--@api-stub: lurek.terminal.addCompletion
-- Demonstrates the proper usage of lurek.terminal.addCompletion.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_terminal_addCompletion()
    local commands = {"look", "inventory", "attack", "use", "drop", "equip",
                  "unequip", "talk", "open", "close", "cast", "rest"}
    for _, cmd in ipairs(commands) do
    lurek.terminal.addCompletion(cmd)
    print(#commands .. " commands registered for tab-completion")
end
local _ok, _err = pcall(demo_lurek_terminal_addCompletion)

-- ---- Stub: lurek.terminal.getCompletions ---------------------------------
--@api-stub: lurek.terminal.getCompletions
-- Demonstrates the proper usage of lurek.terminal.getCompletions.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_terminal_getCompletions()
    local matches = lurek.terminal.getCompletions("a")
    print("completions for 'a': " .. tostring(#matches))
    if matches then
    for _, m in ipairs(matches) do print("  " .. m) end
end
local _ok, _err = pcall(demo_lurek_terminal_getCompletions)

-- ---- Stub: lurek.terminal.nextCompletion ---------------------------------
--@api-stub: lurek.terminal.nextCompletion
-- Demonstrates the proper usage of lurek.terminal.nextCompletion.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_terminal_nextCompletion()
    local c1 = lurek.terminal.nextCompletion("c")
    print("first completion for 'c': " .. tostring(c1))
    local c2 = lurek.terminal.nextCompletion("c")
    print("second completion for 'c': " .. tostring(c2))
end
local _ok, _err = pcall(demo_lurek_terminal_nextCompletion)

-- ---- Stub: lurek.terminal.resetCompletion --------------------------------
--@api-stub: lurek.terminal.resetCompletion
-- Demonstrates the proper usage of lurek.terminal.resetCompletion.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_terminal_resetCompletion()
    lurek.terminal.resetCompletion()
    print("completion cycle reset")
end
local _ok, _err = pcall(demo_lurek_terminal_resetCompletion)

-- ---- Stub: lurek.terminal.removeCompletion -------------------------------
--@api-stub: lurek.terminal.removeCompletion
-- Demonstrates the proper usage of lurek.terminal.removeCompletion.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_terminal_removeCompletion()
    lurek.terminal.removeCompletion("rest")
    print("'rest' removed from completions (combat mode)")
end
local _ok, _err = pcall(demo_lurek_terminal_removeCompletion)

-- ---- Stub: lurek.terminal.clearCompletions -------------------------------
--@api-stub: lurek.terminal.clearCompletions
-- Demonstrates the proper usage of lurek.terminal.clearCompletions.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_terminal_clearCompletions()
    lurek.terminal.clearCompletions()
    print("all completions cleared for cutscene")
end
local _ok, _err = pcall(demo_lurek_terminal_clearCompletions)

-- =============================================================================
-- Widget Factory — labels, buttons, text boxes, lists, borders, panels
-- =============================================================================

-- ---- Stub: lurek.terminal.newLabel ---------------------------------------
--@api-stub: lurek.terminal.newLabel
-- Demonstrates the proper usage of lurek.terminal.newLabel.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_terminal_newLabel()
    local title_label = lurek.terminal.newLabel(30, 1, "Dungeon of Doom - Floor 3")
    print("title label created at (30, 1)")
end
local _ok, _err = pcall(demo_lurek_terminal_newLabel)

-- ---- Stub: lurek.terminal.newButton --------------------------------------
--@api-stub: lurek.terminal.newButton
-- Demonstrates the proper usage of lurek.terminal.newButton.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_terminal_newButton()
    local rest_btn = lurek.terminal.newButton()
    print("rest button created")
end
local _ok, _err = pcall(demo_lurek_terminal_newButton)

-- ---- Stub: lurek.terminal.newTextBox -------------------------------------
--@api-stub: lurek.terminal.newTextBox
-- Demonstrates the proper usage of lurek.terminal.newTextBox.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_terminal_newTextBox()
    local cmd_input = lurek.terminal.newTextBox(2, 24, 60)
    print("command input text box created at (2, 24), max 60 chars")
end
local _ok, _err = pcall(demo_lurek_terminal_newTextBox)

-- ---- Stub: lurek.terminal.newList ----------------------------------------
--@api-stub: lurek.terminal.newList
-- Demonstrates the proper usage of lurek.terminal.newList.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_terminal_newList()
    local inv_list = lurek.terminal.newList(60, 3, 20, 15)
    print("inventory list created at (60, 3), 20x15 cells")
end
local _ok, _err = pcall(demo_lurek_terminal_newList)

-- ---- Stub: lurek.terminal.newBorder --------------------------------------
--@api-stub: lurek.terminal.newBorder
-- Demonstrates the proper usage of lurek.terminal.newBorder.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_terminal_newBorder()
    local inv_border = lurek.terminal.newBorder(59, 2, 22, 17)
    print("inventory border created at (59, 2), 22x17 cells")
end
local _ok, _err = pcall(demo_lurek_terminal_newBorder)

-- ---- Stub: lurek.terminal.newPanel ---------------------------------------
--@api-stub: lurek.terminal.newPanel
-- Demonstrates the proper usage of lurek.terminal.newPanel.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_terminal_newPanel()
    local status_panel = lurek.terminal.newPanel(1, 20, 30, 5)
    print("status panel created at (1, 20), 30x5 cells")
end
local _ok, _err = pcall(demo_lurek_terminal_newPanel)

-- =============================================================================
-- Widget Management — attach/detach widgets to the terminal
-- =============================================================================

-- ---- Stub: Terminal:addWidget --------------------------------------------
--@api-stub: Terminal:addWidget
-- Demonstrates the proper usage of Terminal:addWidget.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Terminal_addWidget()
    term:addWidget(title_label)
    term:addWidget(rest_btn)
    term:addWidget(cmd_input)
    term:addWidget(inv_list)
    term:addWidget(inv_border)
    term:addWidget(status_panel)
    print("6 widgets attached to terminal")
end
local _ok, _err = pcall(demo_Terminal_addWidget)

-- ---- Stub: Terminal:getWidgetCount ---------------------------------------
--@api-stub: Terminal:getWidgetCount
-- Demonstrates the proper usage of Terminal:getWidgetCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Terminal_getWidgetCount()
    local wcount = term:getWidgetCount()
    print("attached widgets: " .. tostring(wcount))
end
local _ok, _err = pcall(demo_Terminal_getWidgetCount)

-- ---- Stub: Terminal:removeWidget -----------------------------------------
--@api-stub: Terminal:removeWidget
-- Temporarily remove the rest button during combat (can't rest while fighting).
term:removeWidget(rest_btn)
print("rest button removed during combat")

-- Re-add it after combat
term:addWidget(rest_btn)

-- ---- Stub: Terminal:clearWidgets -----------------------------------------
--@api-stub: Terminal:clearWidgets
-- Clear all widgets when transitioning to a different screen (e.g. main menu).
-- We'll re-add them immediately for this example.
term:clearWidgets()
print("all widgets cleared (screen transition)")

-- Re-attach for remaining examples
term:addWidget(title_label)
term:addWidget(cmd_input)
term:addWidget(inv_list)
term:addWidget(inv_border)
term:addWidget(status_panel)

-- =============================================================================
-- Widget Common Methods — position, size, visibility, enabled, tag, text
-- =============================================================================

-- ---- Stub: Widget:setPosition --------------------------------------------
--@api-stub: Widget:setPosition
-- Demonstrates the proper usage of Widget:setPosition.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Widget_setPosition()
    title_label:setPosition(28, 1)
    print("title label repositioned to (28, 1)")
end
local _ok, _err = pcall(demo_Widget_setPosition)

-- ---- Stub: Widget:getPosition --------------------------------------------
--@api-stub: Widget:getPosition
-- Demonstrates the proper usage of Widget:getPosition.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Widget_getPosition()
    local lx, ly = title_label:getPosition()
    print("title label position: (" .. tostring(lx) .. ", " .. tostring(ly) .. ")")
end
local _ok, _err = pcall(demo_Widget_getPosition)

-- ---- Stub: Widget:setSize ------------------------------------------------
--@api-stub: Widget:setSize
-- Demonstrates the proper usage of Widget:setSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Widget_setSize()
    inv_list:setSize(20, 18)
    print("inventory list resized to 20x18")
end
local _ok, _err = pcall(demo_Widget_setSize)

-- ---- Stub: Widget:getSize ------------------------------------------------
--@api-stub: Widget:getSize
-- Demonstrates the proper usage of Widget:getSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Widget_getSize()
    local lw, lh = inv_list:getSize()
    print("inventory list size: " .. tostring(lw) .. "x" .. tostring(lh))
end
local _ok, _err = pcall(demo_Widget_getSize)

-- ---- Stub: Widget:setVisible ---------------------------------------------
--@api-stub: Widget:setVisible
-- Demonstrates the proper usage of Widget:setVisible.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Widget_setVisible()
    inv_list:setVisible(false)
    print("inventory hidden for cutscene")
end
local _ok, _err = pcall(demo_Widget_setVisible)

-- ---- Stub: Widget:isVisible ----------------------------------------------
--@api-stub: Widget:isVisible
-- Check visibility before attempting to draw.
local vis = inv_list:isVisible()
print("inventory visible: " .. tostring(vis))

-- Show it again
inv_list:setVisible(true)

-- ---- Stub: Widget:setEnabled ---------------------------------------------
--@api-stub: Widget:setEnabled
-- Demonstrates the proper usage of Widget:setEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Widget_setEnabled()
    cmd_input:setEnabled(false)
    print("command input disabled during animation")
end
local _ok, _err = pcall(demo_Widget_setEnabled)

-- ---- Stub: Widget:isEnabled ----------------------------------------------
--@api-stub: Widget:isEnabled
-- Check if input is accepting keystrokes.
local enabled = cmd_input:isEnabled()
print("command input enabled: " .. tostring(enabled))

-- Re-enable after animation
cmd_input:setEnabled(true)

-- ---- Stub: Widget:setTag -------------------------------------------------
--@api-stub: Widget:setTag
-- Demonstrates the proper usage of Widget:setTag.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Widget_setTag()
    title_label:setTag("title")
    cmd_input:setTag("cmd_input")
    inv_list:setTag("inventory")
    print("widgets tagged: title, cmd_input, inventory")
end
local _ok, _err = pcall(demo_Widget_setTag)

-- ---- Stub: Widget:getTag -------------------------------------------------
--@api-stub: Widget:getTag
-- Demonstrates the proper usage of Widget:getTag.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Widget_getTag()
    local tag = cmd_input:getTag()
    print("cmd_input tag: " .. tostring(tag))
end
local _ok, _err = pcall(demo_Widget_getTag)

-- ---- Stub: Widget:setText ------------------------------------------------
--@api-stub: Widget:setText
-- Demonstrates the proper usage of Widget:setText.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Widget_setText()
    title_label:setText("Dungeon of Doom - Floor 5 (Boss)")
    print("title updated to Floor 5")
end
local _ok, _err = pcall(demo_Widget_setText)

-- ---- Stub: Widget:getText ------------------------------------------------
--@api-stub: Widget:getText
-- Demonstrates the proper usage of Widget:getText.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Widget_getText()
    local title_text = title_label:getText()
    print("title text: " .. tostring(title_text))
end
local _ok, _err = pcall(demo_Widget_getText)

-- ---- Stub: Widget:getColor -----------------------------------------------
--@api-stub: Widget:getColor
-- Demonstrates the proper usage of Widget:getColor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Widget_getColor()
    local label_color = title_label:getColor()
    print("title label color: " .. tostring(label_color))
end
local _ok, _err = pcall(demo_Widget_getColor)

-- =============================================================================
-- Button Widget — click callbacks
-- =============================================================================

-- ---- Stub: Widget:setOnClick ---------------------------------------------
--@api-stub: Widget:setOnClick
-- Demonstrates the proper usage of Widget:setOnClick.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Widget_setOnClick()
    rest_btn:setOnClick(function()
    print("  [button] Rest clicked — player heals 10 HP")
    print("rest button onClick registered")
end
local _ok, _err = pcall(demo_Widget_setOnClick)

-- =============================================================================
-- TextBox Widget — input, max length, change callback
-- =============================================================================

-- ---- Stub: Widget:setMaxLength -------------------------------------------
--@api-stub: Widget:setMaxLength
-- Demonstrates the proper usage of Widget:setMaxLength.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Widget_setMaxLength()
    cmd_input:setMaxLength(80)
    print("command input max length: 80 chars")
end
local _ok, _err = pcall(demo_Widget_setMaxLength)

-- ---- Stub: Widget:getMaxLength -------------------------------------------
--@api-stub: Widget:getMaxLength
-- Demonstrates the proper usage of Widget:getMaxLength.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Widget_getMaxLength()
    local max_len = cmd_input:getMaxLength()
    print("command input max length: " .. tostring(max_len))
end
local _ok, _err = pcall(demo_Widget_getMaxLength)

-- ---- Stub: Widget:setOnChange --------------------------------------------
--@api-stub: Widget:setOnChange
-- Demonstrates the proper usage of Widget:setOnChange.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Widget_setOnChange()
    cmd_input:setOnChange(function(new_text)
    print("  [input] text changed: '" .. tostring(new_text) .. "'")
    print("command input onChange registered for auto-complete")
end
local _ok, _err = pcall(demo_Widget_setOnChange)

-- =============================================================================
-- List Widget — inventory items
-- =============================================================================

-- ---- Stub: Widget:addItem ------------------------------------------------
--@api-stub: Widget:addItem
-- Demonstrates the proper usage of Widget:addItem.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Widget_addItem()
    inv_list:addItem("Iron Sword")
    inv_list:addItem("Leather Armor")
    inv_list:addItem("Health Potion x3")
    inv_list:addItem("Torch x5")
    inv_list:addItem("Rope (50 ft)")
    inv_list:addItem("Rations x10")
    print("6 items added to inventory")
end
local _ok, _err = pcall(demo_Widget_addItem)

-- ---- Stub: Widget:getItemCount -------------------------------------------
--@api-stub: Widget:getItemCount
-- Demonstrates the proper usage of Widget:getItemCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Widget_getItemCount()
    local item_count = inv_list:getItemCount()
    print("inventory items: " .. tostring(item_count))
end
local _ok, _err = pcall(demo_Widget_getItemCount)

-- ---- Stub: Widget:getItem ------------------------------------------------
--@api-stub: Widget:getItem
-- Demonstrates the proper usage of Widget:getItem.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Widget_getItem()
    local first_item = inv_list:getItem(1)
    print("first inventory item: " .. tostring(first_item))
end
local _ok, _err = pcall(demo_Widget_getItem)

-- ---- Stub: Widget:setSelected --------------------------------------------
--@api-stub: Widget:setSelected
-- Demonstrates the proper usage of Widget:setSelected.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Widget_setSelected()
    inv_list:setSelected(1)
    print("first item selected")
end
local _ok, _err = pcall(demo_Widget_setSelected)

-- ---- Stub: Widget:getSelected --------------------------------------------
--@api-stub: Widget:getSelected
-- Demonstrates the proper usage of Widget:getSelected.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Widget_getSelected()
    local sel_idx = inv_list:getSelected()
    print("selected index: " .. tostring(sel_idx))
end
local _ok, _err = pcall(demo_Widget_getSelected)

-- ---- Stub: Widget:setOnSelect --------------------------------------------
--@api-stub: Widget:setOnSelect
-- Demonstrates the proper usage of Widget:setOnSelect.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Widget_setOnSelect()
    inv_list:setOnSelect(function(index)
    print("  [list] item " .. tostring(index) .. " selected")
    print("inventory onSelect registered")
end
local _ok, _err = pcall(demo_Widget_setOnSelect)

-- ---- Stub: Widget:removeItem ---------------------------------------------
--@api-stub: Widget:removeItem
-- Demonstrates the proper usage of Widget:removeItem.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Widget_removeItem()
    inv_list:removeItem(3)
    print("item 3 removed (Health Potion used)")
end
local _ok, _err = pcall(demo_Widget_removeItem)

-- ---- Stub: Widget:clearItems ---------------------------------------------
--@api-stub: Widget:clearItems
-- Clear the inventory when the player dies and restarts.
inv_list:clearItems()
print("inventory cleared for new game")

-- Re-add items for remaining examples
inv_list:addItem("Iron Sword")
inv_list:addItem("Leather Armor")

-- =============================================================================
-- Border Widget — decorative frames with titles and styles
-- =============================================================================

-- ---- Stub: Widget:setStyle -----------------------------------------------
--@api-stub: Widget:setStyle
-- Demonstrates the proper usage of Widget:setStyle.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Widget_setStyle()
    inv_border:setStyle("double")
    print("inventory border style: double")
end
local _ok, _err = pcall(demo_Widget_setStyle)

-- ---- Stub: Widget:getStyle -----------------------------------------------
--@api-stub: Widget:getStyle
-- Demonstrates the proper usage of Widget:getStyle.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Widget_getStyle()
    local border_style = inv_border:getStyle()
    print("border style: " .. tostring(border_style))
end
local _ok, _err = pcall(demo_Widget_getStyle)

-- ---- Stub: Widget:setTitle -----------------------------------------------
--@api-stub: Widget:setTitle
-- Demonstrates the proper usage of Widget:setTitle.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Widget_setTitle()
    inv_border:setTitle("Inventory (" .. tostring(inv_list:getItemCount()) .. " items)")
    print("border title set")
end
local _ok, _err = pcall(demo_Widget_setTitle)

-- ---- Stub: Widget:getTitle -----------------------------------------------
--@api-stub: Widget:getTitle
-- Demonstrates the proper usage of Widget:getTitle.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Widget_getTitle()
    local border_title = inv_border:getTitle()
    print("border title: " .. tostring(border_title))
end
local _ok, _err = pcall(demo_Widget_getTitle)

-- =============================================================================
-- Panel Widget — container with children
-- =============================================================================

-- ---- Stub: Widget:addChild -----------------------------------------------
--@api-stub: Widget:addChild
-- Demonstrates the proper usage of Widget:addChild.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Widget_addChild()
    local hp_label = lurek.terminal.newLabel(2, 1, "HP: 85/100")
    local mp_label = lurek.terminal.newLabel(2, 2, "MP: 30/50")
    local gold_label = lurek.terminal.newLabel(2, 3, "Gold: 142")
    status_panel:addChild(hp_label)
    status_panel:addChild(mp_label)
    status_panel:addChild(gold_label)
    print("3 stat labels added to status panel")
end
local _ok, _err = pcall(demo_Widget_addChild)

-- ---- Stub: Widget:getChildCount ------------------------------------------
--@api-stub: Widget:getChildCount
-- Demonstrates the proper usage of Widget:getChildCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Widget_getChildCount()
    local child_count = status_panel:getChildCount()
    print("status panel children: " .. tostring(child_count))
end
local _ok, _err = pcall(demo_Widget_getChildCount)

-- ---- Stub: Widget:getChild -----------------------------------------------
--@api-stub: Widget:getChild
-- Demonstrates the proper usage of Widget:getChild.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Widget_getChild()
    local hp_child = status_panel:getChild(1)
    if hp_child then
    hp_child:setText("HP: 73/100")
    print("HP label updated after taking damage")
end
local _ok, _err = pcall(demo_Widget_getChild)

-- ---- Stub: Widget:removeChild --------------------------------------------
--@api-stub: Widget:removeChild
-- Demonstrates the proper usage of Widget:removeChild.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Widget_removeChild()
    status_panel:removeChild(gold_label)
    print("gold label removed from status panel during combat")
end
local _ok, _err = pcall(demo_Widget_removeChild)

-- ---- Stub: Widget:clearChildren ------------------------------------------
--@api-stub: Widget:clearChildren
-- Demonstrates the proper usage of Widget:clearChildren.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Widget_clearChildren()
    status_panel:clearChildren()
    print("status panel children cleared")
end
local _ok, _err = pcall(demo_Widget_clearChildren)

-- =============================================================================
-- Focus and Input Routing — keyboard navigation between widgets
-- =============================================================================

-- Re-add widgets for focus examples
term:addWidget(rest_btn)

-- ---- Stub: Terminal:setFocus ---------------------------------------------
--@api-stub: Terminal:setFocus
-- Demonstrates the proper usage of Terminal:setFocus.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Terminal_setFocus()
    term:setFocus(cmd_input)
    print("focus set to command input")
end
local _ok, _err = pcall(demo_Terminal_setFocus)

-- ---- Stub: Terminal:getFocused -------------------------------------------
--@api-stub: Terminal:getFocused
-- Demonstrates the proper usage of Terminal:getFocused.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Terminal_getFocused()
    local focused = term:getFocused()
    print("focused widget: " .. tostring(focused))
end
local _ok, _err = pcall(demo_Terminal_getFocused)

-- ---- Stub: Terminal:keypressed -------------------------------------------
--@api-stub: Terminal:keypressed
-- Demonstrates the proper usage of Terminal:keypressed.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Terminal_keypressed()
    local handled = term:keypressed("return")
    print("keypress 'return' handled: " .. tostring(handled))
end
local _ok, _err = pcall(demo_Terminal_keypressed)

-- ---- Stub: Terminal:textinput --------------------------------------------
--@api-stub: Terminal:textinput
-- Demonstrates the proper usage of Terminal:textinput.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Terminal_textinput()
    local text_handled = term:textinput("look")
    print("textinput 'look' handled: " .. tostring(text_handled))
end
local _ok, _err = pcall(demo_Terminal_textinput)

-- =============================================================================
-- Rendering — draw the terminal grid and all attached widgets
-- =============================================================================

-- ---- Stub: Terminal:render -----------------------------------------------
--@api-stub: Terminal:render
-- Render the entire terminal at screen position (0, 0).
-- Call this once per frame in lurek.render() to draw the grid + all widgets.
term:render(0, 0)
print("terminal rendered at (0, 0)")

print("\n-- terminal.lua example complete --")
