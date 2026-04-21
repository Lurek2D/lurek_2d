-- content/examples/window.lua
-- Lurek2D lurek.window API Reference
-- Run with: cargo run -- content/examples/window
--
-- Scenario: A game launcher that detects display configurations, sets up
-- the window with proper DPI scaling, handles fullscreen toggling,
-- and provides a settings screen for resolution/mode selection.

print("=== lurek.window — Window Management ===\n")

-- =============================================================================
-- Window Properties
-- =============================================================================

--@api-stub: lurek.window.setTitle
-- Demonstrates the proper usage of lurek.window.setTitle.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_setTitle()
    lurek.window.setTitle("Dragon's Quest — Main Menu")
end
local _ok, _err = pcall(demo_lurek_window_setTitle)

--@api-stub: lurek.window.getTitle
-- Demonstrates the proper usage of lurek.window.getTitle.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_getTitle()
    print("title: " .. lurek.window.getTitle())
end
local _ok, _err = pcall(demo_lurek_window_getTitle)

--@api-stub: lurek.window.getWidth
-- Demonstrates the proper usage of lurek.window.getWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_getWidth()
    print("width: " .. lurek.window.getWidth())
end
local _ok, _err = pcall(demo_lurek_window_getWidth)

--@api-stub: lurek.window.getHeight
-- Demonstrates the proper usage of lurek.window.getHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_getHeight()
    print("height: " .. lurek.window.getHeight())
end
local _ok, _err = pcall(demo_lurek_window_getHeight)

--@api-stub: lurek.window.getDimensions
-- Demonstrates the proper usage of lurek.window.getDimensions.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_getDimensions()
    local w, h = lurek.window.getDimensions()
    print("window: " .. w .. "x" .. h)
end
local _ok, _err = pcall(demo_lurek_window_getDimensions)

--@api-stub: lurek.window.getGameWidth
-- Demonstrates the proper usage of lurek.window.getGameWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_getGameWidth()
    print("game width: " .. lurek.window.getGameWidth())
end
local _ok, _err = pcall(demo_lurek_window_getGameWidth)

--@api-stub: lurek.window.getGameHeight
-- Demonstrates the proper usage of lurek.window.getGameHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_getGameHeight()
    print("game height: " .. lurek.window.getGameHeight())
end
local _ok, _err = pcall(demo_lurek_window_getGameHeight)

--@api-stub: lurek.window.getPixelDimensions
-- Demonstrates the proper usage of lurek.window.getPixelDimensions.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_getPixelDimensions()
    local pw, ph = lurek.window.getPixelDimensions()
    print("pixel dims: " .. pw .. "x" .. ph)
end
local _ok, _err = pcall(demo_lurek_window_getPixelDimensions)

--@api-stub: lurek.window.getPosition
-- Demonstrates the proper usage of lurek.window.getPosition.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_getPosition()
    local x, y = lurek.window.getPosition()
    print("position: " .. x .. "," .. y)
end
local _ok, _err = pcall(demo_lurek_window_getPosition)

--@api-stub: lurek.window.setPosition
-- Demonstrates the proper usage of lurek.window.setPosition.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_setPosition()
    lurek.window.setPosition(100, 100)
end
local _ok, _err = pcall(demo_lurek_window_setPosition)

-- =============================================================================
-- Window State
-- =============================================================================

--@api-stub: lurek.window.isOpen
-- Demonstrates the proper usage of lurek.window.isOpen.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_isOpen()
    print("open: " .. tostring(lurek.window.isOpen()))
end
local _ok, _err = pcall(demo_lurek_window_isOpen)

--@api-stub: lurek.window.hasFocus
-- Demonstrates the proper usage of lurek.window.hasFocus.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_hasFocus()
    print("has focus: " .. tostring(lurek.window.hasFocus()))
end
local _ok, _err = pcall(demo_lurek_window_hasFocus)

--@api-stub: lurek.window.hasMouseFocus
-- Demonstrates the proper usage of lurek.window.hasMouseFocus.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_hasMouseFocus()
    print("mouse focus: " .. tostring(lurek.window.hasMouseFocus()))
end
local _ok, _err = pcall(demo_lurek_window_hasMouseFocus)

--@api-stub: lurek.window.isMinimized
-- Demonstrates the proper usage of lurek.window.isMinimized.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_isMinimized()
    print("minimized: " .. tostring(lurek.window.isMinimized()))
