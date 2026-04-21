-- Regression: ObjectPool:acquire must not trigger a RefCell double-borrow.
-- Before the fix the outer `pool.borrow_mut().acquire()` RefMut stayed alive
-- through the if-let body, so the nested `pool.borrow_mut().release(id)`
-- aborted with "already borrowed".

-- @description Covers suite: ObjectPool regression — acquire must not double-borrow internal RefCell.
describe("ObjectPool regression: acquire double-borrow", function()
    -- @covers lurek.patterns.newObjectPool
    -- @covers lurek.patterns.ObjectPool.acquire
    -- @covers lurek.patterns.ObjectPool.release
    it("acquire -> release -> acquire cycle does not panic", function()
        local pool = lurek.patterns.newObjectPool()
        pool:add({ id = "a" })
        expect_no_error(function()
            local v1 = pool:acquire()
            pool:release(v1)
            local v2 = pool:acquire()
            pool:release(v2)
        end)
    end)
end)

test_summary()
