--- Terminal Module Part 2: themes, command history, scrollback, completions, ANSI, highlighting

--@api-stub: lurek.terminal.applyTheme
-- Applying color themes to a terminal.
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(80, 25)
    lurek.terminal.applyTheme(term, "solarized_dark")
    print("applied solarized_dark")
    lurek.terminal.applyTheme(term, "monokai")
    print("applied monokai")
    lurek.terminal.applyTheme(term, "dracula")
    print("applied dracula")
    lurek.terminal.applyTheme(term, "nord")
    print("applied nord")
    lurek.terminal.applyTheme(term, "solarized_light")
    print("applied solarized_light")
end

--@api-stub: lurek.terminal.pushCmdHistory / prevCmd / nextCmd
-- Command history navigation.
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(80, 25)
    lurek.terminal.pushCmdHistory(term, "help")
    lurek.terminal.pushCmdHistory(term, "status")
    lurek.terminal.pushCmdHistory(term, "inventory")
    local prev = lurek.terminal.prevCmd(term)
    print("prev 1 = " .. tostring(prev))
    prev = lurek.terminal.prevCmd(term)
    print("prev 2 = " .. tostring(prev))
    local next_cmd = lurek.terminal.nextCmd(term)
    print("next = " .. tostring(next_cmd))
end

--@api-stub: lurek.terminal.cmdHistoryLen / clearCmdHistory
-- Managing command history size.
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(80, 25)
    lurek.terminal.pushCmdHistory(term, "look")
    lurek.terminal.pushCmdHistory(term, "go north")
    lurek.terminal.pushCmdHistory(term, "take sword")
    print("history len = " .. lurek.terminal.cmdHistoryLen(term))
    lurek.terminal.clearCmdHistory(term)
    print("after clear len = " .. lurek.terminal.cmdHistoryLen(term))
end

--@api-stub: lurek.terminal.pushScrollback / scrollbackLen / getScrollback
-- Scrollback buffer operations.
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(80, 25)
    lurek.terminal.pushScrollback(term, "Welcome to the dungeon.")
    lurek.terminal.pushScrollback(term, "You see a dark corridor.")
    lurek.terminal.pushScrollback(term, "A torch flickers on the wall.")
    lurek.terminal.pushScrollback(term, "You hear footsteps.")
    lurek.terminal.pushScrollback(term, "An enemy appears!")
    print("scrollback len = " .. lurek.terminal.scrollbackLen(term))
    local lines = lurek.terminal.getScrollback(term, 0, 3)
    print("recent 3 lines:")
    for i, line in ipairs(lines) do
        print("  " .. i .. ": " .. line)
    end
end

--@api-stub: lurek.terminal.setScrollbackCap
-- Limiting scrollback buffer size.
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(80, 25)
    lurek.terminal.setScrollbackCap(term, 100)
    for i = 1, 150 do
        lurek.terminal.pushScrollback(term, "Line " .. i)
    end
    print("scrollback after overflow = " .. lurek.terminal.scrollbackLen(term))
end

