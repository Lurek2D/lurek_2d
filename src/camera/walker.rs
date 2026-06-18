//! `src/camera/walker.rs` owns the tile-grid camera walker that couples collision-checked movement with a Camera2D.
//! It defines `CameraWalker`, keeping walker position, body dimensions, speed, tile metrics, and camera linkage together.
//! Tile-to-world placement, world-to-tile queries, directional movement, and solid-tile overlap checks all live here.
//! This file bridges tilemap collision probing and camera follow updates for top-down traversal and guided movement flows.
//! Read it when walker collision policy, movement stepping, or camera-follow coupling behavior needs to change.

use crate::camera::Camera2D;
use crate::tilemap::tilemap::TileMap;
use std::cell::RefCell;
use std::rc::Rc;

/// Walker combining tile-grid movement with camera following.
///
/// Maintains a world-space center point, uses tile collision probing for movement validation,
/// and tracks an associated camera that follows the walker position with smooth interpolation.
pub struct CameraWalker {
    /// Reference to the tilemap used for collision detection.
    map: Rc<RefCell<TileMap>>,
    /// Layer index (0-based) used for collision checks.
    layer: usize,
    /// Tile width in pixels.
    tile_w: f32,
    /// Tile height in pixels.
    tile_h: f32,
    /// Body width in pixels for collision bounds.
    body_w: f32,
    /// Body height in pixels for collision bounds.
    body_h: f32,
    /// Movement speed in pixels per second.
    speed: f32,
    /// Current world-space X position (center).
    x: f32,
    /// Current world-space Y position (center).
    y: f32,
    /// Associated camera that follows the walker.
    camera: Rc<RefCell<Camera2D>>,
}

impl CameraWalker {
    /// Creates a new walker with tile collision and camera following.
    ///
    /// # Arguments
    /// * `map` — reference to the TileMap for collision probing
    /// * `layer` — layer index (0-based) to check for collisions
    /// * `tile_w` — tile width in pixels
    /// * `tile_h` — tile height in pixels
    /// * `body_w` — body bounding box width in pixels
    /// * `body_h` — body bounding box height in pixels
    /// * `speed` — movement speed in pixels per second
    /// * `start_x` — initial world X position
    /// * `start_y` — initial world Y position
    /// * `camera` — camera to follow walker position
    #[allow(clippy::too_many_arguments)]
    pub fn new(
        map: Rc<RefCell<TileMap>>,
        layer: usize,
        tile_w: f32,
        tile_h: f32,
        body_w: f32,
        body_h: f32,
        speed: f32,
        start_x: f32,
        start_y: f32,
        camera: Rc<RefCell<Camera2D>>,
    ) -> Self {
        // Initialize camera to track walker position
        camera.borrow_mut().set_position(start_x, start_y);

        CameraWalker {
            map,
            layer,
            tile_w,
            tile_h,
            body_w,
            body_h,
            speed,
            x: start_x,
            y: start_y,
            camera,
        }
    }

    /// Sets the walker world-space center position.
    pub fn set_position(&mut self, x: f32, y: f32) {
        self.x = x;
        self.y = y;
        self.camera.borrow_mut().set_position(x, y);
    }

    /// Returns the walker world-space center position.
    pub fn get_position(&self) -> (f32, f32) {
        (self.x, self.y)
    }

    /// Places walker using 1-based tile coordinates.
    pub fn set_tile_position(&mut self, tx: u32, ty: u32) {
        let map_ref = self.map.borrow();
        let (wx, wy) = map_ref.tile_to_world(tx - 1, ty - 1);
        drop(map_ref);
        self.set_position(wx + self.tile_w * 0.5, wy + self.tile_h * 0.5);
    }

    /// Returns current walker tile coordinates (1-based).
    pub fn get_tile_position(&self) -> (u32, u32) {
        let map_ref = self.map.borrow();
        let (tx, ty) = map_ref.world_to_tile(self.x, self.y);
        drop(map_ref);
        (tx + 1, ty + 1)
    }

    /// Checks if movement would overlap solid tiles.
    fn would_overlap(&self, next_x: f32, next_y: f32) -> bool {
        let left = next_x - self.body_w * 0.5;
        let top = next_y - self.body_h * 0.5;
        let map_ref = self.map.borrow();
        map_ref.rect_overlaps_solid(
            self.layer,
            crate::math::Rect::new(left, top, self.body_w, self.body_h),
        )
    }

    /// Moves the walker in a given direction with collision checking.
    ///
    /// # Arguments
    /// * `dx` — horizontal direction multiplier (-1, 0, or 1)
    /// * `dy` — vertical direction multiplier (-1, 0, or 1)
    /// * `dt` — time delta in seconds
    pub fn move_direction(&mut self, dx: f32, dy: f32, dt: f32) {
        let step_x = dx * self.speed * dt;
        let step_y = dy * self.speed * dt;

        // Try X movement
        if step_x.abs() > 0.001 {
            let nx = self.x + step_x;
            if !self.would_overlap(nx, self.y) {
                self.x = nx;
            }
        }

        // Try Y movement
        if step_y.abs() > 0.001 {
            let ny = self.y + step_y;
            if !self.would_overlap(self.x, ny) {
                self.y = ny;
            }
        }

        // Update camera target
        self.camera.borrow_mut().set_position(self.x, self.y);
    }

    /// Moves up (negative Y).
    pub fn move_up(&mut self, dt: f32) {
        self.move_direction(0.0, -1.0, dt);
    }

    /// Moves down (positive Y).
    pub fn move_down(&mut self, dt: f32) {
        self.move_direction(0.0, 1.0, dt);
    }

    /// Moves left (negative X).
    pub fn move_left(&mut self, dt: f32) {
        self.move_direction(-1.0, 0.0, dt);
    }

    /// Moves right (positive X).
    pub fn move_right(&mut self, dt: f32) {
        self.move_direction(1.0, 0.0, dt);
    }

    /// Updates camera state, advancing smooth interpolation.
    pub fn update(&mut self, _dt: f32) {
        self.camera.borrow_mut().set_position(self.x, self.y);
    }

    /// Returns a reference to the associated camera.
    pub fn get_camera(&self) -> Rc<RefCell<Camera2D>> {
        Rc::clone(&self.camera)
    }
}
