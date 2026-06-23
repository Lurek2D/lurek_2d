//! Owns mods behavior with explicit state, validation, and crate-local integration boundaries.
//! Centers the implementation around ModInfo, new, from_parts, with helpers kept close to their invariants.
//! Defines how mod manager data is validated, transformed, or stored before neighboring systems use it.
//! Owns mods behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on mod manager behavior while Lua registration stays elsewhere.
//! Documents where mods callers should change defaults, errors, or lifecycle behavior. with focused crate-local behavior.
//! Use this file when changing mod manager defaults, lifecycle handling, validation, or data ownership.
//! Keeps failure paths and edge cases near the mods state that can explain them while keeping call sites explicit.
//! Preserves deterministic behavior by keeping mod manager calculations explicit at their owner boundary.
//! Provides the local adaptation layer that lets callers avoid duplicating mods rules while keeping call sites explicit.
//! Maintains small helper surfaces so broader engine modules can compose mod manager behavior safely.
//! Protects subsystem contracts by keeping resource, cache, or state mutations visible in one place.
//! Links adjacent concerns only where mod manager changes need coordination with owned engine data.

use super::{
    DependencyCyclePolicy, FieldType, HookPoint, ModError, ModLoadPlan, ModReloadReport, ModResult,
    ModSandbox, ModScanPolicy, ModScanReport, ModSkipped, SandboxListMode,
};
use crate::log_msg;
use crate::runtime::log_messages::{MD01_MGR_INIT, MD02_MOD_REG, MD04_ORDER_OK};
use crate::serialize::parse_toml;
use sha2::{Digest, Sha256};
use std::cmp::Reverse;
use std::collections::{BinaryHeap, HashMap, HashSet};
use std::fs;
use std::path::{Path, PathBuf};

/// Metadata and runtime state for a single content mod.
#[derive(Debug, Clone)]
pub struct ModInfo {
    /// Unique mod identifier; used as the canonical key everywhere.
    pub id: String,
    /// Human-readable display name.
    pub name: String,
    /// SemVer-style version string from the manifest.
    pub version: String,
    /// Author name from the manifest.
    pub author: String,
    /// Short description from the manifest.
    pub description: String,
    /// Load priority; lower values load earlier when there are no dependency constraints.
    pub priority: i32,
    /// Ids of other mods that must load before this one.
    pub dependencies: Vec<String>,
    /// Whether this mod is allowed to participate in the load order.
    pub enabled: bool,
    /// Whether the mod's Lua entry point has been executed this session.
    pub loaded: bool,
    /// Absolute path to the `mod.toml` manifest file, when loaded from disk.
    pub path: Option<String>,
    /// Optional minimum engine API version string declared in the manifest.
    pub api_version: Option<String>,
    /// Feature capability tags declared in the manifest.
    pub capabilities: Vec<String>,
    /// Config schema entries as `(key, type_hint, default_value)` triples.
    pub config_schema: Vec<(String, String, String)>,
    /// Asset paths declared in the manifest; checked for conflicts during scan.
    pub asset_paths: Vec<String>,
    /// Optional SHA-256 manifest checksum. The legacy manifest key name `signature` is still accepted.
    pub signature: Option<String>,
    /// Optional asset checksums used when integrity mode is enabled.
    pub asset_checksums: Vec<(String, String)>,
    /// Optional sandbox policy carried with this mod's metadata.
    pub sandbox: Option<ModSandbox>,
}

/// Construction helpers for `ModInfo`.
impl ModInfo {
    /// Create a minimal `ModInfo` with defaults; logs MD02.
    pub fn new(id: impl Into<String>) -> Self {
        let id = id.into();
        log_msg!(debug, MD02_MOD_REG, "{}", id);
        Self {
            name: id.clone(),
            id,
            version: "1.0.0".to_string(),
            author: String::new(),
            description: String::new(),
            priority: 0,
            dependencies: Vec::new(),
            enabled: true,
            loaded: false,
            path: None,
            api_version: None,
            capabilities: Vec::new(),
            config_schema: Vec::new(),
            asset_paths: Vec::new(),
            signature: None,
            asset_checksums: Vec::new(),
            sandbox: None,
        }
    }

    /// Create a `ModInfo` from explicit parts, falling back to defaults when `None` is supplied.
    pub fn from_parts(
        id: String,
        name: Option<String>,
        version: Option<String>,
        author: Option<String>,
        description: Option<String>,
        priority: Option<i32>,
        dependencies: Vec<String>,
    ) -> Self {
        let mut info = Self::new(id);
        if let Some(n) = name {
            info.name = n;
        }
        if let Some(v) = version {
            info.version = v;
        }
        if let Some(a) = author {
            info.author = a;
        }
        if let Some(d) = description {
            info.description = d;
        }
        if let Some(p) = priority {
            info.priority = p;
        }
        info.dependencies = dependencies;
        info
    }

    /// Checks whether the mod's declared API version is compatible with the host engine version.
    pub fn check_api_version(&self, host_version: &str) -> Result<(), String> {
        let required = match &self.api_version {
            None => return Ok(()),
            Some(v) => v,
        };
        let parse = |s: &str| -> Option<(u32, u32, u32)> {
            let mut parts = s.splitn(3, '.');
            let maj = parts.next()?.parse::<u32>().ok()?;
            let min = parts.next()?.parse::<u32>().ok()?;
            let pat = parts
                .next()
                .and_then(|p| p.parse::<u32>().ok())
                .unwrap_or(0);
            Some((maj, min, pat))
        };
        let (req_maj, req_min, _) = match parse(required) {
            Some(v) => v,
            None => {
                return Err(format!(
                    "mod api_version '{}' is not a valid semver",
                    required
                ))
            }
        };
        let (host_maj, host_min, _) = match parse(host_version) {
            Some(v) => v,
            None => {
                return Err(format!(
                    "host api_version '{}' is not a valid semver",
                    host_version
                ))
            }
        };
        if req_maj != host_maj {
            return Err(format!(
                "mod requires API {}.x but host provides {}.x",
                req_maj, host_maj
            ));
        }
        if req_min > host_min {
            return Err(format!(
                "mod requires API {}.{}.x but host provides {}.{}.x",
                req_maj, req_min, host_maj, host_min
            ));
        }
        Ok(())
    }
}

/// Registry of all known mods, their custom load order, and pending hot-reload requests.
#[derive(Debug, Clone, Default)]
pub struct ModManager {
    /// Flat list of all registered `ModInfo` entries.
    mods: Vec<ModInfo>,
    /// Optional explicit load order overriding priority and dependency sort.
    custom_load_order: Option<Vec<String>>,
    /// Ordered queue of mod ids pending a hot-reload.
    reload_queue: Vec<String>,
    /// Set mirror of `reload_queue` for O(1) duplicate prevention.
    reload_queue_set: HashSet<String>,
}

