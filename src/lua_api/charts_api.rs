//! Registers the `lurek.charts` Lua API and keeps chart userdata wrappers thin.
//! Parses chart config/data inputs at the Lua boundary, delegates rendering to `src/charts`,
//! and bridges CPU-generated chart images into the engine's texture-backed draw queue.
//! Module API documentation
//!
//! TODO: add doc note 1
//! TODO: add doc note 2
//! TODO: add doc note 3
//! TODO: add doc note 4
//! TODO: add doc note 5

use super::dataframe_api::LuaDataFrame;
use super::SharedState;
use crate::charts::config::{
    ChartConfig, ChartDataFrameOptions, ChartMargin, ChartSeries, DEFAULT_PALETTE,
};
use crate::charts::{
    AreaChart, BarChart, HeatmapChart, HistogramChart, LineChart, PieChart, ScatterPlot,
};
use crate::color::Color;
use crate::image::{ImageData, Texture};
use crate::render::renderer::RenderCommand;
use crate::runtime::resource_keys::TextureKey;
use mlua::prelude::*;
use slotmap::Key;
use std::cell::{Cell, RefCell};
use std::rc::Rc;

struct ChartTextureCache {
    state: Rc<RefCell<SharedState>>,
    key: RefCell<Option<TextureKey>>,
}

impl ChartTextureCache {
    fn new(state: Rc<RefCell<SharedState>>) -> Self {
        Self {
            state,
            key: RefCell::new(None),
        }
    }

    fn ensure_uploaded<F>(
        &self,
        api_name: &str,
        width: u32,
        height: u32,
        dirty: &Cell<bool>,
        render: F,
    ) -> LuaResult<TextureKey>
    where
        F: FnOnce(&mut [u8]),
    {
        let current_key = *self.key.borrow();
        if !dirty.get() {
            if let Some(key) = current_key {
                return Ok(key);
            }
        }

        let mut pixels = render_chart_buffer(api_name, width, height, render)?;
        let mut state = self.state.borrow_mut();
        if let Some(old_key) = self.key.borrow_mut().take() {
            release_texture(&mut state, old_key);
        }
        let texture = Texture::from_rgba(
            width,
            height,
            std::mem::take(&mut pixels),
            &mut state.textures,
        )
        .map_err(|err| {
            LuaError::RuntimeError(format!("{api_name}: failed to upload chart texture: {err}"))
        })?;
        state
            .released_texture_handles
            .remove(&texture.key.data().as_ffi());
        *self.key.borrow_mut() = Some(texture.key);
        dirty.set(false);
        Ok(texture.key)
    }

    fn draw<F>(
        &self,
        api_name: &str,
        width: u32,
        height: u32,
        dirty: &Cell<bool>,
        transform: RenderDrawTransform,
        render: F,
    ) -> LuaResult<()>
    where
        F: FnOnce(&mut [u8]),
    {
        let key = self.ensure_uploaded(api_name, width, height, dirty, render)?;
        let mut state = self.state.borrow_mut();
        queue_draw_image(&mut state, key, transform)
    }
}

impl Drop for ChartTextureCache {
    fn drop(&mut self) {
        let Some(key) = self.key.get_mut().take() else {
            return;
        };
        let mut state = self.state.borrow_mut();
        release_texture(&mut state, key);
    }
}

#[derive(Clone, Copy)]
struct RenderDrawTransform {
    x: f32,
    y: f32,
    rotation: f32,
    sx: f32,
    sy: f32,
    ox: f32,
    oy: f32,
}

impl RenderDrawTransform {
    fn parse(x: f32, y: f32, opts: Option<LuaTable>) -> LuaResult<Self> {
        let Some(opts) = opts else {
            return Ok(Self {
                x,
                y,
                rotation: 0.0,
                sx: 1.0,
                sy: 1.0,
                ox: 0.0,
                oy: 0.0,
            });
        };
        Ok(Self {
            x,
            y,
            rotation: opts.get::<_, Option<f32>>("rotation")?.unwrap_or(0.0),
            sx: opts.get::<_, Option<f32>>("sx")?.unwrap_or(1.0),
            sy: opts.get::<_, Option<f32>>("sy")?.unwrap_or(1.0),
            ox: opts.get::<_, Option<f32>>("ox")?.unwrap_or(0.0),
            oy: opts.get::<_, Option<f32>>("oy")?.unwrap_or(0.0),
        })
    }

    fn has_non_default_transform(self) -> bool {
        self.rotation != 0.0 || self.sx != 1.0 || self.sy != 1.0 || self.ox != 0.0 || self.oy != 0.0
    }
}

/// Lua handle for a line chart with named x/y series and cached draw output.
struct LuaLineChart {
    inner: RefCell<LineChart>,
    count: Cell<usize>,
    dirty: Cell<bool>,
    cache: ChartTextureCache,
}

/// Lua handle for a grouped bar chart with named series and category labels.
struct LuaBarChart {
    inner: RefCell<BarChart>,
    count: Cell<usize>,
    dirty: Cell<bool>,
    cache: ChartTextureCache,
}

/// Lua handle for a scatter plot with named point series and cached draw output.
struct LuaScatterPlot {
    inner: RefCell<ScatterPlot>,
    count: Cell<usize>,
    dirty: Cell<bool>,
    cache: ChartTextureCache,
}

/// Lua handle for a pie chart with labeled slices and cached draw output.
struct LuaPieChart {
    inner: RefCell<PieChart>,
    count: Cell<usize>,
    dirty: Cell<bool>,
    cache: ChartTextureCache,
}

/// Lua handle for an area chart with stacked layers or named series.
struct LuaAreaChart {
    inner: RefCell<AreaChart>,
    count: Cell<usize>,
    dirty: Cell<bool>,
    cache: ChartTextureCache,
}

/// Lua handle for a histogram chart that bins named numeric samples.
struct LuaHistogramChart {
    inner: RefCell<HistogramChart>,
    count: Cell<usize>,
    dirty: Cell<bool>,
    cache: ChartTextureCache,
}

/// Lua handle for a heatmap chart backed by a numeric matrix.
struct LuaHeatmapChart {
    inner: RefCell<HeatmapChart>,
    dirty: Cell<bool>,
    cache: ChartTextureCache,
}

fn rgba_color(color: [f32; 4]) -> Color {
    Color {
        r: color[0],
        g: color[1],
        b: color[2],
        a: color[3],
    }
}

fn palette_color(index: usize) -> [f32; 4] {
    DEFAULT_PALETTE[index % DEFAULT_PALETTE.len()]
}

fn release_texture(state: &mut SharedState, key: TextureKey) {
    if state.textures.remove(key).is_some() {
        state.released_texture_handles.insert(key.data().as_ffi());
    }
    state.texture_last_used.remove(&key);
}

fn queue_draw_image(
    state: &mut SharedState,
    key: TextureKey,
    transform: RenderDrawTransform,
) -> LuaResult<()> {
    if !state.textures.contains_key(key) {
        return Err(LuaError::RuntimeError(
            "lurek.charts.draw: chart texture is not valid".into(),
        ));
    }
    if transform.has_non_default_transform() {
        state.render_commands.push(RenderCommand::DrawImageEx {
            texture_key: key,
            x: transform.x,
            y: transform.y,
            rotation: transform.rotation,
            sx: transform.sx,
            sy: transform.sy,
            ox: transform.ox,
            oy: transform.oy,
            effect: None,
        });
    } else {
        state.render_commands.push(RenderCommand::DrawImage {
            texture_key: key,
            x: transform.x,
            y: transform.y,
            effect: None,
        });
    }
    Ok(())
}

fn render_chart_buffer<F>(api_name: &str, width: u32, height: u32, render: F) -> LuaResult<Vec<u8>>
where
    F: FnOnce(&mut [u8]),
{
    let len = ImageData::rgba_byte_len(width, height)
        .map_err(|err| LuaError::RuntimeError(format!("{api_name}: {err}")))?;
    let mut buffer = vec![0u8; len];
    render(&mut buffer);
    Ok(buffer)
}

fn chart_image_userdata<'lua, F>(
    lua: &'lua Lua,
    api_name: &str,
    width: u32,
    height: u32,
    render: F,
) -> LuaResult<LuaAnyUserData<'lua>>
where
    F: FnOnce(&mut [u8]),
{
    let buffer = render_chart_buffer(api_name, width, height, render)?;
    let image = ImageData::from_bytes(width, height, buffer)
        .map_err(|err| LuaError::RuntimeError(format!("{api_name}: {err}")))?;
    lua.create_userdata(image)
}

fn write_chart_to_image<F>(
    api_name: &str,
    target: &mut ImageData,
    width: u32,
    height: u32,
    render: F,
) -> LuaResult<()>
where
    F: FnOnce(&mut [u8]),
{
    if target.dimensions() != (width, height) {
        return Err(LuaError::RuntimeError(format!(
            "{api_name}: target image dimensions must be {}x{}, got {}x{}",
            width,
            height,
            target.width(),
            target.height()
        )));
    }
    let buffer = render_chart_buffer(api_name, width, height, render)?;
    target
        .set_raw_data(&buffer)
        .map_err(|err| LuaError::RuntimeError(format!("{api_name}: {err}")))
}

fn lua_table_to_strings(table: LuaTable) -> LuaResult<Vec<String>> {
    let len = table.raw_len();
    let mut values = Vec::with_capacity(len);
    for index in 1..=len {
        values.push(table.raw_get(index)?);
    }
    Ok(values)
}

