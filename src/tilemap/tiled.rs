//! Bounded, format-neutral Tiled object-map import.
//!
//! This owner understands TMX XML and Tiled JSON syntax but does not assign
//! gameplay meaning to object layers. Province import consumes the normalized
//! objects exposed here and applies its own layer/property contract.

use super::limits::TileMapLimits;
use roxmltree::Node;
use serde_json::Value;
use std::collections::HashSet;
use std::fmt;

/// A typed custom property read from a Tiled object.
#[derive(Debug, Clone, PartialEq)]
pub enum TiledPropertyValue {
    /// Tiled string property.
    String(String),
    /// Tiled signed integer property.
    Int(i64),
    /// Tiled floating-point property.
    Float(f64),
    /// Tiled boolean property.
    Bool(bool),
    /// Tiled color property preserved as its source string.
    Color(String),
    /// Tiled file property preserved as its source path.
    File(String),
    /// Tiled object reference.
    Object(u32),
}

impl TiledPropertyValue {
    /// Return an integer only for an explicitly integer property.
    pub fn as_int(&self) -> Option<i64> {
        match self {
            Self::Int(value) => Some(*value),
            _ => None,
        }
    }
}

/// One point in a Tiled polygon, in object-local coordinates.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct TiledPoint {
    /// Local X coordinate in pixels.
    pub x: f64,
    /// Local Y coordinate in pixels.
    pub y: f64,
}

/// Shape attached to a Tiled object.
#[derive(Debug, Clone, PartialEq)]
pub enum TiledObjectShape {
    /// A point object.
    Point,
    /// A polygon whose points are relative to the object's position.
    Polygon(Vec<TiledPoint>),
    /// A shape this normalized importer does not interpret.
    Unsupported,
}

/// Normalized Tiled object data shared by TMX and JSON importers.
#[derive(Debug, Clone, PartialEq)]
pub struct TiledObject {
    /// Stable object ID from Tiled.
    pub id: u32,
    /// Object name.
    pub name: String,
    /// Object class/type name.
    pub class_name: String,
    /// Object position in map pixels.
    pub x: f64,
    /// Object position in map pixels.
    pub y: f64,
    /// Object rotation in degrees.
    pub rotation: f64,
    /// Object shape.
    pub shape: TiledObjectShape,
    /// Typed custom properties.
    pub properties: std::collections::HashMap<String, TiledPropertyValue>,
}

/// A named Tiled object layer.
#[derive(Debug, Clone, PartialEq)]
pub struct TiledObjectLayer {
    /// Layer name.
    pub name: String,
    /// Layer visibility.
    pub visible: bool,
    /// Layer pixel offset.
    pub offset_x: f64,
    /// Layer pixel offset.
    pub offset_y: f64,
    /// Objects in source order.
    pub objects: Vec<TiledObject>,
}

/// Format-neutral map returned by the bounded Tiled importers.
#[derive(Debug, Clone, PartialEq)]
pub struct TiledMap {
    /// Map width in tiles.
    pub width: u32,
    /// Map height in tiles.
    pub height: u32,
    /// Tile width in pixels.
    pub tile_width: u32,
    /// Tile height in pixels.
    pub tile_height: u32,
    /// Tiled orientation string.
    pub orientation: String,
    /// Whether this is an infinite map.
    pub infinite: bool,
    /// Object layers in source order.
    pub object_layers: Vec<TiledObjectLayer>,
}

/// Tiled import failure with a stable format-neutral message.
#[derive(Debug, Clone)]
pub struct TiledImportError {
    /// Error code used by callers and diagnostics.
    pub code: &'static str,
    /// Human-readable message.
    pub message: String,
}

impl TiledImportError {
    fn invalid(message: impl Into<String>) -> Self {
        Self {
            code: "tiled_invalid_content",
            message: message.into(),
        }
    }
}

impl fmt::Display for TiledImportError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}: {}", self.code, self.message)
    }
}

impl std::error::Error for TiledImportError {}