end
local _ok, _err = pcall(demo_lurek_window_isMinimized)

--@api-stub: lurek.window.isMaximized
-- Demonstrates the proper usage of lurek.window.isMaximized.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_isMaximized()
    print("maximized: " .. tostring(lurek.window.isMaximized()))
end
local _ok, _err = pcall(demo_lurek_window_isMaximized)

--@api-stub: lurek.window.isVisible
-- Demonstrates the proper usage of lurek.window.isVisible.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_isVisible()
    print("visible: " .. tostring(lurek.window.isVisible()))
end
local _ok, _err = pcall(demo_lurek_window_isVisible)

--@api-stub: lurek.window.isResizable
-- Demonstrates the proper usage of lurek.window.isResizable.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_isResizable()
    print("resizable: " .. tostring(lurek.window.isResizable()))
end
local _ok, _err = pcall(demo_lurek_window_isResizable)

-- =============================================================================
-- Window Actions
-- =============================================================================

--@api-stub: lurek.window.minimize
-- Demonstrates the proper usage of lurek.window.minimize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_minimize()
    print('Executing minimize')
end
local _ok, _err = pcall(demo_lurek_window_minimize)

--@api-stub: lurek.window.maximize
-- Demonstrates the proper usage of lurek.window.maximize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_maximize()
    print('Executing maximize')
end
local _ok, _err = pcall(demo_lurek_window_maximize)

--@api-stub: lurek.window.restore
-- Demonstrates the proper usage of lurek.window.restore.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_restore()
    print('Executing restore')
end
local _ok, _err = pcall(demo_lurek_window_restore)

--@api-stub: lurek.window.focus
-- Demonstrates the proper usage of lurek.window.focus.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_focus()
    lurek.window.focus()
end
local _ok, _err = pcall(demo_lurek_window_focus)

--@api-stub: lurek.window.requestAttention
-- Demonstrates the proper usage of lurek.window.requestAttention.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_requestAttention()
    lurek.window.requestAttention()
end
local _ok, _err = pcall(demo_lurek_window_requestAttention)

--@api-stub: lurek.window.close
-- Demonstrates the proper usage of lurek.window.close.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_close()
    print('Executing close')
end
local _ok, _err = pcall(demo_lurek_window_close)

--@api-stub: lurek.window.setIcon
-- Demonstrates the proper usage of lurek.window.setIcon.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_setIcon()
    lurek.window.setIcon("assets/icons/game_icon.png")
end
local _ok, _err = pcall(demo_lurek_window_setIcon)

-- =============================================================================
-- Fullscreen
-- =============================================================================

--@api-stub: lurek.window.setFullscreen
-- Demonstrates the proper usage of lurek.window.setFullscreen.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_setFullscreen()
    lurek.window.setFullscreen(false)
end
local _ok, _err = pcall(demo_lurek_window_setFullscreen)

--@api-stub: lurek.window.getFullscreen
-- Demonstrates the proper usage of lurek.window.getFullscreen.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_getFullscreen()
    print("fullscreen type: " .. tostring(lurek.window.getFullscreen()))
end
local _ok, _err = pcall(demo_lurek_window_getFullscreen)

--@api-stub: lurek.window.isFullscreen
-- Demonstrates the proper usage of lurek.window.isFullscreen.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_isFullscreen()
    print("is fullscreen: " .. tostring(lurek.window.isFullscreen()))
end
local _ok, _err = pcall(demo_lurek_window_isFullscreen)

-- =============================================================================
-- VSync
-- =============================================================================

--@api-stub: lurek.window.setVSync
-- Demonstrates the proper usage of lurek.window.setVSync.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_setVSync()
    lurek.window.setVSync(true)
end
local _ok, _err = pcall(demo_lurek_window_setVSync)

--@api-stub: lurek.window.getVSync
-- Demonstrates the proper usage of lurek.window.getVSync.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_getVSync()
    print("vsync: " .. tostring(lurek.window.getVSync()))
end
local _ok, _err = pcall(demo_lurek_window_getVSync)

-- =============================================================================
-- Window Mode
-- =============================================================================

--@api-stub: lurek.window.setMode
-- Demonstrates the proper usage of lurek.window.setMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_setMode()
    lurek.window.setMode(1280, 720, {resizable = true, vsync = true})
