--@api-stub: lurek.ui.beginDrag
--@api-stub: lurek.ui.clearFocus
--@api-stub: lurek.ui.draw
-- lurek.ui drag and draw.
do
    local w = lurek.ui.newCustomWidget({width=80, height=40})
    lurek.ui.beginDrag(w)
    lurek.ui.endDrag()
    lurek.ui.clearFocus()
    lurek.ui.draw()
    print("beginDrag/endDrag/clearFocus/draw ok")
end

--@api-stub: lurek.ui.drawToImage
--@api-stub: lurek.ui.dropOn
--@api-stub: lurek.ui.endDrag
-- lurek.ui drawToImage and drag drop.
do
    local img = lurek.ui.drawToImage(320, 240)
    local w = lurek.ui.newCustomWidget({width=80, height=40})
    lurek.ui.beginDrag(w)
    lurek.ui.dropOn(w)
    lurek.ui.endDrag()
    print("drawToImage ok; dropOn/endDrag ok")
end

--@api-stub: lurek.ui.flushCache
--@api-stub: lurek.ui.focusPrev
--@api-stub: lurek.ui.getActiveDrag
-- lurek.ui cache and focus.
do
    lurek.ui.flushCache()
    lurek.ui.focusPrev()
    local drag = lurek.ui.getActiveDrag()
    local focus = lurek.ui.getFocus()
    lurek.ui.clearFocus()
    print("flushCache/focusPrev ok; activeDrag:", drag, "focus:", focus)
end

--@api-stub: lurek.ui.getFocus
--@api-stub: lurek.ui.getTheme
--@api-stub: lurek.ui.getToastCount
-- lurek.ui focus and theme queries.
do
    lurek.ui.clearFocus()
    local foc = lurek.ui.getFocus()
    local theme = lurek.ui.getTheme()
    local toasts = lurek.ui.getToastCount()
    local widgets = lurek.ui.getWidgetCount()
    print("focus:", foc, "theme:", theme, "toastCount:", toasts, "widgetCount:", widgets)
end

--@api-stub: lurek.ui.getWidgetCount
--@api-stub: lurek.ui.keypressed
--@api-stub: lurek.ui.loadLayoutFile
-- lurek.ui input forwarding and layout loading.
do
    local cnt = lurek.ui.getWidgetCount()
    lurek.ui.keypressed("escape")
    local layout = lurek.ui.loadLayoutFile("content/layouts/main_menu.toml")
    lurek.ui.textinput("a")
    print("widgetCount:", cnt, "loadLayoutFile ok; textinput ok")
end

--@api-stub: lurek.ui.mousemoved
--@api-stub: lurek.ui.mousepressed
--@api-stub: lurek.ui.mousereleased
-- lurek.ui mouse input forwarding.
do
    lurek.ui.mousemoved(100, 150)
    lurek.ui.mousepressed(100, 150, 1)
    lurek.ui.mousereleased(100, 150, 1)
    lurek.ui.wheelmoved(0, -1)
    local cnt = lurek.ui.getWidgetCount()
    print("mousemoved/pressed/released/wheelmoved ok; widgets:", cnt)
end

--@api-stub: lurek.ui.newCustomWidget
--@api-stub: lurek.ui.newLayout
--@api-stub: lurek.ui.newScrollBar
-- lurek.ui constructors.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    local layout = lurek.ui.newLayout("row")
    local sb = lurek.ui.newScrollBar(true)
    print("newCustomWidget:", w, "newLayout:", layout, "newScrollBar:", sb)
end

--@api-stub: lurek.ui.newTheme
--@api-stub: lurek.ui.parseWidgetState
--@api-stub: lurek.ui.renderToImage
-- lurek.ui theme, state parsing, rendering.
do
    local th = lurek.ui.newTheme()
    local state = lurek.ui.parseWidgetState("normal")
    local result = lurek.ui.renderToImage(320, 240, "save/ui_render.png")
    print("newTheme ok; parseWidgetState:", state, "renderToImage:", result)
end

--@api-stub: lurek.ui.setDefaultTheme
--@api-stub: lurek.ui.setTheme
--@api-stub: lurek.ui.setViewport
-- lurek.ui theme and viewport.
do
    local th = lurek.ui.newTheme()
    lurek.ui.setTheme(th)
    lurek.ui.setDefaultTheme()
    lurek.ui.setViewport(1280, 720)
    local cnt = lurek.ui.getWidgetCount()
    print("setTheme/setDefaultTheme/setViewport ok; widgets:", cnt)
end

--@api-stub: lurek.ui.textinput
--@api-stub: lurek.ui.update_bindings
--@api-stub: lurek.ui.wheelmoved
-- lurek.ui text input and bindings.
do
    lurek.ui.textinput("hello")
    lurek.ui.textinput(" world")
    lurek.ui.update_bindings({dt=0.016})
    lurek.ui.wheelmoved(0, 1)
    lurek.ui.wheelmoved(1, 0)
    print("textinput/update_bindings/wheelmoved ok")
end
