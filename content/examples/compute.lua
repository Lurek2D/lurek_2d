-- content/examples/compute.lua
-- lurek.compute API examples.
-- Run: cargo run -- content/examples/compute.lua

--@api-stub: lurek.compute.newArray -- Creates a zero-filled array with the requested shape and data type
do -- lurek.compute.newArray
  local heat = lurek.compute.newArray({64, 64}, "float32")
  heat:set(1, 1, 1.0)
  heat:set(64, 64, 1.0)
  lurek.log.info("heat grid: " .. heat:getSize() .. " cells", "compute")
end

--@api-stub: lurek.compute.zeros -- Creates a zero-filled array with the requested shape and data type
do -- lurek.compute.zeros
  local damage = lurek.compute.zeros({3, 3})
  damage:set(2, 2, 25.0)
  local total = damage:sum()
  lurek.log.info("total damage: " .. total, "compute")
end

--@api-stub: lurek.compute.ones -- Creates a one-filled array with the requested shape and data type
do -- lurek.compute.ones
  local mask = lurek.compute.ones({8, 8})
  local faded = mask:clamp(0.0, 0.5)
  lurek.log.info("faded mean: " .. faded:mean(), "compute")
end

--@api-stub: lurek.compute.range -- Creates a one-dimensional range array
do -- lurek.compute.range
  local frames = lurek.compute.range(0, 10, 1)
  local doubled = frames:pow(2)
  lurek.log.info("frame[5]^2 = " .. doubled:get(6), "compute")
end

--@api-stub: lurek.compute.fromTable -- Creates an array from a flat Lua table and optional shape
do -- lurek.compute.fromTable
  local samples = {0.1, 0.2, 0.4, 0.8, 1.0, 0.8, 0.4}
  local wave = lurek.compute.fromTable(samples)
  local peak = wave:max()
  lurek.log.info("wave peak: " .. peak, "compute")
end

--@api-stub: lurek.compute.getParThreshold -- Returns the global compute parallelism threshold
do -- lurek.compute.getParThreshold
  local threshold = lurek.compute.getParThreshold()
  lurek.log.info("compute parallel threshold=" .. threshold, "compute")
end

--@api-stub: lurek.compute.setParThreshold -- Sets the global compute parallelism threshold and returns the previous value
do -- lurek.compute.setParThreshold
  local previous = lurek.compute.getParThreshold()
  lurek.compute.setParThreshold(1024)
  local updated = lurek.compute.getParThreshold()
  lurek.log.info("threshold " .. previous .. " -> " .. updated, "compute")
end

--@api-stub: lurek.compute.gaussianKernel -- Creates a square Gaussian kernel array
do -- lurek.compute.gaussianKernel
  local kernel = lurek.compute.gaussianKernel(5, 1.2)
  local weight_sum = kernel:sum()
  lurek.log.info("gaussian sum (should be approx 1.0): " .. weight_sum, "compute")
end

--@api-stub: lurek.compute.rotate2dMatrix -- Creates a 2D rotation matrix
do -- lurek.compute.rotate2dMatrix
  local angle = math.pi / 4
  local rot = lurek.compute.rotate2dMatrix(angle)
  local pts = lurek.compute.fromTable({1, 0, 0, 1}, {2, 2})
  local rotated = rot:transformPoints(pts)
  lurek.log.info("rotated[1,1] = " .. rotated:get(1, 1), "compute")
end

--@api-stub: lurek.compute.affine2d -- Creates a 2D affine transform matrix
do -- lurek.compute.affine2d
  local tx, ty = 100, 50
  local m = lurek.compute.affine2d(tx, ty, 0.0, 2.0, 2.0)
  local origin = lurek.compute.fromTable({0, 0}, {1, 2})
  local moved = m:transformPoints(origin)
  lurek.log.info("moved x = " .. moved:get(1, 1), "compute")
end

