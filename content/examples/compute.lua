-- content/examples/compute.lua
-- lurek.compute API examples.
-- Run: cargo run -- content/examples/compute.lua
--@api-stub: lurek.compute.newArray
-- Allocates a typed zero-filled array for game data grids
do
  -- newArray(shape, dtype?) builds a zero-filled LArray with fixed dimensions.
  -- A game can keep per-tile simulation values in this kind of dense grid.
  local heat = lurek.compute.newArray({8, 8}, "float32")

  -- The first two arguments are row and column; the last argument is value.
  heat:set(1, 1, 1.0)
  heat:set(8, 8, 0.75)

  -- getSize() is useful when deciding whether a buffer is small enough for a frame job.
  lurek.log.info("heat grid cells=" .. heat:getSize() .. " seed=" .. heat:get(1, 1), "compute")
end
--@api-stub: lurek.compute.zeros
-- Creates a zero-filled scratch buffer
do
  -- zeros(shape, dtype?) is ideal for counters that start empty each turn.
  -- This grid records damage around an explosion before applying it to entities.
  local damage = lurek.compute.zeros({3, 3}, "float32")

  -- Center cell gets full damage; nearby cells are filled separately by game logic.
  damage:set(2, 2, 25.0)

  -- sum() gives a quick total for balancing the area effect.
  local total = damage:sum()
  lurek.log.info("blast total damage=" .. total, "combat")
end
--@api-stub: lurek.compute.ones
-- Creates a one-filled mask or multiplier array
do
  -- ones(shape, dtype?) starts every cell at 1.0.
  -- A visibility multiplier can begin fully visible, then later fade blocked cells.
  local visibility = lurek.compute.ones({4, 4}, "float32")

  -- clamp() keeps the demonstration bounded without changing the original array.
  local dimmed = visibility:clamp(0.0, 0.5)

  -- Mean opacity is a compact value to feed into debug HUD text.
  lurek.log.info("visibility mean=" .. dimmed:mean(), "fov")
end
--@api-stub: lurek.compute.range
-- Builds a numeric sequence as an LArray
do
  -- range(start, stop, step?, dtype?) generates values from start up to, but not including, stop.
  -- Frame timelines, level curves, and sampled motion paths often start from a simple range.
  local frames = lurek.compute.range(0, 8, 1, "float32")

  -- Squaring the range creates a tiny quadratic timing curve.
  local curve = frames:pow(2)

  -- get() uses Lua-style one-based indexing; index 5 contains 4^2.
  lurek.log.info("curve sample=" .. curve:get(5), "animation")
end
--@api-stub: lurek.compute.fromTable
-- Converts Lua table data into an LArray
do
  -- fromTable(data, shape?, dtype?) copies numeric Lua data into compute storage.
  -- Passing a shape turns a flat table into a grid without changing element order.
  local tiles = {
    0, 1, 0,
    2, 3, 2,
    0, 1, 0,
  }
  local terrain = lurek.compute.fromTable(tiles, {3, 3}, "int32")

  -- The center tile keeps its authored ID after conversion.
  lurek.log.info("center terrain id=" .. terrain:get(2, 2), "tiles")
end
--@api-stub: lurek.compute.getParThreshold
-- Reads the global parallel execution threshold
do
  -- The threshold is the element count where compute operations may use parallel work.
  -- Game code can inspect it before deciding whether to batch many small arrays.
  local threshold = lurek.compute.getParThreshold()
  local sample = lurek.compute.zeros({4, 4})

  -- This small example stays cheap and only reports whether it is below the threshold.
  local below_threshold = sample:getSize() < threshold
  lurek.log.info("small compute job below threshold=" .. tostring(below_threshold), "compute")
end
--@api-stub: lurek.compute.setParThreshold
-- Changes the global parallel threshold and reports the previous value
do
  -- setParThreshold(threshold) returns the old value.
  -- Keep examples conservative: restore the setting so later blocks are not surprised.
  local previous = lurek.compute.getParThreshold()

  -- A small threshold can help benchmark tile-grid operations during development.
  local old_from_set = lurek.compute.setParThreshold(128)
  local updated = lurek.compute.getParThreshold()
  lurek.compute.setParThreshold(previous)

  lurek.log.info("threshold " .. old_from_set .. " -> " .. updated .. " -> " .. previous, "compute")
end
--@api-stub: lurek.compute.gaussianKernel
-- Creates a normalized blur kernel
do
  -- gaussianKernel(size, sigma) creates a square kernel for smoothing 2D data.
  -- In a game, this can soften fog values or smooth procedural terrain height.
  local kernel = lurek.compute.gaussianKernel(3, 1.0)

  -- The weights should sum near 1.0, which preserves overall brightness or height.
  lurek.log.info("gaussian weight sum=" .. kernel:sum(), "render")
end
--@api-stub: lurek.compute.rotate2dMatrix
-- Creates a 2D rotation matrix in radians
do
  -- rotate2dMatrix(angle_rad) returns a 2x2 matrix.
  -- A turret or projectile system can use it to rotate local offsets into world space.
  local angle = math.pi / 4
  local rot = lurek.compute.rotate2dMatrix(angle)

  -- Points are stored as rows, so each row is one (x, y) pair.
  local muzzle_offsets = lurek.compute.fromTable({1, 0, 0, 1}, {2, 2})

  -- transformPoints applies the matrix to both offsets.
  local rotated = rot:transformPoints(muzzle_offsets)
  lurek.log.info("rotated offset x=" .. rotated:get(1, 1), "combat")
end
--@api-stub: lurek.compute.affine2d
-- Creates a combined translate, rotate, and scale matrix
do
  -- affine2d(tx, ty, angle_rad, sx, sy) builds a 2D transform matrix.
  -- This is useful when previewing where local sprite points land on screen.
  local tx, ty = 100, 50
  local angle = 0.0
  local sx, sy = 2.0, 2.0
  local m = lurek.compute.affine2d(tx, ty, angle, sx, sy)

  -- The local point (4, 3) scales to (8, 6), then translates to (108, 56).
  local local_point = lurek.compute.fromTable({4, 3}, {1, 2})
  local screen_point = m:transformPoints(local_point)
  lurek.log.info("screen point=" .. screen_point:get(1, 1) .. "," .. screen_point:get(1, 2), "render")
