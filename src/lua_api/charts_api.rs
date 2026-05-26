//! `lurek.charts` -- Chart creation, configuration, and rendering bindings.

use crate::charts::config::{ChartConfig, ChartMargin, ChartSeries, DEFAULT_PALETTE};
use crate::charts::{AreaChart, BarChart, LineChart, PieChart, ScatterPlot};
use mlua::prelude::*;
use std::cell::{Cell, RefCell};

// ---------------------------------------------------------------------------
// Lua wrapper types
// ---------------------------------------------------------------------------

/// Lua userdata for rendering a connected line series chart.
struct LuaLineChart {
    inner: RefCell<LineChart>,
    count: Cell<usize>,
}

/// Lua userdata for rendering a vertical bar series chart.
struct LuaBarChart {
    inner: RefCell<BarChart>,
    count: Cell<usize>,
}

/// Lua-visible scatter plot userdata.
struct LuaScatterPlot {
    inner: RefCell<ScatterPlot>,
    count: Cell<usize>,
}

/// Lua userdata for rendering a pie slice chart.
struct LuaPieChart {
    inner: RefCell<PieChart>,
    count: Cell<usize>,
}

/// Lua userdata for rendering a stacked area series chart.
struct LuaAreaChart {
    inner: RefCell<AreaChart>,
    count: Cell<usize>,
}

// ---------------------------------------------------------------------------
// Config parsing
// ---------------------------------------------------------------------------

/// Parse an optional Lua config table into a `ChartConfig`, using defaults
/// for any missing fields exposed by the lurek engine.
fn parse_chart_config(config: Option<LuaTable>) -> LuaResult<ChartConfig> {
    let mut cfg = ChartConfig::default();
    let tbl = match config {
        Some(t) => t,
        None => return Ok(cfg),
    };

    if let Ok(w) = tbl.get::<_, u32>("width") {
        cfg.width = w.max(1);
    }
    if let Ok(h) = tbl.get::<_, u32>("height") {
        cfg.height = h.max(1);
    }
    if let Ok(t) = tbl.get::<_, String>("title") {
        cfg.title = Some(t);
    }
    if let Ok(c) = tbl.get::<_, LuaTable>("bgColor") {
        cfg.bg_color = parse_color4(&c)?;
    }
    if let Ok(c) = tbl.get::<_, LuaTable>("axisColor") {
        cfg.axis_color = parse_color4(&c)?;
    }
    if let Ok(c) = tbl.get::<_, LuaTable>("gridColor") {
        cfg.grid_color = parse_color4(&c)?;
    }
    if let Ok(c) = tbl.get::<_, LuaTable>("labelColor") {
        cfg.label_color = parse_color4(&c)?;
    }
    if let Ok(v) = tbl.get::<_, bool>("showGrid") {
        cfg.show_grid = v;
    }
    if let Ok(v) = tbl.get::<_, bool>("showLegend") {
        cfg.show_legend = v;
    }
    if let Ok(m) = tbl.get::<_, LuaTable>("margin") {
        cfg.margin = parse_margin(&m)?;
    }
    Ok(cfg)
}

/// Parse {r, g, b, a} or {[1],[2],[3],[4]} color table.
fn parse_color4(tbl: &LuaTable) -> LuaResult<[f32; 4]> {
    let r: f32 = tbl.get(1)?;
    let g: f32 = tbl.get(2)?;
    let b: f32 = tbl.get(3)?;
    let a: f32 = tbl.get::<_, f32>(4).unwrap_or(1.0);
    Ok([r.clamp(0.0, 1.0), g.clamp(0.0, 1.0), b.clamp(0.0, 1.0), a.clamp(0.0, 1.0)])
}

/// Parse margin table: {top, right, bottom, left}.
fn parse_margin(tbl: &LuaTable) -> LuaResult<ChartMargin> {
    Ok(ChartMargin {
        top: tbl.get::<_, f32>("top").unwrap_or(30.0).max(0.0),
        right: tbl.get::<_, f32>("right").unwrap_or(20.0).max(0.0),
        bottom: tbl.get::<_, f32>("bottom").unwrap_or(40.0).max(0.0),
        left: tbl.get::<_, f32>("left").unwrap_or(50.0).max(0.0),
    })
}

