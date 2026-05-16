-- content/examples/save.lua
-- lurek.save API examples.
-- Run: cargo run -- content/examples/save.lua

--@api-stub: lurek.save.newSaveManager -- Create a new SaveManager instance for managing persistent game saves
do -- lurek.save.newSaveManager
  local mgr = lurek.save.newSaveManager()
  mgr:setSchemaVersion(1)
  mgr:register("player",
    function() return { hp = 100, x = 32, y = 64 } end,
    function(t) lurek.log.info("restored player hp=" .. (t and t.hp or 0), "save") end)
end

-- â”€â”€ SaveManager methods â”€â”€

--@api-stub: SaveManager:unregister
do -- SaveManager:unregister
  local mgr = lurek.save.newSaveManager()
  mgr:register("minigame",
    function() return { score = 0 } end,
    function(_) end)
  mgr:unregister("minigame")
end

--@api-stub: SaveManager:setSchemaVersion
do -- SaveManager:setSchemaVersion
  local mgr = lurek.save.newSaveManager()
  mgr:setSchemaVersion(3)
  lurek.log.info("save schema is now v" .. mgr:getSchemaVersion(), "save")
end

--@api-stub: SaveManager:getSchemaVersion
do -- SaveManager:getSchemaVersion
  local mgr = lurek.save.newSaveManager()
  mgr:setSchemaVersion(2)
  local ver = mgr:getSchemaVersion()
  if ver < 2 then lurek.log.warn("schema older than expected", "save") end
end

--@api-stub: SaveManager:collect
do -- SaveManager:collect
  local mgr = lurek.save.newSaveManager()
  mgr:register("inventory",
    function() return { gold = 250, potions = 3 } end,
    function(_) end)
  local snapshot = mgr:collect()
  lurek.log.info("snapshot has " .. tostring(snapshot.inventory.gold) .. " gold", "save")
end

--@api-stub: SaveManager:restore
do -- SaveManager:restore
  local mgr = lurek.save.newSaveManager()
  local checkpoint
  mgr:register("hp",
    function() return 100 end,
    function(v) lurek.log.info("hp restored to " .. tostring(v), "save") end)
  checkpoint = mgr:collect()
  mgr:restore(checkpoint)
end

--@api-stub: SaveManager:markDirty
do -- SaveManager:markDirty
  local mgr = lurek.save.newSaveManager()
  local function on_item_picked_up()
    mgr:markDirty()
  end
  on_item_picked_up()
end

--@api-stub: SaveManager:isDirty
do -- SaveManager:isDirty
  local mgr = lurek.save.newSaveManager()
  mgr:markDirty()
  if mgr:isDirty() then
    lurek.log.info("unsaved changes pending", "save")
  end
end

--@api-stub: SaveManager:disableAutoSave
do -- SaveManager:disableAutoSave
  local mgr = lurek.save.newSaveManager()
  mgr:enableAutoSave(60.0, "auto")
  mgr:disableAutoSave()
  lurek.log.info("auto-save paused for cutscene", "save")
end

--@api-stub: SaveManager:update
do -- SaveManager:update
  local mgr = lurek.save.newSaveManager()
  mgr:enableAutoSave(30.0, "auto")
  function lurek.process(dt)
    local slot = mgr:update(dt)
    if slot then mgr:save(slot) end
  end
end

--@api-stub: SaveManager:setSummary
do -- SaveManager:setSummary
  local mgr = lurek.save.newSaveManager()
  local area, playtime = "Forest", "12:30"
  mgr:setSummary(area .. " â€” " .. playtime)
end

--@api-stub: SaveManager:getSummary
do -- SaveManager:getSummary
  local mgr = lurek.save.newSaveManager()
  mgr:setSummary("Chapter 2 â€” Boss")
  local label = mgr:getSummary()
  lurek.log.info("current summary: " .. label, "save")
end

--@api-stub: SaveManager:reset
do -- SaveManager:reset
  local mgr = lurek.save.newSaveManager()
  mgr:register("player", function() return {} end, function(_) end)
  mgr:reset()
  lurek.log.info("save manager cleared for main menu", "save")
end

--@api-stub: SaveManager:setCompress
do -- SaveManager:setCompress
  local mgr = lurek.save.newSaveManager()
  mgr:setCompress(true)
  lurek.log.info("compressed saves enabled", "save")
