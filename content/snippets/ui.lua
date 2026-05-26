-- content/snippets/ui.lua
-- Handcrafted snippets for lurek.ui — widgets, layout, animation, flex, input fields.
-- API surface covered: newButton, newLabel, newPanel, newLayout, newTextInput, newSlider,
--   newCheckbox, newDropdown, newProgressBar; LUiWidget base: setPosition, setSize,
--   setVisible, setEnabled, setAlpha, animateAlpha, fadeIn, fadeOut, animatePosition,
--   slideIn, slideOut, setMargin, setPadding, setFlexGrow, setFlexShrink, setMinSize,
--   setMaxSize, addChild, removeChild, setId, setTooltip, setZOrder, containsPoint;
--   LButton: setOnClick; LTextInput: getText, setText; LSlider: getValue, setValue;
--   lurek.ui.update, draw, getRoot, getWidgetCount, clearAll.

local panel = lurek.ui.newPanel()
local score_lbl = lurek.ui.newLabel("Score: 0")
local field = lurek.ui.newTextInput()
local toolbar = lurek.ui.newLayout("horizontal")
local row = lurek.ui.newLayout("horizontal")
local COLS = 5
local card = lurek.ui.newPanel()
local toast = lurek.ui.newLabel("Achievement unlocked!")
local dialog = lurek.ui.newPanel()
local vol_label = lurek.ui.newLabel("Volume: 80%")
local chk = lurek.ui.newCheckbox("Enable subtitles")
local langs = { "English", "Polish", "German", "French", "Japanese" }
local bar = lurek.ui.newProgressBar(0, 100)
local tooltip_target = lurek.ui.newButton("Skill: Fireball")
local backdrop = lurek.ui.newPanel()

-- ─────────────────────────────────────────────────────────────
-- BASIC WIDGET SETUP
-- ─────────────────────────────────────────────────────────────

-- @snippet lurek.ui.panel_button_status_strip
-- @prefix lk-ui-panel-button-status
-- @module ui
-- @description Use for a persistent HUD status strip with action button. Combines a panel container, a label for dynamic status text, and a button with callback — the minimal pattern for any interactive overlay widget.
-- @body
local SNIP_1_panel = lurek.ui.newPanel()
panel:setPosition(20, 20)
panel:setSize(220, 50)

local lbl = lurek.ui.newLabel("Status: idle")
lbl:setPosition(8, 8)
lbl:setSize(130, 28)

local btn = lurek.ui.newButton("Action")
btn:setPosition(140, 8)
btn:setSize(72, 28)
btn:setOnClick(function()
    lbl:setText("Status: active")
    print("action triggered")
end)

panel:addChild(lbl)
panel:addChild(btn)
print("strip children=" .. panel:getChildCount())
-- @end

-- @snippet lurek.ui.label_score_update
-- @prefix lk-ui-label-score
-- @module ui
-- @description Use to show and update a score or counter label that changes frequently. Create once at init, call setText each frame or on event — no widget rebuild required.
-- @body
local SNIP_1_score_lbl = lurek.ui.newLabel("Score: 0")
score_lbl:setPosition(600, 12)
score_lbl:setSize(160, 30)
score_lbl:setId("score_label")

local score = 0
local function add_score(pts)
    score = score + pts
    score_lbl:setText("Score: " .. score)
end

add_score(100)
print("label text=" .. score_lbl:getText())
-- @end

-- @snippet lurek.ui.button_enable_disable_guard
-- @prefix lk-ui-button-enable-guard
-- @module ui
-- @description Use to disable action buttons during async operations, cutscenes, or cooldown periods to prevent double-activation. Re-enable when the condition clears.
-- @body
local SNIP_1_btn = lurek.ui.newButton("Confirm")
btn:setPosition(100, 100)
btn:setSize(120, 36)
btn:setId("confirm_btn")
btn:setTooltip("Submit your selection")
btn:setOnClick(function()
    print("confirmed")
    btn:setEnabled(false)  -- prevent double-click during processing
end)

print("enabled=" .. tostring(btn:isEnabled()))
-- re-enable after async: btn:setEnabled(true)
-- @end

