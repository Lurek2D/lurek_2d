-- Shared headless checks for content/games demos (tests/lua/demos/).
-- Loaded via dofile() from each test_<name>.lua file.

local function main_path(demo_dir)
    if demo_dir:sub(-1) == "/" or demo_dir:sub(-1) == "\\" then
        return demo_dir .. "main.lua"
    end
    return demo_dir .. "/main.lua"
end

--- Read main.lua; asserts readability via expect_not_nil.
function demo_read_main(demo_dir, label)
    label = label or demo_dir
    local path = main_path(demo_dir)
    local src = read_file(path)
    expect_not_nil(src, label .. ": main.lua must be readable at " .. path)
    return src
end

local function has_callback(src, name)
    return src:find("function lurek." .. name, 1, true) ~= nil
end

--- Assert lurek.init or lurek.load, lurek.process or lurek.update, and lurek.draw exist.
function demo_check_lifecycle(demo_dir, label)
    label = label or demo_dir
    local src = demo_read_main(demo_dir, label)
    local has_entry = has_callback(src, "init") or has_callback(src, "load")
    local has_tick = has_callback(src, "process") or has_callback(src, "update")
    local has_draw = has_callback(src, "draw")
    expect_true(has_entry, label .. ": missing lurek.init or lurek.load in main.lua")
    expect_true(has_tick, label .. ": missing lurek.process or lurek.update in main.lua")
    expect_true(has_draw, label .. ": missing lurek.draw in main.lua")
end

--- If conf.toml or conf.lua exists, assert it mentions window configuration.
function demo_check_conf_optional(demo_dir, label)
    label = label or demo_dir
    local conf = read_file(demo_dir .. "/conf.toml")
    if conf == nil then
        conf = read_file(demo_dir .. "/conf.lua")
    end
    if conf == nil then
        return
    end
    local has_window = conf:find("%[window%]", 1, true) ~= nil
        or conf:find("window", 1, true) ~= nil
        or conf:find("width", 1, true) ~= nil
        or conf:find("height", 1, true) ~= nil
    expect_true(has_window, label .. ": config should define window settings")
end

--- Assert main.lua does not call forbidden window-only entry points in headless audit.
function demo_check_no_direct_present(demo_dir, label)
    label = label or demo_dir
    local src = demo_read_main(demo_dir, label)
    expect_nil(
        src:find("lurek%.window%.present", 1, true),
        label .. ": main.lua should not call lurek.window.present (headless demos)"
    )
end