/// Parse a Tiled map by extension (`tmx`, `tmj`, or `json`).
pub fn load_tiled(
    text: &str,
    extension: &str,
    limits: &TileMapLimits,
) -> Result<TiledMap, TiledImportError> {
    limits
        .validate()
        .map_err(|error| TiledImportError::invalid(error.to_string()))?;
    if text.len() > limits.max_import_bytes {
        return Err(TiledImportError::invalid(format!(
            "Tiled input is {} bytes, maximum is {}",
            text.len(),
            limits.max_import_bytes
        )));
    }
    match extension
        .trim_start_matches('.')
        .to_ascii_lowercase()
        .as_str()
    {
        "tmx" => load_tiled_tmx(text, limits),
        "tmj" | "json" => load_tiled_json(text, limits),
        other => Err(TiledImportError::invalid(format!(
            "unsupported Tiled extension '{other}'"
        ))),
    }
}

/// Parse Tiled XML into the normalized object model.
pub fn load_tiled_tmx(text: &str, limits: &TileMapLimits) -> Result<TiledMap, TiledImportError> {
    let document = roxmltree::Document::parse(text)
        .map_err(|error| TiledImportError::invalid(format!("TMX XML parse error: {error}")))?;
    let map = document.root_element();
    if !map.has_tag_name("map") {
        return Err(TiledImportError::invalid("TMX is missing a <map> root"));
    }
    let width = attr_u32_xml(&map, "width")?;
    let height = attr_u32_xml(&map, "height")?;
    let tile_width = attr_u32_xml(&map, "tilewidth")?;
    let tile_height = attr_u32_xml(&map, "tileheight")?;
    if width == 0 || height == 0 || tile_width == 0 || tile_height == 0 {
        return Err(TiledImportError::invalid(
            "Tiled map dimensions and tile dimensions must be positive",
        ));
    }
    let orientation = map
        .attribute("orientation")
        .ok_or_else(|| TiledImportError::invalid("TMX map is missing the orientation attribute"))?;
    let mut layers = Vec::new();
    let mut total_objects = 0usize;
    let mut total_points = 0usize;
    let mut object_ids = HashSet::new();
    for layer in map
        .children()
        .filter(|node| node.has_tag_name("objectgroup"))
    {
        if layers.len() >= limits.max_layers {
            return Err(TiledImportError::invalid(
                "Tiled object-layer limit exceeded",
            ));
        }
        let name = layer.attribute("name").unwrap_or_default().to_string();
        let offset_x = attr_f64_xml(&layer, "offsetx")?.unwrap_or(0.0);
        let offset_y = attr_f64_xml(&layer, "offsety")?.unwrap_or(0.0);
        if !offset_x.is_finite() || !offset_y.is_finite() {
            return Err(TiledImportError::invalid(format!(
                "object layer '{name}' has non-finite offsets"
            )));
        }
        let mut objects = Vec::new();
        for object in layer.children().filter(|node| node.has_tag_name("object")) {
            check_object_limit(total_objects, limits, &name)?;
            let parsed = parse_xml_object(&object, limits, &mut total_points)?;
            if !object_ids.insert(parsed.id) {
                return Err(TiledImportError::invalid(format!(
                    "Tiled object id {} is duplicated",
                    parsed.id
                )));
            }
            objects.push(parsed);
            total_objects += 1;
        }
        layers.push(TiledObjectLayer {
            name,
            visible: attr_bool_xml(&layer, "visible")?.unwrap_or(true),
            offset_x,
            offset_y,
            objects,
        });
    }
    Ok(TiledMap {
        width,
        height,
        tile_width,
        tile_height,
        orientation: orientation.to_string(),
        infinite: attr_bool_xml(&map, "infinite")?.unwrap_or(false),
        object_layers: layers,
    })
}