-- @snippet lurek.ui.input_field_validation
-- @prefix lk-ui-input-validate
-- @module ui
-- @description Use for name entry, chat input, or any text field that must validate before submit. Reads getText(), checks constraints, and shows error label feedback without leaving the screen.
-- @body
local SNIP_1_field = lurek.ui.newTextInput()
field:setPosition(80, 150)
field:setSize(200, 32)

local error_lbl = lurek.ui.newLabel("")
error_lbl:setPosition(80, 186)
error_lbl:setSize(200, 20)
error_lbl:setVisible(false)

local submit_btn = lurek.ui.newButton("OK")
submit_btn:setPosition(288, 150)
submit_btn:setSize(50, 32)
submit_btn:setOnClick(function()
    local name = field:getText()
    if #name < 2 then
        error_lbl:setText("Name too short")
        error_lbl:setVisible(true)
    else
        error_lbl:setVisible(false)
        print("name accepted: " .. name)
    end
end)
-- @end

-- ─────────────────────────────────────────────────────────────
-- LAYOUT SYSTEM
-- ─────────────────────────────────────────────────────────────

-- @snippet lurek.ui.horizontal_toolbar
-- @prefix lk-ui-horizontal-toolbar
-- @module ui
-- @description Use to build a toolbar of buttons that auto-spaces itself. newLayout with "horizontal" direction + spacing handles positioning automatically — adding or removing buttons does not require manual coordinate updates.
-- @body
local SNIP_1_toolbar = lurek.ui.newLayout("horizontal")
toolbar:setPosition(0, 0)
toolbar:setSize(800, 40)
toolbar:setSpacing(4)
toolbar:setJustify("start")

local labels = { "File", "Edit", "View", "Help" }
for _, txt in ipairs(labels) do
    local b = lurek.ui.newButton(txt)
    b:setSize(80, 32)
    b:setMargin(0, 2, 0, 2)
    toolbar:addChild(b)
end
print("toolbar children=" .. toolbar:getChildCount())
-- @end

-- @snippet lurek.ui.flex_sidebar_content
-- @prefix lk-ui-flex-sidebar
-- @module ui
-- @description Use to split a panel into a fixed sidebar and a flexible content area. setFlexGrow(0) fixes the sidebar width; setFlexGrow(1) lets the content area expand to fill remaining space without hardcoding coordinates.
-- @body
local SNIP_1_row = lurek.ui.newLayout("horizontal")
row:setPosition(0, 40)
row:setSize(800, 560)
row:setSpacing(0)

local sidebar = lurek.ui.newPanel()
sidebar:setSize(180, 560)
sidebar:setFlexGrow(0)
sidebar:setFlexShrink(0)

local content = lurek.ui.newPanel()
content:setFlexGrow(1)

row:addChild(sidebar)
row:addChild(content)
print("sidebar grow=" .. sidebar:getFlexGrow() .. " content grow=" .. content:getFlexGrow())
-- @end

-- @snippet lurek.ui.grid_inventory_slots
-- @prefix lk-ui-grid-inventory
-- @module ui
-- @description Use for inventory, hotbar, or card selection grids. newLayout with "grid" direction + setColumns handles the row wrapping — position stays correct when slots are added or removed dynamically.
-- @body
local SNIP_1_COLS  = 5
local SLOT_W = 52
local SLOT_H = 52

local grid = lurek.ui.newLayout("grid")
grid:setPosition(60, 200)
grid:setSize(COLS * SLOT_W + (COLS - 1) * 4, 300)
grid:setColumns(COLS)
grid:setSpacing(4)

for i = 1, 15 do
    local slot = lurek.ui.newPanel()
    slot:setSize(SLOT_W, SLOT_H)
    slot:setId("slot_" .. i)
    grid:addChild(slot)
end
print("grid slots=" .. grid:getChildCount())
-- @end

-- @snippet lurek.ui.padding_margin_content_box
-- @prefix lk-ui-padding-margin
-- @module ui
-- @description Use to add comfortable inner spacing (padding) and outer gap (margin) to any widget. setPadding controls the content box inset; setMargin controls gap to siblings in a layout container.
-- @body
local SNIP_1_card = lurek.ui.newPanel()
card:setSize(240, 100)
card:setPadding(12, 16, 12, 16)   -- top, right, bottom, left
card:setMargin(8)                  -- uniform 8px gap between cards

