//! Tests for the data module.

// ── toml_convert ──────────────────────────────────────────────────────────────

mod toml_convert_tests {
    use lurek2d::data::toml_convert::{encode_toml, parse_toml};

    #[test]
    fn parse_simple_table() {
        let input = r#"
[section]
key = "value"
number = 42
"#;
        let val = parse_toml(input).unwrap();
        let table = val.as_table().unwrap();
        let section = table["section"].as_table().unwrap();
        assert_eq!(section["key"].as_str().unwrap(), "value");
        assert_eq!(section["number"].as_integer().unwrap(), 42);
    }

    #[test]
    fn parse_empty_document() {
        let val = parse_toml("").unwrap();
        assert!(val.as_table().unwrap().is_empty());
    }

    #[test]
    fn parse_invalid_toml_returns_error() {
        let result = parse_toml("[broken");
        assert!(result.is_err());
    }

    #[test]
    fn parse_nested_tables() {
        let input = r#"
[a.b]
c = true
"#;
        let val = parse_toml(input).unwrap();
        let inner = &val["a"]["b"]["c"];
        assert_eq!(inner.as_bool().unwrap(), true);
    }

    #[test]
    fn parse_array_of_tables() {
        let input = r#"
[[items]]
name = "one"

[[items]]
name = "two"
"#;
        let val = parse_toml(input).unwrap();
        let items = val["items"].as_array().unwrap();
        assert_eq!(items.len(), 2);
        assert_eq!(items[0]["name"].as_str().unwrap(), "one");
        assert_eq!(items[1]["name"].as_str().unwrap(), "two");
    }

    #[test]
    fn encode_roundtrip() {
        let input = "key = \"value\"\nnumber = 42\n";
        let val = parse_toml(input).unwrap();
        let output = encode_toml(&val).unwrap();
        let reparsed = parse_toml(&output).unwrap();
        assert_eq!(val, reparsed);
    }

    #[test]
    fn encode_non_table_returns_error() {
        let val = toml::Value::String("not a table".into());
        let result = encode_toml(&val);
        assert!(result.is_err());
    }

    #[test]
    fn encode_empty_table() {
        let val = toml::Value::Table(toml::map::Map::new());
        let output = encode_toml(&val).unwrap();
        assert!(output.is_empty() || output.trim().is_empty());
    }
}

// ── ring_buffer ───────────────────────────────────────────────────────────────

mod ring_buffer_tests {
    use lurek2d::data::RingBuffer;

    #[test]
    fn new_buffer_is_empty() {
        let rb = RingBuffer::<i32>::new(4);
        assert!(rb.is_empty());
        assert_eq!(rb.len(), 0);
        assert_eq!(rb.capacity(), 4);
    }

    #[test]
    fn zero_capacity_clamped_to_one() {
        let rb = RingBuffer::<i32>::new(0);
        assert_eq!(rb.capacity(), 1);
    }

    #[test]
    fn push_pop_fifo() {
        let mut rb = RingBuffer::new(4);
        rb.push(1);
        rb.push(2);
        rb.push(3);
        assert_eq!(rb.pop(), Some(1));
        assert_eq!(rb.pop(), Some(2));
        assert_eq!(rb.pop(), Some(3));
        assert_eq!(rb.pop(), None);
    }

    #[test]
    fn push_returns_true_when_space_available() {
        let mut rb = RingBuffer::new(2);
        assert!(rb.push(1));
        assert!(rb.push(2));
        assert!(!rb.push(3)); // full, overwrites
    }

    #[test]
    fn overwrite_evicts_oldest() {
        let mut rb = RingBuffer::new(3);
        rb.push(1);
        rb.push(2);
        rb.push(3);
        rb.push(4); // overwrites 1
        assert_eq!(rb.to_vec(), vec![2, 3, 4]);
    }

    #[test]
    fn peek_returns_oldest() {
        let mut rb = RingBuffer::new(3);
        rb.push(10);
        rb.push(20);
        assert_eq!(rb.peek(), Some(&10));
        assert_eq!(rb.len(), 2); // not consumed
    }

