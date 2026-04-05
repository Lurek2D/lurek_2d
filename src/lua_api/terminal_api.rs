//! Lua API bindings for the `luna.terminal.*` text-mode terminal emulator.
//!
//! This binding layer uses userdata handles so terminal methods work with
//! idiomatic Lua colon syntax. Widget constructors return detached widget
//! handles that carry their own data and callbacks until `addWidget()`
//! attaches them to a terminal.

use std::cell::RefCell;
use std::collections::HashMap;
use std::rc::{Rc, Weak};

use mlua::prelude::*;

use crate::engine::SharedState;
use crate::graphics::renderer::DrawCommand;
use crate::terminal::{BorderStyle, TCell, Terminal, TerminalEvent, Widget, WidgetKind};

/// Default cell width in pixels for coordinate conversion.
const CELL_W: f32 = 8.0;

/// Default cell height in pixels for coordinate conversion.
const CELL_H: f32 = 14.0;

fn char_count(text: &str) -> usize {
    text.chars().count()
}

fn truncate_chars(text: &str, max_chars: usize) -> String {
    text.chars().take(max_chars).collect()
}

fn usize_from_value(value: Option<LuaValue>) -> usize {
    match value {
        Some(LuaValue::Integer(value)) => value.max(0) as usize,
        Some(LuaValue::Number(value)) => value.max(0.0) as usize,
        _ => 0,
    }
}

fn number_from_value(value: Option<LuaValue>) -> Option<f32> {
    match value {
        Some(LuaValue::Integer(value)) => Some(value as f32),
        Some(LuaValue::Number(value)) => Some(value as f32),
        _ => None,
    }
}

fn runtime_error(method: &str, message: &str) -> LuaError {
    LuaError::RuntimeError(format!("{method}: {message}"))
}

fn wrong_widget_kind(method: &str, expected: &str) -> LuaError {
    runtime_error(method, &format!("expected {expected} widget"))
}

fn wrong_terminal(method: &str) -> LuaError {
    runtime_error(method, "widget is not attached to this terminal")
}

fn widget_handle_from_userdata(userdata: &LuaAnyUserData) -> LuaResult<Rc<RefCell<WidgetBinding>>> {
    let widget = userdata.borrow::<LuaWidget>()?;
    Ok(widget.binding.clone())
}

#[derive(Default)]
struct WidgetCallbacks {
    on_click: Option<LuaRegistryKey>,
    on_change: Option<LuaRegistryKey>,
    on_select: Option<LuaRegistryKey>,
}

enum WidgetAttachment {
    Detached,
    Attached {
        terminal: Rc<TerminalBinding>,
        index: usize,
    },
}

struct WidgetBinding {
    widget: Widget,
    callbacks: WidgetCallbacks,
    pending_children: Vec<Rc<RefCell<WidgetBinding>>>,
    attachment: WidgetAttachment,
}

impl WidgetBinding {
    fn new(widget: Widget) -> Self {
        Self {
            widget,
            callbacks: WidgetCallbacks::default(),
            pending_children: Vec::new(),
            attachment: WidgetAttachment::Detached,
        }
    }
}

struct TerminalBinding {
    terminal: Rc<RefCell<Terminal>>,
    shared_state: Rc<RefCell<SharedState>>,
    widget_handles: RefCell<HashMap<usize, Weak<RefCell<WidgetBinding>>>>,
}

#[derive(Clone)]
struct LuaTerminal {
    binding: Rc<TerminalBinding>,
}

#[derive(Clone)]
struct LuaWidget {
    binding: Rc<RefCell<WidgetBinding>>,
}

enum CallbackKind {
    Click,
    Change,
    Select,
}

fn attached_location(binding: &Rc<RefCell<WidgetBinding>>) -> Option<(Rc<TerminalBinding>, usize)> {
    let binding_ref = binding.borrow();
    match &binding_ref.attachment {
        WidgetAttachment::Attached { terminal, index } => Some((terminal.clone(), *index)),
        WidgetAttachment::Detached => None,
    }
}

fn attached_index_for_terminal(
    binding: &Rc<RefCell<WidgetBinding>>,
    terminal: &Rc<TerminalBinding>,
) -> Option<usize> {
    attached_location(binding).and_then(|(attached_terminal, index)| {
        if Rc::ptr_eq(&attached_terminal, terminal) {
            Some(index)
        } else {
            None
        }
    })
}

fn with_widget<R>(
    binding: &Rc<RefCell<WidgetBinding>>,
    method: &str,
    action: impl FnOnce(&Widget) -> LuaResult<R>,
) -> LuaResult<R> {
    if let Some((terminal, index)) = attached_location(binding) {
        let terminal_ref = terminal.terminal.borrow();
        let widget = terminal_ref
            .get_widget(index)
            .ok_or_else(|| runtime_error(method, "widget handle is stale"))?;
        action(widget)
    } else {
        let binding_ref = binding.borrow();
        action(&binding_ref.widget)
    }
}

