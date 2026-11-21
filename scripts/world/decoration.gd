extends Node2D
## Marcadores semánticos reemplazables por sprites sin tocar colisiones.
@export_enum("crystal", "ship", "sil", "memory", "core", "tree", "ruins") var kind := "crystal"
@export var tint := Color("4c88a0")
@export var size := Vector2(64, 96)
var elapsed: float = 0.0

func _process(delta: float) -> void:
	elapsed += delta
	if kind in ["sil", "core", "memory"]:
		queue_redraw()

func _draw() -> void:
	match kind:
		"ship":
			draw_colored_polygon(PackedVector2Array([Vector2(-size.x / 2, 0), Vector2(-size.x / 3, -size.y), Vector2(size.x / 4, -size.y * 0.7), Vector2(size.x / 2, 0)]), tint)
			draw_rect(Rect2(-22, -size.y * 0.75, 40, 22), Color("83c2dc"))
		"sil":
			var bounce := sin(elapsed * 3.0) * 3.0
			draw_circle(Vector2(0, -12 + bounce), 10, Color("99f2c3"))
			draw_circle(Vector2(6, -14 + bounce), 2, Color("102c36"))
			draw_line(Vector2(-8, -8 + bounce), Vector2(-20, -20 + bounce), Color("99f2c3"), 3)
		"core":
			draw_arc(Vector2(0, -size.y / 2), size.x / 2, elapsed * 0.1, elapsed * 0.1 + TAU - 0.3, 64, Color(tint, 0.5), 4)
			draw_circle(Vector2(0, -size.y / 2), size.x * 0.3 + sin(elapsed) * 3, Color(tint, 0.3))
		"memory":
			draw_circle(Vector2(0, -27 + sin(elapsed) * 4), 9, Color(tint, 0.6))
			draw_rect(Rect2(-8, -17, 16, 17), Color(tint, 0.4))
		"tree", "ruins":
			draw_rect(Rect2(-7, -size.y, 14, size.y), tint)
			if kind == "tree":
				draw_colored_polygon(PackedVector2Array([Vector2(-size.x / 2, -size.y / 2), Vector2(0, -size.y - 30), Vector2(size.x / 2, -size.y / 2)]), tint.lightened(0.12))
			else:
				draw_rect(Rect2(-size.x / 2, -size.y, size.x, 12), tint)
		_:
			draw_colored_polygon(PackedVector2Array([Vector2(-size.x / 2, 0), Vector2(-size.x / 4, -size.y), Vector2(size.x / 3, -size.y * 0.8), Vector2(size.x / 2, 0)]), tint)

