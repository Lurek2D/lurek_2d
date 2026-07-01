//! This file owns `DoorDirection`, `DoorState`, `Door`, and `DoorManager` for animated doors in map cells.
//! It stores grid position, open amount, speed, slide axis, and phase state so doors evolve without retagging tiles.
//! Manager helpers add doors, switch them between opening and closing, advance animation, and query doors by tile.
//! Rendering and collision code can read one shared door registry, keeping passage state consistent across subsystems.
//! Open this file when door lifecycle semantics change; wall descriptors and scene construction stay in siblings.

use super::contract::RaycasterError;

/// Slide axis of a door: horizontal (slides along X) or vertical (slides along Y).
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum DoorDirection {
    /// Door slides along the X axis when opening.
    Horizontal,
    /// Door slides along the Y axis when opening.
    Vertical,
}
/// Current animation phase of a door.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum DoorState {
    /// Fully closed; blocks passage.
    Closed,
    /// Animating toward fully open.
    Opening,
    /// Fully open; passage allowed.
    Open,
    /// Animating toward fully closed.
    Closing,
}
/// A single animated door placed at a grid tile.
#[derive(Debug, Clone)]
pub struct Door {
    /// Grid X coordinate of the door tile.
    pub x: u32,
    /// Grid Y coordinate of the door tile.
    pub y: u32,
    /// How far the door has slid open, 0.0 (closed) to 1.0 (fully open).
    pub open_amount: f32,
    /// Animation speed in open_amount units per second.
    pub speed: f32,
    /// Slide direction of this door.
    pub direction: DoorDirection,
    /// Current animation state.
    pub state: DoorState,
}
/// Registry and update driver for all doors in the current map.
pub struct DoorManager {
    /// All registered doors, indexed by the integer handle returned from `add_door`.
    doors: Vec<Door>,
}
impl DoorManager {
    /// Create an empty `DoorManager`.
    pub fn new() -> Self {
        Self { doors: Vec::new() }
    }
    /// Register a new closed door at `(x, y)` with the given `direction` and `speed`; return its index handle.
    pub fn add_door(&mut self, x: u32, y: u32, direction: DoorDirection, speed: f32) -> usize {
        if let Some(existing) = self.doors.iter().position(|door| door.x == x && door.y == y) {
            let door = &mut self.doors[existing];
            door.direction = direction;
            door.speed = if speed.is_finite() { speed.max(0.0) } else { 0.0 };
            return existing;
        }
        let index = self.doors.len();
        self.doors.push(Door {
            x,
            y,
            open_amount: 0.0,
            speed: if speed.is_finite() { speed.max(0.0) } else { 0.0 },
            direction,
            state: DoorState::Closed,
        });
        index
    }
    /// Register a new closed door strictly, rejecting duplicates and invalid speeds.
    pub fn try_add_door(
        &mut self,
        x: u32,
        y: u32,
        direction: DoorDirection,
        speed: f32,
    ) -> Result<usize, RaycasterError> {
        if !speed.is_finite() || speed < 0.0 {
            return Err(RaycasterError::InvalidDoorSpeed { speed });
        }
        if self.doors.iter().any(|door| door.x == x && door.y == y) {
            return Err(RaycasterError::DuplicateDoorTile { x, y });
        }
        Ok(self.add_door(x, y, direction, speed))
    }
    /// Start opening door `index` if it is Closed or Closing; no-op otherwise.
    pub fn open_door(&mut self, index: usize) {
        if let Some(door) = self.doors.get_mut(index) {
            if door.state == DoorState::Closed || door.state == DoorState::Closing {
                door.state = DoorState::Opening;
            }
        }
    }
    /// Start closing door `index` if it is Open or Opening; no-op otherwise.
    pub fn close_door(&mut self, index: usize) {
        if let Some(door) = self.doors.get_mut(index) {
            if door.state == DoorState::Open || door.state == DoorState::Opening {
                door.state = DoorState::Closing;
            }
        }
    }
    /// Advance all door animations by `dt` seconds.
    pub fn update(&mut self, dt: f32) {
        if !dt.is_finite() || dt <= 0.0 {
            return;
        }
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
    /// Advance all door animations strictly, rejecting negative or non-finite delta time.
    pub fn try_update(&mut self, dt: f32) -> Result<(), RaycasterError> {
        if !dt.is_finite() || dt < 0.0 {
            return Err(RaycasterError::InvalidDoorDelta { dt });
        }
        self.update(dt);
        Ok(())
    }
    /// Return the first door at grid tile `(x, y)`, or `None` if none is registered there.
    pub fn get_door_at(&self, x: u32, y: u32) -> Option<&Door> {
        self.doors.iter().find(|d| d.x == x && d.y == y)
    }
    /// Return a slice of all registered doors.
    pub fn doors(&self) -> &[Door] {
        &self.doors
    }
}
/// Implement `Default` for `DoorManager` delegating to `new()`.
impl Default for DoorManager {
    fn default() -> Self {
        Self::new()
    }
}