fn with_widget_mut<R>(
    binding: &Rc<RefCell<WidgetBinding>>,
    method: &str,
    action: impl FnOnce(&mut Widget) -> LuaResult<R>,
) -> LuaResult<R> {
    if let Some((terminal, index)) = attached_location(binding) {
        let mut terminal_ref = terminal.terminal.borrow_mut();
        let widget = terminal_ref
            .get_widget_mut(index)
            .ok_or_else(|| runtime_error(method, "widget handle is stale"))?;
        action(widget)
    } else {
        let mut binding_ref = binding.borrow_mut();
        action(&mut binding_ref.widget)
    }
}

fn store_callback(
    lua: &Lua,
    slot: &mut Option<LuaRegistryKey>,
    callback: Option<LuaFunction>,
) -> LuaResult<()> {
    *slot = callback
        .map(|func| lua.create_registry_value(func))
        .transpose()?;
    Ok(())
}

fn resolve_callback<'lua>(
    lua: &'lua Lua,
    binding: &Rc<RefCell<WidgetBinding>>,
    kind: CallbackKind,
) -> LuaResult<Option<LuaFunction<'lua>>> {
    let binding_ref = binding.borrow();
    let callback = match kind {
        CallbackKind::Click => binding_ref
            .callbacks
            .on_click
            .as_ref()
            .map(|key| lua.registry_value(key))
            .transpose()?,
        CallbackKind::Change => binding_ref
            .callbacks
            .on_change
            .as_ref()
            .map(|key| lua.registry_value(key))
            .transpose()?,
        CallbackKind::Select => binding_ref
            .callbacks
            .on_select
            .as_ref()
            .map(|key| lua.registry_value(key))
            .transpose()?,
    };
    Ok(callback)
}

fn dispatch_callback(
    lua: &Lua,
    binding: &Rc<RefCell<WidgetBinding>>,
    kind: CallbackKind,
) -> LuaResult<()> {
    if let Some(function) = resolve_callback(lua, binding, kind)? {
        function.call::<_, ()>(())?;
    }
    Ok(())
}

fn widget_handle_for_index(
    terminal: &Rc<TerminalBinding>,
    index: usize,
) -> Option<Rc<RefCell<WidgetBinding>>> {
    let weak = {
        let handles = terminal.widget_handles.borrow();
        handles.get(&index).cloned()
    };
    match weak.and_then(|value| value.upgrade()) {
        Some(handle) => Some(handle),
        None => {
            terminal.widget_handles.borrow_mut().remove(&index);
            None
        }
    }
}

fn sync_binding_snapshot(
    binding: &Rc<RefCell<WidgetBinding>>,
    terminal: &Rc<TerminalBinding>,
    index: usize,
    snapshot: Option<Widget>,
) {
    let mut snapshot = snapshot.or_else(|| terminal.terminal.borrow().get_widget(index).cloned());
    let pending_children = match snapshot.as_ref() {
        Some(Widget {
            kind: WidgetKind::Panel { children },
            ..
        }) => children
            .iter()
            .filter_map(|child_index| widget_handle_for_index(terminal, *child_index))
            .collect(),
        _ => Vec::new(),
    };

    if let Some(widget) = &mut snapshot {
        if let WidgetKind::Panel { children } = &mut widget.kind {
            children.clear();
        }
    }

    let mut binding_ref = binding.borrow_mut();
    if let Some(widget) = snapshot {
        binding_ref.widget = widget;
    }
    binding_ref.pending_children = pending_children;
    binding_ref.attachment = WidgetAttachment::Detached;
}

fn reindex_widget_handles(terminal: &Rc<TerminalBinding>, removed_index: usize) {
    let entries: Vec<(usize, Weak<RefCell<WidgetBinding>>)> = {
        let handles = terminal.widget_handles.borrow();
        handles
            .iter()
            .map(|(index, handle)| (*index, handle.clone()))
            .collect()
    };

    let mut reindexed = HashMap::new();
    for (index, weak) in entries {
        if index == removed_index {
            continue;
        }

        if let Some(handle) = weak.upgrade() {
            if index > removed_index {
                let mut handle_ref = handle.borrow_mut();
                if let WidgetAttachment::Attached {
                    terminal: attached_terminal,
                    index: attached_index,
                } = &mut handle_ref.attachment
                {
                    if Rc::ptr_eq(attached_terminal, terminal) {
                        *attached_index -= 1;
                    }
                }
            }

            let new_index = if index > removed_index {
                index - 1
            } else {
                index
            };
            reindexed.insert(new_index, Rc::downgrade(&handle));
        }
    }

    *terminal.widget_handles.borrow_mut() = reindexed;
}

fn attach_widget(
    terminal: &Rc<TerminalBinding>,
    binding: &Rc<RefCell<WidgetBinding>>,
) -> LuaResult<usize> {
    let (widget, pending_children) = {
        let binding_ref = binding.borrow();
        match &binding_ref.attachment {
            WidgetAttachment::Detached => (
                binding_ref.widget.clone(),
                binding_ref.pending_children.clone(),
            ),
            WidgetAttachment::Attached {
                terminal: attached_terminal,
                index,
            } => {
                if Rc::ptr_eq(attached_terminal, terminal) {
                    return Ok(*index);
                }
                return Err(runtime_error(
                    "Terminal:addWidget",
                    "widget is already attached to another terminal",
                ));
            }
        }
    };

    let index = terminal.terminal.borrow_mut().add_widget(widget);
    terminal
        .widget_handles
        .borrow_mut()
        .insert(index, Rc::downgrade(binding));

    {
        let mut binding_ref = binding.borrow_mut();
        binding_ref.pending_children.clear();
        binding_ref.attachment = WidgetAttachment::Attached {
            terminal: terminal.clone(),
            index,
        };
    }

    for child in pending_children {
        let child_index = attach_widget(terminal, &child)?;
        let _ = terminal
            .terminal
            .borrow_mut()
            .add_panel_child(index, child_index);
    }

    Ok(index)
}

