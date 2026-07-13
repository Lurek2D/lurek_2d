//! Owns derived-value validation, parsing, AST evaluation, and bounded result normalization rules.
//! Exposes the store entrypoints that read or explain derived values through one safe formula pipeline.
//! Resolves counter, attribute, resource, level, and XP inputs into deterministic numeric maps.
//! Stores the expression token and AST shapes used by validation, explanation, and runtime evaluation.
//! Rejects malformed expressions, unsupported helpers, and non-finite results before they reach APIs.
//! Keeps parser and evaluator internals out of `store.rs` so numeric derivation has a focused owner.
//! Avoids Lua eval, runtime code execution, and rendering concerns so formulas stay headless and safe.
//! Open this file when changing derived expressions, parser limits, supported math helpers, or payloads.
use super::*;

impl ProgressionStore {
    /// Evaluate one derived value for a profile.
    pub fn get_derived_value(&self, profile_id: &str, id: &str) -> Result<f64, ProgressionError> {
        let definition = self.derived_value_definitions.get(id).ok_or_else(|| {
            ProgressionError::MissingDefinition {
                kind: "derived_value",
                id: id.to_string(),
            }
        })?;
        let parsed = parse_formula_expression(&definition.expression)?;
        let inputs = self.resolve_derived_inputs(profile_id, definition)?;
        self.evaluate_derived_formula(definition, &parsed, &inputs)
    }

    /// Explain one derived value evaluation with resolved inputs and bounded result.
    pub fn explain_derived_value(
        &self,
        profile_id: &str,
        id: &str,
    ) -> Result<JsonValue, ProgressionError> {
        let definition = self.derived_value_definitions.get(id).ok_or_else(|| {
            ProgressionError::MissingDefinition {
                kind: "derived_value",
                id: id.to_string(),
            }
        })?;
        let parsed = parse_formula_expression(&definition.expression)?;
        let inputs = self.resolve_derived_inputs(profile_id, definition)?;
        let raw = evaluate_formula_ast(&parsed, &inputs)?;
        let value = apply_derived_result_policy(definition, raw)?;
        Ok(json!({
            "id": id,
            "expression": definition.expression,
            "inputs": inputs,
            "raw": raw,
            "value": value,
            "min": definition.min,
            "max": definition.max,
            "round": definition.round,
        }))
    }

    /// Validate all authored derived values.
    pub fn validate_derived_values(&self) -> JsonValue {
        let mut errors = Vec::new();
        for (id, definition) in &self.derived_value_definitions {
            if let Err(err) = self.validate_derived_value_definition(id, definition) {
                errors.push(err.to_string());
            }
        }
        json!({
            "ok": errors.is_empty(),
            "errors": errors,
        })
    }

    /// Resolve one derived-value definition into deterministic numeric inputs for a profile.
    pub(crate) fn resolve_derived_inputs(
        &self,
        profile_id: &str,
        definition: &DerivedValueDefinition,
    ) -> Result<BTreeMap<String, f64>, ProgressionError> {
        let mut resolved = BTreeMap::new();
        for (name, input) in &definition.inputs {
            let value = match input {
                DerivedValueInput::Counter { counter_id } => {
                    self.get_counter(profile_id, counter_id)?
                }
                DerivedValueInput::Attribute { attribute_id, mode } => {
                    self.get_attribute(profile_id, attribute_id, *mode)?
                }
                DerivedValueInput::Resource { resource_id } => {
                    self.get_resource_value(profile_id, resource_id)?
                }
                DerivedValueInput::Level { track_id } => {
                    self.get_level(profile_id, track_id)? as f64
                }
                DerivedValueInput::Experience { track_id } => self
                    .get_experience(profile_id, track_id)?
                    .get("experience")
                    .and_then(JsonValue::as_f64)
                    .unwrap_or(0.0),
            };
            resolved.insert(name.clone(), value);
        }
        Ok(resolved)
    }

    /// Evaluate one parsed formula with resolved inputs and apply the authored result policy.
    pub(crate) fn evaluate_derived_formula(
        &self,
        definition: &DerivedValueDefinition,
        parsed: &FormulaExpr,
        inputs: &BTreeMap<String, f64>,
    ) -> Result<f64, ProgressionError> {
        let raw = evaluate_formula_ast(parsed, inputs)?;
        apply_derived_result_policy(definition, raw)
    }
}

/// Token emitted by the bounded derived-value formula tokenizer.
#[derive(Debug, Clone)]
pub(crate) enum FormulaToken {
    Number(f64),
    Ident(String),
    Plus,
    Minus,
    Star,
    Slash,
    LParen,
    RParen,
    Comma,
}

/// AST node used by derived-value validation, explanation, and evaluation.
#[derive(Debug, Clone)]
pub(crate) enum FormulaExpr {
    Number(f64),
    Variable(String),
    UnaryMinus(Box<FormulaExpr>),
    Binary {
        op: char,
        left: Box<FormulaExpr>,
        right: Box<FormulaExpr>,
    },
    Function {
        name: String,
        args: Vec<FormulaExpr>,
    },
}

