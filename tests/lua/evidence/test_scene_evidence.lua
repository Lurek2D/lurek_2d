-- Canonical evidence file for lurek.scene data and visual outputs.

local OUT = evidence_output_dir("scene")

local function write_text(path, text)
    if write_file then
        write_file(path, text)
    else
        lurek.filesystem.write(path, text)
    end
    expect_evidence_created(path)
end

local function save_png(img, path)
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
end

local function draw_outline(img, x, y, w, h, r, g, b, a)
    img:drawLine(x, y, x + w - 1, y, r, g, b, a or 255)
    img:drawLine(x + w - 1, y, x + w - 1, y + h - 1, r, g, b, a or 255)
    img:drawLine(x + w - 1, y + h - 1, x, y + h - 1, r, g, b, a or 255)
    img:drawLine(x, y + h - 1, x, y, r, g, b, a or 255)
end

-- @describe Evidence: lurek.scene DepthSorter
describe("Evidence: lurek.scene DepthSorter", function()
    before_each(function()
        ensure_evidence_dir("scene")
    end)
    -- Does: Runs "depth order ascending" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.scene.newDepthSorter, LDepthSorter:add, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/scene/<artifact>
    -- Why: This is meaningful only if the visible/text output comes from lurek.scene.newDepthSorter, LDepthSorter:add, and related owner calls; export helpers are just the container.

    it("TXT: depth order ascending", function()
        local ds = lurek.scene.newDepthSorter()
        local call_order = {}

        ds:add(function() call_order[#call_order + 1] = 30 end, 30.0)
        ds:add(function() call_order[#call_order + 1] = 10 end, 10.0)
        ds:add(function() call_order[#call_order + 1] = 50 end, 50.0)
        ds:add(function() call_order[#call_order + 1] = -5 end, -5.0)
        ds:add(function() call_order[#call_order + 1] = 20 end, 20.0)

        ds:flush()

        local prev = -math.huge
        for _, v in ipairs(call_order) do
            expect_true(v >= prev)
            prev = v
        end

        local lines = {}
        for _, v in ipairs(call_order) do
            lines[#lines + 1] = tostring(v)
        end

        local path = OUT .. "scene_depth_sort_ascending.txt"
        write_text(path, table.concat(lines, "\n") .. "\n")
    end)
    -- Does: Runs "stable equal-depth order" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by LDepthSorter:setStable and LDepthSorter:flush without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/scene/scene_depth_sort_stable_equal_depth.txt
    -- Why: This is meaningful only if the visible/text output comes from LDepthSorter:setStable and LDepthSorter:flush; export helpers are just the container.

    it("TXT: stable equal-depth order", function()
        local ds = lurek.scene.newDepthSorter()
        ds:setStable(true)

        local call_order = {}
        ds:add(function() call_order[#call_order + 1] = "A" end, 5.0)
        ds:add(function() call_order[#call_order + 1] = "B" end, 5.0)
        ds:add(function() call_order[#call_order + 1] = "C" end, 5.0)
        ds:flush()

        expect_equal("A", call_order[1])
        expect_equal("B", call_order[2])
        expect_equal("C", call_order[3])

        local path = OUT .. "scene_depth_sort_stable_equal_depth.txt"
        write_text(path, table.concat(call_order, "\n") .. "\n")
    end)
    -- Does: Runs "object entry order" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by LDepthSorter:addObject and LDepthSorter:flush without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/scene/scene_depth_sort_object_entries.txt
    -- Why: This is meaningful only if the visible/text output comes from LDepthSorter:addObject and LDepthSorter:flush; export helpers are just the container.

    it("TXT: object entry order", function()
        local ds = lurek.scene.newDepthSorter()
        local call_order = {}

        local obj1 = { depth = 2.0, drawSorted = function() call_order[#call_order + 1] = 2 end }
        local obj2 = { depth = 1.0, drawSorted = function() call_order[#call_order + 1] = 1 end }

        ds:addObject(obj1)
        ds:addObject(obj2)
        ds:flush()

        expect_equal(1, call_order[1])
        expect_equal(2, call_order[2])

        local path = OUT .. "scene_depth_sort_object_entries.txt"
        write_text(path, table.concat({ tostring(call_order[1]), tostring(call_order[2]) }, "\n") .. "\n")
    end)
end)

-- @describe Evidence: lurek.scene runtime flow
describe("Evidence: lurek.scene runtime flow", function()
    before_each(function()
        ensure_evidence_dir("scene")
        lurek.scene.clear()
        lurek.scene.clearQueuedTransitions()
    end)
    -- Does: Runs "depth sorter order bands" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by LDepthSorter:add and LDepthSorter:flush without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/scene/<artifact>
    -- Why: This is meaningful only if the visible/text output comes from LDepthSorter:add and LDepthSorter:flush; export helpers are just the container.

    it("PNG: depth sorter order bands", function()
        local ds = lurek.scene.newDepthSorter()
        local order = {}

        ds:add(function() order[#order + 1] = 4 end, 40.0)
        ds:add(function() order[#order + 1] = 1 end, 10.0)
        ds:add(function() order[#order + 1] = 3 end, 30.0)
        ds:add(function() order[#order + 1] = 2 end, 20.0)
        ds:flush()

        local img = lurek.image.newImageData(320, 180)
        img:fill(14, 16, 22, 255)
        for x = 0, 319, 16 do
            img:drawLine(x, 0, x, 179, 24, 28, 36, 255)
        end
        for y = 0, 179, 18 do
            img:drawLine(0, y, 319, y, 22, 26, 34, 255)
        end

        local colors = {
            { 90, 180, 255 },
            { 120, 220, 140 },
            { 255, 190, 80 },
            { 255, 120, 120 },
        }
        for i, depth_rank in ipairs(order) do
            local c = colors[depth_rank]
            local x = 28 + (depth_rank - 1) * 12
            local y = 22 + (i - 1) * 36
            local w = 230 - (i - 1) * 6
            local h = 24
            img:drawRect(x + 6, y + 6, w, h, 8, 10, 14, 180)
            img:drawRect(x, y, w, h, 30, 34, 42, 255)
            img:drawRect(x + 2, y + 2, 16, h - 4, c[1], c[2], c[3], 255)
            draw_outline(img, x, y, w, h, 226, 232, 244, 255)
            for py = y + 5, y + h - 6 do
                for px = x + 24, x + w - 14 do
                    img:setPixel(px, py, c[1], c[2], c[3], 235)
                end
            end
            for dot = 0, depth_rank - 1 do
                local dx = x + w - 18 - dot * 8
                for oy = -1, 1 do
                    for ox = -1, 1 do
                        img:setPixel(dx + ox, y + 12 + oy, 255, 244, 220, 255)
                    end
                end
            end
        end

        local path = OUT .. "scene_depth_sort_bands.png"
        save_png(img, path)
    end)
    -- Does: Runs "scene transition queue trace" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.scene.queueTransition, lurek.scene.getQueuedTransitionCount, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/scene/scene_transition_queue_trace.txt
    -- Why: This is meaningful only if the visible/text output comes from lurek.scene.queueTransition, lurek.scene.getQueuedTransitionCount, and related owner calls; export helpers are just the container.

    it("TXT: scene transition queue trace", function()
        lurek.scene.push({})
        lurek.scene.queueTransition("fade", 0.5, "linear")
        local queued_before = lurek.scene.getQueuedTransitionCount()
        lurek.scene.update(0.25)
        local progress_mid = lurek.scene.getTransitionProgress()
        lurek.scene.clearQueuedTransitions()
        local queued_after = lurek.scene.getQueuedTransitionCount()

        local lines = {
            "queued_before=" .. tostring(queued_before),
            "progress_mid=" .. tostring(progress_mid),
            "queued_after=" .. tostring(queued_after),
        }
        local path = OUT .. "scene_transition_queue_trace.txt"
        write_text(path, table.concat(lines, "\n") .. "\n")
    end)
    -- Does: Runs "scene transition progress dashboard" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.scene.queueTransition, lurek.scene.getQueuedTransitionCount, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/scene/<artifact>
    -- Why: This is meaningful only if the visible/text output comes from lurek.scene.queueTransition, lurek.scene.getQueuedTransitionCount, and related owner calls; export helpers are just the container.

    it("PNG: scene transition progress dashboard", function()
        lurek.scene.push({})
        lurek.scene.queueTransition("fade", 0.5, "linear")

        local img = lurek.image.newImageData(340, 140)
        img:fill(14, 16, 22, 255)
        local samples = {}
        for i = 1, 4 do
            samples[i] = {
                progress = lurek.scene.getTransitionProgress(),
                queued = lurek.scene.getQueuedTransitionCount(),
            }
            lurek.scene.update(0.125)
        end

        for i, sample in ipairs(samples) do
            local x = 18 + (i - 1) * 80
            local y = 24
            img:drawRect(x, y, 66, 84, 28, 32, 42, 255)
            draw_outline(img, x, y, 66, 84, 226, 232, 244, 255)
            local fill_w = math.floor((sample.progress or 0) * 50 + 0.5)
            img:drawRect(x + 8, y + 18, 50, 12, 18, 22, 30, 255)
            img:drawRect(x + 8, y + 18, fill_w, 12, 92, 178, 255, 255)
            for q = 1, sample.queued do
                local qx = x + 12 + (q - 1) * 12
                img:drawRect(qx, y + 46, 8, 18, 255, 190, 96, 255)
                draw_outline(img, qx, y + 46, 8, 18, 250, 238, 210, 255)
            end
            img:drawLine(x + 8, y + 72, x + 58, y + 72, 70, 76, 92, 255)
            img:drawLine(x + 8, y + 78, x + 8 + fill_w, y + 78, 110, 220, 154, 255)
        end

        save_png(img, OUT .. "scene_transition_progress_dashboard.png")
        lurek.scene.clearQueuedTransitions()
        lurek.scene.clear()
    end)
end)

-- @describe Evidence: lurek.scene state registry and serialization
describe("Evidence: lurek.scene state registry and serialization", function()
    before_each(function()
        ensure_evidence_dir("scene")
        lurek.scene.clear()
        lurek.scene.clearQueuedTransitions()
    end)
    -- Does: Runs "scene state, preload, and overlay trace" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.scene.clear, lurek.scene.setData, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/scene/<artifact>
    -- Why: This is meaningful only if the visible/text output comes from lurek.scene.clear, lurek.scene.setData, and related owner calls; export helpers are just the container.

    it("TXT: scene state, preload, and overlay trace", function()
        local preload_name = "scene_evidence_preloaded"
        local preload_calls = 0

        lurek.scene.setData("chapter", 4)
        lurek.scene.setData("gold", 275)
        local snap = lurek.scene.serializeScene()
        lurek.scene.clear()
        lurek.scene.deserializeScene(snap)
        expect_equal(4, lurek.scene.getData("chapter"))
        expect_equal(275, lurek.scene.getData("gold"))

        lurek.scene.registerScene(preload_name, { name = preload_name })
        lurek.scene.preload(preload_name, function()
            preload_calls = preload_calls + 1
        end)
        expect_false(lurek.scene.isPreloaded(preload_name))
        lurek.scene.pushPreloaded(preload_name)
        expect_true(lurek.scene.isPreloaded(preload_name))

        lurek.scene.clear()
        lurek.scene.push({ name = "base_scene" })
        lurek.scene.pushOverlay({ name = "overlay_scene" })
        local active = lurek.scene.getActiveScenes()
        expect_true(#active >= 2)

        local lines = {
            "chapter=" .. tostring(lurek.scene.getData("chapter")),
            "gold=" .. tostring(lurek.scene.getData("gold")),
            "preload_calls=" .. tostring(preload_calls),
            "preloaded=" .. tostring(lurek.scene.isPreloaded(preload_name)),
            "active_scene_count=" .. tostring(#active),
        }

        write_text(OUT .. "scene_state_preload_overlay_trace.txt", table.concat(lines, "\n") .. "\n")
        lurek.scene.unregisterScene(preload_name)
        lurek.scene.clear()
    end)
end)

-- @describe Evidence: lurek.scene object container flow
describe("Evidence: lurek.scene object container flow", function()
    before_each(function()
        ensure_evidence_dir("scene")
    end)
    -- Does: Runs "object container layer trace" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.scene.newObjectContainer, LSceneObjectContainer:add, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/scene/<artifact>
    -- Why: This is meaningful only if the visible/text output comes from lurek.scene.newObjectContainer, LSceneObjectContainer:add, and related owner calls; export helpers are just the container.

    it("TXT: object container layer trace", function()
        local container = lurek.scene.newObjectContainer()
        local updates = 0
        local draws = 0
        local scout = {
            layer = 1,
            id = "scout",
            update = function(_, dt)
                if dt > 0 then
                    updates = updates + 1
                end
            end,
            draw = function()
                draws = draws + 1
            end,
        }
        local turret = {
            layer = 2,
            id = "turret",
            draw = function()
                draws = draws + 1
            end,
        }

        container:add(scout)
        container:add(turret)
        expect_equal(2, container:getCount())
        expect_true(container:has(scout))

        container:update(0.16)
        container:draw()

        local layer_two = container:getByLayer(2)
        local objects = container:getObjects()
        expect_equal(1, #layer_two)
        expect_equal(2, #objects)
        expect_equal("LSceneObjectContainer", container:type())
        expect_true(container:typeOf("LSceneObjectContainer"))

        container:remove(turret)
        expect_false(container:has(turret))
        container:clear()
        expect_equal(0, container:getCount())

        local lines = {
            "updates=" .. tostring(updates),
            "draws=" .. tostring(draws),
            "layer_two_count=" .. tostring(#layer_two),
            "objects_before_clear=" .. tostring(#objects),
            "container_type=" .. tostring(container:type()),
        }

        write_text(OUT .. "scene_object_container_layer_trace.txt", table.concat(lines, "\n") .. "\n")
    end)
end)
test_summary()
