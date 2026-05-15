use lurek2d::repl::{ReplCommand, ReplResult, ReplSession};

#[test]
fn eval_expression_returns_value() {
    let lua = mlua::Lua::new();
    let mut session = ReplSession::new(8);

    let result = session.eval_line("2 + 3", &lua);

    assert_eq!(result, ReplResult::Value("5".to_string()));
    assert_eq!(session.history(), &["2 + 3".to_string()]);
}

#[test]
fn eval_statement_keeps_lua_state() {
    let lua = mlua::Lua::new();
    let mut session = ReplSession::new(8);

    assert_eq!(session.eval_line("answer = 41", &lua), ReplResult::Ok);
    assert_eq!(
        session.eval_line("answer + 1", &lua),
        ReplResult::Value("42".to_string())
    );
}

#[test]
fn history_is_bounded() {
    let lua = mlua::Lua::new();
    let mut session = ReplSession::new(2);

    session.eval_line("1", &lua);
    session.eval_line("2", &lua);
    session.eval_line("3", &lua);

    assert_eq!(session.history(), &["2".to_string(), "3".to_string()]);
}

#[test]
fn commands_return_command_results() {
    let lua = mlua::Lua::new();
    let mut session = ReplSession::new(8);

    assert_eq!(
        session.eval_line(":help", &lua),
        ReplResult::Command(ReplCommand::Help)
    );
    assert_eq!(
        session.eval_line(":quit", &lua),
        ReplResult::Command(ReplCommand::Quit)
    );
    assert_eq!(
        session.eval_line(":clear", &lua),
        ReplResult::Command(ReplCommand::Clear)
    );
    assert!(session.is_empty());
}

#[test]
fn load_command_executes_file() {
    let lua = mlua::Lua::new();
    let mut session = ReplSession::new(8);
    let dir = tempfile::tempdir().expect("tempdir");
    let file_path = dir.path().join("snippet.lua");
    std::fs::write(&file_path, "loaded_value = 19").expect("write snippet");

    let result = session.eval_line(&format!(":load {}", file_path.display()), &lua);

    assert!(matches!(
        result,
        ReplResult::Command(ReplCommand::Load { .. })
    ));
    assert_eq!(
        session.eval_line("loaded_value", &lua),
        ReplResult::Value("19".to_string())
    );
}

#[test]
fn completions_include_static_and_lua_table_items() {
    let lua = mlua::Lua::new();
    let session = ReplSession::new(8);
    lua.load("lurek = { repl = { new = function() end } }")
        .exec()
        .expect("seed lua table");

    let completions = session.completions_for("lurek.re", Some(&lua));

    assert!(completions.iter().any(|item| item == "lurek.repl"));
}
