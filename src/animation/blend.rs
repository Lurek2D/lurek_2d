//! Blend-layer system for compositing multiple animation clips on a single sprite.
//!
//! A [`BlendLayerSet`] holds an ordered list of [`BlendLayer`] entries.  Each layer
//! references a named clip, carries a normalised weight (`0.0`–`1.0`), and can be
//! restricted to a named bone/joint set via a [`BlendMask`].
//!
//! This module is pure-Rust data — it contains no Lua bindings.  See
//! `src/lua_api/animation_api.rs` for the `lurek.animation.*` exposure.

/// Restricts a [`BlendLayer`] to a named subset of bone or joint identifiers.
///
/// When `bone_names` is empty the layer applies to all bones (no masking).
///
/// # Fields
/// - `bone_names` — `Vec<String>` — names of bones this layer affects; empty = all bones.
#[derive(Debug, Clone, Default)]
pub struct BlendMask {
    /// Names of bones (or joint slots) to which this layer applies.
    /// An empty list means the layer affects every bone — i.e. no masking.
    pub bone_names: Vec<String>,
}

impl BlendMask {
    /// Creates a mask that affects all bones (no filtering).
    ///
    /// # Returns
    /// `BlendMask`.
    pub fn all() -> Self {
        Self { bone_names: Vec::new() }
    }

    /// Creates a mask restricted to the given bone names.
    ///
    /// # Parameters
    /// - `bones` — `Vec<String>` — bone names to include.
    ///
    /// # Returns
    /// `BlendMask`.
    pub fn from_bones(bones: Vec<String>) -> Self {
        Self { bone_names: bones }
    }

    /// Returns `true` if this mask applies to the given bone name.
    ///
    /// When the mask is empty every bone matches.
    ///
    /// # Parameters
    /// - `bone` — `&str` — bone identifier.
    ///
    /// # Returns
    /// `bool`.
    pub fn includes(&self, bone: &str) -> bool {
        self.bone_names.is_empty() || self.bone_names.iter().any(|b| b == bone)
    }
}

/// One layer in a [`BlendLayerSet`]: a named clip at a given blend weight.
///
/// # Fields
/// - `name` — `String` — unique layer identifier.
/// - `clip_name` — `String` — animation clip this layer drives.
/// - `weight` — `f32` — blend contribution in `[0.0, 1.0]`.
/// - `mask` — `BlendMask` — optional bone restriction.
#[derive(Debug, Clone)]
pub struct BlendLayer {
    /// Unique name for this layer (used as a stable key for lookups).
    pub name: String,
    /// Name of the [`AnimClip`] this layer plays.
    pub clip_name: String,
    /// Blend weight in `[0.0, 1.0]`.  Weight 0 = invisible; weight 1 = full.
    pub weight: f32,
    /// Bone mask restricting which joints this layer influences.
    pub mask: BlendMask,
}

impl BlendLayer {
    /// Creates a new blend layer.
    ///
    /// # Parameters
    /// - `name` — `&str` — unique layer identifier.
    /// - `clip_name` — `&str` — animation clip name.
    /// - `weight` — `f32` — initial blend weight.
    /// - `mask` — `BlendMask` — bone restriction mask.
    ///
    /// # Returns
    /// `BlendLayer`.
    pub fn new(name: &str, clip_name: &str, weight: f32, mask: BlendMask) -> Self {
        Self {
            name: name.to_string(),
            clip_name: clip_name.to_string(),
            weight: weight.clamp(0.0, 1.0),
            mask,
        }
    }
}

/// Ordered set of blend layers for a single sprite's animation.
///
/// Layers are evaluated from bottom to top; higher layers blend over lower ones
/// according to their weights.  The caller is responsible for sampling each
/// layer's clip and compositing the resulting transforms.
///
/// # Fields
/// - `layers` — ordered list of [`BlendLayer`] entries.
#[derive(Debug, Clone, Default)]
pub struct BlendLayerSet {
    layers: Vec<BlendLayer>,
}

impl BlendLayerSet {
    /// Creates an empty blend layer set.
    ///
    /// # Returns
    /// `BlendLayerSet`.
    pub fn new() -> Self {
        Self { layers: Vec::new() }
    }

    /// Returns the number of layers currently in the set.
    ///
    /// # Returns
    /// `usize`.
    pub fn len(&self) -> usize {
        self.layers.len()
    }

    /// Returns `true` if the set contains no layers.
    ///
    /// # Returns
    /// `bool`.
    pub fn is_empty(&self) -> bool {
        self.layers.is_empty()
    }

    /// Appends a new layer.  Returns `Err` if a layer with the same name already exists.
    ///
    /// # Parameters
    /// - `layer` — `BlendLayer` — layer to add.
    ///
    /// # Returns
    /// `Result<(), String>`.
    pub fn add_layer(&mut self, layer: BlendLayer) -> Result<(), String> {
        if self.layers.iter().any(|l| l.name == layer.name) {
            return Err(format!(
                "blend: layer '{}' already exists",
                layer.name
            ));
        }
        self.layers.push(layer);
        log::debug!("animation: blend layer '{}' added", self.layers.last().unwrap().name);
        Ok(())
    }

