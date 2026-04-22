-- content/examples/window.lua
-- love2d-style usage snippets for the lurek.window API (50 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/window.lua

-- ── lurek.window.* functions ──

--@api-stub: lurek.window.setTitle
-- Sets the window title bar text.
-- Apply at startup or in response to user input.
lurek.window.setTitle("My Awesome Game")
lurek.window.setTitle("Score: " .. tostring(score))
-- best called once at startup
print("ok")

--@api-stub: lurek.window.getTitle
-- Returns the current window title.
-- Cheap to call; safe inside callbacks.
local value = lurek.window.getTitle()
print("getTitle:", value)
return value

--@api-stub: lurek.window.getWidth
-- Returns the window width in pixels.
-- Cheap to call; safe inside callbacks.
local value = lurek.window.getWidth()
print("getWidth:", value)
return value

--@api-stub: lurek.window.getHeight
-- Returns the window height in pixels.
-- Cheap to call; safe inside callbacks.
local value = lurek.window.getHeight()
print("getHeight:", value)
return value

--@api-stub: lurek.window.getDimensions
-- Returns the window dimensions as width, height.
-- Cheap to call; safe inside callbacks.
local value = lurek.window.getDimensions()
print("getDimensions:", value)
return value

--@api-stub: lurek.window.setFullscreen
-- Enables or disables fullscreen mode.
-- Apply at startup or in response to user input.
lurek.window.setFullscreen(true)
lurek.window.setFullscreen(false)
-- toggle on F11 in your update callback
print("ok")

--@api-stub: lurek.window.getFullscreen
-- Returns the fullscreen state and type string.
-- Cheap to call; safe inside callbacks.
local value = lurek.window.getFullscreen()
print("getFullscreen:", value)
return value

--@api-stub: lurek.window.isOpen
-- Returns whether the window is open.
-- Use as a guard inside lurek.update or event handlers.
if lurek.window.isOpen() then
  print("isOpen -> true")
end

--@api-stub: lurek.window.setVSync
-- Sets the VSync mode (1=on, 0=off, -1=adaptive).
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.window.setVSync(mode)
print("setVSync applied")
print("ok")

--@api-stub: lurek.window.getVSync
-- Returns the current VSync mode integer.
-- Cheap to call; safe inside callbacks.
local value = lurek.window.getVSync()
print("getVSync:", value)
return value

--@api-stub: lurek.window.hasFocus
-- Returns whether the window has keyboard focus.
-- Use as a guard inside lurek.update or event handlers.
if lurek.window.hasFocus() then
  print("hasFocus -> true")
end

--@api-stub: lurek.window.hasMouseFocus
-- Returns whether the mouse cursor is inside the window.
-- Use as a guard inside lurek.update or event handlers.
if lurek.window.hasMouseFocus() then
  print("hasMouseFocus -> true")
end

--@api-stub: lurek.window.isMinimized
-- Returns whether the window is minimized.
-- Use as a guard inside lurek.update or event handlers.
if lurek.window.isMinimized() then
  print("isMinimized -> true")
end

--@api-stub: lurek.window.isMaximized
-- Returns whether the window is maximized.
-- Use as a guard inside lurek.update or event handlers.
if lurek.window.isMaximized() then
  print("isMaximized -> true")
end

--@api-stub: lurek.window.isVisible
-- Returns whether the window is visible.
-- Use as a guard inside lurek.update or event handlers.
if lurek.window.isVisible() then
  print("isVisible -> true")
end

--@api-stub: lurek.window.minimize
-- Minimizes the window to the taskbar.
-- See the module spec for detailed semantics.
local result = lurek.window.minimize()
print("minimize:", result)
return result

--@api-stub: lurek.window.maximize
-- Maximizes the window to fill the desktop.
-- See the module spec for detailed semantics.
local result = lurek.window.maximize()
print("maximize:", result)
return result

--@api-stub: lurek.window.restore
-- Restores the window from minimized or maximized state.
-- See the module spec for detailed semantics.
local result = lurek.window.restore()
print("restore:", result)
return result

--@api-stub: lurek.window.getPosition
-- Returns the window position as x, y in screen coordinates.
-- Cheap to call; safe inside callbacks.
local value = lurek.window.getPosition()
print("getPosition:", value)
return value

--@api-stub: lurek.window.setPosition
-- Moves the window to the given screen position.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.window.setPosition(100, 100)
print("setPosition applied")
print("ok")

--@api-stub: lurek.window.getDisplayCount
-- Returns the number of connected displays.
-- Cheap to call; safe inside callbacks.
local value = lurek.window.getDisplayCount()
print("getDisplayCount:", value)
return value

--@api-stub: lurek.window.getDesktopDimensions
-- Returns the desktop resolution as width, height.
-- Cheap to call; safe inside callbacks.
local value = lurek.window.getDesktopDimensions()
print("getDesktopDimensions:", value)
return value

--@api-stub: lurek.window.getDPIScale
-- Returns the DPI scaling factor for the window.
-- Cheap to call; safe inside callbacks.
local value = lurek.window.getDPIScale()
print("getDPIScale:", value)
return value

--@api-stub: lurek.window.toPixels
-- Converts a device-independent coordinate to physical pixels.
-- See the module spec for detailed semantics.
local result = lurek.window.toPixels(value)
print("toPixels:", result)
return result

--@api-stub: lurek.window.fromPixels
-- Converts physical pixels to device-independent coordinates.
-- Build once at startup; reuse across frames.
local frompixels = lurek.window.fromPixels(value)
print("created", frompixels)
return frompixels

--@api-stub: lurek.window.setIcon
-- Sets the window icon from a file path.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.window.setIcon("data/file.txt")
print("setIcon applied")
print("ok")

--@api-stub: lurek.window.setMode
-- Resizes the window and optionally changes fullscreen and vsync.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.window.setMode(64, 64, flags)
print("setMode applied")
print("ok")

--@api-stub: lurek.window.getMode
-- Returns the window dimensions and mode flags as width, height, flags.
-- Cheap to call; safe inside callbacks.
local value = lurek.window.getMode()
print("getMode:", value)
return value

--@api-stub: lurek.window.close
-- Requests the window to close.
-- See the module spec for detailed semantics.
local result = lurek.window.close()
print("close:", result)
return result

--@api-stub: lurek.window.requestAttention
-- Flashes the window in the taskbar to request user attention.
-- See the module spec for detailed semantics.
local result = lurek.window.requestAttention()
print("requestAttention:", result)
return result

--@api-stub: lurek.window.getFullscreenModes
-- Returns all available fullscreen video modes.
-- Cheap to call; safe inside callbacks.
local value = lurek.window.getFullscreenModes()
print("getFullscreenModes:", value)
return value

--@api-stub: lurek.window.getDisplayName
-- Returns the name of the current display.
-- Cheap to call; safe inside callbacks.
local value = lurek.window.getDisplayName(display)
print("getDisplayName:", value)
return value

--@api-stub: lurek.window.getPixelDimensions
-- Returns the window dimensions in physical pixels.
-- Cheap to call; safe inside callbacks.
local value = lurek.window.getPixelDimensions()
print("getPixelDimensions:", value)
return value

--@api-stub: lurek.window.showMessageBox
-- Shows a platform-native message box dialog.
-- See the module spec for detailed semantics.
local result = lurek.window.showMessageBox()
print("showMessageBox:", result)
return result

--@api-stub: lurek.window.focus
-- Requests the window manager to bring the window to the foreground.
-- See the module spec for detailed semantics.
local result = lurek.window.focus()
print("focus:", result)
return result

--@api-stub: lurek.window.getNativeDPIScale
-- Returns the native DPI scale factor.
-- Cheap to call; safe inside callbacks.
local value = lurek.window.getNativeDPIScale()
print("getNativeDPIScale:", value)
return value

--@api-stub: lurek.window.getDisplayOrientation
-- Returns the current display orientation.
-- Cheap to call; safe inside callbacks.
local value = lurek.window.getDisplayOrientation()
print("getDisplayOrientation:", value)
return value

--@api-stub: lurek.window.getSafeArea
-- Returns the safe display area as x, y, w, h.
-- Cheap to call; safe inside callbacks.
local value = lurek.window.getSafeArea()
print("getSafeArea:", value)
return value

--@api-stub: lurek.window.getSystemTheme
-- Returns the OS color theme preference.
-- Cheap to call; safe inside callbacks.
local value = lurek.window.getSystemTheme()
print("getSystemTheme:", value)
return value

--@api-stub: lurek.window.isHighDPIAllowed
-- Returns whether high-DPI rendering is allowed.
-- Use as a guard inside lurek.update or event handlers.
if lurek.window.isHighDPIAllowed() then
  print("isHighDPIAllowed -> true")
end

--@api-stub: lurek.window.getScaleInfo
-- Returns viewport scale and offset information as a table.
-- Cheap to call; safe inside callbacks.
local value = lurek.window.getScaleInfo()
print("getScaleInfo:", value)
return value

--@api-stub: lurek.window.getScaleMode
-- Returns the current viewport scale mode string.
-- Cheap to call; safe inside callbacks.
local value = lurek.window.getScaleMode()
print("getScaleMode:", value)
return value

--@api-stub: lurek.window.setScaleMode
-- Sets the viewport scale mode.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.window.setScaleMode(mode)
print("setScaleMode applied")
print("ok")

--@api-stub: lurek.window.getGameWidth
-- Returns the logical game width in virtual pixels.
-- Cheap to call; safe inside callbacks.
local value = lurek.window.getGameWidth()
print("getGameWidth:", value)
return value

--@api-stub: lurek.window.getGameHeight
-- Returns the logical game height in virtual pixels.
-- Cheap to call; safe inside callbacks.
local value = lurek.window.getGameHeight()
print("getGameHeight:", value)
return value

--@api-stub: lurek.window.isFullscreen
-- Returns whether the window is in fullscreen mode.
-- Use as a guard inside lurek.update or event handlers.
if lurek.window.isFullscreen() then
  print("isFullscreen -> true")
end

--@api-stub: lurek.window.isResizable
-- Returns whether the window can be resized by the user.
-- Use as a guard inside lurek.update or event handlers.
if lurek.window.isResizable() then
  print("isResizable -> true")
end

--@api-stub: lurek.window.onDpiChange
-- Registers a callback invoked (with the new scale factor) when the display.
-- See the module spec for detailed semantics.
local result = lurek.window.onDpiChange(function() print("onDpiChange fired") end)
print("onDpiChange:", result)
return result

--@api-stub: lurek.window.pollDpiChange
-- Polls for a pending DPI change event and returns the new scale factor if any.
-- See the module spec for detailed semantics.
local result = lurek.window.pollDpiChange()
print("pollDpiChange:", result)
return result

--@api-stub: lurek.window.openFileDialog
-- Opens a blocking native file-open dialog.
-- Build once at startup; reuse across frames.
local openfiledialog = lurek.window.openFileDialog({ x = 0, y = 0 })
print("created", openfiledialog)
return openfiledialog

