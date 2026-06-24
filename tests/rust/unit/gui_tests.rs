//! File: tests/rust/unit/gui_tests.rs

// TODO(lua-first): public Rust API coverage in this file should live in tests/lua/unit/; keep only private/internal seams here.

use lurek2d::math::Rect;
use lurek2d::ui::containers::{Layout, LayoutDirection, NinePatch, ScrollPanel};
use lurek2d::ui::context::{GuiContext, GuiEvent};
use lurek2d::ui::controls::{Slider, Switch, TextInput};
use lurek2d::ui::extras::{Dialog, DialogAction, DialogActionRole, TreeView};
use lurek2d::ui::layout_loader::{load_layout_def, render_to_image, WidgetDef};
use lurek2d::ui::theme::{Theme, ThemeToken, WidgetStyle};
use lurek2d::ui::widget::{MouseFilter, WidgetBase, WidgetState, WidgetType};
use std::time::Instant;

// â”€â”€â”€ WidgetStyle field defaults â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// WidgetStyle is an internal struct with no Lua getter; its default values are
// invisible to the script layer and must be confirmed here.

#[test]
fn widget_style_default_shadow_alpha_is_zero() {
    let s = WidgetStyle::default();
    assert!(
        (s.shadow_color[3]).abs() < 1e-5,
        "default shadow alpha must be zero"
    );
}

#[test]
fn widget_style_default_highlight_alpha_is_zero() {
    let s = WidgetStyle::default();
    assert!(
        (s.highlight_alpha).abs() < 1e-5,
        "default highlight_alpha must be zero"
    );
}

#[test]
fn widget_style_default_gradient_end_is_none() {
    assert!(WidgetStyle::default().gradient_end.is_none());
}

#[test]
fn widget_style_default_text_align_is_center() {
    assert_eq!(WidgetStyle::default().text_align, "center");
}

#[test]
fn widget_style_default_shadow_offset_is_zero() {
    let s = WidgetStyle::default();
    assert!((s.shadow_offset[0]).abs() < 1e-5);
    assert!((s.shadow_offset[1]).abs() < 1e-5);
}

// â”€â”€â”€ WidgetType::default_size â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// default_size() is not exposed as a Lua function; it only drives WidgetBase::new().

#[test]
fn widget_type_button_default_size_is_16px_aligned() {
    let (w, h) = WidgetType::Button.default_size();
    assert_eq!(w % 16.0, 0.0, "Button width must be 16px aligned");
    assert_eq!(h % 16.0, 0.0, "Button height must be 16px aligned");
}

#[test]
fn widget_type_spin_box_default_size_is_positive() {
    let (w, h) = WidgetType::SpinBox.default_size();
    assert!(w > 0.0 && h > 0.0);
}

#[test]
fn widget_type_switch_default_size_is_positive() {
    let (w, h) = WidgetType::Switch.default_size();
    assert!(w > 0.0 && h > 0.0);
}

#[test]
fn widget_type_badge_default_size_is_positive() {
    let (w, h) = WidgetType::Badge.default_size();
    assert!(w > 0.0 && h > 0.0);
}

// â”€â”€â”€ WidgetBase::new sizing â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// The fact that WidgetBase uses default_size (not a 100Ă—30 hardcode) is a
// pure-Rust invariant â€” Lua cannot observe the raw width/height before any
// geometry call.

#[test]
fn widget_base_new_width_matches_type_default_size() {
    let (expected_w, _) = WidgetType::Button.default_size();
    let base = WidgetBase::new(WidgetType::Button);
    assert!((base.width - expected_w).abs() < 1e-5);
}

#[test]
fn widget_base_new_height_matches_type_default_size() {
    let (_, expected_h) = WidgetType::Button.default_size();
    let base = WidgetBase::new(WidgetType::Button);
    assert!((base.height - expected_h).abs() < 1e-5);
}

// â”€â”€â”€ Switch::thumb_t â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// `thumb_t` is a private animation field not exposed via the Lua `Switch`
// userdata â€” it drives the thumb animation only inside Rust.

#[test]
fn switch_new_off_has_thumb_t_zero() {
    let sw = Switch::new(false);
    assert!((sw.thumb_t).abs() < 1e-5, "thumb_t must be 0 when off");
}

#[test]
fn switch_new_on_has_thumb_t_one() {
    let sw = Switch::new(true);
    assert!(
        (sw.thumb_t - 1.0).abs() < 1e-5,
        "thumb_t must be 1.0 when on"
    );
}

// â”€â”€â”€ Theme::default_dark â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// The Theme struct's style map is not surfaced through any `lurek.ui.*` getter;
// its content can only be inspected at the Rust level.

#[test]
fn theme_default_dark_has_button_style() {
    use lurek2d::ui::widget::{WidgetState, WidgetType};
    let theme = Theme::default_dark();
    let style = theme.get_style(WidgetType::Button, WidgetState::Normal);
    assert!(
        style.is_some(),
        "default_dark must include a style for Button/Normal"
    );
}

#[test]
fn theme_default_dark_button_has_nonzero_corner_radius() {
    use lurek2d::ui::widget::{WidgetState, WidgetType};
    let theme = Theme::default_dark();
    let style = theme
        .get_style(WidgetType::Button, WidgetState::Normal)
        .unwrap();
    assert!(
        style.corner_radius > 0.0,
        "Button in default_dark must have corner_radius > 0"
    );
}

