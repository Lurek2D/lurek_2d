-- Constants (grouped into C to stay within LuaJIT 60-upvalue limit)
local C = {
  SCREEN_W=800, SCREEN_H=600, WATER_Y=300, SHORE_X=80,
  ROD_TIP_X=110, ROD_TIP_Y=240,
  MAX_CAST_DIST=400, HOOK_WINDOW=1.5,
  TENSION_SNAP=0.80, TENSION_SNAP_TIME=2.0, TENSION_SAFE=0.20,
  REEL_SPEED=60, FISH_PULL_SPEED=30, FISH_BURST_CALM=3.0, FISH_BURST_PULL=1.0,
  LAND_DIST=20, DAY_CYCLE=120, WIN_COUNT=10,
  BITE_MIN=3.0, BITE_MAX=10.0, RAIN_BITE_MULT=0.5,
}
local STATES = {
  TITLE="TITLE", FISHING="FISHING", CATCHING="CATCHING",
  BUCKET="BUCKET_VIEW", GAMEOVER="GAME_OVER",
}

--[[

  Fishing — Lurek2D
  Category: sports

  Side-view lake fishing game with casting, reeling tension minigame,
  five fish species, bait selection, day/night cycle, and weather.
]]



-- Fish definitions
local FISH_TYPES = {
  { name = "Minnow",      points = 5,   fight = 0.3, deep = false, rarity = 0.40, color = {0.7, 0.7, 0.7} },
  { name = "Trout",       points = 15,  fight = 0.5, deep = false, rarity = 0.25, color = {0.3, 0.7, 0.4} },
  { name = "Bass",        points = 30,  fight = 0.7, deep = false, rarity = 0.15, color = {0.2, 0.5, 0.2} },
  { name = "Catfish",     points = 25,  fight = 0.5, deep = true,  rarity = 0.10, color = {0.5, 0.4, 0.3} },
  { name = "Golden Fish", points = 100, fight = 0.9, deep = false, rarity = 0.05, color = {1.0, 0.85, 0.0} },
}

-- Bait definitions
local BAITS = {
  { name = "Worm",      boost = {} },
  { name = "Fly",       boost = { Trout = 2.0, Bass = 1.5 } },
  { name = "Deep Bait", boost = { Catfish = 3.0 } },
}

-- Game state
local state = STATES.TITLE
local power = 0
local charging = false
local cast_x = 0
local bobber_y = C.WATER_Y
local bobber_base_y = C.WATER_Y
local bite_timer = 0
local bite_active = false
local hook_timer = 0
local hooked_fish = nil  ---@type table?
local tension = 0.40
local tension_high_timer = 0
local fish_x = 0
local fish_fight_timer = 0
local fish_bursting = false
local bucket = {}
local total_points = 0
local day_timer = 0
local is_night = false
local raining = false
local rain_timer = 0
local rain_duration = 0
local bait_index = 1
local message = ""
local message_timer = 0
local dt = 0
local bobber_dip_tween = nil
local tension_tween = nil
local fish_approach_tween = nil
local splash_particles = {}
local rain_particles = {}
local sparkle_particles = {}
local ripple_particles = {}
local game_won = false
local win_reason = ""

-- Helpers
local function clamp(v, lo, hi) return math.max(lo, math.min(hi, v)) end

local function lerp(a, b, t) return a + (b - a) * clamp(t, 0, 1) end

local function show_message(msg, dur)
  message = msg
  message_timer = dur or 2.0
end

local function pick_fish()
  local weights = {}
  local total = 0
  local night_mult = is_night and 2.0 or 1.0
  local bait = BAITS[bait_index]
  local deep_cast = cast_x > C.SHORE_X + C.MAX_CAST_DIST * 0.7

  for i, f in ipairs(FISH_TYPES) do
    local w = f.rarity
    if f.deep and not deep_cast then
      w = 0
    end
    if f.name == "Golden Fish" or f.name == "Catfish" then
      w = w * night_mult
    end
    if bait.boost[f.name] then
      w = w * bait.boost[f.name]
    end
    weights[i] = w
    total = total + w
  end

  local r = math.random() * total
  local acc = 0
  for i, w in ipairs(weights) do
    acc = acc + w
    if r <= acc then return FISH_TYPES[i] end
  end
  return FISH_TYPES[1]