/// Mod lifecycle operations: registration, ordering, scanning, reload, and validation.
impl ModManager {
    /// Create an empty mod manager; logs MD01.
    pub fn new() -> Self {
        log_msg!(debug, MD01_MGR_INIT);
        Self {
            mods: Vec::new(),
            custom_load_order: None,
            reload_queue: Vec::new(),
            reload_queue_set: HashSet::new(),
        }
    }

    /// Insert or replace `info` by id; removes it from the reload queue if present.
    pub fn register_mod(&mut self, info: ModInfo) {
        self.reload_queue.retain(|queued| queued != &info.id);
        self.reload_queue_set.remove(info.id.as_str());
        if let Some(pos) = self.mods.iter().position(|m| m.id == info.id) {
            self.mods[pos] = info;
        } else {
            self.mods.push(info);
        }
    }

    /// Remove the mod with `id`; returns true when a mod was actually removed.
    pub fn unregister_mod(&mut self, id: &str) -> bool {
        if let Some(pos) = self.mods.iter().position(|m| m.id == id) {
            self.mods.remove(pos);
            self.reload_queue.retain(|q| q != id);
            self.reload_queue_set.remove(id);
            true
        } else {
            false
        }
    }

    /// Return a shared reference to the mod with `id`, or `None` when not found.
    pub fn get_mod(&self, id: &str) -> Option<&ModInfo> {
        self.mods.iter().find(|m| m.id == id)
    }

    /// Return a mutable reference to the mod with `id`, or `None` when not found.
    pub fn get_mod_mut(&mut self, id: &str) -> Option<&mut ModInfo> {
        self.mods.iter_mut().find(|m| m.id == id)
    }

    /// Return true when a mod with `id` is registered.
    pub fn has_mod(&self, id: &str) -> bool {
        self.mods.iter().any(|m| m.id == id)
    }

    /// Return the total number of registered mods.
    pub fn mod_count(&self) -> usize {
        self.mods.len()
    }

    /// Return the full slice of registered mods in insertion order.
    pub fn all_mods(&self) -> &[ModInfo] {
        &self.mods
    }

    /// Return all mods that declare `capability` in their capabilities list.
    pub fn get_mods_by_capability(&self, capability: &str) -> Vec<&ModInfo> {
        self.mods
            .iter()
            .filter(|mod_info| mod_info.capabilities.iter().any(|cap| cap == capability))
            .collect()
    }

    /// Return mods in their effective load order: custom order, then validated topology or fallback.
    pub fn load_order(&self) -> Vec<&ModInfo> {
        log_msg!(debug, MD04_ORDER_OK);
        let plan = self.build_load_plan(None, DependencyCyclePolicy::WarnAndPriorityFallback);
        self.refs_for_ids(&plan.ordered_ids)
    }

    /// Build a structured load plan for the currently registered mods.
    pub fn build_load_plan(
        &self,
        host_api_version: Option<&str>,
        cycle_policy: DependencyCyclePolicy,
    ) -> ModLoadPlan {
        Self::build_load_plan_for_mods(
            &self.mods,
            &self.custom_load_order,
            host_api_version,
            cycle_policy,
        )
    }

    /// Return a checked load order that errors when the plan is invalid.
    pub fn load_order_checked(
        &self,
        host_api_version: Option<&str>,
        cycle_policy: DependencyCyclePolicy,
    ) -> ModResult<Vec<&ModInfo>> {
        let plan = self.build_load_plan(host_api_version, cycle_policy);
        if let Some(error) = plan.errors.first().cloned() {
            Err(error)
        } else {
            Ok(self.refs_for_ids(&plan.ordered_ids))
        }
    }

    /// Override the default priority/topological sort with an explicit id order.
    pub fn set_load_order(&mut self, order: Vec<String>) {
        self.custom_load_order = Some(order);
    }

    /// Remove the custom load order, restoring priority/topological sort.
    pub fn clear_load_order(&mut self) {
        self.custom_load_order = None;
    }

    /// Return the current custom load order slice, or `None` when not set.
    pub fn get_custom_load_order(&self) -> Option<&[String]> {
        self.custom_load_order.as_deref()
    }

    /// Scan `path` for subdirectories with a `mod.toml`; registers valid mods and returns discovered `ModInfo` list.
    pub fn scan_folder(&mut self, path: &str) -> Vec<ModInfo> {
        match self.scan_folder_with_policy(path, &ModScanPolicy::default()) {
            Ok(report) => report.loaded,
            Err(_) => Vec::new(),
        }
    }

    /// Scan `path` with an explicit policy and return a structured report.
    pub fn scan_folder_with_policy(
        &mut self,
        path: &str,
        policy: &ModScanPolicy,
    ) -> ModResult<ModScanReport<ModInfo>> {
        let root = fs::canonicalize(path).map_err(|err| ModError::Io {
            path: PathBuf::from(path),
            detail: err.to_string(),
        })?;
        let mut report = ModScanReport::new(root.clone());
        let dir_iter = fs::read_dir(&root).map_err(|err| ModError::Io {
            path: root.clone(),
            detail: err.to_string(),
        })?;

        let mut scanned_mod_dirs = 0usize;
        let mut candidates = Vec::new();

        for entry in dir_iter {
            let entry = match entry {
                Ok(entry) => entry,
                Err(err) => {
                    report.errors.push(ModError::Io {
                        path: root.clone(),
                        detail: err.to_string(),
                    });
                    continue;
                }
            };
            let entry_path = entry.path();
            if !entry_path.is_dir() {
                continue;
            }
            let dir_name = entry.file_name().to_string_lossy().into_owned();
            if should_ignore_dir(&dir_name, policy) {
                continue;
            }
            let manifest_path = entry_path.join("mod.toml");
            if !manifest_path.is_file() {
                continue;
            }
            scanned_mod_dirs += 1;
            if scanned_mod_dirs > policy.limits.max_mods {
                report.errors.push(ModError::LimitExceeded {
                    what: format!("mods scanned under '{}'", root.display()),
                    actual: scanned_mod_dirs as u64,
                    max: policy.limits.max_mods as u64,
                });
                break;
            }

            let manifest_path = fs::canonicalize(&manifest_path).map_err(|err| ModError::Io {
                path: manifest_path.clone(),
                detail: err.to_string(),
            })?;
            if !manifest_path.starts_with(&root) {
                report.skipped.push(ModSkipped {
                    path: manifest_path.clone(),
                    error: ModError::PathDenied {
                        path: manifest_path.to_string_lossy().into_owned(),
                        detail: "manifest resolved outside scan root".to_string(),
                    },
                });
                continue;
            }

            let content =
                match read_manifest_with_limit(&manifest_path, policy.limits.max_manifest_bytes) {
                    Ok(content) => content,
                    Err(error) => {
                        report.skipped.push(ModSkipped {
                            path: manifest_path.clone(),
                            error,
                        });
                        continue;
                    }
                };
            let (info, warnings) = match Self::parse_manifest(&manifest_path, &content, policy) {
                Ok(value) => value,
                Err(error) => {
                    report.skipped.push(ModSkipped {
                        path: manifest_path.clone(),
                        error,
                    });
                    continue;
                }
            };
            report.warnings.extend(warnings);

            if let Some(conflict) = self
                .manifest_conflicts_against(&info, self.mods.iter().chain(candidates.iter()))
                .into_iter()
                .next()
            {
                report.skipped.push(ModSkipped {
                    path: manifest_path.clone(),
                    error: conflict,
                });
                continue;
            }

            if policy.verify_asset_checksums {
                if let Err(error) = validate_asset_checksums(&info, &manifest_path) {
                    report.skipped.push(ModSkipped {
                        path: manifest_path.clone(),
                        error,
                    });
                    continue;
                }
            }

            candidates.push(info);
        }

        let candidate_errors = self.collect_candidate_errors(&candidates, policy);
        let mut accepted = Vec::new();
        for info in candidates {
            if let Some(errors) = candidate_errors.get(info.id.as_str()) {
                if policy.strict_load_plan {
                    for error in errors {
                        report.skipped.push(ModSkipped {
                            path: manifest_path_for(&info),
                            error: error.clone(),
                        });
                    }
                    continue;
                }
                report
                    .warnings
                    .extend(errors.iter().map(ToString::to_string));
            }
            accepted.push(info);
        }

        for info in accepted {
            report.loaded_ids.push(info.id.clone());
            self.register_mod(info.clone());
            report.loaded.push(info);
        }

        Ok(report)
    }

