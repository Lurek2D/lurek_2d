//! - Converts a single `mlua::Value` to a display string for REPL and headless stdout output.
//! - Covers all Lua value kinds; opaque types like tables and functions return fixed angle-bracket labels.
//! - Error values include the Lua error message; nil returns the literal string `"nil"`.

/// Convert one Lua value to display text and return a stable fallback for opaque values.
pub fn value_to_string(value: &mlua::Value) -> String {
    match value {
        mlua::Value::Nil => "nil".to_string(),
        mlua::Value::Boolean(flag) => flag.to_string(),
        mlua::Value::Integer(number) => number.to_string(),
        mlua::Value::Number(number) => format!("{}", number),
        mlua::Value::String(text) => text.to_str().unwrap_or("<string>").to_string(),
        mlua::Value::Table(_) => "<table>".to_string(),
        mlua::Value::Function(_) => "<function>".to_string(),
        mlua::Value::Thread(_) => "<thread>".to_string(),
        mlua::Value::UserData(_) => "<userdata>".to_string(),
        mlua::Value::LightUserData(_) => "<lightuserdata>".to_string(),
        mlua::Value::Error(error) => format!("<error: {}>", error),
    }
}
