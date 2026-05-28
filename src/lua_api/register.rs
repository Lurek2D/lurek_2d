//! Lua VM creation and `lurek.*` module registration entry point.

#[cfg(feature = "automation-plugin")]
use super::automation_api;
#[cfg(feature = "ui-charts")]
use super::charts_api;
#[cfg(feature = "devtools-plugin")]
use super::devtools_api;
#[cfg(feature = "flownet")]
use super::flownet_api;
use super::lua_module::ModuleEntry;
use super::{
    ai_api, animation_api, audio_api, binary_api, camera_api, color_api, compute_api, cursor_api,
    dataframe_api, debugbridge_api, dialog_api, docs_api, dsp_api, ecs_api, effect_api, engine_api,
    event_api, filesystem_api, font_api, globe_api, grep_api, html_api, i18n_api, image_api,
    input_api, layout_api, learning_api, light_api, log_api, mapblock_api, math_api, midi_api,
    minimap_api, mods_api, network_api, overlay_api, parallax_api, particle_api, pathfind_api,
    patterns_api, physics_api, pipeline_api, procgen_api, province_api, raycaster_api, render_api,
    repl_api, save_api, scene_api, serialize_api, spine_api, sprite_api, system_api, terminal_api,
    thread_api, tilemap_api, timer_api, tween_api, ui_api, validator_api, visibility_api,
    window_api,
};
use crate::runtime::config::ModulesConfig;
use crate::runtime::SharedState;
use mlua::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;

/// Constructs a [`ModuleEntry`] for a module that is always registered.
macro_rules! always {
    ($api:ident) => {
        ModuleEntry {
            name: stringify!($api),
            is_enabled: |_| true,
            register: $api::register,
        }
    };
}

/// Constructs a [`ModuleEntry`] for a module gated by a [`ModulesConfig`] field.
macro_rules! gated {
    ($api:ident, $field:ident) => {
        ModuleEntry {
            name: stringify!($api),
            is_enabled: |m| m.$field,
            register: $api::register,
        }
    };
}

/// Static registry of all standard (non-feature-gated) modules.
///
/// Order is preserved from the original registration sequence.
/// Always-on modules have `is_enabled` returning `true` unconditionally.
static MODULES: &[ModuleEntry] = &[
    // ── Always-on core modules ──────────────────────────────────────────
    always!(event_api),
    always!(sprite_api),
    always!(save_api),
    always!(docs_api),
    always!(log_api),
    always!(engine_api),
    always!(repl_api),
    always!(binary_api),
    always!(mods_api),
    always!(serialize_api),
    always!(dataframe_api),
    always!(light_api),
    always!(html_api),
    always!(math_api),
    always!(color_api),
    always!(system_api),
    always!(font_api),
    // ── Config-gated modules ────────────────────────────────────────────
    gated!(timer_api, timer),
    gated!(image_api, image),
    gated!(camera_api, camera),
    gated!(animation_api, animation),
    gated!(tween_api, tween),
    gated!(thread_api, thread),
    gated!(debugbridge_api, debug),
    gated!(i18n_api, i18n),
    gated!(input_api, input),
    gated!(filesystem_api, filesystem),
    gated!(ecs_api, ecs),
    gated!(window_api, window),
    gated!(scene_api, scene),
    gated!(compute_api, compute),
    gated!(raycaster_api, raycaster),
    gated!(spine_api, spine),
    gated!(procgen_api, procgen),
    gated!(network_api, network),
    gated!(minimap_api, minimap),
    gated!(province_api, province),
    gated!(pathfind_api, pathfind),
    gated!(layout_api, layout),
    gated!(terminal_api, terminal),
    gated!(pipeline_api, pipeline),
    always!(patterns_api),
    gated!(globe_api, globe),
    gated!(ai_api, ai),
    gated!(dialog_api, ai),
    gated!(learning_api, learning),
    gated!(audio_api, audio),
    gated!(dsp_api, dsp),
    gated!(midi_api, audio),
    gated!(effect_api, effect),
    gated!(overlay_api, overlay),
    gated!(particle_api, particle),
    gated!(parallax_api, parallax),
    gated!(ui_api, ui),
    gated!(visibility_api, visibility),
    gated!(tilemap_api, tilemap),
    gated!(physics_api, physics),
    gated!(cursor_api, cursor),
    gated!(grep_api, grep),
    gated!(mapblock_api, mapblock),
    gated!(validator_api, validator),
    gated!(render_api, render),
];

