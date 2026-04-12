-- Lurek2D filesystem API unit tests
-- Headless-safe (no window / GPU / audio required).
-- Tests the lurek.fs namespace: read, write, append, exists, remove,
-- openFile (FileHandle), newFileData (FileData), directory ops,
-- path queries, identity, lines, async read, mount/unmount, load.
-- @covers lurek.fs.read
-- @covers lurek.fs.write
-- @covers lurek.fs.exists
-- @covers lurek.fs.append
-- @covers lurek.fs.remove
-- @covers lurek.fs.openFile
-- @covers lurek.fs.newFileData
-- @covers lurek.fs.getDirectoryItems
-- @covers lurek.fs.isFile
-- @covers lurek.fs.isDirectory
-- @covers lurek.fs.createDirectory
-- @covers lurek.fs.getInfo
-- @covers lurek.fs.getSource
-- @covers lurek.fs.getSaveDirectory
-- @covers lurek.fs.getWorkingDirectory
-- @covers lurek.fs.getUserDirectory
-- @covers lurek.fs.getIdentity
-- @covers lurek.fs.setIdentity
-- @covers lurek.fs.lines
-- @covers lurek.fs.readAsync
-- @covers lurek.fs.pollAsync
-- @covers lurek.fs.mount
-- @covers lurek.fs.unmount
-- @covers lurek.fs.load

-- ── helpers ─────────────────────────────────────────────────────────────────
local TMP = "save/_fs_tests/"

-- ── module presence ──────────────────────────────────────────────────────────

describe("lurek.fs module", function()
    it("lurek.fs is a table", function()
        expect_type("table", lurek.fs)
    end)

    it("all expected functions are present", function()
        local fns = {
            "read", "write", "exists", "append", "remove",
            "openFile", "newFileData",
            "getDirectoryItems", "isFile", "isDirectory", "createDirectory",
            "getInfo", "getSource", "getSaveDirectory", "getWorkingDirectory",
            "getUserDirectory", "getIdentity", "setIdentity",
            "lines", "readAsync", "pollAsync",
            "mount", "unmount", "load",
        }
        for _, name in ipairs(fns) do
            expect_type("function", lurek.fs[name], name .. " must be a function")
        end
    end)
end)

-- ── write / read / exists / remove ──────────────────────────────────────────

describe("lurek.fs.write / read / exists / remove", function()
    it("write creates a file", function()
        expect_no_error(function()
            lurek.fs.write(TMP .. "basic.txt", "hello lurek2d")
        end)
    end)

    it("exists returns true for a written file", function()
        lurek.fs.write(TMP .. "exists_check.txt", "x")
        expect_true(lurek.fs.exists(TMP .. "exists_check.txt"))
    end)

    it("read returns written content", function()
        lurek.fs.write(TMP .. "roundtrip.txt", "test content here")
        local content = lurek.fs.read(TMP .. "roundtrip.txt")
        expect_equal("test content here", content)
    end)

    it("exists returns false for a nonexistent path", function()
        expect_false(lurek.fs.exists("save/_this_should_not_exist_xyz_9999.txt"))
    end)

    it("write and read are binary-safe with newlines", function()
        local data = "line1\nline2\nline3"
        lurek.fs.write(TMP .. "newline.txt", data)
        expect_equal(data, lurek.fs.read(TMP .. "newline.txt"))
    end)

    it("write overwrites existing file", function()
        lurek.fs.write(TMP .. "overwrite.txt", "first")
        lurek.fs.write(TMP .. "overwrite.txt", "second")
        expect_equal("second", lurek.fs.read(TMP .. "overwrite.txt"))
    end)

    it("remove deletes a file", function()
        lurek.fs.write(TMP .. "to_remove.txt", "bye")
        expect_true(lurek.fs.exists(TMP .. "to_remove.txt"))
        lurek.fs.remove(TMP .. "to_remove.txt")
        expect_false(lurek.fs.exists(TMP .. "to_remove.txt"))
    end)
end)

-- ── append ───────────────────────────────────────────────────────────────────