--@api-stub: lurek.compute.fft -- Computes the FFT of real-valued samples
do -- lurek.compute.fft
  local samples = {0.0, 1.0, 0.0, -1.0, 0.0, 1.0, 0.0, -1.0}
  local spectrum = lurek.compute.fft(samples)
  local bin0 = spectrum[1]
  lurek.log.info("bin 0 re=" .. bin0.re .. " im=" .. bin0.im, "fft")
end

--@api-stub: lurek.compute.ifft -- Computes the inverse FFT of complex frequency pairs
do -- lurek.compute.ifft
  local samples = {1.0, 0.5, 0.0, -0.5}
  local freqs = lurek.compute.fft(samples)
  local rebuilt = lurek.compute.ifft(freqs)
  lurek.log.info("rebuilt[1] = " .. rebuilt[1], "fft")
end

--@api-stub: lurek.compute.fftMagnitude -- Computes FFT magnitudes for real-valued samples
do -- lurek.compute.fftMagnitude
  local samples = {0.0, 1.0, 0.0, -1.0, 0.0, 1.0, 0.0, -1.0}
  local mags = lurek.compute.fftMagnitude(samples)
  lurek.log.info("mag[2] = " .. mags[2], "fft")
end

-- â”€â”€ Array methods â”€â”€

--@api-stub: Array:getShape
do -- Array:getShape
  local grid = lurek.compute.zeros({4, 6})
  local shape = grid:getShape()
  lurek.log.info("grid is " .. shape[1] .. "x" .. shape[2], "compute")
end

--@api-stub: Array:getDimensions
do -- Array:getDimensions
  local v = lurek.compute.range(0, 5)
  if v:getDimensions() == 1 then
    lurek.log.info("vector, len=" .. v:getSize(), "compute")
  end
end

--@api-stub: Array:getSize
do -- Array:getSize
  local img = lurek.compute.zeros({16, 16})
  local n = img:getSize()
  lurek.log.info("img has " .. n .. " pixels", "compute")
end

--@api-stub: Array:getDataType
do -- Array:getDataType
  local mask = lurek.compute.zeros({8}, "int32")
  local dt = mask:getDataType()
  if dt == "int32" then lurek.log.info("ready for bitwise ops", "compute") end
end

--@api-stub: Array:isOnGPU
do -- Array:isOnGPU
  local arr = lurek.compute.zeros({4})
  if not arr:isOnGPU() then
    lurek.log.debug("running compute on CPU", "compute")
  end
end

--@api-stub: Array:get
do -- Array:get
  pcall(function()
    local m = lurek.compute.fromTable({1, 2, 3, 4}, {2, 2})
    local top_right = m:get(1, 2)
    lurek.log.info("m[1,2] = " .. top_right, "compute")
  end)
end

--@api-stub: Array:set
do -- Array:set
  local board = lurek.compute.zeros({3, 3})
  board:set(2, 2, 1.0)
  lurek.log.info("centre = " .. board:get(2, 2), "compute")
end

