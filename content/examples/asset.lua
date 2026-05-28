-- Asset cache example
-- @module lurek.asset

--@api-stub: lurek.asset.load
do
    local handle = lurek.asset.load("assets/fonts/bitmap_fonts.json", "text")
    print("loaded: " .. handle:type())
    lurek.asset.unload(handle)
end

--@api-stub: lurek.asset.unload
do
    local handle = lurek.asset.load("assets/fonts/bitmap_fonts.json", "text")
    lurek.asset.unload(handle)
    print("unloaded, isLoaded = " .. tostring(lurek.asset.isLoaded(handle)))
end

--@api-stub: lurek.asset.get
do
    local handle = lurek.asset.load("assets/fonts/bitmap_fonts.json", "text")
    local content = lurek.asset.get(handle)
    print("content length = " .. tostring(type(content) == "string" and #content or 0))
    lurek.asset.unload(handle)
end

--@api-stub: lurek.asset.preload
do
    local results = {}
    lurek.asset.preload(
        {{"assets/fonts/bitmap_fonts.json", "text"}},
        function(loaded, total)
            if loaded ~= nil then
                table.insert(results, loaded .. "/" .. tostring(total))
            else
                print("preload done: " .. table.concat(results, ", "))
            end
        end
    )
end

--@api-stub: lurek.asset.refcount
do
    local handle = lurek.asset.load("assets/fonts/bitmap_fonts.json", "text")
    print("refcount = " .. lurek.asset.refcount(handle))
    lurek.asset.unload(handle)
end

--@api-stub: lurek.asset.stats
do
    local h = lurek.asset.load("assets/fonts/bitmap_fonts.json", "text")
    local s = lurek.asset.stats()
    print("loaded=" .. s.loaded .. " total_refs=" .. s.total_refs)
    lurek.asset.unload(h)
end

--@api-stub: lurek.asset.clear
do
    lurek.asset.load("assets/fonts/bitmap_fonts.json", "text")
    lurek.asset.clear()
    print("after clear loaded = " .. lurek.asset.stats().loaded)
end

--@api-stub: lurek.asset.isLoaded
do
    local handle = lurek.asset.load("assets/fonts/bitmap_fonts.json", "text")
    print("isLoaded = " .. tostring(lurek.asset.isLoaded(handle)))
    lurek.asset.unload(handle)
    print("isLoaded after unload = " .. tostring(lurek.asset.isLoaded(handle)))
end

--@api-stub: LAssetHandle:type
do
    local handle = lurek.asset.load("assets/fonts/bitmap_fonts.json", "text")
    print("type = " .. handle:type())
    lurek.asset.unload(handle)
end

--@api-stub: LAssetHandle:typeOf
do
    local handle = lurek.asset.load("assets/fonts/bitmap_fonts.json", "text")
    print("typeOf LAssetHandle = " .. tostring(handle:typeOf("LAssetHandle")))
    lurek.asset.unload(handle)
end
