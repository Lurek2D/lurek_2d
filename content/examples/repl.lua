-- content/examples/repl.lua
-- Demonstrates the lurek.repl module: in-game developer console with eval, history, and tab-completion.
-- Run: cargo run -- content/examples/repl.lua

--@api-stub: lurek.repl.new
-- Creates a REPL session with bounded command history (default 200 entries)
do
  -- Use a small history limit for a dev console that only keeps recent commands.
  -- Omit the argument to get the default 200-entry buffer.
  local console = lurek.repl.new(64)

  -- A larger session for an automated test runner that replays many commands
  local test_runner = lurek.repl.new(500)

  -- Default history size (200) is fine for most in-game consoles
  local default_console = lurek.repl.new()
end

--@api-stub: LReplSession:eval
-- Evaluates a Lua string and returns the display result (value, output, or error text)
do
  local console = lurek.repl.new(32)

  -- Evaluate an expression — returns the stringified result
  local result = console:eval("2 + 2")
  lurek.log.info("expr result: " .. result, "repl")

  -- Execute a statement that modifies game state at runtime
  console:eval("player_speed = 400")

  -- Errors are returned as strings, not thrown — safe for player input
  local err = console:eval("this is not valid lua!!")
  lurek.log.info("error output: " .. err, "repl")

  -- Use eval to toggle debug overlays from the in-game console
  console:eval("show_hitboxes = not show_hitboxes")
end

--@api-stub: LReplSession:history
-- Returns all recorded inputs as an array, oldest entry first
do
  local console = lurek.repl.new(16)

  -- Simulate a player typing several console commands during a session
  console:eval("god_mode = true")
  console:eval("spawn_enemy('goblin', 3)")
  console:eval("tp(100, 200)")

  -- Retrieve history to display in a scrollable console UI
  local entries = console:history()
  for i, cmd in ipairs(entries) do
    lurek.log.info(i .. ": " .. cmd, "repl")
  end
end

--@api-stub: LReplSession:clear
-- Removes all history entries; useful when switching contexts or resetting the console
do
  local console = lurek.repl.new(16)

  -- Player runs some debug commands
  console:eval("noclip = true")
  console:eval("set_level(5)")

  -- Clear history when transitioning to a new game scene so old
  -- commands don't clutter the scrollback
  console:clear()

  -- History is now empty
  local count = console:len()
  lurek.log.info("after clear: " .. tostring(count) .. " entries", "repl")
end

--@api-stub: LReplSession:len
-- Returns the current number of stored history entries
do
  local console = lurek.repl.new(8)

  -- Track how many commands the player has entered this session
  console:eval("help()")
  console:eval("list_items()")
  console:eval("equip('sword')")

  local n = console:len()
  lurek.log.info("commands entered: " .. tostring(n), "repl")

  -- Use len() to show "3/8 history slots used" in the console UI
  local max = 8
  lurek.log.info(tostring(n) .. "/" .. tostring(max) .. " history slots", "repl")
end

--@api-stub: LReplSession:complete
-- Returns an array of completion candidates matching a prefix (for tab-completion)
do
  local console = lurek.repl.new(16)

  -- Simulate tab-completion when the player types "lurek.re" and presses Tab
  local matches = console:complete("lurek.re")
  lurek.log.info("completions for 'lurek.re': " .. tostring(#matches), "repl")

  -- Display matches as a dropdown in the console overlay
  for _, candidate in ipairs(matches) do
    lurek.log.info("  " .. candidate, "repl")
  end

  -- Complete a shorter prefix to show broader results
  local broad = console:complete("lurek.")
  lurek.log.info("completions for 'lurek.': " .. tostring(#broad), "repl")
end

--@api-stub: LReplSession:type
-- Returns the type name string "LReplSession" for this handle
do
  local console = lurek.repl.new()

  -- Useful for generic object inspection in a debug console
  local t = console:type()
  lurek.log.info("handle type: " .. t, "repl")
end

--@api-stub: LReplSession:typeOf
-- Checks whether this handle matches a given type name (supports "LReplSession" and "Object")
do
  local console = lurek.repl.new()

  -- Guard code that accepts any lurek object and needs to detect a REPL session
  if console:typeOf("LReplSession") then
    lurek.log.info("confirmed: this is a REPL session", "repl")
  end

  -- All lurek handles also match "Object"
  if console:typeOf("Object") then
    lurek.log.info("also matches base Object type", "repl")
  end
end

print("content/examples/repl.lua")
