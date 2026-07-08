//! Owns the staged command queue that turns chosen intent into ordered executable actions with interruption rules.
//! Defines command payloads with targets, priority, callbacks, and interruptibility, then stores them in FIFO order.
//! Provides enqueue, push-front, replace, cancel, and advance helpers so reactive overrides stay explicit and safe.
//! Acts as the execution boundary between decision layers that choose commands and runtime code that consumes them.
//! Open this owner when command ordering, cancellation, or raw-command construction semantics must change.

use crate::log_msg;
use crate::runtime::log_messages::{CQ01, CQ02, CQ03};
use mlua::RegistryKey;
use std::collections::VecDeque;

/// Immutable view of one queued command exposed to diagnostics, tests, and Lua wrappers.
#[derive(Debug, Clone, PartialEq)]
pub struct CommandSnapshot {
    /// Stable command id assigned by the owning queue.
    pub id: u64,
    /// String tag identifying the action type, e.g. `"move"` or `"attack"`.
    pub kind: String,
    /// Optional caller-owned order tag for grouping and cancellation.
    pub tag: Option<String>,
    /// World-space X target coordinate in pixels.
    pub target_x: f32,
    /// World-space Y target coordinate in pixels.
    pub target_y: f32,
    /// Scheduling priority; higher values are processed before lower ones.
    pub priority: i32,
    /// Whether this command can be cancelled while current.
    pub interruptible: bool,
}

/// Lifecycle event emitted by a command queue when commands are added, removed, or completed.
#[derive(Debug, Clone, PartialEq)]
pub struct CommandEvent {
    /// Stable id of the command that triggered this event.
    pub command_id: u64,
    /// String tag identifying the command type.
    pub kind: String,
    /// Optional caller-owned order tag for grouping and cancellation.
    pub tag: Option<String>,
    /// Lifecycle event label such as `"enqueued"` or `"completed"`.
    pub event: String,
    /// World-space X target coordinate in pixels.
    pub target_x: f32,
    /// World-space Y target coordinate in pixels.
    pub target_y: f32,
    /// Scheduling priority associated with the command at emit time.
    pub priority: i32,
    /// Whether this command was interruptible when the event was emitted.
    pub interruptible: bool,
    /// Optional detail string describing why the lifecycle transition occurred.
    pub detail: Option<String>,
}

