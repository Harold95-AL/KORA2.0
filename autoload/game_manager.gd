extends Node
## Progreso de sesión. Mecanismos persistentes y combate temporal son independientes.
const MAX_HEALTH := 6
var sections: Array = []
var section_index: int = -1
var health: int = MAX_HEALTH
var checkpoints: Dictionary = {}
var mechanisms: Dictionary = {}
var completed: Array[int] = []
var campaign_active := false
var transitioning := false
var instant_transitions := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	sections = JSON.parse_string(FileAccess.get_file_as_string("res://data/sections.json"))

func new_game() -> void:
	checkpoints.clear()
	mechanisms.clear()
	completed.clear()
	NarrativeManager.reset()
	section_index = -1
	health = MAX_HEALTH
	campaign_active = false
	change_scene("res://levels/Prologue.tscn")

func state() -> Dictionary:
	var key := str(section_index)
	if not mechanisms.has(key):
		mechanisms[key] = {}
	return mechanisms[key]

func has_key(key: String) -> bool:
	return bool(state().get(key, false))

func set_key(key: String, value: bool = true) -> void:
	if not key.is_empty():
		state()[key] = value

func requirements_met(keys: PackedStringArray) -> bool:
	for key in keys:
		if not has_key(key):
			return false
	return true

func enter_section(index: int, start: Vector2) -> Vector2:
	if section_index != index:
		section_index = index
		health = MAX_HEALTH
	campaign_active = true
	return checkpoints.get(str(index), start)

func checkpoint(position: Vector2) -> void:
	checkpoints[str(section_index)] = position
	health = MAX_HEALTH
	GameUI.toast("CHECKPOINT · Energía restaurada", 2.5)

func damage(amount: int) -> void:
	if transitioning or not campaign_active:
		return
	health = maxi(0, health - amount)
	if health == 0:
		GameUI.show_result(false)

func respawn() -> void:
	if transitioning or section_index < 0:
		return
	health = MAX_HEALTH
	# Recarga enemigos, peligros, plataformas y secuencia parcial del puzle.
	# Conserva puertas resueltas, registros, historia y checkpoint seguro.
	change_scene(sections[section_index]["scene"])

func goto_section(index: int, fresh: bool = false) -> void:
	if transitioning or index < 0 or index >= sections.size():
		return
	if fresh:
		checkpoints.erase(str(index))
		mechanisms.erase(str(index))
	section_index = index
	health = MAX_HEALTH
	change_scene(sections[index]["scene"])

func advance() -> void:
	if transitioning:
		return
	if section_index not in completed:
		completed.append(section_index)
	if section_index == sections.size() - 1:
		campaign_active = false
		change_scene("res://levels/Epilogue.tscn")
	else:
		goto_section(section_index + 1)

func menu() -> void:
	campaign_active = false
	change_scene("res://ui/MainMenu.tscn")

func change_scene(path: String) -> void:
	if transitioning:
		return
	transitioning = true
	GameUI.close_overlay()
	GameUI.clear_dialogues()
	if not instant_transitions:
		await GameUI.fade(1.0)
	var error := get_tree().change_scene_to_file(path)
	if error != OK:
		push_error("No se pudo abrir: " + path)
	await get_tree().process_frame
	if not instant_transitions:
		await GameUI.fade(0.0)
	transitioning = false

