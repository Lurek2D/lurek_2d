//! Owns mods behavior with explicit state, validation, and crate-local integration boundaries.
//! Centers the implementation around SandboxListMode, from_name, as_str, with helpers kept close to their invariants.
//! Defines how mod sandbox data is validated, transformed, or stored before neighboring systems use it.
//! Owns mods behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on mod sandbox behavior while Lua registration stays elsewhere.
//! Documents where mods callers should change defaults, errors, or lifecycle behavior. with focused crate-local behavior.
//! Use this file when changing mod sandbox defaults, lifecycle handling, validation, or data ownership.

use super::{ModError, ModLimits, ModResult};
use std::collections::HashSet;
use std::fs;
use std::path::{Path, PathBuf};

/// List-policy mode used by API, hook, and read allowlists.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum SandboxListMode {
    /// Allow any value without consulting an allowlist.
    AllowAll,
    /// Deny every value unless a caller changes the mode explicitly.
    DenyByDefault,
    /// Allow only values present in the configured allowlist.
    AllowList,
}

impl SandboxListMode {
    /// Parse a manifest or Lua-facing mode name.
    pub fn from_name(value: &str) -> Option<Self> {
        match value.trim().to_ascii_lowercase().as_str() {
            "allow_all" | "allowall" => Some(Self::AllowAll),
            "deny_by_default" | "denybydefault" | "deny" => Some(Self::DenyByDefault),
            "allow_list" | "allowlist" => Some(Self::AllowList),
            _ => None,
        }
    }

    /// Return the stable string name for this mode.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::AllowAll => "allow_all",
            Self::DenyByDefault => "deny_by_default",
            Self::AllowList => "allow_list",
        }
    }
}

/// Hook point where mods can inject behavior.
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub enum HookPoint {
    /// Called once when the mod loads.
    OnLoad,
    /// Called once when the mod unloads.
    OnUnload,
    /// Called every frame update.
    OnUpdate,
    /// Called on fixed timestep.
    OnFixedUpdate,
    /// Called when a game event fires.
    OnEvent(String),
    /// Called when a specific API type instance is created.
    OnCreate(String),
    /// Called when a specific API type instance is destroyed.
    OnDestroy(String),
    /// Custom named hook.
    Custom(String),
}

impl HookPoint {
    /// Parse a `HookPoint` from a string name, supporting `on_event:`, `on_create:`, and `on_destroy:` prefixes.
    pub fn from_name(s: &str) -> Self {
        match s.to_lowercase().as_str() {
            "on_load" | "load" => Self::OnLoad,
            "on_unload" | "unload" => Self::OnUnload,
            "on_update" | "update" => Self::OnUpdate,
            "on_fixed_update" | "fixed_update" => Self::OnFixedUpdate,
            other => {
                if let Some(event) = other.strip_prefix("on_event:") {
                    Self::OnEvent(event.to_string())
                } else if let Some(type_name) = other.strip_prefix("on_create:") {
                    Self::OnCreate(type_name.to_string())
                } else if let Some(type_name) = other.strip_prefix("on_destroy:") {
                    Self::OnDestroy(type_name.to_string())
                } else {
                    Self::Custom(other.to_string())
                }
            }
        }
    }

    /// Parse and validate a hook name using the shared mod limits.
    pub fn parse_validated(s: &str, limits: &ModLimits) -> ModResult<Self> {
        validate_symbol("hook", s, limits.max_hook_len)?;
        Ok(Self::from_name(s))
    }

    /// Return the canonical string representation of this hook point.
    pub fn as_str(&self) -> String {
        match self {
            Self::OnLoad => "on_load".to_string(),
            Self::OnUnload => "on_unload".to_string(),
            Self::OnUpdate => "on_update".to_string(),
            Self::OnFixedUpdate => "on_fixed_update".to_string(),
            Self::OnEvent(e) => format!("on_event:{e}"),
            Self::OnCreate(t) => format!("on_create:{t}"),
            Self::OnDestroy(t) => format!("on_destroy:{t}"),
            Self::Custom(s) => s.clone(),
        }
    }
}

/// Sandbox configuration restricting mod capabilities.
#[derive(Debug, Clone)]
pub struct ModSandbox {
    /// Allowed lurek.* API module names.
    allowed_apis: HashSet<String>,
    /// Policy mode used for API access.
    api_mode: SandboxListMode,
    /// Blocked filesystem or runtime operations.
    blocked_ops: HashSet<String>,
    /// Allowed hook points.
    allowed_hooks: HashSet<HookPoint>,
    /// Policy mode used for hook access.
    hook_mode: SandboxListMode,
    /// Maximum memory usage in bytes (0 = unlimited).
    pub max_memory: usize,
    /// Whether network access is allowed.
    pub allow_network: bool,
    /// Whether file write access is allowed.
    pub allow_file_write: bool,
    /// Canonical filesystem roots allowed for reads.
    allowed_read_roots: Vec<PathBuf>,
    /// Policy mode used for read roots.
    read_mode: SandboxListMode,
}

