--- Terminal Part 2: LTerminal full API + missing module-level functions

--@api-stub: LTerminal:getDimensions
--@api-stub: LTerminal:type
--@api-stub: LTerminal:typeOf
-- LTerminal full API: create, add widgets, print, render, type.
do
    local term = lurek.terminal.newTerminal(80, 24)
    print("type=" .. term:type())
    print("typeOf=" .. tostring(term:typeOf("LTerminal")))

    local cw, ch = term:getCellSize()
    print("cell_w=" .. cw .. " cell_h=" .. ch)

    local cols, rows = term:getDimensions()
    print("cols=" .. cols .. " rows=" .. rows)

    term:print(0, 0, "Hello Terminal")
    term:set(0, 1, "X", 255, 255, 255, 255, 0, 0, 0, 255)
    local cell = term:get(0, 0)
    print("cell=" .. tostring(cell))

    local lbl = lurek.terminal.newLabel(1, 1, "TestLabel")
    term:addWidget(lbl)
    print("widgets=" .. term:getWidgetCount())

    local focused = term:getFocused()
    print("focused=" .. tostring(focused ~= nil))

    term:setFocus(lbl)
    term:removeWidget(lbl)
    print("widgets_after=" .. term:getWidgetCount())
    term:clearWidgets()

    term:setFont(14)
    term:setCellSize(8, 16)
    term:autoResize()
    term:resetCellSize()

    term:keypressed("return")
    term:textinput("a")
    term:mousepressed(10, 10, 1)

    term:clear()
    term:render(0, 0)

end

--@api-stub: lurek.terminal.clearCmdHistory
--@api-stub: lurek.terminal.prevCmd
--@api-stub: lurek.terminal.nextCmd
--@api-stub: lurek.terminal.getScrollback
--@api-stub: lurek.terminal.scrollbackLen
--@api-stub: lurek.terminal.removeCompletion
--@api-stub: lurek.terminal.resetCompletion
-- Terminal module-level helpers: command history, scrollback, completions, ANSI.
do
    local term = lurek.terminal.newTerminal(40, 10)

    lurek.terminal.clearCmdHistory(term)
    local prev = lurek.terminal.prevCmd(term)
    print("prev_cmd=" .. tostring(prev))
    local next_cmd = lurek.terminal.nextCmd(term)
    print("next_cmd=" .. tostring(next_cmd))

    local sb_len = lurek.terminal.scrollbackLen(term)
    print("scrollback_len=" .. sb_len)
    local sb = lurek.terminal.getScrollback(term, 0, 5)
    print("scrollback=" .. tostring(sb ~= nil))

    lurek.terminal.addCompletion("test_completion")
    lurek.terminal.removeCompletion("test_completion")
    lurek.terminal.resetCompletion()

    local stripped = lurek.terminal.stripAnsi("\27[31mRed\27[0m")
    print("stripped=" .. stripped)

    lurek.terminal.printHighlighted(term, 0, 0, "keyword", {})
    print("highlighted done")
end

print("terminal_02.lua")
