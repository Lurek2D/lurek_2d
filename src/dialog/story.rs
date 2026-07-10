//! Safe Ink-subset story compiler and runtime for `lurek.dialog.compileStory`.

use std::collections::{HashMap, HashSet};

#[derive(Clone, Debug, PartialEq)]
/// Runtime value stored by the safe story interpreter for variables and expression results.
pub enum StoryValue {
    Nil,
    Bool(bool),
    Number(f64),
    String(String),
}

impl StoryValue {
    /// Convert this story value to the interpreter's truthiness rule.
    pub fn as_bool(&self) -> bool {
        match self {
            Self::Nil => false,
            Self::Bool(value) => *value,
            Self::Number(value) => *value != 0.0,
            Self::String(value) => !value.is_empty(),
        }
    }
}

impl std::fmt::Display for StoryValue {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::Nil => Ok(()),
            Self::Bool(value) => write!(f, "{value}"),
            Self::Number(value) => write!(f, "{value}"),
            Self::String(value) => write!(f, "{value}"),
        }
    }
}

#[derive(Clone, Debug)]
enum StoryNode {
    Line {
        text: String,
        tags: Vec<String>,
    },
    Choice {
        text: String,
        tags: Vec<String>,
        sticky: bool,
        cond: Option<String>,
        target: Option<String>,
    },
    Divert(String),
    Set {
        name: String,
        expr: String,
    },
    Tag(String),
}

#[derive(Clone, Debug)]
struct StoryProgram {
    knots: HashMap<String, Vec<StoryNode>>,
    order: Vec<String>,
    decls: Vec<(String, String)>,
}

#[derive(Clone, Debug)]
/// One currently available player choice emitted by a compiled dialog story.
pub struct StoryChoice {
    pub text: String,
    pub tags: Vec<String>,
    pub index: usize,
    target: Option<String>,
    node_key: String,
    sticky: bool,
}

#[derive(Clone, Debug)]
/// Compiled safe Ink-subset story plus mutable runtime state for one playthrough.
pub struct DialogStory {
    program: StoryProgram,
    vars: HashMap<String, StoryValue>,
    visits: HashMap<String, u32>,
    chosen_once: HashSet<String>,
    knot: Option<String>,
    pc: usize,
    ended: bool,
    pending: Vec<StoryChoice>,
}

impl DialogStory {
    /// Compile safe Ink-subset source text into a story runtime.
    pub fn compile(source: &str) -> Result<Self, String> {
        let program = compile_program(source)?;
        let mut story = Self {
            program,
            vars: HashMap::new(),
            visits: HashMap::new(),
            chosen_once: HashSet::new(),
            knot: None,
            pc: 0,
            ended: false,
            pending: Vec::new(),
        };
        story.apply_decls();
        Ok(story)
    }

    /// Start playback at a named knot, or at the default entry knot.
    pub fn start(&mut self, knot: Option<String>) -> Result<(), String> {
        let target = knot
            .or_else(|| {
                if self.program.knots.contains_key("START") {
                    Some("START".to_string())
                } else if self.program.knots.contains_key("ENTRY") {
                    Some("ENTRY".to_string())
                } else {
                    self.program.order.first().cloned()
                }
            })
            .ok_or_else(|| "dialog story has no knots".to_string())?;
        self.goto_knot(target)
    }

    /// Return whether the story can currently emit another line.
    pub fn can_continue(&self) -> bool {
        !self.ended && self.knot.is_some() && self.pending.is_empty()
    }

    /// Advance until one line or tag is emitted, a choice is reached, or the story ends.
    pub fn continue_line(&mut self) -> Result<Option<(String, Vec<String>)>, String> {
        if self.ended || !self.pending.is_empty() {
            return Ok(None);
        }
        loop {
            let Some(knot) = self.knot.clone() else {
                return Ok(None);
            };
            let nodes = self
                .program
                .knots
                .get(&knot)
                .ok_or_else(|| format!("unknown knot '{knot}'"))?;
            if self.pc >= nodes.len() {
                self.ended = true;
                return Ok(None);
            }
            let node = nodes[self.pc].clone();
            self.pc += 1;
            match node {
                StoryNode::Line { text, tags } => {
                    return Ok(Some((self.substitute(&text)?, tags)));
                }
                StoryNode::Tag(tag) => return Ok(Some(("".to_string(), vec![tag]))),
                StoryNode::Set { name, expr } => {
                    let value = self.eval(&expr)?;
                    self.vars.insert(name, value);
                }
                StoryNode::Divert(target) => {
                    if is_end_target(&target) {
                        self.ended = true;
                        return Ok(None);
                    }
                    self.goto_knot(target)?;
                }
                StoryNode::Choice { .. } => {
                    self.pc -= 1;
                    self.gather_choices()?;
                    return Ok(None);
                }
            }
        }
    }

