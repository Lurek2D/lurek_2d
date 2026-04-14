//! Rust unit tests for private UI internals not reachable through the `lurek.*` Lua API.
//!
//! **Rule**: If behaviour can be observed via `lurek.ui.*` it MUST be tested in
//! `tests/lua/unit/test_gui.lua` instead. Only struct-field defaults, non-public
//! helpers, and pure-Rust invariants that cannot survive the Lua call boundary
//! belong here.
//!
//! Naming convention: `<subject>_<scenario>_<expected>` — no `test_` prefix.
//! Float comparisons use `(a - b).abs() < 1e-5` — never `assert_eq!` on floats.

use lurek2d::ui::theme::WidgetStyle;
use lurek2d::ui::widget::{WidgetBase, WidgetType};

// ─── WidgetStyle field defaults ───────────────────────────────────────────────
// WidgetStyle is an internal struct with no Lua getter; its default values are
// invisible to the script layer and must be confirmed here.

#[test]
fn widget_style_default_shadow_alpha_is_zero() {
    let s = WidgetStyle::default();
    assert!((s.shadow_color[3]).abs() < 1e-5, "default shadow alpha must be zero");
}

#[test]
fn widget_style_default_highlight_alpha_is_zero() {
    let s = WidgetStyle::default();
    assert!((s.highlight_alpha).abs() < 1e-5, "default highlight_alpha must be zero");
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

// ─── WidgetType::default_size ─────────────────────────────────────────────────
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

// ─── WidgetBase::new sizing ───────────────────────────────────────────────────
// The fact that WidgetBase uses default_size (not a 100×30 hardcode) is a
// pure-Rust invariant — Lua cannot observe the raw width/height before any
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

//!
//! Naming convention: `<subject>_<scenario>_<expected>` — no `test_` prefix.
//! Float comparisons use `(a - b).abs() < 1e-5` — never `assert_eq!` on floats.

use lurek2d::ui::controls::{SpinBox, Switch};
use lurek2d::ui::context::GuiContext;
use lurek2d::ui::extras::Badge;
use lurek2d::ui::theme::Theme;
use lurek2d::ui::widget::WidgetBase;

// ─── WidgetStyle ──────────────────────────────────────────────────────────────

#[test]
fn widget_style_default_has_zero_shadow_alpha() {
    use lurek2d::ui::theme::WidgetStyle;
    let s = WidgetStyle::default();
    assert!((s.shadow_color[3]).abs() < 1e-5, "default shadow alpha must be zero");
}

#[test]
fn widget_style_default_has_zero_highlight_alpha() {
    use lurek2d::ui::theme::WidgetStyle;
    let s = WidgetStyle::default();
    assert!((s.highlight_alpha).abs() < 1e-5, "default highlight_alpha must be zero");
}

#[test]
fn widget_style_default_gradient_end_is_none() {
    use lurek2d::ui::theme::WidgetStyle;
    assert!(WidgetStyle::default().gradient_end.is_none());
}

#[test]
fn widget_style_default_text_align_is_center() {
    use lurek2d::ui::theme::WidgetStyle;
    assert_eq!(WidgetStyle::default().text_align, "center");
}

// ─── WidgetType::default_size ─────────────────────────────────────────────────

#[test]
fn widget_type_button_default_size_is_16px_aligned() {
    use lurek2d::ui::widget::WidgetType;
    let (w, h) = WidgetType::Button.default_size();
    assert_eq!(w % 16.0, 0.0, "Button width must be 16px aligned");
    assert_eq!(h % 16.0, 0.0, "Button height must be 16px aligned");
}

#[test]
fn widget_type_spin_box_default_size_is_nonzero() {
    use lurek2d::ui::widget::WidgetType;
    let (w, h) = WidgetType::SpinBox.default_size();
    assert!(w > 0.0 && h > 0.0);
}

// ─── WidgetBase::new ──────────────────────────────────────────────────────────

#[test]
fn widget_base_new_uses_type_default_size() {
    use lurek2d::ui::widget::WidgetType;
    let (expected_w, expected_h) = WidgetType::Button.default_size();
    let base = WidgetBase::new(WidgetType::Button);
    assert!((base.width - expected_w).abs() < 1e-5);
    assert!((base.height - expected_h).abs() < 1e-5);
}

// ─── SpinBox ──────────────────────────────────────────────────────────────────

#[test]
fn spin_box_new_value_clamped_to_min() {
    let sb = SpinBox::new(5.0, 20.0);
    assert!((sb.value - 5.0).abs() < 1e-5, "initial value should be min");
}

#[test]
fn spin_box_increment_respects_step() {
    let mut sb = SpinBox::new(0.0, 10.0);
    sb.step = 2.0;
    sb.increment();
    assert!((sb.value - 2.0).abs() < 1e-5);
}

#[test]
fn spin_box_decrement_clamps_at_min() {
    let mut sb = SpinBox::new(0.0, 10.0);
    sb.decrement(); // already at min
    assert!((sb.value - 0.0).abs() < 1e-5, "value must not go below min");
}

#[test]
fn spin_box_increment_clamps_at_max() {
    let mut sb = SpinBox::new(0.0, 1.0);
    sb.step = 10.0;
    sb.increment();
    assert!(
        (sb.value - 1.0).abs() < 1e-5,
        "value must not exceed max after increment"
    );
}

#[test]
fn spin_box_set_value_clamps_to_range() {
    let mut sb = SpinBox::new(0.0, 10.0);
    sb.set_value(99.0);
    assert!((sb.value - 10.0).abs() < 1e-5, "set_value must clamp to max");
    sb.set_value(-5.0);
    assert!((sb.value - 0.0).abs() < 1e-5, "set_value must clamp to min");
}

#[test]
fn spin_box_set_range_updates_fields() {
    let mut sb = SpinBox::new(0.0, 10.0);
    sb.set_range(5.0, 50.0);
    assert!((sb.min - 5.0).abs() < 1e-5);
    assert!((sb.max - 50.0).abs() < 1e-5);
}

// ─── Switch ───────────────────────────────────────────────────────────────────

#[test]
fn switch_new_off_has_thumb_t_zero() {
    let sw = Switch::new(false);
    assert!((sw.thumb_t).abs() < 1e-5, "thumb_t must be 0 when off");
}

#[test]
fn switch_new_on_has_thumb_t_one() {
    let sw = Switch::new(true);
    assert!((sw.thumb_t - 1.0).abs() < 1e-5, "thumb_t must be 1.0 when on");
}

#[test]
fn switch_toggle_flips_on_state() {
    let mut sw = Switch::new(false);
    sw.toggle();
    assert!(sw.on, "toggle should flip off → on");
    sw.toggle();
    assert!(!sw.on, "toggle should flip on → off");
}

#[test]
fn switch_set_on_true_updates_thumb_t() {
    let mut sw = Switch::new(false);
    sw.set_on(true);
    assert!(sw.on);
    assert!((sw.thumb_t - 1.0).abs() < 1e-5);
}

#[test]
fn switch_set_on_false_updates_thumb_t() {
    let mut sw = Switch::new(true);
    sw.set_on(false);
    assert!(!sw.on);
    assert!((sw.thumb_t).abs() < 1e-5);
}

// ─── Badge ────────────────────────────────────────────────────────────────────

#[test]
fn badge_new_stores_count() {
    let b = Badge::new(7);
    assert_eq!(b.count, 7);
}

#[test]
fn badge_default_max_is_99() {
    let b = Badge::new(0);
    assert_eq!(b.max_display, 99);
}

#[test]
fn badge_display_text_below_max_shows_count() {
    let b = Badge::new(42);
    assert_eq!(b.display_text(), "42");
}

#[test]
fn badge_display_text_above_max_shows_plus_notation() {
    let b = Badge::new(200);
    assert_eq!(b.display_text(), "99+");
}

#[test]
fn badge_display_text_at_max_shows_count() {
    let b = Badge::new(99);
    assert_eq!(b.display_text(), "99");
}

#[test]
fn badge_set_count_updates_display() {
    let mut b = Badge::new(0);
    b.set_count(5);
    assert_eq!(b.count, 5);
    assert_eq!(b.display_text(), "5");
}

// ─── Theme::default_dark ──────────────────────────────────────────────────────

#[test]
fn theme_default_dark_has_button_style() {
    use lurek2d::ui::widget::{WidgetState, WidgetType};
    let theme = Theme::default_dark();
    let style = theme.get_style(WidgetType::Button, WidgetState::Normal);
    assert!(style.is_some(), "default_dark must include a style for Button/Normal");
}

#[test]
fn theme_default_dark_button_has_nonzero_corner_radius() {
    use lurek2d::ui::widget::{WidgetState, WidgetType};
    let theme = Theme::default_dark();
    let style = theme
        .get_style(WidgetType::Button, WidgetState::Normal)
        .unwrap();
    assert!(style.corner_radius > 0.0, "Button in default_dark must have corner_radius > 0");
}

// ─── GuiContext ───────────────────────────────────────────────────────────────

#[test]
fn gui_context_new_is_dirty() {
    let ctx = GuiContext::new();
    assert!(ctx.dirty, "GuiContext must start dirty");
}

#[test]
fn gui_context_flush_cache_returns_true_when_dirty() {
    let mut ctx = GuiContext::new();
    assert!(ctx.flush_cache(), "flush_cache must return true on first call");
}

#[test]
fn gui_context_flush_cache_returns_false_when_clean() {
    let mut ctx = GuiContext::new();
    ctx.flush_cache(); // consume dirty flag
    assert!(!ctx.flush_cache(), "flush_cache must return false when not dirty");
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
    assert!(ctx.theme.is_some(), "set_default_theme must install a non-None theme");
}

#[test]
fn gui_context_add_spin_box_returns_valid_index() {
    let mut ctx = GuiContext::new();
    let idx = ctx.add_spin_box(0.0, 10.0);
    assert!(idx < ctx.widgets.len(), "returned index must be within widgets pool");
}
