//! Skeleton container holding bones, slots, and Atlas data.

use std::collections::HashMap;

use super::bone::Bone;
use super::slot::Slot;
use super::ik::IKConstraint;
use super::timeline::SkeletonAnimation;
use crate::runtime::log_messages::SP01_SKEL_LOADED;
use crate::log_msg;

/// Parameters for creating and adding a bone in one call.
///
/// # Fields
/// - `name` — `String`. Bone name.
/// - `parent_index` — `Option<usize>`. Parent bone index, or `None` for root.
/// - `x` — `f32`. Local X offset.
/// - `y` — `f32`. Local Y offset.
/// - `rotation` — `f32`. Local rotation in radians.
/// - `scale_x` — `f32`. Local X scale.
/// - `scale_y` — `f32`. Local Y scale.
pub struct BoneParams {
    pub name: String,
    pub parent_index: Option<usize>,
    pub x: f32,
    pub y: f32,
    pub rotation: f32,
    pub scale_x: f32,
    pub scale_y: f32,
}

/// A skeletal animation rig composed of a bone hierarchy and render slots.
///
/// The skeleton owns a flat array of `Bone`s where parent indices point
/// into earlier entries (bones must be added in topological order —
/// parent before child). Calling `update_world_transforms()` propagates
/// local transforms down the hierarchy to produce world-space positions.
///
/// # Fields
/// - `name` — `String`. Skeleton name.
/// - `bones` — `Vec<Bone>`. Bone array.
/// - `slots` — `Vec<Slot>`. Render slots bound to bones.
/// - `x`, `y` — `f32`. World-space root position.
/// - `scale_x`, `scale_y` — `f32`. Root scale.
/// - `animations` — `Vec<SkeletonAnimation>`. Registered animation clips.
/// - `ik_constraints` — `Vec<IKConstraint>`. Active IK constraints.
/// - `skins` — `HashMap<String, HashMap<String, String>>`. Skin slot-attachment overrides.
/// - `active_skin` — `Option<String>`. Currently active skin name.
/// - `current_animation` — `Option<String>`. Currently active animation name.
/// - `anim_time` — `f32`. Current playback time in seconds.
/// - `anim_playing` — `bool`. Whether the animation is playing.
/// - `anim_loop` — `bool`. Whether the current animation loops.
#[derive(Debug, Clone)]
pub struct Skeleton {
    pub name: String,
    pub bones: Vec<Bone>,
    pub slots: Vec<Slot>,
    pub x: f32,
    pub y: f32,
    pub scale_x: f32,
    pub scale_y: f32,
    /// Registered skeleton animation clips.
    pub animations: Vec<SkeletonAnimation>,
    /// Active IK constraints.
    pub ik_constraints: Vec<IKConstraint>,
    /// Skin slot-to-attachment override maps.
    pub skins: HashMap<String, HashMap<String, String>>,
    /// Currently active skin name, if any.
    pub active_skin: Option<String>,
    /// Currently active animation name, if any.
    pub current_animation: Option<String>,
    /// Current playback time of the active animation in seconds.
    pub anim_time: f32,
    /// Whether the animation is currently playing.
    pub anim_playing: bool,
    /// Whether the current animation should loop.
    pub anim_loop: bool,
}

impl Skeleton {
    /// Creates a new empty skeleton.
    ///
    /// # Parameters
    /// - `name` — `impl Into<String>`. Skeleton name.
    ///
    /// # Returns
    /// `Skeleton` at the origin with unit scale and no bones or slots.
    pub fn new(name: impl Into<String>) -> Self {
        log_msg!(info, SP01_SKEL_LOADED);
        Self {
            name: name.into(),
            bones: Vec::new(),
            slots: Vec::new(),
            x: 0.0,
            y: 0.0,
            scale_x: 1.0,
            scale_y: 1.0,
            animations: Vec::new(),
            ik_constraints: Vec::new(),
            skins: HashMap::new(),
            active_skin: None,
            current_animation: None,
            anim_time: 0.0,
            anim_playing: false,
            anim_loop: true,
        }
    }

