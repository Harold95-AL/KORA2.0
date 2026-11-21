extends CanvasLayer
## Interfaz compartida. Funciona durante pausa, transición y diálogos manuales.
var hud: Control
var heading: Label
var objective: Label
var tasks: Label
var prompt: Label
var controls: Label
var notice: Label
var boss_bar: ProgressBar
var boss_title: Label
var overlay: Control
var overlay_list: VBoxContainer
var dialogue_panel: Panel
var dialogue_title: Label
var dialogue_text: Label
var dialogue_hint: Label
var veil: ColorRect
var pending: Array[Dictionary] = []
var current: Dictionary = {}
var line_index := 0
var line_time: float = 0.0
var notice_time: float = 0.0
var nearest: Node2D
var dash_status: Label

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 50
	hud = Control.new()
	add_child(hud)
	var top := _panel(hud, Rect2(0, 0, 640, 72), Color("0c1525"))
	heading = _label(top, Rect2(14, 5, 610, 20), 13, Color("8ce5dc"))
	objective = _label(top, Rect2(14, 25, 610, 20), 13)
	tasks = _label(top, Rect2(14, 46, 610, 24), 11, Color("b1bed3"))
	dash_status = _label(top,Rect2(420,5,205,20),11,Color("8ce5dc"))
	dash_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var bottom := _panel(hud, Rect2(0, 336, 640, 24), Color("0c1525"))
	controls = _label(bottom, Rect2(10, 1, 625, 22), 10)
	controls.text = "A/D mover · Espacio salto · J ataque · I fuerte · K/E/X dash · F usar · Tab archivo · Esc pausa · F1 secciones"
	prompt = _label(hud, Rect2(65, 306, 510, 28), 12, Color("fff0bb"))
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notice = _label(hud, Rect2(60, 251, 520, 50), 12, Color("aee9ff"))
	notice.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_bar = ProgressBar.new()
	boss_bar.position = Vector2(190, 92)
	boss_bar.size = Vector2(260, 10)
	boss_bar.show_percentage = false
	var bar_background := StyleBoxFlat.new()
	bar_background.bg_color = Color("29374e")
	var bar_fill := StyleBoxFlat.new()
	bar_fill.bg_color = Color("ec929c")
	boss_bar.add_theme_stylebox_override("background", bar_background)
	boss_bar.add_theme_stylebox_override("fill", bar_fill)
	hud.add_child(boss_bar)
	boss_title = _label(hud, Rect2(140, 74, 360, 20), 12, Color("ffbbbf"))
	boss_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dialogue_panel = _panel(self, Rect2(18, 188, 604, 144), Color("14253c"))
	dialogue_title = _label(dialogue_panel, Rect2(14, 8, 575, 21), 14, Color("83e3d7"))
	dialogue_text = _label(dialogue_panel, Rect2(14, 32, 575, 82), 13)
	dialogue_hint = _label(dialogue_panel, Rect2(14, 123, 575, 19), 10, Color("acb9d0"))
	dialogue_panel.hide()
	overlay = Control.new()
	add_child(overlay)
	_panel(overlay, Rect2(0, 0, 640, 360), Color("0b1424"))
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(30, 18)
	scroll.size = Vector2(580, 324)
	overlay.add_child(scroll)
	overlay_list = VBoxContainer.new()
	overlay_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	overlay_list.add_theme_constant_override("separation", 8)
	scroll.add_child(overlay_list)
	overlay.hide()
	veil = ColorRect.new()
	veil.size = Vector2(640, 360)
	veil.color = Color(0, 0, 0, 0)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(veil)
	preload("res://scripts/ui/display_layout.gd").apply(self)

func _panel(parent: Node, rect: Rect2, color: Color) -> Panel:
	var panel := Panel.new()
	panel.position = rect.position
	panel.size = rect.size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = color
	panel.add_theme_stylebox_override("panel", style)
	parent.add_child(panel)
	return panel

