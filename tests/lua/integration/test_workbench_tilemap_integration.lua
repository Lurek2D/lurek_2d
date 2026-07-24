-- Integration: Workbench TMX document editing is consumed by the tilemap importer.
-- @describe workbench tilemap integration

local WORK_ROOT = "work/workbench_tilemap_integration"
local WORKBENCH_ROOT = "lurek_2d_workbench"
local SAMPLE_TMX = WORKBENCH_ROOT .. "/data/sample_project/content/maps/tutorial.tmx"
local SAMPLE_TILESET = WORKBENCH_ROOT .. "/data/sample_project/content/tilesets/terrain.tileset.toml"
local TMX_PATH = WORK_ROOT .. "/content/maps/tutorial.tmx"
local TILESET_PATH = WORK_ROOT .. "/content/tilesets/terrain.tileset.toml"
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

-- @describe workbench tilemap integration
describe("workbench tilemap integration", function()
    before_each(function()
        enable_fixture_writes()
        lurek.filesystem.createDirectory(WORK_ROOT .. "/content/maps")
        lurek.filesystem.createDirectory(WORK_ROOT .. "/content/tilesets")
        lurek.filesystem.write(TMX_PATH, lurek.filesystem.read(SAMPLE_TMX))
        lurek.filesystem.write(TILESET_PATH, lurek.filesystem.read(SAMPLE_TILESET))
    end)

    after_each(function()
        lurek.filesystem.createDirectory = native_create_directory
        lurek.filesystem.write = native_write
    end)

    -- @integration lurek.filesystem.read
    -- @integration lurek.filesystem.write
    -- @integration lurek.tilemap.loadTMX
    -- @integration lurek.tileset.newTileSet
    it("saves a Workbench-painted TMX document linked to a real Lurek tileset", function()
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
        local opened, open_error = services.documents:open(TMX_PATH)
        expect_not_nil(opened, open_error)
        expect_equal("tilemap", opened.editor_id, "TMX files select the Tilemap Editor")
        expect_equal(0, #(opened.problems or {}), "fixture TMX validates through lurek.tilemap")
        expect_equal("content/tilesets/terrain.tileset.toml", opened.model.tileset.path, "TMX remembers its Workbench tileset link")
        expect_equal(16, opened.model.tileset.tile_count, "Tilemap loads linked tileset geometry")
        local brush_selected = registry:get("tilemap").handle_action(ctx, "brush")
        expect_true(brush_selected, "Tile + selects the next paint tile")
        expect_equal(2, services.documents:get_active().model.brush, "Tile + advances the brush id")

        local changed, change_error = services.documents:mutate_active(function(document)
            document.model.layers[1].cells[1] = 4
            document.model.layers[1].cells[2] = 4
        end)
        expect_not_nil(changed, change_error)
        expect_true(changed.dirty, "painting makes the document dirty")

        local added, add_error = registry:get("tilemap").handle_action(ctx, "add-layer")
        expect_not_nil(added, add_error)
        expect_equal(2, #services.documents:get_active().model.layers, "Tilemap editor creates an editable second TMX layer")
        local overlay, overlay_error = services.documents:mutate_active(function(document)
            document.model.layers[2].cells[1] = 3
        end)
        expect_not_nil(overlay, overlay_error)

        local ok_save, save_result = ctx.command_bus:dispatch("document.save_active")
        expect_true(ok_save, tostring(save_result))
        local parsed, problem = lurek.tilemap.loadTMX(lurek.filesystem.read(TMX_PATH), { strictLayerSize = true })
        expect_not_nil(parsed, problem and problem.message or "saved TMX should load")
        expect_equal(8, parsed.width, "saved map preserves dimensions")
        expect_equal(2, #parsed.layers, "saved TMX retains both layers")

        local ok_export, export_result = ctx.command_bus:dispatch("document.export_active")
        expect_true(ok_export, tostring(export_result))
        expect_true(lurek.filesystem.exists(services.documents:get_active().export_path), "loader export is written")
        local loader = lurek.filesystem.read(services.documents:get_active().export_path)
        expect_match(loader, "lurek%.tileset%.newTileSet", "map loader builds the linked Lurek tileset")
        expect_match(loader, "map:addTileSet", "map loader attaches the linked tileset")
    end)
end)

test_summary()