    /// Adds a bone to the skeleton and returns its index.
    ///
    /// Bones must be added in topological order (parent before child).
    ///
    /// # Parameters
    /// - `bone` — `Bone`. The bone to add.
    ///
    /// # Returns
    /// `usize` — index of the newly added bone.
    pub fn add_bone(&mut self, bone: Bone) -> usize {
        let idx = self.bones.len();
        self.bones.push(bone);
        idx
    }

    /// Adds a slot to the skeleton and returns its index.
    ///
    /// # Parameters
    /// - `slot` — `Slot`. The slot to add.
    ///
    /// # Returns
    /// `usize` — index of the newly added slot.
    pub fn add_slot(&mut self, slot: Slot) -> usize {
        let idx = self.slots.len();
        self.slots.push(slot);
        idx
    }

    /// Finds a bone by name and returns its index.
    ///
    /// # Parameters
    /// - `name` — `&str`. Bone name to search for.
    ///
    /// # Returns
    /// `Option<usize>` — bone index, or `None` if not found.
    pub fn find_bone(&self, name: &str) -> Option<usize> {
        self.bones.iter().position(|b| b.name == name)
    }

    /// Finds a slot by name and returns its index.
    ///
    /// # Parameters
    /// - `name` — `&str`. Slot name to search for.
    ///
    /// # Returns
    /// `Option<usize>` — slot index, or `None` if not found.
    pub fn find_slot(&self, name: &str) -> Option<usize> {
        self.slots.iter().position(|s| s.name == name)
    }

    /// Creates and adds a bone with the given local transform in one call.
    ///
    /// # Parameters
    /// - `params` — `BoneParams`. Bone creation parameters.
    ///
    /// # Returns
    /// `usize` — index of the newly added bone.
    pub fn add_bone_full(&mut self, params: BoneParams) -> usize {
        let mut bone = match params.parent_index {
            None => Bone::new(&params.name),
            Some(pi) => Bone::with_parent(&params.name, pi, params.x, params.y),
        };
        bone.local_x = params.x;
        bone.local_y = params.y;
        bone.local_rotation = params.rotation;
        bone.local_scale_x = params.scale_x;
        bone.local_scale_y = params.scale_y;
        self.add_bone(bone)
    }

    /// Creates and adds a slot with an optional attachment name in one call.
    ///
    /// # Parameters
    /// - `name` — `&str`. Slot name.
    /// - `bone_index` — `usize`. Index of the bone this slot is bound to.
    /// - `attachment` — `Option<String>`. Initial attachment name.
    ///
    /// # Returns
    /// `usize` — index of the newly added slot.
    pub fn add_slot_full(
        &mut self,
        name: &str,
        bone_index: usize,
        attachment: Option<String>,
    ) -> usize {
        let mut slot = Slot::new(name, bone_index);
        slot.attachment_name = attachment;
        self.add_slot(slot)
    }

    /// Returns the world-space transform of the bone at the given index.
    ///
    /// # Parameters
    /// - `idx` — `usize`. Bone index.
    ///
    /// # Returns
    /// `Option<(f32, f32, f32, f32, f32)>` — `(x, y, rotation, scale_x, scale_y)` or `None`.
    pub fn bone_world_transform(&self, idx: usize) -> Option<(f32, f32, f32, f32, f32)> {
        self.bones.get(idx).map(|b| {
            (b.world_x, b.world_y, b.world_rotation, b.world_scale_x, b.world_scale_y)
        })
    }

    /// Sets the root bone's local position and propagates world transforms.
    ///
    /// # Parameters
    /// - `x` — `f32`. New local X.
    /// - `y` — `f32`. New local Y.
    pub fn set_root_position(&mut self, x: f32, y: f32) {
        if let Some(root) = self.bones.first_mut() {
            root.local_x = x;
            root.local_y = y;
        }
        self.update_world_transforms();
    }

    /// Returns the number of bones in this skeleton.
    ///
    /// # Returns
    /// `usize`.
    pub fn bone_count(&self) -> usize {
        self.bones.len()
    }

    // ── Skeleton animations ──────────────────────────────────────────────

    /// Adds a [`SkeletonAnimation`] to this skeleton's animation library.
    ///
    /// # Parameters
    /// - `anim` — [`SkeletonAnimation`].
    pub fn add_animation(&mut self, anim: SkeletonAnimation) {
        self.animations.push(anim);
    }

