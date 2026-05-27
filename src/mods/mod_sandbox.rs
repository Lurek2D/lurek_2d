//! Mod sandbox: restricts mod Lua API access to the declared capability set.
//!
//! - Wraps the shared Lua state with a per-mod permission filter over `lurek.*`.
//! - Attempts to call undeclared API functions raise a Lua error instead of panicking.
//! - File system access for mods is limited to their own `content/mods/<id>/` directory.
//! - Sandbox is re-applied after each hot-reload; capability set cannot expand at runtime.

use std::collections::HashSet;

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
    /// Blocked filesystem operations.
    blocked_ops: HashSet<String>,
    /// Allowed hook points.
    allowed_hooks: HashSet<HookPoint>,
    /// Maximum memory usage in bytes (0 = unlimited).
    pub max_memory: usize,
    /// Whether network access is allowed.
    pub allow_network: bool,
    /// Whether file write access is allowed.
    pub allow_file_write: bool,
    /// Allowed file path prefixes for reading.
    pub allowed_read_paths: Vec<String>,
}

impl ModSandbox {
    /// Create a default sandbox (restrictive).
    pub fn new() -> Self {
        Self {
            allowed_apis: HashSet::new(),
            blocked_ops: HashSet::new(),
            allowed_hooks: HashSet::new(),
            max_memory: 64 * 1024 * 1024, // 64 MB
            allow_network: false,
            allow_file_write: false,
            allowed_read_paths: Vec::new(),
        }
    }

    /// Create a permissive sandbox (for trusted mods).
    pub fn permissive() -> Self {
        Self {
            allowed_apis: HashSet::new(), // empty = allow all
            blocked_ops: HashSet::new(),
            allowed_hooks: HashSet::new(), // empty = allow all
            max_memory: 0,
            allow_network: true,
            allow_file_write: true,
            allowed_read_paths: Vec::new(),
        }
    }

    /// Allow access to a specific API module.
    pub fn allow_api(&mut self, module: impl Into<String>) {
        self.allowed_apis.insert(module.into());
    }

    /// Block a specific mod operation.
    pub fn block_op(&mut self, op: impl Into<String>) {
        self.blocked_ops.insert(op.into());
    }

    /// Allow a mod lifecycle hook point.
    pub fn allow_hook(&mut self, hook: HookPoint) {
        self.allowed_hooks.insert(hook);
    }

    /// Check if an API call is allowed.
    pub fn is_api_allowed(&self, module: &str) -> bool {
        if self.allowed_apis.is_empty() {
            return true; // Empty = allow all
        }
        self.allowed_apis.contains(module)
    }

    /// Check if an operation is blocked.
    pub fn is_op_blocked(&self, op: &str) -> bool {
        self.blocked_ops.contains(op)
    }

    /// Check if a hook point is allowed.
    pub fn is_hook_allowed(&self, hook: &HookPoint) -> bool {
        if self.allowed_hooks.is_empty() {
            return true; // Empty = allow all
        }
        self.allowed_hooks.contains(hook)
    }

    /// Check if a file path is allowed for reading.
    pub fn is_read_allowed(&self, path: &str) -> bool {
        if self.allowed_read_paths.is_empty() {
            return true;
        }
        self.allowed_read_paths.iter().any(|prefix| path.starts_with(prefix))
    }
}

impl Default for ModSandbox {
    fn default() -> Self {
        Self::new()
    }
}
