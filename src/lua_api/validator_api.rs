//! Registers the `lurek.validator` Lua API for validator userdata, report conversion, and validation helpers.

use super::SharedState;
use crate::validator::{
    engine::ValidationEngine, report::Severity, rules_lua::LuaPatternRule, ValidatorConfig,
};
use mlua::prelude::*;
use std::cell::RefCell;
use std::path::PathBuf;
use std::rc::Rc;

fn parse_known_api_list(value: LuaValue, api: &str) -> LuaResult<Vec<String>> {
    match value {
        LuaValue::Nil => Ok(Vec::new()),
        LuaValue::String(value) => Ok(vec![value.to_str()?.to_string()]),
        LuaValue::Table(values) => {
            let mut known_apis = Vec::new();
            for entry in values.sequence_values::<String>() {
                known_apis.push(entry?);
            }
            Ok(known_apis)
        }
        other => Err(LuaError::RuntimeError(format!(
            "{api}: expected a string or array table of API prefixes, got {}",
            other.type_name()
        ))),
    }
}

fn known_api_list_from_opts(opts: &Option<LuaTable>, api: &str) -> LuaResult<Option<Vec<String>>> {
    let Some(opts) = opts else {
        return Ok(None);
    };
    let value = opts
        .get::<_, Option<LuaValue>>("api")
        .map_err(|err| LuaError::RuntimeError(format!("{api}: invalid api option: {err}")))?;
    let Some(value) = value else {
        return Ok(None);
    };
    let known_apis = parse_known_api_list(value, api)?;
    if known_apis.is_empty() {
        Ok(None)
    } else {
        Ok(Some(known_apis))
    }
}

fn add_api_rule_with_optional_known_apis(
    engine: &mut ValidationEngine,
    known_apis: Option<Vec<String>>,
) {
    if let Some(known_apis) = known_apis {
        engine.add_api_rule_with_known_apis(known_apis);
    } else {
        engine.add_api_rule();
    }
}

// ---------------------------------------------------------------------------
// Wrapper: LuaValidationEngine
// ---------------------------------------------------------------------------

/// Lua userdata that runs schema and constraint validation on data tables and files.
struct LuaValidationEngine {
    inner: Rc<RefCell<ValidationEngine>>,
}

impl LuaUserData for LuaValidationEngine {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- addAssetRule --
        /// Add the built-in asset existence rule.
        /// @param | asset_root | string | Root directory for asset files.
        methods.add_method("addAssetRule", |_, this, asset_root: String| {
            this.inner
                .borrow_mut()
                .add_asset_rule(PathBuf::from(asset_root));
            Ok(())
        });

        // -- addImportRule --
        /// Add the built-in import resolution rule.
        /// @param | paths | table | Array of Lua search paths.
        methods.add_method("addImportRule", |_, this, paths: Vec<String>| {
            let lua_paths: Vec<PathBuf> = paths.into_iter().map(PathBuf::from).collect();
            this.inner.borrow_mut().add_import_rule(lua_paths);
            Ok(())
        });

        // -- addApiRule --
        /// Add the built-in API compliance rule.
        /// @param | api | string|string[]? | Optional dotted API prefixes to treat as known roots instead of the default `lurek.*` list.
        methods.add_method("addApiRule", |_, this, api: Option<LuaValue>| {
            let known_apis = api
                .map(|value| parse_known_api_list(value, "LValidationEngine:addApiRule"))
                .transpose()?;
            add_api_rule_with_optional_known_apis(&mut this.inner.borrow_mut(), known_apis);
            Ok(())
        });

        // -- addPatternRule --
        /// Add a custom regex pattern rule to the validation engine.
        /// @param | id | string | Rule identifier.
        /// @param | pattern | string | Text pattern to match.
        /// @param | message | string | Violation message.
        /// @param | severity | string | Severity: hint, warning, error, critical.
        methods.add_method(
            "addPatternRule",
            |_, this, (id, pattern, message, severity): (String, String, String, String)| {
                let sev = Severity::from_name(&severity);
                let rule = LuaPatternRule::new(id, pattern, message, sev);
                this.inner.borrow_mut().add_pattern_rule(rule);
                Ok(())
            },
        );

        // -- addRequiredRule --
        /// Add a required pattern rule (violation if pattern NOT found).
        /// @param | id | string | Rule identifier.
        /// @param | pattern | string | Required text pattern.
        /// @param | message | string | Violation message.
        methods.add_method(
            "addRequiredRule",
            |_, this, (id, pattern, message): (String, String, String)| {
                let mut rule = LuaPatternRule::new(id, pattern, message, Severity::Warning);
                rule.set_invert(true);
                this.inner.borrow_mut().add_pattern_rule(rule);
                Ok(())
            },
        );

        // -- loadTomlRules --
        /// Load validation rules from a TOML-formatted rule file.
        /// @param | path | string | Path to .toml rules file.
        methods.add_method("loadTomlRules", |_, this, path: String| {
            this.inner
                .borrow_mut()
                .load_toml_rules(&PathBuf::from(path));
            Ok(())
        });

        // -- run --
        /// Run validation against all Lua files under root.
        /// @return | table | Report with violations, files_checked, duration_ms, error_count, warning_count.
        methods.add_method("run", |lua, this, ()| {
            let report = this.inner.borrow().run();
            report_to_table(lua, &report)
        });

