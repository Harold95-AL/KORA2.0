extends Node2D
## El progreso guardado determina el aspecto al volver a un checkpoint.
@export var mecanismo: String
@export var apagado := Color(0.47, 0.40, 0.55)
@export var encendido := Color(0.82, 1.0, 0.95)

func _process(delta: float) -> void:
	var destino := encendido if GameManager.has_key(mecanismo) else apagado
	modulate = modulate.lerp(destino, 1.0 - exp(-4.0 * delta))
