//! Provides `complete_prefix` for tab completion against a static pool and live Lua globals.
//!
//! - Static pool includes Lua keywords, built-in globals, standard libraries, colon commands, and all `lurek.*` sub-namespaces.
//! - Dynamic branch resolves a dot-separated path through Lua globals and collects matching key names.
//! - Output is sorted and deduplicated; callers pass `None` for the Lua handle when no VM is available.

use mlua::prelude::*;

const STATIC_COMPLETIONS: &[&str] = &[
    ":clear",
    ":help",
    ":load",
    ":quit",
    ":reset",
    "and",
    "break",
    "do",
    "else",
    "elseif",
    "end",
    "false",
    "for",
    "function",
    "if",
    "in",
    "local",
    "nil",
    "not",
    "or",
    "repeat",
    "return",
    "then",
    "true",
    "until",
    "while",
    "_G",
    "_VERSION",
    "assert",
    "collectgarbage",
    "coroutine",
    "debug",
    "dofile",
    "error",
    "getfenv",
    "getmetatable",
    "io",
    "ipairs",
    "jit",
    "bit",
    "load",
    "loadfile",
    "loadstring",
    "math",
    "module",
    "next",
    "os",
    "package",
    "pairs",
    "pcall",
    "print",
    "rawequal",
    "rawget",
    "rawset",
    "require",
    "select",
    "setfenv",
    "setmetatable",
    "string",
    "table",
    "tonumber",
    "tostring",
    "type",
    "unpack",
    "xpcall",
    "lurek",
    "lurek.ai",
    "lurek.animation",
    "lurek.audio",
    "lurek.automation",
    "lurek.camera",
    "lurek.compute",
    "lurek.data",
    "lurek.dataframe",
    "lurek.debugbridge",
    "lurek.devtools",
    "lurek.docs",
    "lurek.ecs",
    "lurek.effect",
    "lurek.event",
    "lurek.filesystem",
    "lurek.globe",
    "lurek.graph",
    "lurek.html",
    "lurek.i18n",
    "lurek.image",
    "lurek.input",
    "lurek.light",
    "lurek.log",
    "lurek.math",
    "lurek.minimap",
    "lurek.mods",
    "lurek.network",
    "lurek.parallax",
    "lurek.particle",
    "lurek.pathfind",
    "lurek.patterns",
    "lurek.physics",
    "lurek.pipeline",
    "lurek.procgen",
    "lurek.province",
    "lurek.raycaster",
    "lurek.render",
    "lurek.repl",
    "lurek.runtime",
    "lurek.save",
    "lurek.scene",
    "lurek.serialize",
    "lurek.spine",
    "lurek.sprite",
    "lurek.terminal",
    "lurek.thread",
    "lurek.tilemap",
    "lurek.timer",
    "lurek.tween",
    "lurek.ui",
    "lurek.window",
];

/// Return sorted completions matching the supplied prefix.
pub fn complete_prefix(prefix: &str, lua: Option<&Lua>) -> Vec<String> {
    let mut completions: Vec<String> = STATIC_COMPLETIONS
        .iter()
        .filter(|candidate| candidate.starts_with(prefix))
        .map(|candidate| (*candidate).to_string())
        .collect();
    if let Some(lua) = lua {
        collect_lua_completions(lua, prefix, &mut completions);
    }
    completions.sort();
    completions.dedup();
    completions
}

/// Walk a Lua table at `path` and collect string keys that match `prefix`.
fn collect_lua_completions(lua: &Lua, prefix: &str, completions: &mut Vec<String>) {
    let Some((table_path, member_prefix)) = prefix.rsplit_once('.') else {
        return;
    };
    let Ok(table) = resolve_table(lua, table_path) else {
        return;
    };
    for pair in table.pairs::<mlua::Value, mlua::Value>() {
        let Ok((key, _)) = pair else {
            continue;
        };
        let key_text = match key {
            mlua::Value::String(text) => text.to_str().unwrap_or_default().to_string(),
            mlua::Value::Integer(number) => number.to_string(),
            _ => continue,
        };
        if key_text.starts_with(member_prefix) {
            completions.push(format!("{}.{}", table_path, key_text));
        }
    }
}

/// Navigate a dot-separated path through nested Lua globals and return the final table.
fn resolve_table<'lua>(lua: &'lua Lua, path: &str) -> LuaResult<LuaTable<'lua>> {
    let mut segments = path.split('.');
    let Some(first) = segments.next() else {
        return Err(mlua::Error::RuntimeError(
            "empty completion path".to_string(),
        ));
    };
    let mut table: LuaTable = lua.globals().get(first)?;
    for segment in segments {
        table = table.get(segment)?;
    }
    Ok(table)
}