#[test]
fn theme_default_dark_button_has_depth_cues() {
    use lurek2d::ui::widget::{WidgetState, WidgetType};
    let theme = Theme::default_dark();
    let style = theme
        .get_style(WidgetType::Button, WidgetState::Normal)
        .unwrap();
    assert!(
        style.gradient_end.is_some(),
        "Button in default_dark must have a gradient fill"
    );
    assert!(
        style.shadow_color[3] > 0.0,
        "Button in default_dark must have a visible shadow"
    );
    assert!(
        style.highlight_alpha > 0.0,
        "Button in default_dark must have a top highlight"
    );
}

#[test]
fn theme_default_dark_exposes_focus_ring_token() {
    let theme = Theme::default_dark();
    match theme.get_token("focus_ring_color") {
        Some(ThemeToken::Color([r, g, b, a])) => {
            assert!(*r > 0.0);
            assert!(*g > 0.0);
            assert!(*b > 0.0);
            assert!(*a > 0.0);
        }
        other => panic!("expected color focus ring token, got {other:?}"),
    }
}

#[test]
fn theme_default_dark_has_normal_style_for_every_widget_type() {
    use lurek2d::ui::widget::{WidgetState, WidgetType};
    let theme = Theme::default_dark();
    let widget_types = [
        WidgetType::Button,
        WidgetType::Label,
        WidgetType::TextInput,
        WidgetType::CheckBox,
        WidgetType::Slider,
        WidgetType::ProgressBar,
        WidgetType::ComboBox,
        WidgetType::ListBox,
        WidgetType::Panel,
        WidgetType::Layout,
        WidgetType::ScrollPanel,
        WidgetType::NinePatch,
        WidgetType::TabBar,
        WidgetType::Toast,
        WidgetType::Separator,
        WidgetType::Spacer,
        WidgetType::TreeView,
        WidgetType::RadioButton,
        WidgetType::ScrollBar,
        WidgetType::GUIWindow,
        WidgetType::SplitPanel,
        WidgetType::DockPanel,
        WidgetType::Toolbar,
        WidgetType::MenuBar,
        WidgetType::MenuItem,
        WidgetType::Dialog,
        WidgetType::StatusBar,
        WidgetType::Accordion,
        WidgetType::TooltipPanel,
        WidgetType::ColorPicker,
        WidgetType::GUITable,
        WidgetType::ImageWidget,
        WidgetType::SpinBox,
        WidgetType::Switch,
        WidgetType::Badge,
        WidgetType::Custom,
    ];
    for widget_type in widget_types {
        assert!(
            theme.get_style(widget_type, WidgetState::Normal).is_some(),
            "default_dark missing normal style for {}",
            widget_type.as_str()
        );
    }
}

#[test]
fn theme_default_dark_panel_and_layout_are_chrome_free_by_default() {
    use lurek2d::ui::widget::{WidgetState, WidgetType};

    let theme = Theme::default_dark();
    for widget_type in [WidgetType::Panel, WidgetType::Layout] {
        let style = theme
            .get_style(widget_type, WidgetState::Normal)
            .unwrap_or_else(|| panic!("missing normal style for {:?}", widget_type));
        assert!(
            style.bg_color[3].abs() < 1e-6,
            "{:?} default background should be transparent",
            widget_type
        );
        assert!(
            style.border_color[3].abs() < 1e-6,
            "{:?} default border should be transparent",
            widget_type
        );
        assert!(
            style.border_width.abs() < 1e-6,
            "{:?} default border width should be zero",
            widget_type
        );
    }
}

// â”€â”€â”€ GuiContext private internals â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// GuiContext fields (dirty, viewport_w/h, theme, widget pool) are not exposed
// via `lurek.ui.*`; only the effects of mutation are observable from Lua.

#[test]
fn gui_context_new_is_dirty() {
    let ctx = GuiContext::new();
    assert!(ctx.dirty, "GuiContext must start dirty");
}

#[test]
fn gui_context_add_spin_box_marks_dirty() {
    let mut ctx = GuiContext::new();
    ctx.flush_cache();
    ctx.add_spin_box(0.0, 10.0);
    assert!(ctx.dirty, "add_spin_box must set dirty = true");
}

#[test]
fn gui_context_add_switch_marks_dirty() {
    let mut ctx = GuiContext::new();
    ctx.flush_cache();
    ctx.add_switch(false);
    assert!(ctx.dirty, "add_switch must set dirty = true");
}

#[test]
fn gui_context_add_badge_marks_dirty() {
    let mut ctx = GuiContext::new();
    ctx.flush_cache();
    ctx.add_badge(0);
    assert!(ctx.dirty, "add_badge must set dirty = true");
}

#[test]
fn gui_context_set_viewport_stores_dimensions() {
    let mut ctx = GuiContext::new();
    ctx.set_viewport(1280.0, 720.0);
    assert!((ctx.viewport_w - 1280.0).abs() < 1e-5);
    assert!((ctx.viewport_h - 720.0).abs() < 1e-5);
}

#[test]
fn gui_context_set_default_theme_installs_theme() {
    let mut ctx = GuiContext::new();
    ctx.set_default_theme();
    assert!(
        ctx.theme.is_some(),
        "set_default_theme must install a non-None theme"
    );
}

#[test]
fn gui_context_add_spin_box_returns_valid_index() {
    let mut ctx = GuiContext::new();
    let idx = ctx.add_spin_box(0.0, 10.0);
    assert!(
        idx < ctx.widgets.len(),
        "returned index must be within widgets pool"
    );
}

#[test]
fn dialog_new_uses_popup_oriented_defaults() {
    let dialog = Dialog::new("Popup");
    assert!(dialog.modal);
    assert!(!dialog.open);
    assert!(dialog.closeable);
    assert!(!dialog.draggable);
    assert!(!dialog.resizable);
    assert!(dialog.footer_idx.is_none());
    assert!(dialog.actions.is_empty());
    assert!(dialog.default_action_idx.is_none());
    assert!(dialog.cancel_action_idx.is_none());
    assert!(!dialog.dismiss_on_outside_click);
    assert!(dialog.center_on_open);
}