fn remove_attached_widget(
    terminal: &Rc<TerminalBinding>,
    binding: &Rc<RefCell<WidgetBinding>>,
) -> LuaResult<bool> {
    let Some(index) = attached_index_for_terminal(binding, terminal) else {
        return Ok(false);
    };

    let snapshot = terminal.terminal.borrow().get_widget(index).cloned();
    if !terminal.terminal.borrow_mut().remove_widget(index) {
        return Ok(false);
    }

    terminal.widget_handles.borrow_mut().remove(&index);
    sync_binding_snapshot(binding, terminal, index, snapshot);
    reindex_widget_handles(terminal, index);
    Ok(true)
}

fn clear_attached_widgets(terminal: &Rc<TerminalBinding>) {
    let snapshots: Vec<(usize, Rc<RefCell<WidgetBinding>>, Widget)> = {
        let terminal_ref = terminal.terminal.borrow();
        let handles = terminal.widget_handles.borrow();
        handles
            .iter()
            .filter_map(|(index, handle)| {
                handle.upgrade().and_then(|binding| {
                    terminal_ref
                        .get_widget(*index)
                        .cloned()
                        .map(|widget| (*index, binding, widget))
                })
            })
            .collect()
    };

    for (index, binding, widget) in snapshots {
        sync_binding_snapshot(&binding, terminal, index, Some(widget));
    }

    terminal.terminal.borrow_mut().clear_widgets();
    terminal.widget_handles.borrow_mut().clear();
}

fn dispatch_terminal_events(
    lua: &Lua,
    terminal: &Rc<TerminalBinding>,
    events: &[TerminalEvent],
) -> LuaResult<()> {
    for event in events {
        let (index, callback) = match event {
            TerminalEvent::ButtonClicked { index } => (*index, CallbackKind::Click),
            TerminalEvent::TextChanged { index } => (*index, CallbackKind::Change),
            TerminalEvent::SelectionChanged { index } => (*index, CallbackKind::Select),
        };

        if let Some(binding) = widget_handle_for_index(terminal, index) {
            dispatch_callback(lua, &binding, callback)?;
        }
    }
    Ok(())
}

fn build_draw_commands(
    cells: &[TCell],
    cols: usize,
    rows: usize,
    ox: f32,
    oy: f32,
) -> Vec<DrawCommand> {
    let mut commands = Vec::new();

    for row in 0..rows {
        let row_cells = &cells[row * cols..(row + 1) * cols];
        if row_cells.is_empty() {
            continue;
        }

        let mut run_start = 0usize;
        let mut run_color = row_cells[0].fg;
        let mut run_text = String::new();

        let flush_run = |commands: &mut Vec<DrawCommand>,
                         run_start: usize,
                         run_color: [f32; 4],
                         run_text: &mut String| {
            if !run_text.trim().is_empty() {
                commands.push(DrawCommand::SetColor(
                    run_color[0],
                    run_color[1],
                    run_color[2],
                    run_color[3],
                ));
                commands.push(DrawCommand::Print {
                    text: run_text.clone(),
                    x: ox + run_start as f32 * CELL_W,
                    y: oy + row as f32 * CELL_H,
                    scale: 1.0,
                });
            }
            run_text.clear();
        };

        for (col, cell) in row_cells.iter().enumerate() {
            if col > 0 && cell.fg != run_color {
                flush_run(&mut commands, run_start, run_color, &mut run_text);
                run_start = col;
                run_color = cell.fg;
            }

            run_text.push(char::from_u32(cell.ch).unwrap_or(' '));
        }

        flush_run(&mut commands, run_start, run_color, &mut run_text);
    }

    if !commands.is_empty() {
        commands.push(DrawCommand::SetColor(1.0, 1.0, 1.0, 1.0));
    }

    commands
}

impl LuaUserData for LuaTerminal {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        methods.add_method("set", |_, this, args: LuaMultiValue| {
            let mut values = args.into_iter();
            let col = usize_from_value(values.next());
            let row = usize_from_value(values.next());
            let ch = match values.next() {
                Some(LuaValue::String(value)) => {
                    value.to_str()?.chars().next().unwrap_or(' ') as u32
                }
                Some(LuaValue::Integer(value)) => value as u32,
                Some(LuaValue::Number(value)) => value as u32,
                _ => b' ' as u32,
            };

            let mut floats = [1.0_f32, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0];
            for float in &mut floats {
                if let Some(value) = number_from_value(values.next()) {
                    *float = value;
                }
            }

            this.binding.terminal.borrow_mut().set(
                col,
                row,
                ch,
                [floats[0], floats[1], floats[2], floats[3]],
                [floats[4], floats[5], floats[6], floats[7]],
            );
            Ok(())
        });