/// Parse one authored derived-value expression into a bounded AST.
pub(crate) fn parse_formula_expression(expression: &str) -> Result<FormulaExpr, ProgressionError> {
    let tokens = tokenize_formula(expression)?;
    let mut parser = FormulaParser::new(tokens);
    let parsed = parser.parse_expression()?;
    if parser.peek().is_some() {
        return Err(ProgressionError::InvalidValue(
            "derived value expression has trailing tokens".to_string(),
        ));
    }
    Ok(parsed)
}

fn tokenize_formula(expression: &str) -> Result<Vec<FormulaToken>, ProgressionError> {
    let mut tokens = Vec::new();
    let mut chars = expression.chars().peekable();
    while let Some(&ch) = chars.peek() {
        match ch {
            ' ' | '\t' | '\n' | '\r' => {
                chars.next();
            }
            '+' => {
                tokens.push(FormulaToken::Plus);
                chars.next();
            }
            '-' => {
                tokens.push(FormulaToken::Minus);
                chars.next();
            }
            '*' => {
                tokens.push(FormulaToken::Star);
                chars.next();
            }
            '/' => {
                tokens.push(FormulaToken::Slash);
                chars.next();
            }
            '(' => {
                tokens.push(FormulaToken::LParen);
                chars.next();
            }
            ')' => {
                tokens.push(FormulaToken::RParen);
                chars.next();
            }
            ',' => {
                tokens.push(FormulaToken::Comma);
                chars.next();
            }
            '0'..='9' | '.' => {
                let mut text = String::new();
                while let Some(&digit) = chars.peek() {
                    if digit.is_ascii_digit() || digit == '.' {
                        text.push(digit);
                        chars.next();
                    } else {
                        break;
                    }
                }
                let value = text.parse::<f64>().map_err(|_| {
                    ProgressionError::InvalidValue(format!("invalid number literal '{}'", text))
                })?;
                tokens.push(FormulaToken::Number(value));
            }
            'a'..='z' | 'A'..='Z' | '_' => {
                let mut text = String::new();
                while let Some(&digit) = chars.peek() {
                    if digit.is_ascii_alphanumeric() || digit == '_' {
                        text.push(digit);
                        chars.next();
                    } else {
                        break;
                    }
                }
                tokens.push(FormulaToken::Ident(text));
            }
            other => {
                return Err(ProgressionError::InvalidValue(format!(
                    "unsupported expression character '{}'",
                    other
                )))
            }
        }
    }
    Ok(tokens)
}

struct FormulaParser {
    tokens: Vec<FormulaToken>,
    index: usize,
}

impl FormulaParser {
    fn new(tokens: Vec<FormulaToken>) -> Self {
        Self { tokens, index: 0 }
    }

    fn peek(&self) -> Option<&FormulaToken> {
        self.tokens.get(self.index)
    }

    fn next(&mut self) -> Option<FormulaToken> {
        let token = self.tokens.get(self.index).cloned();
        if token.is_some() {
            self.index += 1;
        }
        token
    }

    fn parse_expression(&mut self) -> Result<FormulaExpr, ProgressionError> {
        let mut expr = self.parse_term()?;
        while let Some(token) = self.peek() {
            match token {
                FormulaToken::Plus | FormulaToken::Minus => {
                    let op = match self.next() {
                        Some(FormulaToken::Plus) => '+',
                        Some(FormulaToken::Minus) => '-',
                        _ => unreachable!(),
                    };
                    let right = self.parse_term()?;
                    expr = FormulaExpr::Binary {
                        op,
                        left: Box::new(expr),
                        right: Box::new(right),
                    };
                }
                _ => break,
            }
        }
        Ok(expr)
    }

    fn parse_term(&mut self) -> Result<FormulaExpr, ProgressionError> {
        let mut expr = self.parse_factor()?;
        while let Some(token) = self.peek() {
            match token {
                FormulaToken::Star | FormulaToken::Slash => {
                    let op = match self.next() {
                        Some(FormulaToken::Star) => '*',
                        Some(FormulaToken::Slash) => '/',
                        _ => unreachable!(),
                    };
                    let right = self.parse_factor()?;
                    expr = FormulaExpr::Binary {
                        op,
                        left: Box::new(expr),
                        right: Box::new(right),
                    };
                }
                _ => break,
            }
        }
        Ok(expr)
    }

