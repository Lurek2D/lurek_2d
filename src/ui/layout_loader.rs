//! Owns ui behavior with explicit state, validation, and crate-local integration boundaries. for engine changes.
//! Centers the implementation around DialogActionDef, WidgetDef, LayoutDef, with helpers kept close to their invariants.
//! Defines how layout loader data is validated, transformed, or stored before neighboring systems use it.
//! Owns ui behavior with explicit state, validation, and crate-local integration boundaries. for engine changes.
//! Keeps public crate helpers focused on layout loader behavior while Lua registration stays elsewhere.
//! Documents the boundary where ui code accepts inputs, reports errors, or updates state while keeping call sites explicit.
//! Use this file when changing layout loader defaults, lifecycle handling, validation, or data ownership.
//! Keeps failure paths and edge cases near the ui state that can explain them while keeping call sites explicit.
//! Preserves deterministic behavior by keeping layout loader calculations explicit at their owner boundary.

use crate::ui::context::{GuiContext, WidgetKind};
use crate::ui::extras::{DialogAction, DialogActionRole, PropertyRow, PropertyValueKind};
use crate::ui::widget::TextVAlign;
use serde::Deserialize;
use std::collections::{HashMap, HashSet};
use std::path::{Component, Path};
#[derive(Debug, Clone, Deserialize, Default)]
/// Declarative dialog footer action loaded from TOML or Lua layout definitions.
pub struct DialogActionDef {
    /// Button label displayed for this action.
    pub text: String,
    /// Semantic role such as `default`, `cancel`, or `custom`.
    pub role: Option<String>,
    /// Whether activating the action should close the dialog.
    pub close_on_activate: Option<bool>,
}
/// Declarative property row loaded into a `PropertyWidget`.
#[derive(Debug, Clone, Deserialize, Default)]
pub struct PropertyRowDef {
    /// Stable property name shown in the left column.
    pub name: String,
    /// Stringified property value shown in the right column.
    pub value: Option<String>,
    /// Editor kind: `text`, `number`, `bool`, `select`, `color`, or compatible widget aliases.
    pub value_type: Option<String>,
    /// Select options for `value_type = "select"`.
    pub options: Option<Vec<String>>,
    /// Whether this property is displayed as read-only.
    pub read_only: Option<bool>,
}
/// Declarative collapsible property group loaded into a `PropertyWidget`.
#[derive(Debug, Clone, Deserialize, Default)]
pub struct PropertyGroupDef {
    /// Group title shown in the header.
    pub title: String,
    /// Whether rows start hidden.
    pub collapsed: Option<bool>,
    /// Ordered property rows.
    pub rows: Option<Vec<PropertyRowDef>>,
}
/// Flat description of a single widget produced by TOML deserialisation; children are nested inline.
#[derive(Debug, Clone, Deserialize, Default)]
pub struct WidgetDef {
    /// Widget type name string (e.g. `"button"`, `"label"`, `"panel"`).
    pub widget_type: String,
    /// Optional identifier assigned to `WidgetBase::id`.
    pub id: Option<String>,
    /// X pixel position passed to `WidgetBase::x`.
    pub x: Option<f32>,
    /// Y pixel position passed to `WidgetBase::y`.
    pub y: Option<f32>,
    /// Pixel width passed to `WidgetBase::width`.
    pub w: Option<f32>,
    /// Pixel height passed to `WidgetBase::height`.
    pub h: Option<f32>,
    /// Primary text value for buttons, labels, checkboxes, etc.
    pub text: Option<String>,
    /// Minimum value for sliders, progress bars, and spin boxes.
    pub min: Option<f64>,
    /// Maximum value for sliders, progress bars, and spin boxes.
    pub max: Option<f64>,
    /// Initial numeric value for sliders, progress bars, spin boxes, and badge counts.
    pub value: Option<f64>,
    /// Initial checked state for checkboxes.
    pub checked: Option<bool>,
    /// Initial `on` state for switches.
    pub on: Option<bool>,
    /// Initial `WidgetBase::visible` state.
    pub visible: Option<bool>,
    /// Initial `WidgetBase::enabled` state.
    pub enabled: Option<bool>,
    /// Placeholder text for text-input widgets.
    pub placeholder: Option<String>,
    /// Whether Enter on a focused text input should submit the surrounding dialog.
    pub submit_on_enter: Option<bool>,
    /// Hover tooltip text.
    pub tooltip: Option<String>,
    /// Optional built-in icon name assigned to the widget.
    pub icon: Option<String>,
    /// Icon placement relative to text: `left`, `right`, `top`, `bottom`, or `only`.
    pub icon_position: Option<String>,
    /// Requested icon size in pixels; `0` means use the widget font size.
    pub icon_size: Option<f32>,
    /// Inner padding `[top, right, bottom, left]` in pixels.
    pub padding: Option<[f32; 4]>,
    /// Outer margin `[top, right, bottom, left]` in pixels.
    pub margin: Option<[f32; 4]>,
    /// Horizontal text alignment: `"left"`, `"center"`, or `"right"`.
    pub text_align: Option<String>,
    /// Vertical text alignment: `"top"`, `"middle"`, or `"bottom"`.
    pub text_v_align: Option<String>,
    /// Whether text wraps inside the widget.
    pub text_wrap: Option<bool>,
    /// Whether single-line overflowing text is clipped with ellipsis.
    pub text_ellipsis: Option<bool>,
    /// Flex growth factor used by flex-like layout containers.
    pub flex_grow: Option<f32>,
    /// Flex shrink factor used by flex-like layout containers.
    pub flex_shrink: Option<f32>,
    /// Layout direction string (`"horizontal"` / `"vertical"`) for layout and split panels.
    pub direction: Option<String>,
    /// Item spacing in pixels for layout widgets.
    pub spacing: Option<f32>,
    /// Cross-axis alignment token for layout widgets.
    pub align: Option<String>,
    /// Main-axis justification token for layout widgets.
    pub justify: Option<String>,
    /// Grid column count for layout widgets using `direction = "grid"`.
    pub columns: Option<usize>,
    /// Whether layout children wrap when they exceed available space.
    pub wrap: Option<bool>,
    /// Active page index for stack and tab containers; one-based to match Lua.
    pub active_index: Option<usize>,
    /// Optional tab labels for tab container definitions.
    pub tabs: Option<Vec<String>>,
    /// Height reserved for a tab container tab strip.
    pub tab_bar_height: Option<f32>,
    /// Maximum number of visible rows in combo-box dropdowns before scrolling.
    pub max_visible_items: Option<usize>,
    /// Orientation string (`"horizontal"` / `"vertical"`) for separators, scroll bars, etc.
    pub orientation: Option<String>,
    /// Radio-button group identifier.
    pub group: Option<String>,
    /// Dialog/window modal and popup flags.
    pub modal: Option<bool>,
    pub open: Option<bool>,
    pub closeable: Option<bool>,
    pub draggable: Option<bool>,
    pub resizable: Option<bool>,
    pub dismiss_on_outside_click: Option<bool>,
    pub center_on_open: Option<bool>,
    pub min_size: Option<[f32; 2]>,
    pub max_size: Option<[f32; 2]>,
    pub slot: Option<String>,
    pub actions: Option<Vec<DialogActionDef>>,
    /// Property groups for `propertywidget` definitions.
    pub property_groups: Option<Vec<PropertyGroupDef>>,
    /// Left label column width for `propertywidget`.
    pub property_label_width: Option<f32>,
    /// Row height for `propertywidget`.
    pub property_row_height: Option<f32>,
    /// Group header height for `propertywidget`.
    pub property_group_header_height: Option<f32>,
    /// Nested child widget definitions; loaded recursively by `load_layout_def`.
    pub children: Option<Vec<WidgetDef>>,
}
/// Top-level TOML layout definition containing an optional resolution hint and the root widget tree.
#[derive(Debug, Deserialize)]
pub struct LayoutDef {
    /// Optional `[width, height]` target resolution for layout and `render_to_image`.
    pub resolution: Option<[u32; 2]>,
    /// Root widget definition; all descendants are nested under `children`.
    pub root: WidgetDef,
}
/// Recursively instantiate `def` and all its `children` into `ctx`; return the root widget index or an error string.
pub fn load_layout_def(ctx: &mut GuiContext, def: &WidgetDef) -> Result<usize, String> {
    let idx = load_layout_def_inner(ctx, def)?;
    let errors = validate_loaded_subtree(ctx, idx);
    if !errors.is_empty() {
        return Err(format!(
            "layout tree validation failed: {}",
            errors.join("; ")
        ));
    }
    Ok(idx)
}