end

--@api-stub: SaveManager:isCompressed
do -- SaveManager:isCompressed
  local mgr = lurek.save.newSaveManager()
  mgr:setCompress(true)
  if mgr:isCompressed() then
    lurek.log.info("save format: lz4+base64", "save")
  end
end

--@api-stub: SaveManager:onBeforeSave
do -- SaveManager:onBeforeSave
  local mgr = lurek.save.newSaveManager()
  mgr:onBeforeSave(function(slot)
    mgr:setSummary("Saved to " .. slot)
    lurek.log.info("about to write slot " .. slot, "save")
  end)
end

--@api-stub: SaveManager:onAfterLoad
do -- SaveManager:onAfterLoad
  local mgr = lurek.save.newSaveManager()
  mgr:onAfterLoad(function(slot)
    lurek.log.info("loaded slot " .. slot .. ", rebuilding scene", "save")
  end)
end

--@api-stub: SaveManager:save
do -- SaveManager:save
  local mgr
  function lurek.init()
    mgr = lurek.save.newSaveManager()
    mgr:register("world",
      function() return { seed = 12345, day = 7 } end,
      function(_) end)
    mgr:save("slot1")
  end
end

--@api-stub: SaveManager:load
do -- SaveManager:load
  local mgr
  function lurek.init()
    mgr = lurek.save.newSaveManager()
    mgr:register("world", function() return {} end, function(_) end)
    local ok, err = mgr:load("slot1")
    if not ok then lurek.log.warn("load failed: " .. tostring(err), "save") end
  end
end

--@api-stub: SaveManager:delete
do -- SaveManager:delete
  local mgr
  function lurek.quit()
    mgr = lurek.save.newSaveManager()
    mgr:delete("slot_temp")
    lurek.log.info("scratch slot removed on quit", "save")
  end
end

--@api-stub: SaveManager:getSlots
do -- SaveManager:getSlots
  local mgr
  function lurek.init()
    mgr = lurek.save.newSaveManager()
    for _, info in ipairs(mgr:getSlots()) do
      lurek.log.info("slot " .. info.slot .. " â€” " .. info.summary, "save")
    end
  end
end

--@api-stub: SaveManager:getSlotInfo
do -- SaveManager:getSlotInfo
  local mgr
  function lurek.init()
    mgr = lurek.save.newSaveManager()
    local info = mgr:getSlotInfo("slot1")
    if info then lurek.log.info("preview: " .. info.summary, "save") end
  end
end

--@api-stub: SaveManager:addMigration
do -- SaveManager:addMigration
  local sm = lurek.save.newSaveManager()
  sm:setSchemaVersion(2)
  sm:addMigration(1, function(data)
    data.score = data.score or 0
    return data
  end)
  lurek.log.info("migration registered", "save")
end

--@api-stub: SaveManager:enableAutoSave
do -- SaveManager:enableAutoSave
  local sm = lurek.save.newSaveManager()
  sm:register("state", function() return {score=0} end, function(d) end)
  sm:enableAutoSave(5.0, "slot1")
  lurek.log.info("auto-save enabled", "save")
end

--@api-stub: SaveManager:exists
do -- SaveManager:exists
  local sm = lurek.save.newSaveManager()
  local present = sm:exists("slot1")
  lurek.log.info("slot1 exists: " .. tostring(present), "save")
end

--@api-stub: SaveManager:register
do -- SaveManager:register
  local sm = lurek.save.newSaveManager()
  sm:register("player_state",
    function() return {x=200, y=300, hp=100} end,
    function(d) lurek.log.info("restored hp=" .. d.hp, "save") end
  )
  lurek.log.info("component registered", "save")
end

-- =============================================================================
-- COVERAGE: 2 uncovered lurek.save API item(s)
-- Generated by tools/audit/example_add_missing.py
-- Run .github/prompts/flesh-out-example.prompt.md for instructions.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- SaveManager methods
-- -----------------------------------------------------------------------------

-- =============================================================================
-- COVERAGE: 2 uncovered lurek.save API item(s)
-- Generated by tools/audit/example_add_missing.py
-- Run .github/prompts/flesh-out-example.prompt.md for instructions.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- LSaveManager methods
-- -----------------------------------------------------------------------------


