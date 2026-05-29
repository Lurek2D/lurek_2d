-- Lightweight compatibility harness for legacy Lua tests using `t.*` helpers.

local t = {}

local total = 0
local failed = 0

local function fail(msg)
    error(msg, 2)
end

function t.test(name, fn)
    total = total + 1
    local ok, err = pcall(fn)
    if not ok then
        failed = failed + 1
        print("[FAIL] " .. name .. ": " .. tostring(err))
    else
        print("[PASS] " .. name)
    end
end

function t.assert(cond, msg)
    if not cond then
        fail(msg or "assertion failed")
    end
end

function t.assert_eq(actual, expected, msg)
    if actual ~= expected then
        local prefix = msg and (msg .. " - ") or ""
        fail(prefix .. "expected " .. tostring(expected) .. ", got " .. tostring(actual))
    end
end

function t.finish()
    if failed > 0 then
        error(string.format("%d/%d tests failed", failed, total))
    end
    print(string.format("%d/%d tests passed", total, total))
end

return t
