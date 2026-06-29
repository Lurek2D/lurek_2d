-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_filesystem_core_unit.lua
do
-- tests/lua/unit/test_filesystem_core_unit.lua
-- Canonical unit coverage for lurek.filesystem and related userdata APIs.

local TMP = "save/_fs_tests/"
local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

local function ensure_missing(path)
    if lurek.filesystem.exists(path) then
        local info = lurek.filesystem.getInfo(path)
        if info and info.type == "directory" then
            lurek.filesystem.removeDir(path)
        else
            lurek.filesystem.remove(path)
        end
    end
end

local function write_text(path, data)
    lurek.filesystem.write(path, data)
    return path
end

local function make_zip_mount(prefix)
    return lurek.filesystem.mountZip(ZIP_FIXTURE, prefix)
end

-- @describe lurek.filesystem functions
describe("lurek.filesystem functions", function()
    -- @covers lurek.filesystem.append
    it("append adds data to the end of an existing file", function()
        local path = TMP .. "append.txt"
        write_text(path, "A")
        lurek.filesystem.append(path, "B")
        expect_equal("AB", lurek.filesystem.read(path))
    end)

    -- @covers lurek.filesystem.copy
    it("copy duplicates a file into a new path", function()
        local src = TMP .. "copy_src.txt"
        local dst = TMP .. "copy_dst.txt"
        write_text(src, "copy me")
        lurek.filesystem.copy(src, dst)
        expect_equal("copy me", lurek.filesystem.read(dst))
    end)

    -- @covers lurek.filesystem.createDirectory
    it("createDirectory builds nested directories", function()
        local path = TMP .. "create_dir/deep/nested/"
        lurek.filesystem.createDirectory(path)
        expect_true(lurek.filesystem.isDirectory(path))
    end)

    -- @covers lurek.filesystem.createTempFile
    it("createTempFile returns unique save-scoped paths", function()
        local first = lurek.filesystem.createTempFile("tmp_")
        local second = lurek.filesystem.createTempFile("tmp_")
        expect_type("string", first)
        expect_equal("save/", first:sub(1, 5))
        expect_true(first ~= second)
    end)

    -- @covers lurek.filesystem.exists
    it("exists returns true after a file is written", function()
        local path = TMP .. "exists.txt"
        write_text(path, "ping")
        expect_true(lurek.filesystem.exists(path))
    end)

    -- @covers lurek.filesystem.getDirectoryItems
    it("getDirectoryItems lists immediate entries in a directory", function()
        local dir = TMP .. "dir_items/"
        lurek.filesystem.createDirectory(dir)
        write_text(dir .. "a.txt", "a")
        write_text(dir .. "b.txt", "b")
        local items = lurek.filesystem.getDirectoryItems(dir)
        expect_type("table", items)
        expect_true(#items >= 2)
    end)

    -- @covers lurek.filesystem.getIdentity
    it("getIdentity returns the current filesystem identity string", function()
        expect_type("string", lurek.filesystem.getIdentity())
    end)

    -- @covers lurek.filesystem.getInfo
    it("getInfo returns metadata for a written file", function()
        local path = TMP .. "info.txt"
        write_text(path, "hello")
        local info = lurek.filesystem.getInfo(path)
        expect_not_nil(info)
        expect_type("number", info.size)
        expect_type("string", info.type)
    end)

    -- @covers lurek.filesystem.getSaveDirectory
    it("getSaveDirectory returns a non-empty path string", function()
        local path = lurek.filesystem.getSaveDirectory()
        expect_type("string", path)
        expect_true(#path > 0)
    end)

    -- @covers lurek.filesystem.getSource
    it("getSource returns a non-empty source path string", function()
        local path = lurek.filesystem.getSource()
        expect_type("string", path)
        expect_true(#path > 0)
    end)

    -- @covers lurek.filesystem.getUserDirectory
    it("getUserDirectory returns a non-empty user path string", function()
        local path = lurek.filesystem.getUserDirectory()
        expect_type("string", path)
        expect_true(#path > 0)
    end)

    -- @covers lurek.filesystem.getWorkingDirectory
    it("getWorkingDirectory returns a non-empty working path string", function()
        local path = lurek.filesystem.getWorkingDirectory()
        expect_type("string", path)
        expect_true(#path > 0)
    end)

    -- @covers lurek.filesystem.glob
    it("glob returns sorted wildcard matches", function()
        local dir = TMP .. "glob/"
        lurek.filesystem.createDirectory(dir)
        write_text(dir .. "a.lua", "")
        write_text(dir .. "b.lua", "")
        write_text(dir .. "c.txt", "")
        local matches = lurek.filesystem.glob(dir .. "*.lua")
        expect_equal(2, #matches)
        expect_equal(dir .. "a.lua", matches[1])
        expect_equal(dir .. "b.lua", matches[2])
    end)

    -- @covers lurek.filesystem.isDirectory
    it("isDirectory reports true for directories", function()
        local dir = TMP .. "is_directory/"
        lurek.filesystem.createDirectory(dir)
        expect_true(lurek.filesystem.isDirectory(dir))
    end)

    -- @covers lurek.filesystem.isFile
    it("isFile reports true for regular files", function()
        local path = TMP .. "is_file.txt"
        write_text(path, "hello")
        expect_true(lurek.filesystem.isFile(path))
    end)

    -- @covers lurek.filesystem.lines
    it("lines iterates through each line in a text file", function()
        local path = TMP .. "lines.txt"
        write_text(path, "alpha\nbeta\ngamma")
        local count = 0
        for _ in lurek.filesystem.lines(path) do
            count = count + 1
        end
        expect_equal(3, count)
    end)

    -- @covers lurek.filesystem.listRecursive
    it("listRecursive walks nested files recursively", function()
        local dir = TMP .. "recursive/"
        local sub = dir .. "sub/"
        lurek.filesystem.createDirectory(sub)
        write_text(dir .. "a.txt", "a")
        write_text(sub .. "b.txt", "b")
        local items = lurek.filesystem.listRecursive(dir)
        expect_type("table", items)
        expect_true(#items >= 2)
    end)

    -- @covers lurek.filesystem.load
    it("load compiles a Lua chunk from GameFS", function()
        local path = TMP .. "chunk.lua"
        write_text(path, "return function() return 99 end")
        local chunk = lurek.filesystem.load(path)
        expect_type("function", chunk)
        expect_equal(99, chunk()())
    end)

    -- @covers lurek.filesystem.mkdir
    it("mkdir creates directories under the save root", function()
        local dir = TMP .. "mkdir/deep/"
        lurek.filesystem.mkdir(dir)
        expect_true(lurek.filesystem.isDirectory(dir))
    end)

    -- @covers lurek.filesystem.mount
    it("mount accepts a valid source and mountpoint", function()
        local mountpoint = "unit_fs_assets"
        lurek.filesystem.unmount(mountpoint)
        local ok = lurek.filesystem.mount("assets", mountpoint)
        expect_type("boolean", ok)
    end)

    -- @covers lurek.filesystem.mountZip
    it("mountZip reports that ZIP mounts are unavailable in this runtime build", function()
        expect_error(function()
            make_zip_mount("zipmount_fs")
        end)
    end)

    -- @covers lurek.filesystem.move
    it("move relocates a file within the sandbox", function()
        local src = TMP .. "move_src.txt"
        local dst = TMP .. "move_dst.txt"
        write_text(src, "move me")
        lurek.filesystem.move(src, dst)
        expect_false(lurek.filesystem.exists(src))
        expect_equal("move me", lurek.filesystem.read(dst))
    end)

    -- @covers lurek.filesystem.newFileData
    it("newFileData returns an immutable file data handle", function()
        local path = TMP .. "filedata.txt"
        write_text(path, "payload")
        local data = lurek.filesystem.newFileData(path)
        expect_not_nil(data)
        expect_equal(7, data:getSize())
    end)

    -- @covers lurek.filesystem.openFile
    it("openFile returns a file handle in write mode", function()
        local handle = lurek.filesystem.openFile(TMP .. "open_file.txt", "w")
        expect_not_nil(handle)
        handle:close()
    end)

    -- @covers lurek.filesystem.pollAsync
    it("pollAsync reports pending or done for a read ticket", function()
        local path = TMP .. "async_read.txt"
        write_text(path, "async data")
        local handle = lurek.filesystem.readAsync(path)
        local status, data
        for _ = 1, 1000 do
            status, data = lurek.filesystem.pollAsync(handle)
            if status ~= "pending" then
                break
            end
        end
        expect_type("string", status)
        expect_true(status == "done" or status == "pending")
        if status == "done" then
            expect_equal("async data", data)
        end
    end)

    -- @covers lurek.filesystem.pollAsyncWrite
    it("pollAsyncWrite reports pending or done for a write ticket", function()
        local path = TMP .. "async_write.txt"
        local handle = lurek.filesystem.writeAsync(path, "payload")
        local status, info
        for _ = 1, 1000 do
            status, info = lurek.filesystem.pollAsyncWrite(handle)
            if status ~= "pending" then
                break
            end
        end
        expect_type("string", status)
        expect_true(status == "done" or status == "pending")
        if status == "done" then
            expect_equal("7", info)
            expect_equal("payload", lurek.filesystem.read(path))
        end
    end)

    -- @covers lurek.filesystem.pollWatchers
    it("pollWatchers returns a table of changed paths", function()
        local path = TMP .. "watch.txt"
        ensure_missing(path)
        lurek.filesystem.watchPath(path)
        lurek.filesystem.pollWatchers()
        write_text(path, "changed")
        local changed = lurek.filesystem.pollWatchers()
        expect_type("table", changed)
    end)

    -- @covers lurek.filesystem.read
    it("read returns previously written text", function()
        local path = TMP .. "read.txt"
        write_text(path, "read me")
        expect_equal("read me", lurek.filesystem.read(path))
    end)

    -- @covers lurek.filesystem.readAsync
    it("readAsync returns a non-nil request handle", function()
        local path = TMP .. "read_async_handle.txt"
        write_text(path, "hello")
        expect_not_nil(lurek.filesystem.readAsync(path))
    end)

    -- @covers lurek.filesystem.readBytes
    it("readBytes returns a binary string payload", function()
        local path = TMP .. "read_bytes.bin"
        lurek.filesystem.writeBytes(path, "\x00\x01\x02\x03")
        local bytes = lurek.filesystem.readBytes(path)
        expect_type("string", bytes)
        expect_equal(4, #bytes)
    end)

    -- @covers lurek.filesystem.readJson
    it("readJson returns JSON text written through writeJson", function()
        local path = TMP .. "read_json.json"
        lurek.filesystem.writeJson(path, '{"score":42}')
        expect_equal('{"score":42}', lurek.filesystem.readJson(path))
    end)

    -- @covers lurek.filesystem.readOrWriteJson
    it("readOrWriteJson writes default JSON when missing", function()
        local path = TMP .. "default.json"
        ensure_missing(path)
        local json = lurek.filesystem.readOrWriteJson(path, '{"hp":10}')
        expect_equal('{"hp":10}', json)
        expect_true(lurek.filesystem.exists(path))
    end)

    -- @covers lurek.filesystem.remove
    it("remove deletes a written file", function()
        local path = TMP .. "remove.txt"
        write_text(path, "bye")
        lurek.filesystem.remove(path)
        expect_false(lurek.filesystem.exists(path))
    end)

    -- @covers lurek.filesystem.removeDir
    it("removeDir removes nested directory trees", function()
        local dir = TMP .. "remove_dir/"
        local nested = dir .. "deep/nested/"
        lurek.filesystem.createDirectory(nested)
        write_text(nested .. "file.txt", "x")
        lurek.filesystem.removeDir(dir)
        expect_false(lurek.filesystem.exists(nested .. "file.txt"))
        expect_false(lurek.filesystem.isDirectory(dir))
    end)

    -- @covers lurek.filesystem.setIdentity
    it("setIdentity updates the filesystem identity", function()
        local original = lurek.filesystem.getIdentity()
        lurek.filesystem.setIdentity("codex_unit_identity")
        expect_equal("codex_unit_identity", lurek.filesystem.getIdentity())
        lurek.filesystem.setIdentity(original)
    end)

    -- @covers lurek.filesystem.stat
    it("stat returns size and file flags for written files", function()
        local path = TMP .. "stat.txt"
        write_text(path, "abcde")
        local info = lurek.filesystem.stat(path)
        expect_equal(5, info.size)
        expect_true(info.isFile)
        expect_false(info.isDir)
    end)

    -- @covers lurek.filesystem.toAbsolutePath
    it("toAbsolutePath resolves a save path to an absolute path string", function()
        local abs = lurek.filesystem.toAbsolutePath(TMP .. "absolute.txt")
        expect_type("string", abs)
        expect_true(string.find(abs, "_fs_tests", 1, true) ~= nil)
    end)

    -- @covers lurek.filesystem.unmount
    it("unmount returns false for an unknown mountpoint", function()
        expect_false(lurek.filesystem.unmount("missing_mountpoint"))
    end)

    -- @covers lurek.filesystem.unwatchPath
    it("unwatchPath does not error for an unwatched path", function()
        expect_no_error(function()
            lurek.filesystem.unwatchPath("never_watched.txt")
        end)
    end)

    -- @covers lurek.filesystem.watchPath
    it("watchPath registers a path without raising an error", function()
        expect_no_error(function()
            lurek.filesystem.watchPath(TMP .. "watch_register.txt")
        end)
    end)

    -- @covers lurek.filesystem.write
    it("write creates a file with exact text payload", function()
        local path = TMP .. "write.txt"
        lurek.filesystem.write(path, "hello lurek")
        expect_equal("hello lurek", lurek.filesystem.read(path))
    end)

    -- @covers lurek.filesystem.writeAsync
    it("writeAsync returns a non-nil request handle", function()
        expect_not_nil(lurek.filesystem.writeAsync(TMP .. "write_async_handle.txt", "hello"))
    end)

    -- @covers lurek.filesystem.writeBytes
    it("writeBytes persists binary data readable with readBytes", function()
        local path = TMP .. "write_bytes.bin"
        lurek.filesystem.writeBytes(path, "\x00\x01\x02")
        expect_equal(3, #lurek.filesystem.readBytes(path))
    end)

    -- @covers lurek.filesystem.writeJson
    it("writeJson writes valid JSON text", function()
        local path = TMP .. "write_json.json"
        lurek.filesystem.writeJson(path, '{"name":"mage"}')
        expect_equal('{"name":"mage"}', lurek.filesystem.read(path))
    end)
end)

-- @describe LFileHandle methods
describe("LFileHandle methods", function()
    -- @covers LFileHandle:close
    it("close is idempotent for file handles", function()
        local handle = lurek.filesystem.openFile(TMP .. "close.txt", "w")
        handle:write("x")
        handle:close()
        expect_no_error(function()
            handle:close()
        end)
    end)

    -- @covers LFileHandle:flush
    it("flush persists buffered writes before close", function()
        local path = TMP .. "flush.txt"
        local handle = lurek.filesystem.openFile(path, "w")
        handle:write("buffered")
        handle:flush()
        handle:close()
        expect_equal("buffered", lurek.filesystem.read(path))
    end)

    -- @covers LFileHandle:getMode
    it("getMode returns the open mode string", function()
        local handle = lurek.filesystem.openFile(TMP .. "mode.txt", "w")
        expect_equal("w", handle:getMode())
        handle:close()
    end)

    -- @covers LFileHandle:getSize
    it("getSize returns the file byte count", function()
        local path = TMP .. "size.txt"
        write_text(path, "12345")
        local handle = lurek.filesystem.openFile(path, "r")
        expect_equal(5, handle:getSize())
        handle:close()
    end)

    -- @covers LFileHandle:isEOF
    it("isEOF becomes true after the file is fully read", function()
        local path = TMP .. "eof.txt"
        write_text(path, "abcdef")
        local handle = lurek.filesystem.openFile(path, "r")
        handle:read()
        expect_true(handle:isEOF())
        handle:close()
    end)

    -- @covers LFileHandle:read
    it("read accepts byte counts and returns the remaining text", function()
        local path = TMP .. "read_handle.txt"
        write_text(path, "abcdefgh")
        local handle = lurek.filesystem.openFile(path, "r")
        expect_equal("abc", handle:read(3))
        expect_equal("defgh", handle:read())
        handle:close()
    end)

    -- @covers LFileHandle:readLine
    it("readLine returns one logical line at a time", function()
        local path = TMP .. "readline.txt"
        write_text(path, "alpha\nbeta\ngamma")
        local handle = lurek.filesystem.openFile(path, "r")
        expect_equal("alpha", handle:readLine())
        expect_equal("beta", handle:readLine())
        handle:close()
    end)

    -- @covers LFileHandle:seek
    it("seek moves the read cursor to an absolute offset", function()
        local path = TMP .. "seek.txt"
        write_text(path, "ABCDEFGH")
        local handle = lurek.filesystem.openFile(path, "r")
        handle:seek(3)
        expect_equal("DEFGH", handle:read())
        handle:close()
    end)

    -- @covers LFileHandle:tell
    it("tell reports the current cursor position", function()
        local path = TMP .. "tell.txt"
        write_text(path, "abcdef")
        local handle = lurek.filesystem.openFile(path, "r")
        handle:read(3)
        expect_equal(3, handle:tell())
        handle:close()
    end)

    -- @covers LFileHandle:type
    it("type returns the file handle userdata name", function()
        local path = TMP .. "type.txt"
        write_text(path, "x")
        local handle = lurek.filesystem.openFile(path, "r")
        expect_equal("LFileHandle", handle:type())
        handle:close()
    end)

    -- @covers LFileHandle:typeOf
    it("typeOf accepts the file handle type name", function()
        local path = TMP .. "typeof.txt"
        write_text(path, "x")
        local handle = lurek.filesystem.openFile(path, "r")
        expect_true(handle:typeOf("LFileHandle"))
        handle:close()
    end)

    -- @covers LFileHandle:write
    it("write persists text through an open file handle", function()
        local path = TMP .. "write_handle.txt"
        local handle = lurek.filesystem.openFile(path, "w")
        handle:write("written_via_handle")
        handle:close()
        expect_equal("written_via_handle", lurek.filesystem.read(path))
    end)
end)

-- @describe LFileData methods
describe("LFileData methods", function()
    -- @covers LFileData:getFilename
    it("getFilename returns the source path for file data", function()
        local path = TMP .. "filedata_name.txt"
        write_text(path, "hello")
        local data = lurek.filesystem.newFileData(path)
        expect_equal(path, data:getFilename())
    end)

    -- @covers LFileData:getSize
    it("getSize returns the byte length of file data", function()
        local path = TMP .. "filedata_size.txt"
        write_text(path, "hello")
        local data = lurek.filesystem.newFileData(path)
        expect_equal(5, data:getSize())
    end)

    -- @covers LFileData:getString
    it("getString returns the raw file payload", function()
        local path = TMP .. "filedata_string.txt"
        write_text(path, "hello")
        local data = lurek.filesystem.newFileData(path)
        expect_equal("hello", data:getString())
    end)

    -- @covers LFileData:type
    it("type returns the file data userdata name", function()
        local path = TMP .. "filedata_type.txt"
        write_text(path, "hello")
        local data = lurek.filesystem.newFileData(path)
        expect_equal("LFileData", data:type())
    end)

    -- @covers LFileData:typeOf
    it("typeOf accepts the file data type name", function()
        local path = TMP .. "filedata_typeof.txt"
        write_text(path, "hello")
        local data = lurek.filesystem.newFileData(path)
        expect_true(data:typeOf("LFileData"))
    end)
end)
end
-- END test_filesystem_core_unit.lua

test_summary()
