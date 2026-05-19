--@api-stub: LMapGen:type
--@api-stub: LMapGen:typeOf
--@api-stub: LMapGroup:addBlock
-- LMapGen type checks and LMapGroup addBlock.
do
    local group = lurek.tilemap.newMapGroup("dungeon")
    local mb = lurek.tilemap.newMapBlock(8, 8, 1, 2)
    group:addBlock(mb)
    local gen = lurek.tilemap.newMapGen(group, "small", 4)
    local t = gen:type()
    local ok = gen:typeOf("LMapGen")
    print("addBlock ok, LMapGen type:", t, "typeOf:", ok)
end

--@api-stub: LMapGroup:addScript
--@api-stub: LMapGroup:getBlockCount
--@api-stub: LMapGroup:getName
-- LMapGroup script and block queries.
do
    local group = lurek.tilemap.newMapGroup("forest")
    local mb = lurek.tilemap.newMapBlock(6, 6, 1, 2)
    group:addBlock(mb)
    local script = lurek.tilemap.newMapScript()
    group:addScript(script)
    local bc = group:getBlockCount()
    local sc = group:getScriptCount()
    local name = group:getName()
    print("blockCount:", bc, "scriptCount:", sc, "name:", name)
end

--@api-stub: LMapGroup:getScriptCount
--@api-stub: LMapGroup:removeBlock
--@api-stub: LMapGroup:type
-- LMapGroup remove block and type.
do
    local group = lurek.tilemap.newMapGroup("plains")
    local mb1 = lurek.tilemap.newMapBlock(4, 4, 1, 2)
    local mb2 = lurek.tilemap.newMapBlock(4, 4, 1, 2)
    group:addBlock(mb1)
    group:addBlock(mb2)
    group:removeBlock(1)
    local t = group:type()
    print("removeBlock ok, blockCount:", group:getBlockCount(), "type:", t)
end

--@api-stub: LMapGroup:typeOf
--@api-stub: LMapScript:addStep
--@api-stub: LMapScript:getStepCount
-- LMapGroup typeOf and LMapScript step management.
do
    local group = lurek.tilemap.newMapGroup("cave")
    local ok = group:typeOf("LMapGroup")
    local script = lurek.tilemap.newMapScript()
    script:addStep({type = "fill", gid = 1})
    script:addStep({type = "rect", x = 1, y = 1, w = 4, h = 4, gid = 2})
    local cnt = script:getStepCount()
    print("LMapGroup typeOf:", ok, "stepCount:", cnt)
end

--@api-stub: LMapScript:type
--@api-stub: LMapScript:typeOf
-- LMapScript type identity.
do
    local script = lurek.tilemap.newMapScript()
    local t = script:type()
    local ok = script:typeOf("LMapScript")
    local notOk = script:typeOf("LMapBlock")
    print("LMapScript type:", t, "typeOf:", ok, "typeOf LMapBlock:", notOk)
end
