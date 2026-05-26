--- Example usage for library.scene-objects.
-- Demonstrates: creating a container, adding objects on three different layers,
-- running one update+draw cycle, and querying the container.
--
-- Uses plain stub tables — no lurek.* calls — so this runs headlessly via
-- cargo test --test examples_load_test without a live engine.
--
-- @module example.scene-objects

local sceneobj = require("library/scene-objects")

-- ── 1. Create a container ─────────────────────────────────────────────────────

local world = sceneobj.new()
assert(world:count() == 0, "fresh container must be empty")

-- ── 2. Define stub objects on different layers ────────────────────────────────

local update_log = {}
local draw_log   = {}

local bg = {
    layer = 0,
    name  = "background",
    update = function(self, dt)
        update_log[#update_log + 1] = self.name
    end,
    draw = function(self)
        draw_log[#draw_log + 1] = self.name
    end,
}

local player = {
    layer = 5,
    name  = "player",
    update = function(self, dt)
        update_log[#update_log + 1] = self.name
    end,
    draw = function(self)
        draw_log[#draw_log + 1] = self.name
    end,
}

local ui = {
    layer = 10,
    name  = "ui",
    -- no update — only drawn
    draw = function(self)
        draw_log[#draw_log + 1] = self.name
    end,
}

-- ── 3. Add objects in non-layer order to verify sorting ───────────────────────

world:add(ui)
world:add(bg)
world:add(player)

assert(world:count() == 3, "container should hold 3 objects")
assert(world:has(player), "player must be present")

-- ── 4. Update cycle (insertion order) ────────────────────────────────────────

world:update(0.016)  -- one 60 Hz frame

-- ui has no update, so only bg and player produced update events.
assert(#update_log == 2, "expected 2 update calls")

-- ── 5. Draw cycle (layer-sorted order: bg=0, player=5, ui=10) ─────────────────

world:draw()

assert(draw_log[1] == "background", "background should draw first (layer 0)")
assert(draw_log[2] == "player",     "player should draw second (layer 5)")
assert(draw_log[3] == "ui",         "ui should draw last (layer 10)")

-- ── 6. Query helpers ──────────────────────────────────────────────────────────

local layer0 = world:getByLayer(0)
assert(#layer0 == 1 and layer0[1] == bg, "getByLayer(0) should return bg")

local layerNone = world:getByLayer(99)
assert(#layerNone == 0, "getByLayer(99) should be empty")

-- ── 7. Remove and clear ───────────────────────────────────────────────────────

world:remove(player)
assert(world:count() == 2, "count should drop to 2 after remove")
assert(not world:has(player), "player must no longer be present")

world:clear()
assert(world:count() == 0, "container must be empty after clear")

print("[example.scene-objects] all checks passed")
