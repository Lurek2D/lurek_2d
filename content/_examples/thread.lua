-- examples/thread.lua
-- lurek.thread — Background worker threads and inter-thread Channel communication.
--
-- Threading model:
The main thread runs the Lua game loop with the full lurek.* API.
Worker threads get a separate, isolated Lua VM  -- they cannot share Lua state.
All communication goes through typed Channel objects (MPMC queues).
Channel values: nil, booleans, numbers, and strings only.

-- ── Creating a Thread ─────────────────────────────────────────────────────────

-- newThread(code) → Thread
-- Creates a background thread from a Lua source string.
-- The worker VM has access to lurek.math, lurek.data, lurek.thread, lurek.fs,
-- lurek.time, and lurek.platform — but NOT lurek.gfx, lurek.audio, or lurek.physics.
local worker = lurek.thread.newThread([[
    local input_ch  = lurek.thread.getChannel("work_in")
    local output_ch = lurek.thread.getChannel("work_out")

    while true do
        local job = input_ch:demand()  -- block until a job arrives
        if job == "quit" then break end

        -- Heavy computation (safe to do on a worker thread)
        local result = 0
        for i = 1, tonumber(job) do
            result = result + lurek.math.sin(i * 0.001)
        end

        output_ch:push(result)
    end
]])

-- ── Thread Lifecycle ──────────────────────────────────────────────────────────

-- start(...) — launch the thread; optional varargs become the worker's "..."
worker:start()            -- no arguments
worker:start(1, 2, 3)  -- pass initial values accessible in worker as "..."

-- isRunning() → boolean
local running = worker:isRunning()

-- wait() — block the main thread until the worker finishes
worker:wait()

-- getError() → string? — nil if no error; error message if the worker crashed
local err = worker:getError()
if err then
    print("Thread failed: " .. err)
end

-- ── Named Channels ────────────────────────────────────────────────────────────

-- getChannel(name) → Channel
-- Named channels are global across all threads; any thread with the same name
-- accesses the same underlying queue.
local work_in  = lurek.thread.getChannel("work_in")
local work_out = lurek.thread.getChannel("work_out")

-- ── Unnamed (local) Channels ──────────────────────────────────────────────────

-- newChannel() → Channel
-- Creates a fresh unnamed MPMC channel.  Must be passed to workers manually
-- (channels created after newThread('...') won't be visible to the worker).
-- Prefer named channels (getChannel) for most use cases.
local local_ch = lurek.thread.newChannel()

-- ── Channel Operations ────────────────────────────────────────────────────────

-- push(value) — enqueue a value; valid types: nil, boolean, number, string
work_in:push("1000000")   -- send a job to the worker
work_in:push(42)          -- a number
work_in:push(true)        -- a boolean
work_in:push(nil)         -- nil is a valid sentinel / empty slot

-- pop() → value? — dequeue the front value; returns nil immediately if empty
local response = work_out:pop()
if response ~= nil then
    print("Worker result: " .. tostring(response))
end

-- peek() → value? — read front value without removing it
local preview = work_out:peek()

-- demand(timeout_seconds?) → value
-- Blocking pop: waits until an item is available.
-- Optional timeout (seconds); returns nil on timeout.
local result = work_out:demand(5.0)   -- wait up to 5 seconds
local result2 = work_out:demand()      -- wait forever

-- supply(value) — push only if the channel is EMPTY (no-op if already has items)
local_ch:supply(42)  -- set a "latest reading" pattern

-- getCount() → integer — number of queued items
local count = work_out:getCount()

-- clear() — discard all queued items
work_out:clear()

-- ── Typical Usage — main game loop with worker ────────────────────────────────

--[[
local result_ch
local compute_worker

function lurek.init()
    result_ch = lurek.thread.getChannel("results")
    compute_worker = lurek.thread.newThread([[
        local jobs = lurek.thread.getChannel("jobs")
        local out  = lurek.thread.getChannel("results")
        while true do
            local n = jobs:demand()
            if n == -1 then break end
            -- Expensive work
            local sum = 0
            for i = 1, n do sum = sum + lurek.math.sqrt(i) end
            out:push(sum)
        end
    ]])
    compute_worker:start()

    -- send the first batch of jobs
    local jobs = lurek.thread.getChannel("jobs")
    jobs:push(100000)
    jobs:push(200000)
    jobs:push(-1)  -- sentinel: tell worker to exit
end

local result_text = "Computing..."

function lurek.process(dt)
    local r = result_ch:pop()
    if r then
        result_text = "Result: " .. tostring(r)
    end
end

function lurek.render()
    lurek.gfx.print(result_text, 10, 10)
end
]]

-- ─── ThreadHandle ──────────────────────────────────────────────────────────────

local threadhandle_type = threadhandle:type()  -- "ThreadHandle"
local threadhandle_is_type = threadhandle:typeOf("ThreadHandle")  -- Returns whether this object is of the given type

-- ── Table Serialization Through Channels ─────────────────────────────────────

-- pushTable(t) — serialise a Lua table (including nested tables) into the channel.
-- popTable() → table? — deserialise and remove from the channel (nil if empty).

local tbl_ch = lurek.thread.newChannel()

-- Push a structured record
tbl_ch:pushTable({ x = 10, y = 20, tags = {"player", "active"} })

-- Pop it back out on any thread that has access to this channel
local record = tbl_ch:popTable()
-- record.x == 10, record.y == 20

-- ── Byte Blobs Through Channels ───────────────────────────────────────────────

-- pushBytes(str) — push a raw byte string as a Bytes channel value.
-- popBytes() → string? — pop and return the byte string (nil if empty).

local bytes_ch = lurek.thread.newChannel()
local payload = "PNG\0\255\255\0"       -- arbitrary binary content
bytes_ch:pushBytes(payload)
local received = bytes_ch:popBytes()     -- received == payload

-- ── Thread Pool ───────────────────────────────────────────────────────────────

-- newPool(n, workerCode) → ThreadPool
-- Creates n pre-spawned worker VMs all executing workerCode.
-- Workers read from the pool's shared input channel and write results to the
-- output channel.

local pool = lurek.thread.newPool(4, [[
    local input  = lurek.thread.getChannel("__pool_input")
    local output = lurek.thread.getChannel("__pool_output")
    while true do
        local v = input:demand()
        if v == nil then break end
        -- square each number
        output:push(v * v)
    end
]])

pool:submit(3)       -- push 3 onto input channel
pool:submit(5)
pool:join()          -- wait for workers to process all submitted values

local r1 = pool:collect()  -- 9
local r2 = pool:collect()  -- 25

-- size() → integer — number of workers
local worker_count = pool:size()

-- getInputChannel() / getOutputChannel() → Channel
local in_ch  = pool:getInputChannel()
local out_ch = pool:getOutputChannel()

-- ── Promise / Future ──────────────────────────────────────────────────────────

-- async(code, ...args) → Promise
-- Runs code in a background thread; arguments become varargs ("...") in the code.

local promise = lurek.thread.async([[
    local a, b = ...
    -- simulate work
    local result = 0
    for i = 1, 100000 do result = result + lurek.math.sqrt(i) end
    return result + a + b
]], 10, 20)

-- isDone() → boolean  — check without blocking
-- result() → value?   — returns the value if done, nil otherwise
-- getError() → string? — error message if the worker crashed

function lurek.process(dt)
    if promise:isDone() then
        local v = promise:result()
        if v then
            -- use result
        end
        local err = promise:getError()
        if err then
            -- handle error
        end
    end
end
