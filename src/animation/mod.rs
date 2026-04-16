//! Sprite animation system: named clips, frame pools, speed control, and frame-level events.
//!
//! This is a Tier 1 engine module. It imports only from `crate::math`.
//!
//! An [`Animation`] stores a pool of [`AnimFrame`] entries (each defining a source
//! rectangle and optional per-frame duration) and any number of named [`AnimClip`]s
//! that reference those frames by index. Call [`Animation::update`] each tick and
//! inspect [`Animation::drain_events`] for playback notifications.

/// Named clip: frame index list, FPS, and looping flag.
pub mod clip;
/// [`Animation`] controller: frame pool, clip management, and update logic.
pub mod controller;
/// Playback events emitted by [`Animation::update`].
pub mod event;
/// Single animation frame: source quad and optional per-frame duration.
pub mod frame;
/// Render-command generation for sprite animations.
pub mod render;
/// Aseprite JSON export parser.
pub mod aseprite;
/// Finite-state machine for parameter-driven animation control.
pub mod state_machine;
/// Keyframe-based animation curves with per-segment easing.
pub mod curve;
/// Named animation synchronisation groups.
pub mod sync_group;
/// Blend-layer system for compositing multiple animation clips.
pub mod blend;

pub use clip::AnimClip;
pub use blend::{BlendLayer, BlendLayerSet, BlendMask};
pub use controller::Animation;
pub use event::AnimEvent;
pub use frame::{AnimFrame, AnimationFrame};
pub use render::AnimRenderParams;
pub use aseprite::{load_aseprite_json, AsepriteParsed, AsepriteFrameData, AsepriteTagData, AsepriteDirection};
pub use state_machine::{AnimStateMachine, AnimStateConfig, AnimTransition, AnimParamValue, TransitionCondition, ConditionOp, ConditionValue};