fn subtree_children(ctx: &GuiContext, idx: usize) -> Vec<usize> {
    let mut out = ctx
        .widgets
        .get(idx)
        .and_then(|widget| widget.children())
        .cloned()
        .unwrap_or_default();
    if let Some(WidgetKind::Dialog(dialog)) = ctx.widgets.get(idx) {
        if let Some(child_idx) = dialog.content_idx {
            if !out.contains(&child_idx) {
                out.push(child_idx);
            }
        }
        if let Some(child_idx) = dialog.footer_idx {
            if !out.contains(&child_idx) {
                out.push(child_idx);
            }
        }
    }
    if let Some(WidgetKind::SplitPanel(split)) = ctx.widgets.get(idx) {
        if let Some(child_idx) = split.first_child {
            if !out.contains(&child_idx) {
                out.push(child_idx);
            }
        }
        if let Some(child_idx) = split.second_child {
            if !out.contains(&child_idx) {
                out.push(child_idx);
            }
        }
    }
    out
}

fn validate_loaded_subtree(ctx: &GuiContext, root_idx: usize) -> Vec<String> {
    fn visit(
        ctx: &GuiContext,
        idx: usize,
        visited: &mut HashSet<usize>,
        stack: &mut HashSet<usize>,
        parent_counts: &mut HashMap<usize, usize>,
        errors: &mut Vec<String>,
    ) {
        if idx >= ctx.widgets.len() {
            errors.push(format!("widget {idx} is out of range"));
            return;
        }
        if !stack.insert(idx) {
            errors.push(format!("cycle detected at widget {idx}"));
            return;
        }
        visited.insert(idx);
        let mut seen_children = HashSet::new();
        for child_idx in subtree_children(ctx, idx) {
            if child_idx >= ctx.widgets.len() {
                errors.push(format!("widget {idx} references invalid child {child_idx}"));
                continue;
            }
            if !seen_children.insert(child_idx) {
                errors.push(format!(
                    "widget {idx} references child {child_idx} more than once"
                ));
                continue;
            }
            *parent_counts.entry(child_idx).or_insert(0) += 1;
            if parent_counts[&child_idx] > 1 {
                errors.push(format!("widget {child_idx} has multiple parents"));
            }
            if !visited.contains(&child_idx) {
                visit(ctx, child_idx, visited, stack, parent_counts, errors);
            } else if stack.contains(&child_idx) {
                errors.push(format!("cycle detected at widget {child_idx}"));
            }
        }
        stack.remove(&idx);
    }

    let mut visited = HashSet::new();
    let mut stack = HashSet::new();
    let mut parent_counts = HashMap::new();
    let mut errors = Vec::new();
    visit(
        ctx,
        root_idx,
        &mut visited,
        &mut stack,
        &mut parent_counts,
        &mut errors,
    );
    errors
}