    #[test]
    fn peek_newest_returns_last_pushed() {
        let mut rb = RingBuffer::new(3);
        rb.push(10);
        rb.push(20);
        rb.push(30);
        assert_eq!(rb.peek_newest(), Some(&30));
    }

    #[test]
    fn get_index_access() {
        let mut rb = RingBuffer::new(4);
        rb.push(100);
        rb.push(200);
        rb.push(300);
        assert_eq!(rb.get(0), Some(&100));
        assert_eq!(rb.get(2), Some(&300));
        assert_eq!(rb.get(3), None); // out of bounds
    }

    #[test]
    fn is_full() {
        let mut rb = RingBuffer::new(2);
        assert!(!rb.is_full());
        rb.push(1);
        rb.push(2);
        assert!(rb.is_full());
    }

    #[test]
    fn clear_resets() {
        let mut rb = RingBuffer::new(3);
        rb.push(1);
        rb.push(2);
        rb.clear();
        assert!(rb.is_empty());
        assert_eq!(rb.len(), 0);
    }

    #[test]
    fn to_vec_ordered() {
        let mut rb = RingBuffer::new(3);
        rb.push(10);
        rb.push(20);
        rb.push(30);
        rb.push(40); // overwrites 10
        assert_eq!(rb.to_vec(), vec![20, 30, 40]);
    }

    #[test]
    fn pop_on_empty_is_none() {
        let mut rb = RingBuffer::<String>::new(4);
        assert!(rb.pop().is_none());
    }

    #[test]
    fn peek_on_empty_is_none() {
        let rb = RingBuffer::<u8>::new(2);
        assert!(rb.peek().is_none());
        assert!(rb.peek_newest().is_none());
    }
}

// ── pack ──────────────────────────────────────────────────────────────────────

mod pack_tests {
    use lurek2d::data::{get_packed_size, pack, unpack, PackValue};

    #[test]
    fn pack_u8_little_endian_single_byte() {
        let values = vec![PackValue::UInt(42)];
        let buf = pack("<B", &values).unwrap();
        assert_eq!(buf.len(), 1);
        assert_eq!(buf.as_bytes()[0], 42u8);
    }

    #[test]
    fn pack_i16_big_endian() {
        let values = vec![PackValue::Int(256)];
        let buf = pack(">h", &values).unwrap();
        assert_eq!(buf.len(), 2);
        // 256 in big-endian i16 = [0x01, 0x00]
        assert_eq!(&buf.as_bytes()[..2], &[0x01, 0x00]);
    }

    #[test]
    fn pack_unpack_roundtrip_mixed_types() {
        let values = vec![
            PackValue::UInt(255),
            PackValue::Int(-1),
            PackValue::Float(3.14),
            PackValue::Double(2.718),
        ];
        let buf = pack("<Bhfd", &values).unwrap();
        let (unpacked, _pos) = unpack("<Bhfd", buf.as_bytes(), 0).unwrap();
        assert_eq!(unpacked.len(), 4);
        // u8
        if let PackValue::UInt(v) = &unpacked[0] {
            assert_eq!(*v, 255);
        } else {
            panic!("expected UInt");
        }
        // i16
        if let PackValue::Int(v) = &unpacked[1] {
            assert_eq!(*v, -1);
        } else {
            panic!("expected Int");
        }
    }

    #[test]
    fn pack_unpack_string_length_prefixed() {
        let values = vec![PackValue::Str("hello".into())];
        let buf = pack("<s", &values).unwrap();
        let (unpacked, _pos) = unpack("<s", buf.as_bytes(), 0).unwrap();
        if let PackValue::Str(s) = &unpacked[0] {
            assert_eq!(s, "hello");
        } else {
            panic!("expected Str");
        }
    }

    #[test]
    fn pack_unpack_null_terminated_string() {
        let values = vec![PackValue::Str("world".into())];
        let buf = pack("<z", &values).unwrap();
        let (unpacked, _pos) = unpack("<z", buf.as_bytes(), 0).unwrap();
        if let PackValue::Str(s) = &unpacked[0] {
            assert_eq!(s, "world");
        } else {
            panic!("expected Str");
        }
    }

