//! Render-command generation for camera transforms.
//!
//! Converts a [`Camera`] or [`Camera2D`] into transform-stack
//! [`RenderCommand`]s (push/translate/scale/rotate/pop).
//! Pure CPU — no wgpu, winit, or mlua.

use crate::camera::types::{Camera, Camera2D};
use crate::render::renderer::RenderCommand;

impl Camera {
    /// Produces transform-stack render commands for this camera.
    ///
    /// Returns a `PushTransform`, then `Translate` (negate position),
    /// `Rotate`, `Scale` (zoom), ready for the caller to append draw
    /// commands and finish with `PopTransform`.
    ///
    /// The returned vec does **not** include `PopTransform` — the caller
    /// must pair each `begin_render_commands()` with a `PopTransform`
    /// after all scene draw calls.
    ///
    /// # Returns
    /// `Vec<RenderCommand>`.
    pub fn begin_render_commands(&self) -> Vec<RenderCommand> {
        let mut cmds = Vec::with_capacity(4);
        cmds.push(RenderCommand::PushTransform);
        cmds.push(RenderCommand::Translate {
            x: -self.position.x,
            y: -self.position.y,
        });
        if self.rotation.abs() > f32::EPSILON {
            cmds.push(RenderCommand::Rotate {
                angle: self.rotation,
            });
        }
        if (self.zoom - 1.0).abs() > f32::EPSILON {
            cmds.push(RenderCommand::Scale {
                sx: self.zoom,
                sy: self.zoom,
            });
        }
        cmds
    }

    /// Returns the `PopTransform` command that closes the camera scope.
    ///
    /// # Returns
    /// `RenderCommand`.
    pub fn end_render_command() -> RenderCommand {
        RenderCommand::PopTransform
    }

    /// Wrap `scene_commands` in the camera's transform scope.
    ///
    /// Produces `[PushTransform, Translate, (Rotate)?, (Scale)?, ...scene_commands..., PopTransform]`.
    /// Convenience wrapper around `begin_render_commands()` / `end_render_command()`.
    ///
    /// # Parameters
    /// - `scene_commands` — `Vec<RenderCommand>`. Draw calls to wrap.
    ///
    /// # Returns
    /// `Vec<RenderCommand>`.
    pub fn generate_render_commands(
        &self,
        scene_commands: Vec<RenderCommand>,
    ) -> Vec<RenderCommand> {
        let mut cmds = self.begin_render_commands();
        cmds.extend(scene_commands);
        cmds.push(RenderCommand::PopTransform);
        cmds
    }
}

impl Camera2D {
    /// Produces transform-stack render commands for this camera.
    ///
    /// Returns a `PushTransform`, then `Translate` (negate position + shake),
    /// `Rotate`, `Scale` (zoom), ready for the caller to append draw
    /// commands and finish with `PopTransform`.
    ///
    /// # Returns
    /// `Vec<RenderCommand>`.
    pub fn begin_render_commands(&self) -> Vec<RenderCommand> {
        let mut cmds = Vec::with_capacity(4);
        cmds.push(RenderCommand::PushTransform);
        cmds.push(RenderCommand::Translate {
            x: -self.position.x,
            y: -self.position.y,
        });
        if self.rotation.abs() > f32::EPSILON {
            cmds.push(RenderCommand::Rotate {
                angle: self.rotation,
            });
        }
        if (self.zoom - 1.0).abs() > f32::EPSILON {
            cmds.push(RenderCommand::Scale {
                sx: self.zoom,
                sy: self.zoom,
            });
        }
        cmds
    }

    /// Returns the `PopTransform` command that closes the camera scope.
    ///
    /// # Returns
    /// `RenderCommand`.
    pub fn end_render_command() -> RenderCommand {
        RenderCommand::PopTransform
    }

    /// Wrap `scene_commands` in the camera's transform scope.
    ///
    /// Produces `[PushTransform, Translate, (Rotate)?, (Scale)?, ...scene_commands..., PopTransform]`.
    /// Convenience wrapper around `begin_render_commands()` / `end_render_command()`.
    ///
    /// # Parameters
    /// - `scene_commands` — `Vec<RenderCommand>`. Draw calls to wrap.
    ///
    /// # Returns
    /// `Vec<RenderCommand>`.
    pub fn generate_render_commands(
        &self,
        scene_commands: Vec<RenderCommand>,
    ) -> Vec<RenderCommand> {
        let mut cmds = self.begin_render_commands();
        cmds.extend(scene_commands);
        cmds.push(RenderCommand::PopTransform);
        cmds
    }
}
