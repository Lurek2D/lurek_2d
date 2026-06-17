//! Defines the binary utility module boundary for byte serialization, transformation, and integrity workflows. `binary/mod` is the binary module index, declaring `bin_pack`, `byte_data`, `compress`, `data_writer`, `dataview`, and 4 more so agents can identify which files own each feature slice before opening implementation code.
//! Groups packing, encoding, compression, hashing, and buffer primitives under one coherent toolbox. `src/binary/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `bin_pack::{read as bin_read, write as bin_write, BinValue}`, `byte_data::ByteData`, `compress::{ compress, compress_chunks, compress_stream, decompress, decompress_chunks, decompress_stream, CompressFormat, }`, `data_writer::DataWriter`, and 5 more centralized for the binary subsystem.
//! Serves as the composition root for engine-side binary data manipulation operations. The file documents how binary submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.
//! `binary/mod` is the binary module index, declaring `bin_pack`, `byte_data`, `compress`, `data_writer`, `dataview`, and 4 more so agents can identify which files own each feature slice before opening implementation code.
//! `src/binary/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `bin_pack::{read as bin_read, write as bin_write, BinValue}`, `byte_data::ByteData`, `compress::{ compress, compress_chunks, compress_stream, decompress, decompress_chunks, decompress_stream, CompressFormat, }`, `data_writer::DataWriter`, and 5 more centralized for the binary subsystem.
//! The file documents how binary submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.

/// Token-based binary reader and writer for structured byte payloads.
pub mod bin_pack;
/// Mutable owned byte buffer with indexed access and conversion helpers.
pub mod byte_data;
/// Compression and decompression helpers for deflate, gzip, zlib, and lz4.
pub mod compress;
/// Sequential binary writer with a movable cursor over an owned buffer.
pub mod data_writer;
/// Read-only typed accessor over a shared Arc byte buffer.
pub mod dataview;
/// Base64 and hex encode/decode helpers for opaque byte payloads.
pub mod encode;
/// Hash and checksum helpers returning hex-encoded digests.
pub mod hash;
/// Format-string pack and unpack helpers modelled on Python struct.
pub mod pack;
/// Fixed-capacity ring buffer with overwrite-on-full FIFO semantics.
pub mod ring_buffer;
pub(crate) use bin_pack::measure_size as bin_measure_size;
pub use bin_pack::{read as bin_read, write as bin_write, BinValue};
pub use byte_data::ByteData;
pub use compress::{
    compress, compress_chunks, compress_stream, decompress, decompress_chunks, decompress_stream,
    CompressFormat,
};
pub use data_writer::DataWriter;
pub use dataview::{DataView, LuaDataView};
pub use encode::{decode, encode, EncodeFormat};
pub use hash::{crc32, hash, HashAlgorithm};
pub use pack::{get_packed_size, pack, unpack, PackValue};
pub use ring_buffer::RingBuffer;