    #[test]
    fn pack_padding_byte_is_zero() {
        let buf = pack("x", &[]).unwrap();
        assert_eq!(buf.len(), 1);
        assert_eq!(buf.as_bytes()[0], 0u8);
    }

    #[test]
    fn pack_unknown_format_returns_error() {
        let result = pack("Q", &[]);
        assert!(result.is_err());
    }

    #[test]
    fn unpack_buffer_underflow_returns_error() {
        // Trying to unpack an i32 (4 bytes) from a 2-byte buffer
        let result = unpack("<i", &[0x01, 0x02], 0);
        assert!(result.is_err());
    }

    #[test]
    fn get_packed_size_fixed_types() {
        // b + H + I + d = 1 + 2 + 4 + 8 = 15
        let size = get_packed_size("<bHId", &[]).unwrap();
        assert_eq!(size, 15);
    }

    #[test]
    fn get_packed_size_with_string() {
        let values = vec![PackValue::Str("hi".into())];
        // s = 4 (u32 len prefix) + 2 (content) = 6
        let size = get_packed_size("<s", &values).unwrap();
        assert_eq!(size, 6);
    }
}

// ── msgpack ───────────────────────────────────────────────────────────────────

mod msgpack_tests {
    use lurek2d::data::msgpack::{from_msgpack, to_msgpack};
    use serde_json::json;

    #[test]
    fn roundtrip_object() {
        let val = json!({"x": 1, "y": 2.5, "name": "test"});
        let bytes = to_msgpack(&val).unwrap();
        let back = from_msgpack(&bytes).unwrap();
        assert_eq!(val, back);
    }

    #[test]
    fn roundtrip_array() {
        let val = json!([1, "two", 3.0, true, null]);
        let bytes = to_msgpack(&val).unwrap();
        let back = from_msgpack(&bytes).unwrap();
        assert_eq!(val, back);
    }

    #[test]
    fn roundtrip_scalar_string() {
        let val = json!("hello lurek2d");
        let bytes = to_msgpack(&val).unwrap();
        let back = from_msgpack(&bytes).unwrap();
        assert_eq!(val, back);
    }

    #[test]
    fn roundtrip_null() {
        let val = json!(null);
        let bytes = to_msgpack(&val).unwrap();
        let back = from_msgpack(&bytes).unwrap();
        assert_eq!(val, back);
    }

    #[test]
    fn roundtrip_bool() {
        let val = json!(true);
        let bytes = to_msgpack(&val).unwrap();
        let back = from_msgpack(&bytes).unwrap();
        assert_eq!(val, back);
    }

    #[test]
    fn roundtrip_nested_object() {
        let val = json!({"a": {"b": [1, 2, {"c": false}]}});
        let bytes = to_msgpack(&val).unwrap();
        let back = from_msgpack(&bytes).unwrap();
        assert_eq!(val, back);
    }

    #[test]
    fn from_msgpack_invalid_bytes_returns_error() {
        let garbage = vec![0xFF, 0xFE, 0xFD, 0xFC];
        let result = from_msgpack(&garbage);
        assert!(result.is_err());
    }

    #[test]
    fn from_msgpack_empty_bytes_returns_error() {
        let result = from_msgpack(&[]);
        assert!(result.is_err());
    }

    #[test]
    fn msgpack_is_smaller_than_json_for_objects() {
        let val = json!({"key": "value", "number": 12345, "flag": true});
        let msgpack_bytes = to_msgpack(&val).unwrap();
        let json_bytes = serde_json::to_vec(&val).unwrap();
        // MessagePack should be more compact than JSON for typical payloads
        assert!(msgpack_bytes.len() <= json_bytes.len());
    }
}

// ── hash ──────────────────────────────────────────────────────────────────────

mod hash_tests {
    use lurek2d::data::{hash, HashAlgorithm};

    #[test]
    fn parse_str_md5_valid() {
        assert_eq!(HashAlgorithm::parse_str("md5").unwrap(), HashAlgorithm::Md5);
    }

