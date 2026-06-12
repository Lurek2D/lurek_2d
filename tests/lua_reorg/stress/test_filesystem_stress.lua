-- Lurek2D Stress Test: Filesystem I/O Operations
-- Measures file write/read throughput in the sandboxed filesystem.

local function make_files(count, payload)
    local files = {}
    for i = 1, count do
        files[i] = "save/stress_fs_tmp_" .. i .. ".bin"
        lurek.filesystem.write(files[i], payload)
    end
    return files
end

local function cleanup_files(files)
    for _, path in ipairs(files) do
        if lurek.filesystem.exists(path) then
            lurek.filesystem.remove(path)
        end
    end
end

-- @describe stress: filesystem write/read throughput
describe("stress: filesystem write/read throughput", function()
    -- @stress lurek.filesystem.write
    it("write 100 small files (1KB each): <10s", function()
        local COUNT   = 100
        local payload = string.rep("x", 1024)  -- 1KB
        local files   = {}

        for i = 1, COUNT do
            files[i] = "save/stress_fs_tmp_" .. i .. ".bin"
        end

        local start_w = os.clock()
        for _, path in ipairs(files) do
            lurek.filesystem.write(path, payload)
        end
        local w_elapsed = os.clock() - start_w
        print(string.format("[STRESS] write %d       1KB files: %.4fs (%.0f KB/s)",
            COUNT, w_elapsed, COUNT / w_elapsed))

        cleanup_files(files)
        expect_true(w_elapsed < 10.0, "write budget: " .. w_elapsed .. "s")
    end)

    -- @stress lurek.filesystem.read
    it("read 100 small files (1KB each): <10s", function()
        local COUNT   = 100
        local payload = string.rep("x", 1024)  -- 1KB
        local files   = make_files(COUNT, payload)

        local start_r = os.clock()
        for _, path in ipairs(files) do
            local data = lurek.filesystem.read(path)
            expect_equal(payload, data, "read returns original payload")
        end
        local r_elapsed = os.clock() - start_r
        print(string.format("[STRESS] read %d       1KB files: %.4fs (%.0f KB/s)",
            COUNT, r_elapsed, COUNT / r_elapsed))

        cleanup_files(files)
        expect_true(r_elapsed < 10.0, "read budget: " .. r_elapsed .. "s")
    end)

    -- @stress lurek.filesystem.exists
    it("exists check 10000 times in <5s", function()
        local COUNT   = 10000
        local elapsed = measure("filesystem.exists x" .. COUNT, COUNT, function()
            local _ = lurek.filesystem.exists("non_existent_stress_test_path.txt")
        end)

        expect_true(elapsed < 5.0, "exists check budget: " .. elapsed .. "s")
    end)
end)
test_summary()