/// Parse Tiled JSON into the normalized object model.
pub fn load_tiled_json(text: &str, limits: &TileMapLimits) -> Result<TiledMap, TiledImportError> {
    let root: Value = serde_json::from_str(text)
        .map_err(|error| TiledImportError::invalid(format!("Tiled JSON parse error: {error}")))?;
    let object = root
        .as_object()
        .ok_or_else(|| TiledImportError::invalid("Tiled JSON root must be an object"))?;
    let map_type = object
        .get("type")
        .and_then(Value::as_str)
        .ok_or_else(|| TiledImportError::invalid("Tiled JSON root type must be 'map'"))?;
    if map_type != "map" {
        return Err(TiledImportError::invalid(
            "Tiled JSON root type must be 'map'",
        ));
    }
    let width = json_u32(object.get("width"), "width")?;
    let height = json_u32(object.get("height"), "height")?;
    let tile_width = json_u32(object.get("tilewidth"), "tilewidth")?;
    let tile_height = json_u32(object.get("tileheight"), "tileheight")?;
    if width == 0 || height == 0 || tile_width == 0 || tile_height == 0 {
        return Err(TiledImportError::invalid(
            "Tiled map dimensions and tile dimensions must be positive",
        ));
    }
    let mut layers = Vec::new();
    let mut total_objects = 0usize;
    let mut total_points = 0usize;
    let mut object_ids = HashSet::new();
    let json_layers = object
        .get("layers")
        .and_then(Value::as_array)
        .ok_or_else(|| TiledImportError::invalid("Tiled JSON is missing layers"))?;
    for layer in json_layers {
        let layer_obj = layer
            .as_object()
            .ok_or_else(|| TiledImportError::invalid("Tiled JSON layer must be an object"))?;
        let layer_type = layer_obj
            .get("type")
            .and_then(Value::as_str)
            .ok_or_else(|| TiledImportError::invalid("Tiled JSON layer.type is required"))?;
        if layer_type != "objectgroup" {
            continue;
        }
        if layers.len() >= limits.max_layers {
            return Err(TiledImportError::invalid(
                "Tiled object-layer limit exceeded",
            ));
        }
        let name = layer_obj
            .get("name")
            .map(|value| {
                value.as_str().ok_or_else(|| {
                    TiledImportError::invalid("Tiled JSON object layer.name must be a string")
                })
            })
            .transpose()?
            .unwrap_or_default()
            .to_string();
        let offset_x = json_f64(layer_obj.get("offsetx"), "layer.offsetx")?.unwrap_or(0.0);
        let offset_y = json_f64(layer_obj.get("offsety"), "layer.offsety")?.unwrap_or(0.0);
        if !offset_x.is_finite() || !offset_y.is_finite() {
            return Err(TiledImportError::invalid(format!(
                "object layer '{name}' has non-finite offsets"
            )));
        }
        let mut objects = Vec::new();
        for value in layer_obj
            .get("objects")
            .and_then(Value::as_array)
            .ok_or_else(|| {
                TiledImportError::invalid(format!("object layer '{name}' is missing objects"))
            })?
        {
            check_object_limit(total_objects, limits, &name)?;
            let parsed = parse_json_object(value, limits, &mut total_points)?;
            if !object_ids.insert(parsed.id) {
                return Err(TiledImportError::invalid(format!(
                    "Tiled object id {} is duplicated",
                    parsed.id
                )));
            }
            objects.push(parsed);
            total_objects += 1;
        }
        let visible = layer_obj
            .get("visible")
            .map(|value| {
                value.as_bool().ok_or_else(|| {
                    TiledImportError::invalid(format!(
                        "object layer '{name}' visible must be boolean"
                    ))
                })
            })
            .transpose()?
            .unwrap_or(true);
        layers.push(TiledObjectLayer {
            name,
            visible,
            offset_x,
            offset_y,
            objects,
        });
    }
    Ok(TiledMap {
        width,
        height,
        tile_width,
        tile_height,
        orientation: object
            .get("orientation")
            .and_then(Value::as_str)
            .ok_or_else(|| TiledImportError::invalid("Tiled JSON orientation is required"))?
            .to_string(),
        infinite: object
            .get("infinite")
            .map(|value| {
                value
                    .as_bool()
                    .ok_or_else(|| TiledImportError::invalid("Tiled JSON infinite must be boolean"))
            })
            .transpose()?
            .unwrap_or(false),
        object_layers: layers,
    })
}

