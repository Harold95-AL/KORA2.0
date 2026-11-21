extends Node
## Ventana Full HD con reducción automática al área útil del monitor.
var windowed_size := Vector2i(1920,1080)
var windowed_position := Vector2i.ZERO

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Texto del mundo legible con el zoom de cámara y en ventanas reducidas.
	var scalable_font := ThemeDB.fallback_font.duplicate() as FontFile
	scalable_font.multichannel_signed_distance_field = true
	ThemeDB.fallback_font = scalable_font
	ThemeDB.get_default_theme().default_font = scalable_font
	var native_theme: Theme = preload("res://resources/ui/full_hd_theme.tres")
	native_theme.default_font = scalable_font
	get_tree().node_added.connect(_prepare_text)
	get_window().min_size = Vector2i(640,360)
	if DisplayServer.get_name()=="headless": return
	# Respetar --resolution al ejecutar capturas y pruebas de otros tamaños.
	if "--resolution" not in OS.get_cmdline_args():
		var usable := DisplayServer.screen_get_usable_rect()
		var available := usable.size-Vector2i(32,64)
		var factor := minf(1.0,minf(float(available.x)/1920.0,float(available.y)/1080.0))
		get_window().size = Vector2i(Vector2(1920,1080)*factor)
		get_window().position = usable.position+(usable.size-get_window().size)/2
	windowed_size = get_window().size
	windowed_position = get_window().position

func _prepare_text(node: Node) -> void:
	if node is Label:
		node.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_F11:
		if get_window().mode==Window.MODE_FULLSCREEN:
			get_window().mode = Window.MODE_WINDOWED
			get_window().size = windowed_size
			get_window().position = windowed_position
		else:
			windowed_size = get_window().size
			windowed_position = get_window().position
			get_window().mode = Window.MODE_FULLSCREEN
		get_viewport().set_input_as_handled()