#[test]
fn gui_window_resizable_runtime_drag_updates_size() {
    let mut ctx = GuiContext::new();
    ctx.set_viewport(1280.0, 720.0);
    let window_idx = ctx.add_gui_window("Inspector");
    ctx.add_child(0, window_idx);
    {
        let window = match &mut ctx.widgets[window_idx] {
            lurek2d::ui::context::WidgetKind::GUIWindow(window) => window,
            _ => panic!("expected GUIWindow"),
        };
        window.resizable = true;
        window.base.x = 100.0;
        window.base.y = 80.0;
        window.base.width = 180.0;
        window.base.height = 120.0;
        window.base.z_order = 10;
    }

    assert!(ctx.mouse_pressed(278.0, 198.0, 1));
    assert!(ctx.mouse_moved(332.0, 244.0));
    assert!(ctx.mouse_released(332.0, 244.0, 1));

    let base = ctx.widgets[window_idx].base();
    assert!(base.width > 180.0, "resize drag should grow width");
    assert!(base.height > 120.0, "resize drag should grow height");
}

#[test]
fn dialog_footer_action_click_can_close_dialog() {
    let mut ctx = GuiContext::new();
    ctx.set_viewport(1920.0, 1440.0);
    let dialog_idx = ctx.add_dialog("Footer");
    {
        let dialog = match &mut ctx.widgets[dialog_idx] {
            lurek2d::ui::context::WidgetKind::Dialog(dialog) => dialog,
            _ => panic!("expected Dialog"),
        };
        dialog.open = true;
        dialog.center_on_open = false;
        dialog.base.x = 520.0;
        dialog.base.y = 840.0;
        dialog.base.width = 180.0;
        dialog.base.height = 100.0;
        dialog.base.z_order = 1200;
        dialog.actions.push(lurek2d::ui::extras::DialogAction::new(
            "Close",
            lurek2d::ui::extras::DialogActionRole::Custom,
            true,
        ));
    }

    assert!(ctx.mouse_pressed(630.0, 914.0, 1));

    let dialog = match &ctx.widgets[dialog_idx] {
        lurek2d::ui::context::WidgetKind::Dialog(dialog) => dialog,
        _ => panic!("expected Dialog"),
    };
    assert!(
        !dialog.open,
        "footer action should close dialog on activation"
    );
}

#[test]
fn gui_window_resize_without_explicit_viewport_uses_base_resolution_fallback() {
    let mut ctx = GuiContext::new();
    let window_idx = ctx.add_gui_window("Fallback");
    {
        let window = match &mut ctx.widgets[window_idx] {
            lurek2d::ui::context::WidgetKind::GUIWindow(window) => window,
            _ => panic!("expected GUIWindow"),
        };
        window.resizable = true;
        window.base.x = 100.0;
        window.base.y = 80.0;
        window.base.width = 180.0;
        window.base.height = 120.0;
        window.base.z_order = 10;
    }

    assert!(ctx.mouse_pressed(278.0, 198.0, 1));
    assert!(ctx.mouse_moved(332.0, 244.0));
    assert!(ctx.mouse_released(332.0, 244.0, 1));

    let base = ctx.widgets[window_idx].base();
    assert!(base.x >= 0.0 && base.y >= 0.0);
    assert!(base.width > 180.0, "resize drag should grow width");
    assert!(base.height > 120.0, "resize drag should grow height");
}

// â”€â”€â”€ EasingFunction evaluations â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

use lurek2d::ui::widget::EasingFunction;

#[test]
fn easing_linear_zero_returns_zero() {
    assert!((EasingFunction::Linear.eval(0.0)).abs() < 1e-5);
}

#[test]
fn easing_linear_one_returns_one() {
    assert!((EasingFunction::Linear.eval(1.0) - 1.0).abs() < 1e-5);
}

#[test]
fn easing_linear_half_returns_half() {
    assert!((EasingFunction::Linear.eval(0.5) - 0.5).abs() < 1e-5);
}

#[test]
fn easing_sine_out_one_returns_one() {
    assert!((EasingFunction::SineOut.eval(1.0) - 1.0).abs() < 1e-5);
}

#[test]
fn easing_sine_in_zero_returns_zero() {
    assert!((EasingFunction::SineIn.eval(0.0)).abs() < 1e-5);
}

#[test]
fn easing_cubic_out_one_returns_one() {
    assert!((EasingFunction::CubicOut.eval(1.0) - 1.0).abs() < 1e-5);
}

#[test]
fn easing_cubic_in_zero_returns_zero() {
    assert!((EasingFunction::CubicIn.eval(0.0)).abs() < 1e-5);
}

#[test]
fn easing_bounce_out_boundaries() {
    assert!((EasingFunction::BounceOut.eval(0.0)).abs() < 1e-5);
    assert!((EasingFunction::BounceOut.eval(1.0) - 1.0).abs() < 1e-5);
}

#[test]
fn easing_elastic_out_boundaries() {
    assert!((EasingFunction::ElasticOut.eval(0.0)).abs() < 1e-5);
    assert!((EasingFunction::ElasticOut.eval(1.0) - 1.0).abs() < 1e-5);
}

#[test]
fn easing_back_out_reaches_one() {
    assert!((EasingFunction::BackOut.eval(1.0) - 1.0).abs() < 1e-5);
}

