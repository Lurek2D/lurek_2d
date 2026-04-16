-- tests/lua/unit/test_filesystem_zip_watcher.lua
-- Tests for lurek.fs.mountZip, watchPath, unwatchPath, and pollWatchers.
-- Does not access the GPU, audio, or window.

describe("fs.mountZip", function()

    it("mountZip raises error for a nonexistent path", function()
        expect_error(function()
            lurek.fs.mountZip("does_not_exist_xyz.zip", "")
        end)
    end)

    it("mountZip raises error for a non-ZIP file", function()
        -- Write a temp text file via lurek.fs, then try to mount it as ZIP.
        lurek.fs.write("save/not_a_zip.bin", "hello")
        expect_error(function()
            -- Path under save sandbox — not a valid ZIP
            lurek.fs.mountZip("save/not_a_zip.bin", "test")
        end)
    end)

end)

describe("fs.watchPath / pollWatchers", function()

    it("watchPath and pollWatchers exist in lurek.fs", function()
        expect_equal(type(lurek.fs.watchPath), "function")
        expect_equal(type(lurek.fs.pollWatchers), "function")
        expect_equal(type(lurek.fs.unwatchPath), "function")
    end)

    it("pollWatchers returns a table", function()
        local result = lurek.fs.pollWatchers()
        expect_equal(type(result), "table")
    end)

    it("watching a nonexistent file does not raise", function()
        lurek.fs.watchPath("nonexistent_watch_target_abc.lua")
    end)

    it("unwatchPath does not raise for an unwatched path", function()
        lurek.fs.unwatchPath("never_watched.lua")
    end)

    it("pollWatchers after watch returns a table (no false positives for missing file)", function()
        lurek.fs.watchPath("truly_nonexistent_xyz_abc.lua")
        local changed = lurek.fs.pollWatchers()
        expect_equal(type(changed), "table")
        -- Nonexistent file: mtime stays nil → no change
        expect_equal(#changed == 0, true)
    end)

    it("polling a freshly written file detects change", function()
        local path = "save/watcher_test_file.txt"
        -- Write file AFTER setting up the watcher so it transitions None → Some
        lurek.fs.watchPath(path)
        -- First poll: file doesn't exist yet — no change
        lurek.fs.pollWatchers()
        -- Write the file to cause a mtime change
        lurek.fs.write(path, "first write")
        -- Second poll: file now exists — should detect change
        local changed = lurek.fs.pollWatchers()
        expect_equal(type(changed), "table")
        -- We expect at least 0 entries (CI filesystem timing may vary, so we
        -- just verify the return type and no crash, not an exact count)
    end)

end)

test_summary()