    /// Enqueue mod `id` for hot-reload; returns false when the id is unknown.
    pub fn mark_for_reload(&mut self, id: &str) -> bool {
        if !self.has_mod(id) {
            return false;
        }
        if self.reload_queue_set.insert(id.to_string()) {
            self.reload_queue.push(id.to_string());
        }
        true
    }

    /// Return the pending reload queue in submission order.
    pub fn get_reload_queue(&self) -> &[String] {
        &self.reload_queue
    }

    /// Clear the reload queue without processing it.
    pub fn clear_reload_queue(&mut self) {
        self.reload_queue.clear();
        self.reload_queue_set.clear();
    }

    /// Re-parse manifests for all queued mods and re-register them; return the ids that succeeded.
    pub fn process_reload_queue(&mut self) -> Vec<String> {
        self.process_reload_queue_with_policy(&ModScanPolicy::default())
            .reloaded
    }

    /// Atomically process queued reloads with an explicit policy.
    pub fn process_reload_queue_with_policy(&mut self, policy: &ModScanPolicy) -> ModReloadReport {
        let queued = std::mem::take(&mut self.reload_queue);
        self.reload_queue_set.clear();
        let previous_order = self
            .build_load_plan(None, DependencyCyclePolicy::WarnAndPriorityFallback)
            .ordered_ids;

        if queued.is_empty() {
            return ModReloadReport::default();
        }

        let mut scratch = self.clone();
        scratch.reload_queue.clear();
        scratch.reload_queue_set.clear();

        let mut report = ModReloadReport::default();
        let mut fatal = false;

        for id in &queued {
            let Some(path) = scratch.get_mod(id).and_then(|info| info.path.clone()) else {
                report.failed.push((
                    id.clone(),
                    ModError::ReloadFailure {
                        mod_id: id.clone(),
                        detail: "mod has no manifest path".to_string(),
                    },
                ));
                fatal = true;
                continue;
            };
            let manifest_path = PathBuf::from(&path);
            let content =
                match read_manifest_with_limit(&manifest_path, policy.limits.max_manifest_bytes) {
                    Ok(content) => content,
                    Err(error) => {
                        report.failed.push((id.clone(), error));
                        fatal = true;
                        continue;
                    }
                };
            let (mut info, warnings) = match Self::parse_manifest(&manifest_path, &content, policy)
            {
                Ok(value) => value,
                Err(error) => {
                    report.failed.push((id.clone(), error));
                    fatal = true;
                    continue;
                }
            };
            if info.id != *id {
                report.failed.push((
                    id.clone(),
                    ModError::ReloadFailure {
                        mod_id: id.clone(),
                        detail: format!("manifest changed id to '{}'", info.id),
                    },
                ));
                fatal = true;
                continue;
            }
            report.warnings.extend(warnings);
            if policy.verify_asset_checksums {
                if let Err(error) = validate_asset_checksums(&info, &manifest_path) {
                    report.failed.push((id.clone(), error));
                    fatal = true;
                    continue;
                }
            }
            info.loaded = true;
            scratch.register_mod(info);
        }

        if !fatal {
            let conflicts = scratch.manifest_conflicts_all();
            for conflict in conflicts {
                if let Some(mod_id) = mod_id_from_error(&conflict) {
                    if queued.iter().any(|queued_id| queued_id == mod_id) {
                        report.failed.push((mod_id.to_string(), conflict));
                        fatal = true;
                    }
                }
            }
        }

        if !fatal {
            let plan = scratch.build_load_plan(
                policy.host_api_version.as_deref(),
                policy.dependency_cycle_policy,
            );
            report.warnings.extend(plan.warnings.clone());
            if policy.strict_load_plan && !plan.is_valid() {
                for error in plan.errors {
                    if let Some(mod_id) = mod_id_from_error(&error) {
                        if queued.iter().any(|queued_id| queued_id == mod_id) {
                            report.failed.push((mod_id.to_string(), error));
                        }
                    } else {
                        for id in &queued {
                            report.failed.push((
                                id.clone(),
                                ModError::ReloadFailure {
                                    mod_id: id.clone(),
                                    detail: error.to_string(),
                                },
                            ));
                        }
                    }
                }
                fatal = true;
            }
        }

        if fatal {
            return report;
        }

        let new_order = scratch
            .build_load_plan(None, DependencyCyclePolicy::WarnAndPriorityFallback)
            .ordered_ids;
        report.changed_load_order = previous_order != new_order;
        report.reloaded = queued;
        *self = scratch;
        report
    }

    /// Return the ids of dependencies declared by any mod that are not themselves registered.
    pub fn validate_dependencies(&self) -> Vec<String> {
        let mut missing = Vec::new();
        for error in self
            .build_load_plan(None, DependencyCyclePolicy::WarnAndPriorityFallback)
            .errors
        {
            if let ModError::MissingDependency { dependency, .. } = error {
                if !missing.contains(&dependency) {
                    missing.push(dependency);
                }
            }
        }
        missing
    }

    /// Return true when the registered mods contain a dependency cycle.
    pub fn has_circular_dependencies(&self) -> bool {
        self.topological_order(&self.mods).is_err()
    }

    fn refs_for_ids(&self, ids: &[String]) -> Vec<&ModInfo> {
        ids.iter()
            .filter_map(|id| self.mods.iter().find(|info| &info.id == id))
            .collect()
    }

