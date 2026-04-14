//! Shared widget base fields, state enum, and type tag.
//!
//! Every concrete widget embeds a [`WidgetBase`] that provides position, size,
//! visibility, enable state, padding, margin, z-order, min/max size
//! constraints, anchor edges, and flexbox layout properties.  The
//! [`WidgetState`] enum models the five visual states a widget can be in
//! (normal, hovered, pressed, focused, disabled), and [`WidgetType`] tags each
//! concrete kind so the theme system can key its style lookup.

/// Visual interaction state of a widget.
///
/// The GUI system transitions a widget through these states in response to
/// input events forwarded from the Lua game loop.  The theme uses the current
/// state to select the appropriate [`WidgetStyle`](super::WidgetStyle).
///
/// # Variants
/// - `Normal` — Default idle appearance.
/// - `Hovered` — Mouse cursor is inside the widget bounds.
/// - `Pressed` — Mouse button is held down on the widget.
/// - `Focused` — Widget has keyboard focus (tab navigation).
/// - `Disabled` — Widget is inactive; input events are ignored.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum WidgetState {
    /// Default idle appearance.
    Normal,
    /// Mouse cursor is inside the widget bounds.
    Hovered,
    /// Mouse button is held down on the widget.
    Pressed,
    /// Widget has keyboard focus (tab navigation).
    Focused,
    /// Widget is inactive; input events are ignored.
    Disabled,
}

impl WidgetState {
    /// Parse a state name string into a [`WidgetState`].
    ///
    /// Accepted values (case-sensitive): `"normal"`, `"hovered"`, `"pressed"`,
    /// `"focused"`, `"disabled"`.
    ///
    /// # Parameters
    /// - `s` — `&str`.
    ///
    /// # Returns
    /// `Option<WidgetState>`.
    pub fn parse_str(s: &str) -> Option<Self> {
        match s {
            "normal" => Some(Self::Normal),
            "hovered" => Some(Self::Hovered),
            "pressed" => Some(Self::Pressed),
            "focused" => Some(Self::Focused),
            "disabled" => Some(Self::Disabled),
            _ => None,
        }
    }

    /// Return the lowercase name of this state.
    ///
    /// # Returns
    /// `&'static str`.
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Normal => "normal",
            Self::Hovered => "hovered",
            Self::Pressed => "pressed",
            Self::Focused => "focused",
            Self::Disabled => "disabled",
        }
    }
}

/// Type tag identifying a concrete widget kind.
///
/// Used as a key (together with [`WidgetState`]) in the theme system so that
/// each widget type can have its own styled appearance per state.
///
/// # Variants
/// - `Button` — Clickable button.
/// - `Label` — Static text label.
/// - `TextInput` — Editable single-line text field.
/// - `CheckBox` — Toggle check box.
/// - `Slider` — Numeric value slider.
/// - `ProgressBar` — Read-only progress indicator.
/// - `ComboBox` — Drop-down selection.
/// - `ListBox` — Scrollable list of selectable items.
/// - `Panel` — Generic container.
/// - `Layout` — Flexbox layout container.
/// - `ScrollPanel` — Scrollable viewport.
/// - `NinePatch` — Nine-slice scalable panel.
/// - `TabBar` — Tabbed page selector.
/// - `Toast` — Auto-expiring notification.
/// - `Separator` — Visual divider line.
/// - `Spacer` — Empty spacing filler.
/// - `TreeView` — Collapsible tree of nodes.
/// - `RadioButton` — Grouped radio button.
/// - `ScrollBar` — Scroll bar for scrollable areas.
/// - `GUIWindow` — Draggable/closeable window.
/// - `SplitPanel` — Resizable split panel.
/// - `DockPanel` — Dock-based layout.
/// - `Toolbar` — Toolbar container.
/// - `MenuBar` — Horizontal menu bar.
/// - `MenuItem` — Menu item.
/// - `Dialog` — Modal dialog.
/// - `StatusBar` — Status bar with sections.
/// # Variants
/// - `Accordion` — Collapsible accordion.
/// - `TooltipPanel` — Rich tooltip panel.
/// - `ColorPicker` — Color picker.
/// - `GUITable` — Data table.
/// - `ImageWidget` — Image display widget.
/// - `SpinBox` — Numeric spin box with increment/decrement buttons.
/// - `Switch` — Toggle on/off pill switch.
/// - `Badge` — Notification badge with count or label.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum WidgetType {
    /// Clickable button.
    Button,
    /// Static text label.
    Label,
    /// Editable single-line text field.
    TextInput,
    /// Toggle check box.
    CheckBox,
    /// Numeric value slider.
    Slider,
    /// Read-only progress indicator.
    ProgressBar,
    /// Drop-down selection.
    ComboBox,
    /// Scrollable list of selectable items.
    ListBox,
    /// Generic container.
    Panel,
    /// Flexbox layout container.
    Layout,
    /// Scrollable viewport.
    ScrollPanel,
    /// Nine-slice scalable panel.
    NinePatch,
    /// Tabbed page selector.
    TabBar,
    /// Auto-expiring notification.
    Toast,
    /// Visual divider line.
    Separator,
    /// Empty spacing filler.
    Spacer,
    /// Collapsible tree of nodes.
    TreeView,
    /// Grouped radio button.
    RadioButton,
    /// Scroll bar for scrollable areas.
    ScrollBar,
    /// Draggable/closeable window.
    GUIWindow,
    /// Resizable split panel.
    SplitPanel,
    /// Dock-based layout.
    DockPanel,
    /// Toolbar container.
    Toolbar,
    /// Horizontal menu bar.
    MenuBar,
    /// Menu item.
    MenuItem,
    /// Modal dialog.
    Dialog,
    /// Status bar with sections.
    StatusBar,
    /// Collapsible accordion.
    Accordion,
    /// Rich tooltip panel.
    TooltipPanel,
    /// Color picker.
    ColorPicker,
    /// Data table.
    GUITable,
    /// Image display widget.
    ImageWidget,
    /// Numeric spin box (text field with increment/decrement buttons).
    SpinBox,
    /// Toggle switch (on/off pill control).
    Switch,
    /// Notification badge with a count or label.
    Badge,
}