impl ModSandbox {
    /// Create a default sandbox (deny-by-default).
    pub fn new() -> Self {
        Self {
            allowed_apis: HashSet::new(),
            api_mode: SandboxListMode::DenyByDefault,
            blocked_ops: HashSet::new(),
            allowed_hooks: HashSet::new(),
            hook_mode: SandboxListMode::DenyByDefault,
            max_memory: 64 * 1024 * 1024,
            allow_network: false,
            allow_file_write: false,
            allowed_read_roots: Vec::new(),
            read_mode: SandboxListMode::DenyByDefault,
        }
    }

    /// Create a permissive sandbox (for trusted mods).
    pub fn permissive() -> Self {
        Self {
            allowed_apis: HashSet::new(),
            api_mode: SandboxListMode::AllowAll,
            blocked_ops: HashSet::new(),
            allowed_hooks: HashSet::new(),
            hook_mode: SandboxListMode::AllowAll,
            max_memory: 0,
            allow_network: true,
            allow_file_write: true,
            allowed_read_roots: Vec::new(),
            read_mode: SandboxListMode::AllowAll,
        }
    }

    /// Return the API allowlist mode.
    pub fn api_mode(&self) -> SandboxListMode {
        self.api_mode
    }

    /// Return the hook allowlist mode.
    pub fn hook_mode(&self) -> SandboxListMode {
        self.hook_mode
    }

    /// Return the read-root allowlist mode.
    pub fn read_mode(&self) -> SandboxListMode {
        self.read_mode
    }

    /// Replace the API policy mode.
    pub fn set_api_mode(&mut self, mode: SandboxListMode) {
        self.api_mode = mode;
    }

    /// Replace the hook policy mode.
    pub fn set_hook_mode(&mut self, mode: SandboxListMode) {
        self.hook_mode = mode;
    }

    /// Replace the read-root policy mode.
    pub fn set_read_mode(&mut self, mode: SandboxListMode) {
        self.read_mode = mode;
    }

    /// Allow access to a specific API module.
    pub fn allow_api(&mut self, module: impl Into<String>) {
        self.api_mode = SandboxListMode::AllowList;
        self.allowed_apis.insert(module.into());
    }

    /// Block a specific mod operation.
    pub fn block_op(&mut self, op: impl Into<String>) {
        self.blocked_ops.insert(op.into());
    }

    /// Allow a mod lifecycle hook point.
    pub fn allow_hook(&mut self, hook: HookPoint) {
        self.hook_mode = SandboxListMode::AllowList;
        self.allowed_hooks.insert(hook);
    }

    /// Canonicalize and allow a read root.
    pub fn allow_read_root(&mut self, path: impl AsRef<Path>) -> ModResult<()> {
        let canonical = canonicalize_root(path.as_ref())?;
        self.read_mode = SandboxListMode::AllowList;
        if !self
            .allowed_read_roots
            .iter()
            .any(|root| root == &canonical)
        {
            self.allowed_read_roots.push(canonical);
        }
        Ok(())
    }

    /// Return configured canonical read roots.
    pub fn allowed_read_roots(&self) -> &[PathBuf] {
        &self.allowed_read_roots
    }

    /// Iterate configured API allowlist entries.
    pub fn allowed_apis(&self) -> impl Iterator<Item = &String> {
        self.allowed_apis.iter()
    }

    /// Iterate blocked operation names.
    pub fn blocked_ops(&self) -> impl Iterator<Item = &String> {
        self.blocked_ops.iter()
    }

    /// Iterate configured hook allowlist entries.
    pub fn allowed_hooks(&self) -> impl Iterator<Item = &HookPoint> {
        self.allowed_hooks.iter()
    }

    /// Check if an API call is allowed.
    pub fn is_api_allowed(&self, module: &str) -> bool {
        match self.api_mode {
            SandboxListMode::AllowAll => true,
            SandboxListMode::DenyByDefault => false,
            SandboxListMode::AllowList => self.allowed_apis.contains(module),
        }
    }

    /// Check if an operation is blocked.
    pub fn is_op_blocked(&self, op: &str) -> bool {
        self.blocked_ops.contains(op)
    }

