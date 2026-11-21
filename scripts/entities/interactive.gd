extends Node2D
@export var title: String = "Terminal"
@export var state_key: String = ""
@export var story_id: String = ""
@export var record_id: String = ""
@export var required_keys: PackedStringArray = []
@export var locked_hint: String = "Completa el mecanismo anterior."
@export var order: int = 0
@export var tint := Color("72dfef")
var player: Node2D

func _ready() -> void:
	add_to_group("interactables")
	$Label.text = title

func can_interact() -> bool:
	return is_instance_valid(player) and player.global_position.distance_to(global_position) < 58.0

func interact() -> void:
	if not GameManager.requirements_met(required_keys):
		GameUI.toast(locked_hint, 4.0)
		return
	if not record_id.is_empty():
		NarrativeManager.read_record(record_id)
	elif order > 0:
		get_tree().current_scene.resonate(order)
	else:
		var previously_done := GameManager.has_key(state_key)
		GameManager.set_key(state_key)
		if previously_done:
			GameUI.toast(title + " · Completado")
		else:
			NarrativeManager.trigger(story_id)
			if story_id.is_empty():
				GameUI.toast(title + " · Activado")
	queue_redraw()

func _process(_delta: float) -> void:
	player = get_tree().get_first_node_in_group("player")
	queue_redraw()

func _draw() -> void:
	var color := tint
	if not state_key.is_empty() and GameManager.has_key(state_key):
		color = Color("79eda0")
	if not record_id.is_empty():
		color = Color("e0beff")
	draw_colored_polygon(PackedVector2Array([Vector2(0, -38), Vector2(15, -20), Vector2(0, -3), Vector2(-15, -20)]), color)
	draw_rect(Rect2(-20, -3, 40, 4), Color("516482"))
	if can_interact():
		draw_arc(Vector2(0, -20), 24, 0, TAU, 24, Color.WHITE, 1.0)

