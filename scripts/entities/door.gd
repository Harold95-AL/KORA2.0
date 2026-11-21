extends StaticBody2D
@export var required_keys: PackedStringArray = []
@export var arena_lock: bool = false
@export var boss_key: String = "boss"
@export var width: float = 18.0
@export var height: float = 160.0
var opened := false

func _ready() -> void:
	add_to_group("doors")
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, height)
	$CollisionShape2D.shape = shape
	$CollisionShape2D.position = Vector2(width / 2, -height / 2)

func _physics_process(_delta: float) -> void:
	var should_open := GameManager.requirements_met(required_keys)
	if arena_lock:
		should_open = not bool(get_tree().current_scene.get_meta("arena_active", false)) or GameManager.has_key(boss_key)
	opened = should_open
	$CollisionShape2D.set_deferred("disabled", opened)
	queue_redraw()

func _draw() -> void:
	if opened:
		draw_rect(Rect2(0, -5, width, 5), Color("79eda0"))
	else:
		draw_rect(Rect2(0, -height, width, height), Color("8f79cc"))
		for y in range(8, int(height), 16):
			draw_line(Vector2(0, -y), Vector2(width, -y - 8), Color("d1c3ff"), 2)

