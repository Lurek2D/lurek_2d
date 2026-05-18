--- Filesystem Module Part 2: file handles, binary, async, mount, watch, load

--@api-stub: lurek.filesystem.openFile
-- Opens a file handle in a requested mode.
do
    local fh = lurek.filesystem.openFile("save/test_handle.txt", "w")
    fh:write("hello from handle")
    fh:close()
    print("file handle write done")
end

--@api-stub: LFileHandle:read
-- Reads bytes from a file handle.
do
    local fh = lurek.filesystem.openFile("save/test_handle.txt", "r")
    local data = fh:read()
    print("read: " .. data)
    fh:close()
end

--@api-stub: LFileHandle:readLine
-- Reads the next line from a file handle.
do
    lurek.filesystem.write("save/lines.txt", "alpha\nbeta\ngamma")
    local fh = lurek.filesystem.openFile("save/lines.txt", "r")
    local line = fh:readLine()
    print("first line: " .. line)
    fh:close()
end

--@api-stub: LFileHandle:write
-- Writes a string to a file handle.
do
    local fh = lurek.filesystem.openFile("save/append_test.txt", "w")
    fh:write("part1")
    fh:write(" part2")
    fh:close()
    print("wrote via handle")
end

--@api-stub: LFileHandle:seek
-- Moves the file cursor to an absolute byte position.
do
    local fh = lurek.filesystem.openFile("save/test_handle.txt", "r")
    fh:seek(5)
    local data = fh:read(4)
    print("from pos 5: " .. data)
    fh:close()
end

--@api-stub: LFileHandle:tell
-- Returns the current cursor position.
do
    local fh = lurek.filesystem.openFile("save/test_handle.txt", "r")
    fh:read(3)
    local pos = fh:tell()
    print("position = " .. pos)
    fh:close()
end

--@api-stub: LFileHandle:getSize
-- Returns the size of the open file.
do
    local fh = lurek.filesystem.openFile("save/test_handle.txt", "r")
    print("file size = " .. fh:getSize() .. " bytes")
    fh:close()
end

--@api-stub: LFileHandle:getMode
-- Returns the mode used to open this handle.
do
    local fh = lurek.filesystem.openFile("save/test_handle.txt", "r")
    print("mode = " .. fh:getMode())
    fh:close()
end

--@api-stub: LFileHandle:isEOF
-- Returns whether the cursor is at end of file.
do
    local fh = lurek.filesystem.openFile("save/test_handle.txt", "r")
    fh:read()
    print("eof = " .. tostring(fh:isEOF()))
    fh:close()
end

--@api-stub: LFileHandle:flush
-- Flushes pending writes.
do
    local fh = lurek.filesystem.openFile("save/flush_test.txt", "w")
    fh:write("buffered data")
    fh:flush()
    fh:close()
    print("flushed")
end

--@api-stub: LFileHandle:close
-- Closes the file handle.
do
    local fh = lurek.filesystem.openFile("save/close_test.txt", "w")
    fh:write("done")
    fh:close()
    print("closed")
end

--@api-stub: LFileHandle:type
-- Returns the type name "LFileHandle".
do
    local fh = lurek.filesystem.openFile("save/test_handle.txt", "r")
    print("type = " .. fh:type())
    fh:close()
end

--@api-stub: LFileHandle:typeOf
-- Returns whether this handle matches a type name.
do
    local fh = lurek.filesystem.openFile("save/test_handle.txt", "r")
    print("is FileHandle = " .. tostring(fh:typeOf("FileHandle")))
    fh:close()
end

--@api-stub: lurek.filesystem.newFileData
-- Loads a file into an immutable file data handle.
do
    local fd = lurek.filesystem.newFileData("save/test_handle.txt")
    print("filedata size = " .. fd:getSize())
end

--@api-stub: LFileData:getSize
-- Returns the byte length of file data.
do
    local fd = lurek.filesystem.newFileData("save/test_handle.txt")
    print("size = " .. fd:getSize())
end

--@api-stub: LFileData:getString
-- Returns file data bytes as a string.
do
    local fd = lurek.filesystem.newFileData("save/test_handle.txt")
    local str = fd:getString()
    print("content = " .. str)
end

--@api-stub: LFileData:getFilename
-- Returns the path associated with file data.
do
    local fd = lurek.filesystem.newFileData("save/test_handle.txt")
    print("filename = " .. fd:getFilename())
end

--@api-stub: LFileData:type
-- Returns the type name "LFileData".
do
    local fd = lurek.filesystem.newFileData("save/test_handle.txt")
    print("type = " .. fd:type())
end

