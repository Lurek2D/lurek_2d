# Filesystem

## Purpose

Sandboxes path resolution, mount overlays, and ZIP archives.

## When To Use

- Path normalization, traversal checks, mounts, archive access, synchronous handles, and asynchronous IO combine into one controlled runtime view of storage.
- That matters because asset lookup, save data, mod content, hot reload, and tooling workflows all need file access, but they should not each invent their own safety and path rules.
- Watchers, metadata queries, recursive listing, and convenience helpers make the module useful for diagnostics and content tooling as well as for normal gameplay persistence.

## Minimal Example

From the `lurek.filesystem.getSource` example block:

```lua
do
    local source_root = lurek.filesystem.getSource()
    local examples_path = source_root .. "/content/examples"
    local looks_absolute = source_root:find(":") ~= nil or source_root:sub(1, 1) == "/"
    local style = looks_absolute and "absolute" or "relative"
    fs_log("source root for content discovery is " .. style .. ": " .. examples_path)
end
```

## Common Patterns

- Start with `lurek.filesystem.append` when exploring this module.
- Start with `lurek.filesystem.copy` when exploring this module.
- Start with `lurek.filesystem.createDirectory` when exploring this module.
- Start with `lurek.filesystem.createTempFile` when exploring this module.
- Start with `lurek.filesystem.exists` when exploring this module.

## API Reference

- Full generated API reference: [docs/api/lurek.md](../api/lurek.md)
- Runnable example owner: `content/examples/filesystem.lua`

## Summary

- The `filesystem` module is the sandboxed storage surface for users who need file access without giving every script raw platform path power.
- Path normalization, traversal checks, mounts, archive access, synchronous handles, and asynchronous IO combine into one controlled runtime view of storage.
- That matters because asset lookup, save data, mod content, hot reload, and tooling workflows all need file access, but they should not each invent their own safety and path rules.
- Watchers, metadata queries, recursive listing, and convenience helpers make the module useful for diagnostics and content tooling as well as for normal gameplay persistence.
- Mount and archive support are especially important because real projects often mix loose files, packaged assets, save locations, and mod roots under one conceptual storage view.
- The sandboxed design is the key policy boundary: `filesystem` exists so scripts can do meaningful file work while the engine still controls what paths are valid, portable, and safe to expose.
- Async reads and watch-style helpers also make the module practical for hot-reload and content-iteration workflows where storage changes need to become observable runtime events.
- Read `filesystem` as the place where storage becomes safe, portable, and composable for the rest of the engine.

This module primarily collaborates with `dataframe`, `runtime`. Its responsibility should stay inside the Core Runtime group rather than absorb behavior owned by those neighbors.

## Functions

### `lurek.filesystem.append`

Appends UTF-8 text to a GameFS file.

