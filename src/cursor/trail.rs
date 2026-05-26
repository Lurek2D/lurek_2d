//! Cursor trail effects: fading dot trails, connected line trails, and particle modes.
//!
//! - `TrailPoint` records position, timestamp, and current alpha for each trail node.
//! - `TrailState` holds a ring buffer of `TrailPoint`s capped at `max_points`.
//! - `TrailMode` selects: `Dots`, `Line`, `Particles` — each rendered differently.
//! - Trail alpha decays linearly; the oldest points are culled when the buffer is full.
//! - Updated each tick from the cursor manager; rendered in the overlay pass.
use std::collections::VecDeque;

/// A single point in the cursor trail.
#[derive(Debug, Clone, Copy)]
pub struct TrailPoint {
    /// X coordinate position.
    pub x: f32,
    /// Y coordinate position.
    pub y: f32,
    /// Trail point age in seconds since creation.
    pub age: f32,
}

/// Trail rendering mode: controls how trail points are drawn behind the cursor.
#[derive(Debug, Clone)]
pub enum TrailMode {
    /// Fading dots with color and lifetime.
    FadePoints { color: [f32; 4], lifetime: f32 },
    /// Connected line with width and fade.
    Line { color: [f32; 4], width: f32, fade: bool },
}

/// Manages a trail of points behind the cursor.
#[derive(Debug, Clone)]
pub struct CursorTrail {
    mode: TrailMode,
    points: VecDeque<TrailPoint>,
    max_points: usize,
    active: bool,
    min_distance: f32,
}

impl CursorTrail {
    /// Create a new cursor trail with the given render mode and default settings.
    pub fn new(mode: TrailMode) -> Self {
        Self {
            mode,
            points: VecDeque::new(),
            max_points: 64,
            active: true,
            min_distance: 2.0,
        }
    }

    /// Tick the trail: age existing points, remove expired ones, and append a new point if the cursor moved far enough.
    pub fn update(&mut self, x: f32, y: f32, dt: f32) {
        if !self.active {
            return;
        }

        let lifetime = self.lifetime();

        // Age existing points
        for p in self.points.iter_mut() {
            p.age += dt;
        }

        // Remove expired points
        while let Some(front) = self.points.front() {
            if front.age >= lifetime {
                self.points.pop_front();
            } else {
                break;
            }
        }

        // Add new point if far enough from last
        let should_add = match self.points.back() {
            Some(last) => {
                let dx = x - last.x;
                let dy = y - last.y;
                (dx * dx + dy * dy) >= self.min_distance * self.min_distance
            }
            None => true,
        };

        if should_add {
            if self.points.len() >= self.max_points {
                self.points.pop_front();
            }
            self.points.push_back(TrailPoint { x, y, age: 0.0 });
        }
    }

    /// Return the ordered deque of current trail points.
    pub fn get_points(&self) -> &VecDeque<TrailPoint> {
        &self.points
    }

    /// Immediately remove all stored trail points.
    pub fn clear(&mut self) {
        self.points.clear();
    }

    /// Enable or disable trail recording; disabling also clears all existing points.
    pub fn set_active(&mut self, active: bool) {
        self.active = active;
        if !active {
            self.points.clear();
        }
    }

    /// Return `true` if the trail is currently recording cursor positions.
    pub fn is_active(&self) -> bool {
        self.active
    }

    /// Return the current trail render mode.
    pub fn mode(&self) -> &TrailMode {
        &self.mode
    }

    /// Change the trail render mode and clear existing points.
    pub fn set_mode(&mut self, mode: TrailMode) {
        self.mode = mode;
        self.points.clear();
    }

    /// Set the maximum number of stored trail points, evicting oldest if already over the limit.
    pub fn set_max_points(&mut self, max: usize) {
        self.max_points = max;
        while self.points.len() > max {
            self.points.pop_front();
        }
    }

    fn lifetime(&self) -> f32 {
        match &self.mode {
            TrailMode::FadePoints { lifetime, .. } => *lifetime,
            TrailMode::Line { .. } => 0.5,
        }
    }
}
