-- content/examples/compute.lua
-- Auto-generated from content/examples2/compute_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/compute.lua

local function compute_log(message)
    lurek.log.info("[compute] " .. message)
end

local function shape_text(array)
    local shape = array:getShape()
    local parts = {}
    for i = 1, #shape do
        parts[i] = tostring(shape[i])
    end
    return table.concat(parts, "x")
end

--- Compute Module Part 1: Array Creation, Element Access, Shape, Arithmetic, Comparisons

--@api: lurek.compute.newArray
do
    local spawn_weights = lurek.compute.newArray({4, 4}, "float32")
    spawn_weights:set(1, 1, 0.25)
    spawn_weights:set(4, 4, 0.75)
    local shape = shape_text(spawn_weights)
    compute_log("spawn weight grid=" .. shape .. " corners=" .. spawn_weights:get(1, 1) .. "/" .. spawn_weights:get(4, 4))
end

--@api: lurek.compute.zeros
do
    local occupancy = lurek.compute.zeros({3, 3})
    occupancy:set(2, 2, 1)
    local shape = shape_text(occupancy)
    local center = occupancy:get(2, 2)
    compute_log("empty occupancy map=" .. shape .. " center=" .. center)
end

--@api: lurek.compute.ones
do
    local flood_mask = lurek.compute.ones({2, 5}, "float32")
    local total = flood_mask:sum()
    local shape = shape_text(flood_mask)
    local edge = flood_mask:get(1, 5)
    compute_log("full flood mask=" .. shape .. " sum=" .. total .. " edge=" .. edge)
end

--@api: lurek.compute.range
do
    local frame_marks = lurek.compute.range(0, 10, 2, "float32")
    local shape = shape_text(frame_marks)
    local total = frame_marks:getSize()
    local last = frame_marks:get(total)
    compute_log("frame checkpoints shape=" .. shape .. " count=" .. total .. " last=" .. last)
end

--@api: lurek.compute.fromTable
do
    local loot_table = lurek.compute.fromTable({5, 8, 13, 21, 34, 55}, {2, 3})
    local shape = shape_text(loot_table)
    local rare_slot = loot_table:get(2, 2)
    local boss_slot = loot_table:get(2, 3)
    compute_log("loot matrix=" .. shape .. " rare=" .. rare_slot .. " boss=" .. boss_slot)
end

--@api: lurek.compute.gaussianKernel
do
    local blur_kernel = lurek.compute.gaussianKernel(5, 1.0)
    local center = blur_kernel:get(3, 3)
    local total = blur_kernel:sum()
    local shape = shape_text(blur_kernel)
    compute_log("blur kernel=" .. shape .. " center=" .. center .. " sum=" .. total)
end

--@api: lurek.compute.rotate2dMatrix
do
    local facing_turn = lurek.compute.rotate2dMatrix(math.pi / 4)
    local row_x = facing_turn:get(1, 1)
    local row_y = facing_turn:get(1, 2)
    local shape = shape_text(facing_turn)
    compute_log("45 degree facing matrix=" .. shape .. " row=(" .. row_x .. "," .. row_y .. ")")
end

--@api: lurek.compute.affine2d
do
    local camera_move = lurek.compute.affine2d(10, 20, 0, 1, 1)
    local point = lurek.compute.fromTable({0, 0}, {1, 2})
    local moved = camera_move:transformPoints(point)
    local tx = moved:get(1, 1)
    compute_log("camera transform moved x from 0 to " .. tx .. " with tx=" .. camera_move:get(1, 3))
end

