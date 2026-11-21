extends SceneTree
## Ejecutar con VERIFICAR_PROYECTO.bat. No requiere plugins de pruebas.

var failures: int = 0

func _initialize() -> void:
	call_deferred("_run")

func check(condition: bool, message: String) -> void:
	if condition:
		print("OK: ", message)
	else:
		failures += 1
		push_error(message)

func frames(count: int) -> void:
	for index in range(count):
		await physics_frame
		await process_frame

func _run() -> void:
	var lab := load("res://scenes/lab/sprite_lab.tscn").instantiate() as Node2D
	root.add_child(lab)
	current_scene = lab
	await frames(10)
	var player = lab.get_node("Player")
	var atlas: SpriteFrames = player.sprite.sprite_frames
	check(atlas.get_animation_names().size() == 12, "12 animaciones del personaje disponibles")
	check(atlas.has_animation("dash") and atlas.get_frame_count("dash") == 9 and atlas.get_animation_speed("dash") == 18.0, "Dash usa sus nueve fotogramas a 18 FPS")
	check(atlas.has_animation("design") and atlas.get_frame_count("design") == 1, "Sprite de referencia de diseño disponible en SpriteFrames")
	check(atlas.has_animation("walk"), "Caminar analógico y transición del HTML disponibles")
	check(InputMap.has_action("run") and InputMap.has_action("dash") and InputMap.has_action("heavy_attack"), "Modificador, dash y golpe fuerte del HTML")
	var frame_count := 0
	for animation in atlas.get_animation_names():
		frame_count += atlas.get_frame_count(animation)
		for index in range(atlas.get_frame_count(animation)):
			check(atlas.get_frame_texture(animation, index).get_size() == Vector2(128, 128), "%s/%d: recorte 128x128" % [animation, index])
	check(frame_count == 84, "84 fotogramas del personaje")
	check(player.is_on_floor(), "Jugador apoyado en el suelo")
	Input.action_press("move_right")
	player.force_dash()
	await frames(1)
	check(player.sprite.animation==&"dash" and player.motion.is_dashing,"El dash reproduce su propia animación durante el impulso")
	for i in range(15): await frames(1)
	check(player.sprite.animation==&"run" and not player.motion.is_dashing,"La animación de correr se mantiene al terminar el impulso de dash")
	Input.action_release("move_right")
	player.respawn()
	await frames(3)
	var origin: Vector2 = player.position
	Input.action_press("move_right")
	await frames(30)
	check(player.sprite.animation == &"run" and absf(player.velocity.x - 210.0) < 1.0, "Correr a 210 px/s pulsando solo dirección")
	var shift_event := InputEventKey.new()
	shift_event.physical_keycode = KEY_SHIFT
	shift_event.pressed = true
	Input.parse_input_event(shift_event)
	await frames(2)
	check(player.sprite.animation == &"run" and absf(player.velocity.x - 210.0) < 1.0, "El teclado ya corre sin necesitar Shift")
	shift_event.pressed = false
	Input.parse_input_event(shift_event)
	Input.action_release("move_right")
	check(player.position.x > origin.x + 35.0, "Movimiento horizontal con colisiones")
	await frames(15)
	check(player.sprite.animation == &"idle", "Reposo al soltar la dirección")
	player.respawn()
	await frames(3)
	Input.action_press("jump")
	var highest: float = player.position.y
	for index in range(50):
		await frames(1)
		highest = minf(highest, player.position.y)
	Input.action_release("jump")
	check(origin.y - highest > 65.0 and origin.y - highest < 82.0, "Altura del salto conservada (~76 px teóricos)")
	await frames(20)
	check(player.is_on_floor(), "Aterrizaje después del salto")
	Input.action_press("attack")
	await frames(2)
	Input.action_release("attack")
	check(player.sprite.animation == &"combo_1", "Inicio de combo con J")
	await frames(1) # Soltar debe llegar al detector de flancos del HTML.
	Input.action_press("attack")
	await frames(2)
	Input.action_release("attack")
	await frames(17)
	check(player.sprite.animation == &"combo_2", "Segundo golpe encadenado")
	Input.action_press("attack")
	await frames(2)
	Input.action_release("attack")
	await frames(25)
	check(player.sprite.animation == &"combo_3", "Tercer golpe encadenado")
	await frames(55)
	check(player.sprite.animation == &"idle", "Combo termina y devuelve el control")
	player.position.y = 700
	await frames(3)
	check(player.position.distance_to(origin) < 2.0, "Caída fuera del escenario reinicia posición")
	for pair in [["gallery", KEY_F1], ["debug_collision", KEY_F2]]:
		var event := InputMap.action_get_events(pair[0])[0] as InputEventKey
		check(event.physical_keycode == pair[1], "Asignación de tecla: " + pair[0])
	var pause_event := InputEventAction.new()
	pause_event.action = "pause"
	pause_event.pressed = true
	lab._unhandled_input(pause_event)
	check(paused, "Pausa activada")
	lab._unhandled_input(pause_event)
	check(not paused, "Pausa desactivada")
	if "--capture" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.godot/laboratorio.png")
	lab._open_gallery()
	await frames(6)
	var gallery := current_scene
	check(gallery.name == "SpriteGallery", "F1 abre la galería")
	gallery._select_animation(gallery.ANIMATIONS.find(&"combo_3"))
	check(gallery.get_node("Preview").animation == &"combo_3", "Galería selecciona animaciones")
	gallery._set_zoom(2)
	check(gallery.get_node("Preview").scale == Vector2(9, 9), "Ampliación de sprites 3x dentro de la interfaz Full HD")
	if "--capture" in OS.get_cmdline_user_args():
		gallery._select_animation(0)
		gallery._set_zoom(1)
		await frames(3)
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.godot/galeria.png")
	gallery._go_back()
	await frames(6)
	check(current_scene.name == "ReferenceLab", "Regreso al laboratorio de referencia")
	print("RESULTADO: ", failures, " fallos")
	quit(0 if failures == 0 else 1)
