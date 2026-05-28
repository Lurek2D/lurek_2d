//! UI widget tree node: the fundamental layout and rendering unit of the UI system.
//!
//! - `Widget` holds layout properties (size, margin, padding), style, and child list.
//! - Widgets are built from Lua tables or TOML layout files and owned by the UI tree.
//! - Layout is computed in a single top-down pass; results are cached until dirty.
//! - Render commands are emitted per-widget in tree order during the UI render phase.
//! - Interaction (click, hover, focus) is dispatched in a second bottom-up hit-test pass.

use crate::runtime::resource_keys::FontKey;

/// Vertical alignment of text inside a text-bearing widget.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum TextVAlign {
    /// Text is pinned to the top edge plus padding.
    Top,
    /// Text is centred vertically in the widget bounds.
    Middle,
    /// Text is pinned to the bottom edge minus padding.
    Bottom,
}
impl TextVAlign {
    /// Parse a lowercase string ("top", "middle", "bottom") to a variant; returns `None` on unknown input.
    pub fn parse_str(s: &str) -> Option<Self> {
        match s {
            "top" => Some(Self::Top),
            "middle" => Some(Self::Middle),
            "bottom" => Some(Self::Bottom),
            _ => None,
        }
    }
    /// Return the canonical lowercase name string for this alignment.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Top => "top",
            Self::Middle => "middle",
            Self::Bottom => "bottom",
        }
    }
}

