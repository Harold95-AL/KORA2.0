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

var pulse_time := 0.0

func _process(delta: float) -> void:
	if active:
		pulse_time += delta
		queue_redraw()

func _draw() -> void:
	draw_texture(preload("res://assets/sprites/tecnologia/baliza.png"), Vector2(-9,-36))
	if active:
		var light := Color("84ffdf").lerp(Color("46c5bd"), 0.5 + 0.5 * sin(pulse_time * 3.0))
		draw_rect(Rect2(-1,-23,4,6), light)
		draw_rect(Rect2(0,-24,2,8), light)