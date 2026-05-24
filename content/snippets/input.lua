-- content/snippets/input.lua
-- Handcrafted snippets for lurek.input — keyboard, mouse, gamepad, cursor, mappings.
-- API surface covered: keyboard.isDown, isScancodeDown, isModifierActive, setKeyRepeat,
--   setTextInput; mouse.getPosition, isDown, getWheelDelta, setVisible, setGrabbed,
--   setRelativeMode, getSystemCursor, setCursor, newCursor;
--   gamepad.getAxis, isDown, wasPressed, wasReleased, getHat, virtualDpad, vibrate,
--   isConnected, wasConnected, wasDisconnected, loadGamepadMappings.

local kb = lurek.input.keyboard
local left_click = lurek.input.mouse.isDown(1)
local ZOOM_SPEED = 0.1
local mouse = lurek.input.mouse
local gp = lurek.input.gamepad

-- ─────────────────────────────────────────────────────────────
-- KEYBOARD
-- ─────────────────────────────────────────────────────────────

-- @snippet lurek.input.keyboard_move_axis
-- @prefix lk-input-kb-move
-- @module input
-- @description Use in update() to produce a normalised 2-axis movement vector from WASD + arrow keys. Works for top-down, platformer, and grid games. Result is clamped to [-1, 1] so diagonal speed does not exceed 1.
-- @body
local SNIP_1_kb = lurek.input.keyboard
local dx = (kb.isDown("d", "right") and 1 or 0) - (kb.isDown("a", "left") and 1 or 0)
local dy = (kb.isDown("s", "down")  and 1 or 0) - (kb.isDown("w", "up")   and 1 or 0)
local len = math.sqrt(dx * dx + dy * dy)
if len > 0 then dx, dy = dx / len, dy / len end
print("move axis dx=" .. dx .. " dy=" .. dy)
-- @end

-- @snippet lurek.input.keyboard_modifier_combo
-- @prefix lk-input-kb-modifier
-- @module input
-- @description Use to detect hotkeys that require a modifier (Ctrl+S save, Shift+Tab, Alt+F4 intercept). Combine isDown for the primary key with isModifierActive for the modifier — avoids false positives from key order.
-- @body
local SNIP_1_kb = lurek.input.keyboard
local ctrl_s  = kb.isModifierActive("ctrl")  and kb.isDown("s")
local shift_z = kb.isModifierActive("shift") and kb.isDown("z")
if ctrl_s  then print("save triggered") end
if shift_z then print("redo triggered") end
-- @end

-- @snippet lurek.input.keyboard_text_input_mode
-- @prefix lk-input-kb-text
-- @module input
-- @description Use when opening a chat box, search field, or rename dialog. Enables OS text-input mode (IME, dead keys, key repeat) and disables it on close. Pair with setKeyRepeat so held backspace deletes characters continuously.
-- @body
local SNIP_1_kb = lurek.input.keyboard
-- when dialog opens:
kb.setTextInput(true)
kb.setKeyRepeat(true)
print("text input active: " .. tostring(kb.hasTextInput()))

-- when dialog closes:
-- kb.setTextInput(false)
-- kb.setKeyRepeat(false)
-- @end

-- @snippet lurek.input.keyboard_scancode_remap_display
-- @prefix lk-input-kb-scancode-hint
-- @module input
-- @description Use to show localised key names in tooltip / rebind UI. Scancode gives physical position; getKeyFromScancode gives the printable character on the player's actual keyboard layout (AZERTY, QWERTZ, etc.).
-- @body
local SNIP_1_kb = lurek.input.keyboard
local layouts = { "w", "a", "s", "d" }
for _, sc in ipairs(layouts) do
    local key = kb.getKeyFromScancode(sc)
    print("scancode=" .. sc .. "  key='" .. key .. "'")
end
-- @end

-- ─────────────────────────────────────────────────────────────
-- MOUSE
-- ─────────────────────────────────────────────────────────────

-- @snippet lurek.input.mouse_world_probe
-- @prefix lk-input-mouse-world
-- @module input
-- @description Use to map screen-space mouse position to world-space coordinates by subtracting the camera offset. Foundation for click-to-move, hover highlight, and drag-select in top-down games.
-- @body
local mx, my = lurek.input.mouse.getPosition()
-- subtract camera offset (replace with your cam_x / cam_y variables)
local cam_x, cam_y = 0, 0
local wx, wy = mx + cam_x, my + cam_y
local SNIP_1_left_click  = lurek.input.mouse.isDown(1)
local right_click = lurek.input.mouse.isDown(2)
print(string.format("screen(%d,%d) world(%d,%d) L=%s R=%s",
    mx, my, wx, wy, tostring(left_click), tostring(right_click)))
-- @end

