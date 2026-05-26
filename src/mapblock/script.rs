//! Script steps that drive the procedural map block generation sequence.
//!
//! - `MapScript` is a `Vec<ScriptStep>` executed in order by the generator.
//! - `StepType` variants: `Fill`, `PlaceGroup`, `PlaceBlock`, `ApplyLayer`, `Repeat`.
//! - Steps can be loaded from TOML or constructed programmatically from Lua.
//! - `Repeat { count, steps }` nests a sub-list with its own RNG advancement.

/// Type of procedural map generation step executed by the build script.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum StepType {
    /// Fill the entire map randomly from a group's blocks.
    FillRandom,
    /// Place a specific block at a fixed or next-available position.
    PlaceBlock,
    /// Place a random block from a group at a random valid position.
    PlaceRandom,
    /// Place blocks along a line.
    PlaceLine,
    /// Flood fill from a position with a given tile.
    FloodFill,
    /// Fill a rectangular area with a tile.
    FillArea,
    /// Draw a random path between two points.
    DrawPath,
    /// Fill a rectangle with a specific tile ID.
    FillRect,
    /// Place blocks only on map edges.
    FillEdges,
    /// Place blocks that satisfy neighbor constraints automatically.
    AutoPlace,
}

/// A single step in a map generation script.
#[derive(Debug, Clone)]
pub struct ScriptStep {
    /// Type of step to execute.
    pub step_type: StepType,
    /// Group name to use for this step.
    pub group_name: String,
    /// Specific block index within group; -1 means random.
    pub block_index: i32,
    /// X position for placement (if applicable).
    pub x: i32,
    /// Y position for placement (if applicable).
    pub y: i32,
    /// Width for area operations.
    pub width: u32,
    /// Height for area operations.
    pub height: u32,
    /// Number of times to perform this step.
    pub count: u32,
    /// Rotation in 90-degree increments (0, 1, 2, 3).
    pub rotation: u32,
    /// Mirror the block horizontally.
    pub mirror: bool,
    /// Randomly rotate when placing.
    pub random_rotation: bool,
    /// Randomly mirror when placing.
    pub random_mirror: bool,
    /// Match edge sides when placing (Carcassonne-style).
    pub match_sides: bool,
    /// Probability of this step executing (0.0..=1.0).
    pub chance: f32,
    /// How many times this step is repeated.
    pub repeat_count: u32,
    /// Tile ID for fill operations.
    pub tile_id: u32,
    /// Slot index to write to (for multi-slot tiles).
    pub slot_index: usize,
    /// Tileset ID for fill operations.
    pub tileset_id: u32,
    /// Layer index to write to.
    pub layer: u32,
    /// Level (floor/storey) to operate on.
    pub level: u32,
}

impl Default for ScriptStep {
    fn default() -> Self {
        Self {
            step_type: StepType::PlaceRandom,
            group_name: String::new(),
            block_index: -1,
            x: 0,
            y: 0,
            width: 0,
            height: 0,
            count: 1,
            rotation: 0,
            mirror: false,
            random_rotation: false,
            random_mirror: false,
            match_sides: true,
            chance: 1.0,
            repeat_count: 1,
            tile_id: 0,
            slot_index: 0,
            tileset_id: 1,
            layer: 0,
            level: 0,
        }
    }
}

/// An ordered sequence of steps that drives one generation pass.
#[derive(Debug, Clone)]
pub struct MapScript {
    /// Human-readable identifier.
    name: String,
    /// Ordered list of generation steps.
    steps: Vec<ScriptStep>,
}

impl MapScript {
    /// Create an empty script with the given name.
    pub fn new(name: &str) -> Self {
        Self {
            name: name.to_string(),
            steps: Vec::new(),
        }
    }

    /// Append a new step to this script.
    pub fn add_step(&mut self, step: ScriptStep) {
        self.steps.push(step);
    }

    /// Add a step from type and group name with defaults.
    pub fn add_step_simple(&mut self, step_type: StepType, group_name: &str, count: u32) {
        let mut step = ScriptStep::default();
        step.step_type = step_type;
        step.group_name = group_name.to_string();
        step.count = count;
        self.steps.push(step);
    }

    /// Get an immutable script step by index.
    pub fn get_step(&self, index: usize) -> Option<&ScriptStep> {
        self.steps.get(index)
    }

    /// Get a mutable script step by index.
    pub fn get_step_mut(&mut self, index: usize) -> Option<&mut ScriptStep> {
        self.steps.get_mut(index)
    }

    /// Get the total number of steps in this script.
    pub fn step_count(&self) -> usize {
        self.steps.len()
    }

    /// Remove a script step at the given index.
    pub fn remove_step(&mut self, index: usize) {
        if index < self.steps.len() {
            self.steps.remove(index);
        }
    }

    /// Clear all steps from this script.
    pub fn clear(&mut self) {
        self.steps.clear();
    }

    /// Get this script's display name.
    pub fn name(&self) -> &str {
        &self.name
    }

    /// Set this script's display name.
    pub fn set_name(&mut self, name: &str) {
        self.name = name.to_string();
    }

    /// Get all steps in this script as a slice.
    pub fn steps(&self) -> &[ScriptStep] {
        &self.steps
    }
}