    /// Removes a layer by name.  Returns `Err` if not found.
    ///
    /// # Parameters
    /// - `name` — `&str` — name of the layer to remove.
    ///
    /// # Returns
    /// `Result<(), String>`.
    pub fn remove_layer(&mut self, name: &str) -> Result<(), String> {
        let pos = self
            .layers
            .iter()
            .position(|l| l.name == name)
            .ok_or_else(|| format!("blend: layer '{name}' not found"))?;
        self.layers.remove(pos);
        log::debug!("animation: blend layer '{name}' removed");
        Ok(())
    }

    /// Sets the blend weight of a layer.  Returns `Err` if the layer is not found.
    ///
    /// The weight is clamped to `[0.0, 1.0]`.
    ///
    /// # Parameters
    /// - `name` — `&str` — layer to modify.
    /// - `weight` — `f32` — new weight.
    ///
    /// # Returns
    /// `Result<(), String>`.
    pub fn set_weight(&mut self, name: &str, weight: f32) -> Result<(), String> {
        let layer = self
            .layers
            .iter_mut()
            .find(|l| l.name == name)
            .ok_or_else(|| format!("blend: layer '{name}' not found"))?;
        layer.weight = weight.clamp(0.0, 1.0);
        Ok(())
    }

    /// Returns the current weight of a layer, or `None` if not found.
    ///
    /// # Parameters
    /// - `name` — `&str` — layer name.
    ///
    /// # Returns
    /// `Option<f32>`.
    pub fn get_weight(&self, name: &str) -> Option<f32> {
        self.layers.iter().find(|l| l.name == name).map(|l| l.weight)
    }

    /// Replaces the bone mask of a layer.  Returns `Err` if not found.
    ///
    /// # Parameters
    /// - `name` — `&str` — layer to modify.
    /// - `mask` — `BlendMask` — new mask.
    ///
    /// # Returns
    /// `Result<(), String>`.
    pub fn set_mask(&mut self, name: &str, mask: BlendMask) -> Result<(), String> {
        let layer = self
            .layers
            .iter_mut()
            .find(|l| l.name == name)
            .ok_or_else(|| format!("blend: layer '{name}' not found"))?;
        layer.mask = mask;
        Ok(())
    }

    /// Returns a reference to the ordered layer list.
    ///
    /// # Returns
    /// `&[BlendLayer]`.
    pub fn layers(&self) -> &[BlendLayer] {
        &self.layers
    }

    /// Returns an immutable reference to a named layer, or `None`.
    ///
    /// # Parameters
    /// - `name` — `&str`.
    ///
    /// # Returns
    /// `Option<&BlendLayer>`.
    pub fn get_layer(&self, name: &str) -> Option<&BlendLayer> {
        self.layers.iter().find(|l| l.name == name)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn blend_mask_all_matches_everything() {
        let mask = BlendMask::all();
        assert!(mask.includes("torso"));
        assert!(mask.includes("arm_l"));
    }

    #[test]
    fn blend_mask_from_bones_filters() {
        let mask = BlendMask::from_bones(vec!["arm_l".to_string(), "arm_r".to_string()]);
        assert!(mask.includes("arm_l"));
        assert!(!mask.includes("torso"));
    }

    #[test]
    fn blend_layer_clamps_weight() {
        let layer = BlendLayer::new("base", "idle", 1.5, BlendMask::all());
        assert!((layer.weight - 1.0).abs() < 1e-5);
        let layer2 = BlendLayer::new("base2", "idle", -0.5, BlendMask::all());
        assert!((layer2.weight).abs() < 1e-5);
    }

    #[test]
    fn layer_set_add_and_remove() {
        let mut set = BlendLayerSet::new();
        assert!(set.is_empty());
        set.add_layer(BlendLayer::new("base", "idle", 1.0, BlendMask::all())).unwrap();
        assert_eq!(set.len(), 1);
        set.remove_layer("base").unwrap();
        assert!(set.is_empty());
    }

    #[test]
    fn layer_set_rejects_duplicate_name() {
        let mut set = BlendLayerSet::new();
        set.add_layer(BlendLayer::new("base", "idle", 1.0, BlendMask::all())).unwrap();
        assert!(set.add_layer(BlendLayer::new("base", "walk", 0.5, BlendMask::all())).is_err());
    }

    #[test]
    fn set_weight_clamps_and_reads_back() {
        let mut set = BlendLayerSet::new();
        set.add_layer(BlendLayer::new("a", "idle", 0.5, BlendMask::all())).unwrap();
        set.set_weight("a", 0.8).unwrap();
        assert!((set.get_weight("a").unwrap() - 0.8).abs() < 1e-5);
    }

    #[test]
    fn remove_nonexistent_layer_errors() {
        let mut set = BlendLayerSet::new();
        assert!(set.remove_layer("ghost").is_err());
    }
}