/// Parse series data from Lua table of {{x,y},{x,y},...} into Vec<(f32,f32)>.
fn parse_series_data(data: &LuaTable) -> LuaResult<Vec<(f32, f32)>> {
    let mut points = Vec::new();
    for pair in data.sequence_values::<LuaTable>() {
        let pt = pair?;
        let x: f32 = pt.get(1)?;
        let y: f32 = pt.get(2)?;
        points.push((x, y));
    }
    Ok(points)
}

/// Get a palette color by 0-based index (wraps around).
fn palette_color(index: usize) -> [f32; 4] {
    DEFAULT_PALETTE[index % DEFAULT_PALETTE.len()]
}

// ---------------------------------------------------------------------------
// LuaUserData implementations
// ---------------------------------------------------------------------------

impl LuaUserData for LuaLineChart {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- addSeries --
        /// Add a named data series to the line chart.
        /// @param | name | string | Display name of the series.
        /// @param | data | table | Array of {x, y} point tables.
        /// @param | color | table|nil | Optional RGBA color {r, g, b, a}.
        methods.add_method("addSeries", |_, this, (name, data, color): (String, LuaTable, Option<LuaTable>)| {
            let points = parse_series_data(&data)?;
            let c = match color {
                Some(ref t) => parse_color4(t)?,
                None => palette_color(this.count.get()),
            };
            this.count.set(this.count.get() + 1);
            this.inner.borrow_mut().add_series(ChartSeries {
                name,
                color: c,
                data: points,
            });
            Ok(())
        });

        // -- clear --
        /// Removes all data series from this chart.
        methods.add_method("clear", |_, this, ()| {
            this.inner.borrow_mut().clear();
            this.count.set(0);
            Ok(())
        });

        // -- setTitle --
        /// Set or update the chart's displayed title.
        /// @param | title | string | New chart title text.
        methods.add_method("setTitle", |_, this, title: String| {
            this.inner.borrow_mut().config.title = Some(title);
            Ok(())
        });

        // -- render --
        /// Renders the chart contents into a new pixel buffer.
        /// @return | number | Output width in pixels.
        /// @return | number | Output height in pixels.
        /// @return | string | RGBA8 pixel data as a binary string.
        methods.add_method("render", |lua, this, ()| {
            let chart = this.inner.borrow();
            let w = chart.config.width;
            let h = chart.config.height;
            let mut buf = vec![0u8; (w * h * 4) as usize];
            chart.render(&mut buf);
            Ok((w, h, lua.create_string(&buf)?))
        });

        // -- getWidth --
        /// Get the chart output width in pixels.
        /// @return | number | Width in pixels.
        methods.add_method("getWidth", |_, this, ()| {
            Ok(this.inner.borrow().config.width)
        });

        // -- getHeight --
        /// Get the chart output height in pixels.
        /// @return | number | Height in pixels.
        methods.add_method("getHeight", |_, this, ()| {
            Ok(this.inner.borrow().config.height)
        });
    }
}

impl LuaUserData for LuaBarChart {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- addSeries --
        /// Add a named data series to the bar chart.
        /// @param | name | string | Display name of the series.
        /// @param | data | table | Array of {x, y} point tables.
        /// @param | color | table|nil | Optional RGBA color {r, g, b, a}.
        methods.add_method("addSeries", |_, this, (name, data, color): (String, LuaTable, Option<LuaTable>)| {
            let points = parse_series_data(&data)?;
            let c = match color {
                Some(ref t) => parse_color4(t)?,
                None => palette_color(this.count.get()),
            };
            this.count.set(this.count.get() + 1);
            this.inner.borrow_mut().add_series(ChartSeries {
                name,
                color: c,
                data: points,
            });
            Ok(())
        });

        // -- clear --
        /// Removes all data series from this chart.
        methods.add_method("clear", |_, this, ()| {
            this.inner.borrow_mut().clear();
            this.count.set(0);
            Ok(())
        });

        // -- setBarWidth --
        /// Set the pixel width of individual bars in this chart.
        /// @param | width | number | Bar width in pixels (minimum 1).
        methods.add_method("setBarWidth", |_, this, width: f32| {
            this.inner.borrow_mut().set_bar_width(width);
            Ok(())
        });

