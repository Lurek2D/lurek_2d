#!/usr/bin/env python3
"""Fix call_lua_callback_checked to use 'lurek' instead of 'luna' global."""
import sys

with open('src/engine/app.rs', 'r', encoding='utf-8') as f:
    content = f.read()

counts_before = 0

# Pattern 1: in call_lua_callback_checked
marker1 = 'if let Ok(luna) = lua.globals().get::<_, LuaTable>("luna")'
if marker1 in content:
    counts_before += content.count(marker1)
    content = content.replace(
        'if let Ok(luna) = lua.globals().get::<_, LuaTable>("luna") {\n        if let Ok(func) = luna.get::<_, LuaFunction>(name) {',
        'if let Ok(lurek) = lua.globals().get::<_, LuaTable>("lurek") {\n        if let Ok(func) = lurek.get::<_, LuaFunction>(name) {'
    )
    print(f"Fixed call_lua_callback_checked: replaced {marker1!r}")
else:
    print("Pattern 1 not found - might already be fixed")

# Pattern 2: in try_errorhandler_or_screen
marker2 = 'if let Ok(luna) = lua.globals().get::<_, LuaTable>("luna")'
if marker2 in content:
    content = content.replace(
        'if let Ok(luna) = lua.globals().get::<_, LuaTable>("luna") {\n        if let Ok(handler) = luna.get::<_, LuaFunction>("errorhandler") {',
        'if let Ok(lurek) = lua.globals().get::<_, LuaTable>("lurek") {\n        if let Ok(handler) = lurek.get::<_, LuaFunction>("errorhandler") {'
    )
    print("Fixed try_errorhandler_or_screen")
else:
    print("Pattern 2 not found - might already be fixed")

# Verify no more luna occurrences in callback functions
if '"luna"' in content:
    # Check if any remain in the problematic functions
    lines_with_luna = [l for l in content.split('\n') if '"luna"' in l]
    print(f"Remaining 'luna' occurrences: {lines_with_luna}")
else:
    print("No more 'luna' string literals in file")

with open('src/engine/app.rs', 'w', encoding='utf-8') as f:
    f.write(content)
print("Saved app.rs")