/// Interaction state of a widget used as a theme lookup key.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum WidgetState {
    /// Idle, no interaction.
    Normal,
    /// Cursor is over the widget.
    Hovered,
    /// Widget is held down / actively interacted with.
    Pressed,
    /// Widget has keyboard focus.
    Focused,
    /// Widget does not respond to interaction.
    Disabled,
    /// Widget is part of the current selection (e.g. a selected list item).
    Selected,
    /// Widget is in a checked or ticked state (e.g. a checked checkbox).
    Checked,
    /// Widget has failed validation or contains erroneous input.
    Invalid,
    /// Widget is read-only: visible and focusable but not editable.
    ReadOnly,
    /// Widget is the primary active element (e.g. the currently open menu).
    Active,
    /// Widget is in an expanded or open state (e.g. an open accordion section).
    Expanded,
}
impl WidgetState {
    /// Parse a lowercase state name to a variant, or return `None` if unrecognised.
    pub fn parse_str(s: &str) -> Option<Self> {
        match s {
            "normal" => Some(Self::Normal),
            "hovered" => Some(Self::Hovered),
            "pressed" => Some(Self::Pressed),
            "focused" => Some(Self::Focused),
            "disabled" => Some(Self::Disabled),
            "selected" => Some(Self::Selected),
            "checked" => Some(Self::Checked),
            "invalid" => Some(Self::Invalid),
            "readonly" => Some(Self::ReadOnly),
            "active" => Some(Self::Active),
            "expanded" => Some(Self::Expanded),
            _ => None,
        }
    }
    /// Return the canonical lowercase name string for this state.
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Normal => "normal",
            Self::Hovered => "hovered",
            Self::Pressed => "pressed",
            Self::Focused => "focused",
            Self::Disabled => "disabled",
            Self::Selected => "selected",
            Self::Checked => "checked",
            Self::Invalid => "invalid",
            Self::ReadOnly => "readonly",
            Self::Active => "active",
            Self::Expanded => "expanded",
        }
    }
}
/// Mouse interaction filter matching Godot's control behavior.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum MouseFilter {
    /// Intercepts mouse events and stops propagation.
    Stop,
    /// Receives mouse events, but passes them down.
    Pass,
    /// Completely transparent to mouse events.
    Ignore,
}
impl MouseFilter {
    /// Parse from a string representation.
    pub fn parse_str(s: &str) -> Option<Self> {
        match s {
            "stop" => Some(Self::Stop),
            "pass" => Some(Self::Pass),
            "ignore" => Some(Self::Ignore),
            _ => None,
        }
    }
    /// Return the canonical string representation.
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Stop => "stop",
            Self::Pass => "pass",
            Self::Ignore => "ignore",
        }
    }
}
/// Discriminated widget class used as the second key in `Theme` style lookups and for dispatch.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum WidgetType {
    /// Push-button.
    Button,
    /// Read-only text display.
    Label,
    /// Editable single-line text field.
    TextInput,
    /// Toggle tick-box.
    CheckBox,
    /// Draggable value slider.
    Slider,
    /// Read-only fill bar.
    ProgressBar,
    /// Drop-down selection list.
    ComboBox,
    /// Scrollable item list.
    ListBox,
    /// Plain rectangular container.
    Panel,
    /// Flow-layout container.
    Layout,
    /// Overflow container with a scroll offset.
    ScrollPanel,
    /// 9-slice stretchable image frame.
    NinePatch,
    /// Tab strip switching between panes.
    TabBar,
    /// Auto-expiring overlay notification.
    Toast,
    /// Visual divider line.
    Separator,
    /// Blank space filler.
    Spacer,
    /// Collapsible hierarchical list.
    TreeView,
    /// Single-select group option.
    RadioButton,
    /// Standalone scroll track + thumb.
    ScrollBar,
    /// Draggable window pane.
    GUIWindow,
    /// Two-pane adjustable divider container.
    SplitPanel,
    /// Dock-zone container.
    DockPanel,
    /// Icon button strip.
    Toolbar,
    /// Application-level menu bar.
    MenuBar,
    /// Single menu item, possibly with sub-items.
    MenuItem,
    /// Modal or non-modal overlay dialog.
    Dialog,
    /// Application footer info bar.
    StatusBar,
    /// Stacked collapsible section list.
    Accordion,
    /// Hover overlay for target widget.
    TooltipPanel,
    /// RGBA/HSV colour selector.
    ColorPicker,
    /// Column-row data grid.
    GUITable,
    /// Static image display.
    ImageWidget,
    /// Numeric step input.
    SpinBox,
    /// On/off toggle with animated thumb.
    Switch,
    /// Numeric count overlay.
    Badge,
    /// Fully caller-drawn widget.
    Custom,
}
impl WidgetType {
    /// Return the canonical lowercase name string for this type.
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Button => "button",
            Self::Label => "label",
            Self::TextInput => "textinput",
            Self::CheckBox => "checkbox",
            Self::Slider => "slider",
            Self::ProgressBar => "progressbar",
            Self::ComboBox => "combobox",
            Self::ListBox => "listbox",
            Self::Panel => "panel",
            Self::Layout => "layout",
            Self::ScrollPanel => "scrollpanel",
            Self::NinePatch => "ninepatch",
            Self::TabBar => "tabbar",
            Self::Toast => "toast",
            Self::Separator => "separator",
            Self::Spacer => "spacer",
            Self::TreeView => "treeview",
            Self::RadioButton => "radiobutton",
            Self::ScrollBar => "scrollbar",
            Self::GUIWindow => "guiwindow",
            Self::SplitPanel => "splitpanel",
            Self::DockPanel => "dockpanel",
            Self::Toolbar => "toolbar",
            Self::MenuBar => "menubar",
            Self::MenuItem => "menuitem",
            Self::Dialog => "dialog",
            Self::StatusBar => "statusbar",
            Self::Accordion => "accordion",
            Self::TooltipPanel => "tooltippanel",
            Self::ColorPicker => "colorpicker",
            Self::GUITable => "guitable",
            Self::ImageWidget => "imagewidget",
            Self::SpinBox => "spinbox",
            Self::Switch => "switch",
            Self::Badge => "badge",
            Self::Custom => "custom",
        }
    }
    /// Parse str. This function is part of the public API.
    pub fn parse_str(s: &str) -> Option<Self> {
        match s {
            "button" => Some(Self::Button),
            "label" => Some(Self::Label),
            "textinput" => Some(Self::TextInput),
            "checkbox" => Some(Self::CheckBox),
            "slider" => Some(Self::Slider),
            "progressbar" => Some(Self::ProgressBar),
            "combobox" => Some(Self::ComboBox),
            "listbox" => Some(Self::ListBox),
            "panel" => Some(Self::Panel),
            "layout" => Some(Self::Layout),
            "scrollpanel" => Some(Self::ScrollPanel),
            "ninepatch" => Some(Self::NinePatch),
            "tabbar" => Some(Self::TabBar),
            "toast" => Some(Self::Toast),
            "separator" => Some(Self::Separator),
            "spacer" => Some(Self::Spacer),
            "treeview" => Some(Self::TreeView),
            "radiobutton" => Some(Self::RadioButton),
            "scrollbar" => Some(Self::ScrollBar),
            "guiwindow" => Some(Self::GUIWindow),
            "splitpanel" => Some(Self::SplitPanel),
            "dockpanel" => Some(Self::DockPanel),
            "toolbar" => Some(Self::Toolbar),
            "menubar" => Some(Self::MenuBar),
            "menuitem" => Some(Self::MenuItem),
            "dialog" => Some(Self::Dialog),
            "statusbar" => Some(Self::StatusBar),
            "accordion" => Some(Self::Accordion),
            "tooltippanel" => Some(Self::TooltipPanel),
            "colorpicker" => Some(Self::ColorPicker),
            "guitable" => Some(Self::GUITable),
            "imagewidget" => Some(Self::ImageWidget),
            "spinbox" => Some(Self::SpinBox),
            "switch" => Some(Self::Switch),
            "badge" => Some(Self::Badge),
            "custom" => Some(Self::Custom),
            _ => None,
        }
    }
    /// Return the default `(width, height)` size in pixels for this widget type.
    pub fn default_size(self) -> (f32, f32) {
        match self {
            Self::Button => (128.0, 32.0),
            Self::Label => (128.0, 16.0),
            Self::TextInput => (192.0, 32.0),
            Self::CheckBox => (128.0, 16.0),
            Self::Slider => (192.0, 16.0),
            Self::ProgressBar => (192.0, 16.0),
            Self::ComboBox => (192.0, 32.0),
            Self::ListBox => (192.0, 128.0),
            Self::Panel => (256.0, 192.0),
            Self::Layout => (256.0, 192.0),
            Self::ScrollPanel => (256.0, 192.0),
            Self::NinePatch => (256.0, 192.0),
            Self::TabBar => (256.0, 32.0),
            Self::Toast => (240.0, 48.0),
            Self::Separator => (256.0, 2.0),
            Self::Spacer => (16.0, 16.0),
            Self::TreeView => (192.0, 192.0),
            Self::RadioButton => (128.0, 16.0),
            Self::ScrollBar => (16.0, 128.0),
            Self::GUIWindow => (320.0, 240.0),
            Self::SplitPanel => (320.0, 240.0),
            Self::DockPanel => (320.0, 240.0),
            Self::Toolbar => (256.0, 32.0),
            Self::MenuBar => (256.0, 32.0),
            Self::MenuItem => (128.0, 32.0),
            Self::Dialog => (320.0, 240.0),
            Self::StatusBar => (320.0, 16.0),
            Self::Accordion => (256.0, 128.0),
            Self::TooltipPanel => (192.0, 64.0),
            Self::ColorPicker => (256.0, 256.0),
            Self::GUITable => (320.0, 256.0),
            Self::ImageWidget => (128.0, 128.0),
            Self::SpinBox => (128.0, 32.0),
            Self::Switch => (64.0, 32.0),
            Self::Badge => (32.0, 16.0),
            Self::Custom => (128.0, 128.0),
        }
    }
}
/// Easing function for property animations.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum EasingFunction {
    Linear,
    SineIn,
    SineOut,
    SineInOut,
    CubicIn,
    CubicOut,
    CubicInOut,
    BounceOut,
    ElasticOut,
    BackOut,
}