    fn build_load_plan_for_mods(
        mods: &[ModInfo],
        custom_load_order: &Option<Vec<String>>,
        host_api_version: Option<&str>,
        cycle_policy: DependencyCyclePolicy,
    ) -> ModLoadPlan {
        let mut errors = Vec::new();
        let mut warnings = Vec::new();
        let lookup: HashMap<&str, &ModInfo> =
            mods.iter().map(|info| (info.id.as_str(), info)).collect();

        for info in mods.iter().filter(|info| info.enabled) {
            for dependency in &info.dependencies {
                match lookup.get(dependency.as_str()) {
                    None => errors.push(ModError::MissingDependency {
                        mod_id: info.id.clone(),
                        dependency: dependency.clone(),
                    }),
                    Some(dep_info) if !dep_info.enabled => {
                        errors.push(ModError::DisabledDependency {
                            mod_id: info.id.clone(),
                            dependency: dependency.clone(),
                        })
                    }
                    Some(_) => {}
                }
            }
            if let Some(host_version) = host_api_version {
                if let Err(detail) = info.check_api_version(host_version) {
                    errors.push(ModError::ApiVersionMismatch {
                        mod_id: info.id.clone(),
                        detail,
                    });
                }
            }
        }

        let (ordered_ids, used_cycle_fallback) = if let Some(order) = custom_load_order {
            (
                merge_custom_order(order, mods)
                    .into_iter()
                    .map(|info| info.id.clone())
                    .collect(),
                false,
            )
        } else {
            match topological_order_for_mods(mods) {
                Ok(sorted) => (
                    sorted.into_iter().map(|info| info.id.clone()).collect(),
                    false,
                ),
                Err(cycle_ids) => match cycle_policy {
                    DependencyCyclePolicy::Error => {
                        errors.push(ModError::DependencyCycle {
                            cycle_ids: cycle_ids.clone(),
                        });
                        (
                            sort_by_priority(mods.iter().collect())
                                .into_iter()
                                .map(|info| info.id.clone())
                                .collect(),
                            false,
                        )
                    }
                    DependencyCyclePolicy::WarnAndPriorityFallback => {
                        warnings.push(format!(
                            "dependency cycle detected; falling back to priority sort: {:?}",
                            cycle_ids
                        ));
                        (
                            sort_by_priority(mods.iter().collect())
                                .into_iter()
                                .map(|info| info.id.clone())
                                .collect(),
                            true,
                        )
                    }
                },
            }
        };

        ModLoadPlan {
            ordered_ids,
            errors,
            warnings,
            used_cycle_fallback,
        }
    }

    fn topological_order<'a>(&self, mods: &'a [ModInfo]) -> Result<Vec<&'a ModInfo>, Vec<String>> {
        topological_order_for_mods(mods)
    }

    fn parse_manifest(
        entry_path: &Path,
        content: &str,
        policy: &ModScanPolicy,
    ) -> ModResult<(ModInfo, Vec<String>)> {
        let value = parse_toml(content).map_err(|err| ModError::Parse {
            path: entry_path.to_path_buf(),
            detail: format!("invalid TOML: {}", err),
        })?;
        let table = value.as_table().ok_or_else(|| ModError::Validation {
            path: Some(entry_path.to_path_buf()),
            detail: "mod.toml must contain a TOML table".to_string(),
        })?;

        let id = required_string(table, entry_path, "id")?.to_string();
        validate_identifier("mod id", &id, policy.limits.max_id_len, entry_path)?;

        let name = optional_string(table, entry_path, "name")?.map(str::to_string);
        if let Some(name) = &name {
            validate_freeform("mod name", name, policy.limits.max_name_len, entry_path)?;
        }
        let version = optional_string(table, entry_path, "version")?.map(str::to_string);
        if let Some(version) = &version {
            validate_version(version, policy.limits.max_version_len, entry_path)?;
        }
        let author = optional_string(table, entry_path, "author")?.map(str::to_string);
        if let Some(author) = &author {
            validate_freeform(
                "mod author",
                author,
                policy.limits.max_author_len,
                entry_path,
            )?;
        }
        let description = optional_string(table, entry_path, "description")?.map(str::to_string);
        if let Some(description) = &description {
            validate_freeform(
                "mod description",
                description,
                policy.limits.max_description_len,
                entry_path,
            )?;
        }

        let dependencies = string_array(
            table,
            entry_path,
            "dependencies",
            policy.limits.max_dependencies,
        )?;
        for dep in &dependencies {
            validate_identifier("dependency id", dep, policy.limits.max_id_len, entry_path)?;
        }

        let mut info = ModInfo::from_parts(
            id,
            name,
            version,
            author,
            description,
            optional_i32(table, entry_path, "priority")?,
            dependencies,
        );
        info.path = Some(entry_path.to_string_lossy().into_owned());
        info.enabled = optional_bool(table, entry_path, "enabled")?.unwrap_or(true);
        info.api_version = optional_string(table, entry_path, "api_version")?.map(str::to_string);
        if let Some(api_version) = &info.api_version {
            validate_version(api_version, policy.limits.max_version_len, entry_path)?;
        }
        info.capabilities = string_array(
            table,
            entry_path,
            "capabilities",
            policy.limits.max_capabilities,
        )?;
        for capability in &info.capabilities {
            validate_symbol(
                "capability",
                capability,
                policy.limits.max_capability_len,
                entry_path,
            )?;
        }

        info.asset_paths =
            string_array(table, entry_path, "assets", policy.limits.max_asset_paths)?
                .into_iter()
                .map(|asset| normalize_asset_path(&asset, entry_path))
                .collect::<ModResult<Vec<_>>>()?;

        let mut warnings = Vec::new();
        let checksum = match (
            optional_string(table, entry_path, "checksum")?,
            optional_string(table, entry_path, "signature")?,
        ) {
            (Some(checksum), Some(_)) => {
                warnings.push(format!(
                    "{}: manifest uses legacy 'signature'; prefer 'checksum'",
                    entry_path.display()
                ));
                Some(checksum.to_string())
            }
            (Some(checksum), None) => Some(checksum.to_string()),
            (None, Some(signature)) => {
                warnings.push(format!(
                    "{}: manifest key 'signature' is treated as a checksum, not a trust signature",
                    entry_path.display()
                ));
                Some(signature.to_string())
            }
            (None, None) => None,
        };
        info.signature = checksum;
        info.config_schema = parse_config_schema(table, entry_path, policy)?;
        info.asset_checksums = parse_asset_checksums(table, entry_path, policy)?;
        info.sandbox = parse_sandbox(table, entry_path, policy)?;

        if let Some(signature) = &info.signature {
            let expected = manifest_checksum(&info);
            if signature != &expected {
                return Err(ModError::IntegrityMismatch {
                    mod_id: info.id.clone(),
                    detail: format!(
                        "expected manifest checksum '{}' but found '{}'",
                        expected, signature
                    ),
                });
            }
        }

        let known_keys = [
            "id",
            "name",
            "version",
            "author",
            "description",
            "priority",
            "dependencies",
            "enabled",
            "api_version",
            "capabilities",
            "assets",
            "checksum",
            "signature",
            "config_schema",
            "asset_checksums",
            "sandbox",
        ];
        for key in table.keys() {
            if !known_keys.contains(&key.as_str()) {
                warnings.push(format!(
                    "{}: unknown manifest key '{}'",
                    entry_path.display(),
                    key
                ));
            }
        }

        Ok((info, warnings))
    }

    fn collect_candidate_errors(
        &self,
        candidates: &[ModInfo],
        policy: &ModScanPolicy,
    ) -> HashMap<String, Vec<ModError>> {
        let mut errors: HashMap<String, Vec<ModError>> = HashMap::new();
        let mut combined = self.mods.clone();
        combined.extend(candidates.iter().cloned());
        let lookup: HashMap<&str, &ModInfo> = combined
            .iter()
            .map(|info| (info.id.as_str(), info))
            .collect();

        for candidate in candidates {
            for dependency in &candidate.dependencies {
                match lookup.get(dependency.as_str()) {
                    None => errors.entry(candidate.id.clone()).or_default().push(
                        ModError::MissingDependency {
                            mod_id: candidate.id.clone(),
                            dependency: dependency.clone(),
                        },
                    ),
                    Some(dep_info) if !dep_info.enabled => errors
                        .entry(candidate.id.clone())
                        .or_default()
                        .push(ModError::DisabledDependency {
                            mod_id: candidate.id.clone(),
                            dependency: dependency.clone(),
                        }),
                    Some(_) => {}
                }
            }
            if let Some(host_version) = policy.host_api_version.as_deref() {
                if let Err(detail) = candidate.check_api_version(host_version) {
                    errors.entry(candidate.id.clone()).or_default().push(
                        ModError::ApiVersionMismatch {
                            mod_id: candidate.id.clone(),
                            detail,
                        },
                    );
                }
            }
        }

        if policy.dependency_cycle_policy == DependencyCyclePolicy::Error {
            if let Err(cycle_ids) = topological_order_for_mods(&combined) {
                for candidate in candidates {
                    if cycle_ids.iter().any(|cycle_id| cycle_id == &candidate.id) {
                        errors.entry(candidate.id.clone()).or_default().push(
                            ModError::DependencyCycle {
                                cycle_ids: cycle_ids.clone(),
                            },
                        );
                    }
                }
            }
        }

        errors
    }

    fn manifest_conflicts_against<'a>(
        &self,
        info: &ModInfo,
        existing: impl Iterator<Item = &'a ModInfo>,
    ) -> Vec<ModError> {
        let mut conflicts = Vec::new();
        let existing: Vec<&ModInfo> = existing.collect();
        for asset_path in &info.asset_paths {
            for other in &existing {
                if other.id != info.id && other.asset_paths.iter().any(|path| path == asset_path) {
                    conflicts.push(ModError::AssetConflict {
                        mod_id: info.id.clone(),
                        asset_path: asset_path.clone(),
                        other_mod_id: other.id.clone(),
                    });
                    break;
                }
            }
        }
        conflicts
    }

    fn manifest_conflicts_all(&self) -> Vec<ModError> {
        let mut seen: HashMap<&str, &str> = HashMap::new();
        let mut conflicts = Vec::new();
        for info in &self.mods {
            for asset_path in &info.asset_paths {
                if let Some(other_mod_id) = seen.get(asset_path.as_str()) {
                    if *other_mod_id != info.id {
                        conflicts.push(ModError::AssetConflict {
                            mod_id: info.id.clone(),
                            asset_path: asset_path.clone(),
                            other_mod_id: (*other_mod_id).to_string(),
                        });
                    }
                } else {
                    seen.insert(asset_path.as_str(), info.id.as_str());
                }
            }
        }
        conflicts
    }
}

