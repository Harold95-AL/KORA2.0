extends Node2D
## Driver opcional solo para capturas de continuidad del parallax.
## El modo normal conserva el control jugable de Level_1_1.
var capture_scroll := false
var capture_elapsed := 0.0
var capture_speed := 300.0
var player: CharacterBody2D

func _ready() -> void:
	var user_args := OS.get_cmdline_user_args()
	capture_scroll = "--capture-scroll" in user_args
	if not capture_scroll:
		return
	for argument in user_args:
		if argument.begins_with("--capture-speed="):
			capture_speed = argument.get_slice("=", 1).to_float()
	player = $Level_1_1/Player as CharacterBody2D
	player.velocity = Vector2.ZERO
	player.global_position = Vector2(100, 320)

func _process(delta: float) -> void:
	if not capture_scroll or not is_instance_valid(player):
		return
	capture_elapsed += delta
	player.velocity = Vector2.ZERO
	player.global_position = Vector2(100.0 + capture_elapsed * capture_speed, 320.0)
