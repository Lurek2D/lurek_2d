//! Provides storage-agnostic DataFrame and Database file persistence helpers.
//!
//! - Defines a narrow trait for reading and writing text, JSON, and binary payloads without importing GameFS.
//! - Combines existing CSV, JSON, LVDF, and database serializers with caller-provided storage operations.
//! - Keeps storage failures separate from parse and format failures so Lua bindings can preserve error surfaces.

use crate::dataframe::frame::{DataFrame, Database};
use crate::dataframe::serial;
use std::error::Error;
use std::fmt::{self, Display, Formatter};

/// Minimal storage operations required by dataframe file persistence.
pub trait DataFrameFileStore {
    /// Storage-specific error produced by read and write operations.
    type Error;

    /// Read UTF-8 text from a storage path.
    fn read_string(&self, path: &str) -> Result<String, Self::Error>;

    /// Read JSON text from a storage path.
    fn read_json(&self, path: &str) -> Result<String, Self::Error>;

    /// Read raw bytes from a storage path.
    fn read_bytes(&self, path: &str) -> Result<Vec<u8>, Self::Error>;

    /// Write UTF-8 text to a storage path.
    fn write_string(&self, path: &str, content: &str) -> Result<(), Self::Error>;

    /// Write JSON text to a storage path.
    fn write_json(&self, path: &str, json: &str) -> Result<(), Self::Error>;

    /// Write raw bytes to a storage path.
    fn write_bytes(&self, path: &str, bytes: &[u8]) -> Result<(), Self::Error>;
}

/// Error category for dataframe persistence over an external storage layer.
#[derive(Debug)]
pub enum DataFrameFileError<E> {
    /// Storage layer failed while reading or writing the target path.
    Storage(E),
    /// Dataframe serializer or parser rejected the payload.
    Format(String),
}

impl<E: Display> Display for DataFrameFileError<E> {
    /// Format storage and payload errors for diagnostics.
    fn fmt(&self, formatter: &mut Formatter<'_>) -> fmt::Result {
        match self {
            Self::Storage(error) => write!(formatter, "{error}"),
            Self::Format(message) => formatter.write_str(message),
        }
    }
}

impl<E> Error for DataFrameFileError<E>
where
    E: Error + 'static,
{
    /// Return the wrapped storage error when one exists.
    fn source(&self) -> Option<&(dyn Error + 'static)> {
        match self {
            Self::Storage(error) => Some(error),
            Self::Format(_) => None,
        }
    }
}

/// Result type used by dataframe file persistence helpers.
pub type DataFrameFileResult<T, E> = Result<T, DataFrameFileError<E>>;

/// Read CSV text from storage, parse it, and return a dataframe.
pub fn read_csv_dataframe<S>(store: &S, path: &str) -> DataFrameFileResult<DataFrame, S::Error>
where
    S: DataFrameFileStore + ?Sized,
{
    let csv = store
        .read_string(path)
        .map_err(DataFrameFileError::Storage)?;
    serial::from_csv(&csv).map_err(DataFrameFileError::Format)
}

/// Read JSON text from storage, parse it, and return a dataframe.
pub fn read_json_dataframe<S>(store: &S, path: &str) -> DataFrameFileResult<DataFrame, S::Error>
where
    S: DataFrameFileStore + ?Sized,
{
    let json = store.read_json(path).map_err(DataFrameFileError::Storage)?;
    serial::from_json(&json).map_err(DataFrameFileError::Format)
}

/// Serialize a dataframe to CSV and write it through storage.
pub fn write_csv_dataframe<S>(
    store: &S,
    path: &str,
    dataframe: &DataFrame,
) -> DataFrameFileResult<(), S::Error>
where
    S: DataFrameFileStore + ?Sized,
{
    let csv = dataframe.to_csv();
    store
        .write_string(path, &csv)
        .map_err(DataFrameFileError::Storage)
}

/// Serialize a dataframe to JSON and write it through storage.
pub fn write_json_dataframe<S>(
    store: &S,
    path: &str,
    dataframe: &DataFrame,
) -> DataFrameFileResult<(), S::Error>
where
    S: DataFrameFileStore + ?Sized,
{
    let json = dataframe.to_json();
    store
        .write_json(path, &json)
        .map_err(DataFrameFileError::Storage)
}

/// Serialize a dataframe to LVDF bytes and write them through storage.
pub fn write_binary_dataframe<S>(
    store: &S,
    path: &str,
    dataframe: &DataFrame,
) -> DataFrameFileResult<(), S::Error>
where
    S: DataFrameFileStore + ?Sized,
{
    let bytes = dataframe.to_binary();
    store
        .write_bytes(path, &bytes)
        .map_err(DataFrameFileError::Storage)
}

/// Read JSON database text from storage, parse it, and return a database.
pub fn load_json_database<S>(store: &S, path: &str) -> DataFrameFileResult<Database, S::Error>
where
    S: DataFrameFileStore + ?Sized,
{
    let json = store.read_json(path).map_err(DataFrameFileError::Storage)?;
    serial::database_from_json(&json).map_err(DataFrameFileError::Format)
}

/// Serialize a database to JSON and write it through storage.
pub fn save_json_database<S>(
    store: &S,
    path: &str,
    database: &Database,
) -> DataFrameFileResult<(), S::Error>
where
    S: DataFrameFileStore + ?Sized,
{
    let json = database.to_json();
    store
        .write_json(path, &json)
        .map_err(DataFrameFileError::Storage)
}
