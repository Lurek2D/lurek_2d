-- content/examples/filesystem.lua
-- love2d-style usage snippets for the lurek.filesystem API (54 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/filesystem.lua

-- ── lurek.filesystem.* functions ──

--@api-stub: lurek.filesystem.mountZip
-- Mounts a ZIP archive at a virtual path prefix, making its contents readable.
-- See the module spec for detailed semantics.
local result = lurek.filesystem.mountZip("save/data.txt", prefix)
print("mountZip:", result)
return result

--@api-stub: lurek.filesystem.watchPath
-- Adds `path` to the polled file-watch list.
-- See the module spec for detailed semantics.
local result = lurek.filesystem.watchPath("save/data.txt")
print("watchPath:", result)
return result

--@api-stub: lurek.filesystem.unwatchPath
-- Removes `path` from the polled file-watch list.
-- See the module spec for detailed semantics.
local result = lurek.filesystem.unwatchPath("save/data.txt")
print("unwatchPath:", result)
return result

--@api-stub: lurek.filesystem.pollWatchers
-- Polls all watched paths and returns an array of paths that changed since the.
-- See the module spec for detailed semantics.
local result = lurek.filesystem.pollWatchers()
print("pollWatchers:", result)
return result

--@api-stub: lurek.filesystem.read
-- Reads a text file and returns its contents as a string.
-- Cheap to call; safe inside callbacks.
local data = lurek.filesystem.read("save/level1.json")
if data then
  level = lurek.serial.fromJson(data)
end

--@api-stub: lurek.filesystem.write
-- Writes a string to a file in the save directory.
-- See the module spec for detailed semantics.
local score = 1234
lurek.filesystem.write("save/score.txt", tostring(score))
-- save/ folder is sandboxed per game
print("ok")

--@api-stub: lurek.filesystem.exists
-- Returns whether the given file or directory exists.
-- See the module spec for detailed semantics.
if lurek.filesystem.exists("save/profile.json") then
  loadProfile()
end

--@api-stub: lurek.filesystem.append
-- Opens the file in append mode and writes the given string at the end.
-- Side-effecting; safe to call any time after init.
lurek.filesystem.append("save/data.txt", { x = 0, y = 0 })
-- mutator; side effect applied
print("append done")
print("ok")

--@api-stub: lurek.filesystem.openFile
-- Opens a file and returns a readable/writable file handle.
-- Build once at startup; reuse across frames.
local openfile = lurek.filesystem.openFile("save/data.txt", mode)
print("created", openfile)
return openfile

--@api-stub: lurek.filesystem.getDirectoryItems
-- Returns a table containing the names of every file and subdirectory in the given path.
-- Cheap to call; safe inside callbacks.
local value = lurek.filesystem.getDirectoryItems("save/data.txt")
print("getDirectoryItems:", value)
return value

--@api-stub: lurek.filesystem.isFile
-- Returns whether the given path is a regular file.
-- Use as a guard inside lurek.update or event handlers.
if lurek.filesystem.isFile("save/data.txt") then
  print("isFile -> true")
end

--@api-stub: lurek.filesystem.isDirectory
-- Returns whether the given path is a directory.
-- Use as a guard inside lurek.update or event handlers.
if lurek.filesystem.isDirectory("save/data.txt") then
  print("isDirectory -> true")
end

--@api-stub: lurek.filesystem.createDirectory
-- Creates a directory and any missing parent directories in the save area.
-- Build once at startup; reuse across frames.
local createdirectory = lurek.filesystem.createDirectory("save/data.txt")
print("created", createdirectory)
return createdirectory

--@api-stub: lurek.filesystem.remove
-- Permanently deletes a file or empty directory from the save directory.
-- Pair with the matching constructor to free resources.
-- release the resource and forget the handle
lurek.filesystem.remove("save/data.txt")
print("remove done")
print("ok")

--@api-stub: lurek.filesystem.getInfo
-- Returns a table of metadata for a path, or nil if the path does not exist.
-- Cheap to call; safe inside callbacks.
local value = lurek.filesystem.getInfo("save/data.txt")
print("getInfo:", value)
return value

--@api-stub: lurek.filesystem.getSource
-- Returns the absolute path of the directory the game was loaded from.
-- Cheap to call; safe inside callbacks.
local value = lurek.filesystem.getSource()
print("getSource:", value)
return value

--@api-stub: lurek.filesystem.getSaveDirectory
-- Returns the sandboxed save data directory path.
-- Cheap to call; safe inside callbacks.
local value = lurek.filesystem.getSaveDirectory()
print("getSaveDirectory:", value)
return value

--@api-stub: lurek.filesystem.getWorkingDirectory
-- Returns the current working directory path.
-- Cheap to call; safe inside callbacks.
local value = lurek.filesystem.getWorkingDirectory()
print("getWorkingDirectory:", value)
return value

--@api-stub: lurek.filesystem.getUserDirectory
-- Returns the current user's home directory path.
-- Cheap to call; safe inside callbacks.
local value = lurek.filesystem.getUserDirectory()
print("getUserDirectory:", value)
return value

--@api-stub: lurek.filesystem.getIdentity
-- Returns the identity string used to locate the game's save directory.
-- Cheap to call; safe inside callbacks.
local value = lurek.filesystem.getIdentity()
print("getIdentity:", value)
return value

--@api-stub: lurek.filesystem.setIdentity
-- Sets the identity string that names the game's sandboxed save-data directory.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.filesystem.setIdentity("save/data.txt")
print("setIdentity applied")
print("ok")

--@api-stub: lurek.filesystem.lines
-- Returns an iterator function over the lines of a text file.
-- See the module spec for detailed semantics.
local result = lurek.filesystem.lines("save/data.txt")
print("lines:", result)
return result

--@api-stub: lurek.filesystem.readAsync
-- Starts loading a file in the background and returns an opaque handle.
-- Cheap to call; safe inside callbacks.
local value = lurek.filesystem.readAsync("save/data.txt")
print("readAsync:", value)
return value

--@api-stub: lurek.filesystem.pollAsync
-- Polls an async load handle, returning status and optional data.
-- See the module spec for detailed semantics.
local result = lurek.filesystem.pollAsync(1)
print("pollAsync:", result)
return result

--@api-stub: lurek.filesystem.mount
-- Mounts a directory at a virtual path inside the game filesystem.
-- See the module spec for detailed semantics.
local result = lurek.filesystem.mount(src, mp)
print("mount:", result)
return result

--@api-stub: lurek.filesystem.unmount
-- Removes a virtual mount layer by mountpoint.
-- See the module spec for detailed semantics.
local result = lurek.filesystem.unmount(mp)
print("unmount:", result)
return result

--@api-stub: lurek.filesystem.load
-- Loads and compiles a Lua file from the VFS, returning it as a callable function.
-- May block — call from a worker thread for large payloads.
local result = lurek.filesystem.load("save/data.txt")
-- may block; consider lurek.thread for large payloads
print("load:", result)
print("ok")

--@api-stub: lurek.filesystem.newFileData
-- Loads a file from the VFS into a FileData buffer.
-- Build once at startup; reuse across frames.
local filedata = lurek.filesystem.newFileData("save/data.txt")
print("created", filedata)
return filedata

--@api-stub: lurek.filesystem.copy
-- Copies a file within the sandbox.
-- See the module spec for detailed semantics.
local result = lurek.filesystem.copy(src, dst)
print("copy:", result)
return result

--@api-stub: lurek.filesystem.move
-- Moves (renames) a file within the `save/` directory.
-- See the module spec for detailed semantics.
local result = lurek.filesystem.move(src, dst)
print("move:", result)
return result

--@api-stub: lurek.filesystem.removeDir
-- Recursively deletes a directory and all its contents within `save/`.
-- Pair with the matching constructor to free resources.
-- release the resource and forget the handle
lurek.filesystem.removeDir("save/data.txt")
print("removeDir done")
print("ok")

--@api-stub: lurek.filesystem.glob
-- Returns a sorted list of paths matching a simple wildcard pattern.
-- See the module spec for detailed semantics.
local result = lurek.filesystem.glob(pattern)
print("glob:", result)
return result

--@api-stub: lurek.filesystem.listRecursive
-- Returns a sorted list of all files under `path`, recursively.
-- See the module spec for detailed semantics.
local result = lurek.filesystem.listRecursive("save/data.txt")
print("listRecursive:", result)
return result

--@api-stub: lurek.filesystem.stat
-- Returns lightweight file statistics for the given path.
-- See the module spec for detailed semantics.
local result = lurek.filesystem.stat("save/data.txt")
print("stat:", result)
return result

--@api-stub: lurek.filesystem.createTempFile
-- Creates an empty temporary file in the `save/` sandbox and returns its.
-- Build once at startup; reuse across frames.
local createtempfile = lurek.filesystem.createTempFile(prefix)
print("created", createtempfile)
return createtempfile

--@api-stub: lurek.filesystem.mkdir
-- Creates a directory (and any missing parents) relative to the game root.
-- See the module spec for detailed semantics.
lurek.filesystem.mkdir("save/screenshots")
lurek.filesystem.mkdir("save/replays")
-- safe: no error if dir already exists
print("ok")

--@api-stub: lurek.filesystem.toAbsolutePath
-- Resolves a path relative to the game root to an absolute OS path string.
-- See the module spec for detailed semantics.
local result = lurek.filesystem.toAbsolutePath("save/data.txt")
print("toAbsolutePath:", result)
return result

-- ── FileData methods ──

--@api-stub: FileData:getSize
-- Returns the file size in bytes.
-- Cheap to call; safe inside callbacks.
local fileData = lurek.filesystem.newFileData()  -- or your existing handle
local value = fileData:getSize()
print("FileData:getSize ->", value)

--@api-stub: FileData:getString
-- Returns the file content as a Lua string.
-- Cheap to call; safe inside callbacks.
local fileData = lurek.filesystem.newFileData()  -- or your existing handle
local value = fileData:getString()
print("FileData:getString ->", value)

--@api-stub: FileData:getFilename
-- Returns the virtual path this data was loaded from.
-- Cheap to call; safe inside callbacks.
local fileData = lurek.filesystem.newFileData()  -- or your existing handle
local value = fileData:getFilename()
print("FileData:getFilename ->", value)

-- ── FileHandle methods ──

--@api-stub: FileHandle:read
-- Reads bytes from the file, returning them as a string.
-- Cheap to call; safe inside callbacks.
local fileHandle = lurek.filesystem.newFileHandle()  -- or your existing handle
local value = fileHandle:read(10)
print("FileHandle:read ->", value)

--@api-stub: FileHandle:readLine
-- Reads the next line from the file without the trailing newline.
-- Cheap to call; safe inside callbacks.
local fileHandle = lurek.filesystem.newFileHandle()  -- or your existing handle
local value = fileHandle:readLine()
print("FileHandle:readLine ->", value)

--@api-stub: FileHandle:write
-- Writes a string to the file and returns the number of bytes written.
-- See the module spec for detailed semantics.
local fileHandle = lurek.filesystem.newFileHandle()
fileHandle:write({ x = 0, y = 0 })
print("FileHandle:write done")

--@api-stub: FileHandle:seek
-- Seeks the file position to the given byte offset from the start.
-- See the module spec for detailed semantics.
local fileHandle = lurek.filesystem.newFileHandle()
fileHandle:seek(pos)
print("FileHandle:seek done")

--@api-stub: FileHandle:tell
-- Returns the current read/write byte offset from the start of the file.
-- See the module spec for detailed semantics.
local fileHandle = lurek.filesystem.newFileHandle()
fileHandle:tell()
print("FileHandle:tell done")

--@api-stub: FileHandle:getSize
-- Returns the size of the open file in bytes.
-- Cheap to call; safe inside callbacks.
local fileHandle = lurek.filesystem.newFileHandle()  -- or your existing handle
local value = fileHandle:getSize()
print("FileHandle:getSize ->", value)

--@api-stub: FileHandle:getMode
-- Returns the access mode the file was opened with.
-- Cheap to call; safe inside callbacks.
local fileHandle = lurek.filesystem.newFileHandle()  -- or your existing handle
local value = fileHandle:getMode()
print("FileHandle:getMode ->", value)

--@api-stub: FileHandle:flush
-- Flushes all buffered writes to disk without closing the handle.
-- See the module spec for detailed semantics.
local fileHandle = lurek.filesystem.newFileHandle()
fileHandle:flush()
print("FileHandle:flush done")

--@api-stub: FileHandle:close
-- Flushes any pending writes and closes the file handle.
-- See the module spec for detailed semantics.
local fileHandle = lurek.filesystem.newFileHandle()
fileHandle:close()
print("FileHandle:close done")

--@api-stub: FileHandle:isEOF
-- Returns whether the read cursor has reached the end of the file.
-- Use as a guard inside lurek.update or event handlers.
local fileHandle = lurek.filesystem.newFileHandle()
if fileHandle:isEOF() then print("yes") end
-- swap the constructor for your real handle
print("ok")

-- ── ZipMount methods ──

--@api-stub: ZipMount:readFile
-- Reads a file from the ZIP and returns it as a string of bytes.
-- Cheap to call; safe inside callbacks.
local zipMount = lurek.filesystem.newZipMount()  -- or your existing handle
local value = zipMount:readFile("save/data.txt")
print("ZipMount:readFile ->", value)

--@api-stub: ZipMount:contains
-- Returns true if `virtual_path` exists inside this ZIP mount.
-- See the module spec for detailed semantics.
local zipMount = lurek.filesystem.newZipMount()
zipMount:contains("save/data.txt")
print("ZipMount:contains done")

--@api-stub: ZipMount:listFiles
-- Returns a sorted array of all virtual paths exposed by this ZIP mount.
-- See the module spec for detailed semantics.
local zipMount = lurek.filesystem.newZipMount()
zipMount:listFiles()
print("ZipMount:listFiles done")

--@api-stub: ZipMount:prefix
-- Returns the virtual path prefix this archive was mounted under.
-- See the module spec for detailed semantics.
local zipMount = lurek.filesystem.newZipMount()
zipMount:prefix()
print("ZipMount:prefix done")

