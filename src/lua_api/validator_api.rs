//! `lurek.validator` - Schema and constraint validation for Lua files, assets, imports, and custom rules.
use super::SharedState;
use crate::validator::{
    engine::ValidationEngine, report::Severity, rules_lua::LuaPatternRule, ValidatorConfig,
};
use mlua::prelude::*;
use std::cell::RefCell;
use std::path::PathBuf;
use std::rc::Rc;

// ---------------------------------------------------------------------------
// Wrapper: LuaValidationEngine
// ---------------------------------------------------------------------------

/// Lua userdata that runs schema and constraint validation on data tables and files.
struct LuaValidationEngine {
    inner: Rc<RefCell<ValidationEngine>>,
}

impl LuaUserData for LuaValidationEngine {
    fn add_methods<M: LuaUserDataMethods<Self>>(methods: &mut M) {
        /// Add the built-in asset existence rule.
        /// @param | asset_root | string | Root directory for asset files.
        methods.add_method("addAssetRule", |_, this, asset_root: String| {
            this.inner.borrow_mut().add_asset_rule(PathBuf::from(asset_root));
            Ok(())
        });

        /// Add the built-in import resolution rule.
        /// @param | paths | table | Array of Lua search paths.
        methods.add_method("addImportRule", |_, this, paths: Vec<String>| {
            let lua_paths: Vec<PathBuf> = paths.into_iter().map(PathBuf::from).collect();
            this.inner.borrow_mut().add_import_rule(lua_paths);
            Ok(())
        });

        /// Add the built-in API compliance rule.
        methods.add_method("addApiRule", |_, this, ()| {
            this.inner.borrow_mut().add_api_rule();
            Ok(())
        });

        /// Add a custom regex pattern rule to the validation engine.
        /// @param | id | string | Rule identifier.
        /// @param | pattern | string | Text pattern to match.
        /// @param | message | string | Violation message.
        /// @param | severity | string | Severity: hint, warning, error, critical.
        methods.add_method("addPatternRule", |_, this, (id, pattern, message, severity): (String, String, String, String)| {
            let sev = Severity::from_str(&severity);
            let rule = LuaPatternRule::new(id, pattern, message, sev);
            this.inner.borrow_mut().add_pattern_rule(rule);
            Ok(())
        });

        /// Add a required pattern rule (violation if pattern NOT found).
        /// @param | id | string | Rule identifier.
        /// @param | pattern | string | Required text pattern.
        /// @param | message | string | Violation message.
        methods.add_method("addRequiredRule", |_, this, (id, pattern, message): (String, String, String)| {
            let mut rule = LuaPatternRule::new(id, pattern, message, Severity::Warning);
            rule.set_invert(true);
            this.inner.borrow_mut().add_pattern_rule(rule);
            Ok(())
        });

        /// Load validation rules from a TOML-formatted rule file.
        /// @param | path | string | Path to .toml rules file.
        methods.add_method("loadTomlRules", |_, this, path: String| {
            this.inner.borrow_mut().load_toml_rules(&PathBuf::from(path));
            Ok(())
        });

        /// Run validation against all Lua files under root.
        /// @return | table | Report with violations, files_checked, duration_ms, error_count, warning_count.
        methods.add_method("run", |lua, this, ()| {
            let report = this.inner.borrow().run();
            report_to_table(lua, &report)
        });

        /// Run validation against a single file.
        /// @param | path | string | File path to validate.
        /// @return | table | Report.
        methods.add_method("runFile", |lua, this, path: String| {
            let report = this.inner.borrow().run_single(&PathBuf::from(path));
            report_to_table(lua, &report)
        });

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

fn report_to_table(lua: &Lua, report: &crate::validator::report::ValidationReport) -> LuaResult<LuaTable> {
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
/// @return | LuaValidationEngine | Validation engine instance.
///
/// ### validate (see lurek Lua API reference for details).
/// Quick validate: run asset + import + API rules on a directory.
/// @param | path | string | Directory path.
/// @return | table | Validation report.
///
/// ### validateFile (see lurek Lua API reference for details).
/// Validate a single Lua file with default rules.
/// @param | path | string | File path.
/// @return | table | Validation report.
pub fn register(lua: &Lua, _state: &SharedState) -> LuaResult<LuaTable> {
    let module = lua.create_table()?;

    module.set(
        "newEngine",
        lua.create_function(|_, root: String| {
            let engine = ValidationEngine::new(PathBuf::from(root), ValidatorConfig::default());
            Ok(LuaValidationEngine {
                inner: Rc::new(RefCell::new(engine)),
            })
        })?,
    )?;

    module.set(
        "validate",
        lua.create_function(|lua, path: String| {
            let root = PathBuf::from(&path);
            let mut engine = ValidationEngine::new(&root, ValidatorConfig::default());
            engine.add_asset_rule(&root);
            engine.add_import_rule(vec![root.clone()]);
            engine.add_api_rule();
            let report = engine.run();
            report_to_table(lua, &report)
        })?,
    )?;

    module.set(
        "validateFile",
        lua.create_function(|lua, path: String| {
            let file_path = PathBuf::from(&path);
            let root = file_path.parent().unwrap_or(&file_path).to_path_buf();
            let mut engine = ValidationEngine::new(&root, ValidatorConfig::default());
            engine.add_api_rule();
            let report = engine.run_single(&file_path);
            report_to_table(lua, &report)
        })?,
    )?;

    Ok(module)
}