        methods.add_method("get", |_, this, (col, row): (usize, usize)| {
            let cell = this.binding.terminal.borrow().get(col, row);
            Ok((
                cell.ch, cell.fg[0], cell.fg[1], cell.fg[2], cell.fg[3], cell.bg[0], cell.bg[1],
                cell.bg[2], cell.bg[3],
            ))
        });

        methods.add_method("clear", |_, this, ()| {
            this.binding.terminal.borrow_mut().clear();
            Ok(())
        });

        methods.add_method("getDimensions", |_, this, ()| {
            Ok(this.binding.terminal.borrow().get_dimensions())
        });

        methods.add_method("getCellSize", |_, _this, ()| {
            Ok((CELL_W as f64, CELL_H as f64))
        });

        methods.add_method("addWidget", |_, this, widget_ud: LuaAnyUserData| {
            let widget = widget_handle_from_userdata(&widget_ud)?;
            let _ = attach_widget(&this.binding, &widget)?;
            Ok(())
        });

        methods.add_method("removeWidget", |_, this, widget_ud: LuaAnyUserData| {
            let widget = widget_handle_from_userdata(&widget_ud)?;
            let _ = remove_attached_widget(&this.binding, &widget)?;
            Ok(())
        });

        methods.add_method("clearWidgets", |_, this, ()| {
            clear_attached_widgets(&this.binding);
            Ok(())
        });

        methods.add_method("getWidgetCount", |_, this, ()| {
            Ok(this.binding.terminal.borrow().get_widget_count())
        });

        methods.add_method("setFocus", |_, this, value: LuaValue| match value {
            LuaValue::Nil => {
                this.binding.terminal.borrow_mut().set_focus(None);
                Ok(())
            }
            LuaValue::UserData(userdata) => {
                let widget = widget_handle_from_userdata(&userdata)?;
                let index = attached_index_for_terminal(&widget, &this.binding)
                    .ok_or_else(|| wrong_terminal("Terminal:setFocus"))?;
                this.binding.terminal.borrow_mut().set_focus(Some(index));
                Ok(())
            }
            _ => Err(runtime_error("Terminal:setFocus", "expected widget or nil")),
        });

        methods.add_method("getFocused", |lua: &Lua, this, ()| {
            let focused = this.binding.terminal.borrow().get_focused();
            match focused.and_then(|index| widget_handle_for_index(&this.binding, index)) {
                Some(binding) => Ok(LuaValue::UserData(
                    lua.create_userdata(LuaWidget { binding })?,
                )),
                None => Ok(LuaValue::Nil),
            }
        });

        methods.add_method("keypressed", |lua, this, key: String| {
            let (consumed, events) = this
                .binding
                .terminal
                .borrow_mut()
                .keypressed_with_events(&key);
            dispatch_terminal_events(lua, &this.binding, &events)?;
            Ok(consumed)
        });

        methods.add_method("textinput", |lua, this, text: String| {
            let (consumed, events) = this
                .binding
                .terminal
                .borrow_mut()
                .textinput_with_events(&text);
            dispatch_terminal_events(lua, &this.binding, &events)?;
            Ok(consumed)
        });

        methods.add_method(
            "mousepressed",
            |lua, this, (px, py, button): (f32, f32, Option<usize>)| {
                let col = (px / CELL_W).floor() as usize + 1;
                let row = (py / CELL_H).floor() as usize + 1;
                let (_, events) = this.binding.terminal.borrow_mut().mousepressed_with_events(
                    col,
                    row,
                    button.unwrap_or(1),
                );
                dispatch_terminal_events(lua, &this.binding, &events)?;
                Ok(())
            },
        );

        methods.add_method("draw", |_, this, (x, y): (Option<f32>, Option<f32>)| {
            let ox = x.unwrap_or(0.0);
            let oy = y.unwrap_or(0.0);
            let (cells, cols, rows) = {
                let terminal = this.binding.terminal.borrow();
                (terminal.render_cells(), terminal.cols(), terminal.rows())
            };

            let commands = build_draw_commands(&cells, cols, rows, ox, oy);
            this.binding
                .shared_state
                .borrow_mut()
                .draw_commands
                .extend(commands);
            Ok(())
        });
    }
}

impl LuaUserData for LuaWidget {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        methods.add_method("setPosition", |_, this, (col, row): (usize, usize)| {
            with_widget_mut(&this.binding, "Widget:setPosition", |widget| {
                widget.base.set_position_1based(col, row);
                Ok(())
            })
        });

        methods.add_method("getPosition", |_, this, ()| {
            with_widget(&this.binding, "Widget:getPosition", |widget| {
                Ok(widget.base.position_1based())
            })
        });

        methods.add_method("setSize", |_, this, (width, height): (usize, usize)| {
            with_widget_mut(&this.binding, "Widget:setSize", |widget| {
                widget.base.width = width.max(1);
                widget.base.height = height.max(1);
                Ok(())
            })
        });

        methods.add_method("getSize", |_, this, ()| {
            with_widget(&this.binding, "Widget:getSize", |widget| {
                Ok((widget.base.width, widget.base.height))
            })
        });

