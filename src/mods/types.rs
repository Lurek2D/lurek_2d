//! Owns mods behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps mods data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
//! Defines how types data is validated, transformed, or stored before neighboring systems use it.
//! Owns mods behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on types behavior while Lua registration stays elsewhere.
//! Documents where mods callers should change defaults, errors, or lifecycle behavior. with focused crate-local behavior.
//! Use this file when changing types defaults, lifecycle handling, validation, or data ownership.

use std::fmt;
use std::path::PathBuf;

/// Shared result alias for mods operations.
pub type ModResult<T> = Result<T, ModError>;

/// Dependency-cycle behavior used when building a load plan.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DependencyCyclePolicy {
    /// Refuse to build a load plan when a cycle exists.
    Error,
    /// Warn and fall back to priority sorting when a cycle exists.
    WarnAndPriorityFallback,
}

/// Safety and validation ceilings for manifests, content files, and identifiers.
#[derive(Debug, Clone)]
pub struct ModLimits {
    /// Maximum number of mod directories scanned in one pass.
    pub max_mods: usize,
    /// Maximum manifest size in bytes.
    pub max_manifest_bytes: u64,
    /// Maximum content-file size in bytes.
    pub max_content_bytes: usize,
    /// Maximum content instances parsed from one TOML file.
    pub max_instances: usize,
    /// Maximum fields accepted for one content instance.
    pub max_instance_fields: usize,
    /// Maximum mod identifier length.
    pub max_id_len: usize,
    /// Maximum display-name length.
    pub max_name_len: usize,
    /// Maximum version string length.
    pub max_version_len: usize,
    /// Maximum author string length.
    pub max_author_len: usize,
    /// Maximum description string length.
    pub max_description_len: usize,
    /// Maximum capability count per mod.
    pub max_capabilities: usize,
    /// Maximum capability token length.
    pub max_capability_len: usize,
    /// Maximum dependency count per mod.
    pub max_dependencies: usize,
    /// Maximum asset path count per mod.
    pub max_asset_paths: usize,
    /// Maximum config schema entry count per mod.
    pub max_config_schema_entries: usize,
    /// Maximum hook-name length accepted by sandbox helpers.
    pub max_hook_len: usize,
}

impl Default for ModLimits {
    fn default() -> Self {
        Self {
            max_mods: 256,
            max_manifest_bytes: 256 * 1024,
            max_content_bytes: 256 * 1024,
            max_instances: 1024,
            max_instance_fields: 128,
            max_id_len: 64,
            max_name_len: 128,
            max_version_len: 32,
            max_author_len: 128,
            max_description_len: 2048,
            max_capabilities: 64,
            max_capability_len: 64,
            max_dependencies: 64,
            max_asset_paths: 256,
            max_config_schema_entries: 128,
            max_hook_len: 96,
        }
    }
}

/// Scan configuration for mod discovery and validation.
#[derive(Debug, Clone)]
pub struct ModScanPolicy {
    /// Shared limits for manifests and identifiers.
    pub limits: ModLimits,
    /// Whether hidden directories should be ignored during scans.
    pub ignore_hidden_dirs: bool,
    /// Whether common temporary directory names should be ignored during scans.
    pub ignore_temp_dirs: bool,
    /// Whether dependency validation failures should block registration.
    pub strict_load_plan: bool,
    /// Cycle behavior used when building the load plan.
    pub dependency_cycle_policy: DependencyCyclePolicy,
    /// Optional host API version used to validate `api_version`.
    pub host_api_version: Option<String>,
    /// Whether asset checksum verification should run when checksums are present.
    pub verify_asset_checksums: bool,
}

impl Default for ModScanPolicy {
    fn default() -> Self {
        Self {
            limits: ModLimits::default(),
            ignore_hidden_dirs: true,
            ignore_temp_dirs: true,
            strict_load_plan: true,
            dependency_cycle_policy: DependencyCyclePolicy::Error,
            host_api_version: None,
            verify_asset_checksums: false,
        }
    }
}

/// One skipped mod entry recorded during a scan.
#[derive(Debug, Clone)]
pub struct ModSkipped {
    /// Directory or manifest path that was skipped.
    pub path: PathBuf,
    /// Structured reason for the skip.
    pub error: ModError,
}

/// Structured discovery output for `scan_folder_with_policy`.
#[derive(Debug, Clone)]
pub struct ModScanReport<T = String> {
    /// Canonical root that was scanned.
    pub root: PathBuf,
    /// Loaded mod identifiers.
    pub loaded_ids: Vec<String>,
    /// Successfully parsed mod payloads.
    pub loaded: Vec<T>,
    /// Skipped mod directories and reasons.
    pub skipped: Vec<ModSkipped>,
    /// Non-fatal warnings emitted during the scan.
    pub warnings: Vec<String>,
    /// Fatal scan-level errors not tied to a single skipped directory.
    pub errors: Vec<ModError>,
}

impl<T> ModScanReport<T> {
    /// Create an empty report for `root`.
    pub fn new(root: PathBuf) -> Self {
        Self {
            root,
            loaded_ids: Vec::new(),
            loaded: Vec::new(),
            skipped: Vec::new(),
            warnings: Vec::new(),
            errors: Vec::new(),
        }
    }
}

/// Combined dependency and version-validation result for a candidate load order.
#[derive(Debug, Clone)]
pub struct ModLoadPlan {
    /// Ordered mod identifiers that would load under this plan.
    pub ordered_ids: Vec<String>,
    /// Structured validation failures.
    pub errors: Vec<ModError>,
    /// Non-fatal warnings such as fallback sorting.
    pub warnings: Vec<String>,
    /// Whether a cycle fallback was used instead of a strict topological order.
    pub used_cycle_fallback: bool,
}

