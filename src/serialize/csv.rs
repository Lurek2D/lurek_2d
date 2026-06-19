//! This file owns CSV translation between delimited rows and the shared `SerialValue` tree used by the engine.
//! It defines `CsvOptions`, parses header-aware or positional records, and serializes row sequences back to text.
//! Header mode maps columns into ordered maps, while headerless mode keeps each record as a plain value sequence.
//! Encoding enforces compatible row shapes so CSV assumptions stay aligned between read and write operations.
//! Open this file when tabular serialization rules change; generic dispatch and value-tree ownership live nearby.

use super::codec::{SerializeError, SerializeLimitKind};
use super::json::to_json;
use super::lua_table::SerialValue;
use indexmap::IndexMap;
use std::io::Read;

/// How CSV encoding should handle nested values in one cell.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum CsvComplexCellPolicy {
    /// Reject nested maps and sequences.
    Reject,
    /// Encode nested maps and sequences as compact JSON inside the cell.
    Json,
}

/// Options controlling CSV parsing and serialization behavior.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct CsvOptions {
    /// Column separator byte (default `,`).
    pub delimiter: u8,
    /// Whether the first row is treated as column headers.
    pub has_headers: bool,
    /// Maximum allowed row count.
    pub max_rows: usize,
    /// Maximum allowed columns in one row.
    pub max_columns: usize,
    /// Maximum UTF-8 character length in one field.
    pub max_field_chars: usize,
    /// Whether inconsistent column counts should error instead of staying permissive.
    pub strict_column_count: bool,
    /// Nested value handling policy for encoding.
    pub complex_cells: CsvComplexCellPolicy,
}

/// Provide sensible defaults for tabular safety.
impl Default for CsvOptions {
    fn default() -> Self {
        Self {
            delimiter: b',',
            has_headers: true,
            max_rows: 10_000,
            max_columns: 1_024,
            max_field_chars: 1_000_000,
            strict_column_count: false,
            complex_cells: CsvComplexCellPolicy::Reject,
        }
    }
}

fn csv_limit(
    context: impl Into<String>,
    kind: SerializeLimitKind,
    actual: usize,
    max: usize,
) -> SerializeError {
    SerializeError::limit(context, kind, actual, max)
}

fn check_field_length(
    field: &str,
    row_index: usize,
    column_index: usize,
    opts: CsvOptions,
) -> Result<(), SerializeError> {
    let char_len = field.chars().count();
    if char_len > opts.max_field_chars {
        return Err(csv_limit(
            format!("from_csv row {} column {}", row_index + 1, column_index + 1),
            SerializeLimitKind::CsvFieldChars,
            char_len,
            opts.max_field_chars,
        ));
    }
    Ok(())
}

fn csv_cell_to_string(
    value: &SerialValue,
    opts: CsvOptions,
    context: &str,
) -> Result<String, SerializeError> {
    let text = match value {
        SerialValue::Null => String::new(),
        SerialValue::Bool(b) => b.to_string(),
        SerialValue::Int(n) => n.to_string(),
        SerialValue::Float(f) => f.to_string(),
        SerialValue::Str(s) => s.clone(),
        SerialValue::Seq(_) | SerialValue::Map(_) => match opts.complex_cells {
            CsvComplexCellPolicy::Reject => {
                return Err(SerializeError::CsvComplexCell {
                    context: context.to_string(),
                })
            }
            CsvComplexCellPolicy::Json => {
                to_json(value, false).map_err(|msg| SerializeError::codec(context, msg))?
            }
        },
    };
    let char_len = text.chars().count();
    if char_len > opts.max_field_chars {
        return Err(csv_limit(
            context,
            SerializeLimitKind::CsvFieldChars,
            char_len,
            opts.max_field_chars,
        ));
    }
    Ok(text)
}

/// Parse a CSV string into a `SerialValue` sequence.
pub fn from_csv(s: &str, opts: CsvOptions) -> Result<SerialValue, String> {
    from_csv_with_options(s, opts).map_err(|err| err.to_string())
}

/// Parse CSV from text into a `SerialValue` sequence with structured errors.
pub(crate) fn from_csv_with_options(
    s: &str,
    opts: CsvOptions,
) -> Result<SerialValue, SerializeError> {
    from_csv_reader(s.as_bytes(), opts)
}