#[test]
fn easing_parse_str_valid() {
    assert_eq!(
        EasingFunction::parse_str("linear"),
        Some(EasingFunction::Linear)
    );
    assert_eq!(
        EasingFunction::parse_str("bounce_out"),
        Some(EasingFunction::BounceOut)
    );
    assert_eq!(
        EasingFunction::parse_str("elastic_out"),
        Some(EasingFunction::ElasticOut)
    );
}

#[test]
fn easing_parse_str_invalid_returns_none() {
    assert_eq!(EasingFunction::parse_str("nonexistent"), None);
    assert_eq!(EasingFunction::parse_str(""), None);
}

// â”€â”€â”€ WidgetBase new field defaults â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

#[test]
fn widget_base_default_scale_is_one() {
    let base = WidgetBase::new(WidgetType::Panel);
    assert!((base.scale_x - 1.0).abs() < 1e-5);
    assert!((base.scale_y - 1.0).abs() < 1e-5);
}

#[test]
fn widget_base_default_rotation_is_zero() {
    let base = WidgetBase::new(WidgetType::Panel);
    assert!((base.rotation).abs() < 1e-5);
}

#[test]
fn widget_base_default_color_tint_is_white() {
    let base = WidgetBase::new(WidgetType::Panel);
    assert!((base.color_tint[0] - 1.0).abs() < 1e-5);
    assert!((base.color_tint[1] - 1.0).abs() < 1e-5);
    assert!((base.color_tint[2] - 1.0).abs() < 1e-5);
    assert!((base.color_tint[3] - 1.0).abs() < 1e-5);
}

// â”€â”€â”€ GuiContext new field defaults â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

#[test]
fn gui_context_default_base_resolution() {
    let ctx = GuiContext::new();
    assert!((ctx.base_resolution.0 - 1920.0).abs() < 1e-5);
    assert!((ctx.base_resolution.1 - 1080.0).abs() < 1e-5);
}

#[test]
fn gui_context_default_scale_factor_is_one() {
    let ctx = GuiContext::new();
    assert!((ctx.scale_factor - 1.0).abs() < 1e-5);
}

#[test]
fn decorative_widgets_are_not_focusable_by_default() {
    for widget_type in [
        WidgetType::Label,
        WidgetType::Panel,
        WidgetType::Layout,
        WidgetType::Spacer,
        WidgetType::Separator,
        WidgetType::Badge,
        WidgetType::Custom,
    ] {
        assert!(
            !WidgetBase::new(widget_type).focusable,
            "{} should be skipped by default focus traversal",
            widget_type.as_str()
        );
    }
}

#[test]
fn tab_skips_non_interactive_widgets_by_default() {
    let mut ctx = GuiContext::new();
    let label_idx = ctx.add_label("Label");
    let button_idx = ctx.add_button("OK");
    let panel_idx = ctx.add_panel();
    let text_idx = ctx.add_text_input();
    assert!(ctx.add_child(0, label_idx));
    assert!(ctx.add_child(0, button_idx));
    assert!(ctx.add_child(0, panel_idx));
    assert!(ctx.add_child(0, text_idx));

    ctx.focus_next();
    assert_eq!(ctx.focused_widget, Some(button_idx));

    assert!(ctx.key_pressed("tab"));
    assert_eq!(ctx.focused_widget, Some(text_idx));

    assert!(ctx.key_pressed("shift+tab"));
    assert_eq!(ctx.focused_widget, Some(button_idx));
}

#[test]
fn add_child_rejects_cycles_root_and_multi_parent() {
    let mut ctx = GuiContext::new();
    let parent_a = ctx.add_panel();
    let parent_b = ctx.add_panel();
    let child = ctx.add_panel();
    assert!(ctx.add_child(0, parent_a));
    assert!(ctx.add_child(0, parent_b));
    assert!(ctx.add_child(parent_a, child));
    assert!(!ctx.add_child(child, parent_a));
    assert!(!ctx.add_child(parent_b, child));
    assert!(!ctx.add_child(parent_a, 0));
    assert!(ctx.validate_tree().is_empty());
}

#[test]
fn validate_tree_reports_duplicate_children() {
    let mut ctx = GuiContext::new();
    let parent = ctx.add_panel();
    let child = ctx.add_button("dup");
    assert!(ctx.add_child(0, parent));
    assert!(ctx.add_child(parent, child));
    if let lurek2d::ui::context::WidgetKind::Panel(panel) = &mut ctx.widgets[parent] {
        panel.children.push(child);
    }
    let errors = ctx.validate_tree();
    assert!(errors.iter().any(|error| error.contains("more than once")));
}

#[test]
fn slider_reversed_range_is_normalized_and_nan_is_rejected() {
    let slider = Slider::new(10.0, 0.0);
    assert!((slider.min - 0.0).abs() < 1e-9);
    assert!((slider.max - 10.0).abs() < 1e-9);
    assert!((slider.value - 0.0).abs() < 1e-9);

    let mut slider = Slider::new(0.0, 10.0);
    assert!(!slider.set_value(f64::NAN));
    assert!(slider.set_range(25.0, 5.0));
    assert!((slider.min - 5.0).abs() < 1e-9);
    assert!((slider.max - 25.0).abs() < 1e-9);
    assert!(!slider.set_range(f64::INFINITY, 1.0));
}

#[test]
fn text_input_partial_paste_and_delete_are_supported() {
    let mut input = TextInput::new();
    input.set_max_length(5);
    assert!(input.insert_text("abcdef"));
    assert_eq!(input.text, "abcde");
    input.cursor_pos = 2;
    assert!(input.delete_forward());
    assert_eq!(input.text, "abde");
}