fn parse_xml_object(
    node: &Node<'_, '_>,
    limits: &TileMapLimits,
    total_points: &mut usize,
) -> Result<TiledObject, TiledImportError> {
    let id = attr_u32_xml(node, "id")?;
    if id == 0 {
        return Err(TiledImportError::invalid(
            "Tiled object id must be positive",
        ));
    }
    let x = attr_f64_xml(node, "x")?
        .ok_or_else(|| TiledImportError::invalid(format!("object {id} is missing x coordinate")))?;
    let y = attr_f64_xml(node, "y")?
        .ok_or_else(|| TiledImportError::invalid(format!("object {id} is missing y coordinate")))?;
    // Validate optional shape metadata even though the normalized model only
    // needs the position. This prevents malformed numeric fields on an
    // otherwise unsupported object from being silently ignored.
    let width = attr_f64_xml(node, "width")?;
    let height = attr_f64_xml(node, "height")?;
    if width.is_some_and(|value| value < 0.0) || height.is_some_and(|value| value < 0.0) {
        return Err(TiledImportError::invalid(format!(
            "object {id} width and height must be non-negative"
        )));
    }
    if let Some(gid) = node.attribute("gid") {
        gid.parse::<u32>()
            .map_err(|_| TiledImportError::invalid(format!("object {id} gid is not a u32")))?;
    }
    let rotation = attr_f64_xml(node, "rotation")?.unwrap_or(0.0);
    if !x.is_finite() || !y.is_finite() || !rotation.is_finite() {
        return Err(TiledImportError::invalid(format!(
            "object {id} has non-finite coordinates"
        )));
    }
    let has_point = node.children().any(|child| child.has_tag_name("point"));
    let polygons = node
        .children()
        .filter(|child| child.has_tag_name("polygon"))
        .collect::<Vec<_>>();
    if polygons.len() > 1 {
        return Err(TiledImportError::invalid(format!(
            "object {id} contains multiple polygon rings; holes are unsupported"
        )));
    }
    let polygon = polygons.first().copied();
    let unsupported_shape = node.children().find(|child| {
        child.has_tag_name("ellipse")
            || child.has_tag_name("polyline")
            || child.has_tag_name("text")
            || child.has_tag_name("rectangle")
    });
    let shape_count = [has_point, polygon.is_some(), unsupported_shape.is_some()]
        .into_iter()
        .filter(|present| *present)
        .count();
    if shape_count > 1 {
        return Err(TiledImportError::invalid(format!(
            "object {id} contains multiple shape definitions"
        )));
    }
    let shape = if node.attribute("template").is_some() || unsupported_shape.is_some() {
        check_point_limit(1, limits, id, total_points)?;
        TiledObjectShape::Unsupported
    } else if has_point {
        check_point_limit(1, limits, id, total_points)?;
        TiledObjectShape::Point
    } else if let Some(polygon) = polygon {
        let point_text = polygon.attribute("points").ok_or_else(|| {
            TiledImportError::invalid(format!("object {id} polygon is missing points"))
        })?;
        // Count tokens before collecting parsed points so a malformed or
        // oversized object cannot allocate an unbounded vector first.
        let point_count = point_text.split_whitespace().count();
        check_point_limit(point_count, limits, id, total_points)?;
        let points = point_text
            .split_whitespace()
            .map(parse_point_pair)
            .collect::<Result<Vec<_>, _>>()?;
        TiledObjectShape::Polygon(points)
    } else {
        check_point_limit(1, limits, id, total_points)?;
        TiledObjectShape::Unsupported
    };
    let properties = node
        .children()
        .find(|child| child.has_tag_name("properties"))
        .map(parse_xml_properties)
        .transpose()?
        .unwrap_or_default();
    Ok(TiledObject {
        id,
        name: node.attribute("name").unwrap_or_default().to_string(),
        class_name: node
            .attribute("class")
            .or_else(|| node.attribute("type"))
            .unwrap_or_default()
            .to_string(),
        x,
        y,
        rotation,
        shape,
        properties,
    })
}

