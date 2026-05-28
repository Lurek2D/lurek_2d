//! Mod API schema: JSON-serialisable description of every `lurek.*` function signature.
//!
//! - Data types: `FieldDef`, `MethodDef`, `AssetRequirement`.
//! - Enum: `FieldType`.

/// Field type variant for an API schema.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum FieldType {
    String,
    Integer,
    Float,
    Boolean,
    Table,
    Function,
    Userdata(String),
    Any,
    Optional(Box<FieldType>),
    Array(Box<FieldType>),
}

impl FieldType {
    /// Parse a `FieldType` from a string name; supports `?` optional and `[]` array suffixes.
    pub fn from_name(s: &str) -> Self {
        match s.to_lowercase().as_str() {
            "string" | "str" => Self::String,
            "integer" | "int" => Self::Integer,
            "float" | "number" => Self::Float,
            "boolean" | "bool" => Self::Boolean,
            "table" => Self::Table,
            "function" | "fn" => Self::Function,
            "any" => Self::Any,
            other => {
                if let Some(inner) = other.strip_suffix("?") {
                    Self::Optional(Box::new(Self::from_name(inner)))
                } else if let Some(inner) = other.strip_suffix("[]") {
                    Self::Array(Box::new(Self::from_name(inner)))
                } else {
                    Self::Userdata(other.to_string())
                }
            }
        }
    }

    /// Return the canonical string representation of this field type.
    pub fn as_str(&self) -> String {
        match self {
            Self::String => "string".to_string(),
            Self::Integer => "integer".to_string(),
            Self::Float => "float".to_string(),
            Self::Boolean => "boolean".to_string(),
            Self::Table => "table".to_string(),
            Self::Function => "function".to_string(),
            Self::Any => "any".to_string(),
            Self::Userdata(name) => name.clone(),
            Self::Optional(inner) => format!("{}?", inner.as_str()),
            Self::Array(inner) => format!("{}[]", inner.as_str()),
        }
    }
}

/// A single field definition in an API schema.
#[derive(Debug, Clone)]
pub struct FieldDef {
    /// Unique identifier name.
    pub name: String,
    /// Field type.
    pub field_type: FieldType,
    /// Required.
    pub required: bool,
    /// Default value.
    pub default_value: Option<String>,
    /// Human-readable description.
    pub description: String,
}

impl FieldDef {
    /// Create a required field definition with the given name and type.
    pub fn new(name: impl Into<String>, field_type: FieldType) -> Self {
        Self {
            name: name.into(),
            field_type,
            required: true,
            default_value: None,
            description: String::new(),
        }
    }

    /// Mark this field as optional (not required).
    pub fn optional(mut self) -> Self {
        self.required = false;
        self
    }

    /// Set the default value string and mark the field as optional.
    pub fn with_default(mut self, val: impl Into<String>) -> Self {
        self.default_value = Some(val.into());
        self.required = false;
        self
    }

    /// Attach a human-readable description to this field definition.
    pub fn with_description(mut self, desc: impl Into<String>) -> Self {
        self.description = desc.into();
        self
    }
}

/// A method definition in an API schema.
#[derive(Debug, Clone)]
pub struct MethodDef {
    /// Unique identifier name.
    pub name: String,
    /// Params.
    pub params: Vec<FieldDef>,
    /// Returns.
    pub returns: Option<FieldType>,
    /// Human-readable description.
    pub description: String,
}

impl MethodDef {
    /// Create a method definition with the given name and no parameters or return type.
    pub fn new(name: impl Into<String>) -> Self {
        Self {
            name: name.into(),
            params: Vec::new(),
            returns: None,
            description: String::new(),
        }
    }

    /// Add a parameter field to this method definition.
    pub fn with_param(mut self, param: FieldDef) -> Self {
        self.params.push(param);
        self
    }

    /// Set the return type for this method.
    pub fn with_return(mut self, ret: FieldType) -> Self {
        self.returns = Some(ret);
        self
    }
}

/// Asset requirement declared by an API type.
#[derive(Debug, Clone)]
pub struct AssetRequirement {
    /// Field name.
    pub field_name: String,
    /// Asset type.
    pub asset_type: String,
    /// Must exist.
    pub must_exist: bool,
}
