-- Integration: Workbench creates game-ready assets through its document and project services.
-- @describe workbench asset creation integration
local WORK_ROOT = "work/workbench_asset_creation"
local WORKBENCH_ROOT = "lurek_2d_workbench"
local native_create_directory = lurek.filesystem.createDirectory
local native_write = lurek.filesystem.write
local function load_workbench_module(path)
    local chunk = lurek.filesystem.load(WORKBENCH_ROOT .. "/" .. path)
    expect_type("function", chunk, "workbench module loads from GameFS")
    local ok, result = pcall(chunk)
    expect_true(ok, "workbench module executes: " .. tostring(result))
    return result
end
local function enable_fixture_writes()
    lurek.filesystem.createDirectory = function(_path) return nil end
    lurek.filesystem.write = function(path, text)
        if write_file then
            write_file(path, text)
            return nil
        end
        return native_write(path, text)
    end
end
-- @describe workbench asset creation integration
describe("workbench asset creation integration", function()
    before_each(function()
        enable_fixture_writes()
    end)

    after_each(function()
        lurek.filesystem.createDirectory = native_create_directory
        lurek.filesystem.write = native_write
    end)

    -- @integration lurek.filesystem.write
    -- @integration lurek.filesystem.read
    -- @integration lurek.particle.fromTOML
    -- @integration lurek.tilemap.loadTMX
    -- @integration lurek.ui.loadLayoutFile
    -- @integration lurek.sprite.newSheet
    -- @integration lurek.animation.fromFrames
    -- @integration lurek.tileset.newTileSet
    -- @integration lurek.audio.newSource
    -- @integration lurek.filesystem.exists
    it("creates particle, TMX, layout, sprite-sheet, animation, tileset, and audio-cue documents that Lurek can consume", function()
        local Registry = load_workbench_module("app/editor_registry.lua")
        local State = load_workbench_module("app/state.lua")
        local CommandBus = load_workbench_module("app/command_bus.lua")
        local ProjectIndex = load_workbench_module("app/services/project_index.lua")
        local DocumentService = load_workbench_module("app/services/document_service.lua")
        local registry = Registry.create(load_workbench_module)
        local services = {
            commands = CommandBus.create(),
            projects = ProjectIndex.create(),
            documents = DocumentService.create(registry),
        }
        local ctx = State.create(registry, services, { sample_project_root = WORK_ROOT })

        local created = {}
        for _, request in ipairs({ "particle", "tilemap", "ui_layout", "sprite_atlas", "animation_clip", "tileset", "audio_cue" }) do
            local ok, result = ctx.command_bus:dispatch("asset.create", { editor_id = request })
            expect_true(ok, tostring(result))
            local document = services.documents:get_active()
            created[request] = document.path
            expect_true(lurek.filesystem.exists(document.path), "created asset exists")
        end

        local particle = lurek.particle.fromTOML(created.particle)
        expect_not_nil(particle, "created particle config loads")
        particle:release()
        local map, problem = lurek.tilemap.loadTMX(lurek.filesystem.read(created.tilemap), { strictLayerSize = true })
        expect_not_nil(map, problem and problem.message or "created TMX loads")
        lurek.ui.clear()
        local layout = lurek.ui.loadLayoutFile(created.ui_layout)
        expect_not_nil(layout, "created TOML layout loads")
        local atlas_source = lurek.filesystem.read(created.sprite_atlas)
        expect_match(atlas_source, "%[sheet%]", "created sprite descriptor has a sheet table")
        local atlas_editor = registry:get("sprite_atlas")
        local atlas_document = services.documents:get(created.sprite_atlas)
        local loader = atlas_editor.build_export(atlas_document, WORK_ROOT)
        expect_match(loader.text, "lurek%.sprite%.newSheet", "sprite export uses the Lurek sheet API")
        local sheet = lurek.sprite.newSheet(256, 256, 32, 32)
        expect_equal(64, sheet:getFrameCount(), "default sprite grid is valid")
        local animation_editor = registry:get("animation_clip")
        local animation_document = services.documents:get(created.animation_clip)
        local animation_loader = animation_editor.build_export(animation_document, WORK_ROOT)
        expect_match(animation_loader.text, "lurek%.animation%.fromFrames", "animation export uses the Lurek animation API")
        local animation = lurek.animation.fromFrames(animation_document.model.frames, { name = animation_document.model.name, fps = animation_document.model.fps })
        expect_equal(4, animation:getFrameCount(), "default animation clip has usable frame rectangles")
        local tileset_editor = registry:get("tileset")
        local tileset_document = services.documents:get(created.tileset)
        local tileset_loader = tileset_editor.build_export(tileset_document, WORK_ROOT)
        expect_match(tileset_loader.text, "lurek%.tileset%.newTileSet", "tileset export uses the Lurek tileset API")
        local tileset = lurek.tileset.newTileSet(
            tileset_document.model.first_gid,
            tileset_document.model.tile_count,
            tileset_document.model.columns,
            tileset_document.model.tile_width,
            tileset_document.model.tile_height,
            tileset_document.model.spacing,
            tileset_document.model.margin
        )
        expect_not_nil(tileset, "default tileset geometry is valid")
        local audio_editor = registry:get("audio_cue")
        local audio_document = services.documents:get(created.audio_cue)
        local audio_loader = audio_editor.build_export(audio_document, WORK_ROOT)
        expect_match(audio_loader.text, "lurek%.audio%.newSource", "audio cue export uses the Lurek audio API")
        expect_match(audio_loader.text, "lurek%.audio%.setLooping", "audio cue export preserves loop settings")
        expect_true(services.projects.file_count >= 7, "project index refreshes after creation")
    end)

    -- @integration lurek.filesystem.watchPath
    -- @integration lurek.filesystem.pollWatchers
    -- @integration lurek.filesystem.mountWorkspace
    -- @integration lurek.filesystem.read
    -- @integration lurek.filesystem.toAbsolutePath
    -- @integration lurek.filesystem.unmount
    -- @integration lurek.filesystem.writeWorkspaceAtomic
    it("flags only an externally modified open asset through the GameFS watcher", function()
        local Registry = load_workbench_module("app/editor_registry.lua")
        local State = load_workbench_module("app/state.lua")
        local CommandBus = load_workbench_module("app/command_bus.lua")
        local ProjectIndex = load_workbench_module("app/services/project_index.lua")
        local DocumentService = load_workbench_module("app/services/document_service.lua")
        local registry = Registry.create(load_workbench_module)
        local services = {
            commands = CommandBus.create(),
            projects = ProjectIndex.create(),
            documents = DocumentService.create(registry),
        }
        local source = "save/workbench_asset_creation_watch_source"
        local mountpoint = "workbench_watch_project"
        native_create_directory(source)
        lurek.filesystem.unmount(mountpoint)
        lurek.filesystem.mountWorkspace(lurek.filesystem.toAbsolutePath(source), mountpoint)
        local ctx = State.create(registry, services, { sample_project_root = mountpoint })
        local ok, result = ctx.command_bus:dispatch("asset.create", { editor_id = "particle" })
        expect_true(ok, tostring(result))
        local document = services.documents:get_active()
        services.documents:poll_external_changes()
        lurek.filesystem.writeWorkspaceAtomic(document.path, lurek.filesystem.read(document.path) .. "# edited outside Workbench\n")
        local changed = services.documents:poll_external_changes()
        expect_length(changed, 1, "only the watched document reports an external edit")
        expect_equal(document.path, changed[1].path, "watcher event resolves to the virtual document path")
        expect_true(changed[1].external_modified, "document keeps external-change state until reload or save")
        lurek.filesystem.unmount(mountpoint)
    end)

    -- @integration lurek.image.savePNGWorkspace
    -- @integration lurek.image.newImageData
    -- @integration LImageData:getWidth
    -- @integration lurek.filesystem.mountWorkspace
    -- @integration lurek.filesystem.toAbsolutePath
    -- @integration lurek.filesystem.unmount
    it("creates a paintable PNG document that reloads through the image API", function()
        local Registry = load_workbench_module("app/editor_registry.lua")
        local State = load_workbench_module("app/state.lua")
        local CommandBus = load_workbench_module("app/command_bus.lua")
        local ProjectIndex = load_workbench_module("app/services/project_index.lua")
        local DocumentService = load_workbench_module("app/services/document_service.lua")
        local registry = Registry.create(load_workbench_module)
        local services = { commands = CommandBus.create(), projects = ProjectIndex.create(), documents = DocumentService.create(registry) }
        local source, mountpoint = "save/workbench_pixel_art_source", "workbench_pixel_art_project"
        native_create_directory(source)
        lurek.filesystem.unmount(mountpoint)
        lurek.filesystem.mountWorkspace(lurek.filesystem.toAbsolutePath(source), mountpoint)
        local ctx = State.create(registry, services, { sample_project_root = mountpoint })
        local ok, result = ctx.command_bus:dispatch("asset.create", { editor_id = "pixel_art" })
        expect_true(ok, tostring(result))
        local document = services.documents:get_active()
        local image = lurek.image.newImageData(document.path)
        expect_equal(32, image:getWidth(), "new Pixel Art document uses the default canvas")
        services.documents:mutate_active(function(current)
            current.model.pixels[1] = { 255, 0, 0, 255 }
        end)
        local saved, error_message = services.documents:save_active()
        expect_not_nil(saved, error_message)
        local reloaded, reload_error = services.documents:reload_active()
        expect_not_nil(reloaded, reload_error)
        expect_equal(255, reloaded.model.pixels[1][1], "saved pixel survives a PNG reload")
        lurek.filesystem.unmount(mountpoint)
    end)
end)

test_summary()