fn parse_json_object(
    value: &Value,
    limits: &TileMapLimits,
    total_points: &mut usize,
) -> Result<TiledObject, TiledImportError> {
    let object = value
        .as_object()
        .ok_or_else(|| TiledImportError::invalid("Tiled object must be an object"))?;
    let id = json_u32(object.get("id"), "object.id")?;
    if id == 0 {
        return Err(TiledImportError::invalid(
            "Tiled object id must be positive",
        ));
    }
    let x = json_f64(object.get("x"), "object.x")?
        .ok_or_else(|| TiledImportError::invalid(format!("object {id} is missing x coordinate")))?;
    let y = json_f64(object.get("y"), "object.y")?
        .ok_or_else(|| TiledImportError::invalid(format!("object {id} is missing y coordinate")))?;
    let width = json_f64(object.get("width"), "object.width")?;
    let height = json_f64(object.get("height"), "object.height")?;
    if width.is_some_and(|value| value < 0.0) || height.is_some_and(|value| value < 0.0) {
        return Err(TiledImportError::invalid(format!(
            "object {id} width and height must be non-negative"
        )));
    }
    if let Some(gid) = object.get("gid") {
        json_u32(Some(gid), "object.gid")?;
    }
    let rotation = json_f64(object.get("rotation"), "object.rotation")?.unwrap_or(0.0);
    if !x.is_finite() || !y.is_finite() || !rotation.is_finite() {
        return Err(TiledImportError::invalid(format!(
            "object {id} has non-finite coordinates"
        )));
    }
    let point = object
        .get("point")
        .map(|value| {
            value.as_bool().ok_or_else(|| {
                TiledImportError::invalid(format!("object {id} point must be boolean"))
            })
        })
        .transpose()?
        .unwrap_or(false);
    let unsupported_shape = ["ellipse", "polyline", "text", "rectangle"]
        .iter()
        .any(|key| object.contains_key(*key));
    let has_polygon = object.contains_key("polygon");
    if (point && has_polygon) || (unsupported_shape && (point || has_polygon)) {
        return Err(TiledImportError::invalid(format!(
            "object {id} contains multiple shape definitions"
        )));
    }
    if unsupported_shape {
        check_point_limit(1, limits, id, total_points)?;
    }
    let shape = if object.contains_key("template") || unsupported_shape {
        TiledObjectShape::Unsupported
    } else if point {
        check_point_limit(1, limits, id, total_points)?;
        TiledObjectShape::Point
    } else if let Some(points) = object.get("polygon") {
        let values = points.as_array().ok_or_else(|| {
            TiledImportError::invalid(format!("object {id} polygon must be an array"))
        })?;
        check_point_limit(values.len(), limits, id, total_points)?;
        let mut out = Vec::with_capacity(values.len());
        for point in values {
            let point_obj = point.as_object().ok_or_else(|| {
                TiledImportError::invalid(format!("object {id} polygon point must be an object"))
            })?;
            let px = json_f64(point_obj.get("x"), "polygon.x")?
                .ok_or_else(|| TiledImportError::invalid("polygon point is missing x"))?;
            let py = json_f64(point_obj.get("y"), "polygon.y")?
                .ok_or_else(|| TiledImportError::invalid("polygon point is missing y"))?;
            if !px.is_finite() || !py.is_finite() {
                return Err(TiledImportError::invalid(format!(
                    "object {id} has non-finite polygon point"
                )));
            }
            out.push(TiledPoint { x: px, y: py });
        }
        TiledObjectShape::Polygon(out)
    } else {
        check_point_limit(1, limits, id, total_points)?;
        TiledObjectShape::Unsupported
    };
    let properties = object
        .get("properties")
        .map(parse_json_properties)
        .transpose()?
        .unwrap_or_default();
    Ok(TiledObject {
        id,
        name: object
            .get("name")
            .map(|value| {
                value.as_str().ok_or_else(|| {
                    TiledImportError::invalid(format!("object {id} name must be a string"))
                })
            })
            .transpose()?
            .unwrap_or_default()
            .to_string(),
        class_name: object
            .get("class")
            .or_else(|| object.get("type"))
            .map(|value| {
                value.as_str().ok_or_else(|| {
                    TiledImportError::invalid(format!("object {id} class/type must be a string"))
                })
            })
            .transpose()?
            .unwrap_or_default()
            .to_string(),
        x,
        y,
        rotation,
        shape,
        properties,
    })
}

fn parse_xml_properties(
    node: Node<'_, '_>,
) -> Result<std::collections::HashMap<String, TiledPropertyValue>, TiledImportError> {
    let mut out = std::collections::HashMap::new();
    for property in node
        .children()
        .filter(|child| child.has_tag_name("property"))
    {
        let name = property
            .attribute("name")
            .ok_or_else(|| TiledImportError::invalid("Tiled property is missing name"))?;
        let value = property
            .attribute("value")
            .or_else(|| property.text())
            .unwrap_or_default();
        let kind = property.attribute("type").unwrap_or("string");
        out.insert(name.to_string(), parse_property(kind, value)?);
    }
    Ok(out)
}

