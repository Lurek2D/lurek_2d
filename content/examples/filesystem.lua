-- content/examples/filesystem.lua
-- Auto-generated from content/examples2/filesystem_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/filesystem.lua



--- Filesystem Module Part 1: paths, read/write, directory ops

--@api: lurek.filesystem.getSource
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local source_root = lurek.filesystem.getSource()
    local examples_path = source_root .. "/content/examples"
    local looks_absolute = source_root:find(":") ~= nil or source_root:sub(1, 1) == "/"
    local style = looks_absolute and "absolute" or "relative"
    lurek.log.info("source root for content discovery is " .. style .. ": " .. examples_path)
end

--@api: lurek.filesystem.getSaveDirectory
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local save_root = lurek.filesystem.getSaveDirectory()
    local profile_slot = save_root .. "/example_filesystem/profiles/slot_01.json"
    local looks_absolute = save_root:find(":") ~= nil or save_root:sub(1, 1) == "/"
    local style = looks_absolute and "absolute" or "relative"
    lurek.log.info("save root for profile data is " .. style .. ": " .. profile_slot)
end

--@api: lurek.filesystem.getWorkingDirectory
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local cwd = lurek.filesystem.getWorkingDirectory()
    local content_path = cwd .. "/content"
    local tests_path = cwd .. "/tests"
    local summary = "content=" .. content_path .. " tests=" .. tests_path
    lurek.log.info("working directory anchors repo-relative tooling: " .. summary)
end

--@api: lurek.filesystem.getUserDirectory
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local user_root = lurek.filesystem.getUserDirectory()
    local backup_path = user_root .. "/LurekBackups"
    local profile_name = lurek.filesystem.getIdentity()
    local summary = "user backup root for " .. profile_name .. " -> " .. backup_path
    lurek.log.info(summary)
end

--@api: lurek.filesystem.getIdentity
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local identity = lurek.filesystem.getIdentity()
    local save_root = lurek.filesystem.getSaveDirectory()
    local slot_path = save_root .. "/example_filesystem/profiles/slot_01.json"
    local summary = "active identity=" .. identity .. " slot=" .. slot_path
    lurek.log.info(summary)
end

--@api: lurek.filesystem.setIdentity
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local original = lurek.filesystem.getIdentity()
    local preview_identity = "codex_example_identity"
    lurek.filesystem.setIdentity(preview_identity)
    local changed = lurek.filesystem.getIdentity()
    lurek.filesystem.setIdentity(original)
    lurek.log.info("identity swap for save migration preview: " .. original .. " -> " .. changed .. " -> " .. original)
end

--@api: lurek.filesystem.toAbsolutePath
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local relative_path = PROFILE_DIR .. "slot_01.json"
    local absolute_path = lurek.filesystem.toAbsolutePath(relative_path)
    local save_root = lurek.filesystem.getSaveDirectory()
    local is_under_save = absolute_path:find(save_root, 1, true) ~= nil
    lurek.log.info("absolute profile path resolves under save root=" .. tostring(is_under_save) .. ": " .. absolute_path)
end

--@api: lurek.filesystem.exists
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local profile_path = PROFILE_DIR .. "exists_slot.json"
    lurek.filesystem.createDirectory(PROFILE_DIR)
    lurek.filesystem.write(profile_path, '{"name":"Ada","level":7}')
    local exists = lurek.filesystem.exists(profile_path)
    lurek.log.info("profile save exists after write=" .. tostring(exists) .. " at " .. profile_path)
end

--@api: lurek.filesystem.isFile
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local profile_path = PROFILE_DIR .. "slot_file_check.json"
    lurek.filesystem.createDirectory(PROFILE_DIR)
    lurek.filesystem.write(profile_path, '{"name":"Mira","coins":12}')
    local is_file = lurek.filesystem.isFile(profile_path)
    lurek.log.info("profile slot is a file=" .. tostring(is_file) .. " for " .. profile_path)
end

