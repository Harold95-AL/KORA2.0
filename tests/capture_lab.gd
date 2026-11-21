extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func capture(file: String) -> void:
	for i in range(3): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.local/" + file + ".png")

func run() -> void:
	var lab = load("res://scenes/lab/reference_lab.tscn").instantiate()
	root.add_child(lab)
	current_scene = lab
	for i in range(10): await process_frame
	var player = lab.player
	player.set_physics_process(false)
	player.effects.set_physics_process(false)
	await capture("lab-referencia")
	lab.dummy.position.x = 42
	player.force_combo("combo_3")
	for i in range(8): player.step_motion(1.0/60.0,{})
	await capture("lab-impacto")
	player.force_dash()
	for i in range(5): player.step_motion(1.0/60.0,{})
	await capture("lab-dash")
	lab.panel.show()
	await capture("lab-ajustes")
	print("Capturas de referencia, impacto, dash y ajustes guardadas.")
	quit()
