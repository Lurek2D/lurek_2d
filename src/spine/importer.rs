//! Imports standard Spine and DragonBones JSON skeleton shapes into runtime Skeleton data. `spine/importer` delivers the importer implementation for the spine subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! The importer focuses on common production fields for bones, slots, skins, and basic timelines. The file owns or coordinates data contracts including `SpineImportError`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! It intentionally rejects malformed or unsupported structures with explicit, stable errors. Public callable behavior is centered on `skeleton_from_json_str`, `skeleton_from_json_value`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
//! `spine/importer` delivers the importer implementation for the spine subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! The file owns or coordinates data contracts including `SpineImportError`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Public callable behavior is centered on `skeleton_from_json_str`, `skeleton_from_json_value`, while method-level behavior such as no named public items stays attached to the local data model and invariants.

use crate::spine::timeline::{BoneProperty, EasingType, SkeletonAnimation};
use crate::spine::{BoneParams, Skeleton};
use serde_json::Value;
use std::collections::HashMap;
use std::fmt::{Display, Formatter};

/// Error type returned when parsing a Spine or DragonBones JSON payload fails.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum SpineImportError {
    /// JSON text cannot be parsed.
    InvalidJson(String),
    /// Payload does not look like either supported skeleton format.
    UnsupportedFormat,
    /// A required field is missing.
    MissingField(&'static str),
    /// A required field has invalid type or value.
    InvalidField(&'static str),
    /// A bone references a missing parent by name.
    UnknownParent { child: String, parent: String },
    /// A slot references an unknown bone by name.
    UnknownBoneForSlot { slot: String, bone: String },
    /// An animation channel references an unknown bone by name.
    UnknownAnimationBone(String),
}

impl Display for SpineImportError {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::InvalidJson(e) => write!(f, "invalid json: {e}"),
            Self::UnsupportedFormat => {
                write!(
                    f,
                    "unsupported skeleton format (expected Spine bones[] or DragonBones armature[])"
                )
            }
            Self::MissingField(name) => write!(f, "missing required field '{name}'"),
            Self::InvalidField(name) => write!(f, "invalid field '{name}'"),
            Self::UnknownParent { child, parent } => {
                write!(f, "unknown parent bone '{parent}' for bone '{child}'")
            }
            Self::UnknownBoneForSlot { slot, bone } => {
                write!(f, "unknown bone '{bone}' for slot '{slot}'")
            }
            Self::UnknownAnimationBone(name) => {
                write!(f, "animation references unknown bone '{name}'")
            }
        }
    }
}

impl std::error::Error for SpineImportError {}

/// Parse skeleton JSON text in Spine or DragonBones shape.
pub fn skeleton_from_json_str(json: &str) -> Result<Skeleton, SpineImportError> {
    let root: Value =
        serde_json::from_str(json).map_err(|e| SpineImportError::InvalidJson(e.to_string()))?;
    skeleton_from_json_value(&root)
}

/// Parse a skeleton from a JSON value in Spine or DragonBones shape.
pub fn skeleton_from_json_value(root: &Value) -> Result<Skeleton, SpineImportError> {
    if root.get("bones").is_some() {
        parse_spine(root)
    } else if root.get("armature").is_some() {
        parse_dragonbones(root)
    } else {
        Err(SpineImportError::UnsupportedFormat)
    }
}