impl ModLoadPlan {
    /// Return true when the plan has no validation errors.
    pub fn is_valid(&self) -> bool {
        self.errors.is_empty()
    }
}

/// Structured output for hot reload processing.
#[derive(Debug, Clone, Default)]
pub struct ModReloadReport {
    /// Mod identifiers that were reloaded successfully.
    pub reloaded: Vec<String>,
    /// Reload failures with per-mod reasons.
    pub failed: Vec<(String, ModError)>,
    /// Non-fatal warnings emitted while building the reload snapshot.
    pub warnings: Vec<String>,
    /// Whether the effective load order changed after the swap.
    pub changed_load_order: bool,
}

/// Structured mods error used across manifest parsing, scans, planning, and sandbox checks.
#[derive(Debug, Clone)]
pub enum ModError {
    /// A manifest or content file exceeded a configured byte limit.
    LimitExceeded {
        /// Logical limit label.
        what: String,
        /// Observed size or count.
        actual: u64,
        /// Maximum accepted size or count.
        max: u64,
    },
    /// Manifest or content TOML could not be parsed.
    Parse {
        /// Source path being parsed.
        path: PathBuf,
        /// Human-readable parse detail.
        detail: String,
    },
    /// A required field was missing or malformed.
    Validation {
        /// Source path being validated.
        path: Option<PathBuf>,
        /// Human-readable validation detail.
        detail: String,
    },
    /// A path failed normalization, root confinement, or traversal policy.
    PathDenied {
        /// Path string involved in the failure.
        path: String,
        /// Human-readable policy detail.
        detail: String,
    },
    /// A sandbox policy blocked an operation.
    SandboxDenied {
        /// Operation label such as `filesystem.write`.
        operation: String,
        /// Human-readable denial detail.
        detail: String,
    },
    /// A required dependency was missing.
    MissingDependency {
        /// Mod that declared the dependency.
        mod_id: String,
        /// Missing dependency id.
        dependency: String,
    },
    /// A declared dependency exists but is disabled.
    DisabledDependency {
        /// Mod that declared the dependency.
        mod_id: String,
        /// Disabled dependency id.
        dependency: String,
    },
    /// A dependency cycle blocked strict load planning.
    DependencyCycle {
        /// Identifiers participating in the cycle or unresolved knot.
        cycle_ids: Vec<String>,
    },
    /// A mod declared an incompatible API version.
    ApiVersionMismatch {
        /// Mod id that failed version validation.
        mod_id: String,
        /// Human-readable detail returned by version checking.
        detail: String,
    },
    /// Manifest checksum or asset checksum validation failed.
    IntegrityMismatch {
        /// Mod id that failed integrity validation.
        mod_id: String,
        /// Human-readable checksum detail.
        detail: String,
    },
    /// Two mods claimed the same asset path.
    AssetConflict {
        /// Mod id being validated.
        mod_id: String,
        /// Conflicting asset path.
        asset_path: String,
        /// Existing mod id already owning the asset path.
        other_mod_id: String,
    },
    /// Reload failed before the new snapshot could be committed.
    ReloadFailure {
        /// Mod id that failed reload processing.
        mod_id: String,
        /// Human-readable failure detail.
        detail: String,
    },
    /// Filesystem IO failed while scanning or validating a mod.
    Io {
        /// Source or target path involved in the failure.
        path: PathBuf,
        /// Human-readable IO detail.
        detail: String,
    },
}

impl fmt::Display for ModError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::LimitExceeded { what, actual, max } => {
                write!(f, "{} exceeded limit: {} > {}", what, actual, max)
            }
            Self::Parse { path, detail } => write!(f, "{}: {}", path.display(), detail),
            Self::Validation { path, detail } => {
                if let Some(path) = path {
                    write!(f, "{}: {}", path.display(), detail)
                } else {
                    write!(f, "{}", detail)
                }
            }
            Self::PathDenied { path, detail } => write!(f, "{}: {}", path, detail),
            Self::SandboxDenied { operation, detail } => {
                write!(f, "{} denied: {}", operation, detail)
            }
            Self::MissingDependency { mod_id, dependency } => {
                write!(f, "mod '{}' is missing dependency '{}'", mod_id, dependency)
            }
            Self::DisabledDependency { mod_id, dependency } => {
                write!(
                    f,
                    "mod '{}' depends on disabled mod '{}'",
                    mod_id, dependency
                )
            }
            Self::DependencyCycle { cycle_ids } => {
                write!(f, "dependency cycle detected: {}", cycle_ids.join(" -> "))
            }
            Self::ApiVersionMismatch { mod_id, detail } => {
                write!(f, "mod '{}' API version mismatch: {}", mod_id, detail)
            }
            Self::IntegrityMismatch { mod_id, detail } => {
                write!(f, "mod '{}' integrity mismatch: {}", mod_id, detail)
            }
            Self::AssetConflict {
                mod_id,
                asset_path,
                other_mod_id,
            } => write!(
                f,
                "mod '{}' conflicts with '{}' on asset '{}'",
                mod_id, other_mod_id, asset_path
            ),
            Self::ReloadFailure { mod_id, detail } => {
                write!(f, "mod '{}' reload failed: {}", mod_id, detail)
            }
            Self::Io { path, detail } => write!(f, "{}: {}", path.display(), detail),
        }
    }
}

impl std::error::Error for ModError {}
