//! One-shot threaded dataframe jobs for file loading and SQL queries.
//!
//! - Worker-owned storage snapshots so large CSV/JSON reads do not pass through Lua strings.
//! - Poll, wait, result, error, and progress lifecycle helpers shared by Lua bindings.
//! - Snapshot-based DataFrame and Database query execution on Rust worker threads.

use crate::dataframe::file_io::{self, DataFrameFileError, DataFrameFileStore};
use crate::dataframe::frame::{CellValue, DataFrame, Database};
use crate::dataframe::sql;
use std::fmt::Display;
use std::sync::atomic::{AtomicU8, Ordering};
use std::sync::{mpsc, Arc};
use std::thread;

type DataFrameTaskOutcome = Result<DataFrame, String>;

/// Owns one background dataframe job and its eventual result.
pub struct DataFrameTask {
    /// Receives the worker result while the task is pending.
    receiver: Option<mpsc::Receiver<DataFrameTaskOutcome>>,
    /// Stores the completed worker result once observed by the main thread.
    outcome: Option<DataFrameTaskOutcome>,
    /// Stores a coarse completion percentage from 0 to 100.
    progress: Arc<AtomicU8>,
}

impl DataFrameTask {
    /// Spawn a CSV file load task over a worker-owned storage snapshot.
    pub fn spawn_csv_file<S>(store: S, path: String, label: &str) -> Result<Self, String>
    where
        S: DataFrameFileStore + Send + 'static,
        S::Error: Display + Send + 'static,
    {
        Self::spawn(label, move |progress| {
            progress.store(10, Ordering::Relaxed);
            let dataframe =
                file_io::read_csv_dataframe(&store, &path).map_err(format_dataframe_file_error)?;
            progress.store(100, Ordering::Relaxed);
            Ok(dataframe)
        })
    }

    /// Spawn a JSON file load task over a worker-owned storage snapshot.
    pub fn spawn_json_file<S>(store: S, path: String, label: &str) -> Result<Self, String>
    where
        S: DataFrameFileStore + Send + 'static,
        S::Error: Display + Send + 'static,
    {
        Self::spawn(label, move |progress| {
            progress.store(10, Ordering::Relaxed);
            let dataframe =
                file_io::read_json_dataframe(&store, &path).map_err(format_dataframe_file_error)?;
            progress.store(100, Ordering::Relaxed);
            Ok(dataframe)
        })
    }

    /// Spawn a SQL query task over a dataframe snapshot.
    pub fn spawn_dataframe_query(
        dataframe: DataFrame,
        sql_text: String,
        label: &str,
    ) -> Result<Self, String> {
        Self::spawn(label, move |progress| {
            progress.store(40, Ordering::Relaxed);
            let result = sql::query_sql(&dataframe, &sql_text)?;
            progress.store(100, Ordering::Relaxed);
            Ok(result)
        })
    }

    /// Spawn a SQL query task over a database snapshot.
    pub fn spawn_database_query(
        database: Database,
        sql_text: String,
        label: &str,
    ) -> Result<Self, String> {
        Self::spawn(label, move |progress| {
            progress.store(40, Ordering::Relaxed);
            let result = sql::query_sql_database(&database, &sql_text)?;
            progress.store(100, Ordering::Relaxed);
            Ok(result)
        })
    }

    /// Spawn a parameterized SQL query task over a database snapshot.
    pub fn spawn_database_query_params(
        database: Database,
        sql_text: String,
        params: Vec<CellValue>,
        label: &str,
    ) -> Result<Self, String> {
        Self::spawn(label, move |progress| {
            progress.store(40, Ordering::Relaxed);
            let result = sql::query_sql_database_params(&database, &sql_text, &params)?;
            progress.store(100, Ordering::Relaxed);
            Ok(result)
        })
    }

    /// Return true when the task has completed with success or failure.
    pub fn is_done(&mut self) -> bool {
        self.poll();
        self.outcome.is_some()
    }

    /// Block until the task completes and return true only for a successful dataframe result.
    pub fn wait(&mut self) -> bool {
        if self.outcome.is_none() {
            if let Some(receiver) = self.receiver.take() {
                self.outcome = match receiver.recv() {
                    Ok(outcome) => Some(outcome),
                    Err(_) => Some(Err(
                        "dataframe task worker terminated before producing a result".to_string(),
                    )),
                };
                self.progress.store(100, Ordering::Relaxed);
            }
        }
        matches!(self.outcome.as_ref(), Some(Ok(_)))
    }

    /// Return a cloned dataframe result after successful completion.
    pub fn result(&mut self) -> Result<DataFrame, String> {
        self.poll();
        match self.outcome.as_ref() {
            Some(Ok(dataframe)) => Ok(dataframe.clone_df()),
            Some(Err(message)) => Err(message.clone()),
            None => {
                Err("dataframe task is still pending; call wait() or check isDone()".to_string())
            }
        }
    }

    /// Return the task error message when the task has failed.
    pub fn get_error(&mut self) -> Option<String> {
        self.poll();
        match self.outcome.as_ref() {
            Some(Err(message)) => Some(message.clone()),
            _ => None,
        }
    }

    /// Return a coarse completion estimate from 0.0 to 1.0.
    pub fn progress(&mut self) -> f64 {
        self.poll();
        f64::from(self.progress.load(Ordering::Relaxed)) / 100.0
    }

    /// Spawn a worker thread for a one-shot dataframe computation.
    fn spawn<F>(label: &str, job: F) -> Result<Self, String>
    where
        F: FnOnce(&AtomicU8) -> Result<DataFrame, String> + Send + 'static,
    {
        let (sender, receiver) = mpsc::channel();
        let progress = Arc::new(AtomicU8::new(0));
        let worker_progress = Arc::clone(&progress);
        let task_label = label.to_string();
        thread::Builder::new()
            .name("lurek-dataframe-task".to_string())
            .spawn(move || {
                worker_progress.store(1, Ordering::Relaxed);
                let outcome =
                    job(&worker_progress).map_err(|message| format!("{task_label}: {message}"));
                worker_progress.store(100, Ordering::Relaxed);
                let _ = sender.send(outcome);
            })
            .map_err(|error| format!("failed to spawn dataframe task: {error}"))?;
        Ok(Self {
            receiver: Some(receiver),
            outcome: None,
            progress,
        })
    }

    /// Poll the worker result channel without blocking.
    fn poll(&mut self) {
        if self.outcome.is_some() {
            return;
        }
        let poll_result = self.receiver.as_ref().map(|receiver| receiver.try_recv());
        match poll_result {
            Some(Ok(outcome)) => {
                self.outcome = Some(outcome);
                self.receiver = None;
                self.progress.store(100, Ordering::Relaxed);
            }
            Some(Err(mpsc::TryRecvError::Disconnected)) => {
                self.outcome = Some(Err(
                    "dataframe task worker terminated before producing a result".to_string(),
                ));
                self.receiver = None;
                self.progress.store(100, Ordering::Relaxed);
            }
            Some(Err(mpsc::TryRecvError::Empty)) | None => {}
        }
    }
}

/// Convert storage and parser failures into a stable task error string.
fn format_dataframe_file_error<E>(error: DataFrameFileError<E>) -> String
where
    E: Display,
{
    error.to_string()
}
