-- ui_04.lua: Dialogs, windows, toolbar, statusbar

--@api-stub: lurek.ui.newDialog
do
    -- create a modal dialog with title, buttons, and close callback
    ---@type LDialog
    local dlg = lurek.ui.newDialog("Confirm Action")
    dlg:setModal(true)
    dlg:addButton("OK")
    dlg:addButton("Cancel")
    dlg:setOnClose(function(idx)
        print("dialog closed, widget index:", idx)
    end)
    dlg:open()
    print("dialog title:", dlg:getTitle())
    print("is modal:", dlg:isModal())
    print("is open:", dlg:isOpen())
end

--@api-stub: lurek.ui.newDialog
do
    -- set a panel as dialog content widget
    ---@type LDialog
    local dlg = lurek.ui.newDialog("Settings")
    ---@type LPanel
    local panel = lurek.ui.newPanel()
    panel:setSize(300, 200)
    dlg:setContent(1)
    print("dialog content index:", dlg:getContent())
    dlg:setTitle("Advanced Settings")
    print("new title:", dlg:getTitle())
    dlg:close()
    print("after close, is open:", dlg:isOpen())
end

--@api-stub: lurek.ui.newWindow
do
    -- create a draggable, resizable GUI window
    ---@type LGuiWindow
    local win = lurek.ui.newWindow("Editor")
    win:setDraggable(true)
    win:setResizable(true)
    win:setCloseable(true)
    win:setOnClose(function(idx)
        print("window closed, widget index:", idx)
    end)
    print("window title:", win:getTitle())
    print("is draggable:", win:isDraggable())
    print("is resizable:", win:isResizable())
    print("is closeable:", win:isCloseable())
end

--@api-stub: lurek.ui.newWindow
do
    -- change window title and toggle properties
    ---@type LGuiWindow
    local win = lurek.ui.newWindow("Inspector")
    win:setTitle("Object Inspector")
    print("title:", win:getTitle())
    win:setDraggable(false)
    print("draggable after disable:", win:isDraggable())
    win:setResizable(false)
    print("resizable after disable:", win:isResizable())
    win:setCloseable(false)
    print("closeable after disable:", win:isCloseable())
end

--@api-stub: lurek.ui.newToolbar
do
    -- create a horizontal toolbar with buttons and separators
    ---@type LToolbar
    local tb = lurek.ui.newToolbar("horizontal")
    tb:addButton("save", "Save file")
    tb:addButton("load", "Load file")
    tb:addSeparator()
    tb:addButton("undo", "Undo last action")
    tb:addSpacer()
    tb:addButton("settings", "Open settings")
    print("orientation:", tb:getOrientation())
end

--@api-stub: lurek.ui.newToolbar
do
    -- toggle toolbar buttons and check state
    ---@type LToolbar
    local tb = lurek.ui.newToolbar("vertical")
    tb:setOrientation("vertical")
    tb:addButton("bold", "Bold text")
    tb:addButton("italic", "Italic text")
    tb:setButtonToggled("bold", true)
    print("bold toggled:", tb:isButtonToggled("bold"))
    tb:setButtonEnabled("italic", false)
    ---@type LToolbarGetButtonResult
    local info = tb:getButton("bold")
    print("bold info - enabled:", info.enabled, "toggled:", info.toggled)
end

--@api-stub: lurek.ui.newStatusBar
do
    -- create a status bar with multiple sections
    ---@type LStatusBar
    local sb = lurek.ui.newStatusBar()
    sb:addSection("Ready", 150)
    sb:addSection("Line: 1, Col: 1", 120)
    sb:addSection("UTF-8", 80)
    print("section count:", sb:getSectionCount())
    print("section 1:", sb:getSectionText(1))
    print("section 2:", sb:getSectionText(2))
end

--@api-stub: lurek.ui.newStatusBar
do
    -- update status bar sections dynamically
    ---@type LStatusBar
    local sb = lurek.ui.newStatusBar()
    sb:addSection("Idle")
    sb:addSection("0 errors")
    sb:setSectionText(1, "Building...")
    sb:setSectionText(2, "3 warnings")
    print("updated section 1:", sb:getSectionText(1))
    print("updated section 2:", sb:getSectionText(2))
    sb:setSectionCount(3)
    sb:setSectionText(3, "Branch: main")
    print("section count after expand:", sb:getSectionCount())
end

print("ui_04.lua")
