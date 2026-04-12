-- Lurek2D Stress Test: Data Structure Operations
-- Tests large tables, string operations, and data encoding at scale


-- @description Covers suite: data stress: large tables.
describe("data stress: large tables", function()
    -- @covers Lua table allocation
    -- @stress Allocates 10000 table entries, each with a nested record and generated string field.
    -- @description Stresses pure-Lua heap allocation and table growth by building a large array of structured records in one pass.
    it("creates table with 10000 entries", function()
        local t = {}
        for i = 1, 10000 do
            t[i] = { x = i, y = i * 2, name = "entity_" .. i }
        end
        expect_equal(10000, #t, "table has 10000 entries")
        expect_equal(5000, t[5000].x, "middle entry is correct")
    end)

    -- @covers lurek.math.random
    -- @covers table.sort
    -- @stress Fills a 5000-element array with random integers and sorts the full dataset.
    -- @description Stresses random-number generation plus Lua's in-place sort over a large numeric array before validating sorted order.
    it("sorts 5000 entries", function()
        local t = {}
        for i = 1, 5000 do
            t[i] = lurek.math.random(1, 100000)
        end

        table.sort(t)

        -- Verify sorted
        local sorted = true
        for i = 2, #t do
            if t[i] < t[i - 1] then
                sorted = false
                break
            end
        end
        expect_true(sorted, "table is sorted")
    end)

    -- @covers Lua table string-key insertion
    -- @stress Inserts 5000 distinct string keys into one hash table and performs boundary lookups.
    -- @description Stresses string-key hash-table population and lookup performance by building a large associative table and probing first, last, and missing keys.
    it("hash table with 5000 string keys", function()
        local t = {}
        for i = 1, 5000 do
            t["key_" .. i] = i
        end

        -- Verify lookup
        expect_equal(1, t["key_1"], "first key")
        expect_equal(5000, t["key_5000"], "last key")
        expect_equal(nil, t["key_5001"], "missing key")
    end)
end)

-- @description Covers suite: data stress: string operations.
describe("data stress: string operations", function()
    -- @covers string.format
    -- @covers table.concat
    -- @stress Formats 1000 strings and concatenates the whole buffer into one result.
    -- @description Stresses string creation and bulk concatenation by assembling a large parts array and joining it into a single long payload.
    it("builds 1000 strings", function()
        local parts = {}
        for i = 1, 1000 do
            parts[i] = string.format("item_%04d", i)
        end
        local result = table.concat(parts, ",")
        expect_true(#result > 8000, "concatenated string is long")
    end)

    -- @covers string.find
    -- @stress Runs the same substring match 1000 times against a fixed sentence.
    -- @description Stresses repeated pattern lookup cost by executing identical search operations in a tight loop and counting successful matches.
    it("pattern matching 1000 times", function()
        local count = 0
        local text = "Lurek2D game engine version 0.4.0 built with Rust"
        for i = 1, 1000 do
            if string.find(text, "Lurek2D") then
                count = count + 1
            end
        end
        expect_equal(1000, count, "all pattern matches succeeded")
    end)
end)

-- @description Covers suite: data stress: nested structures.
describe("data stress: nested structures", function()
    -- @covers Lua nested table allocation
    -- @stress Builds a 10-level linked table hierarchy with 100 payload values at each depth.
    -- @description Stresses recursive table growth and traversal by constructing a deep chain of nested child tables and walking back down to the deepest node.
    it("10 levels of nesting", function()
        local root = {}
        local current = root
        for depth = 1, 10 do
            current.child = { depth = depth, data = {} }
            for i = 1, 100 do
                current.child.data[i] = depth * 100 + i
            end
            current = current.child
        end

        -- Walk back up
        current = root
        local max_depth = 0
        while current.child do
            current = current.child
            max_depth = current.depth
        end
        expect_equal(10, max_depth, "reached depth 10")
    end)
end)