fn parse_chart_dataframe_options(opts: Option<LuaTable>) -> LuaResult<ChartDataFrameOptions> {
    let Some(opts) = opts else {
        return Ok(ChartDataFrameOptions::default());
    };
    Ok(ChartDataFrameOptions {
        max_rows: opts.get("maxRows")?,
    })
}

fn parse_color4(tbl: &LuaTable) -> LuaResult<[f32; 4]> {
    let r = tbl.get::<_, f32>(1)?.clamp(0.0, 1.0);
    let g = tbl.get::<_, f32>(2)?.clamp(0.0, 1.0);
    let b = tbl.get::<_, f32>(3)?.clamp(0.0, 1.0);
    let a = tbl.get::<_, Option<f32>>(4)?.unwrap_or(1.0).clamp(0.0, 1.0);
    Ok([r, g, b, a])
}

fn color_from_optional_table(color: Option<LuaTable>, index: usize) -> LuaResult<[f32; 4]> {
    match color {
        Some(table) => parse_color4(&table),
        None => Ok(palette_color(index)),
    }
}

fn parse_margin(tbl: &LuaTable) -> LuaResult<ChartMargin> {
    Ok(ChartMargin {
        top: tbl.get::<_, Option<f32>>("top")?.unwrap_or(30.0).max(0.0),
        right: tbl.get::<_, Option<f32>>("right")?.unwrap_or(20.0).max(0.0),
        bottom: tbl
            .get::<_, Option<f32>>("bottom")?
            .unwrap_or(40.0)
            .max(0.0),
        left: tbl.get::<_, Option<f32>>("left")?.unwrap_or(50.0).max(0.0),
    })
}

fn parse_chart_config(config: Option<LuaTable>) -> LuaResult<ChartConfig> {
    let mut cfg = ChartConfig::default();
    let Some(tbl) = config else {
        return Ok(cfg);
    };

    if let Some(width) = tbl.get::<_, Option<u32>>("width")? {
        cfg.width = width.max(1);
    }
    if let Some(height) = tbl.get::<_, Option<u32>>("height")? {
        cfg.height = height.max(1);
    }
    cfg.title = tbl.get::<_, Option<String>>("title")?;
    cfg.x_label = tbl.get::<_, Option<String>>("xLabel")?;
    cfg.y_label = tbl.get::<_, Option<String>>("yLabel")?;
    cfg.x_tick_count = tbl
        .get::<_, Option<u32>>("xTickCount")?
        .unwrap_or(cfg.x_tick_count)
        .max(2);
    cfg.y_tick_count = tbl
        .get::<_, Option<u32>>("yTickCount")?
        .unwrap_or(cfg.y_tick_count)
        .max(2);
    cfg.show_grid = tbl
        .get::<_, Option<bool>>("showGrid")?
        .unwrap_or(cfg.show_grid);
    cfg.show_legend = tbl
        .get::<_, Option<bool>>("showLegend")?
        .unwrap_or(cfg.show_legend);
    cfg.legend_width = tbl
        .get::<_, Option<f32>>("legendWidth")?
        .unwrap_or(cfg.legend_width)
        .max(40.0);
    cfg.max_points = tbl.get::<_, Option<usize>>("maxPoints")?;

    if let Ok(Some(color_tbl)) = tbl.get::<_, Option<LuaTable>>("bgColor") {
        cfg.bg_color = parse_color4(&color_tbl)?;
    }
    if let Ok(Some(color_tbl)) = tbl.get::<_, Option<LuaTable>>("axisColor") {
        cfg.axis_color = parse_color4(&color_tbl)?;
    }
    if let Ok(Some(color_tbl)) = tbl.get::<_, Option<LuaTable>>("gridColor") {
        cfg.grid_color = parse_color4(&color_tbl)?;
    }
    if let Ok(Some(color_tbl)) = tbl.get::<_, Option<LuaTable>>("labelColor") {
        cfg.label_color = parse_color4(&color_tbl)?;
    }
    if let Ok(Some(margin_tbl)) = tbl.get::<_, Option<LuaTable>>("margin") {
        cfg.margin = parse_margin(&margin_tbl)?;
    }

    Ok(cfg)
}

fn parse_series_data(data: &LuaTable, api_name: &str) -> LuaResult<Vec<(f32, f32)>> {
    let mut points = Vec::new();
    for pair in data.clone().sequence_values::<LuaTable>() {
        let point = pair?;
        let x = point.get::<_, f32>(1)?;
        let y = point.get::<_, f32>(2)?;
        if !x.is_finite() || !y.is_finite() {
            return Err(LuaError::RuntimeError(format!(
                "{api_name}: points must contain only finite numeric values"
            )));
        }
        points.push((x, y));
    }
    Ok(points)
}

fn parse_value_list(data: &LuaTable, api_name: &str) -> LuaResult<Vec<f32>> {
    let mut values = Vec::new();
    for value in data.clone().sequence_values::<f32>() {
        let value = value?;
        if !value.is_finite() {
            return Err(LuaError::RuntimeError(format!(
                "{api_name}: values must contain only finite numeric values"
            )));
        }
        values.push(value);
    }
    Ok(values)
}

fn parse_numeric_matrix(data: &LuaTable, api_name: &str) -> LuaResult<(usize, usize, Vec<f32>)> {
    let rows = data.raw_len();
    if rows == 0 {
        return Ok((0, 0, Vec::new()));
    }

    let mut cols = None;
    let mut values = Vec::new();
    for row_index in 1..=rows {
        let row: LuaTable = data.raw_get(row_index)?;
        let row_cols = row.raw_len();
        match cols {
            Some(expected) if expected != row_cols => {
                return Err(LuaError::RuntimeError(format!(
                    "{api_name}: all matrix rows must have the same length"
                )));
            }
            None => cols = Some(row_cols),
            _ => {}
        }
        for col_index in 1..=row_cols {
            let value = row.raw_get::<_, f32>(col_index)?;
            if !value.is_finite() {
                return Err(LuaError::RuntimeError(format!(
                    "{api_name}: matrix values must be finite"
                )));
            }
            values.push(value);
        }
    }

    Ok((rows, cols.unwrap_or(0), values))
}

struct NearestPoint<'a> {
    series_name: &'a str,
    index: usize,
    x: f32,
    y: f32,
    screen_x: f32,
    screen_y: f32,
    distance: f32,
}

#[allow(clippy::too_many_arguments)]
fn nearest_cartesian_point<'a>(
    series: &'a [ChartSeries],
    plot_x: f32,
    plot_y: f32,
    plot_w: f32,
    plot_h: f32,
    min_x: f32,
    max_x: f32,
    min_y: f32,
    max_y: f32,
    query_x: f32,
    query_y: f32,
) -> Option<NearestPoint<'a>> {
    let mut best: Option<NearestPoint<'a>> = None;
    for chart_series in series {
        for (index, &(x, y)) in chart_series.data.iter().enumerate() {
            if !x.is_finite() || !y.is_finite() {
                continue;
            }
            let screen_x =
                plot_x + crate::charts::render_utils::world_to_screen(x, min_x, max_x, plot_w);
            let screen_y = plot_y + plot_h
                - crate::charts::render_utils::world_to_screen(y, min_y, max_y, plot_h);
            let distance = ((screen_x - query_x).powi(2) + (screen_y - query_y).powi(2)).sqrt();
            let candidate = NearestPoint {
                series_name: chart_series.name.as_str(),
                index,
                x,
                y,
                screen_x,
                screen_y,
                distance,
            };
            if best
                .as_ref()
                .map(|current| candidate.distance < current.distance)
                .unwrap_or(true)
            {
                best = Some(candidate);
            }
        }
    }
    best
}

fn push_nearest_point<'lua>(
    lua: &'lua Lua,
    nearest: Option<NearestPoint<'_>>,
) -> LuaResult<LuaValue<'lua>> {
    let Some(nearest) = nearest else {
        return Ok(LuaValue::Nil);
    };
    let table = lua.create_table()?;
    table.set("series", nearest.series_name)?;
    table.set("index", nearest.index + 1)?;
    table.set("x", nearest.x)?;
    table.set("y", nearest.y)?;
    table.set("screenX", nearest.screen_x)?;
    table.set("screenY", nearest.screen_y)?;
    table.set("distance", nearest.distance)?;
    Ok(LuaValue::Table(table))
}

