--- Province Module Part 1: registry queries, module-level functions

--@api-stub: LProvinceRegistry:getName
--@api-stub: LProvinceRegistry:importMetadataFromFiles
-- Province registry name and metadata import.
do
    local reg = lurek.province.newFromPng("test_reg", "assets/textures/ray_water.png")
    print("name=" .. reg:getName())
    reg:importMetadataFromFiles({ dir = "save/example_province", ext = ".toml" })
    print("metadata imported")
end

--@api-stub: lurek.province.exists
--@api-stub: lurek.province.get
--@api-stub: lurek.province.getActive
--@api-stub: lurek.province.remove
-- Province module-level lifecycle functions.
do
    local reg = lurek.province.newFromPng("check_reg", "assets/textures/ray_water.png")
    print("exists=" .. tostring(lurek.province.exists("check_reg")))
    local got = lurek.province.get("check_reg")
    print("got=" .. tostring(got ~= nil))
    lurek.province.setActive("check_reg")
    local active = lurek.province.getActive()
    print("active=" .. tostring(active ~= nil))
    lurek.province.remove("check_reg")
    print("exists_after=" .. tostring(lurek.province.exists("check_reg")))
end

--@api-stub: lurek.province.sanitizeMarkedPng
-- Sanitize a marked PNG for province loading.
do
    lurek.province.sanitizeMarkedPng(
        "assets/textures/ray_water.png",
        "save/province_sanitized.png",
        {}
    )
    print("sanitize ok")
end

print("province_01.lua")