    /// Continue until blocked or ended and join emitted non-empty lines with `sep`.
    pub fn continue_all(&mut self, sep: &str) -> Result<String, String> {
        let mut lines = Vec::new();
        while let Some((line, _)) = self.continue_line()? {
            if !line.is_empty() {
                lines.push(line);
            }
        }
        Ok(lines.join(sep))
    }

    /// Return the currently available choices, gathering them if needed.
    pub fn choices(&mut self) -> Result<Vec<StoryChoice>, String> {
        if self.pending.is_empty() && !self.ended {
            self.gather_choices()?;
        }
        Ok(self.pending.clone())
    }

    /// Select a one-based choice index and continue at its target or next node.
    pub fn choose(&mut self, index: usize) -> Result<(), String> {
        if self.pending.is_empty() {
            self.gather_choices()?;
        }
        let Some(choice) = self.pending.iter().find(|c| c.index == index).cloned() else {
            return Err(format!("invalid story choice index {index}"));
        };
        if !choice.sticky {
            self.chosen_once.insert(choice.node_key);
        }
        self.pending.clear();
        if let Some(target) = choice.target {
            if is_end_target(&target) {
                self.ended = true;
            } else {
                self.goto_knot(target)?;
            }
        } else {
            self.pc += 1;
        }
        Ok(())
    }

    /// Jump to a named knot and reset the program counter for that knot.
    pub fn goto_knot(&mut self, name: String) -> Result<(), String> {
        if !self.program.knots.contains_key(&name) {
            return Err(format!("unknown story knot '{name}'"));
        }
        *self.visits.entry(name.clone()).or_insert(0) += 1;
        self.knot = Some(name);
        self.pc = 0;
        self.ended = false;
        self.pending.clear();
        Ok(())
    }

    /// Set or replace one story variable.
    pub fn set_variable(&mut self, name: String, value: StoryValue) {
        self.vars.insert(name, value);
    }

    /// Return one story variable, or `StoryValue::Nil` when absent.
    pub fn get_variable(&self, name: &str) -> StoryValue {
        self.vars.get(name).cloned().unwrap_or(StoryValue::Nil)
    }

    /// Return sorted variable names currently stored by the runtime.
    pub fn variable_names(&self) -> Vec<String> {
        let mut names: Vec<String> = self.vars.keys().cloned().collect();
        names.sort();
        names
    }

    /// Return how many times a knot has been entered in this runtime.
    pub fn visit_count(&self, knot: &str) -> u32 {
        self.visits.get(knot).copied().unwrap_or(0)
    }

    /// Capture mutable story runtime state for later restoration.
    pub fn snapshot_state(&self) -> StorySnapshot {
        StorySnapshot {
            vars: self.vars.clone(),
            visits: self.visits.clone(),
            chosen_once: self.chosen_once.clone(),
            knot: self.knot.clone(),
            pc: self.pc,
            ended: self.ended,
        }
    }

    /// Replace mutable story runtime state from a previous snapshot.
    pub fn restore_state(&mut self, snapshot: StorySnapshot) {
        self.vars = snapshot.vars;
        self.visits = snapshot.visits;
        self.chosen_once = snapshot.chosen_once;
        self.knot = snapshot.knot;
        self.pc = snapshot.pc;
        self.ended = snapshot.ended;
        self.pending.clear();
    }

    fn apply_decls(&mut self) {
        for (name, expr) in self.program.decls.clone() {
            let value = self.eval(&expr).unwrap_or(StoryValue::String(expr));
            self.vars.insert(name, value);
        }
    }

