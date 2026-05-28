# Filesystem

- The `filesystem` module resides in the Core Runtime tier and implements `GameFS`, a strictly sandboxed virtual filesystem.

It provides the essential abstraction layer between Lua game scripts and the host operating system, ensuring that all file I/O is secure. By confining operations to a designated base game directory and a specific user save directory, `GameFS` actively prevents path-traversal attacks. It intercepts and validates every path component, rejecting any attempts to use `..`, symbolic links, or absolute prefixes that point outside the allowed security boundary. Violations immediately trigger an `EngineError::FsPathTraversal`.

Beyond security, the module offers a robust suite of filesystem operations. It supports synchronous and asynchronous file reads/writes, directory creation, flat and recursive listing, glob matching, and file copy/move operations. A notable feature is its support for virtual mount overlays: directories or read-only `.zip` archives (`ZipMount`) can be layered into the virtual filesystem at specified prefixes. When a file is requested, `GameFS` queries these layered mounts seamlessly, enabling modding, content patching, and asset packing without altering game logic.

To prevent blocking the main engine thread during expensive I/O operations, the module includes an `AsyncLoader`. This loader dispatches read and write requests to a dedicated background worker thread, returning opaque handles that scripts can poll for completion. For fine-grained file manipulation, `FileHandle` provides a buffered, cursor-based streaming API with discrete read, write, and append modes. Additionally, for hot-reload development workflows, a poll-based `FileWatcher` tracks modification-time (`mtime`) changes across registered paths, enabling real-time asset updates. The full functionality of the virtual filesystem, including JSON validation helpers and file metadata queries, is exposed to scripts via the `lurek.filesystem.*` API.

## Functions

### `lurek.filesystem.append`

Appends UTF-8 text to a GameFS file.

```lua
-- signature
lurek.filesystem.append(path, data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | GameFS path to append to. |
| `data` | `string` | Text to append. |

**Example**

```lua
do
    local path = "save/test_write.txt"
    lurek.filesystem.append(path, "\nline 2")
    print("appended to " .. path)
end
```

---

### `lurek.filesystem.copy`

Copies one GameFS file to another path.

```lua
-- signature
lurek.filesystem.copy(src, dst)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `src` | `string` | Source path. |
| `dst` | `string` | Destination path. |

**Example**

```lua
do
    lurek.filesystem.write("save/test_write.txt", "copy source")
    local ok = lurek.filesystem.copy("save/test_write.txt", "save/test_copy.txt")
    print("copy ok = " .. tostring(ok))
end
```

---

### `lurek.filesystem.createDirectory`

Creates a GameFS directory and any missing parents.

```lua
-- signature
lurek.filesystem.createDirectory(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | Directory path to create. |

**Example**

```lua
do
    local ok = lurek.filesystem.createDirectory("save/new_dir")
    print("mkdir ok = " .. tostring(ok))
end
```

---

### `lurek.filesystem.createTempFile`

Creates a temporary file through GameFS.

```lua
-- signature
lurek.filesystem.createTempFile(prefix)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `prefix?` | `string` | Optional filename prefix, defaulting to `tmp`. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | Created temporary file path. |

**Example**

```lua
do
    local tmp = lurek.filesystem.createTempFile("test_")
    print("temp file = " .. tmp)
end
```

---

### `lurek.filesystem.exists`

Returns whether a path exists in GameFS.

```lua
-- signature
lurek.filesystem.exists(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | GameFS path to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the path exists. |

**Example**

```lua
do
    local path = "save/options_exists.json"
    lurek.filesystem.write(path, "{\"ok\":true}")
    local found = lurek.filesystem.exists(path)
    print(path .. " exists = " .. tostring(found))
