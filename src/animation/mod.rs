//! This module is the animation index, re-exporting clips, frames, playback, curves, state control, and render glue.
//! It is the navigation point for authored imports, runtime playback, event flow, blending, and synchronization.
//! `controller.rs` owns the live playback controller, while `clip.rs` and `frame.rs` hold core timeline data.
//! `curve.rs` and `state_machine.rs` cover property interpolation and condition-driven state transitions.
//! `blend.rs` owns layer and mask data, while `render.rs` converts current quads into renderer draw commands.
//! `aseprite.rs` imports authored sheets, `event.rs` defines playback signals, and `sync_group.rs` coordinates peers.
//! `spine_bridge.rs` connects FSM state to Spine playback when that feature is enabled for the runtime build.
//! Change this file when public animation exports move; change siblings when playback or import rules change.

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