    #[test]
    fn parse_str_sha256_valid() {
        assert_eq!(
            HashAlgorithm::parse_str("sha256").unwrap(),
            HashAlgorithm::Sha256
        );
    }

    #[test]
    fn parse_str_invalid_returns_err() {
        assert!(HashAlgorithm::parse_str("blake2").is_err());
    }

    #[test]
    fn md5_same_input_same_output() {
        let h1 = hash(HashAlgorithm::Md5, b"hello");
        let h2 = hash(HashAlgorithm::Md5, b"hello");
        assert_eq!(h1, h2);
    }

    #[test]
    fn md5_different_inputs_different_hashes() {
        let h1 = hash(HashAlgorithm::Md5, b"hello");
        let h2 = hash(HashAlgorithm::Md5, b"world");
        assert_ne!(h1, h2);
    }

    #[test]
    fn sha256_empty_known_value() {
        let h = hash(HashAlgorithm::Sha256, b"");
        assert_eq!(
            h,
            "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        );
    }
}

// ── encode ────────────────────────────────────────────────────────────────────

mod encode_tests {
    use lurek2d::data::{decode, encode, EncodeFormat};

    #[test]
    fn parse_str_base64_valid() {
        assert_eq!(
            EncodeFormat::parse_str("base64").unwrap(),
            EncodeFormat::Base64
        );
    }

    #[test]
    fn parse_str_hex_valid() {
        assert_eq!(EncodeFormat::parse_str("hex").unwrap(), EncodeFormat::Hex);
    }

    #[test]
    fn parse_str_invalid_returns_err() {
        assert!(EncodeFormat::parse_str("binary").is_err());
    }

    #[test]
    fn base64_encode_decode_roundtrip() {
        let data = b"Lurek2D engine test";
        let encoded = encode(EncodeFormat::Base64, data);
        let decoded = decode(EncodeFormat::Base64, &encoded).unwrap();
        assert_eq!(decoded.as_slice(), data.as_ref());
    }

    #[test]
    fn hex_encode_decode_roundtrip() {
        let data: &[u8] = &[0x00, 0xFF, 0x7F, 0x80];
        let encoded = encode(EncodeFormat::Hex, data);
        let decoded = decode(EncodeFormat::Hex, &encoded).unwrap();
        assert_eq!(decoded, data);
    }

    #[test]
    fn hex_encode_known_value() {
        let encoded = encode(EncodeFormat::Hex, &[0xDE, 0xAD, 0xBE, 0xEF]);
        assert_eq!(encoded, "deadbeef");
    }
}

// ── dataview ──────────────────────────────────────────────────────────────────

mod dataview_tests {
    use lurek2d::data::DataView;
    use std::sync::Arc;

    #[test]
    fn new_spans_entire_buffer() {
        let buf = Arc::new(vec![1u8, 2, 3, 4, 5]);
        let dv = DataView::new(buf);
        assert_eq!(dv.get_size(), 5);
        assert_eq!(dv.offset, 0);
    }

    #[test]
    fn new_slice_valid_range() {
        let buf = Arc::new(vec![10u8, 20, 30, 40, 50]);
        let dv = DataView::new_slice(buf, 1, 3).unwrap();
        assert_eq!(dv.get_size(), 3);
        assert_eq!(dv.offset, 1);
    }

    #[test]
    fn new_slice_out_of_bounds_returns_error() {
        let buf = Arc::new(vec![1u8, 2, 3]);
        let result = DataView::new_slice(buf, 2, 5);
        assert!(result.is_err());
    }

    #[test]
    fn new_slice_zero_size_at_end() {
        let buf = Arc::new(vec![1u8, 2, 3]);
        let dv = DataView::new_slice(buf, 3, 0).unwrap();
        assert_eq!(dv.get_size(), 0);
    }

    #[test]
    fn get_u8_reads_correctly() {
        let buf = Arc::new(vec![0xAB, 0xCD]);
        let dv = DataView::new(buf);
        assert_eq!(dv.get_u8(0).unwrap(), 0xAB);
        assert_eq!(dv.get_u8(1).unwrap(), 0xCD);
    }