fn load_layout_def_inner(ctx: &mut GuiContext, def: &WidgetDef) -> Result<usize, String> {
    let idx = create_from_def(ctx, def)?;
    if let Some(children) = &def.children {
        for child_def in children {
            let child_idx = load_layout_def_inner(ctx, child_def)?;
            match child_def.slot.as_deref() {
                Some("content") => match ctx.widgets.get_mut(idx) {
                    Some(WidgetKind::Dialog(dialog)) => {
                        if dialog.content_idx.replace(child_idx).is_some() {
                            return Err(format!(
                                "dialog \"{}\" defines more than one content slot child",
                                def.id.as_deref().unwrap_or(&def.widget_type)
                            ));
                        }
                    }
                    _ => {
                        return Err(format!(
                            "slot=\"content\" is only supported for dialog children (parent: {})",
                            def.widget_type
                        ))
                    }
                },
                Some("footer") => match ctx.widgets.get_mut(idx) {
                    Some(WidgetKind::Dialog(dialog)) => {
                        if dialog.footer_idx.replace(child_idx).is_some() {
                            return Err(format!(
                                "dialog \"{}\" defines more than one footer slot child",
                                def.id.as_deref().unwrap_or(&def.widget_type)
                            ));
                        }
                    }
                    _ => {
                        return Err(format!(
                            "slot=\"footer\" is only supported for dialog children (parent: {})",
                            def.widget_type
                        ))
                    }
                },
                Some("first") | Some("left") | Some("top") => match ctx.widgets.get_mut(idx) {
                    Some(WidgetKind::SplitPanel(split)) => {
                        if split.first_child.replace(child_idx).is_some() {
                            return Err(format!(
                                "split panel \"{}\" defines more than one first slot child",
                                def.id.as_deref().unwrap_or(&def.widget_type)
                            ));
                        }
                    }
                    _ => {
                        return Err(format!(
                            "slot=\"{}\" is only supported for split panel children (parent: {})",
                            child_def.slot.as_deref().unwrap_or_default(),
                            def.widget_type
                        ))
                    }
                },
                Some("second") | Some("right") | Some("bottom") => match ctx.widgets.get_mut(idx) {
                    Some(WidgetKind::SplitPanel(split)) => {
                        if split.second_child.replace(child_idx).is_some() {
                            return Err(format!(
                                "split panel \"{}\" defines more than one second slot child",
                                def.id.as_deref().unwrap_or(&def.widget_type)
                            ));
                        }
                    }
                    _ => {
                        return Err(format!(
                            "slot=\"{}\" is only supported for split panel children (parent: {})",
                            child_def.slot.as_deref().unwrap_or_default(),
                            def.widget_type
                        ))
                    }
                },
                Some(other) => {
                    return Err(format!(
                        "unsupported slot value \"{other}\" for child of {}",
                        def.widget_type
                    ))
                }
                None => {
                    let attached_to_split_slot = match ctx.widgets.get_mut(idx) {
                        Some(WidgetKind::SplitPanel(split)) if split.first_child.is_none() => {
                            split.first_child = Some(child_idx);
                            true
                        }
                        Some(WidgetKind::SplitPanel(split)) if split.second_child.is_none() => {
                            split.second_child = Some(child_idx);
                            true
                        }
                        Some(WidgetKind::SplitPanel(_)) => {
                            return Err(format!(
                                "split panel \"{}\" has more than two child widgets",
                                def.id.as_deref().unwrap_or(&def.widget_type)
                            ));
                        }
                        _ => false,
                    };
                    if !attached_to_split_slot && !ctx.add_child(idx, child_idx) {
                        return Err(format!(
                            "failed to attach child \"{}\" to parent \"{}\"",
                            child_def.id.as_deref().unwrap_or(&child_def.widget_type),
                            def.id.as_deref().unwrap_or(&def.widget_type)
                        ));
                    }
                }
            }
        }
    }
    Ok(idx)
}
/// Parse `toml_src` into a `LayoutDef` and load it into `ctx`; return the root widget index or an error string.
pub fn load_layout_toml(ctx: &mut GuiContext, toml_src: &str) -> Result<usize, String> {
    let layout_def: LayoutDef =
        toml::from_str(toml_src).map_err(|e| format!("TOML parse error: {e}"))?;
    load_layout_def(ctx, &layout_def.root)
}
/// Run the engine UI rasteriser on `ctx` at the given resolution and save the PNG to `path`.
pub fn render_to_image(
    ctx: &mut GuiContext,
    width: u32,
    height: u32,
    path: &str,
) -> Result<(), String> {
    let path = Path::new(path);
    if path.is_absolute()
        || path
            .components()
            .any(|component| matches!(component, Component::ParentDir | Component::Prefix(_)))
    {
        return Err(
            "render_to_image: output path must stay relative to the current workspace".to_string(),
        );
    }
    ctx.set_viewport(width as f32, height as f32);
    let img = ctx.draw_to_image(width, height);
    let png = img.encode_png()?;
    std::fs::write(path, png)
        .map_err(|e| format!("render_to_image: failed to save '{}': {e}", path.display()))
}