--@api: lurek.compute.fft
do
    local samples = {1, 0, -1, 0}
    local spectrum = lurek.compute.fft(samples)
    local bin = spectrum[2]
    local magnitude = math.abs(bin.re) + math.abs(bin.im)
    compute_log("looped pulse fft bins=" .. #spectrum .. " bin2_energy=" .. tostring(magnitude))
end

--@api: lurek.compute.ifft
do
    local original = {1, 0, -1, 0}
    local spectrum = lurek.compute.fft(original)
    local rebuilt = lurek.compute.ifft(spectrum)
    local first = rebuilt[1]
    local drift = math.abs(first - original[1])
    compute_log("ifft rebuilt " .. #rebuilt .. " samples with first_sample_drift=" .. tostring(drift))
end

--@api: lurek.compute.fftMagnitude
do
    local samples = {1, 0, -1, 0}
    local magnitudes = lurek.compute.fftMagnitude(samples)
    local peak = math.max(magnitudes[1], magnitudes[2], magnitudes[3], magnitudes[4])
    local dc = magnitudes[1]
    compute_log("fft magnitudes count=" .. #magnitudes .. " peak=" .. tostring(peak) .. " dc=" .. tostring(dc))
end

--@api: lurek.compute.getParThreshold
do
    local threshold = lurek.compute.getParThreshold()
    local matrix = lurek.compute.newArray({32, 32})
    local size = matrix:getSize()
    local should_parallelize = size >= threshold
    compute_log("parallel threshold=" .. threshold .. " matrix_size=" .. size .. " parallel=" .. tostring(should_parallelize))
end

--@api: lurek.compute.setParThreshold
do
    local previous = lurek.compute.getParThreshold()
    local old_value = lurek.compute.setParThreshold(1024)
    local current = lurek.compute.getParThreshold()
    lurek.compute.setParThreshold(previous)
    compute_log("threshold changed from " .. old_value .. " to " .. current .. " and restored to " .. previous)
end

--@api: LArray:getShape
do
    local visibility = lurek.compute.newArray({3, 4})
    visibility:set(1, 1, 1)
    local shape = visibility:getShape()
    local shape_name = tostring(shape[1]) .. "x" .. tostring(shape[2])
    compute_log("visibility grid shape=" .. shape_name .. " first=" .. visibility:get(1, 1))
end

--@api: LArray:getDimensions
do
    local voxel_costs = lurek.compute.newArray({2, 3, 4})
    voxel_costs:set(2, 3, 4, 9)
    local dims = voxel_costs:getDimensions()
    local size = voxel_costs:getSize()
    compute_log("voxel cost tensor dims=" .. dims .. " size=" .. size .. " last=" .. voxel_costs:get(2, 3, 4))
end

--@api: LArray:getSize
do
    local chunk_cells = lurek.compute.newArray({5, 5})
    chunk_cells:set(3, 3, 7)
    local size = chunk_cells:getSize()
    local dims = chunk_cells:getDimensions()
    compute_log("chunk cell buffer size=" .. size .. " dims=" .. dims .. " center=" .. chunk_cells:get(3, 3))
end

--@api: LArray:getDataType
do
    local heat_values = lurek.compute.newArray({2, 2}, "float32")
    heat_values:set(1, 2, 0.5)
    local dtype = heat_values:getDataType()
    local shape = shape_text(heat_values)
    compute_log("heat grid dtype=" .. dtype .. " shape=" .. shape .. " probe=" .. heat_values:get(1, 2))
end

--@api: LArray:isOnGPU
do
    local nav_buffer = lurek.compute.ones({4, 4})
    nav_buffer:set(2, 3, 4)
    local on_gpu = nav_buffer:isOnGPU()
    local shape = shape_text(nav_buffer)
    compute_log("nav buffer shape=" .. shape .. " gpu_resident=" .. tostring(on_gpu))
end

--@api: LArray:get
do
    local damage_table = lurek.compute.fromTable({10, 20, 30, 40}, {2, 2})
    local melee = damage_table:get(1, 2)
    local ranged = damage_table:get(2, 1)
    local shape = shape_text(damage_table)
    compute_log("damage lookup from " .. shape .. " melee=" .. melee .. " ranged=" .. ranged)
end

--@api: LArray:set
do
    local threat_map = lurek.compute.zeros({3, 3})
    threat_map:set(2, 2, 99)
    threat_map:set(2, 3, 42)
    local center = threat_map:get(2, 2)
    compute_log("threat hotspot center=" .. center .. " east=" .. threat_map:get(2, 3))
end

--@api: LArray:toTable
do
    local patrol_route = lurek.compute.fromTable({1, 2, 3}, {3})
    local steps = patrol_route:toTable()
    local first = steps[1]
    local last = steps[#steps]
    compute_log("patrol route table length=" .. #steps .. " first=" .. first .. " last=" .. last)
end

--@api: LArray:reshape
do
    local encounter_stream = lurek.compute.fromTable({1, 2, 3, 4, 5, 6}, {6})
    local encounter_grid = encounter_stream:reshape({2, 3})
    local shape = shape_text(encounter_grid)
    local last = encounter_grid:get(2, 3)
    compute_log("reshaped encounter grid=" .. shape .. " last=" .. last)
end

--@api: LArray:clone
do
    local source_weights = lurek.compute.ones({3, 3})
    local tuned_weights = source_weights:clone()
    tuned_weights:set(1, 1, 5)
    local original = source_weights:get(1, 1)
    compute_log("clone preserved source=" .. original .. " while tuned copy=" .. tuned_weights:get(1, 1))
end

--@api: LArray:transpose
do
    local room_links = lurek.compute.fromTable({1, 2, 3, 4, 5, 6}, {2, 3})
    local reversed_links = room_links:transpose()
    local shape = shape_text(reversed_links)
    local mirrored = reversed_links:get(3, 2)
    compute_log("transposed room links shape=" .. shape .. " mirrored_cell=" .. mirrored)
end

--@api: LArray:fill
do
    local fog_layer = lurek.compute.newArray({3, 3})
    fog_layer:fill(7)
    local center = fog_layer:get(2, 2)
    local total = fog_layer:sum()
    compute_log("fog layer fill center=" .. center .. " total=" .. total)
end

--@api: LArray:addInplace
do
    local base_cost = lurek.compute.ones({3, 3})
    local swamp_penalty = lurek.compute.ones({3, 3})
    base_cost:addInplace(swamp_penalty)
    local center = base_cost:get(2, 2)
    compute_log("path cost after swamp penalty center=" .. center .. " total=" .. base_cost:sum())
end

--@api: LArray:subInplace
do
    local stamina_pool = lurek.compute.fromTable({5, 5, 5, 5}, {2, 2})
    local drain = lurek.compute.ones({2, 2})
    stamina_pool:subInplace(drain)
    local remaining = stamina_pool:get(1, 1)
    compute_log("stamina pool after drain first=" .. remaining .. " total=" .. stamina_pool:sum())
end

--@api: LArray:mulInplace
do
    local reward_grid = lurek.compute.fromTable({2, 3, 4, 5}, {2, 2})
    local combo_boost = lurek.compute.fromTable({10, 10, 10, 10}, {2, 2})
    reward_grid:mulInplace(combo_boost)
    local boosted = reward_grid:get(1, 1)
    compute_log("reward grid after combo boost first=" .. boosted .. " total=" .. reward_grid:sum())
end

--@api: LArray:divInplace
do
    local frame_times = lurek.compute.fromTable({10, 20, 30, 40}, {2, 2})
    local sample_counts = lurek.compute.fromTable({2, 4, 5, 8}, {2, 2})
    frame_times:divInplace(sample_counts)
    local average = frame_times:get(1, 1)
    compute_log("frame time average first=" .. average .. " final=" .. frame_times:get(2, 2))
end

--@api: LArray:add
do
    local threat_scores = lurek.compute.fromTable({1, 2, 3}, {3})
    local danger_bonus = threat_scores:add(10)
    local original = threat_scores:get(1)
    local boosted = danger_bonus:get(1)
    compute_log("threat scores original=" .. original .. " boosted=" .. boosted)
end

--@api: LArray:sub
do
    local health_bar = lurek.compute.fromTable({10, 20, 30}, {3})
    local after_hit = health_bar:sub(5)
    local middle = after_hit:get(2)
    local last = after_hit:get(3)
    compute_log("health after hit middle=" .. middle .. " last=" .. last)
end

--@api: LArray:mul
do
    local combo_hits = lurek.compute.fromTable({2, 3, 4}, {3})
    local scaled_hits = combo_hits:mul(3)
    local second = scaled_hits:get(2)
    local third = scaled_hits:get(3)
    compute_log("scaled combo hits second=" .. second .. " third=" .. third)
end

--@api: LArray:div
do
    local damage_ticks = lurek.compute.fromTable({10, 20, 30}, {3})
    local normalized = damage_ticks:div(10)
    local first = normalized:get(1)
    local third = normalized:get(3)
    compute_log("normalized damage first=" .. first .. " third=" .. third)
end

--@api: LArray:pow
do
    local distance_ring = lurek.compute.fromTable({2, 3, 4}, {3})
    local falloff = distance_ring:pow(2)
    local second = falloff:get(2)
    local third = falloff:get(3)
    compute_log("quadratic falloff second=" .. second .. " third=" .. third)
end

--@api: LArray:sqrt
do
    local area_values = lurek.compute.fromTable({4, 9, 16}, {3})
    local side_lengths = area_values:sqrt()
    local first = side_lengths:get(1)
    local third = side_lengths:get(3)
    compute_log("square root lengths first=" .. first .. " third=" .. third)
end

--@api: LArray:abs
do
    local recoil_offsets = lurek.compute.fromTable({-3, -1, 2}, {3})
    local absolute_offsets = recoil_offsets:abs()
    local first = absolute_offsets:get(1)
    local third = absolute_offsets:get(3)
    compute_log("absolute recoil first=" .. first .. " third=" .. third)
end

--@api: LArray:neg
do
    local knockback = lurek.compute.fromTable({5, -3, 0}, {3})
    local reversed = knockback:neg()
    local first = reversed:get(1)
    local second = reversed:get(2)
    compute_log("reversed knockback first=" .. first .. " second=" .. second)
end

--@api: LArray:clamp
do
    local audio_levels = lurek.compute.fromTable({-5, 0, 3, 10, 15}, {5})
    local safe_levels = audio_levels:clamp(0, 10)
    local low = safe_levels:get(1)
    local high = safe_levels:get(5)
    compute_log("clamped audio levels low=" .. low .. " high=" .. high)
end

--@api: LArray:eq
do
    local tile_ids = lurek.compute.fromTable({1, 2, 3, 2, 1}, {5})
    local door_mask = tile_ids:eq(2)
    local left = door_mask:get(2)
    local right = door_mask:get(4)
    compute_log("door mask marks left=" .. left .. " right=" .. right)
end

--@api: LArray:neq
do
    local terrain_ids = lurek.compute.fromTable({1, 2, 3}, {3})
    local moving_mask = terrain_ids:neq(2)
    local first = moving_mask:get(1)
    local second = moving_mask:get(2)
    compute_log("moving mask first=" .. first .. " blocked_center=" .. second)
end

--@api: LArray:gt
do
    local aggro = lurek.compute.fromTable({1, 5, 10}, {3})
    local alerted = aggro:gt(4)
    local second = alerted:get(2)
    local third = alerted:get(3)
    compute_log("alert mask medium=" .. second .. " high=" .. third)
end

--@api: LArray:lt
do
    local stamina = lurek.compute.fromTable({1, 5, 10}, {3})
    local low_mask = stamina:lt(6)
    local first = low_mask:get(1)
    local third = low_mask:get(3)
    compute_log("low stamina mask first=" .. first .. " third=" .. third)
end

--@api: LArray:gte
do
    local loot_rarity = lurek.compute.fromTable({1, 5, 10}, {3})
    local rare_mask = loot_rarity:gte(5)
    local second = rare_mask:get(2)
    local third = rare_mask:get(3)
    compute_log("rare loot mask second=" .. second .. " third=" .. third)
end

--@api: LArray:lte
do
    local cooldowns = lurek.compute.fromTable({1, 5, 10}, {3})
    local ready_mask = cooldowns:lte(5)
    local first = ready_mask:get(1)
    local third = ready_mask:get(3)
    compute_log("ready cooldown mask first=" .. first .. " third=" .. third)
end

--@api: LArray:threshold
do
    local light_probe = lurek.compute.fromTable({0.1, 0.5, 0.9}, {3})
    local lit_mask = light_probe:threshold(0.4)
    local first = lit_mask:get(1)
    local third = lit_mask:get(3)
    compute_log("light threshold mask first=" .. first .. " third=" .. third)
end

--@api: LArray:where
do
    local daytime = lurek.compute.fromTable({10, 20, 30}, {3})
    local nighttime = lurek.compute.fromTable({-1, -2, -3}, {3})
    local visible = daytime:gt(15)
    local blend = daytime:where(visible, nighttime)
    compute_log("where blend values=" .. blend:get(1) .. "," .. blend:get(2) .. "," .. blend:get(3))
end

--@api: LArray:countNonZero
do
    local occupancy = lurek.compute.fromTable({0, 1, 0, 2, 3}, {5})
    local count = occupancy:countNonZero()
    local total = occupancy:getSize()
    local empty = total - count
    compute_log("occupied cells=" .. count .. " empty cells=" .. empty)
end

--@api: LArray:argmin
do
    local travel_cost = lurek.compute.fromTable({5, 1, 8, 3}, {4})
    local best = travel_cost:argmin()
    local values = travel_cost:toTable()
    local cost = values[best]
    compute_log("cheapest route index=" .. best .. " cost=" .. cost)
end

--@api: LArray:argmax
do
    local reward_score = lurek.compute.fromTable({5, 1, 8, 3}, {4})
    local best = reward_score:argmax()
    local values = reward_score:toTable()
    local score = values[best]
    compute_log("best reward index=" .. best .. " score=" .. score)
end

--@api: LArray:any
do
    local trigger_mask = lurek.compute.fromTable({0, 0, 1}, {3})
    local any_active = trigger_mask:any()
    local all_active = trigger_mask:all()
    local total = trigger_mask:sum()
    compute_log("trigger mask any=" .. tostring(any_active) .. " all=" .. tostring(all_active) .. " sum=" .. total)
end

--- Compute Module Part 2: Reduction, Linear Algebra, Morphology, Statistics, Functional

--@api: LArray:all
do
    local alive_party = lurek.compute.fromTable({1, 2, 3}, {3})
    local all_alive = alive_party:all()
    local members = alive_party:getSize()
    local total = alive_party:sum()
    compute_log("party alive=" .. tostring(all_alive) .. " members=" .. members .. " total_hp_units=" .. total)
end

--@api: LArray:sum
do
    local wave_counts = lurek.compute.fromTable({1, 2, 3, 4}, {4})
    local total = wave_counts:sum()
    local average = wave_counts:mean()
    local last = wave_counts:get(4)
    compute_log("wave count total=" .. total .. " mean=" .. average .. " last=" .. last)
end

--@api: LArray:mean
do
    local frame_times = lurek.compute.fromTable({2, 4, 6, 8}, {4})
    local average = frame_times:mean()
    local low = frame_times:min()
    local high = frame_times:max()
    compute_log("frame time mean=" .. average .. " range=" .. low .. "-" .. high)
end

--@api: LArray:min
do
    local route_costs = lurek.compute.fromTable({7, 2, 9, 1}, {4})
    local best = route_costs:min()
    local index = route_costs:argmin()
    local total = route_costs:sum()
    compute_log("best route cost=" .. best .. " index=" .. index .. " total=" .. total)
end

--@api: LArray:max
do
    local threat_spikes = lurek.compute.fromTable({7, 2, 9, 1}, {4})
    local peak = threat_spikes:max()
    local index = threat_spikes:argmax()
    local total = threat_spikes:sum()
    compute_log("peak threat=" .. peak .. " index=" .. index .. " total=" .. total)
end

--@api: LArray:matmul
do
    local basis = lurek.compute.fromTable({1, 2, 3, 4}, {2, 2})
    local transform = lurek.compute.fromTable({5, 6, 7, 8}, {2, 2})
    local combined = basis:matmul(transform)
    local top_left = combined:get(1, 1)
    compute_log("combined transform shape=" .. shape_text(combined) .. " top_left=" .. top_left)
end

--@api: LArray:dot
do
    local input_x = lurek.compute.fromTable({1, 2, 3}, {3})
    local input_w = lurek.compute.fromTable({4, 5, 6}, {3})
    local score = input_x:dot(input_w)
    local dims = input_x:getDimensions()
    compute_log("neuron dot score=" .. score .. " vector_dims=" .. dims)
end

--@api: LArray:bitwiseAnd
do
    local flags_a = lurek.compute.fromTable({0xFF, 0x0F, 0xAA}, {3}, "int32")
    local flags_b = lurek.compute.fromTable({0x0F, 0x0F, 0x55}, {3}, "int32")
    local overlap = flags_a:bitwiseAnd(flags_b)
    local first = overlap:get(1)
    compute_log("shared permission mask first=" .. first .. " third=" .. overlap:get(3))
end

--@api: LArray:bitwiseOr
do
    local room_a = lurek.compute.fromTable({0xF0, 0x0F}, {2}, "int32")
    local room_b = lurek.compute.fromTable({0x0F, 0xF0}, {2}, "int32")
    local merged = room_a:bitwiseOr(room_b)
    local first = merged:get(1)
    compute_log("merged room flags first=" .. first .. " second=" .. merged:get(2))
end

--@api: LArray:bitwiseXor
do
    local old_state = lurek.compute.fromTable({0xFF, 0x00}, {2}, "int32")
    local new_state = lurek.compute.fromTable({0x0F, 0x0F}, {2}, "int32")
    local changed = old_state:bitwiseXor(new_state)
    local first = changed:get(1)
    compute_log("changed state mask first=" .. first .. " second=" .. changed:get(2))
end

--@api: LArray:bitwiseNot
do
    local solid_mask = lurek.compute.fromTable({0, 255}, {2}, "int32")
    local walkable_mask = solid_mask:bitwiseNot()
    local first = walkable_mask:get(1)
    local second = walkable_mask:get(2)
    compute_log("walkable mask first=" .. first .. " second=" .. second)
end

--@api: LArray:bitwiseLShift
do
    local palette_bits = lurek.compute.fromTable({1, 2, 4}, {3}, "int32")
    local boosted = palette_bits:bitwiseLShift(2)
    local first = boosted:get(1)
    local third = boosted:get(3)
    compute_log("palette bits shifted left first=" .. first .. " third=" .. third)
end

--@api: LArray:bitwiseRShift
do
    local packed_color = lurek.compute.fromTable({8, 16, 32}, {3}, "int32")
    local unpacked = packed_color:bitwiseRShift(2)
    local first = unpacked:get(1)
    local third = unpacked:get(3)
    compute_log("packed color shifted right first=" .. first .. " third=" .. third)
end

--@api: LArray:convolve2D
do
    local lightmap = lurek.compute.zeros({5, 5})
    lightmap:set(3, 3, 1)
    local blur = lurek.compute.gaussianKernel(3, 1.0)
    local softened = lightmap:convolve2D(blur)
    compute_log("softened light center=" .. softened:get(3, 3) .. " neighbor=" .. softened:get(3, 2))
end

--@api: LArray:dilate
do
    local obstacle = lurek.compute.zeros({5, 5})
    obstacle:set(3, 3, 1)
    local clearance = obstacle:dilate(1)
    local near = clearance:get(2, 3)
    compute_log("clearance map near obstacle=" .. near .. " center=" .. clearance:get(3, 3))
end

--@api: LArray:erode
do
    local floor = lurek.compute.ones({5, 5})
    floor:set(1, 1, 0)
    local trimmed = floor:erode(1)
    local center = trimmed:get(2, 2)
    compute_log("eroded floor center=" .. center .. " corner=" .. trimmed:get(1, 1))
end

--@api: LArray:floodFill
do
    local region = lurek.compute.zeros({5, 5})
    region:set(1, 1, 1)
    region:set(1, 2, 1)
    local filled = region:floodFill(1, 1, 9)
    compute_log("flood fill propagated to second cell=" .. filled:get(1, 2) .. " seed=" .. filled:get(1, 1))
end

--@api: LArray:getRegion
do
    local dungeon = lurek.compute.range(1, 17, 1):reshape({4, 4})
    local room = dungeon:getRegion(2, 2, 2, 2)
    local shape = shape_text(room)
    local top_left = room:get(1, 1)
    compute_log("cropped room region=" .. shape .. " top_left=" .. top_left)
end

--@api: LArray:setRegion
do
    local minimap = lurek.compute.zeros({4, 4})
    local room_patch = lurek.compute.ones({2, 2})
    minimap:setRegion(2, 2, room_patch)
    local center = minimap:get(2, 2)
    compute_log("inserted room patch center=" .. center .. " far_corner=" .. minimap:get(4, 4))
end

--@api: LArray:cumsum
do
    local xp_gains = lurek.compute.fromTable({1, 2, 3, 4}, {4})
    local total_xp = xp_gains:cumsum()
    local fourth = total_xp:get(4)
    local second = total_xp:get(2)
    compute_log("cumulative xp second=" .. second .. " fourth=" .. fourth)
end

--@api: LArray:diff
do
    local lap_times = lurek.compute.fromTable({1, 3, 6, 10}, {4})
    local deltas = lap_times:diff()
    local first = deltas:get(1)
    local second = deltas:get(2)
    compute_log("lap deltas first=" .. first .. " second=" .. second)
end

--@api: LArray:histogram
do
    local loot_rolls = lurek.compute.fromTable({1, 2, 3, 4, 5, 6, 7, 8}, {8})
    local bins = loot_rolls:histogram(4)
    local first = bins[1].count
    local last = bins[#bins].count
    compute_log("loot histogram bins=" .. #bins .. " first=" .. tostring(first) .. " last=" .. tostring(last))
end

--@api: LArray:percentile
do
    local damage_log = lurek.compute.range(1, 100, 1)
    local median = damage_log:percentile(50)
    local upper = damage_log:percentile(90)
    local count = damage_log:getSize()
    compute_log("damage percentile median=" .. median .. " p90=" .. upper .. " count=" .. count)
end

--@api: LArray:covariance
do
    local effort = lurek.compute.fromTable({1, 2, 3, 4, 5}, {5})
    local reward = lurek.compute.fromTable({2, 4, 6, 8, 10}, {5})
    local cov = effort:covariance(reward)
    local pairs = effort:getSize()
    compute_log("effort reward covariance=" .. cov .. " pairs=" .. pairs)
end

--@api: LArray:pearsonCorr
do
    local effort = lurek.compute.fromTable({1, 2, 3, 4, 5}, {5})
    local reward = lurek.compute.fromTable({2, 4, 6, 8, 10}, {5})
    local corr = effort:pearsonCorr(reward)
    local pairs = reward:getSize()
    compute_log("effort reward correlation=" .. corr .. " pairs=" .. pairs)
end

--@api: LArray:normalizeRange
do
    local light_levels = lurek.compute.fromTable({0, 50, 100}, {3})
    local normalized = light_levels:normalizeRange(0, 1)
    local middle = normalized:get(2)
    local high = normalized:get(3)
    compute_log("normalized light middle=" .. middle .. " high=" .. high)
end

--@api: LArray:zscore
do
    local enemy_speeds = lurek.compute.fromTable({2, 4, 4, 4, 5, 5, 7, 9}, {8})
    local zscores = enemy_speeds:zscore()
    local first = zscores:get(1)
    local last = zscores:get(8)
    compute_log("enemy speed zscores first=" .. first .. " last=" .. last)
end

--@api: LArray:convolve1d
do
    local signal = lurek.compute.fromTable({0, 1, 2, 3, 4}, {5})
    local kernel = lurek.compute.fromTable({1, 0, -1}, {3})
    local gradient = signal:convolve1d(kernel)
    local size = gradient:getSize()
    compute_log("1d gradient size=" .. size .. " center=" .. gradient:get(3))
end

--@api: LArray:correlate1d
do
    local signal = lurek.compute.fromTable({0, 0, 1, 0, 0}, {5})
    local template = lurek.compute.fromTable({1}, {1})
    local match = signal:correlate1d(template)
    local center = match:get(3)
    compute_log("correlation match center=" .. center .. " size=" .. match:getSize())
end

--@api: LArray:normalizeVec
do
    local move_input = lurek.compute.fromTable({3, 4}, {2})
    local unit = move_input:normalizeVec()
    local x = unit:get(1)
    local y = unit:get(2)
    compute_log("unit move vector=(" .. x .. "," .. y .. ")")
end

--@api: LArray:outer
do
    local row = lurek.compute.fromTable({1, 2, 3}, {3})
    local col = lurek.compute.fromTable({4, 5}, {2})
    local score_grid = row:outer(col)
    local shape = shape_text(score_grid)
    compute_log("outer score grid=" .. shape .. " top_right=" .. score_grid:get(1, 2))
end

--@api: LArray:cross2d
do
    local facing = lurek.compute.fromTable({1, 0}, {2})
    local target = lurek.compute.fromTable({0, 1}, {2})
    local cross = facing:cross2d(target)
    local alignment = facing:dot(target)
    compute_log("2d cross=" .. cross .. " dot=" .. alignment)
end

--@api: LArray:transformPoints
do
    local world_from_local = lurek.compute.affine2d(10, 20, 0, 1, 1)
    local corners = lurek.compute.fromTable({0, 0, 5, 5}, {2, 2})
    local world_points = world_from_local:transformPoints(corners)
    local first_x = world_points:get(1, 1)
    compute_log("transformed points first_x=" .. first_x .. " last_y=" .. world_points:get(2, 2))
end

--@api: LArray:sobel
do
    local heightfield = lurek.compute.zeros({5, 5})
    heightfield:set(3, 3, 1)
    local gradient = heightfield:sobel()
    local gx_shape = shape_text(gradient.gx)
    compute_log("sobel gx=" .. gx_shape .. " gy=" .. shape_text(gradient.gy))
end

--@api: LArray:linsolve
do
    local matrix = lurek.compute.fromTable({2, 1, 5, 7}, {2, 2})
    local rhs = lurek.compute.fromTable({11, 13}, {2})
    local solution = matrix:linsolve(rhs)
    local x = solution:get(1)
    compute_log("linear solve x=" .. x .. " y=" .. solution:get(2))
end

--@api: LArray:luDecompose
do
    local matrix = lurek.compute.fromTable({4, 3, 6, 3}, {2, 2})
    local lu = matrix:luDecompose()
    local perm0 = lu.perm[1]
    local sign = lu.det_sign
    compute_log("lu decomposition n=" .. lu.n .. " sign=" .. sign .. " perm1=" .. tostring(perm0))
end

--@api: LArray:eigenPower
do
    local covariance = lurek.compute.fromTable({2, 1, 1, 2}, {2, 2})
    local dominant = covariance:eigenPower(100, 1e-6)
    local value = dominant.value
    local first = dominant.vector[1]
    compute_log("dominant eigen value=" .. value .. " vector1=" .. tostring(first))
end

--@api: LArray:map
do
    local base_damage = lurek.compute.fromTable({1, 4, 9}, {3})
    local doubled = base_damage:map(function(x) return x * 2 end)
    local second = doubled:get(2)
    local third = doubled:get(3)
    compute_log("mapped damage second=" .. second .. " third=" .. third)
end

--@api: LArray:eval
do
    local base_damage = lurek.compute.fromTable({1, 2, 3}, {3})
    local scripted = base_damage:eval("x * x + 1")
    local second = scripted:get(2)
    local third = scripted:get(3)
    compute_log("evaluated damage curve second=" .. second .. " third=" .. third)
end

--@api: LArray:reduce
do
    local rewards = lurek.compute.fromTable({1, 2, 3, 4}, {4})
    local total = rewards:reduce(function(acc, v) return acc + v end, 0)
    local mean = rewards:mean()
    local count = rewards:getSize()
    compute_log("reduced rewards total=" .. total .. " mean=" .. mean .. " count=" .. count)
end

--@api: LArray:scan
do
    local combo_hits = lurek.compute.fromTable({1, 2, 3, 4}, {4})
    local running = combo_hits:scan(function(acc, v) return acc + v end, 0)
    local second = running:get(2)
    local fourth = running:get(4)
    compute_log("running combo score second=" .. second .. " fourth=" .. fourth)
end

--@api: LArray:type
do
    local scratch = lurek.compute.ones({2, 2})
    scratch:set(1, 2, 3)
    local type_name = scratch:type()
    local shape = shape_text(scratch)
    compute_log("array userdata type=" .. type_name .. " shape=" .. shape)
end

--@api: LArray:typeOf
do
    local scratch = lurek.compute.ones({2, 2})
    scratch:set(2, 1, 4)
    local is_array = scratch:typeOf("LArray")
    local is_object = scratch:typeOf("LObject")
    compute_log("typeOf array=" .. tostring(is_array) .. " object=" .. tostring(is_object))
end