    fn gather_choices(&mut self) -> Result<(), String> {
        self.pending.clear();
        let Some(knot) = self.knot.clone() else {
            return Ok(());
        };
        let Some(nodes) = self.program.knots.get(&knot) else {
            return Ok(());
        };
        let mut cursor = self.pc;
        let mut index = 1;
        while let Some(StoryNode::Choice {
            text,
            tags,
            sticky,
            cond,
            target,
        }) = nodes.get(cursor).cloned()
        {
            let node_key = format!("{knot}:{cursor}");
            let available = sticky
                || !self.chosen_once.contains(&node_key)
                    && cond
                        .as_ref()
                        .map(|expr| self.eval(expr).map(|v| v.as_bool()))
                        .transpose()?
                        .unwrap_or(true);
            if available {
                self.pending.push(StoryChoice {
                    text: self.substitute(&text)?,
                    tags,
                    index,
                    target,
                    node_key,
                    sticky,
                });
                index += 1;
            }
            cursor += 1;
        }
        Ok(())
    }

    fn substitute(&self, text: &str) -> Result<String, String> {
        let mut out = String::new();
        let mut rest = text;
        while let Some(open) = rest.find('{') {
            let (before, after_open) = rest.split_at(open);
            out.push_str(before);
            let Some(close) = after_open.find('}') else {
                out.push_str(after_open);
                return Ok(out);
            };
            let expr = after_open[1..close].trim();
            out.push_str(&self.eval(expr)?.to_string());
            rest = &after_open[close + 1..];
        }
        out.push_str(rest);
        Ok(out)
    }

    fn eval(&self, expr: &str) -> Result<StoryValue, String> {
        eval_expr(expr.trim(), &self.vars, &self.visits)
    }
}

#[derive(Clone, Debug)]
/// Serializable checkpoint for restoring a `DialogStory` to an earlier runtime position.
pub struct StorySnapshot {
    pub vars: HashMap<String, StoryValue>,
    pub visits: HashMap<String, u32>,
    pub chosen_once: HashSet<String>,
    pub knot: Option<String>,
    pub pc: usize,
    pub ended: bool,
}

fn compile_program(source: &str) -> Result<StoryProgram, String> {
    let mut knots: HashMap<String, Vec<StoryNode>> = HashMap::new();
    let mut order = Vec::new();
    let mut decls = Vec::new();
    let mut current: Option<String> = None;
    for (line_number, raw) in source.lines().enumerate() {
        let line = raw.split("//").next().unwrap_or("").trim();
        if line.is_empty() {
            continue;
        }
        if line.starts_with("===") {
            let name = line.trim_matches('=').trim().to_string();
            if name.is_empty() {
                return Err(format!("line {}: empty knot name", line_number + 1));
            }
            if !knots.contains_key(&name) {
                knots.insert(name.clone(), Vec::new());
                order.push(name.clone());
            }
            current = Some(name);
            continue;
        }
        if let Some(expr) = line.strip_prefix("VAR ") {
            let Some((name, value)) = expr.split_once('=') else {
                return Err(format!("line {}: malformed VAR", line_number + 1));
            };
            decls.push((name.trim().to_string(), value.trim().to_string()));
            continue;
        }
        let knot = current.clone().unwrap_or_else(|| {
            if !knots.contains_key("START") {
                knots.insert("START".to_string(), Vec::new());
                order.push("START".to_string());
            }
            current = Some("START".to_string());
            "START".to_string()
        });
        let nodes = knots.get_mut(&knot).unwrap();
        if let Some(target) = line.strip_prefix("->") {
            nodes.push(StoryNode::Divert(target.trim().to_string()));
        } else if let Some(expr) = line.strip_prefix('~') {
            let Some((name, value)) = expr.split_once('=') else {
                return Err(format!("line {}: malformed assignment", line_number + 1));
            };
            nodes.push(StoryNode::Set {
                name: name.trim().to_string(),
                expr: value.trim().to_string(),
            });
        } else if line.starts_with('*') || line.starts_with('+') {
            let sticky = line.starts_with('+');
            let mut body = line[1..].trim().to_string();
            let cond = if body.starts_with('{') {
                if let Some(close) = body.find('}') {
                    let expr = body[1..close].trim().to_string();
                    body = body[close + 1..].trim().to_string();
                    Some(expr)
                } else {
                    None
                }
            } else {
                None
            };
            let target = if let Some((left, right)) = body.clone().split_once('|') {
                body = left.trim().to_string();
                right
                    .trim()
                    .strip_prefix("->")
                    .map(|v| v.trim().to_string())
            } else {
                None
            };
            let (text, tags) = split_tags(&body);
            nodes.push(StoryNode::Choice {
                text,
                tags,
                sticky,
                cond,
                target,
            });
        } else if let Some(tag) = line.strip_prefix('#') {
            nodes.push(StoryNode::Tag(tag.trim().to_string()));
        } else {
            let (text, tags) = split_tags(line);
            nodes.push(StoryNode::Line { text, tags });
        }
    }
    if knots.is_empty() {
        return Err("dialog story has no knots".to_string());
    }
    Ok(StoryProgram {
        knots,
        order,
        decls,
    })
}