        methods.add_method("setVisible", |_, this, visible: bool| {
            with_widget_mut(&this.binding, "Widget:setVisible", |widget| {
                widget.base.visible = visible;
                Ok(())
            })
        });

        methods.add_method("isVisible", |_, this, ()| {
            with_widget(&this.binding, "Widget:isVisible", |widget| {
                Ok(widget.base.visible)
            })
        });

        methods.add_method("setEnabled", |_, this, enabled: bool| {
            with_widget_mut(&this.binding, "Widget:setEnabled", |widget| {
                widget.base.enabled = enabled;
                Ok(())
            })
        });

        methods.add_method("isEnabled", |_, this, ()| {
            with_widget(&this.binding, "Widget:isEnabled", |widget| {
                Ok(widget.base.enabled)
            })
        });

        methods.add_method("setTag", |_, this, tag: String| {
            with_widget_mut(&this.binding, "Widget:setTag", |widget| {
                widget.base.tag = tag;
                Ok(())
            })
        });

        methods.add_method("getTag", |_, this, ()| {
            with_widget(&this.binding, "Widget:getTag", |widget| {
                Ok(widget.base.tag.clone())
            })
        });

        methods.add_method("setText", |lua, this, text: String| {
            let mut trigger_change = false;
            with_widget_mut(
                &this.binding,
                "Widget:setText",
                |widget| match &mut widget.kind {
                    WidgetKind::Label {
                        text: label_text, ..
                    } => {
                        *label_text = text.clone();
                        widget.base.width = char_count(label_text).max(1);
                        Ok(())
                    }
                    WidgetKind::Button { text: button_text } => {
                        *button_text = text.clone();
                        Ok(())
                    }
                    WidgetKind::TextBox {
                        text: text_box_text,
                        max_length,
                        cursor_pos,
                    } => {
                        let new_text = if *max_length > 0 {
                            truncate_chars(&text, *max_length)
                        } else {
                            text.clone()
                        };
                        trigger_change = *text_box_text != new_text;
                        *text_box_text = new_text;
                        *cursor_pos = char_count(text_box_text);
                        Ok(())
                    }
                    _ => Err(wrong_widget_kind(
                        "Widget:setText",
                        "label, button, or text box",
                    )),
                },
            )?;

            if trigger_change {
                dispatch_callback(lua, &this.binding, CallbackKind::Change)?;
            }
            Ok(())
        });

        methods.add_method("getText", |_, this, ()| {
            with_widget(&this.binding, "Widget:getText", |widget| {
                match &widget.kind {
                    WidgetKind::Label { text, .. } => Ok(text.clone()),
                    WidgetKind::Button { text } => Ok(text.clone()),
                    WidgetKind::TextBox { text, .. } => Ok(text.clone()),
                    _ => Err(wrong_widget_kind(
                        "Widget:getText",
                        "label, button, or text box",
                    )),
                }
            })
        });

        methods.add_method(
            "setColor",
            |_, this, (r, g, b, a): (f32, f32, f32, Option<f32>)| {
                let color = [r, g, b, a.unwrap_or(1.0)];
                with_widget_mut(
                    &this.binding,
                    "Widget:setColor",
                    |widget| match &mut widget.kind {
                        WidgetKind::Label {
                            color: label_color, ..
                        } => {
                            *label_color = color;
                            Ok(())
                        }
                        WidgetKind::Border {
                            color: border_color,
                            ..
                        } => {
                            *border_color = color;
                            Ok(())
                        }
                        _ => Err(wrong_widget_kind("Widget:setColor", "label or border")),
                    },
                )
            },
        );

        methods.add_method("getColor", |_, this, ()| {
            with_widget(&this.binding, "Widget:getColor", |widget| {
                match &widget.kind {
                    WidgetKind::Label { color, .. } | WidgetKind::Border { color, .. } => {
                        Ok((color[0], color[1], color[2], color[3]))
                    }
                    _ => Err(wrong_widget_kind("Widget:getColor", "label or border")),
                }
            })
        });

        methods.add_method("setOnClick", |lua, this, callback: Option<LuaFunction>| {
            with_widget(&this.binding, "Widget:setOnClick", |widget| {
                match &widget.kind {
                    WidgetKind::Button { .. } => Ok(()),
                    _ => Err(wrong_widget_kind("Widget:setOnClick", "button")),
                }
            })?;
            let mut binding_ref = this.binding.borrow_mut();
            store_callback(lua, &mut binding_ref.callbacks.on_click, callback)
        });

        methods.add_method("setMaxLength", |_, this, max_length: usize| {
            with_widget_mut(
                &this.binding,
                "Widget:setMaxLength",
                |widget| match &mut widget.kind {
                    WidgetKind::TextBox {
                        text,
                        max_length: current_max,
                        cursor_pos,
                    } => {
                        *current_max = max_length;
                        if *current_max > 0 && char_count(text) > *current_max {
                            *text = truncate_chars(text, *current_max);
                        }
                        *cursor_pos = (*cursor_pos).min(char_count(text));
                        Ok(())
                    }
                    _ => Err(wrong_widget_kind("Widget:setMaxLength", "text box")),
                },
            )
        });

