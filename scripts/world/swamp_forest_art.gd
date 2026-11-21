extends Node2D
## Capa visual opcional de Fantasy Swamp Forest para el nivel 2.3.
## El paquete se mantiene local y no se incluye en Git por su licencia.

const PACK_ROOT := "res://assets/external/forest-nature-fantasy-tileset-free/Fantasy Swamp Forest/Free/"
const TILE_SIZE := 16
const PROPS_FIRST_GID := 3001
const PROPS_COLUMNS := 20
const PROPS_TILE_COUNT := 680
const PROPS_OFFSET := Vector2(768, 0)

const BACKGROUNDS := [
	{"name": "Sky", "file": "BG_3/BG_3.png", "scroll": Vector2(0.03, 0.0), "z": -30},
	{"name": "DistantForest", "file": "BG_2/BG_2.png", "scroll": Vector2(0.16, 0.0), "z": -20},
	{"name": "ForestCanopy", "file": "BG_1/BG_1.png", "scroll": Vector2(0.38, 0.0), "z": -10},
]

var _props_texture: Texture2D
var _world_art: Node2D

func _ready() -> void:
	_world_art = get_parent().get_node_or_null("WorldArt") as Node2D
	for layer in BACKGROUNDS:
		_add_parallax(layer)
	_add_sample_props()

func _add_parallax(layer: Dictionary) -> void:
	var texture_path: String = PACK_ROOT + layer["file"]
	if not ResourceLoader.exists(texture_path):
		return
	var texture := load(texture_path) as Texture2D
	if texture == null:
		return
	var parallax := Parallax2D.new()
	parallax.name = "Swamp" + layer["name"]
	parallax.scroll_scale = layer["scroll"]
	parallax.repeat_size = Vector2(texture.get_width(), 0)
	parallax.repeat_times = 4
	parallax.z_index = layer["z"]
	var image := Sprite2D.new()
	image.name = "Layer"
	image.texture = texture
	image.centered = false
	image.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	parallax.add_child(image)
	add_child(parallax)

func _add_sample_props() -> void:
	if _world_art == null:
		return
	var texture_path := PACK_ROOT + "Terrain_and_Props.png"
	var map_path := PACK_ROOT + "Free.tmx"
	if not ResourceLoader.exists(texture_path) or not FileAccess.file_exists(map_path):
		return
	_props_texture = load(texture_path) as Texture2D
	if _props_texture == null:
		return
	var parser := XMLParser.new()
	if parser.open(map_path) != OK:
		return
	var in_props_layer := false
	var in_chunk := false
	var chunk_x := 0
	var chunk_y := 0
	var chunk_width := 0
	while parser.read() == OK:
		var node_type := parser.get_node_type()
		var node_name := parser.get_node_name()
		if node_type == XMLParser.NODE_ELEMENT:
			var attributes := _read_attributes(parser)
			if node_name == "layer":
				in_props_layer = attributes.get("name", "") == "Props"
			elif node_name == "chunk" and in_props_layer:
				in_chunk = true
				chunk_x = int(attributes.get("x", "0"))
				chunk_y = int(attributes.get("y", "0"))
				chunk_width = int(attributes.get("width", "0"))
		elif node_type == XMLParser.NODE_TEXT and in_props_layer and in_chunk:
			_add_chunk_tiles(parser.get_node_data(), chunk_x, chunk_y, chunk_width)
		elif node_type == XMLParser.NODE_ELEMENT_END:
			if node_name == "chunk":
				in_chunk = false
			elif node_name == "layer":
				in_props_layer = false

func _read_attributes(parser: XMLParser) -> Dictionary:
	var result := {}
	for index in range(parser.get_attribute_count()):
		result[parser.get_attribute_name(index)] = parser.get_attribute_value(index)
	return result

func _add_chunk_tiles(csv: String, chunk_x: int, chunk_y: int, chunk_width: int) -> void:
	if chunk_width <= 0:
		return
	var values := csv.strip_edges().split(",", false)
	for index in range(values.size()):
		var raw_gid := values[index].strip_edges().to_int()
		var gid := raw_gid & 0x1fffffff # Quita los indicadores de volteo de Tiled.
		var atlas_index := gid - PROPS_FIRST_GID
		if atlas_index < 0 or atlas_index >= PROPS_TILE_COUNT:
			continue
		var prop := Sprite2D.new()
		prop.texture = _props_texture
		prop.region_enabled = true
		prop.region_rect = Rect2((atlas_index % PROPS_COLUMNS) * TILE_SIZE, int(atlas_index / PROPS_COLUMNS) * TILE_SIZE, TILE_SIZE, TILE_SIZE)
		prop.centered = false
		prop.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		prop.position = PROPS_OFFSET + Vector2((chunk_x + index % chunk_width) * TILE_SIZE, (chunk_y + int(index / chunk_width)) * TILE_SIZE)
		prop.flip_h = (raw_gid & 0x80000000) != 0
		prop.flip_v = (raw_gid & 0x40000000) != 0
		_world_art.add_child(prop)
