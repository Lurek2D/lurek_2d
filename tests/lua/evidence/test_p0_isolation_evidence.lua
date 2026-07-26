-- Evidence that the P0 extensions remain explicitly composed, isolated building blocks.

local OUT = evidence_output_dir("p0")

-- @describe evidence: isolated P0 owners
describe("evidence: isolated P0 owners", function()
    -- Does: Creates paired input, UI, and raycaster contexts plus independent physics and grid state, then mutates only one owner in each pair.
    -- Shows: The trace records that equal local ids do not alias and that grid/world changes require explicit calls by Lua.
    -- Artifact: tests/artifacts/current/p0/p0_isolation_trace.txt
    -- Why: This proves the P0 APIs do not create a second authoritative world or an automatic bridge between modules.
    it("TXT: isolated contexts and explicit state propagation", function()
        ensure_evidence_dir("p0")

        local input_a = lurek.input.newPlayerContext(1)
        local input_b = lurek.input.newPlayerContext(2)
        input_a:defineButton("door", { bindings = { "keyboard:e" } })

        local ui_a = lurek.ui.newContext()
        local ui_b = lurek.ui.newContext()
        ui_a:create("label", { id = "door", text = "open" })
        ui_b:create("label", { id = "door", text = "closed" })

        local ray_a = lurek.raycaster.newView()
        local ray_b = lurek.raycaster.newView()
        ray_a:setCameraState({ x = 3, y = 4, angle = 0, fov = math.pi / 3 })

        local world = lurek.physics.newWorld(0, 0)
        local body = world:newCircleBody(0, 0, 0.5, "kinematic")
        local controller = world:newKinematicController(body, { radius = 0.5 })
        local probe = controller:testMove(2, 0)

        local field = lurek.tilefield.new({ width = 2, height = 2 })
        local nav = lurek.pathfind.newNavGrid(2, 2)
        field:patchCells({ { x = 1, y = 1, costs = { move = 7 } } })
        nav:patchCells({ { x = 1, y = 1, blocked = true } })

        local input_a_removed = input_a:removeAction("door")
        local input_b_removed = input_b:removeAction("door")
        local lines = {
            "input_a_removed_door=" .. tostring(input_a_removed),
            "input_b_removed_door=" .. tostring(input_b_removed),
            "ui_a_door=" .. ui_a:getById("door"):getText(),
            "ui_b_door=" .. ui_b:getById("door"):getText(),
            "ray_a_x=" .. tostring(ray_a:getCameraState().x),
            "ray_b_x=" .. tostring(ray_b:getCameraState().x),
            "physics_test_move_x=" .. tostring(probe.appliedX),
            "tilefield_cost=" .. tostring(field:getCost(1, 1, nil, "move")),
            "nav_blocked=" .. tostring(nav:isBlocked(1, 1)),
        }
        local path = OUT .. "p0_isolation_trace.txt"
        if write_file then
            write_file(path, table.concat(lines, "\n") .. "\n")
        else
            lurek.filesystem.write(path, table.concat(lines, "\n") .. "\n")
        end
        expect_evidence_created(path)
    end)
end)

test_summary()