/// Pending AI action with target data and an optional completion callback.
pub struct Command {
    /// Stable command id. A value of `0` means the queue should assign the next id.
    pub id: u64,
    /// String tag identifying the action type, e.g. `"move"` or `"attack"`.
    pub kind: String,
    /// Optional caller-owned order tag for grouping and cancellation.
    pub tag: Option<String>,
    /// Optional registry key of the Lua callback invoked when this command completes.
    pub callback: Option<RegistryKey>,
    /// World-space X target coordinate in pixels.
    pub target_x: f32,
    /// World-space Y target coordinate in pixels.
    pub target_y: f32,
    /// Scheduling priority; higher values are processed before lower ones.
    pub priority: i32,
    /// Whether this command can be cancelled by `cancel_current`.
    pub interruptible: bool,
}
/// FIFO queue of pending AI commands for one actor.
pub struct CommandQueue {
    /// FIFO storage of pending commands.
    pub(crate) commands: VecDeque<Command>,
    /// Ordered lifecycle events waiting to be observed by higher-level systems.
    pub(crate) events: VecDeque<CommandEvent>,
    /// Next stable command id assigned by this queue.
    pub(crate) next_command_id: u64,
}
impl CommandQueue {
    /// Create an empty queue. This function is part of the public API.
    pub fn new() -> Self {
        log_msg!(debug, CQ01);
        Self {
            commands: VecDeque::new(),
            events: VecDeque::new(),
            next_command_id: 1,
        }
    }
    /// Append `cmd` to the back of the queue.
    pub fn enqueue(&mut self, mut cmd: Command) -> u64 {
        log_msg!(debug, CQ02);
        self.assign_command_id(&mut cmd);
        let id = cmd.id;
        self.push_event_for(&cmd, "enqueued", None);
        self.commands.push_back(cmd);
        id
    }
    /// Insert `cmd` at the front, making it the next command to execute.
    pub fn push_front(&mut self, mut cmd: Command) -> u64 {
        self.assign_command_id(&mut cmd);
        let id = cmd.id;
        self.push_event_for(&cmd, "pushed_front", None);
        self.commands.push_front(cmd);
        id
    }
    /// Clear the entire queue and enqueue `cmd` as the sole pending command.
    pub fn replace(&mut self, mut cmd: Command) -> u64 {
        self.clear_with_reason(Some("replaced".to_string()));
        self.assign_command_id(&mut cmd);
        let id = cmd.id;
        self.push_event_for(&cmd, "replaced", None);
        self.commands.push_back(cmd);
        id
    }
    /// Pop the front command if it is interruptible; return `true` on success.
    pub fn cancel_current(&mut self) -> bool {
        self.cancel_current_with_reason(None)
    }
    /// Pop the front command if it is interruptible, recording an optional reason.
    pub fn cancel_current_with_reason(&mut self, detail: Option<String>) -> bool {
        if let Some(front) = self.commands.front() {
            if front.interruptible {
                if let Some(cmd) = self.commands.pop_front() {
                    self.push_event_for(&cmd, "cancelled", detail);
                }
                return true;
            }
        }
        false
    }
    /// Discard all queued commands.
    pub fn clear(&mut self) -> usize {
        self.clear_with_reason(None)
    }
    /// Discard all queued commands, recording an optional clear reason.
    pub fn clear_with_reason(&mut self, detail: Option<String>) -> usize {
        let count = self.commands.len();
        while let Some(cmd) = self.commands.pop_front() {
            self.push_event_for(&cmd, "cleared", detail.clone());
        }
        log_msg!(debug, CQ03, "{}", count);
        count
    }
    /// Return the number of pending commands.
    pub fn count(&self) -> usize {
        self.commands.len()
    }
    /// Return `true` when the queue has no pending commands.
    pub fn is_empty(&self) -> bool {
        self.commands.is_empty()
    }
    /// Return the `kind` tag of the front command, or `None` if the queue is empty.
    pub fn current_type(&self) -> Option<&str> {
        self.commands.front().map(|c| c.kind.as_str())
    }
    /// Return the stable id of the front command, or `None` if the queue is empty.
    pub fn current_id(&self) -> Option<u64> {
        self.commands.front().map(|c| c.id)
    }
    /// Return the `(target_x, target_y)` of the front command; returns `(0, 0)` if empty.
    pub fn current_target(&self) -> (f32, f32) {
        self.commands
            .front()
            .map(|c| (c.target_x, c.target_y))
            .unwrap_or((0.0, 0.0))
    }
    /// Return a snapshot of the front command, or `None` if the queue is empty.
    pub fn current(&self) -> Option<CommandSnapshot> {
        self.commands.front().map(Command::snapshot)
    }
    /// Return snapshots of every pending command in queue order.
    pub fn pending(&self) -> Vec<CommandSnapshot> {
        self.commands.iter().map(Command::snapshot).collect()
    }
    /// Remove all commands whose order tag or kind matches `tag`, returning the number removed.
    pub fn cancel_by_tag(&mut self, tag: &str) -> usize {
        let mut kept = VecDeque::new();
        let mut removed = 0;
        while let Some(cmd) = self.commands.pop_front() {
            if cmd.tag.as_deref() == Some(tag) || cmd.kind == tag {
                removed += 1;
                self.push_event_for(&cmd, "cancelled", Some(format!("tag:{tag}")));
            } else {
                kept.push_back(cmd);
            }
        }
        self.commands = kept;
        removed
    }
    /// Remove the front command as completed and expose the next one.
    pub fn advance(&mut self) -> Option<u64> {
        self.complete_current(None)
    }
    /// Remove the front command as completed, recording an optional detail string.
    pub fn complete_current(&mut self, detail: Option<String>) -> Option<u64> {
        let cmd = self.commands.pop_front()?;
        let id = cmd.id;
        self.push_event_for(&cmd, "completed", detail);
        Some(id)
    }
    /// Remove the front command as failed, recording an optional detail string.
    pub fn fail_current(&mut self, detail: Option<String>) -> bool {
        if let Some(cmd) = self.commands.pop_front() {
            self.push_event_for(&cmd, "failed", detail);
            true
        } else {
            false
        }
    }
    /// Return all pending lifecycle events and clear the queue's event buffer.
    pub fn drain_events(&mut self) -> Vec<CommandEvent> {
        self.events.drain(..).collect()
    }
    /// Record one lifecycle event against an existing command snapshot without mutating queue order.
    pub fn push_snapshot_event(
        &mut self,
        snapshot: &CommandSnapshot,
        event: &str,
        detail: Option<String>,
    ) {
        self.events.push_back(CommandEvent {
            command_id: snapshot.id,
            kind: snapshot.kind.clone(),
            tag: snapshot.tag.clone(),
            event: event.to_string(),
            target_x: snapshot.target_x,
            target_y: snapshot.target_y,
            priority: snapshot.priority,
            interruptible: snapshot.interruptible,
            detail,
        });
    }
    /// Build a `Command` from raw parts and append it to the back of the queue.
    pub fn enqueue_raw(
        &mut self,
        kind: String,
        tx: f32,
        ty: f32,
        priority: i32,
        interruptible: bool,
        callback: Option<RegistryKey>,
    ) -> u64 {
        self.enqueue(Command {
            id: 0,
            kind,
            tag: None,
            target_x: tx,
            target_y: ty,
            priority,
            interruptible,
            callback,
        })
    }
    /// Build a `Command` from raw parts and insert it at the front of the queue.
    pub fn push_front_raw(
        &mut self,
        kind: String,
        tx: f32,
        ty: f32,
        priority: i32,
        interruptible: bool,
        callback: Option<RegistryKey>,
    ) -> u64 {
        self.push_front(Command {
            id: 0,
            kind,
            tag: None,
            target_x: tx,
            target_y: ty,
            priority,
            interruptible,
            callback,
        })
    }
    /// Build a `Command` from raw parts, clear the queue, and set it as the only entry.
    pub fn replace_raw(
        &mut self,
        kind: String,
        tx: f32,
        ty: f32,
        priority: i32,
        interruptible: bool,
        callback: Option<RegistryKey>,
    ) -> u64 {
        self.replace(Command {
            id: 0,
            kind,
            tag: None,
            target_x: tx,
            target_y: ty,
            priority,
            interruptible,
            callback,
        })
    }