--@api-stub: Array:toTable
do -- Array:toTable
  local arr = lurek.compute.range(0, 4)
  local flat = arr:toTable()
  lurek.log.info("flat[3] = " .. flat[3] .. ", count=" .. #flat, "compute")
end

--@api-stub: Array:reshape
do -- Array:reshape
  local row = lurek.compute.range(0, 6)
  local grid = row:reshape({2, 3})
  lurek.log.info("grid[2,3] = " .. grid:get(2, 3), "compute")
end

--@api-stub: Array:clone
do -- Array:clone
  local original = lurek.compute.ones({4})
  local copy = original:clone()
  copy:fill(0.0)
  lurek.log.info("orig sum=" .. original:sum() .. " copy sum=" .. copy:sum(), "compute")
end

--@api-stub: Array:transpose
do -- Array:transpose
  local m = lurek.compute.fromTable({1, 2, 3, 4, 5, 6}, {2, 3})
  local t = m:transpose()
  lurek.log.info("t shape: " .. t:getShape()[1] .. "x" .. t:getShape()[2], "compute")
end

--@api-stub: Array:fill
do -- Array:fill
  local scratch = lurek.compute.zeros({32, 32})
  scratch:fill(-1.0)
  lurek.log.info("scratch sum after fill: " .. scratch:sum(), "compute")
end

--@api-stub: Array:pow
do -- Array:pow
  local v = lurek.compute.fromTable({1, 2, 3, 4})
  local sq = v:pow(2)
  lurek.log.info("4^2 = " .. sq:get(4), "compute")
end

--@api-stub: Array:sqrt
do -- Array:sqrt
  local sq = lurek.compute.fromTable({1, 4, 9, 16})
  local roots = sq:sqrt()
  lurek.log.info("sqrt(16) = " .. roots:get(4), "compute")
end

--@api-stub: Array:abs
do -- Array:abs
  local deltas = lurek.compute.fromTable({-3, 1, -2, 4})
  local mag = deltas:abs()
  lurek.log.info("abs sum = " .. mag:sum(), "compute")
end

--@api-stub: Array:neg
do -- Array:neg
  local impulse = lurek.compute.fromTable({2, -1, 4})
  local counter = impulse:neg()
  lurek.log.info("counter[1] = " .. counter:get(1), "compute")
end

--@api-stub: Array:clamp
do -- Array:clamp
  local hp = lurek.compute.fromTable({120, -5, 75, 200})
  local clamped = hp:clamp(0, 100)
  lurek.log.info("clamped max = " .. clamped:max(), "compute")
end

--@api-stub: Array:threshold
do -- Array:threshold
  local field = lurek.compute.range(0, 8)
  local visible = field:threshold(4.0)
  lurek.log.info("cells visible: " .. visible:sum(), "compute")
end

--@api-stub: Array:countNonZero
do -- Array:countNonZero
  local occupied = lurek.compute.fromTable({0, 1, 0, 1, 1, 0})
  local live = occupied:countNonZero()
  lurek.log.info("occupied tiles: " .. live, "compute")
end

--@api-stub: Array:argmin
do -- Array:argmin
  local distances = lurek.compute.fromTable({12, 4, 9, 7})
  local nearest = distances:argmin()
  lurek.log.info("nearest enemy index: " .. nearest, "ai")
end

--@api-stub: Array:argmax
do -- Array:argmax
  local scores = lurek.compute.fromTable({0.2, 0.5, 0.9, 0.4})
  local choice = scores:argmax()
  lurek.log.info("AI picks action " .. choice, "ai")
end

--@api-stub: Array:any
do -- Array:any
  local hits = lurek.compute.fromTable({0, 0, 1, 0})
  if hits:any() then
    lurek.log.warn("at least one hit registered", "combat")
  end
end

--@api-stub: Array:all
do -- Array:all
  local switches = lurek.compute.fromTable({1, 1, 1, 1})
  if switches:all() then
    lurek.log.info("door unlocked", "puzzle")
  end
end

--@api-stub: Array:sum
do -- Array:sum
  local hits = lurek.compute.fromTable({3, 1, 4, 1, 5, 9})
  local total = hits:sum()
  lurek.log.info("total damage: " .. total, "compute")
end

--@api-stub: Array:mean
do -- Array:mean
  local frame_ms = lurek.compute.fromTable({16.1, 16.7, 17.2, 16.9, 16.4})
  local avg = frame_ms:mean()
  lurek.log.info("avg frame ms: " .. avg, "perf")
end

--@api-stub: Array:min
do -- Array:min
  local costs = lurek.compute.fromTable({7, 3, 9, 4})
  local cheapest = costs:min()
  lurek.log.info("cheapest cost: " .. cheapest, "compute")
end

--@api-stub: Array:max
do -- Array:max
  local latencies = lurek.compute.fromTable({12, 30, 18, 25})
  local worst = latencies:max()
  lurek.log.info("worst latency: " .. worst .. "ms", "net")
end

--@api-stub: Array:matmul
do -- Array:matmul
  local a = lurek.compute.fromTable({1, 2, 3, 4}, {2, 2})
  local b = lurek.compute.fromTable({5, 6, 7, 8}, {2, 2})
  local c = a:matmul(b)
  lurek.log.info("c[1,1] = " .. c:get(1, 1), "compute")
end

--@api-stub: Array:dot
do -- Array:dot
  local heading = lurek.compute.fromTable({1, 0})
  local target = lurek.compute.fromTable({0.7, 0.7})
  local alignment = heading:dot(target)
  lurek.log.info("alignment: " .. alignment, "ai")
end

--@api-stub: Array:bitwiseAnd
do -- Array:bitwiseAnd
  local walk = lurek.compute.fromTable({1, 1, 0, 1}, nil, "int32")
  local lit  = lurek.compute.fromTable({1, 0, 1, 1}, nil, "int32")
  local both = walk:bitwiseAnd(lit)
  lurek.log.info("walkable AND lit count: " .. both:countNonZero(), "tiles")
end

--@api-stub: Array:bitwiseOr
do -- Array:bitwiseOr
  local fov  = lurek.compute.fromTable({1, 0, 0, 1}, nil, "int32")
  local mem  = lurek.compute.fromTable({0, 1, 0, 0}, nil, "int32")
  local seen = fov:bitwiseOr(mem)
  lurek.log.info("seen-tile count: " .. seen:countNonZero(), "fov")
end

--@api-stub: Array:bitwiseXor
do -- Array:bitwiseXor
  local prev = lurek.compute.fromTable({1, 0, 1, 1}, nil, "int32")
  local curr = lurek.compute.fromTable({1, 1, 1, 0}, nil, "int32")
  local changed = prev:bitwiseXor(curr)
  lurek.log.info("cells changed: " .. changed:countNonZero(), "tiles")
end

--@api-stub: Array:bitwiseNot
do -- Array:bitwiseNot
  local occupied = lurek.compute.fromTable({1, 0, 0, 1}, nil, "int32")
  local free = occupied:bitwiseNot()
  lurek.log.info("free mask[2] = " .. free:get(2), "tiles")
end

--@api-stub: Array:bitwiseLShift
do -- Array:bitwiseLShift
  local ids = lurek.compute.fromTable({1, 2, 3, 4}, nil, "int32")
  local packed = ids:bitwiseLShift(4)
  lurek.log.info("packed[2] = " .. packed:get(2), "compute")
end

--@api-stub: Array:bitwiseRShift
do -- Array:bitwiseRShift
  local packed = lurek.compute.fromTable({16, 32, 48, 64}, nil, "int32")
  local high = packed:bitwiseRShift(4)
  lurek.log.info("high[3] = " .. high:get(3), "compute")
end

--@api-stub: Array:convolve2D
do -- Array:convolve2D
  local img = lurek.compute.ones({8, 8})
  local k = lurek.compute.gaussianKernel(3, 0.8)
  local blurred = img:convolve2D(k)
  lurek.log.info("blurred mean = " .. blurred:mean(), "compute")
end

--@api-stub: Array:dilate
do -- Array:dilate
  local mask = lurek.compute.zeros({5, 5})
  mask:set(3, 3, 1.0)
  local grown = mask:dilate(1)
  lurek.log.info("grown nonzero: " .. grown:countNonZero(), "compute")
end

--@api-stub: Array:erode
do -- Array:erode
  local mask = lurek.compute.ones({4, 4})
  local interior = mask:erode(1)
  lurek.log.info("interior cells: " .. interior:countNonZero(), "compute")
end

--@api-stub: Array:cumsum
do -- Array:cumsum
  local scores = lurek.compute.fromTable({1, 2, 3, 4})
  local running = scores:cumsum()
  lurek.log.info("score after 3rd round = " .. running:get(3), "score")
end

--@api-stub: Array:diff
do -- Array:diff
  local pos = lurek.compute.fromTable({0, 1, 3, 6, 10})
  local vel = pos:diff(1)
  lurek.log.info("vel[2] = " .. vel:get(2), "compute")
end

--@api-stub: Array:percentile
do -- Array:percentile
  local times = lurek.compute.fromTable({16, 17, 18, 19, 33})
  local p95 = times:percentile(95)
  lurek.log.info("frame p95 = " .. p95 .. "ms", "perf")
end

--@api-stub: Array:covariance
do -- Array:covariance
  local x = lurek.compute.fromTable({1, 2, 3, 4})
  local y = lurek.compute.fromTable({2, 4, 6, 8})
  local cov = x:covariance(y)
  lurek.log.info("cov(x,y) = " .. cov, "compute")
end

--@api-stub: Array:pearsonCorr
do -- Array:pearsonCorr
  local fps = lurek.compute.fromTable({60, 58, 55, 50, 45})
  local entities = lurek.compute.fromTable({100, 150, 200, 280, 360})
  local r = fps:pearsonCorr(entities)
  lurek.log.info("fps vs entity correlation: " .. r, "perf")
end

--@api-stub: Array:normalizeRange
do -- Array:normalizeRange
  local raw = lurek.compute.fromTable({-2, 0, 2, 4})
  local unit = raw:normalizeRange(0, 1)
  lurek.log.info("unit min=" .. unit:min() .. " max=" .. unit:max(), "compute")
end

--@api-stub: Array:zscore
do -- Array:zscore
  local features = lurek.compute.fromTable({10, 12, 14, 18, 20})
  local z = features:zscore()
  lurek.log.info("z[1] = " .. z:get(1), "compute")
end

--@api-stub: Array:convolve1d
do -- Array:convolve1d
  local signal = lurek.compute.fromTable({0, 1, 0, 1, 0, 1, 0})
  local kernel = lurek.compute.fromTable({0.25, 0.5, 0.25})
  local smoothed = signal:convolve1d(kernel)
  lurek.log.info("smoothed length: " .. smoothed:getSize(), "compute")
end

--@api-stub: Array:correlate1d
do -- Array:correlate1d
  local stream   = lurek.compute.fromTable({0, 1, 2, 3, 2, 1, 0})
  local template = lurek.compute.fromTable({1, 2, 3})
  local match    = stream:correlate1d(template)
  lurek.log.info("best match index: " .. match:argmax(), "compute")
end

--@api-stub: Array:normalizeVec
do -- Array:normalizeVec
  local v = lurek.compute.fromTable({3, 4})
  local unit = v:normalizeVec()
  lurek.log.info("unit[1]^2 + unit[2]^2 = " .. unit:pow(2):sum(), "compute")
end

--@api-stub: Array:outer
do -- Array:outer
  local row = lurek.compute.fromTable({1, 2, 3})
  local col = lurek.compute.fromTable({1, 2})
  local mat = row:outer(col)
  lurek.log.info("outer[2,2] = " .. mat:get(2, 2), "compute")
end

--@api-stub: Array:cross2d
do -- Array:cross2d
  local heading = lurek.compute.fromTable({1, 0})
  local target  = lurek.compute.fromTable({0, 1})
  local cross   = heading:cross2d(target)
  lurek.log.info("turn direction: " .. (cross > 0 and "left" or "right"), "ai")
end

--@api-stub: Array:transformPoints
do -- Array:transformPoints
  pcall(function()
    local rot = lurek.compute.rotate2dMatrix(math.pi / 2)
    local pts = lurek.compute.fromTable({1, 0, 0, 1}, {2, 2})
    local out = rot:transformPoints(pts)
    lurek.log.info("rotated[1,2] = " .. out:get(1, 2), "compute")
  end)
end

--@api-stub: Array:sobel
do -- Array:sobel
  local img = lurek.compute.ones({4, 4})
  local g = img:sobel()
  lurek.log.info("gx[2,2] = " .. g.gx:get(2, 2) .. " gy[2,2] = " .. g.gy:get(2, 2), "compute")
end

--@api-stub: Array:linsolve
do -- Array:linsolve
  local a = lurek.compute.fromTable({2, 1, 1, 3}, {2, 2})
  local b = lurek.compute.fromTable({5, 10})
  local x = a:linsolve(b)
  lurek.log.info("x[1] = " .. x:get(1) .. " x[2] = " .. x:get(2), "compute")
end

--@api-stub: Array:luDecompose
do -- Array:luDecompose
  local a = lurek.compute.fromTable({4, 3, 6, 3}, {2, 2})
  local lu = a:luDecompose()
  lurek.log.info("LU n=" .. lu.n .. " det_sign=" .. lu.det_sign, "compute")
end

--@api-stub: Array:type
do -- Array:type
  local arr = lurek.compute.zeros({2})
  local kind = arr:type()
  if kind == "Array" then lurek.log.debug("got an Array", "compute") end
end

--@api-stub: Array:typeOf
do -- Array:typeOf
  local arr = lurek.compute.zeros({2})
  if arr:typeOf("Array") then
    lurek.log.debug("typeOf check passed", "compute")
  end
end

--@api-stub: Array:map
do -- Array:map
  local a = lurek.compute.fromTable({1, 4, 9})
  local b = a:map(function(x) return math.sqrt(x) end)
  lurek.log.debug("map sqrt: " .. tostring(b:toTable()[1]), "compute")
end

--@api-stub: Array:eval
do -- Array:eval
  local a = lurek.compute.fromTable({1, 2, 3})
  local b = a:eval("x * x + 1")
  lurek.log.debug("eval x^2+1: " .. tostring(b:toTable()[2]), "compute")
end

--@api-stub: Array:reduce
do -- Array:reduce
  local a = lurek.compute.fromTable({1, 2, 3, 4})
  local total = a:reduce(function(acc, x) return acc + x end, 0)
  lurek.log.debug("reduce sum: " .. tostring(total), "compute")
end

--@api-stub: Array:scan
do -- Array:scan
  local a = lurek.compute.fromTable({1, 2, 3, 4})
  local prefix = a:scan(function(acc, x) return acc + x end, 0)
  lurek.log.debug("scan prefix[4]: " .. tostring(prefix:toTable()[4]), "compute")
end


--@api-stub: Array:eigenPower
do -- Array:eigenPower
  local A = lurek.compute.fromTable({2,1,1,2}, {2,2}, "float32")
  local result = A:eigenPower(50)
  lurek.log.info("dominant eigenvalue: " .. result.value, "compute")
end

--@api-stub: Array:floodFill
do -- Array:floodFill
  local grid = lurek.compute.zeros({8,8}, "int32")
  grid:fill(1)
  grid:set(3, 3, 0)
  local n = grid:floodFill(3, 3, 255)
  lurek.log.info("flood filled cells: " .. tostring(n), "compute")
end

--@api-stub: Array:getRegion
do -- Array:getRegion
  local a = lurek.compute.range(0, 64, 1, "int32"):reshape({8, 8})
  local patch = a:getRegion(2, 2, 5, 5)
  lurek.log.info("patch shape: " .. patch:getShape()[1] .. "x" .. patch:getShape()[2], "compute")
end

--@api-stub: Array:histogram
do -- Array:histogram
  local a = lurek.compute.fromTable({1,2,2,3,3,3,4,4,4,4}, nil, "int32")
  local hist = a:histogram(4)
  local ok_h, sz = pcall(function() return hist:len() end)
  if not ok_h then ok_h, sz = pcall(function() return hist:size() end) end
  lurek.log.info("hist bins: " .. tostring(ok_h and sz or "?"), "compute")
end

--@api-stub: Array:setRegion
do -- Array:setRegion
  local canvas = lurek.compute.zeros({16,16}, "float32")
  local stamp = lurek.compute.ones({4,4}, "float32")
  canvas:setRegion(6, 6, stamp)
  lurek.log.info("region set", "compute")
end

--@api-stub: Array:where
do -- Array:where
  local a = lurek.compute.fromTable({1,2,3,4,5,6}, nil, "int32")
  local mask = a:threshold(3)
  local result = a:where(mask, a)
  lurek.log.info("where size: " .. result:getSize(), "compute")
end

--@api-stub: Array:add
do -- Array:add
  local base = lurek.compute.fromTable({1, 2, 3, 4}, {2, 2})
  local boost = lurek.compute.fromTable({10, 20}, {2})
  local out = base:add(boost) -- row broadcast
  lurek.log.info("add row-broadcast [2,2] = " .. out:get(2, 2), "compute")
end

--@api-stub: Array:sub
do -- Array:sub
  local hp = lurek.compute.fromTable({100, 80, 65})
  local after = hp:sub(15)
  lurek.log.info("sub result first = " .. after:get(1), "compute")
end

--@api-stub: Array:mul
do -- Array:mul
  local dmg = lurek.compute.fromTable({10, 12, 8})
  local crit = dmg:mul(1.5)
  lurek.log.info("crit total = " .. crit:sum(), "compute")
end

--@api-stub: Array:div
do -- Array:div
  local ms = lurek.compute.fromTable({16, 20, 25, 33})
  local sec = ms:div(1000)
  lurek.log.info("sec[1] = " .. sec:get(1), "compute")
end

--@api-stub: Array:eq
do -- Array:eq
  local tiles = lurek.compute.fromTable({0, 1, 2, 1, 0}, nil, "int32")
  local walls = tiles:eq(1)
  lurek.log.info("wall count = " .. walls:countNonZero(), "compute")
end

--@api-stub: Array:neq
do -- Array:neq
  local tags = lurek.compute.fromTable({1, 2, 2, 3}, nil, "int32")
  local non_two = tags:neq(2)
  lurek.log.info("non-2 count = " .. non_two:countNonZero(), "compute")
end

--@api-stub: Array:gt
do -- Array:gt
  local heat = lurek.compute.fromTable({0.1, 0.6, 0.8, 0.2})
  local hot = heat:gt(0.5)
  lurek.log.info("hot cells = " .. hot:countNonZero(), "compute")
end

--@api-stub: Array:lt
do -- Array:lt
  local stamina = lurek.compute.fromTable({40, 10, 25, 5})
  local low = stamina:lt(20)
  lurek.log.info("low stamina count = " .. low:countNonZero(), "compute")
end

--@api-stub: Array:gte
do -- Array:gte
  local dist = lurek.compute.fromTable({2, 5, 7, 9})
  local far = dist:gte(7)
  lurek.log.info("far targets = " .. far:countNonZero(), "compute")
end

--@api-stub: Array:lte
do -- Array:lte
  local scores = lurek.compute.fromTable({100, 120, 95, 130})
  local under_cap = scores:lte(120)
  lurek.log.info("<=120 count = " .. under_cap:countNonZero(), "compute")
end

--@api-stub: LArray:addInplace -- Adds another array into this array in place
do -- LArray:addInplace
  local a = lurek.compute.fromTable({1, 2, 3})
  local b = lurek.compute.fromTable({4, 5, 6})
  a:addInplace(b)
end

--@api-stub: LArray:subInplace -- Subtracts another array from this array in place
do -- LArray:subInplace
  local a = lurek.compute.fromTable({5, 5, 5})
  local b = lurek.compute.fromTable({1, 2, 3})
  a:subInplace(b)
end

--@api-stub: LArray:mulInplace -- Multiplies this array by another array in place
do -- LArray:mulInplace
  local a = lurek.compute.fromTable({2, 3, 4})
  local b = lurek.compute.fromTable({5, 6, 7})
  a:mulInplace(b)
end

--@api-stub: LArray:divInplace -- Divides this array by another array in place
do -- LArray:divInplace
  local a = lurek.compute.fromTable({8, 12, 16})
  local b = lurek.compute.fromTable({2, 3, 4})
  a:divInplace(b)
end
