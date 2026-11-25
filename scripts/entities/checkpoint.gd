extends Area2D
var active := false

func _ready() -> void:
	add_to_group("checkpoints")
	body_entered.connect(_entered)
	call_deferred("_restore_active")

func _restore_active() -> void:
	var saved: Vector2 = GameManager.checkpoints.get(str(GameManager.section_index), Vector2(-999, -999))
	active = saved.distance_to(global_position) < 10.0
	_refresh_beacon()

func _entered(body: Node2D) -> void:
	if body is KoraPlayer and not active:
		for other in get_tree().get_nodes_in_group("checkpoints"):
			other.active = false
			other._refresh_beacon()
		active = true
		GameManager.checkpoint(global_position)
		_refresh_beacon(true)

func _refresh_beacon(animate := false) -> void:
	var sprite: AnimatedSprite2D = $Baliza
	sprite.stop()
	sprite.animation = &"activar" if active else &"reposo"
	if active and animate:
		sprite.play()
	elif active:
		sprite.frame = sprite.sprite_frames.get_frame_count(&"activar") - 1
	$Baliza.self_modulate = Color.WHITE if active else Color(0.78, 0.83, 0.90)
