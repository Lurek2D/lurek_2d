//! Owns the catalog entry model for the docs subsystem and keeps its rules local to this file.
//! Centers the implementation around ParamInfo, ReturnInfo, DocEntry, with helpers kept close to their invariants.
//! Defines how entry data is validated, transformed, or stored before neighboring systems use it.
//! Owns docs behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on entry behavior while Lua registration stays elsewhere.

use std::collections::HashMap;
#[derive(Debug, Clone, Default)]
/// Hold one parameter description extracted for a callable entry.
pub struct ParamInfo {
    /// Store the parameter name as visible in the public API.
    pub name: String,
    /// Store the declared parameter type name.
    pub type_name: String,
    /// Store the user-facing parameter description text.
    pub description: String,
    /// Mark whether the parameter can be omitted by callers.
    pub optional: bool,
    /// Store the default value text when one is documented.
    pub default: Option<String>,
}
#[derive(Debug, Clone, Default)]
/// Hold one return value description extracted for a callable entry.
pub struct ReturnInfo {
    /// Store the declared return type name.
    pub type_name: String,
    /// Store the user-facing return value description text.
    pub description: String,
}
#[derive(Debug, Clone, Default)]
/// Hold one normalized documentation record for a lurek API symbol.
pub struct DocEntry {
    /// Store the short symbol name without module prefix.
    pub name: String,
    /// Store the fully qualified symbol name used by tooling lookups.
    pub qualified_name: String,
    /// Store the top-level module segment for grouping and reporting.
    pub module: String,
    /// Store the symbol kind classification such as function or value.
    pub kind: String,
    /// Store the primary user-facing description text.
    pub description: String,
    /// Store ordered parameter descriptors for callable symbols.
    pub parameters: Vec<ParamInfo>,
    /// Store ordered return descriptors for callable symbols.
    pub returns: Vec<ReturnInfo>,
    /// Store an optional runnable usage example snippet.
    pub example: Option<String>,
    /// Store an optional version tag indicating introduction release.
    pub since: Option<String>,
    /// Store an optional deprecation message when symbol is deprecated.
    pub deprecated: Option<String>,
    /// Store arbitrary tags used by docs pipelines and filters.
    pub tags: Vec<String>,
    /// Store extra key-value metadata not covered by typed fields.
    pub extra: HashMap<String, String>,
}
impl DocEntry {
    /// Create an entry shell and return it with a computed qualified name.
    pub fn new(name: &str, module: &str, kind: &str) -> Self {
        let qualified_name = format!("lurek.{}.{}", module, name);
        Self {
            name: name.to_string(),
            qualified_name,
            module: module.to_string(),
            kind: kind.to_string(),
            ..Default::default()
        }
    }
    /// Return true when required fields are present for this kind, else false.
    pub fn is_complete(&self) -> bool {
        if self.name.is_empty() || self.description.is_empty() {
            return false;
        }
        if self.kind == "value" {
            return true;
        }
        !self.parameters.is_empty() || !self.returns.is_empty()
    }
    /// Return symbolic names of missing required fields for this entry.
    pub fn missing_fields(&self) -> Vec<&'static str> {
        let mut missing = Vec::new();
        if self.name.is_empty() {
            missing.push("name");
        }
        if self.description.is_empty() {
            missing.push("description");
        }
        if self.kind != "value" && self.parameters.is_empty() && self.returns.is_empty() {
            missing.push("parameters_or_returns");
        }
        missing
    }
    /// Return true when every documented parameter has both a type and description.
    pub fn has_complete_parameter_docs(&self) -> bool {
        self.parameters
            .iter()
            .all(|param| !param.type_name.is_empty() && !param.description.is_empty())
    }
    /// Return true when every documented return value has both a type and description.
    pub fn has_complete_return_docs(&self) -> bool {
        self.returns
            .iter()
            .all(|ret| !ret.type_name.is_empty() && !ret.description.is_empty())
    }
    /// Return true when the entry has a non-empty example snippet.
    pub fn has_example(&self) -> bool {
        self.example
            .as_deref()
            .map(|example| !example.trim().is_empty())
            .unwrap_or(false)
    }
    /// Return true when the entry has a non-empty version marker.
    pub fn has_since(&self) -> bool {
        self.since
            .as_deref()
            .map(|since| !since.trim().is_empty())
            .unwrap_or(false)
    }
    /// Build cached search text for the entry and return a normalized string.
    pub fn normalized_search_text(&self) -> String {
        format!(
            "{}\n{}\n{}",
            self.name.to_lowercase(),
            self.qualified_name.to_lowercase(),
            self.description.to_lowercase()
        )
    }
}