    /// Returns the index of the animation with the given name.
    ///
    /// # Parameters
    /// - `name` — `&str`.
    ///
    /// # Returns
    /// `Option<usize>`.
    pub fn find_animation(&self, name: &str) -> Option<usize> {
        self.animations.iter().position(|a| a.name == name)
    }

    /// Starts playing the named animation.
    ///
    /// # Parameters
    /// - `name` — `&str`. Animation name.
    /// - `looping` — `bool`. Whether to loop.
    ///
    /// # Returns
    /// `bool` — `true` if the animation was found.
    pub fn play_animation(&mut self, name: &str, looping: bool) -> bool {
        if self.find_animation(name).is_some() {
            self.current_animation = Some(name.to_string());
            self.anim_time = 0.0;
            self.anim_playing = true;
            self.anim_loop = looping;
            true
        } else {
            false
        }
    }

    /// Stops playback of the current animation.
    pub fn stop_animation(&mut self) {
        self.anim_playing = false;
    }

    /// Advances the active animation by `dt` seconds, applies keyframes, and wraps or stops at the end.
    ///
    /// # Parameters
    /// - `dt` — `f32`. Delta time in seconds.
    pub fn update_animation(&mut self, dt: f32) {
        if !self.anim_playing {
            return;
        }
        let anim_idx = match &self.current_animation {
            Some(n) => match self.animations.iter().position(|a| a.name == *n) {
                Some(i) => i,
                None => return,
            },
            None => return,
        };

        self.anim_time += dt;

        let (duration, looping) = {
            let anim = &self.animations[anim_idx];
            (anim.duration, self.anim_loop)
        };

        if looping && duration > 0.0 {
            self.anim_time %= duration;
        } else if self.anim_time >= duration {
            self.anim_time = duration;
            self.anim_playing = false;
        }

        let anim = self.animations[anim_idx].clone();
        let time = self.anim_time;
        anim.apply_to_skeleton(self, time);
    }

    /// Returns the current playback time in seconds.
    ///
    /// # Returns
    /// `f32`.
    pub fn get_animation_time(&self) -> f32 {
        self.anim_time
    }

    // ── IK constraints ───────────────────────────────────────────────────

    /// Adds an IK constraint and returns its index.
    ///
    /// # Parameters
    /// - `constraint` — [`IKConstraint`].
    ///
    /// # Returns
    /// `usize`.
    pub fn add_ik_constraint(&mut self, constraint: IKConstraint) -> usize {
        let idx = self.ik_constraints.len();
        self.ik_constraints.push(constraint);
        idx
    }

    /// Sets the target position for the named IK constraint.
    ///
    /// # Parameters
    /// - `name` — `&str`. Constraint name.
    /// - `x` — `f32`. Target X.
    /// - `y` — `f32`. Target Y.
    ///
    /// # Returns
    /// `bool` — `true` if the constraint was found.
    pub fn set_ik_target(&mut self, name: &str, x: f32, y: f32) -> bool {
        if let Some(c) = self.ik_constraints.iter_mut().find(|c| c.name == name) {
            c.set_target(x, y);
            true
        } else {
            false
        }
    }

    /// Evaluates all IK constraints and writes resulting rotations into the bone array.
    ///
    /// Call after `update_animation` and before `update_world_transforms` for best results.
    pub fn apply_ik_constraints(&mut self) {
        for i in 0..self.ik_constraints.len() {
            let constraint = self.ik_constraints[i].clone();
            constraint.solve(&mut self.bones);
        }
    }

    // ── Skins ────────────────────────────────────────────────────────────

    /// Registers a new empty skin by name.
    ///
    /// # Parameters
    /// - `name` — `&str`. Skin name.
    pub fn add_skin(&mut self, name: &str) {
        self.skins.entry(name.to_string()).or_default();
    }

    /// Sets the active skin, changing slot attachment lookups.
    ///
    /// # Parameters
    /// - `name` — `&str`. Skin name.
    ///
    /// # Returns
    /// `bool` — `true` if the skin exists.
    pub fn set_skin(&mut self, name: &str) -> bool {
        if self.skins.contains_key(name) {
            self.active_skin = Some(name.to_string());
            true
        } else {
            false
        }
    }

