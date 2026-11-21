extends SceneTree
## Capturas reproducibles con renderizado; no modifica las escenas.
var gm: Node
var ui: Node

func _initialize() -> void:
	call_deferred("run")

func frames(count: int) -> void:
	for i in range(count):
		await process_frame

func capture(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/" + name + ".png")

func run() -> void:
	gm = root.get_node("GameManager")
	ui = root.get_node("GameUI")
	gm.instant_transitions = true
	gm.menu()
	await frames(15)
	await capture("campaign_menu")
	var positions := [Vector2(480,320), Vector2(620,320), Vector2(1360,360), Vector2(3220,320), Vector2(2470,320), Vector2(2890,320), Vector2(3010,400), Vector2(3100,320), Vector2(720,1020), Vector2(3370,320), Vector2(2740,320), Vector2(2910,320)]
	for index in range(12):
		gm.goto_section(index, true)
		await frames(10)
		ui.clear_dialogues()
		var player = current_scene.get_node("Player")
		player.position = positions[index]
		player.velocity = Vector2.ZERO
		player.camera_initialized = false
		player._update_camera()
		player.invulnerability = 999.0
		player.set_physics_process(false)
		await frames(12)
		ui.clear_dialogues()
		await frames(3)
		await capture("campaign_%02d" % index)
	ui.show_selector()
	await frames(3)
	await capture("campaign_selector")
	ui.close_overlay()
	root.get_node("NarrativeManager").trigger("STORY_18")
	await frames(3)
	await capture("campaign_dialogue")
	ui.clear_dialogues()
	root.get_node("NarrativeManager").trigger("STORY_15")
	await frames(3)
	await capture("campaign_long_dialogue")
	ui.clear_dialogues()
	gm.campaign_active = false
	gm.change_scene("res://levels/Epilogue.tscn")
	await frames(10)
	await capture("campaign_epilogue")
	current_scene._finish()
	await frames(3)
	await capture("campaign_credits")
	print("Capturas de 12 secciones, menú, selector, diálogo y epílogo listas.")
	quit()