--@api-stub: LFileData:typeOf
-- Returns whether this file data matches a type name.
do
    local fd = lurek.filesystem.newFileData("save/test_handle.txt")
    print("is FileData = " .. tostring(fd:typeOf("FileData")))
end

--@api-stub: lurek.filesystem.readBytes
-- Reads binary file bytes as a Lua string.
do
    local bytes = lurek.filesystem.readBytes("save/test_handle.txt")
    print("binary read " .. #bytes .. " bytes")
end

--@api-stub: lurek.filesystem.writeBytes
-- Writes binary data to a file.
do
    lurek.filesystem.writeBytes("save/binary.bin", "\x00\x01\x02\x03")
    print("wrote 4 binary bytes")
end

--@api-stub: lurek.filesystem.readAsync
-- Starts an asynchronous file read request.
do
    local ticket = lurek.filesystem.readAsync("save/test_handle.txt")
    print("async read ticket = " .. ticket)
end

--@api-stub: lurek.filesystem.pollAsync
-- Polls an async read request.
do
    local ticket = lurek.filesystem.readAsync("save/test_handle.txt")
    local result = lurek.filesystem.pollAsync(ticket)
    print("poll result = " .. tostring(result))
end

--@api-stub: lurek.filesystem.writeAsync
-- Starts an asynchronous file write request.
do
    local ticket = lurek.filesystem.writeAsync("save/async_out.txt", "async data")
    print("async write ticket = " .. ticket)
end

--@api-stub: lurek.filesystem.pollAsyncWrite
-- Polls an async write request.
do
    local ticket = lurek.filesystem.writeAsync("save/async_out.txt", "data")
    local result = lurek.filesystem.pollAsyncWrite(ticket)
    print("write poll = " .. tostring(result))
end

--@api-stub: lurek.filesystem.mount
-- Mounts an external path at a virtual mount point.
do
    local ok = lurek.filesystem.mount("assets", "game_assets")
    print("mount ok = " .. tostring(ok))
end

--@api-stub: lurek.filesystem.unmount
-- Removes a virtual mount point.
do
    local ok = lurek.filesystem.unmount("game_assets")
    print("unmount ok = " .. tostring(ok))
end

--@api-stub: lurek.filesystem.mountZip
-- Mounts a ZIP archive at a virtual prefix.
do
    local zip = lurek.filesystem.mountZip("assets/data.zip", "data")
    print("zip prefix = " .. zip:prefix())
end

--@api-stub: LZipMount:readFile
-- Reads a file from the ZIP mount.
do
    local zip = lurek.filesystem.mountZip("assets/data.zip", "data")
    local txt = zip:readFile("readme.txt")
    print("zip read: " .. txt)
end

--@api-stub: LZipMount:contains
-- Checks if a virtual path exists in the ZIP mount.
do
    local zip = lurek.filesystem.mountZip("assets/data.zip", "data")
    print("has readme = " .. tostring(zip:contains("readme.txt")))
end

--@api-stub: LZipMount:listFiles
-- Lists all files in the ZIP mount.
do
    local zip = lurek.filesystem.mountZip("assets/data.zip", "data")
    local files = zip:listFiles()
    print("zip files: " .. #files)
end

--@api-stub: LZipMount:prefix
-- Returns the virtual prefix of this ZIP mount.
do
    local zip = lurek.filesystem.mountZip("assets/data.zip", "data")
    print("prefix = " .. zip:prefix())
end

--@api-stub: LZipMount:type
-- Returns the type name "LZipMount".
do
    local zip = lurek.filesystem.mountZip("assets/data.zip", "data")
    print("type = " .. zip:type())
end

--@api-stub: LZipMount:typeOf
-- Returns whether this ZIP mount matches a type name.
do
    local zip = lurek.filesystem.mountZip("assets/data.zip", "data")
    print("is ZipMount = " .. tostring(zip:typeOf("ZipMount")))
end

--@api-stub: lurek.filesystem.load
-- Loads a Lua chunk from a file and returns it as a function.
do
    local chunk = lurek.filesystem.load("content/examples/hello.lua")
    print("loaded chunk type = " .. type(chunk))
end

--@api-stub: lurek.filesystem.watchPath
-- Adds a path to the file watcher.
do
    lurek.filesystem.watchPath("save")
    print("watching save/")
end

--@api-stub: lurek.filesystem.unwatchPath
-- Removes a path from the file watcher.
do
    lurek.filesystem.unwatchPath("save")
    print("unwatched save/")
end

--@api-stub: lurek.filesystem.pollWatchers
-- Polls for changed paths from file watchers.
do
    lurek.filesystem.watchPath("save")
    local changed = lurek.filesystem.pollWatchers()
    print("changed paths: " .. #changed)
    lurek.filesystem.unwatchPath("save")
end

print("filesystem_01.lua")
