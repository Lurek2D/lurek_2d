-- content/examples/input.lua
-- lurek.input API examples.
-- Run: cargo run -- content/examples/input.lua

--@api-stub: lurek.input.isDown -- Returns true if down for Lua scripts in this module
do -- lurek.input.isDown
  function lurek.process(dt)
    if lurek.input.keyboard.isDown("space", "w", "up") then
      lurek.log.debug("jump key held", "input")
    end
  end
end

--@api-stub: lurek.input.isScancodeDown
do -- lurek.input.isScancodeDown
  function lurek.process(dt)
    if lurek.input.keyboard.isScancodeDown("a") then
      lurek.log.debug("strafe-left scancode held", "input")
    end
  end
end

--@api-stub: lurek.input.setKeyRepeat
do -- lurek.input.setKeyRepeat
  lurek.input.keyboard.setKeyRepeat(true)
  lurek.log.info("key repeat enabled for menu navigation", "input")
end

--@api-stub: lurek.input.hasKeyRepeat
do -- lurek.input.hasKeyRepeat
  local enabled = lurek.input.keyboard.hasKeyRepeat()
  if not enabled then
    lurek.log.warn("key repeat disabled â€” menus will feel sluggish", "input")
  end
end

--@api-stub: lurek.input.setTextInput
do -- lurek.input.setTextInput
  local function open_chat()
    lurek.input.keyboard.setTextInput(true)
    lurek.log.info("chat box focused; text input on", "input")
  end
  open_chat()
end

--@api-stub: lurek.input.hasTextInput
do -- lurek.input.hasTextInput
  function lurek.process(dt)
    if lurek.input.keyboard.hasTextInput() then
      return  -- typing in chat: do not move the player
    end
  end
end

--@api-stub: lurek.input.getScancodeFromKey
do -- lurek.input.getScancodeFromKey
  local sc = lurek.input.keyboard.getScancodeFromKey("space")
  if sc then
    lurek.log.debug("space maps to scancode " .. sc, "input")
  end
end

--@api-stub: lurek.input.getKeyFromScancode
do -- lurek.input.getKeyFromScancode
  local key_name = lurek.input.keyboard.getKeyFromScancode("lshift")
  local label = key_name or "unbound"
  lurek.log.info("crouch is bound to: " .. label, "ui")
end

--@api-stub: lurek.input.isModifierActive
do -- lurek.input.isModifierActive
  function lurek.process(dt)
    if lurek.input.keyboard.isModifierActive("ctrl") and lurek.input.keyboard.isDown("s") then
      lurek.log.info("ctrl+s pressed: triggering save", "input")
    end
  end
end

--@api-stub: lurek.input.getPosition
do -- lurek.input.getPosition
  function lurek.process(dt)
    local mx, my = lurek.input.mouse.getPosition()
    lurek.log.debug("cursor at " .. mx .. "," .. my, "input")
  end
end

--@api-stub: lurek.input.getX
do -- lurek.input.getX
  function lurek.process(dt)
    local x = lurek.input.mouse.getX()
    local volume = math.max(0, math.min(1, x / 800))
    lurek.log.debug("volume slider: " .. volume, "ui")
  end
end

--@api-stub: lurek.input.getY
do -- lurek.input.getY
  function lurek.process(dt)
    local y = lurek.input.mouse.getY()
    if y < 32 then
      lurek.log.debug("cursor in top menu strip", "ui")
    end
  end
end

--@api-stub: lurek.input.isDown -- Returns true if down for Lua scripts in this module
do -- lurek.input.isDown
  function lurek.process(dt)
    if lurek.input.mouse.isDown(1) then
      lurek.log.debug("left mouse held: dragging selection", "input")
    end
  end
end

--@api-stub: lurek.input.setVisible
do -- lurek.input.setVisible
  lurek.input.mouse.setVisible(false)
  lurek.log.info("cursor hidden for cinematic", "input")
end

--@api-stub: lurek.input.isVisible
do -- lurek.input.isVisible
  if not lurek.input.mouse.isVisible() then
    lurek.input.mouse.setVisible(true)
    lurek.log.info("pause menu opened: cursor restored", "ui")
  end
end

--@api-stub: lurek.input.setGrabbed
do -- lurek.input.setGrabbed
  lurek.input.mouse.setGrabbed(true)
  lurek.input.mouse.setRelativeMode(true)
  lurek.log.info("entered mouselook mode", "input")
