-- Integration: workbench command/state/document flow for particle files
-- @describe workbench particle integration

local WORK_ROOT = "work/issue_36_workbench_particle"
local SAMPLE_FIRE = "workbench/data/sample_project/content/particles/fire.particle.toml"
local PARTICLE_PATH = WORK_ROOT .. "/content/particles/fire.particle.toml"
local native_create_directory = lurek.filesystem.createDirectory
local native_write = lurek.filesystem.write

local function enable_host_writes()
    lurek.filesystem.createDirectory = function(_path)
        return nil
    end
    lurek.filesystem.write = function(path, text)
        if write_file then
            write_file(path, text)
            return nil
        end
        return native_write(path, text)
    end
end

local function restore_native_writes()
    lurek.filesystem.createDirectory = native_create_directory
    lurek.filesystem.write = native_write
end

local function load_workbench_module(path)
    local chunk = lurek.filesystem.load("workbench/" .. path)
    expect_type("function", chunk, "workbench module loads from GameFS")

    local ok, result = pcall(chunk)
    expect_true(ok, "workbench module executes: " .. tostring(result))
    return result
end

local function write_sample_particle_project()
    lurek.filesystem.createDirectory(WORK_ROOT .. "/content/particles")
    local source = lurek.filesystem.read(SAMPLE_FIRE)
    lurek.filesystem.write(PARTICLE_PATH, source)
end

-- @describe workbench particle integration
describe("workbench particle integration", function()
    before_each(function()
        enable_host_writes()
        write_sample_particle_project()
    end)

    after_each(function()
        restore_native_writes()
    end)

    -- @integration lurek.filesystem.load
    -- @integration lurek.filesystem.read
    -- @integration lurek.filesystem.write
    -- @integration lurek.serialize.fromToml
    -- @integration lurek.serialize.toToml
    -- @integration lurek.particle.newSystem
    it("opens, edits, saves, reloads, reverts, and exports a particle document through workbench state commands", function()
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
        local indexed_paths = lurek.filesystem.listRecursive(WORK_ROOT)
        expect_true(#indexed_paths > 0, "fixture project should exist before state boot")
        local ctx = State.create(registry, services, {
            sample_project_root = WORK_ROOT,
        })

        local active = services.documents:get_active()
        expect_not_nil(active, (ctx.status or "missing status") .. " | files=" .. tostring(services.projects.file_count))
        expect_equal("particle", ctx.active_editor, "state boots into the particle slice when a particle file exists")
        expect_equal("content/particles/fire.particle.toml", active.relative_path, "active document uses project-relative paths")
        expect_equal(0, #(active.problems or {}), "sample document validates cleanly")

        local ok_preset, preset_result = ctx.command_bus:dispatch("particle.apply_preset", { name = "sparks" })
        expect_true(ok_preset, tostring(preset_result))

        local mutated, mutate_error = services.documents:mutate_active(function(document)
            document.model.emission_rate = 33.0
            document.model.gravity_y = 77.0
        end)
        expect_not_nil(mutated, mutate_error)

        local ok_save, save_result = ctx.command_bus:dispatch("document.save_active")
        expect_true(ok_save, tostring(save_result))

        active = services.documents:get_active()
        expect_false(active.dirty, "save clears the dirty flag")

        local saved_text = lurek.filesystem.read(PARTICLE_PATH)
        expect_true(saved_text:find("emission_rate = 33") ~= nil, "save writes snake_case emission_rate")
        expect_true(saved_text:find("gravity_y = 77") ~= nil, "save writes snake_case gravity_y")

        local ok_export, export_result = ctx.command_bus:dispatch("document.export_active")
        expect_true(ok_export, tostring(export_result))
        expect_not_nil(active.export_path, "export stores the generated file path on the active document")
        expect_true(lurek.filesystem.exists(active.export_path), "export writes a Lua loader snippet")

        local export_text = lurek.filesystem.read(active.export_path)
        expect_true(
            export_text:find('lurek%.particle%.fromTOML%("content/particles/fire%.particle%.toml"%)') ~= nil,
            "export references the project-relative particle path"
        )

        lurek.filesystem.write(PARTICLE_PATH, table.concat({
            "seed = 11",
            "max_particles = 32",
            "emission_rate = 9.0",
            "lifetime_min = 0.10",
            "lifetime_max = 0.30",
            "speed_min = 12.0",
            "speed_max = 48.0",
            "direction = -1.5707964",
            "spread = 0.25",
            "gravity_x = 0.0",
            "gravity_y = 24.0",
            "sizes = [5.0, 2.0]",
            "colors = [[1.0, 1.0, 1.0, 1.0], [1.0, 0.4, 0.1, 0.0]]",
            "",
        }, "\n"))

        local ok_reload, reload_result = ctx.command_bus:dispatch("document.reload_active")
        expect_true(ok_reload, tostring(reload_result))

        active = services.documents:get_active()
        expect_near(9.0, active.model.emission_rate, 0.001, "reload reparses TOML from disk")
        expect_near(24.0, active.model.gravity_y, 0.001, "reload updates the live model")

        local dirty_doc, dirty_error = services.documents:mutate_active(function(document)
            document.model.emission_rate = 41.0
        end)
        expect_not_nil(dirty_doc, dirty_error)
        expect_true(dirty_doc.dirty, "local edits mark the document dirty")

        local ok_revert, revert_result = ctx.command_bus:dispatch("document.revert_active")
        expect_true(ok_revert, tostring(revert_result))

        active = services.documents:get_active()
        expect_near(9.0, active.model.emission_rate, 0.001, "revert restores the last saved disk model")
        expect_false(active.dirty, "revert clears unsaved changes")
    end)
end)
test_summary()
