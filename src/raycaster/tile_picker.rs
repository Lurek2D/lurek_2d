//! Tile picker: converts a screen (x, y) click into a raycasted map tile coordinate.
//!
//! - `pick_tile(screen_x, screen_y, camera, map)` returns `Option<(tile_x, tile_y)>`.
//! - Reverses the column rendering math to find the intersection depth for a pixel.
//! - Accounts for the player's position and angle at the moment of the pick query.
//! - Used by `lurek.raycaster.pick(x, y)` to report tile coordinates to Lua scripts.

/// Tile picker that maps screen coordinates to raycaster grid tiles.
#[derive(Debug, Clone)]
pub struct TilePicker {
    /// Grid width.
    pub grid_width: usize,
    /// Grid height.
    pub grid_height: usize,
    /// Tile size.
    pub tile_size: f32,
    /// Camera x.
    pub camera_x: f32,
    /// Camera y.
    pub camera_y: f32,
    /// Camera angle.
    pub camera_angle: f32,
    /// Screen width.
    pub screen_width: f32,
    /// Screen height.
    pub screen_height: f32,
}

/// Result of a tile pick operation.
#[derive(Debug, Clone, Copy)]
pub struct PickResult {
    /// Grid x.
    pub grid_x: usize,
    /// Grid y.
    pub grid_y: usize,
    /// Distance.
    pub distance: f32,
    /// Wall side.
    pub wall_side: u8,
}

impl TilePicker {
    /// Create a `TilePicker` for a grid of the given dimensions and tile size in world units.
    pub fn new(grid_width: usize, grid_height: usize, tile_size: f32) -> Self {
        Self {
            grid_width,
            grid_height,
            tile_size,
            camera_x: 0.0,
            camera_y: 0.0,
            camera_angle: 0.0,
            screen_width: 800.0,
            screen_height: 600.0,
        }
    }

    /// Update camera position and angle.
    pub fn set_camera(&mut self, x: f32, y: f32, angle: f32) {
        self.camera_x = x;
        self.camera_y = y;
        self.camera_angle = angle;
    }

    /// Set the screen width and height dimensions.
    pub fn set_screen_size(&mut self, width: f32, height: f32) {
        self.screen_width = width;
        self.screen_height = height;
    }

    /// Pick a tile from screen coordinates using simplified raycasting.
    pub fn pick_tile(&self, screen_x: f32, _screen_y: f32) -> Option<PickResult> {
        let fov = std::f32::consts::FRAC_PI_3; // 60 degrees
        let ray_angle = self.camera_angle
            + (screen_x / self.screen_width - 0.5) * fov;

        let dir_x = ray_angle.cos();
        let dir_y = ray_angle.sin();

        // Simple DDA for tile picking
        let mut map_x = (self.camera_x / self.tile_size) as i32;
        let mut map_y = (self.camera_y / self.tile_size) as i32;

        let delta_x = if dir_x.abs() < 1e-10 { f32::MAX } else { (self.tile_size / dir_x).abs() };
        let delta_y = if dir_y.abs() < 1e-10 { f32::MAX } else { (self.tile_size / dir_y).abs() };

        let step_x: i32 = if dir_x > 0.0 { 1 } else { -1 };
        let step_y: i32 = if dir_y > 0.0 { 1 } else { -1 };

        let cell_x = self.camera_x / self.tile_size;
        let cell_y = self.camera_y / self.tile_size;

        let mut side_x = if dir_x > 0.0 {
            ((map_x as f32 + 1.0) - cell_x) * delta_x
        } else {
            (cell_x - map_x as f32) * delta_x
        };
        let mut side_y = if dir_y > 0.0 {
            ((map_y as f32 + 1.0) - cell_y) * delta_y
        } else {
            (cell_y - map_y as f32) * delta_y
        };

        let max_steps = (self.grid_width + self.grid_height) as i32;
        let mut wall_side = 0u8;

        for _ in 0..max_steps {
            if side_x < side_y {
                side_x += delta_x;
                map_x += step_x;
                wall_side = 0;
            } else {
                side_y += delta_y;
                map_y += step_y;
                wall_side = 1;
            }

            if map_x < 0 || map_y < 0
                || map_x >= self.grid_width as i32
                || map_y >= self.grid_height as i32
            {
                return None;
            }

            // Return the first grid cell hit
            let distance = if wall_side == 0 {
                side_x - delta_x
            } else {
                side_y - delta_y
            };

            return Some(PickResult {
                grid_x: map_x as usize,
                grid_y: map_y as usize,
                distance,
                wall_side,
            });
        }

        None
    }

    /// Get tile coordinates directly from world position.
    pub fn world_to_tile(&self, world_x: f32, world_y: f32) -> Option<(usize, usize)> {
        let tx = (world_x / self.tile_size) as i32;
        let ty = (world_y / self.tile_size) as i32;
        if tx >= 0 && ty >= 0 && (tx as usize) < self.grid_width && (ty as usize) < self.grid_height {
            Some((tx as usize, ty as usize))
        } else {
            None
        }
    }
}