#[test]
fn text_input_selection_replace_and_unicode_cursor_positions_are_supported() {
    let mut input = TextInput::new();
    input.set_text("ążółw");
    assert_eq!(input.cursor_char_pos(), 5);
    assert!(input.move_cursor_left_with_selection(true));
    assert!(input.move_cursor_left_with_selection(true));
    let (selection_start, selection_end) = input.selection_range().expect("selection");
    assert_eq!(&input.text[selection_start..selection_end], "łw");
    assert!(input.backspace());
    assert_eq!(input.text, "ążó");
    assert_eq!(input.cursor_char_pos(), 3);
    assert!(input.select_all());
    assert!(input.insert_text("ć"));
    assert_eq!(input.text, "ć");
    assert_eq!(input.cursor_char_pos(), 1);
    assert!(!input.has_selection());
}

#[test]
fn key_pressed_supports_text_input_selection_shortcuts() {
    let mut ctx = GuiContext::new();
    let input_idx = ctx.add_text_input();
    assert!(ctx.add_child(0, input_idx));
    ctx.set_focus(Some(input_idx));
    assert!(ctx.text_input("abcd"));
    assert!(ctx.key_pressed("shift+left"));
    assert!(ctx.key_pressed("shift+left"));
    assert!(ctx.key_pressed("backspace"));
    match &ctx.widgets[input_idx] {
        lurek2d::ui::context::WidgetKind::TextInput(input) => {
            assert_eq!(input.text, "ab");
            assert_eq!(input.cursor_char_pos(), 2);
        }
        _ => panic!("expected text input"),
    }
    assert!(ctx.key_pressed("ctrl+a"));
    assert!(ctx.text_input("Z"));
    match &ctx.widgets[input_idx] {
        lurek2d::ui::context::WidgetKind::TextInput(input) => {
            assert_eq!(input.text, "Z");
            assert_eq!(input.cursor_char_pos(), 1);
            assert!(!input.has_selection());
        }
        _ => panic!("expected text input"),
    }
}

#[test]
fn key_pressed_supports_text_input_word_navigation_shortcuts() {
    let mut ctx = GuiContext::new();
    let input_idx = ctx.add_text_input();
    assert!(ctx.add_child(0, input_idx));
    ctx.set_focus(Some(input_idx));
    assert!(ctx.text_input("alpha beta gamma"));
    assert!(ctx.key_pressed("ctrl+left"));
    match &ctx.widgets[input_idx] {
        lurek2d::ui::context::WidgetKind::TextInput(input) => {
            assert_eq!(input.cursor_char_pos(), 11);
        }
        _ => panic!("expected text input"),
    }
    assert!(ctx.key_pressed("ctrl+left"));
    match &ctx.widgets[input_idx] {
        lurek2d::ui::context::WidgetKind::TextInput(input) => {
            assert_eq!(input.cursor_char_pos(), 6);
        }
        _ => panic!("expected text input"),
    }
    assert!(ctx.key_pressed("ctrl+right"));
    match &ctx.widgets[input_idx] {
        lurek2d::ui::context::WidgetKind::TextInput(input) => {
            assert_eq!(input.cursor_char_pos(), 11);
        }
        _ => panic!("expected text input"),
    }
}

#[test]
fn layout_loader_uses_control_setters_and_rejects_nonfinite_geometry() {
    let mut switch_ctx = GuiContext::new();
    let switch_idx = load_layout_def(
        &mut switch_ctx,
        &WidgetDef {
            widget_type: "switch".to_string(),
            on: Some(true),
            ..WidgetDef::default()
        },
    )
    .expect("switch layout should load");
    match &switch_ctx.widgets[switch_idx] {
        lurek2d::ui::context::WidgetKind::Switch(sw) => {
            assert!(sw.on);
            assert!((sw.thumb_t - 1.0).abs() < 1e-5);
        }
        _ => panic!("expected switch widget"),
    }

    let mut slider_ctx = GuiContext::new();
    let slider_idx = load_layout_def(
        &mut slider_ctx,
        &WidgetDef {
            widget_type: "slider".to_string(),
            min: Some(0.0),
            max: Some(10.0),
            value: Some(25.0),
            ..WidgetDef::default()
        },
    )
    .expect("slider layout should load");
    match &slider_ctx.widgets[slider_idx] {
        lurek2d::ui::context::WidgetKind::Slider(slider) => {
            assert!((slider.value - 10.0).abs() < 1e-9);
        }
        _ => panic!("expected slider widget"),
    }

    let mut invalid_ctx = GuiContext::new();
    let invalid = load_layout_def(
        &mut invalid_ctx,
        &WidgetDef {
            widget_type: "panel".to_string(),
            x: Some(f32::NAN),
            ..WidgetDef::default()
        },
    );
    assert!(invalid.is_err());
}

#[test]
fn combo_dropdown_clamps_to_viewport_above_trigger() {
    let mut ctx = GuiContext::new();
    ctx.set_viewport(120.0, 100.0);
    let combo_idx = ctx.add_combo_box();
    assert!(ctx.add_child(0, combo_idx));
    if let lurek2d::ui::context::WidgetKind::ComboBox(combo) = &mut ctx.widgets[combo_idx] {
        combo.items = vec!["One".into(), "Two".into(), "Three".into(), "Four".into()];
        combo.set_max_visible_items(3);
        combo.base.x = 10.0;
        combo.base.y = 80.0;
        combo.base.width = 80.0;
        combo.base.height = 20.0;
        combo.base.z_order = 5;
    }

    assert!(ctx.mouse_pressed(20.0, 90.0, 1));
    assert!(ctx.mouse_pressed(20.0, 30.0, 1));
    match &ctx.widgets[combo_idx] {
        lurek2d::ui::context::WidgetKind::ComboBox(combo) => {
            assert_eq!(combo.selected_index, Some(0));
            assert!(!combo.open);
        }
        _ => panic!("expected combo box"),
    }
}

