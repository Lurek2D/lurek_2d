--- ECS Module: tag system, blueprints, layers, snapshots

--@api-stub: LUniverse:defineTag
--@api-stub: LUniverse:addTag
--@api-stub: LUniverse:removeTag
--@api-stub: LUniverse:hasTag
--@api-stub: LUniverse:getTags
-- Tag definition and entity tagging.
do
    ---@type LUniverse
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e1 = u:spawn()
    local e2 = u:spawn()
    u:addTag(e1, "enemy")
    print(u:hasTag(e1, "enemy"))
    print(u:hasTag(e2, "enemy"))
    local tags = u:getTags(e1)
    for _, t in ipairs(tags) do print(t) end
    u:removeTag(e1, "enemy")
    print(u:hasTag(e1, "enemy"))
end

--@api-stub: LUniverse:bitmapTag
--@api-stub: LUniverse:bitmapUntag
--@api-stub: LUniverse:getBitmapTagBit
--@api-stub: LUniverse:hasBitmapTag
--@api-stub: LUniverse:queryBitmapAll
--@api-stub: LUniverse:queryBitmapAny
--@api-stub: LUniverse:queryBitmapTag
-- Bitmap tag queries for bulk entity filtering.
do
    ---@type LUniverse
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e1 = u:spawn()
    u:bitmapTag(e1, "enemy")
    local bit = u:getBitmapTagBit("enemy")
    print("bit = " .. tostring(bit))
    print(u:hasBitmapTag(e1, "enemy"))
    local all = u:queryBitmapAll({ "enemy" })
    local any = u:queryBitmapAny({ "enemy" })
    local tagged = u:queryBitmapTag("enemy")
    for _, id in ipairs(tagged) do print(id) end
    u:bitmapUntag(e1, "enemy")
end

--@api-stub: LUniverse:extendBlueprint
--@api-stub: LUniverse:hasBlueprint
--@api-stub: LUniverse:listBlueprints
--@api-stub: LUniverse:removeBlueprint
-- Blueprint extension and introspection.
do
    ---@type LUniverse
    local u = lurek.ecs.newUniverse()
    u:defineBlueprint("base", { hp = 100 })
    u:extendBlueprint("enemy", "base", { damage = 10 })
    print(u:hasBlueprint("enemy"))
    print(u:hasBlueprint("missing"))
    local names = u:listBlueprints()
    for _, n in ipairs(names) do print(n) end
    u:removeBlueprint("enemy")
    print(u:hasBlueprint("enemy"))
end

--@api-stub: LUniverse:getEntitiesByLayer
--@api-stub: LUniverse:getEntitiesByTag
--@api-stub: LUniverse:getEntitiesSorted
--@api-stub: LUniverse:getLayer
--@api-stub: LUniverse:setLayer
-- Layer-based entity queries.
do
    ---@type LUniverse
    local u = lurek.ecs.newUniverse()
    u:defineTag("unit")
    local e = u:spawn()
    u:setLayer(e, 2)
    local layer = u:getLayer(e)
    print("layer = " .. tostring(layer))
    local byLayer = u:getEntitiesByLayer(2)
    for _, id in ipairs(byLayer) do print(id) end
    u:addTag(e, "unit")
    local byTag = u:getEntitiesByTag("unit")
    for _, id in ipairs(byTag) do print(id) end
    local sorted = u:getEntitiesSorted()
    print("sorted count = " .. #sorted)
end

--@api-stub: LUniverse:applySnapshot
--@api-stub: LUniverse:takeSnapshotDiff
--@api-stub: LUniverse:clear
--@api-stub: LUniverse:release
-- Snapshot diffing and universe lifecycle.
do
    ---@type LUniverse
    local u = lurek.ecs.newUniverse()
    local e = u:spawn()
    u:set(e, "pos", { x = 1, y = 2 })
    local diff = u:takeSnapshotDiff()
    print("diff keys = " .. tostring(diff))
    u:applySnapshot(diff)
    u:clear()
    print("cleared")
    u:release()
    print("released")
end

print("ecs_02.lua")