fn parse_spine(root: &Value) -> Result<Skeleton, SpineImportError> {
    let skel_name = root
        .get("skeleton")
        .and_then(|s| s.get("name"))
        .and_then(Value::as_str)
        .unwrap_or("spine_import");
    let mut skeleton = Skeleton::new(skel_name);
    let mut bone_map: HashMap<String, usize> = HashMap::new();

    let bones = root
        .get("bones")
        .and_then(Value::as_array)
        .ok_or(SpineImportError::MissingField("bones"))?;
    for bone in bones {
        let name = req_str(bone, "name")?.to_string();
        let parent_idx =
            match bone.get("parent").and_then(Value::as_str) {
                Some(parent_name) => Some(*bone_map.get(parent_name).ok_or_else(|| {
                    SpineImportError::UnknownParent {
                        child: name.clone(),
                        parent: parent_name.to_string(),
                    }
                })?),
                None => None,
            };

        let idx = skeleton.add_bone_full(BoneParams {
            name: name.clone(),
            parent_index: parent_idx,
            x: num_any(bone, &["x"]).unwrap_or(0.0),
            y: num_any(bone, &["y"]).unwrap_or(0.0),
            rotation: deg_to_rad(num_any(bone, &["rotation"]).unwrap_or(0.0)),
            scale_x: num_any(bone, &["scaleX", "scale_x"]).unwrap_or(1.0),
            scale_y: num_any(bone, &["scaleY", "scale_y"]).unwrap_or(1.0),
        });
        bone_map.insert(name, idx);
    }

    if let Some(slots) = root.get("slots").and_then(Value::as_array) {
        for slot in slots {
            let slot_name = req_str(slot, "name")?;
            let bone_name = req_str(slot, "bone")?;
            let bone_idx =
                *bone_map
                    .get(bone_name)
                    .ok_or_else(|| SpineImportError::UnknownBoneForSlot {
                        slot: slot_name.to_string(),
                        bone: bone_name.to_string(),
                    })?;
            let attachment = slot
                .get("attachment")
                .and_then(Value::as_str)
                .map(str::to_string);
            skeleton.add_slot_full(slot_name, bone_idx, attachment);
        }
    }

    parse_spine_skins(root, &mut skeleton);
    parse_spine_animations(root, &bone_map, &mut skeleton)?;

    skeleton.update_world_transforms();
    Ok(skeleton)
}

fn parse_spine_skins(root: &Value, skeleton: &mut Skeleton) {
    let Some(skins) = root.get("skins") else {
        return;
    };

    if let Some(skins_obj) = skins.as_object() {
        for (skin_name, slot_map) in skins_obj {
            skeleton.add_skin(skin_name);
            if let Some(slot_map_obj) = slot_map.as_object() {
                for (slot_name, attachments) in slot_map_obj {
                    if let Some(att_name) = first_attachment_name(attachments) {
                        skeleton.set_skin_mapping(skin_name, slot_name, att_name);
                    }
                }
            }
        }
        return;
    }

    if let Some(skins_arr) = skins.as_array() {
        for skin in skins_arr {
            let skin_name = skin
                .get("name")
                .and_then(Value::as_str)
                .unwrap_or("default");
            skeleton.add_skin(skin_name);

            if let Some(attachments) = skin.get("attachments").and_then(Value::as_object) {
                for (slot_name, slot_attachments) in attachments {
                    if let Some(att_name) = first_attachment_name(slot_attachments) {
                        skeleton.set_skin_mapping(skin_name, slot_name, att_name);
                    }
                }
            }
        }
    }
}

fn parse_spine_animations(
    root: &Value,
    bone_map: &HashMap<String, usize>,
    skeleton: &mut Skeleton,
) -> Result<(), SpineImportError> {
    let Some(animations) = root.get("animations").and_then(Value::as_object) else {
        return Ok(());
    };

    for (anim_name, anim_value) in animations {
        let mut max_time = 0.0_f32;
        let mut anim = SkeletonAnimation::new(anim_name, 0.0);

        if let Some(bones_obj) = anim_value.get("bones").and_then(Value::as_object) {
            for (bone_name, channels) in bones_obj {
                let bone_idx = *bone_map
                    .get(bone_name)
                    .ok_or_else(|| SpineImportError::UnknownAnimationBone(bone_name.clone()))?;
                if let Some(channels_obj) = channels.as_object() {
                    parse_spine_rotate_channel(channels_obj, bone_idx, &mut anim, &mut max_time);
                    parse_spine_translate_channel(channels_obj, bone_idx, &mut anim, &mut max_time);
                    parse_spine_scale_channel(channels_obj, bone_idx, &mut anim, &mut max_time);
                }
            }
        }

        if let Some(events_obj) = anim_value.get("events").and_then(Value::as_object) {
            for (event_name, entries) in events_obj {
                if let Some(entries_arr) = entries.as_array() {
                    for entry in entries_arr {
                        let t = num_any(entry, &["time"]).unwrap_or(0.0);
                        let value = num_any(entry, &["float", "int", "value"]).unwrap_or(0.0);
                        anim.add_event_key(t, event_name, value);
                        max_time = max_time.max(t);
                    }
                }
            }
        }

        let explicit_duration = num_any(anim_value, &["duration"]).unwrap_or(0.0);
        anim.duration = explicit_duration.max(max_time);
        skeleton.add_animation(anim);
    }

    Ok(())
}

