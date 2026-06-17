//! This file defines the typed handle keys used to reference runtime-managed resources without exposing storage internals. `runtime/resource_keys` delivers the resource keys implementation for the runtime subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! The handles are cheap to copy and safe to hold across frames, which is essential for Lua userdata and engine-facing APIs.
//! It is the type-safety layer that lets many resource pools share one slotmap-style ownership pattern. Public callable behavior is centered on no named public items, while method-level behavior such as no named public items stays attached to the local data model and invariants.

use slotmap::new_key_type;
new_key_type! {
    /// Key for texture storage entries.
    pub struct TextureKey;
    /// Key for font storage entries.
    pub struct FontKey;
    /// Key for render-canvas storage entries.
    pub struct CanvasKey;
    /// Key for sound storage entries.
    pub struct SoundKey;
    /// Key for particle system storage entries.
    pub struct ParticleKey;
    /// Key for sprite-batch storage entries.
    pub struct SpriteBatchKey;
    /// Key for shader storage entries.
    pub struct ShaderKey;
    /// Key for mesh storage entries.
    pub struct MeshKey;
    /// Key for compound-shape storage entries.
    pub struct ShapeKey;
    /// Key for audio bus storage entries.
    pub struct BusKey;
    /// Key for MIDI player storage entries.
    pub struct MidiPlayerKey;
    /// Key for queued-audio playback entries.
    pub struct QueueableKey;
    /// Key for light storage entries.
    pub struct LightKey;
    /// Key for occluder storage entries.
    pub struct OccluderKey;
    /// Key for static geometry cache entries.
    pub struct StaticGeometryKey;
    /// Key for GPU instance buffer entries.
    pub struct InstanceBufferKey;
}
