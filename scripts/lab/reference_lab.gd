extends Node2D
## Pista de comparación: mismas coordenadas y superficies superiores que el HTML.
@onready var player: KoraPlayer = $Player
@onready var dummy: Node2D = $Dummy
var status: Label
var details: Label
var panel: PanelContainer

func _ready() -> void:
	GameManager.campaign_active = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	player.process_mode = Node.PROCESS_MODE_PAUSABLE
	dummy.process_mode = Node.PROCESS_MODE_PAUSABLE
	player.show_body = true
	_build_ui()

func _build_ui() -> void:
	var hud := CanvasLayer.new()
	add_child(hud)
	var top := ColorRect.new()
	top.color = Color("0c1525")
	top.size = Vector2(640,80)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(top)
	var title := Label.new()
	title.text = "KORA / LABORATORIO DE REFERENCIA"
	title.position = Vector2(12,5)
	title.add_theme_font_size_override("font_size",17)
	title.modulate = Color("8ce5dc")
	hud.add_child(title)
	var controls := Label.new()
	controls.text = "J/clic: combo · I/U/Y/clic der.: fuerte · K/E/X: dash · B: saco · P: pausa\nA/D: mover · Espacio: salto · F4: ajustes · F1: galería · Tab: menú"
	controls.position = Vector2(12,31)
	controls.add_theme_font_size_override("font_size",10)
	controls.add_theme_constant_override("line_spacing",-2)
	hud.add_child(controls)
	var bottom := ColorRect.new()
	bottom.position = Vector2(0,311)
	bottom.size = Vector2(640,49)
	bottom.color = Color("0c1525")
	bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(bottom)
	status = Label.new()
	status.position = Vector2(12,313)
	status.add_theme_font_size_override("font_size",11)
	hud.add_child(status)
	details = Label.new()
	details.position = Vector2(12,337)
	details.add_theme_font_size_override("font_size",10)
	hud.add_child(details)
	panel = PanelContainer.new()
	panel.position = Vector2(367,80)
	panel.size = Vector2(267,229)
	hud.add_child(panel)
	var scroll := ScrollContainer.new()
	panel.add_child(scroll)
	var list := VBoxContainer.new()
	list.custom_minimum_size.x = 240
	scroll.add_child(list)
	_button(list,"Cerrar ajustes / F4",func() -> void: panel.hide())
	_button(list,"Pausar / Reanudar",func() -> void: get_tree().paused = not get_tree().paused)
	_button(list,"Avanzar un fotograma",func() -> void:
		get_tree().paused = true
		player.step_motion(1.0/60.0,player.poll_input())
		player.effects._physics_process(1.0/60.0)
		dummy._physics_process(1.0/60.0))
	for state in ["combo_1","combo_2","combo_3","combo_1_end"]:
		_button(list,state,player.force_combo.bind(state))
	_button(list,"Dash",player.force_dash)
	_button(list,"Recolocar saco / B",_spawn_dummy)
	_button(list,"Reiniciar posición / R",player.respawn)
	var selector := OptionButton.new()
	for state in ["none"] + player.motion.FRAMES.keys(): selector.add_item(state)
	selector.item_selected.connect(func(index: int) -> void:
		player.motion.force_state = selector.get_item_text(index)
		if index > 0: player.motion.set_state(player.motion.force_state))
	list.add_child(selector)
	_slider(list,"Caminar",50,250,player.walk_speed,func(value: float) -> void: player.walk_speed = value)
	_slider(list,"Correr",120,400,player.move_speed,func(value: float) -> void: player.move_speed = value)
	_slider(list,"Salto",200,600,player.jump_force,func(value: float) -> void: player.jump_force = value)
	_slider(list,"Gravedad",400,1800,player.gravity,func(value: float) -> void: player.gravity = value)
	_slider(list,"Escala",1,4,3,func(value: float) -> void: player.visual_scale = value)
	for state in ["idle","walk","run"]:
		_slider(list,"FPS " + state,2,30,player.motion.fps_overrides[state],func(value: float) -> void: player.motion.fps_overrides[state] = value)
	_button(list,"Mostrar colisión / C",func() -> void: player.set_debug_body(not player.show_body))
	_button(list,"Mostrar celda 128×128",func() -> void: player.show_sprite_box = not player.show_sprite_box)
	panel.hide()
	preload("res://scripts/ui/display_layout.gd").apply(hud)

func _button(parent: Node, text: String, callable: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size",12)
	button.pressed.connect(callable)
	parent.add_child(button)

func _slider(parent: Node, title: String, minimum: float, maximum: float, value: float, callable: Callable) -> void:
	var label := Label.new()
	label.text = "%s: %.0f" % [title,value]
	label.add_theme_font_size_override("font_size",12)
	parent.add_child(label)
	var slider := HSlider.new()
	slider.min_value = minimum
	slider.max_value = maximum
	slider.value = value
	slider.value_changed.connect(func(v: float) -> void:
		label.text = "%s: %.0f" % [title,v]
		callable.call(v))
	parent.add_child(slider)

func _process(_delta: float) -> void:
	status.text = "%s · frame %d/%d · Vx %.1f / Vy %.1f · %s" % [player.motion.state,player.motion.frame_index+1,player.motion.FRAMES[player.motion.state],player.velocity.x,player.velocity.y,"Suelo" if player.motion.grounded else "Aire"]
	details.text = "Dash: %.2f s · Saco: %d/100 · %s" % [maxf(0,player.motion.dash_cooldown),dummy.health,"PAUSA" if get_tree().paused else "Listo · mando A salto / X combo / Y fuerte / B-RB-RT dash / LB correr"]

func _spawn_dummy() -> void:
	dummy.position = Vector2(player.position.x+180*player.motion.facing,400)
	dummy.health = 100

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("records"):
		get_tree().paused = false
		GameManager.menu()
	elif event.is_action_pressed("gallery"):
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/lab/sprite_gallery.tscn")
	elif event.is_action_pressed("pause"):
		get_tree().paused = not get_tree().paused
	elif event.is_action_pressed("spawn_dummy"):
		_spawn_dummy()
	elif event.is_action_pressed("debug_collision"):
		player.set_debug_body(not player.show_body)
	elif event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_F4:
		panel.visible = not panel.visible

func _draw() -> void:
	for x in range(-1000,2001,50): draw_line(Vector2(x,-300),Vector2(x,600),Color("16253b"))
	for y in range(-300,601,50): draw_line(Vector2(-1000,y),Vector2(2000,y),Color("16253b"))