end

local function spawn_splash(x, y, count)
  for _ = 1, count do
    table.insert(splash_particles, {
      x = x, y = y,
      vx = (math.random() - 0.5) * 120,
      vy = -math.random() * 80 - 40,
      life = 0.5 + math.random() * 0.3,
    })
  end
end

local function spawn_sparkle(x, y, count)
  for _ = 1, count do
    table.insert(sparkle_particles, {
      x = x, y = y,
      vx = (math.random() - 0.5) * 60,
      vy = -math.random() * 60 - 20,
      life = 0.8 + math.random() * 0.4,
      size = 2 + math.random() * 3,
    })
  end
end

local function spawn_ripple(x, y)
  table.insert(ripple_particles, {
    x = x, y = y, radius = 2, max_radius = 12 + math.random() * 8, life = 0.6,
  })
end

local function reset_cast()
  power = 0
  charging = false
  cast_x = 0
  bobber_y = C.WATER_Y
  bobber_base_y = C.WATER_Y
  bite_timer = 0
  bite_active = false
  hook_timer = 0
  hooked_fish = nil
  tension = 0.40
  tension_high_timer = 0
  fish_x = 0
  fish_fight_timer = 0
  fish_bursting = false
  bobber_dip_tween = nil
  tension_tween = nil
  fish_approach_tween = nil
end

local function start_game()
  state = STATES.FISHING
  bucket = {}
  total_points = 0
  day_timer = 0
  is_night = false
  raining = false
  rain_timer = 0
  bait_index = 1
  game_won = false
  win_reason = ""
  reset_cast()
  show_message("Cast with SPACE! Bait: 1/2/3", 3)
end

-- Input bindings
lurek.input.bind("cast_reel", { "space", "gamepad:0:0" })
lurek.input.bind("bait1", { "1", "gamepad:0:12" })
lurek.input.bind("bait2", { "2", "gamepad:0:10" })
lurek.input.bind("bait3", { "3", "gamepad:0:13" })
lurek.input.bind("quit", { "escape", "gamepad:0:8" })

lurek.window.setTitle("Fishing — Lurek2D")
lurek.render.setBackgroundColor(0.4, 0.6, 0.8)

-- Callbacks
-- Universal render helpers (handles all legacy and current call signatures)
local _gfx = lurek.render
local function _sc(c)
    if type(c) == "table" then
        local col = c.color or c
        if type(col) == "table" then
            _gfx.setColor(col[1] or 1, col[2] or 1, col[3] or 1, col[4] or 1)
        end
    end
end
local function rect(a, b, c, d, e, f, g, h)
    if type(a) == "string" then
        _gfx.rectangle(a, b, c, d, e)
    elseif type(e) == "table" then
        _sc(e); _gfx.rectangle(e.mode or "fill", a, b, c, d)
    elseif type(e) == "number" then
        _gfx.setColor(e or 1, f or 1, g or 1, h or 1); _gfx.rectangle("fill", a, b, c, d)
    else
        _gfx.rectangle("fill", a, b, c, d)
    end
end
local function circ(a, b, c, d, e, f, g, h)
    if type(a) == "string" then
        if type(e) == "table" then _sc(e)
        elseif type(e) == "number" then _gfx.setColor(e or 1, f or 1, g or 1, h or 1) end
        _gfx.circle(a, b, c, d)
    elseif type(d) == "table" then
        _sc(d); _gfx.circle("fill", a, b, c)
    elseif type(d) == "number" then
        _gfx.setColor(d or 1, e or 1, f or 1, g or 1); _gfx.circle("fill", a, b, c)
    else
        _gfx.circle("fill", a, b, c)
    end