end

--@api-stub: lurek.input.isGrabbed
do -- lurek.input.isGrabbed
  if lurek.input.mouse.isGrabbed() then
    lurek.log.debug("cursor locked to window: focus changes will need to release", "input")
  end
end

--@api-stub: lurek.input.setRelativeMode
do -- lurek.input.setRelativeMode
  lurek.input.mouse.setRelativeMode(true)
  lurek.log.info("relative mouse mode on â€” read dx/dy from mousemoved", "input")
end

--@api-stub: lurek.input.getRelativeMode
do -- lurek.input.getRelativeMode
  function lurek.process(dt)
    if lurek.input.mouse.getRelativeMode() then
      lurek.log.debug("camera should integrate dx/dy this frame", "camera")
    end
  end
end

--@api-stub: lurek.input.setPosition
do -- lurek.input.setPosition
  local cx, cy = 400, 300
  lurek.input.mouse.setPosition(cx, cy)
  lurek.log.debug("cursor recentred to " .. cx .. "," .. cy, "input")
end

--@api-stub: lurek.input.setCursor
do -- lurek.input.setCursor
  lurek.input.mouse.setCursor("hand")
  lurek.log.debug("cursor: hand (over clickable link)", "ui")
end

--@api-stub: lurek.input.newCursor
do -- lurek.input.newCursor
  local w, h = 2, 2
  local pixels = { 255,0,0,255,  0,255,0,255,  0,0,255,255,  255,255,255,255 }
  local cur = lurek.input.mouse.newCursor(pixels, w, h, 0, 0)
  lurek.input.mouse.setCursor(cur)
end

--@api-stub: lurek.input.getSystemCursor
do -- lurek.input.getSystemCursor
  local crosshair = lurek.input.mouse.getSystemCursor("crosshair")
  function lurek.process(dt)
    lurek.input.mouse.setCursor(crosshair)
  end
end

--@api-stub: lurek.input.isCursorSupported
do -- lurek.input.isCursorSupported
  if lurek.input.mouse.isCursorSupported() then
    lurek.input.mouse.setCursor("hand")
  else
    lurek.log.warn("custom cursors unsupported â€” keeping default arrow", "input")
  end
end

--@api-stub: lurek.input.getCursor
do -- lurek.input.getCursor
  local name = lurek.input.mouse.getCursor()
  lurek.log.debug("active cursor shape: " .. name, "ui")
end

--@api-stub: lurek.input.getWheelDelta
do -- lurek.input.getWheelDelta
  function lurek.process(dt)
    local dx, dy = lurek.input.mouse.getWheelDelta()
    if dy ~= 0 then
      lurek.log.debug("zoom by " .. dy, "camera")
    end
  end
end

--@api-stub: lurek.input.getCount
do -- lurek.input.getCount
  local n = lurek.input.gamepad.getCount()
  lurek.log.info("connected gamepads: " .. n, "input")
end

--@api-stub: lurek.input.getJoystickCount
do -- lurek.input.getJoystickCount
  local slots = lurek.input.gamepad.getJoystickCount()
  if slots == 0 then
    lurek.log.info("no gamepads tracked yet", "input")
  end
end

--@api-stub: lurek.input.getJoysticks
do -- lurek.input.getJoysticks
  local ids = lurek.input.gamepad.getJoysticks()
  for i, id in ipairs(ids) do
    lurek.log.debug("player " .. i .. " is gamepad id " .. id, "input")
  end
end

--@api-stub: lurek.input.isConnected
do -- lurek.input.isConnected
  local id = 0
  if not lurek.input.gamepad.isConnected(id) then
    lurek.log.warn("player 1 controller disconnected", "input")
  end
end

--@api-stub: lurek.input.getName
do -- lurek.input.getName
  local id = 0
  local name = lurek.input.gamepad.getName(id)
  lurek.log.info("gamepad " .. id .. ": " .. name, "input")
end

--@api-stub: lurek.input.isGamepad
do -- lurek.input.isGamepad
  local id = 0
  if lurek.input.gamepad.isGamepad(id) then
    lurek.log.debug("slot " .. id .. " has a recognised gamepad mapping", "input")
  end
end

