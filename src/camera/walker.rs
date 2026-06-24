//! This file owns walker behavior inside the camera subsystem, close to its data and invariants.
//! It keeps validation, defaults, and error-facing rules near the operations that mutate walker state.
//! Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.
//! Public functions in this file are the stable entry points other modules should use for walker work.
//! Serialization, indexing, and boundary checks stay here when they depend on walker internals.

use crate::camera::Camera2D;
use crate::tilemap::tilemap::TileMap;
use std::cell::RefCell;
use std::rc::Rc;

/// Walker combining tile-grid movement with camera following.
///
/// Maintains a world-space center point and tracks an associated camera that follows the walker
/// position with smooth interpolation.
pub struct CameraWalker {
    /// Reference to the tilemap used for tile/world coordinate conversion.
    map: Rc<RefCell<TileMap>>,
    /// Tile width in pixels.
    tile_w: f32,
    /// Tile height in pixels.
    tile_h: f32,
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
    /// Creates a new walker with tile placement and camera following.
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
        _layer: usize,
        tile_w: f32,
        tile_h: f32,
        _body_w: f32,
        _body_h: f32,
        speed: f32,
        start_x: f32,
        start_y: f32,
        camera: Rc<RefCell<Camera2D>>,
    ) -> Self {
        // Initialize camera to track walker position
        camera.borrow_mut().set_position(start_x, start_y);

        CameraWalker {
            map,
            tile_w,
            tile_h,
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

    /// Moves the walker in a given direction.
    ///
    /// # Arguments
    /// * `dx` — horizontal direction multiplier (-1, 0, or 1)
    /// * `dy` — vertical direction multiplier (-1, 0, or 1)
    /// * `dt` — time delta in seconds
    pub fn move_direction(&mut self, dx: f32, dy: f32, dt: f32) {
        let step_x = dx * self.speed * dt;
        let step_y = dy * self.speed * dt;

        if step_x.abs() > 0.001 {
            self.x += step_x;
        }

        if step_y.abs() > 0.001 {
            self.y += step_y;
        }

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
