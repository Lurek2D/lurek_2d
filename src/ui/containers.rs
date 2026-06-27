//! Defines retained UI container widgets that organize child hierarchies before controls or visuals are drawn.
//! Owns panels, windows, split layouts, scroll regions, docks, and nine-slice shells used across the UI tree.
//! Applies vertical, horizontal, and grid arrangement rules so parent widgets can size and place children predictably.
//! Keeps scroll overflow handling local to container state instead of leaking viewport math into leaf controls.
//! Provides scalable frame metadata through nine-slice records so borders survive resize without visual distortion.
//! Acts as the structural boundary between raw widget nodes and higher-level layout orchestration in the context.
//! Open this file when hierarchy composition, docking, scroll behavior, or container sizing rules look incorrect.

use crate::ui::widget::{WidgetBase, WidgetType};
/// Plain box container that groups children with an optional title and scroll flag.
#[derive(Debug, Clone)]
pub struct Panel {
    /// Shared layout, style, and state fields.
    pub base: WidgetBase,
    /// Indices of direct child widgets in the owning `GuiContext`.
    pub children: Vec<usize>,
    /// Optional header title drawn above the panel body.
    pub title: String,
    /// Whether the panel body scrolls when content overflows.
    pub scrollable: bool,
}
impl Panel {
    /// Create an empty panel with no title and scrolling disabled.
    pub fn new() -> Self {
        Self {
            base: WidgetBase::new(WidgetType::Panel),
            children: Vec::new(),
            title: String::new(),
            scrollable: false,
        }
    }
}
/// Provide a default `Panel` via `Self::new()`.
impl Default for Panel {
    fn default() -> Self {
        Self::new()
    }
}
/// Direction along which a `Layout` positions its children.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum LayoutDirection {
    /// Stack children top-to-bottom.
    Vertical,
    /// Stack children left-to-right.
    Horizontal,
    /// Arrange children in a column-wrapped grid.
    Grid,
}
impl LayoutDirection {
    /// Parse a lowercase string to a variant; return `None` for unrecognised values.
    pub fn parse_str(s: &str) -> Option<Self> {
        match s {
            "vertical" | "vbox" | "vboxcontainer" | "column" => Some(Self::Vertical),
            "horizontal" | "hbox" | "hboxcontainer" | "row" => Some(Self::Horizontal),
            "grid" => Some(Self::Grid),
            _ => None,
        }
    }
    /// Return the canonical lowercase string representation of this variant.
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Vertical => "vertical",
            Self::Horizontal => "horizontal",
            Self::Grid => "grid",
        }
    }
}
/// Container that positions children according to a `LayoutDirection`, spacing, and optional grid columns.
#[derive(Debug, Clone)]
pub struct Layout {
    /// Shared layout, style, and state fields.
    pub base: WidgetBase,
    /// Indices of child widgets positioned by this layout.
    pub children: Vec<usize>,
    /// Direction along which children are stacked or gridded.
    pub direction: LayoutDirection,
    /// Extra pixel gap inserted between consecutive children.
    pub spacing: f32,
    /// Number of columns when `direction` is `Grid`; ignored otherwise.
    pub columns: usize,
    /// Whether children wrap to the next row/column when they exceed the layout extent.
    pub wrap: bool,
    /// Cross-axis alignment token, e.g. `"start"`, `"center"`, `"end"`, or `"stretch"`.
    pub align: String,
    /// Main-axis justification token, e.g. `"start"`, `"space-between"`.
    pub justify: String,
}
impl Layout {
    /// Create a layout with the given direction; sets spacing=0, columns=1, wrap=false.
    pub fn new(direction: LayoutDirection) -> Self {
        Self {
            base: WidgetBase::new(WidgetType::Layout),
            children: Vec::new(),
            direction,
            spacing: 0.0,
            columns: 1,
            wrap: false,
            align: "stretch".to_string(),
            justify: "start".to_string(),
        }
    }
    /// Apply this layout's direction and spacing to position the given widget bases in-place.
    pub fn perform_layout(&self, bases: &mut [WidgetBase]) {
        let pad = &self.base.padding;
        let mut cx = self.base.x + pad[3];
        let mut cy = self.base.y + pad[0];
        for &child_idx in &self.children {
            if child_idx >= bases.len() {
                continue;
            }
            let child = &mut bases[child_idx];
            if !child.visible {
                continue;
            }
            child.x = cx + child.margin[3];
            child.y = cy + child.margin[0];
            match self.direction {
                LayoutDirection::Vertical => {
                    cy += child.height + child.margin[0] + child.margin[2] + self.spacing;
                }
                LayoutDirection::Horizontal => {
                    cx += child.width + child.margin[1] + child.margin[3] + self.spacing;
                }
                LayoutDirection::Grid => {
                    let columns = self.columns.max(1);
                    let col = self
                        .children
                        .iter()
                        .position(|&i| i == child_idx)
                        .unwrap_or(0);
                    let col_in_row = col % columns;
                    if col_in_row == columns - 1 {
                        cx = self.base.x + pad[3];
                        cy += child.height + child.margin[0] + child.margin[2] + self.spacing;
                    } else {
                        cx += child.width + child.margin[1] + child.margin[3] + self.spacing;
                    }
                }
            }
        }
    }
}
/// Provide a default vertical `Layout` via `Self::new(LayoutDirection::Vertical)`.
impl Default for Layout {
    fn default() -> Self {
        Self::new(LayoutDirection::Vertical)
    }
}
/// Panel with independently scrollable content area larger than its visible bounds.
#[derive(Debug, Clone)]
pub struct ScrollPanel {
    /// Shared layout, style, and state fields.
    pub base: WidgetBase,
    /// Indices of child widgets clipped and offset by scroll position.
    pub children: Vec<usize>,
    /// Full scrollable content width in pixels.
    pub content_width: f32,
    /// Full scrollable content height in pixels.
    pub content_height: f32,
    /// Current horizontal scroll offset in pixels.
    pub scroll_x: f32,
    /// Current vertical scroll offset in pixels.
    pub scroll_y: f32,
    /// Pixels scrolled per wheel tick.
    pub scroll_speed: f32,
}
impl ScrollPanel {
    /// Create a scroll panel with default content size 100×100 and scroll_speed 20.
    pub fn new() -> Self {
        Self {
            base: WidgetBase::new(WidgetType::ScrollPanel),
            children: Vec::new(),
            content_width: 100.0,
            content_height: 100.0,
            scroll_x: 0.0,
            scroll_y: 0.0,
            scroll_speed: 20.0,
        }
    }
    /// Return `(max_scroll_x, max_scroll_y)` derived from content and widget dimensions.
    pub fn max_scroll(&self) -> (f32, f32) {
        let viewport_w = if self.base.computed_rect.width > 0.0 {
            self.base.computed_rect.width
        } else {
            self.base.width
        };
        let viewport_h = if self.base.computed_rect.height > 0.0 {
            self.base.computed_rect.height
        } else {
            self.base.height
        };
        let mx = (self.content_width - viewport_w).max(0.0);
        let my = (self.content_height - viewport_h).max(0.0);
        (mx, my)
    }
    /// Clamp `scroll_x` and `scroll_y` to the valid `[0, max_scroll]` range.
    pub fn clamp_scroll(&mut self) {
        let (mx, my) = self.max_scroll();
        self.scroll_x = self.scroll_x.clamp(0.0, mx);
        self.scroll_y = self.scroll_y.clamp(0.0, my);
    }
}
/// Provide a default `ScrollPanel` via `Self::new()`.
impl Default for ScrollPanel {
    fn default() -> Self {
        Self::new()
    }
}
/// Layered child container that lays out every child in the same content rectangle but shows one active page.
#[derive(Debug, Clone)]
pub struct StackContainer {
    /// Shared layout, style, and state fields.
    pub base: WidgetBase,
    /// Ordered child widgets hosted as pages.
    pub children: Vec<usize>,
    /// Zero-based active child slot. Lua APIs expose this as one-based.
    pub active_index: usize,
    /// Optional labels used when the stack is presented as a tab container.
    pub tabs: Vec<String>,
    /// Whether a tab strip is reserved above the active content page.
    pub show_tabs: bool,
    /// Height reserved for the tab strip when `show_tabs` is true.
    pub tab_bar_height: f32,
}
impl StackContainer {
    /// Create a stack or tab container. `show_tabs=true` reserves a tab strip above content.
    pub fn new(show_tabs: bool) -> Self {
        let widget_type = if show_tabs {
            WidgetType::TabContainer
        } else {
            WidgetType::StackContainer
        };
        Self {
            base: WidgetBase::new(widget_type),
            children: Vec::new(),
            active_index: 0,
            tabs: Vec::new(),
            show_tabs,
            tab_bar_height: 32.0,
        }
    }
    /// Set the zero-based active child slot; returns false when out of range.
    pub fn set_active_index(&mut self, index: usize) -> bool {
        if index < self.children.len().max(self.tabs.len()) {
            self.active_index = index;
            true
        } else {
            false
        }
    }
    /// Append a tab label used by tab containers.
    pub fn add_tab(&mut self, label: impl Into<String>) {
        self.tabs.push(label.into());
    }
    /// Return the content rectangle inside `rect`, reserving tab strip height when needed.
    pub fn content_rect(&self, rect: crate::math::Rect) -> crate::math::Rect {
        let pad = self.base.padding;
        let tab_h = if self.show_tabs {
            self.tab_bar_height.max(0.0).min(rect.height)
        } else {
            0.0
        };
        crate::math::Rect::new(
            rect.x + pad[3],
            rect.y + tab_h + pad[0],
            (rect.width - pad[1] - pad[3]).max(0.0),
            (rect.height - tab_h - pad[0] - pad[2]).max(0.0),
        )
    }
}
/// Provide a default non-tabbed stack container.
impl Default for StackContainer {
    fn default() -> Self {
        Self::new(false)
    }
}
/// Eight-tuple of `(src_x, src_y, src_w, src_h, dst_x, dst_y, dst_w, dst_h)` describing one 9-patch tile region.
pub type NineSlice = (f32, f32, f32, f32, f32, f32, f32, f32);
/// 9-patch scalable border widget; divides a source image into 9 regions for resolution-independent borders.
#[derive(Debug, Clone)]
pub struct NinePatch {
    /// Shared layout, style, and state fields.
    pub base: WidgetBase,
    /// Pixel inset from the left edge of the source image to the inner column.
    pub inset_left: u32,
    /// Pixel inset from the top edge of the source image to the inner row.
    pub inset_top: u32,
    /// Pixel inset from the right edge of the source image to the inner column.
    pub inset_right: u32,
    /// Pixel inset from the bottom edge of the source image to the inner row.
    pub inset_bottom: u32,
    /// Full pixel width of the source image.
    pub image_width: u32,
    /// Full pixel height of the source image.
    pub image_height: u32,
}
impl NinePatch {
    /// Create a nine-patch widget with zero insets and zero source image size.
    pub fn new() -> Self {
        Self {
            base: WidgetBase::new(WidgetType::NinePatch),
            inset_left: 0,
            inset_top: 0,
            inset_right: 0,
            inset_bottom: 0,
            image_width: 0,
            image_height: 0,
        }
    }
    /// Return the 9 `NineSlice` tuples describing source and destination rects for each patch region.
    pub fn get_slices(&self) -> Vec<NineSlice> {
        let mut il = self.inset_left as f32;
        let mut it = self.inset_top as f32;
        let mut ir = self.inset_right as f32;
        let mut ib = self.inset_bottom as f32;
        let iw = self.image_width as f32;
        let ih = self.image_height as f32;
        let dw = self.base.width;
        let dh = self.base.height;
        let dx = self.base.x;
        let dy = self.base.y;
        if iw <= 0.0 || ih <= 0.0 || dw <= 0.0 || dh <= 0.0 {
            return Vec::new();
        }
        let inset_w = il + ir;
        if inset_w > iw && inset_w > 0.0 {
            let scale = iw / inset_w;
            il *= scale;
            ir *= scale;
        }
        let inset_h = it + ib;
        if inset_h > ih && inset_h > 0.0 {
            let scale = ih / inset_h;
            it *= scale;
            ib *= scale;
        }
        let mut dil = il;
        let mut dir = ir;
        let border_w = dil + dir;
        if border_w > dw && border_w > 0.0 {
            let scale = dw / border_w;
            dil *= scale;
            dir *= scale;
        }
        let mut dit = it;
        let mut dib = ib;
        let border_h = dit + dib;
        if border_h > dh && border_h > 0.0 {
            let scale = dh / border_h;
            dit *= scale;
            dib *= scale;
        }
        let sm = (iw - il - ir).max(0.0);
        let smh = (ih - it - ib).max(0.0);
        let dm = (dw - dil - dir).max(0.0);
        let dmh = (dh - dit - dib).max(0.0);
        vec![
            (0.0, 0.0, il, it, dx, dy, dil, dit),
            (il, 0.0, sm, it, dx + dil, dy, dm, dit),
            (iw - ir, 0.0, ir, it, dx + dw - dir, dy, dir, dit),
            (0.0, it, il, smh, dx, dy + dit, dil, dmh),
            (il, it, sm, smh, dx + dil, dy + dit, dm, dmh),
            (iw - ir, it, ir, smh, dx + dw - dir, dy + dit, dir, dmh),
            (0.0, ih - ib, il, ib, dx, dy + dh - dib, dil, dib),
            (il, ih - ib, sm, ib, dx + dil, dy + dh - dib, dm, dib),
            (
                iw - ir,
                ih - ib,
                ir,
                ib,
                dx + dw - dir,
                dy + dh - dib,
                dir,
                dib,
            ),
        ]
    }
}
/// Provide a default `NinePatch` via `Self::new()`.
impl Default for NinePatch {
    fn default() -> Self {
        Self::new()
    }
}
/// Floating window with an optional title bar, close button, drag, and resize support.
#[derive(Debug, Clone)]
pub struct GUIWindow {
    /// Shared layout, style, and state fields.
    pub base: WidgetBase,
    /// Title bar text.
    pub title: String,
    /// Whether a close button is rendered on the title bar.
    pub closeable: bool,
    /// Whether the window can be repositioned by dragging the title bar.
    pub draggable: bool,
    /// Whether the window can be resized by dragging its edges.
    pub resizable: bool,
    /// Indices of child widgets hosted inside this window.
    pub children: Vec<usize>,
}
impl GUIWindow {
    /// Create a window with the given title; closeable and draggable by default, not resizable.
    pub fn new(title: impl Into<String>) -> Self {
        Self {
            base: WidgetBase::new(WidgetType::GUIWindow),
            title: title.into(),
            closeable: true,
            draggable: true,
            resizable: false,
            children: Vec::new(),
        }
    }
}
/// Two-pane container split by a draggable divider along a given orientation.
#[derive(Debug, Clone)]
pub struct SplitPanel {
    /// Shared layout, style, and state fields.
    pub base: WidgetBase,
    /// Divider orientation: `"horizontal"` or `"vertical"`.
    pub orientation: String,
    /// Divider position as a fraction in [0, 1] of the total extent.
    pub split_position: f32,
    /// Minimum pixel size each pane may be resized to.
    pub min_panel_size: f32,
    /// Index of the first (top or left) child widget, if any.
    pub first_child: Option<usize>,
    /// Index of the second (bottom or right) child widget, if any.
    pub second_child: Option<usize>,
}
impl SplitPanel {
    /// Create a split panel with the given orientation; split_position defaults to 0.5.
    pub fn new(orientation: impl Into<String>) -> Self {
        Self {
            base: WidgetBase::new(WidgetType::SplitPanel),
            orientation: orientation.into(),
            split_position: 0.5,
            min_panel_size: 50.0,
            first_child: None,
            second_child: None,
        }
    }
}
/// Docking container that attaches children to named edges (`"top"`, `"bottom"`, `"left"`, `"right"`, `"fill"`).
#[derive(Debug, Clone)]
pub struct DockPanel {
    /// Shared layout, style, and state fields.
    pub base: WidgetBase,
    /// Pairs of `(child_index, dock_edge)` for each docked child.
    pub docked: Vec<(usize, String)>,
    /// Per-edge size overrides as `(edge, pixel_size)` pairs.
    pub split_sizes: Vec<(String, f32)>,
}
impl DockPanel {
    /// Create an empty dock panel with no docked children.
    pub fn new() -> Self {
        Self {
            base: WidgetBase::new(WidgetType::DockPanel),
            docked: Vec::new(),
            split_sizes: Vec::new(),
        }
    }
}
/// Provide a default `DockPanel` via `Self::new()`.
impl Default for DockPanel {
    fn default() -> Self {
        Self::new()
    }
}
