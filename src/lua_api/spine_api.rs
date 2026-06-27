//! Registers the `lurek.spine` Lua API for Spine animation userdata, bone options, and validated playback.

use super::physics_api::{lua_body_from_body, LuaPhysicsShape, LuaWorld};
use super::sprite_api::LuaSpriteAtlas;
use super::SharedState;
use crate::image::ImageData;
use crate::physics::{AlphaShapeOptions, Body, BodyType, Shape};
use crate::spine::ik::IKConstraint;
use crate::spine::timeline::{BoneProperty, EasingType, SkeletonAnimation};
use crate::spine::{
    skeleton_from_json_str, AttachmentSource, AttachmentSourceKind, BoneParams, Skeleton,
};
use mlua::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;

fn finite_f32(api: &str, arg_name: &str, value: f32) -> LuaResult<f32> {
    if value.is_finite() {
        Ok(value)
    } else {
        Err(LuaError::RuntimeError(format!(
            "{}: {} must be finite",
            api, arg_name
        )))
    }
}

fn non_negative_f32(api: &str, arg_name: &str, value: f32) -> LuaResult<f32> {
    let value = finite_f32(api, arg_name, value)?;
    if value < 0.0 {
        return Err(LuaError::RuntimeError(format!(
            "{}: {} must be non-negative",
            api, arg_name
        )));
    }
    Ok(value)
}
/// Parses optional bone transform overrides from a Lua table.
fn parse_bone_opts(opts: &Option<LuaTable>) -> LuaResult<(f32, f32, f32, f32, f32)> {
    let (mut x, mut y, mut rot, mut sx, mut sy) = (0.0, 0.0, 0.0, 1.0, 1.0);
    if let Some(tbl) = opts {
        if let Ok(v) = tbl.get::<_, f32>("x") {
            x = v;
        }
        if let Ok(v) = tbl.get::<_, f32>("y") {
            y = v;
        }
        if let Ok(v) = tbl.get::<_, f32>("rotation") {
            rot = v;
        }
        if let Ok(v) = tbl.get::<_, f32>("scale_x") {
            sx = v;
        }
        if let Ok(v) = tbl.get::<_, f32>("scale_y") {
            sy = v;
        }
    }
    Ok((x, y, rot, sx, sy))
}

fn parse_easing(api: &str, easing: Option<String>) -> LuaResult<EasingType> {
    match easing.as_deref().unwrap_or("linear") {
        "linear" => Ok(EasingType::Linear),
        "ease_in" => Ok(EasingType::EaseIn),
        "ease_out" => Ok(EasingType::EaseOut),
        "ease_in_out" => Ok(EasingType::EaseInOut),
        "step" => Ok(EasingType::Step),
        other => Err(LuaError::RuntimeError(format!(
            "{}: unknown easing '{}'",
            api, other
        ))),
    }
}

fn parse_bone_property(api: &str, property: &str) -> LuaResult<BoneProperty> {
    match property {
        "x" => Ok(BoneProperty::X),
        "y" => Ok(BoneProperty::Y),
        "rotation" => Ok(BoneProperty::Rotation),
        "scale_x" => Ok(BoneProperty::ScaleX),
        "scale_y" => Ok(BoneProperty::ScaleY),
        other => Err(LuaError::RuntimeError(format!(
            "{}: unknown property '{}'",
            api, other
        ))),
    }
}

fn parse_bone_ref(api: &str, skeleton: &Skeleton, value: LuaValue) -> LuaResult<usize> {
    match value {
        LuaValue::Integer(idx) if idx >= 0 => {
            let idx = idx as usize;
            if idx < skeleton.bone_count() {
                Ok(idx)
            } else {
                Err(LuaError::RuntimeError(format!(
                    "{}: bone index {} out of bounds for {} bones",
                    api,
                    idx,
                    skeleton.bone_count()
                )))
            }
        }
        LuaValue::Number(idx) if idx.fract() == 0.0 && idx >= 0.0 => {
            parse_bone_ref(api, skeleton, LuaValue::Integer(idx as i64))
        }
        LuaValue::String(name) => {
            let name = name.to_str()?;
            skeleton
                .find_bone(name)
                .ok_or_else(|| LuaError::RuntimeError(format!("{}: unknown bone '{}'", api, name)))
        }
        _ => Err(LuaError::RuntimeError(format!(
            "{}: bone must be a non-negative index or bone name",
            api
        ))),
    }
}

fn table_opt_f32(tbl: &LuaTable, key: &str) -> LuaResult<Option<f32>> {
    tbl.get::<_, Option<f32>>(key).and_then(|value| {
        if let Some(v) = value {
            finite_f32("spine table option", key, v).map(Some)
        } else {
            Ok(None)
        }
    })
}

fn add_key_table_to_animation(
    api: &str,
    anim: &mut SkeletonAnimation,
    bone_idx: usize,
    key: LuaTable,
) -> LuaResult<()> {
    let time = non_negative_f32(api, "time", key.get::<_, f32>("time")?)?;
    let easing = parse_easing(api, key.get::<_, Option<String>>("easing")?)?;
    for property in ["x", "y", "rotation", "scale_x", "scale_y"] {
        if let Some(value) = table_opt_f32(&key, property)? {
            anim.add_keyframe(
                bone_idx,
                parse_bone_property(api, property)?,
                time,
                value,
                easing.clone(),
            );
        }
    }
    Ok(())
}

fn add_bone_track_to_animation(
    api: &str,
    anim: &mut SkeletonAnimation,
    bone_idx: usize,
    keys: LuaTable,
) -> LuaResult<()> {
    for key in keys.sequence_values::<LuaTable>() {
        add_key_table_to_animation(api, anim, bone_idx, key?)?;
    }
    Ok(())
}

