//! Registers font-atlas text draw operations for the canonical `lurek.render` table.

use super::{active_font_key, queue_draw_text, resolve_font_key, RenderDrawTransform, SharedState};
use mlua::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;

/// Register text draw commands; print and rich-text families extend this module.
pub(super) fn register_text_api(
    lua: &Lua,
    graphics: &LuaTable,
    state: Rc<RefCell<SharedState>>,
) -> LuaResult<()> {
    let s = state.clone();
    // -- drawText --
    /// Draws text using the active font with image-like transform parameters on the GPU.
    /// @param | text | string | Text to render.
    /// @param | x | number | X position.
    /// @param | y | number | Y position.
    /// @param | rotation | number? | Rotation in radians (default 0).
    /// @param | sx | number? | X scale factor (default 1).
    /// @param | sy | number? | Y scale factor (defaults to sx).
    /// @param | ox | number? | Origin offset X in text-local pixels (default 0).
    /// @param | oy | number? | Origin offset Y in text-local pixels (default 0).
    #[allow(clippy::type_complexity)]
    graphics.set(
        "drawText",
        lua.create_function(
            move |_,
                  (text, x, y, rotation, sx, sy, ox, oy): (
                String,
                f32,
                f32,
                Option<f32>,
                Option<f32>,
                Option<f32>,
                Option<f32>,
                Option<f32>,
            )| {
                let font_key = { active_font_key(&s.borrow()) };
                let Some(font_key) = font_key else {
                    return Ok(());
                };
                let sx = sx.unwrap_or(1.0);
                queue_draw_text(
                    &mut s.borrow_mut(),
                    font_key,
                    text,
                    RenderDrawTransform {
                        x,
                        y,
                        rotation: rotation.unwrap_or(0.0),
                        sx,
                        sy: sy.unwrap_or(sx),
                        ox: ox.unwrap_or(0.0),
                        oy: oy.unwrap_or(0.0),
                    },
                );
                Ok(())
            },
        )?,
    )?;
    let s = state.clone();
    // -- drawTextWithFont --
    /// Draws text using a specific font with image-like transform parameters on the GPU.
    /// @param | font | LFont | Font handle to use for this draw.
    /// @param | text | string | Text to render.
    /// @param | x | number | X position.
    /// @param | y | number | Y position.
    /// @param | rotation | number? | Rotation in radians (default 0).
    /// @param | sx | number? | X scale factor (default 1).
    /// @param | sy | number? | Y scale factor (defaults to sx).
    /// @param | ox | number? | Origin offset X in text-local pixels (default 0).
    /// @param | oy | number? | Origin offset Y in text-local pixels (default 0).
    #[allow(clippy::type_complexity)]
    graphics.set(
        "drawTextWithFont",
        lua.create_function(
            move |_,
                  (font_ud, text, x, y, rotation, sx, sy, ox, oy): (
                LuaAnyUserData<'_>,
                String,
                f32,
                f32,
                Option<f32>,
                Option<f32>,
                Option<f32>,
                Option<f32>,
                Option<f32>,
            )| {
                let font_key = resolve_font_key(&font_ud)?;
                let sx = sx.unwrap_or(1.0);
                queue_draw_text(
                    &mut s.borrow_mut(),
                    font_key,
                    text,
                    RenderDrawTransform {
                        x,
                        y,
                        rotation: rotation.unwrap_or(0.0),
                        sx,
                        sy: sy.unwrap_or(sx),
                        ox: ox.unwrap_or(0.0),
                        oy: oy.unwrap_or(0.0),
                    },
                );
                Ok(())
            },
        )?,
    )?;
    Ok(())
}
