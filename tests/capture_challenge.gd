extends SceneTree
var gm: Node
var ui: Node

func _initialize() -> void:
	call_deferred("run")

func frames(count: int) -> void:
	for i in range(count):
		await physics_frame
		await process_frame

func capture(file: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.local/"+file+".png")

func run() -> void:
	gm = root.get_node("GameManager")
	ui = root.get_node("GameUI")
	gm.instant_transitions = true
	gm.goto_section(0,true)
	await frames(10)
	ui.clear_dialogues()
	var player = current_scene.get_node("Player")
	player.position = Vector2(182,320)
	player.velocity = Vector2.ZERO
	player.camera_initialized = false
	await frames(3)
	await capture("reto-salto-antes")
	player.velocity.x = 210
	Input.action_press("move_right")
	Input.action_press("jump")
	await frames(20)
	Input.action_press("dash")
	await frames(5)
	await capture("reto-dash")
	for action in ["move_right","jump","dash"]: Input.action_release(action)
	gm.goto_section(11,true)
	await frames(10)
	ui.clear_dialogues()
	player = current_scene.get_node("Player")
	player.position = Vector2(2840,320)
	player.set_physics_process(false)
	player.camera_initialized = false
	player._update_camera()
	var boss: Node
	for actor in current_scene.get_node("Entities").get_children():
		if actor.get_script()==load("res://scripts/entities/boss.gd"): boss = actor
	boss.active = true
	boss.player = player
	boss.move_index = 2
	boss._warn()
	boss.add_to_group("active_boss")
	boss.queue_redraw()
	boss.set_physics_process(false)
	await frames(3)
	ui.clear_dialogues()
	await capture("reto-marca-jefe")
	print("Capturas del salto, dash y aviso del jefe listas.")
	quit()
