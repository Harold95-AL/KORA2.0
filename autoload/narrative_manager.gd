extends Node
## Contenido editable en JSON. Las memorias opcionales nunca abren puertas.
var flags: Dictionary = {}
var records: Dictionary = {}
var content: Dictionary = {}

func _ready() -> void:
	content = JSON.parse_string(FileAccess.get_file_as_string("res://data/narrative.json"))

func reset() -> void:
	flags.clear()
	records.clear()

func trigger(id: String) -> void:
	if id.is_empty() or flags.has(id):
		return
	if not content.has(id):
		push_error("Falta diálogo " + id)
		return
	flags[id] = true
	var entry: Dictionary = content[id]
	GameUI.dialogue(entry.get("title", id), entry["lines"], entry.get("blocking", false))

func read_record(id: String) -> void:
	if not content.has(id):
		return
	records[id] = true
	var entry: Dictionary = content[id]
	GameUI.dialogue(entry["title"], entry["lines"], true)