        // -- setTitle --
        /// Set or update the chart's displayed title.
        /// @param | title | string | New chart title text.
        methods.add_method("setTitle", |_, this, title: String| {
            this.inner.borrow_mut().config.title = Some(title);
            Ok(())
        });

        // -- render --
        /// Renders the chart contents into a new pixel buffer.
        /// @return | number | Output width in pixels.
        /// @return | number | Output height in pixels.
        /// @return | string | RGBA8 pixel data as a binary string.
        methods.add_method("render", |lua, this, ()| {
            let chart = this.inner.borrow();
            let w = chart.config.width;
            let h = chart.config.height;
            let mut buf = vec![0u8; (w * h * 4) as usize];
            chart.render(&mut buf);
            Ok((w, h, lua.create_string(&buf)?))
        });

        // -- getWidth --
        /// Get the chart output width in pixels.
        /// @return | number | Width in pixels.
        methods.add_method("getWidth", |_, this, ()| {
            Ok(this.inner.borrow().config.width)
        });

        // -- getHeight --
        /// Get the chart output height in pixels.
        /// @return | number | Height in pixels.
        methods.add_method("getHeight", |_, this, ()| {
            Ok(this.inner.borrow().config.height)
        });
    }
}

impl LuaUserData for LuaScatterPlot {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- addSeries --
        /// Add a named data series to the scatter plot.
        /// @param | name | string | Display name of the series.
        /// @param | data | table | Array of {x, y} point tables.
        /// @param | color | table|nil | Optional RGBA color {r, g, b, a}.
        methods.add_method("addSeries", |_, this, (name, data, color): (String, LuaTable, Option<LuaTable>)| {
            let points = parse_series_data(&data)?;
            let c = match color {
                Some(ref t) => parse_color4(t)?,
                None => palette_color(this.count.get()),
            };
            this.count.set(this.count.get() + 1);
            this.inner.borrow_mut().add_series(ChartSeries {
                name,
                color: c,
                data: points,
            });
            Ok(())
        });

        // -- clear --
        /// Removes all data series from this chart.
        methods.add_method("clear", |_, this, ()| {
            this.inner.borrow_mut().clear();
            this.count.set(0);
            Ok(())
        });

        // -- setDotRadius --
        /// Set the radius of the dot drawn for each data point.
        /// @param | r | number | Dot radius in pixels (minimum 1).
        methods.add_method("setDotRadius", |_, this, r: f32| {
            this.inner.borrow_mut().set_dot_radius(r);
            Ok(())
        });

        // -- setTitle --
        /// Set or update the chart's displayed title.
        /// @param | title | string | New chart title text.
        methods.add_method("setTitle", |_, this, title: String| {
            this.inner.borrow_mut().config.title = Some(title);
            Ok(())
        });

        // -- render --
        /// Renders the chart contents into a new pixel buffer.
        /// @return | number | Output width in pixels.
        /// @return | number | Output height in pixels.
        /// @return | string | RGBA8 pixel data as a binary string.
        methods.add_method("render", |lua, this, ()| {
            let chart = this.inner.borrow();
            let w = chart.config.width;
            let h = chart.config.height;
            let mut buf = vec![0u8; (w * h * 4) as usize];
            chart.render(&mut buf);
            Ok((w, h, lua.create_string(&buf)?))
        });

        // -- getWidth --
        /// Get the chart output width in pixels.
        /// @return | number | Width in pixels.
        methods.add_method("getWidth", |_, this, ()| {
            Ok(this.inner.borrow().config.width)
        });

        // -- getHeight --
        /// Get the chart output height in pixels.
        /// @return | number | Height in pixels.
        methods.add_method("getHeight", |_, this, ()| {
            Ok(this.inner.borrow().config.height)
        });
    }
}