fn parse_body_type_for_spine(api: &str, body_type: Option<String>) -> LuaResult<BodyType> {
    match body_type.as_deref().unwrap_or("dynamic") {
        "static" => Ok(BodyType::Static),
        "dynamic" => Ok(BodyType::Dynamic),
        "kinematic" => Ok(BodyType::Kinematic),
        "sensor" => Ok(BodyType::Sensor),
        other => Err(LuaError::RuntimeError(format!(
            "{}: invalid bodyType '{}'",
            api, other
        ))),
    }
}

fn alpha_options_for_spine(
    tbl: &LuaTable,
    defaults: AlphaShapeOptions,
) -> LuaResult<AlphaShapeOptions> {
    let mut options = defaults;
    if let Some(v) = tbl.get::<_, Option<u8>>("alphaThreshold")? {
        options.alpha_threshold = v;
    }
    if let Some(v) = tbl.get::<_, Option<usize>>("maxVertices")? {
        options.max_vertices = v;
    }
    Ok(options)
}

fn attachment_source_from_table(api: &str, table: LuaTable) -> LuaResult<AttachmentSource> {
    let kind_str: String = table.get("kind")?;
    let kind = AttachmentSourceKind::parse(&kind_str).ok_or_else(|| {
        LuaError::RuntimeError(format!(
            "{}: unknown attachment source kind '{}'",
            api, kind_str
        ))
    })?;
    let w = table
        .get::<_, Option<f32>>("w")?
        .or_else(|| table.get::<_, Option<f32>>("width").ok().flatten())
        .unwrap_or(0.0);
    let h = table
        .get::<_, Option<f32>>("h")?
        .or_else(|| table.get::<_, Option<f32>>("height").ok().flatten())
        .unwrap_or(0.0);
    Ok(AttachmentSource {
        kind,
        name: table.get::<_, Option<String>>("name")?,
        x: table.get::<_, Option<f32>>("x")?.unwrap_or(0.0),
        y: table.get::<_, Option<f32>>("y")?.unwrap_or(0.0),
        w,
        h,
        texture_w: table
            .get::<_, Option<f32>>("textureWidth")?
            .or_else(|| table.get::<_, Option<f32>>("texW").ok().flatten())
            .unwrap_or(w),
        texture_h: table
            .get::<_, Option<f32>>("textureHeight")?
            .or_else(|| table.get::<_, Option<f32>>("texH").ok().flatten())
            .unwrap_or(h),
        texture_id: table
            .get::<_, Option<u64>>("textureId")?
            .or_else(|| table.get::<_, Option<u64>>("texture_id").ok().flatten()),
    })
}

fn attachment_source_to_table<'lua>(
    lua: &'lua Lua,
    source: &AttachmentSource,
) -> LuaResult<LuaTable<'lua>> {
    let table = lua.create_table()?;
    table.set("kind", source.kind.as_str())?;
    if let Some(name) = &source.name {
        table.set("name", name.as_str())?;
    }
    table.set("x", source.x)?;
    table.set("y", source.y)?;
    table.set("w", source.w)?;
    table.set("h", source.h)?;
    table.set("textureWidth", source.texture_w)?;
    table.set("textureHeight", source.texture_h)?;
    if let Some(texture_id) = source.texture_id {
        table.set("textureId", texture_id)?;
    }
    Ok(table)
}

struct SpinePhysicsLuaParser;

impl SpinePhysicsLuaParser {
    fn shape_from_spine_part(
        lua: &Lua,
        part: &LuaTable,
        defaults: AlphaShapeOptions,
    ) -> LuaResult<(Shape, f32, f32, f32, bool)> {
        if let Some(shape_value) = part.get::<_, Option<LuaValue>>("shape")? {
            if !matches!(shape_value, LuaValue::Nil) {
                let shape_ud = LuaAnyUserData::from_lua(shape_value, lua)?;
                let shape = shape_ud.borrow::<LuaPhysicsShape>()?.data();
                return Ok((
                    shape.shape,
                    shape.density,
                    shape.friction,
                    shape.restitution,
                    shape.sensor,
                ));
            }
        }

        if let Some(image_value) = part.get::<_, Option<LuaValue>>("image")? {
            if !matches!(image_value, LuaValue::Nil) {
                let image_ud = LuaAnyUserData::from_lua(image_value, lua)?;
                let image = image_ud.borrow::<ImageData>()?;
                let options = alpha_options_for_spine(part, defaults)?;
                let shape = Shape::from_image_alpha(&image, options).map_err(|err| {
                    LuaError::RuntimeError(format!("LSkeleton:bindPhysics: {err}"))
                })?;
                let density = part.get::<_, Option<f32>>("density")?.unwrap_or(1.0);
                let friction = part.get::<_, Option<f32>>("friction")?.unwrap_or(0.5);
                let restitution = part.get::<_, Option<f32>>("restitution")?.unwrap_or(0.0);
                let sensor = part.get::<_, Option<bool>>("sensor")?.unwrap_or(false);
                return Ok((shape, density, friction, restitution, sensor));
            }
        }

        let density = part.get::<_, Option<f32>>("density")?.unwrap_or(1.0);
        let friction = part.get::<_, Option<f32>>("friction")?.unwrap_or(0.5);
        let restitution = part.get::<_, Option<f32>>("restitution")?.unwrap_or(0.0);
        let sensor = part.get::<_, Option<bool>>("sensor")?.unwrap_or(false);
        if let Some(radius) = part.get::<_, Option<f32>>("radius")? {
            return Ok((
                Shape::Circle { radius },
                density,
                friction,
                restitution,
                sensor,
            ));
        }
        let width = part.get::<_, Option<f32>>("width")?.unwrap_or(16.0);
        let height = part.get::<_, Option<f32>>("height")?.unwrap_or(16.0);
        Ok((
            Shape::Rect { width, height },
            density,
            friction,
            restitution,
            sensor,
        ))
    }
}