    #[test]
    fn get_i8_reads_signed() {
        let buf = Arc::new(vec![0xFF]); // -1 as i8
        let dv = DataView::new(buf);
        assert_eq!(dv.get_i8(0).unwrap(), -1);
    }

    #[test]
    fn get_u16_little_endian() {
        // 0x0201 in LE = [0x01, 0x02]
        let buf = Arc::new(vec![0x01, 0x02]);
        let dv = DataView::new(buf);
        assert_eq!(dv.get_u16(0).unwrap(), 0x0201);
    }

    #[test]
    fn get_i16_little_endian() {
        // -1 in LE i16 = [0xFF, 0xFF]
        let buf = Arc::new(vec![0xFF, 0xFF]);
        let dv = DataView::new(buf);
        assert_eq!(dv.get_i16(0).unwrap(), -1);
    }

    #[test]
    fn get_u32_little_endian() {
        let buf = Arc::new(vec![0x78, 0x56, 0x34, 0x12]);
        let dv = DataView::new(buf);
        assert_eq!(dv.get_u32(0).unwrap(), 0x12345678);
    }

    #[test]
    fn get_i32_little_endian() {
        // -1 in LE i32
        let buf = Arc::new(vec![0xFF, 0xFF, 0xFF, 0xFF]);
        let dv = DataView::new(buf);
        assert_eq!(dv.get_i32(0).unwrap(), -1);
    }

    #[test]
    fn get_f32_known_value() {
        let bytes = 1.0f32.to_le_bytes();
        let buf = Arc::new(bytes.to_vec());
        let dv = DataView::new(buf);
        assert_eq!(dv.get_f32(0).unwrap(), 1.0f32);
    }

    #[test]
    fn get_f64_known_value() {
        let bytes = std::f64::consts::PI.to_le_bytes();
        let buf = Arc::new(bytes.to_vec());
        let dv = DataView::new(buf);
        let val = dv.get_f64(0).unwrap();
        assert!((val - std::f64::consts::PI).abs() < f64::EPSILON);
    }

    #[test]
    fn get_u8_out_of_bounds() {
        let buf = Arc::new(vec![1u8]);
        let dv = DataView::new(buf);
        assert!(dv.get_u8(1).is_err());
    }

    #[test]
    fn get_u32_out_of_bounds() {
        let buf = Arc::new(vec![1u8, 2, 3]); // only 3 bytes, u32 needs 4
        let dv = DataView::new(buf);
        assert!(dv.get_u32(0).is_err());
    }

    #[test]
    fn get_f64_out_of_bounds() {
        let buf = Arc::new(vec![0u8; 7]); // only 7 bytes, f64 needs 8
        let dv = DataView::new(buf);
        assert!(dv.get_f64(0).is_err());
    }

    #[test]
    fn sliced_view_reads_at_offset() {
        // Buffer: [0x00, 0xAA, 0xBB, 0x00]
        // View starts at offset 1, size 2
        let buf = Arc::new(vec![0x00, 0xAA, 0xBB, 0x00]);
        let dv = DataView::new_slice(buf, 1, 2).unwrap();
        assert_eq!(dv.get_u8(0).unwrap(), 0xAA);
        assert_eq!(dv.get_u8(1).unwrap(), 0xBB);
        assert!(dv.get_u8(2).is_err()); // beyond view
    }
}

// ── compress ──────────────────────────────────────────────────────────────────

mod compress_tests {
    use lurek2d::data::{compress, decompress, CompressFormat};

    #[test]
    fn parse_known_formats() {
        assert_eq!(
            CompressFormat::parse_str("deflate").unwrap(),
            CompressFormat::Deflate
        );
        assert_eq!(
            CompressFormat::parse_str("gzip").unwrap(),
            CompressFormat::Gzip
        );
        assert_eq!(
            CompressFormat::parse_str("gz").unwrap(),
            CompressFormat::Gzip
        );
        assert_eq!(
            CompressFormat::parse_str("lz4").unwrap(),
            CompressFormat::Lz4
        );
        assert_eq!(
            CompressFormat::parse_str("zlib").unwrap(),
            CompressFormat::Zlib
        );
    }

