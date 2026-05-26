# scheduler

A pure-Lua coroutine task scheduler. Runs multiple coroutines concurrently inside a single `update(dt)` call, with pause, resume, and error isolation per task. Complementary to `lurek.timer` (which uses callbacks); this one uses `coroutine.yield` for sequential async-style code.

## Usage

```lua
local scheduler = require("library/scheduler")

local sched = scheduler.Scheduler.new()

sched:add("patrol", coroutine.create(function()
    while true do
        move_to(100, 200)
        coroutine.yield(2.0)  -- wait 2 seconds
        move_to(300, 200)
        coroutine.yield(2.0)
    end
end))

function lurek.update(dt)
    sched:update(dt)
end

sched:pause("patrol")
sched:resume("patrol")
print("Status:", sched:getStatus("patrol"))
```

## Dependencies

- `lurek.log` (optional)