end
local function text_(a, b, c, d, e, f, g, h)
    if type(d) == "table" then
        _sc(d)
    elseif type(d) == "number" and type(e) == "number" then
        _gfx.setColor(e or 1, f or 1, g or 1, h or 1)
    end
    _gfx.print(tostring(a), b, c)
end
local function ln(x1, y1, x2, y2, r, g, b, a)
    if type(r) == "table" then _sc(r)
    elseif r then _gfx.setColor(r, g or 1, b or 1, a or 1) end
    _gfx.line(x1, y1, x2, y2)
end

function lurek.init()
  math.randomseed(os.time())
  
  local ui_root = lurek.ui.loadLayoutFile("content/games/sports/fishing/ui.toml")
  app_ui = {}
  app_ui.title_screen = ui_root:findById("title_screen")
  app_ui.game_over_screen = ui_root:findById("game_over_screen")
  app_ui.bucket_screen = ui_root:findById("bucket_screen")
  app_ui.hud = ui_root:findById("hud")
  
  app_ui.game_over_title = ui_root:findById("game_over_title")
  app_ui.game_over_reason = ui_root:findById("game_over_reason")
  app_ui.game_over_stats = ui_root:findById("game_over_stats")
  app_ui.game_over_bucket = ui_root:findById("game_over_bucket")
  
  app_ui.bucket_stats = ui_root:findById("bucket_stats")
  app_ui.bucket_list = ui_root:findById("bucket_list")
  
  app_ui.fps_label = ui_root:findById("fps_label")
  app_ui.bait_label = ui_root:findById("bait_label")
  app_ui.bucket_label = ui_root:findById("bucket_label")
  app_ui.points_label = ui_root:findById("points_label")
  app_ui.day_night_label = ui_root:findById("day_night_label")
  app_ui.weather_label = ui_root:findById("weather_label")
  app_ui.message_label = ui_root:findById("message_label")
  
  app_ui.power_panel = ui_root:findById("power_panel")
  app_ui.power_fill = ui_root:findById("power_fill")
  
  app_ui.tension_panel = ui_root:findById("tension_panel")
  app_ui.tension_fill = ui_root:findById("tension_fill")
  app_ui.fish_name_label = ui_root:findById("fish_name_label")
  app_ui.strain_warning = ui_root:findById("strain_warning")
  
  app_ui.press_start = ui_root:findById("press_start")
  app_ui.press_title = ui_root:findById("press_title")
  app_ui.press_resume = ui_root:findById("press_resume")
  
  local function handle_action_click()
    if state == STATES.TITLE then
      start_game()
    elseif state == STATES.GAMEOVER then
      state = STATES.TITLE
    elseif state == STATES.BUCKET then
      state = STATES.FISHING
      reset_cast()
    end
  end
  
  if app_ui.press_start then app_ui.press_start:setOnClick(handle_action_click) end
  if app_ui.press_title then app_ui.press_title:setOnClick(handle_action_click) end
  if app_ui.press_resume then app_ui.press_resume:setOnClick(handle_action_click) end
end

local function _ready_setup()
  show_message("", 0)
end