func _label(parent: Node, rect: Rect2, font_size: int, color: Color = Color("e3eaf5")) -> Label:
	var label := Label.new()
	label.position = rect.position
	label.size = rect.size
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_constant_override("line_spacing", -2)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func _process(delta: float) -> void:
	hud.visible = GameManager.campaign_active
	if GameManager.campaign_active:
		var explorer = get_tree().get_first_node_in_group("player")
		if is_instance_valid(explorer):
			dash_status.text = "DASH: ATERRIZA" if explorer.air_dash_spent else ("DASH: %.1f s" % maxf(0,explorer.motion.dash_cooldown) if explorer.motion.dash_cooldown>0 else "DASH LISTO")
	if notice_time > 0.0 and not get_tree().paused:
		notice_time -= delta
	notice.visible = notice_time > 0.0 and current.is_empty()
	dialogue_panel.visible = not current.is_empty() and not overlay.visible
	if not current.is_empty() and not bool(current["blocking"]) and not overlay.visible:
		line_time -= delta
		if line_time <= 0.0:
			advance_dialogue()
	if not GameManager.campaign_active or GameManager.section_index < 0:
		return
	var section: Dictionary = GameManager.sections[GameManager.section_index]
	heading.text = "%s  ·  %s                      ENERGÍA %d/%d" % [section["id"], section["title"], GameManager.health, GameManager.MAX_HEALTH]
	objective.text = section["objective"]
	var remaining: Array[String] = []
	for task in section["tasks"]:
		if not GameManager.has_key(task["key"]):
			remaining.append(task["label"])
	tasks.text = "Siguiente: " + remaining[0] if not remaining.is_empty() else "Objetivo cumplido · Busca la salida →"
	nearest = null
	var player := get_tree().get_first_node_in_group("player") as Node2D
	var distance := INF
	if is_instance_valid(player):
		for candidate in get_tree().get_nodes_in_group("interactables"):
			if candidate.can_interact():
				var value: float = player.global_position.distance_squared_to(candidate.global_position)
				if value < distance:
					distance = value
					nearest = candidate
	prompt.text = "[F] " + nearest.title if is_instance_valid(nearest) else ""
	prompt.visible = current.is_empty()
	var boss := get_tree().get_first_node_in_group("active_boss")
	boss_bar.visible = is_instance_valid(boss)
	boss_title.visible = is_instance_valid(boss)
	if is_instance_valid(boss):
		boss_bar.max_value = boss.max_health
		boss_bar.value = boss.health
		boss_title.text = "%s · FASE %d · %s" % [boss.display_name, boss.phase, boss.state_label()]

func toast(text: String, seconds: float = 3.5) -> void:
	notice.text = text
	notice_time = seconds

func interact_nearest() -> void:
	if is_instance_valid(nearest) and not overlay.visible and (current.is_empty() or not bool(current["blocking"])) and not GameManager.transitioning:
		nearest.interact()

func dialogue(title: String, lines: Array, blocking: bool) -> void:
	pending.append({"title": title, "lines": lines, "blocking": blocking})
	if current.is_empty():
		_next_dialogue()

func _next_dialogue() -> void:
	if pending.is_empty():
		current = {}
		_sync_pause()
		return
	current = pending.pop_front()
	line_index = 0
	_show_line()
	_sync_pause()

func _show_line() -> void:
	dialogue_title.text = current["title"]
	dialogue_text.text = current["lines"][line_index]
	dialogue_hint.text = "F / Enter: siguiente · Esc: cerrar   %d/%d" % [line_index + 1, current["lines"].size()] if current["blocking"] else "LUMA · transmisión en movimiento"
	line_time = maxf(4.5, float(dialogue_text.text.length()) * 0.045)

func advance_dialogue() -> void:
	if current.is_empty():
		return
	line_index += 1
	if line_index >= current["lines"].size():
		current = {}
		_next_dialogue()
	else:
		_show_line()