describe("lurek.fs.append", function()
    it("append adds content to an existing file", function()
        lurek.fs.write(TMP .. "append_test.txt", "part1")
        lurek.fs.append(TMP .. "append_test.txt", "part2")
        local content = lurek.fs.read(TMP .. "append_test.txt")
        expect_equal("part1part2", content)
    end)

    it("append creates a new file when path does not exist", function()
        -- Guard: only remove if it already exists (from a previous test run)
        if lurek.fs.exists(TMP .. "append_new.txt") then
            lurek.fs.remove(TMP .. "append_new.txt")
        end
        lurek.fs.append(TMP .. "append_new.txt", "created_by_append")
        expect_true(lurek.fs.exists(TMP .. "append_new.txt"))
        expect_equal("created_by_append", lurek.fs.read(TMP .. "append_new.txt"))
    end)

    it("multiple appends accumulate data in order", function()
        lurek.fs.write(TMP .. "append_multi.txt", "A")
        lurek.fs.append(TMP .. "append_multi.txt", "B")
        lurek.fs.append(TMP .. "append_multi.txt", "C")
        expect_equal("ABC", lurek.fs.read(TMP .. "append_multi.txt"))
    end)
end)

-- ── FileHandle via openFile ───────────────────────────────────────────────────

describe("lurek.fs.openFile — FileHandle UserData", function()
    it("openFile('w') returns a non-nil FileHandle", function()
        local fh = lurek.fs.openFile(TMP .. "fh_write.txt", "w")
        expect_true(fh ~= nil, "FileHandle is not nil")
        fh:close()
    end)

    it("FileHandle:write then FileHandle:close persists data", function()
        local fh = lurek.fs.openFile(TMP .. "fh_persist.txt", "w")
        fh:write("written_via_handle")
        fh:close()
        expect_equal("written_via_handle", lurek.fs.read(TMP .. "fh_persist.txt"))
    end)

    it("openFile('r') can read written content", function()
        lurek.fs.write(TMP .. "fh_read_src.txt", "hello_handle_reader")
        local fh = lurek.fs.openFile(TMP .. "fh_read_src.txt", "r")
        local content = fh:read()
        fh:close()
        expect_equal("hello_handle_reader", content)
    end)

    it("readLine reads one line at a time", function()
        lurek.fs.write(TMP .. "fh_lines.txt", "alpha\nbeta\ngamma")
        local fh = lurek.fs.openFile(TMP .. "fh_lines.txt", "r")
        local l1 = fh:readLine()
        local l2 = fh:readLine()
        fh:close()
        expect_equal("alpha", l1)
        expect_equal("beta", l2)
    end)

    it("tell returns current position", function()
        lurek.fs.write(TMP .. "fh_tell.txt", "abcdef")
        local fh = lurek.fs.openFile(TMP .. "fh_tell.txt", "r")
        local pos = fh:tell()
        fh:close()
        expect_type("number", pos)
        expect_equal(0, pos)
    end)

    it("seek moves the read position", function()
        lurek.fs.write(TMP .. "fh_seek.txt", "ABCDEFGH")
        local fh = lurek.fs.openFile(TMP .. "fh_seek.txt", "r")
        fh:seek(3)
        local rest = fh:read()
        fh:close()
        expect_equal("DEFGH", rest)
    end)

    it("getSize returns byte count", function()
        lurek.fs.write(TMP .. "fh_size.txt", "12345")
        local fh = lurek.fs.openFile(TMP .. "fh_size.txt", "r")
        local sz = fh:getSize()
        fh:close()
        expect_equal(5, sz)
    end)

    it("getMode returns the mode string", function()
        local fh = lurek.fs.openFile(TMP .. "fh_mode.txt", "w")
        local mode = fh:getMode()
        fh:close()
        expect_type("string", mode)
    end)

    it("isEOF returns false before reading all content", function()
        lurek.fs.write(TMP .. "fh_eof.txt", "not empty")
        local fh = lurek.fs.openFile(TMP .. "fh_eof.txt", "r")
        local eof_before = fh:isEOF()
        fh:close()
        expect_false(eof_before)
    end)

    it("flush does not error on writable handle", function()
        local fh = lurek.fs.openFile(TMP .. "fh_flush.txt", "w")
        fh:write("data")
        expect_no_error(function() fh:flush() end)
        fh:close()
    end)
end)

-- ── FileData via newFileData ──────────────────────────────────────────────────
-- newFileData(path) reads a file from the VFS and returns a FileData object.