#[test]
fn combo_box_typeahead_selects_matching_items() {
    let mut ctx = GuiContext::new();
    let combo_idx = ctx.add_combo_box();
    assert!(ctx.add_child(0, combo_idx));
    if let lurek2d::ui::context::WidgetKind::ComboBox(combo) = &mut ctx.widgets[combo_idx] {
        combo.items = vec![
            "Apple".into(),
            "Banana".into(),
            "Blueberry".into(),
            "Cherry".into(),
        ];
    }
    ctx.set_focus(Some(combo_idx));
    assert!(ctx.text_input("b"));
    assert!(ctx.text_input("l"));
    match &ctx.widgets[combo_idx] {
        lurek2d::ui::context::WidgetKind::ComboBox(combo) => {
            assert_eq!(combo.selected_index, Some(2));
        }
        _ => panic!("expected combo box"),
    }
}

#[test]
fn dialog_enter_policy_inside_text_input_can_consume_without_submitting() {
    let mut ctx = GuiContext::new();
    let dialog_idx = ctx.add_dialog("Prompt");
    let text_idx = ctx.add_text_input();
    if let lurek2d::ui::context::WidgetKind::Dialog(dialog) = &mut ctx.widgets[dialog_idx] {
        dialog.open = true;
        dialog.content_idx = Some(text_idx);
        dialog.actions.push(lurek2d::ui::extras::DialogAction::new(
            "Save",
            lurek2d::ui::extras::DialogActionRole::Default,
            true,
        ));
        dialog.default_action_idx = Some(0);
    }
    ctx.set_focus(Some(text_idx));

    assert!(ctx.key_pressed("enter"));
    match &ctx.widgets[dialog_idx] {
        lurek2d::ui::context::WidgetKind::Dialog(dialog) => assert!(!dialog.open),
        _ => panic!("expected dialog"),
    }

    let mut ctx = GuiContext::new();
    let dialog_idx = ctx.add_dialog("Prompt");
    let text_idx = ctx.add_text_input();
    if let lurek2d::ui::context::WidgetKind::Dialog(dialog) = &mut ctx.widgets[dialog_idx] {
        dialog.open = true;
        dialog.content_idx = Some(text_idx);
        dialog.actions.push(lurek2d::ui::extras::DialogAction::new(
            "Save",
            lurek2d::ui::extras::DialogActionRole::Default,
            true,
        ));
        dialog.default_action_idx = Some(0);
    }
    if let lurek2d::ui::context::WidgetKind::TextInput(text_input) = &mut ctx.widgets[text_idx] {
        text_input.submit_on_enter = false;
    }
    ctx.set_focus(Some(text_idx));

    assert!(ctx.key_pressed("enter"));
    match &ctx.widgets[dialog_idx] {
        lurek2d::ui::context::WidgetKind::Dialog(dialog) => assert!(dialog.open),
        _ => panic!("expected dialog"),
    }
}

#[test]
fn mouse_filter_pass_receives_and_propagates_clicks() {
    let mut ctx = GuiContext::new();
    let button_idx = ctx.add_button("Save");
    let overlay_idx = ctx.add_panel();
    assert!(ctx.add_child(0, button_idx));
    assert!(ctx.add_child(0, overlay_idx));
    ctx.widgets[button_idx].base_mut().x = 10.0;
    ctx.widgets[button_idx].base_mut().y = 10.0;
    ctx.widgets[button_idx].base_mut().width = 100.0;
    ctx.widgets[button_idx].base_mut().height = 30.0;
    ctx.widgets[button_idx].base_mut().z_order = 1;
    ctx.widgets[overlay_idx].base_mut().x = 0.0;
    ctx.widgets[overlay_idx].base_mut().y = 0.0;
    ctx.widgets[overlay_idx].base_mut().width = 140.0;
    ctx.widgets[overlay_idx].base_mut().height = 60.0;
    ctx.widgets[overlay_idx].base_mut().z_order = 5;
    ctx.widgets[overlay_idx].base_mut().mouse_filter = MouseFilter::Pass;

    assert!(ctx.mouse_pressed(20.0, 20.0, 1));
    assert!(ctx.mouse_released(20.0, 20.0, 1));

    let events = ctx.drain_events();
    assert_eq!(events.len(), 2);
    assert!(matches!(events[0], GuiEvent::Click(idx) if idx == overlay_idx));
    assert!(matches!(events[1], GuiEvent::Click(idx) if idx == button_idx));
}