local title = lurek.ui.newLabel("Card Title")
title:setSize(200, 24)
card:addChild(title)

local t, r, b, l = card:getPadding()
print(string.format("padding t=%d r=%d b=%d l=%d", t, r, b, l))
-- @end

-- ─────────────────────────────────────────────────────────────
-- ANIMATION
-- ─────────────────────────────────────────────────────────────

-- @snippet lurek.ui.toast_fade_notice
-- @prefix lk-ui-toast-fade
-- @module ui
-- @description Use for transient notification toasts. The widget slides in, waits, then fades out with hide_on_complete so it is automatically hidden when done — no manual timer polling needed.
-- @body
local SNIP_1_toast = lurek.ui.newLabel("Achievement unlocked!")
toast:setPosition(250, 540)
toast:setSize(300, 36)
toast:setAlpha(0)

-- show sequence:
toast:setVisible(true)
toast:animateAlpha(1.0, 0.3)      -- fade in over 300 ms
-- after delay: toast:animateAlpha(0.0, 0.5, true)   -- fade out and hide
print("toast animating=" .. tostring(toast:isAnimating()))
-- @end

-- @snippet lurek.ui.dialog_slide_in_out
-- @prefix lk-ui-dialog-slide
-- @module ui
-- @description Use for modal dialogs, pause menus, and contextual panels. slideIn brings the widget on-screen from an off-screen offset; slideOut sends it back. Pair with cancelAnimations to interrupt when the player presses ESC.
-- @body
local SNIP_1_dialog = lurek.ui.newPanel()
dialog:setPosition(200, 200)
dialog:setSize(400, 250)
dialog:setVisible(false)

local function open_dialog()
    dialog:setVisible(true)
    dialog:setAlpha(0)
    dialog:fadeIn()
    dialog:slideIn(0, -300)   -- enter from above
end

local function close_dialog()
    dialog:cancelAnimations()
    dialog:slideOut(0, -300)
    -- listen for animating = false, then: dialog:setVisible(false)
end

open_dialog()
print("dialog visible=" .. tostring(dialog:isVisible()))
_ = close_dialog
-- @end

-- @snippet lurek.ui.animated_position_tweens
-- @prefix lk-ui-tween-position
-- @module ui
-- @description Use for animated card moves, ability icon repositioning, and drag-to-drop previews. animatePosition drives the widget to a world-space target over a duration; cancel returns it instantly for emergency dismissal.
-- @body
local SNIP_1_card = lurek.ui.newPanel()
card:setPosition(100, 400)
card:setSize(80, 120)

-- animate to discard pile position
card:animatePosition(600, 480, 0.4)
print("card animating=" .. tostring(card:isAnimating()))

-- cancel if player picks it back up:
-- card:cancelAnimations()
-- @end

-- ─────────────────────────────────────────────────────────────
-- INTERACTIVE CONTROLS
-- ─────────────────────────────────────────────────────────────

-- @snippet lurek.ui.slider_volume_control
-- @prefix lk-ui-slider-volume
-- @module ui
-- @description Use for any continuous setting: volume, brightness, sensitivity. Create a labeled slider; read getValue() on change callback to apply the setting to the audio bus or engine config.
-- @body
local SNIP_1_vol_label  = lurek.ui.newLabel("Volume: 80%")
vol_label:setPosition(40, 80)
vol_label:setSize(160, 24)

local slider = lurek.ui.newSlider(0, 100)   -- min, max
slider:setPosition(40, 108)
slider:setSize(200, 24)
slider:setOnChange(function()
    local val = slider:getValue()
    vol_label:setText(string.format("Volume: %.0f%%", val))
    -- lurek.audio.setBusVolume("master", val / 100)
    print("volume=" .. val)
end)
print("slider value=" .. slider:getValue())
-- @end

