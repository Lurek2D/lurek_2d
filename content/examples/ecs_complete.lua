-- content/examples/ecs_complete.lua
-- Run: cargo run -- content/examples/ecs_complete.lua
--
-- End-to-end ECS simulation: blueprints, systems, movement, damage, query, and cleanup.
-- Headless — no render, input, or window calls. Safe for cargo test --test examples_load_test.
--
-- Scenario:
--   • 1 player at (100, 100), stationary.
--   • 10 enemies — 5 start within 50 units, 5 start far away.
--   • Movement system shifts every pos by vel each tick.
--   • Damage system deals 1 HP/tick to enemies within 50 units of the player.
--   • 10 ticks (dt = 1 s each). Close enemies reach hp = 0; far enemies are unharmed.
--   • Query entities with hp < 5, print count.
--   • Kill all entities with hp ≤ 0 via query + kill.

--@api-stub: LUniverse:defineBlueprint
do
    local uni = lurek.ecs.newUniverse()
    uni:defineBlueprint("enemy", {
        pos = {x = 0,   y = 0},
        vel = {x = 1,   y = 0},
        hp  = {value = 10},
    })
    uni:defineBlueprint("player", {
        pos = {x = 100, y = 100},
        vel = {x = 0,   y = 0},
        hp  = {value = 100},
    })
    print("[1] blueprints defined: enemy, player")
    print("[1] has enemy blueprint = " .. tostring(uni:hasBlueprint("enemy")))
end

--@api-stub: LUniverse:extendBlueprint
do
    local uni = lurek.ecs.newUniverse()
    uni:defineBlueprint("enemy", {
        pos = {x = 0, y = 0},
        vel = {x = 1, y = 0},
        hp = {value = 10},
    })
    uni:extendBlueprint("boss", "enemy", {
        hp  = {value = 50},
        vel = {x = 2, y = 0},
    })
    local boss = uni:getBlueprintComponents("boss")
    print("[2] boss blueprint extended from enemy")
    print("[2] boss hp = " .. tostring(boss.hp.value))
end

--@api-stub: LUniverse:spawnBlueprint
do
    local uni = lurek.ecs.newUniverse()
    uni:defineBlueprint("enemy", {
        pos = {x = 0, y = 0},
        vel = {x = 1, y = 0},
        hp = {value = 10},
    })
    uni:defineBlueprint("player", {
        pos = {x = 100, y = 100},
        vel = {x = 0, y = 0},
        hp = {value = 100},
    })
    local enemy_ids = {}
    for i = 1, 5 do
        local id = uni:spawnBlueprint("enemy", {
            pos = {x = 60 + i * 4, y = 100},
            vel = {x = 1,          y = 0},
        })
        uni:addTag(id, "enemy")
        enemy_ids[#enemy_ids + 1] = id
    end

    for i = 6, 10 do
        local id = uni:spawnBlueprint("enemy", {
            pos = {x = 200 + i * 20, y = 0},
            vel = {x = 1,            y = 0},
        })
        uni:addTag(id, "enemy")
        enemy_ids[#enemy_ids + 1] = id
    end

    local player_id = uni:spawnBlueprint("player")
    uni:addTag(player_id, "player")

    print("[3] spawned 10 enemies + 1 player  (total entities: " .. uni:getEntityCount() .. ")")
    print("[3] tagged enemies = " .. #uni:getEntitiesByTag("enemy"))
end

--@api-stub: LUniverse:addSystem
do
    local uni = lurek.ecs.newUniverse()
    local move_sys = {
        update = function(self, universe, dt)
            local ents = universe:query("pos", "vel")
            for _, id in ipairs(ents) do
                local pos = universe:get(id, "pos")
                local vel = universe:get(id, "vel")
                pos.x = pos.x + vel.x * dt
                pos.y = pos.y + vel.y * dt
                universe:set(id, "pos", pos)
            end
        end,
    }
    uni:addSystem(move_sys, {name = "movement", priority = 1})

    local dmg_sys = {
        update = function(self, universe, dt)
            local players = universe:getEntitiesByTag("player")
            if #players == 0 then
                return
            end

            local ppos = universe:get(players[1], "pos")
            local range_sq = 50 * 50

            local enemies = universe:getEntitiesByTag("enemy")
            for _, eid in ipairs(enemies) do
                if universe:isAlive(eid) then
                    local epos = universe:get(eid, "pos")
                    local dx   = epos.x - ppos.x
                    local dy   = epos.y - ppos.y
                    if dx * dx + dy * dy < range_sq then
                        local hp = universe:get(eid, "hp")
                        hp.value = hp.value - 1
                        universe:set(eid, "hp", hp)
                    end
                end
            end
        end,
    }
    uni:addSystem(dmg_sys, {name = "damage", priority = 10})

    print("[4] registered systems: movement (priority 1), damage (priority 10)")
    print("[4] system count = " .. uni:getSystemCount())
end

--@api-stub: LUniverse:update
do
    local uni = lurek.ecs.newUniverse()
    local enemy_id = uni:spawn()
    uni:set(enemy_id, "pos", {x = 0, y = 0})
    uni:set(enemy_id, "vel", {x = 2, y = 0})
    uni:set(enemy_id, "hp", {value = 10})

    uni:addSystem({
        update = function(self, universe, dt)
            local pos = universe:get(enemy_id, "pos")
            local vel = universe:get(enemy_id, "vel")
            pos.x = pos.x + vel.x * dt
            universe:set(enemy_id, "pos", pos)
        end,
    }, {name = "movement", priority = 1})

    for _ = 1, 3 do
        uni:update(1)
    end
    local pos = uni:get(enemy_id, "pos")
    print("[5] completed 3 ticks (dt = 1 s)")
    print("[5] enemy x = " .. tostring(pos.x))
end

--@api-stub: LUniverse:query
do
    local uni = lurek.ecs.newUniverse()
    local low = uni:spawn()
    local full = uni:spawn()
    uni:set(low, "hp", {value = 3})
    uni:set(low, "enemy", {flag = true})
    uni:set(full, "hp", {value = 10})
    uni:set(full, "enemy", {flag = true})
    local all_with_hp = uni:query("hp")
    local low_count = 0
    for _, id in ipairs(all_with_hp) do
        local hp = uni:get(id, "hp")
        if hp.value < 5 then
            low_count = low_count + 1
        end
    end
    print("[6] entities with hp < 5: " .. low_count)
end

--@api-stub: LUniverse:kill
do
    local uni = lurek.ecs.newUniverse()
    local alive_id = uni:spawn()
    local dead_id = uni:spawn()
    uni:set(alive_id, "hp", {value = 6})
    uni:set(dead_id, "hp", {value = 0})
    local all_with_hp = uni:query("hp")
    local killed = 0
    for _, id in ipairs(all_with_hp) do
        local hp = uni:get(id, "hp")
        if hp.value <= 0 then
            uni:kill(id)
            killed = killed + 1
        end
    end
    print("[7] killed " .. killed .. " dead entities  (remaining alive: " .. uni:getEntityCount() .. ")")
end