    fn assign_command_id(&mut self, cmd: &mut Command) {
        if cmd.id == 0 {
            cmd.id = self.next_command_id;
            self.next_command_id = self.next_command_id.saturating_add(1);
        } else if cmd.id >= self.next_command_id {
            self.next_command_id = cmd.id.saturating_add(1);
        }
    }

    fn push_event_for(&mut self, cmd: &Command, event: &str, detail: Option<String>) {
        self.events.push_back(CommandEvent {
            command_id: cmd.id,
            kind: cmd.kind.clone(),
            tag: cmd.tag.clone(),
            event: event.to_string(),
            target_x: cmd.target_x,
            target_y: cmd.target_y,
            priority: cmd.priority,
            interruptible: cmd.interruptible,
            detail,
        });
    }
}
/// `Default` delegates to `CommandQueue::new`.
impl Default for CommandQueue {
    /// `Default` delegates to `CommandQueue::new`.
    fn default() -> Self {
        Self::new()
    }
}

impl Command {
    /// Return a copyable snapshot that omits the Lua registry key and can be shared safely.
    pub fn snapshot(&self) -> CommandSnapshot {
        CommandSnapshot {
            id: self.id,
            kind: self.kind.clone(),
            tag: self.tag.clone(),
            target_x: self.target_x,
            target_y: self.target_y,
            priority: self.priority,
            interruptible: self.interruptible,
        }
    }
}
