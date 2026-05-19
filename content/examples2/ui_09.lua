--- UI Part 9: LTabBar, LStatusBar, LToolbar

--@api-stub: LStatusBar:addSection
--@api-stub: LStatusBar:getSectionCount
--@api-stub: LStatusBar:getSectionText
--@api-stub: LStatusBar:setSectionText
-- LStatusBar: horizontal bar at screen bottom for status text sections.
do
    local sb = lurek.ui.newStatusBar()
    print("type=" .. sb:type())
    sb:addSection("Ready", 120)
    sb:addSection("Line 1", 80)
    print("sections=" .. sb:getSectionCount())
    print("text0=" .. sb:getSectionText(0))
    sb:setSectionText(0, "Loading...")
    print("text0_after=" .. sb:getSectionText(0))
end

--@api-stub: LToolbar:addButton
--@api-stub: LToolbar:addSeparator
--@api-stub: LToolbar:addSpacer
--@api-stub: LToolbar:getButton
--@api-stub: LToolbar:getOrientation
--@api-stub: LToolbar:isButtonToggled
--@api-stub: LToolbar:setButtonEnabled
--@api-stub: LToolbar:setButtonToggled
--@api-stub: LToolbar:setOrientation
-- LToolbar: icon-based button row with toggles, separators, and spacers.
do
    local bar = lurek.ui.newToolbar("horizontal")
    print("type=" .. bar:type())
    print("orientation=" .. bar:getOrientation())
    bar:addButton("btn_save", "Save file")
    bar:addButton("btn_open", "Open file")
    bar:addSeparator()
    bar:addSpacer(8)
    local btn = bar:getButton("btn_save")
    print("btn=" .. tostring(btn ~= nil))
    print("toggled=" .. tostring(bar:isButtonToggled("btn_save")))
    bar:setButtonToggled("btn_save", true)
    print("toggled_after=" .. tostring(bar:isButtonToggled("btn_save")))
    bar:setButtonEnabled("btn_open", false)
    bar:setOrientation("vertical")
    print("orientation_after=" .. bar:getOrientation())
end

--@api-stub: lurek.ui.addToast
--@api-stub: lurek.ui.loadLayout
-- Toast notifications and TOML-defined layout loading.
do
    lurek.ui.addToast({
        message = "File saved successfully",
        duration = 3.0,
        type = "info"
    })
    print("toast added")

    local layout = lurek.ui.loadLayout({
        type = "panel",
        children = {}
    })
    print("layout=" .. tostring(layout ~= nil))
end

print("ui_09.lua")
