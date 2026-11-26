extends Parallax2D
## La última galería gana luz al acercarse; la restauración completa la transición.
@onready var player: Node2D = $"../../Player"

func _process(delta: float) -> void:
	var distancia := smoothstep(4500.0, 5040.0, player.global_position.x)
	var intensidad := 1.0 if GameManager.has_key("restore") else 0.68
	modulate.a = move_toward(modulate.a, distancia * intensidad, delta * 0.85)
