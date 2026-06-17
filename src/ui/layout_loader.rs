//! This file provides declarative UI loading from TOML definitions into live widget trees. `ui/layout_loader` delivers the layout loader implementation for the ui subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! It maps textual widget kinds onto concrete context constructors with consistent defaults. The file owns or coordinates data contracts including `DialogActionDef`, `WidgetDef`, `LayoutDef`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! It applies generic and type-specific properties so authored layouts become runtime-ready. Public callable behavior is centered on `load_layout_def`, `load_layout_toml`, `render_to_image`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
//! It supports recursive child structures that mirror retained parent-child composition. Runtime integration reaches sibling engine areas through crate modules `ui`, which explains the subsystem dependencies an agent should inspect before changing behavior.
//! It offers headless image rendering for snapshot checks and offline layout verification. External integration uses `serde`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
//! It enables fast iteration on UI structure without hardcoding full trees in Lua scripts. The file boundary separates ui implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.

use crate::ui::context::{GuiContext, WidgetKind};
use crate::ui::extras::{DialogAction, DialogActionRole};
use crate::ui::widget::TextVAlign;
use serde::Deserialize;
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
    /// Hover tooltip text.
    pub tooltip: Option<String>,
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
    let idx = create_from_def(ctx, def)?;
    if let Some(children) = &def.children {
        for child_def in children {
            let child_idx = load_layout_def(ctx, child_def)?;
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
                Some(other) => {
                    return Err(format!(
                        "unsupported slot value \"{other}\" for child of {}",
                        def.widget_type
                    ))
                }
                None => {
                    ctx.add_child(idx, child_idx);
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
    ctx.set_viewport(width as f32, height as f32);
    let img = ctx.draw_to_image(width, height);
    let png = img.encode_png()?;
    std::fs::write(path, png).map_err(|e| format!("render_to_image: failed to save '{path}': {e}"))
}
/// Instantiate a single widget from `def` in `ctx` without recursing into children; return its index or an error.
fn create_from_def(ctx: &mut GuiContext, def: &WidgetDef) -> Result<usize, String> {
    let widget_type = def.widget_type.to_lowercase();
    let idx = match widget_type.as_str() {
        "button" => ctx.add_button(def.text.clone().unwrap_or_default()),
        "label" => ctx.add_label(def.text.clone().unwrap_or_default()),
        "textinput" => ctx.add_text_input(),
        "checkbox" => ctx.add_checkbox(def.text.clone().unwrap_or_default()),
        "slider" => ctx.add_slider(def.min.unwrap_or(0.0), def.max.unwrap_or(1.0)),
        "progressbar" => ctx.add_progress_bar(def.min.unwrap_or(0.0), def.max.unwrap_or(1.0)),
        "combobox" => ctx.add_combo_box(),
        "listbox" | "list" => ctx.add_list_box(),
        "panel" => ctx.add_panel(),
        "layout" => {
            let dir = def
                .direction
                .as_deref()
                .and_then(crate::ui::LayoutDirection::parse_str)
                .unwrap_or(crate::ui::LayoutDirection::Vertical);
            ctx.add_layout(dir)
        }
        "scrollpanel" => ctx.add_scroll_panel(),
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
        "spacer" => ctx.add_spacer(def.w.unwrap_or(0.0), def.h.unwrap_or(0.0)),
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
        "splitpanel" => ctx.add_split_panel(
            def.orientation
                .clone()
                .unwrap_or_else(|| "horizontal".to_string()),
        ),
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
        // Chart widgets are represented as retained UI slots in TOML layouts.
        // Lua content can render chart images into these slot rects by id.
        "chart" | "linechart" | "barchart" | "scatterplot" | "piechart" | "areachart" => {
            ctx.add_panel()
        }
        "imagewidget" | "image" => ctx.add_image_widget(),
        "spinbox" => ctx.add_spin_box(def.min.unwrap_or(0.0), def.max.unwrap_or(100.0)),
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
            base.x = x;
        }
        if let Some(y) = def.y {
            base.y = y;
        }
        if let Some(wv) = def.w {
            base.width = wv;
        }
        if let Some(h) = def.h {
            base.height = h;
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
        if let Some(padding) = def.padding {
            base.padding = padding.map(|v| v.max(0.0));
        }
        if let Some(margin) = def.margin {
            base.margin = margin.map(|v| v.max(0.0));
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
            base.flex_grow = value.max(0.0);
        }
        if let Some(value) = def.flex_shrink {
            base.flex_shrink = value.max(0.0);
        }
        if let Some([min_w, min_h]) = def.min_size {
            base.min_width = min_w.max(0.0);
            base.min_height = min_h.max(0.0);
        }
        if let Some([max_w, max_h]) = def.max_size {
            base.max_width = max_w.max(base.min_width);
            base.max_height = max_h.max(base.min_height);
        }
    }
    match ctx.widgets.get_mut(idx) {
        Some(WidgetKind::Slider(sl)) => {
            if let Some(v) = def.value {
                sl.value = v;
            }
        }
        Some(WidgetKind::ProgressBar(pb)) => {
            if let Some(v) = def.value {
                pb.value = v;
            }
        }
        Some(WidgetKind::SpinBox(sb)) => {
            if let Some(v) = def.value {
                sb.value = v;
            }
        }
        Some(WidgetKind::CheckBox(cb)) => {
            if let Some(c) = def.checked {
                cb.checked = c;
            }
        }
        Some(WidgetKind::Switch(sw)) => {
            if let Some(o) = def.on {
                sw.on = o;
            }
        }
        Some(WidgetKind::TextInput(ti)) => {
            if let Some(ref p) = def.placeholder {
                ti.placeholder = p.clone();
            }
            if let Some(ref t) = def.text {
                ti.set_text(t.clone());
            }
        }
        Some(WidgetKind::Layout(lay)) => {
            if let Some(sp) = def.spacing {
                lay.spacing = sp;
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
        _ => {}
    }
    if dialog_should_open {
        let _ = ctx.open_dialog_widget(idx);
    }
    Ok(())
}
