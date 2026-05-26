-- content/examples/handles.lua
-- Run: cargo run -- content/examples/handles.lua

--- Handle-Based Resource Management
---
--- In Lurek2D, Rust never exposes raw pointers to Lua. Instead, every
--- resource (sprite sheet, physics body, camera, animation) is represented
--- by an opaque handle — a userdata or numeric ID that Lua stores and passes
--- back to Rust when it wants to act on the resource.
---
--- Why handles?
---   1. Safety — Lua's garbage collector cannot corrupt Rust memory.
---   2. No lifetimes — handles outlive any single Lua stack frame safely.
---   3. Clear ownership — Rust owns the data; Lua owns a lightweight ticket.
---   4. Hot-reload friendly — handles survive script reloads if the resource
---      pool is preserved.
---
--- This example shows the pattern across sprite, physics, and camera modules.

--- PATTERN 1: Create a resource, receive a handle
--- lurek.sprite.newSheet(...) returns a LSpriteSheet userdata — the handle.
--- Lua never sees the texture bytes or GPU buffer; only the handle.
--@api-stub: handles.create_sprite_handle
do
    local sheet = lurek.sprite.newSheet(256, 256, 32, 32)
    print("handle type = " .. type(sheet))
    print("sheet:type() = " .. sheet:type())
    print("frames via handle = " .. sheet:getFrameCount())
end

--- PATTERN 2: Use the handle to query and manipulate
--- Every operation takes the handle as the receiver (method call) or first arg.
--- Lua never reaches into struct fields — all access goes through Rust methods.
--@api-stub: handles.use_handle_to_query
do
    local sheet = lurek.sprite.newSheet(128, 64, 32, 32)
    local frame = sheet:getFrame(1)
    print("frame via handle: x=" .. frame.x .. " w=" .. frame.w)
    sheet:nameGroup("idle", 1, 4)
    local names = sheet:getGroupNames()
    print("groups = " .. table.concat(names, ", "))
end

--- PATTERN 3: Physics bodies are handles too
--- lurek.physics.newWorld returns a LWorld handle; bodies created inside it
--- are also handles (LBody). The world handle owns the simulation state.
--@api-stub: handles.physics_body_handle
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 50, 32, 32, "dynamic")
    local x, y = body:getPosition()
    print("body pos = " .. x .. ", " .. y)

    body:setVelocity(50, 0)
    world:step(1 / 60)
    x, y = body:getPosition()
    print("after step = " .. string.format("%.1f, %.1f", x, y))
end

--- PATTERN 4: Multiple handles to the same resource type
--- Each call returns a distinct handle. Lua can store many handles in a table
--- and iterate over them — a common pattern for entity lists.
--@api-stub: handles.multiple_handles
do
    local world = lurek.physics.newWorld(0, 200)
    local bodies = {}

    for i = 1, 5 do
        bodies[i] = world:newBody(i * 40, 0, 16, 16, "dynamic")
    end

    world:step(1 / 60)

    for i, body in ipairs(bodies) do
        local x, y = body:getPosition()
        print("body " .. i .. " y=" .. string.format("%.2f", y))
    end
    print("total handles = " .. #bodies)
end

--- PATTERN 5: Handle lifetime and cleanup
--- Handles are garbage-collected by Lua. When the GC finalizes a handle,
--- Rust releases the underlying resource. You can also destroy explicitly
--- if you need deterministic cleanup (e.g., removing a body from simulation).
--@api-stub: handles.cleanup
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(50, 50, 24, 24, "dynamic")
    print("body alive = " .. tostring(body:getPosition() ~= nil))

    body:destroy()
    print("body removed from world")

    body = nil
    collectgarbage("collect")
    print("handle released to GC")
end

--- PATTERN 6: Camera handle — same pattern, different module
--- The camera module follows the same create-handle, use-handle, release flow.
--@api-stub: handles.camera_handle
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(400, 300)
    cam:setZoom(1.5)
    local x, y = cam:getPosition()
    local z = cam:getZoom()
    print("cam handle: pos=" .. x .. "," .. y .. " zoom=" .. z)
    print("camera type = " .. cam:type())
end