    /// Check if a hook point is allowed.
    pub fn is_hook_allowed(&self, hook: &HookPoint) -> bool {
        match self.hook_mode {
            SandboxListMode::AllowAll => true,
            SandboxListMode::DenyByDefault => false,
            SandboxListMode::AllowList => self.allowed_hooks.contains(hook),
        }
    }

    /// Check if a file path is allowed for reading.
    pub fn is_read_allowed(&self, path: &str) -> bool {
        self.check_read_path(path).is_ok()
    }

    /// Check a requested read path against canonical roots.
    pub fn check_read_path(&self, path: &str) -> ModResult<()> {
        self.check_read_path_host(Path::new(path))
    }

    /// Check a requested host path against canonical roots.
    pub fn check_read_path_host(&self, path: &Path) -> ModResult<()> {
        match self.read_mode {
            SandboxListMode::AllowAll => Ok(()),
            SandboxListMode::DenyByDefault => Err(ModError::PathDenied {
                path: path.to_string_lossy().into_owned(),
                detail: "sandbox read roots are deny-by-default".to_string(),
            }),
            SandboxListMode::AllowList => {
                let canonical = canonicalize_candidate_path(path)?;
                if self
                    .allowed_read_roots
                    .iter()
                    .any(|root| canonical.starts_with(root))
                {
                    Ok(())
                } else {
                    Err(ModError::PathDenied {
                        path: path.to_string_lossy().into_owned(),
                        detail: "path is outside configured read roots".to_string(),
                    })
                }
            }
        }
    }
}

impl Default for ModSandbox {
    fn default() -> Self {
        Self::new()
    }
}

fn validate_symbol(kind: &str, value: &str, max_len: usize) -> ModResult<()> {
    if value.is_empty() {
        return Err(ModError::Validation {
            path: None,
            detail: format!("{} cannot be empty", kind),
        });
    }
    if value.len() > max_len {
        return Err(ModError::Validation {
            path: None,
            detail: format!("{} '{}' exceeds max length {}", kind, value, max_len),
        });
    }
    if !value
        .chars()
        .all(|ch| ch.is_ascii_alphanumeric() || matches!(ch, '_' | '-' | '.' | ':'))
    {
        return Err(ModError::Validation {
            path: None,
            detail: format!("{} '{}' contains unsupported characters", kind, value),
        });
    }
    Ok(())
}

fn canonicalize_root(path: &Path) -> ModResult<PathBuf> {
    let canonical = fs::canonicalize(path).map_err(|err| ModError::Io {
        path: path.to_path_buf(),
        detail: err.to_string(),
    })?;
    if !canonical.is_dir() {
        return Err(ModError::PathDenied {
            path: canonical.to_string_lossy().into_owned(),
            detail: "read root must be an existing directory".to_string(),
        });
    }
    Ok(canonical)
}

fn canonicalize_candidate_path(path: &Path) -> ModResult<PathBuf> {
    let absolute = if path.is_absolute() {
        path.to_path_buf()
    } else {
        std::env::current_dir()
            .map_err(|err| ModError::PathDenied {
                path: path.to_string_lossy().into_owned(),
                detail: err.to_string(),
            })?
            .join(path)
    };

    if absolute.exists() {
        return fs::canonicalize(&absolute).map_err(|err| ModError::PathDenied {
            path: absolute.to_string_lossy().into_owned(),
            detail: err.to_string(),
        });
    }

    let mut candidate = PathBuf::new();
    let mut suffix: Vec<PathBuf> = Vec::new();
    let mut found_existing_ancestor = false;

    for component in absolute.components() {
        match component {
            std::path::Component::Prefix(prefix) => candidate.push(prefix.as_os_str()),
            std::path::Component::RootDir => candidate.push(component.as_os_str()),
            std::path::Component::CurDir => {}
            std::path::Component::ParentDir => {
                return Err(ModError::PathDenied {
                    path: absolute.to_string_lossy().into_owned(),
                    detail: "path traversal is not allowed".to_string(),
                });
            }
            std::path::Component::Normal(part) => {
                if found_existing_ancestor {
                    suffix.push(PathBuf::from(part));
                    continue;
                }
                let next = candidate.join(part);
                if next.exists() {
                    candidate = next;
                } else {
                    found_existing_ancestor = true;
                    suffix.push(PathBuf::from(part));
                }
            }
        }
    }

    let mut canonical = fs::canonicalize(&candidate).map_err(|err| ModError::PathDenied {
        path: absolute.to_string_lossy().into_owned(),
        detail: err.to_string(),
    })?;
    for part in suffix {
        canonical.push(part);
    }
    Ok(canonical)
}