fn parse_spine_rotate_channel(
    channels: &serde_json::Map<String, Value>,
    bone_idx: usize,
    anim: &mut SkeletonAnimation,
    max_time: &mut f32,
) {
    let Some(keys) = channels.get("rotate").and_then(Value::as_array) else {
        return;
    };
    for key in keys {
        let t = num_any(key, &["time"]).unwrap_or(0.0);
        let v = deg_to_rad(num_any(key, &["angle", "value"]).unwrap_or(0.0));
        anim.add_keyframe(
            bone_idx,
            BoneProperty::Rotation,
            t,
            v,
            parse_spine_easing(key),
        );
        *max_time = (*max_time).max(t);
    }
}

fn parse_spine_translate_channel(
    channels: &serde_json::Map<String, Value>,
    bone_idx: usize,
    anim: &mut SkeletonAnimation,
    max_time: &mut f32,
) {
    let Some(keys) = channels.get("translate").and_then(Value::as_array) else {
        return;
    };
    for key in keys {
        let t = num_any(key, &["time"]).unwrap_or(0.0);
        if let Some(x) = num_any(key, &["x"]) {
            anim.add_keyframe(bone_idx, BoneProperty::X, t, x, parse_spine_easing(key));
        }
        if let Some(y) = num_any(key, &["y"]) {
            anim.add_keyframe(bone_idx, BoneProperty::Y, t, y, parse_spine_easing(key));
        }
        *max_time = (*max_time).max(t);
    }
}

fn parse_spine_scale_channel(
    channels: &serde_json::Map<String, Value>,
    bone_idx: usize,
    anim: &mut SkeletonAnimation,
    max_time: &mut f32,
) {
    let Some(keys) = channels.get("scale").and_then(Value::as_array) else {
        return;
    };
    for key in keys {
        let t = num_any(key, &["time"]).unwrap_or(0.0);
        if let Some(x) = num_any(key, &["x"]) {
            anim.add_keyframe(
                bone_idx,
                BoneProperty::ScaleX,
                t,
                x,
                parse_spine_easing(key),
            );
        }
        if let Some(y) = num_any(key, &["y"]) {
            anim.add_keyframe(
                bone_idx,
                BoneProperty::ScaleY,
                t,
                y,
                parse_spine_easing(key),
            );
        }
        *max_time = (*max_time).max(t);
    }
}

fn parse_spine_easing(key: &Value) -> EasingType {
    match key.get("curve") {
        Some(Value::String(s)) if s == "stepped" => EasingType::Step,
        _ => EasingType::Linear,
    }
}

