-- content/examples/filesystem.lua
-- Auto-generated from content/examples2/filesystem_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/filesystem.lua

--- Filesystem Module Part 1: paths, read/write, directory ops

--@api: lurek.filesystem.getSource
do
    local src = lurek.filesystem.getSource()
    print("source = " .. src)
end

--@api: lurek.filesystem.getSaveDirectory
do
    local save = lurek.filesystem.getSaveDirectory()
    print("save dir = " .. save)
end

--@api: lurek.filesystem.getWorkingDirectory
do
    local cwd = lurek.filesystem.getWorkingDirectory()
    print("cwd = " .. cwd)
end

--@api: lurek.filesystem.getUserDirectory
do
    local home = lurek.filesystem.getUserDirectory()
    print("home = " .. home)
end

--@api: lurek.filesystem.getIdentity
do
    local id = lurek.filesystem.getIdentity()
    print("identity = " .. id)
end

--@api: lurek.filesystem.setIdentity
do
    lurek.filesystem.setIdentity("my_game")
    print("identity set to 'my_game'")
end

--@api: lurek.filesystem.toAbsolutePath
do
    local abs = lurek.filesystem.toAbsolutePath("content/examples/assets/data/sample_config.toml")
    print("absolute = " .. abs)
end

--@api: lurek.filesystem.exists
do
    local path = "save/options_exists.json"
    lurek.filesystem.write(path, "{\"ok\":true}")
    local found = lurek.filesystem.exists(path)
    print(path .. " exists = " .. tostring(found))
end

--@api: lurek.filesystem.isFile
do
    local path = "save/is_file.txt"
    lurek.filesystem.write(path, "hello")
    print("is file = " .. tostring(lurek.filesystem.isFile(path)))
end

--@api: lurek.filesystem.isDirectory
do
    local path = "save"
    print("is dir = " .. tostring(lurek.filesystem.isDirectory(path)))
end

--@api: lurek.filesystem.getInfo
do
    local path = "save/info.txt"
    lurek.filesystem.write(path, "info sample")
    local info = lurek.filesystem.getInfo(path)
    if info then
        print("type=" .. info.type .. " size=" .. info.size)
    end
end

--@api: lurek.filesystem.stat
do
    local path = "save/stat.txt"
    lurek.filesystem.write(path, "stat sample")
    local st = lurek.filesystem.stat(path)
    if st then
        print("stat size=" .. st.size .. " isFile=" .. tostring(st.isFile))
    end
end

