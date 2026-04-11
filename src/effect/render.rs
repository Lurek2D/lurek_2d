//! Render-command generation for post-processing effects.
//!
//! Converts a [`PostFxStack`] into the `BeginPostFx` / `EndPostFx` /
//! `ApplyPostFx` render commands that bracket scene capture and shader
//! application.  Pure CPU — no wgpu, winit, or mlua.

use crate::effect::stack::PostFxStack;
use crate::render::renderer::RenderCommand;

impl PostFxStack {
    /// Returns the `BeginPostFx` command that starts scene capture.
    ///
    /// After this command, all subsequent draw calls are redirected to
    /// the post-processing capture canvas until [`end_capture_command`]
    /// is emitted.
    ///
    /// # Parameters
    /// - `stack_id` — `u64`. Identifier for the stack in GPU state.
    ///
    /// # Returns
    /// `RenderCommand`.
    pub fn begin_capture_command(&self, stack_id: u64) -> RenderCommand {
        RenderCommand::BeginPostFx { stack_id }
    }

    /// Returns the `EndPostFx` command that stops scene capture.
    ///
    /// # Parameters
    /// - `stack_id` — `u64`. Identifier for the stack in GPU state.
    ///
    /// # Returns
    /// `RenderCommand`.
    pub fn end_capture_command(&self, stack_id: u64) -> RenderCommand {
        RenderCommand::EndPostFx { stack_id }
    }

    /// Returns the `ApplyPostFx` command that applies all enabled effects.
    ///
    /// The GPU renderer will iterate enabled effects in the stack and run
    /// each shader pass through the ping-pong canvas chain.
    ///
    /// # Parameters
    /// - `stack_id` — `u64`. Identifier for the stack in GPU state.
    ///
    /// # Returns
    /// `RenderCommand`.
    pub fn apply_command(&self, stack_id: u64) -> RenderCommand {
        RenderCommand::ApplyPostFx { stack_id }
    }

    /// Returns the full sequence of render commands for the effect stack.
    ///
    /// The returned vec is `[BeginPostFx, EndPostFx, ApplyPostFx]`.
    /// The caller inserts scene draw commands between index 0 and 1.
    ///
    /// # Parameters
    /// - `stack_id` — `u64`. Identifier for the stack in GPU state.
    ///
    /// # Returns
    /// `Vec<RenderCommand>`.
    pub fn generate_render_commands(&self, stack_id: u64) -> Vec<RenderCommand> {
        if self.effects.is_empty() {
            return Vec::new();
        }

        let has_enabled = self.enabled.iter().any(|&e| e);
        if !has_enabled {
            return Vec::new();
        }

        vec![
            self.begin_capture_command(stack_id),
            self.end_capture_command(stack_id),
            self.apply_command(stack_id),
        ]
    }
}

// ── Tests ────────────────────────────────────────────────────────────────────

#[cfg(test)]
mod tests {
    use super::*;
    use crate::effect::stack::PostFxStack;

    #[test]
    fn empty_stack_produces_no_commands() {
        let stack = PostFxStack::new(800, 600);
        let cmds = stack.generate_render_commands(1);
        assert!(cmds.is_empty());
    }

    #[test]
    fn stack_with_disabled_effects_produces_no_commands() {
        let mut stack = PostFxStack::new(800, 600);
        stack.add(0);
        stack.set_enabled(0, false);
        let cmds = stack.generate_render_commands(1);
        assert!(cmds.is_empty());
    }

    #[test]
    fn stack_with_enabled_effects_produces_three_commands() {
        let mut stack = PostFxStack::new(800, 600);
        stack.add(0);
        stack.add(1);
        let cmds = stack.generate_render_commands(1);
        assert_eq!(cmds.len(), 3);
        assert!(matches!(cmds[0], RenderCommand::BeginPostFx { .. }));
        assert!(matches!(cmds[1], RenderCommand::EndPostFx { .. }));
        assert!(matches!(cmds[2], RenderCommand::ApplyPostFx { .. }));
    }

    #[test]
    fn begin_capture_uses_stack_id() {
        let stack = PostFxStack::new(800, 600);
        let cmd = stack.begin_capture_command(42);
        if let RenderCommand::BeginPostFx { stack_id } = cmd {
            assert_eq!(stack_id, 42);
        } else {
            panic!("Expected BeginPostFx");
        }
    }
}