end
--@api-stub: lurek.compute.fft
-- Converts real samples into frequency bins
do
  -- fft(samples) returns a table of bins, each with re and im fields.
  -- A rhythm game can inspect bins to detect dominant beats in short windows.
  local samples = {0.0, 1.0, 0.0, -1.0, 0.0, 1.0, 0.0, -1.0}
  local spectrum = lurek.compute.fft(samples)

  -- Lua tables are one-based; the first bin is the DC component.
  local bin0 = spectrum[1]
  lurek.log.info("fft dc re=" .. bin0.re .. " im=" .. bin0.im, "audio")
end
--@api-stub: lurek.compute.ifft
-- Rebuilds real samples from frequency bins
do
  -- ifft(freqs) accepts the complex bin table returned by fft().
  -- The round trip is useful when prototyping simple audio filters or beat tools.
  local samples = {1.0, 0.5, 0.0, -0.5}
  local freqs = lurek.compute.fft(samples)

  -- Reconstructing without changing the bins should preserve the first sample.
  local rebuilt = lurek.compute.ifft(freqs)
  lurek.log.info("rebuilt sample=" .. rebuilt[1], "audio")
end
--@api-stub: lurek.compute.fftMagnitude
-- Computes frequency magnitudes directly
do
  -- fftMagnitude(samples) returns a number table of bin strengths.
  -- It skips manual sqrt(re*re + im*im) work in Lua.
  local samples = {0.0, 1.0, 0.0, -1.0, 0.0, 1.0, 0.0, -1.0}
  local mags = lurek.compute.fftMagnitude(samples)

  -- A visualizer might map this magnitude to the height of a bar.
  lurek.log.info("spectrum bar 2=" .. mags[2], "audio")
end
--@api-stub: LArray:getShape
-- Reports the size of each array dimension
do
  -- getShape() returns an integer table, such as {rows, columns} for 2D arrays.
  -- Check it before combining grids that must match.
  local grid = lurek.compute.zeros({4, 6}, "float32")
  local shape = grid:getShape()

  lurek.log.info("influence grid=" .. shape[1] .. "x" .. shape[2], "ai")
end
--@api-stub: LArray:getDimensions
-- Reports how many axes an array has
do
  -- getDimensions() returns 1 for vectors, 2 for matrices, and so on.
  -- Script utilities can reject unexpected shapes early.
  local path_costs = lurek.compute.range(0, 5, 1)
  local heatmap = lurek.compute.zeros({2, 3})

  if path_costs:getDimensions() == 1 and heatmap:getDimensions() == 2 then
    lurek.log.info("vector and grid dimensions are valid", "compute")
  end
end
--@api-stub: LArray:getSize
-- Counts all elements across every dimension
do
  -- getSize() returns the product of the shape dimensions.
  -- Use it for progress bars or to estimate how much work a grid pass will do.
  local minimap = lurek.compute.zeros({8, 8})
  local cells = minimap:getSize()

  lurek.log.info("minimap cell count=" .. cells, "ui")
end
--@api-stub: LArray:getDataType
-- Reports the element storage type
do
  -- getDataType() returns names like float32 or int32.
  -- int32 is a natural fit for tile IDs, bit masks, and inventory slot IDs.
  local tile_ids = lurek.compute.zeros({8}, "int32")
  local dtype = tile_ids:getDataType()

  if dtype == "int32" then
    lurek.log.info("tile id buffer supports integer masks", "tiles")
  end
end
--@api-stub: LArray:isOnGPU
-- Reports whether array storage is GPU-backed
do
  -- isOnGPU() currently returns false for CPU-backed arrays.
  -- Keeping the check in debug tools makes future GPU paths easier to inspect.
  local scratch = lurek.compute.zeros({4})
  local storage = "cpu"
  if scratch:isOnGPU() then
    storage = "gpu"
  end

  lurek.log.debug("compute scratch storage=" .. storage, "compute")
end
--@api-stub: LArray:get
-- Reads a single value with one-based indices
do
  -- get(i, j, ...) uses one index per dimension.
  -- For a 2D board, read as get(row, col), matching Lua table habits.
  local board = lurek.compute.fromTable({
    0, 2,
    1, 0,
  }, {2, 2}, "int32")

  -- The top-right cell contains tile ID 2.
  lurek.log.info("top right tile=" .. board:get(1, 2), "tiles")
end
--@api-stub: LArray:set
-- Writes a single value with one-based indices
do
  -- set(i, j, ..., value) uses all arguments except the last as indices.
  -- The last argument is the numeric value to store.
  local board = lurek.compute.zeros({3, 3})

  -- Mark the center cell as occupied by a player piece.
  board:set(2, 2, 1.0)
  lurek.log.info("center occupied=" .. board:get(2, 2), "puzzle")
