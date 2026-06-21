-- Canonical evidence file for lurek.ecs data outputs.


local OUT = evidence_output_dir("ecs")

local function write_text(path, text)
    if write_file then
        write_file(path, text)
    else
        lurek.filesystem.write(path, text)
    end
    expect_evidence_created(path)
end

local function contains(list, target)
    for _, value in ipairs(list or {}) do
        if value == target then
            return true
        end
    end
    return false
end

-- @describe Evidence: lurek.ecs data outputs
describe("Evidence: lurek.ecs data outputs", function()
    before_each(function()
        ensure_evidence_dir("ecs")
    end)
    -- Does: Runs "writes ecs_entity_lifecycle_snapshot.txt" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.ecs.newUniverse, LUniverse:spawn, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/ecs/ecs_entity_lifecycle_snapshot.txt
    -- Why: This is meaningful only if the visible/text output comes from lurek.ecs.newUniverse, LUniverse:spawn, and related owner calls; export helpers are just the container.

    it("writes ecs_entity_lifecycle_snapshot.txt", function()
        local world = lurek.ecs.newUniverse()
        local a = world:spawn()
        local b = world:spawn()
        world:kill(a)
        local ids = world:getEntities()
        local text = table.concat({
            "spawned_a=" .. tostring(a),
            "spawned_b=" .. tostring(b),
            "alive_a=" .. tostring(world:isAlive(a)),
            "alive_b=" .. tostring(world:isAlive(b)),
            "entity_count=" .. tostring(world:getEntityCount()),
            "contains_b=" .. tostring(contains(ids, b)),
        }, "\n") .. "\n"
        write_text(OUT .. "ecs_entity_lifecycle_snapshot.txt", text)
    end)
    -- Does: Runs "writes ecs_component_query_snapshot.txt" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by LUniverse:set, LUniverse:get, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/ecs/ecs_component_query_snapshot.txt
    -- Why: This is meaningful only if the visible/text output comes from LUniverse:set, LUniverse:get, and related owner calls; export helpers are just the container.

    it("writes ecs_component_query_snapshot.txt", function()
        local world = lurek.ecs.newUniverse()
        local hero = world:spawn()
        local corpse = world:spawn()
        world:set(hero, "Health", 10)
        world:set(hero, "Pos", { x = 1, y = 2 })
        world:set(corpse, "Health", 10)
        world:set(corpse, "Dead", true)
        local health = world:get(hero, "Health")
        local has_pos = world:has(hero, "Pos")
        local components = world:getComponents(hero)
        local live_health = world:query("Health")
        local living = world:queryNot({ "Health" }, { "Dead" })
        local dirty = world:getDirtyEntities()
        world:remove(hero, "Health")
        local text = table.concat({
            "hero_health=" .. tostring(health),
            "hero_has_pos=" .. tostring(has_pos),
            "component_count=" .. tostring(#components),
            "health_query_count=" .. tostring(#live_health),
            "query_not_count=" .. tostring(#living),
            "dirty_count=" .. tostring(#dirty),
            "health_removed=" .. tostring(world:get(hero, "Health") == nil),
        }, "\n") .. "\n"
        write_text(OUT .. "ecs_component_query_snapshot.txt", text)
    end)
    -- Does: Runs "writes ecs_tag_layer_snapshot.txt" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by LUniverse:addTag, LUniverse:getEntitiesByTag, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/ecs/ecs_tag_layer_snapshot.txt
    -- Why: This is meaningful only if the visible/text output comes from LUniverse:addTag, LUniverse:getEntitiesByTag, and related owner calls; export helpers are just the container.

    it("writes ecs_tag_layer_snapshot.txt", function()
        local world = lurek.ecs.newUniverse()
        local scout = world:spawn()
        local tank = world:spawn()
        world:addTag(scout, "enemy")
        world:defineTag("fast")
        world:defineTag("strong")
        world:bitmapTag(scout, "fast")
        world:bitmapTag(tank, "strong")
        world:setLayer(scout, 5)
        world:setLayer(tank, 1)
        local enemy_ids = world:getEntitiesByTag("enemy")
        local bitmap_any = world:queryBitmapAny({ "fast", "strong" })
        local sorted = world:getEntitiesSorted()
        local text = table.concat({
            "enemy_count=" .. tostring(#enemy_ids),
            "bitmap_any_count=" .. tostring(#bitmap_any),
            "sorted_first=" .. tostring(sorted[1]),
            "sorted_last=" .. tostring(sorted[#sorted]),
        }, "\n") .. "\n"
        write_text(OUT .. "ecs_tag_layer_snapshot.txt", text)
    end)
    -- Does: Runs "writes ecs_blueprint_snapshot.txt" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by LUniverse:defineBlueprint, LUniverse:extendBlueprint, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/ecs/ecs_blueprint_snapshot.txt
    -- Why: This is meaningful only if the visible/text output comes from LUniverse:defineBlueprint, LUniverse:extendBlueprint, and related owner calls; export helpers are just the container.

    it("writes ecs_blueprint_snapshot.txt", function()
        local world = lurek.ecs.newUniverse()
        world:defineBlueprint("enemy", {
            hp = 30,
            speed = 5,
            pos = { x = 1, y = 2 },
        })
        world:extendBlueprint("boss", "enemy", { hp = 200, boss = true })
        local boss = world:spawnBlueprint("boss")
        local bullets = world:spawnBulk("enemy", 3)
        local names = world:listBlueprints()
        local boss_components = world:getBlueprintComponents("boss")
        local text = table.concat({
            "blueprint_count=" .. tostring(#names),
            "boss_entity=" .. tostring(boss),
            "boss_hp=" .. tostring(world:get(boss, "hp")),
            "boss_flag=" .. tostring(world:get(boss, "boss")),
            "boss_blueprint_hp=" .. tostring(boss_components.hp),
            "bulk_count=" .. tostring(#bullets),
        }, "\n") .. "\n"
        write_text(OUT .. "ecs_blueprint_snapshot.txt", text)
    end)
    -- Does: Runs "writes ecs_system_snapshot_trace.txt" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by LUniverse:addSystem, LUniverse:getSystemCount, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/ecs/ecs_system_snapshot_trace.txt
    -- Why: This is meaningful only if the visible/text output comes from LUniverse:addSystem, LUniverse:getSystemCount, and related owner calls; export helpers are just the container.

    it("writes ecs_system_snapshot_trace.txt", function()
        local world = lurek.ecs.newUniverse()
        local ran = 0
        local payload = 0
        world:addSystem({
            update = function()
                ran = ran + 1
            end,
            onHit = function(self, w, damage)
                payload = damage
            end,
        })
        local entity = world:spawn()
        world:set(entity, "hp", 10)
        world:update(0.016)
        world:emit("onHit", 42)
        local serialized = world:serialize()
        local snapshot = world:snapshot()
        local diff = world:takeSnapshotDiff()
        world:clear()
        world:deserialize(serialized)
        local restored_after_deserialize = world:getEntityCount()
        world:clear()
        world:applySnapshot(snapshot)
        local restored_after_snapshot = world:getEntityCount()
        local text = table.concat({
            "system_count=" .. tostring(world:getSystemCount()),
            "update_runs=" .. tostring(ran),
            "event_payload=" .. tostring(payload),
            "serialized_entities=" .. tostring(#serialized.entities),
            "snapshot_entities=" .. tostring(#snapshot.entities),
            "diff_dirty=" .. tostring(#diff.dirty_entities),
            "after_deserialize=" .. tostring(restored_after_deserialize),
            "after_apply_snapshot=" .. tostring(restored_after_snapshot),
        }, "\n") .. "\n"
        write_text(OUT .. "ecs_system_snapshot_trace.txt", text)
    end)
    -- Does: Runs "writes ecs_hierarchy_relation_observer_trace.txt" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by LUniverse:flushObservers, LUniverse:onComponentAdded, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/ecs/ecs_hierarchy_relation_observer_trace.txt
    -- Why: This is meaningful only if the visible/text output comes from LUniverse:flushObservers, LUniverse:onComponentAdded, and related owner calls; export helpers are just the container.

    it("writes ecs_hierarchy_relation_observer_trace.txt", function()
        local world = lurek.ecs.newUniverse()
        local added = 0
        local removed = 0
        world:onComponentAdded("Pos", function() added = added + 1 end)
        world:onComponentRemoved("Pos", function() removed = removed + 1 end)

        local parent = world:spawn()
        local child = world:spawn()
        local friend = world:spawn()
        world:set(child, "Pos", { x = 4, y = 9 })
        world:flushObservers()
        world:remove(child, "Pos")
        world:flushObservers()

        world:setParent(child, parent)
        world:addRelation(parent, "targets", friend)
        local children = world:getChildren(parent)
        local related = world:getRelated(parent, "targets")
        local has_relation = world:hasRelation(parent, "targets", friend)
        world:removeRelation(parent, "targets", friend)
        world:clearRelations(parent, "targets")
        world:killRecursive(parent)

        local text = table.concat({
            "added_count=" .. tostring(added),
            "removed_count=" .. tostring(removed),
            "parent_of_child=" .. tostring(world:getParent(child)),
            "children_count=" .. tostring(#children),
            "related_count=" .. tostring(#related),
            "had_relation=" .. tostring(has_relation),
            "parent_alive_after_recursive_kill=" .. tostring(world:isAlive(parent)),
            "child_alive_after_recursive_kill=" .. tostring(world:isAlive(child)),
        }, "\n") .. "\n"
        write_text(OUT .. "ecs_hierarchy_relation_observer_trace.txt", text)
    end)
end)
test_summary()
