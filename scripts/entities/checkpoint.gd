extends Area2D
var active := false

func _ready() -> void:
	add_to_group("checkpoints")
	body_entered.connect(_entered)
	call_deferred("_restore_active")

func _restore_active() -> void:
	var saved: Vector2 = GameManager.checkpoints.get(str(GameManager.section_index), Vector2(-999, -999))
	active = saved.distance_to(global_position) < 10.0
	queue_redraw()

func _entered(body: Node2D) -> void:
	if body is KoraPlayer and not active:
		for other in get_tree().get_nodes_in_group("checkpoints"):
			other.active = false
			other.queue_redraw()
		active = true
		GameManager.checkpoint(global_position)
		queue_redraw()

func _draw() -> void:
	var color := Color("7bffb3") if active else Color("328b7c")
	draw_line(Vector2.ZERO, Vector2(0, -54), color, 3)
	draw_colored_polygon(PackedVector2Array([Vector2(0, -54), Vector2(27, -44), Vector2(0, -34)]), color)
	draw_circle(Vector2.ZERO, 5, color)