fn parse_dragonbones(root: &Value) -> Result<Skeleton, SpineImportError> {
    let armature = root
        .get("armature")
        .and_then(Value::as_array)
        .and_then(|arr| arr.first())
        .ok_or(SpineImportError::MissingField("armature[0]"))?;

    let skel_name = armature
        .get("name")
        .and_then(Value::as_str)
        .unwrap_or("dragonbones_import");
    let mut skeleton = Skeleton::new(skel_name);
    let mut bone_map: HashMap<String, usize> = HashMap::new();

    if let Some(bones) = armature.get("bone").and_then(Value::as_array) {
        for bone in bones {
            let name = req_str(bone, "name")?.to_string();
            let transform = bone.get("transform");

            let x = num_nested(transform, &["x"])
                .or_else(|| num_any(bone, &["x"]))
                .unwrap_or(0.0);
            let y = num_nested(transform, &["y"])
                .or_else(|| num_any(bone, &["y"]))
                .unwrap_or(0.0);
            let rot_deg = num_nested(transform, &["skX", "rotate"])
                .or_else(|| num_any(bone, &["rotation"]))
                .unwrap_or(0.0);
            let sx = num_nested(transform, &["scX", "scaleX"]).unwrap_or(1.0);
            let sy = num_nested(transform, &["scY", "scaleY"]).unwrap_or(1.0);

            let parent_idx = match bone.get("parent").and_then(Value::as_str) {
                Some(parent_name) => Some(*bone_map.get(parent_name).ok_or_else(|| {
                    SpineImportError::UnknownParent {
                        child: name.clone(),
                        parent: parent_name.to_string(),
                    }
                })?),
                None => None,
            };

            let idx = skeleton.add_bone_full(BoneParams {
                name: name.clone(),
                parent_index: parent_idx,
                x,
                y,
                rotation: deg_to_rad(rot_deg),
                scale_x: sx,
                scale_y: sy,
            });
            bone_map.insert(name, idx);
        }
    }

    if let Some(slots) = armature.get("slot").and_then(Value::as_array) {
        for slot in slots {
            let slot_name = req_str(slot, "name")?;
            let bone_name = slot
                .get("parent")
                .and_then(Value::as_str)
                .or_else(|| slot.get("bone").and_then(Value::as_str))
                .ok_or(SpineImportError::MissingField("slot.parent"))?;
            let bone_idx =
                *bone_map
                    .get(bone_name)
                    .ok_or_else(|| SpineImportError::UnknownBoneForSlot {
                        slot: slot_name.to_string(),
                        bone: bone_name.to_string(),
                    })?;
            let attachment = slot
                .get("displayName")
                .and_then(Value::as_str)
                .map(str::to_string);
            skeleton.add_slot_full(slot_name, bone_idx, attachment);
        }
    }

    parse_dragonbones_skins(armature, &mut skeleton);
    parse_dragonbones_animations(root, armature, &bone_map, &mut skeleton)?;

    skeleton.update_world_transforms();
    Ok(skeleton)
}

fn parse_dragonbones_skins(armature: &Value, skeleton: &mut Skeleton) {
    let Some(skins) = armature.get("skin").and_then(Value::as_array) else {
        return;
    };

    for skin in skins {
        let skin_name = skin
            .get("name")
            .and_then(Value::as_str)
            .unwrap_or("default");
        skeleton.add_skin(skin_name);

        if let Some(slot_entries) = skin.get("slot").and_then(Value::as_array) {
            for slot_entry in slot_entries {
                let Some(slot_name) = slot_entry.get("name").and_then(Value::as_str) else {
                    continue;
                };
                let attachment = slot_entry
                    .get("display")
                    .and_then(Value::as_array)
                    .and_then(|displays| displays.first())
                    .and_then(|d| d.get("name"))
                    .and_then(Value::as_str);
                if let Some(att_name) = attachment {
                    skeleton.set_skin_mapping(skin_name, slot_name, att_name);
                }
            }
        }
    }
}

