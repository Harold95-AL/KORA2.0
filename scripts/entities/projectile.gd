extends Node2D
var velocity := Vector2.ZERO
var age: float = 0.0
var ground_wave := false
var damage := 2

func _physics_process(delta: float) -> void:
	var previous := global_position
	var next := previous + velocity * delta
	var wall_query := PhysicsRayQueryParameters2D.create(previous,next,1)
	if not get_world_2d().direct_space_state.intersect_ray(wall_query).is_empty():
		queue_free()
		return
	global_position = next
	age += delta
	var player := get_tree().get_first_node_in_group("player") as KoraPlayer
	if is_instance_valid(player):
		var center := player.global_position + Vector2(0, -19)
		var closest := Geometry2D.get_closest_point_to_segment(center,previous,next)
		if center.distance_to(closest) < 22.0:
			player.take_damage(damage, global_position)
			queue_free()
	if age > 4.5:
		queue_free()
	queue_redraw()

func _draw() -> void:
	var color := Color("ff8b97")
	if ground_wave:
		draw_colored_polygon(PackedVector2Array([Vector2(-10, 10), Vector2(0, -12), Vector2(10, 10)]), color)
	else:
		draw_circle(Vector2.ZERO, 7, color)
		draw_circle(Vector2.ZERO, 3, Color.WHITE)