    fn parse_factor(&mut self) -> Result<FormulaExpr, ProgressionError> {
        match self.next() {
            Some(FormulaToken::Number(value)) => Ok(FormulaExpr::Number(value)),
            Some(FormulaToken::Ident(name)) => {
                if matches!(self.peek(), Some(FormulaToken::LParen)) {
                    self.next();
                    let mut args = Vec::new();
                    if !matches!(self.peek(), Some(FormulaToken::RParen)) {
                        loop {
                            args.push(self.parse_expression()?);
                            if matches!(self.peek(), Some(FormulaToken::Comma)) {
                                self.next();
                                continue;
                            }
                            break;
                        }
                    }
                    match self.next() {
                        Some(FormulaToken::RParen) => Ok(FormulaExpr::Function { name, args }),
                        _ => Err(ProgressionError::InvalidValue(
                            "expected ')' after function call".to_string(),
                        )),
                    }
                } else {
                    Ok(FormulaExpr::Variable(name))
                }
            }
            Some(FormulaToken::Minus) => Ok(FormulaExpr::UnaryMinus(Box::new(
                self.parse_factor()?,
            ))),
            Some(FormulaToken::LParen) => {
                let expr = self.parse_expression()?;
                match self.next() {
                    Some(FormulaToken::RParen) => Ok(expr),
                    _ => Err(ProgressionError::InvalidValue(
                        "expected ')' to close grouped expression".to_string(),
                    )),
                }
            }
            Some(other) => Err(ProgressionError::InvalidValue(format!(
                "unexpected formula token {:?}",
                other
            ))),
            None => Err(ProgressionError::InvalidValue(
                "unexpected end of derived value expression".to_string(),
            )),
        }
    }
}

/// Evaluate one parsed formula AST against a resolved input map.
pub(crate) fn evaluate_formula_ast(
    expr: &FormulaExpr,
    values: &BTreeMap<String, f64>,
) -> Result<f64, ProgressionError> {
    let result = match expr {
        FormulaExpr::Number(value) => *value,
        FormulaExpr::Variable(name) => values.get(name).copied().ok_or_else(|| {
            ProgressionError::InvalidValue(format!("missing derived value input '{}'", name))
        })?,
        FormulaExpr::UnaryMinus(child) => -evaluate_formula_ast(child, values)?,
        FormulaExpr::Binary { op, left, right } => {
            let left = evaluate_formula_ast(left, values)?;
            let right = evaluate_formula_ast(right, values)?;
            match op {
                '+' => left + right,
                '-' => left - right,
                '*' => left * right,
                '/' => {
                    if right.abs() <= f64::EPSILON {
                        return Err(ProgressionError::InvalidValue(
                            "derived value division by zero".to_string(),
                        ));
                    }
                    left / right
                }
                _ => {
                    return Err(ProgressionError::InvalidValue(format!(
                        "unsupported formula operator '{}'",
                        op
                    )))
                }
            }
        }
        FormulaExpr::Function { name, args } => evaluate_formula_function(name, args, values)?,
    };
    ensure_finite(result, "derived value result")?;
    Ok(result)
}

fn evaluate_formula_function(
    name: &str,
    args: &[FormulaExpr],
    values: &BTreeMap<String, f64>,
) -> Result<f64, ProgressionError> {
    match name {
        "min" => {
            if args.len() < 2 {
                return Err(ProgressionError::InvalidValue(
                    "min() expects at least 2 arguments".to_string(),
                ));
            }
            let mut best = f64::INFINITY;
            for arg in args {
                best = best.min(evaluate_formula_ast(arg, values)?);
            }
            Ok(best)
        }
        "max" => {
            if args.len() < 2 {
                return Err(ProgressionError::InvalidValue(
                    "max() expects at least 2 arguments".to_string(),
                ));
            }
            let mut best = f64::NEG_INFINITY;
            for arg in args {
                best = best.max(evaluate_formula_ast(arg, values)?);
            }
            Ok(best)
        }
        "clamp" => {
            if args.len() != 3 {
                return Err(ProgressionError::InvalidValue(
                    "clamp() expects 3 arguments".to_string(),
                ));
            }
            let value = evaluate_formula_ast(&args[0], values)?;
            let min = evaluate_formula_ast(&args[1], values)?;
            let max = evaluate_formula_ast(&args[2], values)?;
            Ok(value.clamp(min, max))
        }
        "abs" | "floor" | "ceil" | "round" => {
            if args.len() != 1 {
                return Err(ProgressionError::InvalidValue(format!(
                    "{}() expects 1 argument",
                    name
                )));
            }
            let value = evaluate_formula_ast(&args[0], values)?;
            Ok(match name {
                "abs" => value.abs(),
                "floor" => value.floor(),
                "ceil" => value.ceil(),
                "round" => value.round(),
                _ => unreachable!(),
            })
        }
        _ => Err(ProgressionError::InvalidValue(format!(
            "unsupported formula function '{}'",
            name
        ))),
    }
}

/// Apply authored min, max, and rounding policy to one raw derived-value result.
pub(crate) fn apply_derived_result_policy(
    definition: &DerivedValueDefinition,
    raw: f64,
) -> Result<f64, ProgressionError> {
    let mut value = raw;
    if let Some(min) = definition.min {
        value = value.max(min);
    }
    if let Some(max) = definition.max {
        value = value.min(max);
    }
    if let Some(round) = &definition.round {
        value = match round.as_str() {
            "floor" => value.floor(),
            "ceil" => value.ceil(),
            "round" => value.round(),
            other => {
                return Err(ProgressionError::InvalidValue(format!(
                    "unsupported derived round mode '{}'",
                    other
                )))
            }
        };
    }
    ensure_finite(value, "derived value final result")?;
    Ok(value)
}