    #[test]
    fn parse_case_insensitive() {
        assert_eq!(
            CompressFormat::parse_str("DEFLATE").unwrap(),
            CompressFormat::Deflate
        );
        assert_eq!(
            CompressFormat::parse_str("GZip").unwrap(),
            CompressFormat::Gzip
        );
    }

    #[test]
    fn parse_unknown_format_errors() {
        assert!(CompressFormat::parse_str("brotli").is_err());
    }

    #[test]
    fn deflate_roundtrip() {
        let data = b"hello world, hello lurek2d!";
        let compressed = compress(data, CompressFormat::Deflate, 6).unwrap();
        let decompressed = decompress(&compressed, CompressFormat::Deflate).unwrap();
        assert_eq!(decompressed, data);
    }

    #[test]
    fn gzip_roundtrip() {
        let data = b"gzip test data for ring buffer";
        let compressed = compress(data, CompressFormat::Gzip, 6).unwrap();
        let decompressed = decompress(&compressed, CompressFormat::Gzip).unwrap();
        assert_eq!(decompressed, data);
    }

    #[test]
    fn zlib_roundtrip() {
        let data = b"zlib compression test";
        let compressed = compress(data, CompressFormat::Zlib, 6).unwrap();
        let decompressed = decompress(&compressed, CompressFormat::Zlib).unwrap();
        assert_eq!(decompressed, data);
    }

    #[test]
    fn lz4_roundtrip() {
        let data = b"lz4 block compression test payload";
        let compressed = compress(data, CompressFormat::Lz4, 0).unwrap();
        let decompressed = decompress(&compressed, CompressFormat::Lz4).unwrap();
        assert_eq!(decompressed, data);
    }

    #[test]
    fn empty_input_roundtrip() {
        let data = b"";
        for fmt in [
            CompressFormat::Deflate,
            CompressFormat::Gzip,
            CompressFormat::Zlib,
            CompressFormat::Lz4,
        ] {
            let compressed = compress(data, fmt, 6).unwrap();
            let decompressed = decompress(&compressed, fmt).unwrap();
            assert_eq!(decompressed, data, "failed for {:?}", fmt);
        }
    }

    #[test]
    fn level_clamped_to_nine() {
        // level 99 should not panic; internally clamped
        let data = b"test";
        let result = compress(data, CompressFormat::Deflate, 99);
        assert!(result.is_ok());
    }
}

// ── byte_data ─────────────────────────────────────────────────────────────────

mod byte_data_tests {
    use lurek2d::data::ByteData;

    #[test]
    fn new_zero_filled_correct_len() {
        let bd = ByteData::new(8);
        assert_eq!(bd.len(), 8);
        assert_eq!(bd.get_byte(0), Some(0));
        assert_eq!(bd.get_byte(7), Some(0));
    }

    #[test]
    fn from_bytes_preserves_data() {
        let bd = ByteData::from_bytes(vec![1, 2, 3]);
        assert_eq!(bd.len(), 3);
        assert_eq!(bd.get_byte(0), Some(1));
        assert_eq!(bd.get_byte(2), Some(3));
    }

    #[test]
    fn from_string_converts_correctly() {
        let bd = ByteData::from_string("hi");
        assert_eq!(bd.len(), 2);
        assert_eq!(bd.get_byte(0), Some(b'h'));
        assert_eq!(bd.get_byte(1), Some(b'i'));
    }

    #[test]
    fn set_byte_roundtrip() {
        let mut bd = ByteData::new(4);
        let ok = bd.set_byte(2, 42);
        assert!(ok);
        assert_eq!(bd.get_byte(2), Some(42));
    }

    #[test]
    fn set_byte_out_of_bounds_returns_false() {
        let mut bd = ByteData::new(4);
        assert!(!bd.set_byte(10, 1));
    }

    #[test]
    fn get_byte_out_of_bounds_returns_none() {
        let bd = ByteData::new(4);
        assert!(bd.get_byte(99).is_none());
    }

