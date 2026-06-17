//! Defines the animation module boundary that unifies playback, blending, transitions, and render bridging. `animation/mod` is the animation module index, declaring `aseprite`, `blend`, `clip`, `controller`, `curve`, and 6 more so agents can identify which files own each feature slice before opening implementation code.
//! Groups import, curve, event, sync, and state-control subsystems into one coherent runtime surface. `src/animation/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `aseprite::{ load_aseprite_json, AsepriteDirection, AsepriteFrameData, AsepriteParsed, AsepriteTagData, }`, `blend::{BlendLayer, BlendLayerSet, BlendMask}`, `clip::{AnimClip, ClipPlaybackMode}`, `controller::Animation`, and 7 more centralized for the animation subsystem.
//! Keeps frame-based and bridge-based animation features accessible through a consistent composition root. The file documents how animation submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.
//! Serves as the high-level integration entry for character animation behavior in engine runtime. Agents should read this index to choose the narrow owner file first, because it maps names such as `aseprite`, `blend`, `clip`, `controller`, `curve`, and 6 more to concrete implementation responsibilities.
//! `animation/mod` is the animation module index, declaring `aseprite`, `blend`, `clip`, `controller`, `curve`, and 6 more so agents can identify which files own each feature slice before opening implementation code.
//! `src/animation/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `aseprite::{ load_aseprite_json, AsepriteDirection, AsepriteFrameData, AsepriteParsed, AsepriteTagData, }`, `blend::{BlendLayer, BlendLayerSet, BlendMask}`, `clip::{AnimClip, ClipPlaybackMode}`, `controller::Animation`, and 7 more centralized for the animation subsystem.

/// Aseprite JSON parsing and tag extraction.
pub mod aseprite;
/// Blend layers and masks for layered animation output.
pub mod blend;
/// Clip definitions and playback mode metadata.
pub mod clip;
/// Runtime animation playback controller.
pub mod controller;
/// Curve and property timeline support.
pub mod curve;
/// Playback events emitted during clip advancement.
pub mod event;
/// Frame geometry and per-frame timing.
pub mod frame;
/// Conversion from frames to render commands.
pub mod render;
/// Optional Spine integration bridge.
#[cfg(feature = "spine")]
pub mod spine_bridge;
/// Animation state machine and transition rules.
pub mod state_machine;
/// Synchronization groups for coordinating multiple animations.
pub mod sync_group;

/// Aseprite import helpers and parsed data structures.
pub use aseprite::{
    load_aseprite_json, AsepriteDirection, AsepriteFrameData, AsepriteParsed, AsepriteTagData,
};
/// Blend-layer data used by composite animation playback.
pub use blend::{BlendLayer, BlendLayerSet, BlendMask};
/// Clip playback primitives.
pub use clip::{AnimClip, ClipPlaybackMode};
/// Primary animation playback controller.
pub use controller::Animation;
/// Property timeline curve container.
pub use curve::AnimPropertyTimeline;
/// Events produced by the animation controller.
pub use event::AnimEvent;
/// Frame rectangle and duration types.
pub use frame::{AnimFrame, AnimationFrame};
/// Rendering parameters for animation draw commands.
pub use render::AnimRenderParams;
/// Spine integration entry point.
#[cfg(feature = "spine")]
pub use spine_bridge::SpineAnimBridge;
/// State machine configuration, conditions, and transitions.
pub use state_machine::{
    AnimParamValue, AnimStateConfig, AnimStateMachine, AnimTransition, ConditionOp, ConditionValue,
    TransitionCondition,
};
/// Group synchronizer for multiple playback controllers.
pub use sync_group::AnimSyncGroup;