--@api-stub: lurek.terminal.addCompletion / getCompletions / clearCompletions
-- Registering and querying completions.
do
    lurek.terminal.clearCompletions()
    lurek.terminal.addCompletion("help")
    lurek.terminal.addCompletion("health")
    lurek.terminal.addCompletion("heal")
    lurek.terminal.addCompletion("inventory")
    lurek.terminal.addCompletion("inspect")
    local matches = lurek.terminal.getCompletions("he")
    print("matches for 'he':")
    for _, m in ipairs(matches) do
        print("  " .. m)
    end
    local inv = lurek.terminal.getCompletions("in")
    print("matches for 'in' = " .. #inv)
end

--@api-stub: lurek.terminal.nextCompletion / resetCompletion / removeCompletion
-- Cycling through completion candidates.
do
    lurek.terminal.clearCompletions()
    lurek.terminal.addCompletion("attack")
    lurek.terminal.addCompletion("attune")
    lurek.terminal.addCompletion("attract")
    lurek.terminal.resetCompletion()
    local c1 = lurek.terminal.nextCompletion("att")
    print("cycle 1 = " .. tostring(c1))
    local c2 = lurek.terminal.nextCompletion("att")
    print("cycle 2 = " .. tostring(c2))
    local c3 = lurek.terminal.nextCompletion("att")
    print("cycle 3 = " .. tostring(c3))
    lurek.terminal.removeCompletion("attune")
    lurek.terminal.resetCompletion()
    local after = lurek.terminal.nextCompletion("att")
    print("after remove = " .. tostring(after))
end

--@api-stub: lurek.terminal.parseAnsi
-- Parsing ANSI escape sequences into spans.
do
    local ansiText = "\27[1;31mError:\27[0m File not found"
    local spans = lurek.terminal.parseAnsi(ansiText)
    print("span count = " .. #spans)
    for i, span in ipairs(spans) do
        print("  span " .. i .. ": text='" .. span.text .. "' bold=" .. tostring(span.bold))
    end
end

--@api-stub: lurek.terminal.stripAnsi
-- Removing ANSI codes from text.
do
    local colored = "\27[32mSuccess\27[0m: Operation complete"
    local plain = lurek.terminal.stripAnsi(colored)
    print("stripped = " .. plain)
    print("length original = " .. #colored)
    print("length stripped = " .. #plain)
end

--@api-stub: lurek.terminal.printAnsi
-- Rendering ANSI-colored text onto the grid.
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(80, 25)
    lurek.terminal.printAnsi(term, 1, 1, "\27[1;33mWarning:\27[0m Low health")
    lurek.terminal.printAnsi(term, 1, 2, "\27[34mInfo:\27[0m Checkpoint saved")
    lurek.terminal.printAnsi(term, 1, 3, "\27[1;31mCritical:\27[0m System failure")
    print("ANSI text rendered to grid")
end

--@api-stub: lurek.terminal.printHighlighted
-- Syntax-highlighted text with custom rules.
do
    ---@type LTerminal
    local term = lurek.terminal.newTerminal(80, 25)
    local rules = {
        { pattern = "local%s+%w+", fg = { r = 100, g = 150, b = 255 } },
        { pattern = '\"[^\"]*\"', fg = { r = 200, g = 200, b = 100 } },
        { pattern = "%-%-%s.*$", fg = { r = 100, g = 100, b = 100 } },
        { pattern = "%d+", fg = { r = 255, g = 150, b = 50 } },
    }
    local code = 'local name = "hero" -- player name'
    lurek.terminal.printHighlighted(term, 1, 1, code, rules)
    print("highlighted code rendered")
    local code2 = "local score = 42"
    lurek.terminal.printHighlighted(term, 1, 2, code2, rules)
    print("highlighted code2 rendered")
end

--@api-stub: lurek.terminal.getMaxCols / getMaxRows
-- Querying terminal size limits.
do
    local maxCols = lurek.terminal.getMaxCols()
    local maxRows = lurek.terminal.getMaxRows()
    print("max cols = " .. maxCols)
    print("max rows = " .. maxRows)
end

--@api-stub: LWidget color and visibility
-- Widget appearance control.
do
    ---@type LWidget
    local label = lurek.terminal.newLabel(1, 1, "Colored")
    label:setColor(0.2, 0.8, 0.3, 1)
    local r, g, b, a = label:getColor()
    print("color = " .. r .. ", " .. g .. ", " .. b .. ", " .. a)
    print("visible = " .. tostring(label:isVisible()))
    label:setVisible(false)
    print("after hide = " .. tostring(label:isVisible()))
    label:setVisible(true)
end

--@api-stub: LWidget enabled and tag
-- Widget enable state and tagging.
do
    ---@type LWidget
    local btn = lurek.terminal.newButton(1, 1, 10, 1, "Submit")
    print("enabled = " .. tostring(btn:isEnabled()))
    btn:setEnabled(false)
    print("after disable = " .. tostring(btn:isEnabled()))
    btn:setEnabled(true)
    btn:setTag("submit_button")
    print("tag = " .. btn:getTag())
end

--@api-stub: LWidget list item manipulation
-- Adding, removing, and querying list items.
do
    ---@type LWidget
    local list = lurek.terminal.newList(1, 1, 20, 5)
    list:addItem("Apple")
    list:addItem("Banana")
    list:addItem("Cherry")
    list:addItem("Date")
    print("items = " .. list:getItemCount())
    list:removeItem(2)
    print("after remove idx 2: items = " .. list:getItemCount())
    print("item 2 now = " .. list:getItem(2))
    list:clearItems()
    print("after clear: items = " .. list:getItemCount())
end

--@api-stub: LWidget panel children
-- Managing panel child widgets.
do
    ---@type LWidget
    local panel = lurek.terminal.newPanel(1, 1, 40, 20)
    local child1 = lurek.terminal.newLabel(2, 2, "Label A")
    local child2 = lurek.terminal.newLabel(2, 4, "Label B")
    local child3 = lurek.terminal.newButton(2, 6, 10, 1, "Btn")
    panel:addChild(child1)
    panel:addChild(child2)
    panel:addChild(child3)
    print("children = " .. panel:getChildCount())
    panel:removeChild(child2)
    print("after remove = " .. panel:getChildCount())
    panel:clearChildren()
    print("after clear = " .. panel:getChildCount())
end

print("terminal_01.lua")