impl EasingFunction {
    /// Evaluate the easing curve at normalized time t in [0, 1].
    pub fn eval(self, t: f32) -> f32 {
        match self {
            Self::Linear => t,
            Self::SineIn => 1.0 - (t * std::f32::consts::FRAC_PI_2).cos(),
            Self::SineOut => (t * std::f32::consts::FRAC_PI_2).sin(),
            Self::SineInOut => -((t * std::f32::consts::PI).cos() - 1.0) / 2.0,
            Self::CubicIn => t * t * t,
            Self::CubicOut => 1.0 - (1.0 - t).powi(3),
            Self::CubicInOut => {
                if t < 0.5 {
                    4.0 * t * t * t
                } else {
                    1.0 - (-2.0 * t + 2.0).powi(3) / 2.0
                }
            }
            Self::BounceOut => {
                if t < 1.0 / 2.75 {
                    7.5625 * t * t
                } else if t < 2.0 / 2.75 {
                    let t = t - 1.5 / 2.75;
                    7.5625 * t * t + 0.75
                } else if t < 2.5 / 2.75 {
                    let t = t - 2.25 / 2.75;
                    7.5625 * t * t + 0.9375
                } else {
                    let t = t - 2.625 / 2.75;
                    7.5625 * t * t + 0.984375
                }
            }
            Self::ElasticOut => {
                if t == 0.0 || t == 1.0 {
                    return t;
                }
                let p = 0.3;
                (2.0_f32).powf(-10.0 * t)
                    * ((t - p / 4.0) * (2.0 * std::f32::consts::PI) / p).sin()
                    + 1.0
            }
            Self::BackOut => {
                let c1 = 1.70158;
                let c3 = c1 + 1.0;
                let t = t - 1.0;
                1.0 + c3 * t.powi(3) + c1 * t.powi(2)
            }
        }
    }