```lua
lurek.filesystem.append(path, data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | GameFS path to append to. |
| `data` | string | Text to append. |

**Example**

```lua
do
    local path = FS_ROOT .. "session.log"
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.write(path, "spawn=village")
    lurek.filesystem.append(path, "\nquest=accepted")
    local contents = lurek.filesystem.read(path)
    fs_log("session log grew to " .. tostring(#contents) .. " bytes after quest append")
end
```

---

### `lurek.filesystem.copy`

Copies one GameFS file to another path.

```lua
lurek.filesystem.copy(src, dst)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `src` | string | Source path. |
| `dst` | string | Destination path. |

**Example**

```lua
do
    local src = PROFILE_DIR .. "slot_copy_source.json"
    local dst = PROFILE_DIR .. "slot_copy_backup.json"
    lurek.filesystem.createDirectory(PROFILE_DIR)
    lurek.filesystem.write(src, '{"name":"Iris","zone":"ruins"}')
    lurek.filesystem.copy(src, dst)
    fs_log("copied profile backup exists=" .. tostring(lurek.filesystem.exists(dst)) .. " at " .. dst)
end
```

---

### `lurek.filesystem.createDirectory`

Creates a GameFS directory and any missing parents.

```lua
lurek.filesystem.createDirectory(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Directory path to create. |

**Example**

```lua
do
    local path = PROFILE_DIR .. "campaign_two/checkpoint_a/"
    lurek.filesystem.createDirectory(path)
    local parent_ready = lurek.filesystem.isDirectory(PROFILE_DIR)
    local child_ready = lurek.filesystem.isDirectory(path)
    fs_log("created nested campaign folders parent=" .. tostring(parent_ready) .. " child=" .. tostring(child_ready))
end
```

---

### `lurek.filesystem.createTempFile`

Creates a temporary file through GameFS.

```lua
lurek.filesystem.createTempFile(prefix)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `prefix?` | string | Optional filename prefix, defaulting to `tmp`. |

**Returns**

| Type | Description |
|------|-------------|
| string | Created temporary file path. |

**Example**

```lua
do
    local temp_path = lurek.filesystem.createTempFile("draft_")
    local draft_payload = "seed=42\nbiome=forest\nweather=rain"
    lurek.filesystem.write(temp_path, draft_payload)
    local exists = lurek.filesystem.exists(temp_path)
    local preview = lurek.filesystem.read(temp_path)
    fs_log("temporary export draft exists=" .. tostring(exists) .. " bytes=" .. tostring(#preview))
end
```

---

### `lurek.filesystem.exists`

Returns whether a path exists in GameFS.

```lua
lurek.filesystem.exists(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | GameFS path to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the path exists. |

**Example**

```lua
do
    local profile_path = PROFILE_DIR .. "exists_slot.json"
    lurek.filesystem.createDirectory(PROFILE_DIR)
    lurek.filesystem.write(profile_path, '{"name":"Ada","level":7}')
    local exists = lurek.filesystem.exists(profile_path)
    fs_log("profile save exists after write=" .. tostring(exists) .. " at " .. profile_path)
end
```

---

### `lurek.filesystem.getDirectoryItems`

Lists immediate entries in a GameFS directory.

```lua
lurek.filesystem.getDirectoryItems(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Directory path to list. |

**Returns**

| Type | Description |
|------|-------------|
| string[] | Entry names. |

**Example**

```lua
do
    local dir = PROFILE_DIR .. "slot_browser/"
    lurek.filesystem.createDirectory(dir)
    lurek.filesystem.write(dir .. "slot_a.json", '{"slot":"A"}')
    lurek.filesystem.write(dir .. "slot_b.json", '{"slot":"B"}')
    local items = lurek.filesystem.getDirectoryItems(dir)
    fs_log("save browser sees " .. tostring(#items) .. " immediate entries in " .. dir)
end
```

---

### `lurek.filesystem.getIdentity`

Returns the current filesystem identity string.

```lua
lurek.filesystem.getIdentity()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Filesystem identity used for save namespacing. |

**Example**

```lua
do
    local identity = lurek.filesystem.getIdentity()
    local save_root = lurek.filesystem.getSaveDirectory()
    local slot_path = save_root .. "/example_filesystem/profiles/slot_01.json"
    local summary = "active identity=" .. identity .. " slot=" .. slot_path
    fs_log(summary)
end
```

---

### `lurek.filesystem.getInfo`

Returns file metadata for a GameFS path when available.

```lua
lurek.filesystem.getInfo(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | GameFS path to inspect. |

**Returns**

| Type | Description |
|------|-------------|
| LFilesystemGetInfoResult | Metadata table with type, size, modtime, and readonly fields, or nil on error. |

**Example**

```lua
do
    local path = PROFILE_DIR .. "info_slot.json"
    lurek.filesystem.createDirectory(PROFILE_DIR)
    lurek.filesystem.write(path, '{"chapter":"forest","hp":18}')
    local info = lurek.filesystem.getInfo(path)
    local summary = info and ("type=" .. tostring(info.type) .. " size=" .. tostring(info.size)) or "missing"
    fs_log("profile info for save browser: " .. summary)
end
```

---

### `lurek.filesystem.getSaveDirectory`

Returns the save directory path used by GameFS.

```lua
lurek.filesystem.getSaveDirectory()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Save directory path. |

**Example**

```lua
do
    local save_root = lurek.filesystem.getSaveDirectory()
    local profile_slot = save_root .. "/example_filesystem/profiles/slot_01.json"
    local looks_absolute = save_root:find(":") ~= nil or save_root:sub(1, 1) == "/"
    local style = looks_absolute and "absolute" or "relative"
    fs_log("save root for profile data is " .. style .. ": " .. profile_slot)
end
```

---

### `lurek.filesystem.getSource`

Returns the GameFS source root string.

```lua
lurek.filesystem.getSource()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Source directory or source description. |

**Example**

```lua
do
    local source_root = lurek.filesystem.getSource()
    local examples_path = source_root .. "/content/examples"
    local looks_absolute = source_root:find(":") ~= nil or source_root:sub(1, 1) == "/"
    local style = looks_absolute and "absolute" or "relative"
    fs_log("source root for content discovery is " .. style .. ": " .. examples_path)
end
```

---

### `lurek.filesystem.getUserDirectory`

Returns the current user's directory path.

```lua
lurek.filesystem.getUserDirectory()
```

**Returns**

| Type | Description |
|------|-------------|
| string | User directory path. |

**Example**

```lua
do
    local user_root = lurek.filesystem.getUserDirectory()
    local backup_path = user_root .. "/LurekBackups"
    local profile_name = lurek.filesystem.getIdentity()
    local summary = "user backup root for " .. profile_name .. " -> " .. backup_path
    fs_log(summary)
end
```

---

### `lurek.filesystem.getWorkingDirectory`

Returns the process working directory.

```lua
lurek.filesystem.getWorkingDirectory()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Working directory path. |

**Example**

```lua
do
    local cwd = lurek.filesystem.getWorkingDirectory()
    local content_path = cwd .. "/content"
    local tests_path = cwd .. "/tests"
    local summary = "content=" .. content_path .. " tests=" .. tests_path
    fs_log("working directory anchors repo-relative tooling: " .. summary)
end
```

---

### `lurek.filesystem.glob`

Returns GameFS paths matching a glob pattern.

```lua
lurek.filesystem.glob(pattern)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pattern` | string | Glob pattern. |

**Returns**

| Type | Description |
|------|-------------|
| string[] | Matching path strings. |

**Example**

```lua
do
    local dir = CACHE_DIR .. "glob/"
    lurek.filesystem.createDirectory(dir)
    lurek.filesystem.write(dir .. "forest.cache", "ok")
    lurek.filesystem.write(dir .. "desert.cache", "ok")
    local matches = lurek.filesystem.glob(dir .. "*.cache")
    fs_log("cache glob matched " .. tostring(#matches) .. " prebuilt biome files")
end
```

---

### `lurek.filesystem.isDirectory`

Returns whether a GameFS path is a directory.

```lua
lurek.filesystem.isDirectory(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | GameFS path to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the path is a directory. |

**Example**

```lua
do
    local slot_dir = PROFILE_DIR .. "campaign_one/"
    lurek.filesystem.createDirectory(slot_dir)
    local is_directory = lurek.filesystem.isDirectory(slot_dir)
    local has_parent = lurek.filesystem.isDirectory(PROFILE_DIR)
    local summary = "campaign dir=" .. tostring(is_directory) .. " parent=" .. tostring(has_parent)
    fs_log(summary)
end
```

---

### `lurek.filesystem.isFile`

Returns whether a GameFS path is a regular file.

```lua
lurek.filesystem.isFile(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | GameFS path to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the path is a file. |

**Example**

```lua
do
    local profile_path = PROFILE_DIR .. "slot_file_check.json"
    lurek.filesystem.createDirectory(PROFILE_DIR)
    lurek.filesystem.write(profile_path, '{"name":"Mira","coins":12}')
    local is_file = lurek.filesystem.isFile(profile_path)
    fs_log("profile slot is a file=" .. tostring(is_file) .. " for " .. profile_path)
end
```

---

### `lurek.filesystem.lines`

Creates an iterator function over lines in a text file.

```lua
lurek.filesystem.lines(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | GameFS path to read. |

**Returns**

| Type | Description |
|------|-------------|
| function | Iterator returning the next line string or nil at EOF. |

**Example**

```lua
do
    local path = FS_ROOT .. "dialogue.txt"
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.write(path, "hero=ready\nmentor=wait\nquest=go")
    local count = 0
    for _ in lurek.filesystem.lines(path) do
        count = count + 1
    end
    fs_log("streamed " .. tostring(count) .. " dialogue lines from " .. path)
end
```

---

### `lurek.filesystem.listRecursive`

Lists all paths under a GameFS directory recursively.

```lua
lurek.filesystem.listRecursive(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Root directory path. |

**Returns**

| Type | Description |
|------|-------------|
| string[] | Path strings. |

**Example**

```lua
do
    local dir = CACHE_DIR .. "imports/"
    lurek.filesystem.createDirectory(dir .. "audio/")
    lurek.filesystem.write(dir .. "manifest.txt", "import=ambient")
    lurek.filesystem.write(dir .. "audio/theme.txt", "placeholder")
    local items = lurek.filesystem.listRecursive(dir)
    fs_log("recursive import scan found " .. tostring(#items) .. " paths under " .. dir)
end
```

---

### `lurek.filesystem.load`

Loads a Lua chunk from GameFS and returns it as a Lua function.

```lua
lurek.filesystem.load(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | GameFS path to a Lua script chunk. |

**Returns**

| Type | Description |
|------|-------------|
| function | Compiled Lua chunk function. |

**Example**

```lua
do
    local path = FS_ROOT .. "spawn_rules.lua"
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.write(path, "return function() return { biome = 'forest', enemies = 5 } end")
    local chunk = lurek.filesystem.load(path)
    local build_rules = chunk()
    local rules = build_rules()
    fs_log("loaded scripted spawn rules biome=" .. tostring(rules.biome) .. " enemies=" .. tostring(rules.enemies))
end
```

---

### `lurek.filesystem.mkdir`

Creates a directory under the GameFS base directory.

```lua
lurek.filesystem.mkdir(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Relative directory path to create. |

**Example**

```lua
do
    local path = CACHE_DIR .. "shader/prewarm/"
    lurek.filesystem.mkdir(path)
    local ready = lurek.filesystem.isDirectory(path)
    local absolute = lurek.filesystem.toAbsolutePath(path)
    fs_log("mkdir prepared shader cache=" .. tostring(ready) .. " at " .. absolute)
end
```

---

### `lurek.filesystem.mount`

Mounts an external source path at a GameFS mount point.

```lua
lurek.filesystem.mount(src, mp)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `src` | string | Source path to mount. |
| `mp` | string | Virtual mount point. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the mount succeeds. |

**Example**

```lua
do
    local mountpoint = "example_assets"
    lurek.filesystem.unmount(mountpoint)
    local mounted = lurek.filesystem.mount("content/examples/assets", mountpoint)
    local items = lurek.filesystem.getDirectoryItems(mountpoint)
    fs_log("mounted shared assets=" .. tostring(mounted) .. " visible entries=" .. tostring(#items))
end
```

---

### `lurek.filesystem.mountZip`

Opens a ZIP archive and exposes it through a virtual prefix.

```lua
lurek.filesystem.mountZip(archive_path, prefix)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `archive_path` | string | Archive path on disk. |
| `prefix` | string | Virtual path prefix for archive contents. |

**Returns**

| Type | Description |
|------|-------------|
| [LZipMount](#lzipmount) | New ZIP mount handle. |

**Example**

```lua
do
    local zip = lurek.filesystem.mountZip(ZIP_FIXTURE, "zip_preview")
    local prefix = zip:prefix()
    local files = zip:listFiles()
    local contains_hello = zip:contains("zip_preview/hello.txt")
    fs_log("zip mount prefix=" .. prefix .. " files=" .. tostring(#files) .. " containsHello=" .. tostring(contains_hello))
end
```

---

### `lurek.filesystem.move`

Moves or renames one GameFS file to another path.

```lua
lurek.filesystem.move(src, dst)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `src` | string | Source path. |
| `dst` | string | Destination path. |

**Example**

```lua
do
    local src = PROFILE_DIR .. "slot_move_tmp.json"
    local dst = PROFILE_DIR .. "slot_move_final.json"
    lurek.filesystem.createDirectory(PROFILE_DIR)
    lurek.filesystem.write(src, '{"name":"Tao","zone":"tower"}')
    lurek.filesystem.move(src, dst)
    fs_log("renamed autosave into final slot=" .. tostring(lurek.filesystem.exists(dst)))
end
```

---

### `lurek.filesystem.newFileData`

Loads a file into an immutable file data handle.

```lua
lurek.filesystem.newFileData(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | GameFS path to load. |

**Returns**

| Type | Description |
|------|-------------|
| [LFileData](#lfiledata) | New file data handle containing path and bytes. |

**Example**

```lua
do
    local path = FS_ROOT .. "filedata_blob.txt"
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.write(path, "spawn=river\nambient=wind")
    local data = lurek.filesystem.newFileData(path)
    local size = data:getSize()
    fs_log("captured immutable file data bytes=" .. tostring(size) .. " from " .. path)
end
```

---

### `lurek.filesystem.openFile`

Opens a GameFS file handle in a requested mode.

```lua
lurek.filesystem.openFile(path, mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | GameFS path to open. |
| `mode` | string | File mode understood by GameFS. |

**Returns**

| Type | Description |
|------|-------------|
| [LFileHandle](#lfilehandle) | Open file handle. |

**Example**

```lua
do
    local path = FS_ROOT .. "handle_open.log"
    lurek.filesystem.createDirectory(FS_ROOT)
    local handle = lurek.filesystem.openFile(path, "w")
    handle:write("encounter=start\n")
    handle:close()
    fs_log("opened encounter log with handle and wrote first line to " .. path)
end
```

---

### `lurek.filesystem.pollAsync`

Polls an asynchronous file load request.

```lua
lurek.filesystem.pollAsync(handle_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle_id` | number | Async load handle id. |

**Returns**

| Type | Description |
|------|-------------|
| string | Completed bytes/result, pending marker, or nil depending on async state. |

**Example**

```lua
do
    local path = FS_ROOT .. "async_poll.json"
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.write(path, '{"region":"cave","npcs":6}')
    local ticket = lurek.filesystem.readAsync(path)
    local status, payload = "pending", nil
    for _ = 1, 20 do
        status, payload = lurek.filesystem.pollAsync(ticket)
        if status == "done" then
            break
        end
    end
    fs_log("async read completed with status=" .. tostring(status) .. " bytes=" .. tostring(payload and #payload or 0))
end
```

---

### `lurek.filesystem.pollAsyncWrite`

Polls an asynchronous file write request.

```lua
lurek.filesystem.pollAsyncWrite(handle_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle_id` | number | Async write handle id. |

**Returns**

| Type | Description |
|------|-------------|
| string | Completed status, pending marker, or nil depending on async state. |

**Example**

```lua
do
    local path = FS_ROOT .. "async_write_poll.json"
    lurek.filesystem.createDirectory(FS_ROOT)
    local ticket = lurek.filesystem.writeAsync(path, '{"region":"harbor","npcs":11}')
    local status, info = "pending", nil
    for _ = 1, 20 do
        status, info = lurek.filesystem.pollAsyncWrite(ticket)
        if status == "done" then
            break
        end
    end
    local persisted = lurek.filesystem.exists(path)
    fs_log("async write finished status=" .. tostring(status) .. " persisted=" .. tostring(persisted))
end
```

---

### `lurek.filesystem.pollWatchers`

Polls watched paths and returns paths that changed since the previous poll.

```lua
lurek.filesystem.pollWatchers()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Changed path strings. |

**Example**

```lua
do
    lurek.filesystem.createDirectory(WATCH_DIR)
    lurek.filesystem.write(WATCH_FILE, '{"volume":74}')
    lurek.filesystem.watchPath(WATCH_FILE)
    lurek.filesystem.pollWatchers()
    lurek.filesystem.append(WATCH_FILE, '\n{"dirty":true}')
    local changed = lurek.filesystem.pollWatchers()
    lurek.filesystem.unwatchPath(WATCH_FILE)
    fs_log("hot-reload poll observed " .. tostring(#changed) .. " changed path(s)")
end
```

---

### `lurek.filesystem.read`

Reads a UTF-8 text file from GameFS.

```lua
lurek.filesystem.read(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | GameFS path to read. |

**Returns**

| Type | Description |
|------|-------------|
| string | File contents as text. |

**Example**

```lua
do
    local path = PROFILE_DIR .. "read_slot.json"
    lurek.filesystem.createDirectory(PROFILE_DIR)
    lurek.filesystem.write(path, '{"name":"Nova","quest":"intro"}')
    local json = lurek.filesystem.read(path)
    local has_intro = json:find("intro", 1, true) ~= nil
    fs_log("loaded checkpoint json bytes=" .. tostring(#json) .. " intro=" .. tostring(has_intro))
end
```

---

### `lurek.filesystem.readAsync`

Starts an asynchronous file load request.

```lua
lurek.filesystem.readAsync(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | GameFS path to read asynchronously. |

**Returns**

| Type | Description |
|------|-------------|
| number | Async load handle id. |

**Example**

```lua
do
    local path = FS_ROOT .. "async_read.json"
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.write(path, '{"region":"forest","npcs":14}')
    local ticket = lurek.filesystem.readAsync(path)
    local exists = lurek.filesystem.exists(path)
    fs_log("queued async region read ticket=" .. tostring(ticket) .. " exists=" .. tostring(exists))
end
```

---

### `lurek.filesystem.readBytes`

Reads a binary file from GameFS and returns the bytes as a Lua string.

```lua
lurek.filesystem.readBytes(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | GameFS path to read. |

**Returns**

| Type | Description |
|------|-------------|
| string | Raw file bytes. |

**Example**

```lua
do
    local path = FS_ROOT .. "palette.bin"
    local bytes = string.char(0, 64, 128, 255)
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.writeBytes(path, bytes)
    local payload = lurek.filesystem.readBytes(path)
    fs_log("read palette blob bytes=" .. tostring(#payload) .. " from " .. path)
end
```

---

### `lurek.filesystem.readJson`

Reads a JSON document as text from GameFS.

```lua
lurek.filesystem.readJson(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | GameFS path to read. |

**Returns**

| Type | Description |
|------|-------------|
| string | JSON text. |

**Example**

```lua
do
    local path = PROFILE_DIR .. "read_json_slot.json"
    lurek.filesystem.createDirectory(PROFILE_DIR)
    lurek.filesystem.writeJson(path, '{"name":"Kira","score":42}')
    local json = lurek.filesystem.readJson(path)
    local has_score = json:find("score", 1, true) ~= nil
    fs_log("read raw json bytes=" .. tostring(#json) .. " scoreField=" .. tostring(has_score))
end
```

---

### `lurek.filesystem.readOrWriteJson`

Reads a JSON file or writes and returns default JSON when the file is absent.

```lua
lurek.filesystem.readOrWriteJson(path, default_json)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | GameFS path to read. |
| `default_json` | string | JSON text written when the path does not exist. |

**Returns**

| Type | Description |
|------|-------------|
| string | Existing or newly written JSON text. |

**Example**

```lua
do
    local path = PROFILE_DIR .. "defaults_slot.json"
    local default_json = '{"volume":80,"fullscreen":false,"language":"pl"}'
    lurek.filesystem.createDirectory(PROFILE_DIR)
    local result = lurek.filesystem.readOrWriteJson(path, default_json)
    local saved = lurek.filesystem.exists(path)
    fs_log("readOrWriteJson seeded defaults=" .. tostring(saved) .. " bytes=" .. tostring(#result))
end
```

---

### `lurek.filesystem.remove`

Removes a GameFS file or supported path.

```lua
lurek.filesystem.remove(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Path to remove. |

**Example**

```lua
do
    local path = CACHE_DIR .. "obsolete_manifest.txt"
    lurek.filesystem.createDirectory(CACHE_DIR)
    lurek.filesystem.write(path, "cache=v1")
    lurek.filesystem.remove(path)
    local exists = lurek.filesystem.exists(path)
    fs_log("removed obsolete cache manifest=" .. tostring(not exists) .. " from " .. path)
end
```

---

### `lurek.filesystem.removeDir`

Removes a GameFS directory by its path.

```lua
lurek.filesystem.removeDir(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Directory path to remove. |

**Example**

```lua
do
    local path = CACHE_DIR .. "old_build/"
    lurek.filesystem.createDirectory(path)
    lurek.filesystem.write(path .. "atlas.txt", "old atlas")
    lurek.filesystem.removeDir(path)
    local exists = lurek.filesystem.isDirectory(path)
    fs_log("removed old build cache directory=" .. tostring(not exists) .. " at " .. path)
end
```

---

### `lurek.filesystem.setIdentity`

Sets the filesystem identity string used by save paths.

```lua
lurek.filesystem.setIdentity(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | New filesystem identity. |

**Example**

```lua
do
    local original = lurek.filesystem.getIdentity()
    local preview_identity = "codex_example_identity"
    lurek.filesystem.setIdentity(preview_identity)
    local changed = lurek.filesystem.getIdentity()
    lurek.filesystem.setIdentity(original)
    fs_log("identity swap for save migration preview: " .. original .. " -> " .. changed .. " -> " .. original)
end
```

---

### `lurek.filesystem.stat`

Returns size and file/directory flags for a GameFS path.

```lua
lurek.filesystem.stat(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Path to inspect. |

**Returns**

| Type | Description |
|------|-------------|
| LFilesystemStatResult | Table with `size`, `isFile`, and `isDir` fields. |

**Example**

```lua
do
    local path = PROFILE_DIR .. "stat_slot.json"
    lurek.filesystem.createDirectory(PROFILE_DIR)
    lurek.filesystem.write(path, '{"chapter":"cave","hp":24}')
    local stat = lurek.filesystem.stat(path)
    local summary = stat and ("size=" .. tostring(stat.size) .. " isFile=" .. tostring(stat.isFile)) or "missing"
    fs_log("stat for checkpoint file: " .. summary)
end
```

---

### `lurek.filesystem.toAbsolutePath`

Resolves a GameFS-relative path against the filesystem base directory.

```lua
lurek.filesystem.toAbsolutePath(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Relative path to resolve. |

**Returns**

| Type | Description |
|------|-------------|
| string | Absolute filesystem path string. |

**Example**

```lua
do
    local relative_path = PROFILE_DIR .. "slot_01.json"
    local absolute_path = lurek.filesystem.toAbsolutePath(relative_path)
    local save_root = lurek.filesystem.getSaveDirectory()
    local is_under_save = absolute_path:find(save_root, 1, true) ~= nil
    fs_log("absolute profile path resolves under save root=" .. tostring(is_under_save) .. ": " .. absolute_path)
end
```

---

### `lurek.filesystem.unmount`

Removes a GameFS mount point by its name.

```lua
lurek.filesystem.unmount(mp)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mp` | string | Virtual mount point to remove. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a mount was removed. |

**Example**

```lua
do
    local mountpoint = "example_assets_cleanup"
    lurek.filesystem.mount("content/examples/assets", mountpoint)
    local before = lurek.filesystem.getDirectoryItems(mountpoint)
    local removed = lurek.filesystem.unmount(mountpoint)
    local after = lurek.filesystem.unmount(mountpoint)
    fs_log("unmounted asset overlay removed=" .. tostring(removed) .. " firstView=" .. tostring(#before) .. " secondTry=" .. tostring(after))
end
```

---

### `lurek.filesystem.unwatchPath`

Removes a path from the module-local file watcher.

```lua
lurek.filesystem.unwatchPath(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Watched path to remove. |

**Example**

```lua
do
    lurek.filesystem.createDirectory(WATCH_DIR)
    lurek.filesystem.write(WATCH_FILE, '{"volume":72}')
    lurek.filesystem.watchPath(WATCH_FILE)
    lurek.filesystem.unwatchPath(WATCH_FILE)
    local changed = lurek.filesystem.pollWatchers()
    fs_log("stopped watching settings file, pending notifications=" .. tostring(#changed))
end
```

---

### `lurek.filesystem.watchPath`

Adds a path to the module-local file watcher.

```lua
lurek.filesystem.watchPath(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Path to watch for changes. |

**Example**

```lua
do
    lurek.filesystem.createDirectory(WATCH_DIR)
    lurek.filesystem.write(WATCH_FILE, '{"volume":70}')
    lurek.filesystem.watchPath(WATCH_FILE)
    lurek.filesystem.pollWatchers()
    fs_log("registered live watch for settings file " .. WATCH_FILE)
end
```

---

### `lurek.filesystem.write`

Writes a UTF-8 text file through GameFS.

```lua
lurek.filesystem.write(path, data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | GameFS path to write. |
| `data` | string | Text contents. |

**Example**

```lua
do
    local path = PROFILE_DIR .. "write_slot.json"
    local payload = '{"name":"Rune","xp":130,"zone":"village"}'
    lurek.filesystem.createDirectory(PROFILE_DIR)
    lurek.filesystem.write(path, payload)
    fs_log("wrote profile snapshot bytes=" .. tostring(#payload) .. " to " .. path)
end
```

---

### `lurek.filesystem.writeAsync`

Starts an asynchronous file write request.

```lua
lurek.filesystem.writeAsync(path, data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | GameFS path to write. |
| `data` | string | Raw bytes stored in a Lua string. |

**Returns**

| Type | Description |
|------|-------------|
| number | Async write handle id. |

**Example**

```lua
do
    local path = FS_ROOT .. "async_write.json"
    lurek.filesystem.createDirectory(FS_ROOT)
    local payload = '{"region":"tower","npcs":3}'
    local ticket = lurek.filesystem.writeAsync(path, payload)
    local absolute = lurek.filesystem.toAbsolutePath(path)
    fs_log("queued async write ticket=" .. tostring(ticket) .. " for " .. absolute)
end
```

---

### `lurek.filesystem.writeBytes`

Writes binary data through GameFS.

```lua
lurek.filesystem.writeBytes(path, data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | GameFS path to write. |
| `data` | string | Raw bytes stored in a Lua string. |

**Example**

```lua
do
    local path = FS_ROOT .. "navmesh.bin"
    local bytes = string.char(4, 8, 15, 16, 23, 42)
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.writeBytes(path, bytes)
    local payload = lurek.filesystem.readBytes(path)
    fs_log("wrote binary navmesh bytes=" .. tostring(#payload) .. " to " .. path)
end
```

---

### `lurek.filesystem.writeJson`

Writes JSON text through the GameFS layer.

```lua
lurek.filesystem.writeJson(path, json)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | GameFS path to write. |
| `json` | string | JSON text to store. |

**Example**

```lua
do
    local path = PROFILE_DIR .. "write_json_slot.json"
    local payload = '{"name":"Nox","difficulty":"hard"}'
    lurek.filesystem.createDirectory(PROFILE_DIR)
    lurek.filesystem.writeJson(path, payload)
    local bytes = #lurek.filesystem.read(path)
    fs_log("persisted structured options bytes=" .. tostring(bytes) .. " to " .. path)
end
```

---

## Module Fields

*No module-level fields documented.*

## Callbacks

*No callback parameters documented in this module.*

## Enums

*No module-specific enums documented.*

## Types

- [LFileData](#lfiledata)
- [LFileHandle](#lfilehandle)
- [LZipMount](#lzipmount)

## LFileData

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LFileData:getFilename`

Returns the path associated with this file data object.

```lua
LFileData:getFilename()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Original file path. |

**Example**

```lua
do
    local path = FS_ROOT .. "filedata_name.txt"
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.write(path, "seed=9301")
    local data = lurek.filesystem.newFileData(path)
    local filename = data:getFilename()
    fs_log("file data remembers source filename=" .. filename)
end
```

---

#### `LFileData:getSize`

Returns the byte length of this file data.

```lua
LFileData:getSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | File data size in bytes. |

**Example**

```lua
do
    local path = FS_ROOT .. "filedata_size.txt"
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.write(path, "enemy=archer")
    local data = lurek.filesystem.newFileData(path)
    local size = data:getSize()
    fs_log("file data size for enemy template=" .. tostring(size))
end
```

---

#### `LFileData:getString`

Returns file data bytes as a Lua string without UTF-8 validation.

```lua
LFileData:getString()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Lua string containing the raw file bytes. |

**Example**

```lua
do
    local path = FS_ROOT .. "filedata_string.txt"
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.write(path, "weather=storm")
    local data = lurek.filesystem.newFileData(path)
    local payload = data:getString()
    fs_log("file data payload for weather preset: " .. payload)
end
```

---

#### `LFileData:type`

Returns the Lua-visible type name for this file data handle.

```lua
LFileData:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LFileData](#lfiledata)`. |

**Example**

```lua
do
    local path = FS_ROOT .. "filedata_type.txt"
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.write(path, "hint=secret")
    local data = lurek.filesystem.newFileData(path)
    local type_name = data:type()
    fs_log("file data userdata type=" .. type_name)
end
```

---

#### `LFileData:typeOf`

Returns whether this file data handle matches a supported type name.

```lua
LFileData:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LFileData](#lfiledata)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local path = FS_ROOT .. "filedata_typeof.txt"
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.write(path, "hint=secret")
    local data = lurek.filesystem.newFileData(path)
    local matches = data:typeOf("LFileData")
    fs_log("typeOf confirms LFileData=" .. tostring(matches))
end
```

---

## LFileHandle

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LFileHandle:close`

Closes this file handle on this object.

```lua
LFileHandle:close()
```

**Example**

```lua
do
    local path = FS_ROOT .. "handle_close.log"
    lurek.filesystem.createDirectory(FS_ROOT)
    local handle = lurek.filesystem.openFile(path, "w")
    handle:write("checkpoint=sealed")
    handle:close()
    local saved = lurek.filesystem.read(path)
    fs_log("closed checkpoint handle with bytes=" .. tostring(#saved))
end
```

---

#### `LFileHandle:flush`

Flushes pending writes on this file handle.

```lua
LFileHandle:flush()
```

**Example**

```lua
do
    local path = FS_ROOT .. "handle_flush.log"
    lurek.filesystem.createDirectory(FS_ROOT)
    local handle = lurek.filesystem.openFile(path, "w")
    handle:write("boss_phase=2")
    handle:flush()
    handle:close()
    fs_log("flushed boss phase update before closing handle")
end
```

---

#### `LFileHandle:getMode`

Returns the mode used to open this file handle.

```lua
LFileHandle:getMode()
```

**Returns**

| Type | Description |
|------|-------------|
| string | File mode string. |

**Example**

```lua
do
    local path = FS_ROOT .. "handle_mode.log"
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.write(path, "quests=3")
    local handle = lurek.filesystem.openFile(path, "r")
    local mode = handle:getMode()
    handle:close()
    fs_log("opened quest summary handle in mode=" .. mode)
end
```

---

#### `LFileHandle:getSize`

Returns the size of the open file in bytes.

```lua
LFileHandle:getSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | File size in bytes. |

**Example**

```lua
do
    local path = FS_ROOT .. "handle_size.log"
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.write(path, "camera=10,20,1.2")
    local handle = lurek.filesystem.openFile(path, "r")
    local bytes = handle:getSize()
    handle:close()
    fs_log("camera bookmark file size=" .. tostring(bytes) .. " bytes")
end
```

---

#### `LFileHandle:isEOF`

Returns whether the file cursor is at end of file.

```lua
LFileHandle:isEOF()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when no more bytes remain. |

**Example**

```lua
do
    local path = FS_ROOT .. "handle_eof.log"
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.write(path, "alpha\nbeta")
    local handle = lurek.filesystem.openFile(path, "r")
    handle:read()
    local eof = handle:isEOF()
    handle:close()
    fs_log("reader reached end of log=" .. tostring(eof))
end
```

---

#### `LFileHandle:read`

Reads up to an optional byte count and returns text using lossless UTF-8 replacement.

```lua
LFileHandle:read(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count?` | number | Optional maximum number of bytes to read. |

**Returns**

| Type | Description |
|------|-------------|
| string | String decoded from the bytes that were read. |

**Example**

```lua
do
    local path = FS_ROOT .. "handle_read.log"
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.write(path, "encounter=boss\nstate=phase2")
    local handle = lurek.filesystem.openFile(path, "r")
    local preview = handle:read(15)
    handle:close()
    fs_log("read preview from encounter log: " .. preview)
end
```

---

#### `LFileHandle:readLine`

Reads the next line from this file handle.

```lua
LFileHandle:readLine()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Line string when available, or nil at EOF. |

**Example**

```lua
do
    local path = FS_ROOT .. "handle_lines.log"
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.write(path, "room=foyer\nroom=hall\nroom=vault")
    local handle = lurek.filesystem.openFile(path, "r")
    local first_line = handle:readLine()
    handle:close()
    fs_log("parsed first room line from route log: " .. first_line)
end
```

---

#### `LFileHandle:seek`

Moves the file cursor to an absolute byte position.

```lua
LFileHandle:seek(pos)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pos` | number | Absolute byte offset. |

**Example**

```lua
do
    local path = FS_ROOT .. "handle_seek.log"
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.write(path, "HP=035|MP=012|ZONE=RUINS")
    local handle = lurek.filesystem.openFile(path, "r")
    handle:seek(7)
    local preview = handle:read(6)
    handle:close()
    fs_log("seek jumped to MP field and read " .. preview)
end
```

---

#### `LFileHandle:tell`

Returns the current file cursor position.

```lua
LFileHandle:tell()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current absolute byte offset. |

**Example**

```lua
do
    local path = FS_ROOT .. "handle_tell.log"
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.write(path, "frame0001\nframe0002\n")
    local handle = lurek.filesystem.openFile(path, "r")
    handle:read(9)
    local cursor = handle:tell()
    handle:close()
    fs_log("replay parser cursor after one frame tag=" .. tostring(cursor))
end
```

---

#### `LFileHandle:type`

Returns the Lua-visible type name for this file handle.

```lua
LFileHandle:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LFileHandle](#lfilehandle)`. |

**Example**

```lua
do
    local path = FS_ROOT .. "handle_type.log"
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.write(path, "data=x")
    local handle = lurek.filesystem.openFile(path, "r")
    local type_name = handle:type()
    handle:close()
    fs_log("file handle userdata type=" .. type_name)
end
```

---

#### `LFileHandle:typeOf`

Returns whether this file handle matches a supported type name.

```lua
LFileHandle:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LFileHandle](#lfilehandle)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local path = FS_ROOT .. "handle_typeof.log"
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.write(path, "data=x")
    local handle = lurek.filesystem.openFile(path, "r")
    local matches = handle:typeOf("LFileHandle")
    handle:close()
    fs_log("typeOf confirms LFileHandle=" .. tostring(matches))
end
```

---

#### `LFileHandle:write`

Writes a string to this file handle.

```lua
LFileHandle:write(data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | string | Text bytes to write. |

**Example**

```lua
do
    local path = FS_ROOT .. "handle_write.log"
    lurek.filesystem.createDirectory(FS_ROOT)
    local handle = lurek.filesystem.openFile(path, "w")
    handle:write("tick=1\n")
    handle:write("tick=2\n")
    handle:close()
    fs_log("wrote two simulation ticks via a persistent handle")
end
```

---

## LZipMount

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LZipMount:contains`

Returns whether a virtual path exists in the ZIP mount.

```lua
LZipMount:contains(virtual_path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `virtual_path` | string | Path inside the mount prefix. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the file exists in the archive. |

**Example**

```lua
do
    local zip = lurek.filesystem.mountZip(ZIP_FIXTURE, "zip_contains")
    local has_hello = zip:contains("zip_contains/hello.txt")
    local has_missing = zip:contains("zip_contains/missing.txt")
    local prefix = zip:prefix()
    fs_log("zip lookup under " .. prefix .. " hello=" .. tostring(has_hello) .. " missing=" .. tostring(has_missing))
end
```

---

#### `LZipMount:listFiles`

Returns every virtual file path in the ZIP mount.

```lua
LZipMount:listFiles()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Mounted file paths. |

**Example**

```lua
do
    local zip = lurek.filesystem.mountZip(ZIP_FIXTURE, "zip_list")
    local files = zip:listFiles()
    local first = files[1] or "none"
    local count = #files
    fs_log("zip file catalog count=" .. tostring(count) .. " first=" .. tostring(first))
end
```

---

#### `LZipMount:prefix`

Returns the virtual prefix used by this ZIP mount.

```lua
LZipMount:prefix()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Mount prefix. |

**Example**

```lua
do
    local zip = lurek.filesystem.mountZip(ZIP_FIXTURE, "zip_prefix")
    local prefix = zip:prefix()
    local hello_path = prefix .. "/hello.txt"
    local exists = zip:contains(hello_path)
    fs_log("zip prefix builds virtual asset path " .. hello_path .. " exists=" .. tostring(exists))
end
```

---

#### `LZipMount:readFile`

Reads a file from the ZIP mount by virtual path.

```lua
LZipMount:readFile(virtual_path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `virtual_path` | string | Path inside the mount prefix. |

**Returns**

| Type | Description |
|------|-------------|
| string | Raw file bytes as a Lua string. |

**Example**

```lua
do
    local zip = lurek.filesystem.mountZip(ZIP_FIXTURE, "zip_read")
    local payload = zip:readFile("zip_read/hello.txt")
    local size = #payload
    local prefix = zip:prefix()
    local summary = "zip payload bytes=" .. tostring(size) .. " from " .. prefix
    fs_log(summary)
end
```

---

#### `LZipMount:type`

Returns the Lua-visible type name for this ZIP mount handle.

```lua
LZipMount:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LZipMount](#lzipmount)`. |

**Example**

```lua
do
    local zip = lurek.filesystem.mountZip(ZIP_FIXTURE, "zip_type")
    local type_name = zip:type()
    local prefix = zip:prefix()
    local file_count = #zip:listFiles()
    fs_log("zip mount type=" .. type_name .. " prefix=" .. prefix .. " files=" .. tostring(file_count))
end
```

---

#### `LZipMount:typeOf`

Returns whether this ZIP mount handle matches a supported type name.

```lua
LZipMount:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LZipMount](#lzipmount)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local zip = lurek.filesystem.mountZip(ZIP_FIXTURE, "zip_typeof")
    local matches = zip:typeOf("LZipMount")
    local prefix = zip:prefix()
    local has_hello = zip:contains(prefix .. "/hello.txt")
    fs_log("typeOf confirms LZipMount=" .. tostring(matches) .. " hello=" .. tostring(has_hello))
end
```

---