-- @snippet lurek.input.mouse_scroll_zoom
-- @prefix lk-input-mouse-zoom
-- @module input
-- @description Use for scroll-wheel zoom in map or level-editor views. Accumulates wheel delta and clamps to a [min, max] range each frame to prevent jump flicker.
-- @body
local SNIP_1_ZOOM_SPEED = 0.1
local zoom_min   = 0.25
local zoom_max   = 4.0
local zoom = 1.0

local wheel = lurek.input.mouse.getWheelDelta()
zoom = math.max(zoom_min, math.min(zoom_max, zoom + wheel * ZOOM_SPEED))
print("zoom=" .. string.format("%.2f", zoom))
-- @end

-- @snippet lurek.input.mouse_cursor_context_swap
-- @prefix lk-input-mouse-cursor-ctx
-- @module input
-- @description Use to change the cursor shape based on context: arrow when idle, hand when hovering a button, crosshair in targeting mode. Uses system cursors — no image files required.
-- @body
local SNIP_1_mouse = lurek.input.mouse
-- preload once (expensive)
local cursor_arrow  = mouse.getSystemCursor("arrow")
local cursor_hand   = mouse.getSystemCursor("hand")
local cursor_target = mouse.getSystemCursor("crosshair")

-- each frame: swap based on state
local hovering_button = false  -- replace with your hover logic
if hovering_button then
    mouse.setCursor(cursor_hand)
else
    mouse.setCursor(cursor_arrow)
end
print("cursor context applied")
_ = cursor_target
-- @end

-- @snippet lurek.input.mouse_fps_look
-- @prefix lk-input-mouse-fps-look
-- @module input
-- @description Use for first-person or third-person camera rotation. Relative mode disables OS cursor movement and reports raw deltas — essential for smooth 360° look. Disable it when showing a pause menu.
-- @body
local SNIP_1_mouse = lurek.input.mouse
-- when entering FPS look:
mouse.setRelativeMode(true)
mouse.setVisible(false)
mouse.setGrabbed(true)
print("fps look mode active, relative=" .. tostring(mouse.getRelativeMode()))

-- in your look update: read delta (engine delivers via events)
-- when exiting:
-- mouse.setRelativeMode(false)
-- mouse.setVisible(true)
-- mouse.setGrabbed(false)
-- @end

-- @snippet lurek.input.mouse_drag_box
-- @prefix lk-input-mouse-drag-box
-- @module input
-- @description Use for rubber-band selection in strategy or editor UIs. Tracks drag start on left-button press and computes the selection rectangle while held.
-- @body
local SNIP_1_mouse = lurek.input.mouse
local drag_start_x, drag_start_y
local drag_active = false

if mouse.isDown(1) and not drag_active then
    drag_start_x, drag_start_y = mouse.getPosition()
    drag_active = true
end

if drag_active and mouse.isDown(1) then
    local cx, cy = mouse.getPosition()
    local rx = math.min(drag_start_x or cx, cx)
    local ry = math.min(drag_start_y or cy, cy)
    local rw = math.abs(cx - (drag_start_x or cx))
    local rh = math.abs(cy - (drag_start_y or cy))
    print(string.format("drag rect=%.0f,%.0f %.0fx%.0f", rx, ry, rw, rh))
end

if not mouse.isDown(1) then
    drag_active = false
end
-- @end

-- ─────────────────────────────────────────────────────────────
-- GAMEPAD
-- ─────────────────────────────────────────────────────────────

-- @snippet lurek.input.gamepad_deadzone_axis
-- @prefix lk-input-gp-deadzone
-- @module input
-- @description Use to read left analogue stick with a circular deadzone. Raw axis values drift near 0 on all controllers — apply deadzone before using for movement to prevent ghost input.
-- @body
local SNIP_1_gp      = lurek.input.gamepad
local pad     = 1
local raw_x   = gp.getAxis(pad, 1)
local raw_y   = gp.getAxis(pad, 2)
local len     = math.sqrt(raw_x * raw_x + raw_y * raw_y)
local deadzone = 0.15
local ax, ay = 0, 0
if len > deadzone then
    local scale = (len - deadzone) / (1 - deadzone)
    ax = (raw_x / len) * scale
    ay = (raw_y / len) * scale
end
print(string.format("stick ax=%.3f ay=%.3f", ax, ay))
-- @end

-- @snippet lurek.input.gamepad_button_press_edge
-- @prefix lk-input-gp-button-edge
-- @module input
-- @description Use to detect single-frame button press and release edges for jump, attack, and UI confirm/cancel. wasPressed fires only on the first frame the button goes down; wasReleased fires only on the frame it goes up.
-- @body
local SNIP_1_gp  = lurek.input.gamepad
local pad = 1
-- Button indices: 1=A/Cross, 2=B/Circle, 3=X/Square, 4=Y/Triangle (SDL mapping)
if gp.wasPressed(pad, 1) then
    print("jump pressed")