fn parse_json_properties(
    value: &Value,
) -> Result<std::collections::HashMap<String, TiledPropertyValue>, TiledImportError> {
    let properties = value
        .as_array()
        .ok_or_else(|| TiledImportError::invalid("Tiled properties must be an array"))?;
    let mut out = std::collections::HashMap::new();
    for property in properties {
        let object = property
            .as_object()
            .ok_or_else(|| TiledImportError::invalid("Tiled property must be an object"))?;
        let name = object
            .get("name")
            .and_then(Value::as_str)
            .ok_or_else(|| TiledImportError::invalid("Tiled property is missing name"))?;
        let kind = object
            .get("type")
            .map(|value| {
                value.as_str().ok_or_else(|| {
                    TiledImportError::invalid(format!("property '{name}' type must be a string"))
                })
            })
            .transpose()?
            .unwrap_or("string");
        let parsed = match kind {
            "int" => {
                TiledPropertyValue::Int(object.get("value").and_then(Value::as_i64).ok_or_else(
                    || TiledImportError::invalid(format!("property '{name}' is not an integer")),
                )?)
            }
            "float" => {
                let value = object.get("value").and_then(Value::as_f64).ok_or_else(|| {
                    TiledImportError::invalid(format!("property '{name}' is not a number"))
                })?;
                if !value.is_finite() {
                    return Err(TiledImportError::invalid(format!(
                        "property '{name}' must be finite"
                    )));
                }
                TiledPropertyValue::Float(value)
            }
            "bool" => {
                TiledPropertyValue::Bool(object.get("value").and_then(Value::as_bool).ok_or_else(
                    || TiledImportError::invalid(format!("property '{name}' is not boolean")),
                )?)
            }
            "color" => TiledPropertyValue::Color(
                object
                    .get("value")
                    .and_then(Value::as_str)
                    .ok_or_else(|| {
                        TiledImportError::invalid(format!("property '{name}' is not a string"))
                    })?
                    .to_string(),
            ),
            "file" => TiledPropertyValue::File(
                object
                    .get("value")
                    .and_then(Value::as_str)
                    .ok_or_else(|| {
                        TiledImportError::invalid(format!("property '{name}' is not a string"))
                    })?
                    .to_string(),
            ),
            "object" => {
                TiledPropertyValue::Object(json_u32(object.get("value"), "object property")?)
            }
            "string" => TiledPropertyValue::String(
                object
                    .get("value")
                    .and_then(Value::as_str)
                    .ok_or_else(|| {
                        TiledImportError::invalid(format!("property '{name}' is not a string"))
                    })?
                    .to_string(),
            ),
            other => {
                return Err(TiledImportError::invalid(format!(
                    "unsupported Tiled property type '{other}'"
                )))
            }
        };
        out.insert(name.to_string(), parsed);
    }
    Ok(out)
}

fn parse_property(kind: &str, value: &str) -> Result<TiledPropertyValue, TiledImportError> {
    let scalar = value.trim();
    match kind {
        "int" => scalar
            .parse::<i64>()
            .map(TiledPropertyValue::Int)
            .map_err(|_| {
                TiledImportError::invalid(format!("property value '{value}' is not an integer"))
            }),
        "float" => scalar
            .parse::<f64>()
            .map_err(|_| {
                TiledImportError::invalid(format!("property value '{value}' is not a number"))
            })
            .and_then(|value| {
                if value.is_finite() {
                    Ok(TiledPropertyValue::Float(value))
                } else {
                    Err(TiledImportError::invalid(
                        "float property values must be finite",
                    ))
                }
            }),
        "bool" => scalar
            .parse::<bool>()
            .map(TiledPropertyValue::Bool)
            .map_err(|_| {
                TiledImportError::invalid(format!("property value '{value}' is not boolean"))
            }),
        "color" => Ok(TiledPropertyValue::Color(value.to_string())),
        "file" => Ok(TiledPropertyValue::File(value.to_string())),
        "object" => scalar
            .parse::<u32>()
            .map(TiledPropertyValue::Object)
            .map_err(|_| {
                TiledImportError::invalid(format!("property value '{value}' is not an object id"))
            }),
        "string" => Ok(TiledPropertyValue::String(value.to_string())),
        other => Err(TiledImportError::invalid(format!(
            "unsupported Tiled property type '{other}'"
        ))),
    }
}