    /// Parse easing name from string.
    pub fn parse_str(s: &str) -> Option<Self> {
        match s {
            "linear" => Some(Self::Linear),
            "sine_in" => Some(Self::SineIn),
            "sine_out" => Some(Self::SineOut),
            "sine_in_out" => Some(Self::SineInOut),
            "cubic_in" => Some(Self::CubicIn),
            "cubic_out" => Some(Self::CubicOut),
            "cubic_in_out" => Some(Self::CubicInOut),
            "bounce_out" => Some(Self::BounceOut),
            "elastic_out" => Some(Self::ElasticOut),
            "back_out" => Some(Self::BackOut),
            _ => None,
        }
    }
}

/// Which property a `WidgetTransition` animates.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum WidgetTransitionKind {
    /// Fade the widget's `alpha` from `from` to `to`.
    Alpha {
        /// Starting alpha value in `[0.0, 1.0]`.
        from: f32,
        /// Target alpha value in `[0.0, 1.0]`.
        to: f32,
    },
    /// Slide the widget from one screen position to another.
    Position {
        /// Starting X pixel position.
        from_x: f32,
        /// Starting Y pixel position.
        from_y: f32,
        /// Target X pixel position.
        to_x: f32,
        /// Target Y pixel position.
        to_y: f32,
    },
    /// Scale the widget from one size factor to another.
    Scale {
        /// Starting X scale factor.
        from_sx: f32,
        /// Starting Y scale factor.
        from_sy: f32,
        /// Target X scale factor.
        to_sx: f32,
        /// Target Y scale factor.
        to_sy: f32,
    },
    /// Rotate the widget from one angle to another (radians).
    Rotation {
        /// Starting angle in radians.
        from: f32,
        /// Target angle in radians.
        to: f32,
    },
    /// Tint the widget from one RGBA colour to another.
    Color {
        /// Starting RGBA colour.
        from: [f32; 4],
        /// Target RGBA colour.
        to: [f32; 4],
    },
}
/// Active animation on a `WidgetBase`; evaluated each frame by `GuiContext::update`.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct WidgetTransition {
    /// Discriminator selecting which property is animated.
    pub kind: WidgetTransitionKind,
    /// Total animation duration in seconds.
    pub duration: f32,
    /// Elapsed time since the transition started; reaches `duration` when complete.
    pub elapsed: f32,
    /// When `true`, hide the widget after the transition completes.
    pub hide_on_complete: bool,
    /// Easing function applied to the normalized time.
    pub easing: EasingFunction,
}
impl WidgetTransition {
    /// Create an alpha fade from `from` to `to` over `duration` seconds; optionally hide when done.
    pub fn alpha(from: f32, to: f32, duration: f32, hide_on_complete: bool) -> Self {
        Self {
            kind: WidgetTransitionKind::Alpha { from, to },
            duration: duration.max(0.0),
            elapsed: 0.0,
            hide_on_complete,
            easing: EasingFunction::Linear,
        }
    }
    /// Create a position slide from `(from_x, from_y)` to `(to_x, to_y)` over `duration` seconds.
    pub fn position(from_x: f32, from_y: f32, to_x: f32, to_y: f32, duration: f32) -> Self {
        Self {
            kind: WidgetTransitionKind::Position {
                from_x,
                from_y,
                to_x,
                to_y,
            },
            duration: duration.max(0.0),
            elapsed: 0.0,
            hide_on_complete: false,
            easing: EasingFunction::Linear,
        }
    }
    /// Create a scale transition from `(from_sx, from_sy)` to `(to_sx, to_sy)` over `duration` seconds.
    pub fn scale(from_sx: f32, from_sy: f32, to_sx: f32, to_sy: f32, duration: f32) -> Self {
        Self {
            kind: WidgetTransitionKind::Scale {
                from_sx,
                from_sy,
                to_sx,
                to_sy,
            },
            duration: duration.max(0.0),
            elapsed: 0.0,
            hide_on_complete: false,
            easing: EasingFunction::Linear,
        }
    }
    /// Create a rotation transition from `from` to `to` radians over `duration` seconds.
    pub fn rotation(from: f32, to: f32, duration: f32) -> Self {
        Self {
            kind: WidgetTransitionKind::Rotation { from, to },
            duration: duration.max(0.0),
            elapsed: 0.0,
            hide_on_complete: false,
            easing: EasingFunction::Linear,
        }
    }
    /// Create a color tint transition from `from` RGBA to `to` RGBA over `duration` seconds.
    pub fn color(from: [f32; 4], to: [f32; 4], duration: f32) -> Self {
        Self {
            kind: WidgetTransitionKind::Color { from, to },
            duration: duration.max(0.0),
            elapsed: 0.0,
            hide_on_complete: false,
            easing: EasingFunction::Linear,
        }
    }
    /// Set the easing function on this transition, returning self for chaining.
    pub fn with_easing(mut self, easing: EasingFunction) -> Self {
        self.easing = easing;
        self
    }
}
/// Shared layout, identity, and state fields embedded in every concrete widget struct.
#[derive(Debug, Clone)]
pub struct WidgetBase {
    /// Unique identifier string; may be empty when not addressed by id.
    pub id: String,
    /// Widget class; drives dispatch and default sizing.
    pub widget_type: WidgetType,
    /// Left edge X position in pixels (parent-relative).
    pub x: f32,
    /// Top edge Y position in pixels (parent-relative).
    pub y: f32,
    /// Pixel width of the widget bounding box.
    pub width: f32,
    /// Pixel height of the widget bounding box.
    pub height: f32,
    /// Whether the widget is included in layout and render passes.
    pub visible: bool,
    /// Whether the widget accepts input.
    pub enabled: bool,
    /// Current interaction state; used for theme lookups.
    pub state: WidgetState,
    /// Hover tooltip text; empty string disables the tooltip.
    pub tooltip: String,
    /// Paint order: higher values appear on top.
    pub z_order: i32,
    /// Inner padding `[top, right, bottom, left]` in pixels.
    pub padding: [f32; 4],
    /// Outer margin `[top, right, bottom, left]` in pixels used by layout containers.
    pub margin: [f32; 4],
    /// Minimum pixel width enforced during layout.
    pub min_width: f32,
    /// Minimum pixel height enforced during layout.
    pub min_height: f32,
    /// Maximum pixel width enforced during layout; `f32::INFINITY` = unconstrained.
    pub max_width: f32,
    /// Maximum pixel height enforced during layout; `f32::INFINITY` = unconstrained.
    pub max_height: f32,
    /// Optional pixel offset from the left edge of the parent for anchor layout.
    pub anchor_left: Option<f32>,
    /// Optional pixel offset from the top edge of the parent for anchor layout.
    pub anchor_top: Option<f32>,
    /// Optional pixel inset from the right edge of the parent for anchor layout.
    pub anchor_right: Option<f32>,
    /// Optional pixel inset from the bottom edge of the parent for anchor layout.
    pub anchor_bottom: Option<f32>,
    /// Optional fraction (0.0–1.0) controlling horizontal centering in anchor layout.
    pub anchor_center_x: Option<f32>,
    /// Optional fraction (0.0–1.0) controlling vertical centering in anchor layout.
    pub anchor_center_y: Option<f32>,
    /// Flex growth factor for flex containers; 0.0 = no growth.
    pub flex_grow: f32,
    /// Flex shrink factor for flex containers; 0.0 = no shrink.
    pub flex_shrink: f32,
    /// Overall opacity multiplier applied by the renderer; 1.0 = fully opaque.
    pub alpha: f32,
    /// Optional font override inherited by this widget and its descendants when set.
    pub font_key: Option<FontKey>,
    /// Optional entity ID linking this widget to a game entity.
    pub entity_attachment: Option<u64>,
    /// Optional data-binding key for `GuiContext::apply_bindings`.
    pub bind_key: Option<String>,
    /// Active animations evaluated each frame by `GuiContext::update`.
    pub transitions: Vec<WidgetTransition>,
    /// Pixel rect computed by the last layout pass.
    pub computed_rect: crate::math::Rect,
    /// Effective visibility after layout and parent visibility propagation.
    pub is_visible: bool,
    /// Optional style class name for category specific styling.
    pub style_class: Option<String>,
    /// Mouse filter strategy controlling event interception.
    pub mouse_filter: MouseFilter,
    /// Whether text content wraps at word boundaries when it exceeds the widget width.
    pub text_wrap: bool,
    /// Whether overflowing single-line text is clipped with a trailing "…" ellipsis.
    pub text_ellipsis: bool,
    /// Vertical alignment of text inside the widget bounds.
    pub text_v_align: TextVAlign,
    /// Whether this widget can receive keyboard focus via traversal APIs.
    pub focusable: bool,
    /// Order key for focus traversal; lower values are visited first.
    pub tab_index: i32,
    /// Optional focus traversal group name; empty string means default/global group.
    pub focus_group: String,
    /// Explicit focus neighbor for up-direction traversal.
    pub focus_neighbor_up: Option<usize>,
    /// Explicit focus neighbor for down-direction traversal.
    pub focus_neighbor_down: Option<usize>,
    /// Explicit focus neighbor for left-direction traversal.
    pub focus_neighbor_left: Option<usize>,
    /// Explicit focus neighbor for right-direction traversal.
    pub focus_neighbor_right: Option<usize>,
    /// Semantic widget role identifier used by tooling and accessibility metadata.
    pub role: String,
    /// Human-readable accessible name.
    pub aria_name: String,
    /// Extended accessible description.
    pub description: String,
    /// Optional widget index this widget labels.
    pub label_for: Option<usize>,
    /// Horizontal scale factor applied during rendering (1.0 = normal).
    pub scale_x: f32,
    /// Vertical scale factor applied during rendering (1.0 = normal).
    pub scale_y: f32,
    /// Rotation angle in radians applied during rendering (0.0 = no rotation).
    pub rotation: f32,
    /// RGBA colour tint multiplied with all widget colours during rendering.
    pub color_tint: [f32; 4],
}
impl WidgetBase {
    /// Create a `WidgetBase` with `widget_type` defaults from `WidgetType::default_size`, visible, enabled, alpha 1.
    pub fn new(widget_type: WidgetType) -> Self {
        let (width, height) = widget_type.default_size();
        let mouse_filter = match widget_type {
            WidgetType::Layout
            | WidgetType::Panel
            | WidgetType::Spacer
            | WidgetType::Separator
            | WidgetType::Badge
            | WidgetType::Custom
            | WidgetType::Label => MouseFilter::Ignore,
            _ => MouseFilter::Stop,
        };
        Self {
            id: String::new(),
            widget_type,
            x: 0.0,
            y: 0.0,
            width,
            height,
            visible: true,
            enabled: true,
            state: WidgetState::Normal,
            tooltip: String::new(),
            z_order: 0,
            padding: [0.0; 4],
            margin: [0.0; 4],
            min_width: 0.0,
            min_height: 0.0,
            max_width: f32::INFINITY,
            max_height: f32::INFINITY,
            anchor_left: None,
            anchor_top: None,
            anchor_right: None,
            anchor_bottom: None,
            anchor_center_x: None,
            anchor_center_y: None,
            flex_grow: 0.0,
            flex_shrink: 0.0,
            alpha: 1.0,
            font_key: None,
            entity_attachment: None,
            bind_key: None,
            transitions: Vec::new(),
            computed_rect: crate::math::Rect::new(0.0, 0.0, 0.0, 0.0),
            is_visible: true,
            style_class: None,
            mouse_filter,
            text_wrap: false,
            text_ellipsis: true,
            text_v_align: TextVAlign::Middle,
            focusable: true,
            tab_index: 0,
            focus_group: String::new(),
            focus_neighbor_up: None,
            focus_neighbor_down: None,
            focus_neighbor_left: None,
            focus_neighbor_right: None,
            role: "generic".to_string(),
            aria_name: String::new(),
            description: String::new(),
            label_for: None,
            scale_x: 1.0,
            scale_y: 1.0,
            rotation: 0.0,
            color_tint: [1.0, 1.0, 1.0, 1.0],
        }
    }
    /// Return `true` if `(px, py)` lies within the computed screen rect, falling back to local geometry.
    pub fn contains_point(&self, px: f32, py: f32) -> bool {
        let rect = if self.computed_rect.width > 0.0 && self.computed_rect.height > 0.0 {
            self.computed_rect
        } else {
            crate::math::Rect::new(self.x, self.y, self.width, self.height)
        };
        rect.contains(px, py)
    }
    /// Clear all six anchor fields (`anchor_left`, `anchor_top`, `anchor_right`, `anchor_bottom`, `anchor_center_x`, `anchor_center_y`).
    pub fn clear_anchors(&mut self) {
        self.anchor_left = None;
        self.anchor_top = None;
        self.anchor_right = None;
        self.anchor_bottom = None;
        self.anchor_center_x = None;
        self.anchor_center_y = None;
    }
}
/// Provide a default `WidgetBase` via `Self::new(WidgetType::Panel)`.
impl Default for WidgetBase {
    fn default() -> Self {
        Self::new(WidgetType::Panel)
    }
}
