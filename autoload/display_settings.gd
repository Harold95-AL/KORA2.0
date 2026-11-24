extends Node
## Ventana Full HD con reducción automática al área útil del monitor.
var windowed_size := Vector2i(1920,1080)
var windowed_position := Vector2i.ZERO

var plates := CanvasLayer.new()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Texto del mundo legible con el zoom de cámara y en ventanas reducidas.
	ThemeDB.fallback_font = preload("res://assets/fonts/silkscreen/Silkscreen-Regular.ttf")
	plates.layer = 8
	add_child(plates)
	get_tree().node_added.connect(_prepare_text)
	call_deferred("_prepare_existing_labels")
	get_window().min_size = Vector2i(640,360)
	if DisplayServer.get_name()=="headless": return
	# Respetar --resolution al ejecutar capturas y pruebas de otros tamaños.
	if "--resolution" not in OS.get_cmdline_args():
		var usable := DisplayServer.screen_get_usable_rect()
		var available := usable.size-Vector2i(32,64)
		var factor := minf(1.0,minf(float(available.x)/1920.0,float(available.y)/1080.0))
		get_window().size = Vector2i(640,360) * maxi(1, floori(factor * 3))
		get_window().position = usable.position+(usable.size-get_window().size)/2
	windowed_size = get_window().size
	windowed_position = get_window().position

func _prepare_existing_labels() -> void:
	await get_tree().process_frame
	var scene := get_tree().current_scene
	if scene == null:
		return
	for label in scene.find_children("*", "Label", true, false):
		_prepare_text(label)

func _prepare_text(node: Node) -> void:
	if node is Label and node.get_parent() is Node2D and not node.get_meta("world_text_plate_attached", false):
		node.set_meta("world_text_plate_attached", true)
		var plate := preload("res://scripts/ui/world_plate.gd").new()
		plates.add_child(plate)
		plate.bind(node)
	if node is Label:
		node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		if node.has_theme_font_size_override("font_size") and not node.get_meta("world_pixel_font", false):
			node.add_theme_font_size_override("font_size", maxi(4, roundi(node.get_theme_font_size("font_size"))))

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_F11:
		toggle_fullscreen()
		get_viewport().set_input_as_handled()

func toggle_fullscreen() -> void:
		if get_window().mode==Window.MODE_FULLSCREEN:
			get_window().mode = Window.MODE_WINDOWED
			get_window().size = windowed_size
			get_window().position = windowed_position
		else:
			windowed_size = get_window().size
			windowed_position = get_window().position
			get_window().mode = Window.MODE_FULLSCREEN
		get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	var candidates: Array = []
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if not is_instance_valid(player):
		return
	var feet := player.get_global_transform_with_canvas().origin
	for plate in plates.get_children():
		if plate.visible:
			candidates.append(plate)
	candidates.sort_custom(func(a, b):
		return a.position.distance_squared_to(feet) < b.position.distance_squared_to(feet))
	var occupied: Array[Rect2] = []
	for plate in candidates:
		var area: Rect2 = plate.get_global_rect().grow(2)
		var blocked := false
		for other in occupied:
			if area.intersects(other):
				blocked = true
				break
		plate.modulate.a = 0.0 if blocked else 1.0
		if not blocked:
			occupied.append(area)