--@api: lurek.filesystem.isDirectory
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local slot_dir = PROFILE_DIR .. "campaign_one/"
    lurek.filesystem.createDirectory(slot_dir)
    local is_directory = lurek.filesystem.isDirectory(slot_dir)
    local has_parent = lurek.filesystem.isDirectory(PROFILE_DIR)
    local summary = "campaign dir=" .. tostring(is_directory) .. " parent=" .. tostring(has_parent)
    lurek.log.info(summary)
end

--@api: lurek.filesystem.getInfo
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local path = PROFILE_DIR .. "info_slot.json"
    lurek.filesystem.createDirectory(PROFILE_DIR)
    lurek.filesystem.write(path, '{"chapter":"forest","hp":18}')
    local info = lurek.filesystem.getInfo(path)
    local summary = info and ("type=" .. tostring(info.type) .. " size=" .. tostring(info.size)) or "missing"
    lurek.log.info("profile info for save browser: " .. summary)
end

--@api: lurek.filesystem.stat
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local path = PROFILE_DIR .. "stat_slot.json"
    lurek.filesystem.createDirectory(PROFILE_DIR)
    lurek.filesystem.write(path, '{"chapter":"cave","hp":24}')
    local stat = lurek.filesystem.stat(path)
    local summary = stat and ("size=" .. tostring(stat.size) .. " isFile=" .. tostring(stat.isFile)) or "missing"
    lurek.log.info("stat for checkpoint file: " .. summary)
end

