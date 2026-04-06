-- examples/filesystem.lua
-- Luna2D luna.filesystem API Reference
-- This file is documentation code, not a runnable game.
-- Demonstrates the sandboxed GameFS, virtual FS, and file API.

-- NOTE: All paths are relative to the game directory (game mount) or the
--       save directory (write mount). Absolute paths and ".." traversals
--       are blocked for security.

-- ─────────────────────────────────────────────────────────────────────────────
-- Directory Information
-- ─────────────────────────────────────────────────────────────────────────────

-- The game's read-only source directory (where main.lua lives)
local source = luna.filesystem.getSource()            -- → "C:/Games/my_game"

-- The writable save directory (platform-specific)
local save_dir = luna.filesystem.getSaveDirectory()   -- → "C:/Users/.../AppData/Roaming/my_game"

-- Current working directory
local cwd = luna.filesystem.getWorkingDirectory()

-- Platform user home directory
local home = luna.filesystem.getUserDirectory()

-- The identity (subdirectory name) used inside the save directory
local identity = luna.filesystem.getIdentity()

-- Change the save identity (call BEFORE any file writes, usually in luna.conf)
luna.filesystem.setIdentity("my_game_v2")

-- ─────────────────────────────────────────────────────────────────────────────
-- Read / Write Files
-- ─────────────────────────────────────────────────────────────────────────────

-- Read entire file as a string (game dir first, then save dir)
local content = luna.filesystem.read("levels/level1.txt")

-- Write a string to a file in the save directory (creates subdirs automatically)
luna.filesystem.write("saves/slot1.sav", "level=5\nhp=100\n")

-- Append to an existing file (creates it if missing)
luna.filesystem.append("logs/session.log", "Session started\n")

-- Check existence
if luna.filesystem.exists("config.toml") then
    print("config found")
end

-- ─────────────────────────────────────────────────────────────────────────────
-- File Info & Metadata
-- ─────────────────────────────────────────────────────────────────────────────

-- Returns a table: {type="file"|"directory", size=N, modtime=unix_timestamp}
-- or nil if path does not exist
local info = luna.filesystem.getInfo("saves/slot1.sav")
if info then
    print("size:", info.size, "modified:", info.modtime)
end

local is_file = luna.filesystem.isFile("config.toml")
local is_dir  = luna.filesystem.isDirectory("levels/")

-- ─────────────────────────────────────────────────────────────────────────────
-- Directory Operations
-- ─────────────────────────────────────────────────────────────────────────────

-- List directory contents (returns a table of filenames, not full paths)
local items = luna.filesystem.getDirectoryItems("levels/")
for _, name in ipairs(items) do
    print(name)  -- e.g. "level1.txt", "level2.txt", ...
end

-- Create a directory (and all parents) in the save directory
luna.filesystem.createDirectory("screenshots/2024")

-- Remove a file or empty directory from the save directory
luna.filesystem.remove("saves/old_slot.sav")

-- ─────────────────────────────────────────────────────────────────────────────
-- Iterate Lines
-- ─────────────────────────────────────────────────────────────────────────────

-- Returns an iterator that yields one line at a time
for line in luna.filesystem.lines("dialog/intro.txt") do
    print(line)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Load Lua Chunks
-- ─────────────────────────────────────────────────────────────────────────────

-- Load and compile a Lua file from the game directory as a function
local chunk = luna.filesystem.load("scripts/util.lua")
if chunk then
    chunk()  -- execute it
end

-- ─────────────────────────────────────────────────────────────────────────────
-- FileHandle — Manual Low-Level Access
-- ─────────────────────────────────────────────────────────────────────────────

-- Open a file handle (mode: "r" | "w" | "a" | "rb" | "wb" | "ab")
local fh = luna.filesystem.openFile("saves/slot1.sav", "r")

-- Read N bytes (or all remaining if count omitted)
local all  = fh:read()
local part = fh:read(64)   -- up to 64 bytes

-- Read one line (strips trailing newline)
local line = fh:readLine()

-- Current size of the file
local sz = fh:getSize()

-- Current read/write position
local pos = fh:tell()

-- Seek to byte offset
fh:seek(0)   -- rewind to start

-- End-of-file
if fh:isEOF() then print("done") end

-- Write (only in "w" / "a" modes)
local wfh = luna.filesystem.openFile("saves/slot2.sav", "w")
wfh:write("hp=100\n")
wfh:write("level=3\n")
wfh:flush()  -- flush OS write buffer
wfh:close()

-- Mode query
local mode = fh:getMode()  -- → "r" or "w" or "a" etc.
fh:close()

-- ─────────────────────────────────────────────────────────────────────────────
-- FileData — In-Memory File Object
-- ─────────────────────────────────────────────────────────────────────────────

-- Load a file fully into memory as a FileData object.
-- Useful for passing to image/audio loaders without touching the file system again.
local fd = luna.filesystem.newFileData("textures/player.png")
local size     = fd:getSize()        -- byte length
local raw      = fd:getString()      -- byte content as a Lua string
local filename = fd:getFilename()    -- → "textures/player.png"

-- ─────────────────────────────────────────────────────────────────────────────
-- Async Reading (non-blocking)
-- ─────────────────────────────────────────────────────────────────────────────

-- Start an async read; returns an opaque handle immediately
local handle = luna.filesystem.readAsync("levels/bigmap.bin")

-- Poll each frame until done (returns status + data when ready)
function luna.update(dt)
    if handle then
        local status, data = luna.filesystem.pollAsync(handle)
        if status == "done" then
            -- data is a string with the file contents
            handle = nil
            -- process data...
        elseif status == "error" then
            print("async read failed")
            handle = nil
        end
        -- status == "pending" → still loading, poll again next frame
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Virtual Filesystem — Mount Points
-- ─────────────────────────────────────────────────────────────────────────────

-- Mount a directory or ZIP archive at a virtual path.
-- Files inside the mount shadow any same-named files at lower-priority mounts.
-- Useful for mod support, DLC, or loading asset packs.
luna.filesystem.mount("dlc/expansion.zip", "dlc")
luna.filesystem.mount("mods/my_mod/",      "mods/my_mod")

-- Query a path under a mount as if it were part of the game FS
local exists = luna.filesystem.exists("dlc/new_level.txt")

-- Unmount by the same source path used in mount()
luna.filesystem.unmount("dlc/expansion.zip")