end
if gp.wasReleased(pad, 1) then
    print("jump released (held time logic here)")
end
if gp.isDown(pad, 5) then
    print("LB held (charge attack)")
end
-- @end

-- @snippet lurek.input.gamepad_dpad_menu
-- @prefix lk-input-gp-dpad
-- @module input
-- @description Use for menu navigation with D-pad. virtualDpad converts left-stick x/y plus deadzone threshold into a discrete direction string — works for both real D-pad (hat) and analogue stick input in the same code path.
-- @body
local SNIP_1_gp  = lurek.input.gamepad
local pad = 1
local sx  = gp.getAxis(pad, 1)
local sy  = gp.getAxis(pad, 2)
local dpad = gp.virtualDpad(sx, sy, 0.5)   -- threshold=0.5 avoids accidental triggers

if dpad.up    then print("menu: up")    end
if dpad.down  then print("menu: down")  end
if dpad.left  then print("menu: left")  end
if dpad.right then print("menu: right") end
print("direction=" .. dpad.direction)
-- @end

-- @snippet lurek.input.gamepad_hat_dpad_raw
-- @prefix lk-input-gp-hat
-- @module input
-- @description Use when the game needs raw hat/D-pad state (not stick emulation) for fighting-game inputs or precise direction detection. getHat returns a direction string: "c", "u", "d", "l", "r", "ul", "ur", "dl", "dr".
-- @body
local SNIP_1_gp  = lurek.input.gamepad
local pad = 1
local hat = gp.getHat(pad, 1)
print("hat direction=" .. hat)
if hat == "u" or hat == "ul" or hat == "ur" then
    print("up input")
elseif hat == "d" or hat == "dl" or hat == "dr" then
    print("down input")
end
-- @end

-- @snippet lurek.input.gamepad_connect_disconnect_handle
-- @prefix lk-input-gp-connect
-- @module input
-- @description Use to detect controller hot-plug and show a UI notification. wasConnected/wasDisconnected are single-frame edge signals — check all slots each frame to handle multi-controller sessions.
-- @body
local SNIP_1_gp = lurek.input.gamepad
for pad = 1, gp.getCount() do
    if gp.wasConnected(pad) then
        print("gamepad " .. pad .. " connected: " .. gp.getName(pad))
    end
    if gp.wasDisconnected(pad) then
        print("gamepad " .. pad .. " disconnected")
    end
end
-- @end

-- @snippet lurek.input.gamepad_vibrate_feedback
-- @prefix lk-input-gp-vibrate
-- @module input
-- @description Use for damage-feedback or hit-confirmation rumble. Checks vibration support before calling to avoid silent no-ops on hardware that lacks motors. Pass different low/high values to distinguish damage type (heavy vs light).
-- @body
local SNIP_1_gp  = lurek.input.gamepad
local pad = 1
if gp.isConnected(pad) and gp.isVibrationSupported(pad) then
    -- heavy hit: strong low-frequency + light high-frequency, 300 ms
    gp.vibrate(pad, 0.8, 0.3, 300)
    print("vibrate: hit feedback sent to pad " .. pad)
end
-- @end

-- @snippet lurek.input.gamepad_mapping_load
-- @prefix lk-input-gp-mapping
-- @module input
-- @description Use on startup to load a community controller mapping database so obscure gamepads are recognised as standard buttons/axes. The file is typically bundled with your game as content/gamecontrollerdb.txt.
-- @body
local SNIP_1_gp       = lurek.input.gamepad
local db_path  = "content/gamecontrollerdb.txt"
gp.loadGamepadMappings(db_path)
print("gamepad mappings loaded from " .. db_path)
for pad = 1, gp.getCount() do
    if gp.isConnected(pad) then
        print("  pad " .. pad .. " '" .. gp.getName(pad) .. "' guid=" .. gp.getGUID(pad))
    end
end
-- @end

-- @snippet lurek.input.gamepad_full_poll_summary
-- @prefix lk-input-gp-full-poll
-- @module input
-- @description Use for a debug diagnostics panel that shows all axes and buttons for the first connected gamepad. Useful when verifying new controller mappings.
-- @body
local SNIP_1_gp  = lurek.input.gamepad
local pad = 1
if gp.isConnected(pad) then
    print("=== gamepad " .. pad .. " " .. gp.getName(pad) .. " ===")
    for a = 1, gp.getAxisCount(pad) do
        print(string.format("  axis[%d]=%.3f", a, gp.getAxis(pad, a)))
    end
    for b = 1, gp.getButtonCount(pad) do
        if gp.isDown(pad, b) then
            print("  btn[" .. b .. "] HELD")
        end
    end
end
-- @end
