//! Implements Lua value pretty-print conversion for REPL and debug-facing display output.
//! Handles scalar and structured value variants with stable human-readable formatting behavior.
//! Returns safe fallback labels for unrecognized or unsupported value representations.

/// Convert one Lua value to display text and return a fallback for unknown kinds.
pub fn value_to_string(v: &mlua::Value) -> String {
    match v {
        mlua::Value::Nil => "nil".to_string(),
        mlua::Value::Boolean(b) => b.to_string(),
        mlua::Value::Integer(i) => i.to_string(),
        mlua::Value::Number(n) => format!("{n}"),
        mlua::Value::String(s) => s.to_str().unwrap_or("<string>").to_string(),
        mlua::Value::Table(_) => "<table>".to_string(),
        mlua::Value::Function(_) => "<function>".to_string(),
        mlua::Value::UserData(_) => "<userdata>".to_string(),
        _ => "<value>".to_string(),
    }
}