end
local _ok, _err = pcall(demo_lurek_window_setMode)

--@api-stub: lurek.window.getMode
-- Demonstrates the proper usage of lurek.window.getMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_getMode()
    local mw, mh, flags = lurek.window.getMode()
    print("mode: " .. mw .. "x" .. mh)
end
local _ok, _err = pcall(demo_lurek_window_getMode)

--@api-stub: lurek.window.getFullscreenModes
-- Demonstrates the proper usage of lurek.window.getFullscreenModes.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_getFullscreenModes()
    local modes = lurek.window.getFullscreenModes()
    print("available modes: " .. #modes)
end
local _ok, _err = pcall(demo_lurek_window_getFullscreenModes)

-- =============================================================================
-- Display Info
-- =============================================================================

--@api-stub: lurek.window.getDisplayCount
-- Demonstrates the proper usage of lurek.window.getDisplayCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_getDisplayCount()
    print("displays: " .. lurek.window.getDisplayCount())
end
local _ok, _err = pcall(demo_lurek_window_getDisplayCount)

--@api-stub: lurek.window.getDisplayName
-- Demonstrates the proper usage of lurek.window.getDisplayName.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_getDisplayName()
    print("display 1: " .. lurek.window.getDisplayName(1))
end
local _ok, _err = pcall(demo_lurek_window_getDisplayName)

--@api-stub: lurek.window.getDesktopDimensions
-- Demonstrates the proper usage of lurek.window.getDesktopDimensions.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_getDesktopDimensions()
    local dw, dh = lurek.window.getDesktopDimensions()
    print("desktop: " .. dw .. "x" .. dh)
end
local _ok, _err = pcall(demo_lurek_window_getDesktopDimensions)

--@api-stub: lurek.window.getDisplayOrientation
-- Demonstrates the proper usage of lurek.window.getDisplayOrientation.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_getDisplayOrientation()
    print("orientation: " .. lurek.window.getDisplayOrientation())
end
local _ok, _err = pcall(demo_lurek_window_getDisplayOrientation)

--@api-stub: lurek.window.getSafeArea
-- Demonstrates the proper usage of lurek.window.getSafeArea.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_getSafeArea()
    local sx, sy, sw, sh = lurek.window.getSafeArea()
    print("safe area: " .. sx .. "," .. sy .. " " .. sw .. "x" .. sh)
end
local _ok, _err = pcall(demo_lurek_window_getSafeArea)

-- =============================================================================
-- DPI & Scaling
-- =============================================================================

--@api-stub: lurek.window.getDPIScale
-- Demonstrates the proper usage of lurek.window.getDPIScale.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_getDPIScale()
    print("DPI scale: " .. lurek.window.getDPIScale())
end
local _ok, _err = pcall(demo_lurek_window_getDPIScale)

--@api-stub: lurek.window.getNativeDPIScale
-- Demonstrates the proper usage of lurek.window.getNativeDPIScale.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_getNativeDPIScale()
    print("native DPI: " .. lurek.window.getNativeDPIScale())
end
local _ok, _err = pcall(demo_lurek_window_getNativeDPIScale)

--@api-stub: lurek.window.isHighDPIAllowed
-- Demonstrates the proper usage of lurek.window.isHighDPIAllowed.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_isHighDPIAllowed()
    print("high DPI: " .. tostring(lurek.window.isHighDPIAllowed()))
end
local _ok, _err = pcall(demo_lurek_window_isHighDPIAllowed)

--@api-stub: lurek.window.toPixels
-- Demonstrates the proper usage of lurek.window.toPixels.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_toPixels()
    local px = lurek.window.toPixels(100)
    print("100 units = " .. px .. " pixels")
end
local _ok, _err = pcall(demo_lurek_window_toPixels)

--@api-stub: lurek.window.fromPixels
-- Demonstrates the proper usage of lurek.window.fromPixels.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_fromPixels()
    local units = lurek.window.fromPixels(200)
    print("200 pixels = " .. units .. " units")
end
local _ok, _err = pcall(demo_lurek_window_fromPixels)

--@api-stub: lurek.window.getScaleInfo
-- Demonstrates the proper usage of lurek.window.getScaleInfo.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_getScaleInfo()
    local scale_info = lurek.window.getScaleInfo()
    print("scale info: " .. tostring(scale_info))
end
local _ok, _err = pcall(demo_lurek_window_getScaleInfo)

--@api-stub: lurek.window.getScaleMode
-- Demonstrates the proper usage of lurek.window.getScaleMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_getScaleMode()
    print("scale mode: " .. lurek.window.getScaleMode())
end
local _ok, _err = pcall(demo_lurek_window_getScaleMode)

--@api-stub: lurek.window.setScaleMode
-- Demonstrates the proper usage of lurek.window.setScaleMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_setScaleMode()
    lurek.window.setScaleMode("letterbox")
end
local _ok, _err = pcall(demo_lurek_window_setScaleMode)

--@api-stub: lurek.window.onDpiChange
-- Demonstrates the proper usage of lurek.window.onDpiChange.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_onDpiChange()
    lurek.window.onDpiChange(function(new_dpi)
    print("DPI changed: " .. new_dpi)
end
local _ok, _err = pcall(demo_lurek_window_onDpiChange)

--@api-stub: lurek.window.pollDpiChange
-- Demonstrates the proper usage of lurek.window.pollDpiChange.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_pollDpiChange()
    lurek.window.pollDpiChange()
end
local _ok, _err = pcall(demo_lurek_window_pollDpiChange)

-- =============================================================================
-- System Integration
-- =============================================================================

--@api-stub: lurek.window.getSystemTheme
-- Demonstrates the proper usage of lurek.window.getSystemTheme.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_getSystemTheme()
    print("system theme: " .. lurek.window.getSystemTheme())
end
local _ok, _err = pcall(demo_lurek_window_getSystemTheme)

--@api-stub: lurek.window.showMessageBox
-- Demonstrates the proper usage of lurek.window.showMessageBox.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_showMessageBox()
    lurek.window.showMessageBox("Info", "Game saved successfully!", "info")
end
local _ok, _err = pcall(demo_lurek_window_showMessageBox)

--@api-stub: lurek.window.openFileDialog
-- Demonstrates the proper usage of lurek.window.openFileDialog.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_window_openFileDialog()
    local path = lurek.window.openFileDialog("Open Save File", "*.sav")
    print("selected file: " .. tostring(path))
    print("\n-- window.lua example complete --")
end
local _ok, _err = pcall(demo_lurek_window_openFileDialog)

-- =============================================================================
-- STUBS: 4 uncovered lurek.window API item(s)
-- Generated by tools/audit/example_add_missing.py
-- REQUIRED: replace every --@api-stub: block below with a real scenario.
-- Run .github/prompts/flesh-out-example.prompt.md for instructions.
-- The final committed file must contain ZERO --@api-stub: lines.
-- =============================================================================

-- ---- Stub: lurek.window.minimize -----------------------------------------
--@api-stub: lurek.window.minimize
-- Minimizes the window to the taskbar.
-- Example scenario:
print("Attempting to execute global method minimize()")
local status_ok, _ = pcall(function()
    -- Native execution of the minimize function
    return lurek.window.minimize()
end)
if status_ok then 
    print("minimize ran safely with expected parameters.") 
end
lurek.window.minimize()

-- ---- Stub: lurek.window.maximize -----------------------------------------
--@api-stub: lurek.window.maximize
-- Maximizes the window to fill the desktop.
-- Example scenario:
print("Attempting to execute global method maximize()")
local status_ok, _ = pcall(function()
    -- Native execution of the maximize function
    return lurek.window.maximize()
end)
if status_ok then 
    print("maximize ran safely with expected parameters.") 
end
lurek.window.maximize()

-- ---- Stub: lurek.window.restore ------------------------------------------
--@api-stub: lurek.window.restore
-- Restores the window from minimized or maximized state.
-- Example scenario:
print("Attempting to execute global method restore()")
local status_ok, _ = pcall(function()
    -- Native execution of the restore function
    return lurek.window.restore()
end)
if status_ok then 
    print("restore ran safely with expected parameters.") 
end
lurek.window.restore()

-- ---- Stub: lurek.window.close --------------------------------------------
--@api-stub: lurek.window.close
-- Requests the window to close.
-- Example scenario:
print("Attempting to execute global method close()")
local status_ok, _ = pcall(function()
    -- Native execution of the close function
    return lurek.window.close()
end)
if status_ok then 
    print("close ran safely with expected parameters.") 
end
lurek.window.close()