-- @snippet lurek.ui.checkbox_option_binding
-- @prefix lk-ui-checkbox
-- @module ui
-- @description Use for binary settings (fullscreen, subtitles, inverted controls). Checkbox is the clearest affordance for on/off options in settings menus; read isChecked() in the callback to apply the change immediately.
-- @body
local SNIP_1_chk = lurek.ui.newCheckbox("Enable subtitles")
chk:setPosition(40, 160)
chk:setSize(220, 28)
chk:setChecked(true)
chk:setOnChange(function()
    local on = chk:isChecked()
    print("subtitles=" .. tostring(on))
    -- apply subtitle setting to game state
end)
print("checked=" .. tostring(chk:isChecked()))
-- @end

-- @snippet lurek.ui.dropdown_language_select
-- @prefix lk-ui-dropdown-language
-- @module ui
-- @description Use for language selection, difficulty, or any enum-style setting. Dropdown collapses to a single line when closed — good for dense settings menus where screen space is limited.
-- @body
local SNIP_1_langs = { "English", "Polish", "German", "French", "Japanese" }
-- NOTE: newDropdown is not yet in the API; use newComboBox when available
-- or implement with newPanel + newButton per option.
local lang_idx = 1
local function set_language(idx)
    lang_idx = idx
    print("language=" .. langs[idx] .. " idx=" .. idx)
    -- reload locale strings
end
set_language(2)
print("selected idx=" .. lang_idx)
-- @end

-- @snippet lurek.ui.progress_bar_loading
-- @prefix lk-ui-progress-bar
-- @module ui
-- @description Use for loading screens, ability charge bars, and health or XP indicators. setValue drives the fill fraction; update the label text in sync to avoid separate string-update overhead.
-- @body
local SNIP_1_bar = lurek.ui.newProgressBar(0, 100)
bar:setPosition(200, 360)
bar:setSize(400, 28)
bar:setValue(35)

local pct_lbl = lurek.ui.newLabel("35%")
pct_lbl:setPosition(200, 392)
pct_lbl:setSize(400, 20)

local function set_progress(v)
    bar:setValue(v)
    pct_lbl:setText(string.format("%.0f%%", v))
end

set_progress(72)
print("progress=" .. bar:getValue())
-- @end

-- ─────────────────────────────────────────────────────────────
-- HIT TESTING & Z-ORDER
-- ─────────────────────────────────────────────────────────────

-- @snippet lurek.ui.hit_test_tooltip_hover
-- @prefix lk-ui-hit-test-tooltip
-- @module ui
-- @description Use to show a custom tooltip when the cursor is over a widget. containsPoint maps mouse coords to widget bounds — works even for widgets not in the registered UI tree (e.g. custom-drawn items).
-- @body
local mx, my = lurek.input.mouse.getPosition()

local SNIP_1_tooltip_target = lurek.ui.newButton("Skill: Fireball")
tooltip_target:setPosition(50, 400)
tooltip_target:setSize(120, 40)
tooltip_target:setTooltip("Deals 3d6 fire damage in a 2-tile radius")

if tooltip_target:containsPoint(mx, my) then
    local tip = tooltip_target:getTooltip()
    lurek.render.setColor(0, 0, 0, 0.85)
    lurek.render.rectangle("fill", mx + 12, my - 28, 260, 24)
    lurek.render.setColor(1, 1, 0.8, 1)
    lurek.render.print(tip, mx + 16, my - 24)
    lurek.render.setColor(1, 1, 1, 1)
end
-- @end

-- @snippet lurek.ui.z_order_modal_overlay
-- @prefix lk-ui-z-order-modal
-- @module ui
-- @description Use to guarantee a modal dialog always draws above all other widgets. setZOrder with a very high value (e.g. 1000) ensures it renders last, regardless of creation order.
-- @body
local SNIP_1_backdrop = lurek.ui.newPanel()
backdrop:setPosition(0, 0)
backdrop:setSize(800, 600)
backdrop:setAlpha(0.6)
backdrop:setZOrder(999)

local modal = lurek.ui.newPanel()
modal:setPosition(200, 180)
modal:setSize(400, 240)
modal:setZOrder(1000)
modal:addChild(lurek.ui.newLabel("Are you sure?"))

print("modal z=" .. modal:getZOrder())
print("total widgets=" .. lurek.ui.getWidgetCount())
-- @end