end
```

---

### `lurek.filesystem.getDirectoryItems`

Lists immediate entries in a GameFS directory.

```lua
-- signature
lurek.filesystem.getDirectoryItems(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | Directory path to list. |

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Entry names. |

**Example**

```lua
do
    local items = lurek.filesystem.getDirectoryItems("save")
    print("save/ has " .. #items .. " items")
end
```

---

### `lurek.filesystem.getIdentity`

Returns the current filesystem identity string.

```lua
-- signature
lurek.filesystem.getIdentity()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Filesystem identity used for save namespacing. |

**Example**

```lua
do
    local id = lurek.filesystem.getIdentity()
    print("identity = " .. id)
end
```

---

### `lurek.filesystem.getInfo`

Returns file metadata for a GameFS path when available.

```lua
-- signature
lurek.filesystem.getInfo(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | GameFS path to inspect. |

**Returns**

| Type | Description |
|------|-------------|
| `FilesystemGetInfoResult` | Metadata table with type, size, modtime, and readonly fields, or nil on error. |

**Example**

```lua
do
    local path = "save/info.txt"
    lurek.filesystem.write(path, "info sample")
    local info = lurek.filesystem.getInfo(path)
    if info then
        print("type=" .. info.type .. " size=" .. info.size)
    end
end
```

---

### `lurek.filesystem.getSaveDirectory`

Returns the save directory path used by GameFS.

```lua
-- signature
lurek.filesystem.getSaveDirectory()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Save directory path. |

**Example**

```lua
do
    local save = lurek.filesystem.getSaveDirectory()
    print("save dir = " .. save)
end
```

---

### `lurek.filesystem.getSource`

Returns the GameFS source root string.

```lua
-- signature
lurek.filesystem.getSource()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Source directory or source description. |

**Example**

```lua
do
    local src = lurek.filesystem.getSource()
    print("source = " .. src)
end
```

---

### `lurek.filesystem.getUserDirectory`

Returns the current user's directory path.

```lua
-- signature
lurek.filesystem.getUserDirectory()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | User directory path. |

**Example**

```lua
do
    local home = lurek.filesystem.getUserDirectory()
    print("home = " .. home)
end
```

---

### `lurek.filesystem.getWorkingDirectory`

Returns the process working directory.

```lua
-- signature
lurek.filesystem.getWorkingDirectory()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Working directory path. |

**Example**

```lua
do
    local cwd = lurek.filesystem.getWorkingDirectory()
    print("cwd = " .. cwd)
end
```

---

### `lurek.filesystem.glob`

Returns GameFS paths matching a glob pattern.

```lua
-- signature
lurek.filesystem.glob(pattern)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pattern` | `string` | Glob pattern. |

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Matching path strings. |

**Example**

```lua
do
    lurek.filesystem.write("save/glob_a.txt", "A")
    lurek.filesystem.write("save/glob_b.txt", "B")
    local matches = lurek.filesystem.glob("save/*.txt")
    print("glob matches: " .. #matches)
end
```

---

### `lurek.filesystem.isDirectory`

Returns whether a GameFS path is a directory.

```lua
-- signature
lurek.filesystem.isDirectory(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | GameFS path to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the path is a directory. |

**Example**

```lua
do
    local path = "save"
    print("is dir = " .. tostring(lurek.filesystem.isDirectory(path)))
end
```

---

### `lurek.filesystem.isFile`

Returns whether a GameFS path is a regular file.

```lua
-- signature
lurek.filesystem.isFile(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | GameFS path to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the path is a file. |

**Example**

```lua
do
    local path = "save/is_file.txt"
    lurek.filesystem.write(path, "hello")
    print("is file = " .. tostring(lurek.filesystem.isFile(path)))
end
```

---

### `lurek.filesystem.lines`

Creates an iterator function over lines in a text file.

```lua
-- signature
lurek.filesystem.lines(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | GameFS path to read. |

**Returns**

| Type | Description |
|------|-------------|
| `function` | Iterator returning the next line string or nil at EOF. |

**Example**

```lua
do
    local path = "save/test_write.txt"
    lurek.filesystem.write(path, "line1\nline2\nline3")
    local count = 0
    for _ in lurek.filesystem.lines(path) do count = count + 1 end
    print("lines: " .. count)
end
```

---

### `lurek.filesystem.listRecursive`

Lists all paths under a GameFS directory recursively.

```lua
-- signature
lurek.filesystem.listRecursive(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | Root directory path. |

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Path strings. |

**Example**

```lua
do
    local files = lurek.filesystem.listRecursive("save")
    print("recursive: " .. #files .. " files")
end
```

---

### `lurek.filesystem.load`

Loads a Lua chunk from GameFS and returns it as a Lua function.

```lua
-- signature
lurek.filesystem.load(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | GameFS path to a Lua script chunk. |

**Returns**

| Type | Description |
|------|-------------|
| `function` | Compiled Lua chunk function. |

**Example**

```lua
do
    local path = "save/hello.lua"
    lurek.filesystem.write(path, "return 'hello from save'\n")
    local chunk = lurek.filesystem.load(path)
    print("loaded chunk type = " .. type(chunk))
end
```

---

### `lurek.filesystem.mkdir`

Creates a directory under the GameFS base directory.

```lua
-- signature
lurek.filesystem.mkdir(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | Relative directory path to create. |

**Example**

```lua
do
    local ok = lurek.filesystem.mkdir("save/another_dir")
    print("mkdir ok = " .. tostring(ok))
end
```

---

### `lurek.filesystem.mount`

Mounts an external source path at a GameFS mount point.

```lua
-- signature
lurek.filesystem.mount(src, mp)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `src` | `string` | Source path to mount. |
| `mp` | `string` | Virtual mount point. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the mount succeeds. |

**Example**

```lua
do
    local ok = lurek.filesystem.mount("assets", "game_assets")
    print("mount ok = " .. tostring(ok))
end
```

---

### `lurek.filesystem.mountZip`

Opens a ZIP archive and exposes it through a virtual prefix.

```lua
-- signature
lurek.filesystem.mountZip(archive_path, prefix)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `archive_path` | `string` | Archive path on disk. |
| `prefix` | `string` | Virtual path prefix for archive contents. |

**Returns**

| Type | Description |
|------|-------------|
| `LZipMount` | New ZIP mount handle. |

**Example**

```lua
do
    local zip = lurek.filesystem.mountZip("content/examples/assets/data/sample_data.zip", "data")
    print("zip prefix = " .. zip:prefix())
end
```

---

### `lurek.filesystem.move`

Moves or renames one GameFS file to another path.

```lua
-- signature
lurek.filesystem.move(src, dst)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `src` | `string` | Source path. |
| `dst` | `string` | Destination path. |

**Example**

```lua
do
    lurek.filesystem.write("save/test_copy.txt", "move source")
    local ok = lurek.filesystem.move("save/test_copy.txt", "save/test_moved.txt")
    print("move ok = " .. tostring(ok))
end
```

---

### `lurek.filesystem.newFileData`

Loads a file into an immutable file data handle.

```lua
-- signature
lurek.filesystem.newFileData(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | GameFS path to load. |

**Returns**

| Type | Description |
|------|-------------|
| `LFileData` | New file data handle containing path and bytes. |

**Example**

```lua
do
    lurek.filesystem.write("save/test_handle.txt", "hello from handle")
    local fd = lurek.filesystem.newFileData("save/test_handle.txt")
    print("filedata size = " .. fd:getSize())
end
```

---

### `lurek.filesystem.openFile`

Opens a GameFS file handle in a requested mode.

```lua
-- signature
lurek.filesystem.openFile(path, mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | GameFS path to open. |
| `mode` | `string` | File mode understood by GameFS. |

**Returns**

| Type | Description |
|------|-------------|
| `LFileHandle` | Open file handle. |

**Example**

```lua
do
    local fh = lurek.filesystem.openFile("save/test_handle.txt", "w")
    fh:write("hello from handle")
    fh:close()
    print("file handle write done")
end
```

---

### `lurek.filesystem.pollAsync`

Polls an asynchronous file load request.

```lua
-- signature
lurek.filesystem.pollAsync(handle_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle_id` | `number` | Async load handle id. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | Completed bytes/result, pending marker, or nil depending on async state. |

**Example**

```lua
do
    lurek.filesystem.write("save/test_handle.txt", "hello from handle")
    local ticket = lurek.filesystem.readAsync("save/test_handle.txt")
    local result = lurek.filesystem.pollAsync(ticket)
    print("poll result = " .. tostring(result))
end
```

---

### `lurek.filesystem.pollAsyncWrite`

Polls an asynchronous file write request.

```lua
-- signature
lurek.filesystem.pollAsyncWrite(handle_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle_id` | `number` | Async write handle id. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | Completed status, pending marker, or nil depending on async state. |

**Example**

```lua
do
    local ticket = lurek.filesystem.writeAsync("save/async_out.txt", "data")
    local result = lurek.filesystem.pollAsyncWrite(ticket)
    print("write poll = " .. tostring(result))
end
```

---

### `lurek.filesystem.pollWatchers`

Polls watched paths and returns paths that changed since the previous poll.

```lua
-- signature
lurek.filesystem.pollWatchers()
```

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Changed path strings. |

**Example**

```lua
do
    lurek.filesystem.watchPath("save")
    local changed = lurek.filesystem.pollWatchers()
    print("changed paths: " .. #changed)
    lurek.filesystem.unwatchPath("save")
end
```

---

### `lurek.filesystem.read`

Reads a UTF-8 text file from GameFS.

```lua
-- signature
lurek.filesystem.read(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | GameFS path to read. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | File contents as text. |

**Example**

```lua
do
    local path = "save/read_sample.txt"
    lurek.filesystem.write(path, "read me")
    local contents = lurek.filesystem.read(path)
    print("read " .. #contents .. " bytes")
    print("contents = " .. contents)
end
```

---

### `lurek.filesystem.readAsync`

Starts an asynchronous file load request.

```lua
-- signature
lurek.filesystem.readAsync(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | GameFS path to read asynchronously. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Async load handle id. |

**Example**

```lua
do
    lurek.filesystem.write("save/test_handle.txt", "hello from handle")
    local ticket = lurek.filesystem.readAsync("save/test_handle.txt")
    print("async read ticket = " .. ticket)
end
```

---

### `lurek.filesystem.readBytes`

Reads a binary file from GameFS and returns the bytes as a Lua string.

```lua
-- signature
lurek.filesystem.readBytes(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | GameFS path to read. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | Raw file bytes. |

**Example**

```lua
do
    lurek.filesystem.write("save/test_handle.txt", "hello from handle")
    local bytes = lurek.filesystem.readBytes("save/test_handle.txt")
    print("binary read " .. #bytes .. " bytes")
end
```

---

### `lurek.filesystem.readJson`

Reads a JSON document as text from GameFS.

```lua
-- signature
lurek.filesystem.readJson(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | GameFS path to read. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | JSON text. |

**Example**

```lua
do
    local path = "save/options.json"
    lurek.filesystem.writeJson(path, '{"name":"test","value":42}')
    local data = lurek.filesystem.readJson(path)
    print("readJson type = " .. type(data))
    print("json bytes = " .. #data)
end
```

---

### `lurek.filesystem.readOrWriteJson`

Reads a JSON file or writes and returns default JSON when the file is absent.

```lua
-- signature
lurek.filesystem.readOrWriteJson(path, default_json)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | GameFS path to read. |
| `default_json` | `string` | JSON text written when the path does not exist. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | Existing or newly written JSON text. |

**Example**

```lua
do
    local path = "save/settings.json"
    local data = lurek.filesystem.readOrWriteJson(path, '{"volume":80,"fullscreen":false}')
    print("settings json = " .. data)
    print("settings exists = " .. tostring(lurek.filesystem.exists(path)))
end
```

---

### `lurek.filesystem.remove`

Removes a GameFS file or supported path.

```lua
-- signature
lurek.filesystem.remove(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | Path to remove. |

**Example**

```lua
do
    lurek.filesystem.write("save/test_moved.txt", "remove source")
    local ok = lurek.filesystem.remove("save/test_moved.txt")
    print("remove ok = " .. tostring(ok))
end
```

---

### `lurek.filesystem.removeDir`

Removes a GameFS directory by its path.

```lua
-- signature
lurek.filesystem.removeDir(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | Directory path to remove. |

**Example**

```lua
do
    lurek.filesystem.mkdir("save/another_dir")
    local ok = lurek.filesystem.removeDir("save/another_dir")
    print("removeDir ok = " .. tostring(ok))
end
```

---

### `lurek.filesystem.setIdentity`

Sets the filesystem identity string used by save paths.

```lua
-- signature
lurek.filesystem.setIdentity(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | New filesystem identity. |

**Example**

```lua
do
    lurek.filesystem.setIdentity("my_game")
    print("identity set to 'my_game'")
end
```

---

### `lurek.filesystem.stat`

Returns size and file/directory flags for a GameFS path.

```lua
-- signature
lurek.filesystem.stat(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | Path to inspect. |

**Returns**

| Type | Description |
|------|-------------|
| `FilesystemStatResult` | Table with `size`, `isFile`, and `isDir` fields. |

**Example**

```lua
do
    local path = "save/stat.txt"
    lurek.filesystem.write(path, "stat sample")
    local st = lurek.filesystem.stat(path)
    if st then
        print("stat size=" .. st.size .. " isFile=" .. tostring(st.isFile))
    end
end
```

---

### `lurek.filesystem.toAbsolutePath`

Resolves a GameFS-relative path against the filesystem base directory.

```lua
-- signature
lurek.filesystem.toAbsolutePath(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | Relative path to resolve. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | Absolute filesystem path string. |

**Example**

```lua
do
    local abs = lurek.filesystem.toAbsolutePath("content/examples/assets/data/sample_config.toml")
    print("absolute = " .. abs)
end
```

---

### `lurek.filesystem.unmount`

Removes a GameFS mount point by its name.

```lua
-- signature
lurek.filesystem.unmount(mp)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mp` | `string` | Virtual mount point to remove. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when a mount was removed. |

**Example**

```lua
do
    local ok = lurek.filesystem.unmount("game_assets")
    print("unmount ok = " .. tostring(ok))
end
```

---

### `lurek.filesystem.unwatchPath`

Removes a path from the module-local file watcher.

```lua
-- signature
lurek.filesystem.unwatchPath(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | Watched path to remove. |

**Example**

```lua
do
    lurek.filesystem.unwatchPath("save")
    print("unwatched save/")
end
```

---

### `lurek.filesystem.watchPath`

Adds a path to the module-local file watcher.

```lua
-- signature
lurek.filesystem.watchPath(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | Path to watch for changes. |

**Example**

```lua
do
    lurek.filesystem.watchPath("save")
    print("watching save/")
end
```

---

### `lurek.filesystem.write`

Writes a UTF-8 text file through GameFS.

```lua
-- signature
lurek.filesystem.write(path, data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | GameFS path to write. |
| `data` | `string` | Text contents. |

**Example**

```lua
do
    local path = "save/test_write.txt"
    lurek.filesystem.write(path, "hello world")
    print("wrote to " .. path)
end
```

---

### `lurek.filesystem.writeAsync`

Starts an asynchronous file write request.

```lua
-- signature
lurek.filesystem.writeAsync(path, data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | GameFS path to write. |
| `data` | `string` | Raw bytes stored in a Lua string. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Async write handle id. |

**Example**

```lua
do
    local ticket = lurek.filesystem.writeAsync("save/async_out.txt", "async data")
    print("async write ticket = " .. ticket)
end
```

---

### `lurek.filesystem.writeBytes`

Writes binary data through GameFS.

```lua
-- signature
lurek.filesystem.writeBytes(path, data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | GameFS path to write. |
| `data` | `string` | Raw bytes stored in a Lua string. |

**Example**

```lua
do
    lurek.filesystem.writeBytes("save/binary.bin", "\x00\x01\x02\x03")
    print("wrote 4 binary bytes")
end
```

---

### `lurek.filesystem.writeJson`

Writes JSON text through the GameFS layer.

```lua
-- signature
lurek.filesystem.writeJson(path, json)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | GameFS path to write. |
| `json` | `string` | JSON text to store. |

**Example**

```lua
do
    local path = "save/test_json.json"
    lurek.filesystem.writeJson(path, '{"name":"test","value":42}')
    print("wrote JSON to " .. path)
end
```

---

## LFileData

### `LFileData:getFilename`

Returns the path associated with this file data object.

```lua
-- signature
LFileData:getFilename()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Original file path. |

**Example**

```lua
do
    lurek.filesystem.write("save/test_handle.txt", "hello from handle")
    local fd = lurek.filesystem.newFileData("save/test_handle.txt")
    print("filename = " .. fd:getFilename())
end
```

---

### `LFileData:getSize`

Returns the byte length of this file data.

```lua
-- signature
LFileData:getSize()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | File data size in bytes. |

**Example**

```lua
do
    lurek.filesystem.write("save/test_handle.txt", "hello from handle")
    local fd = lurek.filesystem.newFileData("save/test_handle.txt")
    print("size = " .. fd:getSize())
end
```

---

### `LFileData:getString`

Returns file data bytes as a Lua string without UTF-8 validation.

```lua
-- signature
LFileData:getString()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Lua string containing the raw file bytes. |

**Example**

```lua
do
    lurek.filesystem.write("save/test_handle.txt", "hello from handle")
    local fd = lurek.filesystem.newFileData("save/test_handle.txt")
    local str = fd:getString()
    print("content = " .. str)
end
```

---

### `LFileData:type`

Returns the Lua-visible type name for this file data handle.

```lua
-- signature
LFileData:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LFileData`. |

**Example**

```lua
do
    lurek.filesystem.write("save/test_handle.txt", "hello from handle")
    local fd = lurek.filesystem.newFileData("save/test_handle.txt")
    print("type = " .. fd:type())
end
```

---

### `LFileData:typeOf`

Returns whether this file data handle matches a supported type name.

```lua
-- signature
LFileData:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LFileData` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    lurek.filesystem.write("save/test_handle.txt", "hello from handle")
    local fd = lurek.filesystem.newFileData("save/test_handle.txt")
    print("is FileData = " .. tostring(fd:typeOf("LFileData")))
end
```

---

## LFileHandle

### `LFileHandle:close`

Closes this file handle on this object.

```lua
-- signature
LFileHandle:close()
```

**Example**

```lua
do
    local fh = lurek.filesystem.openFile("save/close_test.txt", "w")
    fh:write("done")
    fh:close()
    print("closed")
end
```

---

### `LFileHandle:flush`

Flushes pending writes on this file handle.

```lua
-- signature
LFileHandle:flush()
```

**Example**

```lua
do
    local fh = lurek.filesystem.openFile("save/flush_test.txt", "w")
    fh:write("buffered data")
    fh:flush()
    fh:close()
    print("flushed")
end
```

---

### `LFileHandle:getMode`

Returns the mode used to open this file handle.

```lua
-- signature
LFileHandle:getMode()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | File mode string. |

**Example**

```lua
do
    lurek.filesystem.write("save/test_handle.txt", "hello from handle")
    local fh = lurek.filesystem.openFile("save/test_handle.txt", "r")
    print("mode = " .. fh:getMode())
    fh:close()
end
```

---

### `LFileHandle:getSize`

Returns the size of the open file in bytes.

```lua
-- signature
LFileHandle:getSize()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | File size in bytes. |

**Example**

```lua
do
    lurek.filesystem.write("save/test_handle.txt", "hello from handle")
    local fh = lurek.filesystem.openFile("save/test_handle.txt", "r")
    print("file size = " .. fh:getSize() .. " bytes")
    fh:close()
end
```

---

### `LFileHandle:isEOF`

Returns whether the file cursor is at end of file.

```lua
-- signature
LFileHandle:isEOF()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when no more bytes remain. |

**Example**

```lua
do
    lurek.filesystem.write("save/test_handle.txt", "hello from handle")
    local fh = lurek.filesystem.openFile("save/test_handle.txt", "r")
    fh:read()
    print("eof = " .. tostring(fh:isEOF()))
    fh:close()
end
```

---

### `LFileHandle:read`

Reads up to an optional byte count and returns text using lossless UTF-8 replacement.

```lua
-- signature
LFileHandle:read(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count?` | `number` | Optional maximum number of bytes to read. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | String decoded from the bytes that were read. |

**Example**

```lua
do
    lurek.filesystem.write("save/test_handle.txt", "hello from handle")
    local fh = lurek.filesystem.openFile("save/test_handle.txt", "r")
    local data = fh:read()
    print("read: " .. data)
    fh:close()
end
```

---

### `LFileHandle:readLine`

Reads the next line from this file handle.

```lua
-- signature
LFileHandle:readLine()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Line string when available, or nil at EOF. |

**Example**

```lua
do
    lurek.filesystem.write("save/lines.txt", "alpha\nbeta\ngamma")
    local fh = lurek.filesystem.openFile("save/lines.txt", "r")
    local line = fh:readLine()
    print("first line: " .. line)
    fh:close()
end
```

---

### `LFileHandle:seek`

Moves the file cursor to an absolute byte position.

```lua
-- signature
LFileHandle:seek(pos)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pos` | `number` | Absolute byte offset. |

**Example**

```lua
do
    lurek.filesystem.write("save/test_handle.txt", "hello from handle")
    local fh = lurek.filesystem.openFile("save/test_handle.txt", "r")
    fh:seek(5)
    local data = fh:read(4)
    print("from pos 5: " .. data)
    fh:close()
end
```

---

### `LFileHandle:tell`

Returns the current file cursor position.

```lua
-- signature
LFileHandle:tell()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current absolute byte offset. |

**Example**

```lua
do
    lurek.filesystem.write("save/test_handle.txt", "hello from handle")
    local fh = lurek.filesystem.openFile("save/test_handle.txt", "r")
    fh:read(3)
    local pos = fh:tell()
    print("position = " .. pos)
    fh:close()
end
```

---

### `LFileHandle:type`

Returns the Lua-visible type name for this file handle.

```lua
-- signature
LFileHandle:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LFileHandle`. |

**Example**

```lua
do
    lurek.filesystem.write("save/test_handle.txt", "hello from handle")
    local fh = lurek.filesystem.openFile("save/test_handle.txt", "r")
    print("type = " .. fh:type())
    fh:close()
end
```

---

### `LFileHandle:typeOf`

Returns whether this file handle matches a supported type name.

```lua
-- signature
LFileHandle:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LFileHandle` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    lurek.filesystem.write("save/test_handle.txt", "hello from handle")
    local fh = lurek.filesystem.openFile("save/test_handle.txt", "r")
    print("is FileHandle = " .. tostring(fh:typeOf("LFileHandle")))
    fh:close()
end
```

---

### `LFileHandle:write`

Writes a string to this file handle.

```lua
-- signature
LFileHandle:write(data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | `string` | Text bytes to write. |

**Example**

```lua
do
    local fh = lurek.filesystem.openFile("save/append_test.txt", "w")
    fh:write("part1")
    fh:write(" part2")
    fh:close()
    print("wrote via handle")
end
```

---

## LZipMount

### `LZipMount:contains`

Returns whether a virtual path exists in the ZIP mount.

```lua
-- signature
LZipMount:contains(virtual_path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `virtual_path` | `string` | Path inside the mount prefix. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the file exists in the archive. |

**Example**

```lua
do
    local zip = lurek.filesystem.mountZip("content/examples/assets/data/sample_data.zip", "data")
    print("has hello = " .. tostring(zip:contains("data/sample_hello.txt")))
end
```

---

### `LZipMount:listFiles`

Returns every virtual file path in the ZIP mount.

```lua
-- signature
LZipMount:listFiles()
```

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Mounted file paths. |

**Example**

```lua
do
    local zip = lurek.filesystem.mountZip("content/examples/assets/data/sample_data.zip", "data")
    local files = zip:listFiles()
    print("zip files: " .. #files)
end
```

---

### `LZipMount:prefix`

Returns the virtual prefix used by this ZIP mount.

```lua
-- signature
LZipMount:prefix()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Mount prefix. |

**Example**

```lua
do
    local zip = lurek.filesystem.mountZip("content/examples/assets/data/sample_data.zip", "data")
    print("prefix = " .. zip:prefix())
end
```

---

### `LZipMount:readFile`

Reads a file from the ZIP mount by virtual path.

```lua
-- signature
LZipMount:readFile(virtual_path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `virtual_path` | `string` | Path inside the mount prefix. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | Raw file bytes as a Lua string. |

**Example**

```lua
do
    local zip = lurek.filesystem.mountZip("content/examples/assets/data/sample_data.zip", "data")
    local ok, txt = pcall(function() return zip:readFile("data/sample_hello.txt") end)
    print("zip read bytes: " .. (ok and txt and tostring(#txt) or "unavailable"))
end
```

---

### `LZipMount:type`

Returns the Lua-visible type name for this ZIP mount handle.

```lua
-- signature
LZipMount:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LZipMount`. |

**Example**

```lua
do
    local zip = lurek.filesystem.mountZip("content/examples/assets/data/sample_data.zip", "data")
    print("type = " .. zip:type())
end
```

---

### `LZipMount:typeOf`

Returns whether this ZIP mount handle matches a supported type name.

```lua
-- signature
LZipMount:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LZipMount` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local zip = lurek.filesystem.mountZip("content/examples/assets/data/sample_data.zip", "data")
    print("is ZipMount = " .. tostring(zip:typeOf("LZipMount")))
end
```

---