    #[test]
    fn is_empty_zero_size() {
        let bd = ByteData::new(0);
        assert!(bd.is_empty());
    }

    #[test]
    fn as_bytes_matches_data() {
        let bd = ByteData::from_bytes(vec![10, 20, 30]);
        assert_eq!(bd.as_bytes(), &[10u8, 20, 30]);
    }

    #[test]
    fn get_string_roundtrip() {
        let bd = ByteData::from_string("hello");
        assert_eq!(bd.get_string(), "hello");
    }
}

// ── bin_pack ──────────────────────────────────────────────────────────────────

mod bin_pack_tests {
    use lurek2d::data::{bin_measure_size, bin_read, bin_write, BinValue};

    #[test]
    fn measure_size_fixed_tokens_matches_write_output() {
        // "u8 u16 u32 u64" = 1+2+4+8 = 15 bytes
        let size = bin_measure_size("u8 u16 u32 u64").unwrap();
        assert_eq!(size, 15);
    }

    #[test]
    fn write_and_read_round_trip_u32() {
        let values = vec![BinValue::U32(0xDEAD_BEEF)];
        let buf = bin_write("u32", &values).unwrap();
        assert_eq!(buf.len(), 4);
        let (back, _pos) = bin_read("u32", buf.as_bytes(), 0).unwrap();
        assert_eq!(back.len(), 1);
        assert!(matches!(back[0], BinValue::U32(0xDEAD_BEEF)));
    }

    #[test]
    fn measure_size_rejects_variable_length_tokens() {
        assert!(bin_measure_size("str").is_err());
        assert!(bin_measure_size("cstr").is_err());
    }

    #[test]
    fn write_and_read_round_trip_all_fixed_types() {
        let values = vec![
            BinValue::U8(0xFF),
            BinValue::I8(-1),
            BinValue::U16(1000),
            BinValue::I16(-500),
            BinValue::U32(100_000),
            BinValue::I32(-100_000),
            BinValue::F32(3.14),
            BinValue::F64(2.718281828),
            BinValue::Bool(true),
        ];
        let fmt = "u8 i8 u16 i16 u32 i32 f32 f64 bool";
        let buf = bin_write(fmt, &values).unwrap();
        let (back, _pos) = bin_read(fmt, buf.as_bytes(), 0).unwrap();
        assert_eq!(back.len(), 9);
        assert!(matches!(back[0], BinValue::U8(0xFF)));
        assert!(matches!(back[1], BinValue::I8(-1)));
        assert!(matches!(back[8], BinValue::Bool(true)));
    }

    #[test]
    fn write_and_read_string_roundtrip() {
        let values = vec![BinValue::Str("hello".into())];
        let buf = bin_write("str", &values).unwrap();
        let (back, _pos) = bin_read("str", buf.as_bytes(), 0).unwrap();
        if let BinValue::Str(s) = &back[0] {
            assert_eq!(s, "hello");
        } else {
            panic!("expected Str");
        }
    }

    #[test]
    fn write_and_read_cstr_roundtrip() {
        let values = vec![BinValue::Str("world".into())];
        let buf = bin_write("cstr", &values).unwrap();
        let (back, _pos) = bin_read("cstr", buf.as_bytes(), 0).unwrap();
        if let BinValue::Str(s) = &back[0] {
            assert_eq!(s, "world");
        } else {
            panic!("expected Str");
        }
    }

    #[test]
    fn big_endian_modifier_reverses_byte_order() {
        let values = vec![BinValue::U16(0x0102)];
        let buf_le = bin_write("le u16", &values).unwrap();
        let buf_be = bin_write("be u16", &values).unwrap();
        // LE: [0x02, 0x01]  BE: [0x01, 0x02]
        assert_eq!(buf_le.as_bytes(), &[0x02, 0x01]);
        assert_eq!(buf_be.as_bytes(), &[0x01, 0x02]);
    }

    #[test]
    fn pad_token_writes_zero_byte() {
        let buf = bin_write("pad", &[]).unwrap();
        assert_eq!(buf.len(), 1);
        assert_eq!(buf.as_bytes()[0], 0);
    }

