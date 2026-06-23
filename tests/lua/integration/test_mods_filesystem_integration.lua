-- Integration: mod discovery via ModManager combined with filesystem operations
-- @describe mods + filesystem integration

-- @describe mods + filesystem integration
describe("mods + filesystem integration", function()
    -- @integration LModManager:hasMod
    -- @integration LModManager:scanFolder
    -- @integration lurek.filesystem.createDirectory
    -- @integration lurek.filesystem.exists
    -- @integration lurek.filesystem.removeDir
    -- @integration lurek.filesystem.write
    -- @integration lurek.mods.newModManager
    -- @integration lurek.filesystem.createDirectory
    -- @integration lurek.filesystem.exists
    -- @integration lurek.filesystem.removeDir
    -- @integration lurek.filesystem.write
    -- @integration lurek.mods.newModManager
    it("ModManager:scanFolder registers mods discovered on disk", function()
        local root = "save/_mods_scan_case/"
        local mod_dir = root .. "my-mod/"

        if lurek.filesystem.exists(root) then
            lurek.filesystem.removeDir(root)
        end

        lurek.filesystem.createDirectory(mod_dir)
        lurek.filesystem.write(
            mod_dir .. "mod.toml",
            "id = \"my-mod\"\nname = \"My Mod\"\nversion = \"2.0.0\"\npriority = 5\n"
        )

        local mm = lurek.mods.newModManager()
        local found = mm:scanFolder(root)

        expect_equal(1, #found)
        expect_equal("my-mod", found[1].id)
        expect_equal("2.0.0", found[1].version)
        expect_equal(5, found[1].priority)
        expect_true(mm:hasMod("my-mod"))

        lurek.filesystem.removeDir(root)
    end)

    -- @integration LAssetHandle:type
    -- @integration LContentRegistry:get
    -- @integration LContentRegistry:register
    -- @integration LContentRegistry:registerType
    -- @integration LModManager:hasMod
    -- @integration LModManager:registerMod
    -- @integration lurek.asset.get
    -- @integration lurek.asset.load
    -- @integration lurek.asset.unload
    -- @integration lurek.filesystem.createDirectory
    -- @integration lurek.filesystem.exists
    -- @integration lurek.filesystem.removeDir
    -- @integration lurek.filesystem.write
    -- @integration lurek.mods.newMod
    -- @integration lurek.mods.newModManager
    -- @integration lurek.mods.newRegistry
    -- @integration lurek.serialize.fromToml
    it("asset-catalogued TOML definitions feed serialize-backed mod registration", function()
        local root = "save/_mods_asset_catalog_case/"
        local mod_dir = root .. "balance-pack/"
        local manifest_path = mod_dir .. "mod.toml"
        local content_path = mod_dir .. "weapons.toml"

        if lurek.filesystem.exists(root) then
            lurek.filesystem.removeDir(root)
        end

        lurek.filesystem.createDirectory(mod_dir)
        lurek.filesystem.write(
            manifest_path,
            "id = \"balance-pack\"\nname = \"Balance Pack\"\nversion = \"1.1.0\"\npriority = 2\n"
        )
        lurek.filesystem.write(
            content_path,
            "[weapons.short_blade]\nname = \"Short Blade\"\ndamage = 8\n[weapons.long_blade]\nname = \"Long Blade\"\ndamage = 12\n"
        )

        local manifest_asset = lurek.asset.load(manifest_path, "toml", { group = "mods" })
        local content_asset = lurek.asset.load(content_path, "toml", { group = "mods" })
        expect_equal("LAssetHandle", manifest_asset:type())

        local manifest = lurek.serialize.fromToml(lurek.asset.get(manifest_asset))
        local content = lurek.serialize.fromToml(lurek.asset.get(content_asset))

        local manager = lurek.mods.newModManager()
        manager:registerMod(lurek.mods.newMod(manifest))
        expect_true(manager:hasMod("balance-pack"))

        local registry = lurek.mods.newRegistry()
        registry:registerType("weapon")
        for id, definition in pairs(content.weapons) do
            registry:register("weapon", id, definition)
        end

        local short_blade = registry:get("weapon", "short_blade")
        expect_equal("Short Blade", short_blade.name)
        expect_equal(8, short_blade.damage)

        lurek.asset.unload(manifest_asset)
        lurek.asset.unload(content_asset)
        lurek.filesystem.removeDir(root)
    end)
end)
test_summary()
