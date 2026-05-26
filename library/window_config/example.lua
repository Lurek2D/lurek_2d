--- Example usage for library.window_config.
-- Demonstrates fluent builder, presets, runtime helpers, and serialization.
-- @module example.window_config

local WindowConfig = require("library.window_config")

-- ── 1. Fluent builder ─────────────────────────────────────────────────────────
local cfg = WindowConfig.new()
    :title("My Awesome Game")
    :size(1280, 720)
    :minSize(640, 480)
    :resizable(true)
    :vsync(true)
    :fullscreen(false)
    :centered(true)
    :icon("assets/icon.png")
    :scalingMode("letterbox")
    :gameSize(640, 360)

print("[window_config] built config: " .. cfg._title
      .. " (" .. cfg._width .. "x" .. cfg._height .. ")")

-- Apply to the actual window (safe headless)
cfg:apply()

-- ── 2. Presets ────────────────────────────────────────────────────────────────
local retro = WindowConfig.preset("retro")
print("[window_config] retro preset: " .. retro._width .. "x" .. retro._height
      .. " game=" .. retro._game_width .. "x" .. retro._game_height
      .. " mode=" .. retro._scaling_mode)

local hd = WindowConfig.preset("hd")
print("[window_config] hd preset: " .. hd._width .. "x" .. hd._height
      .. " mode=" .. hd._scaling_mode)

local fullhd = WindowConfig.preset("fullhd")
print("[window_config] fullhd preset: " .. fullhd._width .. "x" .. fullhd._height
      .. " mode=" .. fullhd._scaling_mode)

-- Customize a preset further
local custom_retro = WindowConfig.preset("retro")
    :title("Pixel Dungeon")
    :gameSize(256, 224)
    :size(768, 672)

print("[window_config] custom retro: " .. custom_retro._title
      .. " game=" .. custom_retro._game_width .. "x" .. custom_retro._game_height)

-- ── 3. Runtime helpers ────────────────────────────────────────────────────────
local w, h = cfg:getActualSize()
print("[window_config] actual size: " .. w .. "x" .. h)

local scale = cfg:getScaleFactor()
print("[window_config] scale factor: " .. scale)

cfg:toggleFullscreen()
print("[window_config] fullscreen after toggle: " .. tostring(cfg._fullscreen))

cfg:toggleFullscreen()
print("[window_config] fullscreen after second toggle: " .. tostring(cfg._fullscreen))

-- ── 4. Pixel perfect scale ────────────────────────────────────────────────────
local pixel_cfg = WindowConfig.new()
    :size(960, 720)
    :gameSize(320, 240)
    :scalingMode("pixel_perfect")

local pixel_scale = pixel_cfg:getScaleFactor()
print("[window_config] pixel_perfect scale: " .. pixel_scale .. "x")

-- ── 5. Serialization ──────────────────────────────────────────────────────────
local data = cfg:serialize()
print("[window_config] serialized fields: title=" .. data.title
      .. " width=" .. data.width .. " vsync=" .. tostring(data.vsync))

-- Restore from table
local restored = WindowConfig.new()
restored:deserialize(data)
print("[window_config] restored: " .. restored._title
      .. " (" .. restored._width .. "x" .. restored._height .. ")")

-- JSON round-trip
local json = cfg:toJson()
print("[window_config] json: " .. json)

local from_json = WindowConfig.fromJson(json)
print("[window_config] from json: " .. from_json._title
      .. " (" .. from_json._width .. "x" .. from_json._height .. ")")

-- ── 6. Invalid input handling ─────────────────────────────────────────────────
local safe = WindowConfig.new()
    :scalingMode("invalid_mode")  -- falls back to letterbox
print("[window_config] fallback mode: " .. safe._scaling_mode)

local unknown_preset = WindowConfig.preset("unknown")  -- falls back to hd
print("[window_config] unknown preset fallback: "
      .. unknown_preset._width .. "x" .. unknown_preset._height)

print("[window_config] example complete")
