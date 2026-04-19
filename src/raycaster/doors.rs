//! Sliding door support for grid-based raycaster levels.
//!
//! Provides [`Door`], [`DoorManager`], and related types for implementing
//! Wolfenstein 3D-style sliding doors that open and close over time.

/// Sliding direction of a door.
///
/// # Variants
/// - `Horizontal` — Horizontal variant.
/// - `Vertical` — Vertical variant.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum DoorDirection {
    /// Door slides along the X axis.
    Horizontal,
    /// Door slides along the Y axis.
    Vertical,
}

/// Current animation state of a door.
///
/// # Variants
/// - `Closed` — Closed variant.
/// - `Opening` — Opening variant.
/// - `Open` — Open variant.
/// - `Closing` — Closing variant.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum DoorState {
    /// Fully closed.
    Closed,
    /// Currently opening (open_amount increasing).
    Opening,
    /// Fully open.
    Open,
    /// Currently closing (open_amount decreasing).
    Closing,
}

/// Door state in a raycaster level.
///
/// Tracks position, animation progress, speed, and direction for a single door.
///
/// # Fields
/// - `x` — `u32`.
/// - `y` — `u32`.
/// - `open_amount` — `f32`.
/// - `speed` — `f32`.
/// - `direction` — `DoorDirection`.
/// - `state` — `DoorState`.
#[derive(Debug, Clone)]
pub struct Door {
    /// Grid X position.
    pub x: u32,
    /// Grid Y position.
    pub y: u32,
    /// Animation progress: 0.0 = closed, 1.0 = fully open.
    pub open_amount: f32,
    /// Animation speed in units per second.
    pub speed: f32,
    /// Slide direction.
    pub direction: DoorDirection,
    /// Current animation state.
    pub state: DoorState,
}

/// Manages all doors in the level.
///
/// Stores a list of [`Door`] objects and drives their open/close animations
/// each frame via [`DoorManager::update()`].
///
/// # Fields
/// - `doors` — `Vec<Door>`. All registered doors in the current level.
pub struct DoorManager {
    doors: Vec<Door>,
}

impl DoorManager {
    /// Creates an empty door manager.
    ///
    /// # Returns
    /// `Self`.
    pub fn new() -> Self {
        Self { doors: Vec::new() }
    }

    /// Adds a door at (x, y) with the given direction and speed.
    ///
    /// # Parameters
    /// - `x` — `u32`.
    /// - `y` — `u32`.
    /// - `direction` — `DoorDirection`.
    /// - `speed` — `f32`.
    ///
    /// # Returns
    /// `usize`.
    ///
    /// Returns the index of the newly added door.
    pub fn add_door(&mut self, x: u32, y: u32, direction: DoorDirection, speed: f32) -> usize {
        let index = self.doors.len();
        self.doors.push(Door {
            x,
            y,
            open_amount: 0.0,
            speed,
            direction,
            state: DoorState::Closed,
        });
        index
    }

    /// Begins opening a door by index.
    ///
    /// # Parameters
    /// - `index` — `usize`.
    pub fn open_door(&mut self, index: usize) {
        if let Some(door) = self.doors.get_mut(index) {
            if door.state == DoorState::Closed || door.state == DoorState::Closing {
                door.state = DoorState::Opening;
            }
        }
    }

    /// Begins closing a door by index.
    ///
    /// # Parameters
    /// - `index` — `usize`.
    pub fn close_door(&mut self, index: usize) {
        if let Some(door) = self.doors.get_mut(index) {
            if door.state == DoorState::Open || door.state == DoorState::Opening {
                door.state = DoorState::Closing;
            }
        }
    }

    /// Advances all door animations by `dt` seconds.
    ///
    /// Doors in the `Opening` state increase `open_amount` and transition to
    /// `Open` when fully open. Doors in the `Closing` state decrease
    /// `open_amount` and transition to `Closed` when fully closed.
    ///
    /// # Parameters
    /// - `dt` — `f32`.
    pub fn update(&mut self, dt: f32) {
        for door in &mut self.doors {
            match door.state {
                DoorState::Opening => {
                    door.open_amount += door.speed * dt;
                    if door.open_amount >= 1.0 {
                        door.open_amount = 1.0;
                        door.state = DoorState::Open;
                    }
                }
                DoorState::Closing => {
                    door.open_amount -= door.speed * dt;
                    if door.open_amount <= 0.0 {
                        door.open_amount = 0.0;
                        door.state = DoorState::Closed;
                    }
                }
                _ => {}
            }
        }
    }

    /// Finds a door at grid position (x, y), if any.
    ///
    /// # Parameters
    /// - `x` — `u32`.
    /// - `y` — `u32`.
    ///
    /// # Returns
    /// `Option<&Door>`.
    pub fn get_door_at(&self, x: u32, y: u32) -> Option<&Door> {
        self.doors.iter().find(|d| d.x == x && d.y == y)
    }

    /// Returns a slice of all managed doors.
    ///
    /// # Returns
    /// `&[Door]`.
    pub fn doors(&self) -> &[Door] {
        &self.doors
    }
}

impl Default for DoorManager {
    fn default() -> Self {
        Self::new()
    }
}
