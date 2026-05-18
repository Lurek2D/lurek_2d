-- ui_05.lua: Visual widgets — progress bar, image widget, nine-patch, badge, spacer, separator

do --@api-stub: lurek.ui.newProgressBar
    -- create a progress bar and track fill value
    ---@type LProgressBar
    local bar = lurek.ui.newProgressBar(0, 100)
    bar:setValue(35)
    print("value:", bar:getValue())
    print("min:", bar:getMin())
    print("max:", bar:getMax())
    print("progress (normalized):", bar:getProgress())
end

do --@api-stub: lurek.ui.newProgressBar range
    -- change the progress bar range dynamically
    ---@type LProgressBar
    local bar = lurek.ui.newProgressBar(0, 50)
    bar:setValue(25)
    print("progress at 25/50:", bar:getProgress())
    bar:setRange(0, 200)
    bar:setValue(150)
    print("progress at 150/200:", bar:getProgress())
    print("new max:", bar:getMax())
end

do --@api-stub: lurek.ui.newImageWidget
    -- create an image widget and configure scale mode and tint
    ---@type LImageWidget
    local img = lurek.ui.newImageWidget()
    img:setScaleMode("fit")
    print("scale mode:", img:getScaleMode())
    img:setTint(1.0, 0.8, 0.6, 0.9)
    local r, g, b, a = img:getTint()
    print("tint:", r, g, b, a)
end

do --@api-stub: lurek.ui.newImageWidget modes
    -- test different scale modes on image widget
    ---@type LImageWidget
    local img = lurek.ui.newImageWidget()
    img:setScaleMode("fill")
    print("fill mode:", img:getScaleMode())
    img:setScaleMode("stretch")
    print("stretch mode:", img:getScaleMode())
    img:setTint(0.5, 0.5, 1.0)
    local r, g, b, a = img:getTint()
    print("blue tint:", r, g, b, a)
end

do --@api-stub: lurek.ui.newNinePatch
    -- create a nine-patch widget with border insets
    ---@type LNinePatch
    local np = lurek.ui.newNinePatch()
    np:setImageDimensions(128, 128)
    np:setInsets(16, 16, 16, 16)
    local w, h = np:getImageDimensions()
    print("image size:", w, h)
    local l, t, r, b = np:getInsets()
    print("insets:", l, t, r, b)
end

do --@api-stub: lurek.ui.newNinePatch slices
    -- retrieve computed slices from nine-patch
    ---@type LNinePatch
    local np = lurek.ui.newNinePatch()
    np:setImageDimensions(64, 64)
    np:setInsets(8, 8, 8, 8)
    np:setSize(200, 100)
    ---@type LNinePatchGetSlicesResult
    local slices = np:getSlices()
    print("slices retrieved:", slices ~= nil)
end

do --@api-stub: lurek.ui.newBadge
    -- create a notification badge with count
    ---@type LBadge
    local badge = lurek.ui.newBadge(5)
    print("count:", badge:getCount())
    print("display:", badge:getDisplayText())
    badge:setCount(120)
    print("large count display:", badge:getDisplayText())
end

do --@api-stub: lurek.ui.newSpacer
    -- create a spacer widget for layout padding
    ---@type LSpacer
    local sp = lurek.ui.newSpacer(20, 10)
    sp:setSize(40, 20)
    local w, h = sp:getSize()
    print("spacer size:", w, h)
end

do --@api-stub: lurek.ui.newSeparator
    -- create horizontal and vertical separators
    ---@type LSeparator
    local sep = lurek.ui.newSeparator(false)
    print("is vertical:", sep:isVertical())
    print("thickness:", sep:getThickness())
    sep:setThickness(2)
    print("new thickness:", sep:getThickness())
end

do --@api-stub: lurek.ui.newSeparator vertical
    -- create a vertical separator and toggle orientation
    ---@type LSeparator
    local sep = lurek.ui.newSeparator(true)
    print("vertical:", sep:isVertical())
    sep:setVertical(false)
    print("after toggle:", sep:isVertical())
    sep:setThickness(3)
    print("thickness:", sep:getThickness())
end

print("ui_05.lua")