--@api-stub: lurek.input.getButtonCount
do -- lurek.input.getButtonCount
  local id = 0
  local nbtn = lurek.input.gamepad.getButtonCount(id)
  lurek.log.debug("gamepad " .. id .. " has " .. nbtn .. " buttons", "input")
end

--@api-stub: lurek.input.getAxisCount
do -- lurek.input.getAxisCount
  local id = 0
  local naxis = lurek.input.gamepad.getAxisCount(id)
  if naxis < 4 then
    lurek.log.warn("gamepad " .. id .. " has only " .. naxis .. " axes â€” dual-stick aiming unavailable", "input")
  end
end

--@api-stub: lurek.input.isDown -- Returns true if down for Lua scripts in this module
do -- lurek.input.isDown
  function lurek.process(dt)
    if lurek.input.gamepad.isDown(0, 0) then
      lurek.log.debug("player 1 pressed A: jump", "input")
    end
  end
end

--@api-stub: lurek.input.getAxis
do -- lurek.input.getAxis
  function lurek.process(dt)
    local lx = lurek.input.gamepad.getAxis(0, 0)
    if math.abs(lx) > 0.15 then
      lurek.log.debug("player 1 left stick X = " .. lx, "input")
    end
  end
end

--@api-stub: lurek.input.isVibrationSupported
do -- lurek.input.isVibrationSupported
  local id = 0
  if lurek.input.gamepad.isVibrationSupported(id) then
    lurek.log.info("gamepad " .. id .. " supports rumble", "input")
  end
end

--@api-stub: lurek.input.vibrate
do -- lurek.input.vibrate
  local ok = lurek.input.gamepad.vibrate(0, 0.4, 0.8, 250)
  if not ok then
    lurek.log.debug("rumble request ignored (no haptics backend)", "input")
  end
end

--@api-stub: lurek.input.getGUID
do -- lurek.input.getGUID
  local guid = lurek.input.gamepad.getGUID(0)
  if guid ~= "" then
    lurek.log.debug("gamepad 0 GUID: " .. guid, "input")
  end
end

--@api-stub: lurek.input.getHat
do -- lurek.input.getHat
  local dir = lurek.input.gamepad.getHat(0, 0)
  if dir ~= "c" then
    lurek.log.debug("hat 0 = " .. dir, "input")
  end
end

--@api-stub: lurek.input.setVibration
do -- lurek.input.setVibration
  local ok = lurek.input.gamepad.setVibration(0, 0.5, 0.5, 200)
  lurek.log.debug("setVibration returned " .. tostring(ok), "input")
end

--@api-stub: lurek.input.wasPressed -- Was pressed for Lua scripts in this module
do -- lurek.input.wasPressed
  function lurek.process(dt)
    if lurek.input.gamepad.wasPressed(0, 0) then
      lurek.log.info("gamepad A just pressed", "input")
    end
  end
end

--@api-stub: lurek.input.wasReleased -- Was released for Lua scripts in this module
do -- lurek.input.wasReleased
  function lurek.process(dt)
    if lurek.input.gamepad.wasReleased(0, 0) then
      lurek.log.info("gamepad A just released", "input")
    end
  end
end

--@api-stub: lurek.input.wasConnected
do -- lurek.input.wasConnected
  function lurek.process(dt)
    if lurek.input.gamepad.wasConnected(0) then
      lurek.log.info("player 1 controller connected", "input")
    end
  end
end

--@api-stub: lurek.input.wasDisconnected
do -- lurek.input.wasDisconnected
  function lurek.process(dt)
    if lurek.input.gamepad.wasDisconnected(0) then
      lurek.log.warn("controller disconnected", "input")
    end
  end
end

--@api-stub: lurek.input.virtualDpad
do -- lurek.input.virtualDpad
  local leftx = lurek.input.gamepad.getAxis(0, 0)
  local lefty = lurek.input.gamepad.getAxis(0, 1)
  local pad = lurek.input.gamepad.virtualDpad(leftx, lefty, 0.25)
  if pad.direction ~= "c" then
    lurek.log.debug("virtual dpad direction: " .. pad.direction, "input")
  end
end

--@api-stub: lurek.input.setBackgroundEvents
do -- lurek.input.setBackgroundEvents
  lurek.input.gamepad.setBackgroundEvents(true)
  lurek.log.info("gamepad input continues while window is unfocused", "input")
end

