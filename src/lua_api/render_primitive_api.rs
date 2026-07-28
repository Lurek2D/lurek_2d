//! Registers primitive construction operations for the canonical `lurek.render` table.

use super::{LuaQuad, SharedState};
use mlua::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;

/// Register primitive constructors. Draw-command families extend this module.
pub(super) fn register_primitive_api(
    lua: &Lua,
    graphics: &LuaTable,
    _state: Rc<RefCell<SharedState>>,
) -> LuaResult<()> {
    #[allow(clippy::type_complexity)]
    // -- newQuad --
    /// Creates a Quad defining a rectangular sub-region of a texture for sprite-sheet rendering.
    /// @param | x | number | Left edge in texture pixels.
    /// @param | y | number | Top edge in texture pixels.
    /// @param | w | number | Width in texture pixels.
    /// @param | h | number | Height in texture pixels.
    /// @param | sw | number | Full source texture width.
    /// @param | sh | number | Full source texture height.
    /// @return | LQuad | The created quad.
    graphics.set(
        "newQuad",
        lua.create_function(
            move |_, (x, y, w, h, sw, sh): (f32, f32, f32, f32, f32, f32)| {
                Ok(LuaQuad { x, y, w, h, sw, sh })
            },
        )?,
    )?;
    Ok(())
}