fn shape_from_spine_part(
    lua: &Lua,
    part: &LuaTable,
    defaults: AlphaShapeOptions,
) -> LuaResult<(Shape, f32, f32, f32, bool)> {
    SpinePhysicsLuaParser::shape_from_spine_part(lua, part, defaults)
}

fn body_from_spine_shape(
    x: f32,
    y: f32,
    shape: Shape,
    body_type: BodyType,
) -> Result<Body, crate::physics::PhysicsError> {
    match shape {
        Shape::Rect { width, height } => Body::try_new(x, y, width, height, body_type),
        Shape::Circle { radius } => Body::try_new_circle(x, y, radius, body_type),
        Shape::Polygon { vertices } => Body::try_new_polygon(x, y, vertices, body_type),
        Shape::Edge { v1, v2 } => Body::try_new_edge(x, y, v1, v2, body_type),
        Shape::Chain { vertices, closed } => Body::try_new_chain(x, y, vertices, closed, body_type),
    }
}

fn set_spine_body_material(
    body: &mut Body,
    shape: &Shape,
    density: f32,
    friction: f32,
    restitution: f32,
    explicit_mass: Option<f32>,
) {
    body.friction = friction;
    body.restitution = restitution;
    body.mass = explicit_mass.unwrap_or_else(|| (shape.area_estimate() * density).max(0.001));
}
/// Lua-facing skeleton object providing bone hierarchy, slots, IK, skins, and animation playback.
pub struct LuaSkeleton {
    inner: Skeleton,
}
impl LuaUserData for LuaSkeleton {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- addBone --
        /// Adds a root-level bone to the skeleton with optional transform properties.
        /// @param | name | string | Unique name for this bone.
        /// @param | opts | table? | Optional table with keys: x, y, rotation, scale_x, scale_y.
        /// @return | integer | Zero-based index of the newly added bone.
        methods.add_method_mut(
            "addBone",
            |_, this, (name, opts): (String, Option<LuaTable>)| {
                let (x, y, rot, sx, sy) = parse_bone_opts(&opts)?;
                Ok(this.inner.add_bone_full(BoneParams {
                    name,
                    parent_index: None,
                    x,
                    y,
                    rotation: rot,
                    scale_x: sx,
                    scale_y: sy,
                }))
            },
        );
        // -- addChildBone --
        /// Adds a bone as a child of an existing bone, inheriting its parent's world transform.
        /// @param | name | string | Unique name for this bone.
        /// @param | parent_idx | integer | Zero-based index of the parent bone.
        /// @param | opts | table? | Optional table with keys: x, y, rotation, scale_x, scale_y (local offsets from parent).
        /// @return | integer | Zero-based index of the newly added child bone.
        methods.add_method_mut(
            "addChildBone",
            |_, this, (name, parent_idx, opts): (String, usize, Option<LuaTable>)| {
                if parent_idx >= this.inner.bone_count() {
                    return Err(LuaError::RuntimeError(format!(
                        "LSkeleton:addChildBone: parent_idx {} out of bounds for {} bones",
                        parent_idx,
                        this.inner.bone_count()
                    )));
                }
                let (x, y, rot, sx, sy) = parse_bone_opts(&opts)?;
                Ok(this.inner.add_bone_full(BoneParams {
                    name,
                    parent_index: Some(parent_idx),
                    x,
                    y,
                    rotation: rot,
                    scale_x: sx,
                    scale_y: sy,
                }))
            },
        );
        // -- addSlot --
        /// Adds a slot attached to a specific bone, optionally assigning a default attachment name.
        /// @param | name | string | Unique name for this slot.
        /// @param | bone_idx | integer | Zero-based index of the bone this slot is attached to.
        /// @param | attachment | string? | Optional default attachment name for this slot.
        /// @return | integer | Zero-based index of the newly added slot.
        methods.add_method_mut(
            "addSlot",
            |_, this, (name, bone_idx, attachment): (String, usize, Option<String>)| {
                if bone_idx >= this.inner.bone_count() {
                    return Err(LuaError::RuntimeError(format!(
                        "LSkeleton:addSlot: bone_idx {} out of bounds for {} bones",
                        bone_idx,
                        this.inner.bone_count()
                    )));
                }
                Ok(this.inner.add_slot_full(&name, bone_idx, attachment))
            },
        );
        // -- bindAtlas --
        /// Binds all atlas entries as sprite-region attachment sources by name.
        /// @param | atlas | LSpriteAtlas | Sprite atlas containing named attachment regions.
        /// @return | integer | Number of bound sources.
        methods.add_method_mut("bindAtlas", |_, this, atlas_ud: LuaAnyUserData| {
            let atlas = atlas_ud.borrow::<LuaSpriteAtlas>()?;
            let mut count = 0usize;
            for name in atlas.inner.entry_names() {
                if let Some(entry) = atlas.inner.get_entry(name) {
                    this.inner.set_attachment_source(
                        name,
                        AttachmentSource {
                            kind: AttachmentSourceKind::SpriteRegion,
                            name: Some(entry.name.clone()),
                            x: entry.x as f32,
                            y: entry.y as f32,
                            w: entry.w as f32,
                            h: entry.h as f32,
                            texture_w: (entry.x + entry.w) as f32,
                            texture_h: (entry.y + entry.h) as f32,
                            texture_id: None,
                        },
                    );
                    count += 1;
                }
            }
            Ok(count)
        });
        // -- setAttachmentSource --
        /// Assigns a neutral visual source to a slot name, attachment name, or `slot:attachment` key.
        /// @param | slot | string | Slot/source key.
        /// @param | source | table | `{kind, name?, x, y, w, h, textureId?, textureWidth?, textureHeight?}`.
        methods.add_method_mut(
            "setAttachmentSource",
            |_, this, (slot, source): (String, LuaTable)| {
                let source = attachment_source_from_table("LSkeleton:setAttachmentSource", source)?;
                this.inner.set_attachment_source(&slot, source);
                Ok(())
            },
        );
        // -- getAttachmentSource --
        /// Returns the neutral visual source assigned to a slot/source key.
        /// @param | slot | string | Slot/source key.
        /// @return | table|nil | Attachment source DTO or nil.
        methods.add_method("getAttachmentSource", |lua, this, slot: String| match this
            .inner
            .get_attachment_source_by_key(&slot)
        {
            Some(source) => Ok(LuaValue::Table(attachment_source_to_table(lua, source)?)),
            None => Ok(LuaValue::Nil),
        });
        // -- findBone --
        /// Searches for a bone by name and returns its zero-based index, or nil if not found.
        /// @param | name | string | Name of the bone to find.
        /// @return | integer | Zero-based bone index, or nil if no bone with that name exists.
        methods.add_method("findBone", |_, this, name: String| {
            Ok(this.inner.find_bone(&name))
        });
        // -- findSlot --
        /// Searches for a slot by name and returns its zero-based index, or nil if not found.
        /// @param | name | string | Name of the slot to find.
        /// @return | integer | Zero-based slot index, or nil if no slot with that name exists.
        methods.add_method("findSlot", |_, this, name: String| {
            Ok(this.inner.find_slot(&name))
        });
        // -- updateWorldTransforms --
        /// Recomputes world transforms for all bones in hierarchy order. Call after modifying bone locals or IK targets.
        methods.add_method_mut("updateWorldTransforms", |_, this, ()| {
            this.inner.update_world_transforms();
            Ok(())
        });
        // -- getBoneWorld --
        /// Returns the final world-space transform of a bone after hierarchy resolution.
        /// @param | idx | integer | Zero-based bone index.
        /// @return | table | Table with keys x, y, rotation, scale_x, scale_y â€” or nil if the index is invalid.
        /// @field | x | number | X position.
        /// @field | y | number | Y position.
        /// @field | rotation | number | Rotation in degrees.
        /// @field | scale_x | number | Horizontal scale.
        /// @field | scale_y | number | Vertical scale.
        methods.add_method("getBoneWorld", |lua, this, idx: usize| {
            match this.inner.bone_world_transform(idx) {
                None => Ok(LuaValue::Nil),
                Some((x, y, rotation, sx, sy)) => {
                    let t = lua.create_table()?;
                    /// The 'x' field value exposed to Lua scripts.
                    t.set("x", x)?;
                    /// The 'y' field value exposed to Lua scripts.
                    t.set("y", y)?;
                    /// Performs the 'rotation' operation.
                    t.set("rotation", rotation)?;
                    /// Performs the 'scale_x' operation.
                    t.set("scale_x", sx)?;
                    /// Performs the 'scale_y' operation.
                    t.set("scale_y", sy)?;
                    Ok(LuaValue::Table(t))
                }
            }
        });
        // -- setPosition --
        /// Sets the root bone world position, shifting the entire skeleton.
        /// @param | x | number | World X coordinate.
        /// @param | y | number | World Y coordinate.
        methods.add_method_mut("setPosition", |_, this, (x, y): (f32, f32)| {
            this.inner.set_root_position(x, y);
            Ok(())
        });
        // -- boneCount --
        /// Returns the total number of bones in the skeleton.
        /// @return | integer | Bone count.
        methods.add_method("boneCount", |_, this, ()| Ok(this.inner.bone_count()));
        // -- slotCount --
        /// Returns the total number of slots in the skeleton.
        /// @return | integer | Slot count.
        methods.add_method("slotCount", |_, this, ()| Ok(this.inner.slot_count()));
        // -- drawToImage --
        /// Renders the skeleton into an in-memory image of the given dimensions and returns it as LImageData userdata.
        /// @param | w | integer | Width of the output image in pixels.
        /// @param | h | integer | Height of the output image in pixels.
        /// @return | LImageData | A new image data object containing the rendered skeleton.
        methods.add_method("drawToImage", |lua, this, (w, h): (u32, u32)| {
            let img = this.inner.draw_to_image(w, h);
            lua.create_userdata(img)
        });
        // -- playAnimation --
        /// Starts playing a named animation on this skeleton. Optionally loops.
        /// @param | name | string | Name of the animation to play (must have been added via addAnimation).
        /// @param | looping | boolean? | Whether to loop the animation. Defaults to true.
        /// @return | boolean | True if the animation was found and started, false otherwise.
        methods.add_method_mut(
            "playAnimation",
            |_, this, (name, looping): (String, Option<bool>)| {
                Ok(this.inner.play_animation(&name, looping.unwrap_or(true)))
            },
        );
        // -- stopAnimation --
        /// Stops the currently playing animation and resets playback state.
        methods.add_method_mut("stopAnimation", |_, this, ()| {
            this.inner.stop_animation();
            Ok(())
        });
        // -- updateAnimation --
        /// Advances the current animation by a delta time, applying bone transforms to the skeleton.
        /// @param | dt | number | Time step in seconds (e.g. from lurek.timer.getDelta()).
        methods.add_method_mut("updateAnimation", |_, this, dt: f32| {
            let dt = non_negative_f32("LSkeleton:updateAnimation", "dt", dt)?;
            this.inner.update_animation(dt);
            Ok(())
        });
        // -- getAnimationTime --
        /// Returns the current playback time of the active animation in seconds.
        /// @return | number | Current animation time position.
        methods.add_method("getAnimationTime", |_, this, ()| {
            Ok(this.inner.get_animation_time())
        });
        // -- addAnimation --
        /// Registers a SkeletonAnimation object with this skeleton so it can be played by name.
        /// @param | anim | LSkeletonAnimation | The animation userdata to register. Consumed by this call.
        methods.add_method_mut("addAnimation", |_, this, anim_ud: LuaAnyUserData| {
            let anim = anim_ud.take::<LuaSkeletonAnimation>()?.inner;
            this.inner.add_animation(anim);
            Ok(())
        });
        // -- addIKConstraint --
        /// Adds an inverse-kinematics constraint that controls a chain of bones to reach a target position.
        /// @param | name | string | Unique name for this IK constraint (used with setIKTarget).
        /// @param | chain | table | Array of bone indices forming the IK chain from root to tip.
        /// @param | bend_positive | boolean? | Whether the joint bends in the positive direction. Defaults to true.
        /// @return | integer | Index of the newly added constraint.
        methods.add_method_mut(
            "addIKConstraint",
            |_, this, (name, chain_tbl, bend_positive): (String, LuaTable, Option<bool>)| {
                let mut chain: Vec<usize> = Vec::new();
                for v in chain_tbl.sequence_values::<usize>() {
                    chain.push(v?);
                }
                let constraint = IKConstraint::new(&name, chain, bend_positive.unwrap_or(true));
                Ok(this.inner.add_ik_constraint(constraint))
            },
        );
        // -- setIKTarget --
        /// Sets the world-space target position for a named IK constraint. Call updateWorldTransforms after.
        /// @param | name | string | Name of the IK constraint to update.
        /// @param | x | number | Target world X coordinate.
        /// @param | y | number | Target world Y coordinate.
        /// @return | boolean | True if the constraint was found and updated, false otherwise.
        methods.add_method_mut(
            "setIKTarget",
            |_, this, (name, x, y): (String, f32, f32)| Ok(this.inner.set_ik_target(&name, x, y)),
        );
        // -- addSkin --
        /// Registers a new named skin on this skeleton. Skins remap slot attachments for visual variants.
        /// @param | name | string | Unique name for the skin.
        methods.add_method_mut("addSkin", |_, this, name: String| {
            this.inner.add_skin(&name);
            Ok(())
        });
        // -- setSkin --
        /// Activates a named skin, applying its slot-attachment mappings to the skeleton.
        /// @param | name | string | Name of the skin to activate (must have been added via addSkin).
        /// @return | boolean | True if the skin was found and activated, false otherwise.
        methods.add_method_mut("setSkin", |_, this, name: String| {
            Ok(this.inner.set_skin(&name))
        });
        // -- getSkin --
        /// Returns the name of the currently active skin, or nil if no skin is set.
        /// @return | string | Active skin name or nil.
        methods.add_method("getSkin", |_, this, ()| {
            Ok(this.inner.get_skin().map(|s| s.to_owned()))
        });
        // -- setSkinMapping --
        /// Maps a slot to a specific attachment name within a skin. When that skin is active, the slot shows this attachment.
        /// @param | skin | string | Name of the skin to add the mapping to.
        /// @param | slot | string | Name of the slot to remap.
        /// @param | attachment | string | Attachment name to display in that slot when the skin is active.
        methods.add_method_mut(
            "setSkinMapping",
            |_, this, (skin, slot, attachment): (String, String, String)| {
                this.inner.set_skin_mapping(&skin, &slot, &attachment);
                Ok(())
            },
        );
        // -- blendAnimation --
        /// Blends an animation pose onto the skeleton at a given time with a weight factor for smooth transitions.
        /// @param | anim | LSkeletonAnimation | The animation to sample and blend from.
        /// @param | time | number | The time position to sample within the animation.
        /// @param | blend_weight | number? | Blend factor from 0.0 (no effect) to 1.0 (full). Defaults to 1.0.
        methods.add_method_mut(
            "blendAnimation",
            |_, this, (anim_ud, time, blend_weight): (mlua::AnyUserData, f32, Option<f32>)| {
                let anim_ref = anim_ud
                    .borrow::<LuaSkeletonAnimation>()
                    .map_err(mlua::Error::external)?;
                let w = blend_weight.unwrap_or(1.0);
                anim_ref
                    .inner
                    .apply_to_skeleton_blended(&mut this.inner, time, w);
                Ok(())
            },
        );
        // -- buildAnimation --
        /// Builds a full skeleton animation from bone tracks keyed by bone name or index.
        /// @param | name | string | Animation name.
        /// @param | duration | number | Duration in seconds.
        /// @param | tracks | table | Array of `{bone=<name|index>, keys={...}}` track tables.
        /// @return | LSkeletonAnimation | A new animation containing all requested bone timelines.
        methods.add_method(
            "buildAnimation",
            |lua, this, (name, duration, tracks): (String, f32, LuaTable)| {
                let duration = non_negative_f32("LSkeleton:buildAnimation", "duration", duration)?;
                let mut anim = SkeletonAnimation::new(name, duration);
                for track in tracks.sequence_values::<LuaTable>() {
                    let track = track?;
                    let bone_value = match track.get::<_, Option<LuaValue>>("bone")? {
                        Some(value) if !matches!(value, LuaValue::Nil) => value,
                        _ => track.get::<_, LuaValue>("bone_idx")?,
                    };
                    let bone_idx =
                        parse_bone_ref("LSkeleton:buildAnimation", &this.inner, bone_value)?;
                    let keys = track.get::<_, LuaTable>("keys")?;
                    add_bone_track_to_animation(
                        "LSkeleton:buildAnimation",
                        &mut anim,
                        bone_idx,
                        keys,
                    )?;
                }
                lua.create_userdata(LuaSkeletonAnimation { inner: anim })
            },
        );
        // -- bindPhysics --
        /// Creates physics bodies for skeleton parts and connects child parts to parent parts with joints.
        /// @param | world | LWorld | Physics world that will receive the generated bodies and joints.
        /// @param | parts | table | Array of part specs keyed by bone name/index plus shape, image, width/height, or radius.
        /// @param | opts | table? | Defaults such as `joint`, `bodyType`, alphaThreshold, and maxVertices.
        /// @return | table | Binding result with bodies, bodyIds, joints, jointIds, and parts arrays.
        methods.add_method_mut(
            "bindPhysics",
            |lua, this, (world_ud, parts, opts): (LuaAnyUserData, LuaTable, Option<LuaTable>)| {
                let world = world_ud.borrow::<LuaWorld>()?;
                let world_handle = world.world_handle();
                let alpha_defaults = match &opts {
                    Some(opts) => alpha_options_for_spine(opts, AlphaShapeOptions::default())?,
                    None => AlphaShapeOptions::default(),
                };
                let default_joint = opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<String>>("joint").ok().flatten())
                    .unwrap_or_else(|| "revolute".to_string());
                let default_body_type = opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<String>>("bodyType").ok().flatten());