        methods.add_method("getMaxLength", |_, this, ()| {
            with_widget(
                &this.binding,
                "Widget:getMaxLength",
                |widget| match &widget.kind {
                    WidgetKind::TextBox { max_length, .. } => Ok(*max_length),
                    _ => Err(wrong_widget_kind("Widget:getMaxLength", "text box")),
                },
            )
        });

        methods.add_method("setOnChange", |lua, this, callback: Option<LuaFunction>| {
            with_widget(
                &this.binding,
                "Widget:setOnChange",
                |widget| match &widget.kind {
                    WidgetKind::TextBox { .. } => Ok(()),
                    _ => Err(wrong_widget_kind("Widget:setOnChange", "text box")),
                },
            )?;
            let mut binding_ref = this.binding.borrow_mut();
            store_callback(lua, &mut binding_ref.callbacks.on_change, callback)
        });

        methods.add_method("addItem", |_, this, item: String| {
            with_widget_mut(
                &this.binding,
                "Widget:addItem",
                |widget| match &mut widget.kind {
                    WidgetKind::List { items, .. } => {
                        items.push(item);
                        Ok(())
                    }
                    _ => Err(wrong_widget_kind("Widget:addItem", "list")),
                },
            )
        });

        methods.add_method("removeItem", |_, this, index: usize| {
            with_widget_mut(
                &this.binding,
                "Widget:removeItem",
                |widget| match &mut widget.kind {
                    WidgetKind::List {
                        items,
                        selected,
                        scroll_offset,
                    } => {
                        if index >= 1 && index <= items.len() {
                            items.remove(index - 1);
                            if let Some(current) = *selected {
                                if current == index - 1 {
                                    *selected = None;
                                } else if current > index - 1 {
                                    *selected = Some(current - 1);
                                }
                            }
                            if *scroll_offset > items.len().saturating_sub(1) {
                                *scroll_offset = items.len().saturating_sub(1);
                            }
                        }
                        Ok(())
                    }
                    _ => Err(wrong_widget_kind("Widget:removeItem", "list")),
                },
            )
        });

        methods.add_method("clearItems", |_, this, ()| {
            with_widget_mut(
                &this.binding,
                "Widget:clearItems",
                |widget| match &mut widget.kind {
                    WidgetKind::List {
                        items,
                        selected,
                        scroll_offset,
                    } => {
                        items.clear();
                        *selected = None;
                        *scroll_offset = 0;
                        Ok(())
                    }
                    _ => Err(wrong_widget_kind("Widget:clearItems", "list")),
                },
            )
        });

        methods.add_method("getItemCount", |_, this, ()| {
            with_widget(
                &this.binding,
                "Widget:getItemCount",
                |widget| match &widget.kind {
                    WidgetKind::List { items, .. } => Ok(items.len()),
                    _ => Err(wrong_widget_kind("Widget:getItemCount", "list")),
                },
            )
        });

        methods.add_method("getItem", |_, this, index: usize| {
            with_widget(&this.binding, "Widget:getItem", |widget| {
                match &widget.kind {
                    WidgetKind::List { items, .. } => Ok(if index >= 1 && index <= items.len() {
                        items[index - 1].clone()
                    } else {
                        String::new()
                    }),
                    _ => Err(wrong_widget_kind("Widget:getItem", "list")),
                }
            })
        });

        methods.add_method("setSelected", |lua, this, index: Option<usize>| {
            let mut changed = false;
            with_widget_mut(
                &this.binding,
                "Widget:setSelected",
                |widget| match &mut widget.kind {
                    WidgetKind::List {
                        items,
                        selected,
                        scroll_offset,
                    } => {
                        let new_selected = index.and_then(|value| {
                            if value >= 1 && value <= items.len() {
                                Some(value - 1)
                            } else {
                                None
                            }
                        });
                        changed = *selected != new_selected;
                        *selected = new_selected;
                        if let Some(current) = *selected {
                            if current < *scroll_offset {
                                *scroll_offset = current;
                            }
                        }
                        Ok(())
                    }
                    _ => Err(wrong_widget_kind("Widget:setSelected", "list")),
                },
            )?;

            if changed {
                dispatch_callback(lua, &this.binding, CallbackKind::Select)?;
            }
            Ok(())
        });

        methods.add_method("getSelected", |_, this, ()| {
            with_widget(
                &this.binding,
                "Widget:getSelected",
                |widget| match &widget.kind {
                    WidgetKind::List { selected, .. } => Ok(selected.map(|value| value + 1)),
                    _ => Err(wrong_widget_kind("Widget:getSelected", "list")),
                },
            )
        });

        methods.add_method("setOnSelect", |lua, this, callback: Option<LuaFunction>| {
            with_widget(
                &this.binding,
                "Widget:setOnSelect",
                |widget| match &widget.kind {
                    WidgetKind::List { .. } => Ok(()),
                    _ => Err(wrong_widget_kind("Widget:setOnSelect", "list")),
                },
            )?;
            let mut binding_ref = this.binding.borrow_mut();
            store_callback(lua, &mut binding_ref.callbacks.on_select, callback)
        });

