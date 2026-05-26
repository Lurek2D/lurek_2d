//! Frequency tables with optional percentage output
//!
//! - Column-level missing-value reports
//! - Duplicate row extraction by full-row or selected-column keys
//! - ISO date part extraction into appended year, month, and day columns

use crate::dataframe::frame::{CellValue, ColRef, DataFrame};

impl DataFrame {
    /// Count occurrences of values in one column with optional percentage output.
    pub fn value_counts(&self, col: ColRef, include_percent: bool) -> Result<DataFrame, String> {
        let ci = self.resolve_col(col)?;
        let data = self.raw_data();
        let mut counts: Vec<(CellValue, usize)> = Vec::new();
        for value in &data[ci] {
            if let Some((_, count)) = counts.iter_mut().find(|(key, _)| key == value) {
                *count += 1;
            } else {
                counts.push((value.clone(), 1));
            }
        }

        let mut columns = vec!["value".to_string(), "count".to_string()];
        let mut result_data = vec![Vec::new(), Vec::new()];
        if include_percent {
            columns.push("percent".to_string());
            result_data.push(Vec::new());
        }

        let total = self.nrows() as f64;
        for (value, count) in counts {
            result_data[0].push(value);
            result_data[1].push(CellValue::Number(count as f64));
            if include_percent {
                let percent = if total == 0.0 {
                    0.0
                } else {
                    (count as f64 / total) * 100.0
                };
                result_data[2].push(CellValue::Number(percent));
            }
        }

        Ok(DataFrame::from_raw(columns, result_data))
    }

    /// Build a per-column missing-value report.
    pub fn missing_report(&self) -> DataFrame {
        let nrows = self.nrows();
        let total = nrows as f64;
        let mut column_col = Vec::with_capacity(self.ncols());
        let mut missing_col = Vec::with_capacity(self.ncols());
        let mut non_missing_col = Vec::with_capacity(self.ncols());
        let mut missing_percent_col = Vec::with_capacity(self.ncols());

        for (ci, name) in self.columns().iter().enumerate() {
            let missing = self.raw_data()[ci]
                .iter()
                .filter(|cell| cell.is_nil())
                .count();
            let non_missing = nrows.saturating_sub(missing);
            let percent = if total == 0.0 {
                0.0
            } else {
                (missing as f64 / total) * 100.0
            };
            column_col.push(CellValue::Text(name.clone()));
            missing_col.push(CellValue::Number(missing as f64));
            non_missing_col.push(CellValue::Number(non_missing as f64));
            missing_percent_col.push(CellValue::Number(percent));
        }

        DataFrame::from_raw(
            vec![
                "column".to_string(),
                "missing".to_string(),
                "non_missing".to_string(),
                "missing_percent".to_string(),
            ],
            vec![
                column_col,
                missing_col,
                non_missing_col,
                missing_percent_col,
            ],
        )
    }

    /// Return rows whose full-row or selected-column key appears more than once.
    pub fn duplicate_rows(&self, cols: Option<&[ColRef]>) -> Result<DataFrame, String> {
        let key_indices = self.duplicate_key_indices(cols)?;
        let mut counts: Vec<(Vec<CellValue>, usize)> = Vec::new();
        for row in 0..self.nrows() {
            let key = self.row_key(row, &key_indices);
            if let Some((_, count)) = counts.iter_mut().find(|(seen, _)| *seen == key) {
                *count += 1;
            } else {
                counts.push((key, 1));
            }
        }

        let duplicate_rows: Vec<usize> = (0..self.nrows())
            .filter(|&row| {
                let key = self.row_key(row, &key_indices);
                counts
                    .iter()
                    .any(|(seen, count)| *count > 1 && *seen == key)
            })
            .collect();

        Ok(self.extract_rows(&duplicate_rows))
    }

    /// Return a new dataframe with ISO date year, month, and day columns appended.
    pub fn date_parts(&self, date_col: ColRef, prefix: Option<&str>) -> Result<DataFrame, String> {
        let ci = self.resolve_col(date_col)?;
        let prefix = prefix.unwrap_or("");
        let output_names = if prefix.is_empty() {
            ["year".to_string(), "month".to_string(), "day".to_string()]
        } else {
            [
                format!("{prefix}_year"),
                format!("{prefix}_month"),
                format!("{prefix}_day"),
            ]
        };

        let mut columns = self.columns().to_vec();
        for name in &output_names {
            if columns.contains(name) {
                return Err(format!("date_parts: column already exists: {name}"));
            }
            columns.push(name.clone());
        }

        let mut year_col = Vec::with_capacity(self.nrows());
        let mut month_col = Vec::with_capacity(self.nrows());
        let mut day_col = Vec::with_capacity(self.nrows());
        for cell in &self.raw_data()[ci] {
            if let Some((year, month, day)) = parse_iso_date_parts(cell) {
                year_col.push(CellValue::Number(year as f64));
                month_col.push(CellValue::Number(month as f64));
                day_col.push(CellValue::Number(day as f64));
            } else {
                year_col.push(CellValue::Nil);
                month_col.push(CellValue::Nil);
                day_col.push(CellValue::Nil);
            }
        }

        let mut data = self.raw_data().clone();
        data.push(year_col);
        data.push(month_col);
        data.push(day_col);
        Ok(DataFrame::from_raw(columns, data))
    }

    /// Resolve duplicate-key columns, defaulting to all dataframe columns.
    fn duplicate_key_indices(&self, cols: Option<&[ColRef]>) -> Result<Vec<usize>, String> {
        match cols {
            Some(selected) if !selected.is_empty() => selected
                .iter()
                .cloned()
                .map(|col| self.resolve_col(col))
                .collect(),
            _ => Ok((0..self.ncols()).collect()),
        }
    }

    /// Build one duplicate comparison key for a row.
    fn row_key(&self, row: usize, key_indices: &[usize]) -> Vec<CellValue> {
        key_indices
            .iter()
            .map(|&ci| self.raw_data()[ci][row].clone())
            .collect()
    }
}

/// Parse a simple `yyyy-mm-dd` text cell into numeric date parts.
fn parse_iso_date_parts(cell: &CellValue) -> Option<(i32, u32, u32)> {
    let text = cell.as_text()?;
    let bytes = text.as_bytes();
    if bytes.len() != 10 || bytes[4] != b'-' || bytes[7] != b'-' {
        return None;
    }
    if !bytes[0..4].iter().all(|b| b.is_ascii_digit())
        || !bytes[5..7].iter().all(|b| b.is_ascii_digit())
        || !bytes[8..10].iter().all(|b| b.is_ascii_digit())
    {
        return None;
    }
    let year = text[0..4].parse::<i32>().ok()?;
    let month = text[5..7].parse::<u32>().ok()?;
    let day = text[8..10].parse::<u32>().ok()?;
    if !(1..=12).contains(&month) || !(1..=31).contains(&day) {
        return None;
    }
    Some((year, month, day))
}