fn required_string<'a>(
    table: &'a toml::value::Table,
    entry_path: &Path,
    field: &str,
) -> ModResult<&'a str> {
    table
        .get(field)
        .and_then(|value| value.as_str())
        .ok_or_else(|| ModError::Validation {
            path: Some(entry_path.to_path_buf()),
            detail: format!("missing required string field '{}'", field),
        })
}

fn optional_string<'a>(
    table: &'a toml::value::Table,
    entry_path: &Path,
    field: &str,
) -> ModResult<Option<&'a str>> {
    match table.get(field) {
        None => Ok(None),
        Some(value) => value
            .as_str()
            .map(Some)
            .ok_or_else(|| ModError::Validation {
                path: Some(entry_path.to_path_buf()),
                detail: format!("field '{}' must be a string", field),
            }),
    }
}

fn optional_i32(
    table: &toml::value::Table,
    entry_path: &Path,
    field: &str,
) -> ModResult<Option<i32>> {
    match table.get(field) {
        None => Ok(None),
        Some(value) => {
            let integer = value.as_integer().ok_or_else(|| ModError::Validation {
                path: Some(entry_path.to_path_buf()),
                detail: format!("field '{}' must be an integer", field),
            })?;
            i32::try_from(integer)
                .map(Some)
                .map_err(|_| ModError::Validation {
                    path: Some(entry_path.to_path_buf()),
                    detail: format!("field '{}' is out of i32 range", field),
                })
        }
    }
}

fn optional_bool(
    table: &toml::value::Table,
    entry_path: &Path,
    field: &str,
) -> ModResult<Option<bool>> {
    match table.get(field) {
        None => Ok(None),
        Some(value) => value
            .as_bool()
            .map(Some)
            .ok_or_else(|| ModError::Validation {
                path: Some(entry_path.to_path_buf()),
                detail: format!("field '{}' must be a boolean", field),
            }),
    }
}

fn string_array(
    table: &toml::value::Table,
    entry_path: &Path,
    field: &str,
    max_items: usize,
) -> ModResult<Vec<String>> {
    let Some(value) = table.get(field) else {
        return Ok(Vec::new());
    };
    let items = value.as_array().ok_or_else(|| ModError::Validation {
        path: Some(entry_path.to_path_buf()),
        detail: format!("field '{}' must be an array", field),
    })?;
    if items.len() > max_items {
        return Err(ModError::LimitExceeded {
            what: format!("{} items in '{}'", field, entry_path.display()),
            actual: items.len() as u64,
            max: max_items as u64,
        });
    }
    items
        .iter()
        .map(|item| {
            item.as_str()
                .map(str::to_string)
                .ok_or_else(|| ModError::Validation {
                    path: Some(entry_path.to_path_buf()),
                    detail: format!("field '{}' must contain only strings", field),
                })
        })
        .collect()
}

