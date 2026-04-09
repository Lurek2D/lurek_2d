-- Validation tests for current single-file scripts in content/examples/.

require("tests/lua/init")

-- Helper: check if a file exists via io (available in test harness)
local function file_exists(path)
    local f = io.open(path, "r")
    if f then
        f:close()
        return true
    end
    return false
end

-- Helper: attempt to load a Lua file as a chunk (syntax check only)
-- Returns true if syntax is valid, false + error message otherwise.
local function check_syntax(path)
    local chunk, err = loadfile(path)
    if chunk then
        return true, nil
    end
    return false, err
end

local example_files = {
    "content/examples/audio.lua",
    "content/examples/graphics.lua",
    "content/examples/gui.lua",
    "content/examples/image.lua",
    "content/examples/input.lua",
    "content/examples/math.lua",
    "content/examples/physics.lua",
    "content/examples/scene.lua",
    "content/examples/terminal.lua",
    "content/examples/timer.lua",
}

describe("content/examples scripts exist", function()
    for _, path in ipairs(example_files) do
        it("exists: " .. path, (function(p)
            return function()
                expect_equal(file_exists(p), true)
            end
        end)(path))
    end
end)

describe("content/examples scripts have valid syntax", function()
    for _, path in ipairs(example_files) do
        it("syntax OK: " .. path, (function(p)
            return function()
                local ok, err = check_syntax(p)
                if not ok then
                    expect_equal("syntax OK", tostring(err))
                else
                    expect_equal(ok, true)
                end
            end
        end)(path))
    end
end)

test_summary()