func clear_dialogues() -> void:
	pending.clear()
	current = {}
	notice_time = 0.0
	_sync_pause()

func _sync_pause() -> void:
	get_tree().paused = overlay.visible or (not current.is_empty() and bool(current["blocking"]))

func close_overlay() -> void:
	overlay.hide()
	_sync_pause()

func _begin_overlay(title: String) -> void:
	for child in overlay_list.get_children():
		overlay_list.remove_child(child)
		child.queue_free()
	var label := Label.new()
	label.text = title
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color("8ce5dc"))
	overlay_list.add_child(label)
	preload("res://scripts/ui/display_layout.gd").apply(label)
	overlay.show()
	_sync_pause()

func _button(text: String, action: Callable, parent: Node = null) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 27
	button.add_theme_font_size_override("font_size", 12)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(action)
	(parent if parent != null else overlay_list).add_child(button)
	preload("res://scripts/ui/display_layout.gd").apply(button)
	return button

func show_pause() -> void:
	_begin_overlay("KORA / PAUSA")
	_button("Continuar", close_overlay)
	_button("Reiniciar desde checkpoint", func() -> void: close_overlay(); GameManager.respawn())
	_button("Registros encontrados", show_records)
	_button("Selector de secciones · F1", show_selector)
	_button("Menú principal", func() -> void: close_overlay(); GameManager.menu())

func show_selector() -> void:
	_begin_overlay("SECCIONES / PRUEBAS")
	var hint := Label.new()
	hint.text = "Entrada limpia a la sección elegida. Se reinician sus mecanismos y checkpoint."
	hint.add_theme_font_size_override("font_size", 11)
	overlay_list.add_child(hint)
	preload("res://scripts/ui/display_layout.gd").apply(hint)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 4)
	overlay_list.add_child(grid)
	preload("res://scripts/ui/display_layout.gd").apply(grid)
	for index in range(GameManager.sections.size()):
		var section: Dictionary = GameManager.sections[index]
		_button(section["id"] + " · " + section["title"], func() -> void:
			close_overlay()
			GameManager.goto_section(index, true), grid)
	_button("Prólogo", func() -> void:
		close_overlay()
		GameManager.campaign_active = false
		GameManager.change_scene("res://levels/Prologue.tscn"), grid)
	_button("Epílogo", func() -> void:
		close_overlay()
		GameManager.campaign_active = false
		GameManager.change_scene("res://levels/Epilogue.tscn"), grid)
	_button("Volver", close_overlay)

func show_records() -> void:
	_begin_overlay("MEMORIAS / ARCHIVO")
	if NarrativeManager.records.is_empty():
		_button("Aún no hay registros. Busca los cristales violetas.", close_overlay)
	for id in NarrativeManager.records:
		_button(NarrativeManager.content[id]["title"], func() -> void:
			close_overlay()
			NarrativeManager.read_record(id))
	_button("Volver", close_overlay)

func _unhandled_input(event: InputEvent) -> void:
	if GameManager.transitioning:
		return
	if not current.is_empty() and bool(current["blocking"]):
		if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
			advance_dialogue()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("pause"):
			current = {}
			_next_dialogue()
			get_viewport().set_input_as_handled()
		return
	if not GameManager.campaign_active:
		if overlay.visible and (event.is_action_pressed("pause") or event.is_action_pressed("gallery")):
			close_overlay()
			get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("gallery"):
		if overlay.visible:
			close_overlay()
		else:
			show_selector()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("pause"):
		if overlay.visible:
			close_overlay()
		else:
			show_pause()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("records"):
		if overlay.visible:
			close_overlay()
		else:
			show_records()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("debug_collision"):
		var player := get_tree().get_first_node_in_group("player") as KoraPlayer
		if player:
			player.set_debug_body(not player.show_body)

func fade(alpha: float) -> void:
	var tween := create_tween()
	tween.tween_property(veil, "color:a", alpha, 0.22)
	await tween.finished
