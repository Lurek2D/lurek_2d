//! This file owns the slotmap key types used to reference runtime-managed resources without exposing pool internals.
//! It defines cheap copyable handles for textures, fonts, canvases, meshes, shaders, buses, and related objects.
//! Open it when runtime resource identity changes; actual pools and eviction policy live in shared state.

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