fn split_tags(line: &str) -> (String, Vec<String>) {
    let mut text = Vec::new();
    let mut tags = Vec::new();
    for part in line.split_whitespace() {
        if let Some(tag) = part.strip_prefix('#') {
            tags.push(tag.to_string());
        } else {
            text.push(part);
        }
    }
    (text.join(" "), tags)
}

fn eval_expr(
    expr: &str,
    vars: &HashMap<String, StoryValue>,
    visits: &HashMap<String, u32>,
) -> Result<StoryValue, String> {
    for op in ["==", "!=", "~=", ">=", "<=", ">", "<"] {
        if let Some((left, right)) = expr.split_once(op) {
            let left = eval_atom(left.trim(), vars, visits)?;
            let right = eval_atom(right.trim(), vars, visits)?;
            let result = match op {
                "==" => left == right,
                "!=" | "~=" => left != right,
                ">" => compare_values(&left, &right)? > 0,
                "<" => compare_values(&left, &right)? < 0,
                ">=" => compare_values(&left, &right)? >= 0,
                "<=" => compare_values(&left, &right)? <= 0,
                _ => false,
            };
            return Ok(StoryValue::Bool(result));
        }
    }
    eval_atom(expr, vars, visits)
}

fn eval_atom(
    expr: &str,
    vars: &HashMap<String, StoryValue>,
    visits: &HashMap<String, u32>,
) -> Result<StoryValue, String> {
    if expr.eq_ignore_ascii_case("true") {
        return Ok(StoryValue::Bool(true));
    }
    if expr.eq_ignore_ascii_case("false") {
        return Ok(StoryValue::Bool(false));
    }
    if let Ok(number) = expr.parse::<f64>() {
        return Ok(StoryValue::Number(number));
    }
    if (expr.starts_with('"') && expr.ends_with('"'))
        || (expr.starts_with('\'') && expr.ends_with('\''))
    {
        return Ok(StoryValue::String(expr[1..expr.len() - 1].to_string()));
    }
    if let Some(name) = expr
        .strip_prefix("visitCount(")
        .and_then(|v| v.strip_suffix(')'))
    {
        let name = name.trim().trim_matches('"').trim_matches('\'');
        return Ok(StoryValue::Number(
            visits.get(name).copied().unwrap_or(0) as f64
        ));
    }
    Ok(vars.get(expr).cloned().unwrap_or(StoryValue::Nil))
}

fn compare_values(left: &StoryValue, right: &StoryValue) -> Result<i8, String> {
    match (left, right) {
        (StoryValue::Number(a), StoryValue::Number(b)) => Ok(ordering_to_i8(
            a.partial_cmp(b).unwrap_or(std::cmp::Ordering::Equal),
        )),
        (StoryValue::String(a), StoryValue::String(b)) => Ok(ordering_to_i8(a.cmp(b))),
        _ => Err("cannot compare non-matching story values".to_string()),
    }
}

fn ordering_to_i8(ordering: std::cmp::Ordering) -> i8 {
    match ordering {
        std::cmp::Ordering::Less => -1,
        std::cmp::Ordering::Equal => 0,
        std::cmp::Ordering::Greater => 1,
    }
}

fn is_end_target(target: &str) -> bool {
    target.eq_ignore_ascii_case("END") || target.eq_ignore_ascii_case("DONE")
}