    /// Returns the name of the currently active skin.
    ///
    /// # Returns
    /// `Option<&str>`.
    pub fn get_skin(&self) -> Option<&str> {
        self.active_skin.as_deref()
    }

    /// Registers a slot-to-attachment mapping within a named skin.
    ///
    /// # Parameters
    /// - `skin` — `&str`. Skin name (created automatically if not yet registered).
    /// - `slot` — `&str`. Slot name.
    /// - `attachment` — `&str`. Attachment resource name.
    pub fn set_skin_mapping(&mut self, skin: &str, slot: &str, attachment: &str) {
        self.skins
            .entry(skin.to_string())
            .or_default()
            .insert(slot.to_string(), attachment.to_string());
    }

    /// Returns the effective attachment name for a slot, consulting the active skin first.
    ///
    /// Falls back to the slot's own `attachment_name` field when no skin override exists.
    ///
    /// # Parameters
    /// - `slot_idx` — `usize`. Slot index.
    ///
    /// # Returns
    /// `Option<&str>`.
    pub fn get_slot_attachment(&self, slot_idx: usize) -> Option<&str> {
        let slot = self.slots.get(slot_idx)?;
        // Check active skin first.
        if let Some(skin_name) = &self.active_skin {
            if let Some(skin_map) = self.skins.get(skin_name) {
                if let Some(att) = skin_map.get(&slot.name) {
                    return Some(att.as_str());
                }
            }
        }
        slot.attachment_name.as_deref()
    }

    /// Returns the number of slots in this skeleton.
    ///
    /// # Returns
    /// `usize`.
    pub fn slot_count(&self) -> usize {
        self.slots.len()
    }

    /// Propagates local transforms down the bone hierarchy to compute world transforms.
    ///
    /// Iterates bones in array order (which must be topological — parent before child).
    /// Root bones (no parent) are transformed by the skeleton's own position and scale.
    /// Child bones compose their local transform with the parent's world transform.
    pub fn update_world_transforms(&mut self) {
        for i in 0..self.bones.len() {
            let (local_x, local_y, local_rot, local_sx, local_sy, parent_idx) = {
                let b = &self.bones[i];
                (
                    b.local_x,
                    b.local_y,
                    b.local_rotation,
                    b.local_scale_x,
                    b.local_scale_y,
                    b.parent_index,
                )
            };

            match parent_idx {
                None => {
                    // Root bone: apply skeleton root transform
                    self.bones[i].world_x = self.x + local_x * self.scale_x;
                    self.bones[i].world_y = self.y + local_y * self.scale_y;
                    self.bones[i].world_rotation = local_rot;
                    self.bones[i].world_scale_x = self.scale_x * local_sx;
                    self.bones[i].world_scale_y = self.scale_y * local_sy;
                }
                Some(pi) => {
                    // Child bone: compose with parent world transform
                    let (pw_x, pw_y, pw_rot, pw_sx, pw_sy) = {
                        let p = &self.bones[pi];
                        (
                            p.world_x,
                            p.world_y,
                            p.world_rotation,
                            p.world_scale_x,
                            p.world_scale_y,
                        )
                    };
                    let cos_r = pw_rot.cos();
                    let sin_r = pw_rot.sin();
                    let sx = local_x * pw_sx;
                    let sy = local_y * pw_sy;

                    self.bones[i].world_x = pw_x + sx * cos_r - sy * sin_r;
                    self.bones[i].world_y = pw_y + sx * sin_r + sy * cos_r;
                    self.bones[i].world_rotation = pw_rot + local_rot;
                    self.bones[i].world_scale_x = pw_sx * local_sx;
                    self.bones[i].world_scale_y = pw_sy * local_sy;
                }
            }
        }
    }

    // ── CPU rendering ──