                this.inner.update_world_transforms();
                let mut body_by_bone = vec![None; this.inner.bone_count()];
                let mut created: Vec<(usize, usize, f32, f32, String)> = Vec::new();
                let bodies_tbl = lua.create_table()?;
                let body_ids_tbl = lua.create_table()?;
                let parts_tbl = lua.create_table()?;

                let mut body_row = 1usize;
                for part in parts.sequence_values::<LuaTable>() {
                    let part = part?;
                    let bone_value = match part.get::<_, Option<LuaValue>>("bone")? {
                        Some(value) if !matches!(value, LuaValue::Nil) => value,
                        _ => part.get::<_, LuaValue>("bone_idx")?,
                    };
                    let bone_idx =
                        parse_bone_ref("LSkeleton:bindPhysics", &this.inner, bone_value)?;
                    let (wx, wy, rot, _, _) =
                        this.inner.bone_world_transform(bone_idx).ok_or_else(|| {
                            LuaError::RuntimeError(format!(
                                "LSkeleton:bindPhysics: bone index {} is not available",
                                bone_idx
                            ))
                        })?;
                    let x = wx + part.get::<_, Option<f32>>("offsetX")?.unwrap_or(0.0);
                    let y = wy + part.get::<_, Option<f32>>("offsetY")?.unwrap_or(0.0);
                    let (shape, density, friction, restitution, sensor) =
                        shape_from_spine_part(lua, &part, alpha_defaults)?;
                    let body_type = if sensor {
                        BodyType::Sensor
                    } else {
                        parse_body_type_for_spine(
                            "LSkeleton:bindPhysics",
                            part.get::<_, Option<String>>("bodyType")?
                                .or_else(|| default_body_type.clone()),
                        )?
                    };
                    let mut body =
                        body_from_spine_shape(x, y, shape.clone(), body_type).map_err(|err| {
                            LuaError::RuntimeError(format!("LSkeleton:bindPhysics: {err}"))
                        })?;
                    body.angle = rot;
                    set_spine_body_material(
                        &mut body,
                        &shape,
                        density,
                        friction,
                        restitution,
                        part.get::<_, Option<f32>>("mass")?,
                    );
                    let body_handle = lua_body_from_body(world_handle.clone(), body);
                    let body_id = body_handle.body_id();
                    body_by_bone[bone_idx] = Some(body_id);
                    bodies_tbl.set(body_row, lua.create_userdata(body_handle)?)?;
                    body_ids_tbl.set(body_row, body_id)?;

                    let part_info = lua.create_table()?;
                    part_info.set("bone", this.inner.bones[bone_idx].name.clone())?;
                    part_info.set("bone_idx", bone_idx)?;
                    part_info.set("bodyId", body_id)?;
                    if let Some(slot) = part.get::<_, Option<String>>("slot")? {
                        part_info.set("slot", slot)?;
                    }
                    if let Some(attachment) = part.get::<_, Option<String>>("attachment")? {
                        part_info.set("attachment", attachment)?;
                    }
                    parts_tbl.set(body_row, part_info)?;

                    let joint_type = part
                        .get::<_, Option<String>>("joint")?
                        .unwrap_or_else(|| default_joint.clone());
                    created.push((bone_idx, body_id, wx, wy, joint_type));
                    body_row += 1;
                }