impl WidgetType {
    /// Return the lowercase Lua-facing name of this widget type.
    ///
    /// # Returns
    /// `&'static str`.
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
        }
    }

    /// Parse a lowercase widget-type name into a [`WidgetType`].
    ///
    /// # Parameters
    /// - `s` — `&str`.  Accepted values match [`WidgetType::as_str`] output.
    ///
    /// # Returns
    /// `Option<WidgetType>`.
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
            _ => None,
        }
    }

    /// Return the default size `(width, height)` for this widget type on a 16 px grid.
    ///
    /// These values are used by [`WidgetBase::new`] so that initial widget
    /// dimensions feel sensible without requiring the caller to specify them.
    ///
    /// # Returns
    /// `(f32, f32)` — `(width, height)` in pixels.
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
        }
    }
}

/// Shared base properties embedded by every concrete widget.
///
/// `WidgetBase` does not carry rendering or input-handling logic — it stores
/// the common fields that the Lua API and the layout engine operate on.
/// Concrete widgets (e.g. `Button`, `Label`) embed a `WidgetBase` and add
/// type-specific data.
///
/// # Fields
/// - `id` — `String`. Optional identifier for `findById` lookup.
/// - `widget_type` — `WidgetType`. Discriminator for theme key lookup.
/// - `x` — `f32`. Horizontal position relative to parent.
/// - `y` — `f32`. Vertical position relative to parent.
/// - `width` — `f32`. Widget width in pixels.
/// - `height` — `f32`. Widget height in pixels.
/// - `visible` — `bool`. Whether the widget is drawn and receives events.
/// - `enabled` — `bool`. Whether the widget accepts input.
/// - `state` — `WidgetState`. Current visual/interaction state.
/// - `tooltip` — `String`. Tooltip text (displayed externally).
/// - `z_order` — `i32`. Draw layer; higher values draw on top.
/// - `padding` — `[f32; 4]`. Inner padding `[top, right, bottom, left]`.
/// - `margin` — `[f32; 4]`. Outer margin `[top, right, bottom, left]`.
/// - `min_width` — `f32`. Minimum width constraint.
/// - `min_height` — `f32`. Minimum height constraint.
/// - `max_width` — `f32`. Maximum width constraint (`f32::INFINITY` = none).
/// - `max_height` — `f32`. Maximum height constraint (`f32::INFINITY` = none).
/// - `anchor_left` — `Option<f32>`. Left anchor edge offset.
/// - `anchor_top` — `Option<f32>`. Top anchor edge offset.
/// - `anchor_right` — `Option<f32>`. Right anchor edge offset.
/// # Fields
/// - `anchor_bottom` — `Option<f32>`. Bottom anchor edge offset.
/// - `anchor_center_x` — `Option<f32>`. Horizontal centre anchor.
/// - `anchor_center_y` — `Option<f32>`. Vertical centre anchor.
/// - `flex_grow` — `f32`. Flexbox grow factor.
/// - `flex_shrink` — `f32`. Flexbox shrink factor.
/// - `computed_rect` — `crate::math::Rect`. Computed screen-space rectangle after layout.
/// - `is_visible` — `bool`. Whether this widget is visible after layout (not clipped by parent).
#[derive(Debug, Clone)]
pub struct WidgetBase {
    /// Optional identifier for `findById` lookup.
    pub id: String,
    /// Discriminator for theme key lookup.
    pub widget_type: WidgetType,
    /// Horizontal position relative to parent.
    pub x: f32,
    /// Vertical position relative to parent.
    pub y: f32,
    /// Widget width in pixels.
    pub width: f32,
    /// Widget height in pixels.
    pub height: f32,
    /// Whether the widget is drawn and receives events.
    pub visible: bool,
    /// Whether the widget accepts input.
    pub enabled: bool,
    /// Current visual/interaction state.
    pub state: WidgetState,
    /// Tooltip text (displayed externally).
    pub tooltip: String,
    /// Draw layer; higher values draw on top.
    pub z_order: i32,
    /// Inner padding `[top, right, bottom, left]`.
    pub padding: [f32; 4],
    /// Outer margin `[top, right, bottom, left]`.
    pub margin: [f32; 4],
    /// Minimum width constraint.
    pub min_width: f32,
    /// Minimum height constraint.
    pub min_height: f32,
    /// Maximum width constraint (`f32::INFINITY` = none).
    pub max_width: f32,
    /// Maximum height constraint (`f32::INFINITY` = none).
    pub max_height: f32,
    /// Left anchor edge offset.
    pub anchor_left: Option<f32>,
    /// Top anchor edge offset.
    pub anchor_top: Option<f32>,
    /// Right anchor edge offset.
    pub anchor_right: Option<f32>,
    /// Bottom anchor edge offset.
    pub anchor_bottom: Option<f32>,
    /// Horizontal centre anchor.
    pub anchor_center_x: Option<f32>,
    /// Vertical centre anchor.
    pub anchor_center_y: Option<f32>,
    /// Flexbox grow factor.
    pub flex_grow: f32,
    /// Flexbox shrink factor.
    pub flex_shrink: f32,
    /// Computed screen-space rectangle after layout. Written by `run_layout_pass()`.
    pub computed_rect: crate::math::Rect,
    /// Whether this widget is visible after layout (not clipped by parent).
    pub is_visible: bool,
}

