--- Example usage for library.input_action_map.
-- Demonstrates binding actions, querying state, and using axes.
-- @module example.input_action_map

package.path = "library/?.lua;library/?/init.lua;" .. package.path
local InputActionMap = require("library.input_action_map")

print("[example.input_action_map] === Setup: create action map and bind keys ===")

local actions = InputActionMap.new()

-- Bind movement actions (multiple keys per action)
actions:bind("move_left", "a")
actions:bind("move_left", "left")
actions:bind("move_right", "d")
actions:bind("move_right", "right")
actions:bind("move_up", "w")
actions:bind("move_up", "up")
actions:bind("move_down", "s")
actions:bind("move_down", "down")

-- Bind jump to keyboard and gamepad
actions:bind("jump", "space")
actions:bind("jump", "gamepad_a")

-- Bind fire to mouse and gamepad
actions:bind("fire", "mouse_left")
actions:bind("fire", "gamepad_rb")

-- Bind menu to escape
actions:bind("menu", "escape")

print("  Bound 6 actions with multiple keys each.")

print("[example.input_action_map] === Query bindings ===")

local jump_keys = actions:getBindings("jump")
print(string.format("  jump is bound to: %s", table.concat(jump_keys, ", ")))

local fire_keys = actions:getBindings("fire")
print(string.format("  fire is bound to: %s", table.concat(fire_keys, ", ")))

print("[example.input_action_map] === Unbind a single key ===")

actions:unbind("jump", "gamepad_a")
jump_keys = actions:getBindings("jump")
print(string.format("  jump after unbind gamepad_a: %s", table.concat(jump_keys, ", ")))

print("[example.input_action_map] === Unbind all keys from an action ===")

actions:unbindAll("menu")
local menu_keys = actions:getBindings("menu")
print(string.format("  menu bindings after unbindAll: %d keys", #menu_keys))

print("[example.input_action_map] === Simulated game loop (one frame) ===")

-- In a real game loop you would call update() each frame:
actions:update()

-- Query actions (will return false outside of engine runtime)
local jumped = actions:pressed("jump")
local moving_left = actions:held("move_left")
local fired = actions:released("fire")
print(string.format("  pressed(jump)=%s  held(move_left)=%s  released(fire)=%s",
    tostring(jumped), tostring(moving_left), tostring(fired)))

-- Compute horizontal and vertical axes
local h = actions:axis("move_left", "move_right")
local v = actions:axis("move_down", "move_up")
print(string.format("  axis horizontal=%d  vertical=%d", h, v))

print("[example.input_action_map] === Clear all bindings ===")

actions:clear()
local all_gone = actions:getBindings("jump")
print(string.format("  bindings after clear: jump has %d keys", #all_gone))

print("[example.input_action_map] === Done ===")