function lurek.process(delta)
  if lurek.automation then lurek.automation.update(delta) end
  dt = delta

  -- Message timer
  if message_timer > 0 then
    message_timer = message_timer - dt
    if message_timer <= 0 then message = "" end
  end

  -- Quit
  if lurek.input.isActionDown("quit") then
    lurek.event.quit()
    return
  end

  -- Update particles
  for i = #splash_particles, 1, -1 do
    local p = splash_particles[i]
    p.x = p.x + p.vx * dt
    p.y = p.y + p.vy * dt
    p.vy = p.vy + 200 * dt
    p.life = p.life - dt
    if p.life <= 0 then table.remove(splash_particles, i) end
  end
  for i = #sparkle_particles, 1, -1 do
    local p = sparkle_particles[i]
    p.x = p.x + p.vx * dt
    p.y = p.y + p.vy * dt
    p.life = p.life - dt
    if p.life <= 0 then table.remove(sparkle_particles, i) end
  end
  for i = #ripple_particles, 1, -1 do
    local p = ripple_particles[i]
    local t = 1.0 - (p.life / 0.6)
    p.radius = lerp(2, p.max_radius, t)
    p.life = p.life - dt
    if p.life <= 0 then table.remove(ripple_particles, i) end
  end

  -- Rain particles
  if raining then
    for _ = 1, 3 do
      table.insert(rain_particles, {
        x = math.random() * C.SCREEN_W,
        y = -10,
        vy = 300 + math.random() * 100,
        life = 2.0,
      })
    end
  end
  for i = #rain_particles, 1, -1 do
    local p = rain_particles[i]
    p.y = p.y + p.vy * dt
    p.life = p.life - dt
    if p.life <= 0 or p.y > C.SCREEN_H then table.remove(rain_particles, i) end
  end

  -- TITLE
  if state == STATES.TITLE then
    if lurek.input.wasActionPressed("cast_reel") then
      start_game()
    end
  end

  -- GAME OVER
  if state == STATES.GAMEOVER then
    if lurek.input.wasActionPressed("cast_reel") then
      state = STATES.TITLE
    end
  end

  -- BUCKET VIEW
  if state == STATES.BUCKET then
    if lurek.input.wasActionPressed("cast_reel") then
      state = STATES.FISHING
      reset_cast()
    end
  end

  -- UI Sync
  app_ui.title_screen.visible = (state == STATES.TITLE)
  app_ui.game_over_screen.visible = (state == STATES.GAMEOVER)
  app_ui.bucket_screen.visible = (state == STATES.BUCKET)
  app_ui.hud.visible = (state == STATES.FISHING or state == STATES.CATCHING)
  
  if state == STATES.GAMEOVER then
    if game_won then
      app_ui.game_over_title.text = "YOU WIN!"
      app_ui.game_over_title.color = {1.0, 0.9, 0.2, 1.0}
      app_ui.game_over_reason.visible = true
      app_ui.game_over_reason.text = win_reason
    else
      app_ui.game_over_title.text = "GAME OVER"
      app_ui.game_over_title.color = {1.0, 0.3, 0.3, 1.0}
      app_ui.game_over_reason.visible = false
    end
    app_ui.game_over_stats.text = "Fish caught: " .. #bucket .. "\nTotal points: " .. total_points
    
    local blist = ""
    for i, f in ipairs(bucket) do
      if i <= 8 then
        blist = blist .. f.name .. " (" .. f.points .. "pts)\n"
      end
    end
    if #bucket > 8 then
      blist = blist .. "...and " .. (#bucket - 8) .. " more\n"
    end
    app_ui.game_over_bucket.text = blist
  end
  
  if state == STATES.BUCKET then
    app_ui.bucket_stats.text = "Fish: " .. #bucket .. "/" .. C.WIN_COUNT .. "  Points: " .. total_points
    local blist = ""
    for i, f in ipairs(bucket) do
      blist = blist .. i .. ". " .. f.name .. "  +" .. f.points .. "\n"
      if i >= 12 then
        blist = blist .. "..." .. (#bucket - i) .. " more\n"
        break
      end
    end
    app_ui.bucket_list.text = blist
  end
  
  if state == STATES.FISHING or state == STATES.CATCHING then
    app_ui.fps_label.text = "FPS: " .. tostring(math.floor(lurek.timer.getFPS()))
    app_ui.bait_label.text = "Bait: " .. BAITS[bait_index].name
    app_ui.bucket_label.text = "Bucket: " .. #bucket .. "/" .. C.WIN_COUNT
    app_ui.points_label.text = "Points: " .. total_points
    app_ui.day_night_label.text = is_night and "Night" or "Day"
    app_ui.weather_label.visible = raining
    
    app_ui.message_label.text = message
    
    app_ui.power_panel.visible = charging
    if charging then
      local pr = power / 100
      app_ui.power_fill.width = pr * 196
      app_ui.power_fill.bg_color = {pr, 1.0 - pr * 0.5, 0.1, 0.9}
    end
    
    app_ui.tension_panel.visible = (state == STATES.CATCHING)
    if state == STATES.CATCHING then
      app_ui.tension_fill.width = tension * 196
      app_ui.tension_fill.bg_color = {tension, 1.0 - tension, 0.1, 0.9}
      
      if hooked_fish then
        app_ui.fish_name_label.text = hooked_fish.name
        app_ui.fish_name_label.color = {hooked_fish.color[1], hooked_fish.color[2], hooked_fish.color[3], 1.0}
      end
      
      app_ui.strain_warning.visible = (tension > C.TENSION_SNAP and math.sin(day_timer * 10) > 0)
    end
  end
  
  if state ~= STATES.FISHING and state ~= STATES.CATCHING then return end

  -- Day/night cycle
  day_timer = day_timer + dt
  local cycle_pos = day_timer % C.DAY_CYCLE
  is_night = cycle_pos > C.DAY_CYCLE * 0.5

  -- Weather
  rain_timer = rain_timer - dt
  if rain_timer <= 0 then
    raining = not raining
    rain_duration = 10 + math.random() * 20
    rain_timer = rain_duration
    if raining then show_message("Rain starts...", 2) end
  end

  -- Bait selection
  if lurek.input.isActionDown("bait1") then bait_index = 1; show_message("Bait: Worm", 1.5) end
  if lurek.input.isActionDown("bait2") then bait_index = 2; show_message("Bait: Fly", 1.5) end
  if lurek.input.isActionDown("bait3") then bait_index = 3; show_message("Bait: Deep Bait", 1.5) end

  -- FISHING state
  if state == STATES.FISHING then
    if cast_x == 0 then
      -- Charging
      if lurek.input.isActionDown("cast_reel") then
        charging = true
        power = clamp(power + dt * 80, 0, 100)
      elseif charging then
        -- Release cast
        charging = false
        local dist = (power / 100) * C.MAX_CAST_DIST
        cast_x = C.SHORE_X + dist
        bobber_y = C.WATER_Y
        bobber_base_y = C.WATER_Y
        local bite_delay = C.BITE_MIN + math.random() * (C.BITE_MAX - C.BITE_MIN)
        if raining then bite_delay = bite_delay * C.RAIN_BITE_MULT end
        bite_timer = bite_delay
        bite_active = false
        spawn_splash(cast_x, C.WATER_Y, 8)
        spawn_ripple(cast_x, C.WATER_Y)
        show_message("Waiting for a bite...", 2)
        power = 0
      end
    else
      -- Waiting for bite
      if not bite_active then
        bite_timer = bite_timer - dt
        -- Bobber gentle bob
        bobber_y = bobber_base_y + math.sin(day_timer * 3) * 2

        if bite_timer <= 0 then
          bite_active = true
          hook_timer = C.HOOK_WINDOW
          hooked_fish = pick_fish()
          -- Bobber dip
          bobber_dip_tween = { from = bobber_y, to = bobber_y + 15, t = 0, dur = 0.3 }
          show_message("BITE! Press SPACE!", 1.5)
          spawn_ripple(cast_x, C.WATER_Y)
        end
      else
        -- Bite window
        hook_timer = hook_timer - dt

        -- Animate bobber dip
        if bobber_dip_tween then
          bobber_dip_tween.t = bobber_dip_tween.t + dt
          local prog = clamp(bobber_dip_tween.t / bobber_dip_tween.dur, 0, 1)
          local ease = math.sin(prog * math.pi)
          bobber_y = lerp(bobber_dip_tween.from, bobber_dip_tween.to, ease)
          if bobber_dip_tween.t >= bobber_dip_tween.dur then bobber_dip_tween = nil end
        end

        if lurek.input.isActionDown("cast_reel") then
          -- Hooked!
          state = STATES.CATCHING
          fish_x = cast_x
          tension = 0.40
          tension_high_timer = 0
          fish_fight_timer = 0
          fish_bursting = false
          ---@cast hooked_fish table
          show_message("Hooked " .. hooked_fish.name .. "! Reel with SPACE!", 2)
          spawn_splash(cast_x, C.WATER_Y, 5)
        elseif hook_timer <= 0 then
          show_message("Too slow! Fish escaped.", 2)
          reset_cast()
        end
      end

      -- Bucket view shortcut
      if lurek.input.isActionDown("bait1") and cast_x > 0 then
        -- already handled above
      end
    end
  end

  -- CATCHING state
  if state == STATES.CATCHING then
    ---@cast hooked_fish table
    local fight = hooked_fish.fight

    -- Fish fight bursts
    fish_fight_timer = fish_fight_timer + dt
    local cycle_t = fish_fight_timer % (C.FISH_BURST_CALM + C.FISH_BURST_PULL)
    fish_bursting = cycle_t > C.FISH_BURST_CALM

    -- Tension dynamics
    if fish_bursting then
      tension = tension + fight * 0.4 * dt
    else
      tension = tension - 0.05 * dt
    end

    if lurek.input.isActionDown("cast_reel") then
      -- Reeling in
      fish_x = fish_x - C.REEL_SPEED * dt
      tension = tension + 0.15 * dt
      spawn_ripple(fish_x, C.WATER_Y)
    else
      -- Fish pulls away
      if fish_bursting then
        fish_x = fish_x + C.FISH_PULL_SPEED * fight * dt
      end
      tension = tension - 0.08 * dt
    end

    tension = clamp(tension, 0, 1.0)
    fish_x = clamp(fish_x, C.SHORE_X, C.SCREEN_W - 20)

    -- Snap check
    if tension > C.TENSION_SNAP then
      tension_high_timer = tension_high_timer + dt
      if tension_high_timer >= C.TENSION_SNAP_TIME then
        show_message("LINE SNAPPED! " .. hooked_fish.name .. " escaped!", 2.5)
        spawn_splash(fish_x, C.WATER_Y, 10)
        state = STATES.FISHING
        reset_cast()
        return
      end
    else
      tension_high_timer = 0
    end

    -- Land check
    if fish_x <= C.SHORE_X + C.LAND_DIST then
      -- Caught!
      table.insert(bucket, { name = hooked_fish.name, points = hooked_fish.points, color = hooked_fish.color })
      total_points = total_points + hooked_fish.points
      spawn_sparkle(C.SHORE_X + 20, C.WATER_Y - 30, 15)
      spawn_splash(C.SHORE_X, C.WATER_Y, 6)
      show_message("Caught " .. hooked_fish.name .. "! +" .. hooked_fish.points .. "pts", 2.5)

      -- Win check
      if hooked_fish.name == "Golden Fish" then
        game_won = true
        win_reason = "You caught the legendary Golden Fish!"
        state = STATES.GAMEOVER
      elseif #bucket >= C.WIN_COUNT then
        game_won = true
        win_reason = "You filled the bucket with " .. #bucket .. " fish!"
        state = STATES.GAMEOVER
      else
        state = STATES.FISHING
        reset_cast()
      end
    end
  end
end

function lurek.draw()
  -- Sky gradient
  local sky_r, sky_g, sky_b = 0.4, 0.6, 0.9
  if is_night then sky_r, sky_g, sky_b = 0.05, 0.05, 0.15 end
  lurek.render.setBackgroundColor(sky_r, sky_g, sky_b)

  -- Water
  local water_r, water_g, water_b = 0.1, 0.2, 0.5
  if is_night then water_r, water_g, water_b = 0.03, 0.06, 0.15 end
  rect(0, C.WATER_Y, C.SCREEN_W, C.SCREEN_H - C.WATER_Y, water_r, water_g, water_b, 0.85)

  -- Water surface line
  rect(0, C.WATER_Y - 2, C.SCREEN_W, 4, 0.3, 0.5, 0.8, 0.6)

  -- Shore
  rect(0, C.WATER_Y - 10, C.SHORE_X + 10, C.SCREEN_H - C.WATER_Y + 10, 0.45, 0.35, 0.2, 1.0)
  -- Grass
  rect(0, C.WATER_Y - 15, C.SHORE_X + 15, 8, 0.2, 0.6, 0.2, 1.0)

  -- Fisher (stick figure)
  -- Body
  rect(C.SHORE_X - 5, C.WATER_Y - 55, 6, 30, 0.3, 0.2, 0.1, 1.0)
  -- Head
  circ(C.SHORE_X - 2, C.WATER_Y - 62, 8, 0.9, 0.75, 0.6, 1.0)
  -- Legs
  rect(C.SHORE_X - 8, C.WATER_Y - 25, 5, 20, 0.2, 0.15, 0.1, 1.0)
  rect(C.SHORE_X, C.WATER_Y - 25, 5, 20, 0.2, 0.15, 0.1, 1.0)
  -- Rod
  ln(C.SHORE_X, C.WATER_Y - 50, C.ROD_TIP_X, C.ROD_TIP_Y, 0.5, 0.35, 0.1, 1.0)

  -- Fishing line + bobber
  if cast_x > 0 then
    ln(C.ROD_TIP_X, C.ROD_TIP_Y, cast_x, bobber_y, 0.8, 0.8, 0.8, 0.6)
    -- Bobber
    circ(cast_x, bobber_y, 5, 1.0, 0.2, 0.1, 1.0)
    circ(cast_x, bobber_y - 4, 3, 1.0, 1.0, 1.0, 1.0)
  end

  -- Fish under water (visible when hooked in CATCHING)
  if state == STATES.CATCHING and hooked_fish then
    local fc = hooked_fish.color
    local fy = C.WATER_Y + 30 + math.sin(day_timer * 5) * 8
    -- Fish body
    circ(fish_x, fy, 10, fc[1], fc[2], fc[3], 0.8)
    -- Tail
    rect(fish_x + 8, fy - 5, 8, 10, fc[1] * 0.8, fc[2] * 0.8, fc[3] * 0.8, 0.7)
    -- Line to fish
    ln(cast_x, bobber_y, fish_x, fy, 0.8, 0.8, 0.8, 0.4)
  end

  -- Bite indicator
  if state == STATES.FISHING and bite_active then
    text_("!", cast_x - 3, bobber_y - 25, 1.0, 0.9, 0.0, 1.0)
  end

  -- Splash particles
  for _, p in ipairs(splash_particles) do
    local a = clamp(p.life / 0.5, 0, 1)
    circ(p.x, p.y, 2, 0.6, 0.8, 1.0, a)
  end

  -- Ripple particles
  for _, p in ipairs(ripple_particles) do
    local a = clamp(p.life / 0.6, 0, 1) * 0.5
    circ(p.x, p.y, p.radius, 0.5, 0.7, 1.0, a)
  end

  -- Sparkle particles
  for _, p in ipairs(sparkle_particles) do
    local a = clamp(p.life / 0.8, 0, 1)
    circ(p.x, p.y, p.size, 1.0, 1.0, 0.5, a)
  end

  -- Rain particles
  for _, p in ipairs(rain_particles) do
    ln(p.x, p.y, p.x - 1, p.y + 8, 0.5, 0.6, 0.9, 0.3)
  end

  -- Night/day indicator stars
  if is_night then
    for i = 1, 12 do
      local sx = (i * 67 + 13) % C.SCREEN_W
      local sy = (i * 43 + 7) % (C.WATER_Y - 30)
      local flicker = 0.5 + 0.5 * math.sin(day_timer * 2 + i)
      circ(sx, sy, 1.5, 1.0, 1.0, 0.8, flicker)
    end
  end
end

function lurek.draw_ui()
end