/// Parse CSV from any `Read` source into a `SerialValue` sequence.
pub(crate) fn from_csv_reader<R: Read>(
    reader: R,
    opts: CsvOptions,
) -> Result<SerialValue, SerializeError> {
    let mut reader = csv::ReaderBuilder::new()
        .delimiter(opts.delimiter)
        .has_headers(opts.has_headers)
        .from_reader(reader);

    let mut expected_columns: Option<usize> = None;
    if opts.has_headers {
        let headers = reader
            .headers()
            .map_err(|e| SerializeError::codec("from_csv", format!("CSV parse error: {e}")))?
            .clone();
        if headers.len() > opts.max_columns {
            return Err(csv_limit(
                "from_csv headers",
                SerializeLimitKind::CsvColumns,
                headers.len(),
                opts.max_columns,
            ));
        }
        for (column_index, header) in headers.iter().enumerate() {
            check_field_length(header, 0, column_index, opts)?;
        }
        expected_columns = Some(headers.len());
        let headers: Vec<String> = headers.iter().map(ToString::to_string).collect();
        let mut rows = Vec::new();
        for (row_index, result) in reader.records().enumerate() {
            if row_index >= opts.max_rows {
                return Err(csv_limit(
                    "from_csv rows",
                    SerializeLimitKind::CsvRows,
                    row_index + 1,
                    opts.max_rows,
                ));
            }
            let record = result
                .map_err(|e| SerializeError::codec("from_csv", format!("CSV parse error: {e}")))?;
            if record.len() > opts.max_columns {
                return Err(csv_limit(
                    format!("from_csv row {}", row_index + 1),
                    SerializeLimitKind::CsvColumns,
                    record.len(),
                    opts.max_columns,
                ));
            }
            if opts.strict_column_count && record.len() != expected_columns.unwrap_or(0) {
                return Err(SerializeError::CsvColumnMismatch {
                    context: format!("from_csv row {}", row_index + 1),
                    expected: expected_columns.unwrap_or(0),
                    actual: record.len(),
                });
            }

            let mut map = IndexMap::new();
            for (column_index, field) in record.iter().enumerate() {
                check_field_length(field, row_index + 1, column_index, opts)?;
                let key = headers
                    .get(column_index)
                    .cloned()
                    .unwrap_or_else(|| column_index.to_string());
                map.insert(key, SerialValue::Str(field.to_string()));
            }
            rows.push(SerialValue::Map(map));
        }
        return Ok(SerialValue::Seq(rows));
    }

    let mut rows = Vec::new();
    for (row_index, result) in reader.records().enumerate() {
        if row_index >= opts.max_rows {
            return Err(csv_limit(
                "from_csv rows",
                SerializeLimitKind::CsvRows,
                row_index + 1,
                opts.max_rows,
            ));
        }
        let record = result
            .map_err(|e| SerializeError::codec("from_csv", format!("CSV parse error: {e}")))?;
        if record.len() > opts.max_columns {
            return Err(csv_limit(
                format!("from_csv row {}", row_index + 1),
                SerializeLimitKind::CsvColumns,
                record.len(),
                opts.max_columns,
            ));
        }
        if opts.strict_column_count {
            match expected_columns {
                Some(expected) if record.len() != expected => {
                    return Err(SerializeError::CsvColumnMismatch {
                        context: format!("from_csv row {}", row_index + 1),
                        expected,
                        actual: record.len(),
                    });
                }
                None => expected_columns = Some(record.len()),
                _ => {}
            }
        }
        let mut fields = Vec::with_capacity(record.len());
        for (column_index, field) in record.iter().enumerate() {
            check_field_length(field, row_index + 1, column_index, opts)?;
            fields.push(SerialValue::Str(field.to_string()));
        }
        rows.push(SerialValue::Seq(fields));
    }
    Ok(SerialValue::Seq(rows))
}

/// Serialize a `SerialValue` sequence of rows into a CSV string.
pub fn to_csv(val: &SerialValue, opts: CsvOptions) -> Result<String, String> {
    to_csv_with_options(val, opts).map_err(|err| err.to_string())
}