end
--@api-stub: LArray:toTable
-- Copies array data back to a flat Lua table
do
  -- toTable() returns values in storage order.
  -- This is useful for save data, debug overlays, or APIs that expect Lua tables.
  local cooldowns = lurek.compute.fromTable({0.0, 0.5, 1.0, 1.5})
  local flat = cooldowns:toTable()

  lurek.log.info("cooldown count=" .. #flat .. " third=" .. flat[3], "ui")
end
--@api-stub: LArray:reshape
-- Reinterprets array data with a new shape
do
  -- reshape(shape) changes dimensions while preserving the same total element count.
  -- It is handy when generated 1D data needs to become a tile grid.
  local row = lurek.compute.range(0, 6)
  local grid = row:reshape({2, 3})

  -- After reshape, row 2 column 3 holds the last generated value.
  lurek.log.info("spawn grid last value=" .. grid:get(2, 3), "procgen")
end
--@api-stub: LArray:clone
-- Makes an independent copy of an array
do
  -- clone() is the safe way to keep a snapshot before mutating current state.
  -- This mirrors saving last frame's occupancy map for change detection.
  local previous_frame = lurek.compute.ones({4})
  local current_frame = previous_frame:clone()

  -- Mutating the clone does not affect the source snapshot.
  current_frame:fill(0.0)
  lurek.log.info("previous=" .. previous_frame:sum() .. " current=" .. current_frame:sum(), "tiles")
end
--@api-stub: LArray:transpose
-- Swaps rows and columns of a 2D array
do
  -- transpose() turns a {2, 3} grid into {3, 2}.
  -- This helps when a tool exports columns but the game reads rows.
  local m = lurek.compute.fromTable({1, 2, 3, 4, 5, 6}, {2, 3})
  local t = m:transpose()
  local shape = t:getShape()

  lurek.log.info("transposed shape=" .. shape[1] .. "x" .. shape[2], "tools")
end
--@api-stub: LArray:fill
-- Overwrites every element in place
do
  -- fill(val) reuses an existing buffer instead of allocating a replacement.
  -- This is a good pattern for per-frame scratch masks.
  local fog = lurek.compute.zeros({4, 4})

  -- Mark all cells unexplored, using -1 as the local script convention.
  fog:fill(-1.0)
  lurek.log.info("fog reset sum=" .. fog:sum(), "fov")
end
--@api-stub: LArray:pow
-- Raises each element to a scalar exponent
do
  -- pow(exp) returns a new array; the original stays unchanged.
  -- Squared distances are common in cheap range checks.
  local distance_steps = lurek.compute.fromTable({1, 2, 3, 4})
  local squared = distance_steps:pow(2)

  lurek.log.info("max squared distance=" .. squared:max(), "ai")
end
--@api-stub: LArray:sqrt
-- Computes square roots element by element
do
  -- sqrt() turns squared magnitudes back into distances.
  -- Values should be non-negative for real-valued results.
  local squared_ranges = lurek.compute.fromTable({1, 4, 9, 16})
  local ranges = squared_ranges:sqrt()

  lurek.log.info("longest range=" .. ranges:get(4), "ai")
end
--@api-stub: LArray:abs
-- Removes the sign from every value
do
  -- abs() is useful for screen shake or input deltas where direction is irrelevant.
  local input_deltas = lurek.compute.fromTable({-3, 1, -2, 4})
  local magnitudes = input_deltas:abs()

  lurek.log.info("total input movement=" .. magnitudes:sum(), "input")
end
--@api-stub: LArray:neg
-- Flips the sign of every value
do
  -- neg() returns a new array with each value multiplied by -1.
  -- Knockback code can use this to build an opposite impulse.
  local impulse = lurek.compute.fromTable({2, -1, 4})
  local counter_impulse = impulse:neg()

  lurek.log.info("counter impulse x=" .. counter_impulse:get(1), "physics")
end
--@api-stub: LArray:clamp
-- Bounds values inside a numeric range
do
  -- clamp(min, max) is a safe final step for health, stamina, and color channels.
  local hp = lurek.compute.fromTable({120, -5, 75, 200})

  -- Values below 0 become 0; values above 100 become 100.
  local clamped = hp:clamp(0, 100)
  lurek.log.info("highest legal hp=" .. clamped:max(), "combat")
end
--@api-stub: LArray:threshold
-- Converts values above a cutoff into a mask
do
  -- threshold(val) returns 1 where element > val, otherwise 0.
  -- This makes masks for visibility, danger zones, or spawn eligibility.
  local danger = lurek.compute.fromTable({0.1, 0.8, 0.4, 0.9})

  -- Count cells hot enough to warn the player.
  local warning_mask = danger:threshold(0.5)
  lurek.log.info("danger cells=" .. warning_mask:countNonZero(), "ui")
end
--@api-stub: LArray:countNonZero
-- Counts elements that are not zero
do
  -- countNonZero() is a compact way to count active flags.
  -- A board game can count occupied cells without looping in Lua.
  local occupied = lurek.compute.fromTable({0, 1, 0, 1, 1, 0}, nil, "int32")
  local occupied_count = occupied:countNonZero()

  lurek.log.info("occupied tile count=" .. occupied_count, "tiles")
end
--@api-stub: LArray:argmin
-- Finds the flat index of the smallest value
do
  -- argmin() returns a one-based flat index, matching Lua table indexing.
  -- AI steering can use this to pick the nearest candidate.
  local distances = lurek.compute.fromTable({12, 4, 9, 7})
  local nearest_index = distances:argmin()

  lurek.log.info("nearest target index=" .. nearest_index, "ai")
end
--@api-stub: LArray:argmax
-- Finds the flat index of the largest value
do
  -- argmax() returns a one-based flat index for the strongest value.
  -- Utility AI can use it to choose the best scored action.
  local action_scores = lurek.compute.fromTable({0.2, 0.5, 0.9, 0.4})
  local action_index = action_scores:argmax()

  lurek.log.info("chosen action index=" .. action_index, "ai")
end
--@api-stub: LArray:any
-- Tests whether at least one element is active
do
  -- any() answers existence questions without counting every active value in Lua.
  -- Collision or trigger systems often need this yes/no result.
  local collision_flags = lurek.compute.fromTable({0, 0, 1, 0}, nil, "int32")

  if collision_flags:any() then
    lurek.log.warn("collision flag detected", "physics")
  end
end
--@api-stub: LArray:all
-- Tests whether every element is active
do
  -- all() is a natural fit for completion checks.
  -- For a puzzle room, every pressure plate must be active before the door opens.
  local pressure_plates = lurek.compute.fromTable({1, 1, 1, 1}, nil, "int32")

  if pressure_plates:all() then
    lurek.log.info("all plates active", "puzzle")
  end
end
--@api-stub: LArray:sum
-- Adds values across the array or one axis
do
  -- sum() with no argument returns one number.
  -- sum(axis) returns an LArray reduced along the one-based axis.
  local damage_grid = lurek.compute.fromTable({
    3, 1, 4,
    1, 5, 9,
  }, {2, 3})
  local total_damage = damage_grid:sum()
  local row_totals = damage_grid:sum(2)

  lurek.log.info("damage total=" .. total_damage .. " first row=" .. row_totals:get(1), "combat")
end
--@api-stub: LArray:mean
-- Averages values across the array or one axis
do
  -- mean() gives a scalar average when called without an axis.
  -- Frame pacing and AI utility scoring both benefit from simple averages.
  local frame_ms = lurek.compute.fromTable({16.1, 16.7, 17.2, 16.9, 16.4})
  local average_frame_ms = frame_ms:mean()

  lurek.log.info("average frame ms=" .. average_frame_ms, "perf")
end
--@api-stub: LArray:min
-- Finds the smallest value globally or along one axis
do
  -- min() returns the smallest scalar value when no axis is supplied.
  -- Pathfinding tools can use it to find the cheapest candidate cost.
  local path_costs = lurek.compute.fromTable({7, 3, 9, 4})
  local cheapest_cost = path_costs:min()

  lurek.log.info("cheapest path cost=" .. cheapest_cost, "ai")
end
--@api-stub: LArray:max
-- Finds the largest value globally or along one axis
do
  -- max() returns the largest scalar value when no axis is supplied.
  -- HUD code can use it for peak damage, highest score, or worst latency.
  local damage_rolls = lurek.compute.fromTable({12, 30, 18, 25})
  local peak_damage = damage_rolls:max()

  lurek.log.info("peak damage=" .. peak_damage, "combat")
end
--@api-stub: LArray:matmul
-- Performs matrix multiplication with another 2D array
do
  -- matmul(other) computes the standard matrix product (A * B).
  -- Both arrays must be 2D with compatible inner dimensions.
  -- Use for chaining transforms, neural network layers, or physics Jacobians.
  local a = lurek.compute.fromTable({1, 2, 3, 4}, {2, 2})
  local b = lurek.compute.fromTable({5, 6, 7, 8}, {2, 2})
  local c = a:matmul(b)

  -- c[1,1] = 1*5 + 2*7 = 19
  lurek.log.info("c[1,1] = " .. c:get(1, 1), "compute")
end
--@api-stub: LArray:dot
-- Computes the dot product with another 1D array
do
  -- dot(other) computes the scalar dot product of two vectors.
  -- Use for angle checks: dot > 0 means vectors point roughly the same way.
  local heading = lurek.compute.fromTable({1, 0})  -- facing right
  local target = lurek.compute.fromTable({0.7, 0.7})  -- 45 degrees
  local alignment = heading:dot(target)

  -- alignment = 0.7, meaning target is mostly in front
  lurek.log.info("alignment: " .. alignment, "ai")
end
--@api-stub: LArray:bitwiseAnd
-- Returns element-wise bitwise AND with another int32 array
do
  -- bitwiseAnd(other) combines bit flags between two mask arrays.
  -- Both arrays must be int32. Use to intersect tile property layers.
  local walk = lurek.compute.fromTable({1, 1, 0, 1}, nil, "int32") -- walkable mask
  local lit  = lurek.compute.fromTable({1, 0, 1, 1}, nil, "int32") -- illuminated mask

  -- AND finds tiles that are BOTH walkable AND illuminated
  local both = walk:bitwiseAnd(lit)
  lurek.log.info("walkable AND lit count: " .. both:countNonZero(), "tiles")
end
--@api-stub: LArray:bitwiseOr
-- Returns element-wise bitwise OR with another int32 array
do
  -- bitwiseOr(other) merges bit flags. Use to combine visibility layers.
  local fov  = lurek.compute.fromTable({1, 0, 0, 1}, nil, "int32") -- current FOV
  local mem  = lurek.compute.fromTable({0, 1, 0, 0}, nil, "int32") -- remembered tiles

  -- OR creates the "ever seen" map for minimap rendering
  local seen = fov:bitwiseOr(mem)
  lurek.log.info("seen-tile count: " .. seen:countNonZero(), "fov")
end
--@api-stub: LArray:bitwiseXor
-- Returns element-wise bitwise XOR with another int32 array
do
  -- bitwiseXor(other) finds bits that differ between frames.
  -- Use for dirty-region detection: which tiles changed since last frame?
  local prev = lurek.compute.fromTable({1, 0, 1, 1}, nil, "int32")
  local curr = lurek.compute.fromTable({1, 1, 1, 0}, nil, "int32")

  -- XOR marks cells that flipped state
  local changed = prev:bitwiseXor(curr)
  lurek.log.info("cells changed: " .. changed:countNonZero(), "tiles")
end
--@api-stub: LArray:bitwiseNot
-- Returns element-wise bitwise NOT of this int32 array
do
  -- bitwiseNot() inverts all bits. For simple 0/1 masks, this flips the mask.
  -- Use to get the complement: "free" tiles from an "occupied" mask.
  local occupied = lurek.compute.fromTable({1, 0, 0, 1}, nil, "int32")
  local free = occupied:bitwiseNot()
  lurek.log.info("free mask[2] = " .. free:get(2), "tiles")
end
--@api-stub: LArray:bitwiseLShift
-- Returns element-wise left bit shift by a given amount
do
  -- bitwiseLShift(amount) shifts each int32 element left.
  -- Use for packing tile data: combine type and variant into one int.
  local ids = lurek.compute.fromTable({1, 2, 3, 4}, nil, "int32")

  -- Shift left by 4 bits to make room for a variant nibble
  local packed = ids:bitwiseLShift(4)
  lurek.log.info("packed[2] = " .. packed:get(2), "compute")
end
--@api-stub: LArray:bitwiseRShift
-- Returns element-wise right bit shift by a given amount
do
  -- bitwiseRShift(amount) shifts each int32 element right.
  -- Use to extract packed fields from combined tile data.
  local packed = lurek.compute.fromTable({16, 32, 48, 64}, nil, "int32")

  -- Shift right by 4 to recover the original tile type IDs
  local high = packed:bitwiseRShift(4)
  lurek.log.info("high[3] = " .. high:get(3), "compute")
end
--@api-stub: LArray:convolve2D
-- Applies a 2D convolution kernel to this array
do
  -- convolve2D(kernel) slides a kernel over the 2D array.
  -- Use for blur, edge detect, sharpen, or custom spatial filters.
  -- The kernel must be a small 2D array (odd dimensions recommended).
  local img = lurek.compute.ones({8, 8})
  local k = lurek.compute.gaussianKernel(3, 0.8)

  -- Blurring a uniform image should preserve the mean
  local blurred = img:convolve2D(k)
  lurek.log.info("blurred mean = " .. blurred:mean(), "compute")
end
--@api-stub: LArray:dilate
-- Applies morphological dilation with a given radius
do
  -- dilate(radius) expands non-zero regions outward.
  -- Use to grow collision boundaries, expand influence zones,
  -- or create "buffer zones" around obstacles on a nav mesh.
  local mask = lurek.compute.zeros({5, 5})
  mask:set(3, 3, 1.0) -- single seed point

  -- Dilate by 1 cell: the seed grows into a 3x3 cross pattern
  local grown = mask:dilate(1)
  lurek.log.info("grown nonzero: " .. grown:countNonZero(), "compute")
end
--@api-stub: LArray:erode
-- Applies morphological erosion with a given radius
do
  -- erode(radius) shrinks non-zero regions inward.
  -- Use to find safe interior areas, remove thin noise features,
  -- or compute safe spawn zones away from walls.
  local mask = lurek.compute.ones({4, 4})

  -- Erode by 1: only the inner 2x2 survives
  local interior = mask:erode(1)
  lurek.log.info("interior cells: " .. interior:countNonZero(), "compute")
end
--@api-stub: LArray:cumsum
-- Returns the cumulative sum (prefix sum) of this array
do
  -- cumsum() computes running totals. Element i = sum of elements 1..i.
  -- Use for weighted random selection, score tracking, or integral images.
  local scores = lurek.compute.fromTable({1, 2, 3, 4})

  -- running = {1, 3, 6, 10}
  local running = scores:cumsum()
  lurek.log.info("score after 3rd round = " .. running:get(3), "score")
end
--@api-stub: LArray:diff
-- Returns finite differences (velocity from position, acceleration from velocity)
do
  -- diff(order?) computes element-to-element differences.
  -- Order 1 (default): velocity from position. Order 2: acceleration from position.
  -- Result is one element shorter per order applied.
  local pos = lurek.compute.fromTable({0, 1, 3, 6, 10})

  -- First difference gives velocity: {1, 2, 3, 4}
  local vel = pos:diff(1)
  lurek.log.info("vel[2] = " .. vel:get(2), "compute")
end
--@api-stub: LArray:percentile
-- Returns a percentile value from the array data
do
  -- percentile(p) finds the value below which p% of data falls.
  -- Use for performance monitoring: p95 frame time shows worst-case spikes.
  local times = lurek.compute.fromTable({16, 17, 18, 19, 33})

  -- 95th percentile: almost all frames are under this value
  local p95 = times:percentile(95)
  lurek.log.info("frame p95 = " .. p95 .. "ms", "perf")
end
--@api-stub: LArray:covariance
-- Computes covariance with another array
do
  -- covariance(other) measures how two variables change together.
  -- Positive = they increase together. Negative = one rises as other falls.
  -- Use for correlating game stats (e.g., player level vs. damage output).
  local x = lurek.compute.fromTable({1, 2, 3, 4})
  local y = lurek.compute.fromTable({2, 4, 6, 8}) -- perfectly correlated

  local cov = x:covariance(y)
  lurek.log.info("cov(x,y) = " .. cov, "compute")
end
--@api-stub: LArray:pearsonCorr
-- Computes Pearson correlation coefficient with another array
do
  -- pearsonCorr(other) returns a value in [-1, 1].
  -- +1 = perfect positive correlation, -1 = perfect negative, 0 = no relation.
  -- Use to detect relationships (fps vs entity count, score vs playtime).
  local fps = lurek.compute.fromTable({60, 58, 55, 50, 45})
  local entities = lurek.compute.fromTable({100, 150, 200, 280, 360})

  -- Expected: strong negative correlation (more entities = lower fps)
  local r = fps:pearsonCorr(entities)
  lurek.log.info("fps vs entity correlation: " .. r, "perf")
end
--@api-stub: LArray:normalizeRange
-- Returns values rescaled to a target [lo, hi] range
do
  -- normalizeRange(lo, hi) maps the array's min to lo and max to hi.
  -- Use for mapping raw sensor data to screen coordinates, or
  -- normalizing AI utility scores to [0, 1] for comparison.
  local raw = lurek.compute.fromTable({-2, 0, 2, 4})

  -- Map to unit range: -2 -> 0.0, 4 -> 1.0
  local unit = raw:normalizeRange(0, 1)
  lurek.log.info("unit min=" .. unit:min() .. " max=" .. unit:max(), "compute")
end
--@api-stub: LArray:zscore
-- Returns z-score normalized values (mean=0, std=1)
do
  -- zscore() standardizes data: (value - mean) / std_deviation.
  -- Use for comparing features on different scales in AI systems,
  -- or detecting outliers (|z| > 2 is unusual).
  local features = lurek.compute.fromTable({10, 12, 14, 18, 20})
  local z = features:zscore()

  -- First element is below mean, so z[1] should be negative
  lurek.log.info("z[1] = " .. z:get(1), "compute")
end
--@api-stub: LArray:convolve1d
-- Applies a 1D convolution kernel to this array
do
  -- convolve1d(kernel) slides a 1D kernel along the array.
  -- Use for smoothing time-series data, audio filtering, or 1D signal processing.
  local signal = lurek.compute.fromTable({0, 1, 0, 1, 0, 1, 0})

  -- Simple averaging kernel: [0.25, 0.5, 0.25]
  local kernel = lurek.compute.fromTable({0.25, 0.5, 0.25})
  local smoothed = signal:convolve1d(kernel)
  lurek.log.info("smoothed length: " .. smoothed:getSize(), "compute")
end
--@api-stub: LArray:correlate1d
-- Computes 1D cross-correlation with a template array
do
  -- correlate1d(template) measures how well the template matches at each position.
  -- Use for pattern matching: find where a known shape appears in a signal.
  local stream   = lurek.compute.fromTable({0, 1, 2, 3, 2, 1, 0})
  local template = lurek.compute.fromTable({1, 2, 3}) -- rising pattern

  -- argmax of the result tells you where the best match is
  local match = stream:correlate1d(template)
  lurek.log.info("best match index: " .. match:argmax(), "compute")
end
--@api-stub: LArray:normalizeVec
-- Returns this vector normalized to unit length
do
  -- normalizeVec() divides by the vector's magnitude so length becomes 1.
  -- Use for direction vectors: normalize velocity to get heading.
  local v = lurek.compute.fromTable({3, 4}) -- length = 5

  local unit = v:normalizeVec()
  -- unit[1]^2 + unit[2]^2 should equal 1.0
  lurek.log.info("unit[1]^2 + unit[2]^2 = " .. unit:pow(2):sum(), "compute")
end
--@api-stub: LArray:outer
-- Computes the outer product of two vectors (result is a matrix)
do
  -- outer(other) produces a matrix where result[i,j] = self[i] * other[j].
  -- Use for rank-1 updates, weight matrices, or constructing projection operators.
  local row = lurek.compute.fromTable({1, 2, 3})
  local col = lurek.compute.fromTable({1, 2})

  -- Result is a 3x2 matrix
  local mat = row:outer(col)
  lurek.log.info("outer[2,2] = " .. mat:get(2, 2), "compute")
end
--@api-stub: LArray:cross2d
-- Computes the 2D cross product (scalar) with another 2D vector
do
  -- cross2d(other) returns the z-component of the 3D cross product.
  -- Sign indicates turn direction: positive = counter-clockwise (left turn).
  -- Use for steering AI, winding-order checks, or left/right detection.
  local heading = lurek.compute.fromTable({1, 0}) -- facing right
  local target  = lurek.compute.fromTable({0, 1}) -- target is above

  local cross = heading:cross2d(target)
  -- cross > 0 means target is to the left of heading
  lurek.log.info("turn direction: " .. (cross > 0 and "left" or "right"), "ai")
end
--@api-stub: LArray:transformPoints
-- Transforms point rows by this matrix (rotation, affine, etc.)
do
  pcall(function()
    -- transformPoints(pts) applies this matrix to each row of the point array.
    -- Points are stored as rows: Nx2 array where each row is (x, y).
    -- The matrix can be 2x2 (rotation) or 3x3 (affine with translation).
    local rot = lurek.compute.rotate2dMatrix(math.pi / 2) -- 90-degree rotation
    local pts = lurek.compute.fromTable({1, 0, 0, 1}, {2, 2})

    local out = rot:transformPoints(pts)
    -- (1,0) rotated 90 degrees CCW = (0,1)
    lurek.log.info("rotated[1,2] = " .. out:get(1, 2), "compute")
  end)
end
--@api-stub: LArray:sobel
-- Computes Sobel edge-detection gradients (returns {gx, gy} table)
do
  -- sobel() returns a table with .gx and .gy gradient arrays.
  -- Magnitude = sqrt(gx^2 + gy^2) gives edge strength.
  -- Use for edge detection in heightmaps, outline rendering, or terrain normals.
  local img = lurek.compute.ones({4, 4})
  local g = img:sobel()
  lurek.log.info("gx[2,2] = " .. g.gx:get(2, 2) .. " gy[2,2] = " .. g.gy:get(2, 2), "compute")
end
--@api-stub: LArray:linsolve
-- Solves the linear system Ax = b for x
do
  -- linsolve(b) solves the equation self*x = b using LU decomposition.
  -- self must be a square NxN matrix, b must be an N-element vector.
  -- Use for physics constraint solving, inverse kinematics, or interpolation.
  local a = lurek.compute.fromTable({2, 1, 1, 3}, {2, 2})
  local b = lurek.compute.fromTable({5, 10})

  -- Solve: 2x + y = 5, x + 3y = 10 -> x=1, y=3
  local x = a:linsolve(b)
  lurek.log.info("x[1] = " .. x:get(1) .. " x[2] = " .. x:get(2), "compute")
end
--@api-stub: LArray:luDecompose
-- Returns LU decomposition data for this square matrix
do
  -- luDecompose() factorizes a square matrix into L and U factors.
  -- Returns a table with: n (size), det_sign (+1 or -1), perm (permutation), lu_data (flat LU values).
  -- Use for determinant computation or repeated solves with different right-hand sides.
  local a = lurek.compute.fromTable({4, 3, 6, 3}, {2, 2})
  local lu = a:luDecompose()
  lurek.log.info("LU n=" .. lu.n .. " det_sign=" .. lu.det_sign, "compute")
end
--@api-stub: LArray:type
-- Returns the Lua-visible type name string for this array handle
do
  -- type() returns the string "LArray" for any compute array.
  -- Use for runtime type checking when handling mixed userdata.
  local arr = lurek.compute.zeros({2})
  local kind = arr:type()
  if kind == "LArray" then lurek.log.debug("got an Array", "compute") end
end
--@api-stub: LArray:typeOf
-- Returns true if this array handle matches the given type name string
do
  -- typeOf(name) accepts "LArray", "Array", or "Object" â€” all return true.
  -- Use for duck-typing checks in utility functions that accept multiple types.
  local arr = lurek.compute.zeros({2})
  if arr:typeOf("Array") then
    lurek.log.debug("typeOf check passed", "compute")
  end
end
--@api-stub: LArray:map
-- Applies a Lua function to each element, returning a new array
do
  -- map(func) calls func(element) for every value and stores the result.
  -- Flexible but slower than built-in ops. Use for custom per-element logic
  -- that has no built-in equivalent (e.g., lookup tables, conditional transforms).
  local a = lurek.compute.fromTable({1, 4, 9})
  local b = a:map(function(x) return math.sqrt(x) end)
  lurek.log.debug("map sqrt: " .. tostring(b:toTable()[1]), "compute")
end
--@api-stub: LArray:eval
-- Evaluates a Lua expression string on each element (x = current value)
do
  -- eval(expr) compiles the expression once and applies it per element.
  -- The variable 'x' holds the current element value.
  -- Faster to write than map() for simple formulas; same performance.
  local a = lurek.compute.fromTable({1, 2, 3})
  local b = a:eval("x * x + 1") -- quadratic transform

  -- Element 2: 2*2+1 = 5
  lurek.log.debug("eval x^2+1: " .. tostring(b:toTable()[2]), "compute")
end
--@api-stub: LArray:reduce
-- Reduces all elements to a single value using an accumulator function
do
  -- reduce(func, init) folds left: acc = func(acc, element) for each element.
  -- Use for custom aggregations that sum/min/max can't express.
  local a = lurek.compute.fromTable({1, 2, 3, 4})
  local total = a:reduce(function(acc, x) return acc + x end, 0)

  -- Equivalent to a:sum(), but allows arbitrary fold logic
  lurek.log.debug("reduce sum: " .. tostring(total), "compute")
end
--@api-stub: LArray:scan
-- Produces a prefix-scan array using an accumulator function
do
  -- scan(func, init) is like reduce but keeps every intermediate accumulator value.
  -- Result has the same shape as the input.
  -- Use for prefix sums, running maxima, or streaming statistics.
  local a = lurek.compute.fromTable({1, 2, 3, 4})
  local prefix = a:scan(function(acc, x) return acc + x end, 0)

  -- prefix = {1, 3, 6, 10}
  lurek.log.debug("scan prefix[4]: " .. tostring(prefix:toTable()[4]), "compute")
end
--@api-stub: LArray:eigenPower
-- Estimates the dominant eigenvalue and eigenvector via power iteration
do
  -- eigenPower(max_iter?, tol?) finds the largest eigenvalue of a square matrix.
  -- Returns a table with .value (eigenvalue) and .vector (eigenvector table).
  -- Use for principal component analysis, stability checks, or vibration modes.
  local A = lurek.compute.fromTable({2, 1, 1, 2}, {2, 2}, "float32")

  -- Power iteration with up to 50 steps; default tolerance used
  local result = A:eigenPower(50)
  lurek.log.info("dominant eigenvalue: " .. result.value, "compute")
end
--@api-stub: LArray:floodFill
-- Fills connected cells from a start position with a replacement value
do
  -- floodFill(row, col, val) fills connected cells that share the same value
  -- as the starting cell. Returns a new array with the fill applied.
  -- Use for room detection, island counting, or paint-bucket tools.
  local grid = lurek.compute.zeros({8, 8}, "int32")
  grid:fill(1) -- fill everything with 1

  -- Place a 0-cell "wall" at (3,3) then flood from it
  grid:set(3, 3, 0)
  local filled = grid:floodFill(3, 3, 255)

  -- Only the single 0-cell at (3,3) gets filled since it's isolated
  lurek.log.info("filled[3,3] = " .. tostring(filled:get(3, 3)), "compute")
end
--@api-stub: LArray:getRegion
-- Extracts a rectangular sub-region from this 2D array
do
  -- getRegion(row, col, rows, cols) copies a rectangular patch.
  -- All coordinates are 1-based.
  -- Use for chunk-based terrain, viewport extraction, or tile atlas slicing.
  local a = lurek.compute.range(0, 64, 1, "int32"):reshape({8, 8})

  -- Extract a 4x4 patch starting at row 2, col 2
  local patch = a:getRegion(2, 2, 4, 4)
  lurek.log.info("patch shape: " .. patch:getShape()[1] .. "x" .. patch:getShape()[2], "compute")
end
--@api-stub: LArray:histogram
-- Computes a histogram of values across the given number of bins
do
  -- histogram(bins, lo?, hi?) groups values into bins and counts occurrences.
  -- Returns a table of bin entries with .lo, .hi, .count fields.
  -- Use for damage distribution analysis, terrain height profiling, or debug stats.
  local a = lurek.compute.fromTable({1, 2, 2, 3, 3, 3, 4, 4, 4, 4}, nil, "int32")

  -- Split into 4 bins across the data range
  local hist = a:histogram(4)
  lurek.log.info("hist bins: " .. #hist .. ", first count: " .. hist[1].count, "compute")
end
--@api-stub: LArray:setRegion
-- Writes a source array into this array at a given position (in place)
do
  -- setRegion(row, col, source) pastes a smaller array into this one.
  -- Use for stamping prefabs onto a world grid, compositing tile patches,
  -- or writing computed chunks back into a full map.
  local canvas = lurek.compute.zeros({16, 16}, "float32")
  local stamp = lurek.compute.ones({4, 4}, "float32")

  -- Paste the 4x4 stamp at position (6, 6) on the canvas
  canvas:setRegion(6, 6, stamp)
  lurek.log.info("canvas[7,7] after stamp = " .. canvas:get(7, 7), "compute")
end
--@api-stub: LArray:where
-- Selects values from this array or another based on a mask
do
  -- where(mask, other) picks from self where mask is non-zero,
  -- and from other where mask is zero.
  -- Use for conditional operations: apply damage only to enemies in range.
  local a = lurek.compute.fromTable({1, 2, 3, 4, 5, 6}, nil, "int32")

  -- Mask: only elements > 3 pass
  local mask = a:gt(3)

  -- Where mask is true, keep 'a'; where false, use zeros
  local zeros = lurek.compute.zeros({6}, "int32")
  local result = a:where(mask, zeros)
  lurek.log.info("where filtered sum: " .. result:sum(), "compute")
end
--@api-stub: LArray:add
-- Returns element-wise addition with an array or scalar
do
  -- add(value) adds either a scalar or another array element-wise.
  -- With an array argument, shapes must be compatible (broadcast supported for 1D->2D).
  local base = lurek.compute.fromTable({1, 2, 3, 4}, {2, 2})
  local boost = lurek.compute.fromTable({10, 20}, {2})

  -- Row broadcast: each row gets +10 and +20 added to its columns
  local out = base:add(boost)
  lurek.log.info("add row-broadcast [2,2] = " .. out:get(2, 2), "compute")
end
--@api-stub: LArray:sub
-- Returns element-wise subtraction with an array or scalar
do
  -- sub(value) subtracts a scalar or array.
  -- Use for applying flat damage reduction to a party's HP array.
  local hp = lurek.compute.fromTable({100, 80, 65})
  local after = hp:sub(15) -- 15 damage to all party members

  lurek.log.info("sub result first = " .. after:get(1), "compute")
end
--@api-stub: LArray:mul
-- Returns element-wise multiplication with an array or scalar
do
  -- mul(value) multiplies by a scalar or array.
  -- Use for applying damage multipliers, scaling physics forces, etc.
  local dmg = lurek.compute.fromTable({10, 12, 8})
  local crit = dmg:mul(1.5) -- 150% critical hit multiplier

  lurek.log.info("crit total = " .. crit:sum(), "compute")
end
--@api-stub: LArray:div
-- Returns element-wise division with an array or scalar
do
  -- div(value) divides by a scalar or array.
  -- Use for unit conversion, normalizing by frame count, etc.
  local ms = lurek.compute.fromTable({16, 20, 25, 33})
  local sec = ms:div(1000) -- convert milliseconds to seconds

  lurek.log.info("sec[1] = " .. sec:get(1), "compute")
end
--@api-stub: LArray:eq
-- Returns a mask array where elements equal the given value
do
  -- eq(value) returns 1 where elements match, 0 elsewhere.
  -- Use for finding specific tile types in a map grid.
  local tiles = lurek.compute.fromTable({0, 1, 2, 1, 0}, nil, "int32")

  -- Find all "wall" tiles (type 1)
  local walls = tiles:eq(1)
  lurek.log.info("wall count = " .. walls:countNonZero(), "compute")
end
--@api-stub: LArray:neq
-- Returns a mask array where elements do not equal the given value
do
  -- neq(value) is the inverse of eq(): 1 where elements differ from value.
  -- Use for "everything except" queries on tagged data.
  local tags = lurek.compute.fromTable({1, 2, 2, 3}, nil, "int32")
  local non_two = tags:neq(2)
  lurek.log.info("non-2 count = " .. non_two:countNonZero(), "compute")
end
--@api-stub: LArray:gt
-- Returns a mask array where elements are greater than the value
do
  -- gt(value) creates a binary mask for "above threshold" queries.
  -- Use for hot zones, danger areas, or quality-tier filtering.
  local heat = lurek.compute.fromTable({0.1, 0.6, 0.8, 0.2})
  local hot = heat:gt(0.5)
  lurek.log.info("hot cells = " .. hot:countNonZero(), "compute")
end
--@api-stub: LArray:lt
-- Returns a mask array where elements are less than the value
do
  -- lt(value) creates a binary mask for "below threshold" queries.
  -- Use for low-resource warnings, cooldown checks, etc.
  local stamina = lurek.compute.fromTable({40, 10, 25, 5})
  local low = stamina:lt(20)
  lurek.log.info("low stamina count = " .. low:countNonZero(), "compute")
end
--@api-stub: LArray:gte
-- Returns a mask array where elements are greater than or equal to the value
do
  -- gte(value) includes the boundary value in the mask.
  local dist = lurek.compute.fromTable({2, 5, 7, 9})
  local far = dist:gte(7)
  lurek.log.info("far targets = " .. far:countNonZero(), "compute")
end
--@api-stub: LArray:lte
-- Returns a mask array where elements are less than or equal to the value
do
  -- lte(value) includes the boundary value in the mask.
  local scores = lurek.compute.fromTable({100, 120, 95, 130})
  local under_cap = scores:lte(120)
  lurek.log.info("<=120 count = " .. under_cap:countNonZero(), "compute")
end
--@api-stub: LArray:addInplace
-- Adds another array into this array in place (mutates self)
do
  -- addInplace(other) modifies the array directly without allocating a new one.
  -- Use in hot loops where you accumulate forces, scores, or pixel values
  -- and want to avoid per-frame allocations.
  local a = lurek.compute.fromTable({1, 2, 3})
  local b = lurek.compute.fromTable({4, 5, 6})

  -- After this call, a = {5, 7, 9}. No new array is created.
  a:addInplace(b)
  lurek.log.info("addInplace result: " .. a:get(1) .. "," .. a:get(2) .. "," .. a:get(3), "compute")
end
--@api-stub: LArray:subInplace
-- Subtracts another array from this array in place (mutates self)
do
  -- subInplace(other) subtracts element-wise without allocation.
  -- Use for applying frame-by-frame decay, cooldown ticks, etc.
  local a = lurek.compute.fromTable({5, 5, 5})
  local b = lurek.compute.fromTable({1, 2, 3})

  -- After: a = {4, 3, 2}
  a:subInplace(b)
  lurek.log.info("subInplace result: " .. a:get(1) .. "," .. a:get(2) .. "," .. a:get(3), "compute")
end
--@api-stub: LArray:mulInplace
-- Multiplies this array by another array in place (mutates self)
do
  -- mulInplace(other) scales element-wise in place.
  -- Use for applying per-cell multipliers (e.g., resistance map * damage).
  local a = lurek.compute.fromTable({2, 3, 4})
  local b = lurek.compute.fromTable({5, 6, 7})

  -- After: a = {10, 18, 28}
  a:mulInplace(b)
  lurek.log.info("mulInplace result: " .. a:get(1) .. "," .. a:get(2) .. "," .. a:get(3), "compute")
end
--@api-stub: LArray:divInplace
-- Divides this array by another array in place (mutates self)
do
  -- divInplace(other) divides element-wise in place.
  -- Use for normalizing accumulated buffers by a count array.
  local a = lurek.compute.fromTable({8, 12, 16})
  local b = lurek.compute.fromTable({2, 3, 4})

  -- After: a = {4, 4, 4}
  a:divInplace(b)
  lurek.log.info("divInplace result: " .. a:get(1) .. "," .. a:get(2) .. "," .. a:get(3), "compute")
end
print("content/examples/compute.lua")
