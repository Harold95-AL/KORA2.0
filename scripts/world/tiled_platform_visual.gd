@tool
extends StaticBody2D
## Capa visual editable; la colisión sigue siendo la CollisionShape2D existente.

const PLATFORM_TEXTURE: Texture2D = preload("res://assets/sprites/tilesets/zona_1/piso_cristalino_base.png")
const SUBSOIL: Texture2D = preload("res://assets/sprites/tilesets/zona_1/subsuelo.png")
const LEFT_CORNER: Texture2D = preload("res://assets/sprites/tilesets/zona_1/piso_cristalino_esquina_izquierda.png")
const RIGHT_CORNER: Texture2D = preload("res://assets/sprites/tilesets/zona_1/piso_cristalino_esquina_derecha.png")

@onready var blockout: Polygon2D = $Blockout

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	queue_redraw()

func _draw() -> void:
	if blockout == null or PLATFORM_TEXTURE == null:
		return
	var bounds := Rect2()
	var first := true
	for point in blockout.polygon:
		if first:
			bounds = Rect2(point, Vector2.ZERO)
			first = false
		else:
			bounds = bounds.expand(point)
	if first or bounds.size.x < 32.0:
		return
	# Los extremos usan sus propios PNG con transparencia y un bisel diagonal.
	# La superficie del medio repite el PNG base a tamaño nativo, sin estirarlo.
	var cliff := Rect2(bounds.position + Vector2(0, 4), Vector2(bounds.size.x, 1024 - position.y - 4))
	if bounds.size.y >= 48:
		draw_texture_rect(SUBSOIL, cliff, true)
	draw_texture_rect(LEFT_CORNER, Rect2(bounds.position, Vector2(16.0, bounds.size.y)), false)
	draw_texture_rect(
		PLATFORM_TEXTURE,
		Rect2(bounds.position + Vector2(16.0, 0.0), Vector2(bounds.size.x - 32.0, bounds.size.y)),
		true
	)
	draw_texture_rect(
		RIGHT_CORNER,
		Rect2(bounds.position + Vector2(bounds.size.x - 16.0, 0.0), Vector2(16.0, bounds.size.y)),
		false
	)