#[test]
fn accessibility_tree_uses_label_fallback_and_validate_ux_reports_gaps() {
    let mut ctx = GuiContext::new();
    let text_idx = ctx.add_text_input();
    let label_idx = ctx.add_label("Name");
    let button_idx = ctx.add_button("Save");
    let panel_idx = ctx.add_panel();
    assert!(ctx.add_child(0, text_idx));
    assert!(ctx.add_child(0, label_idx));
    assert!(ctx.add_child(0, button_idx));
    assert!(ctx.add_child(0, panel_idx));
    ctx.widgets[label_idx].base_mut().label_for = Some(text_idx);
    ctx.widgets[button_idx].base_mut().id = "dup".into();
    ctx.widgets[panel_idx].base_mut().id = "dup".into();
    ctx.widgets[panel_idx].base_mut().focusable = true;
    ctx.widgets[panel_idx].base_mut().label_for = Some(999);

    let accessibility_tree = ctx.accessibility_tree();
    let text_node = accessibility_tree
        .iter()
        .find(|node| node.widget_idx == text_idx)
        .expect("text input accessibility node");
    let button_node = accessibility_tree
        .iter()
        .find(|node| node.widget_idx == button_idx)
        .expect("button accessibility node");
    assert_eq!(text_node.name, "Name");
    assert_eq!(text_node.role, "textbox");
    assert_eq!(button_node.name, "Save");
    assert_eq!(button_node.role, "button");

    let diagnostics = ctx.validate_ux();
    assert!(diagnostics.iter().any(|diagnostic| {
        diagnostic.widget_idx == Some(panel_idx)
            && diagnostic.message.contains("decorative by default")
    }));
    assert!(diagnostics.iter().any(|diagnostic| {
        diagnostic.widget_idx == Some(panel_idx)
            && diagnostic.message.contains("no accessible name")
    }));
    assert!(diagnostics.iter().any(|diagnostic| {
        diagnostic.widget_idx == Some(panel_idx)
            && diagnostic.message.contains("label_for is only supported")
    }));
    assert!(diagnostics.iter().any(|diagnostic| {
        diagnostic.widget_idx == Some(panel_idx)
            && diagnostic.message.contains("invalid widget 999")
    }));
    assert!(diagnostics.iter().any(|diagnostic| {
        diagnostic.widget_idx == Some(panel_idx) && diagnostic.message.contains("duplicates widget")
    }));
}

#[test]
fn validate_ux_reports_dialog_popup_and_touch_target_diagnostics() {
    let mut ctx = GuiContext::new();
    let dialog_idx = ctx.add_dialog("Confirm");
    let window_idx = ctx.add_gui_window("Inspector");
    let button_idx = ctx.add_button("Tiny");
    assert!(ctx.add_child(0, dialog_idx));
    assert!(ctx.add_child(0, window_idx));
    assert!(ctx.add_child(0, button_idx));

    if let lurek2d::ui::context::WidgetKind::Dialog(dialog) = &mut ctx.widgets[dialog_idx] {
        dialog.open = true;
        dialog.modal = true;
        dialog.closeable = false;
    }
    if let lurek2d::ui::context::WidgetKind::GUIWindow(window) = &mut ctx.widgets[window_idx] {
        window.base.visible = true;
        window.base.is_visible = true;
    }
    ctx.widgets[dialog_idx].base_mut().x = -20.0;
    ctx.widgets[dialog_idx].base_mut().y = 10.0;
    ctx.widgets[dialog_idx].base_mut().width = 120.0;
    ctx.widgets[dialog_idx].base_mut().height = 90.0;
    ctx.widgets[dialog_idx].base_mut().computed_rect = Rect::new(-20.0, 10.0, 120.0, 90.0);
    ctx.widgets[dialog_idx].base_mut().z_order = 10;
    ctx.widgets[window_idx].base_mut().x = 30.0;
    ctx.widgets[window_idx].base_mut().y = 30.0;
    ctx.widgets[window_idx].base_mut().width = 160.0;
    ctx.widgets[window_idx].base_mut().height = 120.0;
    ctx.widgets[window_idx].base_mut().computed_rect = Rect::new(30.0, 30.0, 160.0, 120.0);
    ctx.widgets[window_idx].base_mut().z_order = 10;
    ctx.widgets[button_idx].base_mut().width = 30.0;
    ctx.widgets[button_idx].base_mut().height = 20.0;
    ctx.widgets[button_idx].base_mut().computed_rect = Rect::new(0.0, 0.0, 30.0, 20.0);
    ctx.set_viewport(100.0, 100.0);

    let diagnostics = ctx.validate_ux();
    assert!(diagnostics.iter().any(|diagnostic| {
        diagnostic.widget_idx == Some(dialog_idx)
            && diagnostic.message.contains("no default action")
    }));
    assert!(diagnostics.iter().any(|diagnostic| {
        diagnostic.widget_idx == Some(dialog_idx) && diagnostic.message.contains("no cancel action")
    }));
    assert!(diagnostics.iter().any(|diagnostic| {
        diagnostic.widget_idx == Some(dialog_idx)
            && diagnostic.message.contains("outside the active viewport")
    }));
    assert!(diagnostics.iter().any(|diagnostic| {
        diagnostic.widget_idx == Some(dialog_idx) && diagnostic.message.contains("shares z-order")
    }));
    assert!(diagnostics.iter().any(|diagnostic| {
        diagnostic.widget_idx == Some(button_idx) && diagnostic.message.contains("touch target")
    }));

    if let lurek2d::ui::context::WidgetKind::Dialog(dialog) = &mut ctx.widgets[dialog_idx] {
        dialog
            .actions
            .push(DialogAction::new("OK", DialogActionRole::Default, true));
        dialog.default_action_idx = Some(0);
        dialog
            .actions
            .push(DialogAction::new("Cancel", DialogActionRole::Cancel, true));
        dialog.cancel_action_idx = Some(1);
        dialog.closeable = true;
    }
    let diagnostics = ctx.validate_ux();
    assert!(!diagnostics.iter().any(|diagnostic| {
        diagnostic.widget_idx == Some(dialog_idx)
            && diagnostic.message.contains("no default action")
    }));
    assert!(!diagnostics.iter().any(|diagnostic| {
        diagnostic.widget_idx == Some(dialog_idx) && diagnostic.message.contains("no cancel action")
    }));
}