--@api: lurek.filesystem.read
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local path = PROFILE_DIR .. "read_slot.json"
    lurek.filesystem.createDirectory(PROFILE_DIR)
    lurek.filesystem.write(path, '{"name":"Nova","quest":"intro"}')
    local json = lurek.filesystem.read(path)
    local has_intro = json:find("intro", 1, true) ~= nil
    lurek.log.info("loaded checkpoint json bytes=" .. tostring(#json) .. " intro=" .. tostring(has_intro))
end

--@api: lurek.filesystem.write
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local path = PROFILE_DIR .. "write_slot.json"
    local payload = '{"name":"Rune","xp":130,"zone":"village"}'
    lurek.filesystem.createDirectory(PROFILE_DIR)
    lurek.filesystem.write(path, payload)
    lurek.log.info("wrote profile snapshot bytes=" .. tostring(#payload) .. " to " .. path)
end

--@api: lurek.filesystem.append
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local path = FS_ROOT .. "session.log"
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.write(path, "spawn=village")
    lurek.filesystem.append(path, "\nquest=accepted")
    local contents = lurek.filesystem.read(path)
    lurek.log.info("session log grew to " .. tostring(#contents) .. " bytes after quest append")
end

--@api: lurek.filesystem.copy
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local src = PROFILE_DIR .. "slot_copy_source.json"
    local dst = PROFILE_DIR .. "slot_copy_backup.json"
    lurek.filesystem.createDirectory(PROFILE_DIR)
    lurek.filesystem.write(src, '{"name":"Iris","zone":"ruins"}')
    lurek.filesystem.copy(src, dst)
    lurek.log.info("copied profile backup exists=" .. tostring(lurek.filesystem.exists(dst)) .. " at " .. dst)
end

--@api: lurek.filesystem.move
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local src = PROFILE_DIR .. "slot_move_tmp.json"
    local dst = PROFILE_DIR .. "slot_move_final.json"
    lurek.filesystem.createDirectory(PROFILE_DIR)
    lurek.filesystem.write(src, '{"name":"Tao","zone":"tower"}')
    lurek.filesystem.move(src, dst)
    lurek.log.info("renamed autosave into final slot=" .. tostring(lurek.filesystem.exists(dst)))
end

--@api: lurek.filesystem.remove
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local path = CACHE_DIR .. "obsolete_manifest.txt"
    lurek.filesystem.createDirectory(CACHE_DIR)
    lurek.filesystem.write(path, "cache=v1")
    lurek.filesystem.remove(path)
    local exists = lurek.filesystem.exists(path)
    lurek.log.info("removed obsolete cache manifest=" .. tostring(not exists) .. " from " .. path)
end

--@api: lurek.filesystem.createDirectory
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local path = PROFILE_DIR .. "campaign_two/checkpoint_a/"
    lurek.filesystem.createDirectory(path)
    local parent_ready = lurek.filesystem.isDirectory(PROFILE_DIR)
    local child_ready = lurek.filesystem.isDirectory(path)
    lurek.log.info("created nested campaign folders parent=" .. tostring(parent_ready) .. " child=" .. tostring(child_ready))
end

--@api: lurek.filesystem.mkdir
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local path = CACHE_DIR .. "shader/prewarm/"
    lurek.filesystem.mkdir(path)
    local ready = lurek.filesystem.isDirectory(path)
    local absolute = lurek.filesystem.toAbsolutePath(path)
    lurek.log.info("mkdir prepared shader cache=" .. tostring(ready) .. " at " .. absolute)
end

--@api: lurek.filesystem.removeDir
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local path = CACHE_DIR .. "old_build/"
    lurek.filesystem.createDirectory(path)
    lurek.filesystem.write(path .. "atlas.txt", "old atlas")
    lurek.filesystem.removeDir(path)
    local exists = lurek.filesystem.isDirectory(path)
    lurek.log.info("removed old build cache directory=" .. tostring(not exists) .. " at " .. path)
end

--@api: lurek.filesystem.getDirectoryItems
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local dir = PROFILE_DIR .. "slot_browser/"
    lurek.filesystem.createDirectory(dir)
    lurek.filesystem.write(dir .. "slot_a.json", '{"slot":"A"}')
    lurek.filesystem.write(dir .. "slot_b.json", '{"slot":"B"}')
    local items = lurek.filesystem.getDirectoryItems(dir)
    lurek.log.info("save browser sees " .. tostring(#items) .. " immediate entries in " .. dir)
end

--@api: lurek.filesystem.listRecursive
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local dir = CACHE_DIR .. "imports/"
    lurek.filesystem.createDirectory(dir .. "audio/")
    lurek.filesystem.write(dir .. "manifest.txt", "import=ambient")
    lurek.filesystem.write(dir .. "audio/theme.txt", "placeholder")
    local items = lurek.filesystem.listRecursive(dir)
    lurek.log.info("recursive import scan found " .. tostring(#items) .. " paths under " .. dir)
end

--@api: lurek.filesystem.glob
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local dir = CACHE_DIR .. "glob/"
    lurek.filesystem.createDirectory(dir)
    lurek.filesystem.write(dir .. "forest.cache", "ok")
    lurek.filesystem.write(dir .. "desert.cache", "ok")
    local matches = lurek.filesystem.glob(dir .. "*.cache")
    lurek.log.info("cache glob matched " .. tostring(#matches) .. " prebuilt biome files")
end

--@api: lurek.filesystem.lines
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local path = FS_ROOT .. "dialogue.txt"
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.write(path, "hero=ready\nmentor=wait\nquest=go")
    local count = 0
    for _ in lurek.filesystem.lines(path) do
        count = count + 1
    end
    lurek.log.info("streamed " .. tostring(count) .. " dialogue lines from " .. path)
end

--@api: lurek.filesystem.createTempFile
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local temp_path = lurek.filesystem.createTempFile("draft_")
    local draft_payload = "seed=42\nbiome=forest\nweather=rain"
    lurek.filesystem.write(temp_path, draft_payload)
    local exists = lurek.filesystem.exists(temp_path)
    local preview = lurek.filesystem.read(temp_path)
    lurek.log.info("temporary export draft exists=" .. tostring(exists) .. " bytes=" .. tostring(#preview))
end

--@api: lurek.filesystem.readJson
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local path = PROFILE_DIR .. "read_json_slot.json"
    lurek.filesystem.createDirectory(PROFILE_DIR)
    lurek.filesystem.writeJson(path, '{"name":"Kira","score":42}')
    local json = lurek.filesystem.readJson(path)
    local has_score = json:find("score", 1, true) ~= nil
    lurek.log.info("read raw json bytes=" .. tostring(#json) .. " scoreField=" .. tostring(has_score))
end

--@api: lurek.filesystem.writeJson
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local path = PROFILE_DIR .. "write_json_slot.json"
    local payload = '{"name":"Nox","difficulty":"hard"}'
    lurek.filesystem.createDirectory(PROFILE_DIR)
    lurek.filesystem.writeJson(path, payload)
    local bytes = #lurek.filesystem.read(path)
    lurek.log.info("persisted structured options bytes=" .. tostring(bytes) .. " to " .. path)
end

--@api: lurek.filesystem.readOrWriteJson
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local path = PROFILE_DIR .. "defaults_slot.json"
    local default_json = '{"volume":80,"fullscreen":false,"language":"pl"}'
    lurek.filesystem.createDirectory(PROFILE_DIR)
    local result = lurek.filesystem.readOrWriteJson(path, default_json)
    local saved = lurek.filesystem.exists(path)
    lurek.log.info("readOrWriteJson seeded defaults=" .. tostring(saved) .. " bytes=" .. tostring(#result))
end

--- Filesystem Module Part 2: file handles, binary, async, mount, watch, load

--@api: lurek.filesystem.openFile
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local path = FS_ROOT .. "handle_open.log"
    lurek.filesystem.createDirectory(FS_ROOT)
    local handle = lurek.filesystem.openFile(path, "w")
    handle:write("encounter=start\n")
    handle:close()
    lurek.log.info("opened encounter log with handle and wrote first line to " .. path)
end

--@api: LFileHandle:read
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local path = FS_ROOT .. "handle_read.log"
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.write(path, "encounter=boss\nstate=phase2")
    local handle = lurek.filesystem.openFile(path, "r")
    local preview = handle:read(15)
    handle:close()
    lurek.log.info("read preview from encounter log: " .. preview)
end

--@api: LFileHandle:readLine
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local path = FS_ROOT .. "handle_lines.log"
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.write(path, "room=foyer\nroom=hall\nroom=vault")
    local handle = lurek.filesystem.openFile(path, "r")
    local first_line = handle:readLine()
    handle:close()
    lurek.log.info("parsed first room line from route log: " .. first_line)
end

--@api: LFileHandle:write
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local path = FS_ROOT .. "handle_write.log"
    lurek.filesystem.createDirectory(FS_ROOT)
    local handle = lurek.filesystem.openFile(path, "w")
    handle:write("tick=1\n")
    handle:write("tick=2\n")
    handle:close()
    lurek.log.info("wrote two simulation ticks via a persistent handle")
end

--@api: LFileHandle:seek
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local path = FS_ROOT .. "handle_seek.log"
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.write(path, "HP=035|MP=012|ZONE=RUINS")
    local handle = lurek.filesystem.openFile(path, "r")
    handle:seek(7)
    local preview = handle:read(6)
    handle:close()
    lurek.log.info("seek jumped to MP field and read " .. preview)
end

--@api: LFileHandle:tell
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local path = FS_ROOT .. "handle_tell.log"
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.write(path, "frame0001\nframe0002\n")
    local handle = lurek.filesystem.openFile(path, "r")
    handle:read(9)
    local cursor = handle:tell()
    handle:close()
    lurek.log.info("replay parser cursor after one frame tag=" .. tostring(cursor))
end

--@api: LFileHandle:getSize
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local path = FS_ROOT .. "handle_size.log"
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.write(path, "camera=10,20,1.2")
    local handle = lurek.filesystem.openFile(path, "r")
    local bytes = handle:getSize()
    handle:close()
    lurek.log.info("camera bookmark file size=" .. tostring(bytes) .. " bytes")
end

--@api: LFileHandle:getMode
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local path = FS_ROOT .. "handle_mode.log"
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.write(path, "quests=3")
    local handle = lurek.filesystem.openFile(path, "r")
    local mode = handle:getMode()
    handle:close()
    lurek.log.info("opened quest summary handle in mode=" .. mode)
end

--@api: LFileHandle:isEOF
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local path = FS_ROOT .. "handle_eof.log"
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.write(path, "alpha\nbeta")
    local handle = lurek.filesystem.openFile(path, "r")
    handle:read()
    local eof = handle:isEOF()
    handle:close()
    lurek.log.info("reader reached end of log=" .. tostring(eof))
end

--@api: LFileHandle:flush
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local path = FS_ROOT .. "handle_flush.log"
    lurek.filesystem.createDirectory(FS_ROOT)
    local handle = lurek.filesystem.openFile(path, "w")
    handle:write("boss_phase=2")
    handle:flush()
    handle:close()
    lurek.log.info("flushed boss phase update before closing handle")
end

--@api: LFileHandle:close
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local path = FS_ROOT .. "handle_close.log"
    lurek.filesystem.createDirectory(FS_ROOT)
    local handle = lurek.filesystem.openFile(path, "w")
    handle:write("checkpoint=sealed")
    handle:close()
    local saved = lurek.filesystem.read(path)
    lurek.log.info("closed checkpoint handle with bytes=" .. tostring(#saved))
end

--@api: LFileHandle:type
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local path = FS_ROOT .. "handle_type.log"
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.write(path, "data=x")
    local handle = lurek.filesystem.openFile(path, "r")
    local type_name = handle:type()
    handle:close()
    lurek.log.info("file handle userdata type=" .. type_name)
end

--@api: LFileHandle:typeOf
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local path = FS_ROOT .. "handle_typeof.log"
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.write(path, "data=x")
    local handle = lurek.filesystem.openFile(path, "r")
    local matches = handle:typeOf("LFileHandle")
    handle:close()
    lurek.log.info("typeOf confirms LFileHandle=" .. tostring(matches))
end

--@api: lurek.filesystem.newFileData
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local path = FS_ROOT .. "filedata_blob.txt"
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.write(path, "spawn=river\nambient=wind")
    local data = lurek.filesystem.newFileData(path)
    local size = data:getSize()
    lurek.log.info("captured immutable file data bytes=" .. tostring(size) .. " from " .. path)
end

--@api: LFileData:getSize
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local path = FS_ROOT .. "filedata_size.txt"
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.write(path, "enemy=archer")
    local data = lurek.filesystem.newFileData(path)
    local size = data:getSize()
    lurek.log.info("file data size for enemy template=" .. tostring(size))
end

--@api: LFileData:getString
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local path = FS_ROOT .. "filedata_string.txt"
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.write(path, "weather=storm")
    local data = lurek.filesystem.newFileData(path)
    local payload = data:getString()
    lurek.log.info("file data payload for weather preset: " .. payload)
end

--@api: LFileData:getFilename
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local path = FS_ROOT .. "filedata_name.txt"
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.write(path, "seed=9301")
    local data = lurek.filesystem.newFileData(path)
    local filename = data:getFilename()
    lurek.log.info("file data remembers source filename=" .. filename)
end

--@api: LFileData:type
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local path = FS_ROOT .. "filedata_type.txt"
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.write(path, "hint=secret")
    local data = lurek.filesystem.newFileData(path)
    local type_name = data:type()
    lurek.log.info("file data userdata type=" .. type_name)
end

--@api: LFileData:typeOf
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local path = FS_ROOT .. "filedata_typeof.txt"
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.write(path, "hint=secret")
    local data = lurek.filesystem.newFileData(path)
    local matches = data:typeOf("LFileData")
    lurek.log.info("typeOf confirms LFileData=" .. tostring(matches))
end

--@api: lurek.filesystem.readBytes
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local path = FS_ROOT .. "palette.bin"
    local bytes = string.char(0, 64, 128, 255)
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.writeBytes(path, bytes)
    local payload = lurek.filesystem.readBytes(path)
    lurek.log.info("read palette blob bytes=" .. tostring(#payload) .. " from " .. path)
end

--@api: lurek.filesystem.writeBytes
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local path = FS_ROOT .. "navmesh.bin"
    local bytes = string.char(4, 8, 15, 16, 23, 42)
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.writeBytes(path, bytes)
    local payload = lurek.filesystem.readBytes(path)
    lurek.log.info("wrote binary navmesh bytes=" .. tostring(#payload) .. " to " .. path)
end

--@api: lurek.filesystem.readAsync
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local path = FS_ROOT .. "async_read.json"
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.write(path, '{"region":"forest","npcs":14}')
    local ticket = lurek.filesystem.readAsync(path)
    local exists = lurek.filesystem.exists(path)
    lurek.log.info("queued async region read ticket=" .. tostring(ticket) .. " exists=" .. tostring(exists))
end

--@api: lurek.filesystem.pollAsync
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

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
    lurek.log.info("async read completed with status=" .. tostring(status) .. " bytes=" .. tostring(payload and #payload or 0))
end

--@api: lurek.filesystem.writeAsync
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local path = FS_ROOT .. "async_write.json"
    lurek.filesystem.createDirectory(FS_ROOT)
    local payload = '{"region":"tower","npcs":3}'
    local ticket = lurek.filesystem.writeAsync(path, payload)
    local absolute = lurek.filesystem.toAbsolutePath(path)
    lurek.log.info("queued async write ticket=" .. tostring(ticket) .. " for " .. absolute)
end

--@api: lurek.filesystem.pollAsyncWrite
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

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
    lurek.log.info("async write finished status=" .. tostring(status) .. " persisted=" .. tostring(persisted))
end

--@api: lurek.filesystem.mount
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local mountpoint = "example_assets"
    lurek.filesystem.unmount(mountpoint)
    local mounted = lurek.filesystem.mount("content/examples/assets", mountpoint)
    local items = lurek.filesystem.getDirectoryItems(mountpoint)
    lurek.log.info("mounted shared assets=" .. tostring(mounted) .. " visible entries=" .. tostring(#items))
end

--@api: lurek.filesystem.unmount
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local mountpoint = "example_assets_cleanup"
    lurek.filesystem.mount("content/examples/assets", mountpoint)
    local before = lurek.filesystem.getDirectoryItems(mountpoint)
    local removed = lurek.filesystem.unmount(mountpoint)
    local after = lurek.filesystem.unmount(mountpoint)
    lurek.log.info("unmounted asset overlay removed=" .. tostring(removed) .. " firstView=" .. tostring(#before) .. " secondTry=" .. tostring(after))
end

--@api: lurek.filesystem.mountZip
do
    local ok, err = pcall(function()
        local FS_ROOT = "save/example_filesystem/"
        local PROFILE_DIR = FS_ROOT .. "profiles/"
        local CACHE_DIR = FS_ROOT .. "cache/"
        local WATCH_DIR = FS_ROOT .. "watch/"
        local WATCH_FILE = WATCH_DIR .. "settings.json"
        local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

        local zip = lurek.filesystem.mountZip(ZIP_FIXTURE, "zip_preview")
        local prefix = zip:prefix()
        local files = zip:listFiles()
        local contains_hello = zip:contains("zip_preview/hello.txt")
        lurek.log.info("zip mount prefix=" .. prefix .. " files=" .. tostring(#files) .. " containsHello=" .. tostring(contains_hello))
    end)
    if not ok then
        lurek.log.info("zip mount unavailable: " .. tostring(err))
        lurek.log.info("skipping lurek.filesystem.mountZip")
    end
end

--@api: LZipMount:readFile
do
    local ok, err = pcall(function()
        local FS_ROOT = "save/example_filesystem/"
        local PROFILE_DIR = FS_ROOT .. "profiles/"
        local CACHE_DIR = FS_ROOT .. "cache/"
        local WATCH_DIR = FS_ROOT .. "watch/"
        local WATCH_FILE = WATCH_DIR .. "settings.json"
        local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

        local zip = lurek.filesystem.mountZip(ZIP_FIXTURE, "zip_read")
        local payload = zip:readFile("zip_read/hello.txt")
        local size = #payload
        local prefix = zip:prefix()
        local summary = "zip payload bytes=" .. tostring(size) .. " from " .. prefix
        lurek.log.info(summary)
    end)
    if not ok then
        lurek.log.info("zip mount unavailable: " .. tostring(err))
        lurek.log.info("skipping LZipMount:readFile")
    end
end

--@api: LZipMount:contains
do
    local ok, err = pcall(function()
        local FS_ROOT = "save/example_filesystem/"
        local PROFILE_DIR = FS_ROOT .. "profiles/"
        local CACHE_DIR = FS_ROOT .. "cache/"
        local WATCH_DIR = FS_ROOT .. "watch/"
        local WATCH_FILE = WATCH_DIR .. "settings.json"
        local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

        local zip = lurek.filesystem.mountZip(ZIP_FIXTURE, "zip_contains")
        local has_hello = zip:contains("zip_contains/hello.txt")
        local has_missing = zip:contains("zip_contains/missing.txt")
        local prefix = zip:prefix()
        lurek.log.info("zip lookup under " .. prefix .. " hello=" .. tostring(has_hello) .. " missing=" .. tostring(has_missing))
    end)
    if not ok then
        lurek.log.info("zip mount unavailable: " .. tostring(err))
        lurek.log.info("skipping LZipMount:contains")
    end
end

--@api: LZipMount:listFiles
do
    local ok, err = pcall(function()
        local FS_ROOT = "save/example_filesystem/"
        local PROFILE_DIR = FS_ROOT .. "profiles/"
        local CACHE_DIR = FS_ROOT .. "cache/"
        local WATCH_DIR = FS_ROOT .. "watch/"
        local WATCH_FILE = WATCH_DIR .. "settings.json"
        local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

        local zip = lurek.filesystem.mountZip(ZIP_FIXTURE, "zip_list")
        local files = zip:listFiles()
        local first = files[1] or "none"
        local count = #files
        lurek.log.info("zip file catalog count=" .. tostring(count) .. " first=" .. tostring(first))
    end)
    if not ok then
        lurek.log.info("zip mount unavailable: " .. tostring(err))
        lurek.log.info("skipping LZipMount:listFiles")
    end
end

--@api: LZipMount:prefix
do
    local ok, err = pcall(function()
        local FS_ROOT = "save/example_filesystem/"
        local PROFILE_DIR = FS_ROOT .. "profiles/"
        local CACHE_DIR = FS_ROOT .. "cache/"
        local WATCH_DIR = FS_ROOT .. "watch/"
        local WATCH_FILE = WATCH_DIR .. "settings.json"
        local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

        local zip = lurek.filesystem.mountZip(ZIP_FIXTURE, "zip_prefix")
        local prefix = zip:prefix()
        local hello_path = prefix .. "/hello.txt"
        local exists = zip:contains(hello_path)
        lurek.log.info("zip prefix builds virtual asset path " .. hello_path .. " exists=" .. tostring(exists))
    end)
    if not ok then
        lurek.log.info("zip mount unavailable: " .. tostring(err))
        lurek.log.info("skipping LZipMount:prefix")
    end
end

--@api: LZipMount:type
do
    local ok, err = pcall(function()
        local FS_ROOT = "save/example_filesystem/"
        local PROFILE_DIR = FS_ROOT .. "profiles/"
        local CACHE_DIR = FS_ROOT .. "cache/"
        local WATCH_DIR = FS_ROOT .. "watch/"
        local WATCH_FILE = WATCH_DIR .. "settings.json"
        local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

        local zip = lurek.filesystem.mountZip(ZIP_FIXTURE, "zip_type")
        local type_name = zip:type()
        local prefix = zip:prefix()
        local file_count = #zip:listFiles()
        lurek.log.info("zip mount type=" .. type_name .. " prefix=" .. prefix .. " files=" .. tostring(file_count))
    end)
    if not ok then
        lurek.log.info("zip mount unavailable: " .. tostring(err))
        lurek.log.info("skipping LZipMount:type")
    end
end

--@api: LZipMount:typeOf
do
    local ok, err = pcall(function()
        local FS_ROOT = "save/example_filesystem/"
        local PROFILE_DIR = FS_ROOT .. "profiles/"
        local CACHE_DIR = FS_ROOT .. "cache/"
        local WATCH_DIR = FS_ROOT .. "watch/"
        local WATCH_FILE = WATCH_DIR .. "settings.json"
        local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

        local zip = lurek.filesystem.mountZip(ZIP_FIXTURE, "zip_typeof")
        local matches = zip:typeOf("LZipMount")
        local prefix = zip:prefix()
        local has_hello = zip:contains(prefix .. "/hello.txt")
        lurek.log.info("typeOf confirms LZipMount=" .. tostring(matches) .. " hello=" .. tostring(has_hello))
    end)
    if not ok then
        lurek.log.info("zip mount unavailable: " .. tostring(err))
        lurek.log.info("skipping LZipMount:typeOf")
    end
end

--@api: lurek.filesystem.load
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    local path = FS_ROOT .. "spawn_rules.lua"
    lurek.filesystem.createDirectory(FS_ROOT)
    lurek.filesystem.write(path, "return function() return { biome = 'forest', enemies = 5 } end")
    local chunk = lurek.filesystem.load(path)
    local build_rules = chunk()
    local rules = build_rules()
    lurek.log.info("loaded scripted spawn rules biome=" .. tostring(rules.biome) .. " enemies=" .. tostring(rules.enemies))
end

--@api: lurek.filesystem.watchPath
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    lurek.filesystem.createDirectory(WATCH_DIR)
    lurek.filesystem.write(WATCH_FILE, '{"volume":70}')
    lurek.filesystem.watchPath(WATCH_FILE)
    lurek.filesystem.pollWatchers()
    lurek.log.info("registered live watch for settings file " .. WATCH_FILE)
end

--@api: lurek.filesystem.unwatchPath
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    lurek.filesystem.createDirectory(WATCH_DIR)
    lurek.filesystem.write(WATCH_FILE, '{"volume":72}')
    lurek.filesystem.watchPath(WATCH_FILE)
    lurek.filesystem.unwatchPath(WATCH_FILE)
    local changed = lurek.filesystem.pollWatchers()
    lurek.log.info("stopped watching settings file, pending notifications=" .. tostring(#changed))
end

--@api: lurek.filesystem.pollWatchers
do
    local FS_ROOT = "save/example_filesystem/"
    local PROFILE_DIR = FS_ROOT .. "profiles/"
    local CACHE_DIR = FS_ROOT .. "cache/"
    local WATCH_DIR = FS_ROOT .. "watch/"
    local WATCH_FILE = WATCH_DIR .. "settings.json"
    local ZIP_FIXTURE = "tests/fixtures/test_archive.zip"

    lurek.filesystem.createDirectory(WATCH_DIR)
    lurek.filesystem.write(WATCH_FILE, '{"volume":74}')
    lurek.filesystem.watchPath(WATCH_FILE)
    lurek.filesystem.pollWatchers()
    lurek.filesystem.append(WATCH_FILE, '\n{"dirty":true}')
    local changed = lurek.filesystem.pollWatchers()
    lurek.filesystem.unwatchPath(WATCH_FILE)
    lurek.log.info("hot-reload poll observed " .. tostring(#changed) .. " changed path(s)")
end