    /// Renders the skeleton as a stick figure to an `ImageData`.
    ///
    /// Draws bones as lines from parent to child and joint circles at
    /// each bone's world position. Call `update_world_transforms()` before
    /// this method to ensure positions are current.
    ///
    /// # Parameters
    /// - `width` — `u32`.
    /// - `height` — `u32`.
    ///
    /// # Returns
    /// `ImageData`.
    pub fn draw_to_image(&self, width: u32, height: u32) -> crate::image::ImageData {
        let mut img = crate::image::ImageData::new(width, height);
        img.fill(20, 20, 30, 255);

        // Draw bones as lines from parent to child
        for bone in &self.bones {
            if let Some(pi) = bone.parent_index {
                let parent = &self.bones[pi];
                img.draw_line(
                    parent.world_x as i32,
                    parent.world_y as i32,
                    bone.world_x as i32,
                    bone.world_y as i32,
                    200,
                    200,
                    220,
                    255,
                );
            }
        }

        // Draw joint circles at each bone
        for bone in &self.bones {
            img.draw_circle(bone.world_x as i32, bone.world_y as i32, 4, 255, 120, 80, 255);
        }

        img
    }
    /// Draw skeleton with colour-coded joints and bone labels.
    ///
    /// Each bone gets a unique colour; lines show parent→child connections.
    ///
    /// # Parameters
    /// - `width` — `u32`. Image width.
    /// - `height` — `u32`. Image height.
    ///
    /// # Returns
    /// `ImageData`.
    pub fn draw_bones_to_image(&self, width: u32, height: u32) -> crate::image::ImageData {
        let mut img = crate::image::ImageData::new(width, height);
        img.fill(20, 20, 30, 255);

        // Predefined palette for up to 12 bones
        let palette: [(u8, u8, u8); 12] = [
            (255, 200, 80), (200, 100, 100), (255, 150, 100),
            (100, 150, 255), (100, 150, 255), (100, 200, 100),
            (100, 200, 100), (200, 100, 255), (200, 100, 255),
            (180, 180, 80), (80, 180, 180), (180, 80, 180),
        ];

        // Draw bone connections
        for bone in &self.bones {
            if let Some(pi) = bone.parent_index {
                let parent = &self.bones[pi];
                img.draw_line(
                    parent.world_x as i32, parent.world_y as i32,
                    bone.world_x as i32, bone.world_y as i32,
                    180, 180, 200, 255,
                );
            }
        }

        // Draw joint circles with labels
        for (i, bone) in self.bones.iter().enumerate() {
            let (r, g, b) = palette[i % palette.len()];
            img.draw_circle(bone.world_x as i32, bone.world_y as i32, 5, r, g, b, 255);
            let label = bone.name.to_uppercase();
            img.draw_label(&label, bone.world_x as i32 + 8, bone.world_y as i32 - 3, r, g, b);
        }

        let count_str = format!("{} BONES", self.bone_count());
        img.draw_label(&count_str, 10, (height - 15) as i32, 200, 200, 200);
        img.draw_label("SPINE BONES OK", (width / 3) as i32, (height - 15) as i32, 100, 255, 100);
        img
    }

}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::spine::bone::Bone;
    use crate::spine::slot::Slot;
    use crate::spine::ik::IKConstraint;
    use crate::spine::timeline::{BoneProperty, BoneTimeline, EasingType, SkeletonAnimation};

    #[test]
    fn new_skeleton_is_empty() {
        let skel = Skeleton::new("hero");
        assert_eq!(skel.name, "hero");
        assert!(skel.bones.is_empty());
        assert!(skel.slots.is_empty());
        assert_eq!(skel.x, 0.0);
        assert_eq!(skel.y, 0.0);
        assert_eq!(skel.scale_x, 1.0);
        assert_eq!(skel.scale_y, 1.0);
    }

    #[test]
    fn add_bone_returns_incrementing_index() {
        let mut skel = Skeleton::new("test");
        assert_eq!(skel.add_bone(Bone::new("root")), 0);
        assert_eq!(skel.add_bone(Bone::with_parent("arm", 0, 5.0, 0.0)), 1);
        assert_eq!(skel.bone_count(), 2);
    }

    #[test]
    fn add_slot_returns_incrementing_index() {
        let mut skel = Skeleton::new("test");
        skel.add_bone(Bone::new("root"));
        assert_eq!(skel.add_slot(Slot::new("body", 0)), 0);
        assert_eq!(skel.add_slot(Slot::new("hat", 0)), 1);
        assert_eq!(skel.slot_count(), 2);
    }

    #[test]
    fn find_bone_by_name() {
        let mut skel = Skeleton::new("test");
        skel.add_bone(Bone::new("root"));
        skel.add_bone(Bone::with_parent("arm", 0, 5.0, 0.0));
        assert_eq!(skel.find_bone("arm"), Some(1));
        assert_eq!(skel.find_bone("missing"), None);
    }

    #[test]
    fn find_slot_by_name() {
        let mut skel = Skeleton::new("test");
        skel.add_bone(Bone::new("root"));
        skel.add_slot(Slot::new("body", 0));
        assert_eq!(skel.find_slot("body"), Some(0));
        assert_eq!(skel.find_slot("missing"), None);
    }

    #[test]
    fn add_bone_full_with_params() {
        let mut skel = Skeleton::new("test");
        skel.add_bone(Bone::new("root"));
        let idx = skel.add_bone_full(BoneParams {
            name: "leg".to_string(),
            parent_index: Some(0),
            x: 3.0,
            y: -5.0,
            rotation: 0.1,
            scale_x: 1.0,
            scale_y: 1.0,
        });
        assert_eq!(idx, 1);
        assert_eq!(skel.bones[idx].local_x, 3.0);
        assert_eq!(skel.bones[idx].local_y, -5.0);
        assert_eq!(skel.bones[idx].local_rotation, 0.1);
    }

    #[test]
    fn bone_world_transform_in_range() {
        let mut skel = Skeleton::new("test");
        let mut b = Bone::new("root");
        b.world_x = 10.0;
        b.world_y = 20.0;
        b.world_rotation = 0.5;
        b.world_scale_x = 2.0;
        b.world_scale_y = 3.0;
        skel.add_bone(b);
        let t = skel.bone_world_transform(0).unwrap();
        assert_eq!(t, (10.0, 20.0, 0.5, 2.0, 3.0));
    }

    #[test]
    fn bone_world_transform_out_of_range() {
        let skel = Skeleton::new("test");
        assert!(skel.bone_world_transform(0).is_none());
    }

    #[test]
    fn update_world_transforms_root_bone() {
        let mut skel = Skeleton::new("test");
        skel.x = 100.0;
        skel.y = 200.0;
        let mut root = Bone::new("root");
        root.local_x = 10.0;
        root.local_y = 20.0;
        skel.add_bone(root);
        skel.update_world_transforms();
        let b = &skel.bones[0];
        assert_eq!(b.world_x, 110.0);
        assert_eq!(b.world_y, 220.0);
    }

    #[test]
    fn update_world_transforms_child_bone() {
        let mut skel = Skeleton::new("test");
        skel.add_bone(Bone::new("root"));
        skel.add_bone(Bone::with_parent("child", 0, 10.0, 0.0));
        skel.update_world_transforms();
        let child = &skel.bones[1];
        assert_eq!(child.world_x, 10.0);
        assert_eq!(child.world_y, 0.0);
    }

    #[test]
    fn set_root_position_propagates() {
        let mut skel = Skeleton::new("test");
        skel.add_bone(Bone::new("root"));
        skel.add_bone(Bone::with_parent("child", 0, 5.0, 0.0));
        skel.set_root_position(50.0, 60.0);
        assert_eq!(skel.bones[0].world_x, 50.0);
        assert_eq!(skel.bones[0].world_y, 60.0);
    }

    #[test]
    fn play_animation_unknown_returns_false() {
        let mut skel = Skeleton::new("test");
        assert!(!skel.play_animation("missing", false));
    }

    #[test]
    fn play_and_stop_animation() {
        let mut skel = Skeleton::new("test");
        skel.add_bone(Bone::new("root"));
        let anim = SkeletonAnimation::new("walk", 1.0);
        skel.add_animation(anim);
        assert!(skel.play_animation("walk", true));
        assert!(skel.anim_playing);
        skel.stop_animation();
        assert!(!skel.anim_playing);
    }

    #[test]
    fn update_animation_advances_time() {
        let mut skel = Skeleton::new("test");
        skel.add_bone(Bone::new("root"));
        let mut anim = SkeletonAnimation::new("idle", 2.0);
        let mut tl = BoneTimeline::new(0, BoneProperty::X);
        tl.add_key(0.0, 0.0, EasingType::Linear);
        tl.add_key(2.0, 10.0, EasingType::Linear);
        anim.add_timeline(tl);
        skel.add_animation(anim);
        skel.play_animation("idle", false);
        skel.update_animation(0.5);
        assert!((skel.get_animation_time() - 0.5).abs() < 0.01);
    }

    #[test]
    fn animation_loops_wraps_time() {
        let mut skel = Skeleton::new("test");
        skel.add_bone(Bone::new("root"));
        let anim = SkeletonAnimation::new("run", 1.0);
        skel.add_animation(anim);
        skel.play_animation("run", true);
        skel.update_animation(1.5);
        assert!(skel.get_animation_time() < 1.0);
        assert!(skel.anim_playing);
    }

    #[test]
    fn animation_non_loop_stops_at_end() {
        let mut skel = Skeleton::new("test");
        skel.add_bone(Bone::new("root"));
        let anim = SkeletonAnimation::new("die", 1.0);
        skel.add_animation(anim);
        skel.play_animation("die", false);
        skel.update_animation(2.0);
        assert!(!skel.anim_playing);
        assert!((skel.get_animation_time() - 1.0).abs() < 0.01);
    }

    #[test]
    fn add_ik_constraint_returns_index() {
        let mut skel = Skeleton::new("test");
        let ik = IKConstraint::new("arm_ik", vec![0, 1], true);
        assert_eq!(skel.add_ik_constraint(ik), 0);
    }

    #[test]
    fn set_ik_target_found() {
        let mut skel = Skeleton::new("test");
        skel.add_ik_constraint(IKConstraint::new("arm", vec![0, 1], true));
        assert!(skel.set_ik_target("arm", 10.0, 20.0));
    }

    #[test]
    fn set_ik_target_not_found() {
        let mut skel = Skeleton::new("test");
        assert!(!skel.set_ik_target("missing", 0.0, 0.0));
    }

    #[test]
    fn skin_management() {
        let mut skel = Skeleton::new("test");
        skel.add_bone(Bone::new("root"));
        skel.add_slot(Slot::new("body", 0));
        skel.add_skin("default");
        skel.set_skin_mapping("default", "body", "body_normal");
        assert!(skel.set_skin("default"));
        assert_eq!(skel.get_skin(), Some("default"));
        assert!(!skel.set_skin("nonexistent"));
    }

    #[test]
    fn get_slot_attachment_with_skin_override() {
        let mut skel = Skeleton::new("test");
        skel.add_bone(Bone::new("root"));
        let mut slot = Slot::new("body", 0);
        slot.attachment_name = Some("default_body".to_string());
        skel.add_slot(slot);

        // Without skin, returns slot's own attachment
        assert_eq!(skel.get_slot_attachment(0), Some("default_body"));

        // With skin override
        skel.add_skin("armored");
        skel.set_skin_mapping("armored", "body", "armored_body");
        skel.set_skin("armored");
        assert_eq!(skel.get_slot_attachment(0), Some("armored_body"));
    }

    #[test]
    fn get_slot_attachment_out_of_range() {
        let skel = Skeleton::new("test");
        assert!(skel.get_slot_attachment(99).is_none());
    }

    #[test]
    fn add_slot_full_sets_attachment() {
        let mut skel = Skeleton::new("test");
        skel.add_bone(Bone::new("root"));
        let idx = skel.add_slot_full("hat", 0, Some("wizard_hat".to_string()));
        assert_eq!(skel.slots[idx].attachment_name.as_deref(), Some("wizard_hat"));
    }

    #[test]
    fn find_animation_by_name() {
        let mut skel = Skeleton::new("test");
        skel.add_animation(SkeletonAnimation::new("walk", 1.0));
        skel.add_animation(SkeletonAnimation::new("run", 0.5));
        assert_eq!(skel.find_animation("run"), Some(1));
        assert_eq!(skel.find_animation("missing"), None);
    }
}
