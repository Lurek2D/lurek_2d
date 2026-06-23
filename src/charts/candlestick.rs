//! This file owns candlestick chart rendering for OHLC financial or telemetry interval data streams.
//! It stores labeled candles, supports incremental appends, and draws wicks plus open-close bodies in one CPU pass.
//! Axis scaling is derived from high/low values, while shared chart helpers provide grid, ticks, title, and captions.
//! Positive and negative candles use configurable colors so streaming market views remain readable at 10 FPS.
//! The output is `ImageData`, keeping market-style chart semantics separate from render submission ownership.
//! Open it when OHLC ingestion, candle body geometry, or finance-style chart semantics need to change.

use crate::charts::config::ChartConfig;
use crate::charts::render_utils::{
    annotate_cartesian_chart, draw_line, draw_rect_filled, fill_buffer, world_to_screen,
};

/// One open-high-low-close candle.
#[derive(Debug, Clone)]
pub struct Candle {
    /// Display label for this candle slot.
    pub label: String,
    /// Opening value.
    pub open: f32,
    /// Highest value.
    pub high: f32,
    /// Lowest value.
    pub low: f32,
    /// Closing value.
    pub close: f32,
}

/// Candlestick chart for ordered OHLC samples.
#[derive(Debug, Clone)]
pub struct CandlestickChart {
    /// Chart appearance configuration.
    pub config: ChartConfig,
    candles: Vec<Candle>,
    up_color: [f32; 4],
    down_color: [f32; 4],
}

impl CandlestickChart {
    /// Create an empty candlestick chart.
    pub fn new(config: ChartConfig) -> Self {
        Self {
            config,
            candles: Vec::new(),
            up_color: [0.18, 0.66, 0.40, 1.0],
            down_color: [0.89, 0.33, 0.29, 1.0],
        }
    }

    /// Replace all candle data.
    pub fn set_candles(&mut self, candles: Vec<Candle>) {
        self.candles = candles;
        self.trim_window();
    }

    /// Append one candle, trimming to the configured streaming window.
    pub fn append_candle(&mut self, candle: Candle) {
        self.candles.push(candle);
        self.trim_window();
    }

    /// Remove all candle data.
    pub fn clear(&mut self) {
        self.candles.clear();
    }

    /// Set colors for up and down candle bodies.
    pub fn set_colors(&mut self, up: [f32; 4], down: [f32; 4]) {
        self.up_color = up;
        self.down_color = down;
    }

    fn trim_window(&mut self) {
        if let Some(max_points) = self.config.max_points {
            if max_points == 0 {
                self.candles.clear();
            } else if self.candles.len() > max_points {
                let drop_count = self.candles.len() - max_points;
                self.candles.drain(0..drop_count);
            }
        }
    }

    /// Render the chart into an RGBA8 pixel buffer.
    pub fn render(&self, buffer: &mut [u8]) {
        let w = self.config.width;
        let h = self.config.height;
        fill_buffer(buffer, self.config.bg_color);

        let margin = &self.config.margin;
        let legend_reserve = if self.config.show_legend {
            self.config.legend_width
        } else {
            0.0
        };
        let plot_x = margin.left;
        let plot_y = margin.top;
        let plot_w = w as f32 - margin.left - margin.right - legend_reserve;
        let plot_h = h as f32 - margin.top - margin.bottom;
        if plot_w <= 0.0 || plot_h <= 0.0 {
            return;
        }

        let mut min_y = f32::MAX;
        let mut max_y = f32::MIN;
        for candle in &self.candles {
            min_y = min_y.min(candle.low);
            max_y = max_y.max(candle.high);
        }
        if min_y == f32::MAX || max_y == f32::MIN {
            min_y = 0.0;
            max_y = 1.0;
        }
        if (max_y - min_y).abs() < f32::EPSILON {
            max_y = min_y + 1.0;
        }

        if self.config.show_grid {
            for i in 0..=5 {
                let frac = i as f32 / 5.0;
                let gy = plot_y + plot_h * (1.0 - frac);
                draw_line(
                    buffer,
                    w,
                    h,
                    plot_x,
                    gy,
                    plot_x + plot_w,
                    gy,
                    self.config.grid_color,
                );
            }
        }
        draw_line(
            buffer,
            w,
            h,
            plot_x,
            plot_y + plot_h,
            plot_x + plot_w,
            plot_y + plot_h,
            self.config.axis_color,
        );
        draw_line(
            buffer,
            w,
            h,
            plot_x,
            plot_y,
            plot_x,
            plot_y + plot_h,
            self.config.axis_color,
        );

        let count = self.candles.len().max(1);
        let step = plot_w / count as f32;
        let body_w = (step * 0.58).max(2.0);
        for (index, candle) in self.candles.iter().enumerate() {
            if !(candle.open.is_finite()
                && candle.high.is_finite()
                && candle.low.is_finite()
                && candle.close.is_finite())
            {
                continue;
            }
            let cx = plot_x + step * (index as f32 + 0.5);
            let y_high = plot_y + plot_h - world_to_screen(candle.high, min_y, max_y, plot_h);
            let y_low = plot_y + plot_h - world_to_screen(candle.low, min_y, max_y, plot_h);
            let y_open = plot_y + plot_h - world_to_screen(candle.open, min_y, max_y, plot_h);
            let y_close = plot_y + plot_h - world_to_screen(candle.close, min_y, max_y, plot_h);
            let color = if candle.close >= candle.open {
                self.up_color
            } else {
                self.down_color
            };
            draw_line(buffer, w, h, cx, y_high, cx, y_low, color);
            let top = y_open.min(y_close);
            let height = (y_open - y_close).abs().max(1.0);
            draw_rect_filled(
                buffer,
                w,
                (cx - body_w * 0.5).max(0.0) as u32,
                top.max(0.0) as u32,
                body_w as u32,
                height as u32,
                color,
            );
        }

        let labels: Vec<String> = self
            .candles
            .iter()
            .map(|candle| candle.label.clone())
            .collect();
        let legends = [("Up", self.up_color), ("Down", self.down_color)];
        annotate_cartesian_chart(
            buffer,
            w,
            h,
            &self.config,
            plot_x,
            plot_y,
            plot_w,
            plot_h,
            0.0,
            count as f32,
            min_y,
            max_y,
            &legends,
            Some(&labels),
        );
    }
}