                let joints_tbl = lua.create_table()?;
                let joint_ids_tbl = lua.create_table()?;
                let mut joint_row = 1usize;
                for (bone_idx, body_id, wx, wy, joint_type) in created {
                    if joint_type == "none" {
                        continue;
                    }
                    let Some(parent_idx) = this.inner.bones[bone_idx].parent_index else {
                        continue;
                    };
                    let Some(parent_body) = body_by_bone.get(parent_idx).copied().flatten() else {
                        continue;
                    };
                    let jid = {
                        let mut world = world_handle.borrow_mut();
                        match joint_type.as_str() {
                            "weld" | "rigid" => {
                                world.try_add_weld_joint(parent_body, body_id, wx, wy)
                            }
                            "distance" => {
                                let parent = &this.inner.bones[parent_idx];
                                let length =
                                    (wx - parent.world_x).hypot(wy - parent.world_y).max(0.001);
                                world.try_add_distance_joint(
                                    parent_body,
                                    body_id,
                                    0.0,
                                    0.0,
                                    0.0,
                                    0.0,
                                    length,
                                )
                            }
                            "rope" => {
                                let parent = &this.inner.bones[parent_idx];
                                let length =
                                    (wx - parent.world_x).hypot(wy - parent.world_y).max(0.001);
                                world.try_add_rope_joint(
                                    parent_body,
                                    body_id,
                                    0.0,
                                    0.0,
                                    0.0,
                                    0.0,
                                    length,
                                )
                            }
                            "motor" | "spring" => {
                                world.try_add_motor_joint(parent_body, body_id, 0.6)
                            }
                            "revolute" | "hinge" => {
                                world.try_add_revolute_joint(parent_body, body_id, wx, wy)
                            }
                            other => {
                                return Err(LuaError::RuntimeError(format!(
                                    "LSkeleton:bindPhysics: unknown joint '{}'",
                                    other
                                )))
                            }
                        }
                    }
                    .map_err(|err| {
                        LuaError::RuntimeError(format!("LSkeleton:bindPhysics: {err}"))
                    })?;
                    joints_tbl.set(joint_row, jid)?;
                    joint_ids_tbl.set(joint_row, jid)?;
                    joint_row += 1;
                }

