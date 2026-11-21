extends SceneTree
## Ejecutar con renderizado para comprobar la ventana real y tomar capturas.
var failures := 0
var gm: Node
var ui: Node

func _initialize() -> void:
	call_deferred("run")

func frames(count := 5) -> void:
	for i in range(count): await process_frame

func check(ok: bool, label: String) -> void:
	if ok: print("OK PANTALLA: ",label)
	else:
		failures += 1
		push_error(label)

func capture(label: String) -> void:
	await frames()
	await RenderingServer.frame_post_draw
	var screenshot := root.get_texture().get_image()
	var ratio := minf(root.size.x/1920.0,root.size.y/1080.0)
	var content_size := Vector2i(Vector2(1920,1080)*ratio)
	check(screenshot.get_size()==content_size,"Render nativo del área 16:9 " + str(root.size))
	screenshot.save_png("res://.local/1080-"+label+".png")

func contained(control: Control) -> bool:
	return Rect2(Vector2.ZERO,Vector2(1920,1080)).encloses(control.get_global_rect())

func run() -> void:
	gm = root.get_node("GameManager")
	ui = root.get_node("GameUI")
	gm.instant_transitions = true
	check(root.content_scale_size==Vector2i(1920,1080),"Base 1920 × 1080")
	check(root.content_scale_mode==Window.CONTENT_SCALE_MODE_CANVAS_ITEMS,"Render del canvas a resolución de ventana")
	for resolution in [Vector2i(1920,1080),Vector2i(1280,720),Vector2i(960,540),Vector2i(800,600),Vector2i(640,360)]:
		root.size = resolution
		await frames()
		gm.menu()
		await frames()
		var tag := "%dx%d" % [resolution.x,resolution.y]
		check(contained(current_scene.get_node("NewGame")) and contained(current_scene.get_node("Footer")),"Menú contenido " + tag)
		check(current_scene.get_node("Title").get_theme_font_size("font_size")==120,"Fuente nativa del título")
		await capture("menu-"+tag)
		ui.show_selector()
		await frames()
		check(contained(ui.overlay_list),"Selector accesible " + tag)
		await capture("selector-"+tag)
		ui.close_overlay()
		gm.goto_section(0,true)
		await frames(10)
		ui.clear_dialogues()
		var player = current_scene.get_node("Player")
		player.position = Vector2(182,320)
		player.velocity = Vector2.ZERO
		player._update_camera()
		check(player.get_node("Camera2D").zoom==Vector2(4.5,4.5),"Encuadre estable " + tag)
		check(contained(ui.controls) and contained(ui.dash_status),"HUD contenido " + tag)
		await capture("juego-"+tag)
		var dialogue: Dictionary = root.get_node("NarrativeManager").content["STORY_15"]
		ui.dialogue(dialogue.title,dialogue.lines,true)
		await frames()
		check(ui.dialogue_panel.visible and contained(ui.dialogue_panel),"Diálogo visible y contenido " + tag)
		check(ui.dialogue_text.get_line_count()<=ui.dialogue_text.get_visible_line_count(),"Texto del diálogo completo " + tag)
		await capture("dialogo-"+tag)
		ui.clear_dialogues()
	gm.campaign_active = false
	gm.change_scene("res://levels/Prologue.tscn")
	await frames()
	await capture("prologo-640x360")
	gm.change_scene("res://scenes/lab/reference_lab.tscn")
	await frames()
	current_scene.panel.show()
	await capture("laboratorio-640x360")
	gm.change_scene("res://scenes/lab/sprite_gallery.tscn")
	await frames()
	await capture("galeria-640x360")
	var toggle := InputEventKey.new()
	toggle.physical_keycode = KEY_F11
	toggle.pressed = true
	root.get_node("DisplaySettings")._input(toggle)
	check(root.mode==Window.MODE_FULLSCREEN,"F11 activa pantalla completa")
	root.get_node("DisplaySettings")._input(toggle)
	check(root.mode==Window.MODE_WINDOWED and root.size==Vector2i(640,360),"F11 restaura la ventana anterior")
	print("PANTALLA: ",failures," fallos")
	quit(0 if failures==0 else 1)
