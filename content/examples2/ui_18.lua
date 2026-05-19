--@api-stub: LTextInput.getCursorPosition
--@api-stub: LTextInput.getPlaceholder
--@api-stub: LTextInput.getText
-- LTextInput text queries.
do
    local ti = lurek.ui.newTextInput()
    ti:setText("hello")
    local txt = ti:getText()
    ti:setPlaceholder("type here")
    local ph = ti:getPlaceholder()
    local cur = ti:getCursorPosition()
    print("text:", txt, "placeholder:", ph, "cursor:", cur)
end

--@api-stub: LTextInput.isFocused
--@api-stub: LTextInput.setMaxLength
--@api-stub: LTextInput.setPlaceholder
-- LTextInput focus and max length.
do
    local ti = lurek.ui.newTextInput()
    ti:setPlaceholder("Search...")
    local ph = ti:getPlaceholder()
    ti:setMaxLength(50)
    local focused = ti:isFocused()
    print("placeholder:", ph, "isFocused:", focused)
end

--@api-stub: LTextInput.setText
--@api-stub: LTheme:setStyle
--@api-stub: LTheme:type
-- LTextInput setText and LTheme type.
do
    local ti = lurek.ui.newTextInput()
    ti:setText("sample input")
    local txt = ti:getText()
    local th = lurek.ui.newTheme()
    th:setStyle("LButton", "normal", {bg_color = {0.2, 0.3, 0.8}})
    local t = th:type()
    print("text:", txt, "theme type:", t)
end

--@api-stub: LTheme:typeOf
--@api-stub: LToast.getDuration
--@api-stub: LToast.getMessage
-- LTheme identity and LToast queries.
do
    local th = lurek.ui.newTheme()
    local ok = th:typeOf("LTheme")
    local toast = lurek.ui.newToast("Level up!", 3.0)
    local dur = toast:getDuration()
    local msg = toast:getMessage()
    print("theme typeOf:", ok, "duration:", dur, "message:", msg)
end

--@api-stub: LToast.getProgress
--@api-stub: LToast.isExpired
--@api-stub: LToast.setDuration
-- LToast state.
do
    local toast = lurek.ui.newToast("Achievement unlocked", 2.0)
    local prog = toast:getProgress()
    local exp = toast:isExpired()
    toast:setDuration(5.0)
    local dur = toast:getDuration()
    print("progress:", prog, "isExpired:", exp, "duration:", dur)
end

--@api-stub: LToast.setMessage
--@api-stub: LToolbar.addButton
--@api-stub: LToolbar.addSeparator
-- LToast setMessage and LToolbar add.
do
    local toast = lurek.ui.newToast("old message", 2.0)
    toast:setMessage("new message")
    local msg = toast:getMessage()
    local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("save", "Save file")
    tb:addSeparator()
    tb:addButton("open", "Open file")
    print("toast:", msg, "toolbar buttons added ok")
end

--@api-stub: LToolbar.addSpacer
--@api-stub: LToolbar.getButton
--@api-stub: LToolbar.getOrientation
-- LToolbar spacer and queries.
do
    local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("cut", "Cut")
    tb:addSpacer(10)
    tb:addButton("paste", "Paste")
    local ori = tb:getOrientation()
    local btn = tb:getButton("cut")
    print("orientation:", ori, "button:", btn)
end

--@api-stub: LToolbar.isButtonToggled
--@api-stub: LToolbar.setButtonEnabled
--@api-stub: LToolbar.setButtonToggled
-- LToolbar button states.
do
    local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("bold", "Bold")
    tb:setButtonToggled("bold", true)
    local tog = tb:isButtonToggled("bold")
    tb:setButtonEnabled("bold", false)
    print("bold toggled:", tog)
end

--@api-stub: LToolbar.setOrientation
--@api-stub: LTooltipPanel.getDelay
--@api-stub: LTooltipPanel.getTarget
-- LToolbar orientation and LTooltipPanel queries.
do
    local tb = lurek.ui.newToolbar("horizontal")
    tb:setOrientation("vertical")
    local ori = tb:getOrientation()
    local tp = lurek.ui.newTooltipPanel("Hover help")
    local delay = tp:getDelay()
    local target = tp:getTarget()
    print("orientation:", ori, "delay:", delay, "target:", target)
end

--@api-stub: LTooltipPanel.getText
--@api-stub: LTooltipPanel.setDelay
--@api-stub: LTooltipPanel.setTarget
-- LTooltipPanel text and target.
do
    local tp = lurek.ui.newTooltipPanel("initial tip")
    local txt = tp:getText()
    tp:setDelay(0.5)
    local d = tp:getDelay()
    local btn = lurek.ui.newButton("hover me")
    tp:setTarget(btn:getId() and 1 or 1)
    print("text:", txt, "delay:", d)
end

--@api-stub: LTooltipPanel.setText
-- LTooltipPanel setText.
do
    local tp = lurek.ui.newTooltipPanel("old tip")
    tp:setText("new tooltip text")
    local txt = tp:getText()
    tp:setText("another tip")
    local txt2 = tp:getText()
    tp:setDelay(1.0)
    print("setText:", txt, "→", txt2)
end