impl LuaUserData for LuaPieChart {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- addSlice --
        /// Add a slice to the pie chart — Lua userdata object exposed by the engine.
        /// @param | label | string | Display label for the slice.
        /// @param | value | number | Numeric value determining the slice proportion.
        /// @param | color | table|nil | Optional RGBA color {r, g, b, a}. Auto-assigned from palette if nil.
        methods.add_method("addSlice", |_, this, (label, value, color): (String, f32, Option<LuaTable>)| {
            let c = match color {
                Some(ref t) => parse_color4(t)?,
                None => palette_color(this.count.get()),
            };
            this.count.set(this.count.get() + 1);
            this.inner.borrow_mut().add_slice(&label, value.max(0.0), c);
            Ok(())
        });

        // -- clear --
        /// Removes all pie data slices from this chart.
        methods.add_method("clear", |_, this, ()| {
            this.inner.borrow_mut().clear();
            this.count.set(0);
            Ok(())
        });

        // -- setTitle --
        /// Set or update the chart's displayed title.
        /// @param | title | string | New chart title text.
        methods.add_method("setTitle", |_, this, title: String| {
            this.inner.borrow_mut().config.title = Some(title);
            Ok(())
        });

        // -- render --
        /// Renders the chart contents into a new pixel buffer.
        /// @return | number | Output width in pixels.
        /// @return | number | Output height in pixels.
        /// @return | string | RGBA8 pixel data as a binary string.
        methods.add_method("render", |lua, this, ()| {
            let chart = this.inner.borrow();
            let w = chart.config.width;
            let h = chart.config.height;
            let mut buf = vec![0u8; (w * h * 4) as usize];
            chart.render(&mut buf);
            Ok((w, h, lua.create_string(&buf)?))
        });

        // -- getWidth --
        /// Get the chart output width in pixels.
        /// @return | number | Width in pixels.
        methods.add_method("getWidth", |_, this, ()| {
            Ok(this.inner.borrow().config.width)
        });

        // -- getHeight --
        /// Get the chart output height in pixels.
        /// @return | number | Height in pixels.
        methods.add_method("getHeight", |_, this, ()| {
            Ok(this.inner.borrow().config.height)
        });
    }
}

impl LuaUserData for LuaAreaChart {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- addSeries --
        /// Add a named data series to the area chart (stacked above previous).
        /// @param | name | string | Display name of the series.
        /// @param | data | table | Array of {x, y} point tables.
        /// @param | color | table|nil | Optional RGBA color {r, g, b, a}.
        methods.add_method("addSeries", |_, this, (name, data, color): (String, LuaTable, Option<LuaTable>)| {
            let points = parse_series_data(&data)?;
            let c = match color {
                Some(ref t) => parse_color4(t)?,
                None => palette_color(this.count.get()),
            };
            this.count.set(this.count.get() + 1);
            this.inner.borrow_mut().add_series(ChartSeries {
                name,
                color: c,
                data: points,
            });
            Ok(())
        });

        // -- clear --
        /// Removes all data series from this chart.
        methods.add_method("clear", |_, this, ()| {
            this.inner.borrow_mut().clear();
            this.count.set(0);
            Ok(())
        });

        // -- setTitle --
        /// Set or update the chart's displayed title.
        /// @param | title | string | New chart title text.
        methods.add_method("setTitle", |_, this, title: String| {
            this.inner.borrow_mut().config.title = Some(title);
            Ok(())
        });

        // -- render --
        /// Renders the chart contents into a new pixel buffer.
        /// @return | number | Output width in pixels.
        /// @return | number | Output height in pixels.
        /// @return | string | RGBA8 pixel data as a binary string.
        methods.add_method("render", |lua, this, ()| {
            let chart = this.inner.borrow();
            let w = chart.config.width;
            let h = chart.config.height;
            let mut buf = vec![0u8; (w * h * 4) as usize];
            chart.render(&mut buf);
            Ok((w, h, lua.create_string(&buf)?))
        });

        // -- getWidth --
        /// Get the chart output width in pixels.
        /// @return | number | Width in pixels.
        methods.add_method("getWidth", |_, this, ()| {
            Ok(this.inner.borrow().config.width)
        });

        // -- getHeight --
        /// Get the chart output height in pixels.
        /// @return | number | Height in pixels.
        methods.add_method("getHeight", |_, this, ()| {
            Ok(this.inner.borrow().config.height)
        });
    }
}