impl WidgetBase {
    /// Create a new `WidgetBase` with default values for the given widget type.
    ///
    /// Defaults: position `(0, 0)`, size `(100, 30)`, visible, enabled,
    /// `Normal` state, no tooltip, z-order `0`, zero padding/margin,
    /// min size `(0, 0)`, max size unbounded, no anchors, flex grow/shrink `0`.
    ///
    /// # Parameters
    /// - `widget_type` — `WidgetType`.
    ///
    /// # Returns
    /// `WidgetBase`.
    pub fn new(widget_type: WidgetType) -> Self {
        let (width, height) = widget_type.default_size();
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
            computed_rect: crate::math::Rect::new(0.0, 0.0, 0.0, 0.0),
            is_visible: true,
        }
    }

    /// Test whether a point `(px, py)` lies within this widget's bounding
    /// rectangle.
    ///
    /// # Parameters
    /// - `px` — `f32`. X coordinate to test.
    /// - `py` — `f32`. Y coordinate to test.
    ///
    /// # Returns
    /// `bool` — `true` if the point is inside the widget bounds.
    pub fn contains_point(&self, px: f32, py: f32) -> bool {
        px >= self.x && px <= self.x + self.width && py >= self.y && py <= self.y + self.height
    }

    /// Clear all anchor constraints.
    pub fn clear_anchors(&mut self) {
        self.anchor_left = None;
        self.anchor_top = None;
        self.anchor_right = None;
        self.anchor_bottom = None;
        self.anchor_center_x = None;
        self.anchor_center_y = None;
    }
}

impl Default for WidgetBase {
    fn default() -> Self {
        Self::new(WidgetType::Panel)
    }
}