        methods.add_method("setStyle", |_, this, style_name: String| {
            let style = BorderStyle::from_str_name(&style_name)
                .ok_or_else(|| runtime_error("Widget:setStyle", "invalid border style"))?;
            with_widget_mut(
                &this.binding,
                "Widget:setStyle",
                |widget| match &mut widget.kind {
                    WidgetKind::Border {
                        style: border_style,
                        ..
                    } => {
                        *border_style = style;
                        Ok(())
                    }
                    _ => Err(wrong_widget_kind("Widget:setStyle", "border")),
                },
            )
        });

        methods.add_method("getStyle", |_, this, ()| {
            with_widget(&this.binding, "Widget:getStyle", |widget| {
                match &widget.kind {
                    WidgetKind::Border { style, .. } => Ok(style.as_str().to_string()),
                    _ => Err(wrong_widget_kind("Widget:getStyle", "border")),
                }
            })
        });

        methods.add_method("setTitle", |_, this, title: String| {
            with_widget_mut(
                &this.binding,
                "Widget:setTitle",
                |widget| match &mut widget.kind {
                    WidgetKind::Border {
                        title: border_title,
                        ..
                    } => {
                        *border_title = title;
                        Ok(())
                    }
                    _ => Err(wrong_widget_kind("Widget:setTitle", "border")),
                },
            )
        });

        methods.add_method("getTitle", |_, this, ()| {
            with_widget(&this.binding, "Widget:getTitle", |widget| {
                match &widget.kind {
                    WidgetKind::Border { title, .. } => Ok(title.clone()),
                    _ => Err(wrong_widget_kind("Widget:getTitle", "border")),
                }
            })
        });

        methods.add_method("addChild", |_, this, child_ud: LuaAnyUserData| {
            with_widget(&this.binding, "Widget:addChild", |widget| {
                match &widget.kind {
                    WidgetKind::Panel { .. } => Ok(()),
                    _ => Err(wrong_widget_kind("Widget:addChild", "panel")),
                }
            })?;

            let child = widget_handle_from_userdata(&child_ud)?;
            if Rc::ptr_eq(&this.binding, &child) {
                return Err(runtime_error("Widget:addChild", "panel cannot add itself"));
            }

            if let Some((terminal, panel_index)) = attached_location(&this.binding) {
                let child_index = match attached_location(&child) {
                    Some((child_terminal, child_index)) => {
                        if !Rc::ptr_eq(&child_terminal, &terminal) {
                            return Err(runtime_error(
                                "Widget:addChild",
                                "child widget is attached to another terminal",
                            ));
                        }
                        child_index
                    }
                    None => attach_widget(&terminal, &child)?,
                };

                let _ = terminal
                    .terminal
                    .borrow_mut()
                    .add_panel_child(panel_index, child_index);
                Ok(())
            } else {
                if attached_location(&child).is_some() {
                    return Err(runtime_error(
                        "Widget:addChild",
                        "cannot add an attached child to a detached panel",
                    ));
                }

                let mut binding_ref = this.binding.borrow_mut();
                if !binding_ref
                    .pending_children
                    .iter()
                    .any(|existing| Rc::ptr_eq(existing, &child))
                {
                    binding_ref.pending_children.push(child);
                }
                Ok(())
            }
        });

        methods.add_method("removeChild", |_, this, child_ud: LuaAnyUserData| {
            with_widget(
                &this.binding,
                "Widget:removeChild",
                |widget| match &widget.kind {
                    WidgetKind::Panel { .. } => Ok(()),
                    _ => Err(wrong_widget_kind("Widget:removeChild", "panel")),
                },
            )?;

            let child = widget_handle_from_userdata(&child_ud)?;
            if let Some((terminal, panel_index)) = attached_location(&this.binding) {
                if let Some(child_index) = attached_index_for_terminal(&child, &terminal) {
                    let _ = terminal
                        .terminal
                        .borrow_mut()
                        .remove_panel_child(panel_index, child_index);
                }
                Ok(())
            } else {
                let mut binding_ref = this.binding.borrow_mut();
                binding_ref
                    .pending_children
                    .retain(|existing| !Rc::ptr_eq(existing, &child));
                Ok(())
            }
        });

        methods.add_method("clearChildren", |_, this, ()| {
            with_widget(
                &this.binding,
                "Widget:clearChildren",
                |widget| match &widget.kind {
                    WidgetKind::Panel { .. } => Ok(()),
                    _ => Err(wrong_widget_kind("Widget:clearChildren", "panel")),
                },
            )?;

            if let Some((terminal, panel_index)) = attached_location(&this.binding) {
                let _ = terminal
                    .terminal
                    .borrow_mut()
                    .clear_panel_children(panel_index);
            } else {
                this.binding.borrow_mut().pending_children.clear();
            }
            Ok(())
        });

        methods.add_method("getChildCount", |_, this, ()| {
            with_widget(
                &this.binding,
                "Widget:getChildCount",
                |widget| match &widget.kind {
                    WidgetKind::Panel { .. } => Ok(()),
                    _ => Err(wrong_widget_kind("Widget:getChildCount", "panel")),
                },
            )?;

            if let Some((terminal, panel_index)) = attached_location(&this.binding) {
                with_widget(&this.binding, "Widget:getChildCount", |_| {
                    let terminal_ref = terminal.terminal.borrow();
                    match terminal_ref.get_widget(panel_index) {
                        Some(Widget {
                            kind: WidgetKind::Panel { children },
                            ..
                        }) => Ok(children.len()),
                        _ => Err(wrong_widget_kind("Widget:getChildCount", "panel")),
                    }
                })
            } else {
                Ok(this.binding.borrow().pending_children.len())
            }
        });