fn ensure_finite_f32(name: &str, value: f32) -> Result<f32, String> {
    if value.is_finite() {
        Ok(value)
    } else {
        Err(format!("field \"{name}\" must be finite"))
    }
}

fn ensure_finite_f64(name: &str, value: f64) -> Result<f64, String> {
    if value.is_finite() {
        Ok(value)
    } else {
        Err(format!("field \"{name}\" must be finite"))
    }
}
/// Instantiate a single widget from `def` in `ctx` without recursing into children; return its index or an error.
fn create_from_def(ctx: &mut GuiContext, def: &WidgetDef) -> Result<usize, String> {
    let widget_type = def.widget_type.to_lowercase();
    let idx = match widget_type.as_str() {
        "button" => ctx.add_button(def.text.clone().unwrap_or_default()),
        "label" => ctx.add_label(def.text.clone().unwrap_or_default()),
        "textinput" => ctx.add_text_input(),
        "checkbox" => ctx.add_checkbox(def.text.clone().unwrap_or_default()),
        "slider" => ctx.add_slider(
            def.min
                .map(|value| ensure_finite_f64("min", value))
                .transpose()?
                .unwrap_or(0.0),
            def.max
                .map(|value| ensure_finite_f64("max", value))
                .transpose()?
                .unwrap_or(1.0),
        ),
        "progressbar" => ctx.add_progress_bar(
            def.min
                .map(|value| ensure_finite_f64("min", value))
                .transpose()?
                .unwrap_or(0.0),
            def.max
                .map(|value| ensure_finite_f64("max", value))
                .transpose()?
                .unwrap_or(1.0),
        ),
        "combobox" => ctx.add_combo_box(),
        "listbox" | "list" => ctx.add_list_box(),
        "panel" => ctx.add_panel(),
        "layout" | "vboxcontainer" | "vbox" | "hboxcontainer" | "hbox" | "gridcontainer"
        | "grid" | "margincontainer" | "centercontainer" => {
            let dir = def
                .direction
                .as_deref()
                .and_then(crate::ui::LayoutDirection::parse_str)
                .unwrap_or(match widget_type.as_str() {
                    "hboxcontainer" | "hbox" => crate::ui::LayoutDirection::Horizontal,
                    "gridcontainer" | "grid" => crate::ui::LayoutDirection::Grid,
                    _ => crate::ui::LayoutDirection::Vertical,
                });
            let idx = ctx.add_layout(dir);
            if let Some(WidgetKind::Layout(layout)) = ctx.widgets.get_mut(idx) {
                if matches!(widget_type.as_str(), "centercontainer") {
                    layout.align = "center".to_string();
                    layout.justify = "center".to_string();
                }
            }
            idx
        }
        "scrollpanel" | "scrollcontainer" => ctx.add_scroll_panel(),
        "ninepatch" => ctx.add_nine_patch(),
        "tabbar" => ctx.add_tab_bar(),
        "separator" => {
            let vertical = def
                .orientation
                .as_deref()
                .map(|s| s.eq_ignore_ascii_case("vertical"))
                .unwrap_or(false);
            ctx.add_separator(vertical)
        }
        "spacer" => ctx.add_spacer(
            def.w
                .map(|value| ensure_finite_f32("w", value))
                .transpose()?
                .unwrap_or(0.0),
            def.h
                .map(|value| ensure_finite_f32("h", value))
                .transpose()?
                .unwrap_or(0.0),
        ),
        "treeview" => ctx.add_tree_view(),
        "radiobutton" => ctx.add_radio_button(
            def.text.clone().unwrap_or_default(),
            def.group.clone().unwrap_or_default(),
        ),
        "scrollbar" => {
            let vertical = def
                .orientation
                .as_deref()
                .map(|s| !s.eq_ignore_ascii_case("horizontal"))
                .unwrap_or(true);
            ctx.add_scroll_bar(vertical)
        }
        "guiwindow" | "window" => ctx.add_gui_window(def.text.clone().unwrap_or_default()),
        "splitpanel" | "splitcontainer" => ctx.add_split_panel(
            def.orientation
                .clone()
                .unwrap_or_else(|| "horizontal".to_string()),
        ),
        "stackcontainer" | "stack" => ctx.add_stack_container(),
        "tabcontainer" => ctx.add_tab_container(),
        "dockpanel" => ctx.add_dock_panel(),
        "toolbar" => ctx.add_toolbar(
            def.orientation
                .clone()
                .unwrap_or_else(|| "horizontal".to_string()),
        ),
        "menubar" => ctx.add_menu_bar(),
        "menuitem" => ctx.add_menu_item(def.text.clone().unwrap_or_default()),
        "dialog" => ctx.add_dialog(def.text.clone().unwrap_or_default()),
        "statusbar" => ctx.add_status_bar(),
        "accordion" => ctx.add_accordion(),
        "tooltippanel" => ctx.add_tooltip_panel(def.text.clone().unwrap_or_default()),
        "colorpicker" => ctx.add_color_picker(),
        "guitable" => ctx.add_gui_table(),
        "property" | "propertywidget" | "property_widget" => ctx.add_property_widget(),
        // Chart widgets are represented as retained UI slots in TOML layouts.
        // Lua content can render chart images into these slot rects by id.
        "chart" | "linechart" | "barchart" | "scatterplot" | "piechart" | "areachart" => {
            ctx.add_panel()
        }
        "imagewidget" | "image" => ctx.add_image_widget(),
        "spinbox" => ctx.add_spin_box(
            def.min
                .map(|value| ensure_finite_f64("min", value))
                .transpose()?
                .unwrap_or(0.0),
            def.max
                .map(|value| ensure_finite_f64("max", value))
                .transpose()?
                .unwrap_or(100.0),
        ),
        "switch" => ctx.add_switch(def.on.unwrap_or(false)),
        "badge" => ctx.add_badge(def.value.map(|v| v as u32).unwrap_or(0)),
        "custom" => ctx.add_custom_widget(),
        unknown => return Err(format!("Unknown widget type: \"{unknown}\"")),
    };
    apply_base_props(ctx, idx, def)?;
    Ok(idx)
}
/// Apply position, size, id, visibility, enabled, tooltip, and type-specific value props from `def` onto widget `idx`.
fn apply_base_props(ctx: &mut GuiContext, idx: usize, def: &WidgetDef) -> Result<(), String> {
    let mut dialog_should_open = false;
    if let Some(w) = ctx.widgets.get_mut(idx) {
        let base = w.base_mut();
        if let Some(x) = def.x {
            base.x = ensure_finite_f32("x", x)?;
        }
        if let Some(y) = def.y {
            base.y = ensure_finite_f32("y", y)?;
        }
        if let Some(wv) = def.w {
            base.width = ensure_finite_f32("w", wv)?.max(0.0);
        }
        if let Some(h) = def.h {
            base.height = ensure_finite_f32("h", h)?.max(0.0);
        }
        if let Some(ref id) = def.id {
            base.id = id.clone();
        }
        if let Some(vis) = def.visible {
            base.visible = vis;
        }
        if let Some(en) = def.enabled {
            base.enabled = en;
        }
        if let Some(ref tt) = def.tooltip {
            base.tooltip = tt.clone();
        }
        if let Some(ref icon_name) = def.icon {
            if let Some(icon) = crate::ui::lookup_icon(icon_name) {
                base.icon = Some(icon.name.to_string());
            } else {
                return Err(format!("unknown built-in icon \"{}\"", icon_name));
            }
        }
        if let Some(ref position) = def.icon_position {
            base.icon_position = crate::ui::UiIconPosition::parse_str(position)
                .ok_or_else(|| format!("unsupported icon_position value \"{}\"", position))?;
        }
        if let Some(size) = def.icon_size {
            base.icon_size = ensure_finite_f32("icon_size", size)?.max(0.0);
        }
        if let Some(padding) = def.padding {
            base.padding = [
                ensure_finite_f32("padding[0]", padding[0])?.max(0.0),
                ensure_finite_f32("padding[1]", padding[1])?.max(0.0),
                ensure_finite_f32("padding[2]", padding[2])?.max(0.0),
                ensure_finite_f32("padding[3]", padding[3])?.max(0.0),
            ];
        }
        if let Some(margin) = def.margin {
            base.margin = [
                ensure_finite_f32("margin[0]", margin[0])?.max(0.0),
                ensure_finite_f32("margin[1]", margin[1])?.max(0.0),
                ensure_finite_f32("margin[2]", margin[2])?.max(0.0),
                ensure_finite_f32("margin[3]", margin[3])?.max(0.0),
            ];
        }
        if let Some(ref align) = def.text_align {
            if matches!(align.as_str(), "left" | "center" | "right") {
                base.text_align = align.clone();
            } else {
                return Err(format!("unsupported text_align value \"{}\"", align));
            }
        }
        if let Some(ref align) = def.text_v_align {
            base.text_v_align = TextVAlign::parse_str(align)
                .ok_or_else(|| format!("unsupported text_v_align value \"{}\"", align))?;
        }
        if let Some(value) = def.text_wrap {
            base.text_wrap = value;
        }
        if let Some(value) = def.text_ellipsis {
            base.text_ellipsis = value;
        }
        if let Some(value) = def.flex_grow {
            base.flex_grow = ensure_finite_f32("flex_grow", value)?.max(0.0);
        }
        if let Some(value) = def.flex_shrink {
            base.flex_shrink = ensure_finite_f32("flex_shrink", value)?.max(0.0);
        }
        if let Some([min_w, min_h]) = def.min_size {
            base.min_width = ensure_finite_f32("min_size[0]", min_w)?.max(0.0);
            base.min_height = ensure_finite_f32("min_size[1]", min_h)?.max(0.0);
        }
        if let Some([max_w, max_h]) = def.max_size {
            base.max_width = ensure_finite_f32("max_size[0]", max_w)?.max(base.min_width);
            base.max_height = ensure_finite_f32("max_size[1]", max_h)?.max(base.min_height);
        }
    }
    match ctx.widgets.get_mut(idx) {
        Some(WidgetKind::Slider(sl)) => {
            if let Some(v) = def.value {
                if !sl.set_value(ensure_finite_f64("value", v)?) {
                    return Err("slider value is invalid".to_string());
                }
            }
        }
        Some(WidgetKind::ProgressBar(pb)) => {
            if let Some(v) = def.value {
                if !pb.set_value(ensure_finite_f64("value", v)?) {
                    return Err("progress bar value is invalid".to_string());
                }
            }
        }
        Some(WidgetKind::SpinBox(sb)) => {
            if let Some(v) = def.value {
                if !sb.set_value(ensure_finite_f64("value", v)?) {
                    return Err("spin box value is invalid".to_string());
                }
            }
        }
        Some(WidgetKind::CheckBox(cb)) => {
            if let Some(c) = def.checked {
                cb.checked = c;
            }
        }
        Some(WidgetKind::Switch(sw)) => {
            if let Some(o) = def.on {
                sw.set_on(o);
            }
        }
        Some(WidgetKind::TextInput(ti)) => {
            if let Some(ref p) = def.placeholder {
                ti.placeholder = p.clone();
            }
            if let Some(value) = def.submit_on_enter {
                ti.submit_on_enter = value;
            }
            if let Some(ref t) = def.text {
                ti.set_text(t.clone());
            }
        }
        Some(WidgetKind::ComboBox(combo_box)) => {
            if let Some(value) = def.max_visible_items {
                combo_box.set_max_visible_items(value);
            }
        }
        Some(WidgetKind::Layout(lay)) => {
            if let Some(sp) = def.spacing {
                lay.spacing = ensure_finite_f32("spacing", sp)?;
            }
            if let Some(ref align) = def.align {
                lay.align = align.clone();
            }
            if let Some(ref justify) = def.justify {
                lay.justify = justify.clone();
            }
            if let Some(columns) = def.columns {
                lay.columns = columns.max(1);
            }
            if let Some(wrap) = def.wrap {
                lay.wrap = wrap;
            }
        }
        Some(WidgetKind::StackContainer(stack)) | Some(WidgetKind::TabContainer(stack)) => {
            if let Some(active_index) = def.active_index {
                if active_index >= 1 {
                    stack.active_index = active_index - 1;
                }
            }
            if let Some(tabs) = &def.tabs {
                stack.tabs = tabs.clone();
            }
            if let Some(value) = def.tab_bar_height {
                stack.tab_bar_height = ensure_finite_f32("tab_bar_height", value)?.max(0.0);
            }
        }
        Some(WidgetKind::GUIWindow(window)) => {
            if let Some(value) = def.closeable {
                window.closeable = value;
            }
            if let Some(value) = def.draggable {
                window.draggable = value;
            }
            if let Some(value) = def.resizable {
                window.resizable = value;
            }
        }
        Some(WidgetKind::Dialog(dialog)) => {
            if let Some(value) = def.modal {
                dialog.modal = value;
            }
            if let Some(value) = def.closeable {
                dialog.closeable = value;
            }
            if let Some(value) = def.draggable {
                dialog.draggable = value;
            }
            if let Some(value) = def.resizable {
                dialog.resizable = value;
            }
            if let Some(value) = def.dismiss_on_outside_click {
                dialog.dismiss_on_outside_click = value;
            }
            if let Some(value) = def.center_on_open {
                dialog.center_on_open = value;
            }
            if let Some(actions) = &def.actions {
                dialog.actions.clear();
                dialog.default_action_idx = None;
                dialog.cancel_action_idx = None;
                for action_def in actions {
                    let normalized_role = action_def
                        .role
                        .as_deref()
                        .unwrap_or("custom")
                        .to_ascii_lowercase();
                    let role = DialogActionRole::parse_str(&normalized_role).ok_or_else(|| {
                        format!("unsupported dialog action role \"{}\"", normalized_role)
                    })?;
                    let close_on_activate = action_def.close_on_activate.unwrap_or(matches!(
                        role,
                        DialogActionRole::Default | DialogActionRole::Cancel
                    ));
                    dialog.actions.push(DialogAction::new(
                        action_def.text.clone(),
                        role,
                        close_on_activate,
                    ));
                    let action_idx = dialog.actions.len() - 1;
                    match role {
                        DialogActionRole::Default if dialog.default_action_idx.is_none() => {
                            dialog.default_action_idx = Some(action_idx)
                        }
                        DialogActionRole::Cancel if dialog.cancel_action_idx.is_none() => {
                            dialog.cancel_action_idx = Some(action_idx)
                        }
                        _ => {}
                    }
                }
            }
            dialog_should_open = def.open.unwrap_or(false);
        }
        Some(WidgetKind::PropertyWidget(property_widget)) => {
            if let Some(value) = def.property_label_width {
                property_widget.label_width =
                    ensure_finite_f32("property_label_width", value)?.max(1.0);
            }
            if let Some(value) = def.property_row_height {
                property_widget.row_height =
                    ensure_finite_f32("property_row_height", value)?.max(1.0);
            }
            if let Some(value) = def.property_group_header_height {
                property_widget.group_header_height =
                    ensure_finite_f32("property_group_header_height", value)?.max(1.0);
            }
            if let Some(groups) = &def.property_groups {
                property_widget.groups.clear();
                for group_def in groups {
                    let group_idx = property_widget.add_group(
                        group_def.title.clone(),
                        group_def.collapsed.unwrap_or(false),
                    );
                    if let Some(rows) = &group_def.rows {
                        for row_def in rows {
                            let raw_value_type = row_def.value_type.as_deref().unwrap_or("text");
                            let value_kind = PropertyValueKind::parse_str(raw_value_type)
                                .ok_or_else(|| {
                                    format!(
                                        "unsupported property value_type \"{}\"",
                                        raw_value_type
                                    )
                                })?;
                            let mut row = PropertyRow::new(
                                row_def.name.clone(),
                                row_def.value.clone().unwrap_or_default(),
                                value_kind,
                            );
                            row.options = row_def.options.clone().unwrap_or_default();
                            row.read_only = row_def.read_only.unwrap_or(false);
                            let _ = property_widget.add_property(group_idx, row);
                        }
                    }
                }
            }
        }
        _ => {}
    }
    if dialog_should_open {
        let _ = ctx.open_dialog_widget(idx);
    }
    Ok(())
}
