extends Node2D
var health := 100
var flash_timer := 0.0
var wobble_angle := 0.0
var wobble_velocity := 0.0

func _ready() -> void:
	add_to_group("enemies")

func hurt_rect() -> Rect2:
	return Rect2(global_position+Vector2(-12,-45),Vector2(24,45))

func receive_lab_hit(damage: int, direction: int) -> void:
	flash_timer = 0.18
	wobble_velocity = direction * 18.0
	health = maxi(0,health-damage)
	if health == 0: health = 100

func _physics_process(delta: float) -> void:
	if flash_timer > 0.0: flash_timer -= delta
	wobble_velocity += -80.0 * wobble_angle * delta
	wobble_velocity *= maxf(0.0,1.0-6.0*delta)
	wobble_angle += wobble_velocity*delta
	queue_redraw()

func _draw() -> void:
	draw_set_transform(Vector2.ZERO,deg_to_rad(wobble_angle))
	var style := StyleBoxFlat.new()
	style.bg_color = Color.WHITE if flash_timer > 0.0 else Color("b91c1c")
	style.border_color = Color("f87171")
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	draw_style_box(style,Rect2(-12,-45,24,45))
	draw_rect(Rect2(-6,-33,12,4),Color("fee2e2"))
	draw_rect(Rect2(-2,-37,4,12),Color("fee2e2"))
	draw_rect(Rect2(-16,-3,32,6),Color("475569"))