#[test]
fn tree_view_invalid_parent_is_rooted_and_cycles_return_none_for_depth() {
    let mut tree = TreeView::new();
    let root_idx = tree.add_node("Root", Some(999));
    assert_eq!(root_idx, 0);
    assert_eq!(tree.root_nodes, vec![0]);
    assert_eq!(tree.get_parent_node(0), Some(None));

    let child_idx = tree.add_node("Child", Some(root_idx));
    tree.nodes[root_idx].parent = Some(child_idx);
    assert_eq!(tree.get_node_depth(root_idx), None);
}

#[test]
fn scroll_panel_max_scroll_uses_computed_rect() {
    let mut scroll = ScrollPanel::new();
    scroll.content_width = 400.0;
    scroll.content_height = 300.0;
    scroll.base.width = 100.0;
    scroll.base.height = 100.0;
    scroll.base.computed_rect = Rect::new(0.0, 0.0, 250.0, 200.0);
    let (max_x, max_y) = scroll.max_scroll();
    assert!((max_x - 150.0).abs() < 1e-5);
    assert!((max_y - 100.0).abs() < 1e-5);
}

#[test]
fn ninepatch_invalid_insets_are_sanitized() {
    let mut ninepatch = NinePatch::new();
    ninepatch.image_width = 10;
    ninepatch.image_height = 10;
    ninepatch.inset_left = 8;
    ninepatch.inset_right = 8;
    ninepatch.inset_top = 9;
    ninepatch.inset_bottom = 9;
    ninepatch.base.width = 6.0;
    ninepatch.base.height = 4.0;
    let slices = ninepatch.get_slices();
    assert_eq!(slices.len(), 9);
    assert!(slices.iter().all(|slice| slice.2 >= 0.0 && slice.3 >= 0.0));
    assert!(slices.iter().all(|slice| slice.6 >= 0.0 && slice.7 >= 0.0));
}

#[test]
fn grid_layout_zero_columns_does_not_panic() {
    let mut layout = Layout::new(LayoutDirection::Grid);
    layout.columns = 0;
    layout.children = vec![1];
    layout.base.x = 10.0;
    layout.base.y = 20.0;
    let mut bases = vec![
        WidgetBase::new(WidgetType::Layout),
        WidgetBase::new(WidgetType::Button),
    ];
    layout.perform_layout(&mut bases);
    assert!(bases[1].x.is_finite());
    assert!(bases[1].y.is_finite());
}

#[test]
fn render_to_image_rejects_parent_traversal_paths() {
    let mut ctx = GuiContext::new();
    let result = render_to_image(&mut ctx, 16, 16, "..\\escape.png");
    assert!(result.is_err());
}

#[test]
fn draw_to_image_renders_focus_ring_for_focused_controls() {
    let mut ctx = GuiContext::new();
    ctx.set_viewport(180.0, 120.0);
    let button_idx = ctx.add_button("Button");
    let text_idx = ctx.add_text_input();
    let combo_idx = ctx.add_combo_box();
    assert!(ctx.add_child(0, button_idx));
    assert!(ctx.add_child(0, text_idx));
    assert!(ctx.add_child(0, combo_idx));

    for (idx, rect) in [
        (button_idx, Rect::new(20.0, 20.0, 60.0, 28.0)),
        (text_idx, Rect::new(20.0, 60.0, 80.0, 24.0)),
        (combo_idx, Rect::new(110.0, 20.0, 50.0, 24.0)),
    ] {
        let base = ctx.widgets[idx].base_mut();
        base.x = rect.x;
        base.y = rect.y;
        base.width = rect.width;
        base.height = rect.height;
        base.computed_rect = rect;
        base.visible = true;
        base.is_visible = true;
        base.state = WidgetState::Focused;
    }

    let img = ctx.draw_to_image(180, 120);
    let ring_pixel = Some((76, 153, 255, 204));
    assert_eq!(img.get_pixel(19, 19), ring_pixel);
    assert_eq!(img.get_pixel(19, 59), ring_pixel);
    assert_eq!(img.get_pixel(109, 19), ring_pixel);
}

#[test]
#[ignore = "benchmark"]
fn benchmark_hit_test_with_five_thousand_widgets() {
    let mut ctx = GuiContext::new();
    ctx.set_viewport(1920.0, 1080.0);
    for idx in 0..5_000usize {
        let button_idx = ctx.add_button("bench");
        assert!(ctx.add_child(0, button_idx));
        let col = (idx % 100) as f32;
        let row = (idx / 100) as f32;
        let base = ctx.widgets[button_idx].base_mut();
        base.x = col * 18.0;
        base.y = row * 18.0;
        base.width = 16.0;
        base.height = 16.0;
        base.z_order = idx as i32;
    }

    let start = Instant::now();
    for _ in 0..200 {
        assert!(ctx.mouse_pressed(900.0, 450.0, 1));
        assert!(ctx.mouse_released(900.0, 450.0, 1));
    }
    eprintln!(
        "benchmark_hit_test_with_five_thousand_widgets: {:?}",
        start.elapsed()
    );
}

#[test]
#[ignore = "benchmark"]
fn benchmark_long_text_ellipsis_render() {
    let mut ctx = GuiContext::new();
    ctx.set_viewport(320.0, 80.0);
    let label_idx = ctx.add_label(
        "A very long UI label used to exercise ellipsis layout performance across many repeated renders",
    );
    assert!(ctx.add_child(0, label_idx));
    let base = ctx.widgets[label_idx].base_mut();
    base.width = 140.0;
    base.height = 24.0;
    base.text_ellipsis = true;
    base.text_wrap = false;

    let start = Instant::now();
    for _ in 0..200 {
        let _ = ctx.draw_to_image(320, 80);
    }
    eprintln!("benchmark_long_text_ellipsis_render: {:?}", start.elapsed());
}
