-- Lurek2D Lua BDD tests for lurek.patterns collections: Stack, Queue, List, Set
-- Headless: no GPU, no audio, no window.

-- @description Covers suite: lurek.patterns collections (Stack, Queue, List, Set).
describe("lurek.patterns.Stack", function()
    -- @covers lurek.patterns.newStack
    -- @covers lurek.patterns.Stack.push
    -- @covers lurek.patterns.Stack.pop
    -- @covers lurek.patterns.Stack.peek
    -- @covers lurek.patterns.Stack.len
    -- @covers lurek.patterns.Stack.isEmpty
    -- @description Verifies LIFO push/pop ordering.
    it("push and pop follow LIFO order", function()
        local s = lurek.patterns.newStack()
        s:push("a")
        s:push("b")
        s:push("c")
        expect_equal(3, s:len())
        expect_equal("c", s:pop())
        expect_equal("b", s:pop())
        expect_equal("a", s:pop())
        expect_equal(true, s:isEmpty())
    end)

    -- @covers lurek.patterns.Stack.peek
    -- @description Verifies that peek does not remove the top item.
    it("peek does not remove the top item", function()
        local s = lurek.patterns.newStack()
        s:push(42)
        expect_equal(42, s:peek())
        expect_equal(1, s:len())
    end)

    -- @covers lurek.patterns.Stack.isFull
    -- @description Verifies that isFull returns true when capacity is reached.
    it("isFull returns true at capacity", function()
        local s = lurek.patterns.newStack(3)
        s:push(1); s:push(2); s:push(3)
        expect_equal(true, s:isFull())
    end)

    -- @covers lurek.patterns.Stack.toArray
    it("toArray returns all items in order", function()
        local s = lurek.patterns.newStack()
        s:push("x"); s:push("y")
        local arr = s:toArray()
        expect_equal(2, #arr)
    end)

    -- @covers lurek.patterns.Stack.clear
    it("clear empties the stack", function()
        local s = lurek.patterns.newStack()
        s:push(1); s:push(2)
        s:clear()
        expect_equal(0, s:len())
    end)
end)

describe("lurek.patterns.Queue", function()
    -- @covers lurek.patterns.newQueue
    -- @covers lurek.patterns.Queue.enqueue
    -- @covers lurek.patterns.Queue.dequeue
    -- @description Verifies FIFO enqueue/dequeue ordering.
    it("enqueue and dequeue follow FIFO order", function()
        local q = lurek.patterns.newQueue()
        q:enqueue("first")
        q:enqueue("second")
        q:enqueue("third")
        expect_equal("first", q:dequeue())
        expect_equal("second", q:dequeue())
    end)

    -- @covers lurek.patterns.Queue.front
    it("front peeks without removing", function()
        local q = lurek.patterns.newQueue()
        q:enqueue("peek_me")
        expect_equal("peek_me", q:front())
        expect_equal(1, q:len())
    end)

    -- @covers lurek.patterns.Queue.isEmpty
    it("isEmpty returns true on empty queue", function()
        local q = lurek.patterns.newQueue()
        expect_equal(true, q:isEmpty())
        q:enqueue("x")
        expect_equal(false, q:isEmpty())
    end)
end)

describe("lurek.patterns.List", function()
    -- @covers lurek.patterns.newList
    -- @covers lurek.patterns.List.add
    -- @covers lurek.patterns.List.get
    -- @covers lurek.patterns.List.set
    -- @covers lurek.patterns.List.remove
    -- @description Verifies indexed add/get/set/remove operations.
    it("supports indexed access and removal", function()
        local l = lurek.patterns.newList()
        l:add("alpha")
        l:add("beta")
        l:add("gamma")
        expect_equal(3, l:len())
        expect_equal("beta", l:get(2))
        l:set(2, "BETA")
        expect_equal("BETA", l:get(2))
        l:remove(1)
        expect_equal(2, l:len())
    end)

    -- @covers lurek.patterns.List.contains
    it("contains returns true for present and false for absent values", function()
        local l = lurek.patterns.newList()
        l:add("hello")
        expect_equal(true, l:contains("hello"))
        expect_equal(false, l:contains("world"))
    end)
end)

describe("lurek.patterns.Set", function()
    -- @covers lurek.patterns.newSet
    -- @covers lurek.patterns.Set.add
    -- @covers lurek.patterns.Set.has
    -- @covers lurek.patterns.Set.remove
    -- @description Verifies that Set provides string membership.
    it("add, has, and remove work for string members", function()
        local s = lurek.patterns.newSet()
        s:add("fire")
        s:add("water")
        expect_equal(true, s:has("fire"))
        expect_equal(false, s:has("earth"))
        s:remove("fire")
        expect_equal(false, s:has("fire"))
        expect_equal(1, s:len())
    end)

    -- @covers lurek.patterns.Set.union
    it("union returns a set containing all elements of both sets", function()
        local a = lurek.patterns.newSet()
        local b = lurek.patterns.newSet()
        a:add("x"); a:add("y")
        b:add("y"); b:add("z")
        local u = a:union(b)
        expect_equal(3, u:len())
    end)

    -- @covers lurek.patterns.Set.intersection
    it("intersection returns only shared elements", function()
        local a = lurek.patterns.newSet()
        local b = lurek.patterns.newSet()
        a:add("x"); a:add("y"); a:add("z")
        b:add("y"); b:add("z"); b:add("w")
        local i = a:intersection(b)
        expect_equal(2, i:len())
    end)

    -- @covers lurek.patterns.Set.toArray
    it("toArray returns all set members", function()
        local s = lurek.patterns.newSet()
        s:add("one"); s:add("two"); s:add("three")
        local arr = s:toArray()
        expect_equal(3, #arr)
    end)
end)
test_summary()