// ---------------------------------------------------------------------------
// Module registration
// ---------------------------------------------------------------------------

/// Register the `lurek.charts` namespace.
pub fn register(lua: &Lua, lurek: &LuaTable) -> LuaResult<()> {
    let charts = lua.create_table()?;

    // -- newLine --
    /// Create a new line chart exposed by the lurek engine.
    /// @param | config | table|nil | Optional chart configuration table.
    /// @return | LuaLineChart | A line chart userdata object.
    charts.set(
        "newLine",
        lua.create_function(|_, config: Option<LuaTable>| {
            let cfg = parse_chart_config(config)?;
            Ok(LuaLineChart {
                inner: RefCell::new(LineChart::new(cfg)),
                count: Cell::new(0),
            })
        })?,
    )?;

    // -- newBar --
    /// Create a new bar chart exposed by the lurek engine.
    /// @param | config | table|nil | Optional chart configuration table.
    /// @return | LuaBarChart | A bar chart userdata object.
    charts.set(
        "newBar",
        lua.create_function(|_, config: Option<LuaTable>| {
            let cfg = parse_chart_config(config)?;
            Ok(LuaBarChart {
                inner: RefCell::new(BarChart::new(cfg)),
                count: Cell::new(0),
            })
        })?,
    )?;

    // -- newScatter --
    /// Create a new scatter plot exposed by the lurek engine.
    /// @param | config | table|nil | Optional chart configuration table.
    /// @return | LuaScatterPlot | A scatter plot userdata object.
    charts.set(
        "newScatter",
        lua.create_function(|_, config: Option<LuaTable>| {
            let cfg = parse_chart_config(config)?;
            Ok(LuaScatterPlot {
                inner: RefCell::new(ScatterPlot::new(cfg)),
                count: Cell::new(0),
            })
        })?,
    )?;

    // -- newPie --
    /// Create a new pie chart exposed by the lurek engine.
    /// @param | config | table|nil | Optional chart configuration table.
    /// @return | LuaPieChart | A pie chart userdata object.
    charts.set(
        "newPie",
        lua.create_function(|_, config: Option<LuaTable>| {
            let cfg = parse_chart_config(config)?;
            Ok(LuaPieChart {
                inner: RefCell::new(PieChart::new(cfg)),
                count: Cell::new(0),
            })
        })?,
    )?;

    // -- newArea --
    /// Create a new area chart exposed by the lurek engine.
    /// @param | config | table|nil | Optional chart configuration table.
    /// @return | LuaAreaChart | A area chart userdata object.
    charts.set(
        "newArea",
        lua.create_function(|_, config: Option<LuaTable>| {
            let cfg = parse_chart_config(config)?;
            Ok(LuaAreaChart {
                inner: RefCell::new(AreaChart::new(cfg)),
                count: Cell::new(0),
            })
        })?,
    )?;

    // -- defaultPalette --
    /// Get the default 8-color series palette.
    /// @return | table | Array of 8 color tables, each {r, g, b, a}.
    charts.set(
        "defaultPalette",
        lua.create_function(|lua, ()| {
            let tbl = lua.create_table()?;
            for (i, color) in DEFAULT_PALETTE.iter().enumerate() {
                let c = lua.create_table()?;
                c.set(1, color[0])?;
                c.set(2, color[1])?;
                c.set(3, color[2])?;
                c.set(4, color[3])?;
                tbl.set(i + 1, c)?;
            }
            Ok(tbl)
        })?,
    )?;

    // -- seriesColor --
    /// Get a palette color by 1-based index (wraps around for index > 8).
    /// @param | index | integer | 1-based palette index.
    /// @return | table | Color table {r, g, b, a}.
    charts.set(
        "seriesColor",
        lua.create_function(|lua, index: usize| {
            if index == 0 {
                return Err(LuaError::RuntimeError(
                    "seriesColor index must be >= 1".into(),
                ));
            }
            let color = palette_color(index - 1);
            let c = lua.create_table()?;
            c.set(1, color[0])?;
            c.set(2, color[1])?;
            c.set(3, color[2])?;
            c.set(4, color[3])?;
            Ok(c)
        })?,
    )?;

    lurek.set("charts", charts)?;
    Ok(())
}
