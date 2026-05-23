-- Shared test fixtures for physics/world setup (load via dofile in unit/integration tests).

--- Create a headless physics world with optional gravity (default 9.81).
function make_test_world(gravity_y)
    gravity_y = gravity_y or 9.81
    return lurek.physics.newWorld(0, gravity_y)
end

--- Create a dynamic body at (x, y) in the given world.
function make_test_body(world, x, y, body_type)
    body_type = body_type or "dynamic"
    return lurek.physics.newBody(world, x, y, body_type)
end

--- Minimal tilemap grid helper: returns cols, rows, tile_size for callers to pass to tilemap APIs.
function make_test_grid(cols, rows, tile_size)
    cols = cols or 8
    rows = rows or 8
    tile_size = tile_size or 16
    return cols, rows, tile_size
end