fn parse_config_schema(
    table: &toml::value::Table,
    entry_path: &Path,
    policy: &ModScanPolicy,
) -> ModResult<Vec<(String, String, String)>> {
    let Some(value) = table.get("config_schema") else {
        return Ok(Vec::new());
    };
    let entries = value.as_array().ok_or_else(|| ModError::Validation {
        path: Some(entry_path.to_path_buf()),
        detail: "field 'config_schema' must be an array of tables".to_string(),
    })?;
    if entries.len() > policy.limits.max_config_schema_entries {
        return Err(ModError::LimitExceeded {
            what: format!("config_schema entries in '{}'", entry_path.display()),
            actual: entries.len() as u64,
            max: policy.limits.max_config_schema_entries as u64,
        });
    }

    let mut parsed = Vec::new();
    for entry in entries {
        let entry_table = entry.as_table().ok_or_else(|| ModError::Validation {
            path: Some(entry_path.to_path_buf()),
            detail: "config_schema entries must be tables".to_string(),
        })?;
        let key = required_string(entry_table, entry_path, "key")?.to_string();
        validate_identifier(
            "config_schema key",
            &key,
            policy.limits.max_id_len,
            entry_path,
        )?;
        let type_hint = optional_string(entry_table, entry_path, "type")?
            .unwrap_or("any")
            .to_string();
        FieldType::parse_config_type_name(&type_hint).map_err(|detail| ModError::Validation {
            path: Some(entry_path.to_path_buf()),
            detail,
        })?;
        let default = match entry_table.get("default") {
            None => String::new(),
            Some(value) => value.to_string(),
        };
        parsed.push((key, type_hint, default));
    }
    Ok(parsed)
}

fn parse_asset_checksums(
    table: &toml::value::Table,
    entry_path: &Path,
    policy: &ModScanPolicy,
) -> ModResult<Vec<(String, String)>> {
    let Some(value) = table.get("asset_checksums") else {
        return Ok(Vec::new());
    };
    let entries = value.as_array().ok_or_else(|| ModError::Validation {
        path: Some(entry_path.to_path_buf()),
        detail: "field 'asset_checksums' must be an array of tables".to_string(),
    })?;
    if entries.len() > policy.limits.max_asset_paths {
        return Err(ModError::LimitExceeded {
            what: format!("asset_checksums entries in '{}'", entry_path.display()),
            actual: entries.len() as u64,
            max: policy.limits.max_asset_paths as u64,
        });
    }
    let mut parsed = Vec::new();
    for entry in entries {
        let entry_table = entry.as_table().ok_or_else(|| ModError::Validation {
            path: Some(entry_path.to_path_buf()),
            detail: "asset_checksums entries must be tables".to_string(),
        })?;
        let path = normalize_asset_path(
            required_string(entry_table, entry_path, "path")?,
            entry_path,
        )?;
        let sha256 = required_string(entry_table, entry_path, "sha256")?.to_string();
        if sha256.len() != 64 || !sha256.chars().all(|ch| ch.is_ascii_hexdigit()) {
            return Err(ModError::Validation {
                path: Some(entry_path.to_path_buf()),
                detail: format!(
                    "asset checksum for '{}' must be a 64-char hex SHA-256",
                    path
                ),
            });
        }
        parsed.push((path, sha256.to_lowercase()));
    }
    Ok(parsed)
}

fn parse_sandbox(
    table: &toml::value::Table,
    entry_path: &Path,
    policy: &ModScanPolicy,
) -> ModResult<Option<ModSandbox>> {
    let Some(value) = table.get("sandbox") else {
        return Ok(None);
    };
    let sandbox_table = value.as_table().ok_or_else(|| ModError::Validation {
        path: Some(entry_path.to_path_buf()),
        detail: "field 'sandbox' must be a table".to_string(),
    })?;
    let mut sandbox = ModSandbox::new();

    if let Some(mode) = optional_nested_string(sandbox_table, entry_path, "api_mode")? {
        sandbox.set_api_mode(parse_sandbox_mode(mode, entry_path, "sandbox.api_mode")?);
    }
    let api_values = nested_string_array(
        sandbox_table,
        entry_path,
        "apis",
        policy.limits.max_capabilities,
    )?;
    for api in api_values {
        validate_symbol(
            "sandbox api",
            &api,
            policy.limits.max_capability_len,
            entry_path,
        )?;
        sandbox.allow_api(api);
    }

    if let Some(mode) = optional_nested_string(sandbox_table, entry_path, "hook_mode")? {
        sandbox.set_hook_mode(parse_sandbox_mode(mode, entry_path, "sandbox.hook_mode")?);
    }
    let hook_values = nested_string_array(
        sandbox_table,
        entry_path,
        "hooks",
        policy.limits.max_config_schema_entries,
    )?;
    for hook_name in hook_values {
        let hook = HookPoint::parse_validated(&hook_name, &policy.limits)
            .map_err(|error| with_validation_path(error, entry_path))?;
        sandbox.allow_hook(hook);
    }

    if let Some(mode) = optional_nested_string(sandbox_table, entry_path, "read_mode")? {
        sandbox.set_read_mode(parse_sandbox_mode(mode, entry_path, "sandbox.read_mode")?);
    }
    let read_roots = nested_string_array(
        sandbox_table,
        entry_path,
        "read_roots",
        policy.limits.max_asset_paths,
    )?;
    let mod_root = entry_path.parent().ok_or_else(|| ModError::Validation {
        path: Some(entry_path.to_path_buf()),
        detail: "manifest has no parent directory".to_string(),
    })?;
    for read_root in read_roots {
        let resolved = resolve_sandbox_read_root(&read_root, mod_root, entry_path)?;
        sandbox
            .allow_read_root(&resolved)
            .map_err(|error| with_validation_path(error, entry_path))?;
    }

    let blocked_ops = nested_string_array(
        sandbox_table,
        entry_path,
        "blocked_ops",
        policy.limits.max_capabilities,
    )?;
    for op in blocked_ops {
        validate_symbol(
            "sandbox blocked op",
            &op,
            policy.limits.max_hook_len,
            entry_path,
        )?;
        sandbox.block_op(op);
    }

    if let Some(max_memory) = optional_nested_integer(sandbox_table, entry_path, "max_memory")? {
        sandbox.max_memory = usize::try_from(max_memory).map_err(|_| ModError::Validation {
            path: Some(entry_path.to_path_buf()),
            detail: "sandbox.max_memory must be a non-negative integer".to_string(),
        })?;
    }
    sandbox.allow_network =
        optional_nested_bool(sandbox_table, entry_path, "allow_network")?.unwrap_or(false);
    sandbox.allow_file_write =
        optional_nested_bool(sandbox_table, entry_path, "allow_file_write")?.unwrap_or(false);

    Ok(Some(sandbox))
}

fn optional_nested_string<'a>(
    table: &'a toml::value::Table,
    entry_path: &Path,
    field: &str,
) -> ModResult<Option<&'a str>> {
    match table.get(field) {
        None => Ok(None),
        Some(value) => value
            .as_str()
            .map(Some)
            .ok_or_else(|| ModError::Validation {
                path: Some(entry_path.to_path_buf()),
                detail: format!("field 'sandbox.{}' must be a string", field),
            }),
    }
}

fn optional_nested_bool(
    table: &toml::value::Table,
    entry_path: &Path,
    field: &str,
) -> ModResult<Option<bool>> {
    match table.get(field) {
        None => Ok(None),
        Some(value) => value
            .as_bool()
            .map(Some)
            .ok_or_else(|| ModError::Validation {
                path: Some(entry_path.to_path_buf()),
                detail: format!("field 'sandbox.{}' must be a boolean", field),
            }),
    }
}