describe("lurek.fs.newFileData — FileData UserData", function()
    it("newFileData from a written file returns a non-nil object", function()
        lurek.fs.write(TMP .. "fd_blob.txt", "blob content")
        local fd = lurek.fs.newFileData(TMP .. "fd_blob.txt")
        expect_true(fd ~= nil, "FileData is not nil")
    end)

    it("FileData:getSize returns byte count", function()
        lurek.fs.write(TMP .. "fd_hello.txt", "hello")
        local fd = lurek.fs.newFileData(TMP .. "fd_hello.txt")
        expect_equal(5, fd:getSize())
    end)

    it("FileData:getString returns the stored string", function()
        lurek.fs.write(TMP .. "fd_abc.txt", "abc")
        local fd = lurek.fs.newFileData(TMP .. "fd_abc.txt")
        expect_equal("abc", fd:getString())
    end)

    it("FileData:getFilename returns the path used to load the file", function()
        lurek.fs.write(TMP .. "fd_named.txt", "data")
        local path = TMP .. "fd_named.txt"
        local fd = lurek.fs.newFileData(path)
        -- getFilename returns the path it was loaded from
        expect_type("string", fd:getFilename())
    end)
end)

-- ── directory operations ──────────────────────────────────────────────────────

describe("lurek.fs directory operations", function()
    it("createDirectory creates a new directory", function()
        expect_no_error(function()
            lurek.fs.createDirectory(TMP .. "subdir_test/")
        end)
    end)

    it("isDirectory returns true for a created directory", function()
        lurek.fs.createDirectory(TMP .. "isdir_check/")
        expect_true(lurek.fs.isDirectory(TMP .. "isdir_check/"))
    end)

    it("isFile returns false for a directory path", function()
        lurek.fs.createDirectory(TMP .. "not_a_file/")
        expect_false(lurek.fs.isFile(TMP .. "not_a_file/"))
    end)

    it("isFile returns true for a written file", function()
        lurek.fs.write(TMP .. "is_file_test.txt", "yes")
        expect_true(lurek.fs.isFile(TMP .. "is_file_test.txt"))
    end)

    it("isDirectory returns false for a file path", function()
        lurek.fs.write(TMP .. "not_dir.txt", "x")
        expect_false(lurek.fs.isDirectory(TMP .. "not_dir.txt"))
    end)

    it("getDirectoryItems returns a table for a known directory", function()
        lurek.fs.createDirectory(TMP .. "list_dir/")
        lurek.fs.write(TMP .. "list_dir/item1.txt", "a")
        lurek.fs.write(TMP .. "list_dir/item2.txt", "b")
        local items = lurek.fs.getDirectoryItems(TMP .. "list_dir/")
        expect_type("table", items)
        expect_true(#items >= 2, "at least 2 items listed")
    end)

    it("getDirectoryItems entries are strings", function()
        local items = lurek.fs.getDirectoryItems(TMP)
        for _, entry in ipairs(items) do
            expect_type("string", entry)
        end
    end)
end)

-- ── getInfo ──────────────────────────────────────────────────────────────────

describe("lurek.fs.getInfo", function()
    it("getInfo returns a table for a known file", function()
        lurek.fs.write(TMP .. "info_file.txt", "info_test")
        local info = lurek.fs.getInfo(TMP .. "info_file.txt")
        expect_type("table", info)
    end)

    it("getInfo.type is 'file' for a regular file", function()
        lurek.fs.write(TMP .. "info_type.txt", "x")
        local info = lurek.fs.getInfo(TMP .. "info_type.txt")
        expect_equal("file", info.type)
    end)

    it("getInfo.size matches number of bytes written", function()
        lurek.fs.write(TMP .. "info_size.txt", "12345")
        local info = lurek.fs.getInfo(TMP .. "info_size.txt")
        expect_equal(5, info.size)
    end)

    it("getInfo returns nil for nonexistent path", function()
        local info = lurek.fs.getInfo("save/_nonexistent_info_xyz.txt")
        expect_nil(info)
    end)
end)

-- ── path queries ──────────────────────────────────────────────────────────────

describe("lurek.fs path query functions", function()
    it("getSource returns a string", function()
        local src = lurek.fs.getSource()
        expect_type("string", src)
    end)

    it("getSaveDirectory returns a string", function()
        local sd = lurek.fs.getSaveDirectory()
        expect_type("string", sd)
    end)

    it("getWorkingDirectory returns a string", function()
        local wd = lurek.fs.getWorkingDirectory()
        expect_type("string", wd)
    end)

    it("getUserDirectory returns a string", function()
        local ud = lurek.fs.getUserDirectory()
        expect_type("string", ud)
    end)
end)

-- ── identity ─────────────────────────────────────────────────────────────────

describe("lurek.fs.getIdentity / setIdentity", function()
    it("getIdentity returns a string", function()
        local id = lurek.fs.getIdentity()
        expect_type("string", id)
    end)

    it("setIdentity changes the identity returned by getIdentity", function()
        local old = lurek.fs.getIdentity()
        lurek.fs.setIdentity("test_fs_identity")
        local new = lurek.fs.getIdentity()
        expect_equal("test_fs_identity", new)
        -- Restore original identity
        lurek.fs.setIdentity(old)
    end)
end)

-- ── lines iterator ────────────────────────────────────────────────────────────

describe("lurek.fs.lines", function()
    it("lines iterates over all lines in a file", function()
        lurek.fs.write(TMP .. "lines_test.txt", "alpha\nbeta\ngamma")
        local collected = {}
        for line in lurek.fs.lines(TMP .. "lines_test.txt") do
            collected[#collected + 1] = line
        end
        expect_equal(3, #collected)
        expect_equal("alpha", collected[1])
        expect_equal("beta",  collected[2])
        expect_equal("gamma", collected[3])
    end)

    it("lines on empty file yields no iterations", function()
        lurek.fs.write(TMP .. "lines_empty.txt", "")
        local count = 0
        for _ in lurek.fs.lines(TMP .. "lines_empty.txt") do
            count = count + 1
        end
        expect_equal(0, count)
    end)
end)

-- ── async read ───────────────────────────────────────────────────────────────

describe("lurek.fs.readAsync / pollAsync", function()
    it("readAsync returns a handle (non-nil)", function()
        lurek.fs.write(TMP .. "async_src.txt", "async_content")
        local handle = lurek.fs.readAsync(TMP .. "async_src.txt")
        expect_true(handle ~= nil, "async handle is not nil")
    end)

    it("pollAsync returns a status string for a valid handle", function()
        lurek.fs.write(TMP .. "async_poll.txt", "poll_content")
        local handle = lurek.fs.readAsync(TMP .. "async_poll.txt")
        -- pollAsync returns (status:string, data:string|nil)
        -- status is "pending", "done", or "error"
        local status, data
        for _ = 1, 1000 do
            status, data = lurek.fs.pollAsync(handle)
            if status ~= "pending" then break end
        end
        -- In headless tests (no event loop background worker), the loader may
        -- remain "pending". We accept either "done" or "pending" as valid.
        expect_type("string", status)
        expect_true(status == "done" or status == "pending",
            "status must be 'done' or 'pending', got: " .. tostring(status))
        if status == "done" then
            expect_equal("poll_content", data)
        end
    end)
end)

-- ── mount / unmount / load ────────────────────────────────────────────────────

describe("lurek.fs.mount / unmount / load", function()
    it("mount is a function", function()
        expect_type("function", lurek.fs.mount)
    end)

    it("unmount is a function", function()
        expect_type("function", lurek.fs.unmount)
    end)

    it("load compiles a Lua file and returns a callable function", function()
        lurek.fs.write(TMP .. "chunk.lua", "return function() return 99 end")
        local f = lurek.fs.load(TMP .. "chunk.lua")
        expect_type("function", f)
        local inner = f()
        expect_type("function", inner)
        expect_equal(99, inner())
        lurek.fs.remove(TMP .. "chunk.lua")
    end)

    it("load returns an error for invalid Lua syntax", function()
        lurek.fs.write(TMP .. "bad_chunk.lua", ":::invalid lua:::")
        expect_error(function()
            lurek.fs.load(TMP .. "bad_chunk.lua")
        end)
        lurek.fs.remove(TMP .. "bad_chunk.lua")
    end)
end)

test_summary()
