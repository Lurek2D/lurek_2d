//! INTERNAL ONLY: Rust-only tests for binary internals that are not exposed as `lurek.data.*`.

// ── ring_buffer ───────────────────────────────────────────────────────────────

mod ring_buffer_tests {
    use lurek2d::binary::RingBuffer;

    #[test]
    fn zero_capacity_clamped_to_one() {
        let rb = RingBuffer::<i32>::new(0);
        assert_eq!(rb.capacity(), 1);
    }

    #[test]
    fn push_returns_true_when_space_available() {
        let mut rb = RingBuffer::new(2);
        assert!(rb.push(1));
        assert!(rb.push(2));
        assert!(!rb.push(3)); // full, overwrites
    }

    #[test]
    fn iter_and_to_refs_keep_oldest_first_order_after_wrap() {
        let mut rb = RingBuffer::new(3);
        rb.push("a".to_string());
        rb.push("b".to_string());
        rb.push("c".to_string());
        rb.push("d".to_string()); // overwrite "a"

        let from_iter: Vec<&str> = rb.iter().map(|s| s.as_str()).collect();
        let from_refs: Vec<&str> = rb.to_refs().into_iter().map(|s| s.as_str()).collect();

        assert_eq!(from_iter, vec!["b", "c", "d"]);
        assert_eq!(from_refs, vec!["b", "c", "d"]);
    }

    #[test]
    fn collect_copy_matches_to_vec_for_copy_types() {
        let mut rb = RingBuffer::new(4);
        rb.push(10_u32);
        rb.push(20_u32);
        rb.push(30_u32);

        assert_eq!(rb.to_vec(), rb.collect_copy());
    }
}

// ── compress ──────────────────────────────────────────────────────────────────

mod compress_tests {
    use std::io::Cursor;

    use lurek2d::binary::{
        compress_chunks, compress_stream, decompress_chunks, decompress_stream, CompressFormat,
    };

    fn sample_payload() -> Vec<u8> {
        let mut data = Vec::new();
        for i in 0..4096_u32 {
            data.extend_from_slice(format!("row:{:04};", i).as_bytes());
        }
        data
    }

    #[test]
    fn stream_round_trip_for_all_formats() {
        let payload = sample_payload();
        let formats = [
            CompressFormat::Deflate,
            CompressFormat::Gzip,
            CompressFormat::Lz4,
            CompressFormat::Zlib,
        ];

        for format in formats {
            let mut compressed = Vec::new();
            compress_stream(Cursor::new(&payload), &mut compressed, format, 6)
                .expect("compress_stream should succeed");

            let mut restored = Vec::new();
            decompress_stream(Cursor::new(&compressed), &mut restored, format)
                .expect("decompress_stream should succeed");

            assert_eq!(restored, payload, "format {:?}", format);
        }
    }

    #[test]
    fn chunk_helpers_round_trip_for_all_formats() {
        let payload = sample_payload();
        let chunks: Vec<&[u8]> = payload.chunks(97).collect();
        let formats = [
            CompressFormat::Deflate,
            CompressFormat::Gzip,
            CompressFormat::Lz4,
            CompressFormat::Zlib,
        ];

        for format in formats {
            let compressed =
                compress_chunks(&chunks, format, 7).expect("compress_chunks should succeed");
            let compressed_chunks: Vec<&[u8]> = compressed.chunks(53).collect();
            let restored = decompress_chunks(&compressed_chunks, format)
                .expect("decompress_chunks should succeed");

            assert_eq!(restored, payload, "format {:?}", format);
        }
    }

    #[test]
    fn stream_level_is_clamped_for_flate_formats() {
        let payload = sample_payload();

        for format in [
            CompressFormat::Deflate,
            CompressFormat::Gzip,
            CompressFormat::Zlib,
        ] {
            let mut compressed = Vec::new();
            compress_stream(Cursor::new(&payload), &mut compressed, format, 99)
                .expect("compress_stream should clamp level and succeed");

            let mut restored = Vec::new();
            decompress_stream(Cursor::new(&compressed), &mut restored, format)
                .expect("decompress_stream should succeed");

            assert_eq!(restored, payload, "format {:?}", format);
        }
    }
}

// ── pack ──────────────────────────────────────────────────────────────────────

mod pack_tests {
    use lurek2d::binary::pack::{get_packed_size, PackValue};

    #[test]
    fn get_packed_size_accepts_mixed_format_int_and_string() {
        let values = vec![
            PackValue::Int(42),
            PackValue::Str("hello".to_string()),
        ];
        let size = get_packed_size("<is", &values).expect("get_packed_size should succeed");
        // '<' = little-endian prefix (0 bytes)
        // 'i' = 4 bytes (int32)
        // 's' = 4 bytes (length prefix) + 5 bytes (string content)
        assert_eq!(size, 4 + 4 + 5);
    }

    #[test]
    fn get_packed_size_uses_single_value_index_for_each_token() {
        let values = vec![
            PackValue::Int(100),
            PackValue::Double(3.14),
            PackValue::Str("test".to_string()),
        ];
        let size = get_packed_size(">ids", &values).expect("get_packed_size should succeed");
        // '>' = big-endian prefix (0 bytes)
        // 'i' = 4 bytes (int32) at values[0]
        // 'd' = 8 bytes (double) at values[1]
        // 's' = 4 bytes (length) + 4 bytes (content) at values[2]
        assert_eq!(size, 4 + 8 + 4 + 4);
    }
}

// ── data_writer ───────────────────────────────────────────────────────────────

mod data_writer_tests {
    use lurek2d::binary::DataWriter;

    #[test]
    fn append_only_writes_extend_buffer_sequentially() {
        let mut w = DataWriter::new();
        w.write_u32_le(0x12345678);
        w.write_u8(0xAB);
        w.write_bytes(&[0xCD, 0xEF]);
        let buf = w.into_bytes();
        assert_eq!(buf, vec![0x78, 0x56, 0x34, 0x12, 0xAB, 0xCD, 0xEF]);
    }

    #[test]
    fn seek_overwrite_preserves_existing_content() {
        let mut w = DataWriter::new();
        w.write_u32_le(0xAAAAAAAA);
        w.write_u32_le(0xBBBBBBBB);
        w.seek(0);
        w.write_u16_le(0xCCCC);
        let buf = w.into_bytes();
        assert_eq!(buf, vec![0xCC, 0xCC, 0xAA, 0xAA, 0xBB, 0xBB, 0xBB, 0xBB]);
    }

    #[test]
    fn seek_beyond_end_fills_gap_with_zeros() {
        let mut w = DataWriter::new();
        w.write_u8(0xFF);
        w.seek(5);
        w.write_u8(0xAA);
        let buf = w.into_bytes();
        assert_eq!(buf, vec![0xFF, 0x00, 0x00, 0x00, 0x00, 0xAA]);
    }

    #[test]
    fn write_bytes_public_api_matches_internal_behavior() {
        let mut w = DataWriter::new();
        w.write_bytes(&[1, 2, 3]);
        w.write_bytes(&[4, 5]);
        let buf = w.into_bytes();
        assert_eq!(buf, vec![1, 2, 3, 4, 5]);
    }
}
