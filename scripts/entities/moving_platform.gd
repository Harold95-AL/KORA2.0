extends AnimatableBody2D
@export var travel := Vector2(144, 0)
@export var duration: float = 4.0
@export var unstable := false
@export var width: float = 96.0
@export var surface_texture: Texture2D
@export var collapse_delay := 0.30
@export var return_delay := 2.4
var origin := Vector2.ZERO
var elapsed: float = 0.0
var collapse_timer: float = -1.0

func _ready() -> void:
	origin = position
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, 12)
	$CollisionShape2D.shape = shape
	$CollisionShape2D.position = Vector2(width * 0.5, 6)
	queue_redraw()

func _physics_process(delta: float) -> void:
	elapsed += delta
	if not unstable:
		position = origin + travel * (0.5 - cos(elapsed * TAU / duration) * 0.5)
		return
	var player := get_tree().get_first_node_in_group("player") as KoraPlayer
	if is_instance_valid(player) and collapse_timer < 0.0:
		if player.is_on_floor() and absf(player.global_position.y - global_position.y) < 3.0 and player.global_position.x > global_position.x - 10 and player.global_position.x < global_position.x + width + 10:
			collapse_timer = 0.0
	if collapse_timer >= 0.0:
		collapse_timer += delta
		$CollisionShape2D.set_deferred("disabled", collapse_timer > collapse_delay and collapse_timer < return_delay)
		visible = collapse_timer < collapse_delay or collapse_timer >= return_delay
		if collapse_timer >= return_delay:
			collapse_timer = -1.0
	queue_redraw()

func _draw() -> void:
	var color := Color("e0b8ff") if unstable else Color("68ccf1")
	if collapse_timer >= 0.0:
		color = Color("ffc96b")
	if surface_texture:
		draw_texture_rect(surface_texture, Rect2(0, 0, width, 12), false)
	else:
		draw_rect(Rect2(0, 0, width, 12), color)
		for x in range(8, int(width) - 4, 16):
			draw_line(Vector2(x, 4), Vector2(x + 6, 8), Color("233447"), 2)
	if collapse_timer >= 0.0 and collapse_timer < collapse_delay:
		draw_rect(Rect2(0,-3,width * (1.0-collapse_timer/collapse_delay),2),Color("ff646e"))