        // -- runFile --
        /// Run validation against a single file.
        /// @param | path | string | File path to validate.
        /// @return | table | Report.
        methods.add_method("runFile", |lua, this, path: String| {
            let report = this.inner.borrow().run_single(&PathBuf::from(path));
            report_to_table(lua, &report)
        });

        // -- ruleCount --
        /// Get number of loaded rules for this object.
        /// @return | integer | Rule count.
        methods.add_method("ruleCount", |_, this, ()| {
            Ok(this.inner.borrow().rule_count())
        });
    }
}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

fn report_to_table<'lua>(
    lua: &'lua Lua,
    report: &crate::validator::report::ValidationReport,
) -> LuaResult<LuaTable<'lua>> {
    let tbl = lua.create_table()?;
    tbl.set("files_checked", report.files_checked)?;
    tbl.set("duration_ms", report.duration_ms)?;
    tbl.set("error_count", report.error_count())?;
    tbl.set("warning_count", report.warning_count())?;
    tbl.set("is_clean", report.is_clean())?;

    let violations_tbl = lua.create_table()?;
    for (i, v) in report.violations.iter().enumerate() {
        let vt = lua.create_table()?;
        vt.set("rule", v.rule_id.clone())?;
        vt.set("severity", v.severity.as_str())?;
        vt.set("file", v.file.to_string_lossy().to_string())?;
        vt.set("message", v.message.clone())?;
        if let Some(line) = v.line {
            vt.set("line", line)?;
        }
        if let Some(ref suggestion) = v.suggestion {
            vt.set("suggestion", suggestion.clone())?;
        }
        violations_tbl.set(i + 1, vt)?;
    }
    /// Array of violation records from the validation run, each with rule, severity, file, and message fields.
    tbl.set("violations", violations_tbl)?;

    Ok(tbl)
}

// ---------------------------------------------------------------------------
// Register
// ---------------------------------------------------------------------------

/// Register the `lurek.validator` module.
///
/// ## Functions (see lurek Lua API reference for details).
///
/// ### newEngine (see lurek Lua API reference for details).
/// Create a new validation engine.
/// @param | root | string | Root directory to validate.
/// @return | LValidationEngine | Validation engine instance.
///
/// ### validate (see lurek Lua API reference for details).
/// Quick validate: run asset + import + API rules on a directory.
/// @param | path | string | Directory path.
/// @param | opts | table? | Optional validation options. Supports `api = {"game.quest", "game.items"}` to override the known API prefix list.
/// @return | table | Validation report.
///
/// ### validateFile (see lurek Lua API reference for details).
/// Validate a single Lua file with default rules.
/// @param | path | string | File path.
/// @param | opts | table? | Optional validation options. Supports `api = {"game.quest", "game.items"}` to override the known API prefix list.
/// @return | table | Validation report.
pub fn register(lua: &Lua, lurek: &LuaTable, _state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let module = lua.create_table()?;

    /// Creates a new validation engine rooted at the given filesystem path.
    ///
    /// @param | root | string | Root directory path for the validation engine.
    /// @return | LValidationEngine | A new validation engine instance.
    module.set(
        "newEngine",
        lua.create_function(|_, root: String| {
            let engine = ValidationEngine::new(PathBuf::from(root), ValidatorConfig::default());
            Ok(LuaValidationEngine {
                inner: Rc::new(RefCell::new(engine)),
            })
        })?,
    )?;

    /// Runs all validation rules against a project root directory and returns a report table.
    ///
    /// @param | path | string | Root directory path of the project to validate.
    /// @param | opts | table? | Optional validation options. Supports `api = {"game.quest", "game.items"}` to override the built-in `lurek.*` list.
    /// @return | table | Table with fields: errors (table), warnings (table), passed (boolean).
    module.set(
        "validate",
        lua.create_function(|lua, (path, opts): (String, Option<LuaTable>)| {
            let root = PathBuf::from(&path);
            let mut engine = ValidationEngine::new(&root, ValidatorConfig::default());
            engine.add_asset_rule(&root);
            engine.add_import_rule(vec![root.clone()]);
            let known_apis = known_api_list_from_opts(&opts, "lurek.validator.validate")?;
            add_api_rule_with_optional_known_apis(&mut engine, known_apis);
            let report = engine.run();
            report_to_table(lua, &report)
        })?,
    )?;

    /// Runs API validation rules against a single Lua file and returns a report table.
    ///
    /// @param | path | string | Absolute or relative path to the Lua file to validate.
    /// @param | opts | table? | Optional validation options. Supports `api = {"game.quest", "game.items"}` to override the built-in `lurek.*` list.
    /// @return | table | Table with fields: errors (table), warnings (table), passed (boolean).
    module.set(
        "validateFile",
        lua.create_function(|lua, (path, opts): (String, Option<LuaTable>)| {
            let file_path = PathBuf::from(&path);
            let root = file_path.parent().unwrap_or(&file_path).to_path_buf();
            let mut engine = ValidationEngine::new(&root, ValidatorConfig::default());
            let known_apis = known_api_list_from_opts(&opts, "lurek.validator.validateFile")?;
            add_api_rule_with_optional_known_apis(&mut engine, known_apis);
            let report = engine.run_single(&file_path);
            report_to_table(lua, &report)
        })?,
    )?;

    lurek.set("validator", module)?;
    Ok(())
}
