//! This file provides the active tween engine that updates all running animation handles. `tween/engine` delivers the engine implementation for the tween subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! It tracks tweens, sequences, parallels, and springs through one coordinated update surface. The file owns or coordinates data contracts including `TweenEngine`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! It resolves easing behavior and value writes directly onto Lua-owned target tables. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `update`, `cancel_all`, `active_count` stays attached to the local data model and invariants.
//! It manages lifecycle cleanup so completed animations exit without stale runtime state. Runtime integration reaches sibling engine areas through crate modules `tween`, which explains the subsystem dependencies an agent should inspect before changing behavior.

use crate::tween::handle::{LuaTween, LuaTweenParallel, LuaTweenSequence};
use mlua::prelude::*;
use std::cell::RefCell;
use std::collections::HashMap;
use std::rc::Rc;

/// Active tween coordinator; holds registry keys for all running tweens, sequences, parallels, and springs.
pub struct TweenEngine {
    /// Registry keys for standalone `LuaTween` instances currently animating.
    pub active_tweens: Vec<LuaRegistryKey>,
    /// Registry keys for `LuaTweenSequence` instances currently stepping.
    pub active_seqs: Vec<LuaRegistryKey>,
    /// Registry keys for `LuaTweenParallel` groups currently stepping.
    pub active_pars: Vec<LuaRegistryKey>,
    /// Registry keys for `SpringSystem` instances currently simulating.
    pub active_springs: Vec<LuaRegistryKey>,
    /// Named Lua easing functions registered at runtime; key = easing name.
    pub custom_easings: HashMap<String, LuaRegistryKey>,
}

impl TweenEngine {
    /// Create an empty engine with no active animations and no custom easings.
    pub fn new() -> Self {
        Self {
            active_tweens: Vec::new(),
            active_seqs: Vec::new(),
            active_pars: Vec::new(),
            active_springs: Vec::new(),
            custom_easings: HashMap::new(),
        }
    }

    /// Advance all active tweens, sequences, and parallels by `dt` seconds;.
    /// remove completed entries from the registry; return error on Lua fault.
    pub fn update(this_rc: &Rc<RefCell<Self>>, lua: &Lua, dt: f64) -> LuaResult<()> {
        let tween_keys = std::mem::take(&mut this_rc.borrow_mut().active_tweens);
        let mut still_active_tweens = Vec::with_capacity(tween_keys.len());
        for key in tween_keys {
            let ud: LuaAnyUserData = lua.registry_value(&key)?;
            let done = {
                let mut tw = ud.borrow_mut::<LuaTween>()?;
                if tw.owned_by_parent || !tw.active {
                    if !tw.active {
                        if let Some(k) = tw.on_cancel.take() {
                            let f: LuaFunction = lua.registry_value(&k)?;
                            let _ = f.call::<_, ()>(());
                            lua.remove_registry_value(k)?;
                        }
                    }
                    true
                } else {
                    tw.tick_with(lua, dt)?
                }
            };
            if done {
                lua.remove_registry_value(key)?;
            } else {
                still_active_tweens.push(key);
            }
        }
        this_rc.borrow_mut().active_tweens = still_active_tweens;
        let seq_keys = std::mem::take(&mut this_rc.borrow_mut().active_seqs);
        let mut still_active_seqs = Vec::with_capacity(seq_keys.len());
        for key in seq_keys {
            let ud: LuaAnyUserData = lua.registry_value(&key)?;
            let done = {
                let mut seq = ud.borrow_mut::<LuaTweenSequence>()?;
                if !seq.active {
                    true
                } else {
                    seq.tick_with(lua, dt)?
                }
            };
            if done {
                lua.remove_registry_value(key)?;
            } else {
                still_active_seqs.push(key);
            }
        }
        this_rc.borrow_mut().active_seqs = still_active_seqs;
        let par_keys = std::mem::take(&mut this_rc.borrow_mut().active_pars);
        let mut still_active_pars = Vec::with_capacity(par_keys.len());
        for key in par_keys {
            let ud: LuaAnyUserData = lua.registry_value(&key)?;
            let done = {
                let mut par = ud.borrow_mut::<LuaTweenParallel>()?;
                if !par.active {
                    true
                } else {
                    par.tick_with(lua, dt)?
                }
            };
            if done {
                lua.remove_registry_value(key)?;
            } else {
                still_active_pars.push(key);
            }
        }
        this_rc.borrow_mut().active_pars = still_active_pars;
        Ok(())
    }

    /// Cancel and remove all active tweens, sequences, and parallels; fires `on_cancel` callbacks; return error on Lua fault.
    pub fn cancel_all(this_rc: &Rc<RefCell<Self>>, lua: &Lua) -> LuaResult<()> {
        let (tweens, seqs, pars) = {
            let mut s = this_rc.borrow_mut();
            (
                std::mem::take(&mut s.active_tweens),
                std::mem::take(&mut s.active_seqs),
                std::mem::take(&mut s.active_pars),
            )
        };
        for key in tweens {
            let ud: LuaAnyUserData = lua.registry_value(&key)?;
            {
                let mut tw = ud.borrow_mut::<LuaTween>()?;
                tw.active = false;
                if let Some(k) = tw.on_cancel.take() {
                    let f: LuaFunction = lua.registry_value(&k)?;
                    let _ = f.call::<_, ()>(());
                    lua.remove_registry_value(k)?;
                }
            }
            lua.remove_registry_value(key)?;
        }
        for key in seqs {
            let ud: LuaAnyUserData = lua.registry_value(&key)?;
            {
                ud.borrow_mut::<LuaTweenSequence>()?.active = false;
            }
            lua.remove_registry_value(key)?;
        }
        for key in pars {
            let ud: LuaAnyUserData = lua.registry_value(&key)?;
            {
                ud.borrow_mut::<LuaTweenParallel>()?.active = false;
            }
            lua.remove_registry_value(key)?;
        }
        Ok(())
    }

    /// Return the total count of active tweens, sequences, parallels, and springs.
    pub fn active_count(&self) -> usize {
        self.active_tweens.len()
            + self.active_seqs.len()
            + self.active_pars.len()
            + self.active_springs.len()
    }
}

/// Provide `TweenEngine::new()` as the default constructor.
impl Default for TweenEngine {
    fn default() -> Self {
        Self::new()
    }
}
