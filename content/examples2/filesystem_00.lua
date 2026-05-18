--- Filesystem Module Part 1: paths, read/write, directory ops

--@api-stub: lurek.filesystem.getSource
-- Returns the game source directory path.
do
    local src = lurek.filesystem.getSource()
    print("source = " .. src)
end

--@api-stub: lurek.filesystem.getSaveDirectory
-- Returns the save directory path.
do
    local save = lurek.filesystem.getSaveDirectory()
    print("save dir = " .. save)
end

--@api-stub: lurek.filesystem.getWorkingDirectory
-- Returns the current working directory.
do
    local cwd = lurek.filesystem.getWorkingDirectory()
    print("cwd = " .. cwd)
end

--@api-stub: lurek.filesystem.getUserDirectory
-- Returns the user home directory.
do
    local home = lurek.filesystem.getUserDirectory()
    print("home = " .. home)
end

--@api-stub: lurek.filesystem.getIdentity
-- Returns the current game identity string.
do
    local id = lurek.filesystem.getIdentity()
    print("identity = " .. id)
end

--@api-stub: lurek.filesystem.setIdentity
-- Sets the game identity used for save directory naming.
do
    lurek.filesystem.setIdentity("my_game")
    print("identity set to 'my_game'")
end

--@api-stub: lurek.filesystem.toAbsolutePath
-- Converts a relative path to an absolute path.
do
    local abs = lurek.filesystem.toAbsolutePath("data/config.toml")
    print("absolute = " .. abs)
end

--@api-stub: lurek.filesystem.exists
-- Checks whether a file or directory exists.
do
    local path = "save/options.json"
    local found = lurek.filesystem.exists(path)
    print(path .. " exists = " .. tostring(found))
end

--@api-stub: lurek.filesystem.isFile
-- Checks whether a path is a file.
do
    local path = "save/options.json"
    print("is file = " .. tostring(lurek.filesystem.isFile(path)))
end

--@api-stub: lurek.filesystem.isDirectory
-- Checks whether a path is a directory.
do
    local path = "save"
    print("is dir = " .. tostring(lurek.filesystem.isDirectory(path)))
end

--@api-stub: lurek.filesystem.getInfo
-- Returns info table for a path (type, size, modtime).
do
    local path = "save/options.json"
    local info = lurek.filesystem.getInfo(path)
    if info then
        print("type=" .. info.type .. " size=" .. info.size)
    end
end

--@api-stub: lurek.filesystem.stat
-- Returns stat table for a path (size, isFile, isDir).
do
    local path = "save/options.json"
    local st = lurek.filesystem.stat(path)
    if st then
        print("stat size=" .. st.size .. " isFile=" .. tostring(st.isFile))
    end
end

--@api-stub: lurek.filesystem.read
-- Reads a file and returns its contents as a string.
do
    local path = "save/options.json"
    local contents = lurek.filesystem.read(path)
    print("read " .. #contents .. " bytes")
end

--@api-stub: lurek.filesystem.write
-- Writes a string to a file (creates or overwrites).
do
    local path = "save/test_write.txt"
    lurek.filesystem.write(path, "hello world")
    print("wrote to " .. path)
end

--@api-stub: lurek.filesystem.append
-- Appends a string to an existing file.
do
    local path = "save/test_write.txt"
    lurek.filesystem.append(path, "\nline 2")
    print("appended to " .. path)
end

--@api-stub: lurek.filesystem.copy
-- Copies a file from source to destination.
do
    local ok = lurek.filesystem.copy("save/test_write.txt", "save/test_copy.txt")
    print("copy ok = " .. tostring(ok))
end

--@api-stub: lurek.filesystem.move
-- Moves (renames) a file.
do
    local ok = lurek.filesystem.move("save/test_copy.txt", "save/test_moved.txt")
    print("move ok = " .. tostring(ok))
end

--@api-stub: lurek.filesystem.remove
-- Removes a file.
do
    local ok = lurek.filesystem.remove("save/test_moved.txt")
    print("remove ok = " .. tostring(ok))
end

--@api-stub: lurek.filesystem.createDirectory
-- Creates a directory.
do
    local ok = lurek.filesystem.createDirectory("save/new_dir")
    print("mkdir ok = " .. tostring(ok))
end

--@api-stub: lurek.filesystem.mkdir
-- Alias for createDirectory.
do
    local ok = lurek.filesystem.mkdir("save/another_dir")
    print("mkdir ok = " .. tostring(ok))
end

--@api-stub: lurek.filesystem.removeDir
-- Removes a directory.
do
    local ok = lurek.filesystem.removeDir("save/another_dir")
    print("removeDir ok = " .. tostring(ok))
end

--@api-stub: lurek.filesystem.getDirectoryItems
-- Lists items in a directory.
do
    local items = lurek.filesystem.getDirectoryItems("save")
    print("save/ has " .. #items .. " items")
    for _, name in ipairs(items) do
        print("  " .. name)
    end
end

--@api-stub: lurek.filesystem.listRecursive
-- Lists all files recursively under a path.
do
    local files = lurek.filesystem.listRecursive("save")
    print("recursive: " .. #files .. " files")
end

--@api-stub: lurek.filesystem.glob
-- Returns files matching a glob pattern.
do
    local matches = lurek.filesystem.glob("save/*.txt")
    print("glob matches: " .. #matches)
end

--@api-stub: lurek.filesystem.lines
-- Returns an iterator over lines in a file.
do
    local path = "save/test_write.txt"
    lurek.filesystem.write(path, "line1\nline2\nline3")
    local count = 0
    for line in lurek.filesystem.lines(path) do
        count = count + 1
    end
    print("lines: " .. count)
end

--@api-stub: lurek.filesystem.createTempFile
-- Creates a temporary file and returns its path.
do
    local tmp = lurek.filesystem.createTempFile("test_")
    print("temp file = " .. tmp)
end

--@api-stub: lurek.filesystem.readJson
-- Reads and parses a JSON file.
do
    local path = "save/options.json"
    local data = lurek.filesystem.readJson(path)
    print("readJson type = " .. type(data))
end

--@api-stub: lurek.filesystem.writeJson
-- Writes JSON text to a file.
do
    local path = "save/test_json.json"
    lurek.filesystem.writeJson(path, '{"name":"test","value":42}')
    print("wrote JSON to " .. path)
end

--@api-stub: lurek.filesystem.readOrWriteJson
-- Reads JSON or writes default text if the file doesn't exist.
do
    local path = "save/settings.json"
    local data = lurek.filesystem.readOrWriteJson(path, '{"volume":80,"fullscreen":false}')
    print("settings json = " .. data)
end

print("filesystem_00.lua")