fn parse_dragonbones_animations(
    root: &Value,
    armature: &Value,
    bone_map: &HashMap<String, usize>,
    skeleton: &mut Skeleton,
) -> Result<(), SpineImportError> {
    let Some(anims) = armature.get("animation").and_then(Value::as_array) else {
        return Ok(());
    };

    let frame_rate = num_any(root, &["frameRate"])
        .or_else(|| num_any(armature, &["frameRate"]))
        .unwrap_or(24.0)
        .max(1.0);

    for anim_json in anims {
        let anim_name = req_str(anim_json, "name")?;
        let mut max_time = 0.0_f32;

        let duration_frames = num_any(anim_json, &["duration"]).unwrap_or(0.0);
        let mut anim = SkeletonAnimation::new(anim_name, duration_frames / frame_rate);

        if let Some(bones) = anim_json.get("bone").and_then(Value::as_array) {
            for bone_entry in bones {
                let bone_name = req_str(bone_entry, "name")?;
                let bone_idx = *bone_map
                    .get(bone_name)
                    .ok_or_else(|| SpineImportError::UnknownAnimationBone(bone_name.to_string()))?;

                parse_dragonbones_frame_channel(
                    bone_entry.get("translateFrame"),
                    frame_rate,
                    |entry, time, anim| {
                        if let Some(x) = num_any(entry, &["x"]) {
                            anim.add_keyframe(
                                bone_idx,
                                BoneProperty::X,
                                time,
                                x,
                                EasingType::Linear,
                            );
                        }
                        if let Some(y) = num_any(entry, &["y"]) {
                            anim.add_keyframe(
                                bone_idx,
                                BoneProperty::Y,
                                time,
                                y,
                                EasingType::Linear,
                            );
                        }
                    },
                    &mut anim,
                    &mut max_time,
                );

                parse_dragonbones_frame_channel(
                    bone_entry.get("rotateFrame"),
                    frame_rate,
                    |entry, time, anim| {
                        if let Some(rot) = num_any(entry, &["rotate", "skX"]) {
                            anim.add_keyframe(
                                bone_idx,
                                BoneProperty::Rotation,
                                time,
                                deg_to_rad(rot),
                                EasingType::Linear,
                            );
                        }
                    },
                    &mut anim,
                    &mut max_time,
                );

                parse_dragonbones_frame_channel(
                    bone_entry.get("scaleFrame"),
                    frame_rate,
                    |entry, time, anim| {
                        if let Some(sx) = num_any(entry, &["x", "scX"]) {
                            anim.add_keyframe(
                                bone_idx,
                                BoneProperty::ScaleX,
                                time,
                                sx,
                                EasingType::Linear,
                            );
                        }
                        if let Some(sy) = num_any(entry, &["y", "scY"]) {
                            anim.add_keyframe(
                                bone_idx,
                                BoneProperty::ScaleY,
                                time,
                                sy,
                                EasingType::Linear,
                            );
                        }
                    },
                    &mut anim,
                    &mut max_time,
                );
            }
        }

        anim.duration = anim.duration.max(max_time);
        skeleton.add_animation(anim);
    }

    Ok(())
}

fn parse_dragonbones_frame_channel<F>(
    channel: Option<&Value>,
    frame_rate: f32,
    mut emit: F,
    anim: &mut SkeletonAnimation,
    max_time: &mut f32,
) where
    F: FnMut(&Value, f32, &mut SkeletonAnimation),
{
    let Some(frames) = channel.and_then(Value::as_array) else {
        return;
    };

    let mut cursor_frames = 0.0_f32;
    for frame in frames {
        let time = cursor_frames / frame_rate;
        emit(frame, time, anim);
        *max_time = (*max_time).max(time);
        let step = num_any(frame, &["duration"]).unwrap_or(0.0).max(0.0);
        cursor_frames += step;
    }
}

fn req_str<'a>(obj: &'a Value, field: &'static str) -> Result<&'a str, SpineImportError> {
    obj.get(field)
        .and_then(Value::as_str)
        .ok_or(SpineImportError::MissingField(field))
}

fn num_any(obj: &Value, keys: &[&str]) -> Option<f32> {
    keys.iter()
        .find_map(|k| obj.get(*k).and_then(Value::as_f64).map(|v| v as f32))
}

fn num_nested(obj: Option<&Value>, keys: &[&str]) -> Option<f32> {
    obj.and_then(|o| num_any(o, keys))
}

fn first_attachment_name(v: &Value) -> Option<&str> {
    v.as_object()?.keys().next().map(String::as_str)
}

fn deg_to_rad(v: f32) -> f32 {
    v.to_radians()
}