impl LuaUserData for LuaLineChart {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        /// Adds a named line series from an array-style Lua table of points.
        ///
        /// @param name : string
        /// @param data : table
        /// @param color : table?
        /// @return nil
        methods.add_method(
            "addSeries",
            |_, this, (name, data, color): (String, LuaTable, Option<LuaTable>)| {
                let points = parse_series_data(&data, "lurek.charts.LLineChart:addSeries")?;
                let rgba = color_from_optional_table(color, this.count.get())?;
                this.count.set(this.count.get() + 1);
                this.inner
                    .borrow_mut()
                    .add_series(&name, &points, rgba_color(rgba));
                this.dirty.set(true);
                Ok(())
            },
        );
        /// Builds a named line series from x and y columns in a dataframe.
        ///
        /// @param name : string
        /// @param df : userdata
        /// @param x_col : string
        /// @param y_col : string
        /// @param color : table?
        /// @param opts : table?
        /// @return nil
        methods.add_method(
            "addSeriesFromDataFrame",
            |_,
             this,
             (name, df, x_col, y_col, color, opts): (
                String,
                LuaAnyUserData,
                String,
                String,
                Option<LuaTable>,
                Option<LuaTable>,
            )| {
                let rgba = color_from_optional_table(color, this.count.get())?;
                let options = parse_chart_dataframe_options(opts)?;
                let df = df.borrow::<LuaDataFrame>()?;
                let dataframe = df.borrow_dataframe();
                let added = this
                    .inner
                    .borrow_mut()
                    .add_series_from_dataframe(
                        &name,
                        &dataframe,
                        &x_col,
                        &y_col,
                        rgba_color(rgba),
                        options,
                    )
                    .map_err(|err| {
                        LuaError::RuntimeError(format!(
                            "lurek.charts.LLineChart:addSeriesFromDataFrame: {err}"
                        ))
                    })?;
                if added > 0 {
                    this.count.set(this.count.get() + 1);
                    this.dirty.set(true);
                }
                Ok(added)
            },
        );
        /// Replaces a named line series with a new array-style Lua table of points.
        ///
        /// @param name : string
        /// @param data : table
        /// @param color : table?
        /// @return nil
        methods.add_method(
            "replaceSeries",
            |_, this, (name, data, color): (String, LuaTable, Option<LuaTable>)| {
                let points = parse_series_data(&data, "lurek.charts.LLineChart:replaceSeries")?;
                let rgba = color_from_optional_table(color, this.count.get())?;
                this.inner
                    .borrow_mut()
                    .replace_series(&name, &points, rgba_color(rgba));
                this.dirty.set(true);
                Ok(())
            },
        );
        /// Appends one finite point to a named line series.
        ///
        /// @param name : string
        /// @param x : number
        /// @param y : number
        /// @param color : table?
        /// @return nil
        methods.add_method(
            "appendPoint",
            |_, this, (name, x, y, color): (String, f32, f32, Option<LuaTable>)| {
                if !x.is_finite() || !y.is_finite() {
                    return Err(LuaError::RuntimeError(
                        "lurek.charts.LLineChart:appendPoint requires finite x/y values".into(),
                    ));
                }
                let rgba = color_from_optional_table(color, this.count.get())?;
                this.inner
                    .borrow_mut()
                    .append_point(&name, x, y, rgba_color(rgba));
                this.dirty.set(true);
                Ok(())
            },
        );
        /// Sets the window.
        ///
        /// @param max_points : integer?
        methods.add_method("setWindow", |_, this, max_points: Option<usize>| {
            this.inner.borrow_mut().set_max_points(max_points);
            this.dirty.set(true);
            Ok(())
        });
        /// Clears the state.
        ///
        methods.add_method("clear", |_, this, ()| {
            this.inner.borrow_mut().clear();
            this.count.set(0);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the title.
        ///
        /// @param title : string
        methods.add_method("setTitle", |_, this, title: String| {
            this.inner.borrow_mut().config.title = Some(title);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the y max.
        ///
        /// @param value : number
        methods.add_method("setYMax", |_, this, value: f32| {
            this.inner.borrow_mut().y_max = value;
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the x max.
        ///
        /// @param value : number
        methods.add_method("setXMax", |_, this, value: f32| {
            this.inner.borrow_mut().x_max = value;
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the x label.
        ///
        /// @param label : string
        methods.add_method("setXLabel", |_, this, label: String| {
            this.inner.borrow_mut().config.x_label = Some(label);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the y label.
        ///
        /// @param label : string
        methods.add_method("setYLabel", |_, this, label: String| {
            this.inner.borrow_mut().config.y_label = Some(label);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the x tick count.
        ///
        /// @param count : integer
        methods.add_method("setXTickCount", |_, this, count: u32| {
            this.inner.borrow_mut().config.x_tick_count = count.max(2);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the y tick count.
        ///
        /// @param count : integer
        methods.add_method("setYTickCount", |_, this, count: u32| {
            this.inner.borrow_mut().config.y_tick_count = count.max(2);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the show legend.
        ///
        /// @param value : boolean
        methods.add_method("setShowLegend", |_, this, value: bool| {
            this.inner.borrow_mut().config.show_legend = value;
            this.dirty.set(true);
            Ok(())
        });
        /// Render.
        ///
        /// @return any
        methods.add_method("render", |lua, this, ()| {
            let chart = this.inner.borrow();
            let width = chart.config.width;
            let height = chart.config.height;
            let buffer =
                render_chart_buffer("lurek.charts.LLineChart:render", width, height, |buffer| {
                    chart.render(buffer);
                })?;
            Ok((width, height, lua.create_string(&buffer)?))
        });
        /// Render image.
        ///
        methods.add_method("renderImage", |lua, this, ()| {
            let chart = this.inner.borrow();
            chart_image_userdata(
                lua,
                "lurek.charts.LLineChart:renderImage",
                chart.config.width,
                chart.config.height,
                |buffer| {
                    chart.render(buffer);
                },
            )
        });
        /// Draw to image.
        ///
        /// @param target : userdata
        methods.add_method("drawToImage", |_, this, target: LuaAnyUserData| {
            let chart = this.inner.borrow();
            let mut image = target.borrow_mut::<ImageData>()?;
            write_chart_to_image(
                "lurek.charts.LLineChart:drawToImage",
                &mut image,
                chart.config.width,
                chart.config.height,
                |buffer| chart.render(buffer),
            )
        });
        /// Draws the line chart at world or screen coordinates using optional transform options.
        ///
        /// @param x : number
        /// @param y : number
        /// @param opts : table?
        /// @return nil
        methods.add_method(
            "draw",
            |_, this, (x, y, opts): (f32, f32, Option<LuaTable>)| {
                let transform = RenderDrawTransform::parse(x, y, opts)?;
                let chart = this.inner.borrow();
                this.cache.draw(
                    "lurek.charts.LLineChart:draw",
                    chart.config.width,
                    chart.config.height,
                    &this.dirty,
                    transform,
                    |buffer| chart.render(buffer),
                )
            },
        );
        /// Nearest.
        ///
        /// @param x : number
        /// @param y : number
        /// @return any
        methods.add_method("nearest", |lua, this, (x, y): (f32, f32)| {
            let chart = this.inner.borrow();
            let margin = chart.config.margin;
            let legend_reserve = if chart.config.show_legend {
                chart.config.legend_width
            } else {
                0.0
            };
            let plot_x = margin.left;
            let plot_y = margin.top;
            let plot_w = chart.config.width as f32 - margin.left - margin.right - legend_reserve;
            let plot_h = chart.config.height as f32 - margin.top - margin.bottom;
            if plot_w <= 0.0 || plot_h <= 0.0 {
                return Ok(LuaValue::Nil);
            }
            let (min_x, auto_max_x, min_y, auto_max_y) =
                crate::charts::render_utils::auto_range(chart.series());
            let max_x = if chart.x_max > min_x {
                chart.x_max
            } else {
                auto_max_x
            };
            let max_y = if chart.y_max > min_y {
                chart.y_max
            } else {
                auto_max_y
            };
            push_nearest_point(
                lua,
                nearest_cartesian_point(
                    chart.series(),
                    plot_x,
                    plot_y,
                    plot_w,
                    plot_h,
                    min_x,
                    max_x,
                    min_y,
                    max_y,
                    x,
                    y,
                ),
            )
        });
        /// Returns the width.
        ///
        /// @return any
        methods.add_method("getWidth", |_, this, ()| {
            Ok(this.inner.borrow().config.width)
        });
        /// Returns the height.
        ///
        /// @return any
        methods.add_method("getHeight", |_, this, ()| {
            Ok(this.inner.borrow().config.height)
        });
        /// Type.
        ///
        /// @return any
        methods.add_method("type", |_, _, ()| Ok("LLineChart"));
        /// Type of.
        ///
        /// @param name : string
        /// @return any
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LLineChart" || name == "LObject")
        });
    }
}

impl LuaUserData for LuaBarChart {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        /// Adds a named bar series from an array-style Lua table of values or points.
        ///
        /// @param name : string
        /// @param data : table
        /// @param color : table?
        /// @return nil
        methods.add_method(
            "addSeries",
            |_, this, (name, data, color): (String, LuaTable, Option<LuaTable>)| {
                let points = parse_series_data(&data, "lurek.charts.LBarChart:addSeries")?;
                let rgba = color_from_optional_table(color, this.count.get())?;
                this.count.set(this.count.get() + 1);
                this.inner
                    .borrow_mut()
                    .add_series_data(&name, &points, rgba_color(rgba));
                this.dirty.set(true);
                Ok(())
            },
        );
        /// Adds one category label with a numeric value list for grouped bars.
        ///
        /// @param label : string
        /// @param values : table
        /// @return nil
        methods.add_method(
            "addCategory",
            |_, this, (label, values): (String, LuaTable)| {
                let values = parse_value_list(&values, "lurek.charts.LBarChart:addCategory")?;
                this.inner.borrow_mut().add_category(&label, &values);
                this.dirty.set(true);
                Ok(())
            },
        );
        /// Adds grouped bar categories by reading one label column and one or more value columns from a dataframe.
        ///
        /// @param df : userdata
        /// @param label_col : string
        /// @param value_cols : table
        /// @param opts : table?
        /// @return nil
        methods.add_method(
            "addCategoriesFromDataFrame",
            |_,
             this,
             (df, label_col, value_cols, opts): (
                LuaAnyUserData,
                String,
                LuaTable,
                Option<LuaTable>,
            )| {
                let value_cols = lua_table_to_strings(value_cols)?;
                let options = parse_chart_dataframe_options(opts)?;
                let df = df.borrow::<LuaDataFrame>()?;
                let dataframe = df.borrow_dataframe();
                let added = this
                    .inner
                    .borrow_mut()
                    .add_categories_from_dataframe(&dataframe, &label_col, &value_cols, options)
                    .map_err(|err| {
                        LuaError::RuntimeError(format!(
                            "lurek.charts.LBarChart:addCategoriesFromDataFrame: {err}"
                        ))
                    })?;
                if added > 0 {
                    this.dirty.set(true);
                }
                Ok(added)
            },
        );
        /// Clears the state.
        ///
        methods.add_method("clear", |_, this, ()| {
            this.inner.borrow_mut().clear();
            this.count.set(0);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the bar width.
        ///
        /// @param width : number
        methods.add_method("setBarWidth", |_, this, width: f32| {
            this.inner.borrow_mut().set_bar_width(width);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the title.
        ///
        /// @param title : string
        methods.add_method("setTitle", |_, this, title: String| {
            this.inner.borrow_mut().config.title = Some(title);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the x label.
        ///
        /// @param label : string
        methods.add_method("setXLabel", |_, this, label: String| {
            this.inner.borrow_mut().config.x_label = Some(label);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the y label.
        ///
        /// @param label : string
        methods.add_method("setYLabel", |_, this, label: String| {
            this.inner.borrow_mut().config.y_label = Some(label);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the x tick count.
        ///
        /// @param count : integer
        methods.add_method("setXTickCount", |_, this, count: u32| {
            this.inner.borrow_mut().config.x_tick_count = count.max(2);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the y tick count.
        ///
        /// @param count : integer
        methods.add_method("setYTickCount", |_, this, count: u32| {
            this.inner.borrow_mut().config.y_tick_count = count.max(2);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the show legend.
        ///
        /// @param value : boolean
        methods.add_method("setShowLegend", |_, this, value: bool| {
            this.inner.borrow_mut().config.show_legend = value;
            this.dirty.set(true);
            Ok(())
        });
        /// Render.
        ///
        /// @return any
        methods.add_method("render", |lua, this, ()| {
            let chart = this.inner.borrow();
            let width = chart.config.width;
            let height = chart.config.height;
            let buffer =
                render_chart_buffer("lurek.charts.LBarChart:render", width, height, |buffer| {
                    chart.render(buffer);
                })?;
            Ok((width, height, lua.create_string(&buffer)?))
        });
        /// Render image.
        ///
        methods.add_method("renderImage", |lua, this, ()| {
            let chart = this.inner.borrow();
            chart_image_userdata(
                lua,
                "lurek.charts.LBarChart:renderImage",
                chart.config.width,
                chart.config.height,
                |buffer| {
                    chart.render(buffer);
                },
            )
        });
        /// Draw to image.
        ///
        /// @param target : userdata
        methods.add_method("drawToImage", |_, this, target: LuaAnyUserData| {
            let chart = this.inner.borrow();
            let mut image = target.borrow_mut::<ImageData>()?;
            write_chart_to_image(
                "lurek.charts.LBarChart:drawToImage",
                &mut image,
                chart.config.width,
                chart.config.height,
                |buffer| chart.render(buffer),
            )
        });
        /// Draws the bar chart at world or screen coordinates using optional transform options.
        ///
        /// @param x : number
        /// @param y : number
        /// @param opts : table?
        /// @return nil
        methods.add_method(
            "draw",
            |_, this, (x, y, opts): (f32, f32, Option<LuaTable>)| {
                let transform = RenderDrawTransform::parse(x, y, opts)?;
                let chart = this.inner.borrow();
                this.cache.draw(
                    "lurek.charts.LBarChart:draw",
                    chart.config.width,
                    chart.config.height,
                    &this.dirty,
                    transform,
                    |buffer| chart.render(buffer),
                )
            },
        );
        /// Returns the width.
        ///
        /// @return any
        methods.add_method("getWidth", |_, this, ()| {
            Ok(this.inner.borrow().config.width)
        });
        /// Returns the height.
        ///
        /// @return any
        methods.add_method("getHeight", |_, this, ()| {
            Ok(this.inner.borrow().config.height)
        });
        /// Type.
        ///
        /// @return any
        methods.add_method("type", |_, _, ()| Ok("LBarChart"));
        /// Type of.
        ///
        /// @param name : string
        /// @return any
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LBarChart" || name == "LObject")
        });
    }
}

impl LuaUserData for LuaScatterPlot {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        /// Adds a named scatter series from an array-style Lua table of points.
        ///
        /// @param name : string
        /// @param data : table
        /// @param color : table?
        /// @return nil
        methods.add_method(
            "addSeries",
            |_, this, (name, data, color): (String, LuaTable, Option<LuaTable>)| {
                let points = parse_series_data(&data, "lurek.charts.LScatterPlot:addSeries")?;
                let rgba = color_from_optional_table(color, this.count.get())?;
                this.count.set(this.count.get() + 1);
                this.inner
                    .borrow_mut()
                    .add_series(&name, &points, rgba_color(rgba));
                this.dirty.set(true);
                Ok(())
            },
        );
        /// Builds a named scatter series from x and y columns in a dataframe.
        ///
        /// @param name : string
        /// @param df : userdata
        /// @param x_col : string
        /// @param y_col : string
        /// @param color : table?
        /// @param opts : table?
        /// @return nil
        methods.add_method(
            "addSeriesFromDataFrame",
            |_,
             this,
             (name, df, x_col, y_col, color, opts): (
                String,
                LuaAnyUserData,
                String,
                String,
                Option<LuaTable>,
                Option<LuaTable>,
            )| {
                let rgba = color_from_optional_table(color, this.count.get())?;
                let options = parse_chart_dataframe_options(opts)?;
                let df = df.borrow::<LuaDataFrame>()?;
                let dataframe = df.borrow_dataframe();
                let added = this
                    .inner
                    .borrow_mut()
                    .add_series_from_dataframe(
                        &name,
                        &dataframe,
                        &x_col,
                        &y_col,
                        rgba_color(rgba),
                        options,
                    )
                    .map_err(|err| {
                        LuaError::RuntimeError(format!(
                            "lurek.charts.LScatterPlot:addSeriesFromDataFrame: {err}"
                        ))
                    })?;
                if added > 0 {
                    this.count.set(this.count.get() + 1);
                    this.dirty.set(true);
                }
                Ok(added)
            },
        );
        /// Replaces a named scatter series with a new array-style Lua table of points.
        ///
        /// @param name : string
        /// @param data : table
        /// @param color : table?
        /// @return nil
        methods.add_method(
            "replaceSeries",
            |_, this, (name, data, color): (String, LuaTable, Option<LuaTable>)| {
                let points = parse_series_data(&data, "lurek.charts.LScatterPlot:replaceSeries")?;
                let rgba = color_from_optional_table(color, this.count.get())?;
                this.inner
                    .borrow_mut()
                    .replace_series(&name, &points, rgba_color(rgba));
                this.dirty.set(true);
                Ok(())
            },
        );
        /// Appends one finite point to a named scatter series.
        ///
        /// @param name : string
        /// @param x : number
        /// @param y : number
        /// @param color : table?
        /// @return nil
        methods.add_method(
            "appendPoint",
            |_, this, (name, x, y, color): (String, f32, f32, Option<LuaTable>)| {
                if !x.is_finite() || !y.is_finite() {
                    return Err(LuaError::RuntimeError(
                        "lurek.charts.LScatterPlot:appendPoint requires finite x/y values".into(),
                    ));
                }
                let rgba = color_from_optional_table(color, this.count.get())?;
                this.inner
                    .borrow_mut()
                    .append_point(&name, x, y, rgba_color(rgba));
                this.dirty.set(true);
                Ok(())
            },
        );
        /// Sets the window.
        ///
        /// @param max_points : integer?
        methods.add_method("setWindow", |_, this, max_points: Option<usize>| {
            this.inner.borrow_mut().set_max_points(max_points);
            this.dirty.set(true);
            Ok(())
        });
        /// Clears the state.
        ///
        methods.add_method("clear", |_, this, ()| {
            this.inner.borrow_mut().clear();
            this.count.set(0);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the dot radius.
        ///
        /// @param radius : number
        methods.add_method("setDotRadius", |_, this, radius: f32| {
            this.inner.borrow_mut().set_dot_radius(radius);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the title.
        ///
        /// @param title : string
        methods.add_method("setTitle", |_, this, title: String| {
            this.inner.borrow_mut().config.title = Some(title);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the x range.
        ///
        /// @param min_x : number
        /// @param max_x : number
        methods.add_method("setXRange", |_, this, (min_x, max_x): (f32, f32)| {
            this.inner.borrow_mut().x_range = (min_x, max_x);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the y range.
        ///
        /// @param min_y : number
        /// @param max_y : number
        methods.add_method("setYRange", |_, this, (min_y, max_y): (f32, f32)| {
            this.inner.borrow_mut().y_range = (min_y, max_y);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the x label.
        ///
        /// @param label : string
        methods.add_method("setXLabel", |_, this, label: String| {
            this.inner.borrow_mut().config.x_label = Some(label);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the y label.
        ///
        /// @param label : string
        methods.add_method("setYLabel", |_, this, label: String| {
            this.inner.borrow_mut().config.y_label = Some(label);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the x tick count.
        ///
        /// @param count : integer
        methods.add_method("setXTickCount", |_, this, count: u32| {
            this.inner.borrow_mut().config.x_tick_count = count.max(2);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the y tick count.
        ///
        /// @param count : integer
        methods.add_method("setYTickCount", |_, this, count: u32| {
            this.inner.borrow_mut().config.y_tick_count = count.max(2);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the show legend.
        ///
        /// @param value : boolean
        methods.add_method("setShowLegend", |_, this, value: bool| {
            this.inner.borrow_mut().config.show_legend = value;
            this.dirty.set(true);
            Ok(())
        });
        /// Render.
        ///
        /// @return any
        methods.add_method("render", |lua, this, ()| {
            let chart = this.inner.borrow();
            let width = chart.config.width;
            let height = chart.config.height;
            let buffer = render_chart_buffer(
                "lurek.charts.LScatterPlot:render",
                width,
                height,
                |buffer| {
                    chart.render(buffer);
                },
            )?;
            Ok((width, height, lua.create_string(&buffer)?))
        });
        /// Render image.
        ///
        methods.add_method("renderImage", |lua, this, ()| {
            let chart = this.inner.borrow();
            chart_image_userdata(
                lua,
                "lurek.charts.LScatterPlot:renderImage",
                chart.config.width,
                chart.config.height,
                |buffer| chart.render(buffer),
            )
        });
        /// Draw to image.
        ///
        /// @param target : userdata
        methods.add_method("drawToImage", |_, this, target: LuaAnyUserData| {
            let chart = this.inner.borrow();
            let mut image = target.borrow_mut::<ImageData>()?;
            write_chart_to_image(
                "lurek.charts.LScatterPlot:drawToImage",
                &mut image,
                chart.config.width,
                chart.config.height,
                |buffer| chart.render(buffer),
            )
        });
        /// Draws the scatter plot at world or screen coordinates using optional transform options.
        ///
        /// @param x : number
        /// @param y : number
        /// @param opts : table?
        /// @return nil
        methods.add_method(
            "draw",
            |_, this, (x, y, opts): (f32, f32, Option<LuaTable>)| {
                let transform = RenderDrawTransform::parse(x, y, opts)?;
                let chart = this.inner.borrow();
                this.cache.draw(
                    "lurek.charts.LScatterPlot:draw",
                    chart.config.width,
                    chart.config.height,
                    &this.dirty,
                    transform,
                    |buffer| chart.render(buffer),
                )
            },
        );
        /// Nearest.
        ///
        /// @param x : number
        /// @param y : number
        /// @return any
        methods.add_method("nearest", |lua, this, (x, y): (f32, f32)| {
            let chart = this.inner.borrow();
            let margin = chart.config.margin;
            let legend_reserve = if chart.config.show_legend {
                chart.config.legend_width
            } else {
                0.0
            };
            let plot_x = margin.left;
            let plot_y = margin.top;
            let plot_w = chart.config.width as f32 - margin.left - margin.right - legend_reserve;
            let plot_h = chart.config.height as f32 - margin.top - margin.bottom;
            if plot_w <= 0.0 || plot_h <= 0.0 {
                return Ok(LuaValue::Nil);
            }
            let (auto_min_x, auto_max_x, auto_min_y, auto_max_y) =
                crate::charts::render_utils::auto_range(chart.series());
            let (min_x, max_x) = if chart.x_range.1 > chart.x_range.0 {
                chart.x_range
            } else {
                (auto_min_x, auto_max_x)
            };
            let (min_y, max_y) = if chart.y_range.1 > chart.y_range.0 {
                chart.y_range
            } else {
                (auto_min_y, auto_max_y)
            };
            push_nearest_point(
                lua,
                nearest_cartesian_point(
                    chart.series(),
                    plot_x,
                    plot_y,
                    plot_w,
                    plot_h,
                    min_x,
                    max_x,
                    min_y,
                    max_y,
                    x,
                    y,
                ),
            )
        });
        /// Returns the width.
        ///
        /// @return any
        methods.add_method("getWidth", |_, this, ()| {
            Ok(this.inner.borrow().config.width)
        });
        /// Returns the height.
        ///
        /// @return any
        methods.add_method("getHeight", |_, this, ()| {
            Ok(this.inner.borrow().config.height)
        });
        /// Type.
        ///
        /// @return any
        methods.add_method("type", |_, _, ()| Ok("LScatterPlot"));
        /// Type of.
        ///
        /// @param name : string
        /// @return any
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LScatterPlot" || name == "LObject")
        });
    }
}

impl LuaUserData for LuaPieChart {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        /// Legacy alias that adds one pie slice with a non-negative value.
        ///
        /// @param label : string
        /// @param value : number
        /// @param color : table?
        /// @return nil
        methods.add_method(
            "addSlice",
            |_, this, (label, value, color): (String, f32, Option<LuaTable>)| {
                let rgba = color_from_optional_table(color, this.count.get())?;
                this.count.set(this.count.get() + 1);
                this.inner
                    .borrow_mut()
                    .add_slice(&label, value.max(0.0), rgba);
                this.dirty.set(true);
                Ok(())
            },
        );
        /// Adds one pie segment with a non-negative value.
        ///
        /// @param label : string
        /// @param value : number
        /// @param color : table?
        /// @return nil
        methods.add_method(
            "addSegment",
            |_, this, (label, value, color): (String, f32, Option<LuaTable>)| {
                let rgba = color_from_optional_table(color, this.count.get())?;
                this.count.set(this.count.get() + 1);
                this.inner
                    .borrow_mut()
                    .add_segment(&label, value.max(0.0), rgba_color(rgba));
                this.dirty.set(true);
                Ok(())
            },
        );
        /// Adds pie segments by reading label and value columns from a dataframe.
        ///
        /// @param df : userdata
        /// @param label_col : string
        /// @param value_col : string
        /// @param opts : table?
        /// @return nil
        methods.add_method(
            "addSegmentsFromDataFrame",
            |_,
             this,
             (df, label_col, value_col, opts): (
                LuaAnyUserData,
                String,
                String,
                Option<LuaTable>,
            )| {
                let options = parse_chart_dataframe_options(opts)?;
                let df = df.borrow::<LuaDataFrame>()?;
                let dataframe = df.borrow_dataframe();
                let added = this
                    .inner
                    .borrow_mut()
                    .add_segments_from_dataframe(&dataframe, &label_col, &value_col, options)
                    .map_err(|err| {
                        LuaError::RuntimeError(format!(
                            "lurek.charts.LPieChart:addSegmentsFromDataFrame: {err}"
                        ))
                    })?;
                if added > 0 {
                    this.count.set(this.count.get() + added);
                    this.dirty.set(true);
                }
                Ok(added)
            },
        );
        /// Clears the state.
        ///
        methods.add_method("clear", |_, this, ()| {
            this.inner.borrow_mut().clear();
            this.count.set(0);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the title.
        ///
        /// @param title : string
        methods.add_method("setTitle", |_, this, title: String| {
            this.inner.borrow_mut().config.title = Some(title);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the show legend.
        ///
        /// @param value : boolean
        methods.add_method("setShowLegend", |_, this, value: bool| {
            this.inner.borrow_mut().config.show_legend = value;
            this.dirty.set(true);
            Ok(())
        });
        /// Render.
        ///
        /// @return any
        methods.add_method("render", |lua, this, ()| {
            let chart = this.inner.borrow();
            let width = chart.config.width;
            let height = chart.config.height;
            let buffer =
                render_chart_buffer("lurek.charts.LPieChart:render", width, height, |buffer| {
                    chart.render(buffer);
                })?;
            Ok((width, height, lua.create_string(&buffer)?))
        });
        /// Render image.
        ///
        methods.add_method("renderImage", |lua, this, ()| {
            let chart = this.inner.borrow();
            chart_image_userdata(
                lua,
                "lurek.charts.LPieChart:renderImage",
                chart.config.width,
                chart.config.height,
                |buffer| {
                    chart.render(buffer);
                },
            )
        });
        /// Draw to image.
        ///
        /// @param target : userdata
        methods.add_method("drawToImage", |_, this, target: LuaAnyUserData| {
            let chart = this.inner.borrow();
            let mut image = target.borrow_mut::<ImageData>()?;
            write_chart_to_image(
                "lurek.charts.LPieChart:drawToImage",
                &mut image,
                chart.config.width,
                chart.config.height,
                |buffer| chart.render(buffer),
            )
        });
        /// Draws the pie chart at world or screen coordinates using optional transform options.
        ///
        /// @param x : number
        /// @param y : number
        /// @param opts : table?
        /// @return nil
        methods.add_method(
            "draw",
            |_, this, (x, y, opts): (f32, f32, Option<LuaTable>)| {
                let transform = RenderDrawTransform::parse(x, y, opts)?;
                let chart = this.inner.borrow();
                this.cache.draw(
                    "lurek.charts.LPieChart:draw",
                    chart.config.width,
                    chart.config.height,
                    &this.dirty,
                    transform,
                    |buffer| chart.render(buffer),
                )
            },
        );
        /// Returns the width.
        ///
        /// @return any
        methods.add_method("getWidth", |_, this, ()| {
            Ok(this.inner.borrow().config.width)
        });
        /// Returns the height.
        ///
        /// @return any
        methods.add_method("getHeight", |_, this, ()| {
            Ok(this.inner.borrow().config.height)
        });
        /// Type.
        ///
        /// @return any
        methods.add_method("type", |_, _, ()| Ok("LPieChart"));
        /// Type of.
        ///
        /// @param name : string
        /// @return any
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LPieChart" || name == "LObject")
        });
    }
}

impl LuaUserData for LuaAreaChart {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        /// Adds a named area series from an array-style Lua table of points.
        ///
        /// @param name : string
        /// @param data : table
        /// @param color : table?
        /// @return nil
        methods.add_method(
            "addSeries",
            |_, this, (name, data, color): (String, LuaTable, Option<LuaTable>)| {
                let points = parse_series_data(&data, "lurek.charts.LAreaChart:addSeries")?;
                let rgba = color_from_optional_table(color, this.count.get())?;
                this.count.set(this.count.get() + 1);
                this.inner.borrow_mut().add_series(ChartSeries {
                    name,
                    color: rgba,
                    data: points,
                });
                this.dirty.set(true);
                Ok(())
            },
        );
        /// Adds one filled area layer from a numeric value list.
        ///
        /// @param name : string
        /// @param values : table
        /// @param color : table?
        /// @return nil
        methods.add_method(
            "addLayer",
            |_, this, (name, values, color): (String, LuaTable, Option<LuaTable>)| {
                let values = parse_value_list(&values, "lurek.charts.LAreaChart:addLayer")?;
                let rgba = color_from_optional_table(color, this.count.get())?;
                this.count.set(this.count.get() + 1);
                this.inner
                    .borrow_mut()
                    .add_layer(&name, &values, rgba_color(rgba));
                this.dirty.set(true);
                Ok(())
            },
        );
        /// Builds one filled area layer from a dataframe value column.
        ///
        /// @param name : string
        /// @param df : userdata
        /// @param value_col : string
        /// @param color : table?
        /// @param opts : table?
        /// @return nil
        methods.add_method(
            "addLayerFromDataFrame",
            |_,
             this,
             (name, df, value_col, color, opts): (
                String,
                LuaAnyUserData,
                String,
                Option<LuaTable>,
                Option<LuaTable>,
            )| {
                let rgba = color_from_optional_table(color, this.count.get())?;
                let options = parse_chart_dataframe_options(opts)?;
                let df = df.borrow::<LuaDataFrame>()?;
                let dataframe = df.borrow_dataframe();
                let added = this
                    .inner
                    .borrow_mut()
                    .add_layer_from_dataframe(
                        &name,
                        &dataframe,
                        &value_col,
                        rgba_color(rgba),
                        options,
                    )
                    .map_err(|err| {
                        LuaError::RuntimeError(format!(
                            "lurek.charts.LAreaChart:addLayerFromDataFrame: {err}"
                        ))
                    })?;
                if added > 0 {
                    this.count.set(this.count.get() + 1);
                    this.dirty.set(true);
                }
                Ok(added)
            },
        );
        /// Appends one finite point to a named area series.
        ///
        /// @param name : string
        /// @param x : number
        /// @param y : number
        /// @param color : table?
        /// @return nil
        methods.add_method(
            "appendPoint",
            |_, this, (name, x, y, color): (String, f32, f32, Option<LuaTable>)| {
                if !x.is_finite() || !y.is_finite() {
                    return Err(LuaError::RuntimeError(
                        "lurek.charts.LAreaChart:appendPoint requires finite x/y values".into(),
                    ));
                }
                let rgba = color_from_optional_table(color, this.count.get())?;
                this.inner
                    .borrow_mut()
                    .append_point(&name, x, y, rgba_color(rgba));
                this.dirty.set(true);
                Ok(())
            },
        );
        /// Sets the window.
        ///
        /// @param max_points : integer?
        methods.add_method("setWindow", |_, this, max_points: Option<usize>| {
            this.inner.borrow_mut().set_max_points(max_points);
            this.dirty.set(true);
            Ok(())
        });
        /// Clears the state.
        ///
        methods.add_method("clear", |_, this, ()| {
            this.inner.borrow_mut().clear();
            this.count.set(0);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the title.
        ///
        /// @param title : string
        methods.add_method("setTitle", |_, this, title: String| {
            this.inner.borrow_mut().config.title = Some(title);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the y max.
        ///
        /// @param value : number
        methods.add_method("setYMax", |_, this, value: f32| {
            this.inner.borrow_mut().y_max = value;
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the x label.
        ///
        /// @param label : string
        methods.add_method("setXLabel", |_, this, label: String| {
            this.inner.borrow_mut().config.x_label = Some(label);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the y label.
        ///
        /// @param label : string
        methods.add_method("setYLabel", |_, this, label: String| {
            this.inner.borrow_mut().config.y_label = Some(label);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the x tick count.
        ///
        /// @param count : integer
        methods.add_method("setXTickCount", |_, this, count: u32| {
            this.inner.borrow_mut().config.x_tick_count = count.max(2);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the y tick count.
        ///
        /// @param count : integer
        methods.add_method("setYTickCount", |_, this, count: u32| {
            this.inner.borrow_mut().config.y_tick_count = count.max(2);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the show legend.
        ///
        /// @param value : boolean
        methods.add_method("setShowLegend", |_, this, value: bool| {
            this.inner.borrow_mut().config.show_legend = value;
            this.dirty.set(true);
            Ok(())
        });
        /// Render.
        ///
        /// @return any
        methods.add_method("render", |lua, this, ()| {
            let chart = this.inner.borrow();
            let width = chart.config.width;
            let height = chart.config.height;
            let buffer =
                render_chart_buffer("lurek.charts.LAreaChart:render", width, height, |buffer| {
                    chart.render(buffer);
                })?;
            Ok((width, height, lua.create_string(&buffer)?))
        });
        /// Render image.
        ///
        methods.add_method("renderImage", |lua, this, ()| {
            let chart = this.inner.borrow();
            chart_image_userdata(
                lua,
                "lurek.charts.LAreaChart:renderImage",
                chart.config.width,
                chart.config.height,
                |buffer| {
                    chart.render(buffer);
                },
            )
        });
        /// Draw to image.
        ///
        /// @param target : userdata
        methods.add_method("drawToImage", |_, this, target: LuaAnyUserData| {
            let chart = this.inner.borrow();
            let mut image = target.borrow_mut::<ImageData>()?;
            write_chart_to_image(
                "lurek.charts.LAreaChart:drawToImage",
                &mut image,
                chart.config.width,
                chart.config.height,
                |buffer| chart.render(buffer),
            )
        });
        /// Draws the area chart at world or screen coordinates using optional transform options.
        ///
        /// @param x : number
        /// @param y : number
        /// @param opts : table?
        /// @return nil
        methods.add_method(
            "draw",
            |_, this, (x, y, opts): (f32, f32, Option<LuaTable>)| {
                let transform = RenderDrawTransform::parse(x, y, opts)?;
                let chart = this.inner.borrow();
                this.cache.draw(
                    "lurek.charts.LAreaChart:draw",
                    chart.config.width,
                    chart.config.height,
                    &this.dirty,
                    transform,
                    |buffer| chart.render(buffer),
                )
            },
        );
        /// Returns the width.
        ///
        /// @return any
        methods.add_method("getWidth", |_, this, ()| {
            Ok(this.inner.borrow().config.width)
        });
        /// Returns the height.
        ///
        /// @return any
        methods.add_method("getHeight", |_, this, ()| {
            Ok(this.inner.borrow().config.height)
        });
        /// Type.
        ///
        /// @return any
        methods.add_method("type", |_, _, ()| Ok("LAreaChart"));
        /// Type of.
        ///
        /// @param name : string
        /// @return any
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LAreaChart" || name == "LObject")
        });
    }
}

impl LuaUserData for LuaHistogramChart {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        /// Adds a named histogram sample series from a numeric value list.
        ///
        /// @param name : string
        /// @param data : table
        /// @param color : table?
        /// @return nil
        methods.add_method(
            "addSeries",
            |_, this, (name, values, color): (String, LuaTable, Option<LuaTable>)| {
                let values = parse_value_list(&values, "lurek.charts.LHistogramChart:addSeries")?;
                let rgba = color_from_optional_table(color, this.count.get())?;
                if !this
                    .inner
                    .borrow()
                    .series()
                    .iter()
                    .any(|series| series.name == name)
                {
                    this.count.set(this.count.get() + 1);
                }
                this.inner
                    .borrow_mut()
                    .add_series(&name, &values, rgba_color(rgba));
                this.dirty.set(true);
                Ok(())
            },
        );
        /// Builds a named histogram sample series from one dataframe value column.
        ///
        /// @param name : string
        /// @param df : userdata
        /// @param x_col : string
        /// @param y_col : string
        /// @param color : table?
        /// @param opts : table?
        /// @return nil
        methods.add_method(
            "addSeriesFromDataFrame",
            |_,
             this,
             (name, df, value_col, color, opts): (
                String,
                LuaAnyUserData,
                String,
                Option<LuaTable>,
                Option<LuaTable>,
            )| {
                let rgba = color_from_optional_table(color, this.count.get())?;
                let options = parse_chart_dataframe_options(opts)?;
                let df = df.borrow::<LuaDataFrame>()?;
                let dataframe = df.borrow_dataframe();
                let exists = this
                    .inner
                    .borrow()
                    .series()
                    .iter()
                    .any(|series| series.name == name);
                let added = this
                    .inner
                    .borrow_mut()
                    .add_series_from_dataframe(
                        &name,
                        &dataframe,
                        &value_col,
                        rgba_color(rgba),
                        options,
                    )
                    .map_err(|err| {
                        LuaError::RuntimeError(format!(
                            "lurek.charts.LHistogramChart:addSeriesFromDataFrame: {err}"
                        ))
                    })?;
                if added > 0 && !exists {
                    this.count.set(this.count.get() + 1);
                }
                if added > 0 {
                    this.dirty.set(true);
                }
                Ok(added)
            },
        );
        /// Replaces a named histogram sample series with a new numeric value list.
        ///
        /// @param name : string
        /// @param data : table
        /// @param color : table?
        /// @return nil
        methods.add_method(
            "replaceSeries",
            |_, this, (name, values, color): (String, LuaTable, Option<LuaTable>)| {
                let values =
                    parse_value_list(&values, "lurek.charts.LHistogramChart:replaceSeries")?;
                let rgba = color_from_optional_table(color, this.count.get())?;
                if !this
                    .inner
                    .borrow()
                    .series()
                    .iter()
                    .any(|series| series.name == name)
                {
                    this.count.set(this.count.get() + 1);
                }
                this.inner
                    .borrow_mut()
                    .replace_series(&name, &values, rgba_color(rgba));
                this.dirty.set(true);
                Ok(())
            },
        );
        /// Appends one finite numeric sample to a named histogram series.
        ///
        /// @param name : string
        /// @param value : number
        /// @param color : table?
        /// @return nil
        methods.add_method(
            "appendValue",
            |_, this, (name, value, color): (String, f32, Option<LuaTable>)| {
                if !value.is_finite() {
                    return Err(LuaError::RuntimeError(
                        "lurek.charts.LHistogramChart:appendValue requires a finite value".into(),
                    ));
                }
                let rgba = color_from_optional_table(color, this.count.get())?;
                if !this
                    .inner
                    .borrow()
                    .series()
                    .iter()
                    .any(|series| series.name == name)
                {
                    this.count.set(this.count.get() + 1);
                }
                this.inner
                    .borrow_mut()
                    .append_value(&name, value, rgba_color(rgba));
                this.dirty.set(true);
                Ok(())
            },
        );
        /// Sets the window.
        ///
        /// @param max_points : integer?
        methods.add_method("setWindow", |_, this, max_points: Option<usize>| {
            this.inner.borrow_mut().set_max_points(max_points);
            this.dirty.set(true);
            Ok(())
        });
        /// Clears the state.
        ///
        methods.add_method("clear", |_, this, ()| {
            this.inner.borrow_mut().clear();
            this.count.set(0);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the bin count.
        ///
        /// @param bins : integer
        methods.add_method("setBinCount", |_, this, bins: u32| {
            this.inner.borrow_mut().set_bin_count(bins as usize);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the range.
        ///
        /// @param min : number
        /// @param max : number
        methods.add_method("setRange", |_, this, (min, max): (f32, f32)| {
            this.inner.borrow_mut().set_range(min, max);
            this.dirty.set(true);
            Ok(())
        });
        /// Clears range.
        ///
        methods.add_method("clearRange", |_, this, ()| {
            this.inner.borrow_mut().clear_range();
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the density.
        ///
        /// @param enabled : boolean
        methods.add_method("setDensity", |_, this, enabled: bool| {
            this.inner.borrow_mut().set_density(enabled);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the title.
        ///
        /// @param title : string
        methods.add_method("setTitle", |_, this, title: String| {
            this.inner.borrow_mut().config.title = Some(title);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the x label.
        ///
        /// @param label : string
        methods.add_method("setXLabel", |_, this, label: String| {
            this.inner.borrow_mut().config.x_label = Some(label);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the y label.
        ///
        /// @param label : string
        methods.add_method("setYLabel", |_, this, label: String| {
            this.inner.borrow_mut().config.y_label = Some(label);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the x tick count.
        ///
        /// @param count : integer
        methods.add_method("setXTickCount", |_, this, count: u32| {
            this.inner.borrow_mut().config.x_tick_count = count.max(2);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the y tick count.
        ///
        /// @param count : integer
        methods.add_method("setYTickCount", |_, this, count: u32| {
            this.inner.borrow_mut().config.y_tick_count = count.max(2);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the show legend.
        ///
        /// @param value : boolean
        methods.add_method("setShowLegend", |_, this, value: bool| {
            this.inner.borrow_mut().config.show_legend = value;
            this.dirty.set(true);
            Ok(())
        });
        /// Render.
        ///
        /// @return any
        methods.add_method("render", |lua, this, ()| {
            let chart = this.inner.borrow();
            let width = chart.config.width;
            let height = chart.config.height;
            let buffer = render_chart_buffer(
                "lurek.charts.LHistogramChart:render",
                width,
                height,
                |buffer| {
                    chart.render(buffer);
                },
            )?;
            Ok((width, height, lua.create_string(&buffer)?))
        });
        /// Render image.
        ///
        methods.add_method("renderImage", |lua, this, ()| {
            let chart = this.inner.borrow();
            chart_image_userdata(
                lua,
                "lurek.charts.LHistogramChart:renderImage",
                chart.config.width,
                chart.config.height,
                |buffer| chart.render(buffer),
            )
        });
        /// Draw to image.
        ///
        /// @param target : userdata
        methods.add_method("drawToImage", |_, this, target: LuaAnyUserData| {
            let chart = this.inner.borrow();
            let mut image = target.borrow_mut::<ImageData>()?;
            write_chart_to_image(
                "lurek.charts.LHistogramChart:drawToImage",
                &mut image,
                chart.config.width,
                chart.config.height,
                |buffer| chart.render(buffer),
            )
        });
        /// Draws the histogram at world or screen coordinates using optional transform options.
        ///
        /// @param x : number
        /// @param y : number
        /// @param opts : table?
        /// @return nil
        methods.add_method(
            "draw",
            |_, this, (x, y, opts): (f32, f32, Option<LuaTable>)| {
                let transform = RenderDrawTransform::parse(x, y, opts)?;
                let chart = this.inner.borrow();
                this.cache.draw(
                    "lurek.charts.LHistogramChart:draw",
                    chart.config.width,
                    chart.config.height,
                    &this.dirty,
                    transform,
                    |buffer| chart.render(buffer),
                )
            },
        );
        /// Returns the width.
        ///
        /// @return any
        methods.add_method("getWidth", |_, this, ()| {
            Ok(this.inner.borrow().config.width)
        });
        /// Returns the height.
        ///
        /// @return any
        methods.add_method("getHeight", |_, this, ()| {
            Ok(this.inner.borrow().config.height)
        });
        /// Type.
        ///
        /// @return any
        methods.add_method("type", |_, _, ()| Ok("LHistogramChart"));
        /// Type of.
        ///
        /// @param name : string
        /// @return any
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LHistogramChart" || name == "LObject")
        });
    }
}

impl LuaUserData for LuaHeatmapChart {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        /// Replaces the heatmap contents from a numeric matrix with optional row and column labels.
        ///
        /// @param matrix : table
        /// @param row_labels : table?
        /// @param col_labels : table?
        /// @return nil
        methods.add_method(
            "setMatrix",
            |_,
             this,
             (matrix, row_labels, col_labels): (LuaTable, Option<LuaTable>, Option<LuaTable>)| {
                let (rows, cols, values) =
                    parse_numeric_matrix(&matrix, "lurek.charts.LHeatmapChart:setMatrix")?;
                let row_labels = match row_labels {
                    Some(labels) => lua_table_to_strings(labels)?,
                    None => Vec::new(),
                };
                let col_labels = match col_labels {
                    Some(labels) => lua_table_to_strings(labels)?,
                    None => Vec::new(),
                };
                this.inner
                    .borrow_mut()
                    .set_matrix(rows, cols, values, row_labels, col_labels);
                this.dirty.set(true);
                Ok(())
            },
        );
        /// Builds the heatmap contents from dataframe row, column, and value fields.
        ///
        /// @param df : userdata
        /// @param row_col : string
        /// @param col_col : string
        /// @param value_col : string
        /// @param opts : table?
        /// @return nil
        methods.add_method(
            "setMatrixFromDataFrame",
            |_,
             this,
             (df, row_col, col_col, value_col, opts): (
                LuaAnyUserData,
                String,
                String,
                String,
                Option<LuaTable>,
            )| {
                let options = parse_chart_dataframe_options(opts)?;
                let df = df.borrow::<LuaDataFrame>()?;
                let dataframe = df.borrow_dataframe();
                let added = this
                    .inner
                    .borrow_mut()
                    .set_matrix_from_dataframe(&dataframe, &row_col, &col_col, &value_col, options)
                    .map_err(|err| {
                        LuaError::RuntimeError(format!(
                            "lurek.charts.LHeatmapChart:setMatrixFromDataFrame: {err}"
                        ))
                    })?;
                this.dirty.set(true);
                Ok(added)
            },
        );
        /// Resize.
        ///
        /// @param rows : integer
        /// @param cols : integer
        methods.add_method("resize", |_, this, (rows, cols): (u32, u32)| {
            this.inner.borrow_mut().resize(rows as usize, cols as usize);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the cell.
        ///
        /// @param row : integer
        /// @param col : integer
        /// @param value : number
        methods.add_method("setCell", |_, this, (row, col, value): (u32, u32, f32)| {
            if row == 0 || col == 0 {
                return Err(LuaError::RuntimeError(
                    "lurek.charts.LHeatmapChart:setCell uses one-based row/col indices".into(),
                ));
            }
            if !value.is_finite() {
                return Err(LuaError::RuntimeError(
                    "lurek.charts.LHeatmapChart:setCell requires a finite value".into(),
                ));
            }
            this.inner
                .borrow_mut()
                .set_cell((row - 1) as usize, (col - 1) as usize, value);
            this.dirty.set(true);
            Ok(())
        });
        /// Clears the state.
        ///
        methods.add_method("clear", |_, this, ()| {
            this.inner.borrow_mut().clear();
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the row labels.
        ///
        /// @param labels : table
        methods.add_method("setRowLabels", |_, this, labels: LuaTable| {
            this.inner
                .borrow_mut()
                .set_row_labels(lua_table_to_strings(labels)?);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the column labels.
        ///
        /// @param labels : table
        methods.add_method("setColumnLabels", |_, this, labels: LuaTable| {
            this.inner
                .borrow_mut()
                .set_col_labels(lua_table_to_strings(labels)?);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the value range.
        ///
        /// @param min : number
        /// @param max : number
        methods.add_method("setValueRange", |_, this, (min, max): (f32, f32)| {
            this.inner.borrow_mut().set_value_range(min, max);
            this.dirty.set(true);
            Ok(())
        });
        /// Clears value range.
        ///
        methods.add_method("clearValueRange", |_, this, ()| {
            this.inner.borrow_mut().clear_value_range();
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the low and high RGBA colors used for the heatmap gradient.
        ///
        /// @param low : table
        /// @param high : table
        /// @return nil
        methods.add_method(
            "setColorRange",
            |_, this, (low, high): (LuaTable, LuaTable)| {
                let low = parse_color4(&low)?;
                let high = parse_color4(&high)?;
                this.inner.borrow_mut().set_color_range(low, high);
                this.dirty.set(true);
                Ok(())
            },
        );
        /// Sets the show values.
        ///
        /// @param value : boolean
        methods.add_method("setShowValues", |_, this, value: bool| {
            this.inner.borrow_mut().set_show_values(value);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the title.
        ///
        /// @param title : string
        methods.add_method("setTitle", |_, this, title: String| {
            this.inner.borrow_mut().config.title = Some(title);
            this.dirty.set(true);
            Ok(())
        });
        /// Sets the show legend.
        ///
        /// @param value : boolean
        methods.add_method("setShowLegend", |_, this, value: bool| {
            this.inner.borrow_mut().config.show_legend = value;
            this.dirty.set(true);
            Ok(())
        });
        /// Render.
        ///
        /// @return any
        methods.add_method("render", |lua, this, ()| {
            let chart = this.inner.borrow();
            let width = chart.config.width;
            let height = chart.config.height;
            let buffer = render_chart_buffer(
                "lurek.charts.LHeatmapChart:render",
                width,
                height,
                |buffer| {
                    chart.render(buffer);
                },
            )?;
            Ok((width, height, lua.create_string(&buffer)?))
        });
        /// Render image.
        ///
        methods.add_method("renderImage", |lua, this, ()| {
            let chart = this.inner.borrow();
            chart_image_userdata(
                lua,
                "lurek.charts.LHeatmapChart:renderImage",
                chart.config.width,
                chart.config.height,
                |buffer| chart.render(buffer),
            )
        });
        /// Draw to image.
        ///
        /// @param target : userdata
        methods.add_method("drawToImage", |_, this, target: LuaAnyUserData| {
            let chart = this.inner.borrow();
            let mut image = target.borrow_mut::<ImageData>()?;
            write_chart_to_image(
                "lurek.charts.LHeatmapChart:drawToImage",
                &mut image,
                chart.config.width,
                chart.config.height,
                |buffer| chart.render(buffer),
            )
        });
        /// Draws the heatmap at world or screen coordinates using optional transform options.
        ///
        /// @param x : number
        /// @param y : number
        /// @param opts : table?
        /// @return nil
        methods.add_method(
            "draw",
            |_, this, (x, y, opts): (f32, f32, Option<LuaTable>)| {
                let transform = RenderDrawTransform::parse(x, y, opts)?;
                let chart = this.inner.borrow();
                this.cache.draw(
                    "lurek.charts.LHeatmapChart:draw",
                    chart.config.width,
                    chart.config.height,
                    &this.dirty,
                    transform,
                    |buffer| chart.render(buffer),
                )
            },
        );
        /// Returns the width.
        ///
        /// @return any
        methods.add_method("getWidth", |_, this, ()| {
            Ok(this.inner.borrow().config.width)
        });
        /// Returns the height.
        ///
        /// @return any
        methods.add_method("getHeight", |_, this, ()| {
            Ok(this.inner.borrow().config.height)
        });
        /// Type.
        ///
        /// @return any
        methods.add_method("type", |_, _, ()| Ok("LHeatmapChart"));
        /// Type of.
        ///
        /// @param name : string
        /// @return any
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LHeatmapChart" || name == "LObject")
        });
    }
}

/// Register the `lurek.charts` namespace.
pub fn register(lua: &Lua, lurek: &LuaTable, state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let charts = lua.create_table()?;

    /// New line.
    ///
    /// @param config : table?
    /// @return any
    charts.set(
        "newLine",
        lua.create_function({
            let state = state.clone();
            move |_, config: Option<LuaTable>| {
                let config = parse_chart_config(config)?;
                Ok(LuaLineChart {
                    inner: RefCell::new(LineChart::new(config)),
                    count: Cell::new(0),
                    dirty: Cell::new(true),
                    cache: ChartTextureCache::new(state.clone()),
                })
            }
        })?,
    )?;

    /// New bar.
    ///
    /// @param config : table?
    /// @return any
    charts.set(
        "newBar",
        lua.create_function({
            let state = state.clone();
            move |_, config: Option<LuaTable>| {
                let config = parse_chart_config(config)?;
                Ok(LuaBarChart {
                    inner: RefCell::new(BarChart::new(config)),
                    count: Cell::new(0),
                    dirty: Cell::new(true),
                    cache: ChartTextureCache::new(state.clone()),
                })
            }
        })?,
    )?;

    /// New scatter.
    ///
    /// @param config : table?
    /// @return any
    charts.set(
        "newScatter",
        lua.create_function({
            let state = state.clone();
            move |_, config: Option<LuaTable>| {
                let config = parse_chart_config(config)?;
                Ok(LuaScatterPlot {
                    inner: RefCell::new(ScatterPlot::new(config)),
                    count: Cell::new(0),
                    dirty: Cell::new(true),
                    cache: ChartTextureCache::new(state.clone()),
                })
            }
        })?,
    )?;

    /// New pie.
    ///
    /// @param config : table?
    /// @return any
    charts.set(
        "newPie",
        lua.create_function({
            let state = state.clone();
            move |_, config: Option<LuaTable>| {
                let config = parse_chart_config(config)?;
                Ok(LuaPieChart {
                    inner: RefCell::new(PieChart::new(config)),
                    count: Cell::new(0),
                    dirty: Cell::new(true),
                    cache: ChartTextureCache::new(state.clone()),
                })
            }
        })?,
    )?;

    /// New area.
    ///
    /// @param config : table?
    /// @return any
    charts.set(
        "newArea",
        lua.create_function({
            let state = state.clone();
            move |_, config: Option<LuaTable>| {
                let config = parse_chart_config(config)?;
                Ok(LuaAreaChart {
                    inner: RefCell::new(AreaChart::new(config)),
                    count: Cell::new(0),
                    dirty: Cell::new(true),
                    cache: ChartTextureCache::new(state.clone()),
                })
            }
        })?,
    )?;

    /// New histogram.
    ///
    /// @param config : table?
    /// @return any
    charts.set(
        "newHistogram",
        lua.create_function({
            let state = state.clone();
            move |_, config: Option<LuaTable>| {
                let config = parse_chart_config(config)?;
                Ok(LuaHistogramChart {
                    inner: RefCell::new(HistogramChart::new(config)),
                    count: Cell::new(0),
                    dirty: Cell::new(true),
                    cache: ChartTextureCache::new(state.clone()),
                })
            }
        })?,
    )?;

    /// New heatmap.
    ///
    /// @param config : table?
    /// @return any
    charts.set(
        "newHeatmap",
        lua.create_function({
            let state = state.clone();
            move |_, config: Option<LuaTable>| {
                let config = parse_chart_config(config)?;
                Ok(LuaHeatmapChart {
                    inner: RefCell::new(HeatmapChart::new(config)),
                    dirty: Cell::new(true),
                    cache: ChartTextureCache::new(state.clone()),
                })
            }
        })?,
    )?;

    /// Default palette.
    ///
    /// @return any
    charts.set(
        "defaultPalette",
        lua.create_function(|lua, ()| {
            let table = lua.create_table()?;
            for (index, color) in DEFAULT_PALETTE.iter().enumerate() {
                let color_table = lua.create_table()?;
                color_table.set(1, color[0])?;
                color_table.set(2, color[1])?;
                color_table.set(3, color[2])?;
                color_table.set(4, color[3])?;
                table.set(index + 1, color_table)?;
            }
            Ok(table)
        })?,
    )?;

    /// Series color.
    ///
    /// @param index : integer
    /// @return any
    charts.set(
        "seriesColor",
        lua.create_function(|lua, index: usize| {
            if index == 0 {
                return Err(LuaError::RuntimeError(
                    "lurek.charts.seriesColor: index must be >= 1".into(),
                ));
            }
            let color = palette_color(index - 1);
            let color_table = lua.create_table()?;
            color_table.set(1, color[0])?;
            color_table.set(2, color[1])?;
            color_table.set(3, color[2])?;
            color_table.set(4, color[3])?;
            Ok(color_table)
        })?,
    )?;

    lurek.set("charts", charts)?;
    Ok(())
}