// ─── VM constructors ────────────────────────────────────────────────────────

/// Creates a Lua VM, locks down unsafe standard-library entry points, installs the `lurek` table, and registers enabled modules.
pub fn create_lua_vm(state: Rc<RefCell<SharedState>>, modules: &ModulesConfig) -> LuaResult<Lua> {
    let lua = Lua::new();
    lockdown_stdlib(&lua)?;

    let lurek = lua.create_table()?;
    lua.globals().set("lurek", lurek.clone())?;

    register_modules(&lua, &lurek, &state, modules)?;

    lua.globals().set("lurek", lurek)?;
    setup_package_path(&lua)?;
    Ok(lua)
}

/// Creates a Lua VM with no-window headless module profile applied.
pub fn create_headless_vm(
    state: Rc<RefCell<SharedState>>,
    modules: &ModulesConfig,
) -> LuaResult<Lua> {
    let mut headless_modules = modules.clone();
    headless_modules.apply_headless_profile();
    headless_modules.validate_and_fix();
    create_lua_vm(state, &headless_modules)
}

/// Creates a default test Lua VM with default module configuration.
pub fn create_test_vm() -> LuaResult<Lua> {
    use crate::runtime::config::Config;
    use std::path::PathBuf;
    let state = Rc::new(RefCell::new(SharedState::new(
        800,
        600,
        "Test",
        PathBuf::from("."),
    )));
    let modules = Config::default().modules;
    create_lua_vm(state, &modules)
}

// ─── Internal helpers ───────────────────────────────────────────────────────

/// Removes unsafe standard-library functions from the Lua global environment.
fn lockdown_stdlib(lua: &Lua) -> LuaResult<()> {
    let globals = lua.globals();
    globals.set("load", mlua::Value::Nil)?;
    globals.set("loadfile", mlua::Value::Nil)?;
    globals.set("dofile", mlua::Value::Nil)?;
    globals.set("debug", mlua::Value::Nil)?;
    if let Ok(os) = globals.get::<_, mlua::Table>("os") {
        os.set("execute", mlua::Value::Nil)?;
        os.set("getenv", mlua::Value::Nil)?;
    }
    if let Ok(io) = globals.get::<_, mlua::Table>("io") {
        io.set("open", mlua::Value::Nil)?;
        io.set("popen", mlua::Value::Nil)?;
    }
    Ok(())
}

/// Iterates the module registry and calls `register` for each enabled entry,
/// then handles feature-gated modules that cannot be in the static slice.
fn register_modules(
    lua: &Lua,
    lurek: &LuaTable,
    state: &Rc<RefCell<SharedState>>,
    modules: &ModulesConfig,
) -> LuaResult<()> {
    for entry in MODULES {
        if (entry.is_enabled)(modules) {
            (entry.register)(lua, lurek, state.clone())?;
        }
    }

    // Feature-gated modules require compile-time #[cfg] — cannot be in MODULES.
    #[cfg(feature = "automation-plugin")]
    if modules.debug {
        automation_api::register(lua, lurek, state.clone())?;
    }

    #[cfg(feature = "devtools-plugin")]
    if modules.debug {
        devtools_api::register(lua, lurek, state.clone())?;
    }

    #[cfg(feature = "flownet")]
    if modules.flownet {
        flownet_api::register(lua, lurek, state.clone())?;
    }

    #[cfg(feature = "ui-charts")]
    charts_api::register(lua, lurek, state.clone())?;

    Ok(())
}

/// Extends `package.path` so `require` finds game scripts and content modules.
fn setup_package_path(lua: &Lua) -> LuaResult<()> {
    let package: LuaTable = lua.globals().get("package")?;
    let old_path: String = package.get("path")?;
    let mut new_path = old_path;
    new_path.push_str(";./?/init.lua;./?.lua;./content/?/init.lua;./content/?.lua");
    if let Ok(exe) = std::env::current_exe() {
        if let Some(dir) = exe.parent() {
            let d = dir.to_string_lossy().replace('\\', "/");
            new_path.push_str(&format!(
                ";{}/?/init.lua;{}/?.lua;{}/content/?/init.lua;{}/content/?.lua",
                d, d, d, d
            ));
        }
    }
    package.set("path", new_path)?;
    Ok(())
}
