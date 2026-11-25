extends Node2D
@export var arch_texture: Texture2D
@export var required_keys: PackedStringArray = []
@export var hint: String = "Completa los objetivos indicados arriba."
var player: Node2D
var title := "Continuar →"

func _ready() -> void:
	add_to_group("interactables")

func can_interact() -> bool:
	return is_instance_valid(player) and player.global_position.distance_to(global_position) < 64.0

func interact() -> void:
	if GameManager.requirements_met(required_keys):
		GameManager.advance()
	else:
		GameUI.toast(hint, 5.0)

func _process(_delta: float) -> void:
	player = get_tree().get_first_node_in_group("player")
	queue_redraw()

func _draw() -> void:
	var color := Color("79eda0") if GameManager.requirements_met(required_keys) else Color("847a9d")
	if arch_texture:
		draw_texture(arch_texture, Vector2(-arch_texture.get_width() / 2.0, -arch_texture.get_height()), color)
	else:
		draw_rect(Rect2(-20, -68, 40, 68), color, false, 3)
	draw_line(Vector2(-9, -33), Vector2(10, -33), color, 3)
	draw_line(Vector2(1, -42), Vector2(10, -33), color, 3)
	draw_line(Vector2(1, -24), Vector2(10, -33), color, 3)