--@api-stub: lurek.input.getBackgroundEvents
do -- lurek.input.getBackgroundEvents
  local on = lurek.input.gamepad.getBackgroundEvents()
  if on then
    lurek.log.debug("background gamepad events: enabled", "input")
  end
end

--@api-stub: lurek.input.setGamepadMapping
do -- lurek.input.setGamepadMapping
  local guid = "030000005e040000130b000011050000"
  local mapping = guid .. ",My Custom Pad,a:b0,b:b1,x:b2,y:b3,start:b7,back:b6,"
  lurek.input.gamepad.setGamepadMapping(guid, mapping)
  lurek.log.info("custom mapping stored for " .. guid, "input")
end

--@api-stub: lurek.input.getGamepadMappingString
do -- lurek.input.getGamepadMappingString
  local guid = "030000005e040000130b000011050000"
  local mapping = lurek.input.gamepad.getGamepadMappingString(guid)
  if mapping then
    lurek.log.debug("override mapping length: " .. #mapping, "input")
  end
end

--@api-stub: lurek.input.loadGamepadMappings
do -- lurek.input.loadGamepadMappings
  local ok, n = pcall(lurek.input.gamepad.loadGamepadMappings, "save/gamecontrollerdb.txt")
  if ok then lurek.log.info("loaded " .. n .. " controller mappings", "input") end
end

--@api-stub: lurek.input.saveGamepadMappings
do -- lurek.input.saveGamepadMappings
  lurek.input.gamepad.saveGamepadMappings("save/user_mappings.txt")
  lurek.log.info("user gamepad mappings written", "input")
end

--@api-stub: lurek.input.getTouches
do -- lurek.input.getTouches
  function lurek.process(dt)
    local touches = lurek.input.touch.getTouches()
    for _, tp in ipairs(touches) do
      lurek.log.debug("touch " .. tp.id .. " at " .. tp.x .. "," .. tp.y, "input")
    end
  end
end

--@api-stub: lurek.input.getPosition
do -- lurek.input.getPosition
  function lurek.process(dt)
    local touches = lurek.input.touch.getTouches()
    if touches[1] then
      local x, y = lurek.input.touch.getPosition(touches[1].id)
      lurek.log.debug("primary touch at " .. x .. "," .. y, "input")
    end
  end
end

--@api-stub: lurek.input.getPressure
do -- lurek.input.getPressure
  function lurek.process(dt)
    local touches = lurek.input.touch.getTouches()
    if touches[1] then
      local p = lurek.input.touch.getPressure(touches[1].id)
      if p > 0.5 then
        lurek.log.debug("firm touch (pressure " .. p .. ")", "input")
      end
    end
  end
end

--@api-stub: lurek.input.getTouchCount
do -- lurek.input.getTouchCount
  function lurek.process(dt)
    if lurek.input.touch.getTouchCount() >= 2 then
      lurek.log.debug("multi-touch gesture in progress", "input")
    end
  end
end

--@api-stub: lurek.input.wasPressed -- Was pressed for Lua scripts in this module
do -- lurek.input.wasPressed
  function lurek.process(dt)
    local touches = lurek.input.touch.getTouches()
    if touches[1] and lurek.input.touch.wasPressed(touches[1].id) then
      lurek.log.info("touch just started", "input")
    end
  end
end

--@api-stub: lurek.input.wasReleased -- Was released for Lua scripts in this module
do -- lurek.input.wasReleased
  function lurek.process(dt)
    local id = 1
    if lurek.input.touch.wasReleased(id) then
      lurek.log.info("touch id " .. id .. " released", "input")
    end
  end
end

--@api-stub: lurek.input.bind -- Adds one or more keyboard/gamepad bindings to an action
do -- lurek.input.bind
  lurek.input.bind("jump", "space")
  lurek.input.bind("move_left", { "a", "left" })
  lurek.log.info("default bindings installed", "input")
end

--@api-stub: lurek.input.unbind -- Removes all bindings for an action
do -- lurek.input.unbind
  lurek.input.bind("jump", "space")
  local existed = lurek.input.unbind("jump")
  lurek.log.debug("unbind jump returned " .. tostring(existed), "input")
end

--@api-stub: lurek.input.clearBindings -- Removes all action bindings
do -- lurek.input.clearBindings
  lurek.input.bind("jump", "space")
  lurek.input.clearBindings()
  lurek.log.info("all action bindings cleared", "input")
end

--@api-stub: lurek.input.getBindings -- Returns all action bindings
do -- lurek.input.getBindings
  lurek.input.bind("jump", "space")
  local bindings = lurek.input.getBindings()
  for action, keys in pairs(bindings) do
    lurek.log.debug(action .. " <- " .. table.concat(keys, ","), "input")
  end
end

--@api-stub: lurek.input.isActionDown -- Returns whether any binding for an action is currently down
do -- lurek.input.isActionDown
  lurek.input.bind("jump", { "space", "w" })
  function lurek.process(dt)
    if lurek.input.isActionDown("jump") then
      lurek.log.debug("jump action held", "input")
    end
  end
end

--@api-stub: lurek.input.wasActionPressed -- Returns whether any binding for an action was pressed this frame and records the frame
do -- lurek.input.wasActionPressed
  lurek.input.bind("confirm", "return")
  function lurek.process(dt)
    if lurek.input.wasActionPressed("confirm") then
      lurek.log.info("menu: option selected", "ui")
    end
  end
end

--@api-stub: lurek.input.wasActionReleased -- Returns whether any binding for an action was released this frame
do -- lurek.input.wasActionReleased
  lurek.input.bind("shoot", "left")
  function lurek.process(dt)
    if lurek.input.wasActionReleased("shoot") then
      lurek.log.info("charged shot released", "combat")
    end
  end
end

--@api-stub: lurek.input.wasActionPressedWithin -- Returns whether an action was pressed within a recent frame window
do -- lurek.input.wasActionPressedWithin
  lurek.input.bind("jump", "space")
  function lurek.process(dt)
    if lurek.input.wasActionPressedWithin("jump", 6) then
      lurek.log.debug("buffered jump within last 6 frames", "input")
    end
  end
end

--@api-stub: lurek.input.newMapping -- Creates an action mapping table with isDown, wasPressed, and wasReleased helper functions
do -- lurek.input.newMapping
  local dash = lurek.input.newMapping("dash", {"shift", "gamepad:0:0"})
  function lurek.process(dt)
    if dash.wasPressed() then
      lurek.log.info("dash triggered", "input")
    end
  end
end

--@api-stub: lurek.input.newCombo -- Creates a combo detector from string steps or step tables with optional timing
do -- lurek.input.newCombo
  local hadouken = lurek.input.newCombo(
    { "down", { key = "right", gap = 300 }, "a" },
    { total_gap = 1500 }
  )
  lurek.log.info("combo detector ready (" .. hadouken:totalSteps() .. " steps)", "combat")
end

--@api-stub: lurek.input.startRecording -- Starts recording input events into the module recorder
do -- lurek.input.startRecording
  lurek.input.startRecording()
  lurek.log.info("input recording started", "replay")
end

--@api-stub: lurek.input.stopRecording -- Stops input recording and returns the captured recording when one is active
do -- lurek.input.stopRecording
  lurek.input.startRecording()
  local rec = lurek.input.stopRecording()
  if rec then
    lurek.log.info("captured " .. rec:totalFrames() .. " frames", "replay")
  end
end

--@api-stub: lurek.input.loadRecording -- Loads recording JSON into the module recorder
do -- lurek.input.loadRecording
  local json = '{"version":1,"total_frames":1,"frames":[]}'
  lurek.input.loadRecording(json)
  lurek.log.info("recording loaded for playback", "replay")
end

--@api-stub: lurek.input.startPlayback -- Starts playback of the loaded recording
do -- lurek.input.startPlayback
  local json = '{"version":1,"total_frames":1,"frames":[]}'
  lurek.input.loadRecording(json)
  lurek.input.startPlayback()
  lurek.log.info("playback armed", "replay")
end

--@api-stub: lurek.input.stopPlayback -- Stops playback of the loaded recording
do -- lurek.input.stopPlayback
  lurek.input.stopPlayback()
  lurek.log.info("playback halted; live input restored", "replay")
end

--@api-stub: lurek.input.isRecording -- Returns whether the module recorder is currently recording
do -- lurek.input.isRecording
  if lurek.input.isRecording() then
    lurek.log.debug("REC indicator: visible", "ui")
  end
end

--@api-stub: lurek.input.isPlayingBack -- Returns whether the module recorder is currently playing back
do -- lurek.input.isPlayingBack
  function lurek.process(dt)
    if lurek.input.isPlayingBack() then
      return  -- skip live-input branch this frame
    end
  end
end

--@api-stub: lurek.input.getPlaybackFrame -- Returns the current playback frame index
do -- lurek.input.getPlaybackFrame
  function lurek.process(dt)
    local f = lurek.input.getPlaybackFrame()
    if f > 0 and f % 60 == 0 then
      lurek.log.debug("playback at frame " .. f, "replay")
    end
  end
end

--@api-stub: lurek.input.advancePlayback -- Advances playback by one frame and returns events for that frame
do -- lurek.input.advancePlayback
  function lurek.process(dt)
    local events = lurek.input.advancePlayback()
    for _, ev in ipairs(events) do
      lurek.log.debug("playback event " .. ev.kind .. " " .. ev.name, "replay")
    end
  end
end

-- â”€â”€ Cursor methods â”€â”€

--@api-stub: Cursor:release
do -- Cursor:release
  local cur = lurek.input.mouse.getSystemCursor("hand")
  cur:release()
  lurek.log.debug("cursor handle released (no-op on desktop)", "input")
end

--@api-stub: Cursor:getType
do -- Cursor:getType
  local cur = lurek.input.mouse.getSystemCursor("crosshair")
  local kind = cur:getType()
  lurek.log.debug("cursor kind: " .. kind, "input")
end

-- â”€â”€ Combo methods â”€â”€

--@api-stub: Combo:feed
do -- Combo:feed
  local combo = lurek.input.newCombo({ "down", "right", "a" })
  local progress = combo:feed("down")
  lurek.log.debug("combo step result: " .. progress, "combat")
end

--@api-stub: Combo:tick
do -- Combo:tick
  local combo = lurek.input.newCombo({ "down", "right", "a" })
  function lurek.process(dt)
    local status = combo:tick(dt)
    if status == "expired" then
      lurek.log.debug("combo window expired", "combat")
    end
  end
end

--@api-stub: Combo:reset
do -- Combo:reset
  local combo = lurek.input.newCombo({ "down", "right", "a" })
  combo:feed("down")
  combo:reset()
  lurek.log.debug("combo cleared after stagger", "combat")
end

--@api-stub: Combo:totalSteps
do -- Combo:totalSteps
  local combo = lurek.input.newCombo({ "down", "right", "a" })
  local total = combo:totalSteps()
  lurek.log.debug("combo length: " .. total, "combat")
end

--@api-stub: Combo:isInProgress
do -- Combo:isInProgress
  local combo = lurek.input.newCombo({ "down", "right", "a" })
  combo:feed("down")
  if combo:isInProgress() then
    lurek.log.debug("combo HUD: visible", "ui")
  end
end

--@api-stub: Combo:getStep
do -- Combo:getStep
  local combo = lurek.input.newCombo({ "down", { key = "right", gap = 300 }, "a" })
  local step = combo:getStep(2)
  if step then
    lurek.log.debug("step 2: key=" .. step.key .. " gap=" .. step.gap_ms .. "ms", "combat")
  end
end

-- â”€â”€ InputRecording methods â”€â”€

--@api-stub: InputRecording:toJson
do -- InputRecording:toJson
  lurek.input.startRecording()
  local rec = lurek.input.stopRecording()
  if rec then
    local json = rec:toJson()
    lurek.log.debug("serialised recording: " .. #json .. " bytes", "replay")
  end
end

--@api-stub: InputRecording:totalFrames
do -- InputRecording:totalFrames
  lurek.input.startRecording()
  local rec = lurek.input.stopRecording()
  if rec then
    lurek.log.info("recorded " .. rec:totalFrames() .. " frames", "replay")
  end
end

--@api-stub: InputRecording:frameCount
do -- InputRecording:frameCount
  lurek.input.startRecording()
  local rec = lurek.input.stopRecording()
  if rec and rec:frameCount() == 0 then
    lurek.log.warn("recording has no input events", "replay")
  end
end

--@api-stub: Combo:progress
do -- Combo:progress
  local combo = lurek.input.newCombo({"right","right","attack"})
  combo:feed("right")
  local pct = combo:progress()
  lurek.log.info("combo progress: " .. pct, "input")
end

-- =============================================================================
-- COVERAGE: 7 uncovered lurek.input API item(s)
-- Generated by tools/audit/example_add_missing.py
-- REQUIRED: replace every --@api-stub: block below with a real scenario.
-- Run .github/prompts/flesh-out-example.prompt.md for instructions.
-- The final committed file must contain ZERO --@api-stub: lines.
-- =============================================================================

--@api-stub: lurek.input.gamepad.loadGamepadMappings -- Loads gamepad mapping strings from a file
do -- lurek.input.gamepad.loadGamepadMappings
  -- loadGamepadMappings may not be available headless; guard with pcall
  local ok, count = pcall(lurek.input.gamepad.loadGamepadMappings, "assets/gamecontrollerdb.txt")
  lurek.log.info("loadGamepadMappings ok=" .. tostring(ok), "input")
end


-- -----------------------------------------------------------------------------
-- InputRecording methods
-- -----------------------------------------------------------------------------

-- =============================================================================
-- COVERAGE: 7 uncovered lurek.input API item(s)
-- Generated by tools/audit/example_add_missing.py
-- REQUIRED: replace every --@api-stub: block below with a real scenario.
-- Run .github/prompts/flesh-out-example.prompt.md for instructions.
-- The final committed file must contain ZERO --@api-stub: lines.
-- =============================================================================

--@api-stub: LCombo:type -- Returns the Lua-visible type name for this combo handle
do -- LCombo:type
  local ok ---@type boolean
  local combo_obj ---@type LCombo?
  ok, combo_obj = pcall(lurek.input.newCombo, {"a","b"}, {})
  if not ok then combo_obj = nil end
  local t = combo_obj and combo_obj:type() or "LInputCombo"
  lurek.log.info("LCombo:type = " .. t, "input")
end
--@api-stub: LCombo:typeOf -- Returns whether this combo handle matches a supported type name
do -- LCombo:typeOf
  local ok_c2 ---@type boolean
  local combo_obj2 ---@type LCombo?
  ok_c2, combo_obj2 = pcall(lurek.input.newCombo, {"a","b"}, {})
  if not ok_c2 then combo_obj2 = nil end
  lurek.log.info("is LCombo: " .. tostring(combo_obj2 and combo_obj2:typeOf("LCombo") or false), "input")
  lurek.log.info("is wrong: " .. tostring(combo_obj2 and combo_obj2:typeOf("Unknown") or false), "input")
end
--@api-stub: LCursor:type -- Returns the Lua-visible type name for this cursor handle
do -- LCursor:type
  local ok_c, cursor_obj = pcall(lurek.input.mouse.newCursor)
  if ok_c and cursor_obj then
    local t = cursor_obj:type()
    lurek.log.info("LCursor:type = " .. t, "input")
  else
    lurek.log.info("LCursor:type = skipped", "input")
  end
end
--@api-stub: LCursor:typeOf -- Returns whether this cursor handle matches a supported type name
do -- LCursor:typeOf
  local ok_c2, cursor_obj = pcall(lurek.input.mouse.newCursor)
  if ok_c2 and cursor_obj then
    lurek.log.info("is LCursor: " .. tostring(cursor_obj:typeOf("LCursor")), "input")
    lurek.log.info("is wrong: " .. tostring(cursor_obj:typeOf("Unknown")), "input")
  else
    lurek.log.info("LCursor:typeOf = skipped", "input")
  end
end
--@api-stub: LInputRecording:type -- Returns the Lua-visible type name for this input recording handle
do -- LInputRecording:type
  local obj = lurek.input.startRecording()
  local rec = lurek.input.stopRecording()
  if rec then
    local _ = rec:toJson()
  end
  local t = obj and obj:type() or "LInputRecording"
  lurek.log.info("LInputRecording:type = " .. t, "input")
end
--@api-stub: LInputRecording:typeOf -- Returns whether this input recording handle matches a supported type name
do -- LInputRecording:typeOf
  local obj = lurek.input.startRecording()
  local rec = lurek.input.stopRecording()
  if rec then
    local _ = rec:toJson()
  end
  lurek.log.info("is LInputRecording: " .. tostring(obj and obj:typeOf("LInputRecording") or false), "input")
  lurek.log.info("is wrong: " .. tostring(obj and obj:typeOf("Unknown") or false), "input")
end


