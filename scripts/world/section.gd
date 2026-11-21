extends Node2D
## Cada .tscn contiene su geometría, entidades y capas editables.
@export var section_index: int = 0
@export var bounds := Rect2(0, 0, 4800, 720)
@export var palette := Color("283d59")
@export var entry_story: String = ""
@export var entry_hint: String = ""
@export var show_blockout_backdrop := true
@onready var player: KoraPlayer = $Player
var puzzle_progress: int = 0
const PUZZLE_ORDER: Array[int] = [1, 3, 2]

func _ready() -> void:
	player.global_position = GameManager.enter_section(section_index, player.position)
	player.spawn_position = player.position
	player.respawn_y = bounds.end.y + 100.0
	var camera: Camera2D = $Player/Camera2D
	camera.limit_left = int(bounds.position.x)
	camera.limit_right = int(bounds.end.x)
	camera.limit_top = int(bounds.position.y)
	camera.limit_bottom = int(bounds.end.y)
	camera.reset_smoothing()
	queue_redraw()
	if not entry_story.is_empty():
		NarrativeManager.call_deferred("trigger", entry_story)
	if not entry_hint.is_empty():
		GameUI.toast(entry_hint, 7.0)

func resonate(order: int) -> void:
	if GameManager.has_key("sequence"):
		GameUI.toast("Secuencia ya establecida: I → III → II")
		return
	if order == PUZZLE_ORDER[puzzle_progress]:
		puzzle_progress += 1
		GameUI.toast("Resonancia %d/3 · I → III → II" % puzzle_progress)
		if puzzle_progress == 3:
			GameManager.set_key("sequence")
			NarrativeManager.trigger("PUZZLE_DONE")
	else:
		puzzle_progress = 0
		GameUI.toast("La secuencia se reinicia sin daño. Pista: I → III → II", 4.0)

func _draw() -> void:
	if not show_blockout_backdrop:
		return
	for x in range(int(bounds.position.x), int(bounds.end.x), 160):
		var top := 100.0 + sin(float(x) * 0.003) * 70.0
		draw_colored_polygon(PackedVector2Array([
			Vector2(x, bounds.end.y), Vector2(x + 60, top),
			Vector2(x + 145, bounds.end.y)]), Color(palette, 0.22))
	for y in range(160, int(bounds.end.y), 160):
		draw_line(Vector2(bounds.position.x, y), Vector2(bounds.end.x, y), Color(palette, 0.12))