fn optional_nested_integer(
    table: &toml::value::Table,
    entry_path: &Path,
    field: &str,
) -> ModResult<Option<i64>> {
    match table.get(field) {
        None => Ok(None),
        Some(value) => value
            .as_integer()
            .map(Some)
            .ok_or_else(|| ModError::Validation {
                path: Some(entry_path.to_path_buf()),
                detail: format!("field 'sandbox.{}' must be an integer", field),
            }),
    }
}

fn nested_string_array(
    table: &toml::value::Table,
    entry_path: &Path,
    field: &str,
    max_items: usize,
) -> ModResult<Vec<String>> {
    let Some(value) = table.get(field) else {
        return Ok(Vec::new());
    };
    let items = value.as_array().ok_or_else(|| ModError::Validation {
        path: Some(entry_path.to_path_buf()),
        detail: format!("field 'sandbox.{}' must be an array of strings", field),
    })?;
    if items.len() > max_items {
        return Err(ModError::LimitExceeded {
            what: format!("sandbox.{} entries in '{}'", field, entry_path.display()),
            actual: items.len() as u64,
            max: max_items as u64,
        });
    }
    items
        .iter()
        .map(|item| {
            item.as_str()
                .map(str::to_string)
                .ok_or_else(|| ModError::Validation {
                    path: Some(entry_path.to_path_buf()),
                    detail: format!("field 'sandbox.{}' must contain only strings", field),
                })
        })
        .collect()
}

fn parse_sandbox_mode(value: &str, entry_path: &Path, field: &str) -> ModResult<SandboxListMode> {
    SandboxListMode::from_name(value).ok_or_else(|| ModError::Validation {
        path: Some(entry_path.to_path_buf()),
        detail: format!(
            "{} must be one of allow_all, deny_by_default, allow_list",
            field
        ),
    })
}

fn resolve_sandbox_read_root(path: &str, mod_root: &Path, entry_path: &Path) -> ModResult<PathBuf> {
    let normalized = normalize_asset_path(path, entry_path)?;
    Ok(mod_root.join(normalized))
}

fn with_validation_path(error: ModError, entry_path: &Path) -> ModError {
    match error {
        ModError::Validation { detail, .. } => ModError::Validation {
            path: Some(entry_path.to_path_buf()),
            detail,
        },
        other => other,
    }
}

fn validate_asset_checksums(info: &ModInfo, manifest_path: &Path) -> ModResult<()> {
    let Some(mod_root) = manifest_path.parent() else {
        return Err(ModError::Validation {
            path: Some(manifest_path.to_path_buf()),
            detail: "manifest has no parent directory".to_string(),
        });
    };
    for (asset_path, expected_sha) in &info.asset_checksums {
        let full_path = mod_root.join(asset_path);
        let bytes = fs::read(&full_path).map_err(|err| ModError::Io {
            path: full_path.clone(),
            detail: err.to_string(),
        })?;
        let actual = hex::encode(Sha256::digest(bytes));
        if &actual != expected_sha {
            return Err(ModError::IntegrityMismatch {
                mod_id: info.id.clone(),
                detail: format!(
                    "asset '{}' checksum mismatch: expected '{}' got '{}'",
                    asset_path, expected_sha, actual
                ),
            });
        }
    }
    Ok(())
}

fn manifest_checksum(info: &ModInfo) -> String {
    let mut hasher = Sha256::new();
    hasher.update(info.id.as_bytes());
    hasher.update([0]);
    hasher.update(info.name.as_bytes());
    hasher.update([0]);
    hasher.update(info.version.as_bytes());
    hasher.update([0]);
    hasher.update(info.author.as_bytes());
    hasher.update([0]);
    hasher.update(info.description.as_bytes());
    hasher.update([0]);
    hasher.update(info.priority.to_le_bytes());
    hasher.update([0]);
    if let Some(api_version) = &info.api_version {
        hasher.update(api_version.as_bytes());
    }
    hasher.update([0]);
    for dependency in &info.dependencies {
        hasher.update(dependency.as_bytes());
        hasher.update([0]);
    }
    for capability in &info.capabilities {
        hasher.update(capability.as_bytes());
        hasher.update([0]);
    }
    for asset_path in &info.asset_paths {
        hasher.update(asset_path.as_bytes());
        hasher.update([0]);
    }
    for (asset_path, sha256) in &info.asset_checksums {
        hasher.update(asset_path.as_bytes());
        hasher.update([0]);
        hasher.update(sha256.as_bytes());
        hasher.update([0]);
    }
    for (key, type_hint, default) in &info.config_schema {
        hasher.update(key.as_bytes());
        hasher.update([0]);
        hasher.update(type_hint.as_bytes());
        hasher.update([0]);
        hasher.update(default.as_bytes());
        hasher.update([0]);
    }
    if let Some(sandbox) = &info.sandbox {
        hasher.update(sandbox.api_mode().as_str().as_bytes());
        hasher.update([0]);
        let mut apis: Vec<String> = sandbox.allowed_apis().cloned().collect();
        apis.sort();
        for api in apis {
            hasher.update(api.as_bytes());
            hasher.update([0]);
        }

        hasher.update(sandbox.hook_mode().as_str().as_bytes());
        hasher.update([0]);
        let mut hooks: Vec<String> = sandbox.allowed_hooks().map(HookPoint::as_str).collect();
        hooks.sort();
        for hook in hooks {
            hasher.update(hook.as_bytes());
            hasher.update([0]);
        }

        hasher.update(sandbox.read_mode().as_str().as_bytes());
        hasher.update([0]);
        for root in sandbox.allowed_read_roots() {
            hasher.update(root.to_string_lossy().as_bytes());
            hasher.update([0]);
        }

        let mut blocked_ops: Vec<String> = sandbox.blocked_ops().cloned().collect();
        blocked_ops.sort();
        for op in blocked_ops {
            hasher.update(op.as_bytes());
            hasher.update([0]);
        }

        hasher.update(sandbox.max_memory.to_le_bytes());
        hasher.update([0]);
        hasher.update([u8::from(sandbox.allow_network)]);
        hasher.update([u8::from(sandbox.allow_file_write)]);
    }
    hex::encode(hasher.finalize())
}

fn read_manifest_with_limit(path: &Path, max_bytes: u64) -> ModResult<String> {
    let metadata = fs::metadata(path).map_err(|err| ModError::Io {
        path: path.to_path_buf(),
        detail: err.to_string(),
    })?;
    if metadata.len() > max_bytes {
        return Err(ModError::LimitExceeded {
            what: format!("manifest '{}'", path.display()),
            actual: metadata.len(),
            max: max_bytes,
        });
    }
    fs::read_to_string(path).map_err(|err| ModError::Io {
        path: path.to_path_buf(),
        detail: err.to_string(),
    })
}

fn validate_identifier(kind: &str, value: &str, max_len: usize, path: &Path) -> ModResult<()> {
    validate_symbol(kind, value, max_len, path)
}