/// Serialize a `SerialValue` sequence of rows into a CSV string with structured errors.
pub(crate) fn to_csv_with_options(
    val: &SerialValue,
    opts: CsvOptions,
) -> Result<String, SerializeError> {
    let rows = match val {
        SerialValue::Seq(rows) => rows,
        _ => {
            return Err(SerializeError::codec(
                "to_csv",
                "expected a sequence of rows",
            ))
        }
    };
    if rows.len() > opts.max_rows {
        return Err(csv_limit(
            "to_csv rows",
            SerializeLimitKind::CsvRows,
            rows.len(),
            opts.max_rows,
        ));
    }

    let mut out = Vec::new();
    let mut writer = csv::WriterBuilder::new()
        .delimiter(opts.delimiter)
        .from_writer(&mut out);

    if opts.has_headers {
        let mut headers = Vec::new();
        for row in rows {
            match row {
                SerialValue::Map(map) => {
                    for key in map.keys() {
                        if !headers.iter().any(|header: &String| header == key) {
                            headers.push(key.clone());
                        }
                    }
                }
                _ => {
                    return Err(SerializeError::codec(
                        "to_csv",
                        "rows must be maps when has_headers is true",
                    ))
                }
            }
        }

        if headers.len() > opts.max_columns {
            return Err(csv_limit(
                "to_csv headers",
                SerializeLimitKind::CsvColumns,
                headers.len(),
                opts.max_columns,
            ));
        }
        for header in &headers {
            let header_len = header.chars().count();
            if header_len > opts.max_field_chars {
                return Err(csv_limit(
                    "to_csv headers",
                    SerializeLimitKind::CsvFieldChars,
                    header_len,
                    opts.max_field_chars,
                ));
            }
        }
        writer
            .write_record(&headers)
            .map_err(|e| SerializeError::codec("to_csv", format!("CSV encode error: {e}")))?;

        for (row_index, row) in rows.iter().enumerate() {
            let map = match row {
                SerialValue::Map(map) => map,
                _ => unreachable!("has_headers path already validated row shape"),
            };
            if opts.strict_column_count && map.len() != headers.len() {
                return Err(SerializeError::CsvColumnMismatch {
                    context: format!("to_csv row {}", row_index + 1),
                    expected: headers.len(),
                    actual: map.len(),
                });
            }
            let mut values = Vec::with_capacity(headers.len());
            for header in &headers {
                let cell_context = format!("to_csv row {} column {}", row_index + 1, header);
                let text = match map.get(header) {
                    Some(value) => csv_cell_to_string(value, opts, &cell_context)?,
                    None => String::new(),
                };
                values.push(text);
            }
            writer
                .write_record(&values)
                .map_err(|e| SerializeError::codec("to_csv", format!("CSV encode error: {e}")))?;
        }
    } else {
        let mut expected_columns: Option<usize> = None;
        for (row_index, row) in rows.iter().enumerate() {
            let values: Vec<String> = match row {
                SerialValue::Map(map) => map
                    .values()
                    .enumerate()
                    .map(|(column_index, value)| {
                        csv_cell_to_string(
                            value,
                            opts,
                            &format!("to_csv row {} column {}", row_index + 1, column_index + 1),
                        )
                    })
                    .collect::<Result<Vec<_>, _>>()?,
                SerialValue::Seq(fields) => fields
                    .iter()
                    .enumerate()
                    .map(|(column_index, value)| {
                        csv_cell_to_string(
                            value,
                            opts,
                            &format!("to_csv row {} column {}", row_index + 1, column_index + 1),
                        )
                    })
                    .collect::<Result<Vec<_>, _>>()?,
                _ => {
                    return Err(SerializeError::codec(
                        "to_csv",
                        "each row must be a map or sequence",
                    ))
                }
            };

            if values.len() > opts.max_columns {
                return Err(csv_limit(
                    format!("to_csv row {}", row_index + 1),
                    SerializeLimitKind::CsvColumns,
                    values.len(),
                    opts.max_columns,
                ));
            }
            if opts.strict_column_count {
                match expected_columns {
                    Some(expected) if values.len() != expected => {
                        return Err(SerializeError::CsvColumnMismatch {
                            context: format!("to_csv row {}", row_index + 1),
                            expected,
                            actual: values.len(),
                        });
                    }
                    None => expected_columns = Some(values.len()),
                    _ => {}
                }
            }

            writer
                .write_record(&values)
                .map_err(|e| SerializeError::codec("to_csv", format!("CSV encode error: {e}")))?;
        }
    }

    writer
        .flush()
        .map_err(|e| SerializeError::codec("to_csv", format!("CSV encode error: {e}")))?;
    drop(writer);
    String::from_utf8(out)
        .map_err(|e| SerializeError::codec("to_csv", format!("CSV encode error: {e}")))
}
