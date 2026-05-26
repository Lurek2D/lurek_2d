//! Deserialise TOML layout files into a recursive `WidgetDef` tree and instantiate them into a live `GuiContext`.
//!
//! - Map widget-type strings to concrete `GuiContext::add_*` constructors covering 30+ widget kinds.
//! - Apply optional base properties (position, size, id, visibility, enabled, tooltip) and type-specific values after creation.
//! - Provide a headless `render_to_image` path that saves the engine's default UI rasterisation to PNG.
//! - Support recursive child nesting via the `children` field in `WidgetDef`, mirroring the runtime parent–child hierarchy.
//! - Integrate with `GuiContext` only; no wgpu dependency — useful for offline layout validation and snapshot tests.

use crate::ui::context::{GuiContext, WidgetKind};
use serde::Deserialize;
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
    /// Layout direction string (`"horizontal"` / `"vertical"`) for layout and split panels.
    pub direction: Option<String>,
    /// Item spacing in pixels for layout widgets.
    pub spacing: Option<f32>,
    /// Orientation string (`"horizontal"` / `"vertical"`) for separators, scroll bars, etc.
    pub orientation: Option<String>,
    /// Radio-button group identifier.
    pub group: Option<String>,
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
            ctx.add_child(idx, child_idx);
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
    std::fs::write(path, png)
        .map_err(|e| format!("render_to_image: failed to save '{path}': {e}"))
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
    apply_base_props(ctx, idx, def);
    Ok(idx)
}
/// Apply position, size, id, visibility, enabled, tooltip, and type-specific value props from `def` onto widget `idx`.
fn apply_base_props(ctx: &mut GuiContext, idx: usize, def: &WidgetDef) {
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
        }
        _ => {}
    }
}