fn parse_point_pair(value: &str) -> Result<TiledPoint, TiledImportError> {
    let (x, y) = value
        .split_once(',')
        .ok_or_else(|| TiledImportError::invalid(format!("polygon point '{value}' must be x,y")))?;
    let x = x
        .parse::<f64>()
        .map_err(|_| TiledImportError::invalid(format!("polygon x '{x}' is not a number")))?;
    let y = y
        .parse::<f64>()
        .map_err(|_| TiledImportError::invalid(format!("polygon y '{y}' is not a number")))?;
    if !x.is_finite() || !y.is_finite() {
        return Err(TiledImportError::invalid("polygon point must be finite"));
    }
    Ok(TiledPoint { x, y })
}

fn check_object_limit(
    current: usize,
    limits: &TileMapLimits,
    layer: &str,
) -> Result<(), TiledImportError> {
    if current >= limits.max_objects {
        return Err(TiledImportError::invalid(format!(
            "object layer '{layer}' exceeds object limit {}",
            limits.max_objects
        )));
    }
    Ok(())
}

fn check_point_limit(
    count: usize,
    limits: &TileMapLimits,
    object_id: u32,
    total_points: &mut usize,
) -> Result<(), TiledImportError> {
    if count > limits.max_points_per_object {
        return Err(TiledImportError::invalid(format!(
            "object {object_id} exceeds polygon point limit {}",
            limits.max_points_per_object
        )));
    }
    *total_points = total_points
        .checked_add(count)
        .ok_or_else(|| TiledImportError::invalid("Tiled object point count overflows"))?;
    if *total_points > limits.max_total_object_points {
        return Err(TiledImportError::invalid(format!(
            "Tiled object point limit {} exceeded",
            limits.max_total_object_points
        )));
    }
    Ok(())
}

fn attr_u32_xml(node: &Node<'_, '_>, name: &str) -> Result<u32, TiledImportError> {
    node.attribute(name)
        .ok_or_else(|| TiledImportError::invalid(format!("TMX element is missing '{name}'")))?
        .parse::<u32>()
        .map_err(|_| TiledImportError::invalid(format!("TMX attribute '{name}' is not a u32")))
}

fn attr_f64_xml(node: &Node<'_, '_>, name: &str) -> Result<Option<f64>, TiledImportError> {
    let Some(value) = node.attribute(name) else {
        return Ok(None);
    };
    let parsed = value.parse::<f64>().map_err(|_| {
        TiledImportError::invalid(format!("TMX attribute '{name}' is not a number"))
    })?;
    if !parsed.is_finite() {
        return Err(TiledImportError::invalid(format!(
            "TMX attribute '{name}' must be finite"
        )));
    }
    Ok(Some(parsed))
}

fn attr_bool_xml(node: &Node<'_, '_>, name: &str) -> Result<Option<bool>, TiledImportError> {
    let Some(value) = node.attribute(name) else {
        return Ok(None);
    };
    match value {
        "0" | "false" => Ok(Some(false)),
        "1" | "true" => Ok(Some(true)),
        _ => Err(TiledImportError::invalid(format!(
            "TMX attribute '{name}' must be boolean"
        ))),
    }
}

fn json_u32(value: Option<&Value>, name: &str) -> Result<u32, TiledImportError> {
    let number = value.and_then(Value::as_u64).ok_or_else(|| {
        TiledImportError::invalid(format!("Tiled JSON field '{name}' is not a u32"))
    })?;
    u32::try_from(number).map_err(|_| {
        TiledImportError::invalid(format!("Tiled JSON field '{name}' is out of range"))
    })
}

fn json_f64(value: Option<&Value>, name: &str) -> Result<Option<f64>, TiledImportError> {
    let Some(value) = value else {
        return Ok(None);
    };
    let parsed = value.as_f64().ok_or_else(|| {
        TiledImportError::invalid(format!("Tiled JSON field '{name}' is not a number"))
    })?;
    if !parsed.is_finite() {
        return Err(TiledImportError::invalid(format!(
            "Tiled JSON field '{name}' must be finite"
        )));
    }
    Ok(Some(parsed))
}