        methods.add_method("getChild", |lua: &Lua, this, index: usize| {
            with_widget(&this.binding, "Widget:getChild", |widget| {
                match &widget.kind {
                    WidgetKind::Panel { .. } => Ok(()),
                    _ => Err(wrong_widget_kind("Widget:getChild", "panel")),
                }
            })?;

            if index == 0 {
                return Ok(LuaValue::Nil);
            }

            if let Some((terminal, panel_index)) = attached_location(&this.binding) {
                let child_handle = {
                    let terminal_ref = terminal.terminal.borrow();
                    match terminal_ref.get_widget(panel_index) {
                        Some(Widget {
                            kind: WidgetKind::Panel { children },
                            ..
                        }) if index <= children.len() => {
                            widget_handle_for_index(&terminal, children[index - 1])
                        }
                        _ => None,
                    }
                };

                match child_handle {
                    Some(binding) => Ok(LuaValue::UserData(
                        lua.create_userdata(LuaWidget { binding })?,
                    )),
                    None => Ok(LuaValue::Nil),
                }
            } else {
                let child = this
                    .binding
                    .borrow()
                    .pending_children
                    .get(index - 1)
                    .cloned();
                match child {
                    Some(binding) => Ok(LuaValue::UserData(
                        lua.create_userdata(LuaWidget { binding })?,
                    )),
                    None => Ok(LuaValue::Nil),
                }
            }
        });
    }
}

/// Register the `luna.terminal` namespace on the `luna` table.
///
/// # Parameters
/// - `lua` — `&Lua`.
/// - `luna` — `&LuaTable`.
/// - `state` — `Rc<RefCell<SharedState>>`.
///
/// # Returns
/// `LuaResult<()>`.
pub fn register(lua: &Lua, luna: &LuaTable, state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let terminal_ns = lua.create_table()?;

    {
        let state = state.clone();
        terminal_ns.set(
            "newTerminal",
            lua.create_function(move |lua, (cols, rows): (Option<usize>, Option<usize>)| {
                let binding = Rc::new(TerminalBinding {
                    terminal: Rc::new(RefCell::new(Terminal::new(
                        cols.unwrap_or(80),
                        rows.unwrap_or(40),
                    ))),
                    shared_state: state.clone(),
                    widget_handles: RefCell::new(HashMap::new()),
                });
                lua.create_userdata(LuaTerminal { binding })
            })?,
        )?;
    }

    terminal_ns.set(
        "newLabel",
        lua.create_function(
            move |lua, (col, row, text): (usize, usize, Option<String>)| {
                let binding = Rc::new(RefCell::new(WidgetBinding::new(Widget::new_label(
                    col,
                    row,
                    text.unwrap_or_default(),
                ))));
                lua.create_userdata(LuaWidget { binding })
            },
        )?,
    )?;

    terminal_ns.set(
        "newButton",
        lua.create_function(
            move |lua,
                  (col, row, width, height, text): (
                usize,
                usize,
                usize,
                Option<usize>,
                Option<String>,
            )| {
                let binding = Rc::new(RefCell::new(WidgetBinding::new(Widget::new_button(
                    col,
                    row,
                    width,
                    height.unwrap_or(1),
                    text.unwrap_or_default(),
                ))));
                lua.create_userdata(LuaWidget { binding })
            },
        )?,
    )?;

    terminal_ns.set(
        "newTextBox",
        lua.create_function(move |lua, (col, row, width): (usize, usize, usize)| {
            let binding = Rc::new(RefCell::new(WidgetBinding::new(Widget::new_text_box(
                col, row, width,
            ))));
            lua.create_userdata(LuaWidget { binding })
        })?,
    )?;

    terminal_ns.set(
        "newList",
        lua.create_function(
            move |lua, (col, row, width, height): (usize, usize, usize, usize)| {
                let binding = Rc::new(RefCell::new(WidgetBinding::new(Widget::new_list(
                    col, row, width, height,
                ))));
                lua.create_userdata(LuaWidget { binding })
            },
        )?,
    )?;

    terminal_ns.set(
        "newBorder",
        lua.create_function(
            move |lua, (col, row, width, height): (usize, usize, usize, usize)| {
                let binding = Rc::new(RefCell::new(WidgetBinding::new(Widget::new_border(
                    col, row, width, height,
                ))));
                lua.create_userdata(LuaWidget { binding })
            },
        )?,
    )?;

    terminal_ns.set(
        "newPanel",
        lua.create_function(
            move |lua, (col, row, width, height): (usize, usize, Option<usize>, Option<usize>)| {
                let binding = Rc::new(RefCell::new(WidgetBinding::new(Widget::new_panel(
                    col,
                    row,
                    width.unwrap_or(1),
                    height.unwrap_or(1),
                ))));
                lua.create_userdata(LuaWidget { binding })
            },
        )?,
    )?;

    luna.set("terminal", terminal_ns)?;
    Ok(())
}