                let result = lua.create_table()?;
                result.set("bodies", bodies_tbl)?;
                result.set("bodyIds", body_ids_tbl)?;
                result.set("joints", joints_tbl)?;
                result.set("jointIds", joint_ids_tbl)?;
                result.set("parts", parts_tbl)?;
                result.set("bodyCount", body_row - 1)?;
                result.set("jointCount", joint_row - 1)?;
                Ok(result)
            },
        );
        // -- type --
        /// Returns the type name of this userdata object.
        /// @return | string | Always "LSkeleton".
        methods.add_method("type", |_, _, ()| Ok("LSkeleton"));
        // -- typeOf --
        /// Checks whether this object is of the given type name. Supports "LSkeleton" and "Object".
        /// @param | name | string | Type name to check.
        /// @return | boolean | True if this object matches the given type.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LSkeleton" || name == "LObject")
        });
    }
}
/// Lua-facing animation object containing bone timelines, keyframes, events, and easing curves.
pub struct LuaSkeletonAnimation {
    inner: SkeletonAnimation,
}
impl LuaUserData for LuaSkeletonAnimation {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- addKeyframe --
        /// Adds a keyframe to a bone's property timeline at a specific time with a value and easing curve.
        /// @param | bone_idx | integer | Zero-based index of the target bone.
        /// @param | property | string | Bone property: "x", "y", "rotation", "scale_x", or "scale_y".
        /// @param | time | number | Time position in seconds for this keyframe.
        /// @param | value | number | Value of the property at this keyframe.
        /// @param | easing | string? | Easing type: "linear" (default), "ease_in", "ease_out", "ease_in_out", or "step".
        methods.add_method_mut(
            "addKeyframe",
            |_,
             this,
             (bone_idx, prop_str, time, value, easing_str): (
                usize,
                String,
                f32,
                f32,
                Option<String>,
            )| {
                let time = non_negative_f32("LSkeletonAnimation:addKeyframe", "time", time)?;
                let value = finite_f32("LSkeletonAnimation:addKeyframe", "value", value)?;
                let property = match prop_str.as_str() {
                    "x" => BoneProperty::X,
                    "y" => BoneProperty::Y,
                    "rotation" => BoneProperty::Rotation,
                    "scale_x" => BoneProperty::ScaleX,
                    "scale_y" => BoneProperty::ScaleY,
                    other => {
                        return Err(LuaError::RuntimeError(format!(
                            "addKeyframe: unknown property '{}'",
                            other
                        )))
                    }
                };
                let easing = match easing_str.as_deref().unwrap_or("linear") {
                    "linear" => EasingType::Linear,
                    "ease_in" => EasingType::EaseIn,
                    "ease_out" => EasingType::EaseOut,
                    "ease_in_out" => EasingType::EaseInOut,
                    "step" => EasingType::Step,
                    other => {
                        return Err(LuaError::RuntimeError(format!(
                            "addKeyframe: unknown easing '{}'",
                            other
                        )))
                    }
                };
                this.inner
                    .add_keyframe(bone_idx, property, time, value, easing);
                Ok(())
            },
        );
        // -- addBoneTrack --
        /// Adds many keyframes for one bone from an array of key tables.
        /// @param | bone_idx | integer | Zero-based index of the target bone.
        /// @param | keys | table | Array of key tables with `time` and any of x, y, rotation, scale_x, scale_y.
        methods.add_method_mut(
            "addBoneTrack",
            |_, this, (bone_idx, keys): (usize, LuaTable)| {
                add_bone_track_to_animation(
                    "LSkeletonAnimation:addBoneTrack",
                    &mut this.inner,
                    bone_idx,
                    keys,
                )
            },
        );
        // -- getDuration --
        /// Returns the total duration of this animation in seconds.
        /// @return | number | Duration in seconds.
        methods.add_method("getDuration", |_, this, ()| Ok(this.inner.duration));
        // -- addEventKey --
        /// Inserts an event trigger at a specific time within the animation timeline.
        /// @param | time | number | Time position in seconds when the event fires.
        /// @param | name | string | Name of the event (used to identify it when querying).
        /// @param | value | number? | Optional numeric payload for the event. Defaults to 0.
        methods.add_method_mut(
            "addEventKey",
            |_, this, (time, name, value): (f32, String, Option<f32>)| {
                let time = non_negative_f32("LSkeletonAnimation:addEventKey", "time", time)?;
                let value = finite_f32(
                    "LSkeletonAnimation:addEventKey",
                    "value",
                    value.unwrap_or(0.0),
                )?;
                this.inner.add_event_key(time, name, value);
                Ok(())
            },
        );
        // -- getEvents --
        /// Collects all events that fire within a time range. Useful for triggering sound effects or gameplay actions.
        /// @param | from | number | Start time in seconds (inclusive).
        /// @param | to | number | End time in seconds (exclusive).
        /// @return | table | Array of tables, each with "name" (string) and "value" (number) fields.
        /// @field | name | string | Event name.
        /// @field | value | number | Event value.
        methods.add_method("getEvents", |lua, this, (from, to): (f32, f32)| {
            let pairs = this.inner.collect_events(from, to);
            let tbl = lua.create_table()?;
            for (i, (name, value)) in pairs.into_iter().enumerate() {
                let entry = lua.create_table()?;
                /// Performs the 'name' operation.
                entry.set("name", name)?;
                /// Performs the 'value' operation.
                entry.set("value", value)?;
                tbl.set(i + 1, entry)?;
            }
            Ok(tbl)
        });
        // -- getTimelineCount --
        /// Returns the number of bone-property timelines in this animation.
        /// @return | integer | Timeline count.
        methods.add_method("getTimelineCount", |_, this, ()| {
            Ok(this.inner.timelines.len())
        });
        // -- poseAt --
        /// Samples all timelines at a given time and returns the computed pose as an array of bone-property-value entries.
        /// @param | time | number | Time position in seconds to sample.
        /// @return | table | Array of tables, each with "bone_idx" (integer), "property" (string), and "value" (number).
        /// @field | bone_idx | integer | Bone index.
        /// @field | property | string | Property name.
        /// @field | value | number | Property value.
        methods.add_method("poseAt", |lua, this, time: f32| {
            let snapshot = this.inner.pose_at(time);
            let arr = lua.create_table()?;
            for (i, (bone_idx, prop, value)) in snapshot.iter().enumerate() {
                let entry = lua.create_table()?;
                /// Performs the 'bone_idx' operation.
                entry.set("bone_idx", *bone_idx)?;
                let prop_name = match prop {
                    BoneProperty::X => "x",
                    BoneProperty::Y => "y",
                    BoneProperty::Rotation => "rotation",
                    BoneProperty::ScaleX => "scale_x",
                    BoneProperty::ScaleY => "scale_y",
                };
                /// Performs the 'property' operation.
                entry.set("property", prop_name)?;
                /// Performs the 'value' operation.
                entry.set("value", *value)?;
                arr.set(i + 1, entry)?;
            }
            Ok(arr)
        });
        // -- reverse --
        /// Creates a new animation that plays this animation's keyframes in reverse order.
        /// @return | LSkeletonAnimation | A new reversed copy of this animation.
        methods.add_method("reverse", |lua, this, ()| {
            lua.create_userdata(LuaSkeletonAnimation {
                inner: this.inner.reverse(),
            })
        });
        // -- type --
        /// Returns the type name of this userdata object.
        /// @return | string | Always "LSkeletonAnimation".
        methods.add_method("type", |_, _, ()| Ok("LSkeletonAnimation"));
        // -- typeOf --
        /// Checks whether this object is of the given type name. Supports "LSkeletonAnimation" and "Object".
        /// @param | name | string | Type name to check.
        /// @return | boolean | True if this object matches the given type.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LSkeletonAnimation" || name == "LObject")
        });
    }
}
/// Registers the `lurek.spine` module on the given Lua table.
pub fn register(lua: &Lua, luna: &LuaTable, _state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;
    // -- newSkeleton --
    /// Creates a new empty skeleton with the given name. Add bones and slots to build the hierarchy.
    /// @param | name | string | Name identifier for this skeleton.
    /// @return | LSkeleton | A new skeleton userdata.
    tbl.set(
        "newSkeleton",
        lua.create_function(|lua, name: String| {
            lua.create_userdata(LuaSkeleton {
                inner: Skeleton::new(&name),
            })
        })?,
    )?;
    // -- newSkeletonAnimation --
    /// Creates a new empty animation with the given name and duration. Add keyframes to define motion.
    /// @param | name | string | Name identifier for this animation (used with playAnimation).
    /// @param | duration | number | Total duration of the animation in seconds.
    /// @return | LSkeletonAnimation | A new animation userdata.
    tbl.set(
        "newSkeletonAnimation",
        lua.create_function(|lua, (name, duration): (String, f32)| {
            let duration =
                non_negative_f32("lurek.spine.newSkeletonAnimation", "duration", duration)?;
            lua.create_userdata(LuaSkeletonAnimation {
                inner: SkeletonAnimation {
                    name,
                    duration,
                    timelines: Vec::new(),
                    events: Vec::new(),
                },
            })
        })?,
    )?;
    // -- animationFromJson --
    /// Parses a JSON string into a SkeletonAnimation. Returns nil if parsing fails or the format is invalid.
    /// @param | json | string | JSON string describing the animation (Spine-compatible format).
    /// @return | LSkeletonAnimation | Parsed animation userdata, or nil on failure.
    tbl.set(
        "animationFromJson",
        lua.create_function(|lua, json: String| {
            let parsed: serde_json::Value = serde_json::from_str(&json)
                .map_err(|e| LuaError::RuntimeError(format!("animationFromJson: {e}")))?;
            match SkeletonAnimation::from_json(&parsed) {
                Some(anim) => Ok(LuaValue::UserData(
                    lua.create_userdata(LuaSkeletonAnimation { inner: anim })?,
                )),
                None => Ok(LuaValue::Nil),
            }
        })?,
    )?;
    // -- skeletonFromJson --
    /// Parses a Spine or DragonBones JSON string into a full runtime skeleton.
    /// @param | json | string | JSON string in standard Spine (bones/slots/animations) or DragonBones (armature) shape.
    /// @return | LSkeleton | Parsed skeleton userdata.
    tbl.set(
        "skeletonFromJson",
        lua.create_function(|lua, json: String| {
            let skeleton = skeleton_from_json_str(&json)
                .map_err(|e| LuaError::RuntimeError(format!("skeletonFromJson: {e}")))?;
            lua.create_userdata(LuaSkeleton { inner: skeleton })
        })?,
    )?;
    /// Performs the 'spine' operation.
    luna.set("spine", tbl)?;
    Ok(())
}