fn validate_symbol(kind: &str, value: &str, max_len: usize, path: &Path) -> ModResult<()> {
    if value.is_empty() {
        return Err(ModError::Validation {
            path: Some(path.to_path_buf()),
            detail: format!("{} cannot be empty", kind),
        });
    }
    if value.len() > max_len {
        return Err(ModError::Validation {
            path: Some(path.to_path_buf()),
            detail: format!("{} '{}' exceeds max length {}", kind, value, max_len),
        });
    }
    if !value
        .chars()
        .all(|ch| ch.is_ascii_alphanumeric() || matches!(ch, '_' | '-' | '.' | ':'))
    {
        return Err(ModError::Validation {
            path: Some(path.to_path_buf()),
            detail: format!("{} '{}' contains unsupported characters", kind, value),
        });
    }
    Ok(())
}

fn validate_freeform(kind: &str, value: &str, max_len: usize, path: &Path) -> ModResult<()> {
    if value.len() > max_len {
        return Err(ModError::Validation {
            path: Some(path.to_path_buf()),
            detail: format!("{} exceeds max length {}", kind, max_len),
        });
    }
    Ok(())
}

fn validate_version(value: &str, max_len: usize, path: &Path) -> ModResult<()> {
    if value.is_empty() || value.len() > max_len {
        return Err(ModError::Validation {
            path: Some(path.to_path_buf()),
            detail: format!("version '{}' has invalid length", value),
        });
    }
    if !value
        .chars()
        .all(|ch| ch.is_ascii_alphanumeric() || matches!(ch, '.' | '-' | '+'))
    {
        return Err(ModError::Validation {
            path: Some(path.to_path_buf()),
            detail: format!("version '{}' contains unsupported characters", value),
        });
    }
    Ok(())
}

fn normalize_asset_path(path: &str, entry_path: &Path) -> ModResult<String> {
    let logical = path.replace('\\', "/");
    if logical.is_empty() {
        return Err(ModError::Validation {
            path: Some(entry_path.to_path_buf()),
            detail: "asset path cannot be empty".to_string(),
        });
    }
    let candidate = Path::new(&logical);
    if candidate.is_absolute() {
        return Err(ModError::PathDenied {
            path: logical,
            detail: "asset path must be relative to the mod root".to_string(),
        });
    }
    let mut cleaned = Vec::new();
    for component in candidate.components() {
        match component {
            std::path::Component::CurDir => {}
            std::path::Component::Normal(part) => cleaned.push(part.to_string_lossy().into_owned()),
            std::path::Component::ParentDir => {
                return Err(ModError::PathDenied {
                    path: path.to_string(),
                    detail: "asset path traversal is not allowed".to_string(),
                })
            }
            std::path::Component::RootDir | std::path::Component::Prefix(_) => {
                return Err(ModError::PathDenied {
                    path: path.to_string(),
                    detail: "asset path must be relative to the mod root".to_string(),
                })
            }
        }
    }
    Ok(cleaned.join("/"))
}

fn should_ignore_dir(name: &str, policy: &ModScanPolicy) -> bool {
    (policy.ignore_hidden_dirs && name.starts_with('.'))
        || (policy.ignore_temp_dirs
            && (name.starts_with('~')
                || name.ends_with('~')
                || name.ends_with(".tmp")
                || name.ends_with(".temp")))
}

fn manifest_path_for(info: &ModInfo) -> PathBuf {
    info.path
        .as_ref()
        .map(PathBuf::from)
        .unwrap_or_else(|| PathBuf::from(&info.id))
}

fn mod_id_from_error(error: &ModError) -> Option<&str> {
    match error {
        ModError::MissingDependency { mod_id, .. }
        | ModError::DisabledDependency { mod_id, .. }
        | ModError::ApiVersionMismatch { mod_id, .. }
        | ModError::IntegrityMismatch { mod_id, .. }
        | ModError::ReloadFailure { mod_id, .. } => Some(mod_id.as_str()),
        ModError::AssetConflict { mod_id, .. } => Some(mod_id.as_str()),
        ModError::DependencyCycle { cycle_ids } => cycle_ids.first().map(String::as_str),
        ModError::LimitExceeded { .. }
        | ModError::Parse { .. }
        | ModError::Validation { .. }
        | ModError::PathDenied { .. }
        | ModError::SandboxDenied { .. }
        | ModError::Io { .. } => None,
    }
}

fn sort_by_priority(mut mods: Vec<&ModInfo>) -> Vec<&ModInfo> {
    mods.sort_by(|a, b| a.priority.cmp(&b.priority).then(a.id.cmp(&b.id)));
    mods
}

fn merge_custom_order<'a>(order: &[String], mods: &'a [ModInfo]) -> Vec<&'a ModInfo> {
    let mut result = Vec::new();
    let mut seen = HashSet::new();
    for id in order {
        if let Some(info) = mods.iter().find(|info| &info.id == id) {
            seen.insert(info.id.as_str());
            result.push(info);
        }
    }
    let mut remainder: Vec<&ModInfo> = mods
        .iter()
        .filter(|info| !seen.contains(info.id.as_str()))
        .collect();
    remainder = sort_by_priority(remainder);
    result.extend(remainder);
    result
}

fn topological_order_for_mods(mods: &[ModInfo]) -> Result<Vec<&ModInfo>, Vec<String>> {
    let mut index_by_id: HashMap<&str, usize> = HashMap::new();
    for (index, info) in mods.iter().enumerate() {
        index_by_id.insert(info.id.as_str(), index);
    }
    let mut indegree = vec![0usize; mods.len()];
    let mut outgoing = vec![Vec::<usize>::new(); mods.len()];
    for (index, info) in mods.iter().enumerate() {
        for dependency in &info.dependencies {
            if let Some(&dependency_index) = index_by_id.get(dependency.as_str()) {
                outgoing[dependency_index].push(index);
                indegree[index] += 1;
            }
        }
    }
    let mut ready: BinaryHeap<Reverse<(i32, String, usize)>> = BinaryHeap::new();
    for (index, info) in mods.iter().enumerate() {
        if indegree[index] == 0 {
            ready.push(Reverse((info.priority, info.id.clone(), index)));
        }
    }
    let mut ordered = Vec::with_capacity(mods.len());
    while let Some(Reverse((_priority, _id, index))) = ready.pop() {
        ordered.push(&mods[index]);
        for &dependent in &outgoing[index] {
            if indegree[dependent] > 0 {
                indegree[dependent] -= 1;
                if indegree[dependent] == 0 {
                    let info = &mods[dependent];
                    ready.push(Reverse((info.priority, info.id.clone(), dependent)));
                }
            }
        }
    }
    if ordered.len() != mods.len() {
        let cycle_ids = mods
            .iter()
            .enumerate()
            .filter(|(index, _)| indegree[*index] > 0)
            .map(|(_, info)| info.id.clone())
            .collect();
        Err(cycle_ids)
    } else {
        Ok(ordered)
    }
}
