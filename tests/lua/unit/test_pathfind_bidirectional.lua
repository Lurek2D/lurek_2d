-- Bidirectional A* Lua unit tests.
-- Tests are headless-safe (BDD framework).

-- @description Covers suite: NavGrid bidirectional A* path finding.
describe("Bidirectional A*: path finding", function()

    -- @covers lurek.pathfinding.NavGrid.findPathBidirectional
    -- @description Verify findPathBidirectional returns complete path on open 5x5 grid.
    it("finds path on open 5x5 grid from (1,1) to (5,5)", function()
        local grid = lurek.pathfinding.newNavGrid(5, 5)
        local res = grid:findPathBidirectional(1, 1, 5, 5)
        expect_not_nil(res, "result table must not be nil")
        expect_not_nil(res.path, "path must not be nil")
        expect_true(res.complete, "path must be complete")
        expect_greater(#res.path, 0, "path must have at least one node")
        local first = res.path[1]
        expect_equal(1, first.x)
        expect_equal(1, first.y)
        local last = res.path[#res.path]
        expect_equal(5, last.x)
        expect_equal(5, last.y)
    end)

    -- @covers lurek.pathfinding.NavGrid.findPathBidirectional
    -- @description Verify start==goal returns single-node path.
    it("start equals goal returns single-node path", function()
        local grid = lurek.pathfinding.newNavGrid(5, 5)
        local res = grid:findPathBidirectional(3, 3, 3, 3)
        expect_not_nil(res)
        expect_not_nil(res.path)
        expect_equal(1, #res.path)
        expect_true(res.complete)
        expect_equal(3, res.path[1].x)
        expect_equal(3, res.path[1].y)
    end)

    -- @covers lurek.pathfinding.NavGrid.findPathBidirectional
    -- @description Verify blocked start returns nil path and complete=false.
    it("blocked start returns nil path and complete false", function()
        local grid = lurek.pathfinding.newNavGrid(5, 5)
        grid:setBlocked(1, 1, true)
        local res = grid:findPathBidirectional(1, 1, 5, 5)
        expect_not_nil(res, "result table must not be nil")
        expect_nil(res.path, "path must be nil when start is blocked")
        expect_false(res.complete, "complete must be false when start is blocked")
    end)

    -- @covers lurek.pathfinding.NavGrid.findPathBidirectionalEx
    -- @description Full-control variant returns correct path on larger grid.
    it("findPathBidirectionalEx finds path on 10x10 grid", function()
        local grid = lurek.pathfinding.newNavGrid(10, 10)
        local res = grid:findPathBidirectionalEx(1, 1, 10, 10, 1, 0)
        expect_not_nil(res)
        expect_true(res.complete)
        expect_greater(#res.path, 0)
        local last = res.path[#res.path]
        expect_equal(10, last.x)
        expect_equal(10, last.y)
    end)

    -- @covers lurek.pathfinding.NavGrid.findPathBidirectionalEx
    -- @description Very small max_nodes budget returns incomplete result.
    it("tiny max_nodes budget returns incomplete path", function()
        local grid = lurek.pathfinding.newNavGrid(10, 10)
        local res = grid:findPathBidirectionalEx(1, 1, 10, 10, 1, 2)
        expect_not_nil(res)
        expect_false(res.complete, "should be partial when max_nodes is very small")
    end)

end)

test_summary()