--@api: lurek.filesystem.read
do
    local path = "save/read_sample.txt"
    lurek.filesystem.write(path, "read me")
    local contents = lurek.filesystem.read(path)
    print("read " .. #contents .. " bytes")
    print("contents = " .. contents)
end

--@api: lurek.filesystem.write
do
    local path = "save/test_write.txt"
    lurek.filesystem.write(path, "hello world")
    print("wrote to " .. path)
end

--@api: lurek.filesystem.append
do
    local path = "save/test_write.txt"
    lurek.filesystem.append(path, "\nline 2")
    print("appended to " .. path)
end

--@api: lurek.filesystem.copy
do
    lurek.filesystem.write("save/test_write.txt", "copy source")
    local ok = lurek.filesystem.copy("save/test_write.txt", "save/test_copy.txt")
    print("copy ok = " .. tostring(ok))
end

--@api: lurek.filesystem.move
do
    lurek.filesystem.write("save/test_copy.txt", "move source")
    local ok = lurek.filesystem.move("save/test_copy.txt", "save/test_moved.txt")
    print("move ok = " .. tostring(ok))
end

--@api: lurek.filesystem.remove
do
    lurek.filesystem.write("save/test_moved.txt", "remove source")
    local ok = lurek.filesystem.remove("save/test_moved.txt")
    print("remove ok = " .. tostring(ok))
end

--@api: lurek.filesystem.createDirectory
do
    local ok = lurek.filesystem.createDirectory("save/new_dir")
    print("mkdir ok = " .. tostring(ok))
end

--@api: lurek.filesystem.mkdir
do
    local ok = lurek.filesystem.mkdir("save/another_dir")
    print("mkdir ok = " .. tostring(ok))
end

--@api: lurek.filesystem.removeDir
do
    lurek.filesystem.mkdir("save/another_dir")
    local ok = lurek.filesystem.removeDir("save/another_dir")
    print("removeDir ok = " .. tostring(ok))
end

--@api: lurek.filesystem.getDirectoryItems
do
    local items = lurek.filesystem.getDirectoryItems("save")
    print("save/ has " .. #items .. " items")
end

--@api: lurek.filesystem.listRecursive
do
    local files = lurek.filesystem.listRecursive("save")
    print("recursive: " .. #files .. " files")
end

--@api: lurek.filesystem.glob
do
    lurek.filesystem.write("save/glob_a.txt", "A")
    lurek.filesystem.write("save/glob_b.txt", "B")
    local matches = lurek.filesystem.glob("save/*.txt")
    print("glob matches: " .. #matches)
end

--@api: lurek.filesystem.lines
do
    local path = "save/test_write.txt"
    lurek.filesystem.write(path, "line1\nline2\nline3")
    local count = 0
    for _ in lurek.filesystem.lines(path) do count = count + 1 end
    print("lines: " .. count)
end

--@api: lurek.filesystem.createTempFile
do
    local tmp = lurek.filesystem.createTempFile("test_")
    print("temp file = " .. tmp)
end

--@api: lurek.filesystem.readJson
do
    local path = "save/options.json"
    lurek.filesystem.writeJson(path, '{"name":"test","value":42}')
    local data = lurek.filesystem.readJson(path)
    print("readJson type = " .. type(data))
    print("json bytes = " .. #data)
end

--@api: lurek.filesystem.writeJson
do
    local path = "save/test_json.json"
    lurek.filesystem.writeJson(path, '{"name":"test","value":42}')
    print("wrote JSON to " .. path)
end

--@api: lurek.filesystem.readOrWriteJson
do
    local path = "save/settings.json"
    local data = lurek.filesystem.readOrWriteJson(path, '{"volume":80,"fullscreen":false}')
    print("settings json = " .. data)
    print("settings exists = " .. tostring(lurek.filesystem.exists(path)))
end

--- Filesystem Module Part 2: file handles, binary, async, mount, watch, load

--@api: lurek.filesystem.openFile
do
    local fh = lurek.filesystem.openFile("save/test_handle.txt", "w")
    fh:write("hello from handle")
    fh:close()
    print("file handle write done")
end

--@api: LFileHandle:read
do
    lurek.filesystem.write("save/test_handle.txt", "hello from handle")
    local fh = lurek.filesystem.openFile("save/test_handle.txt", "r")
    local data = fh:read()
    print("read: " .. data)
    fh:close()
end

--@api: LFileHandle:readLine
do
    lurek.filesystem.write("save/lines.txt", "alpha\nbeta\ngamma")
    local fh = lurek.filesystem.openFile("save/lines.txt", "r")
    local line = fh:readLine()
    print("first line: " .. line)
    fh:close()
end

--@api: LFileHandle:write
do
    local fh = lurek.filesystem.openFile("save/append_test.txt", "w")
    fh:write("part1")
    fh:write(" part2")
    fh:close()
    print("wrote via handle")
end

--@api: LFileHandle:seek
do
    lurek.filesystem.write("save/test_handle.txt", "hello from handle")
    local fh = lurek.filesystem.openFile("save/test_handle.txt", "r")
    fh:seek(5)
    local data = fh:read(4)
    print("from pos 5: " .. data)
    fh:close()
end

--@api: LFileHandle:tell
do
    lurek.filesystem.write("save/test_handle.txt", "hello from handle")
    local fh = lurek.filesystem.openFile("save/test_handle.txt", "r")
    fh:read(3)
    local pos = fh:tell()
    print("position = " .. pos)
    fh:close()
end

--@api: LFileHandle:getSize
do
    lurek.filesystem.write("save/test_handle.txt", "hello from handle")
    local fh = lurek.filesystem.openFile("save/test_handle.txt", "r")
    print("file size = " .. fh:getSize() .. " bytes")
    fh:close()
end

--@api: LFileHandle:getMode
do
    lurek.filesystem.write("save/test_handle.txt", "hello from handle")
    local fh = lurek.filesystem.openFile("save/test_handle.txt", "r")
    print("mode = " .. fh:getMode())
    fh:close()
end

--@api: LFileHandle:isEOF
do
    lurek.filesystem.write("save/test_handle.txt", "hello from handle")
    local fh = lurek.filesystem.openFile("save/test_handle.txt", "r")
    fh:read()
    print("eof = " .. tostring(fh:isEOF()))
    fh:close()
end

--@api: LFileHandle:flush
do
    local fh = lurek.filesystem.openFile("save/flush_test.txt", "w")
    fh:write("buffered data")
    fh:flush()
    fh:close()
    print("flushed")
end

--@api: LFileHandle:close
do
    local fh = lurek.filesystem.openFile("save/close_test.txt", "w")
    fh:write("done")
    fh:close()
    print("closed")
end

--@api: LFileHandle:type
do
    lurek.filesystem.write("save/test_handle.txt", "hello from handle")
    local fh = lurek.filesystem.openFile("save/test_handle.txt", "r")
    print("type = " .. fh:type())
    fh:close()
end

--@api: LFileHandle:typeOf
do
    lurek.filesystem.write("save/test_handle.txt", "hello from handle")
    local fh = lurek.filesystem.openFile("save/test_handle.txt", "r")
    print("is FileHandle = " .. tostring(fh:typeOf("LFileHandle")))
    fh:close()
end

--@api: lurek.filesystem.newFileData
do
    lurek.filesystem.write("save/test_handle.txt", "hello from handle")
    local fd = lurek.filesystem.newFileData("save/test_handle.txt")
    print("filedata size = " .. fd:getSize())
end

--@api: LFileData:getSize
do
    lurek.filesystem.write("save/test_handle.txt", "hello from handle")
    local fd = lurek.filesystem.newFileData("save/test_handle.txt")
    print("size = " .. fd:getSize())
end

--@api: LFileData:getString
do
    lurek.filesystem.write("save/test_handle.txt", "hello from handle")
    local fd = lurek.filesystem.newFileData("save/test_handle.txt")
    local str = fd:getString()
    print("content = " .. str)
end

--@api: LFileData:getFilename
do
    lurek.filesystem.write("save/test_handle.txt", "hello from handle")
    local fd = lurek.filesystem.newFileData("save/test_handle.txt")
    print("filename = " .. fd:getFilename())
end

--@api: LFileData:type
do
    lurek.filesystem.write("save/test_handle.txt", "hello from handle")
    local fd = lurek.filesystem.newFileData("save/test_handle.txt")
    print("type = " .. fd:type())
end

--@api: LFileData:typeOf
do
    lurek.filesystem.write("save/test_handle.txt", "hello from handle")
    local fd = lurek.filesystem.newFileData("save/test_handle.txt")
    print("is FileData = " .. tostring(fd:typeOf("LFileData")))
end

--@api: lurek.filesystem.readBytes
do
    lurek.filesystem.write("save/test_handle.txt", "hello from handle")
    local bytes = lurek.filesystem.readBytes("save/test_handle.txt")
    print("binary read " .. #bytes .. " bytes")
end

--@api: lurek.filesystem.writeBytes
do
    lurek.filesystem.writeBytes("save/binary.bin", "\x00\x01\x02\x03")
    print("wrote 4 binary bytes")
end

--@api: lurek.filesystem.readAsync
do
    lurek.filesystem.write("save/test_handle.txt", "hello from handle")
    local ticket = lurek.filesystem.readAsync("save/test_handle.txt")
    print("async read ticket = " .. ticket)
end

--@api: lurek.filesystem.pollAsync
do
    lurek.filesystem.write("save/test_handle.txt", "hello from handle")
    local ticket = lurek.filesystem.readAsync("save/test_handle.txt")
    local result = lurek.filesystem.pollAsync(ticket)
    print("poll result = " .. tostring(result))
end

--@api: lurek.filesystem.writeAsync
do
    local ticket = lurek.filesystem.writeAsync("save/async_out.txt", "async data")
    print("async write ticket = " .. ticket)
end

--@api: lurek.filesystem.pollAsyncWrite
do
    local ticket = lurek.filesystem.writeAsync("save/async_out.txt", "data")
    local result = lurek.filesystem.pollAsyncWrite(ticket)
    print("write poll = " .. tostring(result))
end

--@api: lurek.filesystem.mount
do
    local ok = lurek.filesystem.mount("content/examples/assets", "game_assets")
    print("mount ok = " .. tostring(ok))
end

--@api: lurek.filesystem.unmount
do
    local ok = lurek.filesystem.unmount("game_assets")
    print("unmount ok = " .. tostring(ok))
end

--@api: lurek.filesystem.mountZip
do
    local zip = lurek.filesystem.mountZip("content/examples/assets/data/sample_data.zip", "data")
    print("zip prefix = " .. zip:prefix())
end

--@api: LZipMount:readFile
do
    local zip = lurek.filesystem.mountZip("content/examples/assets/data/sample_data.zip", "data")
    local ok, txt = pcall(function() return zip:readFile("data/sample_hello.txt") end)
    print("zip read bytes: " .. (ok and txt and tostring(#txt) or "unavailable"))
end

--@api: LZipMount:contains
do
    local zip = lurek.filesystem.mountZip("content/examples/assets/data/sample_data.zip", "data")
    print("has hello = " .. tostring(zip:contains("data/sample_hello.txt")))
end

--@api: LZipMount:listFiles
do
    local zip = lurek.filesystem.mountZip("content/examples/assets/data/sample_data.zip", "data")
    local files = zip:listFiles()
    print("zip files: " .. #files)
end

--@api: LZipMount:prefix
do
    local zip = lurek.filesystem.mountZip("content/examples/assets/data/sample_data.zip", "data")
    print("prefix = " .. zip:prefix())
end

--@api: LZipMount:type
do
    local zip = lurek.filesystem.mountZip("content/examples/assets/data/sample_data.zip", "data")
    print("type = " .. zip:type())
end

--@api: LZipMount:typeOf
do
    local zip = lurek.filesystem.mountZip("content/examples/assets/data/sample_data.zip", "data")
    print("is ZipMount = " .. tostring(zip:typeOf("LZipMount")))
end

--@api: lurek.filesystem.load
do
    local path = "save/hello.lua"
    lurek.filesystem.write(path, "return 'hello from save'\n")
    local chunk = lurek.filesystem.load(path)
    print("loaded chunk type = " .. type(chunk))
end

--@api: lurek.filesystem.watchPath
do
    lurek.filesystem.watchPath("save")
    print("watching save/")
end

--@api: lurek.filesystem.unwatchPath
do
    lurek.filesystem.unwatchPath("save")
    print("unwatched save/")
end

--@api: lurek.filesystem.pollWatchers
do
    lurek.filesystem.watchPath("save")
    local changed = lurek.filesystem.pollWatchers()
    print("changed paths: " .. #changed)
    lurek.filesystem.unwatchPath("save")
end