    #[test]
    fn unknown_token_returns_error() {
        let result = bin_write("float128", &[]);
        assert!(result.is_err());
    }

    #[test]
    fn read_out_of_bounds_returns_error() {
        let result = bin_read("u32", &[0x01, 0x02], 0);
        assert!(result.is_err());
    }
}

// ── DataWriter ────────────────────────────────────────────────────────────────

mod data_writer_tests {
    use lurek2d::data::DataWriter;

    #[test]
    fn new_is_empty() {
        let w = DataWriter::new();
        assert_eq!(w.len(), 0);
        assert!(w.is_empty());
    }

    #[test]
    fn write_u8_increments_len() {
        let mut w = DataWriter::new();
        w.write_u8(42);
        assert_eq!(w.len(), 1);
    }

    #[test]
    fn write_u8_correct_byte_value() {
        let mut w = DataWriter::new();
        w.write_u8(0xAB);
        assert_eq!(w.as_bytes(), &[0xAB]);
    }

    #[test]
    fn write_u32_le_writes_four_bytes() {
        let mut w = DataWriter::new();
        w.write_u32_le(0x01020304);
        assert_eq!(w.len(), 4);
        let b = w.as_bytes();
        assert_eq!(b[0], 0x04); // LE: least significant first
        assert_eq!(b[3], 0x01);
    }

    #[test]
    fn write_string_adds_length_prefix() {
        let mut w = DataWriter::new();
        w.write_string("hi");
        // 4 bytes LE prefix + 2 bytes content
        assert_eq!(w.len(), 6);
    }

    #[test]
    fn write_string_content_preserved() {
        let mut w = DataWriter::new();
        w.write_string("AB");
        let b = w.as_bytes();
        assert_eq!(b[4], b'A');
        assert_eq!(b[5], b'B');
    }

    #[test]
    fn tell_starts_at_zero() {
        let w = DataWriter::new();
        assert_eq!(w.tell(), 0);
    }

    #[test]
    fn tell_advances_after_write() {
        let mut w = DataWriter::new();
        w.write_u8(1);
        w.write_u8(2);
        assert_eq!(w.tell(), 2);
    }

    #[test]
    fn seek_repositions_cursor() {
        let mut w = DataWriter::new();
        w.write_u8(1);
        w.write_u8(2);
        w.write_u8(3);
        w.seek(1);
        assert_eq!(w.tell(), 1);
    }

    #[test]
    fn seek_past_end_extends_buffer() {
        let mut w = DataWriter::new();
        w.seek(4);
        assert_eq!(w.len(), 4);
    }

    #[test]
    fn seek_and_overwrite() {
        let mut w = DataWriter::new();
        w.write_u8(0x00);
        w.write_u8(0x00);
        w.seek(0);
        w.write_u8(0xFF);
        let b = w.into_bytes();
        assert_eq!(b.len(), 2);
        assert_eq!(b[0], 0xFF);
        assert_eq!(b[1], 0x00);
    }

    #[test]
    fn into_bytes_returns_all_written() {
        let mut w = DataWriter::new();
        w.write_u8(10);
        w.write_u8(20);
        w.write_u8(30);
        let b = w.into_bytes();
        assert_eq!(b, vec![10, 20, 30]);
    }
}

mod crc32_tests {
    use lurek2d::data::crc32;

    #[test]
    fn crc32_empty_is_zero() {
        assert_eq!(0, crc32(b""));
    }

    #[test]
    fn crc32_known_vector_123456789() {
        // Standard CRC-32/ISO-HDLC check value for "123456789" is 0xCBF43926
        assert_eq!(0xCBF4_3926_u64, crc32(b"123456789"));
    }

    #[test]
    fn crc32_is_deterministic() {
        assert_eq!(crc32(b"hello"), crc32(b"hello"));
    }

    #[test]
    fn crc32_differs_for_different_inputs() {
        assert_ne!(crc32(b"hello"), crc32(b"world"));
    }

    #[test]
    fn crc32_result_fits_in_u32_range() {
        let v = crc32(b"test");
        assert!(v <= u32::MAX as u64);
    }
}
