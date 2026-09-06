-- Lurek2D Stress Test: bounded graph batches, inventory recipes, and event queues.

-- @describe flownet stress: prepared topology
describe("flownet stress: prepared topology", function()
    local function __audit_stress_3()
        local graph = lurek.graph.newGraph()
        local edits = {}
        for i = 1, 2000 do
            edits[i] = {
                op = "addNode",
                key = "node_" .. i,
                nodeType = "storage",
                capacity = 8,
            }
        end
        local version = graph:getVersion()
        local started = os.clock()
        local batch = graph:prepareBatch(edits, version)
        local preview = batch:preview()
        local ids = batch:commit()
        local elapsed = os.clock() - started
        expect_equal(2000, preview.changedCount)
        expect_equal(2000, graph:getNodeCount())
        expect_equal(version + 1, graph:getVersion())
        expect_type("number", ids.node_1)
        expect_type("number", ids.node_2000)
        expect_true(elapsed < 5.0, "prepared topology stress budget exceeded: " .. tostring(elapsed))
    end

    -- @stress LGraph:prepareBatch
    it("validates and commits thousands of nodes as one topology version", function()
        __audit_stress_3()
    end)
end)

-- @describe flownet stress: explicit inventory operations
describe("flownet stress: explicit inventory operations", function()
    local function __audit_stress_2()
        local graph = lurek.graph.newGraph()
        local node = graph:addNode("assembler", 10000)
        node:setRecipe("gear", { ore = 2, coal = 1 }, { gear = 1 })
        graph:spawnItems(node, "ore", 2000)
        graph:spawnItems(node, "coal", 1000)
        local started = os.clock()
        local execution = node:runRecipe("gear", 1000)
        local elapsed = os.clock() - started
        expect_equal(1000, execution.runs)
        expect_equal(3000, #execution.consumedIds)
        expect_equal(1000, #execution.producedIds)
        expect_equal(1000, graph:summarizeInventory().byType.gear)
        expect_true(elapsed < 5.0, "recipe stress budget exceeded: " .. tostring(elapsed))
    end

    -- @stress LGraph:spawnItems
    it("processes thousands of recipe item operations in bounded Rust calls", function()
        __audit_stress_2()
    end)
end)

-- @describe flownet stress: bounded pull events
describe("flownet stress: bounded pull events", function()
    local function __audit_stress_1()
        local graph = lurek.graph.newGraph()
        local node = graph:addNode("storage", 5000)
        graph:setEventMode("queue")
        graph:setEventQueueLimit(256)
        graph:spawnItems(node, "ore", 2000, 0.01)
        graph:update(1.0)
        local stats = graph:getEventQueueStats()
        expect_equal(256, stats.pending)
        expect_equal(2000 - 256, stats.dropped)
        local events = graph:drainEvents()
        expect_equal(256, #events)
        expect_equal("itemDecay", events[1].event)
        expect_equal(0, graph:getEventQueueStats().pending)
    end

    -- @stress LGraph:setEventQueueLimit
    it("retains a bounded suffix under a large deterministic event burst", function()
        __audit_stress_1()
    end)
end)

test_summary()
